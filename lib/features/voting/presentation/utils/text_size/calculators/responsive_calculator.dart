import 'package:flutter/material.dart';
import '../constants/text_size_constants.dart';
import '../constants/breakpoint_constants.dart';
import 'text_size_calculator.dart';
import 'scale_factor_calculator.dart';

/// Calculator for responsive text sizing based on screen dimensions
class ResponsiveCalculator {
  /// Calculate responsive text size considering screen dimensions
  ///
  /// [context] BuildContext for accessing MediaQuery
  /// [containerSize] Size of the text container
  /// [textType] Type of text
  /// [enableResponsive] Whether to apply responsive adjustments
  static double calculate({
    required BuildContext context,
    required Size containerSize,
    TextType textType = TextType.title,
    bool enableResponsive = true,
  }) {
    // Start with base calculation
    double baseSize = TextSizeCalculator.calculate(
      containerSize: containerSize,
      textType: textType,
    );

    if (!enableResponsive) {
      return baseSize;
    }

    // Get screen dimensions
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final textScaler = mediaQuery.textScaler;
    final textScaleFactor = textScaler.scale(1.0);

    // Calculate screen-based adjustment
    final screenFactor = ScaleFactorCalculator.calculateScreenFactor(
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    );

    // Apply adjustments
    double adjustedSize = baseSize * screenFactor;
    
    // Consider system text scale factor
    if (textScaleFactor != 1.0) {
      adjustedSize = _adjustForTextScaleFactor(
        adjustedSize,
        textScaleFactor,
        textType,
      );
    }

    return TextSizeCalculator.applyConstraints(adjustedSize, textType);
  }

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < BreakpointConstants.smallScreenWidth) {
      return ScreenSize.small;
    } else if (width < BreakpointConstants.mediumScreenWidth) {
      return ScreenSize.medium;
    } else if (width < BreakpointConstants.largeScreenWidth) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// Get device orientation category
  static DeviceOrientation getDeviceOrientation(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    
    if (aspectRatio < BreakpointConstants.narrowAspectRatio) {
      return DeviceOrientation.veryPortrait;
    } else if (aspectRatio < BreakpointConstants.standardAspectRatio) {
      return DeviceOrientation.portrait;
    } else if (aspectRatio < BreakpointConstants.wideAspectRatio) {
      return DeviceOrientation.landscape;
    } else {
      return DeviceOrientation.veryLandscape;
    }
  }

  /// Calculate responsive padding based on screen size
  static double getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return TextSizeConstants.defaultPadding * 0.75;
      case ScreenSize.medium:
        return TextSizeConstants.defaultPadding;
      case ScreenSize.large:
        return TextSizeConstants.defaultPadding * 1.25;
      case ScreenSize.extraLarge:
        return TextSizeConstants.defaultPadding * 1.5;
    }
  }

  /// Calculate responsive line spacing
  static double getResponsiveLineSpacing(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return TextSizeConstants.defaultLineSpacing * 0.9;
      case ScreenSize.medium:
        return TextSizeConstants.defaultLineSpacing;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return TextSizeConstants.defaultLineSpacing * 1.1;
    }
  }

  /// Adjust size for system text scale factor
  static double _adjustForTextScaleFactor(
    double size,
    double textScaleFactor,
    TextType textType,
  ) {
    // Limit the impact of text scale factor to prevent extreme sizes
    final clampedFactor = textScaleFactor.clamp(0.8, 1.3);
    
    // Apply different scaling based on text type
    double scalingImpact;
    switch (textType) {
      case TextType.title:
      case TextType.subtitle:
        scalingImpact = 0.5; // 50% of scale factor applied
        break;
      case TextType.body:
      case TextType.label:
        scalingImpact = 0.7; // 70% of scale factor applied
        break;
      case TextType.caption:
      case TextType.button:
        scalingImpact = 0.3; // 30% of scale factor applied
        break;
    }
    
    final adjustmentFactor = 1.0 + (clampedFactor - 1.0) * scalingImpact;
    return size * adjustmentFactor;
  }
}

/// Screen size categories
enum ScreenSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Device orientation categories
enum DeviceOrientation {
  veryPortrait,
  portrait,
  landscape,
  veryLandscape,
}