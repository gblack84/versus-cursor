// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_validation_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Media validation state management with Riverpod Notifier
/// 미디어 검증 상태 관리 - Riverpod 3.x Migration (Phase 2-5-2)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<ValidationState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - Old ValidationResult → Freezed ValidationResult
///
/// **Responsibilities**:
/// - AI content moderation (AI 콘텐츠 검열)
/// - Validation result caching (검증 결과 캐싱)
/// - Batch validation (일괄 검증)
/// - Error handling (에러 처리)

@ProviderFor(MediaValidation)
const mediaValidationProvider = MediaValidationProvider._();

/// Media validation state management with Riverpod Notifier
/// 미디어 검증 상태 관리 - Riverpod 3.x Migration (Phase 2-5-2)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<ValidationState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - Old ValidationResult → Freezed ValidationResult
///
/// **Responsibilities**:
/// - AI content moderation (AI 콘텐츠 검열)
/// - Validation result caching (검증 결과 캐싱)
/// - Batch validation (일괄 검증)
/// - Error handling (에러 처리)
final class MediaValidationProvider
    extends $NotifierProvider<MediaValidation, ValidationState> {
  /// Media validation state management with Riverpod Notifier
  /// 미디어 검증 상태 관리 - Riverpod 3.x Migration (Phase 2-5-2)
  ///
  /// **Migration Changes**:
  /// - ChangeNotifier → Notifier<ValidationState>
  /// - Mutable state → Immutable Freezed state
  /// - notifyListeners() → state = state.copyWith()
  /// - Old ValidationResult → Freezed ValidationResult
  ///
  /// **Responsibilities**:
  /// - AI content moderation (AI 콘텐츠 검열)
  /// - Validation result caching (검증 결과 캐싱)
  /// - Batch validation (일괄 검증)
  /// - Error handling (에러 처리)
  const MediaValidationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaValidationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaValidationHash();

  @$internal
  @override
  MediaValidation create() => MediaValidation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidationState>(value),
    );
  }
}

String _$mediaValidationHash() => r'50fc01c84866532cdbcc186b57699166b71a3c54';

/// Media validation state management with Riverpod Notifier
/// 미디어 검증 상태 관리 - Riverpod 3.x Migration (Phase 2-5-2)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<ValidationState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - Old ValidationResult → Freezed ValidationResult
///
/// **Responsibilities**:
/// - AI content moderation (AI 콘텐츠 검열)
/// - Validation result caching (검증 결과 캐싱)
/// - Batch validation (일괄 검증)
/// - Error handling (에러 처리)

abstract class _$MediaValidation extends $Notifier<ValidationState> {
  ValidationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ValidationState, ValidationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ValidationState, ValidationState>,
              ValidationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
