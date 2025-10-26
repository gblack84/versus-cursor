/// Voting Feature - Riverpod Providers
///
/// **Clean Architecture v4.0 - Repository-based**
/// - UI 상태 관리만 담당
/// - VoteStateCoordinator를 통한 도메인 레이어 연결
/// - Service 레이어 제거됨
///
/// **Provider 구조:**
/// - VoteSubmissionProvider: 투표 제출 액션
/// - VoteUIStateProvider: UI 상태 (로딩, 에러, 성공)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '/features/voting/domain/coordinators/vote_state_coordinator.dart';

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
/// **Clean Architecture v4.0**: VoteStateCoordinator 사용
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

    try {
      // VoteStateCoordinator를 통한 투표 제출
      await VoteStateCoordinator.instance.submitVote(
        postId: postId,
        voteOption: choice,
      );

      // 성공
      final successState = const VoteSubmissionState(isSuccess: true);
      ref.read(voteSubmissionStateProvider.notifier).state = successState;
      return successState;
    } catch (e) {
      // 에러
      final errorState = VoteSubmissionState(
        error: '투표 처리 중 오류가 발생했습니다: ${e.toString()}',
      );
      ref.read(voteSubmissionStateProvider.notifier).state = errorState;
      return errorState;
    }
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
