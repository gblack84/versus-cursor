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

// NewFFVideoEditorView 위젯 (최종 수정본)

import 'dart:io';
import 'dart:convert';
import 'package:video_editor/video_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path; // path 패키지 import 추가

// 우리가 만든 커스텀 액션들을 import 합니다.
import '/custom_code/actions/get_signed_url.dart' as action_get_signed_url;
import '/custom_code/actions/upload_to_gcs.dart' as action_upload_to_gcs;
import '/custom_code/actions/postencode.dart' as action_post_encode;
import '/custom_code/actions/generate_cover_image.dart'
    as action_generate_cover;

const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);

/// ======================================================================= │
/// 1단계: 영상 편집 및 인코딩 시작 위젯
/// =======================================================================
class NewFFVideoEditorView extends StatefulWidget {
  const NewFFVideoEditorView({
    Key? key,
    required this.videoPath,
    required this.videoDocRef,
    required this.postId,
    this.width,
    this.height,
  }) : super(key: key);

  final String videoPath;
  final DocumentReference videoDocRef;
  final String postId;
  final double? width;
  final double? height;

  @override
  State<NewFFVideoEditorView> createState() => _NewFFVideoEditorViewState();
}

class _NewFFVideoEditorViewState extends State<NewFFVideoEditorView> {
  late final VideoEditorController _controller = VideoEditorController.file(
    File(widget.videoPath),
    maxDuration: const Duration(seconds: 60),
  );
  bool _isProcessing = false;
  String _processingStatus = '';

  @override
  void initState() {
    super.initState();
    _controller.initialize(aspectRatio: 9 / 16).then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // [수정됨] 새로운 GCS 직접 업로드 로직
  Future<void> _startUploadFlow() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = '업로드 티켓 요청 중...';
    });

    try {
      // 1. 업로드 티켓(Signed URL) 요청
      final fileName = path.basename(widget.videoPath);
      final dynamic signedUrlResult =
          await action_get_signed_url.getSignedUrl(fileName, 'video/mp4');

      if (signedUrlResult == null) throw Exception('Signed URL 받기 실패');

      final String signedUrl = signedUrlResult['signedUrl'];
      final String gcsPath = signedUrlResult['gcsPath'];

      // 2. GCS로 직접 파일 업로드
      setState(() => _processingStatus = '파일 업로드 중...');
      final bool uploadSuccess = await action_upload_to_gcs.uploadToGCS(
          signedUrl, widget.videoPath, 'video/mp4');

      if (!uploadSuccess) throw Exception('GCS에 파일 업로드 실패');

      // 3. 백엔드에 인코딩 작업 지시
      setState(() => _processingStatus = '서버에 처리 요청 중...');
      final params = {
        'postId': widget.postId,
        'docId': widget.videoDocRef.id,
        'start_ms': _controller.startTrim.inMilliseconds,
        'end_ms': _controller.endTrim.inMilliseconds,
        'rotate': _controller.rotation,
        'crop':
            '${_controller.minCrop.dx},${_controller.minCrop.dy},${_controller.maxCrop.dx},${_controller.maxCrop.dy}',
      };

      // 수정된 postencode 액션 호출
      await action_post_encode.postencode(gcsPath, jsonEncode(params));

      if (!mounted) return;

      // 4. 모든 것이 성공하면 커버 편집 화면으로 이동
      // [중요] 이제 gcsPath를 전달합니다.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoverAndTextView(
            controller: _controller,
            gcsPath: gcsPath, // videoPath 대신 gcsPath 전달
            videoDocRef: widget.videoDocRef,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: CropGridViewer.preview(controller: _controller)),
            TrimSlider(controller: _controller, height: 60),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startUploadFlow,
                child: _isProcessing
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(width: 8),
                        Text(_processingStatus)
                      ])
                    : const Text('Next >'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// │ 2단계: 커버 & 텍스트 편집 및 최종 저장 위젯
// =======================================================================
class CoverAndTextView extends StatefulWidget {
  const CoverAndTextView({
    super.key,
    required this.controller,
    required this.gcsPath, // videoPath -> gcsPath로 변경
    required this.videoDocRef,
  });

  final VideoEditorController controller;
  final String gcsPath; // videoPath -> gcsPath로 변경
  final DocumentReference videoDocRef;

  @override
  State<CoverAndTextView> createState() => _CoverAndTextViewState();
}

class _CoverAndTextViewState extends State<CoverAndTextView> {
  final _textCtl = TextEditingController();
  bool _isSaving = false;

  Future<void> _generateAndSaveCover() async {
    setState(() => _isSaving = true);
    try {
      final coverTimeMs = widget.controller.selectedCoverVal?.timeMs;
      if (coverTimeMs == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('커버 프레임을 선택해주세요.')));
        setState(() => _isSaving = false);
        return;
      }

      // 1. 수정된 /generate-cover API 호출
      final String? thumbUrl = await action_generate_cover.generateCoverImage(
        widget.gcsPath, // videoPath 대신 gcsPath 사용
        widget.videoDocRef.id,
        coverTimeMs.toInt(),
        _textCtl.text,
      );

      if (thumbUrl == null) throw Exception('Cover generation failed.');

      // 2. Firestore에 최종 정보 업데이트
      await widget.videoDocRef.update({
        'thumbUrl': thumbUrl,
        'status': 'done',
        'duration': widget.controller.trimmedDuration.inMilliseconds,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('업로드 완료!')));

      int popCount = 0;
      Navigator.of(context).popUntil((_) => popCount++ >= 2);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _textCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... build 메서드는 기존과 동일하므로 생략 ...
  }
}
