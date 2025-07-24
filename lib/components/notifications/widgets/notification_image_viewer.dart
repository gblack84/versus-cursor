import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/design_system/design_system.dart';

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
  final String? descriptionA;
  final String? descriptionB;
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
    this.descriptionA,
    this.descriptionB,
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
    String? descriptionA,
    String? descriptionB,
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
          descriptionA: descriptionA,
          descriptionB: descriptionB,
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
  
  @override
  void initState() {
    super.initState();
    
    // 초기 박스 타입과 인덱스 계산
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    
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
        description: widget.descriptionA,
        boxType: 'A',
        imageIndex: index + 1,
        totalInBox: effectiveUrlsA.length,
      );
    } else if (_currentBoxType == 'B' && effectiveUrlsB.isNotEmpty) {
      final index = _currentIndexInBoxB.clamp(0, effectiveUrlsB.length - 1);
      return (
        imageUrl: effectiveUrlsB[index],
        title: widget.optionB,
        description: widget.descriptionB,
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
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            
            // 이미지 뷰어 - Stack 구조로 변경
            Expanded(
              child: GestureDetector(
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
                                    description: widget.descriptionA,
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
                                    description: widget.descriptionB,
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
              ),
            ),
            
            // 페이지 인디케이터
            if ((effectiveUrlsA.length + effectiveUrlsB.length) > 1) 
              _buildPageIndicator(effectiveUrlsA.length + effectiveUrlsB.length),
            
            // 하단 정보
            _buildBottomInfo(_getCurrentImageData()),
          ],
        ),
      ),
      floatingActionButton: _buildSwipeHint(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  Widget _buildHeader() {
    final currentImage = _getCurrentImageData();
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          
          // 현재 박스 타입과 이미지 위치 표시
          if (effectiveUrlsA.isNotEmpty && effectiveUrlsB.isNotEmpty) ...[
            const SizedBox(width: 16),
            Row(
              children: [
                // A/B 전환 가능 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'A ⇄ B',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 현재 위치
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: _currentBoxType == 'A' ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${currentImage.boxType} ${currentImage.imageIndex}/${currentImage.totalInBox}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: _currentBoxType == 'A' ? Colors.red : Colors.green,
                  width: 1.5,
                ),
              ),
              child: Text(
                '${currentImage.boxType} ${currentImage.imageIndex}/${currentImage.totalInBox}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          const Spacer(),
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
                          : (_currentBoxType == 'A' ? Colors.red.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    );
                  }),
                ),
              ],
              
              // A/B 구분선
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
                _currentBoxType == 'A' ? 'A 이미지' : 'B 이미지',
                style: TextStyle(
                  color: _currentBoxType == 'A' ? Colors.red : Colors.green,
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
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문 제목
          Text(
            widget.question,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          // 옵션 정보
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
          
          // 설명 (있는 경우)
          if (data.description != null && data.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(
                  data.description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 스와이프 힌트 표시
  Widget? _buildSwipeHint() {
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    
    // 이미지가 없거나 하나만 있으면 힌트 표시 안 함
    if ((effectiveUrlsA.length + effectiveUrlsB.length) <= 1) return null;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        if (value < 0.9) {
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
                    color: Colors.white.withValues(alpha: 1.0 - value),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '좌우: A/B 전환\n상하: 이미지',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 1.0 - value),
                      fontSize: 10,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Icon(
                    Icons.swipe_vertical,
                    color: Colors.white.withValues(alpha: 1.0 - value),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '위아래로\n스와이프',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 1.0 - value),
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