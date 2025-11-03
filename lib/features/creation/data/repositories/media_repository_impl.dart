import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../datasources/interfaces/i_storage_datasource.dart';
import '../../domain/models/entities/media_info.dart';
import '../models/image_result.dart';
import '../models/video_result.dart';

/// Implementation of Media Repository using Clean Architecture
///
/// This repository uses DataSource for storage operations,
/// keeping Firebase dependencies isolated.
class MediaRepositoryImpl implements IMediaRepository {
  final FirebaseFirestore _firestore;
  final IStorageDataSource _storageDataSource;

  MediaRepositoryImpl({
    FirebaseFirestore? firestore,
    required IStorageDataSource storageDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageDataSource = storageDataSource;

  // ========== Helper Methods for Conversion ==========

  /// Convert ImageResult to ImageInfo domain entity
  ImageInfo _resultToImageInfo(ImageResult result) {
    return MediaInfo.image(
      id: result.id,
      url: result.url,
      parentId: result.parentId,
      width: null,  // Result doesn't have width field
      height: null,  // Result doesn't have height field
      size: null,  // Result doesn't have size field
      mimeType: null,  // Result doesn't have mimeType field
      createdAt: null,  // Result doesn't have createdAt field
      thumbnailUrl: null,  // Result doesn't have thumbnailUrl field
      metadata: {
        'option': result.option,
      },
    );
  }

  /// Convert VideoResult to VideoInfo domain entity
  VideoInfo _resultToVideoInfo(VideoResult result) {
    return MediaInfo.video(
      id: result.id,
      url: result.url,
      parentId: result.parentId,
      width: null,  // Result doesn't have width field
      height: null,  // Result doesn't have height field
      duration: result.duration.toDouble(),
      size: null,  // Result doesn't have size field
      mimeType: null,  // Result doesn't have mimeType field
      createdAt: result.createdAt,
      thumbnailUrl: result.thumbUrl?.isNotEmpty == true ? result.thumbUrl : null,
      aspectRatio: null,
      metadata: {
        'params': result.params,
        'sourceVideoUrl': result.sourceVideoUrl,
        'ownerUid': result.ownerUid,
        'status': result.status,
      },
    );
  }

  // ========== Image Queries ==========
  @override
  Stream<List<ImageInfo>> queryImages({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  }) {
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
      return snapshot.docs
          .map((doc) => ImageResult.fromFirestore(doc.data(), doc.id))
          .map((result) => _resultToImageInfo(result))
          .toList();
    });
  }

  @override
  Future<int> queryImagesCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  }) async {
    final snapshot = await queryImages(
      parentId: parentId,
      filters: filters,
      limit: limit,
    ).first;
    return snapshot.length;
  }

  // ========== Video Queries ==========
  @override
  Stream<List<VideoInfo>> queryVideos({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  }) {
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
      return snapshot.docs
          .map((doc) => VideoResult.fromFirestore(doc.data(), doc.id))
          .map((result) => _resultToVideoInfo(result))
          .toList();
    });
  }

  @override
  Future<int> queryVideosCount({
    String? parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  }) async {
    final snapshot = await queryVideos(
      parentId: parentId,
      filters: filters,
      limit: limit,
    ).first;
    return snapshot.length;
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
  Future<String> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  }) async {
    // Create temporary file
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    try {
      // Use DataSource for upload (Firebase isolation)
      final url = await _storageDataSource.uploadImage(file, path);
      return url;
    } finally {
      // Clean up temporary file
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<String> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  }) async {
    // Create temporary file
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    try {
      // Use DataSource for upload (Firebase isolation)
      final url = await _storageDataSource.uploadImage(file, path);
      return url;
    } finally {
      // Clean up temporary file
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<void> deleteMedia(String url) async {
    // Use DataSource for deletion (Firebase isolation)
    await _storageDataSource.deleteImage(url);
  }

  @override
  Future<List<String>> uploadImages(List<File> files) async {
    // Use DataSource for batch upload (Firebase isolation)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final basePath = 'posts/images/$timestamp';
    return await _storageDataSource.uploadMultipleImages(files, basePath);
  }

  @override
  Future<List<String>> uploadVideos(List<File> files) async {
    // Use DataSource for batch upload (Firebase isolation)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final basePath = 'posts/videos/$timestamp';
    return await _storageDataSource.uploadMultipleImages(files, basePath);
  }

  // ========== CRUD Operations ==========

  @override
  Future<ImageInfo?> getImage(String imageId) async {
    final doc = await _firestore.collection('images').doc(imageId).get();
    if (!doc.exists) return null;
    final result = ImageResult.fromFirestore(doc.data()!, doc.id);
    return _resultToImageInfo(result);
  }

  @override
  Future<void> createImage(ImageInfo image) async {
    // Convert ImageInfo to map for Firestore
    final data = {
      'url': image.url,
      'parentId': image.parentId,
      'width': image.width?.toInt(),
      'height': image.height?.toInt(),
      'size': image.size,
      'mimeType': image.mimeType,
      'createdAt': image.createdAt,
      if (image.metadata != null) ...image.metadata!,
    };
    await _firestore.collection('images').add(data);
  }

  @override
  Future<void> updateImage(ImageInfo image) async {
    if (image.id.isEmpty) throw Exception('Image ID is required for update');
    final data = {
      'url': image.url,
      'parentId': image.parentId,
      'width': image.width?.toInt(),
      'height': image.height?.toInt(),
      'size': image.size,
      'mimeType': image.mimeType,
      'createdAt': image.createdAt,
      if (image.metadata != null) ...image.metadata!,
    };
    await _firestore.collection('images').doc(image.id).update(data);
  }

  @override
  Future<void> deleteImage(String imageId) async {
    await _firestore.collection('images').doc(imageId).delete();
  }

  @override
  Future<VideoInfo?> getVideo(String videoId) async {
    final doc = await _firestore.collection('videos').doc(videoId).get();
    if (!doc.exists) return null;
    final result = VideoResult.fromFirestore(doc.data()!, doc.id);
    return _resultToVideoInfo(result);
  }

  @override
  Future<void> createVideo(VideoInfo video) async {
    // Convert VideoInfo to map for Firestore
    final data = {
      'url': video.url,
      'parentId': video.parentId,
      'width': video.width?.toInt(),
      'height': video.height?.toInt(),
      'duration': video.duration?.toInt(),
      'size': video.size,
      'mimeType': video.mimeType,
      'createdAt': video.createdAt,
      if (video.metadata != null) ...video.metadata!,
    };
    await _firestore.collection('videos').add(data);
  }

  @override
  Future<void> updateVideo(VideoInfo video) async {
    if (video.id.isEmpty) throw Exception('Video ID is required for update');
    final data = {
      'url': video.url,
      'parentId': video.parentId,
      'width': video.width?.toInt(),
      'height': video.height?.toInt(),
      'duration': video.duration?.toInt(),
      'size': video.size,
      'mimeType': video.mimeType,
      'createdAt': video.createdAt,
      if (video.metadata != null) ...video.metadata!,
    };
    await _firestore.collection('videos').doc(video.id).update(data);
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    await _firestore.collection('videos').doc(videoId).delete();
  }

  @override
  Future<void> requestEncoding({
    required String videoId,
    required String quality,
  }) async {
    await _firestore.collection('encodings').add({
      'videoId': videoId,
      'quality': quality,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
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