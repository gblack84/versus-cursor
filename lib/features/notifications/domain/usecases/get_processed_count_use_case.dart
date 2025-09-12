import '../repositories/i_notification_repository.dart';
import 'base/use_case.dart';

/// 처리된 알림 개수를 조회하는 UseCase
/// Clean Architecture - 처리된 알림 통계 비즈니스 로직
class GetProcessedCountUseCase implements UseCase<String, int> {
  final INotificationRepository _repository;

  GetProcessedCountUseCase(this._repository);

  @override
  Future<Result<int>> call(String userId) async {
    try {
      // 파라미터 검증
      if (userId.isEmpty) {
        return const Result.failure('User ID is required');
      }

      // 사용자의 모든 알림 조회
      final notifications = await _repository.getUserNotifications(
        userId: userId,
      );

      // 처리된(읽은) 알림 개수 계산
      final processedCount = notifications.where((n) => n.isRead).length;

      return Result.success(processedCount);
    } catch (e) {
      return Result.failure('Failed to get processed count: ${e.toString()}');
    }
  }

  /// 특정 기간 동안의 처리된 알림 개수 조회
  Future<Result<int>> getProcessedCountByPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final notifications = await _repository.getUserNotifications(
        userId: userId,
      );

      // 기간 내 처리된 알림 필터링
      final processedInPeriod = notifications.where((n) {
        return n.isRead &&
            n.readAt != null &&
            n.readAt!.isAfter(startDate) &&
            n.readAt!.isBefore(endDate);
      }).length;

      return Result.success(processedInPeriod);
    } catch (e) {
      return Result.failure(
        'Failed to get processed count by period: ${e.toString()}',
      );
    }
  }

  /// 타입별 처리된 알림 개수 조회
  Future<Result<Map<String, int>>> getProcessedCountByType(
    String userId,
  ) async {
    try {
      final notifications = await _repository.getUserNotifications(
        userId: userId,
      );

      final countByType = <String, int>{};
      
      for (final notification in notifications.where((n) => n.isRead)) {
        final typeKey = notification.type.name;
        countByType[typeKey] = (countByType[typeKey] ?? 0) + 1;
      }

      return Result.success(countByType);
    } catch (e) {
      return Result.failure(
        'Failed to get processed count by type: ${e.toString()}',
      );
    }
  }
}