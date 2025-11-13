// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard_analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(guardEvents)
const guardEventsProvider = GuardEventsProvider._();

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

final class GuardEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GuardAnalyticsEvent>>,
          List<GuardAnalyticsEvent>,
          Stream<List<GuardAnalyticsEvent>>
        >
    with
        $FutureModifier<List<GuardAnalyticsEvent>>,
        $StreamProvider<List<GuardAnalyticsEvent>> {
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
  const GuardEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guardEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guardEventsHash();

  @$internal
  @override
  $StreamProviderElement<List<GuardAnalyticsEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GuardAnalyticsEvent>> create(Ref ref) {
    return guardEvents(ref);
  }
}

String _$guardEventsHash() => r'5d732ee70446ab5a29e5dc0f84dd7bdadb6bc498';

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

@ProviderFor(guardStats)
const guardStatsProvider = GuardStatsProvider._();

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

final class GuardStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<GuardAnalyticsStats>,
          GuardAnalyticsStats,
          FutureOr<GuardAnalyticsStats>
        >
    with
        $FutureModifier<GuardAnalyticsStats>,
        $FutureProvider<GuardAnalyticsStats> {
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
  const GuardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guardStatsHash();

  @$internal
  @override
  $FutureProviderElement<GuardAnalyticsStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GuardAnalyticsStats> create(Ref ref) {
    return guardStats(ref);
  }
}

String _$guardStatsHash() => r'f01cadb6e135e31f52b742a20a9992e3e4eee401';

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

@ProviderFor(guardEventsByResult)
const guardEventsByResultProvider = GuardEventsByResultFamily._();

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

final class GuardEventsByResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GuardAnalyticsEvent>>,
          List<GuardAnalyticsEvent>,
          FutureOr<List<GuardAnalyticsEvent>>
        >
    with
        $FutureModifier<List<GuardAnalyticsEvent>>,
        $FutureProvider<List<GuardAnalyticsEvent>> {
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
  const GuardEventsByResultProvider._({
    required GuardEventsByResultFamily super.from,
    required GuardResult super.argument,
  }) : super(
         retry: null,
         name: r'guardEventsByResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guardEventsByResultHash();

  @override
  String toString() {
    return r'guardEventsByResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GuardAnalyticsEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GuardAnalyticsEvent>> create(Ref ref) {
    final argument = this.argument as GuardResult;
    return guardEventsByResult(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GuardEventsByResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guardEventsByResultHash() =>
    r'946e84a82fa7d2a8e5d01d8394d86b55f5869198';

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

final class GuardEventsByResultFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<GuardAnalyticsEvent>>,
          GuardResult
        > {
  const GuardEventsByResultFamily._()
    : super(
        retry: null,
        name: r'guardEventsByResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  GuardEventsByResultProvider call(GuardResult result) =>
      GuardEventsByResultProvider._(argument: result, from: this);

  @override
  String toString() => r'guardEventsByResultProvider';
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

@ProviderFor(guardEventsByUser)
const guardEventsByUserProvider = GuardEventsByUserFamily._();

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

final class GuardEventsByUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GuardAnalyticsEvent>>,
          List<GuardAnalyticsEvent>,
          FutureOr<List<GuardAnalyticsEvent>>
        >
    with
        $FutureModifier<List<GuardAnalyticsEvent>>,
        $FutureProvider<List<GuardAnalyticsEvent>> {
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
  const GuardEventsByUserProvider._({
    required GuardEventsByUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'guardEventsByUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guardEventsByUserHash();

  @override
  String toString() {
    return r'guardEventsByUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GuardAnalyticsEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GuardAnalyticsEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return guardEventsByUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GuardEventsByUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guardEventsByUserHash() => r'880954aa2b34713986198673bc25bd9bf9fcca47';

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

final class GuardEventsByUserFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<GuardAnalyticsEvent>>, String> {
  const GuardEventsByUserFamily._()
    : super(
        retry: null,
        name: r'guardEventsByUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  GuardEventsByUserProvider call(String userId) =>
      GuardEventsByUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'guardEventsByUserProvider';
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

@ProviderFor(clearGuardEvents)
const clearGuardEventsProvider = ClearGuardEventsProvider._();

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

final class ClearGuardEventsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
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
  const ClearGuardEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearGuardEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearGuardEventsHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return clearGuardEvents(ref);
  }
}

String _$clearGuardEventsHash() => r'4ea25195921649f5fcf6945431de84d7267a3909';
