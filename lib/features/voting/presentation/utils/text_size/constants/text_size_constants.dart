/// Text size constants and default values for adaptive text sizing
class TextSizeConstants {
  // Private constructor to prevent instantiation
  TextSizeConstants._();

  /// Base text sizes for different text types
  static const Map<TextType, double> baseSizes = {
    TextType.title: 16.0,
    TextType.subtitle: 14.0,
    TextType.body: 12.0,
    TextType.caption: 10.0,
    TextType.label: 11.0,
    TextType.button: 13.0,
  };

  /// Minimum text sizes for different text types
  static const Map<TextType, double> minSizes = {
    TextType.title: 12.0,  // VotingDialogConstraints.minTextSize + 2
    TextType.subtitle: 11.0,  // VotingDialogConstraints.minTextSize + 1
    TextType.body: 10.0,  // VotingDialogConstraints.minTextSize
    TextType.caption: 9.0,  // VotingDialogConstraints.minTextSize - 1
    TextType.label: 10.0,  // VotingDialogConstraints.minTextSize
    TextType.button: 11.0,  // VotingDialogConstraints.minTextSize + 1
  };

  /// Maximum text sizes for different text types
  static const Map<TextType, double> maxSizes = {
    TextType.title: 24.0,  // VotingDialogConstraints.maxTextSize + 4
    TextType.subtitle: 22.0,  // VotingDialogConstraints.maxTextSize + 2
    TextType.body: 20.0,  // VotingDialogConstraints.maxTextSize
    TextType.caption: 18.0,  // VotingDialogConstraints.maxTextSize - 2
    TextType.label: 19.0,  // VotingDialogConstraints.maxTextSize - 1
    TextType.button: 21.0,  // VotingDialogConstraints.maxTextSize + 1
  };

  /// Default padding value
  static const double defaultPadding = 16.0;

  /// Default line spacing for multiline text
  static const double defaultLineSpacing = 1.2;

  /// Default height ratio for height-based calculations
  static const double defaultHeightRatio = 0.12;

  /// Default width ratio for width-based calculations
  static const double defaultWidthRatio = 0.08;

  /// Text length thresholds for size adjustments
  static const int shortTextThreshold = 10;
  static const int mediumTextThreshold = 30;
  static const int longTextThreshold = 50;

  /// Text length adjustment factors
  static const double shortTextFactor = 1.15;
  static const double mediumTextFactor = 0.85;
  static const double longTextFactor = 0.75;

  /// Font weight adjustment factors
  static const double boldFontFactor = 0.95;
  static const double lightFontFactor = 1.05;
}

/// Text type enumeration for categorizing different text usages
enum TextType {
  /// Title text (largest)
  title,
  
  /// Subtitle text
  subtitle,
  
  /// Body text (standard)
  body,
  
  /// Caption text (smallest)
  caption,
  
  /// Label text
  label,
  
  /// Button text
  button,
}