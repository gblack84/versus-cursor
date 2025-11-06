// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifiers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Profile UI State Notifier

@ProviderFor(ProfileUI)
const profileUIProvider = ProfileUIProvider._();

/// Profile UI State Notifier
final class ProfileUIProvider
    extends $NotifierProvider<ProfileUI, ProfileUIState> {
  /// Profile UI State Notifier
  const ProfileUIProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileUIProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileUIHash();

  @$internal
  @override
  ProfileUI create() => ProfileUI();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileUIState>(value),
    );
  }
}

String _$profileUIHash() => r'74bd2f21d5fb30c9edc39a9ee3036e0250a5c20e';

/// Profile UI State Notifier

abstract class _$ProfileUI extends $Notifier<ProfileUIState> {
  ProfileUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileUIState, ProfileUIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileUIState, ProfileUIState>,
              ProfileUIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Settings UI State Notifier

@ProviderFor(SettingsUI)
const settingsUIProvider = SettingsUIProvider._();

/// Settings UI State Notifier
final class SettingsUIProvider
    extends $NotifierProvider<SettingsUI, SettingsUIState> {
  /// Settings UI State Notifier
  const SettingsUIProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsUIProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsUIHash();

  @$internal
  @override
  SettingsUI create() => SettingsUI();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsUIState>(value),
    );
  }
}

String _$settingsUIHash() => r'52c00b61cd989c37ae936a356d1fffe1621a5b90';

/// Settings UI State Notifier

abstract class _$SettingsUI extends $Notifier<SettingsUIState> {
  SettingsUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SettingsUIState, SettingsUIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsUIState, SettingsUIState>,
              SettingsUIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Image Upload State Notifier

@ProviderFor(ImageUpload)
const imageUploadProvider = ImageUploadProvider._();

/// Image Upload State Notifier
final class ImageUploadProvider
    extends $NotifierProvider<ImageUpload, ImageUploadState> {
  /// Image Upload State Notifier
  const ImageUploadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageUploadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageUploadHash();

  @$internal
  @override
  ImageUpload create() => ImageUpload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageUploadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageUploadState>(value),
    );
  }
}

String _$imageUploadHash() => r'9a952fb10dc9a5c8a6a1ac2dfad63722b26cceb0';

/// Image Upload State Notifier

abstract class _$ImageUpload extends $Notifier<ImageUploadState> {
  ImageUploadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ImageUploadState, ImageUploadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImageUploadState, ImageUploadState>,
              ImageUploadState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Profile Actions Notifier

@ProviderFor(ProfileNotifier)
const profileProvider = ProfileNotifierProvider._();

/// Profile Actions Notifier
final class ProfileNotifierProvider
    extends $NotifierProvider<ProfileNotifier, void> {
  /// Profile Actions Notifier
  const ProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$profileNotifierHash() => r'47631607d38f3fc3044385ace0ffd22834007385';

/// Profile Actions Notifier

abstract class _$ProfileNotifier extends $Notifier<void> {
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

/// Profile Stream Provider

@ProviderFor(profileStream)
const profileStreamProvider = ProfileStreamFamily._();

/// Profile Stream Provider

final class ProfileStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  /// Profile Stream Provider
  const ProfileStreamProvider._({
    required ProfileStreamFamily super.from,
    required (String, {bool keepAlive}) super.argument,
  }) : super(
         retry: null,
         name: r'profileStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileStreamHash();

  @override
  String toString() {
    return r'profileStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    final argument = this.argument as (String, {bool keepAlive});
    return profileStream(ref, argument.$1, keepAlive: argument.keepAlive);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileStreamHash() => r'4eb2f51468a80e0555a1ec394bb78e0681ca9f3e';

/// Profile Stream Provider

final class ProfileStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<UserProfile?>,
          (String, {bool keepAlive})
        > {
  const ProfileStreamFamily._()
    : super(
        retry: null,
        name: r'profileStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Profile Stream Provider

  ProfileStreamProvider call(String userId, {bool keepAlive = false}) =>
      ProfileStreamProvider._(
        argument: (userId, keepAlive: keepAlive),
        from: this,
      );

  @override
  String toString() => r'profileStreamProvider';
}

/// Settings Stream Provider

@ProviderFor(settingsStream)
const settingsStreamProvider = SettingsStreamFamily._();

/// Settings Stream Provider

final class SettingsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserSettings?>,
          UserSettings?,
          Stream<UserSettings?>
        >
    with $FutureModifier<UserSettings?>, $StreamProvider<UserSettings?> {
  /// Settings Stream Provider
  const SettingsStreamProvider._({
    required SettingsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsStreamHash();

  @override
  String toString() {
    return r'settingsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserSettings?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserSettings?> create(Ref ref) {
    final argument = this.argument as String;
    return settingsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsStreamHash() => r'1a27802f1c576224925e114e3d4dcc04aab69a71';

/// Settings Stream Provider

final class SettingsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserSettings?>, String> {
  const SettingsStreamFamily._()
    : super(
        retry: null,
        name: r'settingsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Settings Stream Provider

  SettingsStreamProvider call(String userId) =>
      SettingsStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'settingsStreamProvider';
}
