import 'dart:io';
import '/app/contracts/models/post_bundle.dart';
import '../models/post_core.dart';
import '../models/post_content.dart';
import '../models/target_audience.dart';
import '../services/i_target_audience_service.dart' as service;
import '../services/i_image_processing_service.dart';
import '/features/voting/domain/models/chat/post_voting.dart';
import '/features/post/domain/models/post_metrics.dart';

/// Repository interface for Post creation operations (V2 - Clean Architecture)
///
/// This V2 interface uses PostBundle and domain models instead of PostsModel,
/// removing ALL Firebase dependencies from the domain layer.
abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// Create a new post using PostBundle
  /// Returns the created post ID
  Future<String> createPost(PostBundle bundle);

  /// Create a new post using individual domain models
  /// Returns the created post ID
  Future<String> createPostFromModels({
    required PostCore core,
    required PostContent content,
    required PostVoting voting,
    required PostMetrics metrics,
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

  /// Update post voting state
  Future<void> updatePostVoting({
    required String postId,
    required PostVoting voting,
  });

  /// Update post metrics
  Future<void> updatePostMetrics({
    required String postId,
    required PostMetrics metrics,
  });

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

  /// Get post as PostBundle
  Future<PostBundle?> getPostBundle(String postId);

  /// Get individual post models
  Future<PostCore?> getPostCore(String postId);
  Future<PostContent?> getPostContent(String postId);
  Future<PostVoting?> getPostVoting(String postId);
  Future<PostMetrics?> getPostMetrics(String postId);

  /// Stream post changes as PostBundle
  Stream<PostBundle> watchPostBundle(String postId);

  /// Stream individual model changes
  Stream<PostCore> watchPostCore(String postId);
  Stream<PostContent> watchPostContent(String postId);
  Stream<PostVoting> watchPostVoting(String postId);
  Stream<PostMetrics> watchPostMetrics(String postId);

  // ====== User's Posts ======

  /// Get user's created posts as PostBundles
  Stream<List<PostBundle>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// Get count of user's created posts
  Future<int> getUserCreatedPostsCount(String userId);

  // ====== Validation ======

  /// Validate post data before creation
  Future<bool> validatePostData(PostBundle bundle);

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