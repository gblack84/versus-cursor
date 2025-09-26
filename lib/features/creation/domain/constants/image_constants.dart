/// 이미지 처리 관련 상수
class ImageConstants {
  // Image Sizes
  static const int displayMaxWidth = 800;
  static const int thumbnailSize = 150;
  static const int jpegQuality = 85;

  // Aspect Ratio Thresholds
  static const double landscapeThreshold = 1.2;
  static const double portraitThreshold = 0.8;
  static const double extremeLandscapeRatio = 1.5;
  static const double extremePortraitRatio = 0.67;

  // Box Size Limits
  static const double maxHeightHorizontal = 500;
  static const double minHeightHorizontal = 150;
  static const double maxHeightVertical = 400;
  static const double minHeightVertical = 120;
  static const double padding = 5;

  // Default Box Heights
  static const double defaultHeightHorizontal = 350;
  static const double defaultHeightVertical = 200;
  static const double defaultHeightSingle = 400;

  // Icon Size Ratios
  static const double horizontalIconRatio = 0.45;
  static const double verticalIconRatio = 0.40;
  static const double minIconSize = 80.0;
  static const double maxIconSize = 300.0;

  // Cache Size Ranges
  static const int minCacheSize = 200;
  static const int maxCacheSize = 800;
}
