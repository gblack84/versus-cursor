import 'dart:io';
import 'dart:ui' as ui;
import 'package:fpdart/fpdart.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../domain/services/i_image_processing_service.dart';
import '../../domain/services/i_image_moderation_service.dart'; // ✅ Port Interface import
import '../../domain/failures/creation_failure.dart';

/// Implementation of IImageProcessingService
///
/// Clean Architecture implementation - Domain service interface implemented in Data layer
///
/// Responsibilities:
/// - Image processing with AI moderation
/// - Aspect ratio calculation
/// - Multi-image batch processing
/// - Edited image handling
///
/// ✅ DI Pattern: IImageModerationService 주입
class ImageProcessingRepositoryImpl implements IImageProcessingService {
  final IImageModerationService _moderationService; // ✅ DI 주입

  /// Constructor with dependency injection
  ///
  /// ✅ DI Pattern (기존 생성자 없음 → DI 지원 생성자 추가)
  ImageProcessingRepositoryImpl({
    required IImageModerationService moderationService,
  }) : _moderationService = moderationService;

  /// Process edited image with moderation (for multi-image edit flow)
  @override
  Future<Either<CreationFailure, SingleImageResult>> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // ✅ Instance method 호출 (기존 Static call에서 변경)
      final moderationResult = await _moderationService.checkImage(
        imageFile: editedFile,
        box: box,
      );

      onProgress?.call(0.5);

      if (!moderationResult.isAppropriate) {
        onProgress?.call(1.0);
        return right(
          SingleImageResult(
            success: false,
            rejectionReason: moderationResult.reason,
            moderationResult: moderationResult,
          ),
        );
      }

      // Calculate aspect ratio
      final aspectRatio = await _calculateAspectRatio(editedFile);

      onProgress?.call(1.0);

      return right(
        SingleImageResult(
          success: true,
          file: editedFile,
          aspectRatio: aspectRatio,
          assetId: assetId,
          moderationResult: moderationResult,
        ),
      );
    } catch (e) {
      return left(
        CreationFailure.mediaProcessingFailed(
          failedStep: MediaProcessingStep.moderationCheck,
          affectedFiles: [editedFile.path],
          details: 'Unexpected error: $e',
        ),
      );
    }
  }

  /// Process multiple images with moderation check
  @override
  Future<Either<CreationFailure, ImageProcessingResult>> processMultipleImages({
    required List<File> files,
    required String box,
    File? editedFile,
    int? editedFileIndex,
    List<AssetEntity>? assetEntities,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      final approvedFiles = <File>[];
      final approvedRatios = <double>[];
      final approvedAssetIds = <String>[];
      final rejectedIndices = <int>[];
      final rejectedReasons = <String, List<int>>{};

      // Process edited file if provided
      if (editedFile != null && editedFileIndex != null) {
        onModerationProgress?.call(1, 1);

        // ✅ Instance method 호출
        final result = await _moderationService.checkImage(
          imageFile: editedFile,
          box: box,
        );

        if (!result.isAppropriate) {
          rejectedIndices.add(editedFileIndex + 1);
          _addRejectionReason(
            rejectedReasons,
            result.reason,
            editedFileIndex + 1,
          );
        } else {
          approvedFiles.add(editedFile);
          final ratio = await _calculateAspectRatio(editedFile);
          approvedRatios.add(ratio);

          if (assetEntities != null && editedFileIndex < assetEntities.length) {
            approvedAssetIds.add(assetEntities[editedFileIndex].id);
          }
        }
      }

      // Process remaining files
      for (int i = 0; i < files.length; i++) {
        if (editedFile != null && i == editedFileIndex) {
          continue; // Skip if already processed as edited
        }

        // ✅ Instance method 호출
        final result = await _moderationService.checkImage(
          imageFile: files[i],
          box: box,
        );

        if (result.isAppropriate) {
          approvedFiles.add(files[i]);
          final ratio = await _calculateAspectRatio(files[i]);
          approvedRatios.add(ratio);

          if (assetEntities != null && i < assetEntities.length) {
            approvedAssetIds.add(assetEntities[i].id);
          }
        } else {
          rejectedIndices.add(i + 1);
          _addRejectionReason(rejectedReasons, result.reason, i + 1);
        }

        onModerationProgress?.call(i + 1, files.length);
        onProgress?.call(0.1 + (0.8 * (i + 1) / files.length));
      }

      onProgress?.call(1.0);

      return right(
        ImageProcessingResult(
          approvedFiles: approvedFiles,
          approvedRatios: approvedRatios,
          approvedAssetIds: approvedAssetIds,
          rejectedReasons: rejectedReasons,
          rejectedIndices: rejectedIndices,
          rejectedCount: rejectedIndices.length,
          allRejected: approvedFiles.isEmpty,
        ),
      );
    } catch (e) {
      return left(
        CreationFailure.mediaProcessingFailed(
          failedStep: MediaProcessingStep.moderationCheck,
          affectedFiles: files.map((f) => f.path).toList(),
          details: 'Unexpected error: $e',
        ),
      );
    }
  }

  /// Process single image with moderation
  Future<Either<CreationFailure, SingleImageResult>> processSingleImage({
    required File file,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // ✅ Instance method 호출
      final moderationResult = await _moderationService.checkImage(
        imageFile: file,
        box: box,
      );

      onProgress?.call(0.5);

      if (!moderationResult.isAppropriate) {
        onProgress?.call(1.0);
        return right(
          SingleImageResult(
            success: false,
            rejectionReason: moderationResult.reason,
            moderationResult: moderationResult,
          ),
        );
      }

      // Calculate aspect ratio
      final aspectRatio = await _calculateAspectRatio(file);

      onProgress?.call(1.0);

      return right(
        SingleImageResult(
          success: true,
          file: file,
          aspectRatio: aspectRatio,
          assetId: assetId,
          moderationResult: moderationResult,
        ),
      );
    } catch (e) {
      return left(
        CreationFailure.mediaProcessingFailed(
          failedStep: MediaProcessingStep.moderationCheck,
          affectedFiles: [file.path],
          details: 'Unexpected error: $e',
        ),
      );
    }
  }

  // ========== Private Helper Methods ==========

  /// Calculate image aspect ratio
  Future<double> _calculateAspectRatio(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final width = image.width;
      final height = image.height;
      final ratio = width / height.toDouble();

      image.dispose();

      return ratio;
    } catch (e) {
      // Return default square ratio on error
      return 1.0;
    }
  }

  /// Add rejection reason to map
  void _addRejectionReason(
    Map<String, List<int>> reasons,
    String reason,
    int index,
  ) {
    if (reasons.containsKey(reason)) {
      reasons[reason]!.add(index);
    } else {
      reasons[reason] = [index];
    }
  }
}
