// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialNotification _$SocialNotificationFromJson(Map<String, dynamic> json) =>
    SocialNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isRead: json['isRead'] as bool,
      expiryTime: json['expiryTime'] == null
          ? null
          : DateTime.parse(json['expiryTime'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      actionType: $enumDecode(_$SocialActionTypeEnumMap, json['actionType']),
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserProfileUrl: json['fromUserProfileUrl'] as String?,
      relatedPostId: json['relatedPostId'] as String?,
      relatedCommentId: json['relatedCommentId'] as String?,
      relatedContent: json['relatedContent'] as String?,
      interactionCount: (json['interactionCount'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SocialNotificationToJson(SocialNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'isRead': instance.isRead,
      'expiryTime': instance.expiryTime?.toIso8601String(),
      'metadata': instance.metadata,
      'actionType': _$SocialActionTypeEnumMap[instance.actionType]!,
      'fromUserId': instance.fromUserId,
      'fromUserName': instance.fromUserName,
      'fromUserProfileUrl': instance.fromUserProfileUrl,
      'relatedPostId': instance.relatedPostId,
      'relatedCommentId': instance.relatedCommentId,
      'relatedContent': instance.relatedContent,
      'interactionCount': instance.interactionCount,
      'runtimeType': instance.$type,
    };

const _$SocialActionTypeEnumMap = {
  SocialActionType.like: 'like',
  SocialActionType.comment: 'comment',
  SocialActionType.friendRequest: 'friendRequest',
  SocialActionType.friendAccepted: 'friendAccepted',
  SocialActionType.follow: 'follow',
  SocialActionType.mention: 'mention',
  SocialActionType.share: 'share',
};

SystemNotification _$SystemNotificationFromJson(Map<String, dynamic> json) =>
    SystemNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isRead: json['isRead'] as bool,
      expiryTime: json['expiryTime'] == null
          ? null
          : DateTime.parse(json['expiryTime'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      alertType: $enumDecode(_$SystemAlertTypeEnumMap, json['alertType']),
      actionUrl: json['actionUrl'] as String?,
      actionLabel: json['actionLabel'] as String?,
      actionButtons: (json['actionButtons'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      iconUrl: json['iconUrl'] as String?,
      isDismissible: json['isDismissible'] as bool? ?? true,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SystemNotificationToJson(SystemNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'isRead': instance.isRead,
      'expiryTime': instance.expiryTime?.toIso8601String(),
      'metadata': instance.metadata,
      'alertType': _$SystemAlertTypeEnumMap[instance.alertType]!,
      'actionUrl': instance.actionUrl,
      'actionLabel': instance.actionLabel,
      'actionButtons': instance.actionButtons,
      'iconUrl': instance.iconUrl,
      'isDismissible': instance.isDismissible,
      'runtimeType': instance.$type,
    };

const _$SystemAlertTypeEnumMap = {
  SystemAlertType.critical: 'critical',
  SystemAlertType.security: 'security',
  SystemAlertType.maintenance: 'maintenance',
  SystemAlertType.update: 'update',
  SystemAlertType.info: 'info',
};

VotingNotification _$VotingNotificationFromJson(Map<String, dynamic> json) =>
    VotingNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isRead: json['isRead'] as bool,
      expiryTime: json['expiryTime'] == null
          ? null
          : DateTime.parse(json['expiryTime'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      postId: json['postId'] as String,
      postTitle: json['postTitle'] as String,
      imageUrlsA: (json['imageUrlsA'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrlsB: (json['imageUrlsB'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      voteDeadline: json['voteDeadline'] == null
          ? null
          : DateTime.parse(json['voteDeadline'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$VotingNotificationToJson(VotingNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'isRead': instance.isRead,
      'expiryTime': instance.expiryTime?.toIso8601String(),
      'metadata': instance.metadata,
      'postId': instance.postId,
      'postTitle': instance.postTitle,
      'imageUrlsA': instance.imageUrlsA,
      'imageUrlsB': instance.imageUrlsB,
      'voteDeadline': instance.voteDeadline?.toIso8601String(),
      'runtimeType': instance.$type,
    };
