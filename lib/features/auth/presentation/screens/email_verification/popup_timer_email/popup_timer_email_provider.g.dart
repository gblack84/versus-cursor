// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popup_timer_email_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PopupTimerEmail Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

@ProviderFor(PopupTimerEmail)
const popupTimerEmailProvider = PopupTimerEmailProvider._();

/// PopupTimerEmail Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
final class PopupTimerEmailProvider
    extends $NotifierProvider<PopupTimerEmail, PopupTimerEmailState> {
  /// PopupTimerEmail Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  const PopupTimerEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popupTimerEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popupTimerEmailHash();

  @$internal
  @override
  PopupTimerEmail create() => PopupTimerEmail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PopupTimerEmailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PopupTimerEmailState>(value),
    );
  }
}

String _$popupTimerEmailHash() => r'30058310d8b4f777fd004492b0ea2879a0aab775';

/// PopupTimerEmail Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

abstract class _$PopupTimerEmail extends $Notifier<PopupTimerEmailState> {
  PopupTimerEmailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PopupTimerEmailState, PopupTimerEmailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PopupTimerEmailState, PopupTimerEmailState>,
              PopupTimerEmailState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
