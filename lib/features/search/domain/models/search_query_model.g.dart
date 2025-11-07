// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_query_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchQuery _$SearchQueryFromJson(Map<String, dynamic> json) => _SearchQuery(
  query: json['query'] as String,
  filter: json['filter'] == null
      ? null
      : SearchFilter.fromJson(json['filter'] as Map<String, dynamic>),
  page: (json['page'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$SearchQueryToJson(_SearchQuery instance) =>
    <String, dynamic>{
      'query': instance.query,
      'filter': instance.filter,
      'page': instance.page,
      'limit': instance.limit,
    };
