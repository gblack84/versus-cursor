import 'dart:io';
import '../core/result.dart';
import '../entities/post.dart';
import '../failures/post_failures.dart';
import '../models/target_audience.dart';
import '../repositories/i_post_repository.dart';
import '../repositories/i_media_repository.dart';
import '../../data/services/target_audience_service.dart';
import '../../data/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// UseCase for creating a new post
/// 새로운 게시물을 생성하기 위한 UseCase
class CreatePostUseCase {
  final IPostRepository _postRepository;
  final IMediaRepository _mediaRepository;
  final TargetAudienceService _targetAudienceService;
  final ImageUploadService _imageUploadService;

  CreatePostUseCase({
    required IPostRepository postRepository,
    required IMediaRepository mediaRepository,
    required TargetAudienceService targetAudienceService,
    required ImageUploadService imageUploadService,
  })  : _postRepository = postRepository,
        _mediaRepository = mediaRepository,
        _targetAudienceService = targetAudienceService,
        _imageUploadService = imageUploadService;

  /// Execute the use case
  Future<Result<Post>> execute({
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
      if (targetAudience != null) {
        final audienceValidation = _targetAudienceService.validateTargetAudience(
          targetAudience,
        );
        if (!audienceValidation.isValid) {
          return ResultFailure(
            ValidationFailure(
              audienceValidation.error ?? 'Invalid target audience',
            ),
          );
        }
      }

      // 6. Create post entity
      final post = Post(
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

      // 7. Save to repository
      // For now, we'll create a map and let the repository handle the conversion
      final postMap = post.toFirestoreMap();

      // Create a document reference for the new post
      final docRef = FirebaseFirestore.instance.collection('posts').doc();
      await docRef.set(postMap);

      // Update the post with the generated ID
      final savedPost = post.copyWith(id: docRef.id);

      onProgress?.call(1.0);

      return Success(savedPost);
    } catch (error, stackTrace) {
      print('CreatePostUseCase Error: $error');
      print('StackTrace: $stackTrace');

      if (error is FirebaseException) {
        return ResultFailure(
          ServerFailure(
            'Failed to create post: ${error.message}',
            code: error.code,
          ),
        );
      }

      return ResultFailure(
        UnknownFailure('Failed to create post: $error'),
      );
    }
  }

  /// Validate inputs
  ValidationFailure? _validateInputs({
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
      return ValidationFailure(
        'Validation failed',
        fieldErrors: errors,
      );
    }

    return null;
  }

  /// Process and moderate images
  Future<Result<ImageProcessingResult>> _processImages({
    required List<File> images,
    required String box,
    Function(double)? onProgress,
  }) async {
    try {
      final result = await _imageUploadService.processMultipleImages(
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

/// Extension to convert domain Post to Firestore-compatible format
extension PostToFirestore on Post {
  /// Create PostsModel-compatible map
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userid': userId,
      'content': description,
      'title': title,
      'optionA': optionA.toMap(),
      'optionB': optionB.toMap(),
      'targetAudience': targetAudience?.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': status.name,
      'likecount': likeCount,
      'commentcount': commentCount,
      'votesA': votesA,
      'votesB': votesB,
      'voteStartTime': voteStartTime,
      'voteEndTime': voteEndTime,
      'isAnonymous': isAnonymous,
      'metadata': metadata,
    };
  }
}