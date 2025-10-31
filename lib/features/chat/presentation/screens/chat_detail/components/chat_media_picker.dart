import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:uuid/uuid.dart';
import '/core/constants/app_constants.dart';
import '/core/design_system/design_system.dart';
import '/app/di.dart';
import '/features/chat/domain/usecases/send_message_usecase.dart';
import '/features/chat/domain/entities/message.dart';

/// 채팅 미디어 피커 컴포넌트
///
/// **Clean Architecture v4.0 (리팩토링 완료)**:
/// - ✅ SendMessageUseCase를 통한 미디어 업로드 (Domain Layer)
/// - ✅ Data Layer 직접 의존 제거 (ChatMediaUploadService → Repository → UseCase)
/// - ✅ Presentation → Domain → Data 의존성 규칙 준수
/// - 이미지 압축 및 비디오 썸네일 자동 생성 (Repository 내부 처리)
class ChatMediaPicker {
  /// 미디어 옵션 다이얼로그 표시
  static Future<void> showMediaOptions(
    BuildContext context, {
    required String chatId,
    required String messageId,
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
                  await pickMediaFromGallery(
                    context,
                    chatId: chatId,
                    messageId: messageId,
                    onMediaSelected: onMediaSelected,
                  );
                },
              ),
              _buildMediaOption(
                context: context,
                icon: Icons.camera_alt,
                title: '카메라로 촬영',
                onTap: () async {
                  Navigator.pop(context);
                  await pickMediaFromCamera(
                    context,
                    chatId: chatId,
                    messageId: messageId,
                    onMediaSelected: onMediaSelected,
                  );
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
    required String chatId,
    required String messageId,
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
          chatId: chatId,
          messageId: messageId,
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
    required String chatId,
    required String messageId,
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
          chatId: chatId,
          messageId: messageId,
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
  ///
  /// **Clean Architecture v4.0 (리팩토링 완료)**:
  /// - ✅ SendMessageUseCase를 통한 미디어 업로드 (Domain Layer)
  /// - ✅ Repository → ChatMediaUploadService 내부 처리
  /// - 이미지: 자동 압축 (2MB 이하)
  /// - 비디오: 썸네일 자동 생성
  static Future<void> _uploadAndSendAsset(
    AssetEntity asset, {
    required String chatId,
    required String messageId,
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

      // GetIt으로 UseCase 가져오기 (DI)
      final sendMessageUseCase = getIt<SendMessageUseCase>();

      // Determine media type
      final String mediaType =
          asset.type == AssetType.video ? 'video' : AppConstants.messageTypeImage;

      // Create Message Entity
      final message = Message(
        id: messageId,
        parentPath: 'chats/$chatId',
        messageId: messageId,
        senderId: '', // 실제 사용 시 currentUserId 전달 필요
        content: '', // 미디어 메시지는 content 비어있음
        isRead: false,
        messageType: mediaType,
        mediaType: mediaType,
        timeStamp: DateTime.now(),
      );

      // UseCase를 통한 미디어 업로드 및 메시지 전송
      final result = await sendMessageUseCase.execute(
        chatId: chatId,
        message: message,
        eventId: const Uuid().v4(), // 중복 전송 방지용 UUID
        mediaFile: file, // ← UseCase가 업로드 처리!
      );

      // Result 처리
      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (_) {
          // 성공 시 콜백 호출 (업로드된 URL은 Firestore에서 가져옴)
          // TODO: Firestore에서 업로드된 메시지 URL 가져오기
          onMediaSelected('', mediaType);

          if (mediaType == AppConstants.messageTypeImage) {
            BotToast.showText(text: '이미지 업로드 완료!');
          } else {
            BotToast.showText(text: '비디오 업로드 완료!');
          }
        },
      );
    } catch (e) {
      BotToast.showText(
        text: '업로드 실패: ${e.toString()}',
        contentColor: VersusColors.error,
      );
    }
  }
}
