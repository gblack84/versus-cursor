import 'dart:io';
import '../../core/result.dart';
import ../../failures/creation_failures.dart';
import '../../repositories/i_media_repository.dart';
import '../../services/i_image_processing_service.dart';

/// UseCase for uploading and processing images
///
/// This UseCase wraps the ImageUploadService to provide a clean interface
/// for the Presentation layer, following Clean Architecture principles.
class UploadImagesUseCase {
  final IMediaRepository _mediaRepository;
  final IImageProcessingService _imageProcessingService;

  UploadImagesUseCase({
    required IMediaRepository mediaRepository,
    required IImageProcessingService imageProcessingService,
  })  : _mediaRepository = mediaRepository,
        _imageProcessingService = imageProcessingService;

  /// Upload multiple images with processing and moderation
  Future<Result<UploadResult>> execute({
    required List<File> images,
    required String box,
    required String userId,
    Function(double)? onProgress,
  }) async {
    try {
      if (images.isEmpty) {
        return ResultFailure(
          ValidationFailure('No images provided'),
        );
      }

      // Step 1: Process and moderate images
      onProgress?.call(0.2);

      final processingResult = await _imageProcessingService.processMultipleImages(
        files: images,
        box: box,
        onProgress: (progress) {
          // Map processing progress to 20-60% of total
          onProgress?.call(0.2 + (progress * 0.4));
        },
      );

      if (processingResult.allRejected) {
        return ResultFailure(
          ModerationFailure(
            'All images were rejected',
            rejectedReasons: processingResult.rejectedReasons,
          ),
        );
      }

      // Step 2: Upload approved images to storage
      onProgress?.call(0.6);

      final uploadedUrls = await _mediaRepository.uploadImages(
        processingResult.approvedFiles,
      );

      onProgress?.call(0.9);

      // Step 3: Return results
      final result = UploadResult(
        uploadedUrls: uploadedUrls,
        aspectRatios: processingResult.approvedRatios,
        rejectedCount: processingResult.rejectedFiles.length,
        rejectedReasons: processingResult.rejectedReasons,
      );

      onProgress?.call(1.0);

      return Success(result);
    } catch (error, stackTrace) {
      print('UploadImagesUseCase Error: $error');
      print('StackTrace: $stackTrace');

      return ResultFailure(
        ImageUploadFailure('Failed to upload images: $error'),
      );
    }
  }

  /// Process and upload a single edited image
  Future<Result<SingleUploadResult>> uploadEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    try {
      // Process with moderation
      final processingResult = await _imageUploadService.processEditedImage(
        editedFile: editedFile,
        box: box,
        assetId: assetId,
        onProgress: (progress) {
          onProgress?.call(progress * 0.5);
        },
      );

      if (!processingResult.success || processingResult.file == null) {
        return ResultFailure(
          ModerationFailure(
            'Image was rejected',
            rejectedReasons: {
              'edited': processingResult.moderationResult?.rejectionReason ?? 'Unknown reason',
            },
          ),
        );
      }

      // Upload to storage
      onProgress?.call(0.7);

      final urls = await _mediaRepository.uploadImages([processingResult.file!]);

      if (urls.isEmpty) {
        return ResultFailure(
          ImageUploadFailure('Failed to upload edited image'),
        );
      }

      onProgress?.call(1.0);

      return Success(
        SingleUploadResult(
          uploadedUrl: urls.first,
          aspectRatio: processingResult.aspectRatio ?? 1.0,
          assetId: processingResult.assetId,
        ),
      );
    } catch (error) {
      print('UploadEditedImageUseCase Error: $error');

      return ResultFailure(
        ImageUploadFailure('Failed to upload edited image: $error'),
      );
    }
  }
}

/// Result of multiple image uploads
class UploadResult {
  final List<String> uploadedUrls;
  final List<double> aspectRatios;
  final int rejectedCount;
  final Map<String, String> rejectedReasons;

  UploadResult({
    required this.uploadedUrls,
    required this.aspectRatios,
    required this.rejectedCount,
    this.rejectedReasons = const {},
  });
}

/// Result of single image upload
class SingleUploadResult {
  final String uploadedUrl;
  final double aspectRatio;
  final String? assetId;

  SingleUploadResult({
    required this.uploadedUrl,
    required this.aspectRatio,
    this.assetId,
  });
}