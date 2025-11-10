import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/core_exports.dart';
import '/features/creation/presentation/providers/media_selection_provider.dart';
import 'media_upload_service.dart';

/// 이미지 에디터 콜백 처리를 담당하는 클래스
///
/// **Phase 3.6**: AppState → MediaSelectionProvider 마이그레이션
/// - AppState 의존성 제거
/// - WidgetRef를 통한 Provider 접근
/// - Clean Architecture v4.0 준수
class ImageEditorCallbackHandler {
  final BuildContext context;
  final WidgetRef ref;
  final String box;
  final List<File> allSelectedFiles;
  final List<AssetEntity> selectedAssets;
  final int currentEditIndex;
  final bool isAddMode;
  final int? currentIndex;
  final List<String>? existingImageUrls;
  final List<double>? existingAspectRatios;
  final List<String>? existingAssetIds;
  final bool startWithEditor;
  final String? initialImageUrl;
  final Function(double) onProgressUpdate;
  final Function(List<String>)? onMultiComplete;
  final Function(String)? onSingleComplete;

  ImageEditorCallbackHandler({
    required this.context,
    required this.ref,
    required this.box,
    required this.allSelectedFiles,
    required this.selectedAssets,
    required this.currentEditIndex,
    required this.isAddMode,
    this.currentIndex,
    this.existingImageUrls,
    this.existingAspectRatios,
    this.existingAssetIds,
    required this.startWithEditor,
    this.initialImageUrl,
    required this.onProgressUpdate,
    this.onMultiComplete,
    this.onSingleComplete,
  });

  /// 이미지 편집 완료 처리
  Future<void> handleImageEditingComplete(Uint8List bytes) async {
    print('onImageEditingComplete 호출됨');
    try {
      onProgressUpdate(0.2);

      if (allSelectedFiles.isNotEmpty) {
        await _handleMultiImageUpload(bytes);
      } else {
        await _handleSingleImageUpload(bytes);
      }
    } catch (e) {
      print('이미지 업로드 에러: $e');
      if (context.mounted) {
        onProgressUpdate(0.0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  /// 멀티 이미지 업로드 처리
  Future<void> _handleMultiImageUpload(Uint8List bytes) async {
    final reorderedUrls = <String>[];
    final reorderedRatios = <double>[];

    // 1. 편집된 이미지 업로드
    onProgressUpdate(0.2);

    final editedResult = await _uploadEditedImage(bytes);
    if (editedResult == null) return; // 업로드 실패

    final editedDisplayUrl = editedResult['urls']['display'];
    final editedAspectRatio = editedResult['aspectRatio'];

    // 추가 모드 처리
    if (isAddMode && currentIndex != null) {
      await _handleAddMode(
          reorderedUrls, reorderedRatios, editedDisplayUrl, editedAspectRatio);
    } else {
      await _handleEditMode(
          reorderedUrls, reorderedRatios, editedDisplayUrl, editedAspectRatio);
    }

    // AssetEntity ID 순서 맞추기
    final reorderedAssetIds = _reorderAssetIds();

    // AppState에 저장
    _updateAppState(reorderedUrls, reorderedRatios, reorderedAssetIds);

    // 콜백 호출
    onMultiComplete?.call(reorderedUrls);

    onProgressUpdate(1.0);

    // 모달 닫기
    if (context.mounted) {
      Navigator.pop(context);
      print('멀티 이미지 업로드 완료 및 모달 닫기');
    }
  }

  /// 단일 이미지 업로드 처리
  Future<void> _handleSingleImageUpload(Uint8List bytes) async {
    onProgressUpdate(0.5);

    // 업로드
    final result = await _uploadEditedImage(bytes);
    if (result == null) return;

    final displayUrl = result['urls']['display'] as String;
    final aspectRatio = result['aspectRatio'] as double;

    onProgressUpdate(0.9);

    // 편집 모드 확인
    final isEditMode = startWithEditor && initialImageUrl != null;

    if (!isEditMode) {
      // 편집 모드가 아닐 때만 MediaSelectionProvider에 추가
      // Phase 3.6: AppState.addToUploadImage → MediaSelectionProvider.addUploadedUrl
      final assetId = selectedAssets.isNotEmpty ? selectedAssets.first.id : '';

      if (box == 'A') {
        ref.read(mediaSelectionProvider.notifier).addUploadedUrlA(
          url: displayUrl,
          aspectRatio: aspectRatio,
          assetId: assetId,
        );
      } else {
        ref.read(mediaSelectionProvider.notifier).addUploadedUrlB(
          url: displayUrl,
          aspectRatio: aspectRatio,
          assetId: assetId,
        );
      }
    }

    // 프리캐싱
    precacheImage(CachedNetworkImageProvider(displayUrl), context)
        .catchError((e) {
      print('프리캐싱 실패 (무시됨): $e');
    });

    // 콜백 호출
    onSingleComplete?.call(displayUrl);

    onProgressUpdate(1.0);

    // 모달 닫기
    if (context.mounted) {
      Navigator.pop(context);
      print('단일 이미지 업로드 완료 및 모달 닫기');
    }
  }

  /// 편집된 이미지 업로드
  Future<Map<String, dynamic>?> _uploadEditedImage(Uint8List bytes) async {
    try {
      return await MediaUploadService.uploadImageWithVariants(
        imageBytes: bytes,
        box: box,
        onModerationStatusUpdate: (status) =>
            _handleModerationStatusUpdate(status),
        onRejected: (reason) => _handleModerationRejected(reason),
      );
    } catch (e) {
      if (context.mounted) {
        String errorMessage = '이미지 업로드 실패';
        if (e.toString().contains('커뮤니티 가이드라인') ||
            e.toString().contains('부적절한')) {
          errorMessage = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.of(context).error,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
      return null;
    }
  }

  /// 추가 모드 처리
  Future<void> _handleAddMode(
    List<String> reorderedUrls,
    List<double> reorderedRatios,
    String editedDisplayUrl,
    double editedAspectRatio,
  ) async {
    print('추가 모드: 현재 인덱스 $currentIndex에서 이미지 추가');

    // 기존 이미지들을 그대로 복사
    if (existingImageUrls != null && existingAspectRatios != null) {
      reorderedUrls.addAll(existingImageUrls!);
      reorderedRatios.addAll(existingAspectRatios!);
    }

    // 새 이미지를 추가
    reorderedUrls.add(editedDisplayUrl);
    reorderedRatios.add(editedAspectRatio);

    print('새 이미지 추가 완료. 총 ${reorderedUrls.length}개 이미지');
  }

  /// 편집 모드 처리
  Future<void> _handleEditMode(
    List<String> reorderedUrls,
    List<double> reorderedRatios,
    String editedDisplayUrl,
    double editedAspectRatio,
  ) async {
    // 편집된 이미지를 맨 앞에 배치
    reorderedUrls.add(editedDisplayUrl);
    reorderedRatios.add(editedAspectRatio);
    print('편집된 이미지 업로드 완료 (썸네일)');

    // 첫 번째 이미지 즉시 프리캐싱
    await precacheImage(CachedNetworkImageProvider(editedDisplayUrl), context)
        .catchError((e) {
      print('첫 이미지 프리캐싱 실패 (무시됨): $e');
    });

    onProgressUpdate(0.4);

    // 나머지 이미지들 처리
    if (!isAddMode &&
        existingImageUrls != null &&
        existingAspectRatios != null &&
        existingImageUrls!.isNotEmpty) {
      await _reuseExistingImages(reorderedUrls, reorderedRatios);
    } else {
      await _uploadRemainingImages(reorderedUrls, reorderedRatios);
    }
  }

  /// 기존 이미지 재사용
  Future<void> _reuseExistingImages(
    List<String> reorderedUrls,
    List<double> reorderedRatios,
  ) async {
    for (int i = 0; i < existingImageUrls!.length; i++) {
      if (i != currentEditIndex) {
        reorderedUrls.add(existingImageUrls![i]);
        if (i < existingAspectRatios!.length) {
          reorderedRatios.add(existingAspectRatios![i]);
        }
      }
    }
    onProgressUpdate(0.8);
    print('기존 이미지 URL 재사용 완료');
  }

  /// 나머지 이미지들 업로드
  Future<void> _uploadRemainingImages(
    List<String> reorderedUrls,
    List<double> reorderedRatios,
  ) async {
    final uploadFutures = <Future<Map<String, dynamic>>>[];
    final fileBytesFutures = <Future<Uint8List>>[];

    // 파일 읽기 병렬 처리
    for (int i = 0; i < allSelectedFiles.length; i++) {
      if (i != currentEditIndex) {
        fileBytesFutures.add(allSelectedFiles[i].readAsBytes());
      }
    }

    if (fileBytesFutures.isEmpty) return;

    final allFileBytes = await Future.wait(fileBytesFutures);

    // 업로드 작업 병렬로 시작
    for (final fileBytes in allFileBytes) {
      uploadFutures.add(MediaUploadService.uploadImageWithVariants(
        imageBytes: fileBytes,
        box: box,
        onModerationStatusUpdate: (_) {},
        onRejected: (_) {},
      ).catchError((e) {
        print('[MediaSelection] 이미지 업로드 실패 (건너뜀): $e');
        return <String, dynamic>{
          'urls': {'display': '', 'original': '', 'thumbnail': ''},
          'aspectRatio': 1.0,
        };
      }));
    }

    onProgressUpdate(0.6);

    // 모든 업로드 완료 대기
    final results = await Future.wait(uploadFutures);

    // 결과 처리 및 프리캐싱
    final precacheFutures = <Future<void>>[];
    for (final result in results) {
      final displayUrl = result['urls']['display'];
      if (displayUrl != null && displayUrl.isNotEmpty) {
        reorderedUrls.add(displayUrl);
        reorderedRatios.add(result['aspectRatio']);

        // 백그라운드 프리캐싱
        precacheFutures.add(
            precacheImage(CachedNetworkImageProvider(displayUrl), context)
                .catchError((e) {
          print('프리캐싱 실패 (무시됨): $e');
        }));
      }
    }

    // 백그라운드 프리캐싱
    Future.wait(precacheFutures).then((_) {
      print('모든 이미지 프리캐싱 완료');
    });

    print('전체 이미지 처리 완료: ${reorderedUrls.length}개');
  }

  /// AssetEntity ID 재정렬
  List<String> _reorderAssetIds() {
    final reorderedAssetIds = <String>[];

    if (isAddMode) {
      // 추가 모드: 기존 ID들 + 새 ID
      if (existingAssetIds != null) {
        reorderedAssetIds.addAll(existingAssetIds!);
      }
      if (selectedAssets.isNotEmpty &&
          currentEditIndex < selectedAssets.length) {
        reorderedAssetIds.add(selectedAssets[currentEditIndex].id);
      }
    } else if (selectedAssets.isNotEmpty) {
      // 편집 모드: 편집된 이미지의 AssetEntity ID를 맨 앞에
      if (currentEditIndex < selectedAssets.length) {
        reorderedAssetIds.add(selectedAssets[currentEditIndex].id);
      }
      // 나머지 AssetEntity ID들
      for (int i = 0; i < selectedAssets.length; i++) {
        if (i != currentEditIndex) {
          reorderedAssetIds.add(selectedAssets[i].id);
        }
      }
    }

    return reorderedAssetIds;
  }

  /// MediaSelectionProvider 업데이트
  ///
  /// **Phase 3.6**: AppState.uploadImageA = ... → MediaSelectionProvider.setUploadedUrlsA
  void _updateAppState(
    List<String> reorderedUrls,
    List<double> reorderedRatios,
    List<String> reorderedAssetIds,
  ) {
    if (box == 'A') {
      ref.read(mediaSelectionProvider.notifier).setUploadedUrlsA(
        urls: reorderedUrls,
        aspectRatios: reorderedRatios,
        assetIds: reorderedAssetIds,
      );
    } else {
      ref.read(mediaSelectionProvider.notifier).setUploadedUrlsB(
        urls: reorderedUrls,
        aspectRatios: reorderedRatios,
        assetIds: reorderedAssetIds,
      );
    }
  }

  /// 검열 상태 업데이트 처리
  void _handleModerationStatusUpdate(String status) {
    print('[MediaSelection] 검열 상태 업데이트: $status');
    // 필요한 경우 구현
  }

  /// 검열 거부 처리
  void _handleModerationRejected(String reason) {
    print('[MediaSelection] 이미지 거부됨: $reason');
    // 필요한 경우 구현
  }
}
