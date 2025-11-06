import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart'; // ✅ Phase 4: UUID for idempotency
import '../entities/post_creation.dart';
import '../entities/target_audience.dart';
import '../failures/creation_failures.dart';
import '../repositories/i_post_creation_repository_v2.dart';
import '../repositories/i_media_repository.dart';
import '../services/i_image_processing_service.dart';

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
  })  : _postRepository = postRepository,
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
  Future<Either<CreateContentFailure, PostCreation>> execute({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    bool isAnonymous = false,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. Validate inputs
      final validationResult = _validateInputs(
        title: title,
        description: description,
        imagesA: imagesA,
        imagesB: imagesB,
      );

      if (validationResult != null) {
        return left(
          CreateContentFailure(
            validationResult.message,
            validationResult.code,
          ),
        );
      }

      onProgress?.call(0.1);

      // 2. Process images for option A
      final resultA = await _processImages(
        images: imagesA,
        box: 'A',
        onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
      );

      return resultA.fold(
        (failure) => left(failure),
        (processedA) async {
          onProgress?.call(0.4);

          // 3. Process images for option B
          final resultB = await _processImages(
            images: imagesB,
            box: 'B',
            onProgress: (progress) => onProgress?.call(0.4 + progress * 0.3),
          );

          return resultB.fold(
            (failure) => left(failure),
            (processedB) async {
              onProgress?.call(0.7);

              // 4. Upload processed images for option A
              final uploadResultA = await _uploadImages(
                processedImages: processedA.approvedFiles,
              );

              return uploadResultA.fold(
                (failure) => left(failure),
                (urlsA) async {
                  // 5. Upload processed images for option B
                  final uploadResultB = await _uploadImages(
                    processedImages: processedB.approvedFiles,
                  );

                  return uploadResultB.fold(
                    (failure) => left(failure),
                    (urlsB) async {
                      onProgress?.call(0.8);

                      // 6. Validate target audience if provided
                      if (targetAudience != null) {
                        final validation = _postRepository.validateTargetAudience(
                          targetAudience,
                        );

                        if (!validation.isValid) {
                          return left(
                            CreateContentFailure(
                              validation.error ?? 'Invalid target audience',
                              'validation-failed',
                            ),
                          );
                        }
                      }

                      // 7. Create post entity with uploaded media
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

                      // ✅ Phase 4: Generate eventId for idempotency
                      final eventId = _uuid.v4();

                      // 8. Save post using PostCreation aggregate with eventId
                      final createResult = await _postRepository.createPost(
                        post: post,
                        eventId: eventId, // ✅ Phase 4: UUID for idempotency
                      );

                      return createResult.map((postId) {
                        // Update the post with the generated ID
                        final savedPost = post.copyWith(id: postId);
                        onProgress?.call(1.0);
                        return savedPost;
                      });
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (error, stackTrace) {
      print('CreatePostUseCase Error: $error');
      print('StackTrace: $stackTrace');

      // Handle specific error types without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return left(
          CreateContentFailure(
            'Permission denied to create post',
            'permission-denied',
          ),
        );
      }

      return left(
        CreateContentFailure(
          'Failed to create post: $error',
          'unknown-error',
        ),
      );
    }
  }

  /// Validate inputs
  CreationValidationFailure? _validateInputs({
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
      return CreationValidationFailure(
        'Validation failed',
        fieldErrors: errors,
      );
    }

    return null;
  }

  /// Process and moderate images
  /// Now using repository method instead of direct service dependency (Phase 1.3)
  Future<Either<CreateContentFailure, ImageProcessingResult>> _processImages({
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
          CreateContentFailure(
            'All images were rejected: ${result.rejectedReasons.keys.join(", ")}',
            'moderation-failed',
          ),
        );
      }

      return right(result);
    } catch (error) {
      return left(
        CreateContentFailure(
          'Failed to process images: $error',
          'image-processing-failed',
        ),
      );
    }
  }

  /// Upload images to storage
  Future<Either<CreateContentFailure, List<String>>> _uploadImages({
    required List<File> processedImages,
  }) async {
    final result = await _mediaRepository.uploadImages(processedImages);

    // Convert MediaRepositoryFailure to CreateContentFailure
    return result.mapLeft((failure) =>
      CreateContentFailure(
        'Failed to upload images: ${failure.message}',
        'image-upload-failed',
      ),
    );
  }
}