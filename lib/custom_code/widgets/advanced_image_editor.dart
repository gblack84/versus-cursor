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

// --- Custom Imports for this Widget ---
import 'dart:convert';
import 'dart:typed_data';
import 'package:pro_image_editor/pro_image_editor.dart';
import '/custom_code/actions/finalize_and_save.dart' as action_blocks;

// [수정] custom_action을 인식하지 못하는 경우를 대비해 명시적으로 import

class AdvancedImageEditor extends StatefulWidget {
  const AdvancedImageEditor({
    Key? key,
    this.width,
    this.height,
    required this.originalVideoPath,
    required this.trimStart,
    required this.trimEnd,
    required this.rotation,
    required this.cropData,
    required this.coverTimestamp,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String originalVideoPath;
  final int trimStart;
  final int trimEnd;
  final int rotation;
  final String cropData;
  final int coverTimestamp;

  @override
  State<AdvancedImageEditor> createState() => _AdvancedImageEditorState();
}

class _AdvancedImageEditorState extends State<AdvancedImageEditor> {
  Uint8List? _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final String? base64Image = FFAppState().selectedCoverImageBytes;
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        _imageBytes = base64Decode(base64Image);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print("Base64 디코딩 실패: $e");
        _handleError();
      }
    } else {
      _handleError();
    }
  }

  void _handleError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('편집할 이미지를 불러오지 못했습니다.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ProImageEditor.memory(
      _imageBytes!,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List finalBytes) async {
          final String base64FinalImage = base64Encode(finalBytes);
          await action_blocks.finalizeAndSave(
            context,
            widget.originalVideoPath,
            widget.trimStart,
            widget.trimEnd,
            widget.rotation,
            widget.cropData,
            widget.coverTimestamp,
            base64FinalImage,
          );
        },
        onCloseEditor: () {
          Navigator.pop(context);
        },
      ),
      // [수정] configs 부분을 수정하여 버전에 맞게 변경
      configs: ProImageEditorConfigs(
        designMode: ImageEditorDesignModeE.material, // 'whatsapp' -> material
        i18n: I18n(
          done: '완료',
          cancel: '취소',
        ),
      ),
    );
  }
}
