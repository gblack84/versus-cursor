import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image/image.dart' as img;

/// 이미지 검열 서비스 (Cloud Function 사용)
class ImageModerationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-northeast3',
  );

  /// 단일 이미지 검열
  static Future<ModerationResult> checkImage({
    required File imageFile,
    required String box,
  }) async {
    try {
      // 이미지를 리사이즈하여 base64로 변환
      final resizedBytes = await _resizeImageForModeration(imageFile);
      final base64Image = base64Encode(resizedBytes);

      // Cloud Function 호출
      final callable = _functions.httpsCallable('checkImageContent');
      final response = await callable.call<Map<String, dynamic>>({
        'image': base64Image,
        'box': box,
      });

      final data = response.data;
      return ModerationResult(
        isAppropriate: data['isAppropriate'] ?? false,
        reason: data['reason'] ?? '',
        hasText: data['hasText'] ?? false,
      );
    } catch (e) {
      print('[ImageModerationService] 검열 중 오류: $e');
      // 오류 시 통과로 처리 (나중에 서버에서 재검증)
      return ModerationResult(isAppropriate: true, reason: '', hasText: false);
    }
  }

  /// 여러 이미지 검열
  static Future<List<ModerationResult>> checkMultipleImages({
    required List<File> imageFiles,
    required String box,
    Function(int current, int total)? onProgress,
  }) async {
    final results = <ModerationResult>[];

    for (int i = 0; i < imageFiles.length; i++) {
      onProgress?.call(i + 1, imageFiles.length);
      
      final result = await checkImage(
        imageFile: imageFiles[i],
        box: box,
      );
      results.add(result);
    }

    return results;
  }

  /// 검열용 이미지 리사이즈 (작은 크기로 변환하여 속도 향상)
  static Future<Uint8List> _resizeImageForModeration(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('이미지 디코딩 실패');
      }

      // 검열용으로 작은 크기로 리사이즈 (최대 500px)
      const maxSize = 500;
      img.Image resized;
      
      if (image.width > maxSize || image.height > maxSize) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: maxSize);
        } else {
          resized = img.copyResize(image, height: maxSize);
        }
      } else {
        resized = image;
      }

      // JPEG로 압축 (품질 70%)
      return Uint8List.fromList(
        img.encodeJpg(resized, quality: 70),
      );
    } catch (e) {
      print('[ImageModerationService] 이미지 리사이즈 실패: $e');
      // 실패 시 원본 반환
      return await imageFile.readAsBytes();
    }
  }

  /// File에서 Uint8List로 변환
  static Future<Uint8List> fileToBytes(File file) async {
    return await file.readAsBytes();
  }
}

/// 검열 결과
class ModerationResult {
  final bool isAppropriate;
  final String reason;
  final bool hasText;

  ModerationResult({
    required this.isAppropriate,
    required this.reason,
    this.hasText = false,
  });
}