// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algolia_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlgoliaResult _$AlgoliaResultFromJson(Map<String, dynamic> json) =>
    _AlgoliaResult(
      hits: json['hits'] as List<dynamic>,
      totalHits: (json['totalHits'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      nbPages: (json['nbPages'] as num).toInt(),
      hitsPerPage: (json['hitsPerPage'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$AlgoliaResultToJson(_AlgoliaResult instance) =>
    <String, dynamic>{
      'hits': instance.hits,
      'totalHits': instance.totalHits,
      'page': instance.page,
      'nbPages': instance.nbPages,
      'hitsPerPage': instance.hitsPerPage,
    };
