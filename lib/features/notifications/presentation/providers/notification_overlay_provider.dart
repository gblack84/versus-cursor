import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/notification.dart' as domain;
import '../../domain/models/social_notification.dart' as domain;
import '../../domain/models/system_notification.dart' as domain;
import '../../domain/usecases/mark_as_read_use_case.dart';
import '/services/notification/notification_queue_service.dart';
import '/core/utils/logger.dart';
import '/app/router/navigation/nav.dart';
import '/core/domain/ports/i_notification_display_port.dart';
import '/app/contracts/notification_types.dart';

/// Notification Overlay Provider - Presentation Layer
///
/// Subscribes to NotificationQueueService stream and displays notifications as overlays.
/// Handles user interactions (vote, dismiss) and coordinates with business logic layer.
///
/// Clean Architecture: Presentation → Data (via Stream)
class NotificationOverlayProvider extends ChangeNotifier {
  final NotificationQueueService _queueService;
  final MarkAsReadUseCase _markAsRead;
  final INotificationDisplayPort _votingDisplayPort;

  StreamSubscription<domain.Notification>? _subscription;
  bool _isInitialized = false;

  NotificationOverlayProvider({
    required NotificationQueueService queueService,
    required MarkAsReadUseCase markAsRead,
    required INotificationDisplayPort votingDisplayPort,
  })  : _queueService = queueService,
        _markAsRead = markAsRead,
        _votingDisplayPort = votingDisplayPort;

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

  /// Handle incoming notification from stream
  void _handleNotification(domain.Notification notification) {
    Logger.debug('Received notification: ${notification.id}, type: ${notification.type}',
        tag: 'NotificationOverlayProvider');

    // Route to appropriate handler based on notification type
    // Note: Using type String comparison instead of 'is' check for better feature isolation
    if (notification.type == NotificationTypes.votingRequest) {
      _showVotingDialog(notification);
    } else if (notification is domain.SocialNotification) {
      _showSocialDialog(notification);
    } else if (notification is domain.SystemNotification) {
      _showSystemDialog(notification);
    } else {
      Logger.warning('Unknown notification type: ${notification.type}',
          tag: 'NotificationOverlayProvider');
      _queueService.notificationClosed();
    }
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
  /// Note: Vote submission is handled by VoteHandlerImpl (Voting Feature)
  Future<void> _handleVote(
    domain.Notification notification,
    String selectedOption,
  ) async {
    Logger.info('Vote callback received: $selectedOption for notification ${notification.id}',
        tag: 'NotificationOverlayProvider');

    try {
      // Mark notification as read (Notification Feature responsibility)
      await _markAsRead.call(MarkAsReadParams(
        notificationId: notification.id,
        userId: notification.userId,
      ));

      // Signal queue service to process next notification (300ms delay)
      _queueService.notificationClosed(delayMilliseconds: 300);
    } catch (e) {
      Logger.error('Error handling vote callback', error: e,
          tag: 'NotificationOverlayProvider');
      _queueService.notificationClosed();
    }
  }

  /// Handle notification dismissal
  Future<void> _handleDismiss(domain.Notification notification) async {
    Logger.debug('Notification dismissed: ${notification.id}',
        tag: 'NotificationOverlayProvider');

    try {
      // Mark notification as read
      await _markAsRead.call(MarkAsReadParams(
        notificationId: notification.id,
        userId: notification.userId,
      ));

      // Signal queue service to process next notification (500ms delay)
      _queueService.notificationClosed(delayMilliseconds: 500);
    } catch (e) {
      Logger.error('Error handling dismiss', error: e,
          tag: 'NotificationOverlayProvider');
      _queueService.notificationClosed();
    }
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

  /// Show voting notification dialog using Port-Adapter pattern
  /// Note: Delegates to Voting Feature via Port - the feature extracts its own data
  Future<void> _showVotingNotificationDialog({
    required BuildContext context,
    required domain.Notification notification,
    required Future<void> Function(String) onVote,
    required Future<void> Function() onDismiss,
  }) async {
    // Voting Feature's Port를 통해 표시
    // The notification is passed as dynamic - Voting Feature will handle casting and data extraction
    await _votingDisplayPort.showVotingNotification(
      notification: notification,
      context: context,
      displayData: {}, // Voting Feature extracts its own display data from notification
      onVote: (selectedOption) async {
        await onVote(selectedOption);
      },
      onDismiss: (hasVoted) async {
        await onDismiss();
      },
    );
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
