import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/entities/chat/vote_state.dart';

/// 투표 카드 푸터 컴포넌트
/// 액션 버튼을 표시하고 관리합니다
class VoteCardFooter extends StatelessWidget {
  const VoteCardFooter({
    super.key,
    required this.state,
    required this.isMe,
    required this.isVoting,
    required this.onPressed,
  });

  final VoteState state;
  final bool isMe;
  final bool isVoting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isVoting ? null : onPressed,
        style: _getButtonStyle(),
        child: Text(
          _getButtonText(),
          style: VersusTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    // 내 투표인 경우 항상 "투표 현황 보기"
    if (isMe) {
      return '투표 현황 보기';
    }
    
    // 다른 사람의 투표인 경우 상태에 따라 다름
    return state == VoteState.votingRequest ? '투표하기' : '투표 현황 보기';
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getButtonColor(),
      foregroundColor: Colors.white,
      disabledBackgroundColor: VersusColors.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: VersusSpacing.sm,
      ),
    );
  }

  Color _getButtonColor() {
    // 투표 중이면 비활성화 색상
    if (isVoting) {
      return VersusColors.backgroundSecondary;
    }

    // 투표 요청 상태이고 내가 아닌 경우 primary 색상
    if (state == VoteState.votingRequest && !isMe) {
      return VersusColors.primary;
    }

    // 그 외의 경우 secondary 색상
    return VersusColors.secondary;
  }
}