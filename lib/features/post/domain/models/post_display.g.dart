// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_display.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostDisplay _$PostDisplayFromJson(Map<String, dynamic> json) => _PostDisplay(
  id: json['id'] as String,
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String,
  questionTitle: json['questionTitle'] as String,
  description: json['description'] as String?,
  optionAText: json['optionAText'] as String?,
  optionBText: json['optionBText'] as String?,
  optionAImageUrl: json['optionAImageUrl'] as String?,
  optionBImageUrl: json['optionBImageUrl'] as String?,
  optionAImages: (json['optionAImages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  optionAAspectRatios: (json['optionAAspectRatios'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  optionBImages: (json['optionBImages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  optionBAspectRatios: (json['optionBAspectRatios'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  layoutType: json['layoutType'] as String? ?? 'vertical',
  votesA: (json['votesA'] as num?)?.toInt() ?? 0,
  votesB: (json['votesB'] as num?)?.toInt() ?? 0,
  voteStatus: json['voteStatus'] as String? ?? 'pending',
  voteCompleted: json['voteCompleted'] as bool? ?? false,
  voteStartTime: (json['voteStartTime'] as num?)?.toInt(),
  voteEndTime: (json['voteEndTime'] as num?)?.toInt(),
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  createdAt: (json['createdAt'] as num).toInt(),
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  status: json['status'] as String? ?? 'published',
  targetAudience: json['targetAudience'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PostDisplayToJson(_PostDisplay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'questionTitle': instance.questionTitle,
      'description': instance.description,
      'optionAText': instance.optionAText,
      'optionBText': instance.optionBText,
      'optionAImageUrl': instance.optionAImageUrl,
      'optionBImageUrl': instance.optionBImageUrl,
      'optionAImages': instance.optionAImages,
      'optionAAspectRatios': instance.optionAAspectRatios,
      'optionBImages': instance.optionBImages,
      'optionBAspectRatios': instance.optionBAspectRatios,
      'layoutType': instance.layoutType,
      'votesA': instance.votesA,
      'votesB': instance.votesB,
      'voteStatus': instance.voteStatus,
      'voteCompleted': instance.voteCompleted,
      'voteStartTime': instance.voteStartTime,
      'voteEndTime': instance.voteEndTime,
      'commentCount': instance.commentCount,
      'likeCount': instance.likeCount,
      'shareCount': instance.shareCount,
      'createdAt': instance.createdAt,
      'isAnonymous': instance.isAnonymous,
      'status': instance.status,
      'targetAudience': instance.targetAudience,
    };
