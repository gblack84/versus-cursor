import 'package:flutter/material.dart';
import 'in_app_notification_dialog.dart';
import 'voting_notification_dialog.dart';
import 'models/versus_box_size_data.dart';

class NotificationOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onTap,
    String buttonText = '참여하기',
  }) {
    // 기존 알림이 있으면 제거
    hide();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 10, // 상태바 아래
        left: 0,
        right: 0,
        child: InAppNotificationDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onTap: onTap,
          onDismiss: hide,
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  /// 투표 알림 표시 (새로운 사이즈 바인딩 시스템 사용)
  static void showVoting(
    BuildContext context, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    required Function(String option) onVote,
    VoidCallback? onDismiss,
    VersusBoxSizeData? sizeData,
    bool showResults = false,
    double? votePercentageA,
    double? votePercentageB,
    int? voteCountA,
    int? voteCountB,
    bool showDebugInfo = false,
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
          onDismiss: onDismiss ?? hide,
          sizeData: sizeData,
          showResults: showResults,
          votePercentageA: votePercentageA,
          votePercentageB: votePercentageB,
          voteCountA: voteCountA,
          voteCountB: voteCountB,
          showDebugInfo: showDebugInfo,
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