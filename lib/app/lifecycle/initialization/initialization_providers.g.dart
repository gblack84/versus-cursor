// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initialization_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AppInitializationService Provider
///
/// **싱글톤**: 앱 전체에서 하나의 인스턴스만 사용
///
/// **사용처**:
/// - app.dart: 로그인 시 초기화 실행
/// - 테스트: Mock 서비스 주입 가능

@ProviderFor(appInitializationService)
const appInitializationServiceProvider = AppInitializationServiceProvider._();

/// AppInitializationService Provider
///
/// **싱글톤**: 앱 전체에서 하나의 인스턴스만 사용
///
/// **사용처**:
/// - app.dart: 로그인 시 초기화 실행
/// - 테스트: Mock 서비스 주입 가능

final class AppInitializationServiceProvider
    extends
        $FunctionalProvider<
          AppInitializationService,
          AppInitializationService,
          AppInitializationService
        >
    with $Provider<AppInitializationService> {
  /// AppInitializationService Provider
  ///
  /// **싱글톤**: 앱 전체에서 하나의 인스턴스만 사용
  ///
  /// **사용처**:
  /// - app.dart: 로그인 시 초기화 실행
  /// - 테스트: Mock 서비스 주입 가능
  const AppInitializationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInitializationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInitializationServiceHash();

  @$internal
  @override
  $ProviderElement<AppInitializationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppInitializationService create(Ref ref) {
    return appInitializationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppInitializationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppInitializationService>(value),
    );
  }
}

String _$appInitializationServiceHash() =>
    r'ae0acd53c9b7fe17f3c64b399ab8a9dc3fc036ed';

/// 앱 초기화 실행 Provider
///
/// **FutureProvider**: 비동기 초기화 작업 실행
/// **autoDispose**: 사용 종료 시 자동 정리
///
/// **파라미터**:
/// - `userId`: 프리로드 대상 사용자 ID
///
/// **사용 예시**:
/// ```dart
/// // app.dart에서 사용
/// final service = ref.read(appInitializationServiceProvider);
/// final result = await service.initialize(user.uid);
///
/// if (result.isSuccess) {
///   debugPrint('프리로드 성공: ${result.successCount}개');
/// }
/// ```

@ProviderFor(initializeApp)
const initializeAppProvider = InitializeAppFamily._();

/// 앱 초기화 실행 Provider
///
/// **FutureProvider**: 비동기 초기화 작업 실행
/// **autoDispose**: 사용 종료 시 자동 정리
///
/// **파라미터**:
/// - `userId`: 프리로드 대상 사용자 ID
///
/// **사용 예시**:
/// ```dart
/// // app.dart에서 사용
/// final service = ref.read(appInitializationServiceProvider);
/// final result = await service.initialize(user.uid);
///
/// if (result.isSuccess) {
///   debugPrint('프리로드 성공: ${result.successCount}개');
/// }
/// ```

final class InitializeAppProvider
    extends
        $FunctionalProvider<
          AsyncValue<InitializationResult>,
          InitializationResult,
          FutureOr<InitializationResult>
        >
    with
        $FutureModifier<InitializationResult>,
        $FutureProvider<InitializationResult> {
  /// 앱 초기화 실행 Provider
  ///
  /// **FutureProvider**: 비동기 초기화 작업 실행
  /// **autoDispose**: 사용 종료 시 자동 정리
  ///
  /// **파라미터**:
  /// - `userId`: 프리로드 대상 사용자 ID
  ///
  /// **사용 예시**:
  /// ```dart
  /// // app.dart에서 사용
  /// final service = ref.read(appInitializationServiceProvider);
  /// final result = await service.initialize(user.uid);
  ///
  /// if (result.isSuccess) {
  ///   debugPrint('프리로드 성공: ${result.successCount}개');
  /// }
  /// ```
  const InitializeAppProvider._({
    required InitializeAppFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'initializeAppProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$initializeAppHash();

  @override
  String toString() {
    return r'initializeAppProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<InitializationResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InitializationResult> create(Ref ref) {
    final argument = this.argument as String;
    return initializeApp(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InitializeAppProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$initializeAppHash() => r'65a98e1bf079a0b55d699e4f8350ba631e5965ae';

/// 앱 초기화 실행 Provider
///
/// **FutureProvider**: 비동기 초기화 작업 실행
/// **autoDispose**: 사용 종료 시 자동 정리
///
/// **파라미터**:
/// - `userId`: 프리로드 대상 사용자 ID
///
/// **사용 예시**:
/// ```dart
/// // app.dart에서 사용
/// final service = ref.read(appInitializationServiceProvider);
/// final result = await service.initialize(user.uid);
///
/// if (result.isSuccess) {
///   debugPrint('프리로드 성공: ${result.successCount}개');
/// }
/// ```

final class InitializeAppFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<InitializationResult>, String> {
  const InitializeAppFamily._()
    : super(
        retry: null,
        name: r'initializeAppProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 앱 초기화 실행 Provider
  ///
  /// **FutureProvider**: 비동기 초기화 작업 실행
  /// **autoDispose**: 사용 종료 시 자동 정리
  ///
  /// **파라미터**:
  /// - `userId`: 프리로드 대상 사용자 ID
  ///
  /// **사용 예시**:
  /// ```dart
  /// // app.dart에서 사용
  /// final service = ref.read(appInitializationServiceProvider);
  /// final result = await service.initialize(user.uid);
  ///
  /// if (result.isSuccess) {
  ///   debugPrint('프리로드 성공: ${result.successCount}개');
  /// }
  /// ```

  InitializeAppProvider call(String userId) =>
      InitializeAppProvider._(argument: userId, from: this);

  @override
  String toString() => r'initializeAppProvider';
}
