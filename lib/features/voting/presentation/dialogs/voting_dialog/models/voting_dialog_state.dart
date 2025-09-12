import 'package:flutter/material.dart';

/// State model for the voting dialog
@immutable
class VotingDialogState {
  final bool hasVoted;
  final String? selectedOption;
  final DateTime? voteTimestamp;
  final bool isAnimating;
  final bool isTimerActive;

  const VotingDialogState({
    this.hasVoted = false,
    this.selectedOption,
    this.voteTimestamp,
    this.isAnimating = false,
    this.isTimerActive = true,
  });

  VotingDialogState copyWith({
    bool? hasVoted,
    String? selectedOption,
    DateTime? voteTimestamp,
    bool? isAnimating,
    bool? isTimerActive,
  }) {
    return VotingDialogState(
      hasVoted: hasVoted ?? this.hasVoted,
      selectedOption: selectedOption ?? this.selectedOption,
      voteTimestamp: voteTimestamp ?? this.voteTimestamp,
      isAnimating: isAnimating ?? this.isAnimating,
      isTimerActive: isTimerActive ?? this.isTimerActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VotingDialogState &&
      other.hasVoted == hasVoted &&
      other.selectedOption == selectedOption &&
      other.voteTimestamp == voteTimestamp &&
      other.isAnimating == isAnimating &&
      other.isTimerActive == isTimerActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasVoted,
      selectedOption,
      voteTimestamp,
      isAnimating,
      isTimerActive,
    );
  }
}

/// Configuration model for the voting dialog
@immutable
class VotingDialogConfig {
  final bool showResults;
  final bool showDebugInfo;
  final bool enableAutoClose;
  final Duration autoCloseDuration;
  final Duration voteCompleteDuration;

  const VotingDialogConfig({
    this.showResults = false,
    this.showDebugInfo = false,
    this.enableAutoClose = true,
    this.autoCloseDuration = const Duration(minutes: 10),
    this.voteCompleteDuration = const Duration(seconds: 2),
  });

  VotingDialogConfig copyWith({
    bool? showResults,
    bool? showDebugInfo,
    bool? enableAutoClose,
    Duration? autoCloseDuration,
    Duration? voteCompleteDuration,
  }) {
    return VotingDialogConfig(
      showResults: showResults ?? this.showResults,
      showDebugInfo: showDebugInfo ?? this.showDebugInfo,
      enableAutoClose: enableAutoClose ?? this.enableAutoClose,
      autoCloseDuration: autoCloseDuration ?? this.autoCloseDuration,
      voteCompleteDuration: voteCompleteDuration ?? this.voteCompleteDuration,
    );
  }
}