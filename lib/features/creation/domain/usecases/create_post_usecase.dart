import 'dart:io';
import '../core/result.dart';
import '../entities/post_creation.dart';
import '../failures/creation_failures.dart';
import '../models/target_audience.dart';
import '../repositories/i_post_creation_repository_v2.dart';
import '../repositories/i_media_repository.dart';
import '../models/post_core.dart';
import '../models/post_content.dart';
import '../models/post_voting.dart';
import '../models/post_metrics.dart';
import '../models/media_content.dart';
import '/app/contracts/models/post_bundle.dart';
import '../services/i_target_audience_service.dart' as service;
import '../services/i_image_processing_service.dart';

/// UseCase for creating a new post
/// 새로운 게시물을 생성하기 위한 UseCase
///
/// Phase 1.3: Service dependencies removed, now using Repository methods
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
  })  : _postRepository = postRepository,
        _mediaRepository = mediaRepository;

  /// Execute the use case
  Future<Result<PostCreation>> execute({
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
        return ResultFailure(validationResult);
      }

      onProgress?.call(0.1);

      // 2. Process and moderate images for option A
      final resultA = await _processImages(
        images: imagesA,
        box: 'A',
        onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
      );

      if (resultA.isFailure) {
        return ResultFailure(resultA.failureOrNull!);
      }

      onProgress?.call(0.4);

      // 3. Process and moderate images for option B
      final resultB = await _processImages(
        images: imagesB,
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

      // 5. Validate target audience if provided
      // Now using repository method instead of direct service dependency (Phase 1.3)
      if (targetAudience != null) {
        final audienceValidation = _postRepository.validateTargetAudience(
          targetAudience,
        );
        if (!audienceValidation.isValid) {
          return ResultFailure(
            CreationValidationFailure(
              audienceValidation.error ?? 'Invalid target audience',
            ),
          );
        }
      }

      // 6. Create post entity
      final post = PostCreation(
        userId: userId,
        title: title,
        description: description,
        optionA: PostOption(
          imageUrls: uploadResultA.valueOrNull!,
          aspectRatios: resultA.valueOrNull!.approvedRatios,
        ),
        optionB: PostOption(
          imageUrls: uploadResultB.valueOrNull!,
          aspectRatios: resultB.valueOrNull!.approvedRatios,
        ),
        targetAudience: targetAudience,
        createdAt: DateTime.now(),
        status: PostStatus.published,
        isAnonymous: isAnonymous,
      );

      onProgress?.call(0.9);

      // 7. Create PostBundle for V2 repository
      final postBundle = PostBundle(
        core: PostCore(
          id: '', // Will be set by repository
          userId: userId,
          title: title,
          description: description,
          isAnonymous: isAnonymous,
          createdAt: DateTime.now(),
        ),
        content: PostContent(
          optionA: MediaContent(
            text: null, // Text is now in optionA/B properties of Post
            imageUrls: uploadResultA.valueOrNull!,
            videoUrls: [],
            aspectRatios: resultA.valueOrNull!.approvedRatios,
          ),
          optionB: MediaContent(
            text: null, // Text is now in optionA/B properties of Post
            imageUrls: uploadResultB.valueOrNull!,
            videoUrls: [],
            aspectRatios: resultB.valueOrNull!.approvedRatios,
          ),
          contentType: 'versus',
        ),
        voting: PostVoting(
          voteMode: targetAudience?.mode ?? 'public',
          targetAudience: targetAudience?.toMap() ?? {},
          voteStartTime: DateTime.now(),
          voteEndTime: DateTime.now().add(const Duration(minutes: 10)),
        ),
        metrics: PostMetrics(
          views: 0,
          shares: 0,
          likeCount: 0,
          commentCount: 0,
        ),
      );

      // Save using V2 repository
      final postId = await _postRepository.createPost(postBundle);

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
        UnknownFailure('Failed to create post: $error'),
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