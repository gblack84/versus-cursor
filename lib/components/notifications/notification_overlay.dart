import 'package:flutter/material.dart';
import 'in_app_notification_dialog.dart';
import 'voting_notification_dialog.dart';
import 'models/versus_box_size_data.dart';

class NotificationOverlay {
  static OverlayEntry? _currentEntry;
  static DateTime? _lastShowTime;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onTap,
    String buttonText = '참여하기',
  }) {
    debugPrint('[NotificationOverlay] show() 호출됨');
    debugPrint('[NotificationOverlay]   - title: $title');
    debugPrint('[NotificationOverlay]   - message: $message');
    debugPrint('[NotificationOverlay]   - buttonText: $buttonText');
    
    // 기존 알림이 있으면 제거
    if (_currentEntry != null) {
      debugPrint('[NotificationOverlay] 기존 알림 제거');
      hide();
    }

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 10, // 상태바 아래
        left: 0,
        right: 0,
        child: InAppNotificationDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onTap: () {
            debugPrint('[NotificationOverlay] 알림 버튼 클릭됨');
            onTap();
          },
          onDismiss: () {
            debugPrint('[NotificationOverlay] 알림 닫기 요청');
            hide();
          },
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
    _lastShowTime = DateTime.now();
    debugPrint('[NotificationOverlay] ✅ 알림 표시됨');
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
    debugPrint('[NotificationOverlay] ========== showVoting() 호출됨 ==========');
    debugPrint('[NotificationOverlay] 질문: $question');
    debugPrint('[NotificationOverlay] 옵션 A: $optionA');
    debugPrint('[NotificationOverlay] 옵션 B: $optionB');
    debugPrint('[NotificationOverlay] 이미지 A: ${imageUrlA != null ? '있음' : '없음'}');
    debugPrint('[NotificationOverlay] 이미지 B: ${imageUrlB != null ? '있음' : '없음'}');
    debugPrint('[NotificationOverlay] 결과 표시: $showResults');
    debugPrint('[NotificationOverlay] 디버그 정보 표시: $showDebugInfo');
    
    // 기존 알림이 있으면 제거
    if (_currentEntry != null) {
      debugPrint('[NotificationOverlay] 기존 알림 제거');
      hide();
    }

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
          onVote: (option) {
            debugPrint('[NotificationOverlay] 사용자가 투표함: $option');
            onVote(option);
          },
          onDismiss: () {
            debugPrint('[NotificationOverlay] 사용자가 알림을 닫음 (X 버튼 또는 나중에)');
            if (onDismiss != null) {
              onDismiss();
            } else {
              hide();
            }
          },
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
    _lastShowTime = DateTime.now();
    debugPrint('[NotificationOverlay] ✅ 투표 알림 표시됨');
    debugPrint('[NotificationOverlay] ========== showVoting() 종료 ==========');
  }

  static void hide() {
    if (_currentEntry != null) {
      debugPrint('[NotificationOverlay] hide() 호출됨 - 알림 제거');
      if (_lastShowTime != null) {
        final duration = DateTime.now().difference(_lastShowTime!);
        debugPrint('[NotificationOverlay] 알림 표시 시간: ${duration.inSeconds}초 ${duration.inMilliseconds % 1000}ms');
      }
      _currentEntry?.remove();
      _currentEntry = null;
      _lastShowTime = null;
    } else {
      debugPrint('[NotificationOverlay] hide() 호출됨 - 제거할 알림 없음');
    }
  }
}