// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phonelogeinpincode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Phonelogeinpincode Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

@ProviderFor(Phonelogeinpincode)
const phonelogeinpincodeProvider = PhonelogeinpincodeProvider._();

/// Phonelogeinpincode Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
final class PhonelogeinpincodeProvider
    extends $NotifierProvider<Phonelogeinpincode, PhonelogeinpincodeState> {
  /// Phonelogeinpincode Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  const PhonelogeinpincodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phonelogeinpincodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phonelogeinpincodeHash();

  @$internal
  @override
  Phonelogeinpincode create() => Phonelogeinpincode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhonelogeinpincodeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhonelogeinpincodeState>(value),
    );
  }
}

String _$phonelogeinpincodeHash() =>
    r'3a6d5985abc412f464a19da600dd332813d77393';

/// Phonelogeinpincode Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

abstract class _$Phonelogeinpincode extends $Notifier<PhonelogeinpincodeState> {
  PhonelogeinpincodeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<PhonelogeinpincodeState, PhonelogeinpincodeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhonelogeinpincodeState, PhonelogeinpincodeState>,
              PhonelogeinpincodeState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
