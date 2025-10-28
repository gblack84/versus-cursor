import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class OtpTimerDisplay extends StatelessWidget {
  final int initialTimeMs;
  final AppTimerController timerController;
  final Function(int value, String displayTime, bool shouldUpdate) onChanged;

  const OtpTimerDisplay({
    super.key,
    required this.initialTimeMs,
    required this.timerController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTimer(
      initialTime: initialTimeMs,
      getDisplayTime: (value) => StopWatchTimer.getDisplayTime(
        value,
        hours: false,
        milliSecond: false,
      ),
      controller: timerController,
      updateStateInterval: Duration(milliseconds: 1000),
      onChanged: onChanged,
      textAlign: TextAlign.start,
      style: AppTheme.of(context).headlineSmall.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
              fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
            fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
          ),
    );
  }
}