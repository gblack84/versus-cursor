import 'package:flutter/material.dart';
import '/features/voting/domain/models/vote_state.dart';
import '../vote_status_badge.dart';
import '../vote_timer_widget.dart';

/// 투표 카드 헤더 컴포넌트
/// 상태 배지와 타이머를 표시합니다
class VoteCardHeader extends StatelessWidget {
  const VoteCardHeader({
    super.key,
    required this.state,
    required this.hasUserVoted,
    this.remainingDuration,
    required this.isTimerExpired,
  });

  final VoteState state;
  final bool hasUserVoted;
  final Duration? remainingDuration;
  final bool isTimerExpired;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 상태 배지
        VoteStatusBadge(
          state: state,
          hasUserVoted: hasUserVoted,
        ),

        // 타이머 (진행중이고 만료되지 않은 경우에만 표시)
        if (state == VoteState.inProgress && !isTimerExpired)
          VoteTimerWidget(
            state: state,
            remainingTime: _formatDuration(remainingDuration),
            isTimerExpired: isTimerExpired,
            hasUserVoted: hasUserVoted,
          ),
      ],
    );
  }

  String? _formatDuration(Duration? duration) {
    if (duration == null) return null;
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '$minutes분 ${seconds}초';
    } else {
      return '$seconds초';
    }
  }
}