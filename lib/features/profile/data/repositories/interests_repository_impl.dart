import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '/core/utils/idempotency_service.dart';
import '../../domain/repositories/i_interests_repository.dart';
import '../../domain/entities/interest.dart';
import '../../domain/failures/profile_failure.dart';
import '/services/cache/unified_cache_service.dart';
import '/services/cache/failures/cache_failure.dart';

/// InterestsRepository 구현 (Clean Architecture v4.0)
///
/// **Phase 4: Firebase-Centric v2.0 전환** (2025-01-29):
/// - DataSource 제거 → FirebaseFirestore 직접 사용
/// - FieldValue.arrayUnion/arrayRemove 직접 호출
/// - Auth Feature 패턴 100% 일치
/// - _mapFirebaseException() 메서드 추가
///
/// **책임**:
/// - Firebase SDK를 통한 직접 관심사 데이터 접근
/// - List<String> ↔ List<Interest> 변환
/// - 제약사항 검증 (expertise 최대 4개, hobbies 최대 8개)
/// - 에러 처리
class InterestsRepositoryImpl implements IInterestsRepository {
  final FirebaseFirestore _firestore;
  final IdempotencyService _idempotencyService;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

  InterestsRepositoryImpl({
    FirebaseFirestore? firestore,
    IdempotencyService? idempotencyService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _idempotencyService = idempotencyService ?? IdempotencyService();

  // ============= 관심사 관리 =============

  @override
  Future<Either<ProfileFailure, Unit>> updateUserInterests(
    String userId,
    List<Interest> interests, {
    String? eventId,
  }) async {
    try {
      debugPrint('[InterestsRepository] Updating interests for: $userId');

      // 제약사항 검증
      final expertise =
          interests.where((i) => i.category == 'expertise').toList();
      final hobbies = interests.where((i) => i.category == 'hobby').toList();

      if (expertise.length > 4) {
        debugPrint('[InterestsRepository] Validation failed: Too many expertise (${expertise.length})');
        return left(ProfileFailure.validation('expertise'));
      }

      if (hobbies.length > 8) {
        debugPrint('[InterestsRepository] Validation failed: Too many hobbies (${hobbies.length})');
        return left(ProfileFailure.validation('hobbies'));
      }

      // Interest 리스트를 Firestore interests 배열로 변환
      final interestNames = interests.map((i) => i.name).toList();

      // IdempotencyService로 래핑
      if (eventId != null && eventId.isNotEmpty) {
        await _idempotencyService.executeIdempotent<void>(
          entityType: 'interest_updates',
          entityId: userId,
          userId: userId,
          eventId: eventId,
          operation: (transaction) async {
            // Transaction 내부에서 update
            final docRef = _firestore.collection('users').doc(userId);
            transaction.update(docRef, {'interests': interestNames});
          },
        );
      } else {
        // eventId 없으면 기존 로직 (backward compatibility)
        await _firestore.collection('users').doc(userId).update({
          'interests': interestNames,
        });
      }

      // 🔥 캐시 무효화 (다음 조회 시 최신 데이터 가져오도록)
      await _cacheService.clearUserInterests(userId);

      debugPrint('[InterestsRepository] Interests updated successfully, cache cleared');
      return right(unit);
    } on IdempotencyViolation catch (e) {
      debugPrint('[InterestsRepository] Idempotency violation: $e');
      return left(ProfileFailure.duplicateOperation('Interests already updated: ${e.message}'));
    } on FirebaseException catch (e) {
      debugPrint('[InterestsRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[InterestsRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to update user interests: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, List<Interest>>> getUserInterests(
    String userId,
  ) async {
    try {
      debugPrint('[InterestsRepository] Getting interests for: $userId');

      // 🔥 3-Layer Cache 우선 조회
      final cachedNamesResult = await _cacheService.getUserInterests(userId);
      final cachedNames = cachedNamesResult.fold(
        (failure) => null,  // Cache miss or error
        (names) => names,
      );

      if (cachedNames != null) {
        final interests = _convertStringListToInterests(cachedNames);
        debugPrint('[InterestsRepository] Found ${interests.length} interests from CACHE');
        return right(interests);
      }

      // Cache Miss - Firebase SDK 직접 사용
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        debugPrint('[InterestsRepository] User not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      final data = doc.data() as Map<String, dynamic>;
      final interests = _convertToInterestList(data);

      // 🔥 캐시에 저장 (Interest → String 변환)
      final interestNames = interests.map((i) => i.name).toList();
      await _cacheService.setUserInterests(userId, interestNames);

      debugPrint('[InterestsRepository] Found ${interests.length} interests from FIRESTORE and cached');
      return right(interests);
    } on FirebaseException catch (e) {
      debugPrint('[InterestsRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[InterestsRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to get user interests: $e'));
    }
  }

  // Phase 6 Cleanup: watchUserInterests 삭제 (Stream 미사용)

  @override
  Future<Either<ProfileFailure, Unit>> addInterest({
    required String userId,
    required Interest interest,
  }) async {
    try {
      debugPrint('[InterestsRepository] Adding interest: ${interest.name} for user: $userId');

      // 레거시 패턴: expertise_select_widget.dart line 370-380
      // await currentUserReference!.update({
      //   'expertise': FieldValue.arrayUnion([text])
      // });

      final field = interest.category == 'expertise' ? 'expertise' : 'interests';

      // 직접 Firebase SDK 사용 (FieldValue.arrayUnion)
      await _firestore.collection('users').doc(userId).update({
        field: FieldValue.arrayUnion([interest.name]),
      });

      // 🔥 캐시 무효화
      await _cacheService.clearUserInterests(userId);

      debugPrint('[InterestsRepository] Interest added successfully, cache cleared');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[InterestsRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[InterestsRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to add interest: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> removeInterest({
    required String userId,
    required Interest interest,
  }) async {
    try {
      debugPrint('[InterestsRepository] Removing interest: ${interest.name} for user: $userId');

      // 레거시 패턴: expertise_select_widget.dart line 559-569
      // await currentUserReference!.update({
      //   'expertise': FieldValue.arrayRemove([authenticatedUserItem])
      // });

      final field = interest.category == 'expertise' ? 'expertise' : 'interests';

      // 직접 Firebase SDK 사용 (FieldValue.arrayRemove)
      await _firestore.collection('users').doc(userId).update({
        field: FieldValue.arrayRemove([interest.name]),
      });

      // 🔥 캐시 무효화
      await _cacheService.clearUserInterests(userId);

      debugPrint('[InterestsRepository] Interest removed successfully, cache cleared');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[InterestsRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[InterestsRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to remove interest: $e'));
    }
  }

  // ============= 헬퍼 메서드 =============

  /// Firestore 데이터를 Interest 리스트로 변환
  ///
  /// **Note**: Firestore에는 interests가 List<String>으로 저장되어 있음
  /// Category 분류 로직이 필요한 경우 별도 컬렉션 참조 필요
  List<Interest> _convertToInterestList(Map<String, dynamic> data) {
    final interestNames = data['interests'];
    if (interestNames is! List) return <Interest>[];

    final interests = <Interest>[];

    for (final name in interestNames) {
      if (name is! String) continue;

      // TODO: Phase 5에서 'interest' 컬렉션 조회하여 category, weight 등 가져오기
      // 현재는 name만으로 간단한 Interest 객체 생성
      interests.add(Interest(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        category: 'hobby', // 기본값
        weight: 0.5,
        selectedAt: DateTime.now(),
      ));
    }

    return interests;
  }

  /// List<String>을 Interest 리스트로 변환 (캐시용)
  List<Interest> _convertStringListToInterests(List<String> names) {
    return names.map((name) => Interest(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      category: 'hobby', // 기본값
      weight: 0.5,
      selectedAt: DateTime.now(),
    )).toList();
  }

  /// Firebase Exception → ProfileFailure 매핑
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return ProfileFailure.permissionDenied('user interests');
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');
      case 'unavailable':
      case 'deadline-exceeded':
        return const ProfileFailure.network();
      case 'invalid-argument':
        return ProfileFailure.firestoreWrite('Invalid interest data format');
      case 'resource-exhausted':
        return ProfileFailure.firestoreWrite('Firebase quota exceeded');
      default:
        return ProfileFailure.unknown('Firebase: ${e.code} - ${e.message}');
    }
  }
}
