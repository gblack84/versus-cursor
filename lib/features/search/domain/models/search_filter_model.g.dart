// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchFilter _$SearchFilterFromJson(Map<String, dynamic> json) =>
    _SearchFilter(
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      sortBy: json['sortBy'] as String? ?? 'relevance',
      descending: json['descending'] as bool? ?? true,
    );

Map<String, dynamic> _$SearchFilterToJson(_SearchFilter instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'sortBy': instance.sortBy,
      'descending': instance.descending,
    };
