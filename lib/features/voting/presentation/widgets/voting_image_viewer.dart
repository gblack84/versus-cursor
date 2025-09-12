import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'image_viewer/components/image_viewer_app_bar.dart';
import 'image_viewer/components/image_viewer_page_view.dart';
import 'image_viewer/components/image_viewer_controls.dart';
import 'image_viewer/components/image_viewer_indicators.dart';
import 'image_viewer/components/image_viewer_text_sections.dart';
import 'image_viewer/utils/image_viewer_helpers.dart';

/// 투표 이미지 전체화면 뷰어
///
/// 투표 알림에서 이미지를 탭했을 때 표시되는 전체화면 모달입니다.
/// A/B 이미지를 스와이프로 전환하고 하단에 상세 정보를 표시합니다.
class VotingImageViewer extends StatefulWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;

  /// 멀티이미지 지원 (새로운 기능)
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? description;
  final int initialIndex;

  const VotingImageViewer({
    Key? key,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.description,
    this.initialIndex = 0,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? description,
    int initialIndex = 0,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) =>
            VotingImageViewer(
          question: question,
          optionA: optionA,
          optionB: optionB,
          imageUrlA: imageUrlA,
          imageUrlB: imageUrlB,
          imageUrlsA: imageUrlsA,
          imageUrlsB: imageUrlsB,
          description: description,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<VotingImageViewer> createState() => _VotingImageViewerState();
}

class _VotingImageViewerState extends State<VotingImageViewer> {
  // 각 박스별 독립적인 PageController
  late PageController _pageControllerA;
  late PageController _pageControllerB;

  // 박스별 관리를 위한 상태 변수
  String _currentBoxType = 'A';
  int _currentIndexInBoxA = 0;
  int _currentIndexInBoxB = 0;

  // 효과적인 URL 리스트
  late List<String> _effectiveUrlsA;
  late List<String> _effectiveUrlsB;

  @override
  void initState() {
    super.initState();

    // 효과적인 URL 리스트 초기화
    _effectiveUrlsA = ImageViewerHelpers.getEffectiveImageUrls(
      boxType: 'A',
      imageUrlsA: widget.imageUrlsA,
      imageUrlsB: widget.imageUrlsB,
      imageUrlA: widget.imageUrlA,
      imageUrlB: widget.imageUrlB,
    );

    _effectiveUrlsB = ImageViewerHelpers.getEffectiveImageUrls(
      boxType: 'B',
      imageUrlsA: widget.imageUrlsA,
      imageUrlsB: widget.imageUrlsB,
      imageUrlA: widget.imageUrlA,
      imageUrlB: widget.imageUrlB,
    );

    // 초기 위치 계산
    final initialPosition = ImageViewerHelpers.calculateInitialPosition(
      initialIndex: widget.initialIndex,
      urlsA: _effectiveUrlsA,
      urlsB: _effectiveUrlsB,
    );

    _currentBoxType = initialPosition.boxType;
    _currentIndexInBoxA = initialPosition.indexA;
    _currentIndexInBoxB = initialPosition.indexB;

    // 각 박스별 PageController 초기화
    _pageControllerA = PageController(initialPage: _currentIndexInBoxA);
    _pageControllerB = PageController(initialPage: _currentIndexInBoxB);

    _logInitState();
  }

  void _logInitState() {
    if (kDebugMode) {
      print('[VotingImageViewer] ===== initState 디버그 =====');
      print('  - widget.imageUrlsA: ${widget.imageUrlsA?.length ?? 0}개');
      print('  - widget.imageUrlsB: ${widget.imageUrlsB?.length ?? 0}개');
      print('  - effectiveUrlsA: ${_effectiveUrlsA.length}개');
      print('  - effectiveUrlsB: ${_effectiveUrlsB.length}개');
      print('  - initialIndex: ${widget.initialIndex}');
      print('  - 시작 박스: $_currentBoxType');
      print('  - A박스 인덱스: $_currentIndexInBoxA');
      print('  - B박스 인덱스: $_currentIndexInBoxB');
    }
  }

  @override
  void dispose() {
    _pageControllerA.dispose();
    _pageControllerB.dispose();
    super.dispose();
  }

  /// 현재 보고 있는 이미지 데이터 반환
  ImageData _getCurrentImageData() {
    if (_currentBoxType == 'A' && _effectiveUrlsA.isNotEmpty) {
      final index = _currentIndexInBoxA.clamp(0, _effectiveUrlsA.length - 1);
      return (
        imageUrl: _effectiveUrlsA[index],
        title: widget.optionA,
        description: widget.description,
        boxType: 'A',
        imageIndex: index + 1,
        totalInBox: _effectiveUrlsA.length,
      );
    } else if (_currentBoxType == 'B' && _effectiveUrlsB.isNotEmpty) {
      final index = _currentIndexInBoxB.clamp(0, _effectiveUrlsB.length - 1);
      return (
        imageUrl: _effectiveUrlsB[index],
        title: widget.optionB,
        description: widget.description,
        boxType: 'B',
        imageIndex: index + 1,
        totalInBox: _effectiveUrlsB.length,
      );
    }

    // 기본값 반환
    return (
      imageUrl: null,
      title: '',
      description: null,
      boxType: 'A',
      imageIndex: 1,
      totalInBox: 1,
    );
  }

  void _handleSwitchToA() {
    if (_effectiveUrlsA.isNotEmpty && _currentBoxType == 'B') {
      if (kDebugMode) {
        print('[VotingImageViewer] B에서 A로 전환!');
      }
      setState(() {
        _currentBoxType = 'A';
      });
    }
  }

  void _handleSwitchToB() {
    if (_effectiveUrlsB.isNotEmpty && _currentBoxType == 'A') {
      if (kDebugMode) {
        print('[VotingImageViewer] A에서 B로 전환!');
      }
      setState(() {
        _currentBoxType = 'B';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이미지가 없으면 팝
    if (_effectiveUrlsA.isEmpty && _effectiveUrlsB.isEmpty) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    final isSingleImageMode = _effectiveUrlsB.isEmpty;
    final currentData = _getCurrentImageData();
    final shouldShowSwipeHint = 
        (_effectiveUrlsA.length + _effectiveUrlsB.length) > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 헤더
                ImageViewerAppBar(
                  boxType: currentData.boxType,
                  imageIndex: currentData.imageIndex,
                  totalInBox: currentData.totalInBox,
                  isSingleMode: isSingleImageMode,
                  onClose: () => Navigator.of(context).pop(),
                ),

                // 이미지 뷰어
                Expanded(
                  child: isSingleImageMode
                      ? _buildSingleModeViewer()
                      : _buildDualModeViewer(),
                ),

                // 페이지 인디케이터
                ImageViewerIndicators(
                  urlsA: _effectiveUrlsA,
                  urlsB: _effectiveUrlsB,
                  currentBoxType: _currentBoxType,
                  currentIndexA: _currentIndexInBoxA,
                  currentIndexB: _currentIndexInBoxB,
                  isSingleMode: isSingleImageMode,
                ),

                // 하단 정보
                ImageViewerTextSections(
                  question: widget.question,
                  optionA: widget.optionA,
                  optionB: widget.optionB,
                  description: widget.description,
                  currentBoxType: currentData.boxType,
                  isSingleMode: isSingleImageMode,
                ),
              ],
            ),

            // 스와이프 힌트를 화면 정중앙에 표시
            if (shouldShowSwipeHint)
              Center(
                child: ImageViewerSwipeHint(
                  hasMultipleBoxes: _effectiveUrlsA.isNotEmpty && 
                                    _effectiveUrlsB.isNotEmpty,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 단일 이미지 모드 뷰어 (A박스만 표시)
  Widget _buildSingleModeViewer() {
    return _effectiveUrlsA.isNotEmpty
        ? ImageViewerPageView(
            imageUrls: _effectiveUrlsA,
            controller: _pageControllerA,
            title: widget.optionA,
            description: widget.description,
            boxType: 'A',
            onPageChanged: (index) {
              setState(() {
                _currentIndexInBoxA = index;
              });
            },
          )
        : const SizedBox.shrink();
  }

  /// 듀얼 모드 뷰어 (A/B 박스 모두 표시)
  Widget _buildDualModeViewer() {
    return DualModeViewerWrapper(
      canSwitchToA: _effectiveUrlsA.isNotEmpty && _currentBoxType == 'B',
      canSwitchToB: _effectiveUrlsB.isNotEmpty && _currentBoxType == 'A',
      onSwitchToA: _handleSwitchToA,
      onSwitchToB: _handleSwitchToB,
      child: Stack(
        children: [
          // A박스 레이어
          AnimatedOpacity(
            opacity: _currentBoxType == 'A' ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _currentBoxType != 'A',
              child: _effectiveUrlsA.isNotEmpty
                  ? ImageViewerPageView(
                      imageUrls: _effectiveUrlsA,
                      controller: _pageControllerA,
                      title: widget.optionA,
                      description: widget.description,
                      boxType: 'A',
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndexInBoxA = index;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // B박스 레이어
          AnimatedOpacity(
            opacity: _currentBoxType == 'B' ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _currentBoxType != 'B',
              child: _effectiveUrlsB.isNotEmpty
                  ? ImageViewerPageView(
                      imageUrls: _effectiveUrlsB,
                      controller: _pageControllerB,
                      title: widget.optionB,
                      description: widget.description,
                      boxType: 'B',
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndexInBoxB = index;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}