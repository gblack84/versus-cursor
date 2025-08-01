import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > maxImageSize) {
        throw Exception('이미지 크기는 2MB를 초과할 수 없습니다.');
      }

      // Compress image
      final compressedImage = await _compressImage(imageFile);
      
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
      // Check file size
      final fileSize = await videoFile.length();
      if (fileSize > maxVideoSize) {
        throw Exception('비디오 크기는 10MB를 초과할 수 없습니다.');
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
        final thumbnailStoragePath = 'chat_media/$chatId/$messageId/$thumbnailFileName';
        
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