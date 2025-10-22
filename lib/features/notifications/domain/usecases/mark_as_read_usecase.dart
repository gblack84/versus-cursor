import '/core/types/result.dart';
import '../repositories/i_notification_repository.dart';
import '../failures/notification_failure.dart';
import 'base/use_case.dart';

/// UseCase for marking notification as read
/// Clean Architecture - Domain Business Logic
///
/// **Clean Architecture v4.0 - UseCase with Result Pattern**:
/// - Uses Core Result<T> for type-safe error handling
/// - Returns typed NotificationFailure instead of String errors
/// - Implements business rules for notification ownership
class MarkAsReadUseCase implements UseCase<MarkAsReadParams, void> {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  @override
  Future<Result<void>> call(MarkAsReadParams params) async {
    try {
      // 비즈니스 규칙: 권한 검증
      if (params.userId.isEmpty || params.notificationId.isEmpty) {
        return ResultFailure(Unexpected('잘못된 요청입니다'));
      }

      // 비즈니스 로직: 알림 조회하여 소유자 확인
      final notification =
          await _repository.getNotification(params.notificationId);

      if (notification == null) {
        return ResultFailure(const NotificationNotFound());
      }

      // 비즈니스 규칙: 본인 알림만 읽음 처리 가능
      if (notification.userId != params.userId) {
        return ResultFailure(const PermissionDenied());
      }

      // 비즈니스 규칙: 이미 읽은 알림은 스킵 (Idempotent)
      if (notification.isRead) {
        return const Success(null); // 이미 읽음, 성공으로 처리
      }

      // Repository 호출
      await _repository.markAsRead(params.notificationId);

      // 도메인 이벤트 발생 (옵션 - EventBus 통합 시)
      // _eventBus.fire(NotificationReadEvent(notificationId: params.notificationId));

      return const Success(null);
    } on NotificationFailure catch (failure) {
      // Repository에서 throw된 NotificationFailure 그대로 전달
      return ResultFailure(failure);
    } catch (e) {
      // 예기치 않은 에러
      return ResultFailure(Unexpected(e.toString()));
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
