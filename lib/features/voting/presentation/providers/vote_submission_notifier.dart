/// Voting Feature - Vote Submission Notifier (Riverpod 3.x)
///
/// **Riverpod 3.x Migration**:
/// - StateProvider → AutoDisposeNotifier
/// - Controller 클래스 → Notifier 클래스로 통합
/// - @riverpod 어노테이션 사용
/// - Freezed를 사용한 불변 상태 클래스
///
/// **역할**:
/// - 투표 제출 상태 관리 (로딩, 성공, 에러)
/// - SubmitVoteUseCase를 통한 투표 제출 로직
/// - Either 패턴을 통한 에러 처리

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '/features/voting/domain/usecases/chat/submit_vote_use_case.dart';
import '/features/voting/domain/failures/voting_failure.dart';

part 'vote_submission_notifier.freezed.dart';
part 'vote_submission_notifier.g.dart';

// ============================================================================
// State Class (Freezed)
// ============================================================================

/// 투표 제출 상태
///
/// **Freezed Pattern**:
/// - 불변 클래스 (immutable)
/// - copyWith() 자동 생성
/// - ==, hashCode 자동 생성
@freezed
class VoteSubmissionState with _$VoteSubmissionState {
  const VoteSubmissionState._(); // Private constructor for Freezed

  const factory VoteSubmissionState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(false) bool isSuccess,
  }) = _VoteSubmissionState;
}

// ============================================================================
// Notifier Class (Riverpod 3.x)
// ============================================================================

/// 투표 제출 Notifier
///
/// **Riverpod 3.x Pattern**:
/// - AutoDisposeNotifier<State> 상속
/// - build() 메서드에서 초기 상태 반환
/// - 상태 변경 시 state = newState 사용
///
/// **Clean Architecture v4.0**:
/// - SubmitVoteUseCase를 통한 도메인 레이어 연결
/// - Either 패턴으로 에러 처리
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() {
    return const VoteSubmissionState();
  }

  /// 투표 제출
  ///
  /// **Parameters**:
  /// - [postId]: 투표할 게시물 ID
  /// - [userId]: 투표하는 사용자 ID
  /// - [choice]: 선택한 옵션 ('A' 또는 'B')
  /// - [messageId]: 메시지 ID (선택적)
  /// - [chatId]: 채팅 ID (선택적)
  ///
  /// **Returns**: 최종 상태 (성공 또는 에러)
  Future<VoteSubmissionState> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
  }) async {
    // 로딩 시작
    state = state.copyWith(
      isLoading: true,
      error: null,
      isSuccess: false,
    );

    try {
      // SubmitVoteUseCase를 통한 투표 제출
      final useCase = getIt<SubmitVoteUseCase>();
      final result = await useCase(
        postId: postId,
        userId: userId,
        voteOption: choice,
      );

      // Either<Failure, T> 패턴으로 결과 처리
      return result.fold(
        // 실패 시
        (failure) {
          final errorMessage = _mapFailureToMessage(failure);
          state = state.copyWith(
            isLoading: false,
            error: errorMessage,
            isSuccess: false,
          );
          return state;
        },
        // 성공 시
        (postVoting) {
          state = state.copyWith(
            isLoading: false,
            error: null,
            isSuccess: true,
          );
          return state;
        },
      );
    } catch (e) {
      // 예상치 못한 에러 처리
      state = state.copyWith(
        isLoading: false,
        error: '투표 처리 중 오류가 발생했습니다: $e',
        isSuccess: false,
      );
      return state;
    }
  }

  /// VotingFailure → 사용자 메시지 변환
  String _mapFailureToMessage(VotingFailure failure) {
    return failure.when(
      networkError: (_) => '네트워크 연결을 확인해주세요',
      timeout: (_) => '요청 시간이 초과되었습니다',
      serverError: (_) => '서버 오류가 발생했습니다',
      notFound: (_) => '투표를 찾을 수 없습니다',
      permissionDenied: (_) => '권한이 거부되었습니다',
      unauthenticated: (_) => '인증이 필요합니다',
      unauthorized: (_) => '권한이 없습니다',
      alreadyExists: (_) => '이미 존재하는 데이터입니다',
      quotaExceeded: (_) => '할당량을 초과했습니다',
      cancelled: (_) => '작업이 취소되었습니다',
      aborted: (_) => '작업이 중단되었습니다',
      invalidArgument: (_) => '잘못된 요청입니다',
      invalidData: (_) => '잘못된 투표 데이터입니다',
      failedPrecondition: (_) => '사전 조건이 충족되지 않았습니다',
      alreadyVoted: (_) => '이미 투표하셨습니다',
      votingClosed: (_) => '투표가 종료되었습니다',
      cacheError: (_) => '캐시 오류가 발생했습니다',
      unexpected: (message) => '투표 처리 중 오류가 발생했습니다: $message',
    );
  }

  /// 상태 초기화
  void reset() {
    state = const VoteSubmissionState();
  }
}
