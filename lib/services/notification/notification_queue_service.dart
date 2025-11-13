import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
// Domain imports only
import '/features/notifications/domain/entities/notification.dart' as domain;
import '/features/notifications/domain/services/i_notification_service.dart';
// Core utilities
import '/services/logging/logger_service.dart';
import '/services/cache/unified_cache_service.dart';
// FCM Service
import 'fcm_service.dart';

/// Notification Queue Service - Business Logic Layer
///
/// Manages notification queue, duplicate prevention, and sequential display.
/// Implements Clean Architecture by emitting notifications via Stream for UI layer.
///
/// Integrates both Firestore-based notifications and FCM push notifications.
/// **Phase 5 Complete**: UnifiedCacheService 통합
/// - ILocalNotificationDatasource 제거
/// - UnifiedCacheService 3-Layer 캐싱 사용
/// - Firebase-Centric v2.0 아키텍처 준수
class NotificationQueueService {
  final INotificationService _notificationService;
  final FCMService _fcmService;

  /// Stream for UI to subscribe and display notifications
  final StreamController<domain.Notification> _showNotificationController =
    StreamController<domain.Notification>.broadcast();

  /// Stream that presentation layer subscribes to for showing notifications
  Stream<domain.Notification> get showNotificationStream =>
    _showNotificationController.stream;

  NotificationQueueService({
    required INotificationService notificationService,
    FCMService? fcmService,
  })  : _notificationService = notificationService,
        _fcmService = fcmService ?? FCMService();

  /// 알림 큐
  final List<domain.Notification> _notificationQueue = [];

  /// 현재 표시 중인 알림
  domain.Notification? _currentNotification;

  /// 알림 표시 중 여부
  bool _isShowingNotification = false;

  /// 처리된 알림 ID 세트 (중복 표시 방지)
  final Set<String> _processedNotificationIds = {};

  /// 처리된 알림 ID + 타임스탬프 (TTL 기반 정리용)
  final Map<String, DateTime> _processedNotificationTimestamps = {};

  /// 중복 감지 통계
  int _duplicateDetectionCount = 0;

  /// 스트림 구독
  StreamSubscription<List<domain.Notification>>? _notificationSubscription;
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  /// 큐 처리 타이머
  Timer? _queueTimer;

  /// 정리 타이머
  Timer? _cleanupTimer;

  /// NotificationService 및 FCMService와 연동 시작
  ///
  /// [userId] - 사용자 ID (알림 리스닝 시작에 필요)
  /// [type] - 알림 타입 필터 (null이면 모든 타입)
  void startListening({
    required String userId,
    String? type,
  }) async {
    Logger.info('알림 매니저 시작 (Firestore + FCM) - userId: ${Logger.maskSensitive(userId)}, type: ${type ?? "all"}',
        tag: 'NotificationQueueService');

    // 저장된 처리 기록 로드
    await _loadProcessedNotifications();

    // 0. NotificationService 리스닝 시작 (Firestore 감시 시작)
    _notificationService.startListening(userId, type: type);

    // 1. NotificationService의 스트림 구독 (Firestore 기반)
    _notificationSubscription = _notificationService.notificationsStream.listen(
      (notifications) {
        Logger.debug('Firestore 알림 수신: ${notifications.length}개',
            tag: 'NotificationQueueService');
        _handleNewNotifications(notifications);
      },
      onError: (error) {
        Logger.error('Firestore 스트림 오류', error: error, tag: 'NotificationQueueService');
      },
    );

    // 2. FCMService의 messageStream 구독 (FCM Push)
    if (_fcmService.isInitialized) {
      _fcmSubscription = _fcmService.messageStream.listen(
        (remoteMessage) {
          Logger.debug('FCM 메시지 수신: ${remoteMessage.notification?.title}',
              tag: 'NotificationQueueService');
          _handleFCMMessage(remoteMessage);
        },
        onError: (error) {
          Logger.error('FCM 스트림 오류', error: error, tag: 'NotificationQueueService');
        },
      );
    } else {
      Logger.warning('FCMService가 초기화되지 않음 - FCM 알림 비활성화',
          tag: 'NotificationQueueService');
    }

    // 큐 처리 타이머 시작 (3초마다 체크)
    _queueTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _processQueue();
    });

    // 정리 타이머 시작 (30분마다 오래된 기록 정리)
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupProcessedNotifications();
    });
  }

  /// 리스닝 중지
  void stopListening() {
    Logger.info('알림 매니저 중지', tag: 'NotificationQueueService');

    // 처리 기록 저장
    _saveProcessedNotifications();

    _notificationSubscription?.cancel();
    _fcmSubscription?.cancel();
    _queueTimer?.cancel();
    _cleanupTimer?.cancel();
    _showNotificationController.close();  // StreamController 정리
    _notificationQueue.clear();
    _currentNotification = null;
    _isShowingNotification = false;
    // 세션 종료 시 처리 기록은 유지 (다음 세션에서 사용하기 위해)
    // _processedNotificationIds.clear();
  }

  /// FCM RemoteMessage 처리
  void _handleFCMMessage(RemoteMessage message) {
    try {
      // FCM 메시지를 domain.Notification으로 변환
      final notification = _convertFCMMessageToNotification(message);

      if (notification != null) {
        // 기존 큐 시스템에 추가
        _handleNewNotifications([notification]);
      } else {
        Logger.warning('FCM 메시지 변환 실패: ${message.messageId}',
            tag: 'NotificationQueueService');
      }
    } catch (e) {
      Logger.error('FCM 메시지 처리 오류', error: e, tag: 'NotificationQueueService');
    }
  }

  /// FCM RemoteMessage를 domain.Notification으로 변환
  ///
  /// FCM 메시지의 data 페이로드를 파싱하여 적절한 도메인 모델로 변환합니다.
  /// 현재는 VoteNotification만 지원하며, 추후 확장 가능합니다.
  domain.Notification? _convertFCMMessageToNotification(RemoteMessage message) {
    try {
      final data = message.data;
      final notificationType = data['type'] as String?;

      if (notificationType == null) {
        Logger.warning('FCM 메시지에 type 필드 없음', tag: 'NotificationQueueService');
        return null;
      }

      switch (notificationType.toLowerCase()) {
        case 'vote':
        case 'vote_notification':
          // Vote 알림은 Firestore로 처리됨 (FCM Push는 미구현)
          Logger.info('Vote 알림은 Firestore로 처리됨 (FCM은 미구현)',
            tag: 'NotificationQueueService');
          return null;

        case 'social':
        case 'social_notification':
          return _convertToSocialNotification(data);

        case 'system':
        case 'system_notification':
          return _convertToSystemNotification(data);

        default:
          Logger.warning('알 수 없는 알림 타입: $notificationType',
              tag: 'NotificationQueueService');
          return null;
      }
    } catch (e) {
      Logger.error('FCM 메시지 변환 오류', error: e, tag: 'NotificationQueueService');
      return null;
    }
  }

  /// FCM 데이터를 SocialNotification으로 변환
  domain.SocialNotification? _convertToSocialNotification(Map<String, dynamic> data) {
    try {
      return domain.SocialNotification(
        id: data['id'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
        type: data['type'] as String? ?? 'social',
        title: data['title'] as String? ?? '',
        content: data['content'] as String? ?? '',
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
        isRead: data['isRead'] as bool? ?? false,
        readAt: data['readAt'] != null
            ? DateTime.parse(data['readAt'] as String)
            : null,
        expiryTime: data['expiryTime'] != null
            ? DateTime.parse(data['expiryTime'] as String)
            : null,
        metadata: data['metadata'] as Map<String, dynamic>? ?? {},
        actionType: _parseSocialActionType(data['actionType'] as String?),
        fromUserId: data['fromUserId'] as String? ?? '',
        fromUserName: data['fromUserName'] as String? ?? '',
        fromUserProfileUrl: data['fromUserProfileUrl'] as String?,
        relatedPostId: data['relatedPostId'] as String?,
        relatedCommentId: data['relatedCommentId'] as String?,
        relatedContent: data['relatedContent'] as String?,
        interactionCount: data['interactionCount'] as int?,
      );
    } catch (e) {
      Logger.error('Social 알림 변환 오류', error: e, tag: 'NotificationQueueService');
      return null;
    }
  }

  /// FCM 데이터를 SystemNotification으로 변환
  domain.SystemNotification? _convertToSystemNotification(Map<String, dynamic> data) {
    try {
      return domain.SystemNotification(
        id: data['id'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
        type: data['type'] as String? ?? 'system',
        title: data['title'] as String? ?? '',
        content: data['content'] as String? ?? '',
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
        isRead: data['isRead'] as bool? ?? false,
        readAt: data['readAt'] != null
            ? DateTime.parse(data['readAt'] as String)
            : null,
        expiryTime: data['expiryTime'] != null
            ? DateTime.parse(data['expiryTime'] as String)
            : null,
        metadata: data['metadata'] as Map<String, dynamic>? ?? {},
        alertType: _parseSystemAlertType(data['alertType'] as String?),
        actionUrl: data['actionUrl'] as String?,
        actionLabel: data['actionLabel'] as String?,
        actionButtons: (data['actionButtons'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString())),
        iconUrl: data['iconUrl'] as String?,
        isDismissible: data['isDismissible'] as bool? ?? true,
      );
    } catch (e) {
      Logger.error('System 알림 변환 오류', error: e, tag: 'NotificationQueueService');
      return null;
    }
  }

  /// SocialActionType 파싱 헬퍼
  domain.SocialActionType _parseSocialActionType(String? typeStr) {
    if (typeStr == null) return domain.SocialActionType.like;

    switch (typeStr.toLowerCase()) {
      case 'like': return domain.SocialActionType.like;
      case 'comment': return domain.SocialActionType.comment;
      case 'friend_request': return domain.SocialActionType.friendRequest;
      case 'friend_accepted': return domain.SocialActionType.friendAccepted;
      case 'follow': return domain.SocialActionType.follow;
      case 'mention': return domain.SocialActionType.mention;
      case 'share': return domain.SocialActionType.share;
      default: return domain.SocialActionType.like;
    }
  }

  /// SystemAlertType 파싱 헬퍼
  domain.SystemAlertType _parseSystemAlertType(String? typeStr) {
    if (typeStr == null) return domain.SystemAlertType.info;

    switch (typeStr.toLowerCase()) {
      case 'critical': return domain.SystemAlertType.critical;
      case 'security': return domain.SystemAlertType.security;
      case 'maintenance': return domain.SystemAlertType.maintenance;
      case 'update': return domain.SystemAlertType.update;
      case 'info': return domain.SystemAlertType.info;
      default: return domain.SystemAlertType.info;
    }
  }

  /// 새로운 알림 처리
  void _handleNewNotifications(List<domain.Notification> notifications) {
    // 기존 큐에 없고, 이미 처리되지 않은 새로운 알림만 추가
    for (final notification in notifications) {
      final notificationId = notification.id;

      // 이미 처리된 알림은 무시 (중복 감지)
      if (_processedNotificationIds.contains(notificationId)) {
        _duplicateDetectionCount++;
        Logger.warning(
          '중복 알림 감지: $notificationId (총 $_duplicateDetectionCount회)',
          tag: 'NotificationQueueService',
        );
        continue;
      }

      // 큐에 없는 경우만 추가
      if (!_notificationQueue.any((n) => n.id == notificationId)) {
        _notificationQueue.add(notification);
        Logger.logOnce(
            'notif_queued_$notificationId', '알림 큐에 추가: $notificationId',
            tag: 'NotificationQueueService');
      }
    }

    // 큐 정렬 (생성 시간 기준)
    _notificationQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    Logger.debug(
        '큐 크기: ${_notificationQueue.length}, 처리된: ${_processedNotificationIds.length}, 중복: $_duplicateDetectionCount',
        tag: 'NotificationQueueService');

    // 즉시 처리 시도
    _processQueue();
  }

  /// 큐 처리
  void _processQueue() {
    // 이미 표시 중이면 대기
    if (_isShowingNotification) {
      return;
    }

    // 큐가 비어있으면 종료
    if (_notificationQueue.isEmpty) {
      return;
    }

    // 다음 알림 가져오기
    final notification = _notificationQueue.removeAt(0);
    _showNotification(notification);
  }

  /// 알림 표시 - Stream을 통해 Presentation Layer에 전달
  void _showNotification(domain.Notification notification) {
    // 알림을 처리 목록에 추가 (중복 표시 방지)
    final notificationId = notification.id;
    _processedNotificationIds.add(notificationId);
    _processedNotificationTimestamps[notificationId] = DateTime.now();

    // 처리 기록 저장 (비동기로 처리하여 UI 블로킹 방지)
    _saveProcessedNotifications();

    // 상태 업데이트
    _isShowingNotification = true;
    _currentNotification = notification;

    // Stream으로 알림 전달 (Presentation Layer가 구독하여 UI 표시)
    _showNotificationController.add(notification);

    Logger.debug('알림 Stream 전달: $notificationId', tag: 'NotificationQueueService');
  }

  /// UI에서 알림 처리 완료 시 호출되는 콜백
  ///
  /// Presentation layer에서 사용자가 투표하거나 알림을 닫은 후 호출합니다.
  /// 다음 알림 처리를 위해 상태를 초기화하고 큐 처리를 재개합니다.
  ///
  /// [delayMilliseconds] - 다음 알림 처리 전 대기 시간 (기본값: 500ms)
  void notificationClosed({int delayMilliseconds = 500}) {
    Logger.debug('알림 닫힘 - 다음 알림 ${delayMilliseconds}ms 후 처리',
        tag: 'NotificationQueueService');

    // 상태 초기화
    _isShowingNotification = false;
    _currentNotification = null;

    // 다음 알림 처리 (delay 후)
    Future.delayed(Duration(milliseconds: delayMilliseconds), () {
      _processQueue();
    });
  }

  /// 오래된 처리 기록 정리 (TTL 기반)
  void _cleanupProcessedNotifications() {
    final beforeCount = _processedNotificationIds.length;
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // 1시간 이상 지난 항목 찾기
    final idsToRemove = _processedNotificationTimestamps.entries
        .where((entry) => entry.value.isBefore(oneHourAgo))
        .map((entry) => entry.key)
        .toList();

    // 오래된 항목 제거
    for (final id in idsToRemove) {
      _processedNotificationIds.remove(id);
      _processedNotificationTimestamps.remove(id);
    }

    if (idsToRemove.isNotEmpty) {
      Logger.debug(
        '처리 기록 TTL 정리: $beforeCount -> ${_processedNotificationIds.length} (${idsToRemove.length}개 제거)',
        tag: 'NotificationQueueService',
      );

      // 정리 후 저장
      _saveProcessedNotifications();
    }
  }

  /// 처리된 알림 ID 로드
  Future<void> _loadProcessedNotifications() async {
    try {
      // IDs 로드
      final cachedIdsResult = await UnifiedCacheService.instance
          .get<List<dynamic>>('processed_notification_ids');
      final cachedIds = cachedIdsResult.fold(
        (failure) => null,  // Cache miss or error
        (ids) => ids,
      );

      if (cachedIds != null) {
        _processedNotificationIds.addAll(
          cachedIds.map((id) => id.toString())
        );
      }

      // Timestamps 로드
      final cachedTimestampsResult = await UnifiedCacheService.instance
          .get<Map<String, dynamic>>('processed_notification_timestamps');
      final cachedTimestamps = cachedTimestampsResult.fold(
        (failure) => null,
        (timestamps) => timestamps,
      );

      if (cachedTimestamps != null) {
        cachedTimestamps.forEach((key, value) {
          if (value is String) {
            try {
              _processedNotificationTimestamps[key] = DateTime.parse(value);
            } catch (e) {
              // 파싱 실패 시 무시
            }
          }
        });
      }
    } catch (e) {
      Logger.warning('처리 기록 로드 실패', tag: 'NotificationQueueService');
    }
  }

  /// 처리된 알림 ID 저장
  Future<void> _saveProcessedNotifications() async {
    try {
      // IDs 저장
      await UnifiedCacheService.instance.set(
        'processed_notification_ids',
        _processedNotificationIds.toList(),
      );

      // Timestamps 저장 (ISO8601 문자열로 변환)
      final timestampsMap = _processedNotificationTimestamps.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );
      await UnifiedCacheService.instance.set(
        'processed_notification_timestamps',
        timestampsMap,
      );
    } catch (e) {
      Logger.warning('처리 기록 저장 실패', tag: 'NotificationQueueService');
    }
  }

  /// 현재 큐 상태 반환
  int get queueLength => _notificationQueue.length;

  /// 현재 표시 중인지 여부
  bool get isShowingNotification => _isShowingNotification;

  /// 현재 표시 중인 알림 반환
  domain.Notification? get currentNotification => _currentNotification;

  /// 디버그 정보 반환
  Map<String, dynamic> getDebugInfo() {
    // 가장 오래된 처리 기록 찾기
    DateTime? oldestTimestamp;
    if (_processedNotificationTimestamps.isNotEmpty) {
      oldestTimestamp = _processedNotificationTimestamps.values.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
    }

    return {
      'isShowingNotification': _isShowingNotification,
      'queueLength': _notificationQueue.length,
      'processedCount': _processedNotificationIds.length,
      'duplicateDetectionCount': _duplicateDetectionCount,
      'oldestProcessedTimestamp': oldestTimestamp?.toIso8601String(),
      'currentNotificationId': _currentNotification?.id,
      'currentNotificationType': _currentNotification?.type,
      'fcmInitialized': _fcmService.isInitialized,
    };
  }

  /// 큐 크기 반환
  int getQueueSize() => _notificationQueue.length;

  /// 처리된 알림 개수 반환
  int getProcessedNotificationCount() => _processedNotificationIds.length;

  /// 큐 비우기 (테스트용)
  void clearQueue() {
    _notificationQueue.clear();
    _currentNotification = null;
    _isShowingNotification = false;
    Logger.info('알림 큐 비움', tag: 'NotificationQueueService');
  }
}
