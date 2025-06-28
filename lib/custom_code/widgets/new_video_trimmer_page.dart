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

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:flutter_native_video_trimmer/flutter_native_video_trimmer.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:get_thumbnail_video/index.dart';
import '/app_state.dart';

// --- Helper function to format duration ---
String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$minutes:$seconds";
}

class NewVideoTrimmerPage extends StatefulWidget {
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
  final _trimmer = VideoTrimmer();
  VideoPlayerController? _videoPlayerController;
  final PageController _pageController = PageController();

  int _currentPageIndex = 0;
  double _startValue = 0.0;
  double _endValue = 0.0;

  Future<List<Uint8List>>? _thumbnailsFuture;
  Uint8List? _selectedCoverBytes;
  int _selectedCoverIndex = -1;

  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _trimmer.clearCache();
    _videoPlayerController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    final videoPath = FFAppState().uploadVideoPath;
    if (videoPath.isEmpty || !await File(videoPath).exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비디오 경로가 올바르지 않습니다.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    await _trimmer.loadVideo(videoPath);
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    await _videoPlayerController!.initialize();

    if (mounted) {
      setState(() {
        _endValue =
            _videoPlayerController!.value.duration.inMilliseconds.toDouble();
        _isPlayerInitialized = true;
        _thumbnailsFuture = _generateThumbnails();
      });
    }
  }

  Future<List<Uint8List>> _generateThumbnails() async {
    final List<Uint8List> thumbnails = [];
    final videoPath = FFAppState().uploadVideoPath;
    if (videoPath.isEmpty) return [];

    final videoDurationMs =
        _videoPlayerController!.value.duration.inMilliseconds;

    const int thumbnailCount = 10;
    final double interval =
        videoDurationMs / (thumbnailCount > 1 ? thumbnailCount - 1 : 1);

    for (int i = 0; i < thumbnailCount; i++) {
      final timeMs = (interval * i).toInt();
      try {
        final Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 25,
          timeMs: timeMs,
        );
        if (thumbnail != null) {
          thumbnails.add(thumbnail);
        }
      } catch (e) {
        print("썸네일 생성 오류 (시간: $timeMs ms): $e");
      }
    }

    if (mounted && thumbnails.isNotEmpty) {
      setState(() {
        _selectedCoverBytes = thumbnails.first;
        _selectedCoverIndex = 0;
      });
    }
    return thumbnails;
  }

  void _onNextButtonPressed() async {
    if (_currentPageIndex == 0) {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isPlaying) {
        await _videoPlayerController!.pause();
      }
      FFAppState().update(() {
        FFAppState().uploadStartMs = _startValue;
        FFAppState().uploadEndMs = _endValue;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentPageIndex == 1) {
      if (_selectedCoverBytes != null) {
        FFAppState().update(() {
          FFAppState().uploadCoverBytes = base64Encode(_selectedCoverBytes!);
        });
        context.pushNamed('ImageEditorPage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('커버 이미지를 먼저 선택해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isPlayerInitialized
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: <Widget>[
                  _buildHeader(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) =>
                          setState(() => _currentPageIndex = index),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              _currentPageIndex == 0 ? Icons.close : Icons.arrow_back_ios,
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
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: _onNextButtonPressed,
            child: const Text('다음',
                style: TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
          ),
        ),
        _buildCustomTrimEditor(),
        IconButton(
          icon: Icon(
            _videoPlayerController!.value.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
            size: 60.0,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              final isPlaying = _videoPlayerController!.value.isPlaying;
              if (isPlaying) {
                _videoPlayerController!.pause();
              } else {
                _videoPlayerController!
                    .seekTo(Duration(milliseconds: _startValue.toInt()));
                _videoPlayerController!.play();
              }
            });
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomTrimEditor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // 듀레이션 텍스트 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(Duration(milliseconds: _startValue.toInt())),
                  style: TextStyle(color: Colors.white)),
              Text(formatDuration(Duration(milliseconds: _endValue.toInt())),
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 50,
            child: FutureBuilder<List<Uint8List>>(
              future: _thumbnailsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                      color: Colors.grey[800],
                      child: Center(
                          child: Text("썸네일 생성중...",
                              style: TextStyle(color: Colors.white))));
                }

                final thumbnails = snapshot.data!;
                final maxDuration = _videoPlayerController!
                    .value.duration.inMilliseconds
                    .toDouble();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final viewerWidth = constraints.maxWidth;
                    double startPx = (_startValue / maxDuration) * viewerWidth;
                    double endPx = (_endValue / maxDuration) * viewerWidth;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // 썸네일 스트립
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Container(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: thumbnails.length,
                              itemBuilder: (context, index) => Image.memory(
                                thumbnails[index],
                                width: viewerWidth / thumbnails.length,
                                height: 50,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                            ),
                          ),
                        ),

                        // 편집기 오버레이
                        Positioned.fill(
                          child: Stack(
                            children: [
                              // 어둡게 처리 (왼쪽)
                              Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                      width: startPx,
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft:
                                                  Radius.circular(5))))),
                              // 어둡게 처리 (오른쪽)
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                      width: viewerWidth - endPx,
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight:
                                                  Radius.circular(5))))),

                              // 상단 테두리
                              Positioned(
                                  top: 0,
                                  left: startPx,
                                  child: Container(
                                      width: endPx - startPx,
                                      height: 4,
                                      color: Colors.yellow)),
                              // 하단 테두리
                              Positioned(
                                  bottom: 0,
                                  left: startPx,
                                  child: Container(
                                      width: endPx - startPx,
                                      height: 4,
                                      color: Colors.yellow)),

                              // 시작 핸들
                              Positioned(
                                left: startPx - 8,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) =>
                                      setState(() {
                                    final newStartValue = _startValue +
                                        (details.delta.dx /
                                            viewerWidth *
                                            maxDuration);
                                    _startValue = newStartValue.clamp(
                                        0.0, _endValue - 1000);
                                    _videoPlayerController!.seekTo(Duration(
                                        milliseconds: _startValue.toInt()));
                                  }),
                                  child: Container(
                                      width: 16,
                                      color: Colors.yellow,
                                      child: Icon(Icons.chevron_left,
                                          color: Colors.black, size: 16)),
                                ),
                              ),

                              // 종료 핸들
                              Positioned(
                                left: endPx - 8,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) =>
                                      setState(() {
                                    final newEndValue = _endValue +
                                        (details.delta.dx /
                                            viewerWidth *
                                            maxDuration);
                                    _endValue = newEndValue.clamp(
                                        _startValue + 1000, maxDuration);
                                    _videoPlayerController!.seekTo(Duration(
                                        milliseconds: _endValue.toInt()));
                                  }),
                                  child: Container(
                                      width: 16,
                                      color: Colors.yellow,
                                      child: Icon(Icons.chevron_right,
                                          color: Colors.black, size: 16)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSelectionPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('커버로 사용할 프레임을 선택하세요.',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Expanded(
          child: Center(
            child: _selectedCoverBytes != null
                ? Image.memory(_selectedCoverBytes!, fit: BoxFit.contain)
                : const CircularProgressIndicator(color: Colors.white),
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
                final thumbnails = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCoverBytes = thumbnails[index];
                        _selectedCoverIndex = index;
                      }),
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedCoverIndex == index
                                ? Colors.yellow
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(thumbnails[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            },
          ),
        ),
      ],
    );
  }
}
