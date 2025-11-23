// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guard_analytics_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuardAnalyticsEvent {

/// Unique event identifier (UUID v4)
 String get eventId;/// Event timestamp (server time)
 DateTime get timestamp;/// Path user attempted to access
 String get attemptedPath;/// Path user was redirected to (null if allowed)
 String? get redirectPath;/// Guard execution result
 GuardResult get result;/// User ID if authenticated (null if not logged in)
 String? get userId;/// Reason for block/allow (e.g., "auth_required", "public_route")
 String get reason;
/// Create a copy of GuardAnalyticsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuardAnalyticsEventCopyWith<GuardAnalyticsEvent> get copyWith => _$GuardAnalyticsEventCopyWithImpl<GuardAnalyticsEvent>(this as GuardAnalyticsEvent, _$identity);

  /// Serializes this GuardAnalyticsEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuardAnalyticsEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.attemptedPath, attemptedPath) || other.attemptedPath == attemptedPath)&&(identical(other.redirectPath, redirectPath) || other.redirectPath == redirectPath)&&(identical(other.result, result) || other.result == result)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,timestamp,attemptedPath,redirectPath,result,userId,reason);

@override
String toString() {
  return 'GuardAnalyticsEvent(eventId: $eventId, timestamp: $timestamp, attemptedPath: $attemptedPath, redirectPath: $redirectPath, result: $result, userId: $userId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $GuardAnalyticsEventCopyWith<$Res>  {
  factory $GuardAnalyticsEventCopyWith(GuardAnalyticsEvent value, $Res Function(GuardAnalyticsEvent) _then) = _$GuardAnalyticsEventCopyWithImpl;
@useResult
$Res call({
 String eventId, DateTime timestamp, String attemptedPath, String? redirectPath, GuardResult result, String? userId, String reason
});




}
/// @nodoc
class _$GuardAnalyticsEventCopyWithImpl<$Res>
    implements $GuardAnalyticsEventCopyWith<$Res> {
  _$GuardAnalyticsEventCopyWithImpl(this._self, this._then);

  final GuardAnalyticsEvent _self;
  final $Res Function(GuardAnalyticsEvent) _then;

/// Create a copy of GuardAnalyticsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? timestamp = null,Object? attemptedPath = null,Object? redirectPath = freezed,Object? result = null,Object? userId = freezed,Object? reason = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,attemptedPath: null == attemptedPath ? _self.attemptedPath : attemptedPath // ignore: cast_nullable_to_non_nullable
as String,redirectPath: freezed == redirectPath ? _self.redirectPath : redirectPath // ignore: cast_nullable_to_non_nullable
as String?,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GuardResult,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GuardAnalyticsEvent].
extension GuardAnalyticsEventPatterns on GuardAnalyticsEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuardAnalyticsEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuardAnalyticsEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuardAnalyticsEvent value)  $default,){
final _that = this;
switch (_that) {
case _GuardAnalyticsEvent():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuardAnalyticsEvent value)?  $default,){
final _that = this;
switch (_that) {
case _GuardAnalyticsEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  DateTime timestamp,  String attemptedPath,  String? redirectPath,  GuardResult result,  String? userId,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuardAnalyticsEvent() when $default != null:
return $default(_that.eventId,_that.timestamp,_that.attemptedPath,_that.redirectPath,_that.result,_that.userId,_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  DateTime timestamp,  String attemptedPath,  String? redirectPath,  GuardResult result,  String? userId,  String reason)  $default,) {final _that = this;
switch (_that) {
case _GuardAnalyticsEvent():
return $default(_that.eventId,_that.timestamp,_that.attemptedPath,_that.redirectPath,_that.result,_that.userId,_that.reason);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  DateTime timestamp,  String attemptedPath,  String? redirectPath,  GuardResult result,  String? userId,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _GuardAnalyticsEvent() when $default != null:
return $default(_that.eventId,_that.timestamp,_that.attemptedPath,_that.redirectPath,_that.result,_that.userId,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuardAnalyticsEvent extends GuardAnalyticsEvent {
  const _GuardAnalyticsEvent({required this.eventId, required this.timestamp, required this.attemptedPath, this.redirectPath, required this.result, this.userId, required this.reason}): super._();
  factory _GuardAnalyticsEvent.fromJson(Map<String, dynamic> json) => _$GuardAnalyticsEventFromJson(json);

/// Unique event identifier (UUID v4)
@override final  String eventId;
/// Event timestamp (server time)
@override final  DateTime timestamp;
/// Path user attempted to access
@override final  String attemptedPath;
/// Path user was redirected to (null if allowed)
@override final  String? redirectPath;
/// Guard execution result
@override final  GuardResult result;
/// User ID if authenticated (null if not logged in)
@override final  String? userId;
/// Reason for block/allow (e.g., "auth_required", "public_route")
@override final  String reason;

/// Create a copy of GuardAnalyticsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuardAnalyticsEventCopyWith<_GuardAnalyticsEvent> get copyWith => __$GuardAnalyticsEventCopyWithImpl<_GuardAnalyticsEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuardAnalyticsEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuardAnalyticsEvent&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.attemptedPath, attemptedPath) || other.attemptedPath == attemptedPath)&&(identical(other.redirectPath, redirectPath) || other.redirectPath == redirectPath)&&(identical(other.result, result) || other.result == result)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,timestamp,attemptedPath,redirectPath,result,userId,reason);

@override
String toString() {
  return 'GuardAnalyticsEvent(eventId: $eventId, timestamp: $timestamp, attemptedPath: $attemptedPath, redirectPath: $redirectPath, result: $result, userId: $userId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$GuardAnalyticsEventCopyWith<$Res> implements $GuardAnalyticsEventCopyWith<$Res> {
  factory _$GuardAnalyticsEventCopyWith(_GuardAnalyticsEvent value, $Res Function(_GuardAnalyticsEvent) _then) = __$GuardAnalyticsEventCopyWithImpl;
@override @useResult
$Res call({
 String eventId, DateTime timestamp, String attemptedPath, String? redirectPath, GuardResult result, String? userId, String reason
});




}
/// @nodoc
class __$GuardAnalyticsEventCopyWithImpl<$Res>
    implements _$GuardAnalyticsEventCopyWith<$Res> {
  __$GuardAnalyticsEventCopyWithImpl(this._self, this._then);

  final _GuardAnalyticsEvent _self;
  final $Res Function(_GuardAnalyticsEvent) _then;

/// Create a copy of GuardAnalyticsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? timestamp = null,Object? attemptedPath = null,Object? redirectPath = freezed,Object? result = null,Object? userId = freezed,Object? reason = null,}) {
  return _then(_GuardAnalyticsEvent(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,attemptedPath: null == attemptedPath ? _self.attemptedPath : attemptedPath // ignore: cast_nullable_to_non_nullable
as String,redirectPath: freezed == redirectPath ? _self.redirectPath : redirectPath // ignore: cast_nullable_to_non_nullable
as String?,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GuardResult,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GuardAnalyticsStats {

 int get totalChecks; int get blockedCount; int get allowedCount;
/// Create a copy of GuardAnalyticsStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuardAnalyticsStatsCopyWith<GuardAnalyticsStats> get copyWith => _$GuardAnalyticsStatsCopyWithImpl<GuardAnalyticsStats>(this as GuardAnalyticsStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuardAnalyticsStats&&(identical(other.totalChecks, totalChecks) || other.totalChecks == totalChecks)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.allowedCount, allowedCount) || other.allowedCount == allowedCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalChecks,blockedCount,allowedCount);

@override
String toString() {
  return 'GuardAnalyticsStats(totalChecks: $totalChecks, blockedCount: $blockedCount, allowedCount: $allowedCount)';
}


}

/// @nodoc
abstract mixin class $GuardAnalyticsStatsCopyWith<$Res>  {
  factory $GuardAnalyticsStatsCopyWith(GuardAnalyticsStats value, $Res Function(GuardAnalyticsStats) _then) = _$GuardAnalyticsStatsCopyWithImpl;
@useResult
$Res call({
 int totalChecks, int blockedCount, int allowedCount
});




}
/// @nodoc
class _$GuardAnalyticsStatsCopyWithImpl<$Res>
    implements $GuardAnalyticsStatsCopyWith<$Res> {
  _$GuardAnalyticsStatsCopyWithImpl(this._self, this._then);

  final GuardAnalyticsStats _self;
  final $Res Function(GuardAnalyticsStats) _then;

/// Create a copy of GuardAnalyticsStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalChecks = null,Object? blockedCount = null,Object? allowedCount = null,}) {
  return _then(_self.copyWith(
totalChecks: null == totalChecks ? _self.totalChecks : totalChecks // ignore: cast_nullable_to_non_nullable
as int,blockedCount: null == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int,allowedCount: null == allowedCount ? _self.allowedCount : allowedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuardAnalyticsStats].
extension GuardAnalyticsStatsPatterns on GuardAnalyticsStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuardAnalyticsStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuardAnalyticsStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuardAnalyticsStats value)  $default,){
final _that = this;
switch (_that) {
case _GuardAnalyticsStats():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuardAnalyticsStats value)?  $default,){
final _that = this;
switch (_that) {
case _GuardAnalyticsStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalChecks,  int blockedCount,  int allowedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuardAnalyticsStats() when $default != null:
return $default(_that.totalChecks,_that.blockedCount,_that.allowedCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalChecks,  int blockedCount,  int allowedCount)  $default,) {final _that = this;
switch (_that) {
case _GuardAnalyticsStats():
return $default(_that.totalChecks,_that.blockedCount,_that.allowedCount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalChecks,  int blockedCount,  int allowedCount)?  $default,) {final _that = this;
switch (_that) {
case _GuardAnalyticsStats() when $default != null:
return $default(_that.totalChecks,_that.blockedCount,_that.allowedCount);case _:
  return null;

}
}

}

/// @nodoc


class _GuardAnalyticsStats extends GuardAnalyticsStats {
  const _GuardAnalyticsStats({this.totalChecks = 0, this.blockedCount = 0, this.allowedCount = 0}): super._();
  

@override@JsonKey() final  int totalChecks;
@override@JsonKey() final  int blockedCount;
@override@JsonKey() final  int allowedCount;

/// Create a copy of GuardAnalyticsStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuardAnalyticsStatsCopyWith<_GuardAnalyticsStats> get copyWith => __$GuardAnalyticsStatsCopyWithImpl<_GuardAnalyticsStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuardAnalyticsStats&&(identical(other.totalChecks, totalChecks) || other.totalChecks == totalChecks)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.allowedCount, allowedCount) || other.allowedCount == allowedCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalChecks,blockedCount,allowedCount);

@override
String toString() {
  return 'GuardAnalyticsStats(totalChecks: $totalChecks, blockedCount: $blockedCount, allowedCount: $allowedCount)';
}


}

/// @nodoc
abstract mixin class _$GuardAnalyticsStatsCopyWith<$Res> implements $GuardAnalyticsStatsCopyWith<$Res> {
  factory _$GuardAnalyticsStatsCopyWith(_GuardAnalyticsStats value, $Res Function(_GuardAnalyticsStats) _then) = __$GuardAnalyticsStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalChecks, int blockedCount, int allowedCount
});




}
/// @nodoc
class __$GuardAnalyticsStatsCopyWithImpl<$Res>
    implements _$GuardAnalyticsStatsCopyWith<$Res> {
  __$GuardAnalyticsStatsCopyWithImpl(this._self, this._then);

  final _GuardAnalyticsStats _self;
  final $Res Function(_GuardAnalyticsStats) _then;

/// Create a copy of GuardAnalyticsStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalChecks = null,Object? blockedCount = null,Object? allowedCount = null,}) {
  return _then(_GuardAnalyticsStats(
totalChecks: null == totalChecks ? _self.totalChecks : totalChecks // ignore: cast_nullable_to_non_nullable
as int,blockedCount: null == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int,allowedCount: null == allowedCount ? _self.allowedCount : allowedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
