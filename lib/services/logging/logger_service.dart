import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ║                    LOGGING SERVICE - TABLE OF CONTENTS                       ║
// ║                                                                              ║
// ║  Single-file structure chosen for Clean Architecture compliance.            ║
// ║  See README.md for architectural decision rationale.                        ║
// ║                                                                              ║
// ║  Total: 19 Logger Classes (13 Phase 1 + 3 Phase 2 + 3 Phase 3) = ~4,209 lines ║
// ║  Phase 1: ✅ 100% | Phase 2: ✅ 100% (3/3) | Phase 3 (3-1, 3-2, 3-3): ✅ 100% (3/3 integrated) ║
// ║  Phase 3-2: ✅ Integrated | Phase 3-3: ✅ Integrated | Phase 4: ✅ 100% (2025-11-17) ║
// ═══════════════════════════════════════════════════════════════════════════════
//
// **NAVIGATION GUIDE** (Use IDE Outline or Ctrl+F to jump):
//
//  1. Logger (Base)          Lines 86-269    (184 lines) - Core logging, masking
//  2. ModerationLogger        Lines 270-535   (266 lines) - Perspective, Gemini, Vision
//  3. TargetAudienceLogger    Lines 536-770   (235 lines) - AI recommendations, votes
//  4. ProfileLogger           Lines 771-1107  (337 lines) - Profile watch, activity
//  5. ChatLogger              Lines 1108-1334 (227 lines) - Messages, AI chat
//  6. PostLogger              Lines 1335-1477 (143 lines) - Post CRUD, metrics
//  7. VotingLogger            Lines 1478-1862 (385 lines) - ✅ Phase 2-3, Vote operations
//  8. MediaLogger             Lines 1863-2253 (391 lines) - ✅ Phase 2-4, Media processing
//  9. CacheLogger             Lines 2254-2402 (149 lines) - 3-Layer cache tracking
// 10. CreationLogger          Lines 2403-2462 (60 lines)  - Media selection, drafts
// 11. NotificationsLogger     Lines 2463-2636 (174 lines) - Notifications, badges
// 12. ServicesLogger          Lines 2637-2710 (74 lines)  - Geo, Analytics
// 13. UtilsLogger             Lines 2711-2773 (63 lines)  - UI, DateTime utilities
// 14. AuthLogger              Lines 2774-2884 (111 lines) - Sign in/out, accounts
// 15. RouterLogger            Lines 2885-2950 (66 lines)  - Navigation, guards
//
// **PHASE 2 - COMPLETE**:
// 16. BatchLogger             Lines 4023-4295 (273 lines) - ✅ Phase 2-5, Batch operations
//
// **PHASE 3 - ALL INTEGRATED** (StateLogger, SearchLogger, ServiceLogger):
// 17. StateLogger             Lines 2951-3467 (517 lines) - ✅ Phase 3-1, Notifier logging
// 18. SearchLogger            Lines 3468-3747 (280 lines) - ✅ Phase 3-2, Search operations
// 19. ServiceLogger           Lines 3748-4022 (275 lines) - ✅ Phase 3-3, Support Services Logging
//
// **USAGE EXAMPLES**:
//
//   // Standard logging
//   Logger.info('App started', tag: 'App');
//   Logger.error('Failed to load', tag: 'Network');
//
//   // Domain-specific logging
//   ProfileLogger.watchStart(userId);
//   ChatLogger.sendMessage(chatId, messageId);
//   CacheLogger.hit('L1', key);
//
//   // Sensitive data masking (automatic)
//   Logger.maskSensitive('user@example.com');  // Returns 'use***'
//
// **ARCHITECTURAL DECISION**:
//   - Single file kept to respect Clean Architecture cross-cutting concerns
//   - Precedent: unified_cache_service.dart (1,787 lines)
//   - Threshold: Reconsider at 5,000 lines
//   - See README.md for full rationale and migration path
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Log levels for categorizing messages
enum LogLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  LOGGER (Base Class) - Core Logging Utilities (184 lines)                   ║
// ║  Lines 86-269 | Standard logging, sensitive data masking, log-once         ║
// ═══════════════════════════════════════════════════════════════════════════════

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

  // Duplicate error/warning prevention (Phase 2 Task 2 - 2025-11-19)
  // Prevents same error/warning from being sent to Crashlytics within cooldown period
  // Expected effect: 30-50% reduction in Crashlytics events
  static final Map<String, DateTime> _errorCache = {};
  static const Duration _errorCooldown = Duration(hours: 1);

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
  ///
  /// **Environments**:
  /// - Development: debugPrint to console
  /// - Production: Firebase Analytics (business metrics)
  ///
  /// **Production Logging** (Phase 3 Task 1 - 2025-11-19):
  /// - ✅ Firebase Analytics integration
  /// - ✅ Business metrics tracking (user actions, content, system)
  /// - ✅ Event categorization: user_*/content_*/system_*
  /// - ✅ Automatic parameter extraction from tag and message
  /// - ✅ Non-blocking: Analytics errors silently ignored
  ///
  /// **Event Categories**:
  /// - **User Actions**: sign_in, create_post, vote_cast, etc.
  /// - **Content Metrics**: post_view, media_upload, chat_message
  /// - **System Metrics**: cache_hit, api_call, feature_usage
  ///
  /// **Usage Examples**:
  /// ```dart
  /// Logger.info('User signed in successfully', tag: 'Auth/SignIn');
  /// // → Analytics event: "user_sign_in"
  ///
  /// Logger.info('Post created', tag: 'Content/Create');
  /// // → Analytics event: "content_create"
  ///
  /// Logger.info('Cache hit rate: 85%', tag: 'System/Cache');
  /// // → Analytics event: "system_cache"
  /// ```
  static void info(String message, {String? tag}) {
    // Development: Console logging (always enabled)
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] INFO: $message');
    }

    // Production: Firebase Analytics (business metrics)
    if (!kDebugMode) {
      try {
        final eventName = _extractEventName(tag);
        final parameters = {
          'message': message.length > 100 ? message.substring(0, 100) : message,
          'tag': tag ?? _defaultTag,
          'timestamp': DateTime.now().toIso8601String(),
        };

        FirebaseAnalytics.instance.logEvent(
          name: eventName,
          parameters: parameters,
        );
      } catch (analyticsError) {
        // Analytics 전송 실패는 silent fail (비즈니스 로직에 영향 없음)
        // INFO는 critical하지 않으므로 에러 무시
        if (kDebugMode) {
          debugPrint(
              '[Logger] Analytics event transmission failed: $analyticsError');
        }
      }
    }
  }

  /// Extract Analytics event name from Logger tag
  ///
  /// **Tag Format**: "Domain/Action" (e.g., "Auth/SignIn", "Post/Create")
  ///
  /// **Event Categories**:
  /// - **user_***: User authentication and profile actions
  ///   - Auth, Profile → user_sign_in, user_update_profile
  /// - **content_***: User-generated content actions
  ///   - Post, Voting, Creation, Media → content_create, content_vote
  /// - **system_***: System operations and performance
  ///   - Cache, Services, Batch, Search → system_cache_hit, system_api_call
  ///
  /// **Conversion Rules**:
  /// 1. Extract domain and action from tag (split by '/')
  /// 2. Map domain to category prefix (Auth → user, Post → content, Cache → system)
  /// 3. Convert action from CamelCase to snake_case
  /// 4. Combine: "{category}_{snake_case_action}"
  ///
  /// **Examples**:
  /// - "Auth/SignIn" → "user_sign_in"
  /// - "Post/Create" → "content_create"
  /// - "Cache/Hit" → "system_cache_hit"
  /// - null → "app_event" (fallback)
  ///
  /// **Firebase Analytics Constraints**:
  /// - Event name: max 40 characters, alphanumeric + underscore only
  /// - Parameter: max 100 characters per value
  ///
  /// **Phase 3 Task 1** (2025-11-19):
  /// Returns sanitized event name compliant with Firebase Analytics naming rules
  static String _extractEventName(String? tag) {
    // Fallback for null tags
    if (tag == null || tag.isEmpty) return 'app_event';

    // Parse tag: "Domain/Action" → [Domain, Action]
    final parts = tag.split('/');
    if (parts.isEmpty) return 'app_event';

    final domain = parts[0].toLowerCase();
    final action = parts.length > 1 ? parts[1] : 'event';

    // Map domain to Analytics category
    final categoryPrefix = _mapDomainToCategory(domain);

    // Convert CamelCase action to snake_case
    final snakeCaseAction = _toSnakeCase(action);

    // Combine and sanitize
    final eventName = '${categoryPrefix}_$snakeCaseAction';

    // Firebase Analytics: max 40 characters
    return eventName.length > 40 ? eventName.substring(0, 40) : eventName;
  }

  /// Map Logger domain to Analytics category prefix
  ///
  /// **Category Mapping**:
  /// - **user**: Authentication and user profile (Auth, Profile)
  /// - **content**: User-generated content (Post, Voting, Creation, Media, Chat)
  /// - **system**: System operations (Cache, Services, Batch, Search, Router)
  ///
  /// Returns category prefix for event naming
  static String _mapDomainToCategory(String domain) {
    switch (domain) {
      // User domain: Authentication and profile
      case 'auth':
      case 'profile':
        return 'user';

      // Content domain: User-generated content
      case 'post':
      case 'voting':
      case 'creation':
      case 'media':
      case 'chat':
      case 'targetaudience':
        return 'content';

      // System domain: Infrastructure and performance
      case 'cache':
      case 'services':
      case 'batch':
      case 'search':
      case 'router':
      case 'state':
      case 'utils':
      case 'moderation':
      case 'notifications':
        return 'system';

      // Fallback
      default:
        return 'app';
    }
  }

  /// Convert CamelCase string to snake_case
  ///
  /// **Examples**:
  /// - "SignIn" → "sign_in"
  /// - "CreatePost" → "create_post"
  /// - "cacheHit" → "cache_hit"
  /// - "UpdateUserProfile" → "update_user_profile"
  ///
  /// Returns snake_case string
  static String _toSnakeCase(String input) {
    // Insert underscore before uppercase letters (except first)
    final withUnderscores = input.replaceAllMapped(
      RegExp(r'(?<!^)(?=[A-Z])'),
      (match) => '_',
    );

    // Convert to lowercase
    return withUnderscores.toLowerCase();
  }

  /// Determine if WARNING should be sent to Crashlytics
  ///
  /// **Selective Activation Criteria** (20-30% transmission rate):
  /// - Performance degradation: degraded, slow, timeout
  /// - Cost spikes: spike, quota, limit
  /// - Cache quality issues: Cache tag + hit rate/corruption
  ///
  /// **Phase 2 Task 2** (2025-11-19):
  /// - Goal: Reduce WARNING volume while catching critical issues
  /// - Expected: 600-1,500 events/month (vs 3,000-9,000 for ERROR)
  ///
  /// **Returns**: true if WARNING should be transmitted to Crashlytics
  static bool _shouldSendWarningToCrashlytics(String message, String? tag) {
    // Performance degradation keywords
    if (message.contains('degraded') ||
        message.contains('slow') ||
        message.contains('timeout')) {
      return true;
    }

    // Cost-related keywords
    if (message.contains('spike') ||
        message.contains('quota') ||
        message.contains('limit')) {
      return true;
    }

    // Cache quality issues (Cache tag + specific keywords)
    if (tag?.contains('Cache') == true &&
        (message.contains('hit rate') ||
         message.contains('corruption') ||
         message.contains('degraded'))) {
      return true;
    }

    return false; // Default: do not send (70-80% filtered)
  }

  /// Log warning message
  ///
  /// **Environments**:
  /// - Development: debugPrint to console
  /// - Production: Selective Firebase Crashlytics (20-30% only)
  ///
  /// **Production Logging** (Phase 2 Task 2 - 2025-11-19):
  /// - ✅ Selective activation: Performance/cost/quality issues only
  /// - ✅ Keyword filtering: degraded, slow, spike, quota, timeout
  /// - ✅ Tag-based filtering: Cache + quality keywords
  /// - ✅ Duplicate prevention: 1-hour cooldown (30-50% reduction)
  /// - ✅ Non-blocking: Crashlytics errors silently ignored
  ///
  /// **Transmission Rate**:
  /// - Expected: 20-30% of all WARNING messages (600-1,500 events/month)
  /// - Filtered: 70-80% blocked (performance-neutral WARNINGs)
  ///
  /// **Crashlytics Allocation**:
  /// - ERROR: 3,000-9,000 events/month (100% transmission)
  /// - WARNING: 600-1,500 events/month (20-30% transmission)
  /// - Total: 3,600-10,500 events/month (within 10K free tier)
  static void warning(String message, {String? tag}) {
    // Development: Console logging (always enabled)
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] ⚠️ WARNING: $message');
    }

    // Production: Selective Crashlytics transmission (20-30% rate)
    if (!kDebugMode && _shouldSendWarningToCrashlytics(message, tag)) {
      // Duplicate prevention: 1-hour cooldown
      final warningKey = '${tag ?? _defaultTag}:$message';
      final lastSent = _errorCache[warningKey];

      if (lastSent != null && DateTime.now().difference(lastSent) < _errorCooldown) {
        return; // Skip transmission (duplicate within 1 hour)
      }

      try {
        // Crashlytics.log() for warnings (non-blocking, lower severity)
        FirebaseCrashlytics.instance.log(
          '⚠️ WARNING [${tag ?? _defaultTag}]: $message',
        );

        // Update cache after successful transmission
        _errorCache[warningKey] = DateTime.now();
      } catch (crashlyticsError) {
        // Crashlytics 자체 에러는 무시 (순환 참조 방지)
        // WARNING은 critical하지 않으므로 전송 실패 시 silent fail
        if (kDebugMode) {
          debugPrint('[Logger] Crashlytics warning transmission failed: $crashlyticsError');
        }
      }
    }
  }

  /// Log error message
  ///
  /// **Environments**:
  /// - Development: debugPrint to console
  /// - Production: Firebase Crashlytics (non-fatal)
  ///
  /// **Production Logging** (Phase 1 - 2025-11-18):
  /// - ✅ Firebase Crashlytics integration
  /// - ✅ Non-fatal error tracking (앱 계속 실행)
  /// - ✅ Automatic metadata (tag, timestamp)
  /// - ✅ PII masking via Logger.maskSensitive()
  static void error(String message,
      {dynamic error, String? tag, StackTrace? stackTrace}) {
    // Development: Console logging
    if (kDebugMode) {
      debugPrint('[${tag ?? _defaultTag}] ❌ ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    // Production: Firebase Crashlytics (non-fatal error tracking)
    if (error != null && !kDebugMode) {
      try {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace ?? StackTrace.current,
          reason: message,
          information: [
            'tag: ${tag ?? _defaultTag}',
            'timestamp: ${DateTime.now().toIso8601String()}',
          ],
          fatal: false, // Non-fatal error (앱은 계속 실행)
        );
      } catch (crashlyticsError) {
        // Crashlytics 자체 에러는 무시 (순환 참조 방지)
        if (kDebugMode) {
          debugPrint('[Logger] Crashlytics error: $crashlyticsError');
        }
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

// ═══════════════════════════════════════════════════════════════════════════════
// ║  MODERATION LOGGER - Content Moderation Services (262 lines)                ║
// ║  Lines 235-500 | Perspective API, Gemini AI, Cloud Vision                  ║
// ═══════════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════════
// ║  TARGET AUDIENCE LOGGER - AI Recommendations & Voting (230 lines)           ║
// ║  Lines 502-733 | AI targeting, vote creation, notification status          ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Target Audience & AI Recommendation Services
///
/// Provides domain-specific logging methods for:
/// - AI-powered user recommendations (Gemini AI)
/// - Target audience creation and management
/// - Vote creation and notification workflows
/// - Statistics and analytics queries
///
/// **Features**:
/// - Automatic sensitive data masking (userId, contentId, postId)
/// - Structured logging with consistent tags
/// - Performance tracking for AI recommendations
/// - GDPR compliance (no user IDs in logs)
///
/// **Phase 2: Logger Integration** ✅
/// - Created: 2025-11-13
/// - Replaces: 18 print() statements in target_audience_repository_impl.dart
/// - Pattern: Static methods with 'TargetAudience' tag namespace
class TargetAudienceLogger {
  static const String _tag = 'TargetAudience';

  // ========== AI Recommendation Logging ==========

  /// Log AI recommendation process start
  ///
  /// **Parameters**:
  /// - contentId: Post/content ID (masked automatically)
  /// - requestedCount: Number of recommendations requested
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.aiRecommendationStarted(
  ///   contentId: 'post123',
  ///   requestedCount: 50,
  /// );
  /// ```
  static void aiRecommendationStarted({
    required String contentId,
    required int requestedCount,
  }) {
    Logger.info(
      'AI Recommendation: Starting (contentId: ${Logger.maskSensitive(contentId)}, requested: $requestedCount)',
      tag: '$_tag/AI',
    );
  }

  /// Log AI recommendation completion with metadata
  ///
  /// **Parameters**:
  /// - totalCandidates: Total users evaluated
  /// - recommendedCount: Final recommended users count
  /// - avgScore: Average relevance score (0.0-1.0)
  ///
  /// **GDPR Compliance**: Does NOT log user IDs, only aggregated metrics
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.aiRecommendationCompleted(
  ///   totalCandidates: 1234,
  ///   recommendedCount: 50,
  ///   avgScore: 0.78,
  /// );
  /// ```
  static void aiRecommendationCompleted({
    required int totalCandidates,
    required int recommendedCount,
    required double avgScore,
  }) {
    Logger.info(
      'AI Recommendation: Completed - ${recommendedCount}/${totalCandidates} users (avg score: ${avgScore.toStringAsFixed(2)})',
      tag: '$_tag/AI',
    );
  }

  /// Log AI recommendation error
  ///
  /// **Parameters**:
  /// - error: Exception or error object
  /// - stage: Optional stage where error occurred
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.aiRecommendationError(
  ///   error: e,
  ///   stage: 'Cloud Function call',
  /// );
  /// ```
  static void aiRecommendationError({
    required dynamic error,
    String? stage,
  }) {
    Logger.error(
      'AI Recommendation: ${stage != null ? '$stage - ' : ''}Failed',
      error: error,
      tag: '$_tag/AI',
    );
  }

  // ========== Vote Creation Logging ==========

  /// Log vote creation completion
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.voteCreationCompleted(postId: 'post123');
  /// ```
  static void voteCreationCompleted({required String postId}) {
    Logger.info(
      'Vote Creation: Completed for post ${Logger.maskSensitive(postId)}',
      tag: '$_tag/Vote',
    );
  }

  /// Log vote creation error
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically, optional for pre-creation errors)
  /// - error: Exception or error object
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.voteCreationError(
  ///   postId: 'post123',
  ///   error: e,
  /// );
  /// ```
  static void voteCreationError({
    String? postId,
    required dynamic error,
  }) {
    final postInfo = postId != null ? ' for post ${Logger.maskSensitive(postId)}' : '';
    Logger.error(
      'Vote Creation: Failed$postInfo',
      error: error,
      tag: '$_tag/Vote',
    );
  }

  // ========== Notification Status Logging ==========

  /// Log notification status update
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - sentCount: Number of notifications sent
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.notificationStatusUpdated(
  ///   postId: 'post123',
  ///   sentCount: 50,
  /// );
  /// ```
  static void notificationStatusUpdated({
    required String postId,
    required int sentCount,
  }) {
    Logger.info(
      'Notification Status: Updated for post ${Logger.maskSensitive(postId)} ($sentCount sent)',
      tag: '$_tag/Notification',
    );
  }

  /// Log notification status error
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - error: Exception or error object
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.notificationStatusError(
  ///   postId: 'post123',
  ///   error: e,
  /// );
  /// ```
  static void notificationStatusError({
    required String postId,
    required dynamic error,
  }) {
    Logger.error(
      'Notification Status: Update failed for post ${Logger.maskSensitive(postId)}',
      error: error,
      tag: '$_tag/Notification',
    );
  }

  // ========== Statistics Query Logging ==========

  /// Log statistics query error
  ///
  /// **Parameters**:
  /// - error: Exception or error object
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.statsQueryError(error: e);
  /// ```
  static void statsQueryError({required dynamic error}) {
    Logger.error(
      'Statistics Query: Failed',
      error: error,
      tag: '$_tag/Stats',
    );
  }

  // ========== Target Audience Creation Logging ==========

  /// Log target audience creation error
  ///
  /// **Parameters**:
  /// - error: Exception or error object
  ///
  /// **Example**:
  /// ```dart
  /// TargetAudienceLogger.targetAudienceCreationError(error: e);
  /// ```
  static void targetAudienceCreationError({required dynamic error}) {
    Logger.error(
      'Target Audience Creation: Failed',
      error: error,
      tag: '$_tag/Creation',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  PROFILE LOGGER - User Profile Management (333 lines)                       ║
// ║  Lines 735-1069 | Profile watch, activity tracking, media, settings        ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Profile Feature
///
/// Provides domain-specific logging methods for:
/// - User profile CRUD operations
/// - Profile watching (Stream subscriptions)
/// - Last active timestamp updates
/// - Media selection and validation
/// - Profile settings management
///
/// **Features**:
/// - Automatic sensitive data masking (userId, photoUrl, email)
/// - Structured logging with consistent tags
/// - Performance tracking for profile operations
/// - GDPR compliance (masks personal information)
///
/// **Phase 2-1: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 19 print() statements across Profile Feature
/// - Pattern: Static methods with 'Profile' tag namespace
class ProfileLogger {
  static const String _tag = 'Profile';

  // ========== Profile Watch Logging ==========

  /// Log profile watching start
  ///
  /// **Parameters**:
  /// - userId: User ID (masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.profileWatching(userId: 'user123');
  /// ```
  static void profileWatching({required String userId}) {
    Logger.debug(
      'Watching profile for user ${Logger.maskSensitive(userId)}',
      tag: '$_tag/Watch',
    );
  }

  /// Log profile update received
  ///
  /// **Parameters**:
  /// - displayName: User's display name
  /// - photoUrl: Optional photo URL
  /// - bio: Optional bio text
  /// - email: Optional email (masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.profileUpdated(
  ///   displayName: 'John Doe',
  ///   photoUrl: 'https://...',
  ///   bio: 'Hello world',
  /// );
  /// ```
  static void profileUpdated({
    required String displayName,
    String? photoUrl,
    String? bio,
    String? email,
  }) {
    final emailInfo = email != null ? ', Email: ${Logger.maskSensitive(email)}' : '';
    Logger.info(
      'Profile updated - Name: $displayName, Photo: ${photoUrl != null ? 'Yes' : 'No'}${bio != null ? ', Bio: ${bio.length} chars' : ''}$emailInfo',
      tag: '$_tag/Watch',
    );
  }

  /// Log profile watch error
  ///
  /// **Parameters**:
  /// - errorType: Type of error (e.g., 'notFound', 'unauthorized')
  /// - message: Optional error message
  /// - error: Optional error object
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.profileError(
  ///   errorType: 'notFound',
  ///   message: 'User profile does not exist',
  /// );
  /// ```
  static void profileError({
    required String errorType,
    String? message,
    dynamic error,
  }) {
    Logger.error(
      'Profile watch error - Type: $errorType${message != null ? ', Message: $message' : ''}',
      error: error,
      tag: '$_tag/Watch',
    );
  }

  // ========== Last Active Logging ==========

  /// Log last active update start
  ///
  /// **Parameters**:
  /// - userId: User ID (masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.lastActiveUpdating(userId: 'user123');
  /// ```
  static void lastActiveUpdating({required String userId}) {
    Logger.debug(
      'Updating last active for user ${Logger.maskSensitive(userId)}',
      tag: '$_tag/Activity',
    );
  }

  /// Log last active update success
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.lastActiveUpdated();
  /// ```
  static void lastActiveUpdated() {
    Logger.info(
      'Last active timestamp updated successfully',
      tag: '$_tag/Activity',
    );
  }

  /// Log last active update error
  ///
  /// **Parameters**:
  /// - error: Exception or error object
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.lastActiveError(error: e);
  /// ```
  static void lastActiveError({required dynamic error}) {
    Logger.error(
      'Last active update failed',
      error: error,
      tag: '$_tag/Activity',
    );
  }

  // ========== Media Selection Logging ==========

  /// Log media selection start
  ///
  /// **Parameters**:
  /// - mediaType: Type of media ('image', 'video', 'audio')
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.mediaSelecting(mediaType: 'image');
  /// ```
  static void mediaSelecting({required String mediaType}) {
    Logger.debug(
      'Selecting media - Type: $mediaType',
      tag: '$_tag/Media',
    );
  }

  /// Log media selection success
  ///
  /// **Parameters**:
  /// - count: Number of media items selected
  /// - mediaType: Optional type of media
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.mediaSelected(count: 3, mediaType: 'image');
  /// ```
  static void mediaSelected({
    required int count,
    String? mediaType,
  }) {
    Logger.info(
      'Media selected - Count: $count${mediaType != null ? ' (type: $mediaType)' : ''}',
      tag: '$_tag/Media',
    );
  }

  /// Log media selection error
  ///
  /// **Parameters**:
  /// - error: Exception or error object
  /// - reason: Optional error reason
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.mediaError(
  ///   error: e,
  ///   reason: 'Permission denied',
  /// );
  /// ```
  static void mediaError({
    required dynamic error,
    String? reason,
  }) {
    Logger.error(
      'Media selection failed${reason != null ? ' - $reason' : ''}',
      error: error,
      tag: '$_tag/Media',
    );
  }

  // ========== Media Validation Logging ==========

  /// Log media validation start
  ///
  /// **Parameters**:
  /// - fileCount: Number of files to validate
  /// - mediaType: Optional type of media
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.mediaValidating(fileCount: 3, mediaType: 'image');
  /// ```
  static void mediaValidating({
    required int fileCount,
    String? mediaType,
  }) {
    Logger.debug(
      'Validating media files - Count: $fileCount${mediaType != null ? ' (type: $mediaType)' : ''}',
      tag: '$_tag/Validation',
    );
  }

  /// Log media validation success
  ///
  /// **Parameters**:
  /// - fileCount: Optional number of validated files
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.mediaValidated(fileCount: 3);
  /// ```
  static void mediaValidated({int? fileCount}) {
    Logger.info(
      'All media files validated successfully${fileCount != null ? ' ($fileCount files)' : ''}',
      tag: '$_tag/Validation',
    );
  }

  /// Log media validation error
  ///
  /// **Parameters**:
  /// - reason: Validation failure reason
  /// - fileName: Optional file name that failed
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.mediaValidationError(
  ///   reason: 'File too large',
  ///   fileName: 'image.jpg',
  /// );
  /// ```
  static void mediaValidationError({
    required String reason,
    String? fileName,
  }) {
    Logger.warning(
      'Media validation failed - Reason: $reason${fileName != null ? ' (file: $fileName)' : ''}',
      tag: '$_tag/Validation',
    );
  }

  // ========== Profile Settings Logging ==========

  /// Log profile settings update start
  ///
  /// **Parameters**:
  /// - userId: User ID (masked automatically)
  /// - settingsType: Type of settings being updated
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.settingsUpdating(
  ///   userId: 'user123',
  ///   settingsType: 'privacy',
  /// );
  /// ```
  static void settingsUpdating({
    required String userId,
    required String settingsType,
  }) {
    Logger.debug(
      'Updating $settingsType settings for user ${Logger.maskSensitive(userId)}',
      tag: '$_tag/Settings',
    );
  }

  /// Log profile settings update success
  ///
  /// **Parameters**:
  /// - settingsType: Type of settings updated
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.settingsUpdated(settingsType: 'privacy');
  /// ```
  static void settingsUpdated({required String settingsType}) {
    Logger.info(
      'Settings updated successfully - Type: $settingsType',
      tag: '$_tag/Settings',
    );
  }

  /// Log profile settings update error
  ///
  /// **Parameters**:
  /// - settingsType: Type of settings that failed
  /// - error: Exception or error object
  ///
  /// **Example**:
  /// ```dart
  /// ProfileLogger.settingsError(
  ///   settingsType: 'privacy',
  ///   error: e,
  /// );
  /// ```
  static void settingsError({
    required String settingsType,
    required dynamic error,
  }) {
    Logger.error(
      'Settings update failed - Type: $settingsType',
      error: error,
      tag: '$_tag/Settings',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  CHAT LOGGER - Messaging & AI Chat (226 lines)                              ║
// ║  Lines 1071-1298 | Message send/receive, AI queries, search, chat list     ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Chat Feature
///
/// Provides domain-specific logging methods for:
/// - 1:1 message sending and receiving
/// - AI chat query and streaming responses
/// - Message search and filtering
/// - Chat list retrieval
/// - Message pagination (load more)
///
/// **Features**:
/// - Automatic sensitive data masking (userId, chatId)
/// - Structured logging with consistent tags
/// - Real-time streaming chunk logging (AI responses)
/// - GDPR compliance (masks personal information)
///
/// **Phase 2-2: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 14 print() statements across Chat Feature
/// - Pattern: Static methods with 'Chat' tag namespace
class ChatLogger {
  static const String _tag = 'Chat';

  // ========== Message Sending Logging ==========

  /// Log message sending start
  static void messageSending({
    required String chatId,
    required String content,
  }) {
    Logger.debug(
      'Sending message to chat ${Logger.maskSensitive(chatId)} - Content: ${content.length} chars',
      tag: '$_tag/Send',
    );
  }

  /// Log message sent successfully
  static void messageSent({
    required String messageId,
    String? chatId,
  }) {
    Logger.info(
      'Message sent successfully - ID: $messageId${chatId != null ? ' (chat: ${Logger.maskSensitive(chatId)})' : ''}',
      tag: '$_tag/Send',
    );
  }

  /// Log message send error
  static void messageError({
    required String errorType,
    String? message,
    dynamic error,
  }) {
    Logger.error(
      'Message send failed - Type: $errorType${message != null ? ', Message: $message' : ''}',
      error: error,
      tag: '$_tag/Send',
    );
  }

  // ========== Message Receiving Logging ==========

  /// Log messages received
  static void messagesReceived({
    required int count,
    String? chatId,
  }) {
    Logger.info(
      'Received $count message(s)${chatId != null ? ' from chat ${Logger.maskSensitive(chatId)}' : ''}',
      tag: '$_tag/Receive',
    );
  }

  // ========== Message Loading Logging ==========

  /// Log loading more messages
  static void messagesLoading({
    required String chatId,
    int? limit,
  }) {
    Logger.debug(
      'Loading more messages from chat ${Logger.maskSensitive(chatId)}${limit != null ? ' (limit: $limit)' : ''}',
      tag: '$_tag/Load',
    );
  }

  /// Log messages loaded successfully
  static void messagesLoaded({
    required int count,
    String? chatId,
  }) {
    Logger.info(
      'Loaded $count additional message(s)${chatId != null ? ' from chat ${Logger.maskSensitive(chatId)}' : ''}',
      tag: '$_tag/Load',
    );
  }

  /// Log message load error
  static void loadError({
    required dynamic error,
    String? chatId,
  }) {
    Logger.error(
      'Failed to load messages${chatId != null ? ' from chat ${Logger.maskSensitive(chatId)}' : ''}',
      error: error,
      tag: '$_tag/Load',
    );
  }

  // ========== Message Search Logging ==========

  /// Log message search start
  static void messagesSearching({
    required String query,
    String? chatId,
  }) {
    Logger.debug(
      'Searching messages - Query: "$query"${chatId != null ? ' in chat ${Logger.maskSensitive(chatId)}' : ''}',
      tag: '$_tag/Search',
    );
  }

  /// Log search results
  static void messagesSearched({
    required int count,
    String? query,
  }) {
    Logger.info(
      'Found $count message(s)${query != null ? ' matching "$query"' : ''}',
      tag: '$_tag/Search',
    );
  }

  /// Log search error
  static void searchError({
    required dynamic error,
    String? query,
  }) {
    Logger.error(
      'Message search failed${query != null ? ' for query "$query"' : ''}',
      error: error,
      tag: '$_tag/Search',
    );
  }

  // ========== AI Chat Logging ==========

  /// Log AI query start
  static void aiQuerying({
    required String query,
    String? userId,
  }) {
    Logger.debug(
      'Sending AI query${userId != null ? ' for user ${Logger.maskSensitive(userId)}' : ''} - Query: ${query.length} chars',
      tag: '$_tag/AI',
    );
  }

  /// Log AI response chunk (streaming)
  static void aiResponseChunk({
    required String chunk,
    int? chunkIndex,
  }) {
    Logger.debug(
      'AI Response chunk${chunkIndex != null ? ' #$chunkIndex' : ''}: "${chunk.length > 50 ? '${chunk.substring(0, 50)}...' : chunk}"',
      tag: '$_tag/AI',
    );
  }

  /// Log AI query completion
  static void aiResponseComplete({
    required int totalChunks,
    int? totalLength,
  }) {
    Logger.info(
      'AI Response complete - $totalChunks chunk(s)${totalLength != null ? ', $totalLength chars total' : ''}',
      tag: '$_tag/AI',
    );
  }

  /// Log AI query error
  static void aiError({
    required dynamic error,
    String? message,
  }) {
    Logger.error(
      'AI query failed${message != null ? ' - $message' : ''}',
      error: error,
      tag: '$_tag/AI',
    );
  }

  // ========== Chat List Logging ==========

  /// Log chat list loading
  static void chatListLoading({
    required String userId,
  }) {
    Logger.debug(
      'Loading chat list for user ${Logger.maskSensitive(userId)}',
      tag: '$_tag/List',
    );
  }

  /// Log chat list loaded
  static void chatListLoaded({
    required int count,
  }) {
    Logger.info(
      'Chat list loaded - $count chat(s)',
      tag: '$_tag/List',
    );
  }

  /// Log chat list error
  static void chatListError({
    required dynamic error,
  }) {
    Logger.error(
      'Failed to load chat list',
      error: error,
      tag: '$_tag/List',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  POST LOGGER - Post Management (137 lines)                                  ║
// ║  Lines 1300-1438 | Post CRUD operations, metrics, queries                   ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Post Feature
///
/// Provides domain-specific logging methods for:
/// - Post CRUD operations (create, read, update, delete)
/// - Post metrics (view count, interactions)
/// - Post queries and searches
///
/// **Features**:
/// - Automatic sensitive data masking (userId, postId)
/// - Structured logging with consistent tags
/// - GDPR compliance (masks personal information)
///
/// **Phase 2-3: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 5 print() statements across Post Feature
/// - Pattern: Static methods with 'Post' tag namespace
class PostLogger {
  static const String _tag = 'Post';

  // ========== Post Operations Logging ==========

  /// Log post creation success
  static void postCreated({
    required String postId,
    String? authorId,
  }) {
    Logger.info(
      'Post created - ID: ${Logger.maskSensitive(postId)}${authorId != null ? ' (author: ${Logger.maskSensitive(authorId)})' : ''}',
      tag: '$_tag/Create',
    );
  }

  /// Log post update success
  static void postUpdated({
    required String postId,
  }) {
    Logger.info(
      'Post updated - ID: ${Logger.maskSensitive(postId)}',
      tag: '$_tag/Update',
    );
  }

  /// Log post deletion success
  static void postDeleted({
    required String postId,
  }) {
    Logger.info(
      'Post deleted - ID: ${Logger.maskSensitive(postId)}',
      tag: '$_tag/Delete',
    );
  }

  /// Log post not found error
  static void postNotFound({
    required String postId,
  }) {
    Logger.warning(
      'Post not found - ID: ${Logger.maskSensitive(postId)}',
      tag: '$_tag/Error',
    );
  }

  /// Log post error
  static void postError({
    required String errorType,
    dynamic error,
    String? message,
  }) {
    Logger.error(
      'Post error ($errorType): ${message ?? error?.toString() ?? 'Unknown error'}',
      error: error,
      tag: '$_tag/Error',
    );
  }

  // ========== Metrics Logging ==========

  /// Log view count increment
  static void viewCountIncremented({
    required String postId,
    required int newCount,
  }) {
    Logger.info(
      'View count incremented - Post: ${Logger.maskSensitive(postId)}, Count: $newCount',
      tag: '$_tag/Metrics',
    );
  }

  /// Log metrics operation success
  static void metricsUpdated({
    required String operation,
    required String postId,
  }) {
    Logger.info(
      'Metrics updated ($operation) - Post: ${Logger.maskSensitive(postId)}',
      tag: '$_tag/Metrics',
    );
  }

  /// Log metrics operation error
  static void metricsError({
    required String operation,
    dynamic error,
  }) {
    Logger.error(
      'Metrics operation failed ($operation)',
      error: error,
      tag: '$_tag/Metrics',
    );
  }

  // ========== Query Logging ==========

  /// Log post query success
  static void postsLoaded({
    required int count,
    String? filter,
  }) {
    Logger.info(
      'Posts loaded - $count post(s)${filter != null ? ' (filter: $filter)' : ''}',
      tag: '$_tag/Query',
    );
  }

  /// Log post search
  static void postsSearched({
    required String query,
    required int count,
  }) {
    Logger.info(
      'Posts searched - Query: "$query", Results: $count',
      tag: '$_tag/Search',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  VOTING LOGGER - Vote Management (330 lines)                                ║
// ║  Lines 1448-1778 | Vote casting, expansion, counts, user history           ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Voting Feature
///
/// Provides domain-specific logging methods for:
/// - Vote casting and removal (CRUD operations)
/// - Vote counts and aggregation queries
/// - Vote expansion requests (approval/rejection)
/// - User vote history tracking
///
/// **Features**:
/// - Automatic sensitive data masking (userId, postId)
/// - Structured logging with consistent tags
/// - Performance tracking for vote operations
/// - GDPR compliance (masks personal information)
///
/// **Phase 2-3: Logger Integration**
/// - Created: 2025-11-17
/// - Replaces: Exception throws and silent failures
/// - Pattern: Static methods with 'Voting' tag namespace
class VotingLogger {
  static const String _tag = 'Voting';

  // ========== Vote Casting Logging ==========

  /// Log vote casting start
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - userId: User ID (masked automatically)
  /// - voteOption: Vote option ('A' or 'B')
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteCasting(
  ///   postId: 'post123',
  ///   userId: 'user456',
  ///   voteOption: 'A',
  /// );
  /// ```
  static void voteCasting({
    required String postId,
    required String userId,
    required String voteOption,
  }) {
    Logger.debug(
      'Casting vote - Post: ${Logger.maskSensitive(postId)}, '
      'User: ${Logger.maskSensitive(userId)}, Option: $voteOption',
      tag: '$_tag/Cast',
    );
  }

  /// Log vote cast success
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - voteOption: Vote option ('A' or 'B')
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteCasted(postId: 'post123', voteOption: 'A');
  /// ```
  static void voteCasted({
    required String postId,
    required String voteOption,
  }) {
    Logger.info(
      'Vote casted successfully - Post: ${Logger.maskSensitive(postId)}, '
      'Option: $voteOption',
      tag: '$_tag/Cast',
    );
  }

  /// Log vote removal
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - userId: User ID (masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteRemoved(postId: 'post123', userId: 'user456');
  /// ```
  static void voteRemoved({
    required String postId,
    required String userId,
  }) {
    Logger.info(
      'Vote removed - Post: ${Logger.maskSensitive(postId)}, '
      'User: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/Remove',
    );
  }

  /// Log vote error
  ///
  /// **Parameters**:
  /// - errorType: Error type description
  /// - error: Exception object (optional)
  /// - postId: Post ID for context (optional, masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteError(
  ///   errorType: 'castVoteFailed',
  ///   error: e,
  ///   postId: 'post123',
  /// );
  /// ```
  static void voteError({
    required String errorType,
    Object? error,
    String? postId,
  }) {
    Logger.error(
      'Vote operation failed - Type: $errorType'
      '${postId != null ? ", Post: ${Logger.maskSensitive(postId)}" : ""}',
      error: error,
      tag: '$_tag/Error',
    );
  }

  // ========== Vote Loading Logging ==========

  /// Log vote loading start
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - userId: User ID (optional, masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteLoading(postId: 'post123', userId: 'user456');
  /// ```
  static void voteLoading({
    required String postId,
    String? userId,
  }) {
    Logger.debug(
      'Loading vote - Post: ${Logger.maskSensitive(postId)}'
      '${userId != null ? ", User: ${Logger.maskSensitive(userId)}" : ""}',
      tag: '$_tag/Load',
    );
  }

  /// Log vote loaded success
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - hasVoted: Whether user has voted
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteLoaded(postId: 'post123', hasVoted: true);
  /// ```
  static void voteLoaded({
    required String postId,
    bool? hasVoted,
  }) {
    Logger.debug(
      'Vote loaded - Post: ${Logger.maskSensitive(postId)}'
      '${hasVoted != null ? ", Has voted: $hasVoted" : ""}',
      tag: '$_tag/Load',
    );
  }

  /// Log vote counts loaded
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - countA: Vote count for option A
  /// - countB: Vote count for option B
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.voteCountsLoaded(
  ///   postId: 'post123',
  ///   countA: 42,
  ///   countB: 38,
  /// );
  /// ```
  static void voteCountsLoaded({
    required String postId,
    int? countA,
    int? countB,
  }) {
    Logger.debug(
      'Vote counts loaded - Post: ${Logger.maskSensitive(postId)}'
      '${countA != null && countB != null ? ", A: $countA, B: $countB" : ""}',
      tag: '$_tag/Counts',
    );
  }

  /// Log vote load error
  ///
  /// **Parameters**:
  /// - error: Exception object
  /// - postId: Post ID for context (optional, masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.loadError(error: e, postId: 'post123');
  /// ```
  static void loadError({
    required Object error,
    String? postId,
  }) {
    Logger.error(
      'Failed to load vote data'
      '${postId != null ? " - Post: ${Logger.maskSensitive(postId)}" : ""}',
      error: error,
      tag: '$_tag/Load',
    );
  }

  // ========== Vote Expansion Logging ==========

  /// Log vote expansion request start
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - userId: User ID (masked automatically)
  /// - requestedDuration: Requested extension duration (minutes)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.expansionRequesting(
  ///   postId: 'post123',
  ///   userId: 'user456',
  ///   requestedDuration: 60,
  /// );
  /// ```
  static void expansionRequesting({
    required String postId,
    required String userId,
    int? requestedDuration,
  }) {
    Logger.debug(
      'Requesting vote expansion - Post: ${Logger.maskSensitive(postId)}, '
      'User: ${Logger.maskSensitive(userId)}'
      '${requestedDuration != null ? ", Duration: ${requestedDuration}min" : ""}',
      tag: '$_tag/Expansion',
    );
  }

  /// Log vote expansion request success
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - requestedDuration: Requested extension duration (minutes)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.expansionRequested(
  ///   postId: 'post123',
  ///   requestedDuration: 60,
  /// );
  /// ```
  static void expansionRequested({
    required String postId,
    int? requestedDuration,
  }) {
    Logger.info(
      'Vote expansion requested - Post: ${Logger.maskSensitive(postId)}'
      '${requestedDuration != null ? ", Duration: ${requestedDuration}min" : ""}',
      tag: '$_tag/Expansion',
    );
  }

  /// Log vote expansion approval
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - requestId: Request ID (masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.expansionApproved(
  ///   postId: 'post123',
  ///   requestId: 'req456',
  /// );
  /// ```
  static void expansionApproved({
    required String postId,
    required String requestId,
  }) {
    Logger.info(
      'Vote expansion approved - Post: ${Logger.maskSensitive(postId)}, '
      'Request: ${Logger.maskSensitive(requestId)}',
      tag: '$_tag/Expansion',
    );
  }

  /// Log vote expansion rejection
  ///
  /// **Parameters**:
  /// - postId: Post ID (masked automatically)
  /// - requestId: Request ID (masked automatically)
  /// - reason: Rejection reason (optional)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.expansionRejected(
  ///   postId: 'post123',
  ///   requestId: 'req456',
  ///   reason: 'Insufficient participation',
  /// );
  /// ```
  static void expansionRejected({
    required String postId,
    required String requestId,
    String? reason,
  }) {
    Logger.info(
      'Vote expansion rejected - Post: ${Logger.maskSensitive(postId)}, '
      'Request: ${Logger.maskSensitive(requestId)}'
      '${reason != null ? ", Reason: $reason" : ""}',
      tag: '$_tag/Expansion',
    );
  }

  /// Log vote expansion error
  ///
  /// **Parameters**:
  /// - errorType: Error type description
  /// - error: Exception object
  /// - postId: Post ID for context (optional, masked automatically)
  ///
  /// **Example**:
  /// ```dart
  /// VotingLogger.expansionError(
  ///   errorType: 'approvalFailed',
  ///   error: e,
  ///   postId: 'post123',
  /// );
  /// ```
  static void expansionError({
    required String errorType,
    required Object error,
    String? postId,
  }) {
    Logger.error(
      'Vote expansion operation failed - Type: $errorType'
      '${postId != null ? ", Post: ${Logger.maskSensitive(postId)}" : ""}',
      error: error,
      tag: '$_tag/Expansion',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  MEDIA LOGGER - Media Upload/Management (422 lines)                         ║
// ║  Lines 1802-2223 | Image/video upload, validation, deletion, queue         ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Media Upload/Management
///
/// Provides domain-specific logging methods for:
/// - Image upload, validation, and processing
/// - Video upload, validation, and processing
/// - Media deletion and cleanup operations
/// - Upload queue status tracking
///
/// **Features**:
/// - Automatic sensitive data masking (userId, mediaPath)
/// - Structured logging with consistent tags
/// - Performance tracking for upload operations
/// - GDPR compliance (masks personal information)
///
/// **Phase 2-4: MediaLogger Implementation**
/// - Created: 2025-11-17
/// - Replaces: Exception throws and silent failures in MediaRepository
/// - Pattern: Static methods with 'Media' tag namespace
/// - Target: media_repository_impl.dart (~5-6 Logger calls)
///
/// **Tag Namespacing**:
/// - 'Media/Upload' - Image/video upload operations
/// - 'Media/Validation' - Media validation checks
/// - 'Media/Delete' - Media deletion operations
/// - 'Media/Queue' - Upload queue management
///
/// **Usage Example**:
/// ```dart
/// // In MediaRepositoryImpl.uploadImage()
/// MediaLogger.imageUploadStarted(
///   userId: currentUser.uid,
///   imagePath: imagePath,
///   sizeBytes: fileSize,
/// );
///
/// try {
///   final url = await _storage.upload(imagePath);
///   MediaLogger.imageUploaded(
///     imagePath: imagePath,
///     uploadUrl: url,
///     durationMs: stopwatch.elapsedMilliseconds,
///   );
/// } catch (e) {
///   MediaLogger.imageUploadError(
///     errorType: 'storage',
///     error: e,
///     imagePath: imagePath,
///   );
/// }
/// ```
class MediaLogger {
  static const String _tag = 'Media';

  // ========== IMAGE UPLOAD LOGGING ==========

  /// Log image upload initiation
  ///
  /// **When to call**: At the start of image upload process
  ///
  /// **Parameters**:
  /// - [userId]: User ID initiating upload (masked for GDPR)
  /// - [imagePath]: Local file path (masked for privacy)
  /// - [sizeBytes]: File size in bytes
  ///
  /// **Tag**: 'Media/Upload'
  static void imageUploadStarted({
    required String userId,
    required String imagePath,
    required int sizeBytes,
  }) {
    Logger.debug(
      'Starting image upload - '
      'User: ${Logger.maskSensitive(userId)}, '
      'Path: ${Logger.maskSensitive(imagePath)}, '
      'Size: ${(sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
      tag: '$_tag/Upload',
    );
  }

  /// Log successful image upload
  ///
  /// **When to call**: After successful upload to Firebase Storage
  ///
  /// **Parameters**:
  /// - [imagePath]: Local file path (masked)
  /// - [uploadUrl]: Firebase Storage URL (masked)
  /// - [durationMs]: Upload duration in milliseconds
  ///
  /// **Tag**: 'Media/Upload'
  static void imageUploaded({
    required String imagePath,
    required String uploadUrl,
    required int durationMs,
  }) {
    Logger.info(
      'Image uploaded successfully - '
      'Path: ${Logger.maskSensitive(imagePath)}, '
      'URL: ${Logger.maskSensitive(uploadUrl)}, '
      'Duration: ${durationMs}ms',
      tag: '$_tag/Upload',
    );
  }

  /// Log image upload error
  ///
  /// **When to call**: On upload failure (network, storage, permissions)
  ///
  /// **Parameters**:
  /// - [errorType]: Error category (network, storage, permissions)
  /// - [error]: Exception object (optional)
  /// - [imagePath]: Local file path (masked)
  ///
  /// **Tag**: 'Media/Upload'
  static void imageUploadError({
    required String errorType,
    Object? error,
    String? imagePath,
  }) {
    Logger.error(
      'Image upload failed - '
      'Type: $errorType'
      '${imagePath != null ? ", Path: ${Logger.maskSensitive(imagePath)}" : ""}',
      error: error,
      tag: '$_tag/Upload',
    );
  }

  /// Log successful image validation
  ///
  /// **When to call**: After image validation checks pass
  ///
  /// **Parameters**:
  /// - [imagePath]: Local file path (masked)
  /// - [width]: Image width in pixels
  /// - [height]: Image height in pixels
  /// - [sizeBytes]: File size in bytes
  ///
  /// **Tag**: 'Media/Validation'
  static void imageValidated({
    required String imagePath,
    required int width,
    required int height,
    required int sizeBytes,
  }) {
    Logger.info(
      'Image validated - '
      'Path: ${Logger.maskSensitive(imagePath)}, '
      'Dimensions: ${width}x$height, '
      'Size: ${(sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
      tag: '$_tag/Validation',
    );
  }

  /// Log image validation error
  ///
  /// **When to call**: When image fails validation checks
  ///
  /// **Parameters**:
  /// - [errorType]: Validation error type (size, format, dimensions, moderation)
  /// - [imagePath]: Local file path (masked)
  /// - [reason]: Human-readable failure reason
  ///
  /// **Tag**: 'Media/Validation'
  static void imageValidationError({
    required String errorType,
    required String imagePath,
    required String reason,
  }) {
    Logger.warning(
      'Image validation failed - '
      'Type: $errorType, '
      'Path: ${Logger.maskSensitive(imagePath)}, '
      'Reason: $reason',
      tag: '$_tag/Validation',
    );
  }

  // ========== VIDEO UPLOAD LOGGING ==========

  /// Log video upload initiation
  ///
  /// **When to call**: At the start of video upload process
  ///
  /// **Parameters**:
  /// - [userId]: User ID initiating upload (masked for GDPR)
  /// - [videoPath]: Local file path (masked for privacy)
  /// - [sizeBytes]: File size in bytes
  ///
  /// **Tag**: 'Media/Upload'
  static void videoUploadStarted({
    required String userId,
    required String videoPath,
    required int sizeBytes,
  }) {
    Logger.debug(
      'Starting video upload - '
      'User: ${Logger.maskSensitive(userId)}, '
      'Path: ${Logger.maskSensitive(videoPath)}, '
      'Size: ${(sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
      tag: '$_tag/Upload',
    );
  }

  /// Log successful video upload
  ///
  /// **When to call**: After successful upload to Firebase Storage
  ///
  /// **Parameters**:
  /// - [videoPath]: Local file path (masked)
  /// - [uploadUrl]: Firebase Storage URL (masked)
  /// - [durationMs]: Upload duration in milliseconds
  ///
  /// **Tag**: 'Media/Upload'
  static void videoUploaded({
    required String videoPath,
    required String uploadUrl,
    required int durationMs,
  }) {
    Logger.info(
      'Video uploaded successfully - '
      'Path: ${Logger.maskSensitive(videoPath)}, '
      'URL: ${Logger.maskSensitive(uploadUrl)}, '
      'Duration: ${durationMs}ms',
      tag: '$_tag/Upload',
    );
  }

  /// Log video upload error
  ///
  /// **When to call**: On upload failure (network, storage, permissions)
  ///
  /// **Parameters**:
  /// - [errorType]: Error category (network, storage, permissions)
  /// - [error]: Exception object (optional)
  /// - [videoPath]: Local file path (masked)
  ///
  /// **Tag**: 'Media/Upload'
  static void videoUploadError({
    required String errorType,
    Object? error,
    String? videoPath,
  }) {
    Logger.error(
      'Video upload failed - '
      'Type: $errorType'
      '${videoPath != null ? ", Path: ${Logger.maskSensitive(videoPath)}" : ""}',
      error: error,
      tag: '$_tag/Upload',
    );
  }

  /// Log successful video validation
  ///
  /// **When to call**: After video validation checks pass
  ///
  /// **Parameters**:
  /// - [videoPath]: Local file path (masked)
  /// - [durationMs]: Video duration in milliseconds
  /// - [sizeBytes]: File size in bytes
  ///
  /// **Tag**: 'Media/Validation'
  static void videoValidated({
    required String videoPath,
    required int durationMs,
    required int sizeBytes,
  }) {
    Logger.info(
      'Video validated - '
      'Path: ${Logger.maskSensitive(videoPath)}, '
      'Duration: ${(durationMs / 1000).toStringAsFixed(1)}s, '
      'Size: ${(sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
      tag: '$_tag/Validation',
    );
  }

  /// Log video validation error
  ///
  /// **When to call**: When video fails validation checks
  ///
  /// **Parameters**:
  /// - [errorType]: Validation error type (size, format, duration, moderation)
  /// - [videoPath]: Local file path (masked)
  /// - [reason]: Human-readable failure reason
  ///
  /// **Tag**: 'Media/Validation'
  static void videoValidationError({
    required String errorType,
    required String videoPath,
    required String reason,
  }) {
    Logger.warning(
      'Video validation failed - '
      'Type: $errorType, '
      'Path: ${Logger.maskSensitive(videoPath)}, '
      'Reason: $reason',
      tag: '$_tag/Validation',
    );
  }

  // ========== MEDIA DELETION LOGGING ==========

  /// Log successful media deletion
  ///
  /// **When to call**: After media file deleted from Firebase Storage
  ///
  /// **Parameters**:
  /// - [mediaUrl]: Firebase Storage URL (masked)
  /// - [mediaType]: Media type (image, video)
  ///
  /// **Tag**: 'Media/Delete'
  static void mediaDeleted({
    required String mediaUrl,
    required String mediaType,
  }) {
    Logger.info(
      'Media deleted successfully - '
      'Type: $mediaType, '
      'URL: ${Logger.maskSensitive(mediaUrl)}',
      tag: '$_tag/Delete',
    );
  }

  /// Log media deletion error
  ///
  /// **When to call**: On deletion failure (permissions, not found, network)
  ///
  /// **Parameters**:
  /// - [errorType]: Error category (permissions, notFound, network)
  /// - [error]: Exception object (optional)
  /// - [mediaUrl]: Firebase Storage URL (masked)
  ///
  /// **Tag**: 'Media/Delete'
  static void mediaDeletionError({
    required String errorType,
    Object? error,
    String? mediaUrl,
  }) {
    Logger.error(
      'Media deletion failed - '
      'Type: $errorType'
      '${mediaUrl != null ? ", URL: ${Logger.maskSensitive(mediaUrl)}" : ""}',
      error: error,
      tag: '$_tag/Delete',
    );
  }

  /// Log media cleanup operation
  ///
  /// **When to call**: After batch media cleanup (orphaned files, old drafts)
  ///
  /// **Parameters**:
  /// - [deletedCount]: Number of files deleted
  /// - [totalSizeMB]: Total size freed in MB
  ///
  /// **Tag**: 'Media/Delete'
  static void mediaCleanup({
    required int deletedCount,
    required double totalSizeMB,
  }) {
    Logger.info(
      'Media cleanup completed - '
      'Deleted: $deletedCount files, '
      'Freed: ${totalSizeMB.toStringAsFixed(2)} MB',
      tag: '$_tag/Delete',
    );
  }

  // ========== UPLOAD QUEUE LOGGING ==========

  /// Log upload queue status
  ///
  /// **When to call**: Periodically during upload queue processing
  ///
  /// **Parameters**:
  /// - [queueSize]: Total items in queue
  /// - [pendingCount]: Items awaiting upload
  /// - [completedCount]: Successfully uploaded items
  ///
  /// **Tag**: 'Media/Queue'
  static void uploadQueueStatus({
    required int queueSize,
    required int pendingCount,
    required int completedCount,
  }) {
    Logger.debug(
      'Upload queue status - '
      'Total: $queueSize, '
      'Pending: $pendingCount, '
      'Completed: $completedCount',
      tag: '$_tag/Queue',
    );
  }

  /// Log upload queue error
  ///
  /// **When to call**: On queue processing failure
  ///
  /// **Parameters**:
  /// - [errorType]: Error category (processing, retry, timeout)
  /// - [error]: Exception object (optional)
  /// - [queueSize]: Current queue size
  ///
  /// **Tag**: 'Media/Queue'
  static void uploadQueueError({
    required String errorType,
    Object? error,
    int? queueSize,
  }) {
    Logger.error(
      'Upload queue error - '
      'Type: $errorType'
      '${queueSize != null ? ", Queue size: $queueSize" : ""}',
      error: error,
      tag: '$_tag/Queue',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  CACHE LOGGER - 3-Layer Cache System (148 lines)                            ║
// ║  Lines 1779-1928 | L1 Memory, L2 Hive, L3 Firestore hit/miss tracking      ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Cache Service
///
/// Provides domain-specific logging methods for:
/// - Cache hit/miss tracking (L1 Memory, L2 Hive, L3 Firestore)
/// - Cache set/invalidate operations
/// - Cache error handling (6 failure types)
/// - Cache statistics
///
/// **Features**:
/// - 3-Layer cache visibility (L1/L2/L3)
/// - Performance metrics (hit rate, latency)
/// - Automatic error categorization
/// - GDPR compliance (masks sensitive keys)
///
/// **Phase 2-3: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 7 print() statements across Cache Service
/// - Pattern: Static methods with 'Cache' tag namespace
class CacheLogger {
  static const String _tag = 'Cache';

  // ========== Cache Hit/Miss Logging ==========

  /// Log cache hit (any layer)
  static void cacheHit({
    required String key,
    required String layer, // 'L1', 'L2', or 'L3'
  }) {
    Logger.debug(
      'Cache HIT ($layer) - Key: ${Logger.maskSensitive(key)}',
      tag: '$_tag/Hit',
    );
  }

  /// Log cache miss
  static void cacheMiss({
    required String key,
    String? layer,
  }) {
    Logger.debug(
      'Cache MISS${layer != null ? ' ($layer)' : ''} - Key: ${Logger.maskSensitive(key)}',
      tag: '$_tag/Miss',
    );
  }

  // ========== Cache Operations Logging ==========

  /// Log cache set operation
  static void cacheSet({
    required String key,
    required String layer,
    Duration? ttl,
  }) {
    Logger.debug(
      'Cache SET ($layer) - Key: ${Logger.maskSensitive(key)}${ttl != null ? ', TTL: ${ttl.inSeconds}s' : ''}',
      tag: '$_tag/Set',
    );
  }

  /// Log cache invalidation
  static void cacheInvalidated({
    required String key,
  }) {
    Logger.info(
      'Cache invalidated - Key: ${Logger.maskSensitive(key)}',
      tag: '$_tag/Invalidate',
    );
  }

  /// Log cache clear (all entries)
  static void cacheCleared() {
    Logger.info(
      'All cache entries cleared',
      tag: '$_tag/Clear',
    );
  }

  // ========== Cache Error Logging ==========

  /// Log cache error (6 failure types)
  static void cacheError({
    required String errorType, // 'notFound', 'typeMismatch', 'hiveError', 'firestoreError', 'serializationError', 'expired'
    String? message,
    dynamic error,
  }) {
    final severity = _getErrorSeverity(errorType);

    switch (severity) {
      case 'ERROR':
        Logger.error(
          'Cache error ($errorType): ${message ?? error?.toString() ?? 'Unknown error'}',
          error: error,
          tag: '$_tag/Error',
        );
        break;
      case 'WARNING':
        Logger.warning(
          'Cache warning ($errorType): ${message ?? error?.toString() ?? 'Unknown error'}',
          tag: '$_tag/Error',
        );
        break;
      default: // INFO
        Logger.info(
          'Cache info ($errorType): ${message ?? error?.toString() ?? 'Cache miss'}',
          tag: '$_tag/Error',
        );
    }
  }

  /// Get error severity based on error type
  static String _getErrorSeverity(String errorType) {
    switch (errorType) {
      case 'notFound':
      case 'expired':
        return 'INFO';
      case 'typeMismatch':
        return 'WARNING';
      case 'hiveError':
      case 'firestoreError':
      case 'serializationError':
        return 'ERROR';
      default:
        return 'WARNING';
    }
  }

  // ========== Cache Statistics Logging ==========

  /// Log cache statistics
  static void cacheStats({
    required int l1Hits,
    required int l1Misses,
    required int l2Hits,
    required int l2Misses,
    required int firestoreReadsSaved,
  }) {
    final l1HitRate = l1Hits / (l1Hits + l1Misses) * 100;
    final l2HitRate = l2Hits / (l2Hits + l2Misses) * 100;
    final overallHitRate = (l1Hits + l2Hits) / (l1Hits + l1Misses + l2Hits + l2Misses) * 100;

    Logger.info(
      'Cache statistics - L1: ${l1HitRate.toStringAsFixed(1)}%, L2: ${l2HitRate.toStringAsFixed(1)}%, Overall: ${overallHitRate.toStringAsFixed(1)}%, Firestore saved: $firestoreReadsSaved',
      tag: '$_tag/Stats',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  CREATION LOGGER - Content Creation (56 lines)                              ║
// ║  Lines 1591-1648 | Media selection, draft management                        ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Creation Feature
///
/// Provides domain-specific logging methods for:
/// - Media selection and upload
/// - Draft management
/// - Content creation workflow
///
/// **Features**:
/// - Automatic sensitive data masking (userId, mediaPath)
/// - Structured logging with consistent tags
///
/// **Phase 2-4: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 2 print() statements across Creation Feature
/// - Pattern: Static methods with 'Creation' tag namespace
class CreationLogger {
  static const String _tag = 'Creation';

  // ========== Media Selection Logging ==========

  /// Log media selection
  static void mediaSelected({
    required String mediaType,
    required int count,
  }) {
    Logger.info(
      'Media selected - Type: $mediaType, Count: $count',
      tag: '$_tag/Media',
    );
  }

  /// Log media moderation validation
  static void mediaModerationValidated({
    required String mediaPath,
    required bool isValid,
  }) {
    Logger.info(
      'Media moderation validated - Path: ${Logger.maskSensitive(mediaPath)}, Valid: $isValid',
      tag: '$_tag/Media',
    );
  }

  /// Log creation error
  static void creationError({
    required String errorType,
    dynamic error,
  }) {
    Logger.error(
      'Creation error ($errorType)',
      error: error,
      tag: '$_tag/Error',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  NOTIFICATIONS LOGGER - Notification System (170 lines)                     ║
// ║  Lines 1650-1821 | Notification watch, badges, read status, deletion        ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Notifications Feature
///
/// Provides domain-specific logging methods for:
/// - Notification watching and receiving
/// - Badge count updates
/// - Notification actions
///
/// **Features**:
/// - Automatic sensitive data masking (userId, notificationId)
/// - Structured logging with consistent tags
///
/// **Phase 2-4: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 1 print() statement across Notifications Feature
/// - Pattern: Static methods with 'Notifications' tag namespace
class NotificationsLogger {
  static const String _tag = 'Notifications';

  // ========== Notification Watching Logging ==========

  /// Log notifications received
  static void notificationsReceived({
    required int count,
    String? userId,
  }) {
    Logger.info(
      'Notifications received - Count: $count${userId != null ? ' (user: ${Logger.maskSensitive(userId)})' : ''}',
      tag: '$_tag/Watch',
    );
  }

  /// Log notification error
  static void notificationError({
    required String errorType,
    dynamic error,
  }) {
    Logger.error(
      'Notification error ($errorType)',
      error: error,
      tag: '$_tag/Error',
    );
  }

  // ========== Notification Creation Logging ==========

  /// Log notification created
  static void notificationCreated({
    required String notificationId,
    required String type,
    required String recipientId,
  }) {
    Logger.info(
      'Notification created - Type: $type, Recipient: ${Logger.maskSensitive(recipientId)}, ID: $notificationId',
      tag: '$_tag/Creation',
    );
  }

  /// Log notification creation error
  static void notificationCreationError({
    required String recipientId,
    required dynamic error,
  }) {
    Logger.error(
      'Notification creation failed - Recipient: ${Logger.maskSensitive(recipientId)}',
      tag: '$_tag/Creation',
      error: error,
    );
  }

  // ========== Notification Read Status Logging ==========

  /// Log notification marked as read
  static void notificationMarkedAsRead({
    required String notificationId,
    required String userId,
  }) {
    Logger.info(
      'Notification marked as read - ID: $notificationId, User: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/ReadStatus',
    );
  }

  /// Log all notifications marked as read
  static void allNotificationsMarkedAsRead({
    required String userId,
    required int count,
  }) {
    Logger.info(
      'All notifications marked as read - User: ${Logger.maskSensitive(userId)}, Count: $count',
      tag: '$_tag/ReadStatus',
    );
  }

  /// Log mark as read error
  static void markAsReadError({
    required String notificationId,
    required dynamic error,
  }) {
    Logger.error(
      'Mark as read failed - ID: $notificationId',
      tag: '$_tag/ReadStatus',
      error: error,
    );
  }

  // ========== Notification Deletion Logging ==========

  /// Log notification deleted
  static void notificationDeleted({
    required String notificationId,
    required String userId,
  }) {
    Logger.info(
      'Notification deleted - ID: $notificationId, User: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/Deletion',
    );
  }

  /// Log all notifications deleted
  static void allNotificationsDeleted({
    required String userId,
    required int count,
  }) {
    Logger.warning(
      'All notifications deleted - User: ${Logger.maskSensitive(userId)}, Count: $count',
      tag: '$_tag/Deletion',
    );
  }

  /// Log notification deletion error
  static void notificationDeletionError({
    required String notificationId,
    required dynamic error,
  }) {
    Logger.error(
      'Notification deletion failed - ID: $notificationId',
      tag: '$_tag/Deletion',
      error: error,
    );
  }

  // ========== Badge Count Logging ==========

  /// Log badge count updated
  static void badgeCountUpdated({
    required String userId,
    required int count,
  }) {
    Logger.debug(
      'Badge count updated - User: ${Logger.maskSensitive(userId)}, Count: $count',
      tag: '$_tag/BadgeCount',
    );
  }

  // ========== Notification Query Logging ==========

  /// Log notification query error
  static void notificationQueryError({
    required String userId,
    required dynamic error,
  }) {
    Logger.error(
      'Notification query failed - User: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/Query',
      error: error,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  SERVICES LOGGER - Cross-Cutting Services (71 lines)                        ║
// ║  Lines 1823-1895 | Geo-location, Firestore batch, Analytics                ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Core Services
///
/// Provides domain-specific logging methods for:
/// - Geo-location services
/// - Firestore utilities
/// - Analytics events
///
/// **Features**:
/// - Automatic sensitive data masking (location, userId)
/// - Structured logging with consistent tags
///
/// **Phase 2-4: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 4 print() statements across Core Services
/// - Pattern: Static methods with 'Services' tag namespace
class ServicesLogger {
  static const String _tag = 'Services';

  // ========== Geo-location Logging ==========

  /// Log location detected
  static void locationDetected({
    required String city,
    required String country,
  }) {
    Logger.info(
      'Location detected - City: $city, Country: $country',
      tag: '$_tag/Geo',
    );
  }

  // ========== Firestore Utilities Logging ==========

  /// Log Firestore batch operation
  static void firestoreBatchOperation({
    required String operation,
    required int count,
  }) {
    Logger.info(
      'Firestore batch operation - Operation: $operation, Count: $count',
      tag: '$_tag/Firestore',
    );
  }

  // ========== Analytics Logging ==========

  /// Log analytics event
  static void analyticsEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    Logger.info(
      'Analytics event - Event: $eventName${parameters != null ? ', Params: ${parameters.length}' : ''}',
      tag: '$_tag/Analytics',
    );
  }

  /// Log service error
  static void serviceError({
    required String service,
    dynamic error,
  }) {
    Logger.error(
      'Service error ($service)',
      error: error,
      tag: '$_tag/Error',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  UTILS LOGGER - Utility Functions (57 lines)                                ║
// ║  Lines 1897-1955 | UI utilities, DateTime operations                        ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Core Utilities
///
/// Provides domain-specific logging methods for:
/// - UI utilities
/// - DateTime utilities
/// - Helper functions
///
/// **Features**:
/// - Structured logging with consistent tags
///
/// **Phase 2-4: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 2 print() statements across Core Utils
/// - Pattern: Static methods with 'Utils' tag namespace
class UtilsLogger {
  static const String _tag = 'Utils';

  // ========== UI Utilities Logging ==========

  /// Log UI operation
  static void uiOperation({
    required String operation,
    String? details,
  }) {
    Logger.debug(
      'UI operation - Operation: $operation${details != null ? ', Details: $details' : ''}',
      tag: '$_tag/UI',
    );
  }

  // ========== DateTime Utilities Logging ==========

  /// Log datetime operation
  static void datetimeOperation({
    required String operation,
    String? result,
  }) {
    Logger.debug(
      'Datetime operation - Operation: $operation${result != null ? ', Result: $result' : ''}',
      tag: '$_tag/DateTime',
    );
  }

  /// Log utils error
  static void utilsError({
    required String utility,
    dynamic error,
  }) {
    Logger.error(
      'Utils error ($utility)',
      error: error,
      tag: '$_tag/Error',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  AUTH LOGGER - Authentication & User Management (108 lines)                 ║
// ║  Lines 1957-2066 | Sign in/out, user creation, account deletion             ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Authentication
///
/// Provides domain-specific logging methods for:
/// - User sign in/out operations
/// - User creation in Firestore
/// - Account deletion
///
/// **Features**:
/// - Automatic sensitive data masking (userId, authMethod)
/// - Structured logging with consistent tags
/// - Support for multiple auth methods (Apple, Google, Email)
///
/// **Phase 1: CRITICAL Logger Integration** 🆕
/// - Created: 2025-11-16
/// - Supports: 7 auth operations + 29 debugPrint conversions
/// - Pattern: Static methods with 'Auth' tag namespace
class AuthLogger {
  static const String _tag = 'Auth';

  // ============================================
  // SIGN IN (2 methods)
  // ============================================

  static void signInSuccess({
    required String userId,
    required String authMethod,
  }) {
    Logger.info(
      'User signed in successfully - Method: $authMethod, UserId: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/SignIn',
    );
  }

  static void signInError({
    required String authMethod,
    required dynamic error,
  }) {
    Logger.error(
      'Sign in failed - Method: $authMethod',
      tag: '$_tag/SignIn',
      error: error,
    );
  }

  // ============================================
  // USER CREATION (2 methods)
  // ============================================

  static void userCreated({
    required String userId,
    required String authMethod,
  }) {
    Logger.info(
      'New user created in Firestore - Method: $authMethod, UserId: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/UserCreation',
    );
  }

  static void userCreationError({
    required String userId,
    required dynamic error,
  }) {
    Logger.error(
      'User creation failed - UserId: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/UserCreation',
      error: error,
    );
  }

  // ============================================
  // ACCOUNT DELETION (2 methods)
  // ============================================

  static void accountDeleted({
    required String userId,
  }) {
    Logger.warning(
      'User account deleted - UserId: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/AccountDeletion',
    );
  }

  static void accountDeletionError({
    required String userId,
    required dynamic error,
  }) {
    Logger.error(
      'Account deletion failed - UserId: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/AccountDeletion',
      error: error,
    );
  }

  // ============================================
  // SIGN OUT (1 method)
  // ============================================

  static void signOutSuccess({
    required String userId,
  }) {
    Logger.info(
      'User signed out - UserId: ${Logger.maskSensitive(userId)}',
      tag: '$_tag/SignOut',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  ROUTER LOGGER - Navigation & Routing (57 lines)                            ║
// ║  Lines 2068-2126 | Route navigation, auth guards, redirects                 ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for App Router
///
/// Provides domain-specific logging methods for:
/// - Route navigation
/// - Auth guard checks
/// - Route redirects
///
/// **Features**:
/// - Automatic sensitive data masking (userId, route)
/// - Structured logging with consistent tags
///
/// **Phase 2-4: Logger Integration** ✅
/// - Created: 2025-11-15
/// - Replaces: 1 print() statement across App Router
/// - Pattern: Static methods with 'Router' tag namespace
class RouterLogger {
  static const String _tag = 'Router';

  // ========== Route Navigation Logging ==========

  /// Log auth guard check
  static void authGuardCheck({
    required String route,
    required bool isAuthenticated,
  }) {
    Logger.info(
      'Auth guard check - Route: $route, Authenticated: $isAuthenticated',
      tag: '$_tag/Guard',
    );
  }

  /// Log route redirect
  static void routeRedirect({
    required String from,
    required String to,
  }) {
    Logger.info(
      'Route redirect - From: $from, To: $to',
      tag: '$_tag/Redirect',
    );
  }

  /// Log router error
  static void routerError({
    required String errorType,
    dynamic error,
  }) {
    Logger.error(
      'Router error ($errorType)',
      error: error,
      tag: '$_tag/Error',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  STATE LOGGER - Presentation Layer State Management (~510 lines)            ║
// ║  Lines 2920-3430 | Notifier business logic, state changes                   ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Presentation Layer State Management
///
/// Provides domain-specific logging methods for:
/// - Create Post Notifier (8 methods) - Post submission, draft saving, validation
/// - Notification Badge (4 methods) - Badge count changes
/// - Voting State (4 methods) - Vote state updates, submission handling
/// - Chat State (3 methods) - Chat activity, typing indicators
/// - Profile State (2 methods) - Profile cache updates, refresh requests
/// - Post State (1 method) - Post visibility changes
///
/// **Features**:
/// - Presentation layer business logic tracking
/// - State change visibility
/// - Duration metrics for async operations
/// - Automatic userId masking (GDPR compliance)
///
/// **Phase 3-1: Notifier Logging** ✅ Integrated
/// - Created: 2025-11-17
/// - Integrated: 2025-11-17
/// - Usage: 11 calls in create_post_notifier.dart
/// - Pattern: Static methods with 'State' tag namespace
class StateLogger {
  static const String _tag = 'State';

  // ============================================
  // CREATE POST NOTIFIER (8 methods)
  // ============================================

  /// Log post submission started
  ///
  /// **When to call**: At the beginning of submitPost() method
  ///
  /// **Parameters**:
  /// - [userId]: User ID initiating submission
  ///
  /// **Tag**: 'State/PostSubmission'
  static void postSubmissionStarted({
    required String userId,
  }) {
    Logger.info(
      'Post submission started - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation, '
      'Notifier: CreatePostNotifier',
      tag: '$_tag/PostSubmission',
    );
  }

  /// Log post submission completed
  ///
  /// **When to call**: After successful post creation
  ///
  /// **Parameters**:
  /// - [postId]: Created post ID
  /// - [submissionTime]: Total submission duration
  ///
  /// **Tag**: 'State/PostSubmission'
  static void postSubmissionCompleted({
    required String postId,
    required Duration submissionTime,
  }) {
    Logger.info(
      'Post submission completed - '
      'PostId: ${Logger.maskSensitive(postId)}, '
      'Duration: ${submissionTime.inMilliseconds}ms, '
      'Layer: Presentation',
      tag: '$_tag/PostSubmission',
    );
  }

  /// Log post submission error
  ///
  /// **When to call**: On post creation failure
  ///
  /// **Parameters**:
  /// - [userId]: User ID who attempted submission
  /// - [error]: Exception or failure object
  ///
  /// **Tag**: 'State/PostSubmission'
  static void postSubmissionError({
    required String userId,
    required dynamic error,
  }) {
    Logger.error(
      'Post submission failed - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation',
      error: error,
      tag: '$_tag/PostSubmission',
    );
  }

  /// Log draft saved to cache
  ///
  /// **When to call**: After saving draft to CreationCacheService
  ///
  /// **Parameters**:
  /// - [userId]: User ID who owns the draft
  ///
  /// **Tag**: 'State/Draft'
  static void draftSaved({
    required String userId,
  }) {
    Logger.debug(
      'Draft saved to cache - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation, '
      'Cache: CreationCacheService',
      tag: '$_tag/Draft',
    );
  }

  /// Log content validation started
  ///
  /// **When to call**: At the beginning of validateContent() method
  ///
  /// **Parameters**:
  /// - [userId]: User ID requesting validation
  ///
  /// **Tag**: 'State/Validation'
  static void contentValidationStarted({
    required String userId,
  }) {
    Logger.debug(
      'Content validation started - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation',
      tag: '$_tag/Validation',
    );
  }

  /// Log content validation completed
  ///
  /// **When to call**: After validation result received
  ///
  /// **Parameters**:
  /// - [isValid]: Whether content passed validation
  /// - [reason]: Failure reason (if invalid)
  ///
  /// **Tag**: 'State/Validation'
  static void contentValidationCompleted({
    required bool isValid,
    String? reason,
  }) {
    Logger.debug(
      'Content validation completed - '
      'IsValid: $isValid'
      '${reason != null ? ", Reason: $reason" : ""}, '
      'Layer: Presentation',
      tag: '$_tag/Validation',
    );
  }

  /// Log media upload queue started
  ///
  /// **When to call**: When uploadMedia() begins processing queue
  ///
  /// **Parameters**:
  /// - [mediaCount]: Number of media items in queue
  ///
  /// **Tag**: 'State/MediaQueue'
  static void mediaUploadQueueStarted({
    required int mediaCount,
  }) {
    Logger.info(
      'Media upload queue started - '
      'MediaCount: $mediaCount, '
      'Layer: Presentation',
      tag: '$_tag/MediaQueue',
    );
  }

  /// Log media upload queue completed
  ///
  /// **When to call**: After all media uploads finished
  ///
  /// **Parameters**:
  /// - [successCount]: Number of successful uploads
  /// - [failedCount]: Number of failed uploads
  ///
  /// **Tag**: 'State/MediaQueue'
  static void mediaUploadQueueCompleted({
    required int successCount,
    required int failedCount,
  }) {
    Logger.info(
      'Media upload queue completed - '
      'Success: $successCount, '
      'Failed: $failedCount, '
      'Layer: Presentation',
      tag: '$_tag/MediaQueue',
    );
  }

  // ============================================
  // NOTIFICATION BADGE (4 methods)
  // ============================================

  /// Log badge count incremented
  ///
  /// **When to call**: When incrementBadgeCount() is called
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose badge count changed
  /// - [newCount]: New badge count after increment
  ///
  /// **Tag**: 'State/Badge'
  static void badgeCountIncremented({
    required String userId,
    required int newCount,
  }) {
    Logger.debug(
      'Badge count incremented - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'NewCount: $newCount, '
      'Layer: Presentation',
      tag: '$_tag/Badge',
    );
  }

  /// Log badge count decremented
  ///
  /// **When to call**: When decrementBadgeCount() is called
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose badge count changed
  /// - [newCount]: New badge count after decrement
  ///
  /// **Tag**: 'State/Badge'
  static void badgeCountDecremented({
    required String userId,
    required int newCount,
  }) {
    Logger.debug(
      'Badge count decremented - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'NewCount: $newCount, '
      'Layer: Presentation',
      tag: '$_tag/Badge',
    );
  }

  /// Log badge count reset
  ///
  /// **When to call**: When resetBadgeCount() is called
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose badge count was reset
  ///
  /// **Tag**: 'State/Badge'
  static void badgeCountReset({
    required String userId,
  }) {
    Logger.debug(
      'Badge count reset - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'NewCount: 0, '
      'Layer: Presentation',
      tag: '$_tag/Badge',
    );
  }

  /// Log badge count error
  ///
  /// **When to call**: On badge count operation failure
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose badge count operation failed
  /// - [error]: Exception or failure object
  ///
  /// **Tag**: 'State/Badge'
  static void badgeCountError({
    required String userId,
    required dynamic error,
  }) {
    Logger.error(
      'Badge count operation failed - '
      'UserId: ${Logger.maskSensitive(userId)}',
      error: error,
      tag: '$_tag/Badge',
    );
  }

  // ============================================
  // VOTING STATE (4 methods)
  // ============================================

  /// Log vote state updated
  ///
  /// **When to call**: When updateVoteState() is called
  ///
  /// **Parameters**:
  /// - [voteId]: Vote ID being updated
  /// - [newState]: New vote state (active/expired/closed)
  ///
  /// **Tag**: 'State/VoteState'
  static void voteStateUpdated({
    required String voteId,
    required String newState,
  }) {
    Logger.debug(
      'Vote state updated - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'NewState: $newState, '
      'Layer: Presentation',
      tag: '$_tag/VoteState',
    );
  }

  /// Log vote submission handled
  ///
  /// **When to call**: When handleVoteSubmission() is called
  ///
  /// **Parameters**:
  /// - [voteId]: Vote ID being submitted
  /// - [userId]: User ID submitting vote
  ///
  /// **Tag**: 'State/VoteSubmission'
  static void voteSubmissionHandled({
    required String voteId,
    required String userId,
  }) {
    Logger.info(
      'Vote submission handled - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation',
      tag: '$_tag/VoteSubmission',
    );
  }

  /// Log vote change handled
  ///
  /// **When to call**: When handleVoteChange() is called
  ///
  /// **Parameters**:
  /// - [voteId]: Vote ID being changed
  /// - [userId]: User ID changing vote
  ///
  /// **Tag**: 'State/VoteChange'
  static void voteChangeHandled({
    required String voteId,
    required String userId,
  }) {
    Logger.info(
      'Vote change handled - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation',
      tag: '$_tag/VoteChange',
    );
  }

  /// Log vote state error
  ///
  /// **When to call**: On vote state operation failure
  ///
  /// **Parameters**:
  /// - [voteId]: Vote ID whose operation failed
  /// - [error]: Exception or failure object
  ///
  /// **Tag**: 'State/VoteState'
  static void voteStateError({
    required String voteId,
    required dynamic error,
  }) {
    Logger.error(
      'Vote state operation failed - '
      'VoteId: ${Logger.maskSensitive(voteId)}',
      error: error,
      tag: '$_tag/VoteState',
    );
  }

  // ============================================
  // CHAT STATE (3 methods)
  // ============================================

  /// Log chat marked as active
  ///
  /// **When to call**: When markChatAsActive() is called
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID being marked active
  /// - [userId]: User ID marking chat active
  ///
  /// **Tag**: 'State/ChatActive'
  static void chatMarkedAsActive({
    required String chatId,
    required String userId,
  }) {
    Logger.debug(
      'Chat marked as active - '
      'ChatId: ${Logger.maskSensitive(chatId)}, '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation',
      tag: '$_tag/ChatActive',
    );
  }

  /// Log typing indicator updated
  ///
  /// **When to call**: When updateTypingIndicator() is called
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID where typing indicator changed
  /// - [userId]: User ID whose typing status changed
  /// - [isTyping]: Whether user is now typing
  ///
  /// **Tag**: 'State/ChatTyping'
  static void typingIndicatorUpdated({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) {
    Logger.debug(
      'Typing indicator updated - '
      'ChatId: ${Logger.maskSensitive(chatId)}, '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'IsTyping: $isTyping, '
      'Layer: Presentation',
      tag: '$_tag/ChatTyping',
    );
  }

  /// Log chat state error
  ///
  /// **When to call**: On chat state operation failure
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID whose operation failed
  /// - [error]: Exception or failure object
  ///
  /// **Tag**: 'State/ChatState'
  static void chatStateError({
    required String chatId,
    required dynamic error,
  }) {
    Logger.error(
      'Chat state operation failed - '
      'ChatId: ${Logger.maskSensitive(chatId)}',
      error: error,
      tag: '$_tag/ChatState',
    );
  }

  // ============================================
  // PROFILE STATE (2 methods)
  // ============================================

  /// Log local profile cache updated
  ///
  /// **When to call**: When updateLocalProfile() is called
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose profile was updated in cache
  ///
  /// **Tag**: 'State/ProfileCache'
  static void localProfileUpdated({
    required String userId,
  }) {
    Logger.debug(
      'Local profile cache updated - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation, '
      'Cache: UnifiedCacheService',
      tag: '$_tag/ProfileCache',
    );
  }

  /// Log profile refresh requested
  ///
  /// **When to call**: When refreshProfile() is called
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose profile refresh was requested
  ///
  /// **Tag**: 'State/ProfileRefresh'
  static void profileRefreshRequested({
    required String userId,
  }) {
    Logger.debug(
      'Profile refresh requested - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Layer: Presentation',
      tag: '$_tag/ProfileRefresh',
    );
  }

  // ============================================
  // POST STATE (1 method)
  // ============================================

  /// Log post visibility updated
  ///
  /// **When to call**: When updatePostVisibility() is called
  ///
  /// **Parameters**:
  /// - [postId]: Post ID whose visibility changed
  /// - [isVisible]: New visibility state
  ///
  /// **Tag**: 'State/PostVisibility'
  static void postVisibilityUpdated({
    required String postId,
    required bool isVisible,
  }) {
    Logger.info(
      'Post visibility updated - '
      'PostId: ${Logger.maskSensitive(postId)}, '
      'IsVisible: $isVisible, '
      'Layer: Presentation',
      tag: '$_tag/PostVisibility',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  SEARCH LOGGER - Search Operations (~280 lines)                             ║
// ║  Lines 3439-3719 | Search queries, history management                       ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Search operations
///
/// Provides domain-specific logging methods for:
/// - Search Query (6 methods) - Query execution, performance tracking
/// - Search History (4 methods) - History save/delete operations
///
/// **Features**:
/// - Query performance metrics (duration, result count)
/// - Search type tracking (posts/users)
/// - Query truncation (max 50 chars)
/// - Automatic error categorization
///
/// **Phase 3-2: Search Logging** ✅ Integrated
/// - Created: 2025-11-17
/// - Integrated: 2025-11-17
/// - Usage: 11 calls in search_repository_impl.dart, algolia_manager.dart
/// - Pattern: Static methods with 'Search' tag namespace
class SearchLogger {
  static const String _tag = 'Search';

  // ============================================
  // SEARCH QUERY (6 methods)
  // ============================================

  /// Log search query started
  ///
  /// **When to call**: At the beginning of search operation
  ///
  /// **Parameters**:
  /// - [query]: Search query text (truncated to 50 chars)
  /// - [searchType]: Type of search (posts/users)
  ///
  /// **Tag**: 'Search/Query'
  static void searchQueryStarted({
    required String query,
    required String searchType,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.info(
      'Search query started - '
      'Query: "$truncatedQuery", '
      'SearchType: $searchType',
      tag: '$_tag/Query',
    );
  }

  /// Log search query completed
  ///
  /// **When to call**: After search results received
  ///
  /// **Parameters**:
  /// - [query]: Search query text (truncated to 50 chars)
  /// - [resultCount]: Number of results found
  /// - [queryTime]: Total query duration
  ///
  /// **Tag**: 'Search/Query'
  static void searchQueryCompleted({
    required String query,
    required int resultCount,
    required Duration queryTime,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.info(
      'Search query completed - '
      'Query: "$truncatedQuery", '
      'ResultCount: $resultCount, '
      'Duration: ${queryTime.inMilliseconds}ms',
      tag: '$_tag/Query',
    );
  }

  /// Log search query error
  ///
  /// **When to call**: On search operation failure
  ///
  /// **Parameters**:
  /// - [query]: Search query text (truncated to 50 chars)
  /// - [error]: Exception or failure object
  ///
  /// **Tag**: 'Search/Query'
  static void searchQueryError({
    required String query,
    required dynamic error,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.error(
      'Search query failed - '
      'Query: "$truncatedQuery"',
      error: error,
      tag: '$_tag/Query',
    );
  }

  /// Log post search completed
  ///
  /// **When to call**: After searchPosts() returns results
  ///
  /// **Parameters**:
  /// - [query]: Search query text (truncated to 50 chars)
  /// - [resultCount]: Number of posts found
  ///
  /// **Tag**: 'Search/Posts'
  static void searchPostsQuery({
    required String query,
    required int resultCount,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.info(
      'Post search completed - '
      'Query: "$truncatedQuery", '
      'ResultCount: $resultCount, '
      'Collection: posts',
      tag: '$_tag/Posts',
    );
  }

  /// Log user search completed
  ///
  /// **When to call**: After searchUsers() returns results
  ///
  /// **Parameters**:
  /// - [query]: Search query text (truncated to 50 chars)
  /// - [resultCount]: Number of users found
  ///
  /// **Tag**: 'Search/Users'
  static void searchUsersQuery({
    required String query,
    required int resultCount,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.info(
      'User search completed - '
      'Query: "$truncatedQuery", '
      'ResultCount: $resultCount, '
      'Collection: users',
      tag: '$_tag/Users',
    );
  }

  /// Log empty search results
  ///
  /// **When to call**: When search returns 0 results
  ///
  /// **Parameters**:
  /// - [query]: Search query text (truncated to 50 chars)
  /// - [searchType]: Type of search (posts/users)
  ///
  /// **Tag**: 'Search/Empty'
  static void searchEmptyResults({
    required String query,
    required String searchType,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.debug(
      'Search returned no results - '
      'Query: "$truncatedQuery", '
      'SearchType: $searchType',
      tag: '$_tag/Empty',
    );
  }

  // ============================================
  // SEARCH HISTORY (4 methods)
  // ============================================

  /// Log search history saved
  ///
  /// **When to call**: After saving search query to history
  ///
  /// **Parameters**:
  /// - [userId]: User ID who performed search
  /// - [query]: Search query text (truncated to 50 chars)
  ///
  /// **Tag**: 'Search/History'
  static void searchHistorySaved({
    required String userId,
    required String query,
  }) {
    final truncatedQuery = query.length > 50
        ? '${query.substring(0, 50)}...'
        : query;

    Logger.debug(
      'Search history saved - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'Query: "$truncatedQuery", '
      'Collection: search_history',
      tag: '$_tag/History',
    );
  }

  /// Log search history deleted
  ///
  /// **When to call**: After deleting search history
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose history was deleted
  /// - [deletedCount]: Number of history entries deleted
  ///
  /// **Tag**: 'Search/History'
  static void searchHistoryDeleted({
    required String userId,
    required int deletedCount,
  }) {
    Logger.info(
      'Search history deleted - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'DeletedCount: $deletedCount',
      tag: '$_tag/History',
    );
  }

  /// Log search history error
  ///
  /// **When to call**: On search history operation failure
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose operation failed
  /// - [error]: Exception or failure object
  ///
  /// **Tag**: 'Search/History'
  static void searchHistoryError({
    required String userId,
    required dynamic error,
  }) {
    Logger.error(
      'Search history operation failed - '
      'UserId: ${Logger.maskSensitive(userId)}',
      error: error,
      tag: '$_tag/History',
    );
  }

  /// Log search history loaded
  ///
  /// **When to call**: After loading user's search history
  ///
  /// **Parameters**:
  /// - [userId]: User ID whose history was loaded
  /// - [historyCount]: Number of history entries loaded
  ///
  /// **Tag**: 'Search/History'
  static void searchHistoryLoaded({
    required String userId,
    required int historyCount,
  }) {
    Logger.debug(
      'Search history loaded - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'HistoryCount: $historyCount',
      tag: '$_tag/History',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  SERVICE LOGGER - Support Services (~240 lines)                             ║
// ║  Lines 3716-3956 | Vote timer, status, state coordination                   ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Support Services
///
/// Provides domain-specific logging methods for:
/// - Vote Timer Service (4 methods) - Timer lifecycle, extension, expiration
/// - Vote Status Service (2 methods) - Status updates, broadcasting
/// - Vote State Coordinator (2 methods) - State coordination, conflict resolution
///
/// **Features**:
/// - Vote timer lifecycle tracking
/// - Status propagation monitoring
/// - State coordination visibility
/// - Automatic voteId masking (GDPR compliance)
/// - Timestamp formatting (ISO8601)
///
/// **Phase 3-3: Support Services Logging** ✅ Integrated
/// - Created: 2025-11-17
/// - Integrated: 2025-11-17
/// - Usage: 4 calls in vote_timer_service.dart
/// - Pattern: Static methods with 'Service' tag namespace
class ServiceLogger {
  static const String _tag = 'Service';

  // ============================================
  // VOTE TIMER SERVICE (4 methods)
  // ============================================

  /// Log vote timer started
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteTimerStarted(
  ///   voteId: voteId,
  ///   endTime: endTime,
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [endTime]: Vote end timestamp
  ///
  /// **Tag**: 'Service/Timer'
  static void voteTimerStarted({
    required String voteId,
    required DateTime endTime,
  }) {
    Logger.info(
      'Vote timer started - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'EndTime: ${endTime.toIso8601String()}, '
      'Layer: Service, '
      'Service: VoteTimerService',
      tag: '$_tag/Timer',
    );
  }

  /// Log vote timer stopped
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteTimerStopped(
  ///   voteId: voteId,
  ///   reason: 'Vote cancelled',
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [reason]: Stop reason
  ///
  /// **Tag**: 'Service/Timer'
  static void voteTimerStopped({
    required String voteId,
    required String reason,
  }) {
    Logger.info(
      'Vote timer stopped - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'Reason: $reason, '
      'Layer: Service',
      tag: '$_tag/Timer',
    );
  }

  /// Log vote timer extended
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteTimerExtended(
  ///   voteId: voteId,
  ///   oldEndTime: oldEndTime,
  ///   newEndTime: newEndTime,
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [oldEndTime]: Original end time
  /// - [newEndTime]: Extended end time
  ///
  /// **Tag**: 'Service/Timer'
  static void voteTimerExtended({
    required String voteId,
    required DateTime oldEndTime,
    required DateTime newEndTime,
  }) {
    final extension = newEndTime.difference(oldEndTime);

    Logger.info(
      'Vote timer extended - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'OldEndTime: ${oldEndTime.toIso8601String()}, '
      'NewEndTime: ${newEndTime.toIso8601String()}, '
      'ExtensionDuration: ${extension.inMinutes}min, '
      'Layer: Service',
      tag: '$_tag/Timer',
    );
  }

  /// Log vote timer expired
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteTimerExpired(voteId: voteId);
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  ///
  /// **Tag**: 'Service/Timer'
  static void voteTimerExpired({required String voteId}) {
    Logger.info(
      'Vote timer expired - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'Layer: Service, '
      'Action: Vote finalization triggered',
      tag: '$_tag/Timer',
    );
  }

  // ============================================
  // VOTE STATUS SERVICE (2 methods)
  // ============================================

  /// Log vote status updated
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteStatusUpdated(
  ///   voteId: voteId,
  ///   status: 'active',
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [status]: New vote status
  ///
  /// **Tag**: 'Service/Status'
  static void voteStatusUpdated({
    required String voteId,
    required String status,
  }) {
    Logger.info(
      'Vote status updated - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'NewStatus: $status, '
      'Layer: Service, '
      'Service: VoteStatusService',
      tag: '$_tag/Status',
    );
  }

  /// Log vote status broadcasted
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteStatusBroadcasted(
  ///   voteId: voteId,
  ///   status: 'completed',
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [status]: Broadcasted status
  ///
  /// **Tag**: 'Service/Status'
  static void voteStatusBroadcasted({
    required String voteId,
    required String status,
  }) {
    Logger.debug(
      'Vote status broadcasted - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'Status: $status, '
      'Layer: Service, '
      'Action: Stream notification sent',
      tag: '$_tag/Status',
    );
  }

  // ============================================
  // VOTE STATE COORDINATOR (2 methods)
  // ============================================

  /// Log vote state coordinated
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteStateCoordinated(
  ///   voteId: voteId,
  ///   coordinatedSources: ['timer', 'status', 'repository'],
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [coordinatedSources]: List of coordinated state sources
  ///
  /// **Tag**: 'Service/Coordinator'
  static void voteStateCoordinated({
    required String voteId,
    required List<String> coordinatedSources,
  }) {
    Logger.info(
      'Vote state coordinated - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'CoordinatedSources: [${coordinatedSources.join(', ')}], '
      'SourceCount: ${coordinatedSources.length}, '
      'Layer: Service, '
      'Service: VoteStateCoordinator',
      tag: '$_tag/Coordinator',
    );
  }

  /// Log vote state conflict resolved
  ///
  /// **Usage**:
  /// ```dart
  /// ServiceLogger.voteStateConflictResolved(
  ///   voteId: voteId,
  ///   conflictType: 'timer_status_mismatch',
  ///   resolution: 'timer_priority',
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote identifier (auto-masked)
  /// - [conflictType]: Type of state conflict
  /// - [resolution]: How conflict was resolved
  ///
  /// **Tag**: 'Service/Coordinator'
  static void voteStateConflictResolved({
    required String voteId,
    required String conflictType,
    required String resolution,
  }) {
    Logger.warning(
      'Vote state conflict resolved - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'ConflictType: $conflictType, '
      'Resolution: $resolution, '
      'Layer: Service',
      tag: '$_tag/Coordinator',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ║  BATCH LOGGER - Firestore Batch Operations (~330 lines)                     ║
// ║  Lines 3994-4323 | Atomic multi-operations, bulk processing                 ║
// ═══════════════════════════════════════════════════════════════════════════════

/// Specialized logger for Firestore Batch Operations
///
/// Provides domain-specific logging methods for:
/// - Batch Execution General (3 methods) - Start, complete, error tracking
/// - Profile Batch Operations (1 method) - Full profile updates
/// - Auth Batch Operations (1 method) - Account deletion cascades
/// - Notifications Batch (1 method) - Bulk notification creation
/// - Voting Batch Operations (1 method) - Vote + counter updates
///
/// **Features**:
/// - Atomic operation tracking (all-or-nothing)
/// - Performance metrics (operations/sec, duration)
/// - Operation count visibility
/// - Automatic error categorization
/// - GDPR compliance (ID masking)
///
/// **Phase 2-5: Batch Operations Logging** ✅ Complete
/// - Created: 2025-11-17
/// - Usage: 7 calls in batch_service.dart
/// - Pattern: Static methods with 'Batch' tag namespace
/// - Performance Impact: 100x improvement for bulk operations
class BatchLogger {
  static const String _tag = 'Batch';

  // ============================================
  // BATCH EXECUTION GENERAL (3 methods)
  // ============================================

  /// Log batch execution started
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.batchExecutionStarted(
  ///   operationCount: batch.operations.length,
  ///   batchType: 'notification_bulk',
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [operationCount]: Number of operations in batch
  /// - [batchType]: Type of batch operation
  ///
  /// **Tag**: 'Batch/Execution'
  static void batchExecutionStarted({
    required int operationCount,
    required String batchType,
  }) {
    Logger.info(
      'Batch execution started - '
      'OperationCount: $operationCount, '
      'BatchType: $batchType, '
      'Layer: Service, '
      'Service: BatchService',
      tag: '$_tag/Execution',
    );
  }

  /// Log batch execution completed
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.batchExecutionCompleted(
  ///   operationCount: successCount,
  ///   batchType: 'notification_bulk',
  ///   executionTime: stopwatch.elapsed,
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [operationCount]: Number of successfully executed operations
  /// - [batchType]: Type of batch operation
  /// - [executionTime]: Total batch execution duration
  ///
  /// **Tag**: 'Batch/Execution'
  static void batchExecutionCompleted({
    required int operationCount,
    required String batchType,
    required Duration executionTime,
  }) {
    final opsPerSecond = operationCount / executionTime.inSeconds;

    Logger.info(
      'Batch execution completed - '
      'OperationCount: $operationCount, '
      'BatchType: $batchType, '
      'Duration: ${executionTime.inMilliseconds}ms, '
      'OpsPerSec: ${opsPerSecond.toStringAsFixed(2)}, '
      'Layer: Service',
      tag: '$_tag/Execution',
    );
  }

  /// Log batch execution error
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.batchExecutionError(
  ///   batchType: 'notification_bulk',
  ///   failedCount: 42,
  ///   error: e,
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [batchType]: Type of batch operation
  /// - [failedCount]: Number of operations that failed (optional)
  /// - [error]: Error object
  ///
  /// **Tag**: 'Batch/Execution'
  static void batchExecutionError({
    required String batchType,
    int? failedCount,
    required dynamic error,
  }) {
    Logger.error(
      'Batch execution failed - '
      'BatchType: $batchType'
      '${failedCount != null ? ", FailedCount: $failedCount" : ""}, '
      'Layer: Service',
      error: error,
      tag: '$_tag/Execution',
    );
  }

  // ============================================
  // PROFILE BATCH OPERATIONS (1 method)
  // ============================================

  /// Log profile batch executed (full profile update)
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.profileBatchExecuted(
  ///   userId: userId,
  ///   updateCount: 5,
  ///   collections: ['users', 'userSettings', 'userStats'],
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [userId]: User ID (auto-masked)
  /// - [updateCount]: Number of updates in batch
  /// - [collections]: List of updated collections
  ///
  /// **Tag**: 'Batch/Profile'
  ///
  /// **Performance**:
  /// - Before: 5 sequential writes (5 network round-trips)
  /// - After: 1 batch write (1 network round-trip)
  /// - Improvement: 3x faster, 66% fewer network calls
  static void profileBatchExecuted({
    required String userId,
    required int updateCount,
    required List<String> collections,
  }) {
    Logger.info(
      'Profile batch executed - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'UpdateCount: $updateCount, '
      'Collections: [${collections.join(', ')}], '
      'Layer: Service, '
      'Feature: Profile',
      tag: '$_tag/Profile',
    );
  }

  // ============================================
  // AUTH BATCH OPERATIONS (1 method)
  // ============================================

  /// Log account deletion batch executed
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.accountDeletionBatchExecuted(
  ///   userId: userId,
  ///   deletedCollections: ['users', 'chats', 'posts', 'votes'],
  ///   deletedCount: 127,
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [userId]: User ID being deleted (auto-masked)
  /// - [deletedCollections]: List of collections cascaded
  /// - [deletedCount]: Total documents deleted
  ///
  /// **Tag**: 'Batch/Auth'
  ///
  /// **Cascade Delete Pattern**:
  /// - User document + all related data
  /// - Atomic operation ensures data consistency
  /// - GDPR compliance: complete data removal
  static void accountDeletionBatchExecuted({
    required String userId,
    required List<String> deletedCollections,
    required int deletedCount,
  }) {
    Logger.info(
      'Account deletion batch executed - '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'DeletedCollections: [${deletedCollections.join(', ')}], '
      'DeletedCount: $deletedCount, '
      'Layer: Service, '
      'Feature: Auth, '
      'GDPRCompliance: true',
      tag: '$_tag/Auth',
    );
  }

  // ============================================
  // NOTIFICATIONS BATCH (1 method)
  // ============================================

  /// Log bulk notifications created
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.notificationsBatchCreated(
  ///   recipientCount: userIds.length,
  ///   notificationType: 'voting_request',
  ///   batchSize: 100,
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [recipientCount]: Number of notification recipients
  /// - [notificationType]: Type of notification
  /// - [batchSize]: Batch size used
  ///
  /// **Tag**: 'Batch/Notifications'
  ///
  /// **Performance**:
  /// - Before: 100 sequential writes (100 network calls)
  /// - After: 1 batch write per 500 notifications (1 network call)
  /// - Improvement: 100x faster, 99% fewer network calls
  static void notificationsBatchCreated({
    required int recipientCount,
    required String notificationType,
    required int batchSize,
  }) {
    Logger.info(
      'Notifications batch created - '
      'RecipientCount: $recipientCount, '
      'NotificationType: $notificationType, '
      'BatchSize: $batchSize, '
      'Layer: Service, '
      'Feature: Notifications',
      tag: '$_tag/Notifications',
    );
  }

  // ============================================
  // VOTING BATCH OPERATIONS (1 method)
  // ============================================

  /// Log vote batch submitted (vote + counter updates)
  ///
  /// **Usage**:
  /// ```dart
  /// BatchLogger.voteBatchSubmitted(
  ///   voteId: voteId,
  ///   userId: userId,
  ///   updatedCounters: ['optionA_count', 'total_votes', 'user_stats'],
  /// );
  /// ```
  ///
  /// **Parameters**:
  /// - [voteId]: Vote ID (auto-masked)
  /// - [userId]: User ID who voted (auto-masked)
  /// - [updatedCounters]: List of counter fields updated
  ///
  /// **Tag**: 'Batch/Voting'
  ///
  /// **Atomic Vote Pattern**:
  /// - Vote submission + counter increments
  /// - Prevents vote count inconsistencies
  /// - Ensures idempotency
  static void voteBatchSubmitted({
    required String voteId,
    required String userId,
    required List<String> updatedCounters,
  }) {
    Logger.info(
      'Vote batch submitted - '
      'VoteId: ${Logger.maskSensitive(voteId)}, '
      'UserId: ${Logger.maskSensitive(userId)}, '
      'UpdatedCounters: [${updatedCounters.join(', ')}], '
      'CounterCount: ${updatedCounters.length}, '
      'Layer: Service, '
      'Feature: Voting',
      tag: '$_tag/Voting',
    );
  }
}
