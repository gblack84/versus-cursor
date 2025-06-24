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

// --- Custom Imports for this Widget ---
import 'dart:io';
import 'dart:convert'; // For base64Encode
import 'dart:typed_data'; // For image bytes (Uint8List)
import 'package:video_editor/video_editor.dart';

const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);

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
  late final VideoEditorController _controller;
  final _pageController = PageController();
  bool _isLoading = false;
  String _loadingText = '';

  @override
  void initState() {
    super.initState();
    _controller = VideoEditorController.file(
      File(widget.videoPath),
      maxDuration: const Duration(seconds: 60),
    )..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setLoading(bool isLoading, [String text = '']) {
    setState(() {
      _isLoading = isLoading;
      _loadingText = text;
    });
  }

  // [핵심 로직 V3] 커버 이미지를 Base64 문자열로 App State에 저장하고 다음 페이지로 이동합니다.
  Future<void> _saveCoverAndNavigate() async {
    _setLoading(true, '다음 단계 준비 중...');
    try {
      // .thumbData를 사용하여 Uint8List를 직접 가져옵니다.
      final Uint8List? imageBytes =
          await _controller.selectedCoverVal.thumbData;

      if (imageBytes == null) {
        throw Exception('커버 이미지를 생성할 수 없습니다.');
      }

      // [핵심] 이미지 바이트(Uint8List)를 Base64 문자열로 인코딩합니다.
      final String base64Image = base64Encode(imageBytes);

      // App State 변수('selectedCoverImageBytes')를 업데이트합니다.
      FFAppState().update(() {
        // 이제 String 타입의 변수에 Base64 문자열을 저장합니다.
        FFAppState().selectedCoverImageBytes = base64Image;
      });

      if (!mounted) return;

      // 다음 페이지(ImageEditorPage)로 모든 편집 데이터를 파라미터로 전달하며 이동합니다.
      context.pushNamed(
        'ImageEditorPage',
        queryParameters: {
          'originalVideoPath':
              serializeParam(widget.videoPath, ParamType.String),
          'trimStart': serializeParam(
              _controller.startTrim.inMilliseconds, ParamType.int),
          'trimEnd':
              serializeParam(_controller.endTrim.inMilliseconds, ParamType.int),
          'rotation': serializeParam(_controller.rotation, ParamType.int),
          'cropData': serializeParam(
              '${_controller.minCrop.dx},${_controller.minCrop.dy},${_controller.maxCrop.dx},${_controller.maxCrop.dy}',
              ParamType.String),
          'coverTimestamp': serializeParam(
              _controller.selectedCoverVal?.timeMs ?? 0, ParamType.int),
        }.withoutNulls,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.initialized) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(child: CircularProgressIndicator(color: kAccent)),
      );
    }
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTrimPage(),
              _buildCoverSelectionPage(),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: kAccent),
                    const SizedBox(height: 16),
                    Text(
                      _loadingText,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 트림/크롭 페이지 UI
  Widget _buildTrimPage() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  child: const Text('Next', style: TextStyle(color: kAccent)),
                ),
              ],
            ),
          ),
          Expanded(
            child: CropGridViewer.preview(controller: _controller),
          ),
          TrimSlider(controller: _controller, height: 60),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 커버 선택 페이지 UI
  Widget _buildCoverSelectionPage() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: kAccent),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                ),
                TextButton(
                  onPressed: _saveCoverAndNavigate,
                  child: const Text('Next', style: TextStyle(color: kAccent)),
                ),
              ],
            ),
          ),
          Expanded(child: CoverViewer(controller: _controller)),
          SizedBox(
            height: 100,
            child: CoverSelection(
              controller: _controller,
              quantity: 8,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
