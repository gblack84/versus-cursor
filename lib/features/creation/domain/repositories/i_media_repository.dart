import 'dart:io';
import '../models/entities/media_info.dart';

/// Repository interface for Media-related operations
/// This interface handles images, videos, and media encoding functionality
abstract class IMediaRepository {
  // Image queries - Clean Architecture compliant
  Stream<List<ImageInfo>> queryImages({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryImagesCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Video queries - Clean Architecture compliant
  Stream<List<VideoInfo>> queryVideos({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryVideosCount({
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
  Future<String> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  Future<String> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  Future<void> deleteMedia(String url);

  // Batch upload operations
  Future<List<String>> uploadImages(List<File> files);
  Future<List<String>> uploadVideos(List<File> files);

  // Image operations
  Future<ImageInfo?> getImage(String imageId);
  Future<void> createImage(ImageInfo image);
  Future<void> updateImage(ImageInfo image);
  Future<void> deleteImage(String imageId);

  // Video operations
  Future<VideoInfo?> getVideo(String videoId);
  Future<void> createVideo(VideoInfo video);
  Future<void> updateVideo(VideoInfo video);
  Future<void> deleteVideo(String videoId);

  // Encoding operations - DEPRECATED: EncodingsModel removed due to Clean Architecture violation
  Future<void> requestEncoding({
    required String videoId,
    required String quality,
  });

  // Future<EncodingsModel?> getEncodingStatus(String videoId);
  // Future<void> updateEncodingStatus(String videoId, EncodingsModel encoding);
}
