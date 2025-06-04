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

/* 외부 import */

import 'package:video_editor/video_editor.dart';

/* ─ 팔레트 ─ */
const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);
const kTextDim = Colors.white54;

class FFCoverEditorView extends StatefulWidget {
  const FFCoverEditorView({
    super.key,
    required this.controller,
    required this.videoPath,
    required this.params, // trim / crop / rotate / overlay
    this.width,
    this.height,
  });

  final VideoEditorController controller;
  final String videoPath;
  final Map<String, dynamic> params;
  final double? width, height;

  @override
  State<FFCoverEditorView> createState() => _FFCoverEditorViewState();
}

class _FFCoverEditorViewState extends State<FFCoverEditorView> {
  final _textCtl = TextEditingController();
  Offset _pos = Offset.zero;

  @override
  void dispose() {
    _textCtl.dispose();
    super.dispose();
  }

  /* UI */
  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? MediaQuery.of(context).size.width;
    final h = widget.height ?? MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _preview()),
            _selectionBar(),
          ],
        ),
      ),
    );
  }

  /* ─ 상단 바 ─ */
  Widget _topBar() => Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: kAccent),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: kAccent,
              side: const BorderSide(color: kAccent),
            ),
            onPressed: _exportMp4,
            child: const Text('EXPORT', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
        ],
      );

  /* ─ 미리보기 ─ */
  Widget _preview() => Stack(
        children: [
          Center(child: CoverViewer(controller: widget.controller)),
          Positioned(
            left: _pos.dx,
            top: _pos.dy,
            child: GestureDetector(
              onPanUpdate: (d) => setState(() => _pos += d.delta),
              child: Text(
                _textCtl.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      );

  /* ─ 썸네일 + 텍스트 입력 ─ */
  Widget _selectionBar() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _textCtl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter text',
                hintStyle: TextStyle(color: kTextDim),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 100,
            child: CoverSelection(
              controller: widget.controller,
              quantity: 8,
              selectedCoverBuilder: (cover, _) => Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  const Icon(Icons.check_circle, color: kAccent),
                ],
              ),
            ),
          ),
        ],
      );

  /* ─ Cloud Run 업로드 ─ */
  Future<void> _exportMp4() async {
    // ① 잘라낸 구간 길이(ms)
    final startMs = widget.params['start_ms'] as int;
    final endMs = widget.params['end_ms'] as int;
    final durationMs = endMs - startMs;

    // ② 선택된 커버 썸네일 비율 (0 ~ 1)
    final Object? sel = widget.controller.selectedCoverVal; // double?  또는 null
    final double ratio = sel is num ? (sel as num).toDouble() : 0.0;

    // ③ 비율 → 밀리초
    final coverMs = startMs + (durationMs * ratio).round();

    // ④ 파라미터 합치고 Cloud Run 호출
    final params = {
      ...widget.params,
      'cover_frame_ms': coverMs,
    };

    _snack('Encoding… 잠시만 기다려 주세요');
    final url = await postencode(
      widget.videoPath, // String
      jsonEncode(params), // String  ← 반드시 JSON 문자열로!
    );
    if (url == null) {
      _snack('업로드/인코딩 실패 😢');
      return;
    }

    _snack('완료!');
    if (mounted) Navigator.pop(context, url);
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
