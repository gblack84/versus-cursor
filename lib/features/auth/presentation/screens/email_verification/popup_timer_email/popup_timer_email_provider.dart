import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'popup_timer_email_state.dart';

part 'popup_timer_email_provider.g.dart';

/// PopupTimerEmail Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
@riverpod
class PopupTimerEmail extends _$PopupTimerEmail {
  @override
  PopupTimerEmailState build() {
    return PopupTimerEmailState.initial();
  }

  /// Increment resend count
  void incrementResendCount() {
    state = state.copyWith(
      resendCount: state.resendCount + 1,
    );
  }

  /// Update email verification status
  void updateVerificationStatus(bool isVerified) {
    state = state.copyWith(
      isVerifiedEmail: isVerified,
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
      timerMilliseconds: 180000,
      timerValue: '03:00',
    );
  }

  /// Reset state to initial
  void reset() {
    state = PopupTimerEmailState.initial();
  }
}
