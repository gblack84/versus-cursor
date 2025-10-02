import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/services/moderation/image_moderation_service.dart';

/// Image processing service interface for Domain layer
///
/// Abstracts image processing and moderation logic
/// to avoid direct Service dependency in UseCase
abstract class IImageProcessingService {
  /// Process multiple images with moderation
  Future<ImageProcessingResult> processMultipleImages({
    required List<File> files,
    required String box,
    File? editedFile,
    int? editedFileIndex,
    List<AssetEntity>? assetEntities,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
  });

  /// Process a single edited image
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  });
}

/// Result of processing multiple images
class ImageProcessingResult {
  final List<File> approvedFiles;
  final List<double> approvedRatios;
  final List<String> approvedAssetIds;
  final Map<String, List<int>> rejectedReasons;
  final List<int> rejectedIndices;
  final int rejectedCount;
  final bool allRejected;

  const ImageProcessingResult({
    required this.approvedFiles,
    required this.approvedRatios,
    required this.approvedAssetIds,
    required this.rejectedReasons,
    required this.rejectedIndices,
    required this.rejectedCount,
    required this.allRejected,
  });
}

/// Result of processing a single image
class SingleImageResult {
  final bool success;
  final File? file;
  final double? aspectRatio;
  final String? assetId;
  final String? rejectionReason;
  final ModerationResult? moderationResult;

  const SingleImageResult({
    required this.success,
    this.file,
    this.aspectRatio,
    this.assetId,
    this.rejectionReason,
    this.moderationResult,
  });
}