/// 이미지 처리 비즈니스 로직 상수
/// Domain layer - UI 의존성 없음
class ImageProcessingConstants {
  // Image Processing Settings
  static const int displayMaxWidth = 800;
  static const int thumbnailSize = 150;
  static const int jpegQuality = 85;

  // Aspect Ratio Thresholds (비즈니스 규칙)
  static const double landscapeThreshold = 1.2;
  static const double portraitThreshold = 0.8;
  static const double extremeLandscapeRatio = 1.5;
  static const double extremePortraitRatio = 0.67;
}
