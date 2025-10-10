import '/core/types/result.dart';
import '/core/errors/failures.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';

/// UseCase for getting popular posts
/// 인기 게시물을 가져오기 위한 UseCase
///
/// Popular posts are sorted by engagement metrics (likes, comments, shares)
/// Optionally filtered by time window for recent popularity
class GetPopularPostsUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetPopularPostsUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to get popular posts
  ///
  /// [limit] - Maximum number of posts to return
  /// [timeWindow] - Optional time window for filtering recent posts
  ///
  /// Returns a Result containing either a list of popular posts or a Failure
  Future<Result<List<PostDisplay>>> execute({
    int limit = 20,
    Duration? timeWindow,
  }) async {
    try {
      // Get popular posts from repository
      final stream = _postRepository.getPopularPosts(
        limit: limit,
        timeWindow: timeWindow,
      );
      final posts = await stream.first;

      return Success(posts);
    } catch (error) {
      print('GetPopularPostsUseCase Error: $error');

      // Handle errors without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return ResultFailure(
          ServerFailure(
            message: 'Permission denied to load popular posts',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        AppFailure(message: 'Failed to load popular posts: $error'),
      );
    }
  }

  /// Get popular posts as a real-time stream
  /// 실시간 인기 게시물 스트림 가져오기
  Stream<Result<List<PostDisplay>>> getPopularStream({
    int limit = 20,
    Duration? timeWindow,
  }) {
    try {
      final stream = _postRepository.getPopularPosts(
        limit: limit,
        timeWindow: timeWindow,
      );

      return stream.map((posts) {
        try {
          return Success(posts);
        } catch (error) {
          return ResultFailure<List<PostDisplay>>(
            AppFailure(message: 'Failed to load popular posts: $error'),
          );
        }
      });
    } catch (error) {
      return Stream.value(
        ResultFailure(
          AppFailure(message: 'Failed to create popular stream: $error'),
        ),
      );
    }
  }
}
