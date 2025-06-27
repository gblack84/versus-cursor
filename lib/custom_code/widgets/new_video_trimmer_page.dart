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

// 필수 패키지 import 구문 (기존과 동일)
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_video_trimmer/flutter_video_trimmer.dart';
import 'package:get_video_thumbnail/get_video_thumbnail.dart';
import 'package:get_video_thumbnail/index.dart';
// [핵심] App State를 사용하기 위한 import
import '/app_state.dart';

const kAccentColor = Color(0xFFFFD600);
const kBackgroundColor = Colors.black;

class NewVideoTrimmerPage extends StatefulWidget {
  // [수정] App State를 사용하므로 페이지 파라미터를 모두 제거합니다.
  const NewVideoTrimmerPage({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _NewVideoTrimmerPageState createState() => _NewVideoTrimmerPageState();
}

class _NewVideoTrimmerPageState extends State<NewVideoTrimmerPage> {
  // 상태 변수들은 기존과 동일하게 유지합니다.
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
    // [수정] App State에서 videoPath를 가져와 비디오를 로드합니다.
    _loadVideo();
    // 썸네일 생성 로직은 동일하게 유지됩니다.
    _thumbnailsFuture = _generateThumbnails();
  }

  // [수정] App State에서 videoPath를 가져오도록 수정합니다.
  void _loadVideo() {
    final videoPath = FFAppState().uploadVideoPath;
    if (videoPath.isNotEmpty) {
      _trimmer.loadVideo(videoFile: File(videoPath));
    } else {
      // 비디오 경로가 없는 경우 에러 처리 (예: 이전 페이지로 돌려보내기)
      print("Error: Video path from AppState is empty.");
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('영상을 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  // [핵심 수정] "다음" 버튼을 눌렀을 때의 로직을 App State 중심으로 변경합니다.
  void _onNextButtonPressed() async {
    // 1페이지 (영상 자르기)에서 "다음"을 누를 때
    if (_currentPageIndex == 0) {
      if (_isPlaying) {
        await _trimmer.videoPlaybackControl(
            startValue: _startValue, endValue: _endValue);
        _isPlaying = false;
      }
      // [수정] 자른 영상의 시작/종료 시간을 App State에 저장합니다.
      FFAppState().update(() {
        FFAppState().uploadStartMs = _startValue;
        FFAppState().uploadEndMs = _endValue;
      });
      // 2페이지(커버 선택)로 이동
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );

      // 2페이지 (커버 선택)에서 "다음"을 누를 때
    } else if (_currentPageIndex == 1) {
      if (_selectedCoverBytes != null) {
        // [수정] 선택한 커버 이미지를 Base64 문자열로 변환하여 App State에 저장합니다.
        FFAppState().update(() {
          FFAppState().uploadCoverBytes = base64Encode(_selectedCoverBytes!);
        });

        // [수정] 이제 파라미터 없이 ImageEditorPage로 이동합니다.
        context.pushNamed('ImageEditorPage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('커버 이미지를 선택해주세요.')),
        );
      }
    }
  }

  // [수정] 썸네일 생성 시 App State의 경로를 사용하도록 수정
  Future<List<Uint8List>> _generateThumbnails() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final List<Uint8List> thumbnails = [];
    final videoPath = FFAppState().uploadVideoPath;

    if (videoPath.isEmpty) return [];

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
        video: videoPath,
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

  @override
  void dispose() {
    _trimmer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // [변경 없음] 이하 build, _buildTrimPage, _buildCoverSelectionPage 함수는 기존 구조를 그대로 유지합니다.
  // 데이터 처리 로직만 수정되었을 뿐, UI와 패키지 사용법은 동일합니다.
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
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _onNextButtonPressed,
                    child: const Text('다음',
                        style: TextStyle(
                            color: kAccentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
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
                      child: Text('썸네일을 생성할 수 없습니다.',
                          style: TextStyle(color: Colors.white)));
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
                              fit: BoxFit.cover),
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
}
