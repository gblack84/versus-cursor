import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'simple_memory_cache.dart' hide CacheKeys;
import 'cache_statistics.dart';
import '/app/contracts/cache_contract.dart';
// Domain models imports (migrated from backend.dart)
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/chat/data/models/message_dto.dart';
import '/features/profile/domain/models/user_profile.dart';

/// 캐시 레이어 정의
enum CacheLayer {
  memory, // L1: 메모리 캐시
  local, // L2: 로컬 DB (Hive)
  remote, // L3: Firestore
  all, // 모든 레이어
}

/// 통합 캐시 서비스
///
/// 3-Layer 캐싱 아키텍처를 구현하여 앱 성능을 대폭 향상
abstract class UnifiedCacheService implements CacheContract {
  // 싱글톤 인스턴스
  static late UnifiedCacheService _instance;
  static UnifiedCacheService get instance => _instance;

  // 초기화
  static Future<void> initialize() async {
    _instance = UnifiedCacheServiceImpl();
    await _instance.init();
  }

  // 초기화 메서드
  Future<void> init();

  // 기본 캐시 인터페이스
  Future<T?> get<T>(String key, {CacheLayer? layer});
  Future<void> set<T>(String key, T value, {Duration? ttl, CacheLayer? layer});
  Future<void> remove(String key, {CacheLayer? layer});
  Future<void> invalidate(String pattern, {CacheLayer? layer});
  Future<void> clear({CacheLayer? layer});

  // CacheContract implementation
  @override
  Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20});
  @override
  Future<void> setFeedPosts(List<Map<String, dynamic>> posts);
  @override
  Future<void> clearFeedPosts();
  @override
  Future<UserProfile?> getUserProfile(String userId);
  @override
  Future<void> setUserProfile(String userId, UserProfile profile);
  @override
  Future<void> clearUserProfile(String userId);
  @override
  Future<List<Map<String, dynamic>>> getChatMessages({required String chatId, int limit = 30});
  @override
  Future<void> setChatMessages({required String chatId, required List<Map<String, dynamic>> messages});
  @override
  Future<void> clearChatMessages(String chatId);
  @override
  Future<void> clearAll();
  @override
  Map<String, dynamic> getStatistics();
  @override
  Future<void> preloadRecentChats();
  @override
  Future<void> preloadPopularPosts();

  // 통계
  double get hitRate;
  int get memorySize;
  Future<int> get localSize;
}

/// UnifiedCacheService 구현체
class UnifiedCacheServiceImpl extends UnifiedCacheService {
  // 캐시 레이어
  late SimpleMemoryCache _memoryCache;
  late Box<dynamic> _localCache; // Hive local cache

  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> init() async {
    _memoryCache = SimpleMemoryCache.instance;

    // Hive 초기화
    await Hive.initFlutter();

    // Hive 박스 열기 - 손상된 경우 자동 재생성
    try {
      _localCache = await Hive.openBox('unified_cache');
      _logDebug('Hive cache opened successfully');
    } catch (e) {
      // 손상된 캐시 제거 후 재생성
      _logDebug('Hive cache corrupted, resetting: $e');
      try {
        await Hive.deleteBoxFromDisk('unified_cache');
        _logDebug('Corrupted Hive cache deleted');
      } catch (deleteError) {
        _logDebug('Failed to delete corrupted cache: $deleteError');
      }

      // 새로운 박스 생성
      _localCache = await Hive.openBox('unified_cache');
      _logDebug('New Hive cache created');
    }

    _logDebug('UnifiedCacheService initialized with Hive');
  }

  @override
  Future<T?> get<T>(String key, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    // L1: Memory Cache
    if (layer == CacheLayer.memory || layer == CacheLayer.all) {
      final memoryResult = _memoryCache.get<T>(key);
      if (memoryResult != null) {
        return memoryResult;
      }
    }

    // L2: Local DB (Hive)
    if (layer == CacheLayer.local || layer == CacheLayer.all) {
      try {
        final localResult = await _localCache.get(key);
        if (localResult != null) {
          // Promote to memory cache
          _memoryCache.set(key, localResult);
          _logDebug('Cache HIT from Hive: $key');
          return localResult as T;
        }
      } catch (e) {
        _logDebug('Hive get error for $key: $e');
      }
    }

    // L3: Remote (Firestore는 자체 오프라인 캐시 사용)
    // 특정 쿼리는 도메인별 메서드에서 처리

    return null;
  }

  @override
  Future<void> set<T>(String key, T value,
      {Duration? ttl, CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    // L1: Memory Cache
    if (layer == CacheLayer.memory || layer == CacheLayer.all) {
      _memoryCache.set(key, value, ttl: ttl);
    }

    // L2: Local DB (Hive)
    if (layer == CacheLayer.local || layer == CacheLayer.all) {
      try {
        await _localCache.put(key, value);
        _logDebug('Cached to Hive: $key');
      } catch (e) {
        _logDebug('Hive set error for $key: $e');
      }
    }
  }

  @override
  Future<void> remove(String key, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    if (layer == CacheLayer.memory || layer == CacheLayer.all) {
      _memoryCache.remove(key);
    }

    // L2: Local DB
    if (layer == CacheLayer.local || layer == CacheLayer.all) {
      try {
        await _localCache.delete(key);
      } catch (e) {
        _logDebug('Hive remove error for $key: $e');
      }
    }
  }

  @override
  Future<void> invalidate(String pattern, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    if (layer == CacheLayer.memory || layer == CacheLayer.all) {
      _memoryCache.invalidate(pattern);
    }

    // L2: Local DB
    if (layer == CacheLayer.local || layer == CacheLayer.all) {
      try {
        final keysToDelete = _localCache.keys
            .where((key) => key.toString().contains(pattern))
            .toList();
        for (final key in keysToDelete) {
          await _localCache.delete(key);
        }
        _logDebug(
            'Invalidated ${keysToDelete.length} keys from Hive matching: $pattern');
      } catch (e) {
        _logDebug('Hive invalidate error: $e');
      }
    }
  }

  @override
  Future<void> clear({CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    if (layer == CacheLayer.memory || layer == CacheLayer.all) {
      _memoryCache.clear();
    }

    // L2: Local DB
    if (layer == CacheLayer.local || layer == CacheLayer.all) {
      try {
        await _localCache.clear();
        _logDebug('Cleared Hive cache');
      } catch (e) {
        _logDebug('Hive clear error: $e');
      }
    }
  }

  // === 채팅 관련 ===

  @override
  Future<List<Map<String, dynamic>>> getChatMessages({
    required String chatId,
    int limit = 30,
  }) async {
    final cacheKey = CacheKeys.chatMessages(chatId);
    final stopwatch = Stopwatch()..start();

    // 통계: 요청 기록
    CacheStatistics.instance.recordRequest();

    // L1: Memory Cache
    final cached = _memoryCache.get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) {
      stopwatch.stop();
      CacheStatistics.instance
          .recordL1Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
      _logDebug(
          'Chat messages from MEMORY: $chatId (${stopwatch.elapsedMilliseconds}ms)');
      // 백그라운드에서 동기화
      _syncChatMessagesInBackground(chatId);
      return cached;
    }

    // L2: Local DB (Hive)
    try {
      final hiveCached = await _localCache.get(cacheKey);
      if (hiveCached != null && hiveCached is List) {
        // 캐시 데이터 무결성 검증 및 복구
        final validMessages = <Map<String, dynamic>>[];
        bool hasCorruptedData = false;

        for (final item in hiveCached) {
          try {
            if (item is Map) {
              final messageMap = Map<String, dynamic>.from(item);
              validMessages.add(messageMap);
            }
          } catch (e) {
            // 손상된 데이터 발견
            hasCorruptedData = true;
            _logDebug('Corrupted message data found in cache: $e');
          }
        }

        // 손상된 데이터가 있으면 Hive 캐시 제거
        if (hasCorruptedData) {
          _logDebug('Removing corrupted cache entry for: $cacheKey');
          await _localCache.delete(cacheKey);
          // Firestore에서 다시 로드하도록 진행
        } else if (validMessages.isNotEmpty) {
          // 유효한 메시지들만 반환
          _memoryCache.set(cacheKey, validMessages,
              ttl: const Duration(minutes: 5));
          stopwatch.stop();
          CacheStatistics.instance
              .recordL2Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
          _logDebug(
              'Chat messages from HIVE: $chatId (${stopwatch.elapsedMilliseconds}ms)');
          // 백그라운드에서 동기화
          _syncChatMessagesInBackground(chatId);
          return validMessages;
        }
      }
    } catch (e) {
      _logDebug('Hive read error for chat messages: $e');
      // 캐시 데이터가 완전히 손상된 경우 삭제
      try {
        await _localCache.delete(cacheKey);
        _logDebug('Removed corrupted cache entry: $cacheKey');
      } catch (_) {}
    }

    // L3: Firestore (오프라인 캐시 우선)
    try {
      // 캐시 우선 조회
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timeStamp', descending: false)
          .limitToLast(limit)
          .get(const GetOptions(source: Source.cache));

      final messages = snapshot.docs
          .map((doc) => MessageDto.fromFirestore(doc).toFirestore())
          .toList();

      // 메모리 및 로컬 DB에 저장
      _memoryCache.set(cacheKey, messages, ttl: const Duration(minutes: 5));
      try {
        await _localCache.put(cacheKey, messages);
      } catch (e) {
        _logDebug('Failed to save to Hive: $e');
      }
      stopwatch.stop();
      CacheStatistics.instance
          .recordL3Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
      _logDebug(
          'Chat messages from FIRESTORE CACHE: $chatId (${stopwatch.elapsedMilliseconds}ms)');

      return messages;
    } catch (e) {
      // 캐시 실패 시 서버에서 가져오기
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timeStamp', descending: false)
          .limitToLast(limit)
          .get();

      final messages = snapshot.docs
          .map((doc) => MessageDto.fromFirestore(doc).toFirestore())
          .toList();

      // 캐시 업데이트 (메모리 및 로컬 DB)
      _memoryCache.set(cacheKey, messages, ttl: const Duration(minutes: 5));
      try {
        await _localCache.put(cacheKey, messages);
      } catch (e) {
        _logDebug('Failed to save to Hive: $e');
      }
      stopwatch.stop();
      CacheStatistics.instance
          .recordNetworkHit(responseTimeMs: stopwatch.elapsedMilliseconds);
      _logDebug(
          'Chat messages from SERVER: $chatId (${stopwatch.elapsedMilliseconds}ms)');

      return messages;
    }
  }

  @override
  Future<void> setChatMessages({
    required String chatId,
    required List<Map<String, dynamic>> messages,
  }) async {
    final cacheKey = CacheKeys.chatMessages(chatId);
    _memoryCache.set(cacheKey, messages, ttl: const Duration(minutes: 5));
  }

  // 백그라운드 동기화
  Future<void> _syncChatMessagesInBackground(String chatId) async {
    // 비동기로 최신 메시지 확인
    Future.delayed(Duration.zero, () async {
      try {
        final snapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timeStamp', descending: false)
            .limitToLast(30)
            .get();

        final messages = snapshot.docs
            .map((doc) => MessageDto.fromFirestore(doc).toFirestore())
            .toList();

        // 캐시 업데이트
        await setChatMessages(chatId: chatId, messages: messages);
      } catch (e) {
        // 백그라운드 동기화 실패는 무시
      }
    });
  }

  // === 피드 관련 ===

  @override
  Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20}) async {
    final cacheKey = CacheKeys.feedPosts();

    // L1: Memory Cache
    final cached = _memoryCache.get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) {
      _logDebug('Feed posts from MEMORY');
      return cached;
    }

    // L3: Firestore
    try {
      // 캐시 우선
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('postCreatedDate', descending: true)
          .limit(limit)
          .get(const GetOptions(source: Source.cache));

      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        data['reference'] = doc.reference; // Add reference for compatibility
        return data;
      }).toList();

      _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
      return posts;
    } catch (e) {
      // 서버에서 가져오기
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('postCreatedDate', descending: true)
          .limit(limit)
          .get();

      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        data['reference'] = doc.reference; // Add reference for compatibility
        return data;
      }).toList();

      _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
      return posts;
    }
  }

  @override
  Future<void> setFeedPosts(List<Map<String, dynamic>> posts) async {
    final cacheKey = CacheKeys.feedPosts();
    _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
  }

  @override
  Future<void> clearFeedPosts() async {
    final cacheKey = CacheKeys.feedPosts();
    _memoryCache.remove(cacheKey);
  }

  // === 사용자 관련 ===

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final cacheKey = CacheKeys.userProfile(userId);

    // L1: Memory Cache
    final cached = _memoryCache.get<UserProfile>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // L3: Firestore
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final user = UserProfile.fromSnapshot(doc);
        _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
        return user;
      }
    } catch (e) {
      _logDebug('Failed to get user profile: $userId');
    }

    return null;
  }

  @override
  Future<void> setUserProfile(String userId, UserProfile user) async {
    final cacheKey = CacheKeys.userProfile(userId);
    _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
  }

  // === 프리페칭 ===

  @override
  Future<void> preloadRecentChats() async {
    try {
      // 최근 채팅방 목록 가져오기
      final chatsSnapshot = await _firestore
          .collection('chats')
          .orderBy('lastMessageAt', descending: true)
          .limit(5)
          .get();

      // 각 채팅방의 메시지 프리로드
      for (final chatDoc in chatsSnapshot.docs) {
        await getChatMessages(chatId: chatDoc.id);
      }

      _logDebug('Preloaded ${chatsSnapshot.docs.length} recent chats');
    } catch (e) {
      _logDebug('Failed to preload recent chats: $e');
    }
  }

  @override
  Future<void> preloadPopularPosts() async {
    try {
      // 인기 포스트 프리로드
      await getFeedPosts(limit: 10);
      _logDebug('Preloaded popular posts');
    } catch (e) {
      _logDebug('Failed to preload popular posts: $e');
    }
  }

  // === 통계 ===

  @override
  double get hitRate => _memoryCache.hitRate;

  @override
  int get memorySize => _memoryCache.size;

  @override
  Future<int> get localSize async {
    try {
      return _localCache.length;
    } catch (e) {
      _logDebug('Error getting Hive size: $e');
      return 0;
    }
  }

  // === CacheContract 필수 구현 메서드 ===

  @override
  Future<void> clearChatMessages(String chatId) async {
    final cacheKey = CacheKeys.chatMessages(chatId);
    await remove(cacheKey, layer: CacheLayer.all);
  }

  @override
  Future<void> clearUserProfile(String userId) async {
    final cacheKey = CacheKeys.userProfile(userId);
    await remove(cacheKey, layer: CacheLayer.all);
  }

  @override
  Future<void> clearAll() async {
    await clear(layer: CacheLayer.all);
  }

  @override
  Map<String, dynamic> getStatistics() {
    final stats = CacheStatistics.instance;
    return {
      'overallHitRate': stats.overallHitRate,
      'l1HitRate': stats.l1HitRate,
      'l2HitRate': stats.l2HitRate,
      'l3HitRate': stats.l3HitRate,
      'networkHitRate': stats.networkHitRate,
      'averageResponseTime': stats.averageResponseTime,
      'minResponseTime': stats.minResponseTime,
      'maxResponseTime': stats.maxResponseTime,
      'estimatedCostSavings': stats.estimatedCostSavings,
    };
  }

  /// 캐시 통계 출력
  void printStatistics() {
    CacheStatistics.instance.logStatistics();
  }

  /// 캐시 통계 요약 가져오기
  String getStatisticsSummary() {
    return CacheStatistics.instance.getSummary();
  }

  // 디버그 로깅
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[UnifiedCache] $message');
    }
  }
}
