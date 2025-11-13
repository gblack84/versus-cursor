// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editviedo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EditviedoWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

@ProviderFor(Editviedo)
const editviedoProvider = EditviedoProvider._();

/// EditviedoWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
final class EditviedoProvider
    extends $NotifierProvider<Editviedo, EditviedoState> {
  /// EditviedoWidget Riverpod Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  const EditviedoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editviedoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editviedoHash();

  @$internal
  @override
  Editviedo create() => Editviedo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditviedoState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditviedoState>(value),
    );
  }
}

String _$editviedoHash() => r'958f8bfd03fa6a1e2becbc98d30937fed9479492';

/// EditviedoWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

abstract class _$Editviedo extends $Notifier<EditviedoState> {
  EditviedoState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EditviedoState, EditviedoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditviedoState, EditviedoState>,
              EditviedoState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
