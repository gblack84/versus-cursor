import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/media/images_model.dart';
import '../../data/models/media/video_model.dart';
import '../models/encodings_model.dart';

/// Repository interface for Media-related operations
/// This interface handles images, videos, and media encoding functionality
abstract class IMediaRepository {
  // Image queries
  Stream<List<ImagesModel>> queryImages({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryImagesCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Video queries
  Stream<List<VideoModel>> queryVideos({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryVideosCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Encoding queries
  Stream<List<EncodingsModel>> queryEncodings({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryEncodingsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

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

  // Image operations
  Future<ImagesModel?> getImage(String imageId);
  Future<void> createImage(ImagesModel image);
  Future<void> updateImage(ImagesModel image);
  Future<void> deleteImage(String imageId);

  // Video operations
  Future<VideoModel?> getVideo(String videoId);
  Future<void> createVideo(VideoModel video);
  Future<void> updateVideo(VideoModel video);
  Future<void> deleteVideo(String videoId);

  // Encoding operations
  Future<void> requestEncoding({
    required String videoId,
    required String quality,
  });

  Future<EncodingsModel?> getEncodingStatus(String videoId);
  Future<void> updateEncodingStatus(String videoId, EncodingsModel encoding);
}