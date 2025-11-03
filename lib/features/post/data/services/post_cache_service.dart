import 'package:flutter/foundation.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/domain/usecases/get_feed_usecase.dart'; // FeedSortBy, FeedFilter
import '/services/cache/unified_cache_service.dart';

/// Post Cache Service - 3-Layer Caching Strategy
///
/// **Phase 3: Cache Integration**
///
/// **Caching Strategy**:
/// - L1 (Memory): <10ms, SimpleMemoryCache with LRU eviction
/// - L2 (Hive): 10-30ms, persistent local storage
/// - L3 (Firestore): 50-500ms, offline support enabled
///
/// **Cache-First Pattern**:
/// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore)
/// 2. Serve stale data immediately if available
/// 3. Revalidate in background if TTL expired
///
/// **TTL Configuration**:
/// - Feed posts: 5 minutes
/// - Post detail: 10 minutes
/// - Popular/Trending: 10 minutes
/// - User posts: 5 minutes
class PostCacheService {
  final UnifiedCacheService _cache;

  PostCacheService({required UnifiedCacheService cache}) : _cache = cache;

  // ────────────────────────────────────────────────────────────────
  // Cache Key Generation
  // ────────────────────────────────────────────────────────────────

  String _feedCacheKey({
    required FeedSortBy sortBy,
    int limit = 20,
    FeedFilter? filter,
  }) {
    final sortByStr = sortBy.name;
    final filterStr = filter != null ? '_filter_${filter.hashCode}' : '';
    return 'feed_${sortByStr}_limit_$limit$filterStr';
  }

  String _postCacheKey(String postId) => 'post_detail_$postId';

  String _popularPostsCacheKey({int limit = 20, Duration? timeWindow}) {
    final days = timeWindow?.inDays ?? 7;
    return 'posts_popular_limit_${limit}_days_$days';
  }

  String _trendingPostsCacheKey({int limit = 20}) {
    return 'posts_trending_limit_$limit';
  }

  String _userPostsCacheKey({
    required String userId,
    int limit = 20,
  }) {
    return 'posts_user_${userId}_limit_$limit';
  }

  // ────────────────────────────────────────────────────────────────
  // Feed Posts Cache Operations
  // ────────────────────────────────────────────────────────────────

  /// Get feed posts from cache (L1 → L2 → L3 cascade)
  ///
  /// **Returns**:
  /// - Cached posts if found in any layer
  /// - Empty list if cache miss
  ///
  /// **TTL**: 5 minutes
  Future<List<PostDisplay>> getFeedPosts({
    required FeedSortBy sortBy,
    int limit = 20,
    FeedFilter? filter,
  }) async {
    final cacheKey = _feedCacheKey(sortBy: sortBy, limit: limit, filter: filter);
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return cachedData
            .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ PostCacheService: Failed to deserialize feed posts - $e');
        await _cache.invalidate(cacheKey);
        return [];
      }
    }

    return [];
  }

  /// Set feed posts in cache (write to all layers)
  ///
  /// **Strategy**:
  /// - Write to L1 (Memory), L2 (Hive), L3 (Firestore) simultaneously
  /// - TTL: 5 minutes
  Future<void> setFeedPosts({
    required FeedSortBy sortBy,
    required List<PostDisplay> posts,
    int limit = 20,
    FeedFilter? filter,
  }) async {
    final cacheKey = _feedCacheKey(sortBy: sortBy, limit: limit, filter: filter);
    final jsonData = posts.map((post) => post.toJson()).toList();

    await _cache.set(
      cacheKey,
      jsonData,
      ttl: const Duration(minutes: 5),
    );

    debugPrint('✅ PostCacheService: Cached ${posts.length} feed posts ($cacheKey)');
  }

  // ────────────────────────────────────────────────────────────────
  // Post Detail Cache Operations
  // ────────────────────────────────────────────────────────────────

  /// Get post detail from cache
  ///
  /// **Returns**:
  /// - Cached post if found
  /// - null if cache miss
  ///
  /// **TTL**: 10 minutes
  Future<PostDisplay?> getPost(String postId) async {
    final cacheKey = _postCacheKey(postId);
    final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);

    if (cachedData != null) {
      try {
        return PostDisplay.fromJson(cachedData);
      } catch (e) {
        debugPrint('⚠️ PostCacheService: Failed to deserialize post detail - $e');
        await _cache.invalidate(cacheKey);
        return null;
      }
    }

    return null;
  }

  /// Set post detail in cache
  ///
  /// **TTL**: 10 minutes
  Future<void> setPost(PostDisplay post) async {
    final cacheKey = _postCacheKey(post.id);
    final jsonData = post.toJson();

    await _cache.set(
      cacheKey,
      jsonData,
      ttl: const Duration(minutes: 10),
    );

    debugPrint('✅ PostCacheService: Cached post detail (${post.id})');
  }

  // ────────────────────────────────────────────────────────────────
  // Popular Posts Cache Operations
  // ────────────────────────────────────────────────────────────────

  /// Get popular posts from cache
  ///
  /// **TTL**: 10 minutes
  Future<List<PostDisplay>> getPopularPosts({
    int limit = 20,
    Duration timeWindow = const Duration(days: 7),
  }) async {
    final cacheKey = _popularPostsCacheKey(limit: limit, timeWindow: timeWindow);
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return cachedData
            .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ PostCacheService: Failed to deserialize popular posts - $e');
        await _cache.invalidate(cacheKey);
        return [];
      }
    }

    return [];
  }

  /// Set popular posts in cache
  ///
  /// **TTL**: 10 minutes
  Future<void> setPopularPosts({
    required List<PostDisplay> posts,
    int limit = 20,
    Duration timeWindow = const Duration(days: 7),
  }) async {
    final cacheKey = _popularPostsCacheKey(limit: limit, timeWindow: timeWindow);
    final jsonData = posts.map((post) => post.toJson()).toList();

    await _cache.set(
      cacheKey,
      jsonData,
      ttl: const Duration(minutes: 10),
    );

    debugPrint('✅ PostCacheService: Cached ${posts.length} popular posts');
  }

  // ────────────────────────────────────────────────────────────────
  // Trending Posts Cache Operations
  // ────────────────────────────────────────────────────────────────

  /// Get trending posts from cache
  ///
  /// **TTL**: 10 minutes
  Future<List<PostDisplay>> getTrendingPosts({int limit = 20}) async {
    final cacheKey = _trendingPostsCacheKey(limit: limit);
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return cachedData
            .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ PostCacheService: Failed to deserialize trending posts - $e');
        await _cache.invalidate(cacheKey);
        return [];
      }
    }

    return [];
  }

  /// Set trending posts in cache
  ///
  /// **TTL**: 10 minutes
  Future<void> setTrendingPosts({
    required List<PostDisplay> posts,
    int limit = 20,
  }) async {
    final cacheKey = _trendingPostsCacheKey(limit: limit);
    final jsonData = posts.map((post) => post.toJson()).toList();

    await _cache.set(
      cacheKey,
      jsonData,
      ttl: const Duration(minutes: 10),
    );

    debugPrint('✅ PostCacheService: Cached ${posts.length} trending posts');
  }

  // ────────────────────────────────────────────────────────────────
  // User Posts Cache Operations
  // ────────────────────────────────────────────────────────────────

  /// Get user posts from cache
  ///
  /// **TTL**: 5 minutes
  Future<List<PostDisplay>> getUserPosts({
    required String userId,
    int limit = 20,
  }) async {
    final cacheKey = _userPostsCacheKey(userId: userId, limit: limit);
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return cachedData
            .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ PostCacheService: Failed to deserialize user posts - $e');
        await _cache.invalidate(cacheKey);
        return [];
      }
    }

    return [];
  }

  /// Set user posts in cache
  ///
  /// **TTL**: 5 minutes
  Future<void> setUserPosts({
    required String userId,
    required List<PostDisplay> posts,
    int limit = 20,
  }) async {
    final cacheKey = _userPostsCacheKey(userId: userId, limit: limit);
    final jsonData = posts.map((post) => post.toJson()).toList();

    await _cache.set(
      cacheKey,
      jsonData,
      ttl: const Duration(minutes: 5),
    );

    debugPrint('✅ PostCacheService: Cached ${posts.length} user posts ($userId)');
  }

  // ────────────────────────────────────────────────────────────────
  // Preloading Operations
  // ────────────────────────────────────────────────────────────────

  /// Preload popular posts into cache
  ///
  /// **Usage**: Call from main.dart during app initialization
  ///
  /// **Strategy**:
  /// - Non-blocking background operation
  /// - Fails silently if error occurs
  Future<void> preloadPopularPosts() async {
    try {
      // Check if already cached
      final cached = await getPopularPosts();
      if (cached.isNotEmpty) {
        debugPrint('📦 PostCacheService: Popular posts already cached');
        return;
      }

      // Preloading will be handled by repository calling setPopularPosts
      debugPrint('📦 PostCacheService: Popular posts preloading initiated');
    } catch (e) {
      debugPrint('⚠️ PostCacheService: Preload popular posts failed - $e');
    }
  }

  /// Preload trending posts into cache
  ///
  /// **Usage**: Call from main.dart during app initialization
  Future<void> preloadTrendingPosts() async {
    try {
      final cached = await getTrendingPosts();
      if (cached.isNotEmpty) {
        debugPrint('📦 PostCacheService: Trending posts already cached');
        return;
      }

      debugPrint('📦 PostCacheService: Trending posts preloading initiated');
    } catch (e) {
      debugPrint('⚠️ PostCacheService: Preload trending posts failed - $e');
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Cache Management Operations
  // ────────────────────────────────────────────────────────────────

  /// Invalidate specific post from all cache layers
  ///
  /// **Use Cases**:
  /// - After post update/delete
  /// - After vote cast
  /// - After comment added
  Future<void> invalidatePost(String postId) async {
    final cacheKey = _postCacheKey(postId);
    await _cache.invalidate(cacheKey);
    debugPrint('🗑️ PostCacheService: Invalidated post cache ($postId)');
  }

  /// Invalidate feed cache
  ///
  /// **Use Cases**:
  /// - After new post creation
  /// - After post deletion
  Future<void> invalidateFeed({
    required FeedSortBy sortBy,
    int limit = 20,
    FeedFilter? filter,
  }) async {
    final cacheKey = _feedCacheKey(sortBy: sortBy, limit: limit, filter: filter);
    await _cache.invalidate(cacheKey);
    debugPrint('🗑️ PostCacheService: Invalidated feed cache ($cacheKey)');
  }

  /// Invalidate all post-related caches
  ///
  /// **Use Cases**:
  /// - During logout
  /// - After major data changes
  Future<void> clearAll() async {
    try {
      // Clear all post-related cache keys
      await _cache.invalidate('feed_');
      await _cache.invalidate('post_detail_');
      await _cache.invalidate('posts_popular_');
      await _cache.invalidate('posts_trending_');
      await _cache.invalidate('posts_user_');

      debugPrint('🗑️ PostCacheService: Cleared all post caches');
    } catch (e) {
      debugPrint('⚠️ PostCacheService: Failed to clear all caches - $e');
    }
  }

  /// Get cache statistics for monitoring
  ///
  /// **Returns**: Cache hit rates and performance metrics
  Map<String, dynamic> getStatistics() {
    return _cache.getStatistics();
  }
}
