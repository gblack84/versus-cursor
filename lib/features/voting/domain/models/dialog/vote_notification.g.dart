// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteNotification _$VoteNotificationFromJson(Map<String, dynamic> json) =>
    _VoteNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      title: json['title'] as String,
      content: json['content'] as String,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      expiryTime: json['expiryTime'] == null
          ? null
          : DateTime.parse(json['expiryTime'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      postId: json['postId'] as String,
      postTitle: json['postTitle'] as String,
      postContent: json['postContent'] as String,
      postDescription: json['postDescription'] as String?,
      voteOptions: VoteOptions.fromJson(
        json['voteOptions'] as Map<String, dynamic>,
      ),
      voteStartTime: DateTime.parse(json['voteStartTime'] as String),
      voteEndTime: DateTime.parse(json['voteEndTime'] as String),
      targetAudience: json['targetAudience'] as String?,
      currentVotesA: (json['currentVotesA'] as num?)?.toInt(),
      currentVotesB: (json['currentVotesB'] as num?)?.toInt(),
      hasVoted: json['hasVoted'] as bool? ?? false,
      userVoteChoice: json['userVoteChoice'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      body: json['body'] as String?,
      notificationPriority: json['notificationPriority'] == null
          ? NotificationPriority.medium
          : NotificationPriority.fromJson(
              (json['notificationPriority'] as num).toInt(),
            ),
    );

Map<String, dynamic> _$VoteNotificationToJson(_VoteNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'title': instance.title,
      'content': instance.content,
      'readAt': instance.readAt?.toIso8601String(),
      'expiryTime': instance.expiryTime?.toIso8601String(),
      'metadata': instance.metadata,
      'postId': instance.postId,
      'postTitle': instance.postTitle,
      'postContent': instance.postContent,
      'postDescription': instance.postDescription,
      'voteOptions': instance.voteOptions,
      'voteStartTime': instance.voteStartTime.toIso8601String(),
      'voteEndTime': instance.voteEndTime.toIso8601String(),
      'targetAudience': instance.targetAudience,
      'currentVotesA': instance.currentVotesA,
      'currentVotesB': instance.currentVotesB,
      'hasVoted': instance.hasVoted,
      'userVoteChoice': instance.userVoteChoice,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'body': instance.body,
      'notificationPriority': _notificationPriorityToJson(
        instance.notificationPriority,
      ),
    };
