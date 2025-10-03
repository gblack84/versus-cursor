/// DataSource interface for Post Creation operations
/// This interface defines the contract for creating and managing posts without Firebase dependency
abstract class IPostCreationDataSource {
  /// Creates a new post with the provided data
  /// Returns the created post data including the generated ID
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData);

  /// Updates an existing post
  /// Uses Map to avoid Firebase dependency in Domain layer
  Future<void> updatePost(String postId, Map<String, dynamic> postData);

  /// Uploads post metadata (used for complex post creation flows)
  /// Returns the metadata document ID
  Future<String> uploadPostMetadata(Map<String, dynamic> metadata);

  /// Gets post creation status (for tracking async operations)
  /// Returns status data without Firebase types
  Future<Map<String, dynamic>?> getPostCreationStatus(String statusId);

  /// Validates post content against moderation rules
  /// Returns validation result as Map
  Future<Map<String, dynamic>> validatePostContent(Map<String, dynamic> content);

  /// Batch creates multiple posts (for bulk operations)
  /// Returns list of created posts with their IDs
  Future<List<Map<String, dynamic>>> batchCreatePosts(List<Map<String, dynamic>> postsData);

  /// Deletes a draft post
  /// Pure operation without Firebase types
  Future<void> deleteDraft(String draftId);

  /// Gets user's draft posts
  /// Returns raw Map data for draft posts
  Future<List<Map<String, dynamic>>> getUserDrafts(String userId);
}