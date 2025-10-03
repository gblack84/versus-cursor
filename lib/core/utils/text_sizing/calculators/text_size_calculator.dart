import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/text_size_constants.dart';
import 'scale_factor_calculator.dart';

/// Core text size calculation logic
class TextSizeCalculator {
  /// Calculate adaptive text size based on container dimensions
  ///
  /// [containerSize] Size of the container
  /// [textType] Type of text (title, body, etc.)
  /// [maxLines] Maximum number of lines
  /// [padding] Container padding
  static double calculate({
    required Size containerSize,
    TextType textType = TextType.title,
    int maxLines = 2,
    double padding = TextSizeConstants.defaultPadding,
  }) {
    // Calculate available space
    final availableWidth = containerSize.width - (padding * 2);
    final availableHeight = containerSize.height - (padding * 2);

    // Get base size for text type
    final baseSize = getBaseSize(textType);

    // Calculate scaling factor
    final scaleFactor = ScaleFactorCalculator.calculate(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      maxLines: maxLines,
    );

    // Apply scaling to base size
    final calculatedSize = baseSize * scaleFactor;

    // Apply constraints
    return applyConstraints(calculatedSize, textType);
  }

  /// Calculate text size from container height
  ///
  /// [containerHeight] Height of the container
  /// [heightRatio] Ratio of text size to container height
  /// [textType] Type of text
  static double fromHeight({
    required double containerHeight,
    double heightRatio = TextSizeConstants.defaultHeightRatio,
    TextType textType = TextType.title,
  }) {
    final calculatedSize = containerHeight * heightRatio;
    return applyConstraints(calculatedSize, textType);
  }

  /// Calculate text size from container width
  ///
  /// [containerWidth] Width of the container
  /// [widthRatio] Ratio of text size to container width
  /// [textType] Type of text
  static double fromWidth({
    required double containerWidth,
    double widthRatio = TextSizeConstants.defaultWidthRatio,
    TextType textType = TextType.title,
  }) {
    final calculatedSize = containerWidth * widthRatio;
    return applyConstraints(calculatedSize, textType);
  }

  /// Calculate text size considering actual text content
  ///
  /// [text] The actual text content
  /// [containerSize] Size of the container
  /// [textType] Type of text
  /// [maxLines] Maximum number of lines
  /// [fontWeight] Font weight of the text
  static double forText({
    required String text,
    required Size containerSize,
    TextType textType = TextType.title,
    int maxLines = 2,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    // Start with base calculation
    double baseSize = calculate(
      containerSize: containerSize,
      textType: textType,
      maxLines: maxLines,
    );

    // Apply text length adjustment
    final lengthFactor = _getTextLengthFactor(text.length);

    // Apply font weight adjustment
    final weightFactor = _getFontWeightFactor(fontWeight);

    // Combine adjustments
    final adjustedSize = baseSize * lengthFactor * weightFactor;
    
    return applyConstraints(adjustedSize, textType);
  }

  /// Calculate optimal size for multiline text
  ///
  /// [lines] List of text lines
  /// [containerSize] Size of the container
  /// [textType] Type of text
  /// [lineSpacing] Spacing between lines
  static double forMultilineText({
    required List<String> lines,
    required Size containerSize,
    TextType textType = TextType.body,
    double lineSpacing = TextSizeConstants.defaultLineSpacing,
  }) {
    if (lines.isEmpty) return getBaseSize(textType);

    final lineCount = lines.length;
    
    // Get line count adjustment factor
    final lineFactor = ScaleFactorCalculator.calculateLineCountFactor(lineCount);

    // Calculate available height per line
    final totalLineHeight = containerSize.height /
        (lineCount + (lineCount - 1) * (lineSpacing - 1));

    // Calculate height-based size
    final heightBasedSize = fromHeight(
      containerHeight: totalLineHeight,
      textType: textType,
    );

    // Find longest line for width-based calculation
    final longestLine = lines.reduce((a, b) => a.length > b.length ? a : b);
    final lengthBasedSize = forText(
      text: longestLine,
      containerSize: containerSize,
      textType: textType,
      maxLines: lineCount,
    );

    // Use smaller size to ensure fit
    final finalSize = math.min(heightBasedSize, lengthBasedSize) * lineFactor;
    
    return applyConstraints(finalSize, textType);
  }

  /// Get base size for text type
  static double getBaseSize(TextType textType) {
    return TextSizeConstants.baseSizes[textType] ?? 
           TextSizeConstants.baseSizes[TextType.body]!;
  }

  /// Apply size constraints based on text type
  static double applyConstraints(double size, TextType textType) {
    final minSize = TextSizeConstants.minSizes[textType] ?? 10.0;
    final maxSize = TextSizeConstants.maxSizes[textType] ?? 20.0;
    return size.clamp(minSize, maxSize);
  }

  /// Get text length adjustment factor
  static double _getTextLengthFactor(int textLength) {
    if (textLength < TextSizeConstants.shortTextThreshold) {
      return TextSizeConstants.shortTextFactor;
    } else if (textLength > TextSizeConstants.longTextThreshold) {
      return TextSizeConstants.longTextFactor;
    } else if (textLength > TextSizeConstants.mediumTextThreshold) {
      return TextSizeConstants.mediumTextFactor;
    }
    return 1.0;
  }

  /// Get font weight adjustment factor
  static double _getFontWeightFactor(FontWeight fontWeight) {
    if (fontWeight.index >= FontWeight.w700.index) {
      return TextSizeConstants.boldFontFactor;
    } else if (fontWeight.index <= FontWeight.w300.index) {
      return TextSizeConstants.lightFontFactor;
    }
    return 1.0;
  }
}