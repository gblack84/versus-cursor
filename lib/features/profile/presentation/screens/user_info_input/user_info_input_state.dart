import 'package:freezed_annotation/freezed_annotation.dart';
import '/features/profile/domain/entities/user_profile.dart';

part 'user_info_input_state.freezed.dart';

/// UserInfoInputWidget State
///
/// **Migration**: AppModel → Riverpod 3.x Notifier + Freezed (Phase 10)
@freezed
sealed class UserInfoInputState with _$UserInfoInputState {
  const UserInfoInputState._();

  const factory UserInfoInputState({
    /// Selected language
    String? selectedLanguage,

    /// Selected country display name (e.g., "South Korea")
    String? selectedCountry,

    /// Selected country code (e.g., "KR")
    String? selectedCountryCode,

    /// User agreed to 13+ age requirement
    @Default(false) bool agreed13old,

    /// Fetched user profile document
    UserProfile? userDocument,

    /// ChoiceChips selected value (gender selection)
    String? choiceChipsValue,

    /// Checkbox value (terms agreement)
    bool? checkboxValue,
  }) = _UserInfoInputState;

  /// Initial state factory
  factory UserInfoInputState.initial() => const UserInfoInputState();
}
