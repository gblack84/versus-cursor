import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/features/common/presentation/design_system/design_system.dart';

/// 알림 이미지 전체화면 뷰어
/// 
/// 알림에서 이미지를 탭했을 때 표시되는 전체화면 모달입니다.
/// A/B 이미지를 스와이프로 전환하고 하단에 상세 정보를 표시합니다.
class NotificationImageViewer extends StatefulWidget {
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
  
  const NotificationImageViewer({
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
    // Overlay context에서는 rootNavigator를 사용해야 함
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) => NotificationImageViewer(
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
  State<NotificationImageViewer> createState() => _NotificationImageViewerState();
}

class _NotificationImageViewerState extends State<NotificationImageViewer> {
  // 각 박스별 독립적인 PageController
  late PageController _pageControllerA;
  late PageController _pageControllerB;
  
  // 박스별 관리를 위한 상태 변수
  String _currentBoxType = 'A';
  int _currentIndexInBoxA = 0;
  int _currentIndexInBoxB = 0;
  
  // 텍스트 확장/축소 상태
  bool _isQuestionExpanded = false;
  bool _isDescriptionExpanded = false;
  
  @override
  void initState() {
    super.initState();
    
    // 멀티이미지 데이터 디버그
    print('[NotificationImageViewer] ===== initState 디버그 =====');
    print('  - widget.imageUrlsA: ${widget.imageUrlsA?.length ?? 0}개');
    print('  - widget.imageUrlsB: ${widget.imageUrlsB?.length ?? 0}개');
    print('  - widget.imageUrlA: ${widget.imageUrlA != null ? "있음" : "없음"}');
    print('  - widget.imageUrlB: ${widget.imageUrlB != null ? "있음" : "없음"}');
    print('  - widget.optionA: ${widget.optionA}');
    print('  - widget.optionB: ${widget.optionB}');
    
    // 초기 박스 타입과 인덱스 계산
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    print('  - effectiveUrlsA: ${effectiveUrlsA.length}개');
    print('  - effectiveUrlsB: ${effectiveUrlsB.length}개');
    print('  - initialIndex: ${widget.initialIndex}');
    
    if (widget.initialIndex >= effectiveUrlsA.length) {
      // B박스에서 시작
      _currentBoxType = 'B';
      _currentIndexInBoxA = 0;
      _currentIndexInBoxB = widget.initialIndex - effectiveUrlsA.length;
    } else {
      // A박스에서 시작
      _currentBoxType = 'A';
      _currentIndexInBoxA = widget.initialIndex;
      _currentIndexInBoxB = 0;
    }
    
    print('  - 시작 박스: $_currentBoxType');
    print('  - A박스 인덱스: $_currentIndexInBoxA');
    print('  - B박스 인덱스: $_currentIndexInBoxB');
    
    // 각 박스별 PageController 초기화
    _pageControllerA = PageController(initialPage: _currentIndexInBoxA);
    _pageControllerB = PageController(initialPage: _currentIndexInBoxB);
  }
  
  @override
  void dispose() {
    _pageControllerA.dispose();
    _pageControllerB.dispose();
    super.dispose();
  }
  
  
  /// 박스별 효과적인 이미지 URL 리스트 반환
  /// 
  /// 멀티이미지가 있으면 우선 사용, 없으면 단일 이미지 사용
  List<String> _getEffectiveImageUrls(String boxType) {
    if (boxType == 'A') {
      if (widget.imageUrlsA != null && widget.imageUrlsA!.isNotEmpty) {
        return widget.imageUrlsA!;
      }
      if (widget.imageUrlA != null) {
        return [widget.imageUrlA!];
      }
    } else if (boxType == 'B') {
      if (widget.imageUrlsB != null && widget.imageUrlsB!.isNotEmpty) {
        return widget.imageUrlsB!;
      }
      if (widget.imageUrlB != null) {
        return [widget.imageUrlB!];
      }
    }
    return [];
  }
  
  /// 현재 보고 있는 이미지 데이터 반환
  ({
    String? imageUrl, 
    String title, 
    String? description, 
    String boxType, 
    int imageIndex, 
    int totalInBox
  }) _getCurrentImageData() {
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    if (_currentBoxType == 'A' && effectiveUrlsA.isNotEmpty) {
      final index = _currentIndexInBoxA.clamp(0, effectiveUrlsA.length - 1);
      return (
        imageUrl: effectiveUrlsA[index],
        title: widget.optionA,
        description: widget.description,
        boxType: 'A',
        imageIndex: index + 1,
        totalInBox: effectiveUrlsA.length,
      );
    } else if (_currentBoxType == 'B' && effectiveUrlsB.isNotEmpty) {
      final index = _currentIndexInBoxB.clamp(0, effectiveUrlsB.length - 1);
      return (
        imageUrl: effectiveUrlsB[index],
        title: widget.optionB,
        description: widget.description,
        boxType: 'B',
        imageIndex: index + 1,
        totalInBox: effectiveUrlsB.length,
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
  
  @override
  Widget build(BuildContext context) {
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    if (effectiveUrlsA.isEmpty && effectiveUrlsB.isEmpty) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }
    
    // 단일 이미지 모드 체크 (B박스가 비어있는 경우)
    final bool isSingleImageMode = effectiveUrlsB.isEmpty;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 헤더
                _buildHeader(),
                
                // 이미지 뷰어
                Expanded(
                  child: isSingleImageMode
                      ? _buildSingleModeViewer(effectiveUrlsA)
                      : _buildDualModeViewer(effectiveUrlsA, effectiveUrlsB),
                ),
                
                // 페이지 인디케이터
                if ((effectiveUrlsA.length + effectiveUrlsB.length) > 1) 
                  _buildPageIndicator(effectiveUrlsA.length + effectiveUrlsB.length),
                  
                // 하단 정보
                _buildBottomInfo(_getCurrentImageData()),
              ],
            ),
            // 스와이프 힌트를 화면 정중앙에 표시
            if (_shouldShowSwipeHint())
              Center(
                child: _buildSwipeHint(),
              ),
          ],
        ),
      ),
    );
  }
  
  /// 단일 이미지 모드 뷰어 (A박스만 표시)
  Widget _buildSingleModeViewer(List<String> effectiveUrlsA) {
    return effectiveUrlsA.isNotEmpty
        ? PageView.builder(
            controller: _pageControllerA,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentIndexInBoxA = index;
              });
            },
            itemCount: effectiveUrlsA.length,
            itemBuilder: (context, index) {
              return _buildImageView((
                imageUrl: effectiveUrlsA[index],
                title: widget.optionA,
                description: widget.description,
                boxType: 'A',
                imageIndex: index + 1,
                totalInBox: effectiveUrlsA.length,
              ));
            },
          )
        : const SizedBox.shrink();
  }
  
  /// 듀얼 모드 뷰어 (A/B 박스 모두 표시)
  Widget _buildDualModeViewer(List<String> effectiveUrlsA, List<String> effectiveUrlsB) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // 스와이프 속도와 방향 확인
        if (details.primaryVelocity == null) return;
        
        print('[NotificationImageViewer] 좌우 스와이프 감지:');
        print('  - 속도: ${details.primaryVelocity}');
        print('  - 현재 박스: $_currentBoxType');
        print('  - A 이미지 수: ${effectiveUrlsA.length}');
        print('  - B 이미지 수: ${effectiveUrlsB.length}');
        
        if (details.primaryVelocity! < -300) {
          // 왼쪽 스와이프 - B로 이동
          if (effectiveUrlsB.isNotEmpty && _currentBoxType == 'A') {
            print('  → A에서 B로 전환!');
            setState(() {
              _currentBoxType = 'B';
            });
          }
        } else if (details.primaryVelocity! > 300) {
          // 오른쪽 스와이프 - A로 이동
          if (effectiveUrlsA.isNotEmpty && _currentBoxType == 'B') {
            print('  → B에서 A로 전환!');
            setState(() {
              _currentBoxType = 'A';
            });
          }
        }
      },
      child: Stack(
        children: [
          // A박스 레이어
          AnimatedOpacity(
            opacity: _currentBoxType == 'A' ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _currentBoxType != 'A',
              child: effectiveUrlsA.isNotEmpty
                  ? PageView.builder(
                      controller: _pageControllerA,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndexInBoxA = index;
                        });
                      },
                      itemCount: effectiveUrlsA.length,
                      itemBuilder: (context, index) {
                        return _buildImageView((
                          imageUrl: effectiveUrlsA[index],
                          title: widget.optionA,
                          description: widget.description,
                          boxType: 'A',
                          imageIndex: index + 1,
                          totalInBox: effectiveUrlsA.length,
                        ));
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
              child: effectiveUrlsB.isNotEmpty
                  ? PageView.builder(
                      controller: _pageControllerB,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndexInBoxB = index;
                        });
                      },
                      itemCount: effectiveUrlsB.length,
                      itemBuilder: (context, index) {
                        return _buildImageView((
                          imageUrl: effectiveUrlsB[index],
                          title: widget.optionB,
                          description: widget.description,
                          boxType: 'B',
                          imageIndex: index + 1,
                          totalInBox: effectiveUrlsB.length,
                        ));
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    final currentImage = _getCurrentImageData();
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    final bool isSingleMode = effectiveUrlsB.isEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          
          const Spacer(),
          
          // 현재 위치 표시 (오른쪽 끝)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isSingleMode ? Colors.red : (_currentBoxType == 'A' ? Colors.red : Colors.green),
                width: 1.5,
              ),
            ),
            child: Text(
              isSingleMode 
                  ? '${currentImage.imageIndex}/${currentImage.totalInBox}'
                  : '${currentImage.boxType} ${currentImage.imageIndex}/${currentImage.totalInBox}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageView(({
    String? imageUrl, 
    String title, 
    String? description, 
    String boxType, 
    int imageIndex, 
    int totalInBox
  }) data) {
    if (data.imageUrl == null) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
      );
    }
    
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: data.imageUrl!,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error, color: Colors.red, size: 64),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator(int count) {
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    final bool isSingleMode = effectiveUrlsB.isEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 박스별 인디케이터를 분리하여 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // A박스 인디케이터 (빨간색)
              if (effectiveUrlsA.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(effectiveUrlsA.length, (index) {
                    final isActive = _currentBoxType == 'A' && index == _currentIndexInBoxA;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      width: isActive ? 20.0 : 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: isActive 
                          ? Colors.red 
                          : (isSingleMode || _currentBoxType == 'A' ? Colors.red.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    );
                  }),
                ),
              ],
              
              // A/B 구분선 (듀얼 모드에서만 표시)
              if (effectiveUrlsA.isNotEmpty && effectiveUrlsB.isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 10,
                  color: Colors.white24,
                ),
                const SizedBox(width: 16),
              ],
              
              // B박스 인디케이터 (녹색)
              if (effectiveUrlsB.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(effectiveUrlsB.length, (index) {
                    final isActive = _currentBoxType == 'B' && index == _currentIndexInBoxB;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      width: isActive ? 20.0 : 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: isActive 
                          ? Colors.green 
                          : (_currentBoxType == 'B' ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
          
          // 박스 라벨 및 스와이프 안내
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSingleMode ? '이미지' : (_currentBoxType == 'A' ? 'A 이미지' : 'B 이미지'),
                style: TextStyle(
                  color: isSingleMode ? Colors.red : (_currentBoxType == 'A' ? Colors.red : Colors.green),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_getEffectiveImageUrls('A').isNotEmpty && _getEffectiveImageUrls('B').isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.swipe,
                  size: 16,
                  color: Colors.white38,
                ),
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.swipe_vertical_rounded,
                  size: 16,
                  color: Colors.white38,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomInfo(({
    String? imageUrl, 
    String title, 
    String? description, 
    String boxType, 
    int imageIndex, 
    int totalInBox
  }) data) {
    final isA = data.boxType == 'A';
    final labelColor = isA ? VersusColors.primary : VersusColors.secondary;
    
    // 단일 이미지 모드 체크 (B박스가 비어있는 경우)
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    final bool isSingleMode = effectiveUrlsB.isEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black,
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 텍스트 스타일 정의
          const questionStyle = TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          );
          const descriptionStyle = TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          );
          
          // 텍스트가 지정된 줄 수를 초과하는지 확인
          final questionExceedsLimit = _exceedsMaxLines(
            widget.question,
            questionStyle,
            constraints.maxWidth - 50, // Q: 라벨 너비 고려
            2
          );
          
          final descriptionExceedsLimit = data.description != null && 
            data.description!.isNotEmpty &&
            _exceedsMaxLines(
              data.description!,
              descriptionStyle,
              constraints.maxWidth - 50, // D: 라벨 너비 고려
              3
            );
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 질문 제목
              GestureDetector(
                onTap: questionExceedsLimit ? () {
                  setState(() {
                    _isQuestionExpanded = !_isQuestionExpanded;
                  });
                } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Q: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: AnimatedCrossFade(
                          firstChild: Text(
                            widget.question,
                            style: questionStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            widget.question,
                            style: questionStyle,
                          ),
                          crossFadeState: _isQuestionExpanded 
                              ? CrossFadeState.showSecond 
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ),
                      if (questionExceedsLimit)
                        AnimatedRotation(
                          turns: _isQuestionExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 옵션 정보
              if (isSingleMode) ...[
                // 단일 이미지 모드: A/B 타이틀 모두 표시
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A 옵션
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: VersusColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: VersusColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.optionA,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // B 옵션
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: VersusColors.secondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'B',
                            style: TextStyle(
                              color: VersusColors.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.optionB,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                // 듀얼 모드: 현재 보고 있는 이미지의 타이틀만 표시
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: labelColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        isA ? 'A' : 'B',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // 설명 (있는 경우)
              if (data.description != null && data.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: descriptionExceedsLimit ? () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  } : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'D: ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                        Expanded(
                          child: AnimatedCrossFade(
                            firstChild: Text(
                              data.description!,
                              style: descriptionStyle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              data.description!,
                              style: descriptionStyle,
                            ),
                            crossFadeState: _isDescriptionExpanded 
                                ? CrossFadeState.showSecond 
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ),
                        if (descriptionExceedsLimit)
                          AnimatedRotation(
                            turns: _isDescriptionExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
  
  /// 스와이프 힌트 표시 여부 결정
  bool _shouldShowSwipeHint() {
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    // 이미지가 없거나 하나만 있으면 힌트 표시 안 함
    return (effectiveUrlsA.length + effectiveUrlsB.length) > 1;
  }
  
  /// 텍스트가 지정된 줄 수를 초과하는지 확인
  bool _exceedsMaxLines(String text, TextStyle style, double maxWidth, int maxLines) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    
    return textPainter.didExceedMaxLines;
  }
  
  /// 스와이프 힌트 표시
  Widget _buildSwipeHint() {
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        // 투명도 계산: 1.5초까지는 완전 불투명, 1.5초~2초 사이에 페이드아웃
        double opacity;
        if (value < 0.75) {  // 0~1.5초
          opacity = 1.0;  // 완전 불투명
        } else {  // 1.5초~2초
          opacity = (1.0 - value) * 4;  // 1.0에서 0.0으로 감소
        }
        
        if (opacity > 0) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (effectiveUrlsA.isNotEmpty && effectiveUrlsB.isNotEmpty) ...[
                  Icon(
                    Icons.swipe,
                    color: Colors.white.withValues(alpha: opacity),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '좌우: A/B 전환\n상하: 이미지',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: opacity),
                      fontSize: 10,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Icon(
                    Icons.swipe_vertical,
                    color: Colors.white.withValues(alpha: opacity),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '위아래로\n스와이프',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: opacity),
                      fontSize: 11,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}