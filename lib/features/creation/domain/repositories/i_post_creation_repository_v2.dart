import 'dart:io';
import '../models/post_core.dart';
import '../models/post_content.dart';
import '../models/target_audience.dart';
import '../services/i_target_audience_service.dart' as service;
import '../services/i_image_processing_service.dart';

/// Repository interface for Post creation operations (V2 - Clean Architecture)
///
/// This V2 interface uses domain models (PostCore, PostContent) from Creation Feature only.
/// Voting and Metrics will be added by their respective features after post creation.
abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// Create a new post with PostCore and PostContent (Creation Feature responsibility)
  /// Returns the created post ID
  ///
  /// Voting Feature and Post Feature will add their fields later through onCreate triggers.
  Future<String> createPost({
    required PostCore core,
    required PostContent content,
  });

  // ====== Update Operations ======

  /// Update post using partial data
  Future<void> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  });

  /// Update post core information
  Future<void> updatePostCore({
    required String postId,
    required PostCore core,
  });

  /// Update post content (media, layout)
  Future<void> updatePostContent({
    required String postId,
    required PostContent content,
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

  /// Get individual post models (Creation Feature responsibility only)
  Future<PostCore?> getPostCore(String postId);
  Future<PostContent?> getPostContent(String postId);

  /// Stream individual model changes (Creation Feature responsibility only)
  Stream<PostCore> watchPostCore(String postId);
  Stream<PostContent> watchPostContent(String postId);

  // Note: PostBundle, PostVoting, PostMetrics queries removed
  // These span multiple features and should be handled at app/contracts level

  // ====== User's Posts ======

  /// Get user's created posts (PostCore + PostContent only)
  Stream<List<PostCore>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// Get count of user's created posts
  Future<int> getUserCreatedPostsCount(String userId);

  // ====== Validation ======

  /// Validate post data before creation (PostCore + PostContent only)
  Future<bool> validatePostData({
    required PostCore core,
    required PostContent content,
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
}