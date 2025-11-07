// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  location: const LatLngConverter().fromJson(
    json['location'] as Map<String, dynamic>?,
  ),
  shortDescription: json['shortDescription'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  language: json['language'] as String?,
  createdTime: json['createdTime'] == null
      ? null
      : DateTime.parse(json['createdTime'] as String),
  lastActive: json['lastActive'] == null
      ? null
      : DateTime.parse(json['lastActive'] as String),
  lastActiveTime: json['lastActiveTime'] == null
      ? null
      : DateTime.parse(json['lastActiveTime'] as String),
  pointsA: (json['pointsA'] as num?)?.toInt() ?? 0,
  pointsQ: (json['pointsQ'] as num?)?.toInt() ?? 0,
  totalAPoints: (json['totalAPoints'] as num?)?.toInt() ?? 0,
  totalQPoints: (json['totalQPoints'] as num?)?.toInt() ?? 0,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  expertise:
      (json['expertise'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  hobbies:
      (json['hobbies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  jobCategory: json['jobCategory'] as String?,
  jobName: json['jobName'] as String?,
  isPremiumUser: json['isPremiumUser'] as bool? ?? false,
  anonymousPostsCount: (json['anonymousPostsCount'] as num?)?.toInt() ?? 0,
  anonymousCommentsCount:
      (json['anonymousCommentsCount'] as num?)?.toInt() ?? 0,
  anonymousQuestionCount:
      (json['anonymousQuestionCount'] as num?)?.toInt() ?? 0,
  currentRank: json['currentRank'] as String?,
  currentTitle: json['currentTitle'] as String?,
  rankChangeDate: json['rankChangeDate'] == null
      ? null
      : DateTime.parse(json['rankChangeDate'] as String),
  titleChangeDate: json['titleChangeDate'] == null
      ? null
      : DateTime.parse(json['titleChangeDate'] as String),
  isRankEligible: json['isRankEligible'] as bool? ?? false,
  rankEvaluationCount: (json['rankEvaluationCount'] as num?)?.toInt() ?? 0,
  rankHistory:
      (json['rankHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  titleHistory:
      (json['titleHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  receiveRankUpdateNotifications:
      json['receiveRankUpdateNotifications'] as bool? ?? false,
  receiveTitleUpdateNotifications:
      json['receiveTitleUpdateNotifications'] as bool? ?? false,
  characterId: json['characterId'] as String?,
  friends:
      (json['friends'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  activeChats:
      (json['activeChats'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  groupChats:
      (json['groupChats'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  role: json['role'] as String?,
  title: json['title'] as String?,
  stats: json['stats'] as Map<String, dynamic>? ?? const {},
  subscription: json['subscription'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$UserProfileToJson(
  _UserProfile instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'phoneNumber': instance.phoneNumber,
  'location': const LatLngConverter().toJson(instance.location),
  'shortDescription': instance.shortDescription,
  'gender': instance.gender,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'language': instance.language,
  'createdTime': instance.createdTime?.toIso8601String(),
  'lastActive': instance.lastActive?.toIso8601String(),
  'lastActiveTime': instance.lastActiveTime?.toIso8601String(),
  'pointsA': instance.pointsA,
  'pointsQ': instance.pointsQ,
  'totalAPoints': instance.totalAPoints,
  'totalQPoints': instance.totalQPoints,
  'interests': instance.interests,
  'expertise': instance.expertise,
  'hobbies': instance.hobbies,
  'jobCategory': instance.jobCategory,
  'jobName': instance.jobName,
  'isPremiumUser': instance.isPremiumUser,
  'anonymousPostsCount': instance.anonymousPostsCount,
  'anonymousCommentsCount': instance.anonymousCommentsCount,
  'anonymousQuestionCount': instance.anonymousQuestionCount,
  'currentRank': instance.currentRank,
  'currentTitle': instance.currentTitle,
  'rankChangeDate': instance.rankChangeDate?.toIso8601String(),
  'titleChangeDate': instance.titleChangeDate?.toIso8601String(),
  'isRankEligible': instance.isRankEligible,
  'rankEvaluationCount': instance.rankEvaluationCount,
  'rankHistory': instance.rankHistory,
  'titleHistory': instance.titleHistory,
  'receiveRankUpdateNotifications': instance.receiveRankUpdateNotifications,
  'receiveTitleUpdateNotifications': instance.receiveTitleUpdateNotifications,
  'characterId': instance.characterId,
  'friends': instance.friends,
  'activeChats': instance.activeChats,
  'groupChats': instance.groupChats,
  'role': instance.role,
  'title': instance.title,
  'stats': instance.stats,
  'subscription': instance.subscription,
};
