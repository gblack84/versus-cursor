import '../models/notification.dart';
import '../models/vote_notification.dart';
import '../models/system_notification.dart';
import '../models/social_notification.dart';
import '../value_objects/notification_filter.dart';

/// Repository interface for Notification-related operations
/// Clean Architecture - Domain Repository Interface (Firebase 의존성 없음)
abstract class INotificationRepository {
  // ===== 조회 Operations =====
  
  /// 단일 알림 조회
  Future<Notification?> getNotification(String notificationId);
  
  /// 사용자의 알림 목록 조회
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });
  
  /// 사용자의 알림 스트림 감시
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });
  
  /// 읽지 않은 알림 개수 조회
  Future<int> getUnreadCount(String userId);
  
  /// 읽지 않은 알림 개수 스트림
  Stream<int> watchUnreadCount(String userId);
  
  /// 읽지 않은 알림 개수 실시간 스트림 (NotificationBadgeProvider에서 사용)
  Stream<int> getUnreadNotificationCount(String userId);
  
  /// 특정 타입의 알림 조회
  Future<List<T>> getNotificationsByType<T extends Notification>({
    required String userId,
    required NotificationType type,
    int? limit,
  });

  // ===== 생성/수정 Operations =====
  
  /// 새 알림 생성
  Future<String> createNotification(Notification notification);
  
  /// 알림 업데이트 (읽음 처리 등)
  Future<void> updateNotification(Notification notification);
  
  /// 알림을 읽음으로 표시
  Future<void> markAsRead(String notificationId);
  
  /// 모든 알림을 읽음으로 표시
  Future<void> markAllAsRead(String userId);

  // ===== 삭제 Operations =====
  
  /// 단일 알림 삭제
  Future<void> deleteNotification(String notificationId);
  
  /// 사용자의 모든 알림 삭제
  Future<void> deleteAllNotifications(String userId);
  
  /// 오래된 알림 삭제
  Future<void> deleteOldNotifications({
    required String userId,
    required DateTime before,
  });
  
  /// 만료된 알림 자동 삭제
  Future<void> deleteExpiredNotifications(String userId);

  // ===== 특수 Operations =====
  
  /// 투표 알림 생성 (타겟 사용자 지정)
  Future<List<String>> createVoteNotifications({
    required VoteNotification baseNotification,
    required List<String> targetUserIds,
  });
  
  /// 시스템 알림 브로드캐스트
  Future<void> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  });
  
  /// 소셜 알림 그룹화 처리
  Future<void> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  });

  // ===== 통계 및 분석 =====
  
  /// 알림 통계 조회
  Future<Map<String, dynamic>> getNotificationStats(String userId);
  
  /// 알림 활동 로그
  Future<List<Map<String, dynamic>>> getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  });
}