import 'dart:async';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/services/i_notification_service.dart';
import '../../domain/value_objects/notification_filter.dart';
import '/services/logging/logger_service.dart';

/// Notification Service Implementation
///
/// **Phase 5 Complete**: Firebase-Centric v2.0 Architecture
/// - Wraps INotificationRepository for streaming notifications
/// - Provides real-time notification stream to NotificationQueueService
/// - Implements all INotificationService methods using Repository
///
/// Architecture:
/// - Repository → Service → QueueService → Presentation
/// - Service acts as stream adapter for Repository queries
class NotificationService implements INotificationService {
  final INotificationRepository _repository;

  // Broadcast stream for multiple listeners
  final _streamController = StreamController<List<Notification>>.broadcast();

  // Repository subscription
  StreamSubscription<List<Notification>>? _subscription;

  NotificationService({
    required INotificationRepository repository,
  }) : _repository = repository;

  @override
  Stream<List<Notification>> get notificationsStream =>
    _streamController.stream;

  @override
  void startListening(String userId, {String? type}) {
    // Stop existing subscription if any
    stopListening();

    Logger.info(
      'NotificationService 리스닝 시작 - userId: ${Logger.maskSensitive(userId)}, type: ${type ?? "all"}',
      tag: 'NotificationService',
    );

    // Subscribe to repository stream
    _subscription = _repository.watchUserNotifications(
      userId: userId,
      filter: NotificationFilter(
        type: type,
        excludeExpired: true,  // 만료된 알림 자동 제외
      ),
    ).listen(
      (notifications) {
        Logger.debug(
          'Repository로부터 알림 수신: ${notifications.length}개',
          tag: 'NotificationService',
        );
        _streamController.add(notifications);
      },
      onError: (error) {
        Logger.error(
          'Repository 스트림 오류',
          error: error,
          tag: 'NotificationService',
        );
        _streamController.addError(error);
      },
    );
  }

  @override
  void stopListening() {
    if (_subscription != null) {
      Logger.info('NotificationService 리스닝 중지', tag: 'NotificationService');
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  Stream<int> getUnreadNotificationCount(String userId) {
    return _repository.getUnreadNotificationCount(userId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      Logger.debug('알림 읽음 처리: $notificationId', tag: 'NotificationService');

      final result = await _repository.markAsRead(
        notificationId,
        DateTime.now().millisecondsSinceEpoch.toString(),  // eventId for idempotency
      );

      result.fold(
        (failure) => Logger.error(
          '알림 읽음 처리 실패: $notificationId',
          error: failure,
          tag: 'NotificationService',
        ),
        (_) => Logger.debug(
          '알림 읽음 처리 성공: $notificationId',
          tag: 'NotificationService',
        ),
      );
    } catch (e) {
      Logger.error(
        '알림 읽음 처리 오류',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  @override
  Future<void> reshowNotification(String notificationId) async {
    try {
      Logger.debug('알림 재표시: $notificationId', tag: 'NotificationService');

      // Get notification first
      final notificationResult = await _repository.getNotification(notificationId);

      await notificationResult.fold(
        (failure) async {
          Logger.error(
            '알림 조회 실패: $notificationId',
            error: failure,
            tag: 'NotificationService',
          );
        },
        (notification) async {
          // Re-emit the notification through the stream to reshow it
          _streamController.add([notification]);

          Logger.debug(
            '알림 재표시 성공: $notificationId',
            tag: 'NotificationService',
          );
        },
      );
    } catch (e) {
      Logger.error(
        '알림 재표시 오류',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      Logger.debug('알림 삭제: $notificationId', tag: 'NotificationService');

      final result = await _repository.deleteNotification(
        notificationId,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      result.fold(
        (failure) => Logger.error(
          '알림 삭제 실패: $notificationId',
          error: failure,
          tag: 'NotificationService',
        ),
        (_) => Logger.debug(
          '알림 삭제 성공: $notificationId',
          tag: 'NotificationService',
        ),
      );
    } catch (e) {
      Logger.error(
        '알림 삭제 오류',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      Logger.debug('모든 알림 읽음 처리: $userId', tag: 'NotificationService');

      // Get all unread notifications
      final notificationsResult = await _repository.getUserNotifications(userId);

      await notificationsResult.fold(
        (failure) async {
          Logger.error(
            '알림 조회 실패',
            error: failure,
            tag: 'NotificationService',
          );
        },
        (notifications) async {
          final unreadNotifications = notifications.where((n) => !n.isRead).toList();

          Logger.debug(
            '읽지 않은 알림 ${unreadNotifications.length}개 처리 중',
            tag: 'NotificationService',
          );

          // Mark each as read
          for (final notification in unreadNotifications) {
            await markAsRead(notification.id);
          }

          Logger.info(
            '모든 알림 읽음 처리 완료: ${unreadNotifications.length}개',
            tag: 'NotificationService',
          );
        },
      );
    } catch (e) {
      Logger.error(
        '모든 알림 읽음 처리 오류',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  @override
  Future<void> cleanupExpiredNotifications(String userId) async {
    try {
      Logger.debug('만료된 알림 정리: $userId', tag: 'NotificationService');

      // Get all notifications
      final notificationsResult = await _repository.getUserNotifications(userId);

      await notificationsResult.fold(
        (failure) async {
          Logger.error(
            '알림 조회 실패',
            error: failure,
            tag: 'NotificationService',
          );
        },
        (notifications) async {
          final expiredNotifications = notifications.where((n) => n.isExpired).toList();

          Logger.debug(
            '만료된 알림 ${expiredNotifications.length}개 삭제 중',
            tag: 'NotificationService',
          );

          // Delete each expired notification
          for (final notification in expiredNotifications) {
            await deleteNotification(notification.id);
          }

          Logger.info(
            '만료된 알림 정리 완료: ${expiredNotifications.length}개',
            tag: 'NotificationService',
          );
        },
      );
    } catch (e) {
      Logger.error(
        '만료된 알림 정리 오류',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  @override
  void clearQueue() {
    // This service doesn't maintain a queue
    // Queue is maintained by NotificationQueueService
    Logger.debug('clearQueue() called - no-op (queue는 QueueService가 관리)', tag: 'NotificationService');
  }

  @override
  void dispose() {
    Logger.info('NotificationService dispose', tag: 'NotificationService');
    stopListening();
    _streamController.close();
  }
}
