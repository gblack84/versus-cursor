import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/presentation/dialogs/voting_dialog.dart';
import '/features/voting/domain/models/vote_state.dart';
import '/services/ui/models/box_sizes.dart';
import '/features/voting/domain/coordinators/vote_state_coordinator.dart';
import 'vote_timer_widget.dart';
import 'vote_options_widget.dart';
import 'vote_results_widget.dart';
import 'vote_status_badge.dart';

/// 리팩토링된 투표 카드 메인 위젯
/// 모든 하위 컴포넌트를 조합하여 완전한 투표 카드를 구성합니다
class VoteCardWidget extends StatefulWidget {
  const VoteCardWidget({
    super.key,
    required this.postId,
    required this.title,
    this.description,
    required this.optionAText,
    required this.optionBText,
    required this.optionAImages,
    required this.optionBImages,
    required this.boxSizes,
    required this.isHorizontal,
    required this.cardStatus,
    this.voteEndTime,
    this.userVotes,
    this.voteResults,
    required this.isMe,
    this.currentUserName,
    this.searchQuery,
    this.onVote,
  });
  final String postId;
  final String title;
  final String? description;
  final String optionAText;
  final String optionBText;
  final List<String> optionAImages;
  final List<String> optionBImages;
  final BoxSizes boxSizes;
  final bool isHorizontal;
  final String cardStatus;
  final DateTime? voteEndTime;
  final List<String>? userVotes;
  final Map<String, dynamic>? voteResults;
  final bool isMe;
  final String? currentUserName;
  final String? searchQuery;
  final Function(String)? onVote;

  @override
  State<VoteCardWidget> createState() => _VoteCardWidgetState();
}

class _VoteCardWidgetState extends State<VoteCardWidget> {
  bool _isVoting = false;
  late Stream<VoteStateData> _voteStateStream;

  @override
  void initState() {
    super.initState();
    _initializeVoteStateStream();
  }

  void _initializeVoteStateStream() {
    _voteStateStream = VoteStateCoordinator.instance.getVoteStateStream(
      postId: widget.postId,
      voteEndTime: widget.voteEndTime,
      initialStatus: widget.cardStatus,
      userVotes: widget.userVotes,
    );
  }

  @override
  void didUpdateWidget(VoteCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.postId != widget.postId ||
        oldWidget.voteEndTime != widget.voteEndTime ||
        oldWidget.cardStatus != widget.cardStatus) {
      VoteStateCoordinator.instance.dispose(oldWidget.postId);
      _initializeVoteStateStream();
    }
  }

  @override
  void dispose() {
    VoteStateCoordinator.instance.dispose(widget.postId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VoteStateData>(
      stream: _voteStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard();
        }

        final stateData = snapshot.data ??
            VoteStateData(
              state: _mapInitialStatus(widget.cardStatus),
              voteEndTime: widget.voteEndTime,
            );

        return _buildCard(stateData);
      },
    );
  }

  Widget _buildCard(VoteStateData stateData) {
    return GestureDetector(
      onTap: () => _handleTap(stateData.state),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
              // 헤더 (상태 배지, 타이머)
              _buildHeader(stateData),
              const SizedBox(height: VersusSpacing.sm),

              // 제목
              _buildTitle(),
              if (widget.description != null) ...[
                const SizedBox(height: VersusSpacing.xs),
                _buildDescription(),
              ],
              const SizedBox(height: VersusSpacing.md),

              // 투표 옵션 또는 결과
              if (stateData.state == VoteState.completed &&
                  widget.voteResults != null)
                VoteResultsWidget(
                  currentUserName: widget.currentUserName,
                  state: stateData.state,
                  voteResults: widget.voteResults,
                )
              else
                VoteOptionsWidget(
                  optionAText: widget.optionAText,
                  optionBText: widget.optionBText,
                  optionAImages: widget.optionAImages,
                  optionBImages: widget.optionBImages,
                  boxSizes: widget.boxSizes,
                  isHorizontal: widget.isHorizontal,
                ),

              const SizedBox(height: VersusSpacing.md),

              // 액션 버튼
              _buildActionButton(stateData.state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VoteStateData stateData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 상태 배지
        VoteStatusBadge(
          state: stateData.state,
          hasUserVoted: stateData.hasUserVoted,
        ),

        // 타이머
        if (stateData.state == VoteState.inProgress &&
            !stateData.isTimerExpired)
          VoteTimerWidget(
            state: stateData.state,
            remainingTime: stateData.remainingTime,
            isTimerExpired: stateData.isTimerExpired,
            hasUserVoted: stateData.hasUserVoted,
          ),
      ],
    );
  }

  Widget _buildTitle() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return Text(
        widget.title,
        style: VersusTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 검색어 하이라이팅 로직
    return _highlightText(
        widget.title,
        VersusTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
        ));
  }

  Widget _buildDescription() {
    if (widget.description == null) return const SizedBox.shrink();

    return Text(
      widget.description!,
      style: VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButton(VoteState state) {
    String buttonText;
    if (widget.isMe) {
      buttonText = '투표 현황 보기';
    } else {
      buttonText = state == VoteState.votingRequest ? '투표하기' : '투표 현황 보기';
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isVoting ? null : () => _handleActionTap(state),
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
          buttonText,
          style: VersusTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(VersusSpacing.md),
      decoration: BoxDecoration(
        color: VersusColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: VersusColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '투표 카드를 불러올 수 없습니다',
          style: VersusTextStyles.bodyMedium.copyWith(
            color: VersusColors.error,
          ),
        ),
      ),
    );
  }

  void _handleTap(VoteState state) {
    if (_isVoting) return;

    setState(() {
      _isVoting = true;
    });

    if (state == VoteState.votingRequest) {
      _showVotingDialog();
    } else {
      _navigateToPost();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    });
  }

  void _handleActionTap(VoteState state) {
    if (_isVoting) return;

    setState(() {
      _isVoting = true;
    });

    if (state == VoteState.votingRequest) {
      _showVotingDialog();
    } else {
      _navigateToPost();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    });
  }

  void _navigateToPost() {
    context.pushNamed(
      'PostView',
      queryParameters: {'postId': widget.postId},
    );
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
          imageUrlA:
              widget.optionAImages.isNotEmpty ? widget.optionAImages[0] : null,
          imageUrlB:
              widget.optionBImages.isNotEmpty ? widget.optionBImages[0] : null,
          imageUrlsA: widget.optionAImages,
          imageUrlsB: widget.optionBImages,
          aspectRatioA: null, // TODO: aspectRatio 전달 필요
          aspectRatioB: null, // TODO: aspectRatio 전달 필요
          onVote: (option) async {
            if (widget.onVote != null) {
              await widget.onVote!(option);
            }
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

  Widget _highlightText(String text, TextStyle baseStyle) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = widget.searchQuery!.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final beforeText = text.substring(0, index);
    final matchText = text.substring(index, index + widget.searchQuery!.length);
    final afterText = text.substring(index + widget.searchQuery!.length);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: beforeText, style: baseStyle),
          TextSpan(
            text: matchText,
            style: baseStyle.copyWith(
              backgroundColor: VersusColors.primary.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: afterText, style: baseStyle),
        ],
      ),
    );
  }

  VoteState _mapInitialStatus(String status) {
    switch (status) {
      case 'votingRequest':
        return VoteState.votingRequest;
      case 'completed':
        return VoteState.completed;
      case 'expired':
        return VoteState.expired;
      case 'notParticipated':
        return VoteState.notParticipated;
      case 'inProgress':
        return VoteState.inProgress;
      default:
        return VoteState.inProgress;
    }
  }
}
