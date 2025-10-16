// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Chat _$ChatFromJson(Map<String, dynamic> json) => _Chat(
  id: json['id'] as String,
  chatId: json['chatId'] as String,
  chatType: json['chatType'] as String,
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  chatName: json['chatName'] as String,
  lastMessageContent: json['lastMessageContent'] as String,
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  isRead: json['isRead'] as bool,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastReadTimestamps: (json['lastReadTimestamps'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, DateTime.parse(e as String)),
  ),
  email: json['email'] as String? ?? '',
  displayName: json['displayName'] as String? ?? '',
  photoUrl: json['photoUrl'] as String? ?? '',
  uid: json['uid'] as String? ?? '',
  createdTime: json['createdTime'] == null
      ? null
      : DateTime.parse(json['createdTime'] as String),
  phoneNumber: json['phoneNumber'] as String? ?? '',
);

Map<String, dynamic> _$ChatToJson(_Chat instance) => <String, dynamic>{
  'id': instance.id,
  'chatId': instance.chatId,
  'chatType': instance.chatType,
  'participantIds': instance.participantIds,
  'chatName': instance.chatName,
  'lastMessageContent': instance.lastMessageContent,
  'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
  'isRead': instance.isRead,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastReadTimestamps': instance.lastReadTimestamps.map(
    (k, e) => MapEntry(k, e.toIso8601String()),
  ),
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'uid': instance.uid,
  'createdTime': instance.createdTime?.toIso8601String(),
  'phoneNumber': instance.phoneNumber,
};
