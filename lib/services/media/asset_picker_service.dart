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
        // AssetEntity 복원 실패 시 무시
      }
    }
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
    // DevTools Layout Inspector로 대체 가능 - print 제거됨
  }

  /// 첫 5개 사진의 생성 날짜 디버깅 (카메라 버튼 클릭 시)
  static Future<void> debugPhotoOrder() async {
    // DevTools에서 asset 정보 확인 가능 - print 제거됨
    // Photo order debugging removed - use DevTools instead
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
