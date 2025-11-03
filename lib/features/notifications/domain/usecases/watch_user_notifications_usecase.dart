import '../entities/notification.dart';
import '../repositories/i_notification_repository.dart';
import '../value_objects/notification_filter.dart';
import 'base/stream_use_case.dart';

/// UseCase for watching user notifications stream
///
/// Clean Architecture - Domain Business Logic with Reactive Programming
/// Observes real-time notification updates for a specific user
///
/// **Phase 1 Complete**: Stream methods unchanged
/// - Streams don't use Either pattern (use Stream.error() instead)
/// - Business logic applied via Repository filter parameters
///
/// Example:
/// ```dart
/// final useCase = WatchUserNotificationsUseCase(repository);
/// final stream = useCase.call(userId);
///
/// stream.listen((notifications) {
///   print('Received ${notifications.length} notifications');
/// });
/// ```
class WatchUserNotificationsUseCase
    implements StreamUseCase<String, List<Notification>> {
  final INotificationRepository _repository;

  WatchUserNotificationsUseCase(this._repository);

  /// Watch notifications stream for the given user ID
  ///
  /// Returns a stream of notification lists that updates in real-time
  /// Excludes expired notifications by default
  ///
  /// [userId] - The ID of the user whose notifications to watch
  @override
  Stream<List<Notification>> call(String userId) {
    // Business rule: Exclude expired notifications by default
    return _repository.watchUserNotifications(
      userId: userId,
      filter: const NotificationFilter(
        excludeExpired: true,
      ),
    );
  }
}
