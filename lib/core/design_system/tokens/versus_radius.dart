import 'package:flutter/material.dart';

/// Versus Space Border Radius 시스템
/// 
/// 기존 코드에서 사용되는 BorderRadius.circular() 값들을 표준화했습니다.
/// AI Moderation 다이얼로그 (16px), 버튼 (8px) 등의 패턴을 기반으로 합니다.
class VersusRadius {
  // 기본 Radius 값들
  static const double none = 0.0;
  static const double small = 8.0;    // 버튼용 (기존 OutlinedButton 패턴)
  static const double medium = 16.0;  // 다이얼로그/카드용 (기존 AlertDialog 패턴)
  static const double large = 24.0;   // 큰 컨테이너용
  static const double circular = 25.0; // 원형 요소용
  
  // BorderRadius 헬퍼 메서드
  static BorderRadius get radiusNone => BorderRadius.circular(none);
  static BorderRadius get radiusSmall => BorderRadius.circular(small);
  static BorderRadius get radiusMedium => BorderRadius.circular(medium);
  static BorderRadius get radiusLarge => BorderRadius.circular(large);
  static BorderRadius get radiusCircular => BorderRadius.circular(circular);
  
  // 커스텀 radius 생성기
  static BorderRadius custom(double value) => BorderRadius.circular(value);
  
  // 방향별 radius (필요시 사용)
  static BorderRadius only({
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomLeft = 0.0,
    double bottomRight = 0.0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );
  
  // 자주 사용되는 패턴들
  static BorderRadius get button => radiusSmall;     // 버튼용 8px
  static BorderRadius get dialog => radiusMedium;    // 다이얼로그용 16px
  static BorderRadius get card => radiusMedium;      // 카드용 16px
  static BorderRadius get container => radiusSmall;  // 컨테이너용 8px
  
  // RoundedRectangleBorder 헬퍼 (기존 OutlinedButton.styleFrom 패턴)
  static RoundedRectangleBorder get buttonShape => RoundedRectangleBorder(
    borderRadius: button,
  );
  
  static RoundedRectangleBorder get dialogShape => RoundedRectangleBorder(
    borderRadius: dialog,
  );
  
  static RoundedRectangleBorder customShape(double radius) => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );
}