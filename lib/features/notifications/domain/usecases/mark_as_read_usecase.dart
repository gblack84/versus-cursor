import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '/services/logging/dev_logger.dart';
import '../repositories/i_notification_repository.dart';
import '../failures/notification_failure.dart';

/// UseCase for marking notification as read
/// Clean Architecture - Domain Business Logic
///
/// **Phase 1 Complete**: Either Pattern 적용
/// - Uses fpdart Either<L,R> for type-safe error handling
/// - Repository returns Either, no need for try-catch
/// - Uses fold() to handle Either results
/// - Implements business rules for notification ownership
class MarkAsReadUseCase {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    DevLogger.params({
      'notificationId': params.notificationId,
      'userId': params.userId,
    }, tag: 'MarkAsRead');

    // 비즈니스 규칙: 권한 검증
    if (params.userId.isEmpty || params.notificationId.isEmpty) {
      DevLogger.validation(
        field: 'userId/notificationId',
        reason: 'User ID and Notification ID cannot be empty',
        tag: 'MarkAsRead',
      );
      return left(const NotificationFailure.invalidNotificationData());
    }

    // 비즈니스 로직: 알림 조회하여 소유자 확인
    DevLogger.checkpoint('Fetching notification for ownership verification', tag: 'MarkAsRead');
    final notificationResult =
        await _repository.getNotification(params.notificationId);

    // fold()로 Either 처리
    return notificationResult.fold(
      // Left: 알림 조회 실패
      (failure) {
        DevLogger.error(
          'Failed to fetch notification',
          error: failure,
          tag: 'MarkAsRead',
        );
        return left(failure);
      },
      // Right: 알림 조회 성공, 추가 검증 수행
      (notification) async {
        // 비즈니스 규칙: 본인 알림만 읽음 처리 가능
        if (notification.userId != params.userId) {
          DevLogger.validation(
            field: 'ownership',
            reason: 'User does not own this notification',
            tag: 'MarkAsRead',
          );
          return left(const NotificationFailure.permissionDenied());
        }

        // 비즈니스 규칙: 이미 읽은 알림은 스킵 (Idempotent)
        if (notification.isRead) {
          DevLogger.checkpoint(
            'Notification already read (idempotent operation)',
            tag: 'MarkAsRead',
          );
          DevLogger.result(
            isSuccess: true,
            data: 'Notification already marked as read',
            tag: 'MarkAsRead',
          );
          return right(unit); // 이미 읽음, 성공으로 처리
        }

        // Repository 호출 - Either 반환 (eventId 생성)
        final eventId = const Uuid().v4();
        DevLogger.checkpoint(
          'Marking notification as read (eventId: $eventId)',
          tag: 'MarkAsRead',
        );
        final markResult = await _repository.markAsRead(
          params.notificationId,
          eventId, // UUID 생성
        );

        // 도메인 이벤트 발생 (옵션 - EventBus 통합 시)
        // _eventBus.fire(NotificationReadEvent(notificationId: params.notificationId));

        markResult.fold(
          (failure) {
            DevLogger.error(
              'Failed to mark notification as read',
              error: failure,
              tag: 'MarkAsRead',
            );
          },
          (_) {
            DevLogger.result(
              isSuccess: true,
              data: 'Notification marked as read (eventId: $eventId)',
              tag: 'MarkAsRead',
            );
          },
        );

        return markResult; // Either<NotificationFailure, Unit> 반환
      },
    );
  }
}

/// Parameters for MarkAsReadUseCase
class MarkAsReadParams {
  final String notificationId;
  final String userId;

  const MarkAsReadParams({
    required this.notificationId,
    required this.userId,
  });
}
