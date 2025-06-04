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

/* ── 직접 import ── */
import 'dart:io';
import 'dart:convert';
import 'package:video_editor/video_editor.dart';
import 'crop_page.dart';

/* ── 팔레트 ── */
const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);
const kBorder = kAccent;
const kTextDim = Colors.white54;
/* ──────────── */

class NewFFVideoEditorView extends StatefulWidget {
  const NewFFVideoEditorView({
    Key? key,
    required this.videoPath,
    this.width,
    this.height,
  }) : super(key: key);

  final String videoPath;
  final double? width;
  final double? height;

  @override
  State<NewFFVideoEditorView> createState() => _NewFFVideoEditorViewState();
}

class _NewFFVideoEditorViewState extends State<NewFFVideoEditorView> {
  /* ── VideoEditorController ── */
  late final VideoEditorController _ctl = VideoEditorController.file(
    File(widget.videoPath),
    maxDuration: const Duration(seconds: 60),
  );

  late double _fixedP;
  bool _wasTrimming = false;

  /* ── init ── */
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _ctl.initialize(aspectRatio: 9 / 16);

    final totalSec =
        _ctl.videoDuration.inSeconds.toDouble().clamp(1, double.infinity);
    final segLen = totalSec >= 60 ? 59.99 : (totalSec >= 20 ? 20.0 : totalSec);

    _fixedP = segLen / totalSec;
    final start = (1 - _fixedP) / 2;
    _ctl.updateTrim(start, start + _fixedP);

    _ctl.addListener(_listener);
    if (mounted) setState(() {});
  }

  void _listener() {
    if (_wasTrimming && !_ctl.isTrimming) {
      final center = (_ctl.minTrim + _ctl.maxTrim) / 2;
      final newMin = (center - _fixedP / 2).clamp(0.0, 1 - _fixedP);
      _ctl.updateTrim(newMin, newMin + _fixedP);
    }
    _wasTrimming = _ctl.isTrimming;
  }

  @override
  void dispose() {
    _ctl.removeListener(_listener);
    _ctl.dispose();
    super.dispose();
  }

  /* ── UI ── */
  @override
  Widget build(BuildContext context) {
    if (!_ctl.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final w = widget.width ?? MediaQuery.of(context).size.width;
    final h = widget.height ?? MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBg,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox(
          width: w,
          height: h,
          child: Column(
            children: [
              _topBar(),
              Expanded(child: _previewArea()),
              _nextBtn(context), // ↙︎ 변경
            ],
          ),
        ),
      ),
    );
  }

  /* ── Top Bar ── */
  Widget _topBar() => Row(
        children: [
          _icon(Icons.close, () => Navigator.pop(context)),
          _divider(),
          _icon(Icons.rotate_left,
              () => _ctl.rotate90Degrees(RotateDirection.left)),
          _icon(Icons.rotate_right,
              () => _ctl.rotate90Degrees(RotateDirection.right)),
          _icon(Icons.crop, () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CropPage(
                  controller: _ctl,
                  width: widget.width,
                  height: widget.height,
                ),
              ),
            );
            setState(() {});
          }),
        ],
      );

  /* ── Preview + Trim ── */
  Widget _previewArea() {
    const sliderH = 60.0;
    String fmt(Duration d) => '${d.inMinutes}m${d.inSeconds.remainder(60)}s';

    return Column(
      children: [
        Expanded(
          child: Stack(alignment: Alignment.center, children: [
            CropGridViewer.preview(controller: _ctl),
            AnimatedBuilder(
              animation: _ctl.video,
              builder: (_, __) => _ctl.isPlaying
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: _ctl.video.play,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: kBg),
                      ),
                    ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sliderH / 4),
          child: Row(children: [
            Text(fmt(_ctl.startTrim), style: const TextStyle(color: kAccent)),
            const Spacer(),
            Text(fmt(_ctl.endTrim), style: const TextStyle(color: kAccent)),
          ]),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: sliderH / 4),
          child: TrimSlider(
            controller: _ctl,
            height: sliderH,
            horizontalMargin: sliderH / 4,
            child: TrimTimeline(
                controller: _ctl, padding: const EdgeInsets.only(top: 10)),
          ),
        ),
      ],
    );
  }

  /* ── NEXT 버튼 (변경 핵심) ── */
  Widget _nextBtn(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kBg,
              foregroundColor: kAccent,
              side: const BorderSide(color: kBorder, width: 2),
            ),
            onPressed: () {
              /* 1) 현재 영상 편집 파라미터를 Map에 저장 */
              final editParams = {
                'start_ms': _ctl.startTrim.inMilliseconds,
                'end_ms': _ctl.endTrim.inMilliseconds,
                'rotate': _ctl.rotation, // 0/90/180/270
                'crop': '${_ctl.minCrop.dx},'
                    '${_ctl.minCrop.dy},'
                    '${_ctl.maxCrop.dx},'
                    '${_ctl.maxCrop.dy}',
              };

              /* 2) 텍스트 오버레이 페이지로 이동 */
              final trimParams = editParams; // 이미 계산한 Map
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FFTextOverlayView(
                    controller: _ctl,
                    videoPath: widget.videoPath, // 추가
                    baseParams: trimParams, // 추가
                    width: widget.width,
                    height: widget.height,
                  ),
                ),
              );
            },
            child: const Text('next', style: TextStyle(fontSize: 16)),
          ),
        ),
      );

  /* ── helpers ── */
  Widget _icon(IconData i, VoidCallback f) =>
      Expanded(child: IconButton(icon: Icon(i, color: kAccent), onPressed: f));
  Widget _divider() => const VerticalDivider(
      color: kAccent, indent: 18, endIndent: 18, width: 1);
}
