import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing voting data for a post
class VoteData extends Equatable {
  const VoteData({
    this.voteStartTime,
    this.voteEndTime,
    this.voteStatus = '',
    this.voteCompleted = false,
    this.isVotingComplete = false,
    this.votesA = 0,
    this.votesB = 0,
    this.votedUserIdsA = const [],
    this.votedUserIdsB = const [],
    this.totalVotes = 0,
    this.voteTimeout = false,
    this.voteCompletedAt,
    this.voteCancelledAt,
    this.voteCancelledReason = '',
    this.notificationsSent = false,
    this.notificationsSentAt,
    this.displayVotesA = 0,
    this.displayVotesB = 0,
    this.displayPercentA = 0,
    this.displayPercentB = 0,
    this.actualVotesA = 0,
    this.actualVotesB = 0,
    this.actualTotalVotes = 0,
    this.expansionPointsUsed = 0,
    this.expandedUserCount = 0,
    this.expansionStatus = '',
  });

  final DateTime? voteStartTime;
  final DateTime? voteEndTime;
  final String voteStatus;
  final bool voteCompleted;
  final bool isVotingComplete;
  final int votesA;
  final int votesB;
  final List<String> votedUserIdsA;
  final List<String> votedUserIdsB;
  final int totalVotes;
  final bool voteTimeout;
  final DateTime? voteCompletedAt;
  final DateTime? voteCancelledAt;
  final String voteCancelledReason;
  final bool notificationsSent;
  final DateTime? notificationsSentAt;
  final int displayVotesA;
  final int displayVotesB;
  final int displayPercentA;
  final int displayPercentB;
  final int actualVotesA;
  final int actualVotesB;
  final int actualTotalVotes;
  final int expansionPointsUsed;
  final int expandedUserCount;
  final String expansionStatus;

  /// Creates a copy of this vote data with the given fields replaced with new values
  VoteData copyWith({
    DateTime? voteStartTime,
    DateTime? voteEndTime,
    String? voteStatus,
    bool? voteCompleted,
    bool? isVotingComplete,
    int? votesA,
    int? votesB,
    List<String>? votedUserIdsA,
    List<String>? votedUserIdsB,
    int? totalVotes,
    bool? voteTimeout,
    DateTime? voteCompletedAt,
    DateTime? voteCancelledAt,
    String? voteCancelledReason,
    bool? notificationsSent,
    DateTime? notificationsSentAt,
    int? displayVotesA,
    int? displayVotesB,
    int? displayPercentA,
    int? displayPercentB,
    int? actualVotesA,
    int? actualVotesB,
    int? actualTotalVotes,
    int? expansionPointsUsed,
    int? expandedUserCount,
    String? expansionStatus,
  }) {
    return VoteData(
      voteStartTime: voteStartTime ?? this.voteStartTime,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      voteStatus: voteStatus ?? this.voteStatus,
      voteCompleted: voteCompleted ?? this.voteCompleted,
      isVotingComplete: isVotingComplete ?? this.isVotingComplete,
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      votedUserIdsA: votedUserIdsA ?? this.votedUserIdsA,
      votedUserIdsB: votedUserIdsB ?? this.votedUserIdsB,
      totalVotes: totalVotes ?? this.totalVotes,
      voteTimeout: voteTimeout ?? this.voteTimeout,
      voteCompletedAt: voteCompletedAt ?? this.voteCompletedAt,
      voteCancelledAt: voteCancelledAt ?? this.voteCancelledAt,
      voteCancelledReason: voteCancelledReason ?? this.voteCancelledReason,
      notificationsSent: notificationsSent ?? this.notificationsSent,
      notificationsSentAt: notificationsSentAt ?? this.notificationsSentAt,
      displayVotesA: displayVotesA ?? this.displayVotesA,
      displayVotesB: displayVotesB ?? this.displayVotesB,
      displayPercentA: displayPercentA ?? this.displayPercentA,
      displayPercentB: displayPercentB ?? this.displayPercentB,
      actualVotesA: actualVotesA ?? this.actualVotesA,
      actualVotesB: actualVotesB ?? this.actualVotesB,
      actualTotalVotes: actualTotalVotes ?? this.actualTotalVotes,
      expansionPointsUsed: expansionPointsUsed ?? this.expansionPointsUsed,
      expandedUserCount: expandedUserCount ?? this.expandedUserCount,
      expansionStatus: expansionStatus ?? this.expansionStatus,
    );
  }

  /// Converts this vote data to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'voteStartTime': voteStartTime,
      'voteEndTime': voteEndTime,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
      'isVotingComplete': isVotingComplete,
      'votesA': votesA,
      'votesB': votesB,
      'votedUserIdsA': votedUserIdsA,
      'votedUserIdsB': votedUserIdsB,
      'totalVotes': totalVotes,
      'voteTimeout': voteTimeout,
      'voteCompletedAt': voteCompletedAt,
      'voteCancelledAt': voteCancelledAt,
      'voteCancelledReason': voteCancelledReason,
      'notificationsSent': notificationsSent,
      'notificationsSentAt': notificationsSentAt,
      'displayVotesA': displayVotesA,
      'displayVotesB': displayVotesB,
      'displayPercentA': displayPercentA,
      'displayPercentB': displayPercentB,
      'actualVotesA': actualVotesA,
      'actualVotesB': actualVotesB,
      'actualTotalVotes': actualTotalVotes,
      'expansionPointsUsed': expansionPointsUsed,
      'expandedUserCount': expandedUserCount,
      'expansionStatus': expansionStatus,
    };
  }

  /// Creates vote data from a Firestore document
  factory VoteData.fromJson(Map<String, dynamic> json) {
    return VoteData(
      voteStartTime: (json['voteStartTime'] as Timestamp?)?.toDate(),
      voteEndTime: (json['voteEndTime'] as Timestamp?)?.toDate(),
      voteStatus: json['voteStatus'] ?? '',
      voteCompleted: json['voteCompleted'] ?? false,
      isVotingComplete: json['isVotingComplete'] ?? false,
      votesA: json['votesA'] ?? 0,
      votesB: json['votesB'] ?? 0,
      votedUserIdsA: List<String>.from(json['votedUserIdsA'] ?? []),
      votedUserIdsB: List<String>.from(json['votedUserIdsB'] ?? []),
      totalVotes: json['totalVotes'] ?? 0,
      voteTimeout: json['voteTimeout'] ?? false,
      voteCompletedAt: (json['voteCompletedAt'] as Timestamp?)?.toDate(),
      voteCancelledAt: (json['voteCancelledAt'] as Timestamp?)?.toDate(),
      voteCancelledReason: json['voteCancelledReason'] ?? '',
      notificationsSent: json['notificationsSent'] ?? false,
      notificationsSentAt: (json['notificationsSentAt'] as Timestamp?)?.toDate(),
      displayVotesA: json['displayVotesA'] ?? 0,
      displayVotesB: json['displayVotesB'] ?? 0,
      displayPercentA: json['displayPercentA'] ?? 0,
      displayPercentB: json['displayPercentB'] ?? 0,
      actualVotesA: json['actualVotesA'] ?? 0,
      actualVotesB: json['actualVotesB'] ?? 0,
      actualTotalVotes: json['actualTotalVotes'] ?? 0,
      expansionPointsUsed: json['expansionPointsUsed'] ?? 0,
      expandedUserCount: json['expandedUserCount'] ?? 0,
      expansionStatus: json['expansionStatus'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        voteStartTime,
        voteEndTime,
        voteStatus,
        voteCompleted,
        isVotingComplete,
        votesA,
        votesB,
        votedUserIdsA,
        votedUserIdsB,
        totalVotes,
        voteTimeout,
        voteCompletedAt,
        voteCancelledAt,
        voteCancelledReason,
        notificationsSent,
        notificationsSentAt,
        displayVotesA,
        displayVotesB,
        displayPercentA,
        displayPercentB,
        actualVotesA,
        actualVotesB,
        actualTotalVotes,
        expansionPointsUsed,
        expandedUserCount,
        expansionStatus,
      ];

  @override
  String toString() => 'VoteData(status: $voteStatus, votesA: $votesA, votesB: $votesB)';
}
