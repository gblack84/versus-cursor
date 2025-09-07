/// Upload Image Use Case
/// 
/// Business logic for image upload operations.
/// Implements validation, moderation, and processing logic.
/// 
/// Created: 2025-09-05
/// Author: CodeSurgeon

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../models/image_upload_result.dart';
import '../models/image_upload_metadata.dart';
import '../repositories/i_image_upload_repository.dart';

/// Parameters for single image upload
@immutable
class UploadImageParams {

  const UploadImageParams({
    required this.imageBytes,
    required this.metadata,
    this.folder,
    this.enableModeration = true,
    this.generateThumbnails = true,
    this.maxSizeMB = 10.0,
    this.allowedFormats,
  });
  final Uint8List imageBytes;
  final ImageUploadMetadata metadata;
  final String? folder;
  final bool enableModeration;
  final bool generateThumbnails;
  final double maxSizeMB;
  final List<String>? allowedFormats;
}

/// Use case for uploading a single image
class UploadImageUseCase implements UseCase<ImageUploadResult, UploadImageParams> {

  UploadImageUseCase({required this.repository});
  final IImageUploadRepository repository;

  @override
  Future<Either<Failure, ImageUploadResult>> call(UploadImageParams params) async {
    try {
      // Step 1: Validate image
      final validationResult = await repository.validateImage(
        imageBytes: params.imageBytes,
        maxSizeMB: params.maxSizeMB,
        allowedFormats: params.allowedFormats,
      );

      return validationResult.fold(
        (failure) => Left(failure),
        (isValid) async {
          if (!isValid) {
            return Left(ValidationFailure('Image validation failed'));
          }

          // Step 2: Upload image
          final uploadResult = await repository.uploadImage(
            imageBytes: params.imageBytes,
            metadata: params.metadata,
            folder: params.folder,
            enableModeration: params.enableModeration,
            generateThumbnails: params.generateThumbnails,
          );

          return uploadResult;
        },
      );
    } catch (e) {
      return Left(ServerFailure('Upload failed: ${e.toString()}'));
    }
  }
}

/// Parameters for multiple image upload
@immutable
class UploadMultipleImagesParams {

  const UploadMultipleImagesParams({
    required this.images,
    this.folder,
    this.enableModeration = true,
    this.onProgress,
    this.maxSizeMB = 10.0,
    this.allowedFormats,
  });
  final List<(Uint8List, ImageUploadMetadata)> images;
  final String? folder;
  final bool enableModeration;
  final void Function(int completed, int total)? onProgress;
  final double maxSizeMB;
  final List<String>? allowedFormats;
}

/// Use case for uploading multiple images
class UploadMultipleImagesUseCase 
    implements UseCase<ImageUploadResult, UploadMultipleImagesParams> {

  UploadMultipleImagesUseCase({required this.repository});
  final IImageUploadRepository repository;

  @override
  Future<Either<Failure, ImageUploadResult>> call(
    UploadMultipleImagesParams params,
  ) async {
    try {
      // Step 1: Validate all images
      for (final (imageBytes, metadata) in params.images) {
        final validationResult = await repository.validateImage(
          imageBytes: imageBytes,
          maxSizeMB: params.maxSizeMB,
          allowedFormats: params.allowedFormats,
        );

        final isValid = validationResult.fold(
          (failure) => false,
          (valid) => valid,
        );

        if (!isValid) {
          return Left(ValidationFailure(
            'Image validation failed for: ${metadata.fileName}'
          ));
        }
      }

      // Step 2: Upload all images
      final uploadResult = await repository.uploadMultipleImages(
        images: params.images,
        folder: params.folder,
        enableModeration: params.enableModeration,
        onProgress: params.onProgress,
      );

      return uploadResult;
    } catch (e) {
      return Left(ServerFailure('Multiple upload failed: ${e.toString()}'));
    }
  }
}

/// Parameters for replacing an image
@immutable
class ReplaceImageParams {

  const ReplaceImageParams({
    required this.oldImageUrl,
    required this.newImageBytes,
    required this.metadata,
    this.deleteOldImage = true,
  });
  final String oldImageUrl;
  final Uint8List newImageBytes;
  final ImageUploadMetadata metadata;
  final bool deleteOldImage;
}

/// Use case for replacing an existing image
class ReplaceImageUseCase implements UseCase<ImageUploadResult, ReplaceImageParams> {

  ReplaceImageUseCase({required this.repository});
  final IImageUploadRepository repository;

  @override
  Future<Either<Failure, ImageUploadResult>> call(ReplaceImageParams params) async {
    try {
      // Replace the image
      final result = await repository.replaceImage(
        oldImageUrl: params.oldImageUrl,
        newImageBytes: params.newImageBytes,
        metadata: params.metadata,
      );

      // Optionally delete the old image
      if (params.deleteOldImage) {
        result.fold(
          (failure) => null, // Don't delete if replacement failed
          (success) async {
            await repository.deleteImage(
              imageUrl: params.oldImageUrl,
              deleteAllVariants: true,
            );
          },
        );
      }

      return result;
    } catch (e) {
      return Left(ServerFailure('Replace image failed: ${e.toString()}'));
    }
  }
}

/// Parameters for deleting images
@immutable
class DeleteImageParams {

  const DeleteImageParams({
    required this.imageUrls,
    this.deleteAllVariants = true,
  });
  final List<String> imageUrls;
  final bool deleteAllVariants;
}

/// Use case for deleting images
class DeleteImageUseCase implements UseCase<void, DeleteImageParams> {

  DeleteImageUseCase({required this.repository});
  final IImageUploadRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteImageParams params) async {
    try {
      if (params.imageUrls.length == 1) {
        return await repository.deleteImage(
          imageUrl: params.imageUrls.first,
          deleteAllVariants: params.deleteAllVariants,
        );
      } else {
        return await repository.deleteMultipleImages(
          imageUrls: params.imageUrls,
        );
      }
    } catch (e) {
      return Left(ServerFailure('Delete failed: ${e.toString()}'));
    }
  }
}

/// Use case for getting upload statistics
class GetUploadStatisticsUseCase 
    implements UseCase<Map<String, dynamic>, String> {

  GetUploadStatisticsUseCase({required this.repository});
  final IImageUploadRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      return await repository.getUploadStatistics(userId: userId);
    } catch (e) {
      return Left(ServerFailure('Failed to get statistics: ${e.toString()}'));
    }
  }
}

/// Use case for cleaning orphaned images
class CleanOrphanedImagesUseCase implements UseCase<int, int> {

  CleanOrphanedImagesUseCase({required this.repository});
  final IImageUploadRepository repository;

  @override
  Future<Either<Failure, int>> call(int olderThanDays) async {
    try {
      return await repository.clearOrphanedImages(
        olderThanDays: olderThanDays,
      );
    } catch (e) {
      return Left(ServerFailure('Cleanup failed: ${e.toString()}'));
    }
  }
}