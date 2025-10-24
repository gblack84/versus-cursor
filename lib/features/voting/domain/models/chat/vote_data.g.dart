// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteData _$VoteDataFromJson(Map<String, dynamic> json) => _VoteData(
  voteStartTime: _dateTimeFromTimestamp(json['voteStartTime']),
  voteEndTime: _dateTimeFromTimestamp(json['voteEndTime']),
  voteStatus: json['voteStatus'] as String? ?? '',
  voteCompleted: json['voteCompleted'] as bool? ?? false,
  isVotingComplete: json['isVotingComplete'] as bool? ?? false,
  votesA: (json['votesA'] as num?)?.toInt() ?? 0,
  votesB: (json['votesB'] as num?)?.toInt() ?? 0,
  votedUserIdsA:
      (json['votedUserIdsA'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  votedUserIdsB:
      (json['votedUserIdsB'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
  voteTimeout: json['voteTimeout'] as bool? ?? false,
  voteCompletedAt: _dateTimeFromTimestamp(json['voteCompletedAt']),
  voteCancelledAt: _dateTimeFromTimestamp(json['voteCancelledAt']),
  voteCancelledReason: json['voteCancelledReason'] as String? ?? '',
  notificationsSent: json['notificationsSent'] as bool? ?? false,
  notificationsSentAt: _dateTimeFromTimestamp(json['notificationsSentAt']),
  displayVotesA: (json['displayVotesA'] as num?)?.toInt() ?? 0,
  displayVotesB: (json['displayVotesB'] as num?)?.toInt() ?? 0,
  displayPercentA: (json['displayPercentA'] as num?)?.toInt() ?? 0,
  displayPercentB: (json['displayPercentB'] as num?)?.toInt() ?? 0,
  actualVotesA: (json['actualVotesA'] as num?)?.toInt() ?? 0,
  actualVotesB: (json['actualVotesB'] as num?)?.toInt() ?? 0,
  actualTotalVotes: (json['actualTotalVotes'] as num?)?.toInt() ?? 0,
  expansionPointsUsed: (json['expansionPointsUsed'] as num?)?.toInt() ?? 0,
  expandedUserCount: (json['expandedUserCount'] as num?)?.toInt() ?? 0,
  expansionStatus: json['expansionStatus'] as String? ?? '',
);

Map<String, dynamic> _$VoteDataToJson(_VoteData instance) => <String, dynamic>{
  'voteStartTime': _dateTimeToTimestamp(instance.voteStartTime),
  'voteEndTime': _dateTimeToTimestamp(instance.voteEndTime),
  'voteStatus': instance.voteStatus,
  'voteCompleted': instance.voteCompleted,
  'isVotingComplete': instance.isVotingComplete,
  'votesA': instance.votesA,
  'votesB': instance.votesB,
  'votedUserIdsA': instance.votedUserIdsA,
  'votedUserIdsB': instance.votedUserIdsB,
  'totalVotes': instance.totalVotes,
  'voteTimeout': instance.voteTimeout,
  'voteCompletedAt': _dateTimeToTimestamp(instance.voteCompletedAt),
  'voteCancelledAt': _dateTimeToTimestamp(instance.voteCancelledAt),
  'voteCancelledReason': instance.voteCancelledReason,
  'notificationsSent': instance.notificationsSent,
  'notificationsSentAt': _dateTimeToTimestamp(instance.notificationsSentAt),
  'displayVotesA': instance.displayVotesA,
  'displayVotesB': instance.displayVotesB,
  'displayPercentA': instance.displayPercentA,
  'displayPercentB': instance.displayPercentB,
  'actualVotesA': instance.actualVotesA,
  'actualVotesB': instance.actualVotesB,
  'actualTotalVotes': instance.actualTotalVotes,
  'expansionPointsUsed': instance.expansionPointsUsed,
  'expandedUserCount': instance.expandedUserCount,
  'expansionStatus': instance.expansionStatus,
};
