import '/features/creation/domain/models/aggregates/post_creation.dart';
import '/features/creation/domain/models/value_objects/target_audience.dart';
import '/features/creation/domain/services/i_target_audience_service.dart';

/// App-level contract for Creation Feature
///
/// This contract provides cross-feature access to post creation operations.
/// Used by:
/// - Notification Feature: Post creation triggers, target audience validation
/// - Chat Feature: Vote card display with real-time updates
/// - Profile Feature: User statistics and post history
/// - Post Feature: Post data validation and display
/// - Moderation Feature: Content moderation and status updates
///
/// **Architecture Pattern**: Dual Interface Pattern
/// - IPostCreationRepositoryV2: Internal domain interface (Port)
/// - CreationContract: External app-level interface (Contract)
///
/// **Implementation**: PostCreationRepositoryV2Impl
abstract class CreationContract {
  // ====== Read Operations (6 methods) ======

  /// Get post by ID
  ///
  /// Used by:
  /// - Post Feature: Display post content
  /// - Chat Feature: Show vote card data
  /// - Notification Feature: Get post info for notifications
  ///
  /// Returns null if post not found.
  Future<PostCreation?> getPost(String postId);

  /// Watch post changes in real-time
  ///
  /// Used by:
  /// - Chat Feature: Real-time vote card updates
  /// - Post Feature: Live post updates
  ///
  /// Returns a stream that emits post updates.
  Stream<PostCreation> watchPost(String postId);

  /// Get user's created posts
  ///
  /// Used by:
  /// - Profile Feature: Display user's post history
  /// - Notification Feature: Track user activity
  ///
  /// Returns a stream of posts created by the user.
  /// Set [limit] to -1 for unlimited results.
  Stream<List<PostCreation>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// Get count of user's created posts
  ///
  /// Used by:
  /// - Profile Feature: Display statistics
  ///
  /// Returns total number of posts created by user.
  Future<int> getUserCreatedPostsCount(String userId);

  /// Validate post data before creation/display
  ///
  /// Used by:
  /// - Post Feature: Validate before displaying
  /// - Creation Feature: Validate before creation
  ///
  /// Returns true if post data is valid.
  Future<bool> validatePostData({required PostCreation post});

  /// Check if user can create post (rate limiting)
  ///
  /// Used by:
  /// - Notification Feature: Spam prevention
  /// - Creation Feature: Rate limit enforcement
  ///
  /// Returns true if user can create more posts.
  Future<bool> canUserCreatePost(String userId);

  // ====== Write Operations (3 methods) ======

  /// Create new post
  ///
  /// Used by:
  /// - Notification Feature: AI-generated recommendations
  /// - Creation Feature: Normal post creation
  ///
  /// Returns the created post ID.
  Future<String> createPost({required PostCreation post});

  /// Update post status
  ///
  /// Used by:
  /// - Notification Feature: Mark as notified
  /// - Moderation Feature: Mark as reviewed
  ///
  /// Status values: 'draft', 'published', 'archived', 'moderated'
  Future<void> updatePostStatus({
    required String postId,
    required String status,
  });

  /// Delete post
  ///
  /// Used by:
  /// - Moderation Feature: Remove inappropriate content
  /// - Admin Feature: Content management
  ///
  /// Permanently deletes the post and all associated data.
  Future<void> deletePost(String postId);

  // ====== Target Audience & Processing (3 methods) ======

  /// Validate target audience configuration
  ///
  /// Used by:
  /// - Notification Feature: Validate before sending notifications
  /// - Creation Feature: Validate before post creation
  ///
  /// Returns validation result with error message if invalid.
  ValidationResult validateTargetAudience(TargetAudience targetAudience);

  /// Convert target audience to Firestore format
  ///
  /// Used by:
  /// - Notification Feature: Store targeting data
  /// - Creation Feature: Save to Firestore
  ///
  /// Returns Map ready for Firestore storage.
  Map<String, dynamic> convertTargetAudienceToStorageFormat(
    TargetAudience targetAudience,
  );

  /// Mark post as processed by moderation/AI
  ///
  /// Used by:
  /// - Moderation Feature: Mark content as reviewed
  /// - AI Feature: Mark as processed
  ///
  /// Sets processedAt timestamp for audit trail.
  Future<void> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  });
}
