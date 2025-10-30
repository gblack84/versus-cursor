import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/user_profile_extensions.dart';
import '../../domain/failures/profile_failure.dart';
import '/services/cache/unified_cache_service.dart';

/// SettingsRepository 구현 (Clean Architecture v4.0)
///
/// **Phase 4: Firebase-Centric v2.0 전환** (2025-01-29):
/// - DataSource 제거 → FirebaseFirestore 직접 사용
/// - Extension 패턴으로 Entity ↔ Firestore 변환
/// - Auth Feature 패턴 100% 일치
/// - _mapFirebaseException() 메서드 추가
///
/// **책임**:
/// - Firebase SDK를 통한 직접 설정 데이터 접근
/// - Extension으로 UserSettings 변환
/// - Firebase Exception → ProfileFailure 매핑
/// - 에러 처리
class SettingsRepositoryImpl implements ISettingsRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

  SettingsRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============= 설정 관리 =============

  @override
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(
      String userId) async {
    try {
      debugPrint('[SettingsRepository] Getting user settings for: $userId');

      // 🔥 3-Layer Cache 우선 조회
      final cached = await _cacheService.getUserSettings(userId);
      if (cached != null) {
        debugPrint('[SettingsRepository] Settings loaded from CACHE');
        return right(cached);
      }

      // Cache Miss - Firebase SDK 직접 사용
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('[SettingsRepository] Settings not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      // Extension으로 변환
      final settings = UserSettingsFirestore.fromFirestore(doc);

      // 🔥 캐시에 저장
      await _cacheService.setUserSettings(userId, settings);

      debugPrint('[SettingsRepository] Settings loaded from FIRESTORE and cached');

      return right(settings);
    } on FirebaseException catch (e) {
      debugPrint('[SettingsRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[SettingsRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to get user settings: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserSettings(
    String userId,
    UserSettings settings,
  ) async {
    try {
      debugPrint('[SettingsRepository] Updating settings for: $userId');

      // UserSettings.toFirestore() 메서드 사용 (이미 정의되어 있음)
      final data = settings.toFirestore();

      // 직접 Firebase SDK 사용
      await _firestore
          .collection('users')
          .doc(userId)
          .update(data);

      // 🔥 캐시 무효화 (다음 조회 시 최신 데이터 가져오도록)
      await _cacheService.clearUserSettings(userId);

      debugPrint('[SettingsRepository] Settings updated successfully, cache cleared');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[SettingsRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } catch (e) {
      debugPrint('[SettingsRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to update user settings: $e'));
    }
  }

  /// Firebase Exception → ProfileFailure 매핑
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return ProfileFailure.permissionDenied('user settings');
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');
      case 'unavailable':
      case 'deadline-exceeded':
        return const ProfileFailure.network();
      case 'invalid-argument':
        return ProfileFailure.firestoreWrite('Invalid settings data format');
      case 'resource-exhausted':
        return ProfileFailure.firestoreWrite('Firebase quota exceeded');
      default:
        return ProfileFailure.unknown('Firebase: ${e.code} - ${e.message}');
    }
  }

  // Phase 6 Cleanup: watchUserSettings, getNotificationSettings, updateNotificationSettings 삭제
  // - watchUserSettings: Stream 미사용
  // - getNotificationSettings: UserSettings.notificationSettings getter 사용
  // - updateNotificationSettings: updateUserSettings로 충분
}
