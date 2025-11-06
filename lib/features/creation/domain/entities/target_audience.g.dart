// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_audience.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TargetAudience _$TargetAudienceFromJson(Map<String, dynamic> json) =>
    _TargetAudience(
      collectionType: json['collectionType'] as String? ?? 'quick',
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 100,
      isPremium: json['isPremium'] as bool? ?? false,
      selectedInterests:
          (json['selectedInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      selectedAgeGroup: json['selectedAgeGroup'] as String? ?? '전체',
      selectedGender: json['selectedGender'] as String? ?? 'all',
      activeUserOnly: json['activeUserOnly'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$TargetAudienceToJson(_TargetAudience instance) =>
    <String, dynamic>{
      'collectionType': instance.collectionType,
      'targetCount': instance.targetCount,
      'isPremium': instance.isPremium,
      'selectedInterests': instance.selectedInterests,
      'selectedAgeGroup': instance.selectedAgeGroup,
      'selectedGender': instance.selectedGender,
      'activeUserOnly': instance.activeUserOnly,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
    };
