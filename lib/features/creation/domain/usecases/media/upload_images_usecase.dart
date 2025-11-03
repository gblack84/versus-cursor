import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../failures/creation_failures.dart';
import '../../repositories/i_media_repository.dart';
import '../../services/i_image_processing_service.dart';
import '../../../data/models/image_upload_dto.dart';

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

  /// Upload multiple images with processing and moderation using DTO
  ///
  /// Simplified interface using ImageUploadDto to bundle parameters.
  Future<Either<Failure, UploadResult>> execute({
    required ImageUploadDto dto,
    Function(double)? onProgress,
  }) async {
    try {
      if (dto.images.isEmpty) {
        return left(
          const CreationValidationFailure('No images provided'),
        );
      }

      // Validate box parameter
      if (!dto.isValidBox) {
        return left(
          CreationValidationFailure('Invalid box parameter: ${dto.box}'),
        );
      }

      // Step 1: Process and moderate images
      onProgress?.call(0.2);

      final processingEither = await _imageProcessingService.processMultipleImages(
        files: dto.images,
        box: dto.box,
        onProgress: (progress) {
          // Map processing progress to 20-60% of total
          onProgress?.call(0.2 + (progress * 0.4));
        },
      );

      return processingEither.fold(
        (failure) => left(failure),
        (processingResult) async {
          if (processingResult.allRejected) {
            return left(
              ModerationFailure(
                'All images were rejected',
                rejectedReasons: processingResult.rejectedReasons.keys.toList(),
              ),
            );
          }

          // Step 2: Upload approved images to storage
          onProgress?.call(0.6);

          final uploadEither = await _mediaRepository.uploadImages(
            processingResult.approvedFiles,
          );

          return uploadEither.fold(
            (failure) => left(failure),
            (uploadedUrls) {
              onProgress?.call(0.9);

              // Step 3: Return results
              final result = UploadResult(
                uploadedUrls: uploadedUrls,
                aspectRatios: processingResult.approvedRatios,
                rejectedCount: processingResult.rejectedCount,
                rejectedReasons: processingResult.rejectedReasons.map(
                  (key, value) => MapEntry(key, value.join(', ')),
                ),
              );

              onProgress?.call(1.0);

              return right(result);
            },
          );
        },
      );
    } catch (error, stackTrace) {
      print('UploadImagesUseCase Error: $error');
      print('StackTrace: $stackTrace');

      return left(
        ImageUploadFailure('Failed to upload images: $error'),
      );
    }
  }

  /// Process and upload a single edited image
  Future<Either<Failure, SingleUploadResult>> uploadEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    try {
      // Process with moderation
      final processingEither = await _imageProcessingService.processEditedImage(
        editedFile: editedFile,
        box: box,
        assetId: assetId,
        onProgress: (progress) {
          onProgress?.call(progress * 0.5);
        },
      );

      return processingEither.fold(
        (failure) => left(failure),
        (processingResult) async {
          if (!processingResult.success || processingResult.file == null) {
            return left(
              ModerationFailure(
                'Image was rejected',
                rejectedReasons: [
                  processingResult.rejectionReason ?? 'Unknown reason',
                ],
              ),
            );
          }

          // Upload to storage
          onProgress?.call(0.7);

          final uploadEither = await _mediaRepository.uploadImages([processingResult.file!]);

          return uploadEither.fold(
            (failure) => left(failure),
            (urls) {
              if (urls.isEmpty) {
                return left(
                  const ImageUploadFailure('Failed to upload edited image'),
                );
              }

              onProgress?.call(1.0);

              return right(
                SingleUploadResult(
                  uploadedUrl: urls.first,
                  aspectRatio: processingResult.aspectRatio ?? 1.0,
                  assetId: processingResult.assetId,
                ),
              );
            },
          );
        },
      );
    } catch (error) {
      print('UploadEditedImageUseCase Error: $error');

      return left(
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