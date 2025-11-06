// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_submission_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(VoteSubmission)
const voteSubmissionProvider = VoteSubmissionProvider._();

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
final class VoteSubmissionProvider
    extends $NotifierProvider<VoteSubmission, VoteSubmissionState> {
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
  const VoteSubmissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteSubmissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteSubmissionHash();

  @$internal
  @override
  VoteSubmission create() => VoteSubmission();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoteSubmissionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoteSubmissionState>(value),
    );
  }
}

String _$voteSubmissionHash() => r'5a9aa1b7dcc0e28feb422103849a2a95400bc1e2';

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

abstract class _$VoteSubmission extends $Notifier<VoteSubmissionState> {
  VoteSubmissionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VoteSubmissionState, VoteSubmissionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoteSubmissionState, VoteSubmissionState>,
              VoteSubmissionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
