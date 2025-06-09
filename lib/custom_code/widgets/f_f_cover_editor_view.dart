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

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_editor/video_editor.dart';
import '/custom_code/actions/postencode.dart' as ca;

/* ─── palette ─── */
const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);
const kTextDim = Colors.white54;

/* ─── small helper ─── */
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

/*────────────────────────────────────────────*/

class FFCoverEditorView extends StatefulWidget {
  const FFCoverEditorView({
    super.key,
    required this.controller,
    required this.videoPath,
    required this.params,
    required this.videoDocRef,
    this.width,
    this.height,
  });

  final VideoEditorController controller;
  final String videoPath;
  final Map<String, dynamic> params;
  final DocumentReference videoDocRef; // 최종 타입 수정
  final double? width, height;

  @override
  State<FFCoverEditorView> createState() => _FFCoverEditorViewState();
}

/*────────────────────────────────────────────*/

class _FFCoverEditorViewState extends State<FFCoverEditorView> {
  bool _isExporting = false;

  @override
  void dispose() {
    super.dispose();
  }

  /*───────────────────  UI  ───────────────────*/
  @override
  Widget build(BuildContext context) {
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

  /*── top bar ─*/
  Widget _topBar() => Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: kAccent),
            onPressed: _isExporting ? null : () => Navigator.pop(context),
          ),
          const Spacer(),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: kAccent,
              side: const BorderSide(color: kAccent),
              disabledForegroundColor: kTextDim.withOpacity(0.5),
            ),
            onPressed: _isExporting ? null : _exportMp4,
            child: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kAccent),
                    ),
                  )
                : const Text('EXPORT', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
        ],
      );

  /*── preview ─*/
  Widget _preview() => Stack(
        alignment: Alignment.center,
        children: [
          CoverViewer(controller: widget.controller),
        ],
      );

  /*── thumbnail bar ─*/
  Widget _selectionBar() => Column(
        children: [
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

  /*─────────────────  핵심 로직 (수정됨) ─────────────────*/
  Future<void> _exportMp4() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final int startMs = _toInt(widget.params['start_ms']);
      final int endMs = _toInt(widget.params['end_ms']);
      final int durationMs = endMs - startMs;

      final double ratio =
          (widget.controller.selectedCoverVal as num?)?.toDouble() ?? 0.0;
      final int coverMs = startMs + (durationMs * ratio).round();

      final params = {...widget.params, 'cover_frame_ms': coverMs};

      _snack('Encoding… 잠시만 기다려 주세요');

      final String? responseJson =
          await ca.postencode(widget.videoPath, jsonEncode(params));

      if (responseJson == null) {
        _snack('업로드/인코딩 실패 😢');
        if (mounted) setState(() => _isExporting = false);
        return;
      }

      final Map<String, dynamic> res =
          jsonDecode(responseJson) as Map<String, dynamic>;

      final String? url = res['url'] as String?;
      final String? thumbUrl = res['cover_url'] as String?;

      if (url == null || thumbUrl == null) {
        _snack('업로드/인코딩 실패: URL을 받지 못했습니다. 😢');
        if (mounted) setState(() => _isExporting = false);
        return;
      }

      /* 5) Firestore update (타입 캐스팅 추가) */
      await (widget.videoDocRef as DocumentReference<Map<String, dynamic>>)
          .update({
        'url': url,
        'thumbUrl': thumbUrl,
        'params': jsonEncode(params),
        'duration': durationMs,
        'status': 'done',
      });

      _snack('완료!');
      int popCount = 0;
      if (mounted) {
        Navigator.of(context).popUntil((_) => popCount++ >= 3);
      }
    } catch (e) {
      _snack('오류 발생: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /*── snack helper ─*/
  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }
}
