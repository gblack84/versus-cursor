import 'dart:io';

/// Domain service interface for image upload operations
abstract class IImageUploadService {
  /// Upload multiple images with processing
  Future<ImageUploadResult> uploadImages({
    required List<File> images,
    required String box,
    required String userId,
    Function(double)? onProgress,
  });

  /// Upload a single image
  Future<SingleImageUploadResult> uploadSingleImage({
    required File image,
    required String box,
    required String userId,
    Function(double)? onProgress,
  });
}

/// Result of multiple image upload
class ImageUploadResult {
  final List<String> urls;
  final List<double> aspectRatios;
  final bool success;
  final String? error;

  const ImageUploadResult({
    required this.urls,
    required this.aspectRatios,
    required this.success,
    this.error,
  });
}

/// Result of single image upload
class SingleImageUploadResult {
  final String url;
  final double aspectRatio;
  final bool success;
  final String? error;

  const SingleImageUploadResult({
    required this.url,
    required this.aspectRatio,
    required this.success,
    this.error,
  });
}