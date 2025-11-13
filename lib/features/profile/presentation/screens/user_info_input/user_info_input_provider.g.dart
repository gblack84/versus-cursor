// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_input_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// UserInfoInput Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

@ProviderFor(UserInfoInput)
const userInfoInputProvider = UserInfoInputProvider._();

/// UserInfoInput Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
final class UserInfoInputProvider
    extends $NotifierProvider<UserInfoInput, UserInfoInputState> {
  /// UserInfoInput Provider
  ///
  /// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
  const UserInfoInputProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userInfoInputProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userInfoInputHash();

  @$internal
  @override
  UserInfoInput create() => UserInfoInput();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserInfoInputState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserInfoInputState>(value),
    );
  }
}

String _$userInfoInputHash() => r'4472465d3c6ed386df2ffde8d1efe11730ece8ff';

/// UserInfoInput Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)

abstract class _$UserInfoInput extends $Notifier<UserInfoInputState> {
  UserInfoInputState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserInfoInputState, UserInfoInputState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserInfoInputState, UserInfoInputState>,
              UserInfoInputState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
