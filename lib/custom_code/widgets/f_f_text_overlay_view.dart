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

/* ── 외부 ── */
import 'package:video_editor/video_editor.dart';

/* 팔레트 */
const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);
const kTextDim = Colors.white54;

class FFTextOverlayView extends StatefulWidget {
  const FFTextOverlayView({
    super.key,
    required this.controller,
    required this.videoPath, // ➊ mp4 경로 추가
    required this.baseParams, // ➋ NewFFVideoEditorView 에서 받은 Map
    this.width,
    this.height,
  });

  final VideoEditorController controller;
  final String videoPath; // ➊
  final Map<String, dynamic> baseParams; // ➋
  final double? width;
  final double? height;

  @override
  State<FFTextOverlayView> createState() => _FFTextOverlayViewState();
}

class _FFTextOverlayViewState extends State<FFTextOverlayView> {
  final _textCtl = TextEditingController();
  Offset _pos = Offset.zero;

  @override
  void dispose() {
    _textCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? MediaQuery.of(context).size.width;
    final h = widget.height ?? MediaQuery.of(context).size.height;

    return Container(
      color: kBg,
      width: w,
      height: h,
      child: Column(
        children: [
          _topBar(context, w, h),
          Expanded(child: _preview()),
          _inputField(),
        ],
      ),
    );
  }

  /* ───── 상단바 ───── */
  Widget _topBar(BuildContext ctx, double w, double h) => SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: kAccent),
              onPressed: () => Navigator.pop(ctx),
            ),
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kAccent,
                side: const BorderSide(color: kAccent),
              ),
              onPressed: () {
                /* 1) overlay 좌표(비율) 계산 */
                final overlayX = _pos.dx / w;
                final overlayY = _pos.dy / h;

                /* 2) 파라미터 합치기 */
                final params = {
                  ...widget.baseParams,
                  'overlay_text': _textCtl.text,
                  'overlay_x': overlayX,
                  'overlay_y': overlayY,
                };

                /* 3) 다음(커버) 페이지로 */
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => FFCoverEditorView(
                      controller: widget.controller,
                      videoPath: widget.videoPath, // 그대로 전달
                      params: params,
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),
                );
              },
              child: const Text('NEXT', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );

  /* ───── 미리보기 ───── */
  Widget _preview() => Stack(
        children: [
          Center(child: CropGridViewer.preview(controller: widget.controller)),
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

  /* ───── 입력창 ───── */
  Widget _inputField() => Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _textCtl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter text',
            hintStyle: TextStyle(color: kTextDim),
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
      );
}
