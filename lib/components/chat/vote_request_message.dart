import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/design_system/design_system.dart';

class VoteRequestMessage extends StatelessWidget {
  const VoteRequestMessage({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.optionAText,
    required this.optionBText,
    this.optionAImage,
    this.optionBImage,
    required this.voteStatus,
    required this.isMe,
    required this.timestamp,
    required this.onTap,
  });

  final String postId;
  final String title;
  final String description;
  final String optionAText;
  final String optionBText;
  final String? optionAImage;
  final String? optionBImage;
  final String voteStatus;
  final bool isMe;
  final DateTime? timestamp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 50 : 16,
          right: isMe ? 16 : 50,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: isMe ? VersusColors.primary : VersusColors.backgroundSecondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(VersusSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 16,
                    color: isMe ? Colors.white : VersusColors.primary,
                  ),
                  const SizedBox(width: VersusSpacing.xs),
                  Text(
                    '투표 요청',
                    style: VersusTextStyles.labelSmall.copyWith(
                      color: isMe ? Colors.white : VersusColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VersusSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: VersusTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VersusSpacing.sm),
              
              // 제목
              Text(
                title,
                style: VersusTextStyles.bodyLarge.copyWith(
                  color: isMe ? Colors.white : VersusColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: VersusTextStyles.bodySmall.copyWith(
                    color: isMe ? Colors.white.withValues(alpha: 0.8) : VersusColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: VersusSpacing.sm),
              
              // A vs B 박스
              Row(
                children: [
                  Expanded(
                    child: _buildOptionBox(
                      label: 'A',
                      text: optionAText,
                      imageUrl: optionAImage,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: VersusSpacing.xs),
                  Text(
                    'VS',
                    style: VersusTextStyles.labelSmall.copyWith(
                      color: isMe ? Colors.white : VersusColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: VersusSpacing.xs),
                  Expanded(
                    child: _buildOptionBox(
                      label: 'B',
                      text: optionBText,
                      imageUrl: optionBImage,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                ],
              ),
              
              // 타임스탬프
              if (timestamp != null) ...[
                const SizedBox(height: VersusSpacing.xs),
                Text(
                  _formatTime(timestamp!),
                  style: VersusTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: isMe ? Colors.white.withValues(alpha: 0.6) : VersusColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionBox({
    required String label,
    required String text,
    String? imageUrl,
    required Color color,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: VersusTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Text(
              text,
              style: VersusTextStyles.bodySmall.copyWith(
                color: imageUrl != null ? Colors.white : color,
                fontWeight: FontWeight.w600,
                shadows: imageUrl != null
                    ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (voteStatus) {
      case 'completed':
        return Colors.green;
      case 'expired':
        return Colors.grey;
      case 'pending':
      default:
        return VersusColors.primary;
    }
  }

  String _getStatusText() {
    switch (voteStatus) {
      case 'completed':
        return '완료';
      case 'expired':
        return '만료';
      case 'pending':
      default:
        return '대기중';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}