import 'package:fpdart/fpdart.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// UseCase for getting posts by a specific user
/// 특정 사용자의 게시물을 가져오기 위한 UseCase
///
/// **Phase 1: Either Pattern Applied**
/// - Returns Either<PostFailure, List<PostDisplay>>
/// - Type-safe error handling with specific failure types
/// - Stream methods return Stream without Either wrapper
class GetUserPostsUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetUserPostsUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to get user's posts
  ///
  /// **Parameters**:
  /// - [userId] - ID of the user whose posts to retrieve
  /// - [limit] - Maximum number of posts to return (-1 for all)
  ///
  /// **Returns**:
  /// - Right(List<PostDisplay>) - User posts loaded successfully
  /// - Left(PostFailure.invalidInput) - Empty or invalid userId
  /// - Left(PostFailure.userNotFound) - User doesn't exist
  /// - Left(PostFailure.queryFailed) - Query execution failed
  /// - Left(PostFailure.*) - Other repository failures
  Future<Either<PostFailure, List<PostDisplay>>> execute({
    required String userId,
    int limit = -1,
  }) async {
    // Validate input
    if (userId.trim().isEmpty) {
      return left(const PostFailure.invalidInput(field: 'userId'));
    }

    try {
      // Get user posts from repository
      final stream = _postRepository.getUserPosts(
        userId: userId,
        limit: limit,
      );
      final posts = await stream.first;

      return right(posts);
    } catch (error) {
      return left(PostFailure.queryFailed(
        reason: 'Failed to load user posts: $error',
      ));
    }
  }

  /// Get user posts as a real-time stream
  /// 실시간 사용자 게시물 스트림 가져오기
  ///
  /// **Note**: Stream methods don't use Either - they use Stream.error()
  ///
  /// **Parameters**:
  /// - [userId] - ID of the user whose posts to retrieve
  /// - [limit] - Maximum number of posts to return (-1 for all)
  ///
  /// **Returns**:
  /// - Stream emits List<PostDisplay> on success
  /// - Stream emits error (PostFailure) on failure
  Stream<List<PostDisplay>> getUserPostsStream({
    required String userId,
    int limit = -1,
  }) {
    // Validate input
    if (userId.trim().isEmpty) {
      return Stream.error(
        const PostFailure.invalidInput(field: 'userId'),
      );
    }

    try {
      return _postRepository.getUserPosts(
        userId: userId,
        limit: limit,
      );
    } catch (error) {
      return Stream.error(
        PostFailure.queryFailed(
          reason: 'Failed to create user posts stream: $error',
        ),
      );
    }
  }
}
