import 'dart:async';

/// Notifications Feature가 다른 Feature들에게 제공하는 계약
///
/// Posts, Chat 등이 알림 기능을 사용할 때 접근
abstract class NotificationContract {
  /// 알림 생성
  Future<void> createNotification({
    required String userId,
    required String type,
    required Map<String, dynamic> data,
  });

  /// 투표 요청 알림 생성 (Posts에서 사용)
  Future<void> createVoteRequestNotification({
    required String postId,
    required List<String> targetUserIds,
    required Map<String, dynamic> targetAudience,
  });

  /// 사용자 알림 목록 조회
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId);

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId);

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId);

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId);

  /// 실시간 알림 스트림
  Stream<Map<String, dynamic>> getRealTimeNotifications(String userId);

  /// 알림 설정 조회
  Future<Map<String, bool>> getNotificationSettings(String userId);

  /// 알림 설정 업데이트
  Future<void> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  });
}