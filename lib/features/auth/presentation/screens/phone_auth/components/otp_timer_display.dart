import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';
import '../../../widgets/timer/auth_timer_display.dart';

/// OTP 타이머 디스플레이 컴포넌트
///
/// AppTimer 제거 (2025-11-11): stop_watch_timer 직접 사용 + AuthTimerDisplay
class OtpTimerDisplay extends StatelessWidget {
  final StopWatchTimer timer;

  const OtpTimerDisplay({
    super.key,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTimerDisplay(
      timer: timer,
      style: AppTheme.of(context).headlineSmall.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
              fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
            fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
          ),
      textAlign: TextAlign.start,
    );
  }
}