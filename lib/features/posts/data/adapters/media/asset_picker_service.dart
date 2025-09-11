import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/core_exports.dart';

/// Asset Picker 관련 로직을 담당하는 서비스
class AssetPickerService {
  /// AssetEntity ID 목록에서 AssetEntity 복원
  static Future<List<AssetEntity>> restoreAssetsFromIds(
      List<String>? assetIds) async {
    if (assetIds == null || assetIds.isEmpty) {
      return [];
    }

    final restoredAssets = <AssetEntity>[];
    for (String id in assetIds) {
      try {
        final asset = await AssetEntity.fromId(id);
        if (asset != null) {
          restoredAssets.add(asset);
        }
      } catch (e) {
        print('AssetEntity 복원 실패 (ID: $id): $e');
      }
    }
    print('[AssetPickerService] 복원된 AssetEntity 개수: ${restoredAssets.length}');
    return restoredAssets;
  }

  /// 피커 테마 생성
  static ThemeData createPickerTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: AppTheme.of(context).primary,
        secondary: AppTheme.of(context).primary,
        surface: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.of(context).primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.of(context).primary,
        ),
      ),
    );
  }

  /// 피커 설정 로그 출력
  static void logPickerConfig({
    required String box,
    required bool isAddMode,
    required int existingAssetsCount,
    required int selectedAssetsCount,
  }) {
    print('[AssetPicker] Opening picker...');
    print('[AssetPicker] Box: $box');
    print('[AssetPicker] isAddMode: $isAddMode');
    print('[AssetPicker] existingAssetIds: $existingAssetsCount');
    print('[AssetPicker] Config:');
    print('  - Max assets: 4');
    print('  - Special item position: NONE (using floating camera button)');
    print('  - Selected assets count: $selectedAssetsCount');
    print('  - Grid count: 4');
    print('  - Sort by modified date: true');
    print('  - Should revert grid: false (최신 사진 맨 위)');
  }

  /// 첫 5개 사진의 생성 날짜 디버깅 (카메라 버튼 클릭 시)
  static Future<void> debugPhotoOrder() async {
    try {
      final paths =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (paths.isNotEmpty) {
        final firstPath = paths.first;
        final assets = await firstPath.getAssetListPaged(page: 0, size: 5);
        print('[AssetPicker] 첫 5개 사진 생성 날짜:');
        for (int i = 0; i < assets.length; i++) {
          final asset = assets[i];
          final createDate = asset.createDateTime;
          print(
              '  ${i + 1}. ${createDate.toString()} - ${asset.title ?? "No title"}');
        }
      }
    } catch (e) {
      print('[AssetPicker] 정렬 디버깅 실패: $e');
    }
  }

  /// 기본 피커 Provider 생성
  static DefaultAssetPickerProvider createProvider({
    required List<AssetEntity> selectedAssets,
  }) {
    return DefaultAssetPickerProvider(
      selectedAssets: selectedAssets,
      maxAssets: 4,
      requestType: RequestType.image,
      sortPathsByModifiedDate: true, // 최신 사진을 맨 위에 표시
    );
  }
}
