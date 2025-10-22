import 'dart:io';

/// Data Transfer Object for image upload operations
/// Bundles image files with metadata for upload process
class ImageUploadDto {
  final List<File> images;
  final String box;  // 'A' or 'B' to identify which option
  final String userId;

  const ImageUploadDto({
    required this.images,
    required this.box,
    required this.userId,
  });

  /// Validates the box parameter
  bool get isValidBox => box == 'A' || box == 'B';

  /// Returns the number of images to upload
  int get imageCount => images.length;

  @override
  String toString() {
    return 'ImageUploadDto('
        'box: $box, '
        'userId: $userId, '
        'images: ${images.length} files)';
  }
}
