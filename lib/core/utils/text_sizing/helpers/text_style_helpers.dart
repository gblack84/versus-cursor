import 'package:flutter/material.dart';
import '../constants/text_size_constants.dart';
import '../calculators/text_size_calculator.dart';
import '../calculators/responsive_calculator.dart';

/// Helper utilities for creating and manipulating TextStyles
class TextStyleHelpers {
  /// Create a TextStyle with adaptive sizing
  static TextStyle createAdaptiveStyle({
    required Size containerSize,
    TextType textType = TextType.body,
    int maxLines = 2,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    String? fontFamily,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    final fontSize = TextSizeCalculator.calculate(
      containerSize: containerSize,
      textType: textType,
      maxLines: maxLines,
    );

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  /// Create a responsive TextStyle
  static TextStyle createResponsiveStyle({
    required BuildContext context,
    required Size containerSize,
    TextType textType = TextType.body,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    String? fontFamily,
  }) {
    final fontSize = ResponsiveCalculator.calculate(
      context: context,
      containerSize: containerSize,
      textType: textType,
    );

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
    );
  }

  /// Merge two TextStyles with priority to override style
  static TextStyle mergeStyles(TextStyle base, TextStyle? override) {
    if (override == null) return base;
    
    return base.merge(override);
  }

  /// Apply adaptive sizing to an existing TextStyle
  static TextStyle applyAdaptiveSize(
    TextStyle style,
    Size containerSize,
    TextType textType,
  ) {
    final fontSize = TextSizeCalculator.calculate(
      containerSize: containerSize,
      textType: textType,
    );

    return style.copyWith(fontSize: fontSize);
  }

  /// Get FontWeight from text type
  static FontWeight getFontWeightForType(TextType textType) {
    switch (textType) {
      case TextType.title:
        return FontWeight.bold;
      case TextType.subtitle:
        return FontWeight.w600;
      case TextType.body:
        return FontWeight.normal;
      case TextType.caption:
        return FontWeight.w300;
      case TextType.label:
        return FontWeight.w500;
      case TextType.button:
        return FontWeight.w600;
    }
  }

  /// Get line height multiplier for text type
  static double getLineHeightForType(TextType textType) {
    switch (textType) {
      case TextType.title:
        return 1.3;
      case TextType.subtitle:
        return 1.25;
      case TextType.body:
        return 1.5;
      case TextType.caption:
        return 1.4;
      case TextType.label:
        return 1.2;
      case TextType.button:
        return 1.0;
    }
  }

  /// Create a style with automatic font weight based on text type
  static TextStyle createAutoWeightStyle({
    required Size containerSize,
    required TextType textType,
    Color color = Colors.black,
    String? fontFamily,
  }) {
    return createAdaptiveStyle(
      containerSize: containerSize,
      textType: textType,
      fontWeight: getFontWeightForType(textType),
      color: color,
      fontFamily: fontFamily,
      height: getLineHeightForType(textType),
    );
  }
}