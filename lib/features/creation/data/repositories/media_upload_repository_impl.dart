import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import '../../domain/failures/creation_failures.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../../domain/services/i_image_processing_service.dart';
import '../../domain/services/i_media_upload_service.dart';

/// Implementation of IMediaUploadService
///
/// Clean Architecture implementation - Domain service interface implemented in Data layer
///
/// Responsibilities:
/// - 3가지 크기 이미지 업로드 (original, display, thumbnail)
/// - AI 검열과 업로드 통합 처리
/// - Firebase Storage URL에서 이미지 다운로드
class MediaUploadRepositoryImpl implements IMediaUploadService {
  final IMediaRepository _mediaRepository;

  MediaUploadRepositoryImpl({
    required IMediaRepository mediaRepository,
    IImageProcessingService? imageProcessingService, // Kept for backward compatibility
  })  : _mediaRepository = mediaRepository;

  /// 이미지를 3가지 크기로 업로드 (original, display, thumbnail)
  ///
  /// Phase 5 핵심 메서드: 멀티 크기 이미지 생성 및 업로드
  ///
  /// Returns:
  /// ```dart
  /// Right({
  ///   'originalUrl': 'https://...',
  ///   'displayUrl': 'https://...',
  ///   'thumbnailUrl': 'https://...',
  ///   'aspectRatio': 1.5,
  ///   'width': 1920,
  ///   'height': 1280,
  /// })
  /// ```
  @override
  Future<Either<MediaRepositoryFailure, Map<String, dynamic>>> uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    String? sessionId,
    Function(String)? onModerationStatusUpdate,
    Function(String)? onRejected,
  }) async {
    try {
      debugPrint('📤 [MediaUploadService] Starting multi-variant upload for box: $box');

      // 1. 원본 이미지 정보 추출
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;
      final aspectRatio = width / height;

      debugPrint('  ℹ️  Original size: ${width}x$height (ratio: ${aspectRatio.toStringAsFixed(2)})');

      // 2. 3가지 크기로 리사이징
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final basePath = customPath ?? 'posts/$box';
      final baseFileName = sessionId != null ? '${sessionId}_$timestamp' : timestamp.toString();

      // Original (원본 크기)
      final originalResult = await _mediaRepository.uploadImage(
        path: basePath,
        fileName: '${baseFileName}_original.jpg',
        bytes: imageBytes,
      );

      final originalUrl = originalResult.fold(
        (failure) => throw Exception('Original upload failed: ${failure.message}'),
        (url) => url,
      );
      onModerationStatusUpdate?.call('Uploaded original image');

      // Display (800px width)
      final displayBytes = await _resizeImage(imageBytes, 800);
      final displayResult = await _mediaRepository.uploadImage(
        path: basePath,
        fileName: '${baseFileName}_display.jpg',
        bytes: displayBytes,
      );

      final displayUrl = displayResult.fold(
        (failure) => throw Exception('Display upload failed: ${failure.message}'),
        (url) => url,
      );
      onModerationStatusUpdate?.call('Uploaded display image');

      // Thumbnail (150px width)
      final thumbnailBytes = await _resizeImage(imageBytes, 150);
      final thumbnailResult = await _mediaRepository.uploadImage(
        path: basePath,
        fileName: '${baseFileName}_thumbnail.jpg',
        bytes: thumbnailBytes,
      );

      final thumbnailUrl = thumbnailResult.fold(
        (failure) => throw Exception('Thumbnail upload failed: ${failure.message}'),
        (url) => url,
      );
      onModerationStatusUpdate?.call('Uploaded thumbnail image');

      debugPrint('✅ [MediaUploadService] All variants uploaded successfully');

      return right({
        'originalUrl': originalUrl,
        'displayUrl': displayUrl,
        'thumbnailUrl': thumbnailUrl,
        'aspectRatio': aspectRatio,
        'width': width,
        'height': height,
      });
    } on FirebaseException catch (e) {
      final errorMessage = 'Failed to upload image variants: ${e.message}';
      debugPrint('❌ [MediaUploadService] Upload failed: $errorMessage');
      onRejected?.call(errorMessage);

      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [customPath ?? 'posts/$box'],
        message: errorMessage,
        code: e.code,
      ));
    } catch (e) {
      final errorMessage = 'Unexpected error during upload: $e';
      debugPrint('❌ [MediaUploadService] Upload failed: $errorMessage');
      onRejected?.call(errorMessage);

      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [customPath ?? 'posts/$box'],
        message: errorMessage,
      ));
    }
  }

  /// 멀티 이미지 업로드와 AI 검열 완료 대기
  ///
  /// Phase 5 핵심 메서드: 업로드 + 검열 통합 처리
  ///
  /// Returns:
  /// ```dart
  /// Right({
  ///   'approvedUrls': ['https://...', 'https://...'],
  ///   'rejectedIndices': [2, 3],
  ///   'rejectedReasons': {
  ///     'inappropriate': [2],
  ///     'violence': [3],
  ///   },
  /// })
  /// ```
  @override
  Future<Either<MediaRepositoryFailure, Map<String, dynamic>>> uploadAndWaitForModeration({
    required List<Uint8List> imageBytesList,
    required String box,
    String? customPath,
    String? sessionId,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      debugPrint('📤 [MediaUploadService] Starting batch upload with moderation for ${imageBytesList.length} images');

      final approvedUrls = <String>[];
      final rejectedIndices = <int>[];
      final rejectedReasons = <String, List<int>>{};
      final failedPaths = <String>[];

      for (int i = 0; i < imageBytesList.length; i++) {
        try {
          onProgress?.call(i + 1, imageBytesList.length);

          // 각 이미지를 variant로 업로드
          final result = await uploadImageWithVariants(
            imageBytes: imageBytesList[i],
            box: box,
            customPath: customPath,
            sessionId: sessionId != null ? '${sessionId}_$i' : null,
            onModerationStatusUpdate: (status) {
              debugPrint('  ⏳ Image $i: $status');
            },
            onRejected: (reason) {
              debugPrint('  ❌ Image $i rejected: $reason');
              rejectedIndices.add(i);

              // Parse rejection reason
              final category = _parseRejectionCategory(reason);
              if (!rejectedReasons.containsKey(category)) {
                rejectedReasons[category] = [];
              }
              rejectedReasons[category]!.add(i + 1); // 1-indexed for user display
            },
          );

          // Handle Either result
          result.fold(
            (failure) {
              debugPrint('  ❌ Image $i upload failed: ${failure.message}');
              rejectedIndices.add(i);
              failedPaths.addAll(failure.failedPaths);

              if (!rejectedReasons.containsKey('error')) {
                rejectedReasons['error'] = [];
              }
              rejectedReasons['error']!.add(i + 1);
            },
            (data) {
              // Display URL만 저장 (UI에서 사용)
              approvedUrls.add(data['displayUrl'] as String);
            },
          );
        } catch (e) {
          debugPrint('❌ [MediaUploadService] Image $i upload failed: $e');
          rejectedIndices.add(i);

          if (!rejectedReasons.containsKey('error')) {
            rejectedReasons['error'] = [];
          }
          rejectedReasons['error']!.add(i + 1);
        }
      }

      debugPrint('✅ [MediaUploadService] Batch upload complete: ${approvedUrls.length} approved, ${rejectedIndices.length} rejected');

      return right({
        'approvedUrls': approvedUrls,
        'rejectedIndices': rejectedIndices,
        'rejectedReasons': rejectedReasons,
        'allRejected': approvedUrls.isEmpty,
      });
    } on FirebaseException catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [customPath ?? 'posts/$box'],
        message: 'Batch upload failed: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [customPath ?? 'posts/$box'],
        message: 'Unexpected error during batch upload: $e',
      ));
    }
  }

  /// Firebase Storage URL에서 이미지 다운로드
  @override
  Future<Either<MediaRepositoryFailure, Uint8List>> downloadImageFromUrl(String url) async {
    try {
      debugPrint('⬇️  [MediaUploadService] Downloading image from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        debugPrint('✅ [MediaUploadService] Image downloaded successfully');
        return right(response.bodyBytes);
      } else {
        return left(MediaRepositoryFailure(
          mediaType: 'image',
          failedPaths: [url],
          message: 'Failed to download image: HTTP ${response.statusCode}',
          code: 'HTTP_${response.statusCode}',
        ));
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ [MediaUploadService] Download failed: ${e.message}');
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [url],
        message: 'Failed to download image: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      debugPrint('❌ [MediaUploadService] Download failed: $e');
      return left(MediaRepositoryFailure(
        mediaType: 'image',
        failedPaths: [url],
        message: 'Unexpected error during download: $e',
      ));
    }
  }

  // ============= Private Helper Methods =============

  /// 이미지 리사이징
  Future<Uint8List> _resizeImage(Uint8List imageBytes, int targetWidth) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final aspectRatio = image.width / image.height;
    final targetHeight = (targetWidth / aspectRatio).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    final resizedImage = await picture.toImage(targetWidth, targetHeight);
    final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Rejection reason 카테고리 파싱
  String _parseRejectionCategory(String reason) {
    final lowerReason = reason.toLowerCase();

    if (lowerReason.contains('inappropriate') || lowerReason.contains('선정적')) {
      return 'inappropriate';
    } else if (lowerReason.contains('violence') || lowerReason.contains('폭력')) {
      return 'violence';
    } else if (lowerReason.contains('spam') || lowerReason.contains('스팸')) {
      return 'spam';
    } else if (lowerReason.contains('hate') || lowerReason.contains('혐오')) {
      return 'hate';
    } else {
      return 'other';
    }
  }
}
