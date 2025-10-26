// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteOptions _$VoteOptionsFromJson(Map<String, dynamic> json) => _VoteOptions(
  optionATitle: json['optionATitle'] as String,
  optionBTitle: json['optionBTitle'] as String,
  optionADescription: json['optionADescription'] as String?,
  optionBDescription: json['optionBDescription'] as String?,
  optionAImageUrls:
      (json['optionAImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  optionBImageUrls:
      (json['optionBImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  optionAAspectRatio: (json['optionAAspectRatio'] as num?)?.toDouble(),
  optionBAspectRatio: (json['optionBAspectRatio'] as num?)?.toDouble(),
  relatedInterests:
      (json['relatedInterests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$VoteOptionsToJson(_VoteOptions instance) =>
    <String, dynamic>{
      'optionATitle': instance.optionATitle,
      'optionBTitle': instance.optionBTitle,
      'optionADescription': instance.optionADescription,
      'optionBDescription': instance.optionBDescription,
      'optionAImageUrls': instance.optionAImageUrls,
      'optionBImageUrls': instance.optionBImageUrls,
      'optionAAspectRatio': instance.optionAAspectRatio,
      'optionBAspectRatio': instance.optionBAspectRatio,
      'relatedInterests': instance.relatedInterests,
      'metadata': instance.metadata,
    };
