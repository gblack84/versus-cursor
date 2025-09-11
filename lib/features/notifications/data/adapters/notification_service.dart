import 'dart:async';
import '/features/notifications/domain/models/notification.dart';
import '/features/notifications/domain/value_objects/notification_filter.dart';
import '/features/posts/domain/models/posts_model.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/i_chat_datasource.dart';
import '/core/utils/logger.dart';

/// 실시간 투표 알림을 관리하는 서비스
///
/// Firebase Firestore의 notifications 컬렉션을 감시하여
/// 새로운 투표 알림이 도착하면 UI에 표시합니다.
class NotificationService {
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
    required PostsModel post,
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
}
