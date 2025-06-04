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

/* ───── 팔레트 상수 ───── */
const kBg = Colors.black; // 배경
const kAccent = Color(0xFFFFD600); // 포인트 노랑
const kBorder = kAccent; // 버튼 테두리
const kTextDim = Colors.white54; // 흐린 텍스트
/* ────────────────────── */

// Displays controls for cropping a selected video segment.

class CropPage extends StatefulWidget {
  /// ⬇️ ➊ width / height 추가 (nullable)
  const CropPage({
    Key? key,
    required this.controller,
    this.width,
    this.height,
  }) : super(key: key);

  final VideoEditorController controller;

  /// FlutterFlow 필수 파라미터
  final double? width;
  final double? height;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  VideoEditorController get _ctl => widget.controller;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              /* ――― 상단 ↺ ↻ ――― */
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.rotate_left),
                    onPressed: () => _ctl.rotate90Degrees(RotateDirection.left),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () =>
                        _ctl.rotate90Degrees(RotateDirection.right),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              /* ――― 편집 뷰 ――― */
              Expanded(child: CropGridViewer.edit(controller: _ctl)),

              /* ――― 비율 선택 바 ――― */
              _ratioBar(),
            ],
          ),
        ),
      );

  Widget _ratioBar() => Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Divider(),
            Row(
              children: [
                _ratioBtn('free', null),
                _ratioBtn('1:1', 1),
                _ratioBtn('9:16', 9 / 16),
                _ratioBtn('3:4', 3 / 4),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('done',
                      style: TextStyle(color: Colors.yellow)),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _ratioBtn(String label, double? ratio) {
    final selected = _ctl.preferredCropAspectRatio == ratio ||
        (ratio == null && _ctl.preferredCropAspectRatio == null);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? Colors.white24 : Colors.transparent,
          side: BorderSide(color: selected ? Colors.white : Colors.white54),
        ),
        onPressed: () {
          _ctl.cropAspectRatio(ratio);
          setState(() {}); // UI 갱신
        },
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.yellow : Colors.white),
        ),
      ),
    );
  }
}
