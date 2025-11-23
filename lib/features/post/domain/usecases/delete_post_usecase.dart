import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// UseCase for deleting a post
///
/// **Phase 4: Natural Idempotency via Deterministic IDs**
/// - Uses deterministic postId for natural idempotency
/// - Validates postId before deletion
/// - Returns Either<PostFailure, Unit> for type-safe error handling
///
/// **Transaction Processing Order**:
/// 1. Delete comments subcollection (including comment likes/dislikes)
/// 2. Delete votes subcollection
/// 3. Delete likes subcollection
/// 4. Delete dislikes subcollection
/// 5. Delete post document
/// 6. Invalidate cache
class DeletePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  DeletePostUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to delete a post
  ///
  /// **Parameters**:
  /// - [postId] - ID of post to delete
  ///
  /// **Returns**:
  /// - Right(unit) - Post and all subcollections deleted successfully
  /// - Left(PostFailure.postNotFound) - Post doesn't exist
  /// - Left(PostFailure.deleteFailed) - Delete operation failed
  /// - Left(PostFailure.permissionDenied) - User not authorized
  /// - Left(PostFailure.invalidInput) - Empty postId
  ///
  /// **Natural Idempotency**:
  /// - postId provides deterministic document ID
  /// - Multiple calls with same postId are safe (Firestore delete is idempotent)
  /// - Network retry with same postId returns success without error
  ///
  /// **Data Cleanup**:
  /// - Complete deletion of all nested subcollections
  /// - No orphaned data left in Firestore
  /// - Atomic transaction ensures all-or-nothing deletion
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
  }) async {
    DevLogger.params({'postId': postId}, tag: 'DeletePost');

    // Validate input
    if (postId.trim().isEmpty) {
      DevLogger.validation(
        field: 'postId',
        reason: 'Post ID cannot be empty',
        tag: 'DeletePost',
      );
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    DevLogger.checkpoint(
      'Deleting post with postId: $postId',
      tag: 'DeletePost',
    );

    // Call repository (natural idempotency via deterministic postId)
    final result = await _postRepository.deletePost(
      postId: postId,
    );

    result.fold(
      (failure) {
        DevLogger.error(
          'Failed to delete post (postId: $postId)',
          error: failure,
          tag: 'DeletePost',
        );
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: 'Post deleted successfully (postId: $postId)',
          tag: 'DeletePost',
        );
      },
    );

    return result;
  }
}
