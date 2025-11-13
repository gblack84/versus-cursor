// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_creat_account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PhoneCreatAccount Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

@ProviderFor(PhoneCreatAccount)
const phoneCreatAccountProvider = PhoneCreatAccountProvider._();

/// PhoneCreatAccount Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
final class PhoneCreatAccountProvider
    extends $NotifierProvider<PhoneCreatAccount, PhoneCreatAccountState> {
  /// PhoneCreatAccount Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  const PhoneCreatAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phoneCreatAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phoneCreatAccountHash();

  @$internal
  @override
  PhoneCreatAccount create() => PhoneCreatAccount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhoneCreatAccountState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhoneCreatAccountState>(value),
    );
  }
}

String _$phoneCreatAccountHash() => r'6354de9a557b5f6ff02250f7653ab4ea37393ba6';

/// PhoneCreatAccount Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

abstract class _$PhoneCreatAccount extends $Notifier<PhoneCreatAccountState> {
  PhoneCreatAccountState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<PhoneCreatAccountState, PhoneCreatAccountState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhoneCreatAccountState, PhoneCreatAccountState>,
              PhoneCreatAccountState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
