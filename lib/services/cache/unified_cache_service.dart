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
import '/services/logging/logger_service.dart';

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
      Logger.debug(
        'Hive cache opened successfully - Box: unified_cache',
        tag: 'Cache/Init',
      );
    } catch (e) {
      // 손상된 캐시 제거 후 재생성
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Hive box open failed',
        error: e,
      );
      try {
        await Hive.deleteBoxFromDisk('unified_cache');
        Logger.info(
          'Corrupted Hive cache deleted - Box: unified_cache',
          tag: 'Cache/Init',
        );
      } catch (deleteError) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive box delete failed',
          error: deleteError,
        );
      }

      // 새로운 박스 생성
      _localCache = await Hive.openBox('unified_cache');
      Logger.debug(
        'New Hive cache created after corruption - Box: unified_cache',
        tag: 'Cache/Init',
      );
    }

    Logger.info(
      'UnifiedCacheService initialized - L1: Memory (LRU 100), L2: Hive, L3: Firestore',
      tag: 'Cache/Init',
    );
  }

  @override
  Future<Either<CacheFailure, T>> get<T>(String key, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      // L1: Memory Cache
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        final memoryResult = _memoryCache.get<T>(key);
        if (memoryResult != null) {
          CacheLogger.cacheHit(key: key, layer: 'L1');
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
              CacheLogger.cacheHit(key: key, layer: 'L2');
              return right(localResult);
            } else {
              CacheLogger.cacheError(
                errorType: 'typeMismatch',
                message: 'Type mismatch: expected $T, got ${localResult.runtimeType}',
              );
              // Delete corrupted cache entry
              await _localCache.delete(key);
              return left(CacheFailure.typeMismatch(
                expected: T.toString(),
                actual: localResult.runtimeType.toString(),
              ));
            }
          }
        } on HiveError catch (e) {
          CacheLogger.cacheError(
            errorType: 'hiveError',
            message: 'Cache get failed',
            error: e,
          );
          return left(CacheFailure.hiveError(e.message));
        }
      }

      // L3: Remote (Firestore는 자체 오프라인 캐시 사용)
      // 특정 쿼리는 도메인별 메서드에서 처리

      CacheLogger.cacheMiss(key: key, layer: 'L1+L2');
      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Cache get operation failed',
        error: e,
      );
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
        CacheLogger.cacheSet(key: key, layer: 'L1', ttl: ttl);
      }

      // L2: Local DB (Hive)
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          await _localCache.put(key, value);
          CacheLogger.cacheSet(key: key, layer: 'L2');
        } on HiveError catch (e) {
          CacheLogger.cacheError(
            errorType: 'hiveError',
            message: 'Cache set failed',
            error: e,
          );
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Cache set operation failed',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> remove(String key, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.remove(key);
        CacheLogger.cacheInvalidated(key: key);
      }

      // L2: Local DB
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          await _localCache.delete(key);
          CacheLogger.cacheInvalidated(key: key);
        } on HiveError catch (e) {
          CacheLogger.cacheError(
            errorType: 'hiveError',
            message: 'Cache remove failed',
            error: e,
          );
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Cache remove operation failed',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> invalidate(String pattern, {CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.invalidate(pattern);
        Logger.debug(
          'Cache invalidation (L1/Memory) - Pattern: ${Logger.maskSensitive(pattern)}',
          tag: 'Cache/Invalidate',
        );
      }

      // L2: Local DB
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          final keysToDelete = _localCache.keys
              .where((key) => key.toString().contains(pattern))
              .toList();

          Logger.debug(
            'Cache invalidation (L2/Hive) - Pattern: ${Logger.maskSensitive(pattern)}, Found: ${keysToDelete.length} keys',
            tag: 'Cache/Invalidate',
          );

          for (final key in keysToDelete) {
            await _localCache.delete(key);
            CacheLogger.cacheInvalidated(key: key.toString());
          }
        } on HiveError catch (e) {
          CacheLogger.cacheError(
            errorType: 'hiveError',
            message: 'Cache invalidate failed',
            error: e,
          );
          return left(CacheFailure.hiveError(e.message));
        }
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Cache invalidate operation failed',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clear({CacheLayer? layer}) async {
    layer ??= CacheLayer.all;

    try {
      if (layer == CacheLayer.memory || layer == CacheLayer.all) {
        _memoryCache.clear();
        Logger.info(
          'Cache cleared (L1/Memory)',
          tag: 'Cache/Clear',
        );
      }

      // L2: Local DB
      if (layer == CacheLayer.local || layer == CacheLayer.all) {
        try {
          await _localCache.clear();
          Logger.info(
            'Cache cleared (L2/Hive)',
            tag: 'Cache/Clear',
          );
        } on HiveError catch (e) {
          CacheLogger.cacheError(
            errorType: 'hiveError',
            message: 'Cache clear failed',
            error: e,
          );
          return left(CacheFailure.hiveError(e.message));
        }
      }

      CacheLogger.cacheCleared();
      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Cache clear operation failed',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(chatId), layer: 'L1');
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
              Logger.debug(
                'Corrupted message data found in cache: $e',
                tag: 'Cache/Chat',
              );
            }
          }

          // 손상된 데이터가 있으면 Hive 캐시 제거
          if (hasCorruptedData) {
            Logger.debug(
              'Corrupted cache data detected - Key: ${Logger.maskSensitive(cacheKey)}',
              tag: 'Cache/Chat',
            );
            await _localCache.delete(cacheKey);
            // Firestore에서 다시 로드하도록 진행
          } else if (validMessages.isNotEmpty) {
            // 유효한 메시지들만 반환
            _memoryCache.set(cacheKey, validMessages,
                ttl: const Duration(minutes: 5));
            stopwatch.stop();
            CacheStatistics.instance
                .recordL2Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
            CacheLogger.cacheHit(key: Logger.maskSensitive(chatId), layer: 'L2');
            // 백그라운드에서 동기화
            _syncChatMessagesInBackground(chatId);
            return right(validMessages);
          }
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for chat messages',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Hive read error for chat messages: $e', tag: 'Cache/Chat');
        // 캐시 데이터가 완전히 손상된 경우 삭제
        try {
          await _localCache.delete(cacheKey);
          Logger.debug(
            'Removed corrupted cache entry - Key: ${Logger.maskSensitive(cacheKey)}',
            tag: 'Cache/Chat',
          );
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
          Logger.debug('Failed to save to Hive: $e', tag: 'Cache/Chat');
        }
        stopwatch.stop();
        CacheStatistics.instance
            .recordL3Hit(responseTimeMs: stopwatch.elapsedMilliseconds);
        CacheLogger.cacheHit(key: Logger.maskSensitive(chatId), layer: 'L3');

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
            Logger.debug('Failed to save to Hive: $e', tag: 'Cache/Chat');
          }
          stopwatch.stop();
          CacheStatistics.instance
              .recordNetworkHit(responseTimeMs: stopwatch.elapsedMilliseconds);
          CacheLogger.cacheMiss(key: Logger.maskSensitive(chatId), layer: 'L1+L2+L3');

          return right(messages);
        } on FirebaseException catch (e) {
          CacheLogger.cacheError(
            errorType: 'firestoreError',
            message: 'Firestore error getting chat messages',
            error: e,
          );
          return left(CacheFailure.firestoreError(e.message ?? e.toString()));
        }
      }
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'firestoreError',
        message: 'Unexpected error getting chat messages',
        error: e,
      );
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
      CacheLogger.cacheSet(key: Logger.maskSensitive(chatId), layer: 'L1', ttl: const Duration(minutes: 5));
      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting chat messages',
        error: e,
      );
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
        CacheLogger.cacheHit(key: 'feed_posts', layer: 'L1');
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
        CacheLogger.cacheHit(key: 'feed_posts', layer: 'L3');
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
          CacheLogger.cacheMiss(key: 'feed_posts', layer: 'L1+L3');
          return right(posts);
        } on FirebaseException catch (e) {
          CacheLogger.cacheError(
            errorType: 'firestoreError',
            message: 'Firestore error getting feed posts',
            error: e,
          );
          return left(CacheFailure.firestoreError(e.message ?? e.toString()));
        }
      }
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'firestoreError',
        message: 'Unexpected error getting feed posts',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setFeedPosts(List<Map<String, dynamic>> posts) async {
    try {
      final cacheKey = CacheKeys.feedPosts();
      _memoryCache.set(cacheKey, posts, ttl: const Duration(minutes: 10));
      CacheLogger.cacheSet(key: 'feed_posts', layer: 'L1', ttl: const Duration(minutes: 10));
      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting feed posts',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearFeedPosts() async {
    try {
      final cacheKey = CacheKeys.feedPosts();
      _memoryCache.remove(cacheKey);
      CacheLogger.cacheInvalidated(key: 'feed_posts');
      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing feed posts',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final profile = UserProfile.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, profile, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(profile);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read error for user profile',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Hive read error for user profile: $e', tag: 'Cache/Profile');
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
            Logger.debug(
              'Cached user profile to Hive - User: ${Logger.maskSensitive(userId)}',
              tag: 'Cache/Profile',
            );
          } catch (e) {
            Logger.debug('Failed to save user profile to Hive: $e', tag: 'Cache/Profile');
          }

          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L3');
          return right(user);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting user profile',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug('Failed to get user profile from Firestore', tag: 'Cache/Profile');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'firestoreError',
        message: 'Unexpected error getting user profile',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setUserProfile(String userId, UserProfile user) async {
    try {
      final cacheKey = CacheKeys.userProfile(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
      CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L1', ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, user.toJson());
        CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save user profile to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Failed to save user profile to Hive: $e', tag: 'Cache/Profile');
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting user profile',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final settings = UserSettings.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, settings, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(settings);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read error for user settings',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Hive read error for user settings: $e', tag: 'Cache/Settings');
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
            Logger.debug(
              'Cached user settings to Hive - User: ${Logger.maskSensitive(userId)}',
              tag: 'Cache/Settings',
            );
          } catch (e) {
            Logger.debug('Failed to save user settings to Hive: $e', tag: 'Cache/Settings');
          }

          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L3');
          return right(settings);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting user settings',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug('Failed to get user settings from Firestore', tag: 'Cache/Settings');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'firestoreError',
        message: 'Unexpected error getting user settings',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setUserSettings(String userId, UserSettings settings) async {
    try {
      final cacheKey = CacheKeys.userSettings(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, settings, ttl: const Duration(hours: 1));
      CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L1', ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, settings.toJson());
        CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save user settings to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Failed to save user settings to Hive: $e', tag: 'Cache/Settings');
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting user settings',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearUserSettings(String userId) async {
    try {
      final cacheKey = CacheKeys.userSettings(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing user settings',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is List) {
          final interests = List<String>.from(hiveData);
          // Promote to memory cache
          _memoryCache.set(cacheKey, interests, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(interests);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read error for user interests',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Hive read error for user interests: $e', tag: 'Cache/Interests');
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
            Logger.debug(
              'Cached user interests to Hive - User: ${Logger.maskSensitive(userId)}',
              tag: 'Cache/Interests',
            );
          } catch (e) {
            Logger.debug('Failed to save user interests to Hive: $e', tag: 'Cache/Interests');
          }

          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L3');
          return right(interests);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting user interests',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug('Failed to get user interests from Firestore', tag: 'Cache/Interests');
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'firestoreError',
        message: 'Unexpected error getting user interests',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setUserInterests(String userId, List<String> interests) async {
    try {
      final cacheKey = CacheKeys.userInterests(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, interests, ttl: const Duration(hours: 1));
      CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L1', ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, interests);
        CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save user interests to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug('Failed to save user interests to Hive: $e', tag: 'Cache/Interests');
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting user interests',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearUserInterests(String userId) async {
    try {
      final cacheKey = CacheKeys.userInterests(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing user interests',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final profileInfo = ProfileInfo.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, profileInfo, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(profileInfo);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for ProfileInfo',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for ProfileInfo ${Logger.maskSensitive(userId)}: $e',
          tag: 'Cache/ProfileInfo',
        );
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
            Logger.debug(
              'Cached ProfileInfo to Hive: ${Logger.maskSensitive(userId)}',
              tag: 'Cache/ProfileInfo',
            );
          } catch (e) {
            Logger.debug(
              'Failed to save ProfileInfo to Hive: $e',
              tag: 'Cache/ProfileInfo',
            );
          }

          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L3');
          return right(profileInfo);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting ProfileInfo',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug(
          'Failed to get ProfileInfo from Firestore: ${Logger.maskSensitive(userId)}',
          tag: 'Cache/ProfileInfo',
        );
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting ProfileInfo',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setProfileInfo(String userId, ProfileInfo info) async {
    try {
      final cacheKey = CacheKeys.profileInfo(userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, info, ttl: const Duration(hours: 1));
      CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L1', ttl: const Duration(hours: 1));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, info.toJson());
        CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save ProfileInfo to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save ProfileInfo to Hive: $e',
          tag: 'Cache/ProfileInfo',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting ProfileInfo',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearProfileInfo(String userId) async {
    try {
      final cacheKey = CacheKeys.profileInfo(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing ProfileInfo',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is double) {
          // Promote to memory cache
          _memoryCache.set(cacheKey, hiveData, ttl: const Duration(minutes: 30));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(hiveData);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for profile completion',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for profile completion ${Logger.maskSensitive(userId)}: $e',
          tag: 'Cache/ProfileCompletion',
        );
      }

      // L3: 프로필 완성도는 계산된 값이므로 Firestore에서 직접 가져오지 않음
      // 호출하는 쪽에서 UserProfile을 가져와서 completionRate를 계산한 후 setProfileCompletion 호출

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting profile completion',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setProfileCompletion(String userId, double percentage) async {
    try {
      final cacheKey = CacheKeys.profileCompletion(userId);

      // L1: Memory Cache (30분 TTL - 자주 변할 수 있음)
      _memoryCache.set(cacheKey, percentage, ttl: const Duration(minutes: 30));
      CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L1', ttl: const Duration(minutes: 30));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, percentage);
        CacheLogger.cacheSet(key: Logger.maskSensitive(userId), layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save profile completion to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save profile completion to Hive: $e',
          tag: 'Cache/ProfileCompletion',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting profile completion',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearProfileCompletion(String userId) async {
    try {
      final cacheKey = CacheKeys.profileCompletion(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing profile completion',
        error: e,
      );
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
        CacheLogger.cacheHit(key: 'available_characters', layer: 'L1');
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
          CacheLogger.cacheHit(key: 'available_characters', layer: 'L2');
          return right(characters);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for available characters',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for available characters: $e',
          tag: 'Cache/Characters',
        );
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
          Logger.debug(
            'Cached available characters to Hive',
            tag: 'Cache/Characters',
          );
        } catch (e) {
          Logger.debug(
            'Failed to save available characters to Hive: $e',
            tag: 'Cache/Characters',
          );
        }

        CacheLogger.cacheHit(key: 'available_characters', layer: 'L3');
        return right(characters);
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting available characters',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug(
          'Failed to get available characters from Firestore: $e',
          tag: 'Cache/Characters',
        );
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting available characters',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setAvailableCharacters(List<Character> characters) async {
    try {
      final cacheKey = CacheKeys.availableCharacters();

      // L1: Memory Cache (24시간 TTL)
      _memoryCache.set(cacheKey, characters, ttl: const Duration(hours: 24));
      CacheLogger.cacheSet(key: 'available_characters', layer: 'L1', ttl: const Duration(hours: 24));

      // L2: Hive Cache
      try {
        final serializedCharacters = characters.map((c) => c.toJson()).toList();
        await _localCache.put(cacheKey, serializedCharacters);
        CacheLogger.cacheSet(key: 'available_characters', layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save available characters to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save available characters to Hive: $e',
          tag: 'Cache/Characters',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting available characters',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAvailableCharacters() async {
    try {
      final cacheKey = CacheKeys.availableCharacters();
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing available characters',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(postId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final counts = VoteCounts.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, counts, ttl: const Duration(minutes: 5));
          CacheLogger.cacheHit(key: Logger.maskSensitive(postId), layer: 'L2');
          return right(counts);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for vote counts',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for vote counts ${Logger.maskSensitive(postId)}: $e',
          tag: 'Cache/VoteCounts',
        );
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
            Logger.debug(
              'Cached vote counts to Hive: ${Logger.maskSensitive(postId)}',
              tag: 'Cache/VoteCounts',
            );
          } catch (e) {
            Logger.debug(
              'Failed to save vote counts to Hive: $e',
              tag: 'Cache/VoteCounts',
            );
          }

          CacheLogger.cacheHit(key: Logger.maskSensitive(postId), layer: 'L3');
          return right(counts);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting vote counts',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug(
          'Failed to get vote counts from Firestore: ${Logger.maskSensitive(postId)}',
          tag: 'Cache/VoteCounts',
        );
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting vote counts',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setVoteCounts(String postId, VoteCounts counts) async {
    try {
      final cacheKey = CacheKeys.voteCounts(postId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, counts, ttl: const Duration(minutes: 5));
      CacheLogger.cacheSet(key: Logger.maskSensitive(postId), layer: 'L1', ttl: const Duration(minutes: 5));

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, counts.toJson());
        CacheLogger.cacheSet(key: Logger.maskSensitive(postId), layer: 'L2');
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save vote counts to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save vote counts to Hive: $e',
          tag: 'Cache/VoteCounts',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting vote counts',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearVoteCounts(String postId) async {
    try {
      final cacheKey = CacheKeys.voteCounts(postId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing vote counts',
        error: e,
      );
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
        CacheLogger.cacheHit(
          key: '${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
          layer: 'L1',
        );
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final state = VoteCacheState.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, state, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(
            key: '${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
            layer: 'L2',
          );
          return right(state);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for vote state',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for vote state ${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}: $e',
          tag: 'Cache/VoteState',
        );
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
            Logger.debug(
              'Cached vote state to Hive: ${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
              tag: 'Cache/VoteState',
            );
          } catch (e) {
            Logger.debug(
              'Failed to save vote state to Hive: $e',
              tag: 'Cache/VoteState',
            );
          }

          CacheLogger.cacheHit(
            key: '${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
            layer: 'L3',
          );
          return right(state);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting vote state',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug(
          'Failed to get vote state from Firestore: ${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
          tag: 'Cache/VoteState',
        );
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting vote state',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setVoteState(String postId, String userId, VoteCacheState state) async {
    try {
      final cacheKey = CacheKeys.voteState(postId, userId);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, state, ttl: const Duration(hours: 1));
      CacheLogger.cacheSet(
        key: '${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
        layer: 'L1',
        ttl: const Duration(hours: 1),
      );

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, state.toJson());
        CacheLogger.cacheSet(
          key: '${Logger.maskSensitive(postId)}/${Logger.maskSensitive(userId)}',
          layer: 'L2',
        );
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save vote state to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save vote state to Hive: $e',
          tag: 'Cache/VoteState',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting vote state',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearVoteState(String postId, String userId) async {
    try {
      final cacheKey = CacheKeys.voteState(postId, userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing vote state',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is List) {
          final history = hiveData.cast<Map<String, dynamic>>();
          // Promote to memory cache
          _memoryCache.set(cacheKey, history, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(history);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for vote history',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for vote history ${Logger.maskSensitive(userId)}: $e',
          tag: 'Cache/VoteHistory',
        );
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
            Logger.debug(
              'Cached vote history to Hive: ${Logger.maskSensitive(userId)}',
              tag: 'Cache/VoteHistory',
            );
          } catch (e) {
            Logger.debug(
              'Failed to save vote history to Hive: $e',
              tag: 'Cache/VoteHistory',
            );
          }

          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L3');
          return right(history);
        }
      } on FirebaseException catch (e) {
        CacheLogger.cacheError(
          errorType: 'firestoreError',
          message: 'Firestore error getting vote history',
          error: e,
        );
        return left(CacheFailure.firestoreError(e.message ?? e.toString()));
      } catch (e) {
        Logger.debug(
          'Failed to get vote history from Firestore: ${Logger.maskSensitive(userId)}',
          tag: 'Cache/VoteHistory',
        );
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting vote history',
        error: e,
      );
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
        CacheLogger.cacheSet(
          key: Logger.maskSensitive(userId),
          layer: 'L1+L2',
          ttl: const Duration(hours: 1),
        );
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save vote history to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save vote history to Hive: $e',
          tag: 'Cache/VoteHistory',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting vote history',
        error: e,
      );
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
        CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L1');
        return right(memCached);
      }

      // L2: Hive Cache (10-30ms)
      try {
        final hiveData = await _localCache.get(cacheKey);
        if (hiveData != null && hiveData is Map) {
          final user = AuthUser.fromJson(Map<String, dynamic>.from(hiveData));
          // Promote to memory cache
          _memoryCache.set(cacheKey, user, ttl: const Duration(hours: 1));
          CacheLogger.cacheHit(key: Logger.maskSensitive(userId), layer: 'L2');
          return right(user);
        }
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Hive read failed for auth user',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Hive read error for auth user ${Logger.maskSensitive(userId)}: $e',
          tag: 'Cache/Auth',
        );
      }

      return left(const CacheFailure.notFound());
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Unexpected error getting auth user',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setAuthUser(String userId, AuthUser user, {Duration? ttl}) async {
    try {
      final cacheKey = CacheKeys.authUser(userId);
      final ttlDuration = ttl ?? const Duration(hours: 1);

      // L1: Memory Cache
      _memoryCache.set(cacheKey, user, ttl: ttlDuration);

      // L2: Hive Cache
      try {
        await _localCache.put(cacheKey, user.toJson());
        CacheLogger.cacheSet(
          key: Logger.maskSensitive(userId),
          layer: 'L1+L2',
          ttl: ttlDuration,
        );
      } on HiveError catch (e) {
        CacheLogger.cacheError(
          errorType: 'hiveError',
          message: 'Failed to save auth user to Hive',
          error: e,
        );
        return left(CacheFailure.hiveError(e.message));
      } catch (e) {
        Logger.debug(
          'Failed to save auth user to Hive: $e',
          tag: 'Cache/Auth',
        );
      }

      return right(null);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting auth user',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAuthUser(String userId) async {
    try {
      final cacheKey = CacheKeys.authUser(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing auth user',
        error: e,
      );
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
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error setting auth token',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAuthToken(String userId) async {
    try {
      final cacheKey = CacheKeys.authToken(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing auth token',
        error: e,
      );
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
          (failure) => Logger.debug(
            'Failed to preload chat ${Logger.maskSensitive(chatDoc.id)}: $failure',
            tag: 'Cache/Preload',
          ),
          (_) => null,
        );
      }

      Logger.debug(
        'Preloaded ${chatsSnapshot.docs.length} recent chats',
        tag: 'Cache/Preload',
      );
      return right(null);
    } on FirebaseException catch (e) {
      CacheLogger.cacheError(
        errorType: 'firestoreError',
        message: 'Firestore error preloading recent chats',
        error: e,
      );
      return left(CacheFailure.firestoreError(e.message ?? e.toString()));
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error preloading recent chats',
        error: e,
      );
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
          CacheLogger.cacheError(
            errorType: 'hiveError',
            message: 'Failed to preload popular posts',
            error: failure,
          );
          return left(failure);
        },
        (_) {
          Logger.debug(
            'Preloaded popular posts',
            tag: 'Cache/Preload',
          );
          return right(null);
        },
      );
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error preloading popular posts',
        error: e,
      );
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
      Logger.debug(
        'Error getting Hive size: $e',
        tag: 'Cache/Stats',
      );
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
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing chat messages',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearUserProfile(String userId) async {
    try {
      final cacheKey = CacheKeys.userProfile(userId);
      return await remove(cacheKey, layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing user profile',
        error: e,
      );
      return left(CacheFailure.hiveError(e.toString()));
    }
  }

  @override
  Future<Either<CacheFailure, void>> clearAll() async {
    try {
      return await clear(layer: CacheLayer.all);
    } catch (e) {
      CacheLogger.cacheError(
        errorType: 'hiveError',
        message: 'Error clearing all cache',
        error: e,
      );
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
}
