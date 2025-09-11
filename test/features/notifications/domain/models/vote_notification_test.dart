import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/features/notifications/domain/models/notification.dart';
import 'package:versus_space/features/notifications/domain/models/vote_notification.dart';
import 'package:versus_space/features/notifications/domain/value_objects/vote_options.dart';

void main() {
  group('VoteNotification', () {
    late VoteNotification notification;
    final now = DateTime.now();

    setUp(() {
      notification = VoteNotification(
        id: 'test-id',
        userId: 'user-123',
        title: 'Test Vote',
        body: 'Choose your option',
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        notificationPriority: NotificationPriority.high,
        metadata: {'source': 'test'},
        postId: 'post-456',
        postTitle: 'Which is better?',
        senderId: 'sender-789',
        senderName: 'Test User',
        voteStartTime: now.subtract(const Duration(minutes: 2)),
        voteEndTime: now.add(const Duration(minutes: 8)),
        voteOptions: const VoteOptions(
          optionATitle: 'Option A',
          optionBTitle: 'Option B',
          optionAImageUrls: ['imageA1.jpg'],
          optionBImageUrls: ['imageB1.jpg'],
        ),
        hasVoted: false,
        userVoteChoice: null,
        currentVotesA: 10,
        currentVotesB: 5,
      );
    });

    group('Constructor', () {
      test('should create valid VoteNotification instance', () {
        expect(notification.id, 'test-id');
        expect(notification.userId, 'user-123');
        expect(notification.type, NotificationType.votingRequest);
        expect(notification.postId, 'post-456');
      });

      test('should have correct type automatically set', () {
        expect(notification.type, NotificationType.votingRequest);
      });
    });

    group('Business Logic - Vote Status', () {
      test('isVoteActive should return true when within voting period', () {
        expect(notification.isVoteActive, true);
      });

      test('isVoteActive should return false when before start time', () {
        final futureVote = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now.add(const Duration(hours: 1)),
          voteEndTime: now.add(const Duration(hours: 2)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 0,
          currentVotesB: 0,
        );

        expect(futureVote.isVoteActive, false);
      });

      test('isVoteActive should return false when after end time', () {
        final expiredVote = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now.subtract(const Duration(hours: 3)),
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now.subtract(const Duration(hours: 2)),
          voteEndTime: now.subtract(const Duration(hours: 1)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 0,
          currentVotesB: 0,
        );

        expect(expiredVote.isVoteActive, false);
      });
    });

    group('Business Logic - User Vote Status', () {
      test('canUserVote should return true when not voted and vote is active',
          () {
        expect(notification.canUserVote, true);
      });

      test('canUserVote should return false when already voted', () {
        final votedNotification = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now.subtract(const Duration(minutes: 2)),
          voteEndTime: now.add(const Duration(minutes: 8)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: true,
          userVoteChoice: 'A',
          currentVotesA: 10,
          currentVotesB: 5,
        );

        expect(votedNotification.canUserVote, false);
      });
    });

    group('Business Logic - Remaining Time', () {
      test('remainingTime should return correct duration', () {
        final remaining = notification.remainingTime;
        expect(remaining, isNotNull);
        expect(remaining!.inMinutes, lessThanOrEqualTo(8));
        expect(remaining.inMinutes, greaterThan(7));
      });

      test('remainingTime should return null when vote ended', () {
        final expiredVote = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now.subtract(const Duration(hours: 3)),
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now.subtract(const Duration(hours: 2)),
          voteEndTime: now.subtract(const Duration(hours: 1)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 0,
          currentVotesB: 0,
        );

        expect(expiredVote.remainingTime, isNull);
      });
    });

    group('Business Logic - Vote Percentages', () {
      test('votesPercentage should calculate correctly', () {
        final percentages = notification.votesPercentage;
        expect(percentages['A'], closeTo(66.67, 0.01));
        expect(percentages['B'], closeTo(33.33, 0.01));
      });

      test('votesPercentage should handle zero votes', () {
        final noVotes = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.high,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now.subtract(const Duration(minutes: 2)),
          voteEndTime: now.add(const Duration(minutes: 8)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 0,
          currentVotesB: 0,
        );

        final percentages = noVotes.votesPercentage;
        expect(percentages['A'], 50.0);
        expect(percentages['B'], 50.0);
      });
    });

    group('Business Logic - Record Vote', () {
      test('recordUserVote should update vote state correctly', () {
        final updatedNotification = notification.recordUserVote('A');

        expect(updatedNotification.hasVoted, true);
        expect(updatedNotification.userVoteChoice, 'A');
        expect(updatedNotification.votesA, 11);
        expect(updatedNotification.votesB, 5);
      });

      test('recordUserVote should update votesB when choosing B', () {
        final updatedNotification = notification.recordUserVote('B');

        expect(updatedNotification.hasVoted, true);
        expect(updatedNotification.userVoteChoice, 'B');
        expect(updatedNotification.votesA, 10);
        expect(updatedNotification.votesB, 6);
      });
    });

    group('Edge Cases', () {
      test('should handle null metadata gracefully', () {
        final minimalNotification = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.medium,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now,
          voteEndTime: now.add(const Duration(minutes: 10)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 0,
          currentVotesB: 0,
        );

        expect(minimalNotification.metadata, isNotNull);
        expect(minimalNotification.metadata, isEmpty);
      });

      test('should handle empty image URLs in VoteOptions', () {
        expect(notification.optionA.imageUrls.length, 1);
        expect(notification.optionB.imageUrls.length, 1);

        final noImages = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.medium,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now,
          voteEndTime: now.add(const Duration(minutes: 10)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 0,
          currentVotesB: 0,
        );

        expect(noImages.optionA.imageUrls, isEmpty);
        expect(noImages.optionB.imageUrls, isEmpty);
      });

      test('should handle very large vote counts', () {
        final largeVotes = VoteNotification(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Vote',
          body: 'Choose your option',
          createdAt: now,
          isRead: false,
          notificationPriority: NotificationPriority.medium,
          metadata: {},
          postId: 'post-456',
          postTitle: 'Which is better?',
          senderId: 'sender-789',
          senderName: 'Test User',
          voteStartTime: now,
          voteEndTime: now.add(const Duration(minutes: 10)),
          voteOptions: const VoteOptions(
            optionATitle: 'A',
            optionBTitle: 'B',
            optionAImageUrls: [],
            optionBImageUrls: [],
          ),
          hasVoted: false,
          userVoteChoice: null,
          currentVotesA: 999999,
          currentVotesB: 1,
        );

        final percentages = largeVotes.votesPercentage;
        expect(percentages['A'], closeTo(99.9999, 0.0001));
        expect(percentages['B'], closeTo(0.0001, 0.0001));
      });
    });
  });
}
