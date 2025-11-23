import '/services/logging/dev_logger.dart';
import '../repositories/i_notification_repository.dart';
import 'base/stream_use_case.dart';

/// UseCase for watching unread notification count
/// Clean Architecture - Domain Business Logic with Reactive Programming
///
/// **Phase 1 Complete**: Stream methods unchanged
/// - Streams don't use Either pattern (use Stream.error() instead)
/// - Business logic applied via Stream operators (map, where, etc.)
class WatchUnreadCountUseCase implements StreamUseCase<String, int> {
  final INotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  @override
  Stream<int> call(String userId) {
    DevLogger.params({'userId': userId}, tag: 'WatchUnreadCount');
    DevLogger.checkpoint('Starting unread count stream', tag: 'WatchUnreadCount');

    // 비즈니스 로직: 읽지 않은 알림 개수 실시간 감시
    return _repository.watchUnreadCount(userId).map((count) {
      // 비즈니스 규칙: 최대 99+로 표시
      final displayCount = count > 99 ? 99 : count;

      DevLogger.result(
        isSuccess: true,
        data: 'Unread count: $count${count > 99 ? " (capped at 99)" : ""}',
        tag: 'WatchUnreadCount',
      );

      return displayCount; // UI에서 "99+"로 표시
    });
  }
}
