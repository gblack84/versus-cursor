/// Rate Limit Service - Request frequency control
///
/// **Purpose**: Prevent brute force attacks and abuse by limiting request frequency
///
/// **Clean Architecture**:
/// - Service Layer (Infrastructure)
/// - Used by Domain Layer UseCases
/// - Firebase-Centric with in-memory caching
///
/// **Features**:
/// - Per-user, per-operation rate limiting
/// - Configurable time windows and limits
/// - In-memory cache for performance
/// - Optional Firestore backup for distributed systems
///
/// **Usage Example**:
/// ```dart
/// final rateLimitService = getIt<RateLimitService>();
///
/// // Check if user can perform operation
/// final canSendOtp = await rateLimitService.canPerformAction(
///   userId: userId,
///   action: RateLimitAction.sendSmsOtp,
/// );
///
/// if (!canSendOtp) {
///   return left(AuthFailure.tooManyRequests());
/// }
///
/// // Record the action
/// await rateLimitService.recordAction(
///   userId: userId,
///   action: RateLimitAction.sendSmsOtp,
/// );
/// ```

import 'package:cloud_firestore/cloud_firestore.dart';

/// Rate limit action types with their respective limits
enum RateLimitAction {
  /// SMS OTP sending: 3 requests per hour
  sendSmsOtp,

  /// Password reset: 5 requests per hour
  resetPassword,

  /// Login attempts: 10 requests per 15 minutes
  loginAttempt,

  /// Phone authentication: 5 requests per hour
  phoneAuth,

  /// Email verification: 5 requests per hour
  emailVerification,
}

/// Rate limit configuration for each action type
class RateLimitConfig {
  final int maxRequests;
  final Duration timeWindow;

  const RateLimitConfig({
    required this.maxRequests,
    required this.timeWindow,
  });

  /// Default configurations for each action type
  static const Map<RateLimitAction, RateLimitConfig> defaults = {
    RateLimitAction.sendSmsOtp: RateLimitConfig(
      maxRequests: 3,
      timeWindow: Duration(hours: 1),
    ),
    RateLimitAction.resetPassword: RateLimitConfig(
      maxRequests: 5,
      timeWindow: Duration(hours: 1),
    ),
    RateLimitAction.loginAttempt: RateLimitConfig(
      maxRequests: 10,
      timeWindow: Duration(minutes: 15),
    ),
    RateLimitAction.phoneAuth: RateLimitConfig(
      maxRequests: 5,
      timeWindow: Duration(hours: 1),
    ),
    RateLimitAction.emailVerification: RateLimitConfig(
      maxRequests: 5,
      timeWindow: Duration(hours: 1),
    ),
  };

  /// Get configuration for an action type
  static RateLimitConfig getConfig(RateLimitAction action) {
    return defaults[action]!;
  }
}

/// Rate limit tracking entry
class RateLimitEntry {
  final String userId;
  final RateLimitAction action;
  final DateTime timestamp;

  RateLimitEntry({
    required this.userId,
    required this.action,
    required this.timestamp,
  });

  /// Check if this entry is still within the time window
  bool isWithinWindow(Duration window) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff < window;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'action': action.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create from Firestore document
  static RateLimitEntry fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RateLimitEntry(
      userId: data['userId'] as String,
      action: RateLimitAction.values.firstWhere(
        (e) => e.name == data['action'],
        orElse: () => RateLimitAction.loginAttempt,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

/// Rate Limit Service implementation
class RateLimitService {
  final FirebaseFirestore _firestore;

  /// In-memory cache: key = "userId_actionName", value = list of timestamps
  final Map<String, List<DateTime>> _requestCache = {};

  RateLimitService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Check if user can perform the action
  ///
  /// **Returns**:
  /// - true: User can perform action (within rate limit)
  /// - false: Rate limit exceeded, reject the action
  ///
  /// **Note**: This method does NOT record the action. Call `recordAction()` after successful operation.
  Future<bool> canPerformAction({
    required String userId,
    required RateLimitAction action,
  }) async {
    final config = RateLimitConfig.getConfig(action);
    final key = _getCacheKey(userId, action);

    // Get timestamps from cache or Firestore
    List<DateTime> timestamps = await _getTimestamps(userId, action);

    // Filter out expired timestamps (outside time window)
    final now = DateTime.now();
    final validTimestamps = timestamps.where((timestamp) {
      final diff = now.difference(timestamp);
      return diff < config.timeWindow;
    }).toList();

    // Update cache
    _requestCache[key] = validTimestamps;

    // Check if within limit
    return validTimestamps.length < config.maxRequests;
  }

  /// Record an action after successful operation
  ///
  /// **Important**: Only call this AFTER the operation succeeds
  Future<void> recordAction({
    required String userId,
    required RateLimitAction action,
  }) async {
    final key = _getCacheKey(userId, action);
    final now = DateTime.now();

    // Update in-memory cache
    if (!_requestCache.containsKey(key)) {
      _requestCache[key] = [];
    }
    _requestCache[key]!.add(now);

    // Persist to Firestore (fire-and-forget for performance)
    _persistToFirestore(userId, action, now);
  }

  /// Get remaining requests for an action
  ///
  /// **Returns**: Number of remaining requests within the time window
  Future<int> getRemainingRequests({
    required String userId,
    required RateLimitAction action,
  }) async {
    final config = RateLimitConfig.getConfig(action);
    final timestamps = await _getTimestamps(userId, action);

    final now = DateTime.now();
    final validTimestamps = timestamps.where((timestamp) {
      final diff = now.difference(timestamp);
      return diff < config.timeWindow;
    }).length;

    return config.maxRequests - validTimestamps;
  }

  /// Get time until next request is allowed
  ///
  /// **Returns**: Duration until user can make another request, or null if allowed now
  Future<Duration?> getTimeUntilNextRequest({
    required String userId,
    required RateLimitAction action,
  }) async {
    final canPerform = await canPerformAction(userId: userId, action: action);
    if (canPerform) return null;

    final config = RateLimitConfig.getConfig(action);
    final timestamps = await _getTimestamps(userId, action);

    if (timestamps.isEmpty) return null;

    // Sort by oldest first
    timestamps.sort();

    // Time until oldest request expires
    final oldestTimestamp = timestamps.first;
    final now = DateTime.now();
    final expiryTime = oldestTimestamp.add(config.timeWindow);
    final diff = expiryTime.difference(now);

    return diff.isNegative ? null : diff;
  }

  /// Reset rate limit for a user and action (admin only)
  ///
  /// **Use cases**:
  /// - Customer support requests
  /// - Testing
  /// - Emergency situations
  Future<void> resetLimit({
    required String userId,
    required RateLimitAction action,
  }) async {
    final key = _getCacheKey(userId, action);

    // Clear cache
    _requestCache.remove(key);

    // Clear Firestore
    final query = _firestore
        .collection('rate_limits')
        .where('userId', isEqualTo: userId)
        .where('action', isEqualTo: action.name);

    final snapshot = await query.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Internal: Get cache key
  String _getCacheKey(String userId, RateLimitAction action) {
    return '${userId}_${action.name}';
  }

  /// Internal: Get timestamps from cache or Firestore
  Future<List<DateTime>> _getTimestamps(
    String userId,
    RateLimitAction action,
  ) async {
    final key = _getCacheKey(userId, action);

    // Try cache first
    if (_requestCache.containsKey(key)) {
      return _requestCache[key]!;
    }

    // Fallback to Firestore
    final config = RateLimitConfig.getConfig(action);
    final cutoffTime = DateTime.now().subtract(config.timeWindow);

    final query = _firestore
        .collection('rate_limits')
        .where('userId', isEqualTo: userId)
        .where('action', isEqualTo: action.name)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('timestamp', descending: true);

    final snapshot = await query.get();
    final timestamps = snapshot.docs
        .map((doc) => (doc.data()['timestamp'] as Timestamp).toDate())
        .toList();

    // Update cache
    _requestCache[key] = timestamps;

    return timestamps;
  }

  /// Internal: Persist to Firestore (fire-and-forget)
  void _persistToFirestore(
    String userId,
    RateLimitAction action,
    DateTime timestamp,
  ) {
    final entry = RateLimitEntry(
      userId: userId,
      action: action,
      timestamp: timestamp,
    );

    // Fire-and-forget pattern - errors are silently ignored
    // In-memory cache is the source of truth for rate limiting
    _firestore.collection('rate_limits').add(entry.toFirestore()).ignore();
  }

  /// Clean up old entries (should be called by Cloud Function)
  ///
  /// **Recommended**: Run as a scheduled Cloud Function (e.g., daily)
  Future<void> cleanupOldEntries() async {
    // Delete entries older than 24 hours
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    final query = _firestore
        .collection('rate_limits')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffTime));

    final snapshot = await query.get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

/// Rate limit exception
///
/// Thrown when rate limit is exceeded
class RateLimitExceededException implements Exception {
  final String message;
  final Duration? retryAfter;

  RateLimitExceededException({
    required this.message,
    this.retryAfter,
  });

  @override
  String toString() {
    if (retryAfter != null) {
      final seconds = retryAfter!.inSeconds;
      return 'RateLimitExceededException: $message (retry after ${seconds}s)';
    }
    return 'RateLimitExceededException: $message';
  }
}
