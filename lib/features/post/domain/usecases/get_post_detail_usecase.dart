import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';
import 'increment_view_count_usecase.dart';

/// UseCase for getting a single post's details
///
/// **Phase 1: Either Pattern Applied**
/// - Returns Either<PostFailure, PostDisplay>
/// - Type-safe error handling with specific failure types
///
/// **Phase 4: Idempotency Integration**
/// - Uses IncrementViewCountUseCase for view count increment
/// - eventId automatically generated for idempotency
class GetPostDetailUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final IncrementViewCountUseCase _incrementViewCountUseCase;

  GetPostDetailUseCase({
    required IPostDisplayRepositoryV2 postRepository,
    required IncrementViewCountUseCase incrementViewCountUseCase,
  })  : _postRepository = postRepository,
        _incrementViewCountUseCase = incrementViewCountUseCase;

  /// Execute the use case to get post details
  ///
  /// **Parameters**:
  /// - [postId] - ID of the post to retrieve
  /// - [incrementViewCount] - Whether to increment the view count (default: true)
  ///
  /// **Returns**:
  /// - Right(PostDisplay) - Post found and loaded successfully
  /// - Left(PostFailure.invalidInput) - Empty postId
  /// - Left(PostFailure.postNotFound) - Post doesn't exist
  /// - Left(PostFailure.*) - Other repository failures
  Future<Either<PostFailure, PostDisplay>> execute({
    required String postId,
    bool incrementViewCount = true,
  }) async {
    DevLogger.params({
      'postId': postId,
      'incrementViewCount': incrementViewCount,
    }, tag: 'GetPostDetail');

    // Validate input
    if (postId.trim().isEmpty) {
      DevLogger.validation(
        field: 'postId',
        reason: 'Post ID cannot be empty',
        tag: 'GetPostDetail',
      );
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    // Get post from repository (now returns Either)
    DevLogger.checkpoint('Fetching post from repository', tag: 'GetPostDetail');
    final result = await _postRepository.getPost(postId);

    result.fold(
      (failure) {
        DevLogger.error(
          'Failed to fetch post',
          error: failure,
          tag: 'GetPostDetail',
        );
      },
      (post) {
        DevLogger.result(
          isSuccess: true,
          data: 'Post fetched: ${post.id}',
          tag: 'GetPostDetail',
        );
      },
    );

    // If successful and incrementViewCount is true, increment view count
    if (incrementViewCount) {
      result.fold(
        (_) {}, // Ignore if post fetch failed
        (post) {
          // Fire and forget - don't wait for completion
          // Phase 4: Use IncrementViewCountUseCase (eventId auto-generated)
          DevLogger.checkpoint('Incrementing view count (async)', tag: 'GetPostDetail');
          _incrementViewCountUseCase.execute(postId: postId).then(
            (viewCountResult) {
              viewCountResult.fold(
                (failure) {
                  // Log error but don't fail the main operation
                  DevLogger.error(
                    'View count increment failed (non-critical)',
                    error: failure,
                    tag: 'GetPostDetail',
                  );
                },
                (_) {
                  DevLogger.checkpoint(
                    'View count incremented successfully',
                    tag: 'GetPostDetail',
                  );
                }, // Success - no action needed
              );
            },
          );
        },
      );
    }

    return result;
  }

  /// Get post details as a real-time stream
  ///
  /// **Note**: Stream methods don't use Either - they use Stream.error()
  ///
  /// **Returns**:
  /// - Stream emits PostDisplay when post is found
  /// - Stream emits null if post doesn't exist
  /// - Stream emits error on failures
  Stream<PostDisplay?> getPostStream({
    required String postId,
  }) {
    DevLogger.params({'postId': postId}, tag: 'GetPostStream');

    if (postId.trim().isEmpty) {
      DevLogger.validation(
        field: 'postId',
        reason: 'Post ID cannot be empty',
        tag: 'GetPostStream',
      );
      return Stream.error(
        const PostFailure.invalidInput(field: 'postId'),
      );
    }

    DevLogger.checkpoint('Starting post stream', tag: 'GetPostStream');
    return _postRepository.streamPost(postId);
  }
}
