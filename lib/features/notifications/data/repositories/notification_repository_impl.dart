import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/models/notification.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../../domain/failures/notification_failure.dart';
import '../datasources/i_remote_notification_datasource.dart';
import '../datasources/i_local_notification_datasource.dart';
import '/app/contracts/notification_contract.dart';
import '/app/contracts/notification_types.dart';
import '../mappers/notification_mapper.dart';
import '../models/notification_dto.dart';
import '../models/system_notification_dto.dart';
import '../models/social_notification_dto.dart';
import '/services/notification/notification_queue_service.dart';

/// Clean Architecture 준수 Repository 구현체
///
/// DataSource를 통해 데이터를 가져오고,
/// Mapper를 통해 Domain 모델로 변환합니다.
class NotificationRepositoryImpl implements INotificationRepository, NotificationContract {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  final NotificationQueueService _queueService;

  // 캐시 설정
  static const Duration _cacheExpiry = Duration(minutes: 30);
  static const int _maxCacheSize = 100;

  NotificationRepositoryImpl({
    required IRemoteNotificationDatasource remoteDatasource,
    required ILocalNotificationDatasource localDatasource,
    required NotificationQueueService queueService,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _queueService = queueService;

  // ===== 조회 Operations =====

  @override
  Future<Notification?> getNotification(String notificationId) async {
    try {
      // 캐시 확인
      final cached =
          await _localDatasource.getCachedNotification(notificationId);
      if (cached != null) {
        final dto = _createDtoFromMap(cached);
        return NotificationMapper.toDomain(dto);
      }

      // Remote에서 가져오기
      final data = await _remoteDatasource.getNotification(notificationId);
      if (data == null) return null;

      // 캐시 저장
      await _localDatasource.cacheNotification(notificationId, data);

      // Domain 모델로 변환
      final dto = _createDtoFromMap(data);
      return NotificationMapper.toDomain(dto);
    } catch (e) {
      print('Error getting notification: $e');
      return null;
    }
  }

  @override
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  }) async {
    try {
      // 캐시 확인
      final cached = await _localDatasource.getCachedNotifications(userId);
      final cacheTime = await _localDatasource.getLastCacheTime(userId);

      // 캐시가 유효한 경우
      if (cached.isNotEmpty &&
          cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheExpiry) {
        final notifications = cached
            .map((data) => _createDtoFromMap(data))
            .map((dto) => NotificationMapper.toDomain(dto))
            .toList();
        return _applyFilter(notifications, filter);
      }

      // Remote에서 가져오기
      final remoteData = await _remoteDatasource.getNotifications(
        userId: userId,
        type: filter?.type,
        unreadOnly: filter?.unreadOnly,
        after: filter?.after,
        before: filter?.before,
        limit: filter?.limit ?? _maxCacheSize,
      );

      // 캐시 업데이트
      await _localDatasource.cacheNotifications(userId, remoteData);

      // Domain 모델로 변환
      final notifications = remoteData
          .map((data) => _createDtoFromMap(data))
          .map((dto) => NotificationMapper.toDomain(dto))
          .toList();

      return _applyFilter(notifications, filter);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  @override
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  }) {
    return _remoteDatasource
        .watchUserNotifications(
      userId: userId,
      type: filter?.type,
      unreadOnly: filter?.unreadOnly,
      after: filter?.after,
      before: filter?.before,
      limit: filter?.limit,
    )
        .asyncMap((dtoList) async {
      // 캐시 업데이트
      await _localDatasource.cacheNotifications(userId, dtoList);

      // Domain 모델로 변환
      final notifications = <Notification>[];
      for (final dtoData in dtoList) {
        try {
          final dto = _createDtoFromMap(dtoData);
          notifications.add(NotificationMapper.toDomain(dto));
        } catch (e) {
          // 변환 실패한 항목은 건너뛰기
          print('Failed to map notification: $e');
        }
      }

      // 필터 적용 (추가 필터링이 필요한 경우)
      return _applyFilter(notifications, filter);
    });
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      // Try to get from remote datasource
      final unreadNotifications = await _remoteDatasource.getNotifications(
        userId: userId,
        unreadOnly: true,
      );
      return unreadNotifications.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _remoteDatasource.watchUnreadCount(
      userId: userId,
      type: null,
    );
  }

  @override
  Future<List<T>> getNotificationsByType<T extends Notification>({
    required String userId,
    required String type,
    int? limit,
  }) async {
    try {
      final remoteData = await _remoteDatasource.getNotifications(
        userId: userId,
        type: type,
        limit: limit,
      );

      final notifications = <T>[];
      for (final dtoData in remoteData) {
        try {
          final dto = _createDtoFromMap(dtoData);
          final notification = NotificationMapper.toDomain(dto);
          if (notification is T) {
            notifications.add(notification);
          }
        } catch (e) {
          print('Failed to map notification: $e');
        }
      }

      return notifications;
    } catch (e) {
      print('Error getting notifications by type: $e');
      return [];
    }
  }
  // ===== 생성/수정 Operations =====

  @override
  Future<String> createNotification(Notification notification) async {
    try {
      // Domain → DTO 변환
      final dto = NotificationMapper.toDto(notification);

      // Map으로 변환
      final data = dto.toJson();

      // Remote에 생성
      final id = await _remoteDatasource.createNotification(data);

      // 캐시 무효화
      await _localDatasource.clearCache(notification.userId);

      print('Notification created with id: $id');
      return id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const NotificationCreateFailed();
    }
  }

  @override
  Future<void> updateNotification(String notificationId, Map<String, dynamic> updates) async {
    try {
      // Remote 업데이트
      await _remoteDatasource.updateNotification(notificationId, updates);

      // 캐시 무효화 - notificationId로부터 userId를 추출할 수 없으므로 전체 캐시 무효화
      await _localDatasource.clearAllCache();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const NotificationUpdateFailed();
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);

      // 캐시 무효화
      await _localDatasource.clearAllCache();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const NotificationUpdateFailed();
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _remoteDatasource.markAllAsRead(userId);

      // 캐시 무효화
      await _localDatasource.clearCache(userId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const NotificationUpdateFailed();
    }
  }

  // ===== 삭제 Operations =====

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Remote에서 삭제
      await _remoteDatasource.deleteNotification(notificationId);

      // 캐시에서도 제거
      await _localDatasource.clearAllCache();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const NotificationDeleteFailed();
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      // Datasource의 효율적인 배치 삭제 메서드 사용
      await _remoteDatasource.deleteAllUserNotifications(userId);

      // 캐시에서도 제거
      await _localDatasource.clearCache(userId);
      
      print('[NotificationRepository] Deleted all notifications for user: $userId');
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }

  @override
  Future<void> deleteOldNotifications({
    required String userId,
    required DateTime before,
  }) async {
    try {
      // Datasource의 효율적인 날짜 기반 삭제 메서드 사용
      await _remoteDatasource.deleteNotificationsBefore(
        userId: userId,
        before: before,
      );

      // 캐시 무효화
      await _localDatasource.clearCache(userId);
      
      print('[NotificationRepository] Deleted notifications before $before for user: $userId');
    } catch (e) {
      throw Exception('Failed to delete old notifications: $e');
    }
  }

  @override
  Future<void> deleteExpiredNotifications(String userId) async {
    try {
      // Datasource의 효율적인 만료 알림 삭제 메서드 사용
      await _remoteDatasource.deleteExpiredNotifications(userId);

      // 캐시 무효화
      await _localDatasource.clearCache(userId);
      
      print('[NotificationRepository] Deleted expired notifications for user: $userId');
    } catch (e) {
      throw Exception('Failed to delete expired notifications: $e');
    }
  }

  @override
  Future<void> cleanupExpiredNotifications(String userId) async {
    // cleanupExpiredNotifications는 deleteExpiredNotifications와 동일한 기능
    // 호환성을 위해 별칭으로 제공
    return deleteExpiredNotifications(userId);
  }
  // ===== 특수 Operations =====
  // Note: Vote notification creation is now handled by Voting Feature

  @override
  Future<void> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  }) async {
    try {
      if (targetUserIds != null && targetUserIds.isNotEmpty) {
        // 특정 사용자들에게만 브로드캐스트
        for (final userId in targetUserIds) {
          final userNotification = Notification.system(
            id: '', // Remote에서 생성됨
            userId: userId,
            type: 'systemAlert',
            createdAt: notification.createdAt,
            isRead: false,
            title: notification.title,
            content: notification.content,
            expiryTime: notification.expiryTime,
            metadata: notification.metadata,
            alertType: notification.alertType,
            actionUrl: notification.actionUrl,
            actionLabel: notification.actionLabel,
            actionButtons: notification.actionButtons,
            iconUrl: notification.iconUrl,
            isDismissible: notification.isDismissible,
          );

          await createNotification(userNotification);
        }
      } else {
        // 모든 활성 사용자 ID 가져오기
        final userIds = await _remoteDatasource.getAllActiveUserIds();

        print('[NotificationRepository] Broadcasting to ${userIds.length} active users');

        for (final userId in userIds) {
          final userNotification = Notification.system(
            id: '', // Remote에서 생성됨
            userId: userId,
            type: 'systemAlert',
            createdAt: notification.createdAt,
            isRead: false,
            title: notification.title,
            content: notification.content,
            expiryTime: notification.expiryTime,
            metadata: notification.metadata,
            alertType: notification.alertType,
            actionUrl: notification.actionUrl,
            actionLabel: notification.actionLabel,
            actionButtons: notification.actionButtons,
            iconUrl: notification.iconUrl,
            isDismissible: notification.isDismissible,
          );

          await createNotification(userNotification);
        }
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const BroadcastFailed();
    }
  }

  @override
  Future<void> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  }) async {
    try {
      // 1. 최근 24시간 내 같은 타입의 알림 조회
      final recentNotifications = await _remoteDatasource.getNotifications(
        userId: userId,
        type: 'social',
        after: DateTime.now().subtract(const Duration(hours: 24)),
        limit: 50,
      );

      // 2. 같은 actionType과 postId를 가진 알림 찾기
      Map<String, dynamic>? existingNotification;
      for (final notif in recentNotifications) {
        if (notif['actionType'] == actionType.value &&
            notif['relatedPostId'] == relatedPostId) {
          existingNotification = notif;
          break;
        }
      }

      if (existingNotification != null) {
        // 3. 기존 알림이 있으면 interactionCount 증가
        final currentCount = existingNotification['interactionCount'] ?? 1;
        await _remoteDatasource.updateNotification(
          existingNotification['id'],
          {
            'interactionCount': currentCount + 1,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // 4. 새 소셜 알림 생성
        final newNotification = Notification.social(
          id: '', // Remote에서 생성됨
          userId: userId,
          type: 'social',
          createdAt: DateTime.now(),
          isRead: false,
          title: _generateSocialTitle(actionType),
          content: _generateSocialContent(actionType, relatedPostId),
          actionType: actionType,
          fromUserId: '', // 실제로는 호출하는 곳에서 제공해야 함
          fromUserName: 'User', // 실제로는 호출하는 곳에서 제공해야 함
          relatedPostId: relatedPostId,
          interactionCount: 1,
        );

        await createNotification(newNotification);
      }

      // 5. 캐시 업데이트
      await _localDatasource.clearCache(userId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw const NetworkError();
      } else {
        throw const ServerError();
      }
    } catch (e) {
      throw const GroupingFailed();
    }
  }

  // Helper 메서드들
  String _generateSocialTitle(SocialActionType actionType) {
    switch (actionType) {
      case SocialActionType.like:
        return '새로운 좋아요';
      case SocialActionType.comment:
        return '새로운 댓글';
      case SocialActionType.friendRequest:
        return '친구 요청';
      case SocialActionType.friendAccepted:
        return '친구 요청 수락됨';
      case SocialActionType.follow:
        return '새로운 팔로워';
      case SocialActionType.mention:
        return '새로운 멘션';
      case SocialActionType.share:
        return '새로운 공유';
    }
  }

  String _generateSocialContent(SocialActionType actionType, String postId) {
    switch (actionType) {
      case SocialActionType.like:
        return '게시물에 좋아요를 받았습니다';
      case SocialActionType.comment:
        return '게시물에 새 댓글이 달렸습니다';
      case SocialActionType.friendRequest:
        return '친구 요청을 받았습니다';
      case SocialActionType.friendAccepted:
        return '친구 요청이 수락되었습니다';
      case SocialActionType.follow:
        return '새로운 팔로워가 있습니다';
      case SocialActionType.mention:
        return '게시물에서 멘션되었습니다';
      case SocialActionType.share:
        return '게시물이 공유되었습니다';
    }
  }

  // ===== 통계 및 분석 =====

  @override
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    try {
      // Datasource에서 통계 데이터 가져오기
      final stats = await _remoteDatasource.getNotificationStats(userId);
      
      // 기본값 보장
      return {
        'totalNotifications': stats['totalNotifications'] ?? 0,
        'unreadCount': stats['unreadCount'] ?? 0,
        'votingRequests': stats['votingRequests'] ?? 0,
        'systemAlerts': stats['systemAlerts'] ?? 0,
        'socialNotifications': stats['socialNotifications'] ?? 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('[NotificationRepository] Error getting notification stats: $e');
      // 에러 시 기본값 반환
      return {
        'totalNotifications': 0,
        'unreadCount': 0,
        'votingRequests': 0,
        'systemAlerts': 0,
        'socialNotifications': 0,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      // Datasource에서 활동 로그 가져오기
      final logs = await _remoteDatasource.getNotificationActivityLog(
        userId: userId,
        from: from,
        to: to,
      );
      
      // 로그 정보 포맷팅
      return logs.map((log) => {
        'timestamp': log['timestamp'] ?? DateTime.now().toIso8601String(),
        'action': log['action'] ?? 'unknown',
        'notificationId': log['notificationId'] ?? '',
        'notificationType': log['notificationType'] ?? '',
        'details': log['details'] ?? {},
      }).toList();
    } catch (e) {
      print('[NotificationRepository] Error getting activity log: $e');
      return [];
    }
  }

  // ===== Clean Architecture Methods (New) =====

  @override
  Future<void> initializeNotificationSystem({required String userId}) async {
    try {
      // Initialize NotificationQueueService
      // Note: Actual implementation would initialize the notification system
      // For now, we'll just clear the cache and prepare for listening
      await _localDatasource.clearCache(userId);
      print(
          '[NotificationRepository] Notification system initialized for user: $userId');
    } catch (e) {
      throw Exception('Failed to initialize notification system: $e');
    }
  }

  @override
  Future<Stream<Notification>> startListening({required String userId}) async {
    try {
      // Start listening to notification stream from remote datasource
      final stream = _remoteDatasource.watchUserNotifications(userId: userId);

      // Transform stream to domain models
      return stream.expand((dataList) => dataList).map((data) {
        final dto = _createDtoFromMap(data);
        return NotificationMapper.toDomain(dto);
      });
    } catch (e) {
      throw Exception('Failed to start notification listening: $e');
    }
  }

  @override
  Stream<int> getUnreadNotificationCount(String userId) {
    // Create a stream controller to emit unread count updates
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      try {
        final notifications = await getUserNotifications(
          userId: userId,
          filter: NotificationFilter(unreadOnly: true),
        );
        return notifications.length;
      } catch (e) {
        print('[NotificationRepository] Error getting unread count: $e');
        return 0;
      }
    }).asyncMap((future) => future);
  }

  @override
  Future<void> stopListening({required String userId}) async {
    try {
      // Stop listening to notifications
      // Note: Actual implementation would stop any active streams
      // For now, just clear cache
      await _localDatasource.clearCache(userId);
      print('[NotificationRepository] Stopped listening for user: $userId');
    } catch (e) {
      throw Exception('Failed to stop notification listening: $e');
    }
  }

  // ===== Private Helper Methods =====

  /// Map 데이터를 적절한 DTO로 변환
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

  /// 추가 필터 적용
  List<Notification> _applyFilter(
    List<Notification> notifications,
    NotificationFilter? filter,
  ) {
    if (filter == null) return notifications;

    var filtered = notifications;

    // Exclude expired notifications if requested
    if (filter.excludeExpired == true) {
      filtered = filtered.where((n) => !n.isExpired).toList();
    }

    // 정렬
    if (filter.sortBy == 'priority') {
      filtered.sort((a, b) {
        // Note: VoteNotification priority sorting is now handled by Voting Feature
        // Default priority comparison for system and social notifications
        final aPriority = 0;
        final bPriority = 0;

        if (filter.sortOrder == SortOrder.descending) {
          return bPriority.compareTo(aPriority);
        } else {
          return aPriority.compareTo(bPriority);
        }
      });
    } else {
      // 기본 정렬 (생성일)
      filtered.sort((a, b) {
        if (filter.sortOrder == SortOrder.descending) {
          return b.createdAt.compareTo(a.createdAt);
        } else {
          return a.createdAt.compareTo(b.createdAt);
        }
      });
    }

    // Limit 적용
    if (filter.limit != null && filtered.length > filter.limit!) {
      filtered = filtered.take(filter.limit!).toList();
    }

    return filtered;
  }

  // ================== NotificationContract 구현 ==================
  // 다른 Feature들이 Notification 기능을 사용할 때 호출하는 메서드들

  @override
  Future<void> sendNotification({
    required String userId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      // 알림 생성 (Domain createNotification 재사용)
      final notificationData = {
        'userId': userId,
        'type': type,
        'data': data,
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      await _remoteDatasource.createNotification(notificationData);
    } catch (e) {
      print('[NotificationContract] Failed to send notification: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamUserNotifications(String userId) {
    try {
      // Stream으로 실시간 알림 목록 반환 (Domain watchUserNotifications 재사용)
      return watchUserNotifications(userId: userId).map((notifications) {
        return notifications.map((notif) {
          // Domain model을 Map으로 변환하여 반환
          final dto = NotificationMapper.toDto(notif);
          return dto.toJson();
        }).toList();
      });
    } catch (e) {
      print('[NotificationContract] Failed to stream user notifications: $e');
      return Stream.value([]);
    }
  }

  @override
  Stream<Map<String, dynamic>> getRealTimeNotifications(String userId) {
    try {
      // 실시간 알림 스트림
      return _remoteDatasource.getRealTimeNotificationStream(userId);
    } catch (e) {
      print('[NotificationContract] Failed to get real-time notifications: $e');
      return Stream.empty();
    }
  }

  @override
  Future<Map<String, bool>> getNotificationSettings(String userId) async {
    try {
      // 알림 설정 조회
      final settings = await _localDatasource.getNotificationSettings(userId);
      return settings ?? {
        'pushEnabled': true,
        'emailEnabled': false,
        'voteRequests': true,
        'socialUpdates': true,
        'systemAlerts': true,
      };
    } catch (e) {
      print('[NotificationContract] Failed to get notification settings: $e');
      return {};
    }
  }

  @override
  Future<void> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  }) async {
    try {
      // 알림 설정 업데이트
      await _localDatasource.saveNotificationSettings(userId, settings);
    } catch (e) {
      print('[NotificationContract] Failed to update notification settings: $e');
      rethrow;
    }
  }

  // ===== NotificationContract 라이프사이클 메서드 구현 =====

  @override
  Future<void> initializeNotifications(String userId) async {
    // InitializeNotificationsUseCase 로직 위임
    await initializeNotificationSystem(userId: userId);
  }

  @override
  Future<void> startNotificationListening(String userId) async {
    // StartNotificationListeningUseCase 로직 위임
    // 1. Repository의 startListening (Domain 모델 스트림)
    await startListening(userId: userId);

    // 2. NotificationQueueService 시작 (실시간 다이얼로그 표시)
    // 현재는 투표 알림만 처리하므로 voting_request 타입으로 필터링
    _queueService.startListening(
      userId: userId,
      type: NotificationTypes.votingRequest,
    );
  }

  @override
  Future<void> stopNotificationListening(String userId) async {
    // StopNotificationListeningUseCase 로직 위임
    await stopListening(userId: userId);
  }

  @override
  Future<void> clearNotificationQueue(String userId) async {
    // ClearQueueUseCase 로직 위임
    try {
      // 1. 읽지 않은 알림들을 모두 읽음 처리
      final notifications = await getUserNotifications(userId: userId);
      final unreadNotifications = notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        await updateNotification(
          notification.id,
          {
            'isRead': true,
            'readAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          },
        );
      }

      // 2. 만료된 알림 정리
      await cleanupExpiredNotifications(userId);
    } catch (e) {
      print('[NotificationContract] Failed to clear notification queue: $e');
      rethrow;
    }
  }
}
