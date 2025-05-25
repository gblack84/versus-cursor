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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

/* ─ 패키지 ─ */
import 'dart:io';
import 'package:video_editor/video_editor.dart';
import 'crop_page.dart'; // ✅ 같은 폴더이므로 상대경로로!

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
  /* — controller — */
  late final VideoEditorController _ctl = VideoEditorController.file(
    File(widget.videoPath),
    minDuration: const Duration(seconds: 20),
    maxDuration: const Duration(seconds: 60),
  );

  late double _fixedP;
  bool _wasTrimming = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _ctl.initialize(aspectRatio: 9 / 16);
    final t = _ctl.videoDuration.inSeconds;
    final seg = t >= 60 ? 60 : (t >= 20 ? 20 : t);
    _fixedP = seg / t;
    _ctl.updateTrim(0, _fixedP);
    _ctl.addListener(_listener);
    if (mounted) setState(() {});
  }

  void _listener() {
    if (_wasTrimming && !_ctl.isTrimming) {
      var s = _ctl.minTrim;
      var e = s + _fixedP;
      if (e > 1) {
        e = 1;
        s = 1 - _fixedP;
      }
      _ctl.updateTrim(s, e);
    }
    _wasTrimming = _ctl.isTrimming;
  }

  @override
  void dispose() {
    _ctl.removeListener(_listener);
    _ctl.dispose();
    super.dispose();
  }

  /* — UI — */
  @override
  Widget build(BuildContext context) {
    if (!_ctl.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final w = widget.width ?? MediaQuery.of(context).size.width;
    final h = widget.height ?? MediaQuery.of(context).size.height;

    return SizedBox(
      width: w,
      height: h,
      child: Column(
        children: [
          _topBar(),
          Expanded(child: _previewArea()),
          _nextBtn(context),
        ],
      ),
    );
  }

  Widget _topBar() => SafeArea(
        child: Row(
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
              setState(() {}); // 크롭 후 미리보기 업데이트
            }),
          ],
        ),
      );

  Widget _previewArea() {
    const sliderH = 60.0;
    String fmt(Duration d) =>
        '${d.inMinutes.remainder(60).toString().padLeft(2, "0")}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, "0")}';

    return Column(
      children: [
        Expanded(
          child: Stack(alignment: Alignment.center, children: [
            CropGridViewer.preview(controller: _ctl),
            AnimatedBuilder(
              animation: _ctl.video,
              builder: (_, __) => _ctl.isPlaying
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: _ctl.video.play,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.play_arrow, color: Colors.black),
                      ),
                    ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sliderH / 4),
          child: Row(
            children: [
              Text(fmt(_ctl.startTrim)),
              const Spacer(),
              Text(fmt(_ctl.endTrim)),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: sliderH / 4),
          child: TrimSlider(
            controller: _ctl,
            height: sliderH,
            horizontalMargin: sliderH / 4,
            child: TrimTimeline(
              controller: _ctl,
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextBtn(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/addTextPage'), // 다음 단계
            child: const Text('다음', style: TextStyle(fontSize: 16)),
          ),
        ),
      );

  Widget _icon(IconData i, VoidCallback f) =>
      Expanded(child: IconButton(icon: Icon(i), onPressed: f));
  Widget _divider() => const VerticalDivider(indent: 18, endIndent: 18);
}
