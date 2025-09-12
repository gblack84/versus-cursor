import 'dart:math' as math;
import '../constants/breakpoint_constants.dart';

/// Calculator for computing scale factors based on container dimensions
class ScaleFactorCalculator {
  /// Calculate scaling factor based on available space
  ///
  /// [availableWidth] Width available for text
  /// [availableHeight] Height available for text
  /// [maxLines] Maximum number of text lines
  static double calculate({
    required double availableWidth,
    required double availableHeight,
    required int maxLines,
  }) {
    // Calculate width and height factors based on reference dimensions
    final widthFactor = availableWidth / BreakpointConstants.referenceWidth;
    final heightFactor = availableHeight / 
        (BreakpointConstants.referenceHeight / maxLines);

    // Use the more restrictive factor to ensure text fits
    final scaleFactor = math.min(widthFactor, heightFactor);

    // Apply scale factor limits to prevent extreme scaling
    return scaleFactor.clamp(
      BreakpointConstants.minScaleFactor,
      BreakpointConstants.maxScaleFactor,
    );
  }

  /// Calculate screen-based scale factor
  ///
  /// [screenWidth] Device screen width
  /// [screenHeight] Device screen height
  static double calculateScreenFactor({
    required double screenWidth,
    required double screenHeight,
  }) {
    double factor = 1.0;

    // Adjust based on screen width breakpoints
    if (screenWidth < BreakpointConstants.smallScreenWidth) {
      factor = BreakpointConstants.smallScreenFactor;
    } else if (screenWidth > BreakpointConstants.largeScreenWidth) {
      factor = BreakpointConstants.largeScreenFactor;
    } else if (screenWidth > BreakpointConstants.mediumScreenWidth) {
      factor = BreakpointConstants.mediumScreenFactor;
    }

    // Further adjust based on aspect ratio
    final aspectRatio = screenWidth / screenHeight;
    factor *= _getAspectRatioFactor(aspectRatio);

    return factor;
  }

  /// Calculate line count adjustment factor
  ///
  /// [lineCount] Number of text lines
  static double calculateLineCountFactor(int lineCount) {
    if (lineCount <= BreakpointConstants.singleLineThreshold) {
      return BreakpointConstants.singleLineFactor;
    } else if (lineCount > BreakpointConstants.fewLinesThreshold) {
      return BreakpointConstants.manyLinesFactor;
    }
    return BreakpointConstants.fewLinesFactor;
  }

  /// Get aspect ratio adjustment factor
  static double _getAspectRatioFactor(double aspectRatio) {
    if (aspectRatio < BreakpointConstants.narrowAspectRatio) {
      return BreakpointConstants.narrowScreenFactor;
    } else if (aspectRatio > BreakpointConstants.wideAspectRatio) {
      return BreakpointConstants.wideScreenFactor;
    }
    return BreakpointConstants.standardScreenFactor;
  }
}