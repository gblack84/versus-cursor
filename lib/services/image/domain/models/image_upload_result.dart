/// Image Upload Result Model
///
/// Domain model for image upload operation results.
/// Follows Clean Architecture principles for the Image Service.
///
/// Created: 2025-09-05
/// Author: CodeSurgeon

import 'package:flutter/foundation.dart';

/// Result of an image upload operation
@immutable
class ImageUploadResult {
  const ImageUploadResult({
    required this.success,
    this.originalUrl,
    this.displayUrl,
    this.thumbnailUrl,
    this.aspectRatio,
    this.width,
    this.height,
    this.fileSize,
    this.imageUrls,
    this.aspectRatios,
    this.assetIds,
    this.errorMessage,
    this.rejectionReason,
    this.isRejected,
    this.visionApiResults,
    this.uploadedAt,
    this.processingDurationMs,
  });

  /// Factory constructor for successful single image upload
  factory ImageUploadResult.success({
    required String originalUrl,
    required String displayUrl,
    required String thumbnailUrl,
    required double aspectRatio,
    int? width,
    int? height,
    int? fileSize,
    Map<String, dynamic>? visionApiResults,
    DateTime? uploadedAt,
    int? processingDurationMs,
  }) {
    return ImageUploadResult(
      success: true,
      originalUrl: originalUrl,
      displayUrl: displayUrl,
      thumbnailUrl: thumbnailUrl,
      aspectRatio: aspectRatio,
      width: width,
      height: height,
      fileSize: fileSize,
      visionApiResults: visionApiResults,
      uploadedAt: uploadedAt ?? DateTime.now(),
      processingDurationMs: processingDurationMs,
      isRejected: false,
    );
  }

  /// Factory constructor for successful multi-image upload
  factory ImageUploadResult.multiSuccess({
    required List<String> imageUrls,
    required List<double> aspectRatios,
    List<String>? assetIds,
    DateTime? uploadedAt,
    int? processingDurationMs,
  }) {
    return ImageUploadResult(
      success: true,
      imageUrls: imageUrls,
      aspectRatios: aspectRatios,
      assetIds: assetIds,
      uploadedAt: uploadedAt ?? DateTime.now(),
      processingDurationMs: processingDurationMs,
      isRejected: false,
    );
  }

  /// Factory constructor for upload failure
  factory ImageUploadResult.failure({
    required String errorMessage,
    String? rejectionReason,
    Map<String, dynamic>? visionApiResults,
    bool isRejected = false,
  }) {
    return ImageUploadResult(
      success: false,
      errorMessage: errorMessage,
      rejectionReason: rejectionReason,
      isRejected: isRejected,
      visionApiResults: visionApiResults,
    );
  }

  /// Factory constructor for moderation rejection
  factory ImageUploadResult.rejected({
    required String rejectionReason,
    Map<String, dynamic>? visionApiResults,
  }) {
    return ImageUploadResult(
      success: false,
      isRejected: true,
      rejectionReason: rejectionReason,
      errorMessage: 'Image rejected by moderation service',
      visionApiResults: visionApiResults,
    );
  }

  /// Whether the upload was successful
  final bool success;

  /// Original image URL (full resolution)
  final String? originalUrl;

  /// Display-optimized image URL (800px width)
  final String? displayUrl;

  /// Thumbnail image URL (150px width)
  final String? thumbnailUrl;

  /// Aspect ratio of the uploaded image
  final double? aspectRatio;

  /// Original image width in pixels
  final int? width;

  /// Original image height in pixels
  final int? height;

  /// File size in bytes
  final int? fileSize;

  /// List of all image URLs (for multi-upload scenarios)
  final List<String>? imageUrls;

  /// List of aspect ratios (for multi-upload scenarios)
  final List<double>? aspectRatios;

  /// Asset IDs from image picker (for tracking)
  final List<String>? assetIds;

  /// Error message if upload failed
  final String? errorMessage;

  /// Rejection reason from moderation service
  final String? rejectionReason;

  /// Whether the image was rejected by moderation
  final bool? isRejected;

  /// Vision API results (if moderation was performed)
  final Map<String, dynamic>? visionApiResults;

  /// Upload timestamp
  final DateTime? uploadedAt;

  /// Processing duration in milliseconds
  final int? processingDurationMs;

  /// Check if this is a multi-image result
  bool get isMultiImage => imageUrls != null && imageUrls!.isNotEmpty;

  /// Get the primary image URL (display URL preferred)
  String? get primaryUrl => displayUrl ?? originalUrl;

  /// Get all URLs in a list (for compatibility)
  List<String> get allUrls {
    if (isMultiImage) {
      return imageUrls ?? [];
    }
    if (displayUrl != null) {
      return [displayUrl!];
    }
    if (originalUrl != null) {
      return [originalUrl!];
    }
    return [];
  }

  /// Calculate file size in human-readable format
  String? get formattedFileSize {
    if (fileSize == null) return null;

    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Copy with method for immutability
  ImageUploadResult copyWith({
    bool? success,
    String? originalUrl,
    String? displayUrl,
    String? thumbnailUrl,
    double? aspectRatio,
    int? width,
    int? height,
    int? fileSize,
    List<String>? imageUrls,
    List<double>? aspectRatios,
    List<String>? assetIds,
    String? errorMessage,
    String? rejectionReason,
    bool? isRejected,
    Map<String, dynamic>? visionApiResults,
    DateTime? uploadedAt,
    int? processingDurationMs,
  }) {
    return ImageUploadResult(
      success: success ?? this.success,
      originalUrl: originalUrl ?? this.originalUrl,
      displayUrl: displayUrl ?? this.displayUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSize: fileSize ?? this.fileSize,
      imageUrls: imageUrls ?? this.imageUrls,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      assetIds: assetIds ?? this.assetIds,
      errorMessage: errorMessage ?? this.errorMessage,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isRejected: isRejected ?? this.isRejected,
      visionApiResults: visionApiResults ?? this.visionApiResults,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      processingDurationMs: processingDurationMs ?? this.processingDurationMs,
    );
  }

  @override
  String toString() {
    if (success) {
      if (isMultiImage) {
        return 'ImageUploadResult(success: true, images: ${imageUrls?.length ?? 0})';
      }
      return 'ImageUploadResult(success: true, url: $primaryUrl, ratio: $aspectRatio)';
    }
    return 'ImageUploadResult(success: false, error: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageUploadResult &&
        other.success == success &&
        other.originalUrl == originalUrl &&
        other.displayUrl == displayUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        originalUrl.hashCode ^
        displayUrl.hashCode ^
        thumbnailUrl.hashCode ^
        aspectRatio.hashCode;
  }
}
