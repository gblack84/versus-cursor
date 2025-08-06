import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '/design_system/design_system.dart';
import '/components/notifications/voting_notification_dialog.dart';
import '/utils/responsive_breakpoints.dart';
import 'base_vote_message.dart';

/// AI 피클 채팅에서 사용되는 투표 카드 메시지 위젯
/// 4가지 상태를 지원: voting_request, in_progress, completed, not_participated
class VoteCardMessage extends BaseVoteMessage {
  const VoteCardMessage({
    super.key,
    required super.postId,
    required super.title,
    super.description,
    required super.optionAText,
    required super.optionBText,
    super.optionAImage,
    super.optionBImage,
    super.optionAImages,
    super.optionBImages,
    super.aspectRatioA,
    super.aspectRatioB,
    required super.cardStatus,
    super.voteEndTime,
    super.userVotes,
    super.voteResults,
    required super.isMe,
    super.timestamp,
    required super.messageType,
    super.messageId,
    super.chatId,
  });

  @override
  State<VoteCardMessage> createState() => _VoteCardMessageState();
}

class _VoteCardMessageState extends State<VoteCardMessage> 
    with BaseVoteMessageStateMixin<VoteCardMessage> {

  @override
  Widget build(BuildContext context) {
    final statusInfo = getStatusInfo();
    
    return GestureDetector(
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildHeader(statusInfo),
          const SizedBox(height: VersusSpacing.sm),
          _buildTitle(),
          if (widget.description != null && widget.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildDescription(),
          ],
          const SizedBox(height: VersusSpacing.sm),
          _buildVersusBoxes(),
          if (shouldShowTimer()) ...[
            const SizedBox(height: VersusSpacing.sm),
            buildTimer(),
          ],
          if (shouldShowAction()) ...[
            const SizedBox(height: VersusSpacing.sm),
            _buildActionButton(),
          ],
          if (shouldShowResult()) ...[
            const SizedBox(height: VersusSpacing.sm),
            _buildResults(),
          ],
          if (widget.timestamp != null) ...[
            const SizedBox(height: VersusSpacing.xs),
            buildTimestamp(),
          ],
        ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(Map<String, dynamic> statusInfo) {
    return Row(
      children: [
        Image.asset(
          'assets/images/pikle_icon.png',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: VersusSpacing.xs),
        Text(
          widget.messageType == 'vote_created' ? '내가 만든 피클' : 'Pikle 도착!',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textSecondary,
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
            color: (statusInfo['color'] as Color).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusInfo['icon'] as IconData,
                size: 12,
                color: statusInfo['color'] as Color,
              ),
              const SizedBox(width: 4),
              Text(
                statusInfo['text'] as String,
                style: VersusTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: statusInfo['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTitle() {
    return Text(
      widget.title,
      style: VersusTextStyles.bodyLarge.copyWith(
        color: VersusColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildDescription() {
    return Text(
      widget.description!,
      style: VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildVersusBoxes() {
    // 이미지 유무 확인
    final bool hasImages = widget.optionAImage != null || widget.optionBImage != null ||
        (widget.optionAImages != null && widget.optionAImages!.isNotEmpty) ||
        (widget.optionBImages != null && widget.optionBImages!.isNotEmpty);
    
    // 반응형 높이 계산
    final double boxHeight = ResponsiveBreakpoints.getVsBoxHeight(context, hasImages, false);
    
    // 단일 이미지 모드 체크 (B가 이미지 없이 텍스트만 있을 때)
    final bool hasOnlyTextB = widget.effectiveImageUrlsB.isEmpty && widget.optionBText.isNotEmpty;
    
    if (hasOnlyTextB) {
      // 단일 이미지 모드: 하나의 박스만 표시
      return _buildSingleImageBox(boxHeight);
    }
    
    // 일반 모드: 두 개의 박스 표시
    return Row(
      children: [
        Expanded(
          child: _buildOptionBox(
            label: 'A',
            text: widget.optionAText,
            imageUrl: widget.optionAImage,
            images: widget.optionAImages,
            color: const Color(0xFFFF6B6B),
            isSelected: widget.currentUserChoice == 'A',
            votePercentage: widget.voteResults?['percentageA'],
            voteCount: widget.voteResults?['votesA'],
            height: boxHeight,
          ),
        ),
        const SizedBox(width: VersusSpacing.xs),
        Text(
          'VS',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: VersusSpacing.xs),
        Expanded(
          child: _buildOptionBox(
            label: 'B',
            text: widget.optionBText,
            imageUrl: widget.optionBImage,
            images: widget.optionBImages,
            color: const Color(0xFF4ECDC4),
            isSelected: widget.currentUserChoice == 'B',
            votePercentage: widget.voteResults?['percentageB'],
            voteCount: widget.voteResults?['votesB'],
            height: boxHeight,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOptionBox({
    required String label,
    required String text,
    String? imageUrl,
    List<String>? images,
    required Color color,
    bool isSelected = false,
    double? votePercentage,
    int? voteCount,
    bool isSingleImageMode = false,
    String? dualModeSecondTitle,
    required double height,
  }) {
    final effectiveImageUrl = (images != null && images.isNotEmpty) ? images.first : imageUrl;
    final hasMultipleImages = (images != null && images.length > 1);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: effectiveImageUrl,
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
          if (hasMultipleImages)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${images.length}',
                      style: VersusTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSingleImageMode && dualModeSecondTitle != null) ...[
                  // 단일 이미지 모드: A/B 타이틀 함께 표시
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A 옵션
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'A',
                              style: VersusTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              text,
                              style: VersusTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // B 옵션
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'B',
                              style: VersusTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dualModeSecondTitle,
                              style: VersusTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  // 일반 모드: 각 옵션 텍스트만 표시
                  Text(
                    text,
                    style: VersusTextStyles.bodySmall.copyWith(
                      color: effectiveImageUrl != null ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                      shadows: effectiveImageUrl != null
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
                ],
                if (votePercentage != null && voteCount != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${votePercentage.toInt()}% (${voteCount}명)',
                      style: VersusTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSingleImageBox(double height) {
    // 단일 이미지 모드: B가 텍스트만 있을 때 하나의 박스에 A/B 모두 표시
    return _buildOptionBox(
      label: 'A',  // 라벨은 A로 표시하지만
      text: widget.optionAText,
      imageUrl: widget.optionAImage,
      images: widget.optionAImages,
      color: const Color(0xFFFF6B6B),
      isSelected: widget.hasCurrentUserVoted && widget.currentUserChoice == 'A',
      votePercentage: widget.voteResults?['percentageA'],
      voteCount: widget.voteResults?['votesA'],
      isSingleImageMode: true,
      dualModeSecondTitle: widget.optionBText,  // B 옵션 텍스트도 함께 전달
      height: height,
    );
  }
  
  
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleActionTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: VersusColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: VersusSpacing.sm,
          ),
        ),
        child: Text(
          widget.cardStatus == 'voting_request' ? '투표하기' : '투표 현황 보기',
          style: VersusTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildResults() {
    final winner = widget.voteResults?['winner'] ?? '';
    final totalVotes = widget.voteResults?['totalVotes'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(VersusSpacing.sm),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '투표 결과',
            style: VersusTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (winner == 'A') ...[
                Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: VersusColors.warning,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                winner == 'draw' ? '무승부' : '$winner 승리!',
                style: VersusTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: VersusColors.primary,
                ),
              ),
            ],
          ),
          Text(
            '총 ${totalVotes}명 참여',
            style: VersusTextStyles.labelSmall.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  
  void _handleTap() {
    if (widget.cardStatus == 'voting_request') {
      _showVotingDialog();
    } else {
      // 게시물 페이지로 이동
      context.pushNamed(
        'PostView',
        queryParameters: {'postId': widget.postId},
      );
    }
  }
  
  void _handleActionTap() {
    if (widget.cardStatus == 'voting_request') {
      _showVotingDialog();
    } else {
      context.pushNamed(
        'PostView',
        queryParameters: {'postId': widget.postId},
      );
    }
  }
  
  void _showVotingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: VotingNotificationDialog(
          question: widget.title,
          optionA: widget.optionAText,
          optionB: widget.optionBText,
          imageUrlA: widget.optionAImage,
          imageUrlB: widget.optionBImage,
          imageUrlsA: widget.optionAImages,
          imageUrlsB: widget.optionBImages,
          onVote: (option) async {
            // 투표 처리
            await submitVote(option);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onDismiss: (hasVoted) {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
}