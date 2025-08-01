import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '/design_system/design_system.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/notifications/voting_notification_dialog.dart';

/// AI 피클 채팅에서 사용되는 투표 카드 메시지 위젯
/// 4가지 상태를 지원: voting_request, in_progress, completed, not_participated
class VoteCardMessage extends StatefulWidget {
  const VoteCardMessage({
    super.key,
    required this.postId,
    required this.title,
    this.description,
    required this.optionAText,
    required this.optionBText,
    this.optionAImage,
    this.optionBImage,
    this.optionAImages,
    this.optionBImages,
    required this.cardStatus,
    this.voteEndTime,
    this.userVoted = false,
    this.voteChoice,
    this.voteResults,
    required this.isMe,
    required this.timestamp,
    required this.messageType,
  });

  final String postId;
  final String title;
  final String? description;
  final String optionAText;
  final String optionBText;
  final String? optionAImage;
  final String? optionBImage;
  final List<String>? optionAImages;
  final List<String>? optionBImages;
  final String cardStatus; // voting_request, in_progress, completed, not_participated
  final DateTime? voteEndTime;
  final bool userVoted;
  final String? voteChoice;
  final Map<String, dynamic>? voteResults;
  final bool isMe;
  final DateTime? timestamp;
  final String messageType; // vote_request, vote_created

  @override
  State<VoteCardMessage> createState() => _VoteCardMessageState();
}

class _VoteCardMessageState extends State<VoteCardMessage> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    if (widget.voteEndTime != null && 
        (widget.cardStatus == 'voting_request' || widget.cardStatus == 'in_progress')) {
      _updateRemainingTime();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemainingTime();
      });
    }
  }
  
  void _updateRemainingTime() {
    final now = DateTime.now();
    final endTime = widget.voteEndTime;
    
    if (endTime != null && endTime.isAfter(now)) {
      setState(() {
        _remainingTime = endTime.difference(now);
      });
    } else {
      _timer?.cancel();
      setState(() {
        _remainingTime = Duration.zero;
      });
    }
  }
  
  String _formatRemainingTime() {
    if (_remainingTime.inSeconds <= 0) {
      return '투표 종료';
    }
    
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes}분 ${seconds}초 남음';
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        margin: EdgeInsets.only(
          left: widget.isMe ? 50 : 16,
          right: widget.isMe ? 16 : 50,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: widget.isMe ? VersusColors.primary : VersusColors.backgroundSecondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
            bottomRight: Radius.circular(widget.isMe ? 4 : 16),
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
              _buildHeader(statusInfo),
              const SizedBox(height: VersusSpacing.sm),
              _buildTitle(),
              if (widget.description != null && widget.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildDescription(),
              ],
              const SizedBox(height: VersusSpacing.sm),
              _buildVersusBoxes(),
              if (_shouldShowTimer()) ...[
                const SizedBox(height: VersusSpacing.sm),
                _buildTimer(),
              ],
              if (_shouldShowAction()) ...[
                const SizedBox(height: VersusSpacing.sm),
                _buildActionButton(),
              ],
              if (_shouldShowResult()) ...[
                const SizedBox(height: VersusSpacing.sm),
                _buildResults(),
              ],
              if (widget.timestamp != null) ...[
                const SizedBox(height: VersusSpacing.xs),
                _buildTimestamp(),
              ],
            ],
          ),
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
            color: widget.isMe ? Colors.white : VersusColors.textSecondary,
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
        color: widget.isMe ? Colors.white : VersusColors.textPrimary,
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
        color: widget.isMe ? Colors.white.withValues(alpha: 0.8) : VersusColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildVersusBoxes() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionBox(
            label: 'A',
            text: widget.optionAText,
            imageUrl: widget.optionAImage,
            images: widget.optionAImages,
            color: const Color(0xFFFF6B6B),
            isSelected: widget.voteChoice == 'A',
            votePercentage: widget.voteResults?['percentageA'],
            voteCount: widget.voteResults?['votesA'],
          ),
        ),
        const SizedBox(width: VersusSpacing.xs),
        Text(
          'VS',
          style: VersusTextStyles.labelSmall.copyWith(
            color: widget.isMe ? Colors.white : VersusColors.textSecondary,
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
            isSelected: widget.voteChoice == 'B',
            votePercentage: widget.voteResults?['percentageB'],
            voteCount: widget.voteResults?['votesB'],
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
  }) {
    final effectiveImageUrl = (images != null && images.isNotEmpty) ? images.first : imageUrl;
    final hasMultipleImages = (images != null && images.length > 1);
    
    return Container(
      height: 100,
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
  
  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VersusSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: VersusColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: VersusColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatRemainingTime(),
            style: VersusTextStyles.labelSmall.copyWith(
              color: VersusColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
  
  Widget _buildTimestamp() {
    return Text(
      _formatTime(widget.timestamp!),
      style: VersusTextStyles.labelSmall.copyWith(
        fontSize: 11,
        color: widget.isMe ? Colors.white.withValues(alpha: 0.6) : VersusColors.textSecondary,
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
            await _submitVote(option);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onDismiss: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
  Future<void> _submitVote(String option) async {
    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);
      
      final userId = currentUserUid;
      if (userId.isEmpty) return;
      
      // 투표 업데이트
      if (option == 'A') {
        await postRef.update({
          'votedUserIDsA': FieldValue.arrayUnion([userId]),
        });
      } else {
        await postRef.update({
          'votedUserIDsB': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print('투표 실패: $e');
    }
  }
  
  bool _shouldShowTimer() {
    return (widget.cardStatus == 'voting_request' || 
            widget.cardStatus == 'in_progress') &&
           widget.voteEndTime != null &&
           _remainingTime.inSeconds > 0;
  }
  
  bool _shouldShowAction() {
    return widget.cardStatus == 'voting_request' || 
           (widget.cardStatus == 'in_progress' && widget.messageType == 'vote_created');
  }
  
  bool _shouldShowResult() {
    return widget.cardStatus == 'completed' && widget.voteResults != null;
  }
  
  Map<String, dynamic> _getStatusInfo() {
    switch (widget.cardStatus) {
      case 'voting_request':
        return {
          'text': '피클요청',
          'color': VersusColors.primary,
          'icon': Icons.how_to_vote,
        };
      case 'in_progress':
        return {
          'text': '진행중',
          'color': VersusColors.warning,
          'icon': Icons.timer,
        };
      case 'completed':
        return {
          'text': '완료',
          'color': VersusColors.success,
          'icon': Icons.check_circle,
        };
      case 'not_participated':
        return {
          'text': '미참여',
          'color': VersusColors.textSecondary,
          'icon': Icons.block,
        };
      default:
        return {
          'text': '알 수 없음',
          'color': VersusColors.textSecondary,
          'icon': Icons.help,
        };
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