/// 타겟 오디언스 UI 관련 상수
///
/// Presentation layer에서만 사용되는 UI 관련 상수들을 정의합니다.
class TargetAudienceUIConstants {
  // Dialog 크기 관련
  static const double dialogWidth = 400.0;
  static const double dialogMaxHeight = 600.0;

  // Step indicator
  static const double stepIndicatorHeight = 60.0;

  // Padding & Spacing
  static const double contentPadding = 24.0;
  static const double itemSpacing = 16.0;
  static const double chipSpacing = 8.0;
  static const double chipRunSpacing = 8.0;

  // Button 크기
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;

  // Animation durations (milliseconds)
  static const int stepTransitionDuration = 300;
  static const int fadeInDuration = 200;

  // Colors - 필요 시 ThemeData에서 가져오도록 권장
  // 하드코딩된 색상은 피하고, Theme.of(context).primaryColor 등 사용

  // Text styles - 필요 시 Theme.of(context).textTheme 사용 권장

  // Private constructor to prevent instantiation
  TargetAudienceUIConstants._();
}