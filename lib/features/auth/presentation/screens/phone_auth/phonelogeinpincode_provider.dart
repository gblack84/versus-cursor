import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'phonelogeinpincode_state.dart';

part 'phonelogeinpincode_provider.g.dart';

/// Phonelogeinpincode Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
@riverpod
class Phonelogeinpincode extends _$Phonelogeinpincode {
  @override
  PhonelogeinpincodeState build() {
    return PhonelogeinpincodeState.initial();
  }

  /// Update verification status
  void updateVerificationStatus(bool? isVerified) {
    state = state.copyWith(isVerified: isVerified);
  }

  /// Update whether user can resend code
  void updateCanResendCode(bool canResend) {
    state = state.copyWith(canResendCode: canResend);
  }

  /// Increment resend count
  void incrementResendCount() {
    state = state.copyWith(
      canResendCount: state.canResendCount + 1,
    );
  }

  /// Update timer values (called from timer callback)
  void updateTimerValues({
    required int milliseconds,
    required String displayValue,
  }) {
    state = state.copyWith(
      timerMilliseconds: milliseconds,
      timerValue: displayValue,
    );
  }

  /// Reset timer to initial state
  void resetTimer() {
    state = state.copyWith(
      timerMilliseconds: 120000,
      timerValue: '02:00',
    );
  }

  /// Reset state to initial
  void reset() {
    state = PhonelogeinpincodeState.initial();
  }
}
