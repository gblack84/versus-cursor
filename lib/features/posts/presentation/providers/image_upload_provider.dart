import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import '/app/state/app_state.dart';
import '../../data/services/image_upload_service.dart';
import '/services/moderation/image_moderation_service.dart';

/// Provider that bridges the pure ImageUploadService with UI state management
/// 순수한 ImageUploadService와 UI 상태 관리를 연결하는 프로바이더
class ImageUploadProvider extends ChangeNotifier {
  final ImageUploadService _service = ImageUploadService();
  final AppState appState;

  ImageUploadProvider({required this.appState});

  /// Process multiple images and update AppState
  Future<ImageUploadResult> processMultipleImages({
    required List<File> files,
    required String box,
    File? editedFile,
    int? editedFileIndex,
    List<AssetEntity>? assetEntities,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
    bool showToast = true,
  }) async {
    final result = await _service.processMultipleImages(
      files: files,
      box: box,
      editedFile: editedFile,
      editedFileIndex: editedFileIndex,
      assetEntities: assetEntities,
      onProgress: onProgress,
      onModerationProgress: onModerationProgress,
    );

    // Update AppState based on results
    if (result.approvedFiles.isNotEmpty) {
      appState.update(() {
        if (box == 'A') {
          // Clear existing and add approved files
          appState.clearTempImageFilesA();
          appState.uploadImageAspectRatioA = [];
          appState.assetEntityIdsA = [];

          for (int i = 0; i < result.approvedFiles.length; i++) {
            appState.addToTempImageFilesA(result.approvedFiles[i]);
            if (i < result.approvedRatios.length) {
              appState.addToUploadImageAspectRatioA(result.approvedRatios[i]);
            }
            if (i < result.approvedAssetIds.length) {
              appState.addToAssetEntityIdsA(result.approvedAssetIds[i]);
            }
          }
        } else {
          // Clear existing and add approved files
          appState.clearTempImageFilesB();
          appState.uploadImageAspectRatioB = [];
          appState.assetEntityIdsB = [];

          for (int i = 0; i < result.approvedFiles.length; i++) {
            appState.addToTempImageFilesB(result.approvedFiles[i]);
            if (i < result.approvedRatios.length) {
              appState.addToUploadImageAspectRatioB(result.approvedRatios[i]);
            }
            if (i < result.approvedAssetIds.length) {
              appState.addToAssetEntityIdsB(result.approvedAssetIds[i]);
            }
          }
        }
      });
    }

    // Show toast for rejections if needed
    if (showToast && result.hasRejections) {
      _showRejectionToast(result.rejectedReasons);
    }

    notifyListeners();

    return ImageUploadResult(
      success: !result.allRejected,
      approvedCount: result.approvedCount,
      rejectedCount: result.rejectedCount,
      allRejected: result.allRejected,
      rejectedIndices: result.rejectedIndices,
    );
  }

  /// Process single image and update AppState
  Future<ImageUploadResult> processSingleImage({
    required File file,
    required String box,
    String? assetId,
    Function(double)? onProgress,
    bool showToast = true,
  }) async {
    final result = await _service.processSingleImage(
      file: file,
      box: box,
      assetId: assetId,
      onProgress: onProgress,
    );

    if (result.success) {
      // Update AppState
      appState.update(() {
        if (box == 'A') {
          appState.clearTempImageFilesA();
          appState.addToTempImageFilesA(result.file!);
          appState.uploadImageAspectRatioA = [result.aspectRatio!];
          if (assetId != null) {
            appState.assetEntityIdsA = [assetId];
          }
        } else {
          appState.clearTempImageFilesB();
          appState.addToTempImageFilesB(result.file!);
          appState.uploadImageAspectRatioB = [result.aspectRatio!];
          if (assetId != null) {
            appState.assetEntityIdsB = [assetId];
          }
        }
      });
    } else if (showToast) {
      _showRejectionToast({
        result.moderationResult.reason: [1]
      }, moderationResult: result.moderationResult);
    }

    notifyListeners();

    return ImageUploadResult(
      success: result.success,
      approvedCount: result.success ? 1 : 0,
      rejectedCount: result.success ? 0 : 1,
      allRejected: !result.success,
      rejectedIndices: result.success ? [] : [1],
      moderationResult: result.moderationResult,
    );
  }

  /// Process edited image for multi-image flow
  Future<ImageUploadResult> processEditedImage({
    required File editedFile,
    required String box,
    required int editIndex,
    String? assetId,
    Function(double)? onProgress,
    bool showToast = true,
  }) async {
    final result = await _service.processEditedImage(
      editedFile: editedFile,
      box: box,
      assetId: assetId,
      onProgress: onProgress,
    );

    if (result.success) {
      // Update specific index in AppState
      appState.update(() {
        if (box == 'A') {
          if (editIndex < appState.tempImageFilesA.length) {
            appState.tempImageFilesA[editIndex] = result.file!;
          }
          if (editIndex < appState.uploadImageAspectRatioA.length) {
            appState.uploadImageAspectRatioA[editIndex] = result.aspectRatio!;
          }
        } else {
          if (editIndex < appState.tempImageFilesB.length) {
            appState.tempImageFilesB[editIndex] = result.file!;
          }
          if (editIndex < appState.uploadImageAspectRatioB.length) {
            appState.uploadImageAspectRatioB[editIndex] = result.aspectRatio!;
          }
        }
      });
    } else if (showToast) {
      _showRejectionToast({
        result.moderationResult.reason: [editIndex + 1]
      }, moderationResult: result.moderationResult);
    }

    notifyListeners();

    return ImageUploadResult(
      success: result.success,
      approvedCount: result.success ? 1 : 0,
      rejectedCount: result.success ? 0 : 1,
      allRejected: !result.success,
      rejectedIndices: result.success ? [] : [editIndex + 1],
      moderationResult: result.moderationResult,
    );
  }

  /// Show rejection toast message
  void _showRejectionToast(
    Map<String, List<int>> rejectedReasons, {
    ModerationResult? moderationResult,
  }) {
    final messages = <String>[];

    // Single image case - more specific message
    if (rejectedReasons.length == 1 && moderationResult != null) {
      final reason = rejectedReasons.keys.first;

      // Distinguish between text and image issues
      if (moderationResult.hasText && reason.isNotEmpty) {
        final textReasons = [
          '욕설',
          '유해한 콘텐츠',
          '심각한 유해 콘텐츠',
          '혐오 표현',
          '모욕적 표현',
          '위협적 표현'
        ];
        if (textReasons.contains(reason)) {
          messages.add('편집된 텍스트가 부적절합니다: $reason');
        } else {
          messages.add('콘텐츠가 부적절합니다: $reason');
        }
      } else {
        final imageReasons = ['성인 콘텐츠', '폭력적 콘텐츠', '선정적 콘텐츠'];
        if (imageReasons.contains(reason)) {
          messages.add('이미지가 부적절합니다: $reason');
        } else {
          messages.add('콘텐츠가 부적절합니다: $reason');
        }
      }
    } else {
      // Multi-image case - keep existing format
      rejectedReasons.forEach((reason, indices) {
        messages.add('$reason: ${indices.join(", ")}');
      });
    }

    final message = messages.join('\n');

    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade700.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              moderationResult?.hasText == true
                  ? Icons.text_fields
                  : Icons.image_not_supported,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
      align: const Alignment(0, 0.8),
      onlyOne: true,
    );
  }
}

/// Result class for image upload operations
class ImageUploadResult {
  final bool success;
  final int approvedCount;
  final int rejectedCount;
  final bool allRejected;
  final List<int> rejectedIndices;
  final ModerationResult? moderationResult;

  ImageUploadResult({
    required this.success,
    required this.approvedCount,
    required this.rejectedCount,
    required this.allRejected,
    required this.rejectedIndices,
    this.moderationResult,
  });
}