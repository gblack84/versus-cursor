import 'package:freezed_annotation/freezed_annotation.dart';

part 'popup_timer_email_state.freezed.dart';

/// PopupTimerEmailWidget State
///
/// **Migration**: AppModel → Riverpod 3.x Notifier + Freezed (Phase 10)
@freezed
sealed class PopupTimerEmailState with _$PopupTimerEmailState {
  const PopupTimerEmailState._();

  const factory PopupTimerEmailState({
    /// Resend count (maximum 3 times)
    @Default(0) int resendCount,

    /// Email verification status
    @Default(false) bool isVerifiedEmail,

    /// Timer current milliseconds
    @Default(180000) int timerMilliseconds,

    /// Timer display value (formatted string)
    @Default('03:00') String timerValue,
  }) = _PopupTimerEmailState;

  /// Initial state factory
  factory PopupTimerEmailState.initial() => const PopupTimerEmailState();

  /// Check if resend is allowed (< 3 times)
  bool get canResend => resendCount < 3;
}
