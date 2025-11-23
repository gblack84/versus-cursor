import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/services/rate_limit/rate_limit_service.dart';

void main() {
  late RateLimitService service;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = RateLimitService(firestore: fakeFirestore);
  });

  group('RateLimitService - canPerformAction', () {
    const testUserId = 'test-user-123';

    test('should return true when no previous requests', () async {
      // Act
      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(canPerform, true);
    });

    test('should return true when within limit', () async {
      // Arrange - Record 1 request (limit is 3)
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Act
      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(canPerform, true);
    });

    test('should return false when limit exceeded', () async {
      // Arrange - Record 3 requests (limit is 3)
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Act
      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(canPerform, false);
    });

    test('should return true after time window expires', () async {
      // Arrange - Create entries from 2 hours ago (time window is 1 hour)
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));

      // Manually add old entries to Firestore
      await fakeFirestore.collection('rate_limits').add({
        'userId': testUserId,
        'action': 'sendSmsOtp',
        'timestamp': Timestamp.fromDate(twoHoursAgo),
      });
      await fakeFirestore.collection('rate_limits').add({
        'userId': testUserId,
        'action': 'sendSmsOtp',
        'timestamp': Timestamp.fromDate(twoHoursAgo),
      });
      await fakeFirestore.collection('rate_limits').add({
        'userId': testUserId,
        'action': 'sendSmsOtp',
        'timestamp': Timestamp.fromDate(twoHoursAgo),
      });

      // Act
      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(canPerform, true); // Old entries should be filtered out
    });

    test('should handle different action types independently', () async {
      // Arrange - Max out sendSmsOtp (3 requests)
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Act - Check different action
      final canPerformLogin = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.loginAttempt,
      );

      // Assert
      expect(canPerformLogin, true); // Different action, should be allowed
    });

    test('should handle different users independently', () async {
      // Arrange - Max out user1
      const user1 = 'user-1';
      const user2 = 'user-2';

      await service.recordAction(userId: user1, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: user1, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: user1, action: RateLimitAction.sendSmsOtp);

      // Act - Check user2
      final canPerformUser2 = await service.canPerformAction(
        userId: user2,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(canPerformUser2, true); // Different user, should be allowed
    });
  });

  group('RateLimitService - recordAction', () {
    const testUserId = 'test-user-123';

    test('should record action in cache', () async {
      // Act
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert - Check via canPerformAction
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);

      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      expect(canPerform, false); // 3 requests recorded, limit reached
    });

    test('should persist to Firestore', () async {
      // Act
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Wait a bit for fire-and-forget to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Check Firestore
      final snapshot = await fakeFirestore
          .collection('rate_limits')
          .where('userId', isEqualTo: testUserId)
          .where('action', isEqualTo: 'sendSmsOtp')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['userId'], testUserId);
      expect(snapshot.docs.first.data()['action'], 'sendSmsOtp');
    });
  });

  group('RateLimitService - getRemainingRequests', () {
    const testUserId = 'test-user-123';

    test('should return max requests when no previous requests', () async {
      // Act
      final remaining = await service.getRemainingRequests(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(remaining, 3); // sendSmsOtp limit is 3
    });

    test('should return correct remaining count', () async {
      // Arrange - Record 1 request
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Act
      final remaining = await service.getRemainingRequests(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(remaining, 2); // 3 - 1 = 2
    });

    test('should return 0 when limit exceeded', () async {
      // Arrange - Max out requests
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);

      // Act
      final remaining = await service.getRemainingRequests(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(remaining, 0);
    });

    test('should handle different action limits correctly', () async {
      // Act - Check loginAttempt (limit is 10)
      final remaining = await service.getRemainingRequests(
        userId: testUserId,
        action: RateLimitAction.loginAttempt,
      );

      // Assert
      expect(remaining, 10); // loginAttempt limit is 10
    });
  });

  group('RateLimitService - getTimeUntilNextRequest', () {
    const testUserId = 'test-user-123';

    test('should return null when user can perform action', () async {
      // Act
      final timeUntil = await service.getTimeUntilNextRequest(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(timeUntil, null);
    });

    test('should return null when within limit', () async {
      // Arrange - Record 1 request (within limit)
      await service.recordAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Act
      final timeUntil = await service.getTimeUntilNextRequest(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(timeUntil, null);
    });

    test('should return duration when limit exceeded', () async {
      // Arrange - Max out requests
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);

      // Act
      final timeUntil = await service.getTimeUntilNextRequest(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert
      expect(timeUntil, isNotNull);
      expect(timeUntil!.inMinutes, lessThanOrEqualTo(60)); // Within 1 hour time window
    });
  });

  group('RateLimitService - resetLimit', () {
    const testUserId = 'test-user-123';

    test('should clear cache for user and action', () async {
      // Arrange - Max out requests
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);

      // Verify limit exceeded
      final beforeReset = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      expect(beforeReset, false);

      // Act - Reset limit
      await service.resetLimit(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert - Should be able to perform action again
      final afterReset = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      expect(afterReset, true);
    });

    test('should clear Firestore entries for user and action', () async {
      // Arrange - Record actions
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);

      // Wait for Firestore persistence
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify entries exist
      final beforeReset = await fakeFirestore
          .collection('rate_limits')
          .where('userId', isEqualTo: testUserId)
          .where('action', isEqualTo: 'sendSmsOtp')
          .get();
      expect(beforeReset.docs.length, 2);

      // Act - Reset limit
      await service.resetLimit(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert - Firestore entries should be deleted
      final afterReset = await fakeFirestore
          .collection('rate_limits')
          .where('userId', isEqualTo: testUserId)
          .where('action', isEqualTo: 'sendSmsOtp')
          .get();
      expect(afterReset.docs.length, 0);
    });

    test('should only reset specified action, not others', () async {
      // Arrange - Record actions for multiple action types
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.loginAttempt);

      // Act - Reset only sendSmsOtp
      await service.resetLimit(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );

      // Assert - sendSmsOtp should be reset
      final canPerformOtp = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      expect(canPerformOtp, true);

      // loginAttempt should still have 1 request recorded
      final remainingLogin = await service.getRemainingRequests(
        userId: testUserId,
        action: RateLimitAction.loginAttempt,
      );
      expect(remainingLogin, 9); // 10 - 1 = 9
    });
  });

  group('RateLimitService - Action Types', () {
    const testUserId = 'test-user-123';

    test('sendSmsOtp: 3 requests per hour', () async {
      final config = RateLimitConfig.getConfig(RateLimitAction.sendSmsOtp);
      expect(config.maxRequests, 3);
      expect(config.timeWindow, const Duration(hours: 1));

      // Test limit
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);
      await service.recordAction(userId: testUserId, action: RateLimitAction.sendSmsOtp);

      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.sendSmsOtp,
      );
      expect(canPerform, false);
    });

    test('resetPassword: 5 requests per hour', () async {
      final config = RateLimitConfig.getConfig(RateLimitAction.resetPassword);
      expect(config.maxRequests, 5);
      expect(config.timeWindow, const Duration(hours: 1));

      // Test limit
      for (int i = 0; i < 5; i++) {
        await service.recordAction(userId: testUserId, action: RateLimitAction.resetPassword);
      }

      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.resetPassword,
      );
      expect(canPerform, false);
    });

    test('loginAttempt: 10 requests per 15 minutes', () async {
      final config = RateLimitConfig.getConfig(RateLimitAction.loginAttempt);
      expect(config.maxRequests, 10);
      expect(config.timeWindow, const Duration(minutes: 15));

      // Test limit
      for (int i = 0; i < 10; i++) {
        await service.recordAction(userId: testUserId, action: RateLimitAction.loginAttempt);
      }

      final canPerform = await service.canPerformAction(
        userId: testUserId,
        action: RateLimitAction.loginAttempt,
      );
      expect(canPerform, false);
    });

    test('phoneAuth: 5 requests per hour', () async {
      final config = RateLimitConfig.getConfig(RateLimitAction.phoneAuth);
      expect(config.maxRequests, 5);
      expect(config.timeWindow, const Duration(hours: 1));
    });

    test('emailVerification: 5 requests per hour', () async {
      final config = RateLimitConfig.getConfig(RateLimitAction.emailVerification);
      expect(config.maxRequests, 5);
      expect(config.timeWindow, const Duration(hours: 1));
    });
  });

  group('RateLimitService - RateLimitEntry', () {
    test('should convert to Firestore format correctly', () {
      // Arrange
      final now = DateTime.now();
      final entry = RateLimitEntry(
        userId: 'test-user',
        action: RateLimitAction.sendSmsOtp,
        timestamp: now,
      );

      // Act
      final firestore = entry.toFirestore();

      // Assert
      expect(firestore['userId'], 'test-user');
      expect(firestore['action'], 'sendSmsOtp');
      expect(firestore['timestamp'], isA<Timestamp>());
    });

    test('isWithinWindow should return true for recent entries', () {
      // Arrange
      final now = DateTime.now();
      final entry = RateLimitEntry(
        userId: 'test-user',
        action: RateLimitAction.sendSmsOtp,
        timestamp: now,
      );

      // Act
      final isWithin = entry.isWithinWindow(const Duration(hours: 1));

      // Assert
      expect(isWithin, true);
    });

    test('isWithinWindow should return false for old entries', () {
      // Arrange
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      final entry = RateLimitEntry(
        userId: 'test-user',
        action: RateLimitAction.sendSmsOtp,
        timestamp: twoHoursAgo,
      );

      // Act
      final isWithin = entry.isWithinWindow(const Duration(hours: 1));

      // Assert
      expect(isWithin, false);
    });
  });

  group('RateLimitService - RateLimitExceededException', () {
    test('should format message correctly without retryAfter', () {
      // Arrange
      final exception = RateLimitExceededException(
        message: 'Too many requests',
      );

      // Act
      final str = exception.toString();

      // Assert
      expect(str, 'RateLimitExceededException: Too many requests');
    });

    test('should format message correctly with retryAfter', () {
      // Arrange
      final exception = RateLimitExceededException(
        message: 'Too many requests',
        retryAfter: const Duration(seconds: 30),
      );

      // Act
      final str = exception.toString();

      // Assert
      expect(str, 'RateLimitExceededException: Too many requests (retry after 30s)');
    });
  });
}
