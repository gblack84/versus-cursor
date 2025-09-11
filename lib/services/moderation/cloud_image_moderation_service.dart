import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/image_moderation_model.dart';

class CloudImageModerationService {
  static final CloudImageModerationService _instance =
      CloudImageModerationService._internal();
  factory CloudImageModerationService() => _instance;
  CloudImageModerationService._internal();

  // 이미지 파일 경로로 검열 상태 확인
  static Future<ImageModerationModel?> checkModerationStatus(
      String filePath) async {
    try {
      final moderationId = filePath.replaceAll(RegExp(r'[/.]'), '_');
      final doc = await FirebaseFirestore.instance
          .collection('imageModeration')
          .doc(moderationId)
          .get();

      if (doc.exists) {
        return ImageModerationModel.getDocumentFromData(
          doc.data()!,
          doc.reference,
        );
      }
      return null;
    } catch (e) {
      print('Error checking moderation status: $e');
      return null;
    }
  }

  // 검열 결과를 기다리는 함수 (최대 30초)
  static Future<ImageModerationModel?> waitForModeration(
    String filePath, {
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(seconds: 1),
  }) async {
    final moderationId = filePath.replaceAll(RegExp(r'[/.]'), '_');
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('imageModeration')
            .doc(moderationId)
            .get();

        if (doc.exists) {
          final record = ImageModerationModel.getDocumentFromData(
            doc.data()!,
            doc.reference,
          );

          // 검열이 완료된 경우 (pending이 아닌 경우)
          if (record.moderationStatus != 'pending') {
            return record;
          }
        }

        // 잠시 대기 후 재시도
        await Future.delayed(pollInterval);
      } catch (e) {
        print('Error waiting for moderation: $e');
      }
    }

    // 타임아웃
    return null;
  }

  // 검열 상태를 실시간으로 감시하는 스트림
  static Stream<ImageModerationModel?> watchModerationStatus(String filePath) {
    final moderationId = filePath.replaceAll(RegExp(r'[/.]'), '_');

    return FirebaseFirestore.instance
        .collection('imageModeration')
        .doc(moderationId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return ImageModerationModel.fromSnapshot(snapshot);
      }
      return null;
    });
  }

  // 이미지가 안전한지 확인
  static bool isImageSafe(ImageModerationModel? moderation) {
    if (moderation == null) return true; // 검열 결과가 없으면 일단 안전하다고 가정

    return moderation.moderationStatus == 'approved';
  }

  // 이미지가 거부되었는지 확인
  static bool isImageRejected(ImageModerationModel? moderation) {
    if (moderation == null) return false;

    return moderation.moderationStatus == 'rejected';
  }

  // 검열 중인지 확인
  static bool isModerationPending(ImageModerationModel? moderation) {
    if (moderation == null) return true; // 검열 결과가 없으면 대기 중

    return moderation.moderationStatus == 'pending';
  }

  // 에러가 발생했는지 확인
  static bool hasError(ImageModerationModel? moderation) {
    if (moderation == null) return false;

    return moderation.moderationStatus == 'error';
  }

  // SafeSearch 결과를 사람이 읽을 수 있는 형태로 변환
  static String getReadableResult(String likelihood) {
    switch (likelihood) {
      case 'VERY_UNLIKELY':
        return '매우 낮음';
      case 'UNLIKELY':
        return '낮음';
      case 'POSSIBLE':
        return '보통';
      case 'LIKELY':
        return '높음';
      case 'VERY_LIKELY':
        return '매우 높음';
      default:
        return '알 수 없음';
    }
  }

  // 거부 이유 가져오기
  static String getRejectionReason(ImageModerationModel moderation) {
    final results = moderation.safeSearchResults;
    final reasons = <String>[];

    if (results.adult == 'LIKELY' || results.adult == 'VERY_LIKELY') {
      reasons.add('성인 콘텐츠');
    }
    if (results.violence == 'LIKELY' || results.violence == 'VERY_LIKELY') {
      reasons.add('폭력적 콘텐츠');
    }
    if (results.racy == 'VERY_LIKELY') {
      reasons.add('선정적 콘텐츠');
    }

    if (reasons.isEmpty) {
      return '커뮤니티 가이드라인 위반';
    }

    return reasons.join(', ');
  }

  // Storage 경로에서 파일 경로 추출 (gs://bucket/path 형식)
  static String extractFilePathFromStorageUrl(String storageUrl) {
    if (storageUrl.startsWith('gs://')) {
      final parts = storageUrl.substring(5).split('/');
      if (parts.length > 1) {
        return parts.sublist(1).join('/');
      }
    }
    return storageUrl;
  }

  // Firebase Storage download URL에서 파일 경로 추출
  static String? extractFilePathFromDownloadUrl(String downloadUrl) {
    try {
      // 쿼리 파라미터 제거
      final urlWithoutQuery = downloadUrl.split('?').first;
      final uri = Uri.parse(urlWithoutQuery);
      final pathSegments = uri.pathSegments;

      // 일반적으로 Storage URL은 /v0/b/{bucket}/o/{encoded-path} 형식
      // pathSegments: [v0, b, {bucket}, o, {encoded-path}]
      if (pathSegments.length >= 5 && pathSegments[3] == 'o') {
        final encodedPath = pathSegments[4];
        // URL 디코딩
        final decodedPath = Uri.decodeComponent(encodedPath);
        print('[CloudImageModeration] 파일 경로 추출 성공: $decodedPath');
        return decodedPath;
      } else {
        print(
            '[CloudImageModeration] URL 형식이 예상과 다름: pathSegments=$pathSegments');
      }
    } catch (e) {
      print('Error extracting file path from URL: $e');
    }
    return null;
  }
}
