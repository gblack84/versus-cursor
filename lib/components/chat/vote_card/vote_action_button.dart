import 'package:flutter/material.dart';
import '/design_system/design_system.dart';

/// 투표 카드의 액션 버튼 컴포넌트
/// 
/// 투표하기 또는 투표 현황 보기 버튼을 표시합니다.
class VoteActionButton extends StatelessWidget {
  final bool isMe;
  final String cardStatus;
  final VoidCallback onPressed;
  
  const VoteActionButton({
    super.key,
    required this.isMe,
    required this.cardStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 버튼 텍스트 결정
    String buttonText;
    if (isMe) {
      // 내가 만든 투표
      buttonText = '투표 현황 보기';
    } else {
      // 남이 만든 투표
      buttonText = cardStatus == 'votingRequest' ? '투표하기' : '투표 현황 보기';
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
}