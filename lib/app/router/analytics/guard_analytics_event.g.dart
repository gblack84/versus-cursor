// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guard_analytics_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuardAnalyticsEvent _$GuardAnalyticsEventFromJson(Map<String, dynamic> json) =>
    _GuardAnalyticsEvent(
      eventId: json['eventId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attemptedPath: json['attemptedPath'] as String,
      redirectPath: json['redirectPath'] as String?,
      result: $enumDecode(_$GuardResultEnumMap, json['result']),
      userId: json['userId'] as String?,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$GuardAnalyticsEventToJson(
  _GuardAnalyticsEvent instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'timestamp': instance.timestamp.toIso8601String(),
  'attemptedPath': instance.attemptedPath,
  'redirectPath': instance.redirectPath,
  'result': _$GuardResultEnumMap[instance.result]!,
  'userId': instance.userId,
  'reason': instance.reason,
};

const _$GuardResultEnumMap = {
  GuardResult.blocked: 'blocked',
  GuardResult.allowed: 'allowed',
};
