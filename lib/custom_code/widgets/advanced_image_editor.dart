// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets
import 'package.flutter/material.dart';

import 'dart:typed_data';
import 'package:pro_image_editor/pro_image_editor.dart';
import '/app_state.dart'; // Added to use FFAppState

// --- Theme colors (Unified with video editor) ---
const kAccentColor = Color(0xFFFFD600);
const kBackgroundColor = Colors.black;

class AdvancedImageEditor extends StatefulWidget {
  const AdvancedImageEditor({
    Key? key,
    this.width,
    this.height,
    // [Added] Parameters to receive from the video editor page
    this.originalVideoPath,
    this.startMs,
    this.endMs,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? originalVideoPath;
  final int? startMs;
  final int? endMs;

  @override
  _AdvancedImageEditorState createState() => _AdvancedImageEditorState();
}

class _AdvancedImageEditorState extends State<AdvancedImageEditor> {
  // Variable to store the image data to be edited
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    // Get the cover image data from AppState
    _imageBytes = FFAppState().interimCoverBytes?.bytes;
  }

  // Final upload and server request function to be implemented in Phase 4
  void _finalizeAndUpload(Uint8List editedImageBytes) {
    // TODO: Implement checklist step 11 logic
    // 1. Show loading indicator
    // 2. Upload edited cover image (editedImageBytes) to Firebase Storage
    // 3. Upload original video (widget.originalVideoPath) to GCS
    // 4. Send the URLs of both files and time values (widget.startMs, widget.endMs) to the server API
    // 5. Navigate to another page after the task is completed

    print('Final "Done" button clicked!');
    print(' - Original Video Path: ${widget.originalVideoPath}');
    print(' - Start Time (ms): ${widget.startMs}');
    print(' - End Time (ms): ${widget.endMs}');
    print(' - Edited Cover Image Size: ${editedImageBytes.length} bytes');

    // Temporary logic to go back to the previous pages
    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Close the video editor as well
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if image data is not available
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
          // Call the final upload function when the 'Done' button is pressed
          _finalizeAndUpload(bytes);
        },
        onCloseEditor: () {
          Navigator.of(context).pop();
        },
      ),
      // [Modified] Configurations for UI style unification and feature management
      configs: ProImageEditorConfigs(
        designMode: ImageEditorDesignModeE.material,

        // --- Unify UI Theme ---
        imageEditorTheme: const ImageEditorTheme(
          mainEditor: MainEditorTheme(
            backgroundColor: kBackgroundColor,
            appBarBackgroundColor: kBackgroundColor,
            bottomBarBackgroundColor: kBackgroundColor,
          ),
        ),

        // --- [수정] 아이콘 크기만 살짝 키움 ---
        icons: const ImageEditorIcons(
          painting: Icon(Icons.brush, size: 30),
          text: Icon(Icons.title, size: 30),
          crop: Icon(Icons.crop, size: 30),
          filter: Icon(Icons.filter, size: 30),
          blur: Icon(Icons.blur_on, size: 30),
          emoji: Icon(Icons.sentiment_satisfied_alt, size: 30),
          sticker: Icon(Icons.sticky_note_2, size: 30),
          back: Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 28), // 상단바 아이콘은 그대로
          done: Text(
            // 'Done' 텍스트 버튼으로 통일
            'Done',
            style: TextStyle(
              color: kAccentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // All features are enabled as requested.
        paintEditorConfigs: const PaintEditorConfigs(),
        textEditorConfigs: const TextEditorConfigs(),
        cropRotateEditorConfigs: const CropRotateEditorConfigs(),
        filterEditorConfigs: const FilterEditorConfigs(),
        blurEditorConfigs: const BlurEditorConfigs(),
        emojiEditorConfigs: const EmojiEditorConfigs(),
        stickerEditorConfigs: const StickerEditorConfigs(),

        // UI text is set to English
        i18n: const I18n(
          mainEditor: I18nMainEditor(
            bottomNavigationBarText: [
              'Crop',
              'Paint',
              'Text',
              'Filter',
              'Sticker',
              'Emoji',
              'Blur'
            ],
          ),
        ),
      ),
    );
  }
}
