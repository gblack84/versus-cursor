import 'package:fpdart/fpdart.dart';

import '../entities/notification.dart';
import '../value_objects/notification_filter.dart';
import '../failures/notification_failure.dart';

/// Repository interface for Notification-related operations
/// Clean Architecture - Domain Repository Interface (Firebase 의존성 없음)
///
/// **Phase 1 Complete**: Either Pattern 적용
/// - Exception-based → Either<NotificationFailure, T>
/// - Nullable 제거 → Either 사용
/// - Stream은 Either 미사용 (Stream.error()로 처리)
///
/// **Phase 4 Complete**: Idempotency Integration
/// - 모든 Write 작업에 eventId 파라미터 추가
/// - IdempotencyService를 통한 중복 방지
/// - Transaction 패턴으로 안전성 보장
abstract class INotificationRepository {
  // ===== CRUD Operations (Either 패턴) =====

  /// 사용자의 알림 목록 조회
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  );

  /// 알림 전송
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId,
  );

  /// 단일 알림 조회
  /// ✅ Nullable 제거, Either 사용
  Future<Either<NotificationFailure, Notification>> getNotification(String id);

  /// 알림 읽음 처리
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String eventId,
  );

  /// 알림 삭제
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String eventId,
  );

  /// 모든 알림을 읽음으로 표시
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> markAllAsRead(
    String userId,
    String eventId,
  );

  /// 사용자의 모든 알림 삭제
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
    String userId,
    String eventId,
  );

  /// 오래된 알림 삭제
  Future<Either<NotificationFailure, Unit>> deleteOldNotifications({
    required String userId,
    required DateTime before,
  });

  /// 만료된 알림 자동 삭제
  Future<Either<NotificationFailure, Unit>> deleteExpiredNotifications(
    String userId,
  );

  /// 만료된 알림 정리 (동일한 기능, 다른 이름으로 호환성 유지)
  Future<Either<NotificationFailure, Unit>> cleanupExpiredNotifications(
    String userId,
  );

  /// 읽지 않은 알림 개수 조회
  Future<Either<NotificationFailure, int>> getUnreadCount(String userId);

  /// 특정 타입의 알림 조회
  Future<Either<NotificationFailure, List<T>>> getNotificationsByType<
      T extends Notification>({
    required String userId,
    required String type,
    int? limit,
  });

  /// 새 알림 생성
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, String>> createNotification(
    Notification notification,
    String eventId,
  );

  /// 알림 업데이트 (읽음 처리 등)
  Future<Either<NotificationFailure, Unit>> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  );

  /// 시스템 알림 브로드캐스트
  Future<Either<NotificationFailure, Unit>> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  });

  /// 소셜 알림 그룹화 처리
  Future<Either<NotificationFailure, Unit>> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  });

  /// 알림 통계 조회
  Future<Either<NotificationFailure, Map<String, dynamic>>>
      getNotificationStats(String userId);

  /// 알림 활동 로그
  Future<Either<NotificationFailure, List<Map<String, dynamic>>>>
      getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  });

  /// 알림 시스템 초기화
  Future<Either<NotificationFailure, Unit>> initializeNotificationSystem({
    required String userId,
  });

  // ===== Queries (Stream) =====
  // Note: Stream은 Either 미사용 (Stream.error()로 처리)

  /// 읽지 않은 알림 개수 실시간 감시
  Stream<int> watchUnreadCount(String userId);

  /// 사용자 알림 실시간 감시
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  /// 읽지 않은 알림 개수 실시간 스트림 (NotificationBadgeProvider에서 사용)
  Stream<int> getUnreadNotificationCount(String userId);

  /// 알림 리스너 시작
  Future<Stream<Notification>> startListening({
    required String userId,
  });

  /// 알림 리스너 중지
  Future<Either<NotificationFailure, Unit>> stopListening({
    required String userId,
  });
}
