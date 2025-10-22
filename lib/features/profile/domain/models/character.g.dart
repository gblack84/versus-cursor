// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Character _$CharacterFromJson(Map<String, dynamic> json) => _Character(
  characterId: json['characterId'] as String,
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  characterType: json['characterType'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CharacterToJson(_Character instance) =>
    <String, dynamic>{
      'characterId': instance.characterId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'isActive': instance.isActive,
      'characterType': instance.characterType,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
