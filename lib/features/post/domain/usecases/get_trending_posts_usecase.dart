import '/core/types/result.dart';
import '/core/errors/failures.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';

/// UseCase for getting trending posts
/// 트렌딩 게시물을 가져오기 위한 UseCase
///
/// Trending posts are determined by recent engagement (likes, comments, shares)
/// within a specific time window
class GetTrendingPostsUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetTrendingPostsUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to get trending posts
  ///
  /// Returns a Result containing either a list of trending posts or a Failure
  Future<Result<List<PostDisplay>>> execute({
    int limit = 20,
  }) async {
    try {
      // Get trending posts from repository
      final stream = _postRepository.getTrendingPosts(limit: limit);
      final posts = await stream.first;

      return Success(posts);
    } catch (error) {
      print('GetTrendingPostsUseCase Error: $error');

      // Handle errors without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return ResultFailure(
          ServerFailure(
            message: 'Permission denied to load trending posts',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        AppFailure(message: 'Failed to load trending posts: $error'),
      );
    }
  }

  /// Get trending posts as a real-time stream
  /// 실시간 트렌딩 게시물 스트림 가져오기
  Stream<Result<List<PostDisplay>>> getTrendingStream({
    int limit = 20,
  }) {
    try {
      final stream = _postRepository.getTrendingPosts(limit: limit);

      return stream.map((posts) {
        try {
          return Success(posts);
        } catch (error) {
          return ResultFailure<List<PostDisplay>>(
            AppFailure(message: 'Failed to load trending posts: $error'),
          );
        }
      });
    } catch (error) {
      return Stream.value(
        ResultFailure(
          AppFailure(message: 'Failed to create trending stream: $error'),
        ),
      );
    }
  }
}
