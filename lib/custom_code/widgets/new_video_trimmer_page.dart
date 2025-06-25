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

import 'index.dart'; // Imports other custom widgets
import 'package.flutter/material.dart';

import 'dart:io';
import 'dart:typed_data'; // Uint8List를 사용하기 위해 추가
import 'package.video_thumbnail/video_thumbnail.dart'; // 커버 생성을 위해 추가
import 'package:video_trimmer/video_trimmer.dart';
import '/app_state.dart'; // FFAppState를 사용하기 위해 추가

// --- 우리가 사용할 테마 색상 ---
const kAccentColor = Color(0xFFFFD600);
const kBackgroundColor = Colors.black;

class NewVideoTrimmerPage extends StatefulWidget {
  const NewVideoTrimmerPage({
    Key? key,
    this.width,
    this.height,
    required this.videoPath,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String videoPath;

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

  // 썸네일 생성이 완료되었는지 추적하는 변수
  late Future<List<Uint8List>> _thumbnailsFuture;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _thumbnailsFuture = _generateThumbnails(); // initState에서 썸네일 생성을 시작
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

  // [수정] 상단 '다음' 버튼 클릭 시 실행될 함수 (네비게이션 기능 추가)
  void _onNextButtonPressed() {
    if (_currentPageIndex == 0) {
      // '영상 자르기' 페이지에서는 비디오 재생을 멈추고 다음 페이지로 이동
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
        // --- 10단계 구현 ---
        // FlutterFlow의 AppState를 사용하여 이미지 데이터를 다음 페이지로 전달
        FFAppState().update(() {
          FFAppState().interimCoverBytes =
              FFUploadedFile(bytes: _selectedCoverBytes);
        });

        // ImageEditorPage로 네비게이션하면서 필요한 모든 정보를 파라미터로 전달
        context.pushNamed(
          'ImageEditorPage', // 실제 이미지 편집기 페이지의 이름으로 변경해야 합니다.
          queryParameters: {
            'originalVideoPath':
                serializeParam(widget.videoPath, ParamType.String),
            'startMs': serializeParam(_startValue.toInt(), ParamType.int),
            'endMs': serializeParam(_endValue.toInt(), ParamType.int),
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
            // 상단 네비게이션 바 (이전과 동일)
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

            // PageView 영역 (이전과 동일)
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

  // 트림 페이지 UI (이전과 동일)
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
            circlePaintColor: kAccentColor,
            borderPaintColor: kAccentColor,
            scrubberPaintColor: Colors.amber,
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

  // 커버 선택 페이지 UI (이전과 동일)
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
                // [수정] 썸네일이 비어있는 경우 처리
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

  // 썸네일 생성 헬퍼 함수 (이전과 동일)
  Future<List<Uint8List>> _generateThumbnails() async {
    // 페이지가 빌드된 후에 _endValue가 확정되므로, 약간의 지연을 줍니다.
    await Future.delayed(const Duration(milliseconds: 500));
    final List<Uint8List> thumbnails = [];

    // 비디오의 실제 길이를 가져옵니다.
    final double videoDurationMs = _trimmer
            .videoPlayerController?.value.duration.inMilliseconds
            .toDouble() ??
        0;
    // 트림 종료 시간을 비디오 전체 길이로 초기화합니다.
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
        timeMs: timeMs,
        quality: 25,
      );
      if (thumbnail != null) {
        thumbnails.add(thumbnail);
      }
    }
    // 첫 썸네일을 기본 선택값으로 설정
    if (mounted && _selectedCoverBytes == null && thumbnails.isNotEmpty) {
      setState(() {
        _selectedCoverBytes = thumbnails.first;
        _selectedCoverIndex = 0;
      });
    }
    return thumbnails;
  }
}
