import 'package:flutter/material.dart';
import 'voting_dialog.dart';

class VotingOverlay {
  static OverlayEntry? _currentEntry;

  static void showVotingNotification(
    BuildContext context, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    required Function(String option) onVote,
  }) {
    // 기존 알림이 있으면 제거
    hide();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 10, // 상태바 아래
        left: 0,
        right: 0,
        child: VotingNotificationDialog(
          question: question,
          optionA: optionA,
          optionB: optionB,
          imageUrlA: imageUrlA,
          imageUrlB: imageUrlB,
          onVote: onVote,
          onDismiss: (hasVoted) => hide(),
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
