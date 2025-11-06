import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../failures/creation_failures.dart';
import '../../repositories/i_media_repository.dart';
import '../../services/i_image_processing_service.dart';

part 'upload_images_usecase.freezed.dart';

/// UseCase for uploading and processing images
///
/// **Phase 5 Migration**: Removed ImageUploadDto dependency
/// - Now uses individual parameters (images, box, userId)
/// - Validation logic moved inline
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
  ///
  /// **Phase 5 Migration**: Replaced ImageUploadDto with individual parameters
  /// - [images]: List of image files to upload
  /// - [box]: 'A' or 'B' to identify which option
  /// - [userId]: User ID for file path generation
  /// - [onProgress]: Optional progress callback (0.0 to 1.0)
  Future<Either<Failure, UploadResult>> execute({
    required List<File> images,
    required String box,
    required String userId,
    Function(double)? onProgress,
  }) async {
    try {
      if (images.isEmpty) {
        return left(
          const CreationValidationFailure('No images provided'),
        );
      }

      // Validate box parameter (inline validation, moved from DTO)
      if (box != 'A' && box != 'B') {
        return left(
          CreationValidationFailure('Invalid box parameter: $box'),
        );
      }

      // Step 1: Process and moderate images
      onProgress?.call(0.2);

      final processingEither = await _imageProcessingService.processMultipleImages(
        files: images,
        box: box,
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

/// Result of multiple image uploads (Freezed - Phase 2-15)
/// 여러 이미지 업로드 결과 - Freezed 불변 클래스로 변환
@freezed
sealed class UploadResult with _$UploadResult {
  const UploadResult._(); // Private constructor for custom getters

  const factory UploadResult({
    required List<String> uploadedUrls,
    required List<double> aspectRatios,
    required int rejectedCount,
    @Default({}) Map<String, String> rejectedReasons,
  }) = _UploadResult;

  /// Custom getter: Check if all uploads succeeded
  /// 모든 업로드가 성공했는지 확인하는 커스텀 getter
  bool get allSucceeded => rejectedCount == 0;

  /// Custom getter: Check if any uploads were rejected
  /// 거부된 업로드가 있는지 확인하는 커스텀 getter
  bool get hasRejections => rejectedCount > 0;
}

/// Result of single image upload (Freezed - Phase 2-15)
/// 단일 이미지 업로드 결과 - Freezed 불변 클래스로 변환
@freezed
sealed class SingleUploadResult with _$SingleUploadResult {
  const SingleUploadResult._(); // Private constructor for custom getters

  const factory SingleUploadResult({
    required String uploadedUrl,
    required double aspectRatio,
    String? assetId,
  }) = _SingleUploadResult;

  /// Custom getter: Check if asset ID is available
  /// Asset ID가 있는지 확인하는 커스텀 getter
  bool get hasAssetId => assetId != null;
}