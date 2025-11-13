import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'guard_analytics_event.freezed.dart';
part 'guard_analytics_event.g.dart';

/// Guard Analytics - Route guard execution result
///
/// **Values**:
/// - `blocked`: Authentication required but user not logged in
/// - `allowed`: User authenticated or route doesn't require auth
enum GuardResult {
  blocked,
  allowed;

  String toValue() => name;

  static GuardResult fromValue(String value) {
    return GuardResult.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GuardResult.blocked,
    );
  }
}

/// Guard Analytics Event Entity
///
/// **Firestore Document Structure**:
/// ```json
/// {
///   "eventId": "uuid-v4",
///   "timestamp": Timestamp,
///   "attemptedPath": "/admin",
///   "redirectPath": "/startPage",
///   "result": "blocked",
///   "userId": "user123",
///   "reason": "auth_required"
/// }
/// ```
///
/// **Usage**:
/// ```dart
/// final event = GuardAnalyticsEvent(
///   eventId: Uuid().v4(),
///   timestamp: DateTime.now(),
///   attemptedPath: '/profile/edit',
///   redirectPath: '/startPage',
///   result: GuardResult.blocked,
///   userId: null,
///   reason: 'auth_required',
/// );
///
/// // Save to Firestore
/// await FirebaseFirestore.instance
///   .collection('guard_analytics')
///   .doc(event.eventId)
///   .set(event.toFirestore());
/// ```
@freezed
sealed class GuardAnalyticsEvent with _$GuardAnalyticsEvent {
  const GuardAnalyticsEvent._();

  const factory GuardAnalyticsEvent({
    /// Unique event identifier (UUID v4)
    required String eventId,

    /// Event timestamp (server time)
    required DateTime timestamp,

    /// Path user attempted to access
    required String attemptedPath,

    /// Path user was redirected to (null if allowed)
    String? redirectPath,

    /// Guard execution result
    required GuardResult result,

    /// User ID if authenticated (null if not logged in)
    String? userId,

    /// Reason for block/allow (e.g., "auth_required", "public_route")
    required String reason,
  }) = _GuardAnalyticsEvent;

  /// Create from JSON (for local caching)
  factory GuardAnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      _$GuardAnalyticsEventFromJson(json);

  /// Create from Firestore DocumentSnapshot
  ///
  /// **Extension Pattern**: Direct Firestore → Entity conversion
  static GuardAnalyticsEvent fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return GuardAnalyticsEvent(
      eventId: doc.id,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attemptedPath: data['attemptedPath'] as String? ?? '',
      redirectPath: data['redirectPath'] as String?,
      result: GuardResult.fromValue(data['result'] as String? ?? 'blocked'),
      userId: data['userId'] as String?,
      reason: data['reason'] as String? ?? '',
    );
  }

  /// Convert to Firestore document data
  ///
  /// **Extension Pattern**: Entity → Firestore conversion
  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'attemptedPath': attemptedPath,
      'redirectPath': redirectPath,
      'result': result.toValue(),
      'userId': userId,
      'reason': reason,
    };
  }

  /// Display-friendly result emoji
  String get resultEmoji => result == GuardResult.blocked ? '🔴' : '🟢';

  /// Display-friendly result text
  String get resultText =>
      result == GuardResult.blocked ? 'BLOCKED' : 'ALLOWED';

  /// Terminal-style log line
  ///
  /// **Format**: `🔴 BLOCKED /admin → /startPage (auth_required) [2025-11-10 14:30:45]`
  String get terminalLogLine {
    final formattedTime = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';

    final redirect = redirectPath != null ? ' → $redirectPath' : '';
    final user = userId != null ? ' [$userId]' : '';

    return '$resultEmoji $resultText $attemptedPath$redirect ($reason)$user [$formattedTime]';
  }
}

/// Guard Analytics Statistics
///
/// **Aggregated Metrics**:
/// - Total checks (all guard executions)
/// - Blocked count (auth required but not logged in)
/// - Allowed count (successful access)
/// - Block percentage
///
/// **Usage**:
/// ```dart
/// final stats = GuardAnalyticsStats(
///   totalChecks: 150,
///   blockedCount: 45,
///   allowedCount: 105,
/// );
///
/// print('Block rate: ${stats.blockPercentage.toStringAsFixed(1)}%');
/// ```
@Freezed(fromJson: false, toJson: false)
sealed class GuardAnalyticsStats with _$GuardAnalyticsStats {
  const GuardAnalyticsStats._();

  const factory GuardAnalyticsStats({
    @Default(0) int totalChecks,
    @Default(0) int blockedCount,
    @Default(0) int allowedCount,
  }) = _GuardAnalyticsStats;

  /// Block percentage (0-100)
  double get blockPercentage =>
      totalChecks > 0 ? (blockedCount / totalChecks) * 100 : 0.0;

  /// Allow percentage (0-100)
  double get allowPercentage =>
      totalChecks > 0 ? (allowedCount / totalChecks) * 100 : 0.0;

  /// Terminal-style stats display
  ///
  /// **Format**:
  /// ```
  /// Total Checks: 150
  /// Blocked:      45 (30.0%)
  /// Allowed:      105 (70.0%)
  /// ```
  String get terminalDisplay {
    return '''
Total Checks: $totalChecks
Blocked:      $blockedCount (${blockPercentage.toStringAsFixed(1)}%)
Allowed:      $allowedCount (${allowPercentage.toStringAsFixed(1)}%)''';
  }
}
