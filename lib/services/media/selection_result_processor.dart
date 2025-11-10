import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get_it/get_it.dart';
import '/features/creation/presentation/providers/media_selection_provider.dart';
import '/features/creation/domain/services/i_image_moderation_service.dart';
import '/core/utils/debug_helper.dart';
import '/core/utils/error_handler.dart';

/// 이미지 선택 결과 처리 서비스
///
/// **Phase 3.6**: AppState → MediaSelectionProvider 마이그레이션
/// - AppState 의존성 제거
/// - WidgetRef를 통한 Provider 접근
/// - Clean Architecture v4.0 준수
class SelectionResultProcessor {
  final BuildContext context;
  final WidgetRef ref;
  final String box;
  final List<String>? existingAssetIds;
  final Function(double) onProgressUpdate;
  final Function(List<String>)? onMultiComplete;
  final VoidCallback? onProcessingComplete;

  SelectionResultProcessor({
    required this.context,
    required this.ref,
    required this.box,
    this.existingAssetIds,
    required this.onProgressUpdate,
    this.onMultiComplete,
    this.onProcessingComplete,
  });

  /// 선택 결과 처리
  Future<void> processSelectionResult(List<AssetEntity> selectedAssets) async {
    try {
      onProgressUpdate(0.1);

      // 기존 AssetEntity ID 목록
      final existingIds = existingAssetIds ?? [];
      final selectedIds = selectedAssets.map((e) => e.id).toList();

      // 삭제된 항목 찾기
      final removedIds =
          existingIds.where((id) => !selectedIds.contains(id)).toList();

      // 새로 추가된 항목 찾기
      final newAssets = selectedAssets
          .where((asset) => !existingIds.contains(asset.id))
          .toList();

      print('기존: ${existingIds.length}개, 선택: ${selectedIds.length}개');
      print('삭제: ${removedIds.length}개, 추가: ${newAssets.length}개');

      // 삭제 처리
      if (removedIds.isNotEmpty) {
        _handleRemovals(removedIds);
      }

      onProgressUpdate(0.3);

      // 새 이미지 업로드
      if (newAssets.isNotEmpty) {
        await _handleNewAssets(newAssets);
      }

      // TODO: 순서 재정렬 기능 (ImageReorderService 구현 필요)
      // if (selectedIds.length == appState.assetEntityIdsA.length ||
      //     selectedIds.length == appState.assetEntityIdsB.length) {
      //   ImageReorderService.reorderImages(
      //     appState: appState,
      //     box: box,
      //     newOrder: selectedIds,
      //   );
      // }

      onProgressUpdate(1.0);

      // 콜백 호출
      // Phase 3.6: AppState.uploadImageA → MediaSelectionProvider.uploadedUrlsA
      if (onMultiComplete != null) {
        final state = ref.read(mediaSelectionProvider);
        final urls = box == 'A' ? state.uploadedUrlsA : state.uploadedUrlsB;
        onMultiComplete!(urls);
      }

      // 모달 닫기는 호출한 곳에서 처리
      DebugHelper.log('선택 완료');

      // 처리 완료 콜백 호출
      onProcessingComplete?.call();
    } catch (e) {
      if (context.mounted) {
        onProgressUpdate(0.0);
        ErrorHandler.handle(
          e,
          type: ErrorType.imageProcessing,
          customMessage: '이미지 처리 중 오류가 발생했습니다.',
          context: context,
        );
        // 에러 시에도 모달 닫기는 호출한 곳에서 처리
      }
    }
  }

  /// 삭제 처리
  ///
  /// **Phase 3.6**: AppState.assetEntityIds → MediaSelectionProvider.removeUploadedUrl
  void _handleRemovals(List<String> removedIds) {
    final state = ref.read(mediaSelectionProvider);
    final notifier = ref.read(mediaSelectionProvider.notifier);

    if (box == 'A') {
      // 삭제할 인덱스 찾기 (역순으로 삭제하여 인덱스 변화 방지)
      for (final removedId in removedIds.reversed) {
        final index = state.assetEntityIdsA.indexOf(removedId);
        if (index != -1) {
          notifier.removeUploadedUrlA(index);
        }
      }
    } else {
      for (final removedId in removedIds.reversed) {
        final index = state.assetEntityIdsB.indexOf(removedId);
        if (index != -1) {
          notifier.removeUploadedUrlB(index);
        }
      }
    }
  }

  /// 새 이미지 처리 (검열 후 File 객체로 저장)
  Future<void> _handleNewAssets(List<AssetEntity> newAssets) async {
    final approvedFiles = <File>[];
    final approvedAssets = <AssetEntity>[];
    final rejectedIndices = <int>[];
    final rejectedReasons = <String, List<int>>{};

    // 검열 진행
    for (int i = 0; i < newAssets.length; i++) {
      final asset = newAssets[i];
      final file = await asset.file;
      if (file == null) continue;

      onProgressUpdate(0.3 + (0.3 * (i + 1) / newAssets.length));

      try {
        // 이미지 검열 (GetIt으로 서비스 해결)
        final moderationService = GetIt.instance<IImageModerationService>();
        final result = await moderationService.checkImage(
          imageFile: file,
          box: box,
        );

        if (result.isAppropriate) {
          approvedFiles.add(file);
          approvedAssets.add(asset);
        } else {
          // 기존 이미지 개수를 고려하여 실제 번호 계산
          // Phase 3.6: AppState.tempImageFilesA → MediaSelectionProvider.selectedFilesA
          final state = ref.read(mediaSelectionProvider);
          final existingCount = box == 'A'
              ? state.selectedFilesA.length
              : state.selectedFilesB.length;
          final actualIndex = existingCount + i + 1;
          rejectedIndices.add(actualIndex); // 사용자에게 표시할 번호

          // 거부 이유별로 그룹화
          if (rejectedReasons.containsKey(result.reason)) {
            rejectedReasons[result.reason]!.add(actualIndex);
          } else {
            rejectedReasons[result.reason] = [actualIndex];
          }

          DebugHelper.logModeration(
              '[SelectionProcessor] 이미지 검열 실패: ${result.reason}');
        }
      } catch (e) {
        // 검열 오류 시 통과로 처리 (나중에 서버에서 재검증)
        DebugHelper.logError('이미지 검열 중 오류', e);
        approvedFiles.add(file);
        approvedAssets.add(asset);
      }
    }

    onProgressUpdate(0.7);

    // 검열 결과 처리
    if (rejectedIndices.isNotEmpty && approvedFiles.isEmpty) {
      // 모든 이미지가 거부됨
      _showRejectionToast(rejectedReasons);
      return;
    } else if (rejectedIndices.isNotEmpty) {
      // 일부 이미지만 거부됨
      _showRejectionToast(rejectedReasons);
    }

    // 승인된 이미지들을 MediaSelectionProvider에 File 객체로 저장
    // Phase 3.6: AppState.addToTempImageFilesA → MediaSelectionProvider.addSelectedFileA
    final notifier = ref.read(mediaSelectionProvider.notifier);

    for (int i = 0; i < approvedFiles.length; i++) {
      final file = approvedFiles[i];
      final asset = approvedAssets[i];

      // 이미지 비율 계산
      final bytes = await file.readAsBytes();
      final aspectRatio = await _calculateAspectRatio(bytes);

      if (box == 'A') {
        notifier.addSelectedFileA(
          file: file,
          aspectRatio: aspectRatio,
          assetId: asset.id,
        );
      } else {
        notifier.addSelectedFileB(
          file: file,
          aspectRatio: aspectRatio,
          assetId: asset.id,
        );
      }
    }

    onProgressUpdate(1.0);
  }

  /// 이미지 비율 계산
  Future<double> _calculateAspectRatio(Uint8List bytes) async {
    try {
      final decodedImage = await decodeImageFromList(bytes);
      final width = decodedImage.width;
      final height = decodedImage.height;
      final ratio = width / height;

      DebugHelper.log('[SelectionProcessor] 이미지 비율 계산:');
      DebugHelper.log('  - 이미지 크기: ${width}x${height}');
      DebugHelper.log('  - 계산된 비율: $ratio');

      return ratio;
    } catch (e) {
      DebugHelper.logError('비율 계산 실패', e);
      return 1.0; // 기본값
    }
  }

  /// 거부 메시지 표시 (ErrorHandler 스타일과 통일)
  void _showRejectionToast(Map<String, List<int>> rejectedReasons) {
    final messages = <String>[];

    rejectedReasons.forEach((reason, indices) {
      messages.add('$reason: ${indices.join(", ")}');
    });

    final message = messages.join('\n');

    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade700.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
      duration: const Duration(seconds: 3),
      align: const Alignment(0, 0.8),
      onlyOne: true,
    );
  }
}
