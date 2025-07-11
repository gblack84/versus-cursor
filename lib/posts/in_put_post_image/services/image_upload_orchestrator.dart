import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/app_state.dart';
import 'media_upload_service.dart';

/// 이미지 업로드 프로세스를 조율하는 서비스 클래스
class ImageUploadOrchestrator {
  final BuildContext context;
  final AppState appState;
  final String box;
  
  ImageUploadOrchestrator({
    required this.context,
    required this.appState,
    required this.box,
  });

  /// 멀티 이미지 업로드 처리
  Future<ImageUploadResult> handleMultiImageUpload({
    required Uint8List editedImageBytes,
    required List<File> allFiles,
    required int currentEditIndex,
    required List<AssetEntity> selectedAssets,
    bool isAddMode = false,
    int? currentIndex,
    List<String>? existingImageUrls,
    List<double>? existingAspectRatios,
    List<String>? existingAssetIds,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
  }) async {
    final reorderedUrls = <String>[];
    final reorderedRatios = <double>[];
    final reorderedAssetIds = <String>[];

    try {
      // 1. 편집된 이미지 업로드 및 검열
      onModerationProgress?.call(1, allFiles.isEmpty ? 1 : allFiles.length);
      
      final editedResult = await MediaUploadService.uploadAndWaitForModeration(
        imageBytes: editedImageBytes,
        box: box,
        timeout: const Duration(seconds: 15),
      );
      
      // 검열 결과 확인
      if (editedResult['isApproved'] != true) {
        return ImageUploadResult(
          success: false,
          rejectionReason: editedResult['rejectionReason'] ?? '커뮤니티 가이드라인 위반',
        );
      }
      
      final editedDisplayUrl = editedResult['urls']['display'] as String;
      final editedAspectRatio = editedResult['aspectRatio'] as double;
      
      // 2. 추가 모드 처리
      if (isAddMode && currentIndex != null) {
        // 기존 이미지들을 그대로 복사
        if (existingImageUrls != null && existingAspectRatios != null) {
          reorderedUrls.addAll(existingImageUrls);
          reorderedRatios.addAll(existingAspectRatios);
        }
        
        // 새 이미지를 추가
        reorderedUrls.add(editedDisplayUrl);
        reorderedRatios.add(editedAspectRatio);
      } else {
        // 편집된 이미지를 맨 앞에 배치
        reorderedUrls.add(editedDisplayUrl);
        reorderedRatios.add(editedAspectRatio);
      }
      
      // 첫 번째 이미지 즉시 프리캐싱
      await _precacheImage(editedDisplayUrl);
      onProgress?.call(0.4);
      
      // 3. 나머지 이미지들 처리
      if (!isAddMode && existingImageUrls != null && existingImageUrls.isNotEmpty) {
        // 기존 URL 재사용 모드
        await _reuseExistingImages(
          existingImageUrls: existingImageUrls,
          existingAspectRatios: existingAspectRatios ?? [],
          currentEditIndex: currentEditIndex,
          reorderedUrls: reorderedUrls,
          reorderedRatios: reorderedRatios,
        );
        onProgress?.call(0.8);
      } else {
        // 새로 업로드 모드
        await _uploadRemainingImages(
          allFiles: allFiles,
          currentEditIndex: currentEditIndex,
          reorderedUrls: reorderedUrls,
          reorderedRatios: reorderedRatios,
          onProgress: onProgress,
        );
      }
      
      // 4. AssetEntity ID 순서 맞추기
      _reorderAssetIds(
        isAddMode: isAddMode,
        existingAssetIds: existingAssetIds,
        selectedAssets: selectedAssets,
        currentEditIndex: currentEditIndex,
        reorderedAssetIds: reorderedAssetIds,
      );
      
      // 5. AppState 업데이트
      _updateAppState(
        reorderedUrls: reorderedUrls,
        reorderedRatios: reorderedRatios,
        reorderedAssetIds: reorderedAssetIds,
      );
      
      onProgress?.call(1.0);
      
      return ImageUploadResult(
        success: true,
        imageUrls: reorderedUrls,
        aspectRatios: reorderedRatios,
        assetIds: reorderedAssetIds,
      );
      
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 단일 이미지 업로드 처리
  Future<ImageUploadResult> handleSingleImageUpload({
    required Uint8List imageBytes,
    required List<AssetEntity> selectedAssets,
    bool isEditMode = false,
    Function(double)? onProgress,
    Function()? onModerationStart,
  }) async {
    try {
      onModerationStart?.call();
      
      final result = await MediaUploadService.uploadAndWaitForModeration(
        imageBytes: imageBytes,
        box: box,
        timeout: const Duration(seconds: 15),
      );
      
      // 검열 결과 확인
      if (result['isApproved'] != true) {
        return ImageUploadResult(
          success: false,
          rejectionReason: result['rejectionReason'] ?? '커뮤니티 가이드라인 위반',
        );
      }
      
      final displayUrl = result['urls']['display'] as String;
      final aspectRatio = result['aspectRatio'] as double;
      
      onProgress?.call(0.9);
      
      // 편집 모드가 아닐 때만 AppState에 추가
      if (!isEditMode) {
        appState.update(() {
          if (box == 'A') {
            appState.addToUploadImageA(displayUrl);
            appState.addToUploadImageAspectRatioA(aspectRatio);
            if (selectedAssets.isNotEmpty) {
              appState.addToAssetEntityIdsA(selectedAssets.first.id);
            }
          } else {
            appState.addToUploadImageB(displayUrl);
            appState.addToUploadImageAspectRatioB(aspectRatio);
            if (selectedAssets.isNotEmpty) {
              appState.addToAssetEntityIdsB(selectedAssets.first.id);
            }
          }
        });
      }
      
      // 프리캐싱
      await _precacheImage(displayUrl);
      onProgress?.call(1.0);
      
      return ImageUploadResult(
        success: true,
        imageUrls: [displayUrl],
        aspectRatios: [aspectRatio],
      );
      
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 이미지 프리캐싱
  Future<void> _precacheImage(String url) async {
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (e) {
      print('프리캐싱 실패 (무시됨): $e');
    }
  }

  /// 기존 이미지 재사용
  Future<void> _reuseExistingImages({
    required List<String> existingImageUrls,
    required List<double> existingAspectRatios,
    required int currentEditIndex,
    required List<String> reorderedUrls,
    required List<double> reorderedRatios,
  }) async {
    for (int i = 0; i < existingImageUrls.length; i++) {
      if (i != currentEditIndex) {
        reorderedUrls.add(existingImageUrls[i]);
        if (i < existingAspectRatios.length) {
          reorderedRatios.add(existingAspectRatios[i]);
        }
      }
    }
  }

  /// 나머지 이미지 업로드
  Future<void> _uploadRemainingImages({
    required List<File> allFiles,
    required int currentEditIndex,
    required List<String> reorderedUrls,
    required List<double> reorderedRatios,
    Function(double)? onProgress,
  }) async {
    final uploadFutures = <Future<Map<String, dynamic>>>[];
    final fileBytesFutures = <Future<Uint8List>>[];
    
    // 파일 읽기를 먼저 병렬로 처리
    for (int i = 0; i < allFiles.length; i++) {
      if (i != currentEditIndex) {
        fileBytesFutures.add(allFiles[i].readAsBytes());
      }
    }
    
    if (fileBytesFutures.isNotEmpty) {
      final allFileBytes = await Future.wait(fileBytesFutures);
      
      // 업로드 작업을 병렬로 시작
      for (final fileBytes in allFileBytes) {
        uploadFutures.add(
          MediaUploadService.uploadImageWithVariants(
            imageBytes: fileBytes,
            box: box,
          ).catchError((e) {
            print('[ImageUploadOrchestrator] 이미지 업로드 실패 (건너뜀): $e');
            return <String, dynamic>{
              'urls': {'display': '', 'original': '', 'thumbnail': ''},
              'aspectRatio': 1.0,
            };
          })
        );
      }
      
      onProgress?.call(0.6);
      
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
          precacheFutures.add(_precacheImage(displayUrl));
        }
      }
      
      // 나머지 이미지들은 백그라운드에서 계속 프리캐싱
      Future.wait(precacheFutures).then((_) {
        print('모든 이미지 프리캐싱 완료');
      });
    }
  }

  /// AssetEntity ID 재정렬
  void _reorderAssetIds({
    required bool isAddMode,
    required List<String>? existingAssetIds,
    required List<AssetEntity> selectedAssets,
    required int currentEditIndex,
    required List<String> reorderedAssetIds,
  }) {
    if (isAddMode) {
      // 추가 모드: 기존 ID들 + 새 ID
      if (existingAssetIds != null) {
        reorderedAssetIds.addAll(existingAssetIds);
      }
      if (selectedAssets.isNotEmpty && currentEditIndex < selectedAssets.length) {
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
  }

  /// AppState 업데이트
  void _updateAppState({
    required List<String> reorderedUrls,
    required List<double> reorderedRatios,
    required List<String> reorderedAssetIds,
  }) {
    appState.update(() {
      if (box == 'A') {
        appState.uploadImageA = reorderedUrls;
        appState.uploadImageAspectRatioA = reorderedRatios;
        appState.assetEntityIdsA = reorderedAssetIds;
      } else {
        appState.uploadImageB = reorderedUrls;
        appState.uploadImageAspectRatioB = reorderedRatios;
        appState.assetEntityIdsB = reorderedAssetIds;
      }
    });
  }
}

/// 이미지 업로드 결과 클래스
class ImageUploadResult {
  final bool success;
  final List<String>? imageUrls;
  final List<double>? aspectRatios;
  final List<String>? assetIds;
  final String? rejectionReason;
  final String? error;

  ImageUploadResult({
    required this.success,
    this.imageUrls,
    this.aspectRatios,
    this.assetIds,
    this.rejectionReason,
    this.error,
  });
}