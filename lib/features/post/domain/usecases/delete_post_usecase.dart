import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// UseCase for deleting a post
///
/// **Phase 4: Idempotency Integration**
/// - Generates UUID eventId for duplicate prevention
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
  final Uuid _uuid;

  DeletePostUseCase({
    required IPostDisplayRepositoryV2 postRepository,
    Uuid? uuid,
  })  : _postRepository = postRepository,
        _uuid = uuid ?? const Uuid();

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
  /// **Idempotency**:
  /// - Generates unique eventId for each call
  /// - Same eventId on retry prevents duplicate deletion attempts
  /// - Network retry with same eventId returns success without re-deleting
  ///
  /// **Data Cleanup**:
  /// - Complete deletion of all nested subcollections
  /// - No orphaned data left in Firestore
  /// - Atomic transaction ensures all-or-nothing deletion
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
  }) async {
    // Validate input
    if (postId.trim().isEmpty) {
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    // Generate eventId for idempotency
    final eventId = _uuid.v4();

    // Call repository with eventId
    return await _postRepository.deletePost(
      postId: postId,
      eventId: eventId,
    );
  }
}
