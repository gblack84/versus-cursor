// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:pro_image_editor/pro_image_editor.dart';
import '/app_state.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // 이모지 피커를 위해 추가

const kAccentColor = Color(0xFFFFD600);
const kBackgroundColor = Colors.black;

class AdvancedImageEditor extends StatefulWidget {
  const AdvancedImageEditor({
    Key? key,
    this.width,
    this.height,
    this.originalVideoPath,
    this.startMs,
    this.endMs,
    this.postId,
    this.onComplete,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? originalVideoPath;
  final int? startMs;
  final int? endMs;
  final String? postId;
  final Future<void> Function(FFUploadedFile? editedImageFile)? onComplete;

  @override
  _AdvancedImageEditorState createState() => _AdvancedImageEditorState();
}

class _AdvancedImageEditorState extends State<AdvancedImageEditor> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (FFAppState().selectedCoverImageBytes.isNotEmpty) {
      _imageBytes = base64Decode(FFAppState().selectedCoverImageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: kAccentColor)),
      );
    }

    return ProImageEditor.memory(
      _imageBytes!,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          final editedFile = FFUploadedFile(bytes: bytes);
          await widget.onComplete?.call(editedFile);
        },
        onCloseEditor: () {
          Navigator.of(context).pop();
        },
      ),
      configs: ProImageEditorConfigs(
        designMode: ImageEditorDesignModeE.material,
        imageEditorTheme: const ImageEditorTheme(
          mainEditor: MainEditorTheme(
            backgroundColor: kBackgroundColor,
            appBarBackgroundColor: kBackgroundColor,
            bottomBarBackgroundColor: kBackgroundColor,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // 스티커 에디터 설정을 '이모지'를 사용하도록 수정
        stickerEditorConfigs: StickerEditorConfigs(
          enabled: true,
          buildStickers: (setLayer) {
            return (scrollController) => EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setLayer(
                      EmojiLayerData(
                        emoji: emoji.emoji,
                        offset: const Offset(0, 0),
                      ),
                    );
                  },
                  config: const Config(
                    columns: 8,
                    emojiSizeMax: 32 * 1.2,
                    bgColor: kBackgroundColor,
                    indicatorColor: kAccentColor,
                  ),
                );
          },
        ),
        i18n: const I18n(
          mainEditor: I18nMainEditor(
            // 하단 메뉴에 'Sticker'를 포함하여 모든 기능 표시
            bottomNavigationBarText: [
              'Crop',
              'Paint',
              'Text',
              'Filter',
              'Sticker', // 스티커 메뉴 활성화
              'Emoji',
              'Blur'
            ],
          ),
        ),
      ),
    );
  }
}
