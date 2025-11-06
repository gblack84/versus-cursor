import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../voting_dialog_constraints.dart';

/// Timer component for the voting dialog
/// Manages countdown timer and auto-close functionality
class VotingDialogTimer {
  Timer? _autoCloseTimer;
  final VoidCallback onTimeExpired;
  final bool Function() hasVoted;

  VotingDialogTimer({
    required this.onTimeExpired,
    required this.hasVoted,
  });

  /// Start the auto-close timer (10 minutes)
  void startTimer() {
    _autoCloseTimer = Timer(VotingDialogConstraints.votingTimeLimit, () {
      if (!hasVoted()) {
        if (kDebugMode) {
          debugPrint('[VotingDialogTimer] 10분 시간 제한 도달 - 자동 닫기');
        }
        onTimeExpired();
      }
    });
  }

  /// Cancel the timer (called when user votes)
  void cancelTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  /// Dispose of the timer
  void dispose() {
    cancelTimer();
  }

  /// Check if timer is active
  bool get isActive => _autoCloseTimer?.isActive ?? false;

  /// Format remaining time for display
  static String formatRemainingTime(Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}