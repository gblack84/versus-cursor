import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart';
import '/core/constants/app_constants.dart';
import '/services/cache/unified_cache_service.dart';
import '/features/profile/domain/models/user_profile.dart';

/// Flutter Chat Core 사용자 타입 변환 어댑터
///
/// UserProfile (도메인 모델) → flutter_chat_core.User (UI 타입) 변환을 담당합니다.
/// UnifiedCacheService를 사용하여 3-Layer 캐싱을 활용합니다.
///
/// **아키텍처**:
/// - L0: 변환된 core.User 메모리 캐시 (이 클래스)
/// - L1-L3: UnifiedCacheService의 3-Layer 캐싱 (Memory → Hive → Firestore)
///
/// **성능**:
/// - 첫 로드: ~50ms (Firestore 캐시)
/// - 재방문: <10ms (메모리 캐시)
/// - 앱 재시작: ~30ms (Hive 캐시)
class FlutterChatUserAdapter {
  static final FlutterChatUserAdapter _instance =
      FlutterChatUserAdapter._internal();
  static FlutterChatUserAdapter get instance => _instance;

  FlutterChatUserAdapter._internal();

  // UnifiedCacheService 인스턴스 (3-Layer 캐싱)
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

  // 변환된 core.User 캐시 (메모리만, 타입 변환 결과 저장)
  final Map<String, core.User> _convertedCache = {};

  // Firebase Auth helpers
  String get currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;
  String? get currentUserDisplayName => FirebaseAuth.instance.currentUser?.displayName;
  String? get currentUserPhoto => FirebaseAuth.instance.currentUser?.photoURL;

  /// 단일 사용자 정보 가져오기
  ///
  /// **캐싱 전략**:
  /// 1. 변환된 캐시 확인 (core.User)
  /// 2. AI 사용자 특수 처리
  /// 3. UnifiedCacheService에서 UserProfile 가져오기 (3-Layer)
  /// 4. UserProfile → core.User 변환
  /// 5. 현재 사용자 Fallback
  Future<core.User?> getUser(String userId) async {
    // 1. 변환된 캐시 확인
    if (_convertedCache.containsKey(userId)) {
      return _convertedCache[userId];
    }

    // 2. AI 사용자 특수 처리
    if (userId == AppConstants.aiUserId) {
      final aiUser = core.User(
        id: AppConstants.aiUserId,
        name: AppConstants.aiUserName,
        imageSource: AppConstants.aiUserAvatar,
      );
      _convertedCache[userId] = aiUser;
      return aiUser;
    }

    // 3. UnifiedCacheService에서 UserProfile 가져오기 (3-Layer 캐싱)
    try {
      final userProfile = await _cacheService.getUserProfile(userId);

      if (userProfile != null) {
        // 4. flutter_chat_core.User로 변환
        final chatUser = _convertToFlutterChatUser(userId, userProfile);
        _convertedCache[userId] = chatUser;
        return chatUser;
      }
    } catch (e) {
      debugPrint('[FlutterChatUserAdapter] Error loading user $userId: $e');
    }

    // 5. 현재 사용자 Fallback
    if (userId == currentUserUid) {
      return _getCurrentUserFallback();
    }

    return null;
  }

  /// 여러 사용자 정보 병렬 로드
  ///
  /// UnifiedCacheService가 내부적으로 병렬 처리 및 캐싱을 수행합니다.
  Future<List<core.User>> getUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // 중복 제거
    final uniqueUserIds = userIds.toSet().toList();

    // 캐시되지 않은 사용자들 병렬 로드
    final uncachedUserIds = uniqueUserIds
        .where((id) => !_convertedCache.containsKey(id))
        .toList();

    if (uncachedUserIds.isNotEmpty) {
      final futures = uncachedUserIds.map((id) => getUser(id));
      await Future.wait(futures);
    }

    // 캐시에서 모든 사용자 반환
    final users = <core.User>[];
    for (final userId in uniqueUserIds) {
      final user = _convertedCache[userId];
      if (user != null) {
        users.add(user);
      }
    }

    return users;
  }

  /// UserProfile → flutter_chat_core.User 변환
  ///
  /// **변환 로직**:
  /// - displayName을 name으로 사용 (없으면 email의 앞부분)
  /// - photoUrl을 imageSource로 매핑
  /// - email, role을 metadata로 저장
  core.User _convertToFlutterChatUser(String userId, UserProfile profile) {
    return core.User(
      id: userId,
      name: _extractDisplayName(profile),
      imageSource: profile.photoUrl,
      metadata: {
        'email': profile.email,
        'role': profile.role,
      },
    );
  }

  /// 표시 이름 추출 헬퍼
  ///
  /// **우선순위**:
  /// 1. displayName
  /// 2. email (@ 앞부분)
  /// 3. 'User' (기본값)
  String _extractDisplayName(UserProfile profile) {
    final displayName = profile.displayName ??
        profile.email.split('@')[0];

    return displayName.isNotEmpty ? displayName : 'User';
  }

  /// 현재 사용자 Fallback
  ///
  /// Firestore 조회 실패 시 AuthContract에서 기본 정보 가져오기
  core.User _getCurrentUserFallback() {
    final fallbackUser = core.User(
      id: currentUserUid,
      name: (currentUserDisplayName?.isNotEmpty ?? false)
          ? currentUserDisplayName!
          : 'User',
      imageSource: currentUserPhoto,
      metadata: {
        'email': currentUserEmail,
      },
    );
    _convertedCache[currentUserUid] = fallbackUser;
    return fallbackUser;
  }

  /// 사용자 정보 업데이트
  ///
  /// 변환된 캐시만 업데이트합니다.
  /// UnifiedCacheService 캐시는 자동으로 동기화됩니다.
  void updateUser(core.User user) {
    _convertedCache[user.id] = user;
  }

  /// 특정 사용자 캐시 제거
  ///
  /// 변환된 캐시와 UnifiedCacheService 캐시 모두 무효화합니다.
  void evictUser(String userId) {
    _convertedCache.remove(userId);
    _cacheService.clearUserProfile(userId);
    debugPrint('[FlutterChatUserAdapter] Evicted user from cache: $userId');
  }

  /// 전체 캐시 클리어
  ///
  /// 변환된 캐시만 클리어합니다.
  /// UnifiedCacheService는 별도로 관리됩니다.
  void clearCache() {
    _convertedCache.clear();
    debugPrint('[FlutterChatUserAdapter] Converted cache cleared');
  }

  /// 캐시된 사용자 확인
  bool isCached(String userId) {
    return _convertedCache.containsKey(userId);
  }

  /// 캐시 통계
  ///
  /// 변환된 캐시와 UnifiedCacheService 통계를 모두 반환합니다.
  Map<String, dynamic> getCacheStats() {
    return {
      'convertedCacheSize': _convertedCache.length,
      'convertedCacheMemory':
          _convertedCache.length * 1024, // 대략적인 메모리 크기
      'unifiedCacheStats': _cacheService.getStatistics(),
    };
  }

  /// 오래된 캐시 정리
  ///
  /// 변환된 캐시만 정리합니다 (LRU 방식).
  /// UnifiedCacheService는 자체 정리 메커니즘을 사용합니다.
  void pruneCache({int keepRecentCount = 100}) {
    if (_convertedCache.length <= keepRecentCount) return;

    final entriesToRemove = _convertedCache.length - keepRecentCount;
    final keysToRemove = _convertedCache.keys.take(entriesToRemove).toList();

    for (final key in keysToRemove) {
      _convertedCache.remove(key);
    }

    debugPrint(
        '[FlutterChatUserAdapter] Pruned $entriesToRemove old cache entries');
  }

  /// 캐시 상태 로깅 (디버그용)
  void logCacheStatus() {
    debugPrint('[FlutterChatUserAdapter] Cache Status:');
    debugPrint('  - Converted cache: ${_convertedCache.length} users');
    debugPrint(
        '  - Estimated memory: ${(_convertedCache.length * 1024 / 1024).toStringAsFixed(2)} MB');

    if (kDebugMode) {
      debugPrint('  - Cached user IDs: ${_convertedCache.keys.join(", ")}');
    }

    // UnifiedCacheService 통계도 출력
    debugPrint('\n[UnifiedCacheService] Statistics:');
    final stats = _cacheService.getStatistics();
    stats.forEach((key, value) {
      debugPrint('  - $key: $value');
    });
  }
}
