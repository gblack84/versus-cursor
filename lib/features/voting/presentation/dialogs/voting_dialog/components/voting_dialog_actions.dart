import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';

/// Action buttons component for the voting dialog
/// Displays vote buttons based on available options
class VotingDialogActions extends StatelessWidget {
  final String optionA;
  final String optionB;
  final String? imageUrlB;
  final Function(String option) onVote;
  final bool isEnabled;

  const VotingDialogActions({
    super.key,
    required this.optionA,
    required this.optionB,
    this.imageUrlB,
    required this.onVote,
    this.isEnabled = true,
  });

  bool get _hasBOption => imageUrlB != null || optionB.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasBOption) {
      return _buildSingleButton();
    }
    return _buildDualButtons();
  }

  Widget _buildSingleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => onVote('A') : null,
        style: _getPrimaryButtonStyle(),
        child: Text(
          '선택하기',
          style: VersusTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDualButtons() {
    return Row(
      children: [
        // A option button
        Expanded(
          child: ElevatedButton(
            onPressed: isEnabled ? () => onVote('A') : null,
            style: _getPrimaryButtonStyle(),
            child: Text(
              'A 선택',
              style: VersusTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        VersusSpacing.gapH(VersusSpacing.sm),
        
        // B option button
        Expanded(
          child: ElevatedButton(
            onPressed: isEnabled ? () => onVote('B') : null,
            style: _getSecondaryButtonStyle(),
            child: Text(
              'B 선택',
              style: VersusTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: VersusColors.primary,
      foregroundColor: Colors.white,
      shape: VersusRadius.buttonShape,
      padding: VersusSpacing.buttonInternal,
      disabledBackgroundColor: VersusColors.primary.withValues(alpha: 0.5),
    );
  }

  ButtonStyle _getSecondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: VersusColors.secondary,
      foregroundColor: Colors.white,
      shape: VersusRadius.buttonShape,
      padding: VersusSpacing.buttonInternal,
      disabledBackgroundColor: VersusColors.secondary.withValues(alpha: 0.5),
    );
  }
}