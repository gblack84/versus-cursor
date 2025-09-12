import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../constants/breakpoint_constants.dart';

/// Helper utilities for device-specific calculations and adjustments
class DeviceHelpers {
  /// Check if device is a mobile device
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < BreakpointConstants.largeScreenWidth;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= BreakpointConstants.largeScreenWidth &&
           width < BreakpointConstants.extraLargeScreenWidth;
  }

  /// Check if device is a desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= BreakpointConstants.extraLargeScreenWidth;
  }

  /// Get device pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get safe area insets
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Get platform-specific adjustments
  static double getPlatformTextAdjustment() {
    try {
      if (Platform.isIOS) {
        return 1.0; // iOS baseline
      } else if (Platform.isAndroid) {
        return 0.95; // Android text tends to render slightly larger
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return 1.05; // Desktop platforms can handle slightly larger text
      }
    } catch (e) {
      // Platform may not be available (web)
      return 1.0;
    }
    return 1.0;
  }

  /// Calculate available screen space (accounting for safe areas)
  static Size getAvailableScreenSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    return Size(
      screenSize.width,
      screenSize.height - padding.top - padding.bottom - viewInsets.bottom,
    );
  }

  /// Get orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Get screen diagonal size (useful for device categorization)
  static double getScreenDiagonal(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = (size.width * size.width + size.height * size.height);
    return diagonal > 0 ? diagonal.toDouble() : 0.0;
  }
}