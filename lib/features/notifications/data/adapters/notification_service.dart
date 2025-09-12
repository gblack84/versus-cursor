import 'dart:async';
import '/features/notifications/domain/models/notification.dart';
import '/features/notifications/domain/value_objects/notification_filter.dart';
import '/features/notifications/domain/services/i_notification_service.dart';
import '/core/interfaces/common/i_content_model.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/i_chat_datasource.dart';
import '/core/utils/logger.dart';

/// 실시간 투표 알림을 관리하는 서비스
///
/// Firebase Firestore의 notifications 컬렉션을 감시하여
/// 새로운 투표 알림이 도착하면 UI에 표시합니다.
class NotificationService implements INotificationService {
  NotificationService({
    required INotificationRepository repository,
    IChatDatasource? chatDatasource,
  })  : _repository = repository,
        _chatDatasource = chatDatasource;

  // Repository 리스너
  StreamSubscription<List<Notification>>? _notificationListener;

  // 알림 스트림 (GlobalNotificationManager를 위한)
  final StreamController<List<Notification>> _notificationsStreamController =
      StreamController<List<Notification>>.broadcast();

  Stream<List<Notification>> get notificationsStream =>
      _notificationsStreamController.stream;

  // Repository 의존성
  final INotificationRepository _repository;

  // Chat datasource 의존성 (optional - Chat feature에서 제공)
  final IChatDatasource? _chatDatasource;

  /// 알림 리스닝 시작
  void startListening(String userId) {
    // 기존 리스너 정리
    stopListening();

    Logger.info('알림 리스닝 시작 - 사용자: ${Logger.maskSensitive(userId)}',
        tag: 'NotificationService');

    // Repository를 통한 알림 스트림 구독
    Logger.logOnce('notif_query_$userId',
        '알림 쿼리 시작: userId=${Logger.maskSensitive(userId)}, type=voting_request',
        tag: 'Repository', level: LogLevel.INFO);

    _notificationListener = _repository
        .watchUserNotifications(
      userId: userId,
      filter: NotificationFilter(
        type: NotificationType.votingRequest,
        unreadOnly: true,
        excludeExpired: true,
        sortBy: 'expiryTime',
        sortOrder: SortOrder.ascending,
      ),
    )
        .listen(
      _handleNotificationChanges,
      onError: (error) {
        Logger.error('리스너 오류', error: error, tag: 'NotificationService');
      },
    );
  }

  /// 알림 리스닝 중지
  void stopListening() {
    _notificationListener?.cancel();
    _notificationListener = null;
    _notificationsStreamController.add([]); // 빈 리스트 전송
    Logger.info('알림 리스닝 중지', tag: 'NotificationService');
  }

  /// Repository 알림 변경 처리
  void _handleNotificationChanges(List<Notification> notifications) {
    // 알림 요약 정보는 DEBUG 레벨로
    Logger.debug('알림 변경: ${notifications.length}개 알림',
        tag: 'NotificationService');

    // 새로운 알림만 로깅 (알림별 한 번만)
    for (var notification in notifications) {
      Logger.logOnce(
          'notif_doc_${notification.id}', '🔔 새 알림: ${notification.id}',
          tag: 'NotificationService', level: LogLevel.INFO);
    }

    // GlobalNotificationManager에 알림 전달
    _notificationsStreamController.add(notifications);
    Logger.debug('GlobalNotificationManager에 ${notifications.length}개 알림 전달',
        tag: 'NotificationService');
  }

  /// 사용자의 읽지 않은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount(String userId) {
    return _repository.watchUnreadCount(userId);
  }

  /// 디버그 정보
  Map<String, dynamic> getDebugInfo() {
    return {
      'isListening': _notificationListener != null,
    };
  }

  /// 투표 요청을 채팅 메시지로 생성
  /// Chat Feature가 등록된 경우에만 동작
  Future<void> createVoteRequestChatMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required IContentModel post,
  }) async {
    if (_chatDatasource == null) {
      Logger.warning('Chat datasource not available',
          tag: 'NotificationService');
      return;
    }

    try {
      await _chatDatasource!.createVoteRequestMessage(
        senderId: senderId,
        recipientId: recipientId,
        postId: postId,
        post: post,
      );
      Logger.debug('투표 요청 메시지 생성 완료', tag: 'NotificationService');
    } catch (e) {
      Logger.error('투표 요청 메시지 생성 오류', error: e, tag: 'NotificationService');
    }
  }

  /// AI 채팅 메시지의 투표 상태 업데이트
  /// Chat Feature가 등록된 경우에만 동작
  Future<void> updateVoteMessageStatus({
    required String postId,
    required String userId,
    required String status,
  }) async {
    if (_chatDatasource == null) {
      Logger.warning('Chat datasource not available',
          tag: 'NotificationService');
      return;
    }

    try {
      await _chatDatasource!.updateVoteMessageStatus(
        postId: postId,
        userId: userId,
        status: status,
      );
      Logger.debug('AI 채팅 메시지 상태 업데이트 완료: $status', tag: 'NotificationService');
    } catch (e) {
      Logger.error('AI 채팅 메시지 상태 업데이트 오류',
          error: e, tag: 'NotificationService');
    }
  }

  // ===== INotificationService 구현 =====

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      Logger.debug('알림 읽음 처리: $notificationId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('알림 읽음 처리 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> reshowNotification(String notificationId) async {
    try {
      await _repository.updateNotification(notificationId, {
        'dismissed': false,
        'reshownAt': DateTime.now(),
      });
      Logger.debug('알림 다시 표시: $notificationId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('알림 다시 표시 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      Logger.debug('알림 삭제: $notificationId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('알림 삭제 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);
      Logger.debug('모든 알림 읽음 처리: $userId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('모든 알림 읽음 처리 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> cleanupExpiredNotifications(String userId) async {
    try {
      await _repository.cleanupExpiredNotifications(userId);
      Logger.debug('만료된 알림 정리: $userId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('만료된 알림 정리 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  void clearQueue() {
    // 알림 큐 비우기 - 메모리에서만 제거
    // 실제로는 GlobalNotificationManager에서 큐를 관리하므로
    // 여기서는 스트림을 통해 빈 리스트를 전달합니다.
    _notificationsStreamController.add([]);
    Logger.debug('알림 큐 비움', tag: 'NotificationService');
  }

  @override
  void dispose() {
    stopListening();
    _notificationsStreamController.close();
    Logger.info('NotificationService 리소스 정리', tag: 'NotificationService');
  }
}
