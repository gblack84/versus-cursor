import 'dart:io';
import 'dart:ui' as ui;
import '/services/moderation/image_moderation_service.dart';
import '/features/creation/domain/services/i_image_processing_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Pure image upload and processing service without UI dependencies
/// UI 의존성이 없는 순수한 이미지 업로드 및 처리 서비스
class ImageUploadService implements IImageProcessingService {
  /// Process edited image with moderation (for multi-image edit flow)
  @override
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    onProgress?.call(0.1);

    // Check moderation
    final moderationResult = await ImageModerationService.checkImage(
      imageFile: editedFile,
      box: box,
    );

    onProgress?.call(0.5);

    if (!moderationResult.isAppropriate) {
      onProgress?.call(1.0);
      return SingleImageResult(
        success: false,
        rejectionReason: moderationResult.reason,
      );
    }

    // Calculate aspect ratio
    final aspectRatio = await calculateAspectRatio(editedFile);

    onProgress?.call(1.0);

    return SingleImageResult(
      success: true,
      file: editedFile,
      aspectRatio: aspectRatio,
      assetId: assetId,
    );
  }

  /// Process multiple images with moderation check
  @override
  Future<ImageProcessingResult> processMultipleImages({
    required List<File> files,
    required String box,
    File? editedFile,
    int? editedFileIndex,
    List<AssetEntity>? assetEntities,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
  }) async {
    onProgress?.call(0.1);

    final approvedFiles = <File>[];
    final approvedRatios = <double>[];
    final approvedAssetIds = <String>[];
    final rejectedIndices = <int>[];
    final rejectedReasons = <String, List<int>>{};

    // Process edited file if provided
    if (editedFile != null && editedFileIndex != null) {
      onModerationProgress?.call(1, 1);

      final result = await ImageModerationService.checkImage(
        imageFile: editedFile,
        box: box,
      );

      if (!result.isAppropriate) {
        rejectedIndices.add(editedFileIndex + 1);
        _addRejectionReason(rejectedReasons, result.reason, editedFileIndex + 1);
      } else {
        approvedFiles.add(editedFile);
        final ratio = await calculateAspectRatio(editedFile);
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

      final result = await ImageModerationService.checkImage(
        imageFile: files[i],
        box: box,
      );

      if (result.isAppropriate) {
        approvedFiles.add(files[i]);
        final ratio = await calculateAspectRatio(files[i]);
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

    return ImageProcessingResult(
      approvedFiles: approvedFiles,
      approvedRatios: approvedRatios,
      approvedAssetIds: approvedAssetIds,
      rejectedReasons: rejectedReasons,
      allRejected: approvedFiles.isEmpty,
    );
  }

  /// Process single image with moderation
  Future<SingleImageResult> processSingleImage({
    required File file,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    onProgress?.call(0.1);

    // Check moderation
    final moderationResult = await ImageModerationService.checkImage(
      imageFile: file,
      box: box,
    );

    onProgress?.call(0.5);

    if (!moderationResult.isAppropriate) {
      onProgress?.call(1.0);
      return SingleImageResult(
        success: false,
        rejectionReason: moderationResult.reason,
      );
    }

    // Calculate aspect ratio
    final aspectRatio = await calculateAspectRatio(file);

    onProgress?.call(1.0);

    return SingleImageResult(
      success: true,
      file: file,
      aspectRatio: aspectRatio,
      assetId: assetId,
    );
  }

  /// Calculate image aspect ratio
  Future<double> calculateAspectRatio(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final width = image.width;
      final height = image.height;
      final ratio = width / height.toDouble();

      image.dispose();

      print('[ImageUploadService] Calculated aspect ratio:');
      print('  - File: ${file.path}');
      print('  - Size: ${width}x${height}');
      print('  - Ratio: $ratio');

      return ratio;
    } catch (e) {
      print('[ImageUploadService] Failed to calculate aspect ratio: $e');
      return 1.0; // Default square ratio
    }
  }

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

// Types are imported from IImageProcessingService