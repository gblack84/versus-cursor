import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/failures/creation_failures.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../datasources/interfaces/i_storage_datasource.dart';
import '../../domain/models/entities/media_info.dart';
import '../../domain/models/entities/media_info_extensions.dart';

/// Implementation of Media Repository using Clean Architecture
///
/// **Phase 5 Migration**: Extension Pattern
/// - Removed: ImageResult, VideoResult DTOs (2 files)
/// - Uses: MediaInfoFirestore Extension for direct Firestore transformation
/// - Keeps: IStorageDataSource for upload operations (Storage != Firestore)
/// - Code reduction: 744 → ~400 lines (46% reduction)
class MediaRepositoryImpl implements IMediaRepository {
  final FirebaseFirestore _firestore;
  final IStorageDataSource _storageDataSource;

  MediaRepositoryImpl({
    FirebaseFirestore? firestore,
    required IStorageDataSource storageDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageDataSource = storageDataSource;

  // ========== Image Queries ==========
  @override
  Stream<Either<MediaRepositoryFailure, List<ImageInfo>>> queryImages({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('images');

      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
      }

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.where(key, isEqualTo: value);
        });
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        try {
          final mediaInfoList = snapshot.docs
              .map((doc) {
                // Add 'type' field for MediaInfo discrimination
                final data = {...doc.data(), 'type': 'image', 'id': doc.id};
                return MediaInfoFirestore.fromFirestore(data);
              })
              .whereType<ImageInfo>() // Filter for ImageInfo only
              .toList();
          return right(mediaInfoList);
        } on FirebaseException catch (e) {
          return left(MediaRepositoryFailure(
            mediaType: 'image',
            failedPaths: [],
            message: 'Failed to query images: ${e.message}',
            code: e.code,
          ));
        } catch (e) {
          return left(MediaRepositoryFailure(
            mediaType: 'image',
            failedPaths: [],
            message: 'Unexpected error querying images: $e',
          ));
        }
      });
    } catch (e) {
      // Return a stream with an error if query setup fails
      return Stream.value(left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [],
        message: 'Failed to setup image query: $e',
      )));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, int>> queryImagesCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  }) async {
    try {
      final streamResult = queryImages(
        parentId: parentId,
        filters: filters,
        limit: limit,
      );

      final firstResult = await streamResult.first;

      return firstResult.fold(
        (failure) => left(failure),
        (images) => right(images.length),
      );
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [],
        message: 'Failed to count images: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [],
        message: 'Unexpected error counting images: $e',
      ));
    }
  }

  // ========== Video Queries ==========
  @override
  Stream<Either<MediaRepositoryFailure, List<VideoInfo>>> queryVideos({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('videos');

      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
      }

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.where(key, isEqualTo: value);
        });
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        try {
          final mediaInfoList = snapshot.docs
              .map((doc) {
                // Add 'type' field for MediaInfo discrimination
                final data = {...doc.data(), 'type': 'video', 'id': doc.id};
                return MediaInfoFirestore.fromFirestore(data);
              })
              .whereType<VideoInfo>() // Filter for VideoInfo only
              .toList();
          return right(mediaInfoList);
        } on FirebaseException catch (e) {
          return left(MediaRepositoryFailure(
            mediaType: 'video',
            failedPaths: [],
            message: 'Failed to query videos: ${e.message}',
            code: e.code,
          ));
        } catch (e) {
          return left(MediaRepositoryFailure(
            mediaType: 'video',
            failedPaths: [],
            message: 'Unexpected error querying videos: $e',
          ));
        }
      });
    } catch (e) {
      // Return a stream with an error if query setup fails
      return Stream.value(left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [],
        message: 'Failed to setup video query: $e',
      )));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, int>> queryVideosCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  }) async {
    try {
      final streamResult = queryVideos(
        parentId: parentId,
        filters: filters,
        limit: limit,
      );

      final firstResult = await streamResult.first;

      return firstResult.fold(
        (failure) => left(failure),
        (videos) => right(videos.length),
      );
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [],
        message: 'Failed to count videos: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [],
        message: 'Unexpected error counting videos: $e',
      ));
    }
  }

  // ========== Encoding Queries - DEPRECATED ==========
  // EncodingsModel removed due to Clean Architecture violation
  // These methods are commented out but kept for reference

  // @override
  // Stream<List<EncodingsModel>> queryEncodings({
  //   Map<String, dynamic>? filters,
  //   int limit = -1,
  //   bool singleRecord = false,
  // }) {
  //   Query<Map<String, dynamic>> query = _firestore.collection('encodings');
  //
  //   if (filters != null) {
  //     filters.forEach((key, value) {
  //       query = query.where(key, isEqualTo: value);
  //     });
  //   }
  //
  //   if (limit > 0) {
  //     query = query.limit(limit);
  //   }
  //
  //   return query.snapshots().map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => EncodingsModel.fromMap({...doc.data(), 'id': doc.id}))
  //         .toList();
  //   });
  // }
  //
  // @override
  // Future<int> queryEncodingsCount({
  //   Map<String, dynamic>? filters,
  //   int limit = -1,
  // }) async {
  //   final snapshot = await queryEncodings(
  //     filters: filters,
  //     limit: limit,
  //   ).first;
  //   return snapshot.length;
  // }

  // ========== Media Upload Operations (Using DataSource) ==========

  @override
  Future<Either<MediaRepositoryFailure, String>> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  }) async {
    File? tempFile;
    try {
      // Create temporary file
      final tempDir = Directory.systemTemp;
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Use DataSource for upload (Firebase isolation)
      final url = await _storageDataSource.uploadImage(tempFile, path);
      return right(url);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [path],
        message: 'Failed to upload image: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [path],
        message: 'Unexpected error uploading image: $e',
      ));
    } finally {
      // Clean up temporary file
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, String>> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  }) async {
    File? tempFile;
    try {
      // Create temporary file
      final tempDir = Directory.systemTemp;
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Use DataSource for upload (Firebase isolation)
      final url = await _storageDataSource.uploadImage(tempFile, path);
      return right(url);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [path],
        message: 'Failed to upload video: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [path],
        message: 'Unexpected error uploading video: $e',
      ));
    } finally {
      // Clean up temporary file
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> deleteMedia(String url) async {
    try {
      // Use DataSource for deletion (Firebase isolation)
      await _storageDataSource.deleteImage(url);
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'unknown',
        failedPaths: [url],
        message: 'Failed to delete media: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'unknown',
        failedPaths: [url],
        message: 'Unexpected error deleting media: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, List<String>>> uploadImages(List<File> files) async {
    try {
      // Use DataSource for batch upload (Firebase isolation)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final basePath = 'posts/images/$timestamp';
      final urls = await _storageDataSource.uploadMultipleImages(files, basePath);
      return right(urls);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: files.map((f) => f.path).toList(),
        message: 'Failed to upload images: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: files.map((f) => f.path).toList(),
        message: 'Unexpected error uploading images: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, List<String>>> uploadVideos(List<File> files) async {
    try {
      // Use DataSource for batch upload (Firebase isolation)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final basePath = 'posts/videos/$timestamp';
      final urls = await _storageDataSource.uploadMultipleImages(files, basePath);
      return right(urls);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: files.map((f) => f.path).toList(),
        message: 'Failed to upload videos: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: files.map((f) => f.path).toList(),
        message: 'Unexpected error uploading videos: $e',
      ));
    }
  }

  // ========== CRUD Operations ==========

  @override
  Future<Either<MediaRepositoryFailure, Option<ImageInfo>>> getImage(String imageId) async {
    try {
      final doc = await _firestore.collection('images').doc(imageId).get();

      if (!doc.exists) {
        return right(none());
      }

      // Add 'type' field for MediaInfo discrimination
      final data = {...doc.data()!, 'type': 'image', 'id': doc.id};
      final mediaInfo = MediaInfoFirestore.fromFirestore(data);

      // Ensure it's ImageInfo type
      if (mediaInfo is ImageInfo) {
        return right(some(mediaInfo));
      } else {
        return left(MediaRepositoryFailure(
          mediaType: 'image',
          failedPaths: [imageId],
          message: 'Document is not an image type',
        ));
      }
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [imageId],
        message: 'Failed to get image: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [imageId],
        message: 'Unexpected error getting image: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> createImage(ImageInfo image) async {
    try {
      // Use Extension pattern for Firestore conversion
      final data = image.toFirestore();
      await _firestore.collection('images').add(data);
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [image.id],
        message: 'Failed to create image: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [image.id],
        message: 'Unexpected error creating image: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> updateImage(ImageInfo image) async {
    try {
      if (image.id.isEmpty) {
        return left(MediaRepositoryFailure(
          mediaType: 'image',
          failedPaths: [image.id],
          message: 'Image ID is required for update',
          code: 'INVALID_ARGUMENT',
        ));
      }

      // Use Extension pattern for Firestore conversion
      final data = image.toFirestore();
      await _firestore.collection('images').doc(image.id).update(data);
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [image.id],
        message: 'Failed to update image: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [image.id],
        message: 'Unexpected error updating image: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> deleteImage(String imageId) async {
    try {
      await _firestore.collection('images').doc(imageId).delete();
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [imageId],
        message: 'Failed to delete image: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [imageId],
        message: 'Unexpected error deleting image: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Option<VideoInfo>>> getVideo(String videoId) async {
    try {
      final doc = await _firestore.collection('videos').doc(videoId).get();

      if (!doc.exists) {
        return right(none());
      }

      // Add 'type' field for MediaInfo discrimination
      final data = {...doc.data()!, 'type': 'video', 'id': doc.id};
      final mediaInfo = MediaInfoFirestore.fromFirestore(data);

      // Ensure it's VideoInfo type
      if (mediaInfo is VideoInfo) {
        return right(some(mediaInfo));
      } else {
        return left(MediaRepositoryFailure(
          mediaType: 'video',
          failedPaths: [videoId],
          message: 'Document is not a video type',
        ));
      }
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [videoId],
        message: 'Failed to get video: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [videoId],
        message: 'Unexpected error getting video: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> createVideo(VideoInfo video) async {
    try {
      // Use Extension pattern for Firestore conversion
      final data = video.toFirestore();
      await _firestore.collection('videos').add(data);
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [video.id],
        message: 'Failed to create video: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [video.id],
        message: 'Unexpected error creating video: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> updateVideo(VideoInfo video) async {
    try {
      if (video.id.isEmpty) {
        return left(MediaRepositoryFailure(
          mediaType: 'video',
          failedPaths: [video.id],
          message: 'Video ID is required for update',
          code: 'INVALID_ARGUMENT',
        ));
      }

      // Use Extension pattern for Firestore conversion
      final data = video.toFirestore();
      await _firestore.collection('videos').doc(video.id).update(data);
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [video.id],
        message: 'Failed to update video: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [video.id],
        message: 'Unexpected error updating video: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> deleteVideo(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).delete();
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [videoId],
        message: 'Failed to delete video: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [videoId],
        message: 'Unexpected error deleting video: $e',
      ));
    }
  }

  @override
  Future<Either<MediaRepositoryFailure, Unit>> requestEncoding({
    required String videoId,
    required String quality,
  }) async {
    try {
      await _firestore.collection('encodings').add({
        'videoId': videoId,
        'quality': quality,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [videoId],
        message: 'Failed to request encoding: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'video',
        failedPaths: [videoId],
        message: 'Unexpected error requesting encoding: $e',
      ));
    }
  }

  // Encoding status methods - DEPRECATED
  // These methods have been removed as EncodingsModel violates Clean Architecture

  // @override
  // Future<EncodingsModel?> getEncodingStatus(String videoId) async {
  //   final query = await _firestore
  //       .collection('encodings')
  //       .where('videoId', isEqualTo: videoId)
  //       .limit(1)
  //       .get();
  //
  //   if (query.docs.isEmpty) return null;
  //
  //   final doc = query.docs.first;
  //   return EncodingsModel.fromMap({...doc.data(), 'id': doc.id});
  // }
  //
  // @override
  // Future<void> updateEncodingStatus(String videoId, EncodingsModel encoding) async {
  //   final query = await _firestore
  //       .collection('encodings')
  //       .where('videoId', isEqualTo: videoId)
  //       .limit(1)
  //       .get();
  //
  //   if (query.docs.isNotEmpty) {
  //     await query.docs.first.reference.update(encoding.toMap());
  //   }
  // }
}
