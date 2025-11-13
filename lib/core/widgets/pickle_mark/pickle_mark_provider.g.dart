// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickle_mark_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PickleMarkWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
/// - Empty model (no state)
/// - Used by: alertempty, phonemaximum, start_page, popup_timer_email

@ProviderFor(PickleMark)
const pickleMarkProvider = PickleMarkProvider._();

/// PickleMarkWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
/// - Empty model (no state)
/// - Used by: alertempty, phonemaximum, start_page, popup_timer_email
final class PickleMarkProvider extends $NotifierProvider<PickleMark, void> {
  /// PickleMarkWidget Riverpod Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  /// - Empty model (no state)
  /// - Used by: alertempty, phonemaximum, start_page, popup_timer_email
  const PickleMarkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pickleMarkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pickleMarkHash();

  @$internal
  @override
  PickleMark create() => PickleMark();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pickleMarkHash() => r'002fb078f2c15309770905a3a8804ba82c8e4ecf';

/// PickleMarkWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
/// - Empty model (no state)
/// - Used by: alertempty, phonemaximum, start_page, popup_timer_email

abstract class _$PickleMark extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
