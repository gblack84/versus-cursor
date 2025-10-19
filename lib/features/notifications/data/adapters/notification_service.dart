import 'dart:async';
import '/features/notifications/domain/models/notification.dart';
import '/features/notifications/domain/value_objects/notification_filter.dart';
import '/features/notifications/domain/services/i_notification_service.dart';
import '../datasources/i_remote_notification_datasource.dart';
import '../mappers/notification_mapper.dart';
import '../models/notification_dto.dart';
import '../models/system_notification_dto.dart';
import '../models/social_notification_dto.dart';
import '/core/utils/logger.dart';
import '/app/contracts/notification_types.dart';

/// 실시간 알림을 관리하는 범용 서비스
///
/// Firebase Firestore의 notifications 컬렉션을 감시하여
/// 새로운 알림이 도착하면 UI에 표시합니다.
///
/// 지원하는 알림 타입:
/// - voting_request: 투표 요청 알림 (Voting Feature)
/// - post_liked: 게시물 좋아요 알림 (Social Feature)
/// - comment_added: 댓글 추가 알림 (Social Feature)
/// - friend_request: 친구 요청 알림 (Social Feature)
/// - system_alert: 시스템 알림 (System Feature)
class NotificationService implements INotificationService {
  NotificationService({
    required IRemoteNotificationDatasource remoteDatasource,
  })  : _remoteDatasource = remoteDatasource;

  // Datasource 리스너
  StreamSubscription<List<Notification>>? _notificationListener;

  // 알림 스트림 (NotificationQueueService를 위한)
  final StreamController<List<Notification>> _notificationsStreamController =
      StreamController<List<Notification>>.broadcast();

  Stream<List<Notification>> get notificationsStream =>
      _notificationsStreamController.stream;

  // Datasource 의존성
  final IRemoteNotificationDatasource _remoteDatasource;

  /// 알림 리스닝 시작
  ///
  /// [userId] - 사용자 ID
  /// [type] - 알림 타입 필터 (null이면 모든 타입)
  ///
  /// 사용 예시:
  /// ```dart
  /// // 투표 알림만 리스닝
  /// service.startListening(userId, type: NotificationTypes.votingRequest);
  ///
  /// // 모든 타입 리스닝
  /// service.startListening(userId);
  /// ```
  @override
  void startListening(String userId, {String? type}) {
    // 기존 리스너 정리
    stopListening();

    final typeInfo = type != null ? 'type=$type' : 'all types';
    Logger.info(
      '알림 리스닝 시작 - 사용자: ${Logger.maskSensitive(userId)}, $typeInfo',
      tag: 'NotificationService',
    );

    // Datasource를 통한 알림 스트림 구독
    Logger.logOnce(
      'notif_query_${userId}_${type ?? "all"}',
      '알림 쿼리 시작: userId=${Logger.maskSensitive(userId)}, $typeInfo',
      tag: 'Datasource',
      level: LogLevel.INFO,
    );

    final stream = _remoteDatasource.watchUserNotifications(
      userId: userId,
      type: type, // null이면 모든 타입
      unreadOnly: true,
    );

    // Map<String, dynamic> 리스트를 Notification 도메인 모델 리스트로 변환
    _notificationListener = stream.map((dataList) {
      final notifications = <Notification>[];
      for (final data in dataList) {
        try {
          final dto = _createDtoFromMap(data);
          final notification = NotificationMapper.toDomain(dto);

          // excludeExpired 필터링
          if (!notification.isExpired) {
            notifications.add(notification);
          }
        } catch (e) {
          Logger.error('알림 변환 실패', error: e, tag: 'NotificationService');
        }
      }

      // expiryTime으로 정렬 (오름차순, null은 맨 뒤로)
      notifications.sort((a, b) {
        if (a.expiryTime == null && b.expiryTime == null) return 0;
        if (a.expiryTime == null) return 1;
        if (b.expiryTime == null) return -1;
        return a.expiryTime!.compareTo(b.expiryTime!);
      });

      return notifications;
    }).listen(
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

    // NotificationQueueService에 알림 전달
    _notificationsStreamController.add(notifications);
    Logger.debug('NotificationQueueService에 ${notifications.length}개 알림 전달',
        tag: 'NotificationService');
  }

  /// 사용자의 읽지 않은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount(String userId) {
    return _remoteDatasource.watchUnreadCount(userId: userId);
  }

  /// 디버그 정보
  Map<String, dynamic> getDebugInfo() {
    return {
      'isListening': _notificationListener != null,
    };
  }

  // ===== INotificationService 구현 =====

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);
      Logger.debug('알림 읽음 처리: $notificationId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('알림 읽음 처리 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> reshowNotification(String notificationId) async {
    try {
      await _remoteDatasource.updateNotification(notificationId, {
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
      await _remoteDatasource.deleteNotification(notificationId);
      Logger.debug('알림 삭제: $notificationId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('알림 삭제 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _remoteDatasource.markAllAsRead(userId);
      Logger.debug('모든 알림 읽음 처리: $userId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('모든 알림 읽음 처리 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  Future<void> cleanupExpiredNotifications(String userId) async {
    try {
      await _remoteDatasource.deleteExpiredNotifications(userId);
      Logger.debug('만료된 알림 정리: $userId', tag: 'NotificationService');
    } catch (e) {
      Logger.error('만료된 알림 정리 오류', error: e, tag: 'NotificationService');
      rethrow;
    }
  }

  @override
  void clearQueue() {
    // 알림 큐 비우기 - 메모리에서만 제거
    // 실제로는 NotificationQueueService에서 큐를 관리하므로
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

  /// Map 데이터를 적절한 DTO로 변환하는 헬퍼 메서드
  NotificationDto _createDtoFromMap(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'systemAlert':
        return SystemNotificationDto.fromJson(data);
      case 'social':
        return SocialNotificationDto.fromJson(data);
      default:
        // Note: votingRequest type is now handled by Voting Feature
        return NotificationDto.fromJson(data);
    }
  }
}
