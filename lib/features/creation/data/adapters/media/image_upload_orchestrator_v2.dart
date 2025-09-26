import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import '/app/state/app_state.dart';
import '/services/moderation/image_moderation_service.dart';
import '/features/creation/presentation/screens/create_post/in_put_post_image_model.dart';

/// 이미지 처리 프로세스를 조율하는 서비스 클래스 (File 기반)
///
/// @deprecated Use ImageUploadProvider instead for better architecture separation.
/// This class violates Clean Architecture by mixing UI (BuildContext) with data layer.
/// Migration path:
/// 1. Use ImageUploadService for pure data operations
/// 2. Use ImageUploadProvider for UI state management
///
/// 더 나은 아키텍처 분리를 위해 ImageUploadProvider를 사용하세요.
/// 이 클래스는 UI(BuildContext)를 데이터 레이어와 혼합하여 클린 아키텍처를 위반합니다.
@Deprecated('Use ImageUploadProvider and ImageUploadService instead')
class ImageUploadOrchestratorV2 {
  final BuildContext context;
  final AppState appState;
  final String box;
  final InPutPostImageModel? model;

  ImageUploadOrchestratorV2({
    required this.context,
    required this.appState,
    required this.box,
    this.model,
  });

  /// 멀티 이미지 처리 (편집된 이미지만 검열하고 업데이트)
  Future<ImageProcessResult> handleMultiImageProcess({
    required File editedImageFile,
    required List<File> allFiles,
    required int currentEditIndex,
    required List<AssetEntity> selectedAssets,
    bool isAddMode = false,
    bool isEditMode = false,
    int? currentIndex,
    List<String>? existingImageUrls,
    List<double>? existingAspectRatios,
    List<String>? existingAssetIds,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
    bool showToast = true, // 토스트 표시 여부
  }) async {
    onProgress?.call(0.1);

    // 처음 선택인지 확인
    final isFirstSelection = (box == 'A' && appState.tempImageFilesA.isEmpty) ||
        (box == 'B' && appState.tempImageFilesB.isEmpty);

    // 검열할 파일들과 검열 결과 저장
    final List<File> approvedFiles = [];
    final List<double> approvedRatios = [];
    final List<String> approvedAssetIds = [];
    final List<int> rejectedIndices = [];
    final Map<String, List<int>> rejectedReasons = {};

    // 승인된 파일과 AssetEntity 매핑을 위한 Map
    final Map<File, String> fileToAssetIdMap = {};

    if (isFirstSelection) {
      // 처음 선택 시: 편집된 이미지(썸네일)만 이미지+텍스트 검열
      // 나머지 이미지들은 이미 기본 검열을 통과한 상태
      print('[ImageUploadOrchestrator] 처음 선택 - 편집된 썸네일 이미지 검열');

      onModerationProgress?.call(1, 1);
      final editedResult = await ImageModerationService.checkImage(
        imageFile: editedImageFile,
        box: box,
      );

      onProgress?.call(0.5);

      if (!editedResult.isAppropriate) {
        // 편집된 썸네일 이미지가 거부된 경우 - 거부 목록에 추가하고 계속 진행
        rejectedIndices.add(currentEditIndex + 1);
        if (rejectedReasons.containsKey(editedResult.reason)) {
          rejectedReasons[editedResult.reason]!.add(currentEditIndex + 1);
        } else {
          rejectedReasons[editedResult.reason] = [currentEditIndex + 1];
        }
        print(
            '[ImageUploadOrchestrator] 썸네일 이미지 검열 실패: ${editedResult.reason}');
      } else {
        // 썸네일 검열 통과
        approvedFiles.add(editedImageFile);
        if (currentEditIndex < selectedAssets.length) {
          fileToAssetIdMap[editedImageFile] =
              selectedAssets[currentEditIndex].id;
        }
      }

      // 나머지 이미지들도 기본 검열 계속 진행
      for (int i = 0; i < allFiles.length; i++) {
        if (i == currentEditIndex) {
          // 썸네일은 이미 처리함
          continue;
        } else {
          // 나머지 이미지들 기본 검열
          final result = await ImageModerationService.checkImage(
            imageFile: allFiles[i],
            box: box,
          );

          if (result.isAppropriate) {
            approvedFiles.add(allFiles[i]);
            if (i < selectedAssets.length) {
              fileToAssetIdMap[allFiles[i]] = selectedAssets[i].id;
            }
          } else {
            rejectedIndices.add(i + 1);
            if (rejectedReasons.containsKey(result.reason)) {
              rejectedReasons[result.reason]!.add(i + 1);
            } else {
              rejectedReasons[result.reason] = [i + 1];
            }
            print(
                '[ImageUploadOrchestrator] ${i + 1}번째 이미지 기본 검열 실패: ${result.reason}');
          }
        }

        onModerationProgress?.call(i + 1, allFiles.length);
      }

      // 모든 이미지가 거부된 경우
      if (approvedFiles.isEmpty) {
        if (showToast) {
          _showRejectionToast(rejectedReasons);
        }
        return ImageProcessResult(
          success: false,
          approvedCount: 0,
          rejectedCount: rejectedIndices.length,
          allRejected: true,
          rejectedIndices: rejectedIndices,
        );
      }

      // 일부 이미지가 거부된 경우
      if (rejectedIndices.isNotEmpty) {
        if (showToast) {
          _showRejectionToast(rejectedReasons);
        }
        print(
            '[ImageUploadOrchestrator] 일부 이미지 거부됨. 승인: ${approvedFiles.length}개, 거부: ${rejectedIndices.length}개');
      }
    } else {
      // 기존 이미지가 있을 때: 편집된 이미지만 검열
      onModerationProgress?.call(1, 1);

      // 편집 모드일 때는 항상 이미지+텍스트 검열 수행
      final editedResult = await ImageModerationService.checkImage(
        imageFile: editedImageFile,
        box: box,
      );

      onProgress?.call(0.5);

      if (!editedResult.isAppropriate) {
        // 편집된 이미지가 거부된 경우
        if (showToast) {
          _showRejectionToast({
            editedResult.reason: [currentEditIndex + 1]
          }, moderationResult: editedResult);
        }

        return ImageProcessResult(
          success: false,
          approvedCount: 0,
          rejectedCount: 1,
          allRejected: false,
          rejectedIndices: [currentEditIndex + 1],
          moderationResult: editedResult,
        );
      }
    }

    // 2. 비율 계산 및 AssetEntity ID 매핑
    if (isFirstSelection) {
      // 처음 선택 시: 승인된 이미지들의 비율 계산
      for (final file in approvedFiles) {
        final ratio = await _calculateAspectRatio(file);
        approvedRatios.add(ratio);

        // AssetEntity ID 추가
        if (fileToAssetIdMap.containsKey(file)) {
          approvedAssetIds.add(fileToAssetIdMap[file]!);
        }
      }
    } else {
      // 편집된 이미지의 비율 계산
      final editedRatio = await _calculateAspectRatio(editedImageFile);
      approvedRatios.add(editedRatio);
    }

    onProgress?.call(0.8);

    // 3. AppState 업데이트
    appState.update(() {
      if (box == 'A') {
        if (isFirstSelection) {
          // 처음 선택 시: 승인된 파일들만 추가
          print(
              '[ImageUploadOrchestrator] 승인된 이미지 추가: ${approvedFiles.length}개');
          for (int i = 0; i < approvedFiles.length; i++) {
            appState.addToTempImageFilesA(approvedFiles[i]);
            appState.addToUploadImageAspectRatioA(approvedRatios[i]);
            if (i < approvedAssetIds.length) {
              appState.addToAssetEntityIdsA(approvedAssetIds[i]);
            }
          }
        } else {
          // 기존 이미지가 있을 때: 편집된 이미지만 업데이트
          if (currentEditIndex < appState.tempImageFilesA.length) {
            appState.tempImageFilesA[currentEditIndex] = editedImageFile;
          }
          if (currentEditIndex < appState.uploadImageAspectRatioA.length) {
            appState.uploadImageAspectRatioA[currentEditIndex] =
                approvedRatios[0];
          }
        }
      } else {
        if (isFirstSelection) {
          // 처음 선택 시: 승인된 파일들만 추가
          print(
              '[ImageUploadOrchestrator] 승인된 이미지 추가: ${approvedFiles.length}개');
          for (int i = 0; i < approvedFiles.length; i++) {
            appState.addToTempImageFilesB(approvedFiles[i]);
            appState.addToUploadImageAspectRatioB(approvedRatios[i]);
            if (i < approvedAssetIds.length) {
              appState.addToAssetEntityIdsB(approvedAssetIds[i]);
            }
          }
        } else {
          // 기존 이미지가 있을 때: 편집된 이미지만 업데이트
          if (currentEditIndex < appState.tempImageFilesB.length) {
            appState.tempImageFilesB[currentEditIndex] = editedImageFile;
          }
          if (currentEditIndex < appState.uploadImageAspectRatioB.length) {
            appState.uploadImageAspectRatioB[currentEditIndex] =
                approvedRatios[0];
          }
        }
      }
    });

    onProgress?.call(1.0);

    return ImageProcessResult(
      success: true,
      approvedCount: isFirstSelection
          ? approvedFiles.length
          : (box == 'A'
              ? appState.tempImageFilesA.length
              : appState.tempImageFilesB.length),
      rejectedCount: rejectedIndices.length,
      allRejected: false,
      rejectedIndices: rejectedIndices,
    );
  }

  /// 단일 이미지 처리
  Future<ImageProcessResult> handleSingleImageProcess({
    required File imageFile,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    onProgress?.call(0.1);

    // 이미지 검열
    final result = await ImageModerationService.checkImage(
      imageFile: imageFile,
      box: box,
    );

    onProgress?.call(0.5);

    if (!result.isAppropriate) {
      // 거부 메시지 표시
      _showRejectionToast({
        result.reason: [1]
      }, moderationResult: result);

      return ImageProcessResult(
        success: false,
        approvedCount: 0,
        rejectedCount: 1,
        allRejected: true,
        rejectedIndices: [1],
        moderationResult: result,
      );
    }

    // 이미지 비율 계산
    final aspectRatio = await _calculateAspectRatio(imageFile);

    onProgress?.call(0.8);

    // AppState 업데이트
    appState.update(() {
      if (box == 'A') {
        appState.clearTempImageFilesA();
        appState.addToTempImageFilesA(imageFile);
        appState.uploadImageAspectRatioA = [aspectRatio];
        if (assetId != null) {
          appState.assetEntityIdsA = [assetId];
        }
      } else {
        appState.clearTempImageFilesB();
        appState.addToTempImageFilesB(imageFile);
        appState.uploadImageAspectRatioB = [aspectRatio];
        if (assetId != null) {
          appState.assetEntityIdsB = [assetId];
        }
      }
    });

    onProgress?.call(1.0);

    return ImageProcessResult(
      success: true,
      approvedCount: 1,
      rejectedCount: 0,
      allRejected: false,
      rejectedIndices: [],
    );
  }

  /// 이미지 비율 계산
  Future<double> _calculateAspectRatio(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      final width = decodedImage.width;
      final height = decodedImage.height;
      final ratio = width / height;

      print('[ImageUploadOrchestrator] 이미지 비율 계산:');
      print('  - 파일 경로: ${file.path}');
      print('  - 파일 크기: ${bytes.length} bytes');
      print('  - 이미지 크기: ${width}x${height}');
      print('  - 계산된 비율: $ratio');

      return ratio;
    } catch (e) {
      print('[ImageUploadOrchestrator] 비율 계산 실패: $e');
      print('  - 파일 경로: ${file.path}');
      return 1.0; // 기본값
    }
  }

  /// 거부 메시지 표시 (ErrorHandler 스타일과 통일)
  void _showRejectionToast(Map<String, List<int>> rejectedReasons,
      {ModerationResult? moderationResult}) {
    print('[DEBUG] _showRejectionToast 호출됨');
    print('[DEBUG] rejectedReasons: $rejectedReasons');
    print(
        '[DEBUG] moderationResult: ${moderationResult != null ? "있음" : "없음"}');
    if (moderationResult != null) {
      print('[DEBUG] - hasText: ${moderationResult.hasText}');
      print('[DEBUG] - reason: ${moderationResult.reason}');
    }

    final messages = <String>[];

    // 단일 이미지인 경우 더 구체적인 메시지 제공
    if (rejectedReasons.length == 1 && moderationResult != null) {
      final reason = rejectedReasons.keys.first;

      // 텍스트 문제인지 이미지 문제인지 구분
      if (moderationResult.hasText && reason.isNotEmpty) {
        // 텍스트 관련 거부 이유들
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
        // 이미지 관련 거부 이유들
        final imageReasons = ['성인 콘텐츠', '폭력적 콘텐츠', '선정적 콘텐츠'];
        if (imageReasons.contains(reason)) {
          messages.add('이미지가 부적절합니다: $reason');
        } else {
          messages.add('콘텐츠가 부적절합니다: $reason');
        }
      }
    } else {
      // 멀티 이미지인 경우 기존 방식 유지
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
            // 아이콘 추가
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

/// 이미지 처리 결과
class ImageProcessResult {
  final bool success;
  final int approvedCount;
  final int rejectedCount;
  final bool allRejected;
  final List<int> rejectedIndices;
  final ModerationResult? moderationResult; // 단일 이미지 검열 결과

  ImageProcessResult({
    required this.success,
    required this.approvedCount,
    required this.rejectedCount,
    required this.allRejected,
    required this.rejectedIndices,
    this.moderationResult,
  });
}
