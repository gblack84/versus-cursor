import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_queue_state.freezed.dart';

/// Upload status enum
enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}

/// Individual upload task model
@freezed
sealed class UploadTask with _$UploadTask {
  const UploadTask._();

  const factory UploadTask({
    required String id,
    required String box,
    required List<File> files,
    required DateTime createdAt,
    @Default(UploadStatus.pending) UploadStatus status,
    @Default(0.0) double progress,
    List<String>? uploadedUrls,
    String? errorMessage,
  }) = _UploadTask;

  /// Check if task is in progress
  bool get isInProgress => status == UploadStatus.uploading;

  /// Check if task is complete
  bool get isComplete => status == UploadStatus.completed;

  /// Check if task has failed
  bool get hasFailed => status == UploadStatus.failed;

  /// Check if task is cancelled
  bool get isCancelled => status == UploadStatus.cancelled;

  /// Check if task can be retried
  bool get canRetry => hasFailed || isCancelled;
}

/// Upload error model
@freezed
sealed class UploadError with _$UploadError {
  const factory UploadError({
    required String taskId,
    required String message,
    required DateTime timestamp,
    int? retryCount,
  }) = _UploadError;
}

/// Complete state for MediaUploadProvider
///
/// This consolidates all state variables from MediaUploadProvider into a single immutable state
@freezed
sealed class UploadQueueState with _$UploadQueueState {
  const UploadQueueState._();

  const factory UploadQueueState({
    /// Active upload tasks by ID
    @Default({}) Map<String, UploadTask> activeTasks,

    /// Upload progress tracking by task ID
    @Default({}) Map<String, double> uploadProgress,

    /// Upload errors by task ID
    @Default({}) Map<String, UploadError> uploadErrors,

    /// Upload queue (pending tasks)
    @Default([]) List<UploadTask> uploadQueue,

    /// Currently uploading flag
    @Default(false) bool isUploading,

    /// Retry counts by task ID
    @Default({}) Map<String, int> retryCounts,
  }) = _UploadQueueState;

  /// Get total number of pending tasks
  int get pendingTaskCount => uploadQueue.length;

  /// Get total number of active tasks
  int get activeTaskCount => activeTasks.length;

  /// Get total number of failed tasks
  int get failedTaskCount => activeTasks.values.where((t) => t.hasFailed).length;

  /// Get total number of completed tasks
  int get completedTaskCount => activeTasks.values.where((t) => t.isComplete).length;

  /// Check if any tasks are in progress
  bool get hasActiveUploads => activeTasks.values.any((t) => t.isInProgress);

  /// Get overall upload progress (0.0 to 1.0)
  double get overallProgress {
    if (activeTasks.isEmpty) return 0.0;

    final totalProgress = activeTasks.values.fold<double>(
      0.0,
      (sum, task) => sum + task.progress,
    );

    return totalProgress / activeTasks.length;
  }

  /// Get task by ID
  UploadTask? getTask(String taskId) => activeTasks[taskId];

  /// Get error for task
  UploadError? getError(String taskId) => uploadErrors[taskId];

  /// Get retry count for task
  int getRetryCount(String taskId) => retryCounts[taskId] ?? 0;

  /// Check if task can be retried
  bool canRetryTask(String taskId, int maxRetries) {
    final task = getTask(taskId);
    if (task == null || !task.canRetry) return false;

    final retryCount = getRetryCount(taskId);
    return retryCount < maxRetries;
  }
}
