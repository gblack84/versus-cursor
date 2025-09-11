/// Migration Logger for Phase 1.1
///
/// Tracks model conversion and data access patterns during migration
/// Helps monitor the transition from legacy to new models
///
/// Created: 2025-01-08

import 'package:flutter/foundation.dart';

class MigrationLogger {
  static final MigrationLogger _instance = MigrationLogger._internal();
  factory MigrationLogger() => _instance;
  MigrationLogger._internal();

  // Statistics tracking
  final Map<String, int> _conversionCounts = {};
  final Map<String, Duration> _conversionTimes = {};
  final List<MigrationEvent> _events = [];

  // Configuration
  bool isEnabled = kDebugMode; // Only log in debug mode by default
  bool logToConsole = true;
  bool trackPerformance = true;
  int maxEventHistory = 1000;

  /// Log a model conversion event
  void logConversion({
    required String from,
    required String to,
    String? feature,
    Map<String, dynamic>? metadata,
  }) {
    if (!isEnabled) return;

    final event = MigrationEvent(
      type: MigrationEventType.conversion,
      from: from,
      to: to,
      feature: feature,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _recordEvent(event);
    _incrementCount('conversion_${from}_to_$to');

    if (logToConsole) {
      debugPrint(
          '[Migration] Converting $from → $to${feature != null ? ' in $feature' : ''}');
    }
  }

  /// Log a data access event
  void logDataAccess({
    required String model,
    required String method,
    String? feature,
    bool isLegacy = false,
  }) {
    if (!isEnabled) return;

    final path = isLegacy ? 'legacy' : 'new';
    final event = MigrationEvent(
      type: MigrationEventType.dataAccess,
      from: '$path/$model',
      to: method,
      feature: feature,
      timestamp: DateTime.now(),
    );

    _recordEvent(event);
    _incrementCount('${path}_${model}_$method');

    if (logToConsole && isLegacy) {
      debugPrint('[Migration] ⚠️ Legacy access: $model.$method');
    }
  }

  /// Track performance of a conversion
  Future<T> trackConversion<T>({
    required String operation,
    required Future<T> Function() task,
  }) async {
    if (!isEnabled || !trackPerformance) {
      return await task();
    }

    final stopwatch = Stopwatch()..start();
    try {
      final result = await task();
      stopwatch.stop();

      _conversionTimes[operation] = stopwatch.elapsed;

      if (logToConsole && stopwatch.elapsed.inMilliseconds > 100) {
        debugPrint(
            '[Migration] ⚠️ Slow conversion: $operation took ${stopwatch.elapsed.inMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      logError(
        operation: operation,
        error: e.toString(),
        duration: stopwatch.elapsed,
      );
      rethrow;
    }
  }

  /// Log an error during migration
  void logError({
    required String operation,
    required String error,
    Duration? duration,
    Map<String, dynamic>? context,
  }) {
    if (!isEnabled) return;

    final event = MigrationEvent(
      type: MigrationEventType.error,
      from: operation,
      to: 'error',
      timestamp: DateTime.now(),
      metadata: {
        'error': error,
        if (duration != null) 'duration_ms': duration.inMilliseconds,
        if (context != null) ...context,
      },
    );

    _recordEvent(event);
    _incrementCount('errors_$operation');

    if (logToConsole) {
      debugPrint('[Migration] ❌ Error in $operation: $error');
    }
  }

  /// Get migration statistics
  Map<String, dynamic> getStatistics() {
    final totalConversions = _conversionCounts.entries
        .where((e) => e.key.startsWith('conversion_'))
        .fold<int>(0, (sum, e) => sum + e.value);

    final legacyAccess = _conversionCounts.entries
        .where((e) => e.key.startsWith('legacy_'))
        .fold<int>(0, (sum, e) => sum + e.value);

    final newAccess = _conversionCounts.entries
        .where((e) => e.key.startsWith('new_'))
        .fold<int>(0, (sum, e) => sum + e.value);

    final errors = _conversionCounts.entries
        .where((e) => e.key.startsWith('errors_'))
        .fold<int>(0, (sum, e) => sum + e.value);

    final avgConversionTime = _conversionTimes.isEmpty
        ? Duration.zero
        : _conversionTimes.values.reduce((a, b) => a + b) ~/
            _conversionTimes.length;

    return {
      'totalConversions': totalConversions,
      'legacyAccessCount': legacyAccess,
      'newAccessCount': newAccess,
      'errorCount': errors,
      'avgConversionTimeMs': avgConversionTime.inMilliseconds,
      'conversionCounts': Map.from(_conversionCounts),
      'performanceMetrics': _conversionTimes.map(
        (k, v) => MapEntry(k, v.inMilliseconds),
      ),
      'migrationProgress': _calculateMigrationProgress(),
    };
  }

  /// Calculate migration progress percentage
  double _calculateMigrationProgress() {
    final total = _conversionCounts.entries
        .where((e) => e.key.startsWith('legacy_') || e.key.startsWith('new_'))
        .fold<int>(0, (sum, e) => sum + e.value);

    if (total == 0) return 0.0;

    final newCount = _conversionCounts.entries
        .where((e) => e.key.startsWith('new_'))
        .fold<int>(0, (sum, e) => sum + e.value);

    return (newCount / total) * 100;
  }

  /// Clear all statistics
  void clearStatistics() {
    _conversionCounts.clear();
    _conversionTimes.clear();
    _events.clear();
  }

  /// Get recent events
  List<MigrationEvent> getRecentEvents({int limit = 100}) {
    final start = _events.length > limit ? _events.length - limit : 0;
    return _events.sublist(start);
  }

  // Private helper methods
  void _recordEvent(MigrationEvent event) {
    _events.add(event);

    // Trim history if needed
    if (_events.length > maxEventHistory) {
      _events.removeRange(0, _events.length - maxEventHistory);
    }
  }

  void _incrementCount(String key) {
    _conversionCounts[key] = (_conversionCounts[key] ?? 0) + 1;
  }

  /// Print a summary report
  void printSummaryReport() {
    if (!isEnabled) return;

    final stats = getStatistics();
    debugPrint('''
╔════════════════════════════════════════════════════════════╗
║                  Migration Summary Report                  ║
╠════════════════════════════════════════════════════════════╣
║ Total Conversions:     ${stats['totalConversions'].toString().padLeft(10)}              ║
║ Legacy Access Count:   ${stats['legacyAccessCount'].toString().padLeft(10)}              ║
║ New Model Access:      ${stats['newAccessCount'].toString().padLeft(10)}              ║
║ Error Count:           ${stats['errorCount'].toString().padLeft(10)}              ║
║ Avg Conversion Time:   ${stats['avgConversionTimeMs'].toString().padLeft(7)} ms            ║
║ Migration Progress:    ${stats['migrationProgress'].toStringAsFixed(1).padLeft(6)}%               ║
╚════════════════════════════════════════════════════════════╝
''');
  }
}

/// Migration event types
enum MigrationEventType {
  conversion,
  dataAccess,
  error,
}

/// Migration event data
class MigrationEvent {
  final MigrationEventType type;
  final String from;
  final String to;
  final String? feature;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MigrationEvent({
    required this.type,
    required this.from,
    required this.to,
    this.feature,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'from': from,
        'to': to,
        if (feature != null) 'feature': feature,
        'timestamp': timestamp.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };
}
