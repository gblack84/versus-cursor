import 'dart:async';

/// Notifications Feature가 다른 Feature들에게 제공하는 계약
///
/// Posts, Chat 등이 알림 기능을 사용할 때 접근
abstract class NotificationContract {
  /// 알림 전송 (Posts, Chat 등에서 사용)
  /// Domain의 createNotification과 구분하기 위해 send prefix 사용
  Future<void> sendNotification({
    required String userId,
    required String type,
    required Map<String, dynamic> data,
  });

  /// 사용자 알림 스트림 (실시간 업데이트)
  /// Domain의 getUserNotifications와 구분하기 위해 stream prefix 사용
  Stream<List<Map<String, dynamic>>> streamUserNotifications(String userId);

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

  // ===== 알림 시스템 라이프사이클 관리 =====

  /// 알림 시스템 초기화 (앱 시작 시 호출)
  Future<void> initializeNotifications(String userId);

  /// 알림 리스닝 시작
  Future<void> startNotificationListening(String userId);

  /// 알림 리스닝 중지 (로그아웃 시 호출)
  Future<void> stopNotificationListening(String userId);

  /// 알림 큐 비우기
  Future<void> clearNotificationQueue(String userId);
}