// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_state_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ✅ Coordinator.getVoteStateStream() 완벽 대체
///
/// **고급 기능 100% 보존**:
///
/// 1. **BehaviorSubject.seeded() → AsyncValue.data() 초기값**
///    - Coordinator: `BehaviorSubject.seeded(initialValue)`
///    - Provider: 첫 yield로 즉시 기본값 emit
///
/// 2. **_stateCache[postId] → StreamProvider.family(params)**
///    - Coordinator: Map으로 postId별 Subject 관리
///    - Provider: Family로 params별 Provider 인스턴스 자동 생성
///
/// 3. **중복 리스너 방지**
///    - Coordinator: 같은 postId면 캐시된 Subject 반환
///    - Provider: 같은 params면 동일 Provider 인스턴스 재사용
///
/// 4. **자동 dispose**
///    - Coordinator: 수동 dispose(postId) 호출 필요
///    - Provider: autoDispose로 위젯 dispose 시 자동 정리
///
/// 5. **keepAlive로 중복 방지**
///    - 첫 리스너 생성 후 keepAlive() 호출
///    - 모든 리스너가 사라져도 상태 유지 (BehaviorSubject와 동일)

@ProviderFor(voteStateStream)
const voteStateStreamProvider = VoteStateStreamFamily._();

/// ✅ Coordinator.getVoteStateStream() 완벽 대체
///
/// **고급 기능 100% 보존**:
///
/// 1. **BehaviorSubject.seeded() → AsyncValue.data() 초기값**
///    - Coordinator: `BehaviorSubject.seeded(initialValue)`
///    - Provider: 첫 yield로 즉시 기본값 emit
///
/// 2. **_stateCache[postId] → StreamProvider.family(params)**
///    - Coordinator: Map으로 postId별 Subject 관리
///    - Provider: Family로 params별 Provider 인스턴스 자동 생성
///
/// 3. **중복 리스너 방지**
///    - Coordinator: 같은 postId면 캐시된 Subject 반환
///    - Provider: 같은 params면 동일 Provider 인스턴스 재사용
///
/// 4. **자동 dispose**
///    - Coordinator: 수동 dispose(postId) 호출 필요
///    - Provider: autoDispose로 위젯 dispose 시 자동 정리
///
/// 5. **keepAlive로 중복 방지**
///    - 첫 리스너 생성 후 keepAlive() 호출
///    - 모든 리스너가 사라져도 상태 유지 (BehaviorSubject와 동일)

final class VoteStateStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<VoteStateData>,
          VoteStateData,
          Stream<VoteStateData>
        >
    with $FutureModifier<VoteStateData>, $StreamProvider<VoteStateData> {
  /// ✅ Coordinator.getVoteStateStream() 완벽 대체
  ///
  /// **고급 기능 100% 보존**:
  ///
  /// 1. **BehaviorSubject.seeded() → AsyncValue.data() 초기값**
  ///    - Coordinator: `BehaviorSubject.seeded(initialValue)`
  ///    - Provider: 첫 yield로 즉시 기본값 emit
  ///
  /// 2. **_stateCache[postId] → StreamProvider.family(params)**
  ///    - Coordinator: Map으로 postId별 Subject 관리
  ///    - Provider: Family로 params별 Provider 인스턴스 자동 생성
  ///
  /// 3. **중복 리스너 방지**
  ///    - Coordinator: 같은 postId면 캐시된 Subject 반환
  ///    - Provider: 같은 params면 동일 Provider 인스턴스 재사용
  ///
  /// 4. **자동 dispose**
  ///    - Coordinator: 수동 dispose(postId) 호출 필요
  ///    - Provider: autoDispose로 위젯 dispose 시 자동 정리
  ///
  /// 5. **keepAlive로 중복 방지**
  ///    - 첫 리스너 생성 후 keepAlive() 호출
  ///    - 모든 리스너가 사라져도 상태 유지 (BehaviorSubject와 동일)
  const VoteStateStreamProvider._({
    required VoteStateStreamFamily super.from,
    required VoteStateParams super.argument,
  }) : super(
         retry: null,
         name: r'voteStateStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$voteStateStreamHash();

  @override
  String toString() {
    return r'voteStateStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<VoteStateData> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<VoteStateData> create(Ref ref) {
    final argument = this.argument as VoteStateParams;
    return voteStateStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VoteStateStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$voteStateStreamHash() => r'1ca536a50e047e6b24d2c11f17f20270e51e8ac0';

/// ✅ Coordinator.getVoteStateStream() 완벽 대체
///
/// **고급 기능 100% 보존**:
///
/// 1. **BehaviorSubject.seeded() → AsyncValue.data() 초기값**
///    - Coordinator: `BehaviorSubject.seeded(initialValue)`
///    - Provider: 첫 yield로 즉시 기본값 emit
///
/// 2. **_stateCache[postId] → StreamProvider.family(params)**
///    - Coordinator: Map으로 postId별 Subject 관리
///    - Provider: Family로 params별 Provider 인스턴스 자동 생성
///
/// 3. **중복 리스너 방지**
///    - Coordinator: 같은 postId면 캐시된 Subject 반환
///    - Provider: 같은 params면 동일 Provider 인스턴스 재사용
///
/// 4. **자동 dispose**
///    - Coordinator: 수동 dispose(postId) 호출 필요
///    - Provider: autoDispose로 위젯 dispose 시 자동 정리
///
/// 5. **keepAlive로 중복 방지**
///    - 첫 리스너 생성 후 keepAlive() 호출
///    - 모든 리스너가 사라져도 상태 유지 (BehaviorSubject와 동일)

final class VoteStateStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<VoteStateData>, VoteStateParams> {
  const VoteStateStreamFamily._()
    : super(
        retry: null,
        name: r'voteStateStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ✅ Coordinator.getVoteStateStream() 완벽 대체
  ///
  /// **고급 기능 100% 보존**:
  ///
  /// 1. **BehaviorSubject.seeded() → AsyncValue.data() 초기값**
  ///    - Coordinator: `BehaviorSubject.seeded(initialValue)`
  ///    - Provider: 첫 yield로 즉시 기본값 emit
  ///
  /// 2. **_stateCache[postId] → StreamProvider.family(params)**
  ///    - Coordinator: Map으로 postId별 Subject 관리
  ///    - Provider: Family로 params별 Provider 인스턴스 자동 생성
  ///
  /// 3. **중복 리스너 방지**
  ///    - Coordinator: 같은 postId면 캐시된 Subject 반환
  ///    - Provider: 같은 params면 동일 Provider 인스턴스 재사용
  ///
  /// 4. **자동 dispose**
  ///    - Coordinator: 수동 dispose(postId) 호출 필요
  ///    - Provider: autoDispose로 위젯 dispose 시 자동 정리
  ///
  /// 5. **keepAlive로 중복 방지**
  ///    - 첫 리스너 생성 후 keepAlive() 호출
  ///    - 모든 리스너가 사라져도 상태 유지 (BehaviorSubject와 동일)

  VoteStateStreamProvider call(VoteStateParams params) =>
      VoteStateStreamProvider._(argument: params, from: this);

  @override
  String toString() => r'voteStateStreamProvider';
}
