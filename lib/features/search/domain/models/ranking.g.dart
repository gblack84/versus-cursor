// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ranking _$RankingFromJson(Map<String, dynamic> json) => _Ranking(
  rankingId: json['rankingId'] as String,
  type: json['type'] as String,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$RankingToJson(_Ranking instance) => <String, dynamic>{
  'rankingId': instance.rankingId,
  'type': instance.type,
  'date': instance.date?.toIso8601String(),
};
