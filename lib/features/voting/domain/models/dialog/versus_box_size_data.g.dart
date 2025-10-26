// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'versus_box_size_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VersusBoxSizeData _$VersusBoxSizeDataFromJson(Map<String, dynamic> json) =>
    _VersusBoxSizeData(
      layoutType: $enumDecode(_$LayoutTypeEnumMap, json['layoutType']),
      aspectRatioA: (json['aspectRatioA'] as num?)?.toDouble(),
      aspectRatioB: (json['aspectRatioB'] as num?)?.toDouble(),
      originalSizeA: const SizeConverter().fromJson(
        json['originalSizeA'] as Map<String, dynamic>,
      ),
      originalSizeB: const SizeConverter().fromJson(
        json['originalSizeB'] as Map<String, dynamic>,
      ),
      screenWidth: (json['screenWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      hasImageA: json['hasImageA'] as bool? ?? false,
      hasImageB: json['hasImageB'] as bool? ?? false,
    );

Map<String, dynamic> _$VersusBoxSizeDataToJson(_VersusBoxSizeData instance) =>
    <String, dynamic>{
      'layoutType': _$LayoutTypeEnumMap[instance.layoutType]!,
      'aspectRatioA': instance.aspectRatioA,
      'aspectRatioB': instance.aspectRatioB,
      'originalSizeA': const SizeConverter().toJson(instance.originalSizeA),
      'originalSizeB': const SizeConverter().toJson(instance.originalSizeB),
      'screenWidth': instance.screenWidth,
      'createdAt': instance.createdAt.toIso8601String(),
      'hasImageA': instance.hasImageA,
      'hasImageB': instance.hasImageB,
    };

const _$LayoutTypeEnumMap = {
  LayoutType.horizontal: 'horizontal',
  LayoutType.vertical: 'vertical',
  LayoutType.single: 'single',
  LayoutType.grid: 'grid',
  LayoutType.adaptive: 'adaptive',
};
