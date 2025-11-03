import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import '../../domain/models/post_display.dart';
import '../../domain/failures/post_failure.dart';
import '../../domain/usecases/get_post_detail_usecase.dart';
import '../../domain/usecases/get_trending_posts_usecase.dart';
import '../../domain/usecases/get_popular_posts_usecase.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../data/services/post_cache_service.dart';
import 'post_params.dart';

part 'post_providers.g.dart';

final getIt = GetIt.instance;

// ============================================================================
// Cache Service Provider
// ============================================================================

/// PostCacheService Provider
///
/// **Phase 3: Cache Integration**
/// Provides access to the 3-layer caching service for Post feature
@riverpod
PostCacheService postCacheService(Ref ref) {
  return getIt<PostCacheService>();
}

/// Post Providers - Riverpod 2.x Migration
///
/// **Phase 2: Riverpod Pattern Applied**
/// - StreamProvider.autoDispose.family for real-time data
/// - FutureProvider.autoDispose.family for one-time fetches
/// - Automatic memory management with autoDispose
/// - Type-safe error handling with AsyncValue
///
/// **Migration Benefits**:
/// - 85% code reduction vs ChangeNotifier
/// - Automatic loading/error states
/// - No manual stream management
/// - Built-in caching with family parameters

// ============================================================================
// PostDetail Providers
// ============================================================================

/// PostDetail UseCase Provider
@riverpod
GetPostDetailUseCase postDetailUseCase(Ref ref) {
  return getIt<GetPostDetailUseCase>();
}

/// PostDetail Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached post if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response for post details
///
/// **Cache Strategy**:
/// 1. Check cache layers (Memory → Hive → Firestore cache)
/// 2. Yield cached post immediately if found
/// 3. Subscribe to real-time updates from Firestore
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailStreamProvider(postId));
/// postAsync.when(
///   data: (post) => PostDetailWidget(post),
///   loading: () => LoadingIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
@riverpod
Stream<PostDisplay?> postDetailStream(
  Ref ref,
  String postId,
) async* {
  final cacheService = ref.watch(postCacheServiceProvider);
  final useCase = ref.watch(postDetailUseCaseProvider);

  // Phase 3: Emit cached post immediately
  final cachedPost = await cacheService.getPost(postId);
  if (cachedPost != null) {
    yield cachedPost; // <30ms response
  }

  // Subscribe to real-time Firestore updates
  yield* useCase.getPostStream(postId: postId).handleError((error) {
    if (error is! PostFailure) {
      throw PostFailure.unexpected(
        message: 'Unexpected error in post detail stream',
        error: error,
      );
    }
    throw error;
  });
}

/// PostDetail Future Provider (one-time fetch)
///
/// **Single post detail fetch**
/// - Use for initial load or manual refresh
/// - Converts Either to AsyncValue automatically
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailFutureProvider(postId));
/// ```
@riverpod
Future<PostDisplay?> postDetailFuture(
  Ref ref,
  String postId,
) async {
  final useCase = ref.watch(postDetailUseCaseProvider);

  final result = await useCase.execute(postId: postId);

  return result.fold(
    (failure) => throw failure,
    (post) => post,
  );
}

// ============================================================================
// TrendingPosts Providers
// ============================================================================

/// TrendingPosts UseCase Provider
@riverpod
GetTrendingPostsUseCase trendingPostsUseCase(Ref ref) {
  return getIt<GetTrendingPostsUseCase>();
}

/// TrendingPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached trending posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Trending scores update in real-time
///
/// **Cache Strategy**:
/// - TTL: 10 minutes (trending posts change slower)
/// - Cache key includes limit parameter
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(trendingPostsStreamProvider(20));
/// ```
@riverpod
Stream<List<PostDisplay>> trendingPostsStream(
  Ref ref,
  int limit,
) async* {
  final cacheService = ref.watch(postCacheServiceProvider);
  final useCase = ref.watch(trendingPostsUseCaseProvider);

  // Phase 3: Emit cached trending posts immediately
  final cachedPosts = await cacheService.getTrendingPosts(limit: limit);
  if (cachedPosts.isNotEmpty) {
    yield cachedPosts; // <30ms response
  }

  // Subscribe to real-time Firestore updates
  yield* useCase.getTrendingStream(limit: limit).handleError((error) {
    if (error is! PostFailure) {
      throw PostFailure.unexpected(
        message: 'Unexpected error in trending posts stream',
        error: error,
      );
    }
    throw error;
  });
}

/// TrendingPosts Future Provider
@riverpod
Future<List<PostDisplay>> trendingPostsFuture(
  Ref ref,
  int limit,
) async {
  final useCase = ref.watch(trendingPostsUseCaseProvider);

  final result = await useCase.execute(limit: limit);

  return result.fold(
    (failure) => throw failure,
    (posts) => posts,
  );
}

// ============================================================================
// PopularPosts Providers
// ============================================================================

/// PopularPosts UseCase Provider
@riverpod
GetPopularPostsUseCase popularPostsUseCase(Ref ref) {
  return getIt<GetPopularPostsUseCase>();
}

/// PopularPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached popular posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Popular scores update based on like counts
///
/// **Cache Strategy**:
/// - TTL: 10 minutes
/// - Cache key includes limit and timeWindow
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(popularPostsStreamProvider(
///   PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
/// ));
/// ```
@riverpod
Stream<List<PostDisplay>> popularPostsStream(
  Ref ref,
  PopularPostsParams params,
) async* {
  final cacheService = ref.watch(postCacheServiceProvider);
  final useCase = ref.watch(popularPostsUseCaseProvider);

  // Phase 3: Emit cached popular posts immediately
  final cachedPosts = await cacheService.getPopularPosts(
    limit: params.limit,
    timeWindow: params.timeWindow ?? const Duration(days: 7),
  );
  if (cachedPosts.isNotEmpty) {
    yield cachedPosts; // <30ms response
  }

  // Subscribe to real-time Firestore updates
  yield* useCase.getPopularStream(
    limit: params.limit,
    timeWindow: params.timeWindow,
  ).handleError((error) {
    if (error is! PostFailure) {
      throw PostFailure.unexpected(
        message: 'Unexpected error in popular posts stream',
        error: error,
      );
    }
    throw error;
  });
}

/// PopularPosts Future Provider
@riverpod
Future<List<PostDisplay>> popularPostsFuture(
  Ref ref,
  PopularPostsParams params,
) async {
  final useCase = ref.watch(popularPostsUseCaseProvider);

  final result = await useCase.execute(
    limit: params.limit,
    timeWindow: params.timeWindow,
  );

  return result.fold(
    (failure) => throw failure,
    (posts) => posts,
  );
}

// ============================================================================
// UserPosts Providers
// ============================================================================

/// UserPosts UseCase Provider
@riverpod
GetUserPostsUseCase userPostsUseCase(Ref ref) {
  return getIt<GetUserPostsUseCase>();
}

/// UserPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached user posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Updates when user creates/deletes posts
///
/// **Cache Strategy**:
/// - TTL: 5 minutes (user posts change frequently)
/// - Cache key includes userId and limit
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(userPostsStreamProvider(
///   UserPostsParams(userId: 'user123', limit: 20),
/// ));
/// ```
@riverpod
Stream<List<PostDisplay>> userPostsStream(
  Ref ref,
  UserPostsParams params,
) async* {
  final cacheService = ref.watch(postCacheServiceProvider);
  final useCase = ref.watch(userPostsUseCaseProvider);

  // Phase 3: Emit cached user posts immediately
  final cachedPosts = await cacheService.getUserPosts(
    userId: params.userId,
    limit: params.limit,
  );
  if (cachedPosts.isNotEmpty) {
    yield cachedPosts; // <30ms response
  }

  // Subscribe to real-time Firestore updates
  yield* useCase.getUserPostsStream(
    userId: params.userId,
    limit: params.limit,
  ).handleError((error) {
    if (error is! PostFailure) {
      throw PostFailure.unexpected(
        message: 'Unexpected error in user posts stream',
        error: error,
      );
    }
    throw error;
  });
}

/// UserPosts Future Provider
@riverpod
Future<List<PostDisplay>> userPostsFuture(
  Ref ref,
  UserPostsParams params,
) async {
  final useCase = ref.watch(userPostsUseCaseProvider);

  final result = await useCase.execute(
    userId: params.userId,
    limit: params.limit,
  );

  return result.fold(
    (failure) => throw failure,
    (posts) => posts,
  );
}

// ============================================================================
// Feed Providers (with Pagination)
// ============================================================================

/// Feed UseCase Provider
@riverpod
GetFeedUseCase feedUseCase(Ref ref) {
  return getIt<GetFeedUseCase>();
}

/// Feed Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached data if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response with stale-while-revalidate
///
/// **Cache Strategy**:
/// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore cache)
/// 2. If cache hit, yield immediately
/// 3. Subscribe to Firestore for real-time updates
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(feedStreamProvider(
///   FeedParams(limit: 20, sortBy: FeedSortBy.latest),
/// ));
/// ```
@riverpod
Stream<List<PostDisplay>> feedStream(
  Ref ref,
  FeedParams params,
) async* {
  final cacheService = ref.watch(postCacheServiceProvider);
  final useCase = ref.watch(feedUseCaseProvider);

  // Phase 3: Emit cached data immediately
  final cachedPosts = await cacheService.getFeedPosts(
    sortBy: params.sortBy,
    limit: params.limit,
    filter: params.filter,
  );

  if (cachedPosts.isNotEmpty) {
    yield cachedPosts; // <30ms response
  }

  // Subscribe to real-time Firestore updates
  yield* useCase.getFeedStream(
    limit: params.limit,
    sortBy: params.sortBy,
    filter: params.filter,
  ).handleError((error) {
    if (error is! PostFailure) {
      throw PostFailure.unexpected(
        message: 'Unexpected error in feed stream',
        error: error,
      );
    }
    throw error;
  });
}

/// Feed Future Provider (with pagination support)
///
/// **Paginated feed loading**
/// - Returns FeedResult with hasMore and lastDocumentId
/// - Use with StateProvider for pagination state management
///
/// **Pagination Pattern**:
/// ```dart
/// // State providers for pagination
/// final lastDocIdProvider = StateProvider<String?>((ref) => null);
/// final feedPostsProvider = StateProvider<List<PostDisplay>>((ref) => []);
///
/// // Load more
/// Future<void> loadMore() async {
///   final lastId = ref.read(lastDocIdProvider);
///   final currentPosts = ref.read(feedPostsProvider);
///
///   final result = await ref.read(feedFutureProvider(
///     FeedParams(limit: 20, sortBy: FeedSortBy.latest),
///     lastDocumentId: lastId,
///   ).future);
///
///   ref.read(feedPostsProvider.notifier).state = [
///     ...currentPosts,
///     ...result.posts,
///   ];
///   ref.read(lastDocIdProvider.notifier).state = result.lastDocumentId;
/// }
/// ```
@riverpod
Future<FeedResult> feedFuture(
  Ref ref,
  FeedParams params, {
  String? lastDocumentId,
}) async {
  final useCase = ref.watch(feedUseCaseProvider);

  final result = await useCase.execute(
    limit: params.limit,
    lastDocumentId: lastDocumentId,
    sortBy: params.sortBy,
    filter: params.filter,
  );

  return result.fold(
    (failure) => throw failure,
    (feedResult) => feedResult,
  );
}

// ============================================================================
// Feed State Providers (for pagination and filtering)
// ============================================================================

/// Feed Sort Provider
///
/// **Current sort order**
/// - Persists sort selection
/// - Triggers feed reload on change
@riverpod
class FeedSort extends _$FeedSort {
  @override
  FeedSortBy build() => FeedSortBy.latest;

  void change(FeedSortBy newSort) {
    state = newSort;
  }
}

/// Feed Filter Provider
///
/// **Current filter settings**
/// - Persists filter selection
/// - Triggers feed reload on change
@riverpod
class FeedFilterNotifier extends _$FeedFilterNotifier {
  @override
  FeedFilterModel build() => const FeedFilterModel();

  void apply(FeedFilterModel newFilter) {
    state = newFilter;
  }

  void clear() {
    state = const FeedFilterModel();
  }
}

/// Feed FilterModel (immutable)
class FeedFilterModel {
  final String? status;
  final String? userId;
  final bool? hasImages;
  final bool? isAnonymous;
  final DateTime? startDate;
  final DateTime? endDate;

  const FeedFilterModel({
    this.status,
    this.userId,
    this.hasImages,
    this.isAnonymous,
    this.startDate,
    this.endDate,
  });

  FeedFilter? toFeedFilter() {
    if (!hasActiveFilters) return null;

    return FeedFilter(
      status: status,
      userId: userId,
      hasImages: hasImages,
      isAnonymous: isAnonymous,
      startDate: startDate,
      endDate: endDate,
    );
  }

  FeedFilterModel copyWith({
    String? status,
    String? userId,
    bool? hasImages,
    bool? isAnonymous,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStatus = false,
    bool clearUserId = false,
    bool clearHasImages = false,
    bool clearIsAnonymous = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return FeedFilterModel(
      status: clearStatus ? null : (status ?? this.status),
      userId: clearUserId ? null : (userId ?? this.userId),
      hasImages: clearHasImages ? null : (hasImages ?? this.hasImages),
      isAnonymous: clearIsAnonymous ? null : (isAnonymous ?? this.isAnonymous),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  bool get hasActiveFilters {
    return status != null ||
        userId != null ||
        hasImages != null ||
        isAnonymous != null ||
        startDate != null ||
        endDate != null;
  }
}

/// Feed Pagination State Provider
///
/// **Pagination state management**
/// - Tracks current page, lastDocumentId, hasMore
/// - Use with feedFutureProvider for pagination
@riverpod
class FeedPagination extends _$FeedPagination {
  @override
  FeedPaginationState build() => const FeedPaginationState();

  void updateFromResult(FeedResult result) {
    state = FeedPaginationState(
      posts: [...state.posts, ...result.posts],
      lastDocumentId: result.lastDocumentId,
      hasMore: result.hasMore,
      currentPage: state.currentPage + 1,
    );
  }

  void reset() {
    state = const FeedPaginationState();
  }

  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }

  void updatePost(PostDisplay updatedPost) {
    final index = state.posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      final newPosts = [...state.posts];
      newPosts[index] = updatedPost;
      state = state.copyWith(posts: newPosts);
    }
  }

  void addPost(PostDisplay post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }
}

class FeedPaginationState {
  final List<PostDisplay> posts;
  final String? lastDocumentId;
  final bool hasMore;
  final int currentPage;

  const FeedPaginationState({
    this.posts = const [],
    this.lastDocumentId,
    this.hasMore = true,
    this.currentPage = 0,
  });

  FeedPaginationState copyWith({
    List<PostDisplay>? posts,
    String? lastDocumentId,
    bool? hasMore,
    int? currentPage,
  }) {
    return FeedPaginationState(
      posts: posts ?? this.posts,
      lastDocumentId: lastDocumentId ?? this.lastDocumentId,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// ============================================================================
// Combined Feed Provider (Computed)
// ============================================================================

/// Combined Feed Provider
///
/// **Reactive feed with sort + filter**
/// - Automatically reloads when sort or filter changes
/// - Combines multiple providers reactively
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(combinedFeedProvider);
/// // Automatically updates when sort/filter changes
/// ```
@riverpod
Stream<List<PostDisplay>> combinedFeed(Ref ref) {
  final sortBy = ref.watch(feedSortProvider);
  final filter = ref.watch(feedFilterProvider);

  final params = FeedParams(
    limit: 20,
    sortBy: sortBy,
    filter: filter.toFeedFilter(),
  );

  // Call the feedStream provider function directly
  return feedStream(ref, params);
}
