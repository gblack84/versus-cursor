import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../failures/creation_failure.dart';
import '../../repositories/i_media_repository.dart';
import '../../services/i_image_processing_service.dart';
import '/services/logging/logger_service.dart';
import '/services/logging/dev_logger.dart';

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
  }) : _mediaRepository = mediaRepository,
       _imageProcessingService = imageProcessingService;

  /// Upload multiple images with processing and moderation
  ///
  /// **Phase 5 Migration**: Replaced ImageUploadDto with individual parameters
  /// - [images]: List of image files to upload
  /// - [box]: 'A' or 'B' to identify which option
  /// - [userId]: User ID for file path generation
  /// - [onProgress]: Optional progress callback (0.0 to 1.0)
  ///
  /// **Phase 6: DevLogger Type B Integration**
  /// - Entry: params() logging with image count and box
  /// - 5 checkpoints tracking upload pipeline
  /// - Validation logging for business rule failures
  /// - Final result() with upload statistics
  Future<Either<CreationFailure, UploadResult>> execute({
    required List<File> images,
    required String box,
    required String userId,
    Function(double)? onProgress,
  }) async {
    // ✅ Phase 6: DevLogger Type B (Idempotent) - Log input parameters
    DevLogger.params({
      'images_count': images.length,
      'box': box,
      'userId': userId,
    }, tag: 'UploadImages');

    try {
      // ✅ Phase 6: Checkpoint 1 - Validate inputs
      DevLogger.checkpoint('Step 1: Validate inputs', tag: 'UploadImages');

      if (images.isEmpty) {
        DevLogger.validation(
          field: 'images',
          reason: 'Empty images list',
          tag: 'UploadImages',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'images': 'No images provided'},
          ),
        );
      }

      // Validate box parameter (inline validation, moved from DTO)
      if (box != 'A' && box != 'B') {
        DevLogger.validation(
          field: 'box',
          reason: 'Invalid box parameter: $box',
          tag: 'UploadImages',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'box': 'Invalid box parameter: $box'},
          ),
        );
      }

      onProgress?.call(0.2);

      // ✅ Phase 6: Checkpoint 2 - Process images
      DevLogger.checkpoint('Step 2: Process images', tag: 'UploadImages');

      final processingEither = await _imageProcessingService
          .processMultipleImages(
            files: images,
            box: box,
            onProgress: (progress) {
              // Map processing progress to 20-60% of total
              onProgress?.call(0.2 + (progress * 0.4));
            },
          );

      // Early Return on failure
      if (processingEither.isLeft()) {
        DevLogger.error(
          'Process images failed',
          error: processingEither.fold((l) => l, (r) => null),
          tag: 'UploadImages',
        );
        return left(processingEither.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final processingResult = processingEither.getOrElse((l) => throw Exception('Unreachable'));

      // ✅ Phase 6: Checkpoint 3 - Check rejections
      DevLogger.checkpoint(
        'Step 3: Check rejections - ${processingResult.rejectedCount} rejected',
        tag: 'UploadImages',
      );

      if (processingResult.allRejected) {
        DevLogger.validation(
          field: 'images',
          reason: 'All images rejected: ${processingResult.rejectedReasons.keys.join(", ")}',
          tag: 'UploadImages',
        );
        return left(
          CreationFailure.moderationFailed(
            rejectedReasons: processingResult.rejectedReasons.keys.toList(),
          ),
        );
      }

      onProgress?.call(0.6);

      // ✅ Phase 6: Checkpoint 4 - Upload images
      DevLogger.checkpoint(
        'Step 4: Upload approved images - ${processingResult.approvedFiles.length} files',
        tag: 'UploadImages',
      );

      final uploadEither = await _mediaRepository.uploadImages(
        processingResult.approvedFiles,
      );

      // Early Return on failure
      if (uploadEither.isLeft()) {
        DevLogger.error(
          'Upload images failed',
          error: uploadEither.fold((l) => l, (r) => null),
          tag: 'UploadImages',
        );
        return left(uploadEither.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final uploadedUrls = uploadEither.getOrElse((l) => throw Exception('Unreachable'));
      onProgress?.call(0.9);

      // ✅ Phase 6: Checkpoint 5 - Create result
      DevLogger.checkpoint('Step 5: Create upload result', tag: 'UploadImages');

      final result = UploadResult(
        uploadedUrls: uploadedUrls,
        aspectRatios: processingResult.approvedRatios,
        rejectedCount: processingResult.rejectedCount,
        rejectedReasons: processingResult.rejectedReasons.map(
          (key, value) => MapEntry(key, value.join(', ')),
        ),
      );

      onProgress?.call(1.0);

      // ✅ Phase 6: Final result
      DevLogger.result(
        isSuccess: true,
        data: {
          'uploadedUrls_count': uploadedUrls.length,
          'rejectedCount': processingResult.rejectedCount,
          'aspectRatios_count': processingResult.approvedRatios.length,
        },
        tag: 'UploadImages',
      );

      return right(result);
    } catch (error, stackTrace) {
      // ✅ Phase 6: Exception logging
      DevLogger.error(
        'Image upload failed - Exception caught',
        error: error,
        stackTrace: stackTrace,
        tag: 'UploadImages',
      );

      Logger.error(
        'UploadImagesUseCase: Image upload failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'UploadImagesUseCase',
      );

      return left(CreationFailure.imageUploadFailed());
    }
  }

  /// Process and upload a single edited image
  ///
  /// **Phase 6: DevLogger Type B Integration**
  /// - Entry: params() logging with file path and assetId
  /// - 4 checkpoints tracking edited image pipeline
  /// - Validation logging for moderation failures
  /// - Final result() with upload URL
  Future<Either<CreationFailure, SingleUploadResult>> uploadEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    // ✅ Phase 6: DevLogger Type B - Log input parameters
    DevLogger.params({
      'editedFile': editedFile.path,
      'box': box,
      'assetId': assetId ?? 'null',
    }, tag: 'UploadEditedImage');

    try {
      // ✅ Phase 6: Checkpoint 1 - Process edited image
      DevLogger.checkpoint('Step 1: Process edited image', tag: 'UploadEditedImage');

      final processingEither = await _imageProcessingService.processEditedImage(
        editedFile: editedFile,
        box: box,
        assetId: assetId,
        onProgress: (progress) {
          onProgress?.call(progress * 0.5);
        },
      );

      // Early Return on failure
      if (processingEither.isLeft()) {
        DevLogger.error(
          'Process edited image failed',
          error: processingEither.fold((l) => l, (r) => null),
          tag: 'UploadEditedImage',
        );
        return left(processingEither.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final processingResult = processingEither.getOrElse((l) => throw Exception('Unreachable'));

      // ✅ Phase 6: Checkpoint 2 - Check success
      DevLogger.checkpoint('Step 2: Check moderation result', tag: 'UploadEditedImage');

      if (!processingResult.success || processingResult.file == null) {
        DevLogger.validation(
          field: 'editedImage',
          reason: processingResult.rejectionReason ?? 'Unknown moderation failure',
          tag: 'UploadEditedImage',
        );
        return left(
          CreationFailure.moderationFailed(
            rejectedReasons: [
              processingResult.rejectionReason ?? 'Unknown reason',
            ],
          ),
        );
      }

      onProgress?.call(0.7);

      // ✅ Phase 6: Checkpoint 3 - Upload to storage
      DevLogger.checkpoint('Step 3: Upload to storage', tag: 'UploadEditedImage');

      final uploadEither = await _mediaRepository.uploadImages([
        processingResult.file!,
      ]);

      // Early Return on failure
      if (uploadEither.isLeft()) {
        DevLogger.error(
          'Upload edited image failed',
          error: uploadEither.fold((l) => l, (r) => null),
          tag: 'UploadEditedImage',
        );
        return left(uploadEither.fold((l) => l, (r) => throw Exception('Unreachable')));
      }

      final urls = uploadEither.getOrElse((l) => throw Exception('Unreachable'));

      // ✅ Phase 6: Checkpoint 4 - Validate upload result
      DevLogger.checkpoint('Step 4: Validate upload result', tag: 'UploadEditedImage');

      if (urls.isEmpty) {
        DevLogger.validation(
          field: 'uploadedUrls',
          reason: 'Empty URLs after upload',
          tag: 'UploadEditedImage',
        );
        return left(CreationFailure.imageUploadFailed());
      }

      onProgress?.call(1.0);

      final result = SingleUploadResult(
        uploadedUrl: urls.first,
        aspectRatio: processingResult.aspectRatio ?? 1.0,
        assetId: processingResult.assetId,
      );

      // ✅ Phase 6: Final result
      DevLogger.result(
        isSuccess: true,
        data: {
          'uploadedUrl': urls.first,
          'aspectRatio': processingResult.aspectRatio ?? 1.0,
          'assetId': processingResult.assetId ?? 'null',
        },
        tag: 'UploadEditedImage',
      );

      return right(result);
    } catch (error, stackTrace) {
      // ✅ Phase 6: Exception logging
      DevLogger.error(
        'Edited image upload failed - Exception caught',
        error: error,
        stackTrace: stackTrace,
        tag: 'UploadEditedImage',
      );

      Logger.error(
        'UploadEditedImageUseCase: Edited image upload failed',
        error: error,
        tag: 'UploadImagesUseCase',
      );

      return left(CreationFailure.imageUploadFailed());
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
