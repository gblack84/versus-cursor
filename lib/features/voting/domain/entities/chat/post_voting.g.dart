// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_voting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostVoting _$PostVotingFromJson(Map<String, dynamic> json) => _PostVoting(
  postId: json['postId'] as String,
  voteStartTime: const TimestampConverter().fromJson(json['voteStartTime']),
  voteEndTime: const TimestampConverter().fromJson(json['voteEndTime']),
  voteStatus: json['voteStatus'] == null
      ? VoteStatus.pending
      : const VoteStatusConverter().fromJson(json['voteStatus']),
  voteCompleted: json['voteCompleted'] as bool? ?? false,
  voteCompletedAt: const TimestampConverter().fromJson(json['voteCompletedAt']),
  voteCancelledAt: const TimestampConverter().fromJson(json['voteCancelledAt']),
  voteCancelledReason: json['voteCancelledReason'] as String?,
  voteTimeout: json['voteTimeout'] == null
      ? const Duration(minutes: 10)
      : const DurationConverter().fromJson(
          (json['voteTimeout'] as num?)?.toInt(),
        ),
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
  notificationsSentAt: const TimestampConverter().fromJson(
    json['notificationsSentAt'],
  ),
  expansionPointsUsed: (json['expansionPointsUsed'] as num?)?.toInt() ?? 0,
  expandedUserCount: (json['expandedUserCount'] as num?)?.toInt() ?? 0,
  expansionStatus: json['expansionStatus'] as String? ?? 'none',
);

Map<String, dynamic> _$PostVotingToJson(
  _PostVoting instance,
) => <String, dynamic>{
  'postId': instance.postId,
  'voteStartTime': const TimestampConverter().toJson(instance.voteStartTime),
  'voteEndTime': const TimestampConverter().toJson(instance.voteEndTime),
  'voteStatus': const VoteStatusConverter().toJson(instance.voteStatus),
  'voteCompleted': instance.voteCompleted,
  'voteCompletedAt': const TimestampConverter().toJson(
    instance.voteCompletedAt,
  ),
  'voteCancelledAt': const TimestampConverter().toJson(
    instance.voteCancelledAt,
  ),
  'voteCancelledReason': instance.voteCancelledReason,
  'voteTimeout': const DurationConverter().toJson(instance.voteTimeout),
  'votesA': instance.votesA,
  'votesB': instance.votesB,
  'votedUserIdsA': instance.votedUserIdsA,
  'votedUserIdsB': instance.votedUserIdsB,
  'displayVotesA': instance.displayVotesA,
  'displayVotesB': instance.displayVotesB,
  'notificationsSent': instance.notificationsSent,
  'notificationsSentAt': const TimestampConverter().toJson(
    instance.notificationsSentAt,
  ),
  'expansionPointsUsed': instance.expansionPointsUsed,
  'expandedUserCount': instance.expandedUserCount,
  'expansionStatus': instance.expansionStatus,
};
