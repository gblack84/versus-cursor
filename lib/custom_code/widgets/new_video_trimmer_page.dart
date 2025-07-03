// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/core/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoPlayerController;
  final PageController _pageController = PageController();

  int _currentPageIndex = 0;
  double _startValue = 0.0;
  double _endValue = 0.0;
  final double _maxTrimDuration = 180000.0;

  Future<List<Uint8List>>? _thumbnailsFuture;
  Uint8List? _selectedCoverBytes;
  int _selectedCoverIndex = -1;

  bool _isPlayerInitialized = false;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _pageController.dispose();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _videoListener() {
    if (!mounted || _videoPlayerController == null) return;
    final position =
        _videoPlayerController!.value.position.inMilliseconds.toDouble();
    if (_currentPosition != position) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null || !_isPlayerInitialized) return;
    final isPlaying = _videoPlayerController!.value.isPlaying;
    setState(() {
      _isPlaying = !isPlaying;
      if (_isPlaying) {
        if (_videoPlayerController!.value.position.inMilliseconds >=
            _endValue.toInt()) {
          _videoPlayerController!
              .seekTo(Duration(milliseconds: _startValue.toInt()));
        }
        _videoPlayerController!.play();
        _startPlaybackTimer();
      } else {
        _videoPlayerController!.pause();
        _playbackTimer?.cancel();
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted ||
          _videoPlayerController == null ||
          !_videoPlayerController!.value.isInitialized) {
        timer.cancel();
        return;
      }
      if (_videoPlayerController!.value.position.inMilliseconds >=
          _endValue.toInt()) {
        _videoPlayerController!.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentPosition = _endValue;
          });
        }
        timer.cancel();
      }
    });
  }

  Future<void> _loadVideo() async {
    final videoPath = AppState().uploadVideoPath;
    if (videoPath.isEmpty || !await File(videoPath).exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비디오 경로가 올바르지 않습니다.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    await _videoPlayerController!.initialize();
    _videoPlayerController!.addListener(_videoListener);

    if (mounted) {
      setState(() {
        final totalDuration =
            _videoPlayerController!.value.duration.inMilliseconds.toDouble();
        _endValue =
            totalDuration > _maxTrimDuration ? _maxTrimDuration : totalDuration;
        _isPlayerInitialized = true;
        _thumbnailsFuture =
            _generateThumbnails(0, totalDuration, isForDisplay: true);
      });
    }
  }

  Future<List<Uint8List>> _generateThumbnails(double startTime, double endTime,
      {bool isForDisplay = false}) async {
    final List<Uint8List> thumbnails = [];
    final videoPath = AppState().uploadVideoPath;
    if (videoPath.isEmpty) return [];
    final double duration = endTime - startTime;
    final int thumbnailCount = isForDisplay ? 15 : 8;
    final double interval =
        duration / (thumbnailCount > 1 ? thumbnailCount - 1 : 1);
    for (int i = 0; i < thumbnailCount; i++) {
      final timeMs = (startTime + interval * i).toInt();
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
    if (!isForDisplay && mounted && thumbnails.isNotEmpty) {
      await _selectCoverImage(0, startTime, interval);
    }
    return thumbnails;
  }

  Future<void> _selectCoverImage(
      int index, double startTime, double interval) async {
    setState(() => _selectedCoverIndex = index);
    final timeMs = (startTime + (interval * index)).toInt();
    try {
      final Uint8List? highQualityThumb = await VideoThumbnail.thumbnailData(
        video: AppState().uploadVideoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1080,
        quality: 100,
        timeMs: timeMs,
      );
      if (highQualityThumb != null) {
        setState(() => _selectedCoverBytes = highQualityThumb);
      }
    } catch (e) {
      print("고화질 썸네일 생성 오류: $e");
    }
  }

  // 이 함수가 이전에 누락되었습니다.
  Future<void> _onCoverSelected() async {
    if (_selectedCoverBytes != null) {
      AppState().update(() {
        AppState().uploadCoverBytes = base64Encode(_selectedCoverBytes!);
      });
      context.pushNamed('ImageEditorPage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('커버 이미지를 먼저 선택해주세요.')),
      );
    }
  }

  void _onNextButtonPressed() async {
    if (_currentPageIndex == 0) {
      if (_videoPlayerController?.value.isPlaying == true) {
        _togglePlayPause();
      }
      AppState().update(() {
        AppState().uploadStartMs = _startValue;
        AppState().uploadEndMs = _endValue;
        if (_videoPlayerController != null) {
          AppState().uploadVideoAspectRatio =
              _videoPlayerController!.value.aspectRatio;
        }
      });
      setState(() {
        _thumbnailsFuture = _generateThumbnails(_startValue, _endValue);
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentPageIndex == 1) {
      await _onCoverSelected();
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
            : PageView(
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
    );
  }

  Widget _buildTrimPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                onPressed: _onNextButtonPressed,
                child: const Text('완료',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio > 0
                          ? _videoPlayerController!.value.aspectRatio
                          : 16 / 9,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  ),
                ),
                if (!_isPlaying)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildCustomTrimEditor(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text("드래그하여 동영상 조정", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildHeaderForCoverPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            ),
          ),
          TextButton(
            onPressed: _onCoverSelected,
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

  Widget _buildCustomTrimEditor() {
    const double timelineHeight = 50.0;
    const double handleWidth = 14.0;
    const double handleTouchWidth = 40.0;

    return SizedBox(
      width: double.infinity,
      height: timelineHeight,
      child: FutureBuilder<List<Uint8List>>(
          future: _thumbnailsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                  height: timelineHeight,
                  color: Colors.grey[900],
                  child: const Center(
                      child: Text("썸네일 생성중...",
                          style: TextStyle(color: Colors.white))));
            }

            final thumbnails = snapshot.data!;
            final maxDuration = _videoPlayerController!
                .value.duration.inMilliseconds
                .toDouble();

            return LayoutBuilder(builder: (context, constraints) {
              final viewerWidth = constraints.maxWidth;
              final double startPx = (_startValue / maxDuration) * viewerWidth;
              final double endPx = (_endValue / maxDuration) * viewerWidth;
              final double scrubPx =
                  (_currentPosition / maxDuration) * viewerWidth;

              return GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final selectedDuration = _endValue - _startValue;
                  final newStart = _startValue +
                      (details.delta.dx / viewerWidth * maxDuration);
                  final newEnd = newStart + selectedDuration;
                  if (newStart >= 0 && newEnd <= maxDuration) {
                    setState(() {
                      _startValue = newStart;
                      _endValue = newEnd;
                      _videoPlayerController!
                          .seekTo(Duration(milliseconds: _startValue.toInt()));
                    });
                  }
                },
                child: Container(
                  height: timelineHeight,
                  width: viewerWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  color: Colors.transparent, // 전체 드래그를 위해 배경색 지정
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Layer 1: Background Dimmed Thumbnails
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: SizedBox(
                          height: timelineHeight,
                          child: Stack(
                            children: [
                              ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: thumbnails.length,
                                itemBuilder: (context, index) => Image.memory(
                                  thumbnails[index],
                                  width: viewerWidth / thumbnails.length,
                                  height: timelineHeight,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                              ),
                              Container(color: Colors.black.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),

                      // Layer 2: Bright Selected Thumbnails
                      Positioned(
                        left: startPx,
                        height: timelineHeight,
                        width: endPx - startPx,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: (endPx - startPx) / viewerWidth,
                              child: SizedBox(
                                width: viewerWidth,
                                height: timelineHeight,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: -startPx,
                                      child: SizedBox(
                                        height: timelineHeight,
                                        width: viewerWidth,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: thumbnails.length,
                                          itemBuilder: (context, index) =>
                                              Image.memory(
                                            thumbnails[index],
                                            width:
                                                viewerWidth / thumbnails.length,
                                            height: timelineHeight,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Layer 3: Borders and Handles
                      Positioned(
                        left: startPx,
                        width: endPx - startPx,
                        height: timelineHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.yellow, width: 2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),

                      // Layer 4: Playback Scrubber (Seeker)
                      if (_currentPosition >= _startValue &&
                          _currentPosition <= _endValue)
                        Positioned(
                          left: scrubPx,
                          child: Container(
                            width: 2,
                            height: timelineHeight,
                            color: Colors.white,
                          ),
                        ),

                      // Layer 5: Handle Gestures
                      Positioned(
                          left: startPx - (handleTouchWidth / 2),
                          top: 0,
                          bottom: 0,
                          width: handleTouchWidth,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                final newStart = _startValue +
                                    (details.delta.dx /
                                        viewerWidth *
                                        maxDuration);
                                if (newStart >= 0 &&
                                    _endValue - newStart >= 1000 &&
                                    _endValue - newStart <= _maxTrimDuration) {
                                  _startValue = newStart;
                                  _videoPlayerController!.seekTo(Duration(
                                      milliseconds: _startValue.toInt()));
                                }
                              });
                            },
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    width: handleWidth,
                                    height: timelineHeight,
                                    color: Colors.yellow)),
                          )),
                      Positioned(
                          right: (viewerWidth - endPx) - (handleTouchWidth / 2),
                          top: 0,
                          bottom: 0,
                          width: handleTouchWidth,
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  final newEnd = _endValue +
                                      (details.delta.dx /
                                          viewerWidth *
                                          maxDuration);
                                  if (newEnd <= maxDuration &&
                                      newEnd - _startValue >= 1000 &&
                                      newEnd - _startValue <=
                                          _maxTrimDuration) {
                                    _endValue = newEnd;
                                    _videoPlayerController!.seekTo(Duration(
                                        milliseconds: _endValue.toInt()));
                                  }
                                });
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                    width: handleWidth,
                                    height: timelineHeight,
                                    color: Colors.yellow),
                              ))),

                      // Layer 6: Center Time indicator
                      Positioned(
                          left: startPx,
                          width: endPx - startPx,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${((_endValue - _startValue) / 1000).toStringAsFixed(1)}s',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              );
            });
          }),
    );
  }

  Widget _buildCoverSelectionPage() {
    return Column(
      children: [
        _buildHeaderForCoverPage(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('커버로 사용할 프레임을 선택하세요.',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Expanded(
          child: Center(
            child: _selectedCoverBytes != null
                ? AspectRatio(
                    aspectRatio:
                        _videoPlayerController?.value.aspectRatio ?? 16 / 9,
                    child:
                        Image.memory(_selectedCoverBytes!, fit: BoxFit.contain),
                  )
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
                final double duration = _endValue - _startValue;
                final double interval = duration /
                    (thumbnails.length > 1 ? thumbnails.length - 1 : 1);

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          _selectCoverImage(index, _startValue, interval),
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
