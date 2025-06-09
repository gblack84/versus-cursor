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

import 'package:video_editor/video_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* ── 팔레트 ── */
const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);
const kTextDim = Colors.white54;

/// ──────────────────────────────────────────── │ FFTextOverlayView
class FFTextOverlayView extends StatefulWidget {
  const FFTextOverlayView({
    super.key,
    required this.controller,
    required this.videoPath,
    required this.baseParams,
    required this.videoDocRef,
    this.width,
    this.height,
  });

  final VideoEditorController controller;
  final String videoPath;
  final Map<String, dynamic> baseParams;
  final DocumentReference videoDocRef; // 최종 타입 수정
  final double? width, height;

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

  /* ────────── UI ────────── */
  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? MediaQuery.of(context).size.width;
    final h = widget.height ?? MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _topBar(context, w, h),
          Expanded(child: _preview()),
          _inputField(),
        ],
      ),
    );
  }

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
              child: const Text('NEXT', style: TextStyle(fontSize: 14)),
              onPressed: () {
                final overlayX = _pos.dx / w;
                final overlayY = _pos.dy / h;

                final params = {
                  ...widget.baseParams,
                  'overlay_text': _textCtl.text,
                  'overlay_x': overlayX,
                  'overlay_y': overlayY,
                };

                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => FFCoverEditorView(
                      controller: widget.controller,
                      videoPath: widget.videoPath,
                      params: params,
                      videoDocRef: widget.videoDocRef,
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      );

  Widget _preview() => Stack(
        children: [
          Center(child: CropGridViewer.preview(controller: widget.controller)),
          Positioned(
            left: _pos.dx,
            top: _pos.dy,
            child: GestureDetector(
              onPanUpdate: (details) => setState(() => _pos += details.delta),
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
