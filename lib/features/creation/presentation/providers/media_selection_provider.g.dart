// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Media Selection Provider
///
/// **Phase 3.5**: AppState 미디어 기능 대체
/// - Feature-First 아키텍처: AppState → MediaSelectionProvider
/// - Clean Architecture v4.0: Presentation Layer Provider
/// - Riverpod 3.x: @riverpod class pattern
///
/// **마이그레이션 근거**:
/// - AppState의 미디어 관련 메서드를 Riverpod Provider로 전환
/// - Option A/B 독립적인 상태 관리
/// - 불변성 보장 (Freezed copyWith 패턴)
///
/// **제공 기능**:
/// - Option A/B 이미지 업로드 URL 관리
/// - 선택된 파일 관리
/// - Asset Entity ID 추적
/// - 로컬 경로 관리
/// - 업로드 진행 상태 관리

@ProviderFor(MediaSelection)
const mediaSelectionProvider = MediaSelectionProvider._();

/// Media Selection Provider
///
/// **Phase 3.5**: AppState 미디어 기능 대체
/// - Feature-First 아키텍처: AppState → MediaSelectionProvider
/// - Clean Architecture v4.0: Presentation Layer Provider
/// - Riverpod 3.x: @riverpod class pattern
///
/// **마이그레이션 근거**:
/// - AppState의 미디어 관련 메서드를 Riverpod Provider로 전환
/// - Option A/B 독립적인 상태 관리
/// - 불변성 보장 (Freezed copyWith 패턴)
///
/// **제공 기능**:
/// - Option A/B 이미지 업로드 URL 관리
/// - 선택된 파일 관리
/// - Asset Entity ID 추적
/// - 로컬 경로 관리
/// - 업로드 진행 상태 관리
final class MediaSelectionProvider
    extends $NotifierProvider<MediaSelection, MediaSelectionState> {
  /// Media Selection Provider
  ///
  /// **Phase 3.5**: AppState 미디어 기능 대체
  /// - Feature-First 아키텍처: AppState → MediaSelectionProvider
  /// - Clean Architecture v4.0: Presentation Layer Provider
  /// - Riverpod 3.x: @riverpod class pattern
  ///
  /// **마이그레이션 근거**:
  /// - AppState의 미디어 관련 메서드를 Riverpod Provider로 전환
  /// - Option A/B 독립적인 상태 관리
  /// - 불변성 보장 (Freezed copyWith 패턴)
  ///
  /// **제공 기능**:
  /// - Option A/B 이미지 업로드 URL 관리
  /// - 선택된 파일 관리
  /// - Asset Entity ID 추적
  /// - 로컬 경로 관리
  /// - 업로드 진행 상태 관리
  const MediaSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaSelectionHash();

  @$internal
  @override
  MediaSelection create() => MediaSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaSelectionState>(value),
    );
  }
}

String _$mediaSelectionHash() => r'67920e62a47436fde5b149ddf7c169d9b855e566';

/// Media Selection Provider
///
/// **Phase 3.5**: AppState 미디어 기능 대체
/// - Feature-First 아키텍처: AppState → MediaSelectionProvider
/// - Clean Architecture v4.0: Presentation Layer Provider
/// - Riverpod 3.x: @riverpod class pattern
///
/// **마이그레이션 근거**:
/// - AppState의 미디어 관련 메서드를 Riverpod Provider로 전환
/// - Option A/B 독립적인 상태 관리
/// - 불변성 보장 (Freezed copyWith 패턴)
///
/// **제공 기능**:
/// - Option A/B 이미지 업로드 URL 관리
/// - 선택된 파일 관리
/// - Asset Entity ID 추적
/// - 로컬 경로 관리
/// - 업로드 진행 상태 관리

abstract class _$MediaSelection extends $Notifier<MediaSelectionState> {
  MediaSelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MediaSelectionState, MediaSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MediaSelectionState, MediaSelectionState>,
              MediaSelectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
