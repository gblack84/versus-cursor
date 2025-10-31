import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/notification.dart' as domain;
import '../../domain/usecases/mark_as_read_usecase.dart';
import '/services/notification/notification_queue_service.dart';
import '/core/utils/logger.dart';
import '/app/router/navigation/nav.dart';
import '/app/contracts/notification_types.dart';
import '/features/voting/domain/usecases/chat/submit_vote_use_case.dart';
import '/app/di.dart';

/// Notification Overlay Provider - Presentation Layer
///
/// Subscribes to NotificationQueueService stream and displays notifications as overlays.
/// Handles user interactions (vote, dismiss) and coordinates with business logic layer.
///
/// Clean Architecture: Presentation → Data (via Stream)
class NotificationOverlayProvider extends ChangeNotifier {
  final NotificationQueueService _queueService;
  final MarkAsReadUseCase _markAsRead;

  StreamSubscription<domain.Notification>? _subscription;
  bool _isInitialized = false;

  NotificationOverlayProvider({
    required NotificationQueueService queueService,
    required MarkAsReadUseCase markAsRead,
  })  : _queueService = queueService,
        _markAsRead = markAsRead;

  /// Start listening to notification stream
  void startListening() {
    if (_isInitialized) {
      Logger.warning('NotificationOverlayProvider already initialized',
          tag: 'NotificationOverlayProvider');
      return;
    }

    Logger.info('Starting notification overlay listener',
        tag: 'NotificationOverlayProvider');

    _subscription = _queueService.showNotificationStream.listen(
      (notification) => _handleNotification(notification),
      onError: (error) {
        Logger.error('Stream error', error: error, tag: 'NotificationOverlayProvider');
      },
    );

    _isInitialized = true;
  }

  /// Stop listening to notification stream
  void stopListening() {
    Logger.info('Stopping notification overlay listener',
        tag: 'NotificationOverlayProvider');

    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }

  /// Handle incoming notification from stream (using Freezed when pattern)
  void _handleNotification(domain.Notification notification) {
    Logger.debug('Received notification: ${notification.id}, type: ${notification.type}',
        tag: 'NotificationOverlayProvider');

    // Route to appropriate handler based on notification type using Freezed when pattern
    notification.when(
      social: (id, userId, type, title, content, createdAt, readAt, isRead,
              expiryTime, metadata, actionType, fromUserId, fromUserName,
              fromUserProfileUrl, relatedPostId, relatedCommentId,
              relatedContent, interactionCount) {
        _showSocialDialog(notification as domain.SocialNotification);
      },
      system: (id, userId, type, title, content, createdAt, readAt, isRead,
              expiryTime, metadata, alertType, actionUrl, actionLabel,
              actionButtons, iconUrl, isDismissible) {
        _showSystemDialog(notification as domain.SystemNotification);
      },
      voting: (id, userId, type, title, content, createdAt, readAt, isRead,
              expiryTime, metadata, postId, postTitle, postContent, postDescription,
              voteStartTime, voteEndTime, targetAudience, currentVotesA, currentVotesB,
              hasVoted, userVoteChoice, senderId, senderName, body, notificationPriority,
              imageUrlsA, imageUrlsB, aspectRatioA, aspectRatioB, layoutType) {
        // Check if it's a voting request notification
        if (type == NotificationTypes.votingRequest) {
          _showVotingDialog(notification);
        } else {
          Logger.warning('Unknown voting notification type: $type',
              tag: 'NotificationOverlayProvider');
          _queueService.notificationClosed();
        }
      },
    );
  }

  /// Show voting notification dialog
  /// Note: Accepts base Notification and delegates to Voting Feature via Port
  Future<void> _showVotingDialog(domain.Notification notification) async {
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      Logger.warning('No navigator context available - retrying in 5 seconds',
          tag: 'NotificationOverlayProvider');
      // Retry after delay
      Future.delayed(const Duration(seconds: 5), () {
        _showVotingDialog(notification);
      });
      return;
    }

    try {
      // Import voting notification dialog widget
      // This will be implemented in next step
      await _showVotingNotificationDialog(
        context: context,
        notification: notification,
        onVote: (selectedOption) async {
          await _handleVote(notification, selectedOption);
        },
        onDismiss: () async {
          await _handleDismiss(notification);
        },
      );
    } catch (e) {
      Logger.error('Error showing voting dialog', error: e,
          tag: 'NotificationOverlayProvider');
      _queueService.notificationClosed();
    }
  }

  /// Handle vote callback from voting feature
  /// Submits vote using SubmitVoteUseCase, then marks notification as read
  Future<void> _handleVote(
    domain.Notification notification,
    String selectedOption,
  ) async {
    Logger.info('Vote callback received: $selectedOption for notification ${notification.id}',
        tag: 'NotificationOverlayProvider');

    // Cast to VotingNotification to access postId
    final votingNotif = notification as domain.VotingNotification;

    // 1. Submit vote using SubmitVoteUseCase (Clean Architecture v4.0)
    final submitVote = getIt<SubmitVoteUseCase>();
    final voteResult = await submitVote(
      postId: votingNotif.postId,
      userId: notification.userId,
      voteOption: selectedOption,
    );

    // Handle vote submission result
    await voteResult.fold(
      (failure) async {
        // Show error toast for vote submission failure
        BotToast.showText(text: '투표 제출 실패');
        Logger.error('Error submitting vote',
            error: failure.toString(), tag: 'NotificationOverlayProvider');
        _queueService.notificationClosed();
      },
      (postVoting) async {
        Logger.info('Vote submitted successfully for post ${votingNotif.postId}',
            tag: 'NotificationOverlayProvider');

        // 2. Mark notification as read (Notification Feature responsibility)
        final markAsReadResult = await _markAsRead.call(MarkAsReadParams(
          notificationId: notification.id,
          userId: notification.userId,
        ));

        // Handle mark as read result
        markAsReadResult.fold(
          (failure) {
            // Show error toast to user
            BotToast.showText(text: failure.message);
            Logger.error('Error marking notification as read',
                error: failure.message, tag: 'NotificationOverlayProvider');
            _queueService.notificationClosed();
          },
          (_) {
            // Success: Signal queue service to process next notification (300ms delay)
            _queueService.notificationClosed(delayMilliseconds: 300);
          },
        );
      },
    );
  }

  /// Handle notification dismissal
  Future<void> _handleDismiss(domain.Notification notification) async {
    Logger.debug('Notification dismissed: ${notification.id}',
        tag: 'NotificationOverlayProvider');

    // Mark notification as read
    final result = await _markAsRead.call(MarkAsReadParams(
      notificationId: notification.id,
      userId: notification.userId,
    ));

    // Handle Result with fold pattern
    result.fold(
      (failure) {
        // Show error toast to user
        BotToast.showText(text: failure.message);
        Logger.error('Error marking notification as read',
            error: failure.message, tag: 'NotificationOverlayProvider');
        _queueService.notificationClosed();
      },
      (_) {
        // Success: Signal queue service to process next notification (500ms delay)
        _queueService.notificationClosed(delayMilliseconds: 500);
      },
    );
  }

  /// Show social notification dialog
  Future<void> _showSocialDialog(domain.SocialNotification notification) async {
    // TODO: Implement social notification dialog
    Logger.info('Social notification: ${notification.actionType}',
        tag: 'NotificationOverlayProvider');

    // For now, just mark as read and close
    await _handleDismiss(notification);
  }

  /// Show system notification dialog
  Future<void> _showSystemDialog(domain.SystemNotification notification) async {
    // TODO: Implement system notification dialog
    Logger.info('System notification: ${notification.alertType}',
        tag: 'NotificationOverlayProvider');

    // For now, just mark as read and close
    await _handleDismiss(notification);
  }

  /// Show voting notification dialog using Firebase + routing approach
  /// Note: Reads data directly from Firebase and routes to voting page
  Future<void> _showVotingNotificationDialog({
    required BuildContext context,
    required domain.Notification notification,
    required Future<void> Function(String) onVote,
    required Future<void> Function() onDismiss,
  }) async {
    try {
      // Cast to VotingNotification to access postId
      final votingNotif = notification as domain.VotingNotification;

      // 1. Read post data from Firebase
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(votingNotif.postId)
          .get();

      if (!postDoc.exists) {
        Logger.warning('Post not found: ${votingNotif.postId}',
            tag: 'NotificationOverlayProvider');
        await onDismiss();
        return;
      }

      final postData = postDoc.data()!;
      final question = postData['question'] as String? ?? '질문 없음';

      // 2. Show simple dialog with routing
      final shouldNavigate = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('투표 요청'),
          content: Text(question),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('투표하러 가기'),
            ),
          ],
        ),
      );

      // 3. Route to voting page if user confirmed
      if (shouldNavigate == true) {
        // Navigate to chat page where voting happens
        context.push(
          '/chatDetail?chatId=ai_assistant_${notification.userId}',
        );
      }

      // 4. Mark notification as read
      await onDismiss();

    } catch (e) {
      Logger.error('Error showing voting dialog', error: e,
          tag: 'NotificationOverlayProvider');
      await onDismiss();
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
