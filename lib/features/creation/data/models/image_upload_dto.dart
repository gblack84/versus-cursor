import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_upload_dto.freezed.dart';

/// Data Transfer Object for image upload operations
/// Bundles image files with metadata for upload process
@freezed
sealed class ImageUploadDto with _$ImageUploadDto {
  const factory ImageUploadDto({
    required List<File> images,
    required String box, // 'A' or 'B' to identify which option
    required String userId,
  }) = _ImageUploadDto;
}

/// Extension for business logic methods
extension ImageUploadDtoX on ImageUploadDto {
  /// Validates the box parameter
  bool get isValidBox => box == 'A' || box == 'B';

  /// Returns the number of images to upload
  int get imageCount => images.length;
}
