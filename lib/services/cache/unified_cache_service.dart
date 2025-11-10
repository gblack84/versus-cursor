import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'simple_memory_cache.dart';
import 'cache_statistics.dart';
import 'failures/cache_failure.dart';
import '/core/types/lat_lng.dart';
// Domain models imports (migrated from backend.dart)
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/chat/domain/entities/message_extensions.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/entities/user_profile_extensions.dart';
import '/features/profile/domain/entities/user_settings.dart';
import '/features/profile/domain/entities/profile_info.dart';
import '/features/profile/domain/entities/character.dart';
import '/features/voting/domain/entities/dialog/vote_counts_model.dart';
import '/features/voting/domain/entities/dialog/vote_cache_state.dart';
import '/features/auth/domain/entities/auth_user.dart';

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
  Future<Either<CacheFailure, T>> get<T>(String key, {CacheLayer? layer});
  Future<Either<CacheFailure, void>> set<T>(String key, T value, {Duration? ttl, CacheLayer? layer});
  Future<Either<CacheFailure, void>> remove(String key, {CacheLayer? layer});
  Future<Either<CacheFailure, void>> invalidate(String pattern, {CacheLayer? layer});
  Future<Either<CacheFailure, void>> clear({CacheLayer? layer});

  // CacheContract implementation
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getFeedPosts({int limit = 20});
  Future<Either<CacheFailure, void>> setFeedPosts(List<Map<String, dynamic>> posts);
  Future<Either<CacheFailure, void>> clearFeedPosts();
  Future<Either<CacheFailure, UserProfile>> getUserProfile(String userId);
  Future<Either<CacheFailure, void>> setUserProfile(String userId, UserProfile profile);
  Future<Either<CacheFailure, void>> clearUserProfile(String userId);

  // UserSettings 캐싱
  Future<Either<CacheFailure, UserSettings>> getUserSettings(String userId);
  Future<Either<CacheFailure, void>> setUserSettings(String userId, UserSettings settings);
  Future<Either<CacheFailure, void>> clearUserSettings(String userId);

  // User Interests 캐싱
  Future<Either<CacheFailure, List<String>>> getUserInterests(String userId);
  Future<Either<CacheFailure, void>> setUserInterests(String userId, List<String> interests);
  Future<Either<CacheFailure, void>> clearUserInterests(String userId);

  // ProfileInfo 캐싱
  Future<Either<CacheFailure, ProfileInfo>> getProfileInfo(String userId);
  Future<Either<CacheFailure, void>> setProfileInfo(String userId, ProfileInfo info);
  Future<Either<CacheFailure, void>> clearProfileInfo(String userId);

  // Profile Completion 캐싱
  Future<Either<CacheFailure, double>> getProfileCompletion(String userId);
  Future<Either<CacheFailure, void>> setProfileCompletion(String userId, double percentage);
  Future<Either<CacheFailure, void>> clearProfileCompletion(String userId);

  // Available Characters 캐싱
  Future<Either<CacheFailure, List<Character>>> getAvailableCharacters();
  Future<Either<CacheFailure, void>> setAvailableCharacters(List<Character> characters);
  Future<Either<CacheFailure, void>> clearAvailableCharacters();

  // VoteCounts 캐싱
  Future<Either<CacheFailure, VoteCounts>> getVoteCounts(String postId);
  Future<Either<CacheFailure, void>> setVoteCounts(String postId, VoteCounts counts);
  Future<Either<CacheFailure, void>> clearVoteCounts(String postId);

  // VoteState 캐싱
  Future<Either<CacheFailure, VoteCacheState>> getVoteState(String postId, String userId);
  Future<Either<CacheFailure, void>> setVoteState(String postId, String userId, VoteCacheState state);
  Future<Either<CacheFailure, void>> clearVoteState(String postId, String userId);

  // Vote History 캐싱
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getVoteHistory(String userId);
  Future<Either<CacheFailure, void>> setVoteHistory(String userId, List<Map<String, dynamic>> history);

  // AuthUser 캐싱
  Future<Either<CacheFailure, AuthUser>> getAuthUser(String userId);
  Future<Either<CacheFailure, void>> setAuthUser(String userId, AuthUser user, {Duration? ttl});
  Future<Either<CacheFailure, void>> clearAuthUser(String userId);

  // AuthToken 캐싱
  Future<Either<CacheFailure, String>> getAuthToken(String userId);
  Future<Either<CacheFailure, void>> setAuthToken(String userId, String token, {Duration? ttl});
  Future<Either<CacheFailure, void>> clearAuthToken(String userId);

  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getChatMessages({required String chatId, int limit = 30});
  Future<Either<CacheFailure, void>> setChatMessages({required String chatId, required List<Map<String, dynamic>> messages});
  Future<Either<CacheFailure, void>> clearChatMessages(String chatId);
  Future<Either<CacheFailure, void>> clearAll();
  Map<String, dynamic> getStatistics();
  Future<Either<CacheFailure, void>> preloadRecentChats();
  Future<Either<CacheFailure, void>> preloadPopularPosts();

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
  Future<Either<CacheFailure, T>> get<T>(String key, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      // L1: Memory Cache
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        final memoryResult = _memoryCache.get<T>(key);
        if (memoryResult != null) {
          _logDebug('Cache HIT from Memory: $key');
          return right(memoryResult);
        }
      }

      // L2: Local DB (Hive)
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          final localResult = await _localCache.get(key);
          if (localResult != null) {
            // Type safety check
            if (localResult is T) {
              // Promote to memory cache
              _memoryCache.set(key, localResult);
              _logDebug('Cache HIT from Hive: $key');
              return right(localResult);
            } else {
              _logDebug('Type mismatch in Hive cache for $key: expected $T, got ${localResult.runtimeType}');
              // Delete corrupted cache entry
              await _localCache.delete(key);
              return left(CacheFailure.typeMismatch(
                expected: T.toString(),
                actual: localResult.runtimeType.toString(),
              ));
            }
          }
        } on HiveError catch (e) {
          _logDebug('Hive get error for $key: $e');
          return left(CacheFailure.hiveError(e.message));
        }
      }

      // L3: Remote (Firestore는 자체 오프라인 캐시 사용)
      // 특정 쿼리는 도메인별 메서드에서 처리

      _logDebug('Cache MISS for $key');
      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting $key', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> set<T>(String key, T value,
      {Duration? ttl, CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      // L1: Memory Cache
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.set(key, value, ttl: ttl);
        _logDebug('Cached to Memory: $key');
      }

      // L2: Local DB (Hive)
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          await _localCache.put(key, value);
          _logDebug('Cached to Hive: $key');
        } on HiveError catch (e) {
          _logError('Hive set error for $key', e);
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      _logError('Unexpected error setting $key', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> remove(String key, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.remove(key);
        _logDebug('Removed from Memory: $key');
      }

      // L2: Local DB
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          await _localCache.delete(key);
          _logDebug('Removed from Hive: $key');
        } on HiveError catch (e) {
          _logError('Hive remove error for $key', e);
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      _logError('Unexpected error removing $key', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> invalidate(String pattern, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.invalidate(pattern);
        _logDebug('Invalidated Memory cache matching: $pattern');
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
        } on HiveError catch (e) {
          _logError('Hive invalidate error for pattern $pattern', e);
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      _logError('Unexpected error invalidating pattern $pattern', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clear({CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.clear();
        _logDebug('Cleared Memory cache');
      }

      // L2: Local DB
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          await _localCache.clear();
          _logDebug('Cleared Hive cache');
        } on HiveError catch (e) {
          _logError('Hive clear error', e);
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      _logError('Unexpected error clearing cache', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === 채팅 관련 ===

  @override
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getChatMessages({
    required String chatId,
    int limit = 30,
  }) async {
    final cacheKey = CacheKeys.chatMessages(chatId);
    final stopwatch = Stopwatch()..start();

    try {
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
        return right(cached);
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
            return right(validMessages);
          }
        }
      } on HiveError catch (e) {
        _logError('Hive read error for chat messages', e);
        return left(CacheFailure.hiveError(e.message));
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
            .map((doc) => MessageFirestore.fromFirestore(doc).toFirestore())
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

        return right(messages);
      } catch (e) {
        // 캐시 실패 시 서버에서 가져오기
        try {
          final snapshot = await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timeStamp', descending: false)
              .limitToLast(limit)
              .get();

          final messages = snapshot.docs
              .map((doc) => MessageFirestore.fromFirestore(doc).toFirestore())
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

          return right(messages);
        } on FirebaseException catch (e) {
          _logError('Firestore error getting chat messages', e);
          return left(CacheFailure.firestoreError(e.message ?? e.toString()));
        }
      }
    } catch (e) {
      _logError('Unexpected error getting chat messages for $chatId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setChatMessages({
    required String chatId,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final cacheKey = CacheKeys.chatMessages(chatId);
      _memoryCache.set(cacheKey, messages, ttl: const Duration(minutes: 5));
      return right(null);
    } catch (e) {
      _logError('Error setting chat messages for $chatId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
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
            .map((doc) => MessageFirestore.fromFirestore(doc).toFirestore())
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
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getFeedPosts({int limit = 20}) async {
    final cacheKey = CacheKeys.feedPosts();

    try {
      // L1: Memory Cache
      final cached = _memoryCache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cached != null) {
        _logDebug('Feed posts from MEMORY');
        return right(cached);
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
        return right(posts);
      } catch (e) {
        // 서버에서 가져오기
        try {
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
          return right(posts);
        } on FirebaseException catch (e) {
          _logError('Firestore error getting feed posts', e);
          return left(CacheFailure.firestoreError(e.message ?? e.toString()));
        }
      }
    } catch (e) {
      _logError('Unexpected error getting feed posts', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setFeedPosts(List<Map<String, dynamic>> posts) async {
    try {
      final cacheKey = CacheKeys.feedPosts();
      _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
      return right(null);
    } catch (e) {
      _logError('Error setting feed posts', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearFeedPosts() async {
    try {
      final cacheKey = CacheKeys.feedPosts();
      _memoryCache.remove(cacheKey);
      return right(null);
    } catch (e) {
      _logError('Error clearing feed posts', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === 사용자 관련 ===

  @override
  Future<Either<CacheFailure, UserProfile>> getUserProfile(String userId) async {
    final cacheKey = CacheKeys.userProfile(userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<UserProfile>(cacheKey);
      if (memCached != null) {
        _logDebug('User profile from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final profile = UserProfile.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, profile, ttl: const Duration(hours: 1));
          _logDebug('User profile from HIVE: $userId');
          return right(profile);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for user profile $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for user profile $userId: $e');
      }

      // L3: Firestore
      try {
        final doc = await _firestore.collection('users').doc(userId).get();

        if (doc.exists) {
          final user = UserProfileFirestore.fromFirestore(doc);

          // Save to L1 + L2
          _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
          try {
            await _localCache.put(cacheKey, user.toJson());
            _logDebug('Cached user profile to Hive: $userId');
          } catch (e) {
            _logDebug('Failed to save user profile to Hive: $e');
          }

          _logDebug('User profile from FIRESTORE: $userId');
          return right(user);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting user profile $userId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get user profile from Firestore: $userId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting user profile $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setUserProfile(String userId, UserProfile user) async {
    try {
      final cacheKey = CacheKeys.userProfile(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, user.toJson());
        _logDebug('Set user profile to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save user profile to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save user profile to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting user profile for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === UserSettings 캐싱 ===

  @override
  Future<Either<CacheFailure, UserSettings>> getUserSettings(String userId) async {
    final cacheKey = CacheKeys.userSettings(userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<UserSettings>(cacheKey);
      if (memCached != null) {
        _logDebug('User settings from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final settings = UserSettings.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, settings, ttl: const Duration(hours: 1));
          _logDebug('User settings from HIVE: $userId');
          return right(settings);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for user settings $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for user settings $userId: $e');
      }

      // L3: Firestore
      try {
        final doc = await _firestore.collection('users').doc(userId).get();

        if (doc.exists && doc.data() != null) {
          final settings = UserSettings.fromMap(doc.data()!, userId);

          // Save to L1 + L2
          _memoryCache.set(cacheKey, settings, ttl: const Duration(hours: 1));
          try {
            await _localCache.put(cacheKey, settings.toJson());
            _logDebug('Cached user settings to Hive: $userId');
          } catch (e) {
            _logDebug('Failed to save user settings to Hive: $e');
          }

          _logDebug('User settings from FIRESTORE: $userId');
          return right(settings);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting user settings $userId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get user settings from Firestore: $userId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting user settings $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setUserSettings(String userId, UserSettings settings) async {
    try {
      final cacheKey = CacheKeys.userSettings(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, settings, ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, settings.toJson());
        _logDebug('Set user settings to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save user settings to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save user settings to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting user settings for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearUserSettings(String userId) async {
    try {
      final cacheKey = CacheKeys.userSettings(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing user settings for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === User Interests 캐싱 ===

  @override
  Future<Either<CacheFailure, List<String>>> getUserInterests(String userId) async {
    final cacheKey = CacheKeys.userInterests(userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<List<String>>(cacheKey);
      if (memCached != null) {
        _logDebug('User interests from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is List) {
          final interests = List<String>.from(hiveData);
          // Promote to memory cache
          _memoryCache.set(cacheKey, interests, ttl: const Duration(hours: 1));
          _logDebug('User interests from HIVE: $userId');
          return right(interests);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for user interests $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for user interests $userId: $e');
      }

      // L3: Firestore
      try {
        final doc = await _firestore.collection('users').doc(userId).get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final interests = data['interests'] != null
              ? List<String>.from(data['interests'] as List)
              : <String>[];

          // Save to L1 + L2
          _memoryCache.set(cacheKey, interests, ttl: const Duration(hours: 1));
          try {
            await _localCache.put(cacheKey, interests);
            _logDebug('Cached user interests to Hive: $userId');
          } catch (e) {
            _logDebug('Failed to save user interests to Hive: $e');
          }

          _logDebug('User interests from FIRESTORE: $userId');
          return right(interests);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting user interests $userId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get user interests from Firestore: $userId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting user interests $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setUserInterests(String userId, List<String> interests) async {
    try {
      final cacheKey = CacheKeys.userInterests(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, interests, ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, interests);
        _logDebug('Set user interests to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save user interests to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save user interests to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting user interests for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearUserInterests(String userId) async {
    try {
      final cacheKey = CacheKeys.userInterests(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing user interests for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === ProfileInfo 캐싱 ===

  @override
  Future<Either<CacheFailure, ProfileInfo>> getProfileInfo(String userId) async {
    final cacheKey = CacheKeys.profileInfo(userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<ProfileInfo>(cacheKey);
      if (memCached != null) {
        _logDebug('ProfileInfo from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final profileInfo = ProfileInfo.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, profileInfo, ttl: const Duration(hours: 1));
          _logDebug('ProfileInfo from HIVE: $userId');
          return right(profileInfo);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for ProfileInfo $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for ProfileInfo $userId: $e');
      }

      // L3: Firestore
      try {
        final doc = await _firestore.collection('users').doc(userId).get();

        if (doc.exists && doc.data() != null) {
          // Convert Firestore document to ProfileInfo
          final data = doc.data()!;
          final profileInfo = ProfileInfo(
            userId: userId,
            displayName: data['displayName'] as String? ?? '',
            photoUrl: data['photoUrl'] as String?,
            shortDescription: data['shortDescription'] as String?,
            gender: data['gender'] as String?,
            dateOfBirth: data['dateOfBirth'] != null
                ? (data['dateOfBirth'] as Timestamp).toDate()
                : null,
            language: data['language'] as String? ?? 'en',
            interests: data['interests'] != null
                ? List<String>.from(data['interests'] as List)
                : [],
            expertise: data['expertise'] != null
                ? List<String>.from(data['expertise'] as List)
                : [],
            location: data['location'] != null
                ? LatLng(
                    (data['location']['latitude'] as num).toDouble(),
                    (data['location']['longitude'] as num).toDouble(),
                  )
                : null,
          );

          // Save to L1 + L2
          _memoryCache.set(cacheKey, profileInfo, ttl: const Duration(hours: 1));
          try {
            await _localCache.put(cacheKey, profileInfo.toJson());
            _logDebug('Cached ProfileInfo to Hive: $userId');
          } catch (e) {
            _logDebug('Failed to save ProfileInfo to Hive: $e');
          }

          _logDebug('ProfileInfo from FIRESTORE: $userId');
          return right(profileInfo);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting ProfileInfo $userId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get ProfileInfo from Firestore: $userId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting ProfileInfo $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setProfileInfo(String userId, ProfileInfo info) async {
    try {
      final cacheKey = CacheKeys.profileInfo(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, info, ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, info.toJson());
        _logDebug('Set ProfileInfo to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save ProfileInfo to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save ProfileInfo to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting ProfileInfo for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearProfileInfo(String userId) async {
    try {
      final cacheKey = CacheKeys.profileInfo(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing ProfileInfo for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === Profile Completion 캐싱 ===

  @override
  Future<Either<CacheFailure, double>> getProfileCompletion(String userId) async {
    final cacheKey = CacheKeys.profileCompletion(userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<double>(cacheKey);
      if (memCached != null) {
        _logDebug('Profile completion from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is double) {
          // Promote to memory cache
          _memoryCache.set(cacheKey, hiveData, ttl: const Duration(minutes: 30));
          _logDebug('Profile completion from HIVE: $userId');
          return right(hiveData);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for profile completion $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for profile completion $userId: $e');
      }

      // L3: 프로필 완성도는 계산된 값이므로 Firestore에서 직접 가져오지 않음
      // 호출하는 쪽에서 UserProfile을 가져와서 completionRate를 계산한 후 setProfileCompletion 호출

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting profile completion $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setProfileCompletion(String userId, double percentage) async {
    try {
      final cacheKey = CacheKeys.profileCompletion(userId);

      // L1: Memory Cache (30분 TTL - 자주 변할 수 있음)
      _memoryCache.set(cacheKey, percentage, ttl: const Duration(minutes: 30));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, percentage);
        _logDebug('Set profile completion to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save profile completion to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save profile completion to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting profile completion for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearProfileCompletion(String userId) async {
    try {
      final cacheKey = CacheKeys.profileCompletion(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing profile completion for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === Available Characters 캐싱 ===

  @override
  Future<Either<CacheFailure, List<Character>>> getAvailableCharacters() async {
    final cacheKey = CacheKeys.availableCharacters();

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<List<Character>>(cacheKey);
      if (memCached != null) {
        _logDebug('Available characters from MEMORY');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is List) {
          final characters = hiveData
              .map((item) => Character.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          // Promote to memory cache (24시간 TTL - 거의 변하지 않음)
          _memoryCache.set(cacheKey, characters, ttl: const Duration(hours: 24));
          _logDebug('Available characters from HIVE');
          return right(characters);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for available characters', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for available characters: $e');
      }

      // L3: Firestore
      try {
        final snapshot = await _firestore
            .collection('characters')
            .where('isActive', isEqualTo: true)
            .get();

        final characters = snapshot.docs.map((doc) {
          final data = doc.data();
          return Character(
            characterId: doc.id,
            name: data['CharactersName'] as String? ?? '',
            imageUrl: data['CharactersImageUrl'] as String? ?? '',
            description: data['description'] as String?,
            isActive: data['isActive'] as bool? ?? true,
            characterType: data['characterType'] as String?,
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : null,
          );
        }).toList();

        // Save to L1 + L2 (24시간 TTL)
        _memoryCache.set(cacheKey, characters, ttl: const Duration(hours: 24));
        try {
          final serializedCharacters = characters.map((c) => c.toJson()).toList();
          await _localCache.put(cacheKey, serializedCharacters);
          _logDebug('Cached available characters to Hive');
        } catch (e) {
          _logDebug('Failed to save available characters to Hive: $e');
        }

        _logDebug('Available characters from FIRESTORE');
        return right(characters);
      } on FirebaseException catch (e) {
        _logError('Firestore error getting available characters', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get available characters from Firestore: $e');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting available characters', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setAvailableCharacters(List<Character> characters) async {
    try {
      final cacheKey = CacheKeys.availableCharacters();

      // L1: Memory Cache (24시간 TTL)
      _memoryCache.set(cacheKey, characters, ttl: const Duration(hours: 24));

      // L2: Hive Cache
      try {
        final serializedCharacters = characters.map((c) => c.toJson()).toList();
        await _localCache.put(cacheKey, serializedCharacters);
        _logDebug('Set available characters to L1+L2');
      } on HiveError catch (e) {
        _logError('Failed to save available characters to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save available characters to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting available characters', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAvailableCharacters() async {
    try {
      final cacheKey = CacheKeys.availableCharacters();
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing available characters', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // ============= VoteCounts 캐싱 =============

  @override
  Future<Either<CacheFailure, VoteCounts>> getVoteCounts(String postId) async {
    final cacheKey = CacheKeys.voteCounts(postId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<VoteCounts>(cacheKey);
      if (memCached != null) {
        _logDebug('Vote counts from MEMORY: $postId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final counts = VoteCounts.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, counts, ttl: const Duration(minutes: 5));
          _logDebug('Vote counts from HIVE: $postId');
          return right(counts);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for vote counts $postId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for vote counts $postId: $e');
      }

      // L3: Firestore
      try {
        final doc = await _firestore.collection('posts').doc(postId).get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final counts = VoteCounts(
            votesA: data['votesA'] as int? ?? 0,
            votesB: data['votesB'] as int? ?? 0,
            totalVotes: data['totalVotes'] as int? ?? 0,
          );

          // Save to L1 + L2
          _memoryCache.set(cacheKey, counts, ttl: const Duration(minutes: 5));
          try {
            await _localCache.put(cacheKey, counts.toJson());
            _logDebug('Cached vote counts to Hive: $postId');
          } catch (e) {
            _logDebug('Failed to save vote counts to Hive: $e');
          }

          _logDebug('Vote counts from FIRESTORE: $postId');
          return right(counts);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting vote counts $postId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get vote counts from Firestore: $postId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting vote counts $postId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setVoteCounts(String postId, VoteCounts counts) async {
    try {
      final cacheKey = CacheKeys.voteCounts(postId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, counts, ttl: const Duration(minutes: 5));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, counts.toJson());
        _logDebug('Set vote counts to L1+L2: $postId');
      } on HiveError catch (e) {
        _logError('Failed to save vote counts to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save vote counts to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting vote counts for $postId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearVoteCounts(String postId) async {
    try {
      final cacheKey = CacheKeys.voteCounts(postId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing vote counts for $postId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // ============= VoteState 캐싱 =============

  @override
  Future<Either<CacheFailure, VoteCacheState>> getVoteState(String postId, String userId) async {
    final cacheKey = CacheKeys.voteState(postId, userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<VoteCacheState>(cacheKey);
      if (memCached != null) {
        _logDebug('Vote state from MEMORY: $postId, $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final state = VoteCacheState.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, state, ttl: const Duration(hours: 1));
          _logDebug('Vote state from HIVE: $postId, $userId');
          return right(state);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for vote state $postId/$userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for vote state $postId/$userId: $e');
      }

      // L3: Firestore
      try {
        final doc = await _firestore
            .collection('posts')
            .doc(postId)
            .collection('votes')
            .doc(userId)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final state = VoteCacheState(
            option: data['option'] as String?,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
            completed: data['completed'] as bool? ?? false,
          );

          // Save to L1 + L2
          _memoryCache.set(cacheKey, state, ttl: const Duration(hours: 1));
          try {
            await _localCache.put(cacheKey, state.toJson());
            _logDebug('Cached vote state to Hive: $postId/$userId');
          } catch (e) {
            _logDebug('Failed to save vote state to Hive: $e');
          }

          _logDebug('Vote state from FIRESTORE: $postId, $userId');
          return right(state);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting vote state $postId/$userId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get vote state from Firestore: $postId/$userId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting vote state $postId/$userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setVoteState(String postId, String userId, VoteCacheState state) async {
    try {
      final cacheKey = CacheKeys.voteState(postId, userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, state, ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, state.toJson());
        _logDebug('Set vote state to L1+L2: $postId/$userId');
      } on HiveError catch (e) {
        _logError('Failed to save vote state to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save vote state to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting vote state for $postId/$userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearVoteState(String postId, String userId) async {
    try {
      final cacheKey = CacheKeys.voteState(postId, userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing vote state for $postId/$userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // ============= Vote History 캐싱 =============

  @override
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getVoteHistory(String userId) async {
    final cacheKey = CacheKeys.voteHistory(userId);

    try {
      // L1: Memory Cache
      final memCached = _memoryCache.get<List<Map<String, dynamic>>>(cacheKey);
      if (memCached != null) {
        _logDebug('Vote history from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is List) {
          final history = hiveData.cast<Map<String, dynamic>>();
          // Promote to memory cache
          _memoryCache.set(cacheKey, history, ttl: const Duration(hours: 1));
          _logDebug('Vote history from HIVE: $userId');
          return right(history);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for vote history $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for vote history $userId: $e');
      }

      // L3: Firestore
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('vote_history')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final history = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();

          // Save to L1 + L2
          _memoryCache.set(cacheKey, history, ttl: const Duration(hours: 1));
          try {
            await _localCache.put(cacheKey, history);
            _logDebug('Cached vote history to Hive: $userId');
          } catch (e) {
            _logDebug('Failed to save vote history to Hive: $e');
          }

          _logDebug('Vote history from FIRESTORE: $userId');
          return right(history);
        }
      } on FirebaseException catch (e) {
        _logError('Firestore error getting vote history $userId', e);
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        _logDebug('Failed to get vote history from Firestore: $userId');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting vote history $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setVoteHistory(String userId, List<Map<String, dynamic>> history) async {
    try {
      final cacheKey = CacheKeys.voteHistory(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, history, ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, history);
        _logDebug('Set vote history to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save vote history to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save vote history to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting vote history for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // ============= AuthUser 캐싱 =============

  @override
  Future<Either<CacheFailure, AuthUser>> getAuthUser(String userId) async {
    final cacheKey = CacheKeys.authUser(userId);

    try {
      // L1: Memory Cache (<1ms)
      final memCached = _memoryCache.get<AuthUser>(cacheKey);
      if (memCached != null) {
        _logDebug('Auth user from MEMORY: $userId');
        return right(memCached);
      }

      // L2: Hive Cache (10-30ms)
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final user = AuthUser.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
          _logDebug('Auth user from HIVE: $userId');
          return right(user);
        }
      } on HiveError catch (e) {
        _logError('Hive read error for auth user $userId', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Hive read error for auth user $userId: $e');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      _logError('Unexpected error getting auth user $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setAuthUser(String userId, AuthUser user, {Duration? ttl}) async {
    try {
      final cacheKey = CacheKeys.authUser(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, user, ttl: ttl ?? const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, user.toJson());
        _logDebug('Set auth user to L1+L2: $userId');
      } on HiveError catch (e) {
        _logError('Failed to save auth user to Hive', e);
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        _logDebug('Failed to save auth user to Hive: $e');
      }

      return right(null);
    } catch (e) {
      _logError('Error setting auth user for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAuthUser(String userId) async {
    try {
      final cacheKey = CacheKeys.authUser(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing auth user for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // ============= AuthToken 캐싱 =============

  @override
  Future<Either<CacheFailure, String>> getAuthToken(String userId) async {
    final cacheKey = CacheKeys.authToken(userId);
    return await get<String>(cacheKey);
  }

  @override
  Future<Either<CacheFailure, void>> setAuthToken(String userId, String token, {Duration? ttl}) async {
    try {
      final cacheKey = CacheKeys.authToken(userId);
      return await set(cacheKey, token, ttl: ttl ?? const Duration(hours: 1));
    } catch (e) {
      _logError('Error setting auth token for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAuthToken(String userId) async {
    try {
      final cacheKey = CacheKeys.authToken(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing auth token for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  // === 프리페칭 ===

  @override
  Future<Either<CacheFailure, void>> preloadRecentChats() async {
    try {
      // 최근 채팅방 목록 가져오기
      final chatsSnapshot = await _firestore
          .collection('chats')
          .orderBy('lastMessageAt', descending: true)
          .limit(5)
          .get();

      // 각 채팅방의 메시지 프리로드
      for (final chatDoc in chatsSnapshot.docs) {
        final result = await getChatMessages(chatId: chatDoc.id);
        // Continue even if individual chat fails
        result.fold(
          (failure) => _logDebug('Failed to preload chat ${chatDoc.id}: $failure'),
          (_) => null,
        );
      }

      _logDebug('Preloaded ${chatsSnapshot.docs.length} recent chats');
      return right(null);
    } on FirebaseException catch (e) {
      _logError('Firestore error preloading recent chats', e);
      return left(CacheFailure.firestoreError(e.message ?? e.toString()));
    } catch (e) {
      _logError('Error preloading recent chats', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> preloadPopularPosts() async {
    try {
      // 인기 포스트 프리로드
      final result = await getFeedPosts(limit: 10);
      return result.fold(
        (failure) {
          _logError('Failed to preload popular posts', failure);
          return left(failure);
        },
        (_) {
          _logDebug('Preloaded popular posts');
          return right(null);
        },
      );
    } catch (e) {
      _logError('Error preloading popular posts', e);
      return left(CacheFailure.hiveError(e.toString()));
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
  Future<Either<CacheFailure, void>> clearChatMessages(String chatId) async {
    try {
      final cacheKey = CacheKeys.chatMessages(chatId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing chat messages for $chatId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearUserProfile(String userId) async {
    try {
      final cacheKey = CacheKeys.userProfile(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing user profile for $userId', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAll() async {
    try {
      return await clear(layer: CacheLayer.all);
    } catch (e) {
      _logError('Error clearing all cache', e);
      return left(CacheFailure.hiveError(e.toString()));
    }
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

  // 에러 로깅
  void _logError(String message, Object error) {
    if (kDebugMode) {
      debugPrint('[UnifiedCache ERROR] $message: $error');
    }
  }
}
