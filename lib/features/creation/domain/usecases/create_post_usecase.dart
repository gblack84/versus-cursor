import 'dart:io';
import '/core/types/result.dart';
import '../models/aggregates/post_creation.dart';
import '../failures/creation_failures.dart';
import '../repositories/i_post_creation_repository_v2.dart';
import '../repositories/i_media_repository.dart';
import '../models/core/post_core.dart';
import '../models/core/post_content.dart';
import '../models/value_objects/media_content.dart';
import '../../data/dto/post_creation_dto.dart';
import '../../data/dto/target_audience_dto.dart';
import '../services/i_image_processing_service.dart';
import 'audience/manage_target_audience_usecase.dart';

/// UseCase for creating a new post
/// 새로운 게시물을 생성하기 위한 UseCase
///
/// Phase 1.3: Service dependencies removed, now using Repository methods
/// Phase 5 Restoration: ManageTargetAudienceUseCase fully integrated
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
    required ManageTargetAudienceUseCase manageTargetAudienceUseCase,
  })  : _postRepository = postRepository,
        _mediaRepository = mediaRepository,
        _manageTargetAudienceUseCase = manageTargetAudienceUseCase;

  /// Execute the use case with DTO
  ///
  /// Simplified interface using PostCreationDto to bundle all parameters.
  /// This follows Clean Architecture by reducing coupling between layers.
  Future<Result<PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. Validate inputs from DTO
      final validationResult = _validateInputs(
        title: dto.title,
        description: dto.description,
        imagesA: dto.imagesA,
        imagesB: dto.imagesB,
      );

      if (validationResult != null) {
        return ResultFailure(validationResult);
      }

      onProgress?.call(0.1);

      // 2. Process and moderate images for option A
      final resultA = await _processImages(
        images: dto.imagesA,
        box: 'A',
        onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
      );

      if (resultA.isFailure) {
        return ResultFailure(resultA.failureOrNull!);
      }

      onProgress?.call(0.4);

      // 3. Process and moderate images for option B
      final resultB = await _processImages(
        images: dto.imagesB,
        box: 'B',
        onProgress: (progress) => onProgress?.call(0.4 + progress * 0.3),
      );

      if (resultB.isFailure) {
        return ResultFailure(resultB.failureOrNull!);
      }

      onProgress?.call(0.7);

      // 4. Upload processed images
      final uploadResultA = await _uploadImages(
        processedImages: resultA.valueOrNull!.approvedFiles,
      );

      if (uploadResultA.isFailure) {
        return ResultFailure(uploadResultA.failureOrNull!);
      }

      final uploadResultB = await _uploadImages(
        processedImages: resultB.valueOrNull!.approvedFiles,
      );

      if (uploadResultB.isFailure) {
        return ResultFailure(uploadResultB.failureOrNull!);
      }

      onProgress?.call(0.8);

      // 5. Validate and process target audience if provided
      // Phase 5 Restoration: Using ManageTargetAudienceUseCase for complete functionality
      // - DTO conversion with validation
      // - Model creation with proper defaults
      // - ITargetAudienceService validation
      // - Result pattern error handling
      if (dto.targetAudience != null) {
        // Convert to DTO for UseCase
        final targetAudienceDto = TargetAudienceDto(
          collectionType: dto.targetAudience!.collectionType,
          targetCount: dto.targetAudience!.targetCount,
          selectedInterests: dto.targetAudience!.selectedInterests,
          selectedAgeGroup: dto.targetAudience!.selectedAgeGroup,
          selectedGender: dto.targetAudience!.selectedGender,
          activeUserOnly: dto.targetAudience!.activeUserOnly,
          isPremium: dto.targetAudience!.isPremium,
        );

        // Use ManageTargetAudienceUseCase for creation and validation
        final audienceResult = await _manageTargetAudienceUseCase.createFromDto(
          targetAudienceDto,
        );

        if (audienceResult.isFailure) {
          return ResultFailure(audienceResult.failureOrNull!);
        }

        // Validated TargetAudience is now available for use
        // (dto.targetAudience already contains the necessary data)
      }

      // 6. Create post entity from DTO with uploaded media
      final post = PostCreation(
        userId: dto.userId,
        title: dto.title,
        description: dto.description,
        optionA: PostOption(
          imageUrls: uploadResultA.valueOrNull!,
          aspectRatios: resultA.valueOrNull!.approvedRatios,
        ),
        optionB: PostOption(
          imageUrls: uploadResultB.valueOrNull!,
          aspectRatios: resultB.valueOrNull!.approvedRatios,
        ),
        targetAudience: dto.targetAudience,
        createdAt: DateTime.now(),
        status: PostStatus.published,
        isAnonymous: dto.isAnonymous,
      );

      onProgress?.call(0.9);

      // 7. Create PostCore and PostContent (Creation Feature responsibility only)
      final core = PostCore(
        id: '', // Will be set by repository
        userId: dto.userId,
        questionTitle: dto.title,
        description: dto.description,
        isAnonymous: dto.isAnonymous,
        createdAt: DateTime.now(),
      );

      final content = PostContent(
        postId: '', // Will be set by repository
        optionA: MediaContent(
          imageUrls: uploadResultA.valueOrNull!,
          aspectRatios: resultA.valueOrNull!.approvedRatios,
        ),
        optionB: MediaContent(
          imageUrls: uploadResultB.valueOrNull!,
          aspectRatios: resultB.valueOrNull!.approvedRatios,
        ),
      );

      // Save using V2 repository (PostCore + PostContent only)
      final postId = await _postRepository.createPost(
        core: core,
        content: content,
      );

      // Update the post with the generated ID
      final savedPost = post.copyWith(id: postId);

      onProgress?.call(1.0);

      return Success(savedPost);
    } catch (error, stackTrace) {
      print('CreatePostUseCase Error: $error');
      print('StackTrace: $stackTrace');

      // Handle specific error types without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return ResultFailure(
          ServerFailure(
            'Permission denied to create post',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        UnknownFailure(message: 'Failed to create post: $error'),
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
  Future<Result<ImageProcessingResult>> _processImages({
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
        return ResultFailure(
          ModerationFailure(
            'All images were rejected',
            rejectedReasons: result.rejectedReasons.keys.toList(),
          ),
        );
      }

      return Success(result);
    } catch (error) {
      return ResultFailure(
        ImageUploadFailure('Failed to process images: $error'),
      );
    }
  }

  /// Upload images to storage
  Future<Result<List<String>>> _uploadImages({
    required List<File> processedImages,
  }) async {
    try {
      final urls = await _mediaRepository.uploadImages(processedImages);
      return Success(urls);
    } catch (error) {
      return ResultFailure(
        ImageUploadFailure('Failed to upload images: $error'),
      );
    }
  }
}