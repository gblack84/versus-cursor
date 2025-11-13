import 'package:freezed_annotation/freezed_annotation.dart';

part 'phonelogeinpincode_state.freezed.dart';

/// PhonelogeinpincodeWidget State
///
/// **Migration**: AppModel → Riverpod 3.x Notifier + Freezed (Phase 10)
@freezed
sealed class PhonelogeinpincodeState with _$PhonelogeinpincodeState {
  const PhonelogeinpincodeState._();

  const factory PhonelogeinpincodeState({
    /// Phone verification status
    bool? isVerified,

    /// Whether user can resend verification code
    @Default(false) bool canResendCode,

    /// Resend attempt count
    @Default(0) int canResendCount,

    /// Timer current milliseconds
    @Default(120000) int timerMilliseconds,

    /// Timer display value (formatted string)
    @Default('02:00') String timerValue,
  }) = _PhonelogeinpincodeState;

  /// Initial state factory
  factory PhonelogeinpincodeState.initial() => const PhonelogeinpincodeState();
}
