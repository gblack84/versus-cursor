import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone_creat_account_state.freezed.dart';

/// PhoneCreatAccountWidget State
///
/// **Migration**: AppModel → Riverpod 3.x Notifier + Freezed (Phase 10)
@freezed
sealed class PhoneCreatAccountState with _$PhoneCreatAccountState {
  const PhoneCreatAccountState._();

  const factory PhoneCreatAccountState({
    /// Selected country code (e.g., "+82", "+1")
    String? selectedCountryCode,

    /// Selected country name (e.g., "South Korea", "United States")
    String? selectedCountryName,
  }) = _PhoneCreatAccountState;

  /// Initial state factory
  factory PhoneCreatAccountState.initial() => const PhoneCreatAccountState();
}
