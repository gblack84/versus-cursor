// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_cache_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteCacheState _$VoteCacheStateFromJson(Map<String, dynamic> json) =>
    _VoteCacheState(
      option: json['option'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$VoteCacheStateToJson(_VoteCacheState instance) =>
    <String, dynamic>{
      'option': instance.option,
      'timestamp': instance.timestamp?.toIso8601String(),
      'completed': instance.completed,
    };
