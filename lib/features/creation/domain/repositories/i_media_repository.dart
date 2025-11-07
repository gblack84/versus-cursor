import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failure.dart';
import '../entities/media_info.dart';

/// Repository interface for Media-related operations
/// This interface handles images, videos, and media encoding functionality
abstract class IMediaRepository {
  // Image queries - Clean Architecture compliant

  /// Query images with filters
  ///
  /// **Returns**: Stream of `Either<CreationFailure, List<ImageInfo>>`
  Stream<Either<CreationFailure, List<ImageInfo>>> queryImages({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get image count
  ///
  /// **Returns**: `Either<CreationFailure, int>`
  Future<Either<CreationFailure, int>> queryImagesCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Video queries - Clean Architecture compliant

  /// Query videos with filters
  ///
  /// **Returns**: Stream of `Either<CreationFailure, List<VideoInfo>>`
  Stream<Either<CreationFailure, List<VideoInfo>>> queryVideos({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get video count
  ///
  /// **Returns**: `Either<CreationFailure, int>`
  Future<Either<CreationFailure, int>> queryVideosCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Encoding queries - DEPRECATED: EncodingsModel removed due to Clean Architecture violation
  // Stream<List<EncodingsModel>> queryEncodings({
  //   Map<String, dynamic>? filters,
  //   int limit = -1,
  //   bool singleRecord = false,
  // });

  // Future<int> queryEncodingsCount({
  //   Map<String, dynamic>? filters,
  //   int limit = -1,
  // });

  // Media operations

  /// Upload image to storage
  ///
  /// **Returns**: `Either<CreationFailure, String>` (download URL)
  Future<Either<CreationFailure, String>> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// Upload video to storage
  ///
  /// **Returns**: `Either<CreationFailure, String>` (download URL)
  Future<Either<CreationFailure, String>> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// Delete media from storage
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> deleteMedia(String url);

  // Batch upload operations

  /// Upload multiple images
  ///
  /// **Returns**: `Either<CreationFailure, List<String>>` (download URLs)
  Future<Either<CreationFailure, List<String>>> uploadImages(List<File> files);

  /// Upload multiple videos
  ///
  /// **Returns**: `Either<CreationFailure, List<String>>` (download URLs)
  Future<Either<CreationFailure, List<String>>> uploadVideos(List<File> files);

  // Image operations

  /// Get image by ID
  ///
  /// **Returns**: `Either<CreationFailure, Option<ImageInfo>>`
  Future<Either<CreationFailure, Option<ImageInfo>>> getImage(String imageId);

  /// Create image record
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> createImage(ImageInfo image);

  /// Update image record
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> updateImage(ImageInfo image);

  /// Delete image record
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> deleteImage(String imageId);

  // Video operations

  /// Get video by ID
  ///
  /// **Returns**: `Either<CreationFailure, Option<VideoInfo>>`
  Future<Either<CreationFailure, Option<VideoInfo>>> getVideo(String videoId);

  /// Create video record
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> createVideo(VideoInfo video);

  /// Update video record
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> updateVideo(VideoInfo video);

  /// Delete video record
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> deleteVideo(String videoId);

  // Encoding operations - DEPRECATED: EncodingsModel removed due to Clean Architecture violation

  /// Request video encoding
  ///
  /// **Returns**: `Either<CreationFailure, Unit>`
  Future<Either<CreationFailure, Unit>> requestEncoding({
    required String videoId,
    required String quality,
  });

  // Future<EncodingsModel?> getEncodingStatus(String videoId);
  // Future<void> updateEncodingStatus(String videoId, EncodingsModel encoding);
}
