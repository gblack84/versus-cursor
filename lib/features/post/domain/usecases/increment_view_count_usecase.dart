import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
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

  IncrementViewCountUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

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
  /// **Option 1**: IdempotencyService 제거 (고정 ID + FieldValue.increment)
  /// - FieldValue.increment()는 원자적 연산으로 멱등성 보장
  /// - 조회수는 근사치 허용 (정확도 < 성능)
  /// - IdempotencyService 오버헤드 제거: 100ms → 30ms
  ///
  /// **Usage Pattern**:
  /// ```dart
  /// // Fire and forget (don't wait for completion)
  /// unawaited(incrementViewCountUseCase.execute(postId: post.id));
  ///
  /// // Or await for error handling
  /// final result = await incrementViewCountUseCase.execute(postId: post.id);
  /// result.fold(
  ///   (failure) => PostLogger.metricsError(operation: 'incrementViewCount', error: failure),
  ///   (_) => PostLogger.viewCountIncremented(postId: post.id, newCount: 1),
  /// );
  /// ```
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
  }) async {
    DevLogger.params({'postId': postId}, tag: 'IncrementViewCount');

    // Validate input
    if (postId.trim().isEmpty) {
      DevLogger.validation(
        field: 'postId',
        reason: 'Post ID cannot be empty',
        tag: 'IncrementViewCount',
      );
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    DevLogger.checkpoint(
      'Incrementing view count',
      tag: 'IncrementViewCount',
    );

    // Call repository (no eventId needed)
    final result = await _postRepository.incrementViewCount(
      postId: postId,
    );

    result.fold(
      (failure) {
        DevLogger.error(
          'Failed to increment view count',
          error: failure,
          tag: 'IncrementViewCount',
        );
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: 'View count incremented',
          tag: 'IncrementViewCount',
        );
      },
    );

    return result;
  }
}
