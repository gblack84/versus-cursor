import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/backend/backend.dart';
import 'simple_memory_cache.dart';
import 'cache_statistics.dart';

/// 캐시 레이어 정의
enum CacheLayer {
  memory,    // L1: 메모리 캐시
  local,     // L2: 로컬 DB (Hive)
  remote,    // L3: Firestore
  all,       // 모든 레이어
}

/// 통합 캐시 서비스
/// 
/// 3-Layer 캐싱 아키텍처를 구현하여 앱 성능을 대폭 향상
abstract class UnifiedCacheService {
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
  
  // 도메인별 특화 메서드
  Future<List<MessagesModel>> getChatMessages(String chatId);
  Future<void> setChatMessages(String chatId, List<MessagesModel> messages);
  
  Future<List<PostsModel>> getFeedPosts({int limit = 20});
  Future<void> setFeedPosts(List<PostsModel> posts);
  
  Future<UsersModel?> getUserProfile(String userId);
  Future<void> setUserProfile(String userId, UsersModel user);
  
  // 프리페칭
  Future<void> preloadRecentChats();
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
  late Box<dynamic> _localCache;  // Hive local cache
  
  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<void> init() async {
    _memoryCache = SimpleMemoryCache.instance;
    
    // Hive 초기화
    await Hive.initFlutter();
    _localCache = await Hive.openBox('unified_cache');
    
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
  Future<void> set<T>(String key, T value, {Duration? ttl, CacheLayer? layer}) async {
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
        _logDebug('Invalidated ${keysToDelete.length} keys from Hive matching: $pattern');
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
  Future<List<MessagesModel>> getChatMessages(String chatId) async {
    final cacheKey = CacheKeys.chatMessages(chatId);
    final stopwatch = Stopwatch()..start();
    
    // 통계: 요청 기록
    CacheStatistics.instance.recordRequest();
    
    // L1: Memory Cache
    final cached = _memoryCache.get<List<MessagesModel>>(cacheKey);
    if (cached != null) {
      stopwatch.stop();
      CacheStatistics.instance.recordL1Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
      _logDebug('Chat messages from MEMORY: $chatId (${stopwatch.elapsedMilliseconds}ms)');
      // 백그라운드에서 동기화
      _syncChatMessagesInBackground(chatId);
      return cached;
    }
    
    // L2: Local DB (Hive)
    try {
      final hiveCached = await _localCache.get(cacheKey);
      if (hiveCached != null && hiveCached is List) {
        // 캐시 데이터 무결성 검증 및 복구
        final validMessages = <MessagesModel>[];
        bool hasCorruptedData = false;
        
        for (final item in hiveCached) {
          try {
            if (item is Map) {
              final message = MessagesModel.fromJson(Map<String, dynamic>.from(item));
              validMessages.add(message);
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
          _memoryCache.set(cacheKey, validMessages, ttl: const Duration(minutes: 5));
          stopwatch.stop();
          CacheStatistics.instance.recordL2Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
          _logDebug('Chat messages from HIVE: $chatId (${stopwatch.elapsedMilliseconds}ms)');
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
          .orderBy('time_stamp', descending: false)
          .limitToLast(30)
          .get(const GetOptions(source: Source.cache));
      
      final messages = snapshot.docs
          .map((doc) => MessagesModel.fromSnapshot(doc))
          .toList();
      
      // 메모리 및 로컬 DB에 저장
      _memoryCache.set(cacheKey, messages, ttl: const Duration(minutes: 5));
      try {
        final jsonList = messages.map((m) => m.toJson()).toList();
        await _localCache.put(cacheKey, jsonList);
      } catch (e) {
        _logDebug('Failed to save to Hive: $e');
      }
      stopwatch.stop();
      CacheStatistics.instance.recordL3Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
      _logDebug('Chat messages from FIRESTORE CACHE: $chatId (${stopwatch.elapsedMilliseconds}ms)');
      
      return messages;
    } catch (e) {
      // 캐시 실패 시 서버에서 가져오기
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('time_stamp', descending: false)
          .limitToLast(30)
          .get();
      
      final messages = snapshot.docs
          .map((doc) => MessagesModel.fromSnapshot(doc))
          .toList();
      
      // 캐시 업데이트 (메모리 및 로컬 DB)
      _memoryCache.set(cacheKey, messages, ttl: const Duration(minutes: 5));
      try {
        final jsonList = messages.map((m) => m.toJson()).toList();
        await _localCache.put(cacheKey, jsonList);
      } catch (e) {
        _logDebug('Failed to save to Hive: $e');
      }
      stopwatch.stop();
      CacheStatistics.instance.recordNetworkHit(responseTimeMs: stopwatch.elapsedMilliseconds);
      _logDebug('Chat messages from SERVER: $chatId (${stopwatch.elapsedMilliseconds}ms)');
      
      return messages;
    }
  }
  
  @override
  Future<void> setChatMessages(String chatId, List<MessagesModel> messages) async {
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
            .orderBy('time_stamp', descending: false)
            .limitToLast(30)
            .get();
        
        final messages = snapshot.docs
            .map((doc) => MessagesModel.fromSnapshot(doc))
            .toList();
        
        // 캐시 업데이트
        await setChatMessages(chatId, messages);
      } catch (e) {
        // 백그라운드 동기화 실패는 무시
      }
    });
  }
  
  // === 피드 관련 ===
  
  @override
  Future<List<PostsModel>> getFeedPosts({int limit = 20}) async {
    final cacheKey = CacheKeys.feedPosts();
    
    // L1: Memory Cache
    final cached = _memoryCache.get<List<PostsModel>>(cacheKey);
    if (cached != null) {
      _logDebug('Feed posts from MEMORY');
      return cached;
    }
    
    // L3: Firestore
    try {
      // 캐시 우선
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('post_created_date', descending: true)
          .limit(limit)
          .get(const GetOptions(source: Source.cache));
      
      final posts = snapshot.docs
          .map((doc) => PostsModel.fromSnapshot(doc))
          .toList();
      
      _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
      return posts;
    } catch (e) {
      // 서버에서 가져오기
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('post_created_date', descending: true)
          .limit(limit)
          .get();
      
      final posts = snapshot.docs
          .map((doc) => PostsModel.fromSnapshot(doc))
          .toList();
      
      _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
      return posts;
    }
  }
  
  @override
  Future<void> setFeedPosts(List<PostsModel> posts) async {
    final cacheKey = CacheKeys.feedPosts();
    _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
  }
  
  // === 사용자 관련 ===
  
  @override
  Future<UsersModel?> getUserProfile(String userId) async {
    final cacheKey = CacheKeys.userProfile(userId);
    
    // L1: Memory Cache
    final cached = _memoryCache.get<UsersModel>(cacheKey);
    if (cached != null) {
      return cached;
    }
    
    // L3: Firestore
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final user = UsersModel.fromSnapshot(doc);
        _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
        return user;
      }
    } catch (e) {
      _logDebug('Failed to get user profile: $userId');
    }
    
    return null;
  }
  
  @override
  Future<void> setUserProfile(String userId, UsersModel user) async {
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
          .orderBy('last_message_at', descending: true)
          .limit(5)
          .get();
      
      // 각 채팅방의 메시지 프리로드
      for (final chatDoc in chatsSnapshot.docs) {
        await getChatMessages(chatDoc.id);
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