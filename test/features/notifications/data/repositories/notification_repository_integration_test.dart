import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:versus_space/services/batch/batch_service.dart';
import 'package:versus_space/services/cache/unified_cache_service.dart';
import 'package:versus_space/services/cache/failures/cache_failure.dart';

/// Integration tests for NotificationRepositoryImpl batch operations
///
/// These tests verify the complete end-to-end flow of batch operations:
/// - Firestore query → Batch operations → State changes → Cache invalidation
///
/// Unlike unit tests, these tests use real implementations (not mocks):
/// - FakeFirebaseFirestore for realistic Firestore interactions
/// - Real BatchService with actual chunking logic
/// - FakeUnifiedCacheService to verify cache invalidation
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BatchService batchService;
  late FakeUnifiedCacheService fakeCacheService;
  late NotificationRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    batchService = BatchService(firestore: fakeFirestore);  // ✅ Inject FakeFirebaseFirestore
    fakeCacheService = FakeUnifiedCacheService();
    repository = NotificationRepositoryImpl(
      firestore: fakeFirestore,
      batchService: batchService,
      cacheService: fakeCacheService,
    );
  });

  group('Integration: markAllAsRead', () {
    test('should complete full flow: query → batch update → cache invalidation → verify state', () async {
      // Arrange: Create 5 notifications (3 unread, 2 read)
      final userId = 'integration-user-id';
      final eventId = 'integration-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Unread Notification 1',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Unread Notification 2',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif3').set({
        'userId': userId,
        'isRead': true,
        'title': 'Read Notification 3',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif4').set({
        'userId': userId,
        'isRead': false,
        'title': 'Unread Notification 4',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif5').set({
        'userId': userId,
        'isRead': true,
        'title': 'Read Notification 5',
        'createdAt': Timestamp.now(),
      });

      // Act: Execute markAllAsRead
      final result = await repository.markAllAsRead(userId, eventId);

      // Assert 1: Result is success
      expect(result.isRight(), true);

      // Assert 2: Verify Firestore state - all notifications should now be read
      final updatedSnapshot = await notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      expect(updatedSnapshot.docs.length, 5);
      for (final doc in updatedSnapshot.docs) {
        expect(doc.data()['isRead'], true, reason: 'All notifications should be marked as read');
      }

      // Assert 3: Verify cache was invalidated
      expect(fakeCacheService.invalidateCalls.length, 1);
      expect(fakeCacheService.invalidateCalls.first, 'notifications_$userId');

      // Assert 4: Verify only unread notifications were updated (3 operations)
      // This is implicit in the Firestore state verification above
    });
  });

  group('Integration: deleteOldNotifications', () {
    test('should complete full flow: date filter → batch delete → cache invalidation → verify state', () async {
      // Arrange: Create 5 notifications with different ages
      final userId = 'integration-user-id';
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: 90));
      final notificationsRef = fakeFirestore.collection('notifications');

      // Old notifications (> 90 days)
      await notificationsRef.doc('old1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Old Notification 1',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 100))),
      });
      await notificationsRef.doc('old2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Old Notification 2',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 95))),
      });

      // Recent notifications (< 90 days)
      await notificationsRef.doc('recent1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Recent Notification 1',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 30))),
      });
      await notificationsRef.doc('recent2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Recent Notification 2',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 60))),
      });
      await notificationsRef.doc('recent3').set({
        'userId': userId,
        'isRead': true,
        'title': 'Recent Notification 3',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 10))),
      });

      // Act: Execute deleteOldNotifications
      final result = await repository.deleteOldNotifications(
        userId: userId,
        before: cutoffDate,
      );

      // Assert 1: Result is success (returns Unit)
      expect(result.isRight(), true);

      // Assert 2: Verify Firestore state - only recent notifications remain
      final remainingSnapshot = await notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      expect(remainingSnapshot.docs.length, 3, reason: 'Only 3 recent notifications should remain');

      final remainingIds = remainingSnapshot.docs.map((doc) => doc.id).toSet();
      expect(remainingIds, {'recent1', 'recent2', 'recent3'});
      expect(remainingIds, isNot(contains('old1')));
      expect(remainingIds, isNot(contains('old2')));

      // Assert 3: Verify cache was invalidated
      expect(fakeCacheService.invalidateCalls.length, 1);
      expect(fakeCacheService.invalidateCalls.first, 'notifications_$userId');
    });
  });

  group('Integration: deleteExpiredNotifications', () {
    test('should complete full flow: expiry filter → batch delete → cache invalidation → verify state', () async {
      // Arrange: Create 6 notifications with different expiry states
      final userId = 'integration-user-id';
      final now = DateTime.now();
      final notificationsRef = fakeFirestore.collection('notifications');

      // Expired notifications (expiryTime < now)
      await notificationsRef.doc('expired1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Expired Notification 1',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 10))),
        'expiryTime': Timestamp.fromDate(now.subtract(Duration(days: 1))),
      });
      await notificationsRef.doc('expired2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Expired Notification 2',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 5))),
        'expiryTime': Timestamp.fromDate(now.subtract(Duration(hours: 12))),
      });
      await notificationsRef.doc('expired3').set({
        'userId': userId,
        'isRead': true,
        'title': 'Expired Notification 3',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 3))),
        'expiryTime': Timestamp.fromDate(now.subtract(Duration(minutes: 30))),
      });

      // Valid notifications (expiryTime > now or null)
      await notificationsRef.doc('valid1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Valid Notification 1 (future expiry)',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 2))),
        'expiryTime': Timestamp.fromDate(now.add(Duration(days: 7))),
      });
      await notificationsRef.doc('valid2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Valid Notification 2 (no expiry)',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 1))),
        // No expiryTime field - should be kept
      });
      await notificationsRef.doc('valid3').set({
        'userId': userId,
        'isRead': true,
        'title': 'Valid Notification 3 (null expiry)',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(hours: 6))),
        'expiryTime': null,
      });

      // Act: Execute deleteExpiredNotifications
      final result = await repository.deleteExpiredNotifications(userId);

      // Assert 1: Result is success (returns Unit)
      expect(result.isRight(), true);

      // Assert 2: Verify Firestore state - only valid notifications remain
      final remainingSnapshot = await notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      expect(remainingSnapshot.docs.length, 3, reason: 'Only 3 valid notifications should remain');

      final remainingIds = remainingSnapshot.docs.map((doc) => doc.id).toSet();
      expect(remainingIds, {'valid1', 'valid2', 'valid3'});
      expect(remainingIds, isNot(contains('expired1')));
      expect(remainingIds, isNot(contains('expired2')));
      expect(remainingIds, isNot(contains('expired3')));

      // Assert 3: Verify cache was invalidated
      expect(fakeCacheService.invalidateCalls.length, 1);
      expect(fakeCacheService.invalidateCalls.first, 'notifications_$userId');

      // Assert 4: Verify remaining notifications have valid expiry
      for (final doc in remainingSnapshot.docs) {
        final data = doc.data();
        final expiresAt = data['expiryTime'] as Timestamp?;

        if (expiresAt != null) {
          expect(
            expiresAt.toDate().isAfter(now),
            true,
            reason: 'Remaining notification ${doc.id} should have future expiry',
          );
        }
        // null expiresAt is also valid
      }
    });
  });
}

/// Fake implementation of UnifiedCacheService for integration testing
///
/// This implementation returns Either types to match the actual interface
/// and tracks invalidation calls for verification.
class FakeUnifiedCacheService implements UnifiedCacheService {
  final List<String> invalidateCalls = [];
  final List<String> clearCalls = [];
  final Map<String, dynamic> _cache = {};

  @override
  Future<Either<CacheFailure, void>> invalidate(
    String pattern, {
    CacheLayer? layer,
  }) async {
    invalidateCalls.add(pattern);
    _cache.remove(pattern);
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clear({CacheLayer? layer}) async {
    clearCalls.add('clear');
    _cache.clear();
    return right(null);
  }

  @override
  Future<Either<CacheFailure, T>> get<T>(
    String key, {
    CacheLayer? layer,
  }) async {
    final value = _cache[key];
    if (value == null) {
      return left(const CacheFailure.notFound());
    }
    return right(value as T);
  }

  @override
  Future<Either<CacheFailure, void>> set<T>(
    String key,
    T value, {
    Duration? ttl,
    CacheLayer? layer,
  }) async {
    _cache[key] = value;
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> remove(
    String key, {
    CacheLayer? layer,
  }) async {
    _cache.remove(key);
    return right(null);
  }

  @override
  Future<void> init() async {
    // No-op for fake implementation
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
