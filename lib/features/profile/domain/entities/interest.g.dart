// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Interest _$InterestFromJson(Map<String, dynamic> json) => _Interest(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  weight: (json['weight'] as num?)?.toDouble() ?? 0.5,
  selectedAt: json['selectedAt'] == null
      ? null
      : DateTime.parse(json['selectedAt'] as String),
);

Map<String, dynamic> _$InterestToJson(_Interest instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'weight': instance.weight,
  'selectedAt': instance.selectedAt?.toIso8601String(),
};
