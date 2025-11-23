import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../entities/notification.dart';
import '../repositories/i_notification_repository.dart';
import '../value_objects/notification_filter.dart';
import '../failures/notification_failure.dart';

/// UseCase for getting user notifications
/// Clean Architecture - Domain Business Logic
///
/// **Phase 1 Complete**: Either Pattern 적용
/// - Uses fpdart Either<L,R> for type-safe error handling
/// - Repository returns Either, no need for try-catch
/// - Uses fold() to handle Either results
/// - Implements business rules for filtering and sorting
class GetUserNotificationsUseCase {
  final INotificationRepository _repository;

  GetUserNotificationsUseCase(this._repository);

  Future<Either<NotificationFailure, List<Notification>>> call(
      GetUserNotificationsParams params) async {
    final filter = params.filter ?? NotificationFilter.unreadActive();

    DevLogger.params({
      'userId': params.userId,
      'unreadOnly': filter.unreadOnly ?? false,
      'type': filter.type ?? 'all',
      'excludeExpired': params.excludeExpired,
      'sortByPriority': params.sortByPriority,
      'limit': params.limit ?? filter.limit ?? 'unlimited',
    }, tag: 'GetUserNotifications');

    // Repository 호출 (Either 반환)
    DevLogger.checkpoint('Fetching notifications from repository', tag: 'GetUserNotifications');
    final result = await _repository.getUserNotifications(params.userId);

    // fold()로 Either 처리하며 비즈니스 로직 적용
    return result.fold(
      // Left: 에러를 그대로 전달
      (failure) {
        DevLogger.error(
          'Failed to fetch notifications',
          error: failure,
          tag: 'GetUserNotifications',
        );
        return left(failure);
      },
      // Right: 성공 시 비즈니스 로직 적용
      (notifications) {
        final originalCount = notifications.length;
        DevLogger.checkpoint(
          'Applying filters to $originalCount notifications',
          tag: 'GetUserNotifications',
        );

        // 비즈니스 로직 1: 필터 적용
        var filtered = notifications;

        // 읽지 않은 알림만 필터링
        if (filter.unreadOnly == true) {
          filtered = filtered.where((n) => !n.isRead).toList();
          DevLogger.checkpoint(
            'Unread filter: ${filtered.length}/$originalCount',
            tag: 'GetUserNotifications',
          );
        }

        // 타입별 필터링
        if (filter.type != null) {
          filtered = filtered.where((n) => n.type == filter.type).toList();
          DevLogger.checkpoint(
            'Type filter (${filter.type}): ${filtered.length}/$originalCount',
            tag: 'GetUserNotifications',
          );
        }

        // 비즈니스 로직 2: 만료된 알림 자동 필터링
        if (params.excludeExpired || filter.excludeExpired == true) {
          final beforeExpiredFilter = filtered.length;
          filtered = filtered.where((n) => !n.isExpired).toList();
          DevLogger.checkpoint(
            'Expired filter: ${filtered.length}/$beforeExpiredFilter',
            tag: 'GetUserNotifications',
          );
        }

        // 날짜 범위 필터링
        if (filter.after != null) {
          filtered = filtered.where((n) => n.createdAt.isAfter(filter.after!)).toList();
        }
        if (filter.before != null) {
          filtered = filtered.where((n) => n.createdAt.isBefore(filter.before!)).toList();
        }

        // 비즈니스 로직 3: 우선순위 정렬
        if (params.sortByPriority) {
          DevLogger.checkpoint('Sorting by priority', tag: 'GetUserNotifications');
          filtered.sort((a, b) => b.priority.compareTo(a.priority));
        } else if (filter.sortBy != null) {
          // 필터에 정렬 기준이 있으면 적용
          if (filter.sortOrder == SortOrder.descending) {
            filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else {
            filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          }
        }

        // 비즈니스 로직 4: 최대 개수 제한
        final limit = params.limit ?? filter.limit;
        if (limit != null && filtered.length > limit) {
          filtered = filtered.take(limit).toList();
          DevLogger.checkpoint(
            'Limit applied: ${filtered.length}/$originalCount (limit: $limit)',
            tag: 'GetUserNotifications',
          );
        }

        DevLogger.result(
          isSuccess: true,
          data: '${filtered.length}/$originalCount notifications after filtering',
          tag: 'GetUserNotifications',
        );

        return right(filtered);
      },
    );
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
