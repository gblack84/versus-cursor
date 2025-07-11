import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/app_state.dart';
import '/core/app_theme.dart';
import 'media_upload_service.dart';
import 'image_reorder_service.dart';

/// 이미지 선택 결과 처리 서비스
class SelectionResultProcessor {
  final BuildContext context;
  final AppState appState;
  final String box;
  final List<String>? existingAssetIds;
  final Function(double) onProgressUpdate;
  final Function(List<String>)? onMultiComplete;

  SelectionResultProcessor({
    required this.context,
    required this.appState,
    required this.box,
    this.existingAssetIds,
    required this.onProgressUpdate,
    this.onMultiComplete,
  });

  /// 선택 결과 처리
  Future<void> processSelectionResult(List<AssetEntity> selectedAssets) async {
    try {
      onProgressUpdate(0.1);
      
      // 기존 AssetEntity ID 목록
      final existingIds = existingAssetIds ?? [];
      final selectedIds = selectedAssets.map((e) => e.id).toList();
      
      // 삭제된 항목 찾기
      final removedIds = existingIds.where((id) => !selectedIds.contains(id)).toList();
      
      // 새로 추가된 항목 찾기
      final newAssets = selectedAssets.where((asset) => !existingIds.contains(asset.id)).toList();
      
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
      
      // 순서 재정렬 (선택된 순서대로)
      if (selectedIds.length == appState.assetEntityIdsA.length || 
          selectedIds.length == appState.assetEntityIdsB.length) {
        ImageReorderService.reorderImages(
          appState: appState,
          box: box,
          newOrder: selectedIds,
        );
      }
      
      onProgressUpdate(1.0);
      
      // 콜백 호출
      if (onMultiComplete != null) {
        final urls = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
        onMultiComplete!(urls);
      }
      
      // 모달 닫기
      if (context.mounted) {
        Navigator.pop(context);
        print('선택 완료 및 모달 닫기');
      }
    } catch (e) {
      print('선택 결과 처리 에러: $e');
      if (context.mounted) {
        onProgressUpdate(0.0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 처리 실패: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// 삭제 처리
  void _handleRemovals(List<String> removedIds) {
    appState.update(() {
      if (box == 'A') {
        // 삭제할 인덱스 찾기 (역순으로 삭제)
        for (final removedId in removedIds.reversed) {
          final index = appState.assetEntityIdsA.indexOf(removedId);
          if (index != -1) {
            appState.uploadImageA.removeAt(index);
            appState.uploadImageAspectRatioA.removeAt(index);
            appState.assetEntityIdsA.removeAt(index);
          }
        }
      } else {
        for (final removedId in removedIds.reversed) {
          final index = appState.assetEntityIdsB.indexOf(removedId);
          if (index != -1) {
            appState.uploadImageB.removeAt(index);
            appState.uploadImageAspectRatioB.removeAt(index);
            appState.assetEntityIdsB.removeAt(index);
          }
        }
      }
    });
  }

  /// 새 이미지 업로드 처리
  Future<void> _handleNewAssets(List<AssetEntity> newAssets) async {
    for (int i = 0; i < newAssets.length; i++) {
      final asset = newAssets[i];
      final file = await asset.file;
      if (file != null) {
        final bytes = await file.readAsBytes();
        
        onProgressUpdate(0.3 + (0.6 * (i + 1) / newAssets.length));
        
        Map<String, dynamic> result;
        String? newImageUrl;
        try {
          result = await MediaUploadService.uploadImageWithVariants(
            imageBytes: bytes,
            box: box,
            onModerationStatusUpdate: (status) => _handleModerationStatusUpdate(status, newImageUrl),
            onRejected: (reason) => _handleModerationRejected(reason, newImageUrl),
          );
        } catch (e) {
          // 업로드 실패 시
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이미지 업로드 실패: $e'),
                backgroundColor: AppTheme.of(context).error,
              ),
            );
          }
          continue; // 이 이미지 건너뛰고 계속
        }
        
        final displayUrl = result['urls']['display'];
        final aspectRatio = result['aspectRatio'];
        newImageUrl = displayUrl;
        
        // AppState에 추가
        appState.update(() {
          if (box == 'A') {
            appState.addToUploadImageA(displayUrl);
            appState.addToUploadImageAspectRatioA(aspectRatio);
            appState.addToAssetEntityIdsA(asset.id);
          } else {
            appState.addToUploadImageB(displayUrl);
            appState.addToUploadImageAspectRatioB(aspectRatio);
            appState.addToAssetEntityIdsB(asset.id);
          }
        });
        
        // 프리캐싱
        precacheImage(CachedNetworkImageProvider(displayUrl), context).catchError((e) {
          print('프리캐싱 실패 (무시됨): $e');
        });
      }
    }
  }

  /// 검열 상태 업데이트 처리
  void _handleModerationStatusUpdate(String status, String? imageUrl) {
    print('[MediaSelection] 추가 이미지 검열 상태 업데이트: $status');
    if (imageUrl != null && context.mounted) {
      appState.updateImageModerationStatus(
        imageUrl,
        status,
        isBoxA: box == 'A',
      );
    }
  }

  /// 검열 거부 처리
  void _handleModerationRejected(String reason, String? imageUrl) {
    print('[MediaSelection] 추가 이미지 거부됨: $reason');
    if (imageUrl != null && context.mounted) {
      // 거부된 이미지 제거
      if (box == 'A') {
        final imageIndex = appState.uploadImageA.indexOf(imageUrl);
        if (imageIndex >= 0) {
          appState.removeFromUploadImageA(imageUrl);
          if (imageIndex < appState.uploadImageAspectRatioA.length) {
            appState.removeAtIndexFromUploadImageAspectRatioA(imageIndex);
          }
          if (imageIndex < appState.assetEntityIdsA.length) {
            appState.removeAtIndexFromAssetEntityIdsA(imageIndex);
          }
        }
      } else {
        final imageIndex = appState.uploadImageB.indexOf(imageUrl);
        if (imageIndex >= 0) {
          appState.removeFromUploadImageB(imageUrl);
          if (imageIndex < appState.uploadImageAspectRatioB.length) {
            appState.removeAtIndexFromUploadImageAspectRatioB(imageIndex);
          }
          if (imageIndex < appState.assetEntityIdsB.length) {
            appState.removeAtIndexFromAssetEntityIdsB(imageIndex);
          }
        }
      }
      
      // 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
    }
  }
}