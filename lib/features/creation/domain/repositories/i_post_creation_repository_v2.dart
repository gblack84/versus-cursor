import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failure.dart';
import '../entities/post_creation.dart';
import '../entities/target_audience.dart';
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
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, String>` (postId on success)
  ///
  /// **Errors**:
  /// - `PostCreationRepositoryFailure`: Firestore write failure
  /// - `NetworkFailure`: No internet connection
  /// - `ServerFailure`: Firestore service unavailable
  /// - `IdempotencyViolation`: Duplicate operation with different eventId
  ///
  /// **Idempotency**: Same eventId will skip operation and return success (network retry safe)
  ///
  /// Voting Feature and Post Feature will add their fields later through onCreate triggers.
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  // ====== Update Operations ======

  /// Update post using PostCreation aggregate
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>` (Unit on success = functional void)
  ///
  /// **Errors**:
  /// - `PostCreationRepositoryFailure`: Update failed
  /// - `NetworkFailure`: Connection lost during update
  /// - `IdempotencyViolation`: Duplicate operation with different eventId
  ///
  /// **Idempotency**: Same eventId will skip operation and return success
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Update post using partial data (for granular updates)
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  });

  // Note: updatePostVoting and updatePostMetrics removed
  // These are now handled by Voting Feature and Post Feature respectively

  // ====== Delete Operations ======

  /// Delete post
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  ///
  /// **Idempotency**: Same eventId will skip operation and return success
  Future<Either<CreationFailure, Unit>> deletePost({
    required String postId,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  // ====== Media Operations ======

  /// Upload post media (image/video)
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  ///
  /// **Idempotency**: Same eventId will skip operation and return success
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side, // 'A' or 'B'
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Delete post media
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side, // 'A' or 'B'
  });

  // ====== Status Operations ======

  /// Update post status (draft, published, archived)
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  ///
  /// **Idempotency**: Same eventId will skip operation and return success
  Future<Either<CreationFailure, Unit>> updatePostStatus({
    required String postId,
    required String status,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Mark post as processed by backend
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  ///
  /// **Idempotency**: Same eventId will skip operation and return success
  Future<Either<CreationFailure, Unit>> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  // ====== Query Operations ======

  /// Get post as PostCreation aggregate (Creation Feature responsibility only)
  ///
  /// **Returns**: `Either<CreationFailure, Option<PostCreation>>`
  /// - `Some(post)` if found
  /// - `None()` if not found
  Future<Either<CreationFailure, Option<PostCreation>>> getPost(String postId);

  /// Stream post changes as PostCreation aggregate (Creation Feature responsibility only)
  ///
  /// **Returns**: Stream of `Either<CreationFailure, PostCreation>`
  /// - Emits Left on error
  /// - Emits Right on data
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId);

  // Note: PostBundle, PostVoting, PostMetrics queries removed
  // These span multiple features and should be handled at app/contracts level

  // ====== User's Posts ======

  /// Get user's created posts as PostCreation aggregates
  ///
  /// **Returns**: Stream of `Either<CreationFailure, List<PostCreation>>`
  Stream<Either<CreationFailure, List<PostCreation>>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// Get count of user's created posts
  ///
  /// **Returns**: `Either<CreationFailure, int>`
  Future<Either<CreationFailure, int>> getUserCreatedPostsCount(String userId);

  // ====== Validation ======

  /// Validate post data before creation using PostCreation aggregate
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  /// - `Right(unit)` if valid
  /// - `Left(failure)` with validation errors
  Future<Either<CreationFailure, Unit>> validatePostData({
    required PostCreation post,
  });

  /// Check if user can create post (rate limiting, etc.)
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  /// - `Right(unit)` if allowed
  /// - `Left(failure)` if rate limited or restricted
  Future<Either<CreationFailure, Unit>> canUserCreatePost(String userId);

  // ====== Service Operations (Phase 1.3) ======
  // These methods delegate to internal services but expose them through repository
  // This allows UseCase to avoid direct service dependency

  /// Validate target audience configuration
  service.ValidationResult validateTargetAudience(
    TargetAudience targetAudience,
  );

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
  Map<String, dynamic> convertTargetAudienceToStorageFormat(
    TargetAudience targetAudience,
  );

  // ====== Additional Command Operations (from ICreationCommandRepository) ======

  /// Create content using PostCreation aggregate
  /// Convenience wrapper for createPost() with consistent naming
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, String>` (contentId)
  Future<Either<CreationFailure, String>> createContent(
    PostCreation post, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Update existing content using PostCreation aggregate
  /// Convenience wrapper for updatePost() with consistent naming
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> updateContent(
    String contentId,
    PostCreation post, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Delete content
  /// Removes the post and all associated data
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> deleteContent(
    String contentId, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Publish content (change visibility to public)
  /// This is a convenience method that updates post status and visibility
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> publishContent(
    String contentId, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  /// Save as draft
  /// This saves the post with draft status for later editing
  ///
  /// **Phase 4 Idempotency**: Requires eventId for duplicate prevention
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> saveDraft(
    String contentId,
    PostCreation post, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  });

  // ====== Phase 3: Draft Cache Operations ======

  /// Get user's Draft Post (Cache-First pattern)
  ///
  /// **Flow**: L1 (Memory) → L2 (Hive) → L3 (Firestore)
  /// **Returns**: Draft Post if exists, null otherwise
  /// **Performance**: <10ms (Cache Hit), 50-100ms (Firestore)
  ///
  /// **Example**:
  /// ```dart
  /// final draft = await repository.getDraftPost('user123');
  /// if (draft != null) {
  ///   // Restore form data
  /// }
  /// ```
  Future<PostCreation?> getDraftPost(String userId);

  /// Save Draft Post (Write-Through pattern)
  ///
  /// **Option 1**: IdempotencyService 제거 (고정 ID로 자연스러운 멱등성)
  ///
  /// **Flow**: Cache (L1, L2) immediately → Firestore async
  /// **Performance**: <10ms (non-blocking)
  ///
  /// **Idempotency**: 고정 ID('draft_$userId') + set() = 자연스러운 멱등성 보장
  /// - 동일 사용자의 Draft는 항상 동일한 Document ID 사용
  /// - Firestore set()은 멱등 연산 (동일 데이터로 여러 번 호출 가능)
  /// - eventId 없이도 안전한 재시도 보장
  ///
  /// **Example**:
  /// ```dart
  /// await repository.saveDraftPost('user123', draft);
  /// // Saved to cache instantly, Firestore updates in background
  /// ```
  Future<void> saveDraftPost(
    String userId,
    PostCreation draft,
  );

  /// Delete Draft Post (Cache invalidation + Firestore delete)
  ///
  /// **Called**: After successful post creation
  ///
  /// **Example**:
  /// ```dart
  /// await repository.deleteDraftPost('user123');
  /// ```
  Future<void> deleteDraftPost(String userId);

  /// Get TargetAudience preset (Cache-First pattern)
  ///
  /// **Returns**: Last used TargetAudience settings
  /// **TTL**: Memory 10분, Hive 30일
  ///
  /// **Example**:
  /// ```dart
  /// final preset = await repository.getTargetAudiencePreset('user123');
  /// if (preset != null) {
  ///   // Auto-fill target audience settings
  /// }
  /// ```
  Future<TargetAudience?> getTargetAudiencePreset(String userId);
}
