import 'package:flutter/foundation.dart';
import '/core/utils/ui/box_sizing/models/box_sizes.dart';

/// 투표 카드 속성 모델
/// 투표 카드 위젯에 전달되는 모든 속성을 관리합니다
@immutable
class VoteCardProps {
  const VoteCardProps({
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

  /// Props 복사 메서드
  VoteCardProps copyWith({
    String? postId,
    String? title,
    String? description,
    String? optionAText,
    String? optionBText,
    List<String>? optionAImages,
    List<String>? optionBImages,
    BoxSizes? boxSizes,
    bool? isHorizontal,
    String? cardStatus,
    DateTime? voteEndTime,
    List<String>? userVotes,
    Map<String, dynamic>? voteResults,
    bool? isMe,
    String? currentUserName,
    String? searchQuery,
    Function(String)? onVote,
  }) {
    return VoteCardProps(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      description: description ?? this.description,
      optionAText: optionAText ?? this.optionAText,
      optionBText: optionBText ?? this.optionBText,
      optionAImages: optionAImages ?? this.optionAImages,
      optionBImages: optionBImages ?? this.optionBImages,
      boxSizes: boxSizes ?? this.boxSizes,
      isHorizontal: isHorizontal ?? this.isHorizontal,
      cardStatus: cardStatus ?? this.cardStatus,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      userVotes: userVotes ?? this.userVotes,
      voteResults: voteResults ?? this.voteResults,
      isMe: isMe ?? this.isMe,
      currentUserName: currentUserName ?? this.currentUserName,
      searchQuery: searchQuery ?? this.searchQuery,
      onVote: onVote ?? this.onVote,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VoteCardProps &&
        other.postId == postId &&
        other.title == title &&
        other.description == description &&
        other.optionAText == optionAText &&
        other.optionBText == optionBText &&
        listEquals(other.optionAImages, optionAImages) &&
        listEquals(other.optionBImages, optionBImages) &&
        other.boxSizes == boxSizes &&
        other.isHorizontal == isHorizontal &&
        other.cardStatus == cardStatus &&
        other.voteEndTime == voteEndTime &&
        listEquals(other.userVotes, userVotes) &&
        mapEquals(other.voteResults, voteResults) &&
        other.isMe == isMe &&
        other.currentUserName == currentUserName &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return Object.hash(
      postId,
      title,
      description,
      optionAText,
      optionBText,
      optionAImages,
      optionBImages,
      boxSizes,
      isHorizontal,
      cardStatus,
      voteEndTime,
      userVotes,
      voteResults,
      isMe,
      currentUserName,
      searchQuery,
    );
  }
}