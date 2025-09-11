import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/vote_state.dart';

/// 투표 결과 표시 위젯
/// 투표가 완료되었을 때 결과를 표시합니다
class VoteResultsWidget extends StatelessWidget {
  const VoteResultsWidget({
    super.key,
    this.currentUserName,
    required this.state,
    this.voteResults,
  });
  final String? currentUserName;
  final VoteState state;
  final Map<String, dynamic>? voteResults;

  @override
  Widget build(BuildContext context) {
    // 완료 상태이고 결과가 있으면 결과 표시
    if (state == VoteState.completed && voteResults != null) {
      return _buildDetailedResults();
    }

    // 그 외의 경우 기본 메시지 표시
    return _buildBasicResults();
  }

  Widget _buildBasicResults() {
    final displayName = currentUserName ?? '나';

    return Container(
      padding: const EdgeInsets.all(VersusSpacing.sm),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '피클! 피클! 피클!',
              style: TextStyle(
                fontSize: 18,
                color: VersusColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$displayName님 결과를 보러오세요!',
              style: TextStyle(
                fontSize: 14,
                color: VersusColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResults() {
    final votesA = voteResults?['votesA'] ?? 0;
    final votesB = voteResults?['votesB'] ?? 0;
    final totalVotes = votesA + votesB;

    if (totalVotes == 0) {
      return _buildBasicResults();
    }

    final percentA = (votesA / totalVotes * 100).round();
    final percentB = (votesB / totalVotes * 100).round();

    return Container(
      padding: const EdgeInsets.all(VersusSpacing.md),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: VersusColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          Text(
            '투표 결과',
            style: VersusTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: VersusSpacing.sm),

          // A 옵션 결과
          _buildResultBar(
            label: 'A',
            votes: votesA,
            percentage: percentA,
            isWinner: votesA > votesB,
          ),
          const SizedBox(height: VersusSpacing.xs),

          // B 옵션 결과
          _buildResultBar(
            label: 'B',
            votes: votesB,
            percentage: percentB,
            isWinner: votesB > votesA,
          ),

          const SizedBox(height: VersusSpacing.sm),

          // 총 투표수
          Text(
            '총 $totalVotes표',
            style: VersusTextStyles.bodySmall.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBar({
    required String label,
    required int votes,
    required int percentage,
    required bool isWinner,
  }) {
    return Row(
      children: [
        // 라벨
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isWinner
                ? VersusColors.primary
                : VersusColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isWinner ? VersusColors.primary : VersusColors.borderLight,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: VersusTextStyles.bodySmall.copyWith(
                color: isWinner ? Colors.white : VersusColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: VersusSpacing.xs),

        // 진행바
        Expanded(
          child: Stack(
            children: [
              // 배경바
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: VersusColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: VersusColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              // 진행바
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: isWinner
                        ? VersusColors.primary.withValues(alpha: 0.8)
                        : VersusColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // 텍스트
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$percentage% ($votes표)',
                    style: VersusTextStyles.bodySmall.copyWith(
                      color: VersusColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
