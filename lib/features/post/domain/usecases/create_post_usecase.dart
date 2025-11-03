import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// UseCase for creating a new post
///
/// **Phase 4: Idempotency Integration**
/// - Generates UUID eventId for duplicate prevention
/// - Validates post data before creation
/// - Returns Either<PostFailure, Unit> for type-safe error handling
class CreatePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid;

  CreatePostUseCase({
    required IPostDisplayRepositoryV2 postRepository,
    Uuid? uuid,
  })  : _postRepository = postRepository,
        _uuid = uuid ?? const Uuid();

  /// Execute the use case to create a new post
  ///
  /// **Parameters**:
  /// - [post] - PostDisplay object with all post data
  ///
  /// **Returns**:
  /// - Right(unit) - Post created successfully
  /// - Left(PostFailure.invalidInput) - Invalid post data (e.g., empty titles)
  /// - Left(PostFailure.createFailed) - Firestore write failed
  /// - Left(PostFailure.networkError) - Network connection issue
  ///
  /// **Idempotency**:
  /// - Generates unique eventId for each call
  /// - Same eventId on retry prevents duplicate posts
  /// - Network retry with same eventId returns success without creating duplicate
  Future<Either<PostFailure, Unit>> execute({
    required PostDisplay post,
  }) async {
    // Validate input
    if (post.questionTitle.trim().isEmpty) {
      return left(const PostFailure.invalidInput(field: 'questionTitle'));
    }

    // Generate eventId for idempotency
    final eventId = _uuid.v4();

    // Call repository with eventId
    return await _postRepository.createPost(
      post: post,
      eventId: eventId,
    );
  }
}
