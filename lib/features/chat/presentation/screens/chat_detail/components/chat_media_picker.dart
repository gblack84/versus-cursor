import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:uuid/uuid.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/data/adapters/chat_file_size_service.dart';

/// 채팅 미디어 피커 컴포넌트
///
/// 갤러리 및 카메라에서 미디어를 선택하는 기능을 제공합니다.
class ChatMediaPicker {
  static final _fileSizeService = ChatFileSizeService();
  static const _uuid = Uuid();

  /// 미디어 옵션 다이얼로그 표시
  static Future<void> showMediaOptions(
    BuildContext context, {
    required Function(String url, String type) onMediaSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: VersusColors.backgroundPrimary,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VersusColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMediaOption(
                context: context,
                icon: Icons.photo_library,
                title: '갤러리에서 선택',
                onTap: () async {
                  Navigator.pop(context);
                  await pickMediaFromGallery(context,
                      onMediaSelected: onMediaSelected);
                },
              ),
              _buildMediaOption(
                context: context,
                icon: Icons.camera_alt,
                title: '카메라로 촬영',
                onTap: () async {
                  Navigator.pop(context);
                  await pickMediaFromCamera(context,
                      onMediaSelected: onMediaSelected);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 미디어 옵션 위젯 빌드
  static Widget _buildMediaOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: VersusColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: VersusColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: VersusTextStyles.bodyLarge.copyWith(
                    color: VersusColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: VersusColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 갤러리에서 미디어 선택
  static Future<void> pickMediaFromGallery(
    BuildContext context, {
    required Function(String url, String type) onMediaSelected,
  }) async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.common,
          themeColor: VersusColors.primary,
        ),
      );

      if (result != null && result.isNotEmpty) {
        await _uploadAndSendAsset(
          result.first,
          onMediaSelected: onMediaSelected,
        );
      }
    } catch (e) {
      BotToast.showText(
        text: '미디어 선택 중 오류가 발생했습니다',
        contentColor: VersusColors.error,
      );
    }
  }

  /// 카메라로 미디어 촬영
  static Future<void> pickMediaFromCamera(
    BuildContext context, {
    required Function(String url, String type) onMediaSelected,
  }) async {
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          enableRecording: true,
          textDelegate: const CameraPickerTextDelegate(),
        ),
      );

      if (result != null) {
        await _uploadAndSendAsset(
          result,
          onMediaSelected: onMediaSelected,
        );
      }
    } catch (e) {
      BotToast.showText(
        text: '카메라 촬영 중 오류가 발생했습니다',
        contentColor: VersusColors.error,
      );
    }
  }

  /// 미디어 업로드 및 전송
  static Future<void> _uploadAndSendAsset(
    AssetEntity asset, {
    required Function(String url, String type) onMediaSelected,
  }) async {
    try {
      // Show uploading toast
      BotToast.showText(text: '업로드 중...');

      // Get file
      final File? file = await asset.file;
      if (file == null) {
        throw Exception('파일을 가져올 수 없습니다');
      }

      // Check file size
      if (!await _fileSizeService.checkFileSize(file)) {
        BotToast.showText(
          text: '파일 크기가 너무 큽니다 (최대 10MB)',
          contentColor: VersusColors.error,
        );
        return;
      }

      // Generate unique filename
      final String extension = asset.mimeType?.split('/').last ?? 'jpg';
      final String fileName = '${_uuid.v4()}.$extension';
      final String storagePath = 'chat_media/$fileName';

      // Upload to Firebase Storage
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(storagePath);
      final UploadTask uploadTask = storageRef.putFile(file);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Determine media type
      final String mediaType =
          asset.type == AssetType.video ? 'video' : 'image';

      // Call callback with URL and type
      onMediaSelected(downloadUrl, mediaType);

      BotToast.showText(text: '업로드 완료!');
    } catch (e) {
      BotToast.showText(
        text: '업로드 실패: ${e.toString()}',
        contentColor: VersusColors.error,
      );
    }
  }
}
