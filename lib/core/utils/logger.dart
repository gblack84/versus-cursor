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
///
/// **Features**:
/// - Standard logging (debug, info, warning, error)
/// - In-memory log storage for debug UI (max 1000 entries)
/// - Action/navigation/button click tracking
/// - Sensitive data masking
/// - Log-once capability to prevent spam
class Logger {
  static const String _defaultTag = 'Logger';

  // In-memory log storage for debug UI
  static final List<String> _logs = [];
  static const int _maxLogs = 1000;

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

  // ========== In-Memory Log Storage (for Debug UI) ==========

  /// Log an action with optional metadata
  ///
  /// Stores the log entry in memory for debug UI display.
  /// Automatically manages circular buffer (max 1000 entries).
  ///
  /// Example:
  /// ```dart
  /// Logger.logAction('POST_CREATE', data: {'id': '123', 'type': 'question'});
  /// Logger.logAction('USER_LOGIN', data: {'email': 'user@example.com'});
  /// ```
  static void logAction(String action, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] ACTION: $action${data != null ? ' | DATA: $data' : ''}';

    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0); // Remove oldest entry
    }

    if (kDebugMode) {
      debugPrint('[Logger] $logEntry');
    }
  }

  /// Log navigation between screens
  ///
  /// Convenience method for tracking user navigation.
  ///
  /// Example:
  /// ```dart
  /// Logger.logNavigation('HomePage', 'ProfilePage');
  /// Logger.logNavigation('/home', '/profile/settings');
  /// ```
  static void logNavigation(String from, String to) {
    logAction('NAVIGATION', data: {'from': from, 'to': to});
  }

  /// Log button click events
  ///
  /// Convenience method for tracking user interactions.
  ///
  /// Example:
  /// ```dart
  /// Logger.logButtonClick('submit_button');
  /// Logger.logButtonClick('vote_option_a', extra: {'postId': '123'});
  /// ```
  static void logButtonClick(String buttonName, {Map<String, dynamic>? extra}) {
    logAction('BUTTON_CLICK', data: {'button': buttonName, ...?extra});
  }

  /// Get all stored logs as a single string
  ///
  /// Used by debug UI to display all logs.
  ///
  /// Returns:
  /// - String with all logs separated by newlines
  /// - Empty string if no logs
  static String getAllLogs() {
    return _logs.join('\n');
  }

  /// Get recent N logs
  ///
  /// Used by debug UI to display most recent logs.
  ///
  /// Parameters:
  /// - count: Number of recent logs to retrieve
  ///
  /// Returns:
  /// - String with recent logs separated by newlines
  /// - Returns all logs if count > total logs
  static String getRecentLogs(int count) {
    if (_logs.isEmpty) return '';
    final start = _logs.length > count ? _logs.length - count : 0;
    return _logs.sublist(start).join('\n');
  }

  /// Clear all stored logs
  ///
  /// Used by debug UI to reset log storage.
  static void clearLogs() {
    _logs.clear();
  }
}
