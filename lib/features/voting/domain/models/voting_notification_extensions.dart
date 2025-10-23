import '/features/notifications/domain/models/notification.dart';

/// VotingNotification Extension - 비즈니스 로직 메서드
///
/// VoteNotification에서 마이그레이션된 12개 비즈니스 로직
/// Notification Union의 voting 케이스에 Extension으로 추가
extension VotingNotificationExtensions on VotingNotification {
  // ===== 투표 관련 비즈니스 로직 =====

  /// 투표가 활성 상태인지 확인
  bool get isVoteActive {
    final now = DateTime.now();
    return now.isAfter(voteStartTime) && now.isBefore(voteEndTime);
  }

  /// 투표가 종료되었는지 확인
  bool get isVoteEnded {
    return DateTime.now().isAfter(voteEndTime);
  }

  /// 투표가 아직 시작되지 않았는지 확인
  bool get isVotePending {
    return DateTime.now().isBefore(voteStartTime);
  }

  /// 남은 투표 시간
  Duration? get remainingTime {
    if (isVoteEnded) return null;
    if (isVotePending) return voteEndTime.difference(voteStartTime);
    return voteEndTime.difference(DateTime.now());
  }

  /// 전체 투표 기간
  Duration get totalVotingDuration {
    return voteEndTime.difference(voteStartTime);
  }

  /// 투표 진행률 (퍼센트)
  double get completionPercentage {
    if (isVotePending) return 0.0;
    if (isVoteEnded) return 100.0;

    final elapsed = DateTime.now().difference(voteStartTime);
    final total = totalVotingDuration;
    if (total.inSeconds == 0) return 0.0;

    return (elapsed.inSeconds / total.inSeconds * 100).clamp(0.0, 100.0);
  }

  /// 사용자가 투표할 수 있는지 확인 (알림 UI 표시용)
  /// Note: 실제 투표 로직은 Voting Feature에서 처리
  bool get canUserVote {
    final isExpired = expiryTime != null && DateTime.now().isAfter(expiryTime!);
    return isVoteActive && !hasVoted && !isExpired;
  }

  /// 투표 상태 문자열
  String get voteStatus {
    if (isVotePending) return 'pending';
    if (isVoteActive) return 'active';
    if (isVoteEnded) return 'ended';
    return 'unknown';
  }

  /// 남은 시간 포맷팅
  String get formattedRemainingTime {
    final remaining = remainingTime;
    if (remaining == null) return '종료됨';

    if (remaining.inDays > 0) {
      return '${remaining.inDays}일 ${remaining.inHours % 24}시간';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}시간 ${remaining.inMinutes % 60}분';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}분 ${remaining.inSeconds % 60}초';
    } else {
      return '${remaining.inSeconds}초';
    }
  }

  /// 전체 투표 수
  int get totalVotes => (currentVotesA ?? 0) + (currentVotesB ?? 0);

  /// A 옵션 승률 (0-100%)
  double? get optionAPercentage {
    if (totalVotes == 0) return null;
    return ((currentVotesA ?? 0) / totalVotes * 100).clamp(0.0, 100.0);
  }

  /// B 옵션 승률 (0-100%)
  double? get optionBPercentage {
    if (totalVotes == 0) return null;
    return ((currentVotesB ?? 0) / totalVotes * 100).clamp(0.0, 100.0);
  }

  /// 승리 옵션 ('A', 'B', 또는 'draw')
  String get winningOption {
    final votesA = currentVotesA ?? 0;
    final votesB = currentVotesB ?? 0;

    if (votesA > votesB) return 'A';
    if (votesB > votesA) return 'B';
    return 'draw';
  }
}
