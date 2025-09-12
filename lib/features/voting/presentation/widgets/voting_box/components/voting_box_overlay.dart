import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/presentation/constants/voting_dialog_constraints.dart';

/// Overlay components for voting box (selection state, results, debug info)
class VotingBoxOverlay extends StatelessWidget {
  final bool showResult;
  final bool isSelected;
  final double? votePercentage;
  final int? voteCount;
  final double textSize;
  final bool showDebugInfo;
  final Size boxSize;

  const VotingBoxOverlay({
    Key? key,
    required this.showResult,
    required this.isSelected,
    required this.boxSize,
    required this.textSize,
    this.votePercentage,
    this.voteCount,
    this.showDebugInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vote result overlay
        if (showResult && votePercentage != null)
          _buildResultOverlay(),
        
        // Selection overlay
        if (isSelected)
          _buildSelectionOverlay(),
        
        // Debug info
        if (showDebugInfo)
          _buildDebugInfo(),
      ],
    );
  }

  Widget _buildResultOverlay() {
    if (votePercentage == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: VersusRadius.container,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(votePercentage! * 100).toStringAsFixed(1)}%',
                  style: VersusTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontSize: textSize * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (voteCount != null)
                  Text(
                    '$voteCount표',
                    style: VersusTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                      fontSize: textSize * 0.8,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: VersusRadius.container,
          color: VersusColors.primary.withValues(alpha: 0.3),
        ),
        child: Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.white,
            size: VotingDialogConstraints.statusIconSize * 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Positioned(
      top: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          '${boxSize.width.toStringAsFixed(0)}x${boxSize.height.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}