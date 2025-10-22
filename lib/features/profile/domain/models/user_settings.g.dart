// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(
  Map<String, dynamic> json,
) => _UserSettings(
  userId: json['userId'] as String,
  isPremiumUser: json['isPremiumUser'] as bool? ?? false,
  receiveRankUpdateNotifications:
      json['receiveRankUpdateNotifications'] as bool? ?? true,
  receiveTitleUpdateNotifications:
      json['receiveTitleUpdateNotifications'] as bool? ?? true,
  receiveVoteNotifications: json['receiveVoteNotifications'] as bool? ?? true,
  receiveCommentNotifications:
      json['receiveCommentNotifications'] as bool? ?? true,
  receiveFriendNotifications:
      json['receiveFriendNotifications'] as bool? ?? true,
  subscription: json['subscription'] as Map<String, dynamic>? ?? const {},
  stats: json['stats'] as Map<String, dynamic>? ?? const {},
  privacySettings: json['privacySettings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$UserSettingsToJson(
  _UserSettings instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'isPremiumUser': instance.isPremiumUser,
  'receiveRankUpdateNotifications': instance.receiveRankUpdateNotifications,
  'receiveTitleUpdateNotifications': instance.receiveTitleUpdateNotifications,
  'receiveVoteNotifications': instance.receiveVoteNotifications,
  'receiveCommentNotifications': instance.receiveCommentNotifications,
  'receiveFriendNotifications': instance.receiveFriendNotifications,
  'subscription': instance.subscription,
  'stats': instance.stats,
  'privacySettings': instance.privacySettings,
};
