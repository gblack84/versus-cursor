// ============================================
// PLATFORM UTILITIES - Core Utils
// ============================================
//
// Split from: /lib/core/utils/app_utils.dart
// Migration date: 2025-11-11
// Reason: SRP (Single Responsibility Principle) - platform detection only
//
// Purpose: Platform detection and platform-specific operations
// ============================================

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================
// PLATFORM DETECTION
// ============================================

/// Check if running on Android (native, not web)
bool get isAndroid => !kIsWeb && Platform.isAndroid;

/// Check if running on iOS (native, not web)
bool get isiOS => !kIsWeb && Platform.isIOS;

/// Check if running on Web
bool get isWeb => kIsWeb;

/// Check if running on macOS (native, not web)
bool get isMacOS => !kIsWeb && Platform.isMacOS;

/// Check if running on Windows (native, not web)
bool get isWindows => !kIsWeb && Platform.isWindows;

/// Check if running on Linux (native, not web)
bool get isLinux => !kIsWeb && Platform.isLinux;

// ============================================
// PLATFORM STRINGS
// ============================================

/// Get platform suffix for file names or URLs
///
/// **Returns**: "web", "ios", "android", "macos", "windows", "linux", or "unknown"
///
/// **Example**:
/// ```dart
/// final suffix = getPlatformSuffix();  // "ios" on iPhone
/// final fileName = "config_$suffix.json";  // "config_ios.json"
/// ```
String getPlatformSuffix() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  return 'unknown';
}

/// Get platform display name for UI
///
/// **Returns**: "Web", "iOS", "Android", "macOS", "Windows", "Linux", or "Unknown"
///
/// **Example**:
/// ```dart
/// final name = getPlatformDisplayName();  // "iOS" on iPhone
/// Text('Running on: $name');
/// ```
String getPlatformDisplayName() {
  if (kIsWeb) return 'Web';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

// ============================================
// PLATFORM-SPECIFIC FIXES
// ============================================

/// Fix status bar brightness on iOS 16 and below
///
/// **Purpose**: Adjust status bar icons based on theme brightness
///
/// **Usage**: Call in initState() or when theme changes
///
/// **Example**:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   fixStatusBarOniOS16AndBelow(context);
/// }
/// ```
void fixStatusBarOniOS16AndBelow(BuildContext context) {
  if (!kIsWeb && Platform.isIOS) {
    // Apply fix for iOS 16 and below
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
