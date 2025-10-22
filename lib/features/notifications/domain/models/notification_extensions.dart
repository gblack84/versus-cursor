/// Extension methods for Notification types
/// Clean Architecture - Type-specific business logic

import 'notification.dart';

// ===== Social Notification Extension =====

extension SocialNotificationX on SocialNotification {
  /// 알림을 읽음으로 표시 (copyWith 사용!)
  SocialNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// 그룹 알림에 추가 상호작용 추가
  SocialNotification addInteraction() {
    return copyWith(
      interactionCount: (interactionCount ?? 1) + 1,
    );
  }

  /// 상호작용이 있는 알림인지
  bool get hasInteraction => relatedPostId != null || relatedCommentId != null;

  /// 프로필 이미지가 있는지
  bool get hasProfileImage =>
      fromUserProfileUrl != null && fromUserProfileUrl!.isNotEmpty;

  /// 그룹 알림인지 (여러 사용자의 동일한 액션)
  bool get isGroupNotification => (interactionCount ?? 0) > 1;

  /// 친구 관련 알림인지
  bool get isFriendRelated =>
      actionType == SocialActionType.friendRequest ||
      actionType == SocialActionType.friendAccepted;

  /// 포스트 관련 알림인지
  bool get isPostRelated => relatedPostId != null;

  /// 액션 버튼 텍스트
  String get actionButtonText {
    switch (actionType) {
      case SocialActionType.friendRequest:
        return '수락';
      case SocialActionType.comment:
        return '답글';
      case SocialActionType.mention:
        return '보기';
      default:
        return '확인';
    }
  }

  /// 알림 설명 텍스트 생성
  String get descriptionText {
    if (isGroupNotification) {
      return '$fromUserName님 외 ${interactionCount! - 1}명이 ${_getActionText()}';
    }
    return '$fromUserName님이 ${_getActionText()}';
  }

  String _getActionText() {
    switch (actionType) {
      case SocialActionType.like:
        return '좋아요를 눌렀습니다';
      case SocialActionType.comment:
        return '댓글을 남겼습니다';
      case SocialActionType.friendRequest:
        return '친구 요청을 보냈습니다';
      case SocialActionType.friendAccepted:
        return '친구 요청을 수락했습니다';
      case SocialActionType.follow:
        return '팔로우하기 시작했습니다';
      case SocialActionType.mention:
        return '언급했습니다';
      case SocialActionType.share:
        return '공유했습니다';
    }
  }
}

// ===== System Notification Extension =====

extension SystemNotificationX on SystemNotification {
  /// 알림을 읽음으로 표시
  SystemNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// 액션이 필요한 알림인지 확인
  bool get requiresAction =>
      actionUrl != null || (actionButtons?.isNotEmpty ?? false);

  /// 중요도 레벨
  int get importanceLevel {
    switch (alertType) {
      case SystemAlertType.critical:
        return 5;
      case SystemAlertType.security:
        return 4;
      case SystemAlertType.maintenance:
        return 3;
      case SystemAlertType.update:
        return 2;
      case SystemAlertType.info:
        return 1;
    }
  }

  /// 자동 해제 가능한지
  bool get canAutoDismiss =>
      isDismissible && alertType != SystemAlertType.critical;
}

// ===== Voting Notification Extension =====

extension VotingNotificationX on VotingNotification {
  /// 알림을 읽음으로 표시
  VotingNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// 투표 마감이 임박했는지 (1시간 이내)
  bool get isDeadlineImminent {
    if (voteDeadline == null) return false;
    final timeLeft = voteDeadline!.difference(DateTime.now());
    return timeLeft.inHours < 1 && timeLeft.isNegative == false;
  }

  /// 투표 마감 여부
  bool get isVoteExpired {
    if (voteDeadline == null) return false;
    return DateTime.now().isAfter(voteDeadline!);
  }

  /// 멀티 이미지 여부
  bool get hasMultipleImages {
    final countA = imageUrlsA?.length ?? 0;
    final countB = imageUrlsB?.length ?? 0;
    return countA > 1 || countB > 1;
  }

  /// 남은 투표 시간 (사람이 읽기 쉬운 형식)
  String get remainingTimeText {
    if (voteDeadline == null) return '마감 시간 없음';
    if (isVoteExpired) return '투표 마감';

    final timeLeft = voteDeadline!.difference(DateTime.now());
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays}일 남음';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}시간 남음';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes}분 남음';
    } else {
      return '곧 마감';
    }
  }

  /// 투표 카드 표시 여부 (이미지가 있는 경우만)
  bool get shouldShowVoteCard {
    return (imageUrlsA?.isNotEmpty ?? false) ||
        (imageUrlsB?.isNotEmpty ?? false);
  }
}
