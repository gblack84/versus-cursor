import 'package:flutter/material.dart';

/// Versus Space 색상 시스템
///
/// 기존 AppTheme과 UI 패턴에서 추출한 표준 색상입니다.
/// 일관된 브랜딩과 사용자 경험을 위해 모든 컴포넌트에서 사용됩니다.
class VersusColors {
  // 브랜드 색상 (기존 AppTheme 기반)
  static const Color primary = Color(0xFFD95B5B); // 빨간색 (주요 CTA)
  static const Color secondary = Color(0xFF588157); // 초록색 (보조 액션)

  // 배경 색상
  static const Color backgroundPrimary = Color(0xFFFAF9F6); // 메인 배경
  static const Color backgroundSecondary = Color(0xFFF5F2E8); // 카드/섹션 배경

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF4A444B); // 주요 텍스트
  static const Color textSecondary = Color(0xFF8A817C); // 보조 텍스트

  // UI 요소 색상
  static const Color borderColor = Colors.black; // 테두리 (일관된 패턴)
  static const Color borderLight = Color(0xFFE0E3E7); // 연한 테두리

  // 상태 색상
  static const Color success = Color(0xFF249689); // 성공
  static const Color warning = Color(0xFFF9CF58); // 경고
  static const Color error = Color(0xFFFF5963); // 에러
  static const Color info = Color(0xFF4B39EF); // 정보

  // 투명도가 적용된 색상
  static Color primaryWithAlpha(double alpha) =>
      primary.withValues(alpha: alpha);
  static Color secondaryWithAlpha(double alpha) =>
      secondary.withValues(alpha: alpha);
  static Color blackWithAlpha(double alpha) =>
      Colors.black.withValues(alpha: alpha);
  static Color whiteWithAlpha(double alpha) =>
      Colors.white.withValues(alpha: alpha);

  // 다크 모드 지원 (향후 확장 용도)
  static const Color darkPrimary = Color(0xFF4B39EF);
  static const Color darkSecondary = Color(0xFF39D2C0);
  static const Color darkBackground = Color(0xFF1D2428);
  static const Color darkSurface = Color(0xFF14181B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF95A1AC);
}
