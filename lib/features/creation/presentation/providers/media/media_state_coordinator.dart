import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'media_selection_provider.dart';
import 'media_upload_provider.dart';
import 'media_validation_provider.dart';

/// Media state coordinator for orchestrating between providers
/// Provider 간 조정을 위한 미디어 상태 코디네이터 - Clean Architecture Phase 5
///
/// Responsibilities:
/// - Provider coordination (Provider 간 조정)
/// - Complex workflow management (복잡한 워크플로우 관리)
/// - State synchronization (상태 동기화)
/// - Error recovery (에러 복구)
class MediaStateCoordinator {
  final MediaSelectionProvider _selectionProvider;
  final MediaUploadProvider _uploadProvider;
  final MediaValidationProvider _validationProvider;

  MediaStateCoordinator({
    required MediaSelectionProvider selectionProvider,
    required MediaUploadProvider uploadProvider,
    required MediaValidationProvider validationProvider,
  })  : _selectionProvider = selectionProvider,
        _uploadProvider = uploadProvider,
        _validationProvider = validationProvider;

  // ============= Getters for Provider Access =============
  MediaSelectionProvider get selection => _selectionProvider;
  MediaUploadProvider get upload => _uploadProvider;
  MediaValidationProvider get validation => _validationProvider;

  // ============= Integrated Workflows =============

  /// Process media selection with validation and upload
  /// 미디어 선택을 검증과 업로드와 함께 처리
  Future<MediaProcessingResult> processMediaSelection({
    required String box,
    required List<AssetEntity> assets,
    bool validateContent = true,
    bool autoUpload = false,
    Function(String status)? onStatusUpdate,
  }) async {
    try {
      // Step 1: Selection
      onStatusUpdate?.call('이미지 선택 중...');
      await _selectionProvider.selectImages(
        box: box,
        assets: assets,
      );

      final selectedFiles = box == 'A'
          ? _selectionProvider.selectedFilesA
          : _selectionProvider.selectedFilesB;

      if (selectedFiles.isEmpty) {
        return MediaProcessingResult(
          success: false,
          errorMessage: '선택된 이미지가 없습니다.',
        );
      }

      // Step 2: Validation (optional)
      if (validateContent) {
        onStatusUpdate?.call('이미지 검증 중...');

        final isValid = await _validationProvider.validateImages(
          images: selectedFiles,
          box: box,
        );

        if (!isValid) {
          final rejectionReasons = _validationProvider.parseRejectionReasons();
          return MediaProcessingResult(
            success: false,
            errorMessage: rejectionReasons.isNotEmpty
                ? rejectionReasons
                : '이미지 검증에 실패했습니다.',
          );
        }
      }

      // Step 3: Upload (optional)
      if (autoUpload) {
        onStatusUpdate?.call('이미지 업로드 중...');

        final uploadTask = await _uploadProvider.startUpload(
          files: selectedFiles,
          box: box,
          prefix: 'post_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Wait for upload completion (with timeout)
        final uploadResult = await _waitForUploadCompletion(
          taskId: uploadTask.id,
          timeoutSeconds: 60,
        );

        if (!uploadResult) {
          return MediaProcessingResult(
            success: false,
            errorMessage: '이미지 업로드에 실패했습니다.',
          );
        }

        // Update uploaded URLs in selection provider
        final uploadedUrls = _uploadProvider.getUploadedUrls(uploadTask.id);
        if (uploadedUrls != null) {
          _selectionProvider.updateUploadedUrls(
            box: box,
            urls: uploadedUrls,
          );
        }
      }

      onStatusUpdate?.call('완료!');
      return MediaProcessingResult(
        success: true,
        uploadedUrls: box == 'A'
            ? _selectionProvider.uploadedUrlsA
            : _selectionProvider.uploadedUrlsB,
      );
    } catch (e) {
      debugPrint('MediaStateCoordinator: Error in processMediaSelection: $e');
      return MediaProcessingResult(
        success: false,
        errorMessage: '처리 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// Validate and upload all media
  /// 모든 미디어 검증 및 업로드
  Future<bool> validateAndUploadAll({
    required String title,
    required String description,
    Function(String status)? onStatusUpdate,
  }) async {
    try {
      // Get current files
      final filesA = _selectionProvider.selectedFilesA;
      final filesB = _selectionProvider.selectedFilesB;

      // Validate content
      onStatusUpdate?.call('콘텐츠 검증 중...');
      final isValid = await _validationProvider.validateContent(
        title: title,
        description: description,
        imagesA: filesA,
        imagesB: filesB,
      );

      if (!isValid) {
        return false;
      }

      // Upload A box images
      if (filesA.isNotEmpty && _selectionProvider.uploadedUrlsA.isEmpty) {
        onStatusUpdate?.call('A 이미지 업로드 중...');
        final taskA = await _uploadProvider.startUpload(
          files: filesA,
          box: 'A',
          prefix: 'postA_${DateTime.now().millisecondsSinceEpoch}',
        );

        final successA = await _waitForUploadCompletion(
          taskId: taskA.id,
          timeoutSeconds: 60,
        );

        if (successA) {
          final urls = _uploadProvider.getUploadedUrls(taskA.id);
          if (urls != null) {
            _selectionProvider.updateUploadedUrls(box: 'A', urls: urls);
          }
        }
      }

      // Upload B box images
      if (filesB.isNotEmpty && _selectionProvider.uploadedUrlsB.isEmpty) {
        onStatusUpdate?.call('B 이미지 업로드 중...');
        final taskB = await _uploadProvider.startUpload(
          files: filesB,
          box: 'B',
          prefix: 'postB_${DateTime.now().millisecondsSinceEpoch}',
        );

        final successB = await _waitForUploadCompletion(
          taskId: taskB.id,
          timeoutSeconds: 60,
        );

        if (successB) {
          final urls = _uploadProvider.getUploadedUrls(taskB.id);
          if (urls != null) {
            _selectionProvider.updateUploadedUrls(box: 'B', urls: urls);
          }
        }
      }

      onStatusUpdate?.call('완료!');
      return true;
    } catch (e) {
      debugPrint('MediaStateCoordinator: Error in validateAndUploadAll: $e');
      return false;
    }
  }

  /// Get final media URLs for post creation
  /// 게시물 생성을 위한 최종 미디어 URL 가져오기
  Future<Map<String, List<String>>> getFinalMediaUrls() async {
    // If URLs are already uploaded, return them
    if (_selectionProvider.uploadedUrlsA.isNotEmpty ||
        _selectionProvider.uploadedUrlsB.isNotEmpty) {
      return {
        'A': _selectionProvider.uploadedUrlsA,
        'B': _selectionProvider.uploadedUrlsB,
      };
    }

    // Otherwise, check if there are pending uploads
    final pendingTasks = _uploadProvider.activeTasks.values
        .where((task) => task.status == UploadStatus.uploading)
        .toList();

    // Wait for pending uploads
    for (final task in pendingTasks) {
      await _waitForUploadCompletion(
        taskId: task.id,
        timeoutSeconds: 30,
      );
    }

    return {
      'A': _selectionProvider.uploadedUrlsA,
      'B': _selectionProvider.uploadedUrlsB,
    };
  }

  /// Clean up resources
  /// 리소스 정리
  void cleanupResources() {
    // Cancel all pending uploads
    _uploadProvider.cancelAllUploads();

    // Clear validation cache
    _validationProvider.clearCache();

    // Clear selections
    _selectionProvider.clearAll();
  }

  /// Clear specific box
  /// 특정 박스 초기화
  void clearBox(String box) {
    // Clear selection
    _selectionProvider.clearBox(box);

    // Clear validation for box
    _validationProvider.clearBoxValidation(box);

    // Cancel uploads for box
    final tasksToCancel = _uploadProvider.activeTasks.values
        .where((task) => task.box == box)
        .map((task) => task.id)
        .toList();

    for (final taskId in tasksToCancel) {
      _uploadProvider.cancelUpload(taskId);
    }
  }

  /// Reset all state
  /// 모든 상태 초기화
  void resetAll() {
    cleanupResources();
  }

  // ============= Private Helper Methods =============

  /// Wait for upload completion with timeout
  /// 타임아웃과 함께 업로드 완료 대기
  Future<bool> _waitForUploadCompletion({
    required String taskId,
    required int timeoutSeconds,
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed.inSeconds < timeoutSeconds) {
      final status = _uploadProvider.getTaskStatus(taskId);

      if (status == UploadStatus.completed) {
        return true;
      }

      if (status == UploadStatus.failed || status == UploadStatus.cancelled) {
        return false;
      }

      // Wait a bit before checking again
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Timeout reached
    return false;
  }

  /// Get combined validation summary
  /// 통합 검증 요약 가져오기
  Map<String, dynamic> getValidationSummary() {
    final summary = _validationProvider.getValidationSummary();

    return {
      ...summary,
      'hasMediaA': _selectionProvider.countA > 0,
      'hasMediaB': _selectionProvider.countB > 0,
      'isBoxBVisible': _selectionProvider.isBoxBVisible,
    };
  }

  /// Get upload progress for all active tasks
  /// 모든 활성 작업의 업로드 진행률 가져오기
  Map<String, double> getAllUploadProgress() {
    return Map.fromEntries(
      _uploadProvider.activeTasks.entries
          .map((entry) => MapEntry(entry.key, entry.value.progress)),
    );
  }

  /// Check if any uploads are in progress
  /// 진행 중인 업로드가 있는지 확인
  bool get hasActiveUploads {
    return _uploadProvider.activeUploadsCount > 0;
  }

  /// Check if validation is in progress
  /// 검증이 진행 중인지 확인
  bool get isValidating {
    return _validationProvider.isValidating;
  }

  /// Get current status message
  /// 현재 상태 메시지 가져오기
  String? get statusMessage {
    if (_validationProvider.isValidating) {
      return _validationProvider.validationMessage;
    }

    if (_uploadProvider.isUploading) {
      final activeCount = _uploadProvider.activeUploadsCount;
      final queueLength = _uploadProvider.queueLength;
      return '업로드 중... (활성: $activeCount, 대기: $queueLength)';
    }

    return null;
  }
}

/// Result of media processing workflow
/// 미디어 처리 워크플로우 결과
class MediaProcessingResult {
  final bool success;
  final String? errorMessage;
  final List<String>? uploadedUrls;
  final Map<String, dynamic>? metadata;

  MediaProcessingResult({
    required this.success,
    this.errorMessage,
    this.uploadedUrls,
    this.metadata,
  });
}