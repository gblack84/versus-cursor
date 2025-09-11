import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/features/auth/data/adapters/auth_util.dart';

/// 사용자 정보 캐싱을 위한 통합 서비스
///
/// 채팅 시스템 전체에서 사용자 정보를 효율적으로 관리합니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 동일한 캐시를 공유합니다.
class UserCacheService {
  static final UserCacheService _instance = UserCacheService._internal();
  static UserCacheService get instance => _instance;

  UserCacheService._internal();

  // 사용자 캐시
  final Map<String, core.User> _cache = {};

  // 로딩 중인 사용자 ID 추적 (중복 요청 방지)
  final Set<String> _loadingUserIds = {};

  // Firebase Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // AI 사용자 상수
  static const String aiUserId = 'ai_assistant';
  static const String aiUserName = 'AI 피클';
  static const String aiUserAvatar =
      'https://picsum.photos/seed/ai_assistant/200';

  /// 단일 사용자 정보 가져오기
  Future<core.User?> getUser(String userId) async {
    // 캐시 확인
    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }

    // AI 사용자 처리
    if (userId == aiUserId) {
      final aiUser = core.User(
        id: aiUserId,
        name: aiUserName,
        imageSource: aiUserAvatar,
      );
      _cache[userId] = aiUser;
      return aiUser;
    }

    // 현재 사용자 처리
    if (userId == currentUserUid) {
      return _getCurrentUser();
    }

    // 이미 로딩 중이면 대기
    if (_loadingUserIds.contains(userId)) {
      // 로딩 완료 대기 (최대 5초)
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_cache.containsKey(userId)) {
          return _cache[userId];
        }
        if (!_loadingUserIds.contains(userId)) {
          break;
        }
      }
    }

    // Firestore에서 로드
    _loadingUserIds.add(userId);
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = core.User(
          id: userId,
          name: _extractDisplayName(userData),
          imageSource: userData['photoUrl'],
          metadata: {
            'handle': userData['handle'],
            'email': userData['email'],
            'role': userData['role'],
          },
        );
        _cache[userId] = user;
        return user;
      }
    } catch (e) {
      debugPrint('[UserCacheService] Error loading user $userId: $e');
    } finally {
      _loadingUserIds.remove(userId);
    }

    return null;
  }

  /// 여러 사용자 정보 병렬 로드
  Future<List<core.User>> getUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // 중복 제거
    final uniqueUserIds = userIds.toSet().toList();

    // 캐시되지 않은 사용자 ID 찾기
    final uncachedUserIds =
        uniqueUserIds.where((id) => !_cache.containsKey(id)).toList();

    // 캐시되지 않은 사용자들 병렬 로드
    if (uncachedUserIds.isNotEmpty) {
      final futures = uncachedUserIds.map((id) => getUser(id));
      await Future.wait(futures);
    }

    // 캐시에서 모든 사용자 반환
    final users = <core.User>[];
    for (final userId in uniqueUserIds) {
      final user = _cache[userId];
      if (user != null) {
        users.add(user);
      }
    }

    return users;
  }

  /// 현재 사용자 정보 가져오기
  Future<core.User?> _getCurrentUser() async {
    final userId = currentUserUid;

    // 캐시 확인
    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }

    try {
      // 먼저 Firestore에서 사용자 문서 조회
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final currentUser = core.User(
          id: userId,
          name: _extractDisplayName(userData),
          imageSource: userData['photoUrl'] ?? currentUserPhoto,
          metadata: {
            'handle': userData['handle'],
            'email': userData['email'] ?? currentUserEmail,
            'role': userData['role'],
          },
        );
        _cache[userId] = currentUser;
        return currentUser;
      }
    } catch (e) {
      debugPrint('[UserCacheService] Error loading current user: $e');
    }

    // Firestore 조회 실패 시 전역 변수 사용
    final fallbackUser = core.User(
      id: userId,
      name: currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'User',
      imageSource: currentUserPhoto,
      metadata: {
        'email': currentUserEmail,
      },
    );
    _cache[userId] = fallbackUser;
    return fallbackUser;
  }

  /// 표시 이름 추출 헬퍼
  String _extractDisplayName(Map<String, dynamic> userData) {
    // 여러 필드에서 표시 이름 추출 시도
    final displayName = userData['displayName'] ??
        userData['handle'] ??
        userData['email']?.split('@')[0] ??
        'User';

    return displayName.toString().isNotEmpty ? displayName.toString() : 'User';
  }

  /// 사용자 정보 업데이트
  void updateUser(core.User user) {
    _cache[user.id] = user;
  }

  /// 특정 사용자 캐시 제거
  void evictUser(String userId) {
    _cache.remove(userId);
    debugPrint('[UserCacheService] Evicted user from cache: $userId');
  }

  /// 전체 캐시 클리어
  void clearCache() {
    _cache.clear();
    _loadingUserIds.clear();
    debugPrint('[UserCacheService] Cache cleared');
  }

  /// 캐시된 사용자 확인
  bool isCached(String userId) {
    return _cache.containsKey(userId);
  }

  /// 캐시 통계
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedUsers': _cache.length,
      'loadingUsers': _loadingUserIds.length,
      'cacheSize': _cache.length * 1024, // 대략적인 메모리 크기 (바이트)
    };
  }

  /// 오래된 캐시 정리
  void pruneCache({int keepRecentCount = 100}) {
    if (_cache.length <= keepRecentCount) return;

    // 가장 오래된 항목부터 제거
    final entriesToRemove = _cache.length - keepRecentCount;
    final keysToRemove = _cache.keys.take(entriesToRemove).toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    debugPrint('[UserCacheService] Pruned $entriesToRemove old cache entries');
  }

  /// 캐시 상태 로깅 (디버그용)
  void logCacheStatus() {
    debugPrint('[UserCacheService] Cache Status:');
    debugPrint('  - Cached users: ${_cache.length}');
    debugPrint('  - Loading users: ${_loadingUserIds.length}');
    debugPrint(
        '  - Estimated memory: ${(_cache.length * 1024 / 1024).toStringAsFixed(2)} MB');

    if (kDebugMode) {
      debugPrint('  - Cached user IDs: ${_cache.keys.join(", ")}');
    }
  }
}
