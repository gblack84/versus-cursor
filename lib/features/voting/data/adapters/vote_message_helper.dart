import 'package:flutter/material.dart';

/// 투표 메시지 관련 헬퍼 클래스
class VoteMessageHelper {
  /// 투표 상태 아이콘 가져오기
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'votingRequest':
        return Icons.how_to_vote;
      case 'expired':
        return Icons.block;
      case 'notParticipated':
        return Icons.block;
      case 'inProgress':
        return Icons.timer;
      default:
        return Icons.help;
    }
  }
}
