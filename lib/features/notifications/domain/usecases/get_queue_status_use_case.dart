import '../repositories/i_notification_repository.dart';
import 'base/use_case.dart';

/// 알림 큐 상태를 조회하는 UseCase
/// Clean Architecture - 알림 큐 상태 비즈니스 로직
class GetQueueStatusUseCase implements UseCase<void, Map<String, dynamic>> {
  final INotificationRepository _repository;

  GetQueueStatusUseCase(
    this._repository,
  );

  @override
  Future<Result<Map<String, dynamic>>> call(void params) async {
    try {
      // 서비스에서 큐 상태 조회
      final queueSize = await _getQueueSize();
      final isShowingNotification = await _isShowingNotification();
      final processedCount = await _getProcessedCount();
      
      final status = {
        'initialized': true,
        'queueSize': queueSize,
        'isShowingNotification': isShowingNotification,
        'processedCount': processedCount,
        'hasUIContext': true, // UI context는 presentation layer에서 확인
      };

      return Result.success(status);
    } catch (e) {
      return Result.failure('Failed to get queue status: ${e.toString()}');
    }
  }

  Future<int> _getQueueSize() async {
    try {
      // 읽지 않은 알림 개수를 큐 크기로 사용
      final unreadCount = await _repository.getUnreadCount('current_user');
      return unreadCount;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> _isShowingNotification() async {
    // 현재 알림 표시 상태는 서비스에서 관리
    // 실제 구현은 GlobalNotificationManager와 연동
    return false;
  }

  Future<int> _getProcessedCount() async {
    try {
      // 읽은 알림 개수를 처리된 개수로 사용
      final allNotifications = await _repository.getUserNotifications(
        userId: 'current_user',
      );
      return allNotifications.where((n) => n.isRead).length;
    } catch (_) {
      return 0;
    }
  }
}