import 'package:flutter/material.dart';

/// 채팅 애니메이션 관리 서비스
/// FAB 및 기타 애니메이션 효과 제어
class ChatAnimationService {
  late AnimationController fabAnimationController;
  late Animation<double> fabBounceAnimation;
  late AnimationController fabScaleController;
  late Animation<double> fabScaleAnimation;
  
  /// 애니메이션 초기화
  void initializeAnimations(TickerProvider vsync) {
    // FAB 바운스 애니메이션
    fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    
    fabBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // FAB 스케일 애니메이션
    fabScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: vsync,
    );
    
    fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fabScaleController,
      curve: Curves.easeInOut,
    ));
  }
  
  /// FAB 바운스 애니메이션 실행
  Future<void> playFabBounce() async {
    await fabAnimationController.forward();
    await fabAnimationController.reverse();
  }
  
  /// FAB 표시
  void showFab() {
    fabScaleController.forward();
  }
  
  /// FAB 숨기기
  void hideFab() {
    fabScaleController.reverse();
  }
  
  /// 리소스 정리
  void dispose() {
    fabAnimationController.dispose();
    fabScaleController.dispose();
  }
}