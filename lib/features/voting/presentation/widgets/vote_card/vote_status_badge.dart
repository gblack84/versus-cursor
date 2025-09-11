import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/vote_state.dart';

/// 투표 상태 배지 위젯
/// 현재 투표 상태를 시각적으로 표시합니다
class VoteStatusBadge extends StatelessWidget {
  const VoteStatusBadge({
    super.key,
    required this.state,
    required this.hasUserVoted,
  });
  final VoteState state;
  final bool hasUserVoted;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VersusSpacing.sm,
        vertical: VersusSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (statusInfo['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (statusInfo['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'] as IconData,
            size: 14,
            color: statusInfo['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo['text'] as String,
            style: VersusTextStyles.bodySmall.copyWith(
              color: statusInfo['color'] as Color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo() {
    final statusInfo = <String, dynamic>{};

    switch (state) {
      case VoteState.votingRequest:
        statusInfo['text'] = '피클요청';
        statusInfo['color'] = VersusColors.primary;
        statusInfo['icon'] = Icons.how_to_vote;
        break;
      case VoteState.inProgress:
        // 사용자가 투표했는지 확인
        if (hasUserVoted) {
          statusInfo['text'] = 'Pick 완료!(진행중)';
          statusInfo['color'] = Colors.blue;
          statusInfo['icon'] = Icons.check_circle_outline;
        } else {
          statusInfo['text'] = '진행중';
          statusInfo['color'] = Colors.blue;
          statusInfo['icon'] = Icons.timer;
        }
        break;
      case VoteState.completed:
        statusInfo['text'] = '완료';
        statusInfo['color'] = VersusColors.success;
        statusInfo['icon'] = Icons.check_circle;
        break;
      case VoteState.expired:
        statusInfo['text'] = '만료';
        statusInfo['color'] = VersusColors.textSecondary;
        statusInfo['icon'] = Icons.timer_off;
        break;
      case VoteState.notParticipated:
        statusInfo['text'] = '미참여';
        statusInfo['color'] = VersusColors.textSecondary;
        statusInfo['icon'] = Icons.block;
        break;
    }

    return statusInfo;
  }
}
