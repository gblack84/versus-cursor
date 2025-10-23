// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_display_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteDisplayData _$VoteDisplayDataFromJson(Map<String, dynamic> json) =>
    _VoteDisplayData(
      question: json['question'] as String,
      optionA: json['optionA'] as String,
      optionB: json['optionB'] as String,
      imageUrlA: json['imageUrlA'] as String?,
      imageUrlB: json['imageUrlB'] as String?,
      imageUrlsA: (json['imageUrlsA'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrlsB: (json['imageUrlsB'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String? ?? '',
      aspectRatioA: (json['aspectRatioA'] as num?)?.toDouble(),
      aspectRatioB: (json['aspectRatioB'] as num?)?.toDouble(),
      layoutType: json['layoutType'] as String?,
      authorName: json['authorName'] as String?,
    );

Map<String, dynamic> _$VoteDisplayDataToJson(_VoteDisplayData instance) =>
    <String, dynamic>{
      'question': instance.question,
      'optionA': instance.optionA,
      'optionB': instance.optionB,
      'imageUrlA': instance.imageUrlA,
      'imageUrlB': instance.imageUrlB,
      'imageUrlsA': instance.imageUrlsA,
      'imageUrlsB': instance.imageUrlsB,
      'description': instance.description,
      'aspectRatioA': instance.aspectRatioA,
      'aspectRatioB': instance.aspectRatioB,
      'layoutType': instance.layoutType,
      'authorName': instance.authorName,
    };
