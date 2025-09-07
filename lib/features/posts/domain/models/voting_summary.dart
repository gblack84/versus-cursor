import 'package:freezed_annotation/freezed_annotation.dart';
import 'post_voting.dart' show VoteStatus, VoteOption;

part 'voting_summary.freezed.dart';
part 'voting_summary.g.dart';

/// Simplified voting summary for UI display
@freezed
class VotingSummary with _$VotingSummary {
  const VotingSummary._();

  const factory VotingSummary({
    required String postId,
    required VoteStatus status,
    required int votesA,
    required int votesB,
    required double percentA,
    required double percentB,
    required Duration remainingTime,
    required bool hasUserVoted,
    VoteOption? userVote,
    DateTime? endTime,
    DateTime? completedAt,
  }) = _VotingSummary;

  factory VotingSummary.fromJson(Map<String, dynamic> json) =>
      _$VotingSummaryFromJson(json);

  /// Create from PostVoting model
  factory VotingSummary.fromPostVoting(
    PostVoting voting, {
    required String postId,
    String? userId,
  }) {
    return VotingSummary(
      postId: postId,
      status: voting.status,
      votesA: voting.displayVotesA ?? voting.votesA,
      votesB: voting.displayVotesB ?? voting.votesB,
      percentA: voting.displayPercentA?.toDouble() ?? voting.percentA,
      percentB: voting.displayPercentB?.toDouble() ?? voting.percentB,
      remainingTime: voting.remainingTime,
      hasUserVoted: userId != null ? voting.hasUserVoted(userId) : false,
      userVote: userId != null ? voting.getUserVote(userId) : null,
      endTime: voting.endTime,
      completedAt: voting.completedAt,
    );
  }

  // Computed properties for UI
  int get totalVotes => votesA + votesB;
  bool get isActive => status == VoteStatus.active && remainingTime > Duration.zero;
  bool get isCompleted => status == VoteStatus.completed;
  bool get showResults => isCompleted || hasUserVoted;
  
  String get formattedRemainingTime {
    if (!isActive) return '';
    
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get winnerLabel {
    if (!showResults) return '';
    if (votesA == votesB) return 'Tie';
    return votesA > votesB ? 'A' : 'B';
  }
  
  double get winnerPercentage {
    if (!showResults) return 0;
    return votesA >= votesB ? percentA : percentB;
  }
}