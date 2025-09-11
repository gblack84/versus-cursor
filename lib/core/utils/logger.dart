import 'package:flutter/foundation.dart';

/// Log levels for categorizing messages
enum LogLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
}

/// Core logger utility for cross-feature logging
///
/// This replaces feature-specific debug helpers to maintain
/// Clean Architecture layer independence.
class Logger {
  static const String _defaultTag = 'Logger';

  /// Mask sensitive information (shows first 3 chars + ***)
  static String maskSensitive(String? value) {
    if (value == null || value.isEmpty) return '***';
    if (value.length <= 3) return '***';
    return '${value.substring(0, 3)}***';
  }

  /// Log debug message
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] DEBUG: $message');
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] INFO: $message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] ⚠️ WARNING: $message');
    }
  }

  /// Log error message
  static void error(String message,
      {dynamic error, String? tag, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] ❌ ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log once to avoid spam (uses static cache)
  static final Set<String> _loggedOnce = {};

  static void logOnce(String key, String message,
      {String? tag, LogLevel level = LogLevel.DEBUG}) {
    if (!_loggedOnce.contains(key)) {
      _loggedOnce.add(key);
      // Use appropriate log method based on level
      switch (level) {
        case LogLevel.INFO:
          info(message, tag: tag);
          break;
        case LogLevel.WARNING:
          warning(message, tag: tag);
          break;
        case LogLevel.ERROR:
          error(message, tag: tag);
          break;
        case LogLevel.DEBUG:
          debug(message, tag: tag);
          break;
      }
    }
  }
}
