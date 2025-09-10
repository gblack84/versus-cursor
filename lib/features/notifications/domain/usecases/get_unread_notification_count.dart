import '/features/notifications/domain/repositories/i_notification_repository.dart';

/// 읽지 않은 알림 개수를 실시간으로 가져오는 UseCase
class GetUnreadNotificationCountUseCase {
  final INotificationRepository _repository;

  GetUnreadNotificationCountUseCase(this._repository);

  Stream<int> execute(String userId) {
    return _repository.getUnreadNotificationCount(userId);
  }
}