/// Voting Feature - Vote UI State Notifier (Riverpod 3.x)
///
/// **Riverpod 3.x Migration**:
/// - StateProvider.family → AutoDisposeNotifierFamily
/// - Controller 클래스 → Notifier 클래스로 통합
/// - @riverpod 어노테이션 사용
/// - Freezed를 사용한 불변 상태 클래스
///
/// **역할**:
/// - 투표 UI 상태 관리 (투표 완료 여부, 선택한 옵션, 애니메이션)
/// - postId별 독립적인 상태 관리

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vote_ui_state_notifier.freezed.dart';
part 'vote_ui_state_notifier.g.dart';

// ============================================================================
// State Class (Freezed)
// ============================================================================

/// 투표 UI 상태
///
/// **Freezed Pattern**:
/// - 불변 클래스 (immutable)
/// - copyWith() 자동 생성
/// - ==, hashCode 자동 생성
///
/// **Fields**:
/// - [hasVoted]: 투표 완료 여부
/// - [selectedOption]: 선택한 옵션 ('A' 또는 'B')
/// - [voteTimestamp]: 투표 시간
/// - [isAnimating]: 애니메이션 진행 여부
@freezed
class VoteUIState with _$VoteUIState {
  const VoteUIState._(); // Private constructor for Freezed

  const factory VoteUIState({
    @Default(false) bool hasVoted,
    @Default(null) String? selectedOption,
    @Default(null) DateTime? voteTimestamp,
    @Default(false) bool isAnimating,
  }) = _VoteUIState;
}

// ============================================================================
// Notifier Class (Riverpod 3.x)
// ============================================================================

/// 투표 UI 상태 Notifier
///
/// **Riverpod 3.x Pattern**:
/// - AutoDisposeNotifierFamily<State, Param> 상속
/// - build(Param param) 메서드에서 초기 상태 반환
/// - postId별로 독립적인 상태 관리
///
/// **사용 예시**:
/// ```dart
/// // Widget에서 사용
/// final uiState = ref.watch(voteUIStateNotifierProvider(postId));
/// ref.read(voteUIStateNotifierProvider(postId).notifier).markAsVoted('A');
/// ```
@riverpod
class VoteUIStateNotifier extends _$VoteUIStateNotifier {
  @override
  VoteUIState build(String postId) {
    // postId별로 독립적인 초기 상태 반환
    return const VoteUIState();
  }

  /// 투표 완료 처리
  ///
  /// **Parameters**:
  /// - [option]: 선택한 옵션 ('A' 또는 'B')
  void markAsVoted(String option) {
    state = state.copyWith(
      hasVoted: true,
      selectedOption: option,
      voteTimestamp: DateTime.now(),
    );
  }

  /// 애니메이션 시작
  void startAnimation() {
    state = state.copyWith(isAnimating: true);
  }

  /// 애니메이션 종료
  void stopAnimation() {
    state = state.copyWith(isAnimating: false);
  }

  /// 상태 초기화
  void reset() {
    state = const VoteUIState();
  }
}
