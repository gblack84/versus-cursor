// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_detail_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// CharacterDetailPage Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

@ProviderFor(CharacterDetailPage)
const characterDetailPageProvider = CharacterDetailPageProvider._();

/// CharacterDetailPage Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
final class CharacterDetailPageProvider
    extends $NotifierProvider<CharacterDetailPage, CharacterDetailPageState> {
  /// CharacterDetailPage Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  const CharacterDetailPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'characterDetailPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$characterDetailPageHash();

  @$internal
  @override
  CharacterDetailPage create() => CharacterDetailPage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CharacterDetailPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CharacterDetailPageState>(value),
    );
  }
}

String _$characterDetailPageHash() =>
    r'b21975c8a7daec8e7a52415abfea2b4de75d03fd';

/// CharacterDetailPage Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

abstract class _$CharacterDetailPage
    extends $Notifier<CharacterDetailPageState> {
  CharacterDetailPageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<CharacterDetailPageState, CharacterDetailPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CharacterDetailPageState, CharacterDetailPageState>,
              CharacterDetailPageState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
