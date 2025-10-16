// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voting_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoteReceived _$VoteReceivedFromJson(Map<String, dynamic> json) => VoteReceived(
  postId: json['postId'] as String,
  userId: json['userId'] as String,
  option: $enumDecode(_$VoteOptionEnumMap, json['option']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  newVotesA: (json['newVotesA'] as num).toInt(),
  newVotesB: (json['newVotesB'] as num).toInt(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$VoteReceivedToJson(VoteReceived instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'userId': instance.userId,
      'option': _$VoteOptionEnumMap[instance.option]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'newVotesA': instance.newVotesA,
      'newVotesB': instance.newVotesB,
      'runtimeType': instance.$type,
    };

const _$VoteOptionEnumMap = {VoteOption.A: 'A', VoteOption.B: 'B'};

StatusChanged _$StatusChangedFromJson(Map<String, dynamic> json) =>
    StatusChanged(
      postId: json['postId'] as String,
      newStatus: $enumDecode(_$VoteStatusEnumMap, json['newStatus']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$StatusChangedToJson(StatusChanged instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'newStatus': _$VoteStatusEnumMap[instance.newStatus]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'reason': instance.reason,
      'runtimeType': instance.$type,
    };

const _$VoteStatusEnumMap = {
  VoteStatus.pending: 'pending',
  VoteStatus.active: 'active',
  VoteStatus.completed: 'completed',
  VoteStatus.cancelled: 'cancelled',
  VoteStatus.timeout: 'timeout',
};

DisplayUpdated _$DisplayUpdatedFromJson(Map<String, dynamic> json) =>
    DisplayUpdated(
      postId: json['postId'] as String,
      displayVotesA: (json['displayVotesA'] as num).toInt(),
      displayVotesB: (json['displayVotesB'] as num).toInt(),
      displayPercentA: (json['displayPercentA'] as num).toInt(),
      displayPercentB: (json['displayPercentB'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$DisplayUpdatedToJson(DisplayUpdated instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'displayVotesA': instance.displayVotesA,
      'displayVotesB': instance.displayVotesB,
      'displayPercentA': instance.displayPercentA,
      'displayPercentB': instance.displayPercentB,
      'timestamp': instance.timestamp.toIso8601String(),
      'runtimeType': instance.$type,
    };

ExpansionTriggered _$ExpansionTriggeredFromJson(Map<String, dynamic> json) =>
    ExpansionTriggered(
      postId: json['postId'] as String,
      pointsUsed: (json['pointsUsed'] as num).toInt(),
      additionalReach: (json['additionalReach'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ExpansionTriggeredToJson(ExpansionTriggered instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'pointsUsed': instance.pointsUsed,
      'additionalReach': instance.additionalReach,
      'timestamp': instance.timestamp.toIso8601String(),
      'runtimeType': instance.$type,
    };

NotificationSent _$NotificationSentFromJson(Map<String, dynamic> json) =>
    NotificationSent(
      postId: json['postId'] as String,
      recipientIds: (json['recipientIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$NotificationSentToJson(NotificationSent instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'recipientIds': instance.recipientIds,
      'timestamp': instance.timestamp.toIso8601String(),
      'runtimeType': instance.$type,
    };
