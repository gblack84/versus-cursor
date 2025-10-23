// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_expansion_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteExpansionRequest _$VoteExpansionRequestFromJson(
  Map<String, dynamic> json,
) => _VoteExpansionRequest(
  userId: json['userId'] as String? ?? '',
  pointsUsed: (json['pointsUsed'] as num?)?.toInt() ?? 0,
  additionalUserCount: (json['additionalUserCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$VoteExpansionRequestToJson(
  _VoteExpansionRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'pointsUsed': instance.pointsUsed,
  'additionalUserCount': instance.additionalUserCount,
  'createdAt': instance.createdAt?.toIso8601String(),
};
