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

// ==================== Moderation Logger ====================

/// Specialized logger for Moderation Services
///
/// Provides domain-specific logging methods for content moderation:
/// - Perspective API (text toxicity detection)
/// - Gemini AI (content validation)
/// - Cloud Vision API (image moderation)
/// - AI Moderation Orchestrator
///
/// **Features**:
/// - Automatic sensitive data masking (userId, API responses)
/// - Structured logging with consistent tags
/// - Performance tracking for API calls
/// - Error context preservation
///
/// **Phase 4: Logger Integration** ✅
/// - Created: 2025-11-10
/// - Replaces: 34 print() statements across 5 files
/// - Pattern: Static methods with 'Moderation' tag namespace
class ModerationLogger {
  static const String _tag = 'Moderation';

  // ========== Perspective API Logging ==========

  /// Log Perspective API text analysis start
  static void perspectiveAnalyzing(String text, {int? length}) {
    final textLength = length ?? text.length;
    Logger.debug(
      'Perspective API: Analyzing text (length: $textLength chars)',
      tag: '$_tag/Perspective',
    );
  }

  /// Log Perspective API successful result
  static void perspectiveResult({
    required bool isToxic,
    required double toxicityScore,
    String? topCategory,
  }) {
    Logger.info(
      'Perspective API: Result - Toxic: $isToxic, Score: ${toxicityScore.toStringAsFixed(2)}${topCategory != null ? ', Category: $topCategory' : ''}',
      tag: '$_tag/Perspective',
    );
  }

  /// Log Perspective API error
  static void perspectiveError(dynamic error, {int? statusCode}) {
    Logger.error(
      'Perspective API: ${statusCode != null ? 'HTTP $statusCode - ' : ''}Request failed',
      error: error,
      tag: '$_tag/Perspective',
    );
  }

  /// Log Perspective API validation result
  static void perspectiveValidation(String? message) {
    if (message != null) {
      Logger.warning(
        'Perspective API: Validation failed - $message',
        tag: '$_tag/Perspective',
      );
    }
  }

  // ========== Gemini AI Logging ==========

  /// Log Gemini Cloud Function call start
  static void geminiCalling({
    String? questionTitle,
    String? titleA,
    String? titleB,
    String? userId,
  }) {
    Logger.debug(
      'Gemini AI: Calling validatePostContentWithGemini${userId != null ? ' (user: ${Logger.maskSensitive(userId)})' : ''}',
      tag: '$_tag/Gemini',
    );
  }

  /// Log Gemini Cloud Function response received
  static void geminiResponse({
    String? action,
    double? confidence,
    Map<String, dynamic>? expectedRatio,
  }) {
    Logger.info(
      'Gemini AI: Response received - Action: ${action ?? 'legacy'}, Confidence: ${confidence?.toStringAsFixed(2) ?? 'N/A'}${expectedRatio != null ? ', ExpectedRatio: A=${expectedRatio['A']}, B=${expectedRatio['B']}' : ''}',
      tag: '$_tag/Gemini',
    );
  }

  /// Log Gemini format detection
  static void geminiFormatDetected(String format, String? action) {
    Logger.debug(
      'Gemini AI: $format format detected${action != null ? ' - action: $action' : ''}',
      tag: '$_tag/Gemini',
    );
  }

  /// Log Gemini validation result
  static void geminiValidation({
    required bool isValid,
    required String severity,
    String? reason,
  }) {
    final logMethod = severity == 'error' ? Logger.warning : Logger.info;
    logMethod(
      'Gemini AI: Validation - ${isValid ? 'PASS' : 'FAIL'} (severity: $severity)${reason != null ? ' - $reason' : ''}',
      tag: '$_tag/Gemini',
    );
  }

  /// Log Gemini error
  static void geminiError(dynamic error, {String? code, String? details}) {
    Logger.error(
      'Gemini AI: ${code != null ? 'Error $code - ' : ''}Request failed',
      error: error,
      tag: '$_tag/Gemini',
    );
    if (details != null) {
      Logger.debug('Gemini AI: Error details - $details', tag: '$_tag/Gemini');
    }
  }

  // ========== Cloud Image Moderation Logging ==========

  /// Log image moderation status check
  static void imageCheckingStatus(String filePath) {
    final maskedPath = _maskFilePath(filePath);
    Logger.debug(
      'Image Moderation: Checking status for $maskedPath',
      tag: '$_tag/Image',
    );
  }

  /// Log image moderation result
  static void imageResult({
    required String filePath,
    required String status,
    bool? isSafe,
  }) {
    final maskedPath = _maskFilePath(filePath);
    Logger.info(
      'Image Moderation: Result for $maskedPath - Status: $status${isSafe != null ? ' (safe: $isSafe)' : ''}',
      tag: '$_tag/Image',
    );
  }

  /// Log image moderation waiting
  static void imageWaiting(String filePath, {Duration? elapsed}) {
    final maskedPath = _maskFilePath(filePath);
    Logger.debug(
      'Image Moderation: Waiting for result - $maskedPath${elapsed != null ? ' (${elapsed.inSeconds}s elapsed)' : ''}',
      tag: '$_tag/Image',
    );
  }

  /// Log image moderation timeout
  static void imageTimeout(String filePath, Duration timeout) {
    final maskedPath = _maskFilePath(filePath);
    Logger.warning(
      'Image Moderation: Timeout after ${timeout.inSeconds}s - $maskedPath',
      tag: '$_tag/Image',
    );
  }

  /// Log file path extraction
  static void imagePathExtracted(String originalUrl, String extractedPath) {
    Logger.debug(
      'Image Moderation: Path extracted - ${_maskFilePath(extractedPath)}',
      tag: '$_tag/Image',
    );
  }

  /// Log file path extraction failure
  static void imagePathExtractionFailed(String url, {dynamic error}) {
    Logger.warning(
      'Image Moderation: Path extraction failed for URL',
      tag: '$_tag/Image',
    );
    if (error != null) {
      Logger.error('Image Moderation: Extraction error', error: error, tag: '$_tag/Image');
    }
  }

  /// Log image moderation error
  static void imageError(String operation, dynamic error) {
    Logger.error(
      'Image Moderation: $operation failed',
      error: error,
      tag: '$_tag/Image',
    );
  }

  // ========== AI Moderation Orchestrator Logging ==========

  /// Log moderation progress update
  static void moderationProgress(String message) {
    Logger.debug(
      'Orchestrator: $message',
      tag: '$_tag/Orchestrator',
    );
  }

  /// Log moderation stage completion
  static void moderationStageComplete(String stage, {bool passed = true}) {
    Logger.info(
      'Orchestrator: Stage "$stage" ${passed ? '✓ PASSED' : '✗ FAILED'}',
      tag: '$_tag/Orchestrator',
    );
  }

  /// Log final moderation result
  static void moderationResult({
    required bool isValid,
    required String severity,
    required List<String> violations,
  }) {
    final icon = isValid ? '✓' : '✗';
    Logger.info(
      'Orchestrator: Final result $icon ${isValid ? 'PASS' : 'FAIL'} (severity: $severity, violations: ${violations.length})',
      tag: '$_tag/Orchestrator',
    );
    if (violations.isNotEmpty) {
      Logger.debug(
        'Orchestrator: Violations - ${violations.join(', ')}',
        tag: '$_tag/Orchestrator',
      );
    }
  }

  /// Log moderation error
  static void moderationError(dynamic error, {StackTrace? stackTrace}) {
    Logger.error(
      'Orchestrator: Moderation process failed',
      error: error,
      tag: '$_tag/Orchestrator',
      stackTrace: stackTrace,
    );
  }

  /// Log Gemini API fallback (non-critical)
  static void moderationGeminiFallback(String reason) {
    Logger.warning(
      'Orchestrator: Gemini API unavailable - $reason (proceeding with basic checks)',
      tag: '$_tag/Orchestrator',
    );
  }

  // ========== Helper Methods ==========

  /// Mask file path to show only filename
  ///
  /// Example: "users/123/posts/image.jpg" → "users/.../image.jpg"
  static String _maskFilePath(String filePath) {
    final parts = filePath.split('/');
    if (parts.length <= 2) return filePath;

    return '${parts.first}/.../${parts.last}';
  }
}
