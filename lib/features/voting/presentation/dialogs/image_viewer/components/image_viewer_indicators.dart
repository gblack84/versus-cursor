import 'package:flutter/material.dart';

/// 이미지 뷰어 페이지 인디케이터
///
/// 현재 페이지 위치와 박스 정보를 표시합니다.
class ImageViewerIndicators extends StatelessWidget {
  final List<String> urlsA;
  final List<String> urlsB;
  final String currentBoxType;
  final int currentIndexA;
  final int currentIndexB;
  final bool isSingleMode;

  const ImageViewerIndicators({
    Key? key,
    required this.urlsA,
    required this.urlsB,
    required this.currentBoxType,
    required this.currentIndexA,
    required this.currentIndexB,
    required this.isSingleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCount = urlsA.length + urlsB.length;
    
    if (totalCount <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicatorDots(),
          const SizedBox(height: 8),
          _buildBoxLabels(),
        ],
      ),
    );
  }

  Widget _buildIndicatorDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // A박스 인디케이터 (빨간색)
        if (urlsA.isNotEmpty) ...[
          _buildBoxIndicators(
            count: urlsA.length,
            activeIndex: currentIndexA,
            isActive: currentBoxType == 'A',
            activeColor: Colors.red,
            inactiveColor: isSingleMode || currentBoxType == 'A'
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ],
        
        // A/B 구분선 (듀얼 모드에서만 표시)
        if (urlsA.isNotEmpty && urlsB.isNotEmpty) ...[
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 10,
            color: Colors.white24,
          ),
          const SizedBox(width: 16),
        ],
        
        // B박스 인디케이터 (녹색)
        if (urlsB.isNotEmpty) ...[
          _buildBoxIndicators(
            count: urlsB.length,
            activeIndex: currentIndexB,
            isActive: currentBoxType == 'B',
            activeColor: Colors.green,
            inactiveColor: currentBoxType == 'B'
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ],
    );
  }

  Widget _buildBoxIndicators({
    required int count,
    required int activeIndex,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isDotActive = isActive && index == activeIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          width: isDotActive ? 20.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: isDotActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(3.0),
          ),
        );
      }),
    );
  }

  Widget _buildBoxLabels() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isSingleMode
              ? '이미지'
              : (currentBoxType == 'A' ? 'A 이미지' : 'B 이미지'),
          style: TextStyle(
            color: isSingleMode
                ? Colors.red
                : (currentBoxType == 'A' ? Colors.red : Colors.green),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (urlsA.isNotEmpty && urlsB.isNotEmpty) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.swipe,
            size: 16,
            color: Colors.white38,
          ),
        ] else ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.swipe_vertical_rounded,
            size: 16,
            color: Colors.white38,
          ),
        ],
      ],
    );
  }
}