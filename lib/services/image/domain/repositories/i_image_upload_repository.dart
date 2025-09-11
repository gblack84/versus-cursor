/// Image Upload Repository Interface
///
/// Defines the contract for image upload operations.
/// Follows Clean Architecture repository pattern.
///
/// Created: 2025-09-05
/// Author: CodeSurgeon

import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/image_upload_result.dart';
import '../models/image_upload_metadata.dart';
import '../entities/image_metadata.dart';

/// Repository interface for image upload operations
abstract class IImageUploadRepository {
  /// Upload a single image
  ///
  /// [imageBytes] The image data to upload
  /// [metadata] Metadata associated with the upload
  /// [folder] Storage folder path (e.g., 'posts', 'profile')
  /// [enableModeration] Whether to run content moderation
  /// [generateThumbnails] Whether to generate thumbnail versions
  Future<Either<Failure, ImageUploadResult>> uploadImage({
    required Uint8List imageBytes,
    required ImageUploadMetadata metadata,
    String? folder,
    bool enableModeration = true,
    bool generateThumbnails = true,
  });

  /// Upload multiple images
  ///
  /// [images] List of image data with metadata
  /// [folder] Storage folder path
  /// [enableModeration] Whether to run content moderation
  /// [onProgress] Callback for upload progress
  Future<Either<Failure, ImageUploadResult>> uploadMultipleImages({
    required List<(Uint8List, ImageUploadMetadata)> images,
    String? folder,
    bool enableModeration = true,
    void Function(int completed, int total)? onProgress,
  });

  /// Delete an image from storage
  ///
  /// [imageUrl] The URL of the image to delete
  /// [deleteAllVariants] Whether to delete thumbnail/display variants
  Future<Either<Failure, void>> deleteImage({
    required String imageUrl,
    bool deleteAllVariants = true,
  });

  /// Delete multiple images
  ///
  /// [imageUrls] List of image URLs to delete
  Future<Either<Failure, void>> deleteMultipleImages({
    required List<String> imageUrls,
  });

  /// Get image metadata from URL
  ///
  /// [imageUrl] The image URL to get metadata for
  Future<Either<Failure, ImageMetadata>> getImageMetadata({
    required String imageUrl,
  });

  /// Replace an existing image
  ///
  /// [oldImageUrl] URL of the image to replace
  /// [newImageBytes] New image data
  /// [metadata] New image metadata
  Future<Either<Failure, ImageUploadResult>> replaceImage({
    required String oldImageUrl,
    required Uint8List newImageBytes,
    required ImageUploadMetadata metadata,
  });

  /// Check if an image exists in storage
  ///
  /// [imageUrl] The image URL to check
  Future<Either<Failure, bool>> imageExists({
    required String imageUrl,
  });

  /// Get signed/temporary URL for private images
  ///
  /// [imageUrl] The image URL
  /// [expirationMinutes] How long the URL should be valid
  Future<Either<Failure, String>> getSignedUrl({
    required String imageUrl,
    int expirationMinutes = 60,
  });

  /// Validate image before upload
  ///
  /// [imageBytes] Image data to validate
  /// [maxSizeMB] Maximum allowed size in MB
  /// [allowedFormats] List of allowed MIME types
  Future<Either<Failure, bool>> validateImage({
    required Uint8List imageBytes,
    double maxSizeMB = 10.0,
    List<String>? allowedFormats,
  });

  /// Get upload statistics for a user
  ///
  /// [userId] The user ID to get stats for
  Future<Either<Failure, Map<String, dynamic>>> getUploadStatistics({
    required String userId,
  });

  /// Clear orphaned images (images not referenced anywhere)
  ///
  /// [olderThanDays] Only clear images older than this many days
  Future<Either<Failure, int>> clearOrphanedImages({
    int olderThanDays = 30,
  });
}
