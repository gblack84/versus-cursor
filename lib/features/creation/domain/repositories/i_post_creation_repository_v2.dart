import 'dart:io';
import '../models/aggregates/post_creation.dart';
import '../models/value_objects/target_audience.dart';
import '../services/i_target_audience_service.dart' as service;
import '../services/i_image_processing_service.dart';

/// Repository interface for Post creation operations (V2 - Clean Architecture)
///
/// **Phase 2 Migration**: PostCore/PostContent 제거, PostCreation 직접 사용
/// This V2 interface uses PostCreation aggregate from Creation Feature only.
/// Voting and Metrics will be added by their respective features after post creation.
abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// Create a new post using PostCreation aggregate
  /// Returns the created post ID
  ///
  /// Voting Feature and Post Feature will add their fields later through onCreate triggers.
  Future<String> createPost({
    required PostCreation post,
  });

  // ====== Update Operations ======

  /// Update post using PostCreation aggregate
  Future<void> updatePost({
    required String postId,
    required PostCreation post,
  });

  /// Update post using partial data (for granular updates)
  Future<void> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  });

  // Note: updatePostVoting and updatePostMetrics removed
  // These are now handled by Voting Feature and Post Feature respectively

  // ====== Delete Operations ======

  Future<void> deletePost(String postId);

  // ====== Media Operations ======

  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side, // 'A' or 'B'
  });

  Future<void> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side, // 'A' or 'B'
  });

  // ====== Status Operations ======

  Future<void> updatePostStatus({
    required String postId,
    required String status,
  });

  Future<void> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  });

  // ====== Query Operations ======

  /// Get post as PostCreation aggregate (Creation Feature responsibility only)
  Future<PostCreation?> getPost(String postId);

  /// Stream post changes as PostCreation aggregate (Creation Feature responsibility only)
  Stream<PostCreation> watchPost(String postId);

  // Note: PostBundle, PostVoting, PostMetrics queries removed
  // These span multiple features and should be handled at app/contracts level

  // ====== User's Posts ======

  /// Get user's created posts as PostCreation aggregates
  Stream<List<PostCreation>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// Get count of user's created posts
  Future<int> getUserCreatedPostsCount(String userId);

  // ====== Validation ======

  /// Validate post data before creation using PostCreation aggregate
  Future<bool> validatePostData({
    required PostCreation post,
  });

  /// Check if user can create post (rate limiting, etc.)
  Future<bool> canUserCreatePost(String userId);

  // ====== Service Operations (Phase 1.3) ======
  // These methods delegate to internal services but expose them through repository
  // This allows UseCase to avoid direct service dependency

  /// Validate target audience configuration
  service.ValidationResult validateTargetAudience(TargetAudience targetAudience);

  /// Process images with moderation
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  });

  /// Process single edited image
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  });

  /// Convert target audience to storage format
  Map<String, dynamic> convertTargetAudienceToStorageFormat(TargetAudience targetAudience);

  // ====== Additional Command Operations (from ICreationCommandRepository) ======

  /// Create content using PostCreation aggregate
  /// Convenience wrapper for createPost() with consistent naming
  Future<String> createContent(PostCreation post);

  /// Update existing content using PostCreation aggregate
  /// Convenience wrapper for updatePost() with consistent naming
  Future<void> updateContent(String contentId, PostCreation post);

  /// Delete content
  /// Removes the post and all associated data
  Future<void> deleteContent(String contentId);

  /// Publish content (change visibility to public)
  /// This is a convenience method that updates post status and visibility
  Future<void> publishContent(String contentId);

  /// Save as draft
  /// This saves the post with draft status for later editing
  Future<void> saveDraft(String contentId, PostCreation post);
}