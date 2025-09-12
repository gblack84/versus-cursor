import 'dart:async';
import '../models/notification.dart';

/// 알림 서비스 인터페이스
///
/// Domain 레이어에서 정의하는 알림 서비스 계약
/// Data 레이어에서 구현됨
abstract class INotificationService {
  /// 알림 스트림
  Stream<List<Notification>> get notificationsStream;

  /// 알림 리스닝 시작
  void startListening(String userId);

  /// 알림 리스닝 중지
  void stopListening();

  /// 사용자의 읽지 않은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount(String userId);

  /// 알림을 읽음으로 표시
  Future<void> markAsRead(String notificationId);

  /// 알림 다시 표시 (답변 거부 시)
  Future<void> reshowNotification(String notificationId);

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId);

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId);

  /// 만료된 알림 정리
  Future<void> cleanupExpiredNotifications(String userId);

  /// 알림 큐 비우기
  void clearQueue();

  /// 서비스 리소스 정리
  void dispose();
}