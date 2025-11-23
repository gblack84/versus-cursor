import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/widgets/debug/providers/guard_analytics_providers.dart';
import '/app/router/analytics/guard_analytics_event.dart';

/// **Guard Analytics Tab (Phase 5 - Day 3 Complete)**
///
/// Route Guard 실행 이벤트를 실시간으로 표시하는 터미널 스타일 UI
///
/// ## UI 구조 (2-Section Layout):
///
/// ```
/// ┌─────────────────────────────────────┐
/// │ Statistics Section (Fixed Top)      │
/// │ ├─ Total Checks: 150                │
/// │ ├─ Blocked: 45 (30.0%)              │
/// │ └─ Allowed: 105 (70.0%)             │
/// ├─────────────────────────────────────┤
/// │ Recent Events (Scrollable)          │
/// │ 🔴 BLOCKED /admin → /startPage       │
/// │ 🟢 ALLOWED /home (public_route)      │
/// │ 🔴 BLOCKED /profile → /startPage     │
/// │ ...                                 │
/// └─────────────────────────────────────┘
/// ```
///
/// ## Features:
///
/// - **Real-time Stream**: Firestore snapshots() auto-update
/// - **Statistics**: guardStatsProvider (auto-refresh on new events)
/// - **Terminal UI**: Black background, green text, monospace font
/// - **Emoji Indicators**: 🔴 BLOCKED / 🟢 ALLOWED
/// - **Timestamp**: [HH:MM:SS] format
/// - **Empty State**: Friendly message when no events
///
/// ## Riverpod Integration:
///
/// - `guardEventsProvider`: Stream<List<GuardAnalyticsEvent>>
/// - `guardStatsProvider`: Future<GuardAnalyticsStats>
/// - `ConsumerWidget`: Auto-rebuild on data changes
/// - `AsyncValue.when()`: Loading/Error/Data state handling
class GuardAnalyticsTab extends ConsumerWidget {
  const GuardAnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch statistics (auto-refreshes when events update)
    final statsAsync = ref.watch(guardStatsProvider);

    // Watch real-time events stream
    final eventsAsync = ref.watch(guardEventsProvider);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Statistics Section (Fixed Top)
          _buildStatisticsSection(statsAsync),

          // Divider
          const Divider(
            color: Colors.greenAccent,
            thickness: 2,
            height: 2,
          ),

          // Events List (Scrollable)
          Expanded(
            child: _buildEventsSection(eventsAsync),
          ),
        ],
      ),
    );
  }

  /// Statistics Section - Fixed at top
  ///
  /// Displays aggregated guard analytics:
  /// - Total Checks
  /// - Blocked Count + Percentage
  /// - Allowed Count + Percentage
  Widget _buildStatisticsSection(AsyncValue<GuardAnalyticsStats> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: statsAsync.when(
        data: (stats) => _buildStatsContent(stats),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading stats: $error',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  /// Statistics Content
  Widget _buildStatsContent(GuardAnalyticsStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.greenAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Guard Analytics Statistics',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Checks
        _buildStatRow(
          'Total Checks:',
          '${stats.totalChecks}',
          Colors.greenAccent,
        ),

        const SizedBox(height: 4),

        // Blocked Count + Percentage
        _buildStatRow(
          'Blocked:',
          '${stats.blockedCount} (${stats.blockPercentage.toStringAsFixed(1)}%)',
          Colors.red,
        ),

        const SizedBox(height: 4),

        // Allowed Count + Percentage
        _buildStatRow(
          'Allowed:',
          '${stats.allowedCount} (${stats.allowPercentage.toStringAsFixed(1)}%)',
          Colors.green,
        ),
      ],
    );
  }

  /// Single Stat Row
  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Events List Section - Scrollable
  ///
  /// Real-time stream of guard events:
  /// - Newest first (timestamp DESC)
  /// - Terminal-style log lines
  /// - 🔴 BLOCKED / 🟢 ALLOWED emojis
  Widget _buildEventsSection(
    AsyncValue<List<GuardAnalyticsEvent>> eventsAsync,
  ) {
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyState();
        }
        return _buildEventsList(events);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading events:\n$error',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Events List Content
  Widget _buildEventsList(List<GuardAnalyticsEvent> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableText(
            event.terminalLogLine,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: event.result == GuardResult.blocked
                  ? Colors.red.shade300
                  : Colors.green.shade300,
            ),
          ),
        );
      },
    );
  }

  /// Empty State - No events yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.security,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Guard Events Yet',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Navigate to protected routes to generate events',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 How to generate events:',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Sign out (if logged in)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '2. Try accessing protected routes',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '3. Watch events appear here in real-time',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
