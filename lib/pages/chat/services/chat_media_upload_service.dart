import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:uuid/uuid.dart';
import '/features/common/presentation/design_system/design_system.dart';
import '/backend/backend.dart';
import '/features/auth/data/services/auth_util.dart';
import '/core_exports.dart';
import 'chat_file_size_service.dart';

/// 채팅 미디어 업로드 서비스
class ChatMediaUploadService {
  static const _uuid = Uuid();
  
  /// 갤러리에서 미디어 선택
  static Future<void> pickMediaFromGallery({
    required BuildContext context,
    required ChatsModel chatDocument,
    required Function(String url, String type, String? localPath) onMediaUploaded,
  }) async {
    try {
      // Pick assets using wechat_assets_picker
      final List<AssetEntity>? selectedAssets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 10,
          requestType: RequestType.common,
          specialPickerType: SpecialPickerType.noPreview,
          pickerTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: VersusColors.primary,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );

      if (selectedAssets != null && selectedAssets.isNotEmpty) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(VersusColors.primary),
            ),
          ),
        );
        
        for (final asset in selectedAssets) {
          await _uploadAndSendAsset(
            asset: asset,
            chatDocument: chatDocument,
            onMediaUploaded: onMediaUploaded,
          );
        }
        
        Navigator.of(context).pop(); // Hide loading
      }
    } catch (e) {
      debugPrint('Error picking media from gallery: $e');
      BotToast.showText(text: '갤러리에서 미디어를 선택하는 중 오류가 발생했습니다.');
    }
  }
  
  /// 카메라로 미디어 촬영
  static Future<void> pickMediaFromCamera({
    required BuildContext context,
    required ChatsModel chatDocument,
    required Function(String url, String type, String? localPath) onMediaUploaded,
  }) async {
    try {
      // Pick from camera using wechat_camera_picker
      final AssetEntity? pickedAsset = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          maximumRecordingDuration: Duration(seconds: 60),
        ),
      );

      if (pickedAsset != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(VersusColors.primary),
            ),
          ),
        );
        
        await _uploadAndSendAsset(
          asset: pickedAsset,
          chatDocument: chatDocument,
          onMediaUploaded: onMediaUploaded,
        );
        
        Navigator.of(context).pop(); // Hide loading
      }
    } catch (e) {
      debugPrint('Error picking media from camera: $e');
      BotToast.showText(text: '카메라에서 미디어를 촬영하는 중 오류가 발생했습니다.');
    }
  }
  
  /// Upload asset to Firebase Storage and send as message
  static Future<void> _uploadAndSendAsset({
    required AssetEntity asset,
    required ChatsModel chatDocument,
    required Function(String url, String type, String? localPath) onMediaUploaded,
  }) async {
    try {
      // Get file from asset
      final File? file = await asset.file;
      if (file == null) return;

      // Determine media type
      final bool isVideo = asset.type == AssetType.video;
      final String mediaType = isVideo ? 'video' : 'image';
      
      // Generate unique filename
      final String fileName = '${_uuid.v4()}.${file.path.split('.').last}';
      final String storagePath = 'chat_media/${chatDocument.reference.id}/$fileName';
      
      // Upload to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final UploadTask uploadTask = storageRef.putFile(file);
      
      // Get download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Callback with uploaded media info
      onMediaUploaded(downloadUrl, mediaType, file.path);
    } catch (e) {
      debugPrint('Error uploading asset: $e');
      BotToast.showText(text: '미디어 업로드 중 오류가 발생했습니다.');
    }
  }
  
  /// 미디어 메시지 전송
  static Future<void> sendMediaMessage({
    required ChatsModel chatDocument,
    required String mediaUrl,
    required String mediaType,
    String? localPath,
  }) async {
    final messageId = const Uuid().v4();
    final fileSizeService = ChatFileSizeService();
    
    // Calculate file size
    int fileSize = 0;
    if (localPath != null) {
      fileSize = await fileSizeService.getLocalFileSize(localPath);
    } else if (mediaUrl.isNotEmpty) {
      fileSize = await fileSizeService.calculateMediaSize(mediaUrl);
    }
    
    // Create message in Firestore with media fields
    await MessagesModel.createDoc(chatDocument.reference)
        .set(createMessagesModelData(
      messageId: messageId,
      content: '',
      senderId: currentUserUid,
      timeStamp: getCurrentTimestamp(),
      mediaType: mediaType,
      imageUrl: mediaType == 'image' ? mediaUrl : '',
      videoUrl: mediaType == 'video' ? mediaUrl : '',
      mediaSize: fileSize,
    ));
    
    // Update chat metadata
    await chatDocument.reference.update({
      ...createChatsModelData(
        lastMessageContent: mediaType == 'image' ? '📷 사진' : '📹 비디오',
        lastMessageAt: getCurrentTimestamp(),
      ),
      'participantIds': FieldValue.arrayUnion([currentUserUid]),
    });
  }
}