// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteStateData _$VoteStateDataFromJson(Map<String, dynamic> json) =>
    _VoteStateData(
      state: $enumDecode(_$VoteStateEnumMap, json['state']),
      remainingTime: json['remainingTime'] == null
          ? null
          : Duration(microseconds: (json['remainingTime'] as num).toInt()),
      voteResults: json['voteResults'] as Map<String, dynamic>?,
      isTimerExpired: json['isTimerExpired'] as bool? ?? false,
      voteEndTime: json['voteEndTime'] == null
          ? null
          : DateTime.parse(json['voteEndTime'] as String),
      errorMessage: json['errorMessage'] as String?,
      hasUserVoted: json['hasUserVoted'] as bool? ?? false,
      userChoice: json['userChoice'] as String?,
    );

Map<String, dynamic> _$VoteStateDataToJson(_VoteStateData instance) =>
    <String, dynamic>{
      'state': _$VoteStateEnumMap[instance.state]!,
      'remainingTime': instance.remainingTime?.inMicroseconds,
      'voteResults': instance.voteResults,
      'isTimerExpired': instance.isTimerExpired,
      'voteEndTime': instance.voteEndTime?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'hasUserVoted': instance.hasUserVoted,
      'userChoice': instance.userChoice,
    };

const _$VoteStateEnumMap = {
  VoteState.votingRequest: 'votingRequest',
  VoteState.inProgress: 'inProgress',
  VoteState.completed: 'completed',
  VoteState.expired: 'expired',
  VoteState.notParticipated: 'notParticipated',
};
