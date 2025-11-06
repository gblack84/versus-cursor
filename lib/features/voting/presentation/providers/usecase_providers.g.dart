// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SubmitVoteUseCase Provider
///
/// **Pattern**: @riverpod getter function
/// - GetIt 컨테이너에서 SubmitVoteUseCase 인스턴스 반환
/// - AutoDispose로 자동 메모리 관리
///
/// **사용 예시**:
/// ```dart
/// final useCase = ref.read(submitVoteUseCaseProvider);
/// final result = await useCase(postId: postId, userId: userId, voteOption: 'A');
/// ```

@ProviderFor(submitVoteUseCase)
const submitVoteUseCaseProvider = SubmitVoteUseCaseProvider._();

/// SubmitVoteUseCase Provider
///
/// **Pattern**: @riverpod getter function
/// - GetIt 컨테이너에서 SubmitVoteUseCase 인스턴스 반환
/// - AutoDispose로 자동 메모리 관리
///
/// **사용 예시**:
/// ```dart
/// final useCase = ref.read(submitVoteUseCaseProvider);
/// final result = await useCase(postId: postId, userId: userId, voteOption: 'A');
/// ```

final class SubmitVoteUseCaseProvider
    extends
        $FunctionalProvider<
          SubmitVoteUseCase,
          SubmitVoteUseCase,
          SubmitVoteUseCase
        >
    with $Provider<SubmitVoteUseCase> {
  /// SubmitVoteUseCase Provider
  ///
  /// **Pattern**: @riverpod getter function
  /// - GetIt 컨테이너에서 SubmitVoteUseCase 인스턴스 반환
  /// - AutoDispose로 자동 메모리 관리
  ///
  /// **사용 예시**:
  /// ```dart
  /// final useCase = ref.read(submitVoteUseCaseProvider);
  /// final result = await useCase(postId: postId, userId: userId, voteOption: 'A');
  /// ```
  const SubmitVoteUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitVoteUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitVoteUseCaseHash();

  @$internal
  @override
  $ProviderElement<SubmitVoteUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubmitVoteUseCase create(Ref ref) {
    return submitVoteUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubmitVoteUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubmitVoteUseCase>(value),
    );
  }
}

String _$submitVoteUseCaseHash() => r'0e8756a3587f6457a5664d776963c4c191eab49d';
