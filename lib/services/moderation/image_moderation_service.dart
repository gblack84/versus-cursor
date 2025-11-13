import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image/image.dart' as img;
import '/services/logging/logger_service.dart';
import '/features/creation/domain/services/i_image_moderation_service.dart';

/// Image Moderation Service Implementation
///
/// Clean Architecture - Adapter pattern
/// Implements IImageModerationService interface (Port)
///
/// Responsibilities:
/// - Image content moderation via Cloud Vision API
/// - Inappropriate content detection (violence, adult, etc.)
/// - Text detection (OCR) for policy enforcement
///
/// Pattern: Port-Adapter (Hexagonal Architecture)
class ImageModerationService implements IImageModerationService {
  final FirebaseFunctions _functions;

  /// Constructor with dependency injection
  ///
  /// ✅ DI Pattern (기존 Static → Instance 변환)
  ImageModerationService({FirebaseFunctions? functions})
      : _functions = functions ??
          FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  /// Check image for inappropriate content
  ///
  /// ✅ Instance method (기존 Static method에서 변환)
  @override
  Future<ImageCheckResult> checkImage({
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

      // 디버깅용 로그
      Logger.debug(
        'Image moderation result: isAppropriate=${data['isAppropriate']}, reason=${data['reason']}, hasText=${data['hasText']}',
        tag: 'Moderation/ImageModeration',
      );

      return ImageCheckResult(
        isAppropriate: data['isAppropriate'] ?? false,
        reason: data['reason'] ?? '',
        hasText: data['hasText'] ?? false,
        details: data,
      );
    } catch (e) {
      ModerationLogger.imageError('checkImage', e);
      // 오류 시 통과로 처리 (나중에 서버에서 재검증)
      return ImageCheckResult(
        isAppropriate: true,
        reason: '',
        hasText: false,
      );
    }
  }

  /// 여러 이미지 검열
  ///
  /// ✅ Instance method (기존 Static method에서 변환)
  Future<List<ImageCheckResult>> checkMultipleImages({
    required List<File> imageFiles,
    required String box,
    Function(int current, int total)? onProgress,
  }) async {
    final results = <ImageCheckResult>[];

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
  ///
  /// ✅ Instance method (기존 Static method에서 변환)
  Future<Uint8List> _resizeImageForModeration(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('이미지 디코딩 실패');
      }

      // 검열용으로 리사이즈 (최대 800px - 텍스트 가독성 향상)
      const maxSize = 800;
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
      ModerationLogger.imageError('resizeImage', e);
      // 실패 시 원본 반환
      return await imageFile.readAsBytes();
    }
  }

  /// File에서 Uint8List로 변환
  ///
  /// ✅ Instance method (기존 Static method에서 변환)
  Future<Uint8List> fileToBytes(File file) async {
    return await file.readAsBytes();
  }
}

// ✅ ImageCheckResult 클래스는 IImageModerationService로 이동됨
// (Port Interface에 정의되어 있음)
