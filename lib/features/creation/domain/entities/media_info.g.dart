// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageInfo _$ImageInfoFromJson(Map<String, dynamic> json) => ImageInfo(
  id: json['id'] as String,
  url: json['url'] as String,
  parentId: json['parentId'] as String?,
  aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  size: (json['size'] as num?)?.toInt(),
  mimeType: json['mimeType'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  thumbnailUrl: json['thumbnailUrl'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ImageInfoToJson(ImageInfo instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'parentId': instance.parentId,
  'aspectRatio': instance.aspectRatio,
  'width': instance.width,
  'height': instance.height,
  'size': instance.size,
  'mimeType': instance.mimeType,
  'createdAt': instance.createdAt?.toIso8601String(),
  'thumbnailUrl': instance.thumbnailUrl,
  'metadata': instance.metadata,
  'runtimeType': instance.$type,
};

VideoInfo _$VideoInfoFromJson(Map<String, dynamic> json) => VideoInfo(
  id: json['id'] as String,
  url: json['url'] as String,
  parentId: json['parentId'] as String?,
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  duration: (json['duration'] as num?)?.toDouble(),
  size: (json['size'] as num?)?.toInt(),
  mimeType: json['mimeType'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  thumbnailUrl: json['thumbnailUrl'] as String?,
  aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VideoInfoToJson(VideoInfo instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'parentId': instance.parentId,
  'width': instance.width,
  'height': instance.height,
  'duration': instance.duration,
  'size': instance.size,
  'mimeType': instance.mimeType,
  'createdAt': instance.createdAt?.toIso8601String(),
  'thumbnailUrl': instance.thumbnailUrl,
  'aspectRatio': instance.aspectRatio,
  'metadata': instance.metadata,
  'runtimeType': instance.$type,
};
