// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vote _$VoteFromJson(Map<String, dynamic> json) => _Vote(
  postId: json['postId'] as String,
  userId: json['userId'] as String,
  choice: json['choice'] as String,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$VoteToJson(_Vote instance) => <String, dynamic>{
  'postId': instance.postId,
  'userId': instance.userId,
  'choice': instance.choice,
  'timestamp': instance.timestamp?.toIso8601String(),
};
