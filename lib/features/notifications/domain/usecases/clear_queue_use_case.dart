import '../repositories/i_notification_repository.dart';
import '../services/i_notification_service.dart';
import 'base/use_case.dart';

/// 알림 큐를 비우는 UseCase
/// Clean Architecture - 알림 큐 정리 비즈니스 로직
class ClearQueueUseCase implements UseCase<String, void> {
  final INotificationRepository _repository;
  final INotificationService _notificationService;

  ClearQueueUseCase(
    this._repository,
    this._notificationService,
  );

  @override
  Future<Result<void>> call(String userId) async {
    try {
      // 파라미터 검증
      if (userId.isEmpty) {
        return const Result.failure('User ID is required');
      }

      // 1. 서비스 레벨에서 큐 비우기
      _notificationService.clearQueue();

      // 2. 읽지 않은 알림들을 모두 읽음 처리
      await _markAllAsRead(userId);

      // 3. 만료된 알림 정리
      await _cleanupExpiredNotifications(userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear queue: ${e.toString()}');
    }
  }

  /// 모든 알림을 읽음 처리
  Future<void> _markAllAsRead(String userId) async {
    final notifications = await _repository.getUserNotifications(
      userId: userId,
    );

    // 읽지 않은 알림들만 필터링
    final unreadNotifications = notifications.where((n) => !n.isRead);

    // 각 알림을 읽음 처리
    for (final notification in unreadNotifications) {
      await _repository.updateNotification(
        notification.id,
        {
          'isRead': true,
          'readAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      );
    }
  }

  /// 만료된 알림 정리
  Future<void> _cleanupExpiredNotifications(String userId) async {
    try {
      // Repository에 구현된 메서드 호출
      await _repository.cleanupExpiredNotifications(userId);
    } catch (e) {
      // 에러 발생 시 로그만 남기고 계속 진행
      print('Failed to cleanup expired notifications: $e');
    }
  }

  /// 특정 타입의 알림만 큐에서 제거
  Future<Result<void>> clearByType(String userId, String notificationType) async {
    try {
      final notifications = await _repository.getUserNotifications(
        userId: userId,
      );

      // 특정 타입의 읽지 않은 알림만 필터링
      final targetNotifications = notifications.where(
        (n) => !n.isRead && n.type.name == notificationType,
      );

      // 읽음 처리
      for (final notification in targetNotifications) {
        await _repository.updateNotification(
          notification.id,
          {
            'isRead': true,
            'readAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          },
        );
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear by type: ${e.toString()}');
    }
  }
}