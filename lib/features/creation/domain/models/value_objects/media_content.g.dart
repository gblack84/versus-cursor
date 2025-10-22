// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaContent _$MediaContentFromJson(Map<String, dynamic> json) =>
    _MediaContent(
      text: json['text'] as String? ?? '',
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videoUrl: json['videoUrl'] as String? ?? '',
      youtubeUrl: json['youtubeUrl'] as String? ?? '',
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
      aspectRatios:
          (json['aspectRatios'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      layoutType: json['layoutType'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'text',
      duration: (json['duration'] as num?)?.toInt(),
      fileSize: (json['fileSize'] as num?)?.toInt(),
      dimensions: json['dimensions'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MediaContentToJson(_MediaContent instance) =>
    <String, dynamic>{
      'text': instance.text,
      'imageUrls': instance.imageUrls,
      'videoUrl': instance.videoUrl,
      'youtubeUrl': instance.youtubeUrl,
      'aspectRatio': instance.aspectRatio,
      'aspectRatios': instance.aspectRatios,
      'layoutType': instance.layoutType,
      'thumbnailUrl': instance.thumbnailUrl,
      'mediaType': instance.mediaType,
      'duration': instance.duration,
      'fileSize': instance.fileSize,
      'dimensions': instance.dimensions,
    };
