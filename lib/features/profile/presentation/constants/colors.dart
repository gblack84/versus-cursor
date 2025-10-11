import 'package:flutter/material.dart';

/// 프로필 기능 전용 색상 상수
///
/// **Clean Architecture v4.0 준수**:
/// - 의미론적 색상 네이밍
/// - AppTheme 보조 색상
/// - 접근성 고려 (WCAG 2.1 AA)
class ProfileColors {
  ProfileColors._();

  // 포인트 색상
  static const Color pointsAColor = Color(0xFF4A90E2); // Primary blue
  static const Color pointsQColor = Color(0xFF7B68EE); // Secondary purple

  // 등급 색상
  static const Color rankBronze = Color(0xFFCD7F32);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankPlatinum = Color(0xFFE5E4E2);
  static const Color rankDiamond = Color(0xFFB9F2FF);

  // 프리미엄 색상
  static const Color premiumBadge = Color(0xFFFFD700); // Gold
  static const Color premiumBackground = Color(0xFFFFF8DC); // Cornsilk

  // 관심사 카테고리 색상
  static const Color expertiseColor = Color(0xFF4A90E2); // Blue
  static const Color hobbyColor = Color(0xFF7B68EE); // Purple
  static const Color interestColor = Color(0xFF50C878); // Emerald

  // 친구 상태 색상
  static const Color friendOnline = Color(0xFF4CAF50); // Green
  static const Color friendOffline = Color(0xFF9E9E9E); // Grey
  static const Color friendRequestPending = Color(0xFFFFA726); // Orange

  // 성별 색상 (접근성 고려)
  static const Color genderMale = Color(0xFF2196F3); // Blue
  static const Color genderFemale = Color(0xFFE91E63); // Pink
  static const Color genderOther = Color(0xFF9C27B0); // Purple

  // 상태 색상
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Gradient 색상
  static const List<Color> profileHeaderGradient = [
    Color(0xFF4A90E2), // Primary
    Color(0xFF7B68EE), // Secondary
  ];

  static const List<Color> premiumGradient = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFFA500), // Orange
  ];

  // 투명도 프리셋
  static const double alphaDisabled = 0.38;
  static const double alphaPressed = 0.12;
  static const double alphaHover = 0.08;
  static const double alphaFocus = 0.24;
  static const double alphaDivider = 0.12;
}
