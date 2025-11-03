import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// UseCase for incrementing post view count
///
/// **Phase 4: Idempotency Integration**
/// - Generates UUID eventId for duplicate prevention
/// - Validates postId before increment
/// - Returns Either<PostFailure, Unit> for type-safe error handling
///
/// **Idempotent Behavior**:
/// - Same eventId called multiple times = increment only once
/// - IdempotencyService prevents duplicate increments on network retry
/// - Fire-and-forget pattern: Can be called without awaiting result
class IncrementViewCountUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid;

  IncrementViewCountUseCase({
    required IPostDisplayRepositoryV2 postRepository,
    Uuid? uuid,
  })  : _postRepository = postRepository,
        _uuid = uuid ?? const Uuid();

  /// Execute the use case to increment view count
  ///
  /// **Parameters**:
  /// - [postId] - ID of post to increment views
  ///
  /// **Returns**:
  /// - Right(unit) - View count incremented successfully
  /// - Left(PostFailure.postNotFound) - Post doesn't exist
  /// - Left(PostFailure.updateFailed) - Update operation failed
  /// - Left(PostFailure.invalidInput) - Empty postId
  ///
  /// **Idempotency**:
  /// - Generates unique eventId for each call
  /// - Same eventId on retry prevents duplicate increments
  /// - Network retry with same eventId returns success without re-incrementing
  ///
  /// **Usage Pattern**:
  /// ```dart
  /// // Fire and forget (don't wait for completion)
  /// unawaited(incrementViewCountUseCase.execute(postId: post.id));
  ///
  /// // Or await for error handling
  /// final result = await incrementViewCountUseCase.execute(postId: post.id);
  /// result.fold(
  ///   (failure) => print('Failed to increment: $failure'),
  ///   (_) => print('View count incremented'),
  /// );
  /// ```
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
    return await _postRepository.incrementViewCount(
      postId: postId,
      eventId: eventId,
    );
  }
}
