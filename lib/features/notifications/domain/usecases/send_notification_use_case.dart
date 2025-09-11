import '../models/notification.dart';
import '../models/vote_notification.dart';
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
      if (params.notification is VoteNotification) {
        return await _sendVoteNotifications(params);
      }

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

  Future<Result<List<String>>> _sendVoteNotifications(
      SendNotificationParams params) async {
    final voteNotification = params.notification as VoteNotification;

    // 비즈니스 로직: 타겟 오디언스에 따른 사용자 선택
    List<String> finalTargetUsers = params.targetUserIds;

    if (params.targetAudience == 'quick') {
      // AI 기반 타겟팅 (실제 구현에서는 AI 서비스 호출)
      // finalTargetUsers = await _aiService.selectBestUsers(voteNotification, params.targetUserIds);

      // 비즈니스 규칙: Quick mode는 최대 10명
      if (finalTargetUsers.length > 10) {
        finalTargetUsers = finalTargetUsers.take(10).toList();
      }
    } else if (params.targetAudience == 'public') {
      // 랜덤 선택 로직
      finalTargetUsers.shuffle();
      if (finalTargetUsers.length > 20) {
        finalTargetUsers = finalTargetUsers.take(20).toList();
      }
    }

    // Repository 호출
    final createdIds = await _repository.createVoteNotifications(
      baseNotification: voteNotification,
      targetUserIds: finalTargetUsers,
    );

    return Result.success(createdIds);
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
