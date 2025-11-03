import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';
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
  ///
  /// **Returns**: `Either<CreationFailure, String>` (postId on success)
  ///
  /// **Errors**:
  /// - `PostCreationRepositoryFailure`: Firestore write failure
  /// - `NetworkFailure`: No internet connection
  /// - `ServerFailure`: Firestore service unavailable
  ///
  /// Voting Feature and Post Feature will add their fields later through onCreate triggers.
  Future<Either<CreateContentFailure, String>> createPost({
    required PostCreation post,
  });

  // ====== Update Operations ======

  /// Update post using PostCreation aggregate
  ///
  /// **Returns**: `Either<CreationFailure, Unit>` (Unit on success = functional void)
  ///
  /// **Errors**:
  /// - `PostCreationRepositoryFailure`: Update failed
  /// - `NetworkFailure`: Connection lost during update
  Future<Either<CreateContentFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
  });

  /// Update post using partial data (for granular updates)
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  });

  // Note: updatePostVoting and updatePostMetrics removed
  // These are now handled by Voting Feature and Post Feature respectively

  // ====== Delete Operations ======

  /// Delete post
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> deletePost(String postId);

  // ====== Media Operations ======

  /// Upload post media (image/video)
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side, // 'A' or 'B'
  });

  /// Delete post media
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side, // 'A' or 'B'
  });

  // ====== Status Operations ======

  /// Update post status (draft, published, archived)
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> updatePostStatus({
    required String postId,
    required String status,
  });

  /// Mark post as processed by backend
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  });

  // ====== Query Operations ======

  /// Get post as PostCreation aggregate (Creation Feature responsibility only)
  ///
  /// **Returns**: `Either<CreationFailure, Option<PostCreation>>`
  /// - `Some(post)` if found
  /// - `None()` if not found
  Future<Either<CreateContentFailure, Option<PostCreation>>> getPost(String postId);

  /// Stream post changes as PostCreation aggregate (Creation Feature responsibility only)
  ///
  /// **Returns**: Stream of `Either<CreationFailure, PostCreation>`
  /// - Emits Left on error
  /// - Emits Right on data
  Stream<Either<CreateContentFailure, PostCreation>> watchPost(String postId);

  // Note: PostBundle, PostVoting, PostMetrics queries removed
  // These span multiple features and should be handled at app/contracts level

  // ====== User's Posts ======

  /// Get user's created posts as PostCreation aggregates
  ///
  /// **Returns**: Stream of `Either<CreationFailure, List<PostCreation>>`
  Stream<Either<CreateContentFailure, List<PostCreation>>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// Get count of user's created posts
  ///
  /// **Returns**: `Either<CreationFailure, int>`
  Future<Either<CreateContentFailure, int>> getUserCreatedPostsCount(String userId);

  // ====== Validation ======

  /// Validate post data before creation using PostCreation aggregate
  ///
  /// **Returns**: `Either<CreationValidationFailure, Unit>`
  /// - `Right(unit)` if valid
  /// - `Left(failure)` with validation errors
  Future<Either<CreationValidationFailure, Unit>> validatePostData({
    required PostCreation post,
  });

  /// Check if user can create post (rate limiting, etc.)
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  /// - `Right(unit)` if allowed
  /// - `Left(failure)` if rate limited or restricted
  Future<Either<CreateContentFailure, Unit>> canUserCreatePost(String userId);

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
  ///
  /// **Returns**: `Either<CreationFailure, String>` (contentId)
  Future<Either<CreateContentFailure, String>> createContent(PostCreation post);

  /// Update existing content using PostCreation aggregate
  /// Convenience wrapper for updatePost() with consistent naming
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> updateContent(String contentId, PostCreation post);

  /// Delete content
  /// Removes the post and all associated data
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> deleteContent(String contentId);

  /// Publish content (change visibility to public)
  /// This is a convenience method that updates post status and visibility
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> publishContent(String contentId);

  /// Save as draft
  /// This saves the post with draft status for later editing
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreateContentFailure, Unit>> saveDraft(String contentId, PostCreation post);
}