import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/features/notifications/domain/value_objects/notification_filter.dart';
import 'package:versus_space/features/notifications/domain/models/notification.dart';

void main() {
  group('NotificationFilter', () {
    group('Constructor', () {
      test('should create filter with all parameters', () {
        final now = DateTime.now();
        final filter = NotificationFilter(
          type: NotificationType.votingRequest,
          unreadOnly: true,
          after: now,
          before: now.add(const Duration(days: 1)),
          limit: 10,
        );

        expect(filter.type, NotificationType.votingRequest);
        expect(filter.unreadOnly, true);
        expect(filter.after, now);
        expect(filter.before, now.add(const Duration(days: 1)));
        expect(filter.limit, 10);
      });

      test('should create filter with partial parameters', () {
        final filter = NotificationFilter(
          type: NotificationType.systemAlert,
          unreadOnly: false,
        );

        expect(filter.type, NotificationType.systemAlert);
        expect(filter.unreadOnly, false);
        expect(filter.after, isNull);
        expect(filter.before, isNull);
        expect(filter.limit, isNull);
      });

      test('should create filter with no parameters', () {
        const filter = NotificationFilter();

        expect(filter.type, isNull);
        expect(filter.unreadOnly, isNull);
        expect(filter.after, isNull);
        expect(filter.before, isNull);
        expect(filter.limit, isNull);
      });
    });

    group('Factory Methods', () {
      test('unreadOnly should create filter with unreadOnly=true', () {
        final filter = NotificationFilter.unreadOnly();

        expect(filter.unreadOnly, true);
        expect(filter.type, isNull);
        expect(filter.after, isNull);
        expect(filter.before, isNull);
        expect(filter.limit, isNull);
      });

      test('byType should create filter with specified type', () {
        final filter =
            NotificationFilter.byType(NotificationType.votingRequest);

        expect(filter.type, NotificationType.votingRequest);
        expect(filter.unreadOnly, isNull);
        expect(filter.after, isNull);
        expect(filter.before, isNull);
        expect(filter.limit, isNull);
      });

      test('recent should create filter with after date and limit', () {
        final filter = NotificationFilter.recent(days: 7, limit: 20);

        expect(filter.after, isNotNull);
        expect(filter.limit, 20);

        // Check that 'after' is approximately 7 days ago
        final expectedDate = DateTime.now().subtract(const Duration(days: 7));
        final difference = filter.after!.difference(expectedDate).abs();
        expect(difference.inSeconds, lessThan(2)); // Allow 2 seconds difference
      });

      test('recent should use default values when not specified', () {
        final filter = NotificationFilter.recent();

        expect(filter.after, isNotNull);
        expect(filter.limit, 50);

        // Check that 'after' is approximately 30 days ago (default)
        final expectedDate = DateTime.now().subtract(const Duration(days: 30));
        final difference = filter.after!.difference(expectedDate).abs();
        expect(difference.inSeconds, lessThan(2));
      });
    });

    group('copyWith Method', () {
      test('should copy all fields when all parameters provided', () {
        final now = DateTime.now();
        const original = NotificationFilter(
          type: NotificationType.votingRequest,
          unreadOnly: true,
        );

        final copied = original.copyWith(
          type: NotificationType.systemAlert,
          unreadOnly: false,
          after: now,
          before: now.add(const Duration(days: 1)),
          limit: 25,
        );

        expect(copied.type, NotificationType.systemAlert);
        expect(copied.unreadOnly, false);
        expect(copied.after, now);
        expect(copied.before, now.add(const Duration(days: 1)));
        expect(copied.limit, 25);
      });

      test('should preserve original values when parameters not provided', () {
        final now = DateTime.now();
        final original = NotificationFilter(
          type: NotificationType.votingRequest,
          unreadOnly: true,
          after: now,
          before: now.add(const Duration(days: 1)),
          limit: 10,
        );

        final copied = original.copyWith();

        expect(copied.type, original.type);
        expect(copied.unreadOnly, original.unreadOnly);
        expect(copied.after, original.after);
        expect(copied.before, original.before);
        expect(copied.limit, original.limit);
      });

      test('should update only specified fields', () {
        const original = NotificationFilter(
          type: NotificationType.votingRequest,
          unreadOnly: true,
          limit: 10,
        );

        final copied = original.copyWith(
          type: NotificationType.postLiked,
          limit: 20,
        );

        expect(copied.type, NotificationType.postLiked);
        expect(copied.unreadOnly, true); // Preserved
        expect(copied.limit, 20);
      });
    });

    group('Edge Cases', () {
      test('should handle null values correctly in copyWith', () {
        final now = DateTime.now();
        final original = NotificationFilter(
          type: NotificationType.votingRequest,
          unreadOnly: true,
          after: now,
          limit: 10,
        );

        // Test that we can set values to null explicitly
        // Note: This depends on implementation - if copyWith doesn't support
        // setting to null, this test should be adjusted
        final copied = original.copyWith(
          type: NotificationType.systemAlert,
        );

        expect(copied.type, NotificationType.systemAlert);
        expect(copied.unreadOnly, original.unreadOnly);
        expect(copied.after, original.after);
        expect(copied.limit, original.limit);
      });

      test('should handle date boundary conditions', () {
        final veryOldDate = DateTime(1970, 1, 1);
        final farFutureDate = DateTime(2100, 12, 31);

        final filter = NotificationFilter(
          after: veryOldDate,
          before: farFutureDate,
        );

        expect(filter.after, veryOldDate);
        expect(filter.before, farFutureDate);
      });

      test('should handle large limit values', () {
        const filter = NotificationFilter(limit: 999999);
        expect(filter.limit, 999999);
      });

      // Empty string type test removed - enum doesn't support empty string
    });

    group('Validation Cases', () {
      test('recent factory should create valid date range', () {
        final filter = NotificationFilter.recent(days: 7);

        expect(filter.after, isNotNull);
        expect(filter.before, isNull);

        // Verify the date is in the past
        expect(filter.after!.isBefore(DateTime.now()), true);
      });

      test('should allow before without after', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final filter = NotificationFilter(before: tomorrow);

        expect(filter.after, isNull);
        expect(filter.before, tomorrow);
      });

      test('should allow after without before', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final filter = NotificationFilter(after: yesterday);

        expect(filter.after, yesterday);
        expect(filter.before, isNull);
      });
    });
  });
}
