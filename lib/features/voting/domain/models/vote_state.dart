import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_state.freezed.dart';
part 'vote_state.g.dart';

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
///
/// **Clean Architecture v4.0 - Freezed Domain Entity**:
/// - Immutable value object with auto-generated copyWith
/// - JSON serialization support for caching/persistence
/// - Business logic in getters (statusText)
@freezed
sealed class VoteStateData with _$VoteStateData {
  const VoteStateData._();

  const factory VoteStateData({
    /// 현재 투표 상태
    required VoteState state,

    /// 남은 시간 (타이머가 있는 경우)
    Duration? remainingTime,

    /// 투표 결과 (완료된 경우)
    Map<String, dynamic>? voteResults,

    /// 타이머 만료 여부
    @Default(false) bool isTimerExpired,

    /// 투표 종료 시간
    DateTime? voteEndTime,

    /// 에러 메시지 (에러 발생 시)
    String? errorMessage,

    /// 사용자가 이미 투표했는지 여부
    @Default(false) bool hasUserVoted,

    /// 사용자의 투표 선택 (A 또는 B)
    String? userChoice,
  }) = _VoteStateData;

  factory VoteStateData.fromJson(Map<String, dynamic> json) =>
      _$VoteStateDataFromJson(json);

  // ============================================================================
  // Business Logic
  // ============================================================================

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
}
