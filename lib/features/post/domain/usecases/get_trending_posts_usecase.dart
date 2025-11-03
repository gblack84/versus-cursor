import 'package:fpdart/fpdart.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// UseCase for getting trending posts
/// 트렌딩 게시물을 가져오기 위한 UseCase
///
/// **Phase 1: Either Pattern Applied**
/// - Returns Either<PostFailure, List<PostDisplay>>
/// - Type-safe error handling with specific failure types
/// - Stream methods return Stream without Either wrapper
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
  /// **Parameters**:
  /// - [limit] - Maximum number of posts to return (default: 20)
  ///
  /// **Returns**:
  /// - Right(List<PostDisplay>) - Trending posts loaded successfully
  /// - Left(PostFailure.invalidInput) - Invalid limit parameter
  /// - Left(PostFailure.queryFailed) - Query execution failed
  /// - Left(PostFailure.*) - Other repository failures
  Future<Either<PostFailure, List<PostDisplay>>> execute({
    int limit = 20,
  }) async {
    // Validate input
    if (limit <= 0) {
      return left(const PostFailure.invalidInput(field: 'limit'));
    }

    try {
      // Get trending posts from repository
      final stream = _postRepository.getTrendingPosts(limit: limit);
      final posts = await stream.first;

      return right(posts);
    } catch (error) {
      return left(PostFailure.queryFailed(
        reason: 'Failed to load trending posts: $error',
      ));
    }
  }

  /// Get trending posts as a real-time stream
  /// 실시간 트렌딩 게시물 스트림 가져오기
  ///
  /// **Note**: Stream methods don't use Either - they use Stream.error()
  ///
  /// **Parameters**:
  /// - [limit] - Maximum number of posts to return
  ///
  /// **Returns**:
  /// - Stream emits List<PostDisplay> on success
  /// - Stream emits error (PostFailure) on failure
  Stream<List<PostDisplay>> getTrendingStream({
    int limit = 20,
  }) {
    // Validate input
    if (limit <= 0) {
      return Stream.error(
        const PostFailure.invalidInput(field: 'limit'),
      );
    }

    try {
      return _postRepository.getTrendingPosts(limit: limit);
    } catch (error) {
      return Stream.error(
        PostFailure.queryFailed(
          reason: 'Failed to create trending stream: $error',
        ),
      );
    }
  }
}
