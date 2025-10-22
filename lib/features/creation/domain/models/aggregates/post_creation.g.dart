// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_creation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostCreation _$PostCreationFromJson(
  Map<String, dynamic> json,
) => _PostCreation(
  id: json['id'] as String?,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  optionA: PostOption.fromJson(json['optionA'] as Map<String, dynamic>),
  optionB: PostOption.fromJson(json['optionB'] as Map<String, dynamic>),
  targetAudience: json['targetAudience'] == null
      ? null
      : TargetAudience.fromJson(json['targetAudience'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  status:
      $enumDecodeNullable(_$PostStatusEnumMap, json['status']) ??
      PostStatus.draft,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  voteConfig: json['voteConfig'] == null
      ? null
      : VoteConfiguration.fromJson(json['voteConfig'] as Map<String, dynamic>),
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  category: json['category'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PostCreationToJson(_PostCreation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'optionA': instance.optionA,
      'optionB': instance.optionB,
      'targetAudience': instance.targetAudience,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'status': _$PostStatusEnumMap[instance.status]!,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'voteConfig': instance.voteConfig,
      'isAnonymous': instance.isAnonymous,
      'category': instance.category,
      'tags': instance.tags,
      'metadata': instance.metadata,
    };

const _$PostStatusEnumMap = {
  PostStatus.draft: 'draft',
  PostStatus.published: 'published',
  PostStatus.voting: 'voting',
  PostStatus.completed: 'completed',
  PostStatus.archived: 'archived',
  PostStatus.deleted: 'deleted',
};

_PostOption _$PostOptionFromJson(Map<String, dynamic> json) => _PostOption(
  text: json['text'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  videoUrls: (json['videoUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  aspectRatios:
      (json['aspectRatios'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PostOptionToJson(_PostOption instance) =>
    <String, dynamic>{
      'text': instance.text,
      'imageUrls': instance.imageUrls,
      'videoUrls': instance.videoUrls,
      'aspectRatios': instance.aspectRatios,
      'metadata': instance.metadata,
    };

_VoteConfiguration _$VoteConfigurationFromJson(Map<String, dynamic> json) =>
    _VoteConfiguration(
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: (json['duration'] as num?)?.toInt(),
      allowAnonymous: json['allowAnonymous'] as bool? ?? false,
      requiresExpansion: json['requiresExpansion'] as bool? ?? false,
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VoteConfigurationToJson(_VoteConfiguration instance) =>
    <String, dynamic>{
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration,
      'allowAnonymous': instance.allowAnonymous,
      'requiresExpansion': instance.requiresExpansion,
      'settings': instance.settings,
    };
