// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  parentPath: json['parentPath'] as String,
  messageId: json['messageId'] as String,
  senderId: json['senderId'] as String,
  content: json['content'] as String,
  attachmentUrl: json['attachmentUrl'] as String? ?? '',
  attachmentType: json['attachmentType'] as String? ?? '',
  timeStamp: json['timeStamp'] == null
      ? null
      : DateTime.parse(json['timeStamp'] as String),
  isRead: json['isRead'] as bool,
  messageType: json['messageType'] as String? ?? 'text',
  mediaType: json['mediaType'] as String? ?? 'text',
  imageUrl: json['imageUrl'] as String? ?? '',
  videoUrl: json['videoUrl'] as String? ?? '',
  thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
  mediaSize: (json['mediaSize'] as num?)?.toInt() ?? 0,
  mediaWidth: (json['mediaWidth'] as num?)?.toDouble(),
  mediaHeight: (json['mediaHeight'] as num?)?.toDouble(),
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  seenAt: json['seenAt'] == null
      ? null
      : DateTime.parse(json['seenAt'] as String),
  receiverId: json['receiverId'] as String? ?? '',
  votePostId: json['votePostId'] as String? ?? '',
  voteTitle: json['voteTitle'] as String? ?? '',
  voteDescription: json['voteDescription'] as String? ?? '',
  voteOptionAText: json['voteOptionAText'] as String? ?? '',
  voteOptionBText: json['voteOptionBText'] as String? ?? '',
  voteOptionAImage: json['voteOptionAImage'] as String? ?? '',
  voteOptionBImage: json['voteOptionBImage'] as String? ?? '',
  voteOptionAImages:
      (json['voteOptionAImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  voteOptionBImages:
      (json['voteOptionBImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  voteStatus: json['voteStatus'] as String? ?? 'pending',
  cardStatus: json['cardStatus'] as String? ?? '',
  voteEndTime: json['voteEndTime'] == null
      ? null
      : DateTime.parse(json['voteEndTime'] as String),
  voteResults: json['voteResults'] as Map<String, dynamic>? ?? const {},
  userVotes: json['userVotes'] as Map<String, dynamic>? ?? const {},
  voteAspectRatioA: (json['voteAspectRatioA'] as num?)?.toDouble(),
  voteAspectRatioB: (json['voteAspectRatioB'] as num?)?.toDouble(),
  voteResultsA: (json['voteResultsA'] as num?)?.toInt() ?? 0,
  voteResultsB: (json['voteResultsB'] as num?)?.toInt() ?? 0,
  votePercentA: (json['votePercentA'] as num?)?.toDouble() ?? 0.0,
  votePercentB: (json['votePercentB'] as num?)?.toDouble() ?? 0.0,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'parentPath': instance.parentPath,
  'messageId': instance.messageId,
  'senderId': instance.senderId,
  'content': instance.content,
  'attachmentUrl': instance.attachmentUrl,
  'attachmentType': instance.attachmentType,
  'timeStamp': instance.timeStamp?.toIso8601String(),
  'isRead': instance.isRead,
  'messageType': instance.messageType,
  'mediaType': instance.mediaType,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'mediaSize': instance.mediaSize,
  'mediaWidth': instance.mediaWidth,
  'mediaHeight': instance.mediaHeight,
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'seenAt': instance.seenAt?.toIso8601String(),
  'receiverId': instance.receiverId,
  'votePostId': instance.votePostId,
  'voteTitle': instance.voteTitle,
  'voteDescription': instance.voteDescription,
  'voteOptionAText': instance.voteOptionAText,
  'voteOptionBText': instance.voteOptionBText,
  'voteOptionAImage': instance.voteOptionAImage,
  'voteOptionBImage': instance.voteOptionBImage,
  'voteOptionAImages': instance.voteOptionAImages,
  'voteOptionBImages': instance.voteOptionBImages,
  'voteStatus': instance.voteStatus,
  'cardStatus': instance.cardStatus,
  'voteEndTime': instance.voteEndTime?.toIso8601String(),
  'voteResults': instance.voteResults,
  'userVotes': instance.userVotes,
  'voteAspectRatioA': instance.voteAspectRatioA,
  'voteAspectRatioB': instance.voteAspectRatioB,
  'voteResultsA': instance.voteResultsA,
  'voteResultsB': instance.voteResultsB,
  'votePercentA': instance.votePercentA,
  'votePercentB': instance.votePercentB,
  'metadata': instance.metadata,
};
