import '../models/vote_notification.dart';
import '../repositories/i_notification_repository.dart';
import 'base/use_case.dart';

/// UseCase for processing vote notification and recording user's vote
/// Clean Architecture - Complex Domain Business Logic
class ProcessVoteNotificationUseCase
    implements UseCase<ProcessVoteParams, VoteNotification> {
  final INotificationRepository _notificationRepository;
  // Note: In real implementation, inject IPostRepository here
  // final IPostRepository _postRepository;

  ProcessVoteNotificationUseCase(
    this._notificationRepository,
    // this._postRepository,
  );

  @override
  Future<Result<VoteNotification>> call(ProcessVoteParams params) async {
    try {
      // 비즈니스 규칙: 파라미터 검증
      if (!_isValidVoteChoice(params.voteChoice)) {
        return const Result.failure('Invalid vote choice: Must be A or B');
      }

      // 1. 알림 조회
      final notification =
          await _notificationRepository.getNotification(params.notificationId);

      if (notification == null) {
        return const Result.failure('Notification not found');
      }

      if (notification is! VoteNotification) {
        return const Result.failure('Notification is not a vote notification');
      }

      // 2. 비즈니스 규칙 검증

      // 권한 검증
      if (notification.userId != params.userId) {
        return const Result.failure(
            'Unauthorized: Cannot vote on other user\'s notification');
      }

      // 투표 가능 상태 검증
      if (!notification.canUserVote) {
        if (notification.hasVoted) {
          return const Result.failure('Already voted on this notification');
        }
        if (!notification.isVoteActive) {
          return const Result.failure('Voting period has ended');
        }
        if (notification.isExpired) {
          return const Result.failure('Notification has expired');
        }
        return const Result.failure('Cannot vote on this notification');
      }

      // 3. 투표 처리 (트랜잭션 필요)

      // 3.1 알림에 투표 기록
      final updatedNotification =
          notification.recordUserVote(params.voteChoice);

      // 3.2 알림 업데이트
      await _notificationRepository.updateNotification(updatedNotification);

      // 3.3 포스트에 투표 카운트 증가 (Cross-feature 호출)
      // await _postRepository.incrementVoteCount(
      //   postId: notification.postId,
      //   option: params.voteChoice,
      //   userId: params.userId,
      // );

      // 4. 알림 자동 읽음 처리
      final readNotification = updatedNotification.markAsRead();
      await _notificationRepository.updateNotification(readNotification);

      // 5. 도메인 이벤트 발생
      // _eventBus.fire(VoteCompletedEvent(
      //   notificationId: params.notificationId,
      //   postId: notification.postId,
      //   userId: params.userId,
      //   voteChoice: params.voteChoice,
      // ));

      return Result.success(readNotification);
    } catch (e) {
      return Result.failure('Failed to process vote: ${e.toString()}');
    }
  }

  bool _isValidVoteChoice(String choice) {
    return choice == 'A' || choice == 'B';
  }
}

/// Parameters for ProcessVoteNotificationUseCase
class ProcessVoteParams {
  final String notificationId;
  final String userId;
  final String voteChoice; // 'A' or 'B'

  const ProcessVoteParams({
    required this.notificationId,
    required this.userId,
    required this.voteChoice,
  });
}
