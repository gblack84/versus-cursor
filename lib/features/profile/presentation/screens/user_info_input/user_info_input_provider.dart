import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/features/profile/domain/entities/user_profile.dart';
import 'user_info_input_state.dart';

part 'user_info_input_provider.g.dart';

/// UserInfoInput Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
@riverpod
class UserInfoInput extends _$UserInfoInput {
  @override
  UserInfoInputState build() {
    return UserInfoInputState.initial();
  }

  /// Update selected language
  void updateSelectedLanguage(String? language) {
    state = state.copyWith(selectedLanguage: language);
  }

  /// Update selected country (display name)
  void updateSelectedCountry(String? country) {
    state = state.copyWith(selectedCountry: country);
  }

  /// Update selected country code
  void updateSelectedCountryCode(String? countryCode) {
    state = state.copyWith(selectedCountryCode: countryCode);
  }

  /// Update country (both display name and code)
  void updateCountry({String? country, String? countryCode}) {
    state = state.copyWith(
      selectedCountry: country,
      selectedCountryCode: countryCode,
    );
  }

  /// Update agreed 13+ age requirement
  void updateAgreed13old(bool agreed) {
    state = state.copyWith(agreed13old: agreed);
  }

  /// Update user document
  void updateUserDocument(UserProfile? document) {
    state = state.copyWith(userDocument: document);
  }

  /// Update ChoiceChips value (gender selection)
  void updateChoiceChipsValue(String? value) {
    state = state.copyWith(choiceChipsValue: value);
  }

  /// Update checkbox value (terms agreement)
  void updateCheckboxValue(bool? value) {
    state = state.copyWith(checkboxValue: value);
  }

  /// Reset state to initial
  void reset() {
    state = UserInfoInputState.initial();
  }
}
