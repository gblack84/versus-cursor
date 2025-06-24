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

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:video_editor/video_editor.dart';

const kBg = Colors.black;
const kAccent = Color(0xFFFFD600);

class NewFFVideoEditorView extends StatefulWidget {
  const NewFFVideoEditorView(
      {Key? key, required this.videoPath, this.width, this.height})
      : super(key: key);

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

  Future<void> _saveCoverAndNavigate() async {
    _setLoading(true, '다음 단계 준비 중...');
    try {
      // [핵심 수정] CoverData 라는 타입을 직접 명시하는 대신, var로 타입 추론을 맡깁니다.
      final coverData = _controller.selectedCoverVal;

      if (coverData == null) {
        throw Exception('커버가 선택되지 않았습니다.');
      }

      // coverData의 구체적인 타입 이름은 몰라도, .thumbData 속성은 존재하므로 호출 가능합니다.
      final Uint8List? imageBytes = await coverData.thumbData;

      if (imageBytes == null) {
        throw Exception('커버 이미지를 생성할 수 없습니다.');
      }

      final String base64Image = base64Encode(imageBytes);

      FFAppState().update(() {
        FFAppState().selectedCoverImageBytes = base64Image;
      });

      if (!mounted) return;

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
          'coverTimestamp': serializeParam(coverData.timeMs, ParamType.int),
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
