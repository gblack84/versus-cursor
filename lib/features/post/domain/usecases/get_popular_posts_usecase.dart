import 'package:fpdart/fpdart.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// UseCase for getting popular posts
/// 인기 게시물을 가져오기 위한 UseCase
///
/// **Phase 1: Either Pattern Applied**
/// - Returns Either<PostFailure, List<PostDisplay>>
/// - Type-safe error handling with specific failure types
/// - Stream methods return Stream without Either wrapper
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
  /// **Parameters**:
  /// - [limit] - Maximum number of posts to return (default: 20)
  /// - [timeWindow] - Optional time window for filtering recent posts
  ///
  /// **Returns**:
  /// - Right(List<PostDisplay>) - Popular posts loaded successfully
  /// - Left(PostFailure.invalidInput) - Invalid limit parameter
  /// - Left(PostFailure.queryFailed) - Query execution failed
  /// - Left(PostFailure.*) - Other repository failures
  Future<Either<PostFailure, List<PostDisplay>>> execute({
    int limit = 20,
    Duration? timeWindow,
  }) async {
    // Validate input
    if (limit <= 0) {
      return left(const PostFailure.invalidInput(field: 'limit'));
    }

    try {
      // Get popular posts from repository
      final stream = _postRepository.getPopularPosts(
        limit: limit,
        timeWindow: timeWindow,
      );
      final posts = await stream.first;

      return right(posts);
    } catch (error) {
      return left(PostFailure.queryFailed(
        reason: 'Failed to load popular posts: $error',
      ));
    }
  }

  /// Get popular posts as a real-time stream
  /// 실시간 인기 게시물 스트림 가져오기
  ///
  /// **Note**: Stream methods don't use Either - they use Stream.error()
  ///
  /// **Parameters**:
  /// - [limit] - Maximum number of posts to return
  /// - [timeWindow] - Optional time window for filtering recent posts
  ///
  /// **Returns**:
  /// - Stream emits List<PostDisplay> on success
  /// - Stream emits error (PostFailure) on failure
  Stream<List<PostDisplay>> getPopularStream({
    int limit = 20,
    Duration? timeWindow,
  }) {
    // Validate input
    if (limit <= 0) {
      return Stream.error(
        const PostFailure.invalidInput(field: 'limit'),
      );
    }

    try {
      return _postRepository.getPopularPosts(
        limit: limit,
        timeWindow: timeWindow,
      );
    } catch (error) {
      return Stream.error(
        PostFailure.queryFailed(
          reason: 'Failed to create popular stream: $error',
        ),
      );
    }
  }
}
