import 'package:flutter/material.dart';

/// 이미지 뷰어 스와이프 힌트 컴포넌트
///
/// 스와이프 제스처 안내를 표시합니다.
class ImageViewerSwipeHint extends StatelessWidget {
  final bool hasMultipleBoxes;
  
  const ImageViewerSwipeHint({
    Key? key,
    required this.hasMultipleBoxes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        // 투명도 계산: 1.5초까지는 완전 불투명, 1.5초~2초 사이에 페이드아웃
        double opacity;
        if (value < 0.75) {
          opacity = 1.0;
        } else {
          opacity = (1.0 - value) * 4;
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
                if (hasMultipleBoxes) ...[
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

/// 듀얼 모드 뷰어 래퍼
///
/// A/B 박스 간 스와이프 전환을 처리합니다.
class DualModeViewerWrapper extends StatelessWidget {
  final Widget child;
  final bool canSwitchToB;
  final bool canSwitchToA;
  final VoidCallback onSwitchToB;
  final VoidCallback onSwitchToA;

  const DualModeViewerWrapper({
    Key? key,
    required this.child,
    required this.canSwitchToB,
    required this.canSwitchToA,
    required this.onSwitchToB,
    required this.onSwitchToA,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;

        if (details.primaryVelocity! < -300 && canSwitchToB) {
          // 왼쪽 스와이프 - B로 이동
          onSwitchToB();
        } else if (details.primaryVelocity! > 300 && canSwitchToA) {
          // 오른쪽 스와이프 - A로 이동
          onSwitchToA();
        }
      },
      child: child,
    );
  }
}