import 'package:fpdart/fpdart.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// Repository interface for Post display operations (V2 - Clean Architecture)
///
/// This V2 interface uses PostDisplay model instead of PostsModel,
/// removing ALL Firebase dependencies from the domain layer.
///
/// **Phase 1: Either Pattern Migration**:
/// - Stream methods: Return Stream<T> (no Either wrapper)
/// - Future methods: Return Future<Either<PostFailure, T>>
abstract class IPostDisplayRepositoryV2 {
  // ========== Stream Methods (No Either wrapper) ==========

  /// Query posts for feed
  ///
  /// Real-time updates via Stream. Errors handled via Stream.error()
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Stream single post
  ///
  /// Real-time updates for a single post. Returns null if not found.
  Stream<PostDisplay?> streamPost(String postId);

  /// Get trending posts
  ///
  /// Real-time trending posts sorted by engagement metrics
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});

  /// Get posts by user
  ///
  /// Real-time posts from a specific user
  Stream<List<PostDisplay>> getUserPosts({
    required String userId,
    int limit = -1,
  });

  /// Get posts by category
  ///
  /// Real-time posts filtered by category
  Stream<List<PostDisplay>> getPostsByCategory({
    required String category,
    int limit = -1,
  });

  /// Get posts with active voting
  ///
  /// Real-time posts where voting is currently active
  Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1});

  /// Get completed voting posts
  ///
  /// Real-time posts where voting has completed
  Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1});

  /// Get popular posts (sorted by likes/engagement)
  ///
  /// Real-time popular posts with optional time window
  Stream<List<PostDisplay>> getPopularPosts({
    int limit = 20,
    Duration? timeWindow,
  });

  /// Pagination support - get posts after a document
  ///
  /// Real-time paginated posts starting after lastPostId
  Stream<List<PostDisplay>> getPostsAfter({
    required String lastPostId,
    int limit = 20,
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
  });

  /// Get posts with complex filters
  ///
  /// Real-time posts with multiple filter criteria
  Stream<List<PostDisplay>> getPostsWithFilters({
    String? userId,
    String? status,
    bool? isAnonymous,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int limit = 20,
  });

  // ========== Future Methods (Either Pattern) ==========

  /// Get single post (one-time fetch)
  ///
  /// Returns Either<PostFailure, PostDisplay> for type-safe error handling
  ///
  /// **Success**: Right(PostDisplay) - Post found and loaded
  /// **Failure**: Left(PostFailure.postNotFound) - Post doesn't exist
  /// **Failure**: Left(PostFailure.networkError) - Network issues
  Future<Either<PostFailure, PostDisplay>> getPost(String postId);

  /// Search posts
  ///
  /// **Success**: Right(List<PostDisplay>) - Search results (can be empty list)
  /// **Failure**: Left(PostFailure.searchFailed) - Search query failed
  /// **Failure**: Left(PostFailure.invalidInput) - Invalid query string
  Future<Either<PostFailure, List<PostDisplay>>> searchPosts({
    required String query,
    int limit = 20,
  });

  /// Get recommended posts for user
  ///
  /// **Success**: Right(List<PostDisplay>) - Personalized recommendations
  /// **Failure**: Left(PostFailure.userNotFound) - User doesn't exist
  /// **Failure**: Left(PostFailure.queryFailed) - Recommendation algorithm failed
  Future<Either<PostFailure, List<PostDisplay>>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  });

  /// Get posts by multiple IDs (batch operation)
  ///
  /// **Success**: Right(List<PostDisplay>) - Fetched posts (may be partial if some IDs not found)
  /// **Failure**: Left(PostFailure.queryFailed) - Batch fetch failed
  /// **Failure**: Left(PostFailure.invalidInput) - Empty or invalid ID list
  Future<Either<PostFailure, List<PostDisplay>>> getPostsByIds(
    List<String> postIds,
  );

  // ========== CRUD Methods (Phase 4: Idempotency) ==========

  /// Create a new post
  ///
  /// **Phase 4: IdempotencyService Integration**
  /// - eventId prevents duplicate post creation on network retry
  /// - Transaction ensures atomicity
  /// - Automatic cache invalidation
  ///
  /// **Parameters**:
  /// - post: Post data to create
  /// - eventId: Client-generated UUID for idempotency (prevents duplicates)
  ///
  /// **Success**: Right(unit) - Post created successfully
  /// **Failure**: Left(PostFailure.invalidInput) - Invalid post data (e.g., empty titles)
  /// **Failure**: Left(PostFailure.createFailed) - Firestore write failed
  /// **Failure**: Left(PostFailure.networkError) - Network connection issue
  Future<Either<PostFailure, Unit>> createPost({
    required PostDisplay post,
    required String eventId,
  });

  /// Update an existing post
  ///
  /// **Parameters**:
  /// - postId: ID of post to update
  /// - updates: Map of fields to update (e.g., {'titleA': 'New Title'})
  /// - eventId: Client-generated UUID for idempotency
  ///
  /// **Allowed Fields**:
  /// - titleA, titleB
  /// - descriptionA, descriptionB
  /// - status (published, draft, archived)
  ///
  /// **Success**: Right(unit) - Post updated successfully
  /// **Failure**: Left(PostFailure.postNotFound) - Post doesn't exist
  /// **Failure**: Left(PostFailure.updateFailed) - Update operation failed
  /// **Failure**: Left(PostFailure.invalidInput) - Empty updates map
  Future<Either<PostFailure, Unit>> updatePost({
    required String postId,
    required Map<String, dynamic> updates,
    required String eventId,
  });

  /// Delete a post (complete deletion with subcollections)
  ///
  /// **Transaction Processing Order**:
  /// 1. Delete comments subcollection (including comment likes/dislikes)
  /// 2. Delete votes subcollection
  /// 3. Delete likes subcollection
  /// 4. Delete dislikes subcollection
  /// 5. Delete post document
  /// 6. Invalidate cache
  ///
  /// **Parameters**:
  /// - postId: ID of post to delete
  /// - eventId: Client-generated UUID for idempotency
  ///
  /// **Success**: Right(unit) - Post and all subcollections deleted
  /// **Failure**: Left(PostFailure.postNotFound) - Post doesn't exist
  /// **Failure**: Left(PostFailure.deleteFailed) - Delete operation failed
  /// **Failure**: Left(PostFailure.permissionDenied) - User not authorized
  Future<Either<PostFailure, Unit>> deletePost({
    required String postId,
    required String eventId,
  });

  /// Increment view count (idempotent)
  ///
  /// **Phase 4 Changes**:
  /// - Added eventId parameter for idempotency
  /// - IdempotencyService prevents duplicate increments
  /// - Same eventId called multiple times = increment only once
  ///
  /// **Parameters**:
  /// - postId: ID of post to increment views
  /// - eventId: Client-generated UUID for idempotency (Phase 4 addition)
  ///
  /// **Success**: Right(unit) - View count incremented
  /// **Failure**: Left(PostFailure.postNotFound) - Post doesn't exist
  /// **Failure**: Left(PostFailure.updateFailed) - Update operation failed
  Future<Either<PostFailure, Unit>> incrementViewCount({
    required String postId,
    required String eventId,
  });
}