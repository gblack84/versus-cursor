import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import '/services/cloud_image_moderation_service.dart';
import '/services/storage_service.dart';
import '../utils/debug_helper.dart';
import '../constants/image_constants.dart';
import '../constants/strings.dart';
import '../constants/config.dart';

class MediaUploadService {

  /// 이미지를 3가지 크기로 업로드 (original, display, thumbnail)
  /// 반환값: URLs와 aspect ratio 정보를 포함한 Map
  static Future<Map<String, dynamic>> uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    Function(String)? onModerationStatusUpdate, // deprecated - use uploadAndWaitForModeration
    Function(String)? onRejected, // deprecated - use uploadAndWaitForModeration
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(StringConstants.userNotLoggedIn);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final basePath = customPath ?? 'users/${user.uid}/posts/images';

      // 원본 이미지 디코딩
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception(StringConstants.imageDecodeError);
      }

      // 이미지 비율 계산
      final aspectRatio = originalImage.width / originalImage.height;

      // 업로드 태스크들을 병렬로 실행
      final futures = <String, Future<String>>{};

      // 1. Original 업로드
      futures['original'] = _uploadToFirebase(
        imageBytes,
        '$basePath/${timestamp}_${box}_original.jpg',
        metadata: {
          ConfigConstants.boxMetadataKey: box,
          ConfigConstants.typeMetadataKey: ConfigConstants.originalType,
          ConfigConstants.widthMetadataKey: originalImage.width.toString(),
          ConfigConstants.heightMetadataKey: originalImage.height.toString(),
        },
      );

      // 2. Display 이미지 생성 및 업로드 (너비가 800px보다 큰 경우만)
      if (originalImage.width > ImageConstants.displayMaxWidth) {
        final displayImage = img.copyResize(
          originalImage,
          width: ImageConstants.displayMaxWidth,
          maintainAspect: true,
        );
        final displayBytes = Uint8List.fromList(
          img.encodeJpg(displayImage, quality: ImageConstants.jpegQuality),
        );
        
        futures['display'] = _uploadToFirebase(
          displayBytes,
          '$basePath/${timestamp}_${box}_display.jpg',
          metadata: {
            ConfigConstants.boxMetadataKey: box,
            ConfigConstants.typeMetadataKey: ConfigConstants.displayType,
            ConfigConstants.widthMetadataKey: displayImage.width.toString(),
            ConfigConstants.heightMetadataKey: displayImage.height.toString(),
          },
        );
      } else {
        // 원본이 이미 작으면 display로도 사용
        futures['display'] = futures['original']!;
      }

      // 3. Thumbnail 생성 및 업로드
      final thumbnailImage = _createSquareThumbnail(originalImage, ImageConstants.thumbnailSize);
      final thumbnailBytes = Uint8List.fromList(
        img.encodeJpg(thumbnailImage, quality: ImageConstants.jpegQuality),
      );
      
      futures['thumbnail'] = _uploadToFirebase(
        thumbnailBytes,
        '$basePath/${timestamp}_${box}_thumb.jpg',
        metadata: {
          ConfigConstants.boxMetadataKey: box,
          ConfigConstants.typeMetadataKey: ConfigConstants.thumbnailType,
          ConfigConstants.widthMetadataKey: ImageConstants.thumbnailSize.toString(),
          ConfigConstants.heightMetadataKey: ImageConstants.thumbnailSize.toString(),
        },
      );

      // 모든 업로드 완료 대기
      final results = await Future.wait([
        futures['original']!,
        futures['display']!,
        futures['thumbnail']!,
      ]);

      final uploadResult = {
        'urls': {
          'original': results[0],
          'display': results[1],
          'thumbnail': results[2],
        },
        'aspectRatio': aspectRatio,
        'width': originalImage.width,
        'height': originalImage.height,
        'filePath': '$basePath/${timestamp}_${box}_original.jpg',
      };
      
      // 백그라운드 검열 모니터링 제거됨 - uploadAndWaitForModeration 사용
      
      return uploadResult;
    } catch (e) {
      DebugHelper.logError('이미지 업로드 중 오류 발생', e);
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
          'uploadedBy': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
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
    final result = await uploadImageWithVariants(
      imageBytes: imageBytes,
      box: box,
      customPath: customPath,
    );
    
    // display URL을 기본으로 반환 (기존 호환성 유지)
    return result['urls']['display'];
  }
  
  /// 이미지 업로드 후 검열 결과 확인
  static Future<Map<String, dynamic>> uploadAndWaitForModeration({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // 이미지 업로드
    final uploadResult = await uploadImageWithVariants(
      imageBytes: imageBytes,
      box: box,
      customPath: customPath,
    );
    
    // 검열 결과 대기
    final filePath = uploadResult['filePath'] as String;
    final moderation = await CloudImageModerationService.waitForModeration(
      filePath,
      timeout: timeout,
    );
    
    // 검열 결과 확인
    final isApproved = CloudImageModerationService.isImageSafe(moderation);
    final isRejected = CloudImageModerationService.isImageRejected(moderation);
    
    // 거부된 경우 이미지 삭제
    if (isRejected) {
      DebugHelper.log('[MediaUpload] 부적절한 이미지 감지, 삭제 시작: $filePath');
      
      // 모든 버전 삭제
      final deleteSuccess = await StorageService.deleteAllImageVersions(filePath);
      
      if (deleteSuccess) {
        DebugHelper.log('[MediaUpload] 부적절한 이미지 삭제 완료');
      } else {
        DebugHelper.log('[MediaUpload] 부적절한 이미지 삭제 실패');
      }
      
      // URL로도 삭제 시도 (백업)
      if (!deleteSuccess) {
        final urls = uploadResult['urls'] as Map<String, String>;
        await StorageService.deleteMultipleImages(urls.values.toList());
      }
    }
    
    // 검열 결과를 포함하여 반환
    return {
      ...uploadResult,
      'moderation': moderation,
      'isApproved': isApproved,
      'isRejected': isRejected,
      'rejectionReason': moderation != null && isRejected
          ? CloudImageModerationService.getRejectionReason(moderation)
          : null,
    };
  }
}