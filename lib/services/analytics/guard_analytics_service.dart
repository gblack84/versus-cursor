import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'guard_analytics_event.dart';

/// Guard Analytics Service - Route Guard Event Logging
///
/// **Purpose**: Track authentication guard execution for debugging and analytics
///
/// **Architecture**:
/// - Firestore collection: `guard_analytics`
/// - Append-only logs (no updates/deletes)
/// - Real-time streams for UI
/// - Automatic 30-day cleanup (via Firestore TTL or Cloud Function)
///
/// **Integration**:
/// ```dart
/// // In AuthGuard.checkAuth()
/// final analytics = GuardAnalyticsService();
/// await analytics.logGuardCheck(
///   attemptedPath: state.uri.toString(),
///   redirectPath: '/startPage',
///   result: GuardResult.blocked,
///   userId: null,
///   reason: 'auth_required',
/// );
/// ```
///
/// **UI Integration**:
/// ```dart
/// // In GuardAnalyticsTab
/// final eventsStream = ref.watch(guardEventsProvider);
/// final stats = ref.watch(guardStatsProvider);
/// ```
class GuardAnalyticsService {
  /// Singleton instance
  static final GuardAnalyticsService _instance = GuardAnalyticsService._();

  /// Factory constructor returns singleton
  factory GuardAnalyticsService() => _instance;

  /// Private constructor
  GuardAnalyticsService._();

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// UUID generator for event IDs
  final Uuid _uuid = const Uuid();

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('guard_analytics');

  /// Log a guard check event to Firestore
  ///
  /// **Parameters**:
  /// - `attemptedPath`: Route user tried to access
  /// - `redirectPath`: Where user was redirected (null if allowed)
  /// - `result`: GuardResult.blocked or GuardResult.allowed
  /// - `userId`: Current user ID (null if not authenticated)
  /// - `reason`: Human-readable reason (e.g., "auth_required", "public_route")
  ///
  /// **Firestore Write**: Append-only, no batching for simplicity
  ///
  /// **Usage**:
  /// ```dart
  /// // Blocked case
  /// await analytics.logGuardCheck(
  ///   attemptedPath: '/admin',
  ///   redirectPath: '/startPage',
  ///   result: GuardResult.blocked,
  ///   userId: null,
  ///   reason: 'auth_required',
  /// );
  ///
  /// // Allowed case
  /// await analytics.logGuardCheck(
  ///   attemptedPath: '/home',
  ///   redirectPath: null,
  ///   result: GuardResult.allowed,
  ///   userId: 'user123',
  ///   reason: 'authenticated',
  /// );
  /// ```
  Future<void> logGuardCheck({
    required String attemptedPath,
    String? redirectPath,
    required GuardResult result,
    String? userId,
    required String reason,
  }) async {
    try {
      final eventId = _uuid.v4();

      final event = GuardAnalyticsEvent(
        eventId: eventId,
        timestamp: DateTime.now(),
        attemptedPath: attemptedPath,
        redirectPath: redirectPath,
        result: result,
        userId: userId,
        reason: reason,
      );

      // Write to Firestore (fire-and-forget for performance)
      await _collection.doc(eventId).set(event.toFirestore());
    } catch (e) {
      // Silent fail - analytics should not break app functionality
      // Could add logging here if needed: Logger.error('Analytics logging failed: $e');
    }
  }

  /// Watch recent guard events (real-time stream)
  ///
  /// **Firestore Query**:
  /// - Order by timestamp descending
  /// - Limit to N most recent events (default 100)
  /// - Real-time updates via snapshots()
  ///
  /// **Usage**:
  /// ```dart
  /// @riverpod
  /// Stream<List<GuardAnalyticsEvent>> guardEvents(GuardEventsRef ref) {
  ///   final service = GuardAnalyticsService();
  ///   return service.watchRecentEvents(limit: 50);
  /// }
  /// ```
  ///
  /// **Returns**: Stream of events, newest first
  Stream<List<GuardAnalyticsEvent>> watchRecentEvents({int limit = 100}) {
    return _collection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
          .toList();
    });
  }

  /// Get aggregated statistics
  ///
  /// **Firestore Query**: Fetch all events (consider pagination for production)
  ///
  /// **Aggregation**:
  /// - Total checks: all documents
  /// - Blocked: result == 'blocked'
  /// - Allowed: result == 'allowed'
  ///
  /// **Usage**:
  /// ```dart
  /// @riverpod
  /// Future<GuardAnalyticsStats> guardStats(GuardStatsRef ref) async {
  ///   final service = GuardAnalyticsService();
  ///   return service.getStats();
  /// }
  /// ```
  ///
  /// **Performance Note**: For large datasets, consider pre-aggregated stats
  /// in a separate Firestore document updated via Cloud Function triggers
  Future<GuardAnalyticsStats> getStats() async {
    try {
      final snapshot = await _collection.get();

      int blockedCount = 0;
      int allowedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final result = data['result'] as String? ?? 'blocked';

        if (result == 'blocked') {
          blockedCount++;
        } else {
          allowedCount++;
        }
      }

      return GuardAnalyticsStats(
        totalChecks: snapshot.docs.length,
        blockedCount: blockedCount,
        allowedCount: allowedCount,
      );
    } catch (e) {
      // Return empty stats on error
      return const GuardAnalyticsStats();
    }
  }

  /// Clear all analytics events (admin only)
  ///
  /// **Firestore Batch Delete**: Delete all documents in collection
  ///
  /// **Usage**:
  /// ```dart
  /// // In admin panel or debug page
  /// await GuardAnalyticsService().clearAllEvents();
  /// ```
  ///
  /// **Warning**: This is a destructive operation
  Future<void> clearAllEvents() async {
    try {
      final snapshot = await _collection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      // Silent fail - clearing analytics is not critical
    }
  }

  /// Get events filtered by result type
  ///
  /// **Firestore Query**: Filter by result field
  ///
  /// **Usage**:
  /// ```dart
  /// // Get only blocked events
  /// final blockedEvents = await service.getEventsByResult(
  ///   GuardResult.blocked,
  ///   limit: 50,
  /// );
  /// ```
  Future<List<GuardAnalyticsEvent>> getEventsByResult(
    GuardResult result, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _collection
          .where('result', isEqualTo: result.toValue())
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get events for a specific user
  ///
  /// **Firestore Query**: Filter by userId field
  ///
  /// **Usage**:
  /// ```dart
  /// // Get all guard events for user
  /// final userEvents = await service.getEventsByUser(
  ///   'user123',
  ///   limit: 50,
  /// );
  /// ```
  Future<List<GuardAnalyticsEvent>> getEventsByUser(
    String userId, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
