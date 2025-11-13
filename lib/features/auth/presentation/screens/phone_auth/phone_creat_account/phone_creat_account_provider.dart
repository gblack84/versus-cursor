import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'phone_creat_account_state.dart';

part 'phone_creat_account_provider.g.dart';

/// PhoneCreatAccount Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
@riverpod
class PhoneCreatAccount extends _$PhoneCreatAccount {
  @override
  PhoneCreatAccountState build() {
    return PhoneCreatAccountState.initial();
  }

  /// Update selected country (both code and name)
  void updateCountry({String? code, String? name}) {
    state = state.copyWith(
      selectedCountryCode: code,
      selectedCountryName: name,
    );
  }

  /// Reset state to initial
  void reset() {
    state = PhoneCreatAccountState.initial();
  }
}
