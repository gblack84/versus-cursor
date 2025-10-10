import '/core/types/result.dart';
import '/core/errors/failures.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';

/// UseCase for getting a single post's details
/// 단일 게시물의 상세 정보를 가져오기 위한 UseCase
class GetPostDetailUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetPostDetailUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to get post details
  ///
  /// [postId] - ID of the post to retrieve
  /// [incrementViewCount] - Whether to increment the view count (default: true)
  ///
  /// Returns a Result containing either the post or a Failure
  Future<Result<PostDisplay>> execute({
    required String postId,
    bool incrementViewCount = true,
  }) async {
    try {
      if (postId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'Post ID cannot be empty'),
        );
      }

      // Get post from repository
      final post = await _postRepository.getPost(postId);

      if (post == null) {
        return ResultFailure(
          NotFoundFailure(message: 'Post not found with ID: $postId'),
        );
      }

      // Increment view count if requested
      if (incrementViewCount) {
        // Fire and forget - don't wait for completion
        _postRepository.incrementViewCount(postId).catchError((error) {
          print('Failed to increment view count: $error');
        });
      }

      return Success(post);
    } catch (error) {
      print('GetPostDetailUseCase Error: $error');

      // Handle errors without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return ResultFailure(
          ServerFailure(
            message: 'Permission denied to load post',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        AppFailure(message: 'Failed to load post: $error'),
      );
    }
  }

  /// Get post details as a real-time stream
  /// 실시간 게시물 상세 스트림 가져오기
  Stream<Result<PostDisplay>> getPostStream({
    required String postId,
  }) {
    try {
      if (postId.isEmpty) {
        return Stream.value(
          ResultFailure(
            ValidationFailure(message: 'Post ID cannot be empty'),
          ),
        );
      }

      final stream = _postRepository.streamPost(postId);

      return stream.map((post) {
        try {
          if (post == null) {
            return ResultFailure<PostDisplay>(
              NotFoundFailure(message: 'Post not found with ID: $postId'),
            );
          }
          return Success(post);
        } catch (error) {
          return ResultFailure<PostDisplay>(
            AppFailure(message: 'Failed to load post: $error'),
          );
        }
      });
    } catch (error) {
      return Stream.value(
        ResultFailure(
          AppFailure(message: 'Failed to create post stream: $error'),
        ),
      );
    }
  }
}
