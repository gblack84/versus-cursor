import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import '/services/cloud_image_moderation_service.dart';
import '/backend/backend.dart';

class MediaUploadService {
  static const int displayMaxWidth = 800;
  static const int thumbnailSize = 150;
  static const int jpegQuality = 85;

  /// 이미지를 3가지 크기로 업로드 (original, display, thumbnail)
  /// 반환값: URLs와 aspect ratio 정보를 포함한 Map
  static Future<Map<String, dynamic>> uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    Function(String)? onModerationStatusUpdate,
    Function(String)? onRejected,
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

      // 이미지 비율 계산
      final aspectRatio = originalImage.width / originalImage.height;

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
      
      // 백그라운드에서 검열 상태 모니터링 시작
      if (onModerationStatusUpdate != null || onRejected != null) {
        print('[MediaUpload] 검열 모니터링 시작');
        print('[MediaUpload] filePath: ${uploadResult['filePath']}');
        print('[MediaUpload] onModerationStatusUpdate 전달됨: ${onModerationStatusUpdate != null}');
        print('[MediaUpload] onRejected 전달됨: ${onRejected != null}');
        _startModerationMonitoring(
          filePath: uploadResult['filePath'] as String,
          storageRef: FirebaseStorage.instance.ref('$basePath/${timestamp}_${box}_original.jpg'),
          onStatusUpdate: onModerationStatusUpdate,
          onRejected: onRejected,
        );
      } else {
        print('[MediaUpload] 검열 모니터링 건너뜀 (콜백 없음)');
      }
      
      return uploadResult;
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
    
    // 검열 결과를 포함하여 반환
    return {
      ...uploadResult,
      'moderation': moderation,
      'isApproved': CloudImageModerationService.isImageSafe(moderation),
      'isRejected': CloudImageModerationService.isImageRejected(moderation),
      'rejectionReason': moderation != null && CloudImageModerationService.isImageRejected(moderation)
          ? CloudImageModerationService.getRejectionReason(moderation)
          : null,
    };
  }
  
  /// 백그라운드에서 검열 상태를 모니터링하고 거부 시 자동 삭제
  static void _startModerationMonitoring({
    required String filePath,
    required Reference storageRef,
    Function(String)? onStatusUpdate,
    Function(String)? onRejected,
  }) {
    // 검열 상태를 실시간으로 감시
    CloudImageModerationService.watchModerationStatus(filePath).listen(
      (moderation) async {
        if (moderation == null) {
          onStatusUpdate?.call('pending');
          return;
        }
        
        // 상태 업데이트 콜백
        print('[MediaUpload] 검열 상태 변경: ${moderation.moderationStatus}');
        print('[MediaUpload] onStatusUpdate 콜백 존재: ${onStatusUpdate != null}');
        onStatusUpdate?.call(moderation.moderationStatus);
        
        // 거부된 경우 처리
        if (moderation.moderationStatus == 'rejected') {
          print('[MediaUpload] 이미지 거부 감지: $filePath');
          print('[MediaUpload] onRejected 콜백 존재: ${onRejected != null}');
          
          try {
            // Storage에서 이미지 삭제 (원본, display, thumbnail 모두)
            final basePath = storageRef.fullPath.replaceAll('_original.jpg', '');
            final futures = <Future>[];
            
            // 원본 삭제
            futures.add(storageRef.delete().catchError((_) {}));
            
            // display 버전 삭제
            final displayRef = FirebaseStorage.instance.ref('${basePath}_display.jpg');
            futures.add(displayRef.delete().catchError((_) {}));
            
            // thumbnail 버전 삭제
            final thumbRef = FirebaseStorage.instance.ref('${basePath}_thumb.jpg');
            futures.add(thumbRef.delete().catchError((_) {}));
            
            await Future.wait(futures);
            
            // 거부 콜백 호출
            final reason = CloudImageModerationService.getRejectionReason(moderation);
            print('[MediaUpload] 거부 이유: $reason');
            print('[MediaUpload] onRejected 콜백 호출 시작');
            onRejected?.call(reason);
            print('[MediaUpload] onRejected 콜백 호출 완료');
            
            print('거부된 이미지 삭제 완료: $filePath');
          } catch (e) {
            print('거부된 이미지 삭제 중 오류: $e');
          }
        }
      },
      onError: (error) {
        print('검열 상태 모니터링 오류: $error');
        onStatusUpdate?.call('error');
      },
    );
  }
}