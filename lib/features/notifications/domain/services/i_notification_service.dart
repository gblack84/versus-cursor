import 'dart:async';
import '../models/notification.dart';

/// 알림 서비스 인터페이스
///
/// Domain 레이어에서 정의하는 알림 서비스 계약
/// Data 레이어에서 구현됨
///
/// 모든 타입의 알림(voting, social, system)을 실시간으로 리스닝하는 범용 서비스
/// 각 Feature는 필요한 타입만 필터링해서 사용 가능
abstract class INotificationService {
  /// 알림 스트림
  Stream<List<Notification>> get notificationsStream;

  /// 알림 리스닝 시작
  ///
  /// [userId] - 사용자 ID
  /// [type] - 알림 타입 필터 (null이면 모든 타입)
  ///   예: NotificationTypes.votingRequest, NotificationTypes.postLiked 등
  void startListening(String userId, {String? type});

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