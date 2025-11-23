// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Navigation Provider
///
/// **Riverpod 3.x 마이그레이션**:
/// - ChangeNotifierProvider → @riverpod class pattern
/// - Feature-First 아키텍처: /app/router/navigation/
/// - Clean Architecture 준수
///
/// **제공 기능**:
/// - 네비게이션 모드 관리 (Main ↔ Chat)
/// - 탭 인덱스 추적
/// - 라우트 기반 네비게이션

@ProviderFor(Navigation)
const navigationProvider = NavigationProvider._();

/// Navigation Provider
///
/// **Riverpod 3.x 마이그레이션**:
/// - ChangeNotifierProvider → @riverpod class pattern
/// - Feature-First 아키텍처: /app/router/navigation/
/// - Clean Architecture 준수
///
/// **제공 기능**:
/// - 네비게이션 모드 관리 (Main ↔ Chat)
/// - 탭 인덱스 추적
/// - 라우트 기반 네비게이션
final class NavigationProvider
    extends $NotifierProvider<Navigation, NavigationState> {
  /// Navigation Provider
  ///
  /// **Riverpod 3.x 마이그레이션**:
  /// - ChangeNotifierProvider → @riverpod class pattern
  /// - Feature-First 아키텍처: /app/router/navigation/
  /// - Clean Architecture 준수
  ///
  /// **제공 기능**:
  /// - 네비게이션 모드 관리 (Main ↔ Chat)
  /// - 탭 인덱스 추적
  /// - 라우트 기반 네비게이션
  const NavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationHash();

  @$internal
  @override
  Navigation create() => Navigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationState>(value),
    );
  }
}

String _$navigationHash() => r'96aedbeb77f807748f63020f2760e0712a2c8fbe';

/// Navigation Provider
///
/// **Riverpod 3.x 마이그레이션**:
/// - ChangeNotifierProvider → @riverpod class pattern
/// - Feature-First 아키텍처: /app/router/navigation/
/// - Clean Architecture 준수
///
/// **제공 기능**:
/// - 네비게이션 모드 관리 (Main ↔ Chat)
/// - 탭 인덱스 추적
/// - 라우트 기반 네비게이션

abstract class _$Navigation extends $Notifier<NavigationState> {
  NavigationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NavigationState, NavigationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationState, NavigationState>,
              NavigationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
