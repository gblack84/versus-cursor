/// Voting Feature - Riverpod Providers
///
/// **Clean Architecture v4.0 - UseCase-based**
/// - UI 상태 관리만 담당
/// - SubmitVoteUseCase를 통한 도메인 레이어 연결
/// - Service 레이어 제거됨
///
/// **Provider 구조:**
/// - VoteSubmissionProvider: 투표 제출 액션
/// - VoteUIStateProvider: UI 상태 (로딩, 에러, 성공)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '/app/di.dart';
import '/features/voting/domain/usecases/chat/submit_vote_use_case.dart';
import '/features/voting/domain/failures/voting_failure.dart';

// ============================================================================
// Vote Submission Provider
// ============================================================================

/// 투표 제출 상태
class VoteSubmissionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const VoteSubmissionState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  VoteSubmissionState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return VoteSubmissionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// 투표 제출 Controller
///
/// **Clean Architecture v4.0**: SubmitVoteUseCase 사용
class VoteSubmissionController {
  final Ref ref;

  VoteSubmissionController(this.ref);

  /// 투표 제출
  Future<VoteSubmissionState> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
  }) async {
    // 로딩 시작
    ref.read(voteSubmissionStateProvider.notifier).state =
        const VoteSubmissionState(isLoading: true);

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
        final errorState = VoteSubmissionState(
          error: _mapFailureToMessage(failure),
        );
        ref.read(voteSubmissionStateProvider.notifier).state = errorState;
        return errorState;
      },
      // 성공 시
      (postVoting) {
        final successState = const VoteSubmissionState(isSuccess: true);
        ref.read(voteSubmissionStateProvider.notifier).state = successState;
        return successState;
      },
    );
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
    ref.read(voteSubmissionStateProvider.notifier).state =
        const VoteSubmissionState();
  }
}

/// 투표 제출 상태 Provider
final voteSubmissionStateProvider =
    StateProvider<VoteSubmissionState>((ref) => const VoteSubmissionState());

/// 투표 제출 Controller Provider
final voteSubmissionControllerProvider = Provider<VoteSubmissionController>(
  (ref) => VoteSubmissionController(ref),
);

// ============================================================================
// Vote UI State Provider (Dialog/Card 공통)
// ============================================================================

/// 투표 UI 상태
class VoteUIState {
  final bool hasVoted;
  final String? selectedOption;
  final DateTime? voteTimestamp;
  final bool isAnimating;

  const VoteUIState({
    this.hasVoted = false,
    this.selectedOption,
    this.voteTimestamp,
    this.isAnimating = false,
  });

  VoteUIState copyWith({
    bool? hasVoted,
    String? selectedOption,
    DateTime? voteTimestamp,
    bool? isAnimating,
  }) {
    return VoteUIState(
      hasVoted: hasVoted ?? this.hasVoted,
      selectedOption: selectedOption ?? this.selectedOption,
      voteTimestamp: voteTimestamp ?? this.voteTimestamp,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

/// 투표 UI 상태 Controller
class VoteUIStateController {
  final Ref ref;
  final String postId;

  VoteUIStateController(this.ref, this.postId);

  StateProvider<VoteUIState> get _provider => voteUIStateProvider(postId);

  /// 투표 완료 처리
  void markAsVoted(String option) {
    final currentState = ref.read(_provider);
    ref.read(_provider.notifier).state = currentState.copyWith(
      hasVoted: true,
      selectedOption: option,
      voteTimestamp: DateTime.now(),
    );
  }

  /// 애니메이션 시작
  void startAnimation() {
    final currentState = ref.read(_provider);
    ref.read(_provider.notifier).state =
        currentState.copyWith(isAnimating: true);
  }

  /// 애니메이션 종료
  void stopAnimation() {
    final currentState = ref.read(_provider);
    ref.read(_provider.notifier).state =
        currentState.copyWith(isAnimating: false);
  }

  /// 상태 초기화
  void reset() {
    ref.read(_provider.notifier).state = const VoteUIState();
  }
}

/// 투표 UI 상태 Provider (postId별 독립 관리)
///
/// Family provider를 사용하여 각 postId마다 독립적인 상태 관리
final voteUIStateProvider =
    StateProvider.family<VoteUIState, String>((ref, postId) {
  return const VoteUIState();
});

/// 투표 UI 상태 Controller Provider
final voteUIStateControllerProvider =
    Provider.family<VoteUIStateController, String>((ref, postId) {
  return VoteUIStateController(ref, postId);
});
