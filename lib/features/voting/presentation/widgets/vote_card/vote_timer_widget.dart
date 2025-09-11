import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/vote_state.dart';

/// 투표 타이머 표시 위젯
/// 남은 시간을 표시하고 만료 상태를 보여줍니다
class VoteTimerWidget extends StatelessWidget {
  const VoteTimerWidget({
    super.key,
    required this.state,
    this.remainingTime,
    required this.isTimerExpired,
    required this.hasUserVoted,
  });
  final VoteState state;
  final String? remainingTime;
  final bool isTimerExpired;
  final bool hasUserVoted;

  @override
  Widget build(BuildContext context) {
    // 진행중이 아니거나 타이머가 만료되었거나 남은 시간이 없으면 표시하지 않음
    if (state != VoteState.inProgress ||
        isTimerExpired ||
        remainingTime == null) {
      return const SizedBox.shrink();
    }

    // 사용자가 투표했으면 다른 스타일로 표시
    final textColor =
        hasUserVoted ? VersusColors.textSecondary : VersusColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VersusSpacing.sm,
        vertical: VersusSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: hasUserVoted
            ? VersusColors.backgroundSecondary
            : VersusColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasUserVoted
              ? VersusColors.borderLight
              : VersusColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            remainingTime!,
            style: VersusTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 타이머 만료 상태 표시
  static Widget buildExpiredTimer() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_off,
          size: 16,
          color: VersusColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '투표 종료',
          style: VersusTextStyles.bodySmall.copyWith(
            color: VersusColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
