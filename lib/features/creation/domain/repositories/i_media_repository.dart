import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';
import '../models/entities/media_info.dart';

/// Repository interface for Media-related operations
/// This interface handles images, videos, and media encoding functionality
abstract class IMediaRepository {
  // Image queries - Clean Architecture compliant

  /// Query images with filters
  ///
  /// **Returns**: Stream of `Either<MediaRepositoryFailure, List<ImageInfo>>`
  Stream<Either<MediaRepositoryFailure, List<ImageInfo>>> queryImages({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get image count
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, int>`
  Future<Either<MediaRepositoryFailure, int>> queryImagesCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Video queries - Clean Architecture compliant

  /// Query videos with filters
  ///
  /// **Returns**: Stream of `Either<MediaRepositoryFailure, List<VideoInfo>>`
  Stream<Either<MediaRepositoryFailure, List<VideoInfo>>> queryVideos({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get video count
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, int>`
  Future<Either<MediaRepositoryFailure, int>> queryVideosCount({
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
  /// **Returns**: `Either<MediaRepositoryFailure, String>` (download URL)
  Future<Either<MediaRepositoryFailure, String>> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// Upload video to storage
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, String>` (download URL)
  Future<Either<MediaRepositoryFailure, String>> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// Delete media from storage
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> deleteMedia(String url);

  // Batch upload operations

  /// Upload multiple images
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, List<String>>` (download URLs)
  Future<Either<MediaRepositoryFailure, List<String>>> uploadImages(List<File> files);

  /// Upload multiple videos
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, List<String>>` (download URLs)
  Future<Either<MediaRepositoryFailure, List<String>>> uploadVideos(List<File> files);

  // Image operations

  /// Get image by ID
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Option<ImageInfo>>`
  Future<Either<MediaRepositoryFailure, Option<ImageInfo>>> getImage(String imageId);

  /// Create image record
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> createImage(ImageInfo image);

  /// Update image record
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> updateImage(ImageInfo image);

  /// Delete image record
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> deleteImage(String imageId);

  // Video operations

  /// Get video by ID
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Option<VideoInfo>>`
  Future<Either<MediaRepositoryFailure, Option<VideoInfo>>> getVideo(String videoId);

  /// Create video record
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> createVideo(VideoInfo video);

  /// Update video record
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> updateVideo(VideoInfo video);

  /// Delete video record
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> deleteVideo(String videoId);

  // Encoding operations - DEPRECATED: EncodingsModel removed due to Clean Architecture violation

  /// Request video encoding
  ///
  /// **Returns**: `Either<MediaRepositoryFailure, Unit>`
  Future<Either<MediaRepositoryFailure, Unit>> requestEncoding({
    required String videoId,
    required String quality,
  });

  // Future<EncodingsModel?> getEncodingStatus(String videoId);
  // Future<void> updateEncodingStatus(String videoId, EncodingsModel encoding);
}
