import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/repositories/i_media_repository.dart';
import '../../../data/services/image_upload_service.dart';

/// Upload task model
class UploadTask {
  final String id;
  final String box;
  final List<File> files;
  final DateTime createdAt;
  UploadStatus status;
  double progress;
  List<String>? uploadedUrls;
  String? errorMessage;

  UploadTask({
    required this.id,
    required this.box,
    required this.files,
    DateTime? createdAt,
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.uploadedUrls,
    this.errorMessage,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Upload status enum
enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}

/// Upload error model
class UploadError {
  final String taskId;
  final String message;
  final DateTime timestamp;
  final int? retryCount;

  UploadError({
    required this.taskId,
    required this.message,
    DateTime? timestamp,
    this.retryCount,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Media upload state management provider
/// 미디어 업로드 상태 관리 Provider - Clean Architecture Phase 5
///
/// Responsibilities:
/// - Upload queue management (업로드 큐 관리)
/// - Progress tracking (진행률 추적)
/// - Error handling with retry (에러 처리 및 재시도)
/// - Parallel upload management (병렬 업로드 관리)
class MediaUploadProvider extends ChangeNotifier {
  final IMediaRepository _mediaRepository;
  final ImageUploadService _imageUploadService;

  MediaUploadProvider({
    required IMediaRepository mediaRepository,
    required ImageUploadService imageUploadService,
  })  : _mediaRepository = mediaRepository,
        _imageUploadService = imageUploadService;

  // ============= State =============
  // Active upload tasks
  final Map<String, UploadTask> _activeTasks = {};

  // Upload progress tracking
  final Map<String, double> _uploadProgress = {};

  // Upload errors
  final Map<String, UploadError> _uploadErrors = {};

  // Upload queue
  final Queue<UploadTask> _uploadQueue = Queue();

  // Currently uploading
  bool _isUploading = false;

  // Stream controllers for progress
  final Map<String, StreamController<double>> _progressControllers = {};

  // Configuration
  static const int maxConcurrentUploads = 3;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Retry counts
  final Map<String, int> _retryCount = {};

  // ============= Getters =============
  Map<String, UploadTask> get activeTasks => Map.unmodifiable(_activeTasks);
  Map<String, double> get uploadProgress => Map.unmodifiable(_uploadProgress);
  Map<String, UploadError> get uploadErrors => Map.unmodifiable(_uploadErrors);
  bool get isUploading => _isUploading;
  int get queueLength => _uploadQueue.length;
  int get activeUploadsCount => _activeTasks.values
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
    );

    // Add to active tasks
    _activeTasks[taskId] = task;
    _uploadQueue.add(task);

    // Initialize progress
    _uploadProgress[taskId] = 0.0;
    _retryCount[taskId] = 0;

    // Create progress stream controller
    _progressControllers[taskId] = StreamController<double>.broadcast();

    notifyListeners();

    // Start processing queue if not already
    if (!_isUploading) {
      _processUploadQueue();
    }

    return task;
  }

  /// Process upload queue
  /// 업로드 큐 처리
  Future<void> _processUploadQueue() async {
    if (_isUploading || _uploadQueue.isEmpty) {
      return;
    }

    _isUploading = true;
    notifyListeners();

    while (_uploadQueue.isNotEmpty && activeUploadsCount < maxConcurrentUploads) {
      final task = _uploadQueue.removeFirst();

      if (task.status == UploadStatus.cancelled) {
        continue;
      }

      // Start uploading this task
      _uploadTask(task);
    }

    _isUploading = false;
    notifyListeners();
  }

  /// Upload a single task
  /// 단일 태스크 업로드
  Future<void> _uploadTask(UploadTask task) async {
    try {
      // Update status
      task.status = UploadStatus.uploading;
      notifyListeners();

      // Process images with moderation
      final processResult = await _imageUploadService.processMultipleImages(
        files: task.files,
        box: task.box,
        onProgress: (progress) {
          _updateProgress(task.id, progress * 0.5); // 50% for processing
        },
      );

      // Check if moderation passed
      if (processResult.allRejected) {
        // Build rejection reason from rejectedReasons map
        final reasons = processResult.rejectedReasons.entries
            .map((e) => '${e.key}: ${e.value.join(", ")}')
            .join('; ');
        throw Exception(reasons.isNotEmpty ? reasons : '이미지 검증에 실패했습니다.');
      }

      // Upload approved images
      final uploadedUrls = <String>[];
      final approvedFiles = processResult.approvedFiles;

      for (int i = 0; i < approvedFiles.length; i++) {
        final file = approvedFiles[i];

        try {
          // Upload single file
          final url = await _mediaRepository.uploadImage(
            path: 'posts/${task.box}',
            fileName: '${task.id}_$i.jpg',
            bytes: await file.readAsBytes(),
          );

          uploadedUrls.add(url);

          // Update progress
          final progress = 0.5 + (0.5 * (i + 1) / approvedFiles.length);
          _updateProgress(task.id, progress);
        } catch (e) {
          debugPrint('Failed to upload file $i: $e');
          // Continue with other files even if one fails
        }
      }

      if (uploadedUrls.isEmpty) {
        throw Exception('모든 파일 업로드에 실패했습니다.');
      }

      // Update task
      task.uploadedUrls = uploadedUrls;
      task.status = UploadStatus.completed;
      task.progress = 1.0;
      _uploadProgress[task.id] = 1.0;

      // Clear error if any
      _uploadErrors.remove(task.id);

      // Notify progress complete
      _progressControllers[task.id]?.add(1.0);

      notifyListeners();

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
    final retries = _retryCount[task.id] ?? 0;

    if (retries < maxRetries) {
      // Retry upload
      _retryCount[task.id] = retries + 1;

      // Add back to queue after delay
      Future.delayed(retryDelay * (retries + 1), () {
        task.status = UploadStatus.pending;
        _uploadQueue.addFirst(task);
        _processUploadQueue();
      });

      debugPrint('Retrying upload ${task.id}, attempt ${retries + 1}');
    } else {
      // Max retries reached
      task.status = UploadStatus.failed;
      task.errorMessage = errorMessage;

      _uploadErrors[task.id] = UploadError(
        taskId: task.id,
        message: errorMessage,
        retryCount: retries,
      );

      _progressControllers[task.id]?.addError(errorMessage);

      notifyListeners();

      // Process next in queue
      _processUploadQueue();
    }
  }

  /// Update upload progress
  /// 업로드 진행률 업데이트
  void _updateProgress(String taskId, double progress) {
    _uploadProgress[taskId] = progress;
    _progressControllers[taskId]?.add(progress);

    final task = _activeTasks[taskId];
    if (task != null) {
      task.progress = progress;
    }

    notifyListeners();
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
    final task = _activeTasks[taskId];
    if (task != null) {
      task.status = UploadStatus.cancelled;

      // Remove from queue if pending
      _uploadQueue.removeWhere((t) => t.id == taskId);

      // Close progress controller
      _progressControllers[taskId]?.close();
      _progressControllers.remove(taskId);

      notifyListeners();
    }
  }

  /// Retry failed upload
  /// 실패한 업로드 재시도
  void retryUpload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null && task.status == UploadStatus.failed) {
      // Reset retry count
      _retryCount[taskId] = 0;

      // Clear error
      _uploadErrors.remove(taskId);

      // Reset task status
      task.status = UploadStatus.pending;
      task.progress = 0.0;

      // Add to queue
      _uploadQueue.add(task);

      notifyListeners();

      // Start processing
      _processUploadQueue();
    }
  }

  /// Cancel all uploads
  /// 모든 업로드 취소
  void cancelAllUploads() {
    // Cancel all active tasks
    for (final taskId in _activeTasks.keys.toList()) {
      cancelUpload(taskId);
    }

    // Clear queue
    _uploadQueue.clear();

    _isUploading = false;
    notifyListeners();
  }

  /// Clear completed uploads
  /// 완료된 업로드 정리
  void clearCompleted() {
    _activeTasks.removeWhere((_, task) =>
      task.status == UploadStatus.completed ||
      task.status == UploadStatus.cancelled);

    _uploadProgress.removeWhere((taskId, _) =>
      !_activeTasks.containsKey(taskId));

    notifyListeners();
  }

  /// Get upload URLs for a task
  /// 태스크의 업로드된 URL 가져오기
  List<String>? getUploadedUrls(String taskId) {
    return _activeTasks[taskId]?.uploadedUrls;
  }

  /// Check if task is complete
  /// 태스크 완료 여부 확인
  bool isTaskComplete(String taskId) {
    return _activeTasks[taskId]?.status == UploadStatus.completed;
  }

  /// Get task status
  /// 태스크 상태 가져오기
  UploadStatus? getTaskStatus(String taskId) {
    return _activeTasks[taskId]?.status;
  }

  @override
  void dispose() {
    // Close all progress controllers
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();

    super.dispose();
  }
}