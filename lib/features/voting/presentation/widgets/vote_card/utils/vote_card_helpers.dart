import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/vote_state.dart';
import '/features/voting/domain/constants/voting_constants.dart';

/// 투표 카드 헬퍼 유틸리티
/// 투표 카드에서 사용되는 공통 유틸리티 함수들을 제공합니다
class VoteCardHelpers {
  VoteCardHelpers._();

  /// 텍스트에서 검색어를 하이라이팅합니다
  static Widget highlightText({
    required String text,
    required String searchQuery,
    required TextStyle baseStyle,
    int maxLines = 2,
  }) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    // 검색어가 텍스트에 없으면 일반 텍스트로 반환
    if (index == -1) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 검색어 전후 텍스트 분리
    final beforeText = text.substring(0, index);
    final matchText = text.substring(index, index + searchQuery.length);
    final afterText = text.substring(index + searchQuery.length);

    return RichText(
      maxLines: maxLines,
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

  /// 문자열 상태를 VoteState enum으로 변환합니다
  static VoteState mapStatusToState(String status) {
    switch (status) {
      case VotingConstants.cardStatusVotingRequest:
        return VoteState.votingRequest;
      case VotingConstants.cardStatusCompleted:
        return VoteState.completed;
      case 'expired':
        return VoteState.expired;
      case 'notParticipated':
        return VoteState.notParticipated;
      case VotingConstants.cardStatusVoting:
        return VoteState.inProgress;
      default:
        return VoteState.inProgress;
    }
  }

  /// VoteState를 사용자 친화적인 문자열로 변환합니다
  static String getStateDisplayText(VoteState state) {
    switch (state) {
      case VoteState.votingRequest:
        return '투표 요청';
      case VoteState.inProgress:
        return '진행중';
      case VoteState.completed:
        return '완료';
      case VoteState.expired:
        return '만료';
      case VoteState.notParticipated:
        return '미참여';
    }
  }

  /// 상태에 따른 색상을 반환합니다
  static Color getStateColor(VoteState state) {
    switch (state) {
      case VoteState.votingRequest:
        return VersusColors.warning;
      case VoteState.inProgress:
        return VersusColors.primary;
      case VoteState.completed:
        return VersusColors.success;
      case VoteState.expired:
        return VersusColors.textSecondary;
      case VoteState.notParticipated:
        return VersusColors.textSecondary;
    }
  }

  /// 상태에 따른 아이콘을 반환합니다
  static IconData getStateIcon(VoteState state) {
    switch (state) {
      case VoteState.votingRequest:
        return Icons.notifications_active;
      case VoteState.inProgress:
        return Icons.access_time;
      case VoteState.completed:
        return Icons.check_circle;
      case VoteState.expired:
        return Icons.timer_off;
      case VoteState.notParticipated:
        return Icons.person_off;
    }
  }
}