import '../../domain/entities/chat/post_voting.dart';
import '../../domain/entities/chat/vote_state.dart';

/// PostVoting → VoteStateData 변환 Extension
///
/// **VoteStateCoordinator 변환 로직 이동**:
/// - Firebase-Centric Architecture v1.0 Extension 패턴 준수
/// - Coordinator의 getVoteStateStream() 변환 로직을 Extension으로 분리
/// - 기존 로직 100% 동일하게 유지
///
/// **변환 책임**:
/// - 사용자 투표 여부 확인 (votedUserIdsA/B에서)
/// - 타이머 만료 상태 계산
/// - 투표 상태 결정 (votingRequest/inProgress/completed/expired)
/// - 투표 결과 통계 생성 (votes, percent, winner)
extension PostVotingToVoteStateExtension on PostVoting {
  /// PostVoting을 VoteStateData로 변환
  ///
  /// [userId] - 현재 사용자 ID (투표 여부 확인용, null 가능)
  /// [voteEndTime] - 투표 종료 시간
  ///
  /// Returns VoteStateData with:
  /// - state: 투표 상태 (votingRequest/inProgress/completed/expired)
  /// - hasUserVoted: 사용자 투표 여부
  /// - userChoice: 사용자 선택 ('A' or 'B')
  /// - voteResults: 투표 통계 (votes, percent, winner)
  /// - isTimerExpired: 타이머 만료 여부
  VoteStateData toVoteStateData({
    required String? userId,
    required DateTime? voteEndTime,
  }) {
    // ✅ 1. 사용자 투표 여부 확인 (Coordinator line 110-126)
    bool hasUserVoted = false;
    String? userChoice;

    if (userId != null) {
      if (votedUserIdsA.contains(userId)) {
        hasUserVoted = true;
        userChoice = 'A';
      } else if (votedUserIdsB.contains(userId)) {
        hasUserVoted = true;
        userChoice = 'B';
      }
    }

    // ✅ 2. 타이머 상태 확인 (Coordinator line 128-130)
    final isTimerExpired =
        voteEndTime != null && DateTime.now().isAfter(voteEndTime);

    // ✅ 3. 투표 상태 결정 (Coordinator line 132-142)
    VoteState state;
    if (voteCompleted || isTimerExpired) {
      state = VoteState.completed;
    } else if (voteStatus == VoteStatus.timeout) {
      // Coordinator에서는 문자열 'expired' 체크, PostVoting에서는 timeout enum
      state = VoteState.expired;
    } else if (voteStatus == VoteStatus.pending) {
      state = VoteState.votingRequest;
    } else {
      state = VoteState.inProgress;
    }

    // ✅ 4. 투표 결과 추출 (Coordinator._extractVoteResults)
    final voteResults = _extractVoteResults();

    return VoteStateData(
      state: state,
      hasUserVoted: hasUserVoted,
      userChoice: userChoice,
      voteEndTime: voteEndTime,
      isTimerExpired: isTimerExpired,
      remainingTime: isTimerExpired ? Duration.zero : null,
      voteResults: voteResults,
    );
  }

  /// 투표 데이터에서 결과 추출
  ///
  /// Coordinator._extractVoteResults() 로직 동일 (line 179-192)
  Map<String, dynamic> _extractVoteResults() {
    // Percent 계산
    final percentA = totalVotes > 0 ? (votesA / totalVotes * 100) : 0.0;
    final percentB = totalVotes > 0 ? (votesB / totalVotes * 100) : 0.0;

    return {
      'votesA': votesA,
      'votesB': votesB,
      'actualVotesA': votesA,
      'actualVotesB': votesB,
      'percentA': percentA,
      'percentB': percentB,
      'totalVotes': totalVotes,
      'winner': _calculateWinner(),
    };
  }

  /// 승자 계산
  ///
  /// Coordinator._calculateWinner() 로직 동일 (line 195-202)
  String _calculateWinner() {
    if (votesA > votesB) return 'A';
    if (votesB > votesA) return 'B';
    return 'draw';
  }
}
