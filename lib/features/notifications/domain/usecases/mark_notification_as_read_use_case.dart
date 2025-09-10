import '../repositories/i_notification_repository.dart';

/// Parameters for marking notification as read
class MarkAsReadParams {
  final String notificationId;
  
  MarkAsReadParams({required this.notificationId});
}

/// Use case for marking a notification as read
class MarkNotificationAsReadUseCase {
  final INotificationRepository _repository;
  
  MarkNotificationAsReadUseCase(this._repository);
  
  Future<void> call(MarkAsReadParams params) async {
    await _repository.markAsRead(params.notificationId);
  }
}