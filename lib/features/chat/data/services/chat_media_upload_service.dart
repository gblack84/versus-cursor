import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '/core/utils/file_size_utils.dart';

class ChatMediaUploadService {
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const int maxVideoSize = 10 * 1024 * 1024; // 10MB
  static const double maxImageDimension = 1200; // Max width/height for images
  static const int compressionQuality = 85;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an image for chat message
  Future<Map<String, dynamic>> uploadChatImage({
    required String chatId,
    required String messageId,
    required File imageFile,
  }) async {
    try {
      // Compress image first (always compress before checking size)
      final compressedImage = await _compressImage(imageFile);

      // Check compressed file size using FileSizeUtils
      final fileSizeService = FileSizeUtils();
      if (compressedImage.length > maxImageSize) {
        final formattedSize = fileSizeService.formatFileSize(compressedImage.length);
        throw Exception(
          '압축 후에도 이미지 크기($formattedSize)가 2MB를 초과합니다.\n'
          '다른 이미지를 선택하거나 이미지를 편집해주세요.'
        );
      }

      // Generate storage path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'chat_image_$timestamp.jpg';
      final storagePath = 'chat_media/$chatId/$messageId/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putData(compressedImage);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Get image dimensions
      final codec = await ui.instantiateImageCodec(compressedImage);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      return {
        'url': downloadUrl,
        'size': compressedImage.length,
        'formattedSize': fileSizeService.formatFileSize(compressedImage.length),
        'width': image.width.toDouble(),
        'height': image.height.toDouble(),
        'path': storagePath,
      };
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// Upload a video for chat message
  Future<Map<String, dynamic>> uploadChatVideo({
    required String chatId,
    required String messageId,
    required File videoFile,
  }) async {
    try {
      // Check file size using FileSizeUtils
      final fileSizeService = FileSizeUtils();
      final fileSize = await videoFile.length();
      final isValidSize = await fileSizeService.checkFileSize(
        videoFile,
        maxSizeInBytes: maxVideoSize,
      );

      if (!isValidSize) {
        final formattedSize = fileSizeService.formatFileSize(fileSize);
        throw Exception(
          '비디오 크기($formattedSize)가 10MB를 초과합니다.\n'
          '비디오는 압축되지 않으므로 10MB 이하 파일만 업로드 가능합니다.'
        );
      }

      // Generate thumbnail
      final thumbnailPath = await _generateVideoThumbnail(videoFile);

      // Generate storage paths
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoFileName = 'chat_video_$timestamp.mp4';
      final videoStoragePath = 'chat_media/$chatId/$messageId/$videoFileName';

      // Upload video
      final videoRef = _storage.ref().child(videoStoragePath);
      final videoUploadTask = await videoRef.putFile(videoFile);
      final videoUrl = await videoUploadTask.ref.getDownloadURL();

      // Upload thumbnail
      String? thumbnailUrl;
      if (thumbnailPath != null) {
        final thumbnailFile = File(thumbnailPath);
        final thumbnailFileName = 'video_thumbnail_$timestamp.jpg';
        final thumbnailStoragePath =
            'chat_media/$chatId/$messageId/$thumbnailFileName';

        final thumbnailRef = _storage.ref().child(thumbnailStoragePath);
        final thumbnailUploadTask = await thumbnailRef.putFile(thumbnailFile);
        thumbnailUrl = await thumbnailUploadTask.ref.getDownloadURL();

        // Clean up temp thumbnail
        await thumbnailFile.delete();
      }

      return {
        'url': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'size': fileSize,
        'formattedSize': fileSizeService.formatFileSize(fileSize),
        'path': videoStoragePath,
      };
    } catch (e) {
      throw Exception('비디오 업로드 실패: $e');
    }
  }

  /// Compress image to reduce file size
  Future<Uint8List> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    // Compress and resize if needed
    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: maxImageDimension.toInt(),
      minWidth: maxImageDimension.toInt(),
      quality: compressionQuality,
      format: CompressFormat.jpeg,
    );

    return compressedBytes;
  }

  /// Generate thumbnail for video
  Future<String?> _generateVideoThumbnail(File videoFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 400,
        quality: 75,
      );

      return thumbnailPath;
    } catch (e) {
      print('Thumbnail generation failed: $e');
      return null;
    }
  }

  /// Delete chat media from storage
  Future<void> deleteChatMedia(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } catch (e) {
      print('Failed to delete media: $e');
    }
  }

  /// Get upload progress stream
  Stream<double> uploadWithProgress({
    required String path,
    required File file,
  }) {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);

    return uploadTask.snapshotEvents.map((snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }
}
