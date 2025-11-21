import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart'; // ✅ Phase 4: UUID for idempotency
import '../entities/post_creation.dart';
import '../entities/target_audience.dart';
import '../failures/creation_failure.dart';
import '../repositories/i_post_creation_repository_v2.dart';
import '../repositories/i_media_repository.dart';
import '../services/i_image_processing_service.dart';
import '/services/logging/logger_service.dart';
import '/services/logging/dev_logger.dart';

/// UseCase for creating a new post
/// 새로운 게시물을 생성하기 위한 UseCase
///
/// **Phase 5 Migration**: Removed PostCreationDto dependency
/// - Now uses individual parameters (userId, title, description, etc.)
/// - Validation logic remains inline
///
/// Phase 1.3: Service dependencies removed, now using Repository methods
/// Phase 6: Converted to Either<Failure, T> pattern with fold/map composition
/// Phase 4: Idempotency Pattern - UUID generation for duplicate prevention
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final Uuid _uuid = const Uuid(); // ✅ Phase 4: UUID generator

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
  }) : _postRepository = postRepository,
       _mediaRepository = mediaRepository;

  /// Execute the use case with individual parameters
  ///
  /// **Phase 5 Migration**: Replaced PostCreationDto with individual parameters
  /// - [userId]: User ID creating the post
  /// - [title]: Post title
  /// - [description]: Post description
  /// - [imagesA]: Images for option A
  /// - [imagesB]: Images for option B
  /// - [targetAudience]: Optional target audience configuration
  /// - [isAnonymous]: Whether post is anonymous
  /// - [onProgress]: Optional progress callback (0.0 to 1.0)
  Future<Either<CreationFailure, PostCreation>> execute({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    bool isAnonymous = false,
    Function(double)? onProgress,
  }) async {
    // ✅ Phase 6: DevLogger Type B (Idempotent) - Log input parameters
    DevLogger.params({
      'userId': userId,
      'title': title.length > 50 ? '${title.substring(0, 50)}...' : title,
      'description': description.length > 50 ? '${description.substring(0, 50)}...' : description,
      'imagesA_count': imagesA.length,
      'imagesB_count': imagesB.length,
      'hasTargetAudience': targetAudience != null,
      'isAnonymous': isAnonymous,
    }, tag: 'CreatePost');

    try {
      // ✅ Phase 6: Checkpoint 1 - Validate inputs
      DevLogger.checkpoint('Step 1: Validate inputs', tag: 'CreatePost');
      final validationResult = _validateInputs(
        title: title,
        description: description,
        imagesA: imagesA,
        imagesB: imagesB,
      );

      if (validationResult != null) {
        DevLogger.error('Validation failed', error: validationResult, tag: 'CreatePost');
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'create_post',
            // message: validationResult.message,
            // code: validationResult.code,
          ),
        );
      }

      onProgress?.call(0.1);
      DevLogger.checkpoint('Progress: 10% - Validation complete', tag: 'CreatePost');

      // ✅ Phase 6: Checkpoint 2 - Process images A
      DevLogger.checkpoint('Step 2: Process images for option A', tag: 'CreatePost');
      final resultA = await _processImages(
        images: imagesA,
        box: 'A',
        onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
      );

      // Early Return on failure
      if (resultA.isLeft()) {
        DevLogger.error('Process images A failed', error: resultA.fold((l) => l, (r) => null), tag: 'CreatePost');
        return left(resultA.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final processedA = resultA.getOrElse((l) => throw Exception('Unreachable'));
      onProgress?.call(0.4);
      DevLogger.checkpoint('Progress: 40% - Images A processed: ${processedA.approvedFiles.length} approved', tag: 'CreatePost');

      // ✅ Phase 6: Checkpoint 3 - Process images B
      DevLogger.checkpoint('Step 3: Process images for option B', tag: 'CreatePost');
      final resultB = await _processImages(
        images: imagesB,
        box: 'B',
        onProgress: (progress) => onProgress?.call(0.4 + progress * 0.3),
      );

      // Early Return on failure
      if (resultB.isLeft()) {
        DevLogger.error('Process images B failed', error: resultB.fold((l) => l, (r) => null), tag: 'CreatePost');
        return left(resultB.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final processedB = resultB.getOrElse((l) => throw Exception('Unreachable'));
      onProgress?.call(0.7);
      DevLogger.checkpoint('Progress: 70% - Images B processed: ${processedB.approvedFiles.length} approved', tag: 'CreatePost');

      // ✅ Phase 6: Checkpoint 4 - Upload images A
      DevLogger.checkpoint('Step 4: Upload images for option A', tag: 'CreatePost');
      final uploadResultA = await _uploadImages(
        processedImages: processedA.approvedFiles,
      );

      // Early Return on failure
      if (uploadResultA.isLeft()) {
        DevLogger.error('Upload images A failed', error: uploadResultA.fold((l) => l, (r) => null), tag: 'CreatePost');
        return left(uploadResultA.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final urlsA = uploadResultA.getOrElse((l) => throw Exception('Unreachable'));
      DevLogger.checkpoint('Images A uploaded: ${urlsA.length} URLs', tag: 'CreatePost');

      // ✅ Phase 6: Checkpoint 5 - Upload images B
      DevLogger.checkpoint('Step 5: Upload images for option B', tag: 'CreatePost');
      final uploadResultB = await _uploadImages(
        processedImages: processedB.approvedFiles,
      );

      // Early Return on failure
      if (uploadResultB.isLeft()) {
        DevLogger.error('Upload images B failed', error: uploadResultB.fold((l) => l, (r) => null), tag: 'CreatePost');
        return left(uploadResultB.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final urlsB = uploadResultB.getOrElse((l) => throw Exception('Unreachable'));
      onProgress?.call(0.8);
      DevLogger.checkpoint('Progress: 80% - Images B uploaded: ${urlsB.length} URLs', tag: 'CreatePost');

      // ✅ Phase 6: Checkpoint 6 - Validate target audience
      if (targetAudience != null) {
        DevLogger.checkpoint('Step 6: Validate target audience', tag: 'CreatePost');
        final validation = _postRepository.validateTargetAudience(
          targetAudience,
        );

        if (!validation.isValid) {
          DevLogger.validation(
            field: 'targetAudience',
            reason: validation.error ?? 'Invalid target audience',
            tag: 'CreatePost',
          );
          return left(
            CreationFailure.postCreationRepositoryFailed(
              operation: 'create_post',
              // message: validation.error ?? 'Invalid target audience',
              // code: 'validation-failed',
            ),
          );
        }
        DevLogger.checkpoint('Target audience validated', tag: 'CreatePost');
      }

      // ✅ Phase 6: Checkpoint 7 - Create post entity
      DevLogger.checkpoint('Step 7: Create post entity', tag: 'CreatePost');
      final post = PostCreation(
        userId: userId,
        title: title,
        description: description,
        optionA: PostOption(
          imageUrls: urlsA,
          aspectRatios: processedA.approvedRatios,
        ),
        optionB: PostOption(
          imageUrls: urlsB,
          aspectRatios: processedB.approvedRatios,
        ),
        targetAudience: targetAudience,
        createdAt: DateTime.now(),
        status: PostStatus.published,
        isAnonymous: isAnonymous,
      );

      onProgress?.call(0.9);
      DevLogger.checkpoint('Progress: 90% - Post entity created', tag: 'CreatePost');

      // ✅ Phase 4: Generate eventId for idempotency
      final eventId = _uuid.v4();
      DevLogger.checkpoint('Generated eventId for idempotency: $eventId', tag: 'CreatePost');

      // ✅ Phase 6: Checkpoint 8 - Save post to Firestore
      DevLogger.checkpoint('Step 8: Save post to Firestore', tag: 'CreatePost');
      final createResult = await _postRepository.createPost(
        post: post,
        eventId: eventId, // ✅ Phase 4: UUID for idempotency
      );

      // Early Return on failure
      if (createResult.isLeft()) {
        DevLogger.error('Save post failed', error: createResult.fold((l) => l, (r) => null), tag: 'CreatePost');
        return left(createResult.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      // Update the post with the generated ID
      final postId = createResult.getOrElse((l) => throw Exception('Unreachable'));
      final savedPost = post.copyWith(id: postId);
      onProgress?.call(1.0);

      DevLogger.result(
        isSuccess: true,
        data: {
          'postId': postId,
          'urlsA_count': urlsA.length,
          'urlsB_count': urlsB.length,
          'eventId': eventId,
        },
        tag: 'CreatePost',
      );

      return right(savedPost);
    } catch (error, stackTrace) {
      DevLogger.error(
        'Post creation failed - Exception caught',
        error: error,
        stackTrace: stackTrace,
        tag: 'CreatePost',
      );

      Logger.error(
        'CreatePostUseCase: Post creation failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'CreatePostUseCase',
      );

      // Handle specific error types without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'create_post',
            // message: 'Permission denied to create post',
            // code: 'permission-denied',
          ),
        );
      }

      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'create_post',
          // message: 'Failed to create post: $error',
          // code: 'unknown-error',
        ),
      );
    }
  }

  /// Validate inputs
  CreationFailure? _validateInputs({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) {
    final errors = <String, String>{};

    if (title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.length > 100) {
      errors['title'] = 'Title must be less than 100 characters';
    }

    if (description.trim().isEmpty) {
      errors['description'] = 'Description is required';
    } else if (description.length > 500) {
      errors['description'] = 'Description must be less than 500 characters';
    }

    if (imagesA.isEmpty && imagesB.isEmpty) {
      errors['images'] = 'At least one image is required';
    }

    if (imagesA.length > 4) {
      errors['imagesA'] = 'Maximum 4 images allowed for option A';
    }

    if (imagesB.length > 4) {
      errors['imagesB'] = 'Maximum 4 images allowed for option B';
    }

    if (errors.isNotEmpty) {
      return CreationFailure.creationValidationFailed(fieldErrors: errors);
    }

    return null;
  }

  /// Process and moderate images
  /// Now using repository method instead of direct service dependency (Phase 1.3)
  Future<Either<CreationFailure, ImageProcessingResult>> _processImages({
    required List<File> images,
    required String box,
    Function(double)? onProgress,
  }) async {
    try {
      final result = await _postRepository.processImages(
        files: images,
        box: box,
        onProgress: onProgress,
      );

      if (result.allRejected) {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'create_post',
            // message: 'All images were rejected: ${result.rejectedReasons.keys.join(", ")}',
            // code: 'moderation-failed',
          ),
        );
      }

      return right(result);
    } catch (error) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'create_post',
          // message: 'Failed to process images: $error',
          // code: 'image-processing-failed',
        ),
      );
    }
  }

  /// Upload images to storage
  Future<Either<CreationFailure, List<String>>> _uploadImages({
    required List<File> processedImages,
  }) async {
    final result = await _mediaRepository.uploadImages(processedImages);

    // Convert MediaRepositoryFailure to CreationFailure
    return result.mapLeft(
      (failure) => CreationFailure.postCreationRepositoryFailed(
        operation: 'upload_images',
        // message: 'Failed to upload images: ${failure.message}',
        // code: 'image-upload-failed',
      ),
    );
  }
}
