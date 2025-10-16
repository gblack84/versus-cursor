// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voting_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VotingSummary _$VotingSummaryFromJson(Map<String, dynamic> json) =>
    _VotingSummary(
      postId: json['postId'] as String,
      status: $enumDecode(_$VoteStatusEnumMap, json['status']),
      votesA: (json['votesA'] as num).toInt(),
      votesB: (json['votesB'] as num).toInt(),
      percentA: (json['percentA'] as num).toDouble(),
      percentB: (json['percentB'] as num).toDouble(),
      remainingTime: Duration(
        microseconds: (json['remainingTime'] as num).toInt(),
      ),
      hasUserVoted: json['hasUserVoted'] as bool,
      userVote: $enumDecodeNullable(_$VoteOptionEnumMap, json['userVote']),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$VotingSummaryToJson(_VotingSummary instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'status': _$VoteStatusEnumMap[instance.status]!,
      'votesA': instance.votesA,
      'votesB': instance.votesB,
      'percentA': instance.percentA,
      'percentB': instance.percentB,
      'remainingTime': instance.remainingTime.inMicroseconds,
      'hasUserVoted': instance.hasUserVoted,
      'userVote': _$VoteOptionEnumMap[instance.userVote],
      'endTime': instance.endTime?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$VoteStatusEnumMap = {
  VoteStatus.pending: 'pending',
  VoteStatus.active: 'active',
  VoteStatus.completed: 'completed',
  VoteStatus.cancelled: 'cancelled',
  VoteStatus.timeout: 'timeout',
};

const _$VoteOptionEnumMap = {VoteOption.A: 'A', VoteOption.B: 'B'};
