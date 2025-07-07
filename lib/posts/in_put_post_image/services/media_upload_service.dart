import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;

class MediaUploadService {
  static const int displayMaxWidth = 800;
  static const int thumbnailSize = 150;
  static const int jpegQuality = 85;

  /// 이미지를 3가지 크기로 업로드 (original, display, thumbnail)
  static Future<Map<String, String>> uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final basePath = customPath ?? 'users/${user.uid}/posts/images';

      // 원본 이미지 디코딩
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('이미지를 디코딩할 수 없습니다.');
      }

      // 업로드 태스크들을 병렬로 실행
      final futures = <String, Future<String>>{};

      // 1. Original 업로드
      futures['original'] = _uploadToFirebase(
        imageBytes,
        '$basePath/${timestamp}_${box}_original.jpg',
        metadata: {
          'box': box,
          'type': 'original',
          'width': originalImage.width.toString(),
          'height': originalImage.height.toString(),
        },
      );

      // 2. Display 이미지 생성 및 업로드 (너비가 800px보다 큰 경우만)
      if (originalImage.width > displayMaxWidth) {
        final displayImage = img.copyResize(
          originalImage,
          width: displayMaxWidth,
          maintainAspect: true,
        );
        final displayBytes = Uint8List.fromList(
          img.encodeJpg(displayImage, quality: jpegQuality),
        );
        
        futures['display'] = _uploadToFirebase(
          displayBytes,
          '$basePath/${timestamp}_${box}_display.jpg',
          metadata: {
            'box': box,
            'type': 'display',
            'width': displayImage.width.toString(),
            'height': displayImage.height.toString(),
          },
        );
      } else {
        // 원본이 이미 작으면 display로도 사용
        futures['display'] = futures['original']!;
      }

      // 3. Thumbnail 생성 및 업로드
      final thumbnailImage = _createSquareThumbnail(originalImage, thumbnailSize);
      final thumbnailBytes = Uint8List.fromList(
        img.encodeJpg(thumbnailImage, quality: jpegQuality),
      );
      
      futures['thumbnail'] = _uploadToFirebase(
        thumbnailBytes,
        '$basePath/${timestamp}_${box}_thumb.jpg',
        metadata: {
          'box': box,
          'type': 'thumbnail',
          'width': thumbnailSize.toString(),
          'height': thumbnailSize.toString(),
        },
      );

      // 모든 업로드 완료 대기
      final results = await Future.wait([
        futures['original']!,
        futures['display']!,
        futures['thumbnail']!,
      ]);

      return {
        'original': results[0],
        'display': results[1],
        'thumbnail': results[2],
      };
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 정사각형 썸네일 생성 (중앙 크롭)
  static img.Image _createSquareThumbnail(img.Image source, int size) {
    // 먼저 짧은 쪽을 기준으로 리사이즈
    final shortSide = source.width < source.height ? source.width : source.height;
    final scale = size / shortSide;
    
    final resized = img.copyResize(
      source,
      width: (source.width * scale).round(),
      height: (source.height * scale).round(),
      maintainAspect: true,
    );

    // 중앙에서 정사각형으로 크롭
    final x = (resized.width - size) ~/ 2;
    final y = (resized.height - size) ~/ 2;
    
    return img.copyCrop(
      resized,
      x: x.clamp(0, resized.width - size),
      y: y.clamp(0, resized.height - size),
      width: size,
      height: size,
    );
  }

  /// Firebase Storage에 업로드
  static Future<String> _uploadToFirebase(
    Uint8List bytes,
    String path, {
    Map<String, String>? metadata,
  }) async {
    final ref = FirebaseStorage.instance.ref(path);
    
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      ),
    );

    await uploadTask;
    return await ref.getDownloadURL();
  }

  /// 단일 이미지 업로드 (기존 호환성 유지)
  static Future<String> uploadSingleImage({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
  }) async {
    final urls = await uploadImageWithVariants(
      imageBytes: imageBytes,
      box: box,
      customPath: customPath,
    );
    
    // display URL을 기본으로 반환
    return urls['display']!;
  }
}