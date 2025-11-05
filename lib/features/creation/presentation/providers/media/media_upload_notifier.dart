import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../domain/repositories/i_media_repository.dart';
import '../../../domain/services/i_image_processing_service.dart';
import '../../../domain/failures/creation_failures.dart';
import '../states/upload_queue_state.dart';
import '../creation_providers.dart';

part 'media_upload_notifier.g.dart';

/// Media upload state management with Riverpod Notifier
/// 미디어 업로드 상태 관리 - Riverpod 3.x Migration (Phase 2-5-3)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<UploadQueueState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - StreamController management → Riverpod-managed
///
/// **Responsibilities**:
/// - Upload queue management (업로드 큐 관리)
/// - Progress tracking (진행률 추적)
/// - Error handling with retry (에러 처리 및 재시도)
/// - Parallel upload management (병렬 업로드 관리)
@riverpod
class MediaUpload extends _$MediaUpload {
  // Configuration
  static const int maxConcurrentUploads = 3;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Stream controllers for progress (managed separately from state)
  final Map<String, StreamController<double>> _progressControllers = {};

  @override
  UploadQueueState build() {
    // Initialize with empty state
    ref.onDispose(() {
      // Close all progress controllers on dispose
      for (final controller in _progressControllers.values) {
        controller.close();
      }
      _progressControllers.clear();
    });

    return const UploadQueueState();
  }

  /// Get dependencies from providers
  IMediaRepository get _mediaRepository => ref.read(mediaRepositoryProvider);
  IImageProcessingService get _imageProcessingService =>
      ref.read(imageProcessingServiceProvider);

  // ============= Getters =============
  int get queueLength => state.uploadQueue.length;
  int get activeUploadsCount => state.activeTasks.values
      .where((task) => task.status == UploadStatus.uploading)
      .length;

  // ============= Methods =============

  /// Start uploading images
  /// 이미지 업로드 시작
  Future<UploadTask> startUpload({
    required List<File> files,
    required String box,
    required String prefix,
  }) async {
    // Create upload task
    final taskId = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
    final task = UploadTask(
      id: taskId,
      box: box,
      files: files,
      createdAt: DateTime.now(),
    );

    // Add to active tasks and queue
    final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
    newActiveTasks[taskId] = task;

    final newQueue = List<UploadTask>.from(state.uploadQueue);
    newQueue.add(task);

    final newProgress = Map<String, double>.from(state.uploadProgress);
    newProgress[taskId] = 0.0;

    final newRetryCounts = Map<String, int>.from(state.retryCounts);
    newRetryCounts[taskId] = 0;

    // Create progress stream controller
    _progressControllers[taskId] = StreamController<double>.broadcast();

    // Update state
    state = state.copyWith(
      activeTasks: newActiveTasks,
      uploadQueue: newQueue,
      uploadProgress: newProgress,
      retryCounts: newRetryCounts,
    );

    // Start processing queue if not already
    if (!state.isUploading) {
      _processUploadQueue();
    }

    return task;
  }

  /// Process upload queue
  /// 업로드 큐 처리
  Future<void> _processUploadQueue() async {
    if (state.isUploading || state.uploadQueue.isEmpty) {
      return;
    }

    state = state.copyWith(isUploading: true);

    final queue = Queue<UploadTask>.from(state.uploadQueue);

    while (queue.isNotEmpty && activeUploadsCount < maxConcurrentUploads) {
      final task = queue.removeFirst();

      if (task.status == UploadStatus.cancelled) {
        continue;
      }

      // Start uploading this task
      _uploadTask(task);
    }

    // Update queue with remaining tasks
    state = state.copyWith(
      uploadQueue: queue.toList(),
      isUploading: false,
    );
  }

  /// Upload a single task
  /// 단일 태스크 업로드
  Future<void> _uploadTask(UploadTask task) async {
    try {
      // Update status
      _updateTaskStatus(task.id, UploadStatus.uploading);

      // Process images with moderation
      final processResultEither = await _imageProcessingService.processMultipleImages(
        files: task.files,
        box: task.box,
        onProgress: (progress) {
          _updateProgress(task.id, progress * 0.5); // 50% for processing
        },
      );

      // Handle processing result using fold()
      final processResult = await processResultEither.fold(
        (failure) async {
          // Processing/moderation failed
          throw failure;
        },
        (result) async {
          // Check if moderation passed
          if (result.allRejected) {
            // Build rejection reason from rejectedReasons map
            final reasons = result.rejectedReasons.entries
                .map((e) => '${e.key}: ${e.value.join(", ")}')
                .join('; ');

            // Create MediaProcessingFailure with moderation check failure
            throw MediaProcessingFailure(
              failedStep: MediaProcessingStep.moderationCheck,
              affectedFiles: task.files.map((f) => f.path).toList(),
              details: reasons.isNotEmpty ? reasons : null,
            );
          }

          return result;
        },
      );

      // Upload approved images
      final uploadedUrls = <String>[];
      final approvedFiles = processResult.approvedFiles;

      for (int i = 0; i < approvedFiles.length; i++) {
        final file = approvedFiles[i];

        try {
          // Upload single file
          final urlEither = await _mediaRepository.uploadImage(
            path: 'posts/${task.box}',
            fileName: '${task.id}_$i.jpg',
            bytes: await file.readAsBytes(),
          );

          // Handle upload result using fold()
          urlEither.fold(
            (failure) {
              debugPrint('Failed to upload file $i: ${failure.message}');
              // Continue with other files even if one fails
            },
            (url) {
              uploadedUrls.add(url);

              // Update progress
              final progress = 0.5 + (0.5 * (i + 1) / approvedFiles.length);
              _updateProgress(task.id, progress);
            },
          );
        } catch (e) {
          debugPrint('Failed to upload file $i: $e');
          // Continue with other files even if one fails
        }
      }

      if (uploadedUrls.isEmpty) {
        // Create MediaProcessingFailure with upload failure
        throw MediaProcessingFailure(
          failedStep: MediaProcessingStep.upload,
          affectedFiles: approvedFiles.map((f) => f.path).toList(),
          details: '모든 파일 업로드에 실패했습니다.',
        );
      }

      // Update task
      final updatedTask = task.copyWith(
        uploadedUrls: uploadedUrls,
        status: UploadStatus.completed,
        progress: 1.0,
      );

      final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
      newActiveTasks[task.id] = updatedTask;

      final newProgress = Map<String, double>.from(state.uploadProgress);
      newProgress[task.id] = 1.0;

      final newErrors = Map<String, UploadError>.from(state.uploadErrors);
      newErrors.remove(task.id);

      state = state.copyWith(
        activeTasks: newActiveTasks,
        uploadProgress: newProgress,
        uploadErrors: newErrors,
      );

      // Notify progress complete
      _progressControllers[task.id]?.add(1.0);

      // Process next in queue
      _processUploadQueue();
    } catch (e) {
      // Handle upload error
      _handleUploadError(task, e.toString());
    }
  }

  /// Handle upload error
  /// 업로드 에러 처리
  void _handleUploadError(UploadTask task, String errorMessage) {
    final retries = state.retryCounts[task.id] ?? 0;

    if (retries < maxRetries) {
      // Retry upload
      final newRetryCounts = Map<String, int>.from(state.retryCounts);
      newRetryCounts[task.id] = retries + 1;

      state = state.copyWith(retryCounts: newRetryCounts);

      // Add back to queue after delay
      Future.delayed(retryDelay * (retries + 1), () {
        final updatedTask = task.copyWith(status: UploadStatus.pending);
        final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
        newActiveTasks[task.id] = updatedTask;

        final newQueue = List<UploadTask>.from(state.uploadQueue);
        newQueue.insert(0, updatedTask);

        state = state.copyWith(
          activeTasks: newActiveTasks,
          uploadQueue: newQueue,
        );

        _processUploadQueue();
      });

      debugPrint('Retrying upload ${task.id}, attempt ${retries + 1}');
    } else {
      // Max retries reached
      final failedTask = task.copyWith(
        status: UploadStatus.failed,
        errorMessage: errorMessage,
      );

      final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
      newActiveTasks[task.id] = failedTask;

      final newErrors = Map<String, UploadError>.from(state.uploadErrors);
      newErrors[task.id] = UploadError(
        taskId: task.id,
        message: errorMessage,
        timestamp: DateTime.now(),
        retryCount: retries,
      );

      state = state.copyWith(
        activeTasks: newActiveTasks,
        uploadErrors: newErrors,
      );

      _progressControllers[task.id]?.addError(errorMessage);

      // Process next in queue
      _processUploadQueue();
    }
  }

  /// Update task status
  /// 태스크 상태 업데이트
  void _updateTaskStatus(String taskId, UploadStatus status) {
    final task = state.activeTasks[taskId];
    if (task != null) {
      final updatedTask = task.copyWith(status: status);
      final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
      newActiveTasks[taskId] = updatedTask;

      state = state.copyWith(activeTasks: newActiveTasks);
    }
  }

  /// Update upload progress
  /// 업로드 진행률 업데이트
  void _updateProgress(String taskId, double progress) {
    final newProgress = Map<String, double>.from(state.uploadProgress);
    newProgress[taskId] = progress;

    _progressControllers[taskId]?.add(progress);

    final task = state.activeTasks[taskId];
    if (task != null) {
      final updatedTask = task.copyWith(progress: progress);
      final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
      newActiveTasks[taskId] = updatedTask;

      state = state.copyWith(
        activeTasks: newActiveTasks,
        uploadProgress: newProgress,
      );
    } else {
      state = state.copyWith(uploadProgress: newProgress);
    }
  }

  /// Get upload progress stream
  /// 업로드 진행률 스트림 가져오기
  Stream<double> getProgressStream(String taskId) {
    if (!_progressControllers.containsKey(taskId)) {
      _progressControllers[taskId] = StreamController<double>.broadcast();
    }
    return _progressControllers[taskId]!.stream;
  }

  /// Cancel upload
  /// 업로드 취소
  void cancelUpload(String taskId) {
    final task = state.activeTasks[taskId];
    if (task != null) {
      final cancelledTask = task.copyWith(status: UploadStatus.cancelled);
      final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
      newActiveTasks[taskId] = cancelledTask;

      // Remove from queue if pending
      final newQueue = state.uploadQueue.where((t) => t.id != taskId).toList();

      state = state.copyWith(
        activeTasks: newActiveTasks,
        uploadQueue: newQueue,
      );

      // Close progress controller
      _progressControllers[taskId]?.close();
      _progressControllers.remove(taskId);
    }
  }

  /// Retry failed upload
  /// 실패한 업로드 재시도
  void retryUpload(String taskId) {
    final task = state.activeTasks[taskId];
    if (task != null && task.status == UploadStatus.failed) {
      // Reset retry count
      final newRetryCounts = Map<String, int>.from(state.retryCounts);
      newRetryCounts[taskId] = 0;

      // Clear error
      final newErrors = Map<String, UploadError>.from(state.uploadErrors);
      newErrors.remove(taskId);

      // Reset task status
      final resetTask = task.copyWith(
        status: UploadStatus.pending,
        progress: 0.0,
      );

      final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
      newActiveTasks[taskId] = resetTask;

      // Add to queue
      final newQueue = List<UploadTask>.from(state.uploadQueue);
      newQueue.add(resetTask);

      state = state.copyWith(
        activeTasks: newActiveTasks,
        uploadQueue: newQueue,
        uploadErrors: newErrors,
        retryCounts: newRetryCounts,
      );

      // Start processing
      _processUploadQueue();
    }
  }

  /// Cancel all uploads
  /// 모든 업로드 취소
  void cancelAllUploads() {
    // Cancel all active tasks
    final newActiveTasks = <String, UploadTask>{};
    for (final entry in state.activeTasks.entries) {
      newActiveTasks[entry.key] = entry.value.copyWith(status: UploadStatus.cancelled);
      _progressControllers[entry.key]?.close();
      _progressControllers.remove(entry.key);
    }

    state = state.copyWith(
      activeTasks: newActiveTasks,
      uploadQueue: [],
      isUploading: false,
    );
  }

  /// Clear completed uploads
  /// 완료된 업로드 정리
  void clearCompleted() {
    final newActiveTasks = Map<String, UploadTask>.from(state.activeTasks);
    newActiveTasks.removeWhere((_, task) =>
        task.status == UploadStatus.completed ||
        task.status == UploadStatus.cancelled);

    final newProgress = Map<String, double>.from(state.uploadProgress);
    newProgress.removeWhere((taskId, _) => !newActiveTasks.containsKey(taskId));

    state = state.copyWith(
      activeTasks: newActiveTasks,
      uploadProgress: newProgress,
    );
  }

  /// Get upload URLs for a task
  /// 태스크의 업로드된 URL 가져오기
  List<String>? getUploadedUrls(String taskId) {
    return state.activeTasks[taskId]?.uploadedUrls;
  }

  /// Check if task is complete
  /// 태스크 완료 여부 확인
  bool isTaskComplete(String taskId) {
    return state.activeTasks[taskId]?.status == UploadStatus.completed;
  }

  /// Get task status
  /// 태스크 상태 가져오기
  UploadStatus? getTaskStatus(String taskId) {
    return state.activeTasks[taskId]?.status;
  }

  /// Upload edited image from bytes (ProImageEditor용)
  /// 편집된 이미지를 Uint8List에서 직접 업로드
  ///
  /// ProImageEditor가 반환하는 Uint8List를 받아서
  /// Firebase Storage에 업로드하고 URL을 반환합니다.
  ///
  /// [imageBytes]: 편집된 이미지의 바이트 데이터
  /// [box]: 'A' 또는 'B' 박스 구분
  /// [onProgress]: 업로드 진행률 콜백 (0.0 ~ 1.0)
  ///
  /// Returns: 업로드된 이미지의 Firebase Storage URL
  Future<String> uploadEditedImage({
    required Uint8List imageBytes,
    required String box,
    Function(double)? onProgress,
  }) async {
    try {
      // 진행률 초기화
      onProgress?.call(0.0);

      // Repository를 통해 직접 업로드
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'edited_${timestamp}_$box.jpg';

      final urlEither = await _mediaRepository.uploadImage(
        path: 'posts/$box',
        fileName: fileName,
        bytes: imageBytes,
      );

      // Handle upload result using fold()
      return urlEither.fold(
        (failure) {
          debugPrint('❌ Failed to upload edited image: ${failure.message}');
          throw failure;
        },
        (url) {
          // 업로드 완료
          onProgress?.call(1.0);
          debugPrint('✅ Edited image uploaded: $url');
          return url;
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to upload edited image: $e');
      rethrow;
    }
  }

  /// Process edited image with moderation (MediaEditorWidget용)
  /// 편집된 이미지 검열 및 파일 처리 - UI 레이어에서 호출
  ///
  /// ImageUploadService를 Provider 레이어에서 위임하여
  /// UI가 Data Layer에 직접 접근하지 않도록 합니다.
  ///
  /// [editedFile]: 편집된 이미지 파일
  /// [box]: 'A' 또는 'B' 박스 구분
  /// [assetId]: AssetEntity ID (선택사항)
  /// [onProgress]: 진행률 콜백 (0.0 ~ 1.0)
  ///
  /// Returns: 처리 결과 (성공 여부, 파일, 비율, 검열 결과)
  Future<SingleImageResult> processEditedImageForUI({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    // IImageProcessingService 위임
    final resultEither = await _imageProcessingService.processEditedImage(
      editedFile: editedFile,
      box: box,
      assetId: assetId,
      onProgress: onProgress,
    );

    // Handle result using fold()
    return resultEither.fold(
      (failure) => throw failure,
      (result) => result,
    );
  }

  /// Process multiple images with moderation (MediaEditorWidget용)
  /// 멀티 이미지 검열 및 처리 - UI 레이어에서 호출
  ///
  /// IImageProcessingService를 Provider 레이어에서 위임하여
  /// UI가 Data Layer에 직접 접근하지 않도록 합니다.
  ///
  /// [files]: 선택된 파일들
  /// [box]: 'A' 또는 'B' 박스 구분
  /// [editedFile]: 편집된 파일 (선택사항)
  /// [editedFileIndex]: 편집된 파일 인덱스 (선택사항)
  /// [assetEntities]: AssetEntity 리스트 (선택사항)
  /// [onProgress]: 진행률 콜백
  /// [onModerationProgress]: 검열 진행률 콜백
  ///
  /// Returns: 처리 결과 (승인/거부된 파일, 인덱스, 비율)
  Future<ImageProcessingResult> processMultipleImagesForUI({
    required List<File> files,
    required String box,
    File? editedFile,
    int? editedFileIndex,
    List<AssetEntity>? assetEntities,
    Function(double)? onProgress,
    Function(int, int)? onModerationProgress,
  }) async {
    // IImageProcessingService 위임
    final resultEither = await _imageProcessingService.processMultipleImages(
      files: files,
      box: box,
      editedFile: editedFile,
      editedFileIndex: editedFileIndex,
      assetEntities: assetEntities,
      onProgress: onProgress,
      onModerationProgress: onModerationProgress,
    );

    // Handle result using fold()
    return resultEither.fold(
      (failure) => throw failure,
      (result) => result,
    );
  }
}
