/// 투표 상태를 나타내는 열거형
enum VoteState {
  /// 투표 요청 대기 중
  votingRequest,
  
  /// 투표 진행 중
  inProgress,
  
  /// 투표 완료
  completed,
  
  /// 시간 만료
  expired,
  
  /// 미참여
  notParticipated,
}

/// 투표 상태 데이터를 담는 클래스
class VoteStateData {
  /// 현재 투표 상태
  final VoteState state;
  
  /// 남은 시간 (타이머가 있는 경우)
  final Duration? remainingTime;
  
  /// 투표 결과 (완료된 경우)
  final Map<String, dynamic>? voteResults;
  
  /// 타이머 만료 여부
  final bool isTimerExpired;
  
  /// 투표 종료 시간
  final DateTime? voteEndTime;
  
  /// 에러 메시지 (에러 발생 시)
  final String? errorMessage;
  
  /// 사용자가 이미 투표했는지 여부
  final bool hasUserVoted;
  
  /// 사용자의 투표 선택 (A 또는 B)
  final String? userChoice;
  
  const VoteStateData({
    required this.state,
    this.remainingTime,
    this.voteResults,
    this.isTimerExpired = false,
    this.voteEndTime,
    this.errorMessage,
    this.hasUserVoted = false,
    this.userChoice,
  });
  
  /// 상태 텍스트 반환
  String get statusText {
    switch (state) {
      case VoteState.votingRequest:
        return '피클요청';
      case VoteState.inProgress:
        return hasUserVoted ? 'Pick 완료!(진행중)' : '진행중';
      case VoteState.completed:
        return '완료';
      case VoteState.expired:
        return '만료';
      case VoteState.notParticipated:
        return '미참여';
    }
  }
  
  /// 복사본 생성 메서드
  VoteStateData copyWith({
    VoteState? state,
    Duration? remainingTime,
    Map<String, dynamic>? voteResults,
    bool? isTimerExpired,
    DateTime? voteEndTime,
    String? errorMessage,
    bool? hasUserVoted,
    String? userChoice,
  }) {
    return VoteStateData(
      state: state ?? this.state,
      remainingTime: remainingTime ?? this.remainingTime,
      voteResults: voteResults ?? this.voteResults,
      isTimerExpired: isTimerExpired ?? this.isTimerExpired,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      errorMessage: errorMessage ?? this.errorMessage,
      hasUserVoted: hasUserVoted ?? this.hasUserVoted,
      userChoice: userChoice ?? this.userChoice,
    );
  }
}