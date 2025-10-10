import '../models/post_display.dart';

/// Repository interface for Post display operations (V2 - Clean Architecture)
///
/// This V2 interface uses PostDisplay model instead of PostsModel,
/// removing ALL Firebase dependencies from the domain layer.
abstract class IPostDisplayRepositoryV2 {
  // Query posts for feed
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  // Get single post
  Future<PostDisplay?> getPost(String postId);

  // Stream single post
  Stream<PostDisplay?> streamPost(String postId);

  // Get trending posts
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});

  // Get posts by user
  Stream<List<PostDisplay>> getUserPosts({
    required String userId,
    int limit = -1,
  });

  // Get posts by category
  Stream<List<PostDisplay>> getPostsByCategory({
    required String category,
    int limit = -1,
  });

  // Get posts with active voting
  Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1});

  // Search posts
  Future<List<PostDisplay>> searchPosts({
    required String query,
    int limit = 20,
  });

  // Update post metrics (for view count, etc.)
  Future<void> incrementViewCount(String postId);

  // Get recommended posts for user
  Future<List<PostDisplay>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  });

  // Get posts by multiple IDs (batch operation)
  Future<List<PostDisplay>> getPostsByIds(List<String> postIds);

  // Get completed voting posts
  Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1});

  // Get popular posts (sorted by likes/engagement)
  Stream<List<PostDisplay>> getPopularPosts({
    int limit = 20,
    Duration? timeWindow,
  });

  // Pagination support - get posts after a document
  Stream<List<PostDisplay>> getPostsAfter({
    required String lastPostId,
    int limit = 20,
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
  });

  // Get posts with complex filters
  Stream<List<PostDisplay>> getPostsWithFilters({
    String? userId,
    String? status,
    bool? isAnonymous,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int limit = 20,
  });
}