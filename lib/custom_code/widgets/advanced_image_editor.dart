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

// 필수 패키지를 import 합니다.
import 'dart:convert';
import 'dart:typed_data';
import 'package:pro_image_editor/pro_image_editor.dart';
import '/app_state.dart';

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
    // FFAppState에서 Base64로 인코딩된 이미지 문자열을 가져와 디코딩합니다.
    if (FFAppState().selectedCoverImageBytes.isNotEmpty) {
      try {
        _imageBytes = base64Decode(FFAppState().selectedCoverImageBytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      // 이미지 데이터가 없을 경우 에러 메시지를 표시합니다.
      return const Scaffold(
        body: Center(child: Text('이미지를 불러올 수 없습니다.')),
      );
    }

    // [최종 수정] 모든 커스텀 설정을 제거하고, 패키지가 제공하는 가장 기본적인 형태로 사용합니다.
    // 오직 필수 기능인 '이미지 로딩'과 '편집 완료 후 데이터 반환'에만 집중합니다.
    return ProImageEditor.memory(
      _imageBytes!,
      callbacks: ProImageEditorCallbacks(
        // 편집 완료 시 실행될 콜백 함수
        onImageEditingComplete: (Uint8List bytes) async {
          // 편집된 이미지 데이터를 FlutterFlow에서 사용할 수 있는 FFUploadedFile 형태로 변환합니다.
          final editedFile = FFUploadedFile(
            bytes: bytes,
            name: 'edited_image.jpg', // 파일 이름은 자유롭게 지정 가능
          );
          // 위젯 파라미터로 받은 onComplete 액션을 실행하여, 편집된 파일을 다음 로직으로 전달합니다.
          await widget.onComplete?.call(editedFile);
          // 작업 완료 후, 현재 에디터 화면을 닫습니다.
          if (mounted) Navigator.pop(context);
        },
        // 닫기 버튼을 눌렀을 때 실행될 콜백 함수
        onCloseEditor: () {
          // 현재 에디터 화면을 닫습니다.
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}
