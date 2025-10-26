import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/presentation/dialogs/voting_dialog_constraints.dart';

/// Voting box header component displaying labels and vote information
class VotingBoxHeader extends StatelessWidget {
  final String boxType;
  final bool showLabel;
  final bool showResult;
  final double? votePercentage;
  final int? voteCount;
  final double textSize;
  final Size boxSize;

  const VotingBoxHeader({
    Key? key,
    required this.boxType,
    required this.showLabel,
    required this.showResult,
    required this.boxSize,
    this.votePercentage,
    this.voteCount,
    required this.textSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showLabel && !showResult) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // A/B Label
        if (showLabel)
          Positioned(
            top: 12.0,
            left: 12.0,
            child: _buildLabel(),
          ),
        
        // Vote Results
        if (showResult && votePercentage != null)
          Positioned(
            top: 12.0,
            right: 12.0,
            child: _buildVoteInfo(),
          ),
      ],
    );
  }

  Widget _buildLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: boxType == 'A'
            ? VersusColors.primary.withValues(alpha: 0.3)
            : VersusColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        boxType,
        style: VersusTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontSize: VotingDialogConstraints.labelIconSize * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVoteInfo() {
    if (votePercentage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(votePercentage! * 100).toStringAsFixed(1)}%',
            style: VersusTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontSize: textSize * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (voteCount != null)
            Text(
              '$voteCount표',
              style: VersusTextStyles.labelSmall.copyWith(
                color: Colors.white70,
                fontSize: textSize * 0.6,
              ),
            ),
        ],
      ),
    );
  }
}