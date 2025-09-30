/// DataSource interface for Post Display operations
/// This interface defines the contract for data access without exposing Firebase details
abstract class IPostDisplayDataSource {
  /// Queries posts based on custom query builder
  /// Returns raw Map data to avoid Firebase dependency in Domain layer
  Stream<List<Map<String, dynamic>>> queryPosts({
    required Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder,
    int? limit,
  });

  /// Gets a single post by ID
  /// Returns raw Map data without Firebase types
  Future<Map<String, dynamic>?> getPost(String postId);

  /// Gets multiple posts by IDs
  /// Returns raw Map data for batch operations
  Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds);

  /// Updates post metrics (views, likes, etc.)
  /// Uses Map to avoid Firebase dependency
  Future<void> updatePostMetrics(String postId, Map<String, dynamic> metrics);

  /// Deletes a post
  /// Pure operation without Firebase types
  Future<void> deletePost(String postId);
}