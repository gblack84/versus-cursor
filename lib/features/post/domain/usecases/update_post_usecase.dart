import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// UseCase for updating an existing post
///
/// **Phase 4: Idempotency Integration**
/// - Generates UUID eventId for duplicate prevention
/// - Validates update data before modification
/// - Returns Either<PostFailure, Unit> for type-safe error handling
class UpdatePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid;

  UpdatePostUseCase({
    required IPostDisplayRepositoryV2 postRepository,
    Uuid? uuid,
  })  : _postRepository = postRepository,
        _uuid = uuid ?? const Uuid();

  /// Execute the use case to update a post
  ///
  /// **Parameters**:
  /// - [postId] - ID of post to update
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
  /// **Idempotency**:
  /// - Generates unique eventId for each call
  /// - Same eventId on retry prevents duplicate updates
  /// - Network retry with same eventId returns success without re-updating
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
    required Map<String, dynamic> updates,
  }) async {
    // Validate input
    if (postId.trim().isEmpty) {
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    if (updates.isEmpty) {
      return left(const PostFailure.invalidInput(field: 'updates'));
    }

    // Generate eventId for idempotency
    final eventId = _uuid.v4();

    // Call repository with eventId
    return await _postRepository.updatePost(
      postId: postId,
      updates: updates,
      eventId: eventId,
    );
  }
}
