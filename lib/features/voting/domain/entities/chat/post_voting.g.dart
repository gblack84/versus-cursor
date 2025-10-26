// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_voting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostVoting _$PostVotingFromJson(Map<String, dynamic> json) => _PostVoting(
  postId: json['postId'] as String,
  voteStartTime: _dateTimeFromTimestamp(json['voteStartTime']),
  voteEndTime: _dateTimeFromTimestamp(json['voteEndTime']),
  voteStatus: json['voteStatus'] == null
      ? VoteStatus.pending
      : _voteStatusFromJson(json['voteStatus']),
  voteCompleted: json['voteCompleted'] as bool? ?? false,
  voteCompletedAt: _dateTimeFromTimestamp(json['voteCompletedAt']),
  voteCancelledAt: _dateTimeFromTimestamp(json['voteCancelledAt']),
  voteCancelledReason: json['voteCancelledReason'] as String?,
  voteTimeout: json['voteTimeout'] == null
      ? const Duration(minutes: 10)
      : _durationFromJson((json['voteTimeout'] as num?)?.toInt()),
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
  displayVotesA: (json['displayVotesA'] as num?)?.toInt(),
  displayVotesB: (json['displayVotesB'] as num?)?.toInt(),
  notificationsSent: json['notificationsSent'] as bool? ?? false,
  notificationsSentAt: _dateTimeFromTimestamp(json['notificationsSentAt']),
  expansionPointsUsed: (json['expansionPointsUsed'] as num?)?.toInt() ?? 0,
  expandedUserCount: (json['expandedUserCount'] as num?)?.toInt() ?? 0,
  expansionStatus: json['expansionStatus'] as String? ?? 'none',
);

Map<String, dynamic> _$PostVotingToJson(_PostVoting instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'voteStartTime': _dateTimeToTimestamp(instance.voteStartTime),
      'voteEndTime': _dateTimeToTimestamp(instance.voteEndTime),
      'voteStatus': _voteStatusToJson(instance.voteStatus),
      'voteCompleted': instance.voteCompleted,
      'voteCompletedAt': _dateTimeToTimestamp(instance.voteCompletedAt),
      'voteCancelledAt': _dateTimeToTimestamp(instance.voteCancelledAt),
      'voteCancelledReason': instance.voteCancelledReason,
      'voteTimeout': _durationToJson(instance.voteTimeout),
      'votesA': instance.votesA,
      'votesB': instance.votesB,
      'votedUserIdsA': instance.votedUserIdsA,
      'votedUserIdsB': instance.votedUserIdsB,
      'displayVotesA': instance.displayVotesA,
      'displayVotesB': instance.displayVotesB,
      'notificationsSent': instance.notificationsSent,
      'notificationsSentAt': _dateTimeToTimestamp(instance.notificationsSentAt),
      'expansionPointsUsed': instance.expansionPointsUsed,
      'expandedUserCount': instance.expandedUserCount,
      'expansionStatus': instance.expansionStatus,
    };
