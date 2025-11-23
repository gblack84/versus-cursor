import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// UseCase for updating an existing post
///
/// **Phase 4: Natural Idempotency via Deterministic IDs**
/// - Uses deterministic postId for natural idempotency
/// - Validates update data before modification
/// - Returns Either<PostFailure, Unit> for type-safe error handling
class UpdatePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  UpdatePostUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to update a post
  ///
  /// **Parameters**:
  /// - [postId] - Deterministic ID of post to update
  /// - [updates] - Map of fields to update (e.g., {'titleA': 'New Title'})
  ///
  /// **Allowed Fields**:
  /// - titleA, titleB
  /// - descriptionA, descriptionB
  /// - status (published, draft, archived)
  ///
  /// **Returns**:
  /// - Right(unit) - Post updated successfully
  /// - Left(PostFailure.postNotFound) - Post doesn't exist
  /// - Left(PostFailure.updateFailed) - Update operation failed
  /// - Left(PostFailure.invalidInput) - Empty updates map or invalid postId
  ///
  /// **Natural Idempotency**:
  /// - postId provides deterministic document ID
  /// - Multiple calls with same postId and updates will overwrite (Firestore update)
  /// - No duplicate updates on network retry
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
    required Map<String, dynamic> updates,
  }) async {
    DevLogger.params({
      'postId': postId,
      'updatesCount': updates.length,
      'fields': updates.keys.join(', '),
    }, tag: 'UpdatePost');

    // Validate input
    if (postId.trim().isEmpty) {
      DevLogger.validation(
        field: 'postId',
        reason: 'Post ID cannot be empty',
        tag: 'UpdatePost',
      );
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    if (updates.isEmpty) {
      DevLogger.validation(
        field: 'updates',
        reason: 'Updates map cannot be empty',
        tag: 'UpdatePost',
      );
      return left(const PostFailure.invalidInput(field: 'updates'));
    }

    DevLogger.checkpoint(
      'Updating post with postId: $postId',
      tag: 'UpdatePost',
    );

    // Call repository (natural idempotency via deterministic postId)
    final result = await _postRepository.updatePost(
      postId: postId,
      updates: updates,
    );

    result.fold(
      (failure) {
        DevLogger.error(
          'Failed to update post (postId: $postId)',
          error: failure,
          tag: 'UpdatePost',
        );
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: 'Post updated successfully (postId: $postId)',
          tag: 'UpdatePost',
        );
      },
    );

    return result;
  }
}
