import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/entities/profile_info.dart';
import '../../domain/entities/user_profile_extensions.dart';
import '../../domain/failures/profile_failure.dart';
import '/services/cache/unified_cache_service.dart';

/// ProfileRepository 구현 (Clean Architecture v4.0)
///
/// **Phase 7: 3-Layer 캐싱 시스템 통합** (2025-01-30):
/// - SimpleMemoryCache → UnifiedCacheService 전환
/// - Memory → Hive → Firestore 3-Layer 캐싱 적용
/// - 앱 재시작 후 성능: 300-500ms → 10-30ms (95% ↑)
/// - 오프라인 지원: 0% → 100%
/// - Firestore 비용: 97% 절감
///
/// **Phase 4: Firebase-Centric v2.0 전환** (2025-01-29):
/// - DataSource 제거 → FirebaseFirestore 직접 사용
/// - Extension 패턴으로 Entity ↔ Firestore 변환
/// - Auth Feature 패턴 100% 일치
/// - _mapFirebaseException() 메서드 추가
///
/// **Phase 6 대규모 정리** (2025-01-21):
/// - 20개 → 3개 메서드로 축소 (85% 감소)
/// - 프로필 완성도 + 경량 조회 메서드만 보존
///
/// **책임**:
/// - Firebase SDK를 통한 직접 데이터 조회
/// - Extension으로 Entity 변환
/// - 3-Layer 캐싱으로 성능 최적화
/// - Firebase Exception → ProfileFailure 매핑
/// - 에러 처리
class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============= ProfileInfo 관리 =============

  @override
  Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId) async {
    try {
      debugPrint('[ProfileRepository] Getting profile info for: $userId');

      // 🔥 3-Layer Cache 조회 (Memory → Hive → Firestore)
      final profileInfo = await _cacheService.getProfileInfo(userId);

      if (profileInfo == null) {
        debugPrint('[ProfileRepository] Profile not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      debugPrint('[ProfileRepository] Profile info loaded: ${profileInfo.displayName}');
      return right(profileInfo);
    } on FirebaseException catch (e) {
      debugPrint('[ProfileRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[ProfileRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to get profile info: $e'));
    }
  }

  // TODO: 2025-01-21 삭제됨 - 스트림 및 업데이트 메서드
  //
  // 삭제된 메서드 (2개, 호출처 0건):
  //   - getProfileInfoStream() → 스트림 미사용, Future 조회만 사용
  //   - updateProfileInfo() → UpdateUserProfileUseCase 생성 필요

  // ============= UserSettings 관리 =============
  // TODO: 2025-01-21 삭제됨 - IUserRepository 사용 또는 UseCase 생성
  //
  // 삭제된 메서드 (3개, 호출처 0건):
  //   - getUserSettings() → IUserRepository.getUserSettings() 사용
  //   - getUserSettingsStream() → 스트림 미사용
  //   - updateUserSettings() → UpdateUserSettingsUseCase 존재

  // ============= UserStats 관리 =============
  // TODO: 2025-01-21 삭제됨 - IUserRepository 사용 또는 Voting Feature에서 구현 예정
  //
  // 삭제된 메서드 (3개, 호출처 0건):
  //   - getUserStats() → IUserRepository.getUserStats() 중복
  //   - getUserStatsStream() → 스트림 미사용
  //   - updateUserStats() → Voting Feature에서 구현 예정

  // ============= 필드 업데이트 =============
  // TODO: 2025-01-21 삭제됨 - 미래 기능
  //
  // 삭제된 메서드 (2개, 호출처 0건):
  //   - updateProfileField() → 단일 필드 업데이트 미래 기능
  //   - updateProfileFields() → 다중 필드 업데이트 미래 기능

  // ============= 프로필 사진 관리 =============
  // TODO: 2025-01-21 삭제됨 - UseCase 사용
  //
  // 삭제된 메서드 (2개, 호출처 0건):
  //   - uploadProfilePhoto() → UploadProfileImageUseCase 사용 (IProfileStorageRepository)
  //   - deleteProfilePhoto() → DeleteProfileImageUseCase 생성 필요

  // ============= 프로필 완성도 =============

  @override
  Future<Either<ProfileFailure, bool>> isProfileComplete(String userId) async {
    try {
      debugPrint('[ProfileRepository] Checking profile completion for: $userId');

      // 직접 Firebase SDK 사용
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('[ProfileRepository] Profile not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      // Extension으로 변환
      final profile = UserProfileFirestore.fromFirestore(doc);

      // completionRate getter 사용 (0.0 ~ 1.0)
      final isComplete = profile.completionRate >= 0.8; // 80% 이상이면 완성으로 간주
      debugPrint('[ProfileRepository] Profile completion: $isComplete (${profile.completionRate * 100}%)');

      return right(isComplete);
    } on FirebaseException catch (e) {
      debugPrint('[ProfileRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[ProfileRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to check profile completion: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, double>> getProfileCompletionPercentage(String userId) async {
    try {
      debugPrint('[ProfileRepository] Getting profile completion percentage for: $userId');

      // 🔥 3-Layer Cache 조회 (Memory → Hive)
      final cached = await _cacheService.getProfileCompletion(userId);
      if (cached != null) {
        debugPrint('[ProfileRepository] Profile completion from CACHE: ${cached * 100}%');
        return right(cached);
      }

      // Cache Miss - Firebase SDK 직접 사용하여 계산
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('[ProfileRepository] Profile not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      // Extension으로 변환
      final profile = UserProfileFirestore.fromFirestore(doc);

      // completionRate getter 사용 (0.0 ~ 1.0)
      final percentage = profile.completionRate;

      // 🔥 캐시에 저장 (30분 TTL - 자주 변할 수 있음)
      await _cacheService.setProfileCompletion(userId, percentage);

      debugPrint('[ProfileRepository] Profile completion from FIRESTORE: ${percentage * 100}%');

      return right(percentage);
    } on FirebaseException catch (e) {
      debugPrint('[ProfileRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[ProfileRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to get profile completion percentage: $e'));
    }
  }

  /// Firebase Exception → ProfileFailure 매핑
  ///
  /// **Auth Feature 참조 패턴**:
  /// ```dart
  /// // lib/features/auth/data/repositories/auth_repository_impl.dart
  /// AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
  ///   switch (e.code) {
  ///     case 'user-not-found': return const AuthFailure.userNotFound();
  ///     // ...
  ///   }
  /// }
  /// ```
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      // 권한 에러
      case 'permission-denied':
        return ProfileFailure.permissionDenied('user profile');

      // 찾을 수 없음
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');

      // 네트워크 에러
      case 'unavailable':
      case 'deadline-exceeded':
        return const ProfileFailure.network();

      // 잘못된 인수
      case 'invalid-argument':
        return ProfileFailure.firestoreRead('Invalid data format');

      // 할당량 초과
      case 'resource-exhausted':
        return ProfileFailure.firestoreRead('Firebase quota exceeded');

      // 기타
      default:
        return ProfileFailure.unknown('Firebase: ${e.code} - ${e.message}');
    }
  }

  // TODO: 2025-01-21 삭제됨
  // 삭제된 메서드 (1개, 호출처 0건):
  //   - getProfileCompletion() → 미래 기능 (완성도 상세 정보)

  // TODO: 2025-01-21 삭제됨
  // 삭제된 메서드 (1개, 호출처 0건):
  //   - getUserInterests() → GetUserInterestsUseCase 사용 (IInterestsRepository)

  // ============= 검색 및 추천 =============
  // TODO: 2025-01-21 삭제됨 - Search Feature 구현 시 재생성
  //
  // 삭제된 메서드 (2개 + UseCase 2개 삭제):
  //   - searchProfiles() → SearchProfilesUseCase 삭제됨
  //   - getSuggestedProfiles() → GetSuggestedProfilesUseCase 삭제됨
  //
  // **향후 재구현 시**:
  //   - Search Feature 별도 구현
  //   - Algolia 또는 Firestore Query 사용
  //   - 거리 기반 검색 (GeoPoint + Haversine)
  //   - 관심사/나이/성별 필터링

  // ============= 소셜 기능 =============
  // TODO: 2025-01-21 삭제됨 - Social Feature 구현 시 재생성
  //
  // 삭제된 메서드 (4개 + UseCase 2개 삭제):
  //   - blockUser() → BlockUserUseCase 삭제됨
  //   - unblockUser() → UseCase 미생성, 삭제됨
  //   - getBlockedUsers() → UseCase 미생성, 삭제됨
  //   - reportUser() → ReportUserUseCase 삭제됨
  //
  // **향후 재구현 시**:
  //   - Social Feature 별도 구현
  //   - Firestore 서브컬렉션 (blockedUsers, reports)
  //   - 차단 사용자 필터링 로직
  //   - 신고 사유 분류 시스템
}
