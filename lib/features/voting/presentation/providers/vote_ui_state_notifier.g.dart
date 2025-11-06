// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_ui_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(VoteUIStateNotifier)
const voteUIStateProvider = VoteUIStateNotifierFamily._();

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
final class VoteUIStateNotifierProvider
    extends $NotifierProvider<VoteUIStateNotifier, VoteUIState> {
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
  const VoteUIStateNotifierProvider._({
    required VoteUIStateNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'voteUIStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$voteUIStateNotifierHash();

  @override
  String toString() {
    return r'voteUIStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VoteUIStateNotifier create() => VoteUIStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoteUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoteUIState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VoteUIStateNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$voteUIStateNotifierHash() =>
    r'e3ab8aee42498d7b9b5917531e7d472af94b0f01';

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

final class VoteUIStateNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          VoteUIStateNotifier,
          VoteUIState,
          VoteUIState,
          VoteUIState,
          String
        > {
  const VoteUIStateNotifierFamily._()
    : super(
        retry: null,
        name: r'voteUIStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  VoteUIStateNotifierProvider call(String postId) =>
      VoteUIStateNotifierProvider._(argument: postId, from: this);

  @override
  String toString() => r'voteUIStateProvider';
}

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

abstract class _$VoteUIStateNotifier extends $Notifier<VoteUIState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  VoteUIState build(String postId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<VoteUIState, VoteUIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoteUIState, VoteUIState>,
              VoteUIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
