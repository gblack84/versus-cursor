import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import '/core_exports.dart';
import '/features/posts/presentation/delegates/korean_asset_picker_delegate.dart';
import '/features/posts/presentation/delegates/korean_camera_picker_delegate.dart';

class MediaSelectionService {
  /// 미디어 선택 결과
  static Future<MediaSelectionResult?> openAssetsPicker(
    BuildContext context,
    String box,
  ) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.common,
        themeColor: AppTheme.of(context).primary,
        textDelegate: const CustomKoreanAssetPickerTextDelegate(),
        gridCount: 4,
        specialItemPosition: SpecialItemPosition.prepend,
        specialItemBuilder: (BuildContext context, AssetPathEntity? path, int length) {
          return _buildCameraButton(context);
        },
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      return _processAssetEntity(result.first, box);
    }
    
    return null;
  }

  /// 카메라 버튼 빌드
  static Widget _buildCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final AssetEntity? entity = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
            enableRecording: true,
            textDelegate: const CustomKoreanCameraPickerTextDelegate(),
          ),
        );
        
        if (entity != null && context.mounted) {
          Navigator.of(context).pop([entity]);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '카메라',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AssetEntity 처리
  static Future<MediaSelectionResult?> _processAssetEntity(
    AssetEntity asset,
    String box,
  ) async {
    final file = await asset.file;
    
    if (file != null) {
      final isVideo = asset.type == AssetType.video;
      
      return MediaSelectionResult(
        file: file,
        isVideo: isVideo,
        box: box,
        assetEntity: asset,
      );
    }
    
    return null;
  }
}

/// 미디어 선택 결과 클래스
class MediaSelectionResult {
  final File file;
  final bool isVideo;
  final String box;
  final AssetEntity assetEntity;

  MediaSelectionResult({
    required this.file,
    required this.isVideo,
    required this.box,
    required this.assetEntity,
  });
}