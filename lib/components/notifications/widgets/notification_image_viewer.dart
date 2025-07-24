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
  late PageController _pageController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  /// 멀티이미지 지원 이미지 데이터
  /// 
  /// A박스의 모든 이미지들 → B박스의 모든 이미지들 순서로 구성
  List<({
    String? imageUrl, 
    String title, 
    String? description, 
    String boxType, 
    int imageIndex, 
    int totalInBox
  })> get _imageData {
    final images = <({
      String? imageUrl, 
      String title, 
      String? description, 
      String boxType, 
      int imageIndex, 
      int totalInBox
    })>[];
    
    // A박스 이미지들 추가 (멀티이미지 우선, 없으면 단일 이미지)
    final effectiveUrlsA = _getEffectiveImageUrls('A');
    for (int i = 0; i < effectiveUrlsA.length; i++) {
      images.add((
        imageUrl: effectiveUrlsA[i],
        title: widget.optionA,
        description: widget.descriptionA,
        boxType: 'A',
        imageIndex: i + 1,
        totalInBox: effectiveUrlsA.length,
      ));
    }
    
    // B박스 이미지들 추가 (멀티이미지 우선, 없으면 단일 이미지)
    final effectiveUrlsB = _getEffectiveImageUrls('B');
    for (int i = 0; i < effectiveUrlsB.length; i++) {
      images.add((
        imageUrl: effectiveUrlsB[i],
        title: widget.optionB,
        description: widget.descriptionB,
        boxType: 'B',
        imageIndex: i + 1,
        totalInBox: effectiveUrlsB.length,
      ));
    }
    
    return images;
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
  
  @override
  Widget build(BuildContext context) {
    final images = _imageData;
    if (images.isEmpty) {
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
            
            // 이미지 뷰어
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return _buildImageView(images[index]);
                },
              ),
            ),
            
            // 페이지 인디케이터
            if (images.length > 1) _buildPageIndicator(images.length),
            
            // 하단 정보
            _buildBottomInfo(images[_currentIndex]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final images = _imageData;
    final currentImage = images.isNotEmpty ? images[_currentIndex] : null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          // 멀티이미지 정보 표시 (예: "A 2/3" 또는 "B 1/2")
          if (currentImage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16.0),
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
          const SizedBox(width: 8),
          // 전체 이미지 인덱스
          Text(
            '${_currentIndex + 1} / ${images.length}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 48), // 아이콘 버튼 크기만큼 여백
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == _currentIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: isActive ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive ? VersusColors.primary : Colors.white24,
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }),
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
}