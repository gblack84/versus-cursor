import 'dart:io';

/// Image processing service interface for Domain layer
///
/// Abstracts image processing and moderation logic
/// to avoid direct Service dependency in UseCase
abstract class IImageProcessingService {
  /// Process multiple images with moderation
  Future<ImageProcessingResult> processMultipleImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
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
  final bool allRejected;

  const ImageProcessingResult({
    required this.approvedFiles,
    required this.approvedRatios,
    required this.approvedAssetIds,
    required this.rejectedReasons,
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

  const SingleImageResult({
    required this.success,
    this.file,
    this.aspectRatio,
    this.assetId,
    this.rejectionReason,
  });
}