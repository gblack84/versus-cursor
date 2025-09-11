import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';

/// 채팅 상세 페이지의 Floating Action Button 컴포넌트
class ChatDetailFAB extends StatelessWidget {
  final bool isAtBottom;
  final Animation<double> scaleAnimation;
  final Animation<double> bounceAnimation;
  final VoidCallback onPressed;

  const ChatDetailFAB({
    super.key,
    required this.isAtBottom,
    required this.scaleAnimation,
    required this.bounceAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: isAtBottom ? -100 : 16,
      right: 16,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          scaleAnimation,
          bounceAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value * bounceAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: VersusColors.primary,
              icon: const Icon(
                Icons.arrow_downward,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                '아래로',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
