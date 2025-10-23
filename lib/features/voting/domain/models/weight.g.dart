// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weight _$WeightFromJson(Map<String, dynamic> json) => _Weight(
  nameInterest: json['nameInterest'] as String? ?? '',
  scoreInterest: (json['scoreInterest'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WeightToJson(_Weight instance) => <String, dynamic>{
  'nameInterest': instance.nameInterest,
  'scoreInterest': instance.scoreInterest,
};
