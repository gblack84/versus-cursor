import '../models/notification.dart';
import '../repositories/i_notification_repository.dart';
import 'base/use_case.dart';

/// UseCase for sending notifications to target users
/// Clean Architecture - Domain Business Logic for Notification Creation
class SendNotificationUseCase
    implements UseCase<SendNotificationParams, List<String>> {
  final INotificationRepository _repository;

  SendNotificationUseCase(this._repository);

  @override
  Future<Result<List<String>>> call(SendNotificationParams params) async {
    try {
      // 비즈니스 규칙: 타겟 사용자 검증
      if (params.targetUserIds.isEmpty) {
        return const Result.failure('At least one target user is required');
      }

      // 비즈니스 규칙: 최대 타겟 사용자 수 제한
      const maxTargets = 100;
      if (params.targetUserIds.length > maxTargets) {
        return Result.failure(
            'Cannot send to more than $maxTargets users at once');
      }

      // 알림 타입별 처리
      // Note: VoteNotification is now handled by Voting Feature

      // 일반 알림 처리
      final createdIds = <String>[];
      for (final userId in params.targetUserIds) {
        // 각 사용자별 알림 생성
        final userNotification = _createUserNotification(
          params.notification,
          userId,
        );

        final id = await _repository.createNotification(userNotification);
        createdIds.add(id);
      }

      return Result.success(createdIds);
    } catch (e) {
      return Result.failure('Failed to send notifications: ${e.toString()}');
    }
  }

  Notification _createUserNotification(
      Notification baseNotification, String userId) {
    // 사용자별 알림 생성 (ID와 userId 변경)
    // 실제 구현에서는 각 알림 타입별로 처리
    return baseNotification; // Simplified
  }
}

/// Parameters for SendNotificationUseCase
class SendNotificationParams {
  final Notification notification;
  final List<String> targetUserIds;
  final String? targetAudience; // 'quick', 'public', 'custom'

  const SendNotificationParams({
    required this.notification,
    required this.targetUserIds,
    this.targetAudience,
  });
}
