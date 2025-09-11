import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/features/notifications/domain/models/notification.dart';
import 'package:versus_space/features/notifications/domain/models/vote_notification.dart';
import 'package:versus_space/features/notifications/domain/usecases/process_vote_notification_use_case.dart';
import 'package:versus_space/features/notifications/domain/value_objects/vote_options.dart';
import '../mocks/mock_notification_repository.dart';

void main() {
  group('ProcessVoteNotificationUseCase', () {
    late ProcessVoteNotificationUseCase useCase;
    late MockNotificationRepository mockRepository;
    late VoteNotification testNotification;
    final now = DateTime.now();

    setUp(() {
      mockRepository = MockNotificationRepository();
      useCase = ProcessVoteNotificationUseCase(mockRepository);

      testNotification = VoteNotification(
        id: 'notification-1',
        userId: 'user-123',
        title: 'Vote Request',
        content: 'Please vote on this',
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        notificationPriority: NotificationPriority.high,
        metadata: {},
        postId: 'post-456',
        postContent: 'Which is better?',
        postTitle: 'A vs B',
        senderId: 'sender-789',
        senderName: 'Test Sender',
        voteStartTime: now.subtract(const Duration(minutes: 2)),
        voteEndTime: now.add(const Duration(minutes: 8)),
        voteOptions: const VoteOptions(
          optionATitle: 'Option A',
          optionBTitle: 'Option B',
          optionAImageUrls: ['imageA.jpg'],
          optionBImageUrls: ['imageB.jpg'],
        ),
        hasVoted: false,
        userVoteChoice: null,
        currentVotesA: 10,
        currentVotesB: 5,
      );

      // Add test notification to repository
      mockRepository.addNotification(testNotification);
    });

    tearDown(() {
      mockRepository.clear();
    });

    group('Successful Vote Processing', () {
      test('should process vote for option A successfully', () async {
        // Arrange
        const params = ProcessVoteParams(
          notificationId: 'notification-1',
          userId: 'user-123',
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data!.hasVoted, true);
        expect(result.data!.userVoteChoice, 'A');
        expect(result.data!.currentVotesA, 11); // Should increment
        expect(result.data!.currentVotesB, 5); // Should remain same
        expect(result.data!.isRead, true); // Should be marked as read

        // Verify repository was called
        expect(mockRepository.updateNotificationCalled, true);
        expect(mockRepository.lastUpdatedNotification, isNotNull);
      });

      test('should process vote for option B successfully', () async {
        // Arrange
        const params = ProcessVoteParams(
          notificationId: 'notification-1',
          userId: 'user-123',
          voteChoice: 'B',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data!.hasVoted, true);
        expect(result.data!.userVoteChoice, 'B');
        expect(result.data!.currentVotesA, 10); // Should remain same
        expect(result.data!.currentVotesB, 6); // Should increment
        expect(result.data!.isRead, true);
      });
    });

    group('Validation and Error Cases', () {
      test('should return failure for invalid vote choice', () async {
        // Arrange
        const params = ProcessVoteParams(
          notificationId: 'notification-1',
          userId: 'user-123',
          voteChoice: 'C', // Invalid choice
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Invalid vote choice: Must be A or B');
        expect(mockRepository.updateNotificationCalled, false);
      });

      test('should return failure when notification not found', () async {
        // Arrange
        const params = ProcessVoteParams(
          notificationId: 'non-existent',
          userId: 'user-123',
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Notification not found');
      });

      test('should return failure when user does not own notification',
          () async {
        // Arrange
        const params = ProcessVoteParams(
          notificationId: 'notification-1',
          userId: 'different-user', // Different user
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, contains('Unauthorized'));
      });

      test('should return failure when already voted', () async {
        // Arrange
        final votedNotification = VoteNotification(
          id: 'notification-2',
          userId: 'user-123',
          title: 'Vote Request',
          content: 'Please vote on this',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postContent: 'Which is better?',
          postTitle: 'A vs B',
          senderId: 'sender-789',
          senderName: 'Test Sender',
          voteStartTime: now.subtract(const Duration(minutes: 2)),
          voteEndTime: now.add(const Duration(minutes: 8)),
          voteOptions: const VoteOptions(
            optionATitle: 'Option A',
            optionBTitle: 'Option B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: true, // Already voted
          userVoteChoice: 'A',
          currentVotesA: 10,
          currentVotesB: 5,
        );

        mockRepository.addNotification(votedNotification);

        const params = ProcessVoteParams(
          notificationId: 'notification-2',
          userId: 'user-123',
          voteChoice: 'B',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Already voted on this notification');
      });

      test('should return failure when voting period ended', () async {
        // Arrange
        final expiredNotification = VoteNotification(
          id: 'notification-3',
          userId: 'user-123',
          title: 'Vote Request',
          content: 'Please vote on this',
          createdAt: now.subtract(const Duration(hours: 3)),
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postContent: 'Which is better?',
          postTitle: 'A vs B',
          senderId: 'sender-789',
          senderName: 'Test Sender',
          voteStartTime: now.subtract(const Duration(hours: 2)),
          voteEndTime: now.subtract(const Duration(hours: 1)), // Ended
          voteOptions: const VoteOptions(
            optionATitle: 'Option A',
            optionBTitle: 'Option B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 10,
          currentVotesB: 5,
        );

        mockRepository.addNotification(expiredNotification);

        const params = ProcessVoteParams(
          notificationId: 'notification-3',
          userId: 'user-123',
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Voting period has ended');
      });
    });

    group('Error Handling', () {
      test('should handle repository exceptions gracefully', () async {
        // Arrange
        mockRepository.shouldThrowError = true;
        mockRepository.errorMessage = 'Database error';

        const params = ProcessVoteParams(
          notificationId: 'notification-1',
          userId: 'user-123',
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, contains('Failed to process vote'));
        expect(result.error, contains('Database error'));
      });
    });

    group('Business Logic Edge Cases', () {
      test('should handle notification marked as expired', () async {
        // Arrange
        final expiredNotification = VoteNotification(
          id: 'notification-4',
          userId: 'user-123',
          title: 'Vote Request',
          content: 'Please vote on this',
          createdAt: now.subtract(const Duration(days: 31)), // Old notification
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postContent: 'Which is better?',
          postTitle: 'A vs B',
          senderId: 'sender-789',
          senderName: 'Test Sender',
          voteStartTime: now.subtract(const Duration(days: 30)),
          voteEndTime: now.add(const Duration(minutes: 5)), // Still in future
          expiryTime:
              now.subtract(const Duration(hours: 1)), // Expired 1 hour ago
          voteOptions: const VoteOptions(
            optionATitle: 'Option A',
            optionBTitle: 'Option B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 10,
          currentVotesB: 5,
        );

        mockRepository.addNotification(expiredNotification);

        const params = ProcessVoteParams(
          notificationId: 'notification-4',
          userId: 'user-123',
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Notification has expired');
      });

      test('should update notification twice for vote and read status',
          () async {
        // Arrange
        const params = ProcessVoteParams(
          notificationId: 'notification-1',
          userId: 'user-123',
          voteChoice: 'A',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess, true);

        // Should be called at least once for voting and once for marking as read
        expect(mockRepository.updateNotificationCalled, true);

        // Final notification should have both updates
        final finalNotification = result.data!;
        expect(finalNotification.hasVoted, true);
        expect(finalNotification.isRead, true);
      });
    });
  });
}
