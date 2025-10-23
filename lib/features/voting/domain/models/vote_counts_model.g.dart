// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_counts_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteCounts _$VoteCountsFromJson(Map<String, dynamic> json) => _VoteCounts(
  votesA: (json['votesA'] as num).toInt(),
  votesB: (json['votesB'] as num).toInt(),
  totalVotes: (json['totalVotes'] as num).toInt(),
);

Map<String, dynamic> _$VoteCountsToJson(_VoteCounts instance) =>
    <String, dynamic>{
      'votesA': instance.votesA,
      'votesB': instance.votesB,
      'totalVotes': instance.totalVotes,
    };
