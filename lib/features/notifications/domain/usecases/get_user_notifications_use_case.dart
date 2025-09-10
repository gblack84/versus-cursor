import '../models/notification.dart';
import '../repositories/i_notification_repository.dart';
import '../value_objects/notification_filter.dart';
import 'base/use_case.dart';

/// UseCase for getting user notifications
/// Clean Architecture - Domain Business Logic
class GetUserNotificationsUseCase implements UseCase<GetUserNotificationsParams, List<Notification>> {
  final INotificationRepository _repository;

  GetUserNotificationsUseCase(this._repository);

  @override
  Future<Result<List<Notification>>> call(GetUserNotificationsParams params) async {
    try {
      // 비즈니스 로직: 필터 생성
      var filter = params.filter ?? NotificationFilter.unreadActive();
      
      // 비즈니스 규칙: 만료된 알림 자동 필터링
      if (params.excludeExpired) {
        filter = filter.copyWith(excludeExpired: true);
      }
      
      // Repository 호출
      final notifications = await _repository.getUserNotifications(
        userId: params.userId,
        filter: filter,
      );
      
      // 비즈니스 로직: 우선순위 정렬
      if (params.sortByPriority) {
        notifications.sort((a, b) => b.priority.compareTo(a.priority));
      }
      
      // 비즈니스 로직: 만료 알림 제거 (더블 체크)
      final activeNotifications = notifications
          .where((n) => !n.isExpired || !params.excludeExpired)
          .toList();
      
      // 비즈니스 로직: 최대 개수 제한
      if (params.limit != null && activeNotifications.length > params.limit!) {
        return Result.success(activeNotifications.take(params.limit!).toList());
      }
      
      return Result.success(activeNotifications);
    } catch (e) {
      return Result.failure('Failed to get notifications: ${e.toString()}');
    }
  }
}

/// Parameters for GetUserNotificationsUseCase
class GetUserNotificationsParams {
  final String userId;
  final NotificationFilter? filter;
  final bool excludeExpired;
  final bool sortByPriority;
  final int? limit;

  const GetUserNotificationsParams({
    required this.userId,
    this.filter,
    this.excludeExpired = true,
    this.sortByPriority = true,
    this.limit,
  });
}