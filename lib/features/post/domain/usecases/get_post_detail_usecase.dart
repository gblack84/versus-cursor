import 'package:fpdart/fpdart.dart';
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
    // Validate input
    if (postId.trim().isEmpty) {
      return left(const PostFailure.invalidInput(field: 'postId'));
    }

    // Get post from repository (now returns Either)
    final result = await _postRepository.getPost(postId);

    // If successful and incrementViewCount is true, increment view count
    if (incrementViewCount) {
      result.fold(
        (_) {}, // Ignore if post fetch failed
        (post) {
          // Fire and forget - don't wait for completion
          // Phase 4: Use IncrementViewCountUseCase (eventId auto-generated)
          _incrementViewCountUseCase.execute(postId: postId).then(
            (viewCountResult) {
              viewCountResult.fold(
                (failure) {
                  // Log error but don't fail the main operation
                  print('Failed to increment view count: $failure');
                },
                (_) {}, // Success - no action needed
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
    if (postId.trim().isEmpty) {
      return Stream.error(
        const PostFailure.invalidInput(field: 'postId'),
      );
    }

    return _postRepository.streamPost(postId);
  }
}
