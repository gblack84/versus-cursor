import '../repositories/i_notification_repository.dart';
import 'base/stream_use_case.dart';

/// UseCase for watching unread notification count
/// Clean Architecture - Domain Business Logic with Reactive Programming
class WatchUnreadCountUseCase implements StreamUseCase<String, int> {
  final INotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  @override
  Stream<int> call(String userId) {
    // 비즈니스 로직: 읽지 않은 알림 개수 실시간 감시
    return _repository.watchUnreadCount(userId).map((count) {
      // 비즈니스 규칙: 최대 99+로 표시
      if (count > 99) {
        return 99; // UI에서 "99+"로 표시
      }
      return count;
    });
  }
}
