import 'package:flutter/material.dart';

/// 투표 메시지 관련 헬퍼 클래스
class VoteMessageHelper {
  /// 레거시 데이터를 새 구조로 변환
  static Map<String, dynamic> migrateVoteData(Map<String, dynamic> data) {
    // user_votes가 없으면 기존 필드에서 생성
    if (data['user_votes'] == null) {
      final userVotes = <String, dynamic>{};
      
      // 기존 userVoted 필드 마이그레이션
      if (data['user_voted'] == true && data['sender_id'] != null) {
        userVotes[data['sender_id']] = {
          'option': data['vote_choice'] ?? '',
          'voted_at': data['vote_participated_at'],
        };
      }
      
      data['user_votes'] = userVotes;
    }
    
    return data;
  }
  
  /// 투표 카드 타입 결정
  static String getCardType({
    required String messageType,
    required String? cardStatus,
    required String currentUserId,
    required String? senderId,
  }) {
    if (messageType == 'vote_created' && senderId == currentUserId) {
      return 'vote_created'; // 내가 만든 투표
    } else if (messageType == 'vote_request') {
      return 'vote_request'; // 받은 투표 요청
    }
    return 'vote_info'; // 기타
  }
  
  /// 투표 메시지 메타데이터 병합
  static Map<String, dynamic> mergeVoteMetadata(
    Map<String, dynamic> messageData,
    Map<String, dynamic>? existingMetadata,
  ) {
    final metadata = Map<String, dynamic>.from(existingMetadata ?? {});
    
    // Firebase와 Flutter 필드명 모두 지원
    metadata['postId'] ??= messageData['vote_post_id'];
    metadata['title'] ??= messageData['vote_title'];
    metadata['description'] ??= messageData['vote_description'];
    metadata['optionAText'] ??= messageData['vote_option_a_text'];
    metadata['optionBText'] ??= messageData['vote_option_b_text'];
    metadata['optionAImage'] ??= messageData['vote_option_a_image'];
    metadata['optionBImage'] ??= messageData['vote_option_b_image'];
    metadata['optionAImages'] ??= messageData['vote_option_a_images'];
    metadata['optionBImages'] ??= messageData['vote_option_b_images'];
    metadata['cardStatus'] ??= messageData['card_status'];
    metadata['voteStatus'] ??= messageData['vote_status'];
    metadata['voteEndTime'] ??= messageData['vote_end_time'];
    metadata['userVotes'] ??= messageData['user_votes'];
    metadata['voteResults'] ??= messageData['vote_results'];
    
    // 투표 결과 데이터가 있으면 추가
    if (messageData['vote_results'] != null) {
      final results = messageData['vote_results'] as Map<String, dynamic>;
      metadata['votePercentageA'] = results['percentageA'];
      metadata['votePercentageB'] = results['percentageB'];
      metadata['voteCountA'] = results['votesA'];
      metadata['voteCountB'] = results['votesB'];
    }
    
    return metadata;
  }
  
  /// 투표 상태 아이콘 가져오기
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'voting_request':
        return Icons.how_to_vote;
      case 'expired':
        return Icons.block;
      case 'not_participated':
        return Icons.block;
      case 'in_progress':
        return Icons.timer;
      default:
        return Icons.help;
    }
  }
}