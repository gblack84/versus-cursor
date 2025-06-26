// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

// ===== [수정 1] 필수 패키지 import 구문 추가 =====
// 이 import 구문들이 있어야 FlutterFlow 커스텀 코드 편집기가
// TrimEditorStyle, VideoThumbnail, ImageFormat 같은 외부 패키지의
// 클래스와 열거형(enum)을 인식하고 오류를 발생시키지 않습니다.
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_video_trimmer/flutter_video_trimmer.dart';
import 'package:get_video_thumbnail/get_video_thumbnail.dart';
import 'package:get_video_thumbnail/index.dart';
import '/app_state.dart';

const kAccentColor = Color(0xFFFFD600);
const kBackgroundColor = Colors.black;

class NewVideoTrimmerPage extends StatefulWidget {
  const NewVideoTrimmerPage({
    Key? key,
    this.width,
    this.height,
    required this.videoPath,
    required this.postId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String videoPath;
  final String postId;

  @override
  _NewVideoTrimmerPageState createState() => _NewVideoTrimmerPageState();
}

class _NewVideoTrimmerPageState extends State<NewVideoTrimmerPage> {
  final Trimmer _trimmer = Trimmer();
  final PageController _pageController = PageController();

  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;

  Uint8List? _selectedCoverBytes;
  int _selectedCoverIndex = -1;

  int _currentPageIndex = 0;

  late Future<List<Uint8List>> _thumbnailsFuture;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _thumbnailsFuture = _generateThumbnails();
  }

  @override
  void dispose() {
    _trimmer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(widget.videoPath));
  }

  void _onNextButtonPressed() {
    if (_currentPageIndex == 0) {
      if (_isPlaying) {
        _trimmer.videoPlaybackControl(
          startValue: _startValue,
          endValue: _endValue,
        );
        _isPlaying = false;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentPageIndex == 1) {
      if (_selectedCoverBytes != null) {
        // AppState에 Base64로 인코딩하여 저장
        FFAppState().update(() {
          FFAppState().selectedCoverImageBytes =
              base64Encode(_selectedCoverBytes!);
        });

        context.pushNamed(
          'ImageEditorPage',
          queryParameters: {
            'originalVideoPath':
                serializeParam(widget.videoPath, ParamType.String),
            'startMs': serializeParam(_startValue.toInt(), ParamType.int),
            'endMs': serializeParam(_endValue.toInt(), ParamType.int),
            'postId': serializeParam(widget.postId, ParamType.String),
          }.withoutNulls,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('커버 이미지를 선택해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _currentPageIndex == 0
                          ? Icons.close
                          : Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (_currentPageIndex == 0) {
                        Navigator.of(context).pop();
                      } else {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                  ),
                  Text(
                    _currentPageIndex == 0 ? '영상 자르기' : '커버 선택',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _onNextButtonPressed,
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        color: kAccentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPageIndex = index);
                },
                children: [
                  _buildTrimPage(),
                  _buildCoverSelectionPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimPage() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: VideoViewer(trimmer: _trimmer),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          // [수정 2] TrimViewer의 스타일링 방식 수정:
          // 제공해주신 공식 샘플 코드에 따라, 불필요하고 오류를 발생시키는
          // `editorProperties` 파라미터를 완전히 제거했습니다.
          child: TrimViewer(
            trimmer: _trimmer,
            viewerHeight: 60.0,
            viewerWidth: MediaQuery.of(context).size.width,
            maxVideoLength: const Duration(seconds: 60),
            onChangeStart: (value) => setState(() => _startValue = value),
            onChangeEnd: (value) => setState(() => _endValue = value),
            onChangePlaybackState: (value) =>
                setState(() => _isPlaying = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: TextButton(
            child: _isPlaying
                ? const Icon(Icons.pause, size: 70.0, color: Colors.white)
                : const Icon(Icons.play_arrow, size: 70.0, color: Colors.white),
            onPressed: () async {
              bool playbackState = await _trimmer.videoPlaybackControl(
                startValue: _startValue,
                endValue: _endValue,
              );
              setState(() => _isPlaying = playbackState);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoverSelectionPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            '커버로 사용할 프레임을 선택하세요.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Expanded(
          child: Center(
            child: _selectedCoverBytes != null
                ? Image.memory(_selectedCoverBytes!, fit: BoxFit.contain)
                : VideoViewer(trimmer: _trimmer),
          ),
        ),
        Container(
          height: 100,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: FutureBuilder<List<Uint8List>>(
            future: _thumbnailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    '썸네일을 생성할 수 없습니다.',
                    style: TextStyle(color: Colors.white),
                  ));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCoverBytes = snapshot.data![index];
                          _selectedCoverIndex = index;
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedCoverIndex == index
                                ? kAccentColor
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(snapshot.data![index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(
                  child: CircularProgressIndicator(color: kAccentColor));
            },
          ),
        ),
      ],
    );
  }

  // [수정 3] 썸네일 생성 클래스 수정:
  // get_video_thumbnail 패키지의 공식 문서 예제와 동일하게, 올바른 클래스 이름인
  // `VideoThumbnail`과 열거형 `ImageFormat`을 사용하고, 지적해주신 `maxWidth`
  // 파라미터를 추가했습니다.
  Future<List<Uint8List>> _generateThumbnails() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final List<Uint8List> thumbnails = [];

    final double videoDurationMs = _trimmer
            .videoPlayerController?.value.duration.inMilliseconds
            .toDouble() ??
        0;
    if (_endValue == 0.0) {
      _endValue = videoDurationMs;
    }

    final double trimDuration = _endValue - _startValue;
    if (trimDuration <= 0) return [];

    final double step = trimDuration / 8;

    for (int i = 0; i < 8; i++) {
      final int timeMs = (_startValue + (step * i)).toInt();
      final Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        timeMs: timeMs,
        quality: 25,
      );
      if (thumbnail != null) {
        thumbnails.add(thumbnail);
      }
    }
    if (mounted && _selectedCoverBytes == null && thumbnails.isNotEmpty) {
      setState(() {
        _selectedCoverBytes = thumbnails.first;
        _selectedCoverIndex = 0;
      });
    }
    return thumbnails;
  }
}
