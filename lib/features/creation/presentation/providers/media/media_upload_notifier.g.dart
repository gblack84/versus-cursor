// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Media upload state management with Riverpod Notifier
/// 미디어 업로드 상태 관리 - Riverpod 3.x Migration (Phase 2-5-3)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<UploadQueueState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - StreamController management → Riverpod-managed
///
/// **Responsibilities**:
/// - Upload queue management (업로드 큐 관리)
/// - Progress tracking (진행률 추적)
/// - Error handling with retry (에러 처리 및 재시도)
/// - Parallel upload management (병렬 업로드 관리)

@ProviderFor(MediaUpload)
const mediaUploadProvider = MediaUploadProvider._();

/// Media upload state management with Riverpod Notifier
/// 미디어 업로드 상태 관리 - Riverpod 3.x Migration (Phase 2-5-3)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<UploadQueueState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - StreamController management → Riverpod-managed
///
/// **Responsibilities**:
/// - Upload queue management (업로드 큐 관리)
/// - Progress tracking (진행률 추적)
/// - Error handling with retry (에러 처리 및 재시도)
/// - Parallel upload management (병렬 업로드 관리)
final class MediaUploadProvider
    extends $NotifierProvider<MediaUpload, UploadQueueState> {
  /// Media upload state management with Riverpod Notifier
  /// 미디어 업로드 상태 관리 - Riverpod 3.x Migration (Phase 2-5-3)
  ///
  /// **Migration Changes**:
  /// - ChangeNotifier → Notifier<UploadQueueState>
  /// - Mutable state → Immutable Freezed state
  /// - notifyListeners() → state = state.copyWith()
  /// - StreamController management → Riverpod-managed
  ///
  /// **Responsibilities**:
  /// - Upload queue management (업로드 큐 관리)
  /// - Progress tracking (진행률 추적)
  /// - Error handling with retry (에러 처리 및 재시도)
  /// - Parallel upload management (병렬 업로드 관리)
  const MediaUploadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaUploadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaUploadHash();

  @$internal
  @override
  MediaUpload create() => MediaUpload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UploadQueueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UploadQueueState>(value),
    );
  }
}

String _$mediaUploadHash() => r'c501a25a25a901e28dc8eaed30a269ef6639783b';

/// Media upload state management with Riverpod Notifier
/// 미디어 업로드 상태 관리 - Riverpod 3.x Migration (Phase 2-5-3)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<UploadQueueState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - StreamController management → Riverpod-managed
///
/// **Responsibilities**:
/// - Upload queue management (업로드 큐 관리)
/// - Progress tracking (진행률 추적)
/// - Error handling with retry (에러 처리 및 재시도)
/// - Parallel upload management (병렬 업로드 관리)

abstract class _$MediaUpload extends $Notifier<UploadQueueState> {
  UploadQueueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UploadQueueState, UploadQueueState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UploadQueueState, UploadQueueState>,
              UploadQueueState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
