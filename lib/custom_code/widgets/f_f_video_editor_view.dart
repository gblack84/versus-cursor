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

/* ─── 패키지 ─── */
import 'dart:convert';
import 'dart:io';
import 'package:video_editor/video_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FFVideoEditorView extends StatefulWidget {
  const FFVideoEditorView({
    Key? key,
    required this.videoPath,
    this.width,
    this.height,
  }) : super(key: key);

  final String videoPath;
  final double? width;
  final double? height;

  @override
  State<FFVideoEditorView> createState() => _FFVideoEditorViewState();
}

/* ───────────────────────────────────── */
class _FFVideoEditorViewState extends State<FFVideoEditorView> {
/* 0. controller & state */
  late final VideoEditorController _ctl = VideoEditorController.file(
    File(widget.videoPath),
    minDuration: const Duration(seconds: 20), // 최소 20 초
    maxDuration: const Duration(seconds: 60), // 최대 60 초
  );

  // 고정 길이 비율(0~1), 드래그 감지를 위한 이전 상태
  late double _fixedLenP;
  bool _wasTrimming = false;

  final _sending = ValueNotifier<bool>(false);
  final _progress = ValueNotifier<double>(0); // 0~1

/* 1. lifecycle */
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _ctl.initialize(aspectRatio: 9 / 16);

      final totalSec = _ctl.videoDuration.inSeconds;
      final segLen = totalSec >= 60
          ? 60
          : totalSec >= 20
              ? 20
              : totalSec;
      _fixedLenP = segLen / totalSec;

      _ctl.updateTrim(0.0, _fixedLenP); // 처음엔 0~고정길이
      _ctl.addListener(_onCtlUpdate); // 드래그 종료 감지

      setState(() {});
    } catch (e, st) {
      debugPrint('Video init error: $e\n$st');
      _snack('영상 불러오기 실패');
    }
  }

  void _onCtlUpdate() {
    // 손을 떼는 순간(isTrimming false 로 전환) → 길이를 고정
    if (_wasTrimming && !_ctl.isTrimming) {
      final startP = _ctl.minTrim; // 현재 드래그 결과(비율)
      double newMin = startP;
      double newMax = newMin + _fixedLenP;

      if (newMax > 1) {
        // 우측 초과 시 좌로 이동
        newMax = 1;
        newMin = 1 - _fixedLenP;
      }
      _ctl.updateTrim(newMin, newMax); // 고정 길이 적용
    }
    _wasTrimming = _ctl.isTrimming;
  }

  @override
  void dispose() {
    _ctl.removeListener(_onCtlUpdate);
    _ctl.dispose();
    _sending.dispose();
    _progress.dispose();
    super.dispose();
  }

/* 2. Cloud Run 업로드 (변경 없음) */
  Future<void> _export({required bool cover, bool gif = false}) async {
    final tmp = await getTemporaryDirectory();

    final encRef = FirebaseFirestore.instance.collection('encodings').doc();
    final encId = encRef.id;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final Offset min = _ctl.minCrop;
    final Offset max = _ctl.maxCrop;

    final params = <String, dynamic>{
      'cover': cover,
      'gif': gif,
      'start_ms': _ctl.startTrim.inMilliseconds,
      'end_ms': _ctl.endTrim.inMilliseconds,
      'rotate': _ctl.rotation,
      'crop': '${min.dx},${min.dy},${max.dx},${max.dy}',
    };

    await encRef.set({
      'status': 'processing',
      'ownerUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'params': params,
    });

    final paramFile = File('${tmp.path}/$encId.json')
      ..writeAsStringSync(jsonEncode(params));

    _sending.value = true;
    final storage = FirebaseStorage.instance;
    final vidRef = storage.ref('encode/in/$encId/input.mp4');
    final jsonRef = storage.ref('encode/in/$encId/params.json');

    final vTask = vidRef.putFile(
      File(widget.videoPath),
      SettableMetadata(contentType: 'video/mp4'),
    );
    vTask.snapshotEvents.listen(_uploadProg);
    await vTask;
    await jsonRef.putFile(
      paramFile,
      SettableMetadata(contentType: 'application/json'),
    );

    final res = await http.post(Uri.parse(
        'https://encoder-636984750551.asia-northeast3.run.app/run?encodingId=$encId'));

    if (res.statusCode != 200) {
      _fail('Cloud 인코더 호출 실패: ${res.body}');
      await encRef.update({'status': 'failed', 'error': res.body});
      return;
    }

    encRef.snapshots().listen((s) {
      final d = s.data();
      if (d == null) return;

      if (d['status'] == 'done') {
        _snack('인코딩 완료!');
        Navigator.pop(context, d['url']);
      } else if (d['status'] == 'failed') {
        _fail(d['error'] ?? '인코딩 실패');
      }
    });

    _snack('변환 시작! 완료 알림을 기다려 주세요.');
    _sending.value = false;
    _progress.value = 0;
  }

  void _uploadProg(TaskSnapshot s) => _progress.value =
      s.totalBytes > 0 ? s.bytesTransferred / s.totalBytes : 0;

/* helpers */
  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  void _fail(String m) {
    _sending.value = false;
    _progress.value = 0;
    _snack(m);
  }

/* 3. UI ------------------------------------------------------------------ */
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
          Expanded(child: _editorBody()),
          ValueListenableBuilder<bool>(
            valueListenable: _sending,
            builder: (_, s, __) => AnimatedSwitcher(
              duration: kThemeAnimationDuration,
              child: s
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: ValueListenableBuilder<double>(
                        valueListenable: _progress,
                        builder: (_, p, __) =>
                            LinearProgressIndicator(value: p),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

/* ───── 상단 툴바 ───── */
  Widget _topBar() => SafeArea(
        child: Row(
          children: [
            _icon(Icons.exit_to_app, () => Navigator.pop(context)),
            _divider(),
            _icon(Icons.rotate_left,
                () => _ctl.rotate90Degrees(RotateDirection.left)),
            _icon(Icons.rotate_right,
                () => _ctl.rotate90Degrees(RotateDirection.right)),
            _icon(
              Icons.crop,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CropPage(
                    controller: _ctl,
                    width: widget.width,
                    height: widget.height,
                  ),
                ),
              ),
            ),
            _divider(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.save),
              onSelected: (v) {
                if (v == 'mp4') _export(cover: false);
                if (v == 'gif') _export(cover: false, gif: true);
                if (v == 'cover') _export(cover: true);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'mp4', child: Text('Export MP4')),
                PopupMenuItem(value: 'gif', child: Text('Export GIF')),
                PopupMenuItem(value: 'cover', child: Text('Export Cover')),
              ],
            ),
          ],
        ),
      );

  Widget _icon(IconData i, VoidCallback f) =>
      Expanded(child: IconButton(icon: Icon(i), onPressed: f));
  Widget _divider() => const VerticalDivider(indent: 18, endIndent: 18);

/* ───── 본문 : preview + Trim / Cover ───── */
  Widget _editorBody() => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Stack(alignment: Alignment.center, children: [
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
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow,
                                    color: Colors.black),
                              ),
                            ),
                    ),
                  ]),
                  CoverViewer(controller: _ctl),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  TabBar(tabs: [
                    _tab(Icons.content_cut, 'Trim'),
                    _tab(Icons.video_label, 'Cover'),
                  ]),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [_trimPanel(), _coverPanel()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _tab(IconData i, String t) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.all(5), child: Icon(i)),
          Text(t),
        ],
      );

/* ---------- Trim 패널 ---------- */
  Widget _trimPanel() {
    const double h = 60;
    String fmt(Duration d) =>
        '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(
        animation: Listenable.merge([_ctl, _ctl.video]),
        builder: (_, __) {
          final dur = _ctl.videoDuration.inSeconds;
          final pos = (_ctl.trimPosition * dur).toInt();
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: h / 4),
            child: Row(children: [
              Text(fmt(Duration(seconds: pos))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _ctl.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(fmt(_ctl.startTrim)),
                  const SizedBox(width: 8),
                  Text(fmt(_ctl.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: h / 4),
        child: TrimSlider(
          controller: _ctl,
          height: h,
          horizontalMargin: h / 4,
          child: TrimTimeline(
            controller: _ctl,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      ),
    ]);
  }

/* ---------- Cover 패널 ---------- */
  Widget _coverPanel() => SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: CoverSelection(
              controller: _ctl,
              size: 70,
              quantity: 8,
              selectedCoverBuilder: (cover, _) => Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(Icons.check_circle,
                      color: const CoverSelectionStyle().selectedBorderColor),
                ],
              ),
            ),
          ),
        ),
      );

/* ---------- (더 이상 사용 안 함) Crop 모달 ---------- */
// _openCropModal / _ratioBtn 는 CropPage 로 대체되었습니다.
}
