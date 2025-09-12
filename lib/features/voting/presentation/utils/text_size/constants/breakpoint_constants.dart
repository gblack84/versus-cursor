/// Responsive breakpoints and device size thresholds
class BreakpointConstants {
  // Private constructor to prevent instantiation
  BreakpointConstants._();

  /// Screen width breakpoints
  static const double smallScreenWidth = 350.0;
  static const double mediumScreenWidth = 500.0;
  static const double largeScreenWidth = 768.0;
  static const double extraLargeScreenWidth = 1024.0;

  /// Screen aspect ratio thresholds
  static const double narrowAspectRatio = 0.5;
  static const double standardAspectRatio = 1.0;
  static const double wideAspectRatio = 2.0;

  /// Reference dimensions for scaling calculations
  static const double referenceWidth = 300.0;
  static const double referenceHeight = 150.0;

  /// Screen size adjustment factors
  static const double smallScreenFactor = 0.9;
  static const double mediumScreenFactor = 1.0;
  static const double largeScreenFactor = 1.1;
  static const double extraLargeScreenFactor = 1.2;

  /// Aspect ratio adjustment factors
  static const double narrowScreenFactor = 0.95;
  static const double standardScreenFactor = 1.0;
  static const double wideScreenFactor = 1.05;

  /// Scale factor limits
  static const double minScaleFactor = 0.5;
  static const double maxScaleFactor = 2.0;

  /// Line count thresholds
  static const int singleLineThreshold = 1;
  static const int fewLinesThreshold = 3;
  static const int manyLinesThreshold = 5;

  /// Line count adjustment factors
  static const double singleLineFactor = 1.2;
  static const double fewLinesFactor = 1.0;
  static const double manyLinesFactor = 0.8;
}