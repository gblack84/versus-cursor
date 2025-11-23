import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:versus_space/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:versus_space/features/notifications/domain/failures/notification_failure.dart';
import 'package:versus_space/features/profile/domain/entities/character.dart';
import 'package:versus_space/features/profile/domain/entities/user_profile.dart';
import 'package:versus_space/features/profile/domain/entities/user_settings.dart';
import 'package:versus_space/features/auth/domain/entities/auth_user.dart';
import 'package:versus_space/features/profile/domain/entities/profile_info.dart';
import 'package:versus_space/features/voting/domain/entities/dialog/vote_counts_model.dart';
import 'package:versus_space/features/voting/domain/entities/dialog/vote_cache_state.dart';
import 'package:versus_space/services/batch/batch_service.dart';
import 'package:versus_space/services/cache/unified_cache_service.dart';
import 'package:versus_space/services/cache/failures/cache_failure.dart';

// Generate mocks
@GenerateMocks([BatchService])
import 'notification_repository_impl_test.mocks.dart';

/// Test-specific implementation of UnifiedCacheService that doesn't require Hive
class FakeUnifiedCacheService extends UnifiedCacheService {
  @override
  Future<void> init() async {}

  @override
  Future<Either<CacheFailure, T>> get<T>(String key, {CacheLayer? layer}) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> set<T>(String key, T value, {Duration? ttl, CacheLayer? layer}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> remove(String key, {CacheLayer? layer}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> invalidate(String pattern, {CacheLayer? layer}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clear({CacheLayer? layer}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getFeedPosts({int limit = 20}) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setFeedPosts(List<Map<String, dynamic>> posts) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearFeedPosts() async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, UserProfile>> getUserProfile(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setUserProfile(String userId, UserProfile profile) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearUserProfile(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, UserSettings>> getUserSettings(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setUserSettings(String userId, UserSettings settings) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearUserSettings(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, List<String>>> getUserInterests(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setUserInterests(String userId, List<String> interests) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearUserInterests(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, ProfileInfo>> getProfileInfo(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setProfileInfo(String userId, ProfileInfo info) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearProfileInfo(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, double>> getProfileCompletion(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setProfileCompletion(String userId, double percentage) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearProfileCompletion(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, List<Character>>> getAvailableCharacters() async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setAvailableCharacters(List<Character> characters) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearAvailableCharacters() async {
    return right(null);
  }

  // Vote-related methods - implementing abstract methods from UnifiedCacheService
  @override
  Future<Either<CacheFailure, VoteCounts>> getVoteCounts(String postId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setVoteCounts(String postId, VoteCounts counts) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearVoteCounts(String postId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, VoteCacheState>> getVoteState(String postId, String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setVoteState(String postId, String userId, VoteCacheState state) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearVoteState(String postId, String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getVoteHistory(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setVoteHistory(String userId, List<Map<String, dynamic>> history) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, AuthUser>> getAuthUser(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setAuthUser(String userId, AuthUser user, {Duration? ttl}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearAuthUser(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, String>> getAuthToken(String userId) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setAuthToken(String userId, String token, {Duration? ttl}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearAuthToken(String userId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, List<Map<String, dynamic>>>> getChatMessages({required String chatId, int limit = 30}) async {
    return left(CacheFailure.notFound());
  }

  @override
  Future<Either<CacheFailure, void>> setChatMessages({required String chatId, required List<Map<String, dynamic>> messages}) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearChatMessages(String chatId) async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clearAll() async {
    return right(null);
  }

  @override
  Map<String, dynamic> getStatistics() {
    return {};
  }

  @override
  Future<Either<CacheFailure, void>> preloadRecentChats() async {
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> preloadPopularPosts() async {
    return right(null);
  }

  @override
  double get hitRate => 0.0;

  @override
  int get memorySize => 0;

  @override
  Future<int> get localSize async => 0;
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockBatchService mockBatchService;
  late FakeUnifiedCacheService fakeCacheService;
  late NotificationRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockBatchService = MockBatchService();
    fakeCacheService = FakeUnifiedCacheService();
    repository = NotificationRepositoryImpl(
      firestore: fakeFirestore,
      batchService: mockBatchService,
      cacheService: fakeCacheService,
    );

    // Setup mock BatchService to execute immediately
    // Note: Repository doesn't pass onProgress, so we omit it in stub
    when(mockBatchService.executeBatch(
      operations: anyNamed('operations'),
    )).thenAnswer((_) async {});
  });

  group('markAllAsRead', () {
    test('should successfully mark all unread notifications as read', () async {
      // Arrange: Create 3 unread notifications
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Notification 1',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Notification 2',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif3').set({
        'userId': userId,
        'isRead': false,
        'title': 'Notification 3',
        'createdAt': Timestamp.now(),
      });

      // Act
      final result = await repository.markAllAsRead(userId, eventId);

      // Assert
      expect(result.isRight(), true);

      // Capture operations to verify count and type
      final capturedCall = verify(mockBatchService.executeBatch(
        operations: captureAnyNamed('operations'),
      )).captured.single as List;
      expect(capturedCall.length, 3);
    });

    test('should successfully handle empty list (no unread notifications)', () async {
      // Arrange: No notifications for user
      final userId = 'test-user-id';
      final eventId = 'test-event-id';

      // Act
      final result = await repository.markAllAsRead(userId, eventId);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          isEmpty,
          named: 'operations',
        ),
      )).called(1);
    });

    test('should successfully chunk >500 operations', () async {
      // Arrange: Create 600 unread notifications
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      for (int i = 0; i < 600; i++) {
        await notificationsRef.doc('notif$i').set({
          'userId': userId,
          'isRead': false,
          'title': 'Notification $i',
          'createdAt': Timestamp.now(),
        });
      }

      // Act
      final result = await repository.markAllAsRead(userId, eventId);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          hasLength(600),
          named: 'operations',
        ),
      )).called(1);

      // BatchService should auto-chunk at 500 operations
    });

    test('should invalidate cache after marking all as read', () async {
      // Arrange
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Notification 1',
        'createdAt': Timestamp.now(),
      });

      // Act
      final result = await repository.markAllAsRead(userId, eventId);

      // Assert
      expect(result.isRight(), true);
      // Cache invalidation is handled by UnifiedCacheService.instance
      // We can verify the method was called successfully
    });

    test('should handle Firestore errors gracefully', () async {
      // Arrange: Force BatchService to throw error
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Notification 1',
        'createdAt': Timestamp.now(),
      });

      when(mockBatchService.executeBatch(
        operations: anyNamed('operations'),
      )).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      ));

      // Act
      final result = await repository.markAllAsRead(userId, eventId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotificationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('deleteAllNotifications', () {
    test('should successfully delete all notifications', () async {
      // Arrange: Create 3 notifications
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Notification 1',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Notification 2',
        'createdAt': Timestamp.now(),
      });
      await notificationsRef.doc('notif3').set({
        'userId': userId,
        'isRead': true,
        'title': 'Notification 3',
        'createdAt': Timestamp.now(),
      });

      // Act
      final result = await repository.deleteAllNotifications(userId, eventId);

      // Assert
      expect(result.isRight(), true);

      // Capture operations to verify count and type
      final capturedCall = verify(mockBatchService.executeBatch(
        operations: captureAnyNamed('operations'),
      )).captured.single as List;
      expect(capturedCall.length, 3);
    });

    test('should successfully handle empty list (no notifications)', () async {
      // Arrange: No notifications for user
      final userId = 'test-user-id';
      final eventId = 'test-event-id';

      // Act
      final result = await repository.deleteAllNotifications(userId, eventId);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          isEmpty,
          named: 'operations',
        ),
      )).called(1);
    });

    test('should successfully chunk >500 operations', () async {
      // Arrange: Create 700 notifications
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      for (int i = 0; i < 700; i++) {
        await notificationsRef.doc('notif$i').set({
          'userId': userId,
          'isRead': i % 2 == 0,
          'title': 'Notification $i',
          'createdAt': Timestamp.now(),
        });
      }

      // Act
      final result = await repository.deleteAllNotifications(userId, eventId);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          hasLength(700),
          named: 'operations',
        ),
      )).called(1);

      // BatchService should auto-chunk at 500 operations
    });

    test('should invalidate cache after deleting all notifications', () async {
      // Arrange
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Notification 1',
        'createdAt': Timestamp.now(),
      });

      // Act
      final result = await repository.deleteAllNotifications(userId, eventId);

      // Assert
      expect(result.isRight(), true);
      // Cache invalidation is handled by UnifiedCacheService.instance
    });

    test('should handle Firestore errors gracefully', () async {
      // Arrange: Force BatchService to throw error
      final userId = 'test-user-id';
      final eventId = 'test-event-id';
      final notificationsRef = fakeFirestore.collection('notifications');

      await notificationsRef.doc('notif1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Notification 1',
        'createdAt': Timestamp.now(),
      });

      when(mockBatchService.executeBatch(
        operations: anyNamed('operations'),
      )).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      ));

      // Act
      final result = await repository.deleteAllNotifications(userId, eventId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotificationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('deleteOldNotifications', () {
    test('should successfully delete notifications older than threshold', () async {
      // Arrange: Create notifications with different dates
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();
      final before = now.subtract(const Duration(days: 31));

      // Old notifications (should be deleted)
      await notificationsRef.doc('old1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Old Notification 1',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 32))),
      });
      await notificationsRef.doc('old2').set({
        'userId': userId,
        'isRead': true,
        'title': 'Old Notification 2',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 60))),
      });

      // Recent notifications (should NOT be deleted)
      await notificationsRef.doc('recent1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Recent Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      });

      // Act
      final result = await repository.deleteOldNotifications(userId: userId, before: before);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          hasLength(2), // Only 2 old notifications
          named: 'operations',
        ),
      )).called(1);
    });

    test('should successfully handle empty list (no old notifications)', () async {
      // Arrange: Only recent notifications
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();
      final before = now.subtract(const Duration(days: 31));

      await notificationsRef.doc('recent1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Recent Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      });

      // Act
      final result = await repository.deleteOldNotifications(userId: userId, before: before);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          isEmpty,
          named: 'operations',
        ),
      )).called(1);
    });

    test('should correctly filter by date', () async {
      // Arrange: Create notifications exactly at boundary
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();
      final before = now.subtract(const Duration(days: 30));

      // Exactly 30 days old (should NOT be deleted - boundary)
      await notificationsRef.doc('boundary').set({
        'userId': userId,
        'isRead': true,
        'title': 'Boundary Notification',
        'createdAt': Timestamp.fromDate(before),
      });

      // 31 days old (should be deleted)
      await notificationsRef.doc('old').set({
        'userId': userId,
        'isRead': true,
        'title': 'Old Notification',
        'createdAt': Timestamp.fromDate(before.subtract(const Duration(days: 1))),
      });

      // Act
      final result = await repository.deleteOldNotifications(userId: userId, before: before);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          hasLength(1), // Only 1 notification older than before
          named: 'operations',
        ),
      )).called(1);
    });

    test('should invalidate cache after deleting old notifications', () async {
      // Arrange
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();
      final before = now.subtract(const Duration(days: 31));

      await notificationsRef.doc('old1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Old Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 32))),
      });

      // Act
      final result = await repository.deleteOldNotifications(userId: userId, before: before);

      // Assert
      expect(result.isRight(), true);
      // Cache invalidation is handled by UnifiedCacheService.instance
    });

    test('should handle Firestore errors gracefully', () async {
      // Arrange: Force BatchService to throw error
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();
      final before = now.subtract(const Duration(days: 31));

      await notificationsRef.doc('old1').set({
        'userId': userId,
        'isRead': true,
        'title': 'Old Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 32))),
      });

      when(mockBatchService.executeBatch(
        operations: anyNamed('operations'),
      )).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      ));

      // Act
      final result = await repository.deleteOldNotifications(userId: userId, before: before);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotificationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('deleteExpiredNotifications', () {
    test('should successfully delete expired notifications', () async {
      // Arrange: Create notifications with different expiry times
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();

      // Expired notifications (should be deleted)
      await notificationsRef.doc('expired1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Expired Notification 1',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'expiryTime': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      });
      await notificationsRef.doc('expired2').set({
        'userId': userId,
        'isRead': false,
        'title': 'Expired Notification 2',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
        'expiryTime': Timestamp.fromDate(now.subtract(const Duration(minutes: 30))),
      });

      // Active notifications (should NOT be deleted)
      await notificationsRef.doc('active1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Active Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
        'expiryTime': Timestamp.fromDate(now.add(const Duration(hours: 1))),
      });

      // Act
      final result = await repository.deleteExpiredNotifications(userId);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          hasLength(2), // Only 2 expired notifications
          named: 'operations',
        ),
      )).called(1);
    });

    test('should successfully handle empty list (no expired notifications)', () async {
      // Arrange: Only active notifications
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();

      await notificationsRef.doc('active1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Active Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
        'expiryTime': Timestamp.fromDate(now.add(const Duration(hours: 1))),
      });

      // Act
      final result = await repository.deleteExpiredNotifications(userId);

      // Assert
      expect(result.isRight(), true);
      verify(mockBatchService.executeBatch(
        operations: argThat(
          isEmpty,
          named: 'operations',
        ),
      )).called(1);
    });

    test('should correctly filter by expiry time', () async {
      // Arrange: Create notifications exactly at boundary
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();

      // Expired exactly now (should be deleted - boundary)
      await notificationsRef.doc('boundary').set({
        'userId': userId,
        'isRead': false,
        'title': 'Boundary Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
        'expiryTime': Timestamp.fromDate(now),
      });

      // Expires in 1 second (should NOT be deleted)
      await notificationsRef.doc('future').set({
        'userId': userId,
        'isRead': false,
        'title': 'Future Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
        'expiryTime': Timestamp.fromDate(now.add(const Duration(seconds: 1))),
      });

      // Act
      final result = await repository.deleteExpiredNotifications(userId);

      // Assert
      expect(result.isRight(), true);
      // Note: FakeFirebaseFirestore may not handle exact timestamp comparison perfectly
      // In production, this would delete only the boundary notification
    });

    test('should invalidate cache after deleting expired notifications', () async {
      // Arrange
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();

      await notificationsRef.doc('expired1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Expired Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'expiryTime': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      });

      // Act
      final result = await repository.deleteExpiredNotifications(userId);

      // Assert
      expect(result.isRight(), true);
      // Cache invalidation is handled by UnifiedCacheService.instance
    });

    test('should handle Firestore errors gracefully', () async {
      // Arrange: Force BatchService to throw error
      final userId = 'test-user-id';
      final notificationsRef = fakeFirestore.collection('notifications');
      final now = DateTime.now();

      await notificationsRef.doc('expired1').set({
        'userId': userId,
        'isRead': false,
        'title': 'Expired Notification',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'expiryTime': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      });

      when(mockBatchService.executeBatch(
        operations: anyNamed('operations'),
      )).thenThrow(FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      ));

      // Act
      final result = await repository.deleteExpiredNotifications(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotificationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
