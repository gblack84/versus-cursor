import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/services/analytics/guard_analytics_service.dart';
import '/services/analytics/guard_analytics_event.dart';

part 'guard_analytics_providers.g.dart';

/// **Guard Analytics Providers - Riverpod 3.x**
///
/// Providers for Guard Analytics debugging UI in DebugLogPage.
///
/// ## Providers:
///
/// ### 1. guardEventsProvider
/// - **Type**: StreamProvider
/// - **Data**: List<GuardAnalyticsEvent>
/// - **Source**: Firestore real-time stream (ordered by timestamp DESC)
/// - **Limit**: 100 most recent events
/// - **Auto-Dispose**: Yes (when tab not active)
///
/// **Usage**:
/// ```dart
/// final eventsAsync = ref.watch(guardEventsProvider);
/// eventsAsync.when(
///   data: (events) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error: error),
/// );
/// ```
///
/// ### 2. guardStatsProvider
/// - **Type**: FutureProvider
/// - **Data**: GuardAnalyticsStats
/// - **Source**: Firestore aggregation (all events)
/// - **Refresh**: Auto-refresh when guardEventsProvider updates
/// - **Auto-Dispose**: Yes
///
/// **Usage**:
/// ```dart
/// final statsAsync = ref.watch(guardStatsProvider);
/// statsAsync.when(
///   data: (stats) => Text('Total: ${stats.totalChecks}'),
///   loading: () => Skeleton(),
///   error: (error, stack) => Text('Error loading stats'),
/// );
/// ```
///
/// ## Architecture Pattern:
///
/// ```
/// GuardAnalyticsService (Singleton)
///         ↓
/// guardEventsProvider (Stream<List<Event>>)
///         ↓
/// guardStatsProvider (Future<Stats>) ← Auto-refresh on events update
///         ↓
/// GuardAnalyticsTab UI
/// ```

/// Guard Events Stream Provider
///
/// **Real-time Firestore stream** of guard execution events.
///
/// - **Ordering**: Newest first (timestamp DESC)
/// - **Limit**: 100 most recent events
/// - **Auto-Dispose**: Stream closes when tab inactive
/// - **Error Handling**: Returns empty list on error
///
/// **Firestore Collection**: `guard_analytics`
///
/// **Query**:
/// ```dart
/// _firestore.collection('guard_analytics')
///   .orderBy('timestamp', descending: true)
///   .limit(100)
///   .snapshots()
/// ```
@riverpod
Stream<List<GuardAnalyticsEvent>> guardEvents(Ref ref) {
  final service = GuardAnalyticsService();

  // Watch recent 100 events with real-time updates
  return service.watchRecentEvents(limit: 100);
}

/// Guard Statistics Provider
///
/// **Aggregated statistics** across all guard events.
///
/// - **Total Checks**: Count of all events
/// - **Blocked**: Count where result == 'blocked'
/// - **Allowed**: Count where result == 'allowed'
/// - **Percentages**: Auto-calculated in GuardAnalyticsStats
///
/// **Auto-Refresh Strategy**:
/// - Listens to guardEventsProvider updates
/// - Invalidates stats when new events arrive
/// - Avoids excessive Firestore reads
///
/// **Performance Note**: For large datasets (>10K events),
/// consider pre-aggregated stats in separate Firestore document
/// updated via Cloud Function triggers.
@riverpod
Future<GuardAnalyticsStats> guardStats(Ref ref) async {
  // Listen to events stream to auto-invalidate stats
  // when new events arrive
  ref.watch(guardEventsProvider);

  final service = GuardAnalyticsService();
  return service.getStats();
}

/// Guard Events Filtered by Result
///
/// **Optional Provider** for filtering events by result type.
///
/// - **Parameters**: GuardResult (blocked or allowed)
/// - **Use Case**: Separate tabs or filters for blocked/allowed events
///
/// **Usage**:
/// ```dart
/// // Get only blocked events
/// final blockedAsync = ref.watch(
///   guardEventsByResultProvider(GuardResult.blocked),
/// );
/// ```
@riverpod
Future<List<GuardAnalyticsEvent>> guardEventsByResult(
  Ref ref,
  GuardResult result,
) async {
  final service = GuardAnalyticsService();
  return service.getEventsByResult(result, limit: 100);
}

/// Guard Events Filtered by User ID
///
/// **Optional Provider** for filtering events by specific user.
///
/// - **Parameters**: userId (String)
/// - **Use Case**: User-specific guard event history
///
/// **Usage**:
/// ```dart
/// // Get events for specific user
/// final userEventsAsync = ref.watch(
///   guardEventsByUserProvider('user123'),
/// );
/// ```
@riverpod
Future<List<GuardAnalyticsEvent>> guardEventsByUser(
  Ref ref,
  String userId,
) async {
  final service = GuardAnalyticsService();
  return service.getEventsByUser(userId, limit: 100);
}

/// Clear All Guard Events (Admin Action)
///
/// **Warning**: Destructive operation - deletes all analytics events.
///
/// - **Use Case**: Admin panel, debug cleanup
/// - **Firestore**: Batch delete all documents in guard_analytics
///
/// **Usage**:
/// ```dart
/// // In admin panel
/// await ref.read(clearGuardEventsProvider.future);
/// ```
@riverpod
Future<void> clearGuardEvents(Ref ref) async {
  final service = GuardAnalyticsService();
  await service.clearAllEvents();

  // Invalidate providers to refresh UI
  ref.invalidate(guardEventsProvider);
  ref.invalidate(guardStatsProvider);
}
