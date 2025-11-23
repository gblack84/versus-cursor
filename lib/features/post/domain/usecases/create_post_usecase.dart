import 'package:fpdart/fpdart.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';
import '/services/logging/dev_logger.dart';

/// UseCase for creating a new post
///
/// **Phase 4: Natural Idempotency via Deterministic IDs**
/// - Uses deterministic post.id for natural idempotency
/// - Validates post data before creation
/// - Returns Either<PostFailure, Unit> for type-safe error handling
class CreatePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  CreatePostUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Execute the use case to create a new post
  ///
  /// **Parameters**:
  /// - [post] - PostDisplay object with all post data (with deterministic ID)
  ///
  /// **Returns**:
  /// - Right(unit) - Post created successfully
  /// - Left(PostFailure.invalidInput) - Invalid post data (e.g., empty titles)
  /// - Left(PostFailure.createFailed) - Firestore write failed
  /// - Left(PostFailure.networkError) - Network connection issue
  ///
  /// **Natural Idempotency**:
  /// - post.id provides deterministic document ID
  /// - Multiple calls with same post.id will overwrite (Firestore set operation)
  /// - No duplicate posts created on network retry
  Future<Either<PostFailure, Unit>> execute({
    required PostDisplay post,
  }) async {
    DevLogger.params({
      'postId': post.id,
      'questionTitle': post.questionTitle,
    }, tag: 'CreatePost');

    // Validate input
    if (post.questionTitle.trim().isEmpty) {
      DevLogger.result(
        isSuccess: false,
        data: 'Empty questionTitle',
        tag: 'CreatePost',
      );
      return left(const PostFailure.invalidInput(field: 'questionTitle'));
    }

    DevLogger.checkpoint('Calling repository.createPost with post.id: ${post.id}', tag: 'CreatePost');

    // Call repository (natural idempotency via deterministic post.id)
    final result = await _postRepository.createPost(
      post: post,
    );

    result.fold(
      (failure) => DevLogger.result(
        isSuccess: false,
        data: failure.toString(),
        tag: 'CreatePost',
      ),
      (_) => DevLogger.result(
        isSuccess: true,
        data: {'postId': post.id},
        tag: 'CreatePost',
      ),
    );

    return result;
  }
}
