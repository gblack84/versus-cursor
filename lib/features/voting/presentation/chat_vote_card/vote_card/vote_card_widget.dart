import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/presentation/dialogs/voting_dialog.dart';
import '/features/voting/domain/entities/chat/vote_state.dart';
import '/services/ui/models/box_sizes.dart';
import '/features/voting/presentation/providers/vote_state_providers.dart';
import 'components/vote_card_profile_header.dart';
import 'components/vote_card_header.dart';
import 'components/vote_card_body.dart';
import 'components/vote_card_footer.dart';
import 'utils/vote_card_helpers.dart';

/// 리팩토링된 투표 카드 메인 위젯
/// 모든 하위 컴포넌트를 조합하여 완전한 투표 카드를 구성합니다
class VoteCardWidget extends ConsumerStatefulWidget {
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
    // Profile parameters for Phase 3
    this.senderDisplayName,
    this.senderProfileImageUrl,
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
  final Map<String, dynamic>? userVotes;
  final Map<String, dynamic>? voteResults;
  final bool isMe;
  final String? currentUserName;
  final String? searchQuery;
  final Function(String)? onVote;

  // Profile information
  final String? senderDisplayName;
  final String? senderProfileImageUrl;

  @override
  ConsumerState<VoteCardWidget> createState() => _VoteCardWidgetState();
}

class _VoteCardWidgetState extends ConsumerState<VoteCardWidget> {
  bool _isVoting = false;

  @override
  Widget build(BuildContext context) {
    // StreamProvider 사용 (Coordinator 대체)
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final voteStateParams = VoteStateParams(
      postId: widget.postId,
      userId: userId,
      voteEndTime: widget.voteEndTime,
    );

    final voteStateAsync = ref.watch(voteStateStreamProvider(voteStateParams));

    return voteStateAsync.when(
      loading: () {
        // 로딩 중에는 기본 상태 표시
        final defaultState = VoteStateData(
          state: VoteCardHelpers.mapStatusToState(widget.cardStatus),
          voteEndTime: widget.voteEndTime,
        );
        return _buildCard(defaultState);
      },
      error: (error, stack) => _buildErrorCard(),
      data: (stateData) => _buildCard(stateData),
    );
  }

  Widget _buildCard(VoteStateData stateData) {
    // 상태 정보 생성
    final statusInfo = {
      'text': VoteCardHelpers.getStateDisplayText(stateData.state),
      'color': VoteCardHelpers.getStateColor(stateData.state),
      'icon': VoteCardHelpers.getStateIcon(stateData.state),
    };

    return GestureDetector(
      onTap: () => _handleCardTap(stateData.state),
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
              // 프로필 헤더 컴포넌트 (새로 추가)
              VoteCardProfileHeader(
                isMe: widget.isMe,
                statusInfo: statusInfo,
                displayName: widget.senderDisplayName,
                senderProfileImageUrl: widget.senderProfileImageUrl,
                currentUserName: widget.currentUserName,
              ),
              const SizedBox(height: VersusSpacing.sm),

              // 헤더 컴포넌트
              VoteCardHeader(
                state: stateData.state,
                hasUserVoted: stateData.hasUserVoted,
                remainingDuration: stateData.remainingTime,
                isTimerExpired: stateData.isTimerExpired,
              ),
              const SizedBox(height: VersusSpacing.sm),

              // 본문 컴포넌트
              VoteCardBody(
                title: widget.title,
                description: widget.description,
                searchQuery: widget.searchQuery,
                state: stateData.state,
                optionAText: widget.optionAText,
                optionBText: widget.optionBText,
                optionAImages: widget.optionAImages,
                optionBImages: widget.optionBImages,
                boxSizes: widget.boxSizes,
                isHorizontal: widget.isHorizontal,
                voteResults: widget.voteResults,
                currentUserName: widget.currentUserName,
              ),
              const SizedBox(height: VersusSpacing.md),

              // 푸터 컴포넌트
              VoteCardFooter(
                state: stateData.state,
                isMe: widget.isMe,
                isVoting: _isVoting,
                onPressed: () => _handleActionTap(stateData.state),
              ),
            ],
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

  void _handleCardTap(VoteState state) {
    if (_isVoting) return;
    _performAction(state);
  }

  void _handleActionTap(VoteState state) {
    if (_isVoting) return;
    _performAction(state);
  }

  void _performAction(VoteState state) {
    setState(() {
      _isVoting = true;
    });

    if (state == VoteState.votingRequest && !widget.isMe) {
      _showVotingDialog();
    } else {
      _navigateToPost();
    }

    // 액션 완료 후 상태 복구
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
          imageUrlA: widget.optionAImages.isNotEmpty 
              ? widget.optionAImages[0] 
              : null,
          imageUrlB: widget.optionBImages.isNotEmpty 
              ? widget.optionBImages[0] 
              : null,
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
}