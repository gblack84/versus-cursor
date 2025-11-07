// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileInfo _$ProfileInfoFromJson(Map<String, dynamic> json) => _ProfileInfo(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  shortDescription: json['shortDescription'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  language: json['language'] as String? ?? 'en',
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  expertise:
      (json['expertise'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  location: const LatLngConverter().fromJson(
    json['location'] as Map<String, dynamic>?,
  ),
);

Map<String, dynamic> _$ProfileInfoToJson(_ProfileInfo instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'shortDescription': instance.shortDescription,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'language': instance.language,
      'interests': instance.interests,
      'expertise': instance.expertise,
      'location': const LatLngConverter().toJson(instance.location),
    };
