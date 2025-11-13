// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_encoding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoEncoding _$VideoEncodingFromJson(Map<String, dynamic> json) =>
    _VideoEncoding(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      outputUrl: json['outputUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$VideoEncodingToJson(_VideoEncoding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'status': instance.status,
      'progress': instance.progress,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'outputUrl': instance.outputUrl,
      'errorMessage': instance.errorMessage,
    };
