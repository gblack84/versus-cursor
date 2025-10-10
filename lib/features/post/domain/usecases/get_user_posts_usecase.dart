import '/core/types/result.dart';
import '/core/errors/failures.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';

/// UseCase for getting posts by a specific user
/// 특정 사용자의 게시물을 가져오기 위한 UseCase
class GetUserPostsUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetUserPostsUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to get user's posts
  ///
  /// [userId] - ID of the user whose posts to retrieve
  /// [limit] - Maximum number of posts to return (-1 for all)
  ///
  /// Returns a Result containing either a list of user posts or a Failure
  Future<Result<List<PostDisplay>>> execute({
    required String userId,
    int limit = -1,
  }) async {
    try {
      if (userId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'User ID cannot be empty'),
        );
      }

      // Get user posts from repository
      final stream = _postRepository.getUserPosts(
        userId: userId,
        limit: limit,
      );
      final posts = await stream.first;

      return Success(posts);
    } catch (error) {
      print('GetUserPostsUseCase Error: $error');

      // Handle errors without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return ResultFailure(
          ServerFailure(
            message: 'Permission denied to load user posts',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        AppFailure(message: 'Failed to load user posts: $error'),
      );
    }
  }

  /// Get user posts as a real-time stream
  /// 실시간 사용자 게시물 스트림 가져오기
  Stream<Result<List<PostDisplay>>> getUserPostsStream({
    required String userId,
    int limit = -1,
  }) {
    try {
      if (userId.isEmpty) {
        return Stream.value(
          ResultFailure(
            ValidationFailure(message: 'User ID cannot be empty'),
          ),
        );
      }

      final stream = _postRepository.getUserPosts(
        userId: userId,
        limit: limit,
      );

      return stream.map((posts) {
        try {
          return Success(posts);
        } catch (error) {
          return ResultFailure<List<PostDisplay>>(
            AppFailure(message: 'Failed to load user posts: $error'),
          );
        }
      });
    } catch (error) {
      return Stream.value(
        ResultFailure(
          AppFailure(message: 'Failed to create user posts stream: $error'),
        ),
      );
    }
  }
}
