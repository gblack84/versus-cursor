import '../repositories/i_notification_repository.dart';
import 'base/use_case.dart';

/// UseCase for marking notification as read
/// Clean Architecture - Domain Business Logic
class MarkAsReadUseCase implements UseCase<MarkAsReadParams, void> {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  @override
  Future<Result<void>> call(MarkAsReadParams params) async {
    try {
      // 비즈니스 규칙: 권한 검증
      if (params.userId.isEmpty || params.notificationId.isEmpty) {
        return const Result.failure(
            'Invalid parameters: userId and notificationId are required');
      }

      // 비즈니스 로직: 알림 조회하여 소유자 확인
      final notification =
          await _repository.getNotification(params.notificationId);

      if (notification == null) {
        return const Result.failure('Notification not found');
      }

      // 비즈니스 규칙: 본인 알림만 읽음 처리 가능
      if (notification.userId != params.userId) {
        return const Result.failure(
            'Unauthorized: Cannot mark other user\'s notification as read');
      }

      // 비즈니스 규칙: 이미 읽은 알림은 스킵 (Idempotent)
      if (notification.isRead) {
        return const Result.success(null); // 이미 읽음, 성공으로 처리
      }

      // Repository 호출
      await _repository.markAsRead(params.notificationId);

      // 도메인 이벤트 발생 (옵션 - EventBus 통합 시)
      // _eventBus.fire(NotificationReadEvent(notificationId: params.notificationId));

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to mark as read: ${e.toString()}');
    }
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
