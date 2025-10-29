// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  uid: json['uid'] as String,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  userName: json['userName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  providerId: json['providerId'] as String?,
  bio: json['bio'] as String?,
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  expertise:
      (json['expertise'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  hobbies:
      (json['hobbies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  pointsA: (json['pointsA'] as num?)?.toInt() ?? 0,
  pointsQ: (json['pointsQ'] as num?)?.toInt() ?? 0,
  role: json['role'] == null
      ? UserRole.user
      : const UserRoleConverter().fromJson(json['role'] as String),
  isPremium: json['isPremium'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  settings: json['settings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'userName': instance.userName,
  'photoUrl': instance.photoUrl,
  'phoneNumber': instance.phoneNumber,
  'isEmailVerified': instance.isEmailVerified,
  'isAnonymous': instance.isAnonymous,
  'providerId': instance.providerId,
  'bio': instance.bio,
  'age': instance.age,
  'gender': instance.gender,
  'interests': instance.interests,
  'expertise': instance.expertise,
  'hobbies': instance.hobbies,
  'pointsA': instance.pointsA,
  'pointsQ': instance.pointsQ,
  'role': const UserRoleConverter().toJson(instance.role),
  'isPremium': instance.isPremium,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'settings': instance.settings,
};
