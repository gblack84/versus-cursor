// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchHistory _$SearchHistoryFromJson(Map<String, dynamic> json) =>
    _SearchHistory(
      searchId: json['searchId'] as String,
      userId: json['userId'] as String,
      query: json['query'] as String,
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$SearchHistoryToJson(_SearchHistory instance) =>
    <String, dynamic>{
      'searchId': instance.searchId,
      'userId': instance.userId,
      'query': instance.query,
      'date': instance.date?.toIso8601String(),
    };
