import 'package:flutter/material.dart';
import 'package:versus_space/gen/assets.gen.dart';
import '/core/design_system/design_system.dart';

/// Header component for the voting dialog
/// Displays profile image, "Pikle" icon, author name, and close button
class VotingDialogHeader extends StatelessWidget {
  final String? authorName;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const VotingDialogHeader({
    super.key,
    this.authorName,
    this.onClose,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Test user profile image
        _buildProfileAvatar(),
        VersusSpacing.gapH(2),
        
        // Title and subtitle
        Expanded(
          child: _buildTitleSection(),
        ),
        
        // Close button
        if (showCloseButton && onClose != null)
          _buildCloseButton(),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: VersusColors.borderLight,
      child: Icon(
        Icons.person,
        size: 24,
        color: VersusColors.textSecondary,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPikleTitle(),
        const SizedBox(height: 2.0),
        _buildAuthorSubtitle(),
      ],
    );
  }

  Widget _buildPikleTitle() {
    return Row(
      children: [
        Assets.images_pikle_icon.image(
          width: 30,
          height: 30,
        ),
        Text(
          'Pikle 도착!',
          style: VersusTextStyles.headingSmall,
        ),
      ],
    );
  }

  Widget _buildAuthorSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: authorName ?? 'Test User',
              style: VersusTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: VersusColors.textPrimary,
              ),
            ),
            TextSpan(
              text: '님이 물어봅니다',
              style: VersusTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      onPressed: onClose,
      icon: Icon(
        Icons.close,
        color: VersusColors.textSecondary,
        size: 20,
      ),
    );
  }
}