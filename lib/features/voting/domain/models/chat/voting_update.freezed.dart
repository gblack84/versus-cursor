// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voting_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
VotingUpdate _$VotingUpdateFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'voteReceived':
          return VoteReceived.fromJson(
            json
          );
                case 'statusChanged':
          return StatusChanged.fromJson(
            json
          );
                case 'displayUpdated':
          return DisplayUpdated.fromJson(
            json
          );
                case 'expansionTriggered':
          return ExpansionTriggered.fromJson(
            json
          );
                case 'notificationSent':
          return NotificationSent.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'VotingUpdate',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$VotingUpdate {

 String get postId; DateTime get timestamp;
/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VotingUpdateCopyWith<VotingUpdate> get copyWith => _$VotingUpdateCopyWithImpl<VotingUpdate>(this as VotingUpdate, _$identity);

  /// Serializes this VotingUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VotingUpdate&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,timestamp);

@override
String toString() {
  return 'VotingUpdate(postId: $postId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $VotingUpdateCopyWith<$Res>  {
  factory $VotingUpdateCopyWith(VotingUpdate value, $Res Function(VotingUpdate) _then) = _$VotingUpdateCopyWithImpl;
@useResult
$Res call({
 String postId, DateTime timestamp
});




}
/// @nodoc
class _$VotingUpdateCopyWithImpl<$Res>
    implements $VotingUpdateCopyWith<$Res> {
  _$VotingUpdateCopyWithImpl(this._self, this._then);

  final VotingUpdate _self;
  final $Res Function(VotingUpdate) _then;

/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VotingUpdate].
extension VotingUpdatePatterns on VotingUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VoteReceived value)?  voteReceived,TResult Function( StatusChanged value)?  statusChanged,TResult Function( DisplayUpdated value)?  displayUpdated,TResult Function( ExpansionTriggered value)?  expansionTriggered,TResult Function( NotificationSent value)?  notificationSent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VoteReceived() when voteReceived != null:
return voteReceived(_that);case StatusChanged() when statusChanged != null:
return statusChanged(_that);case DisplayUpdated() when displayUpdated != null:
return displayUpdated(_that);case ExpansionTriggered() when expansionTriggered != null:
return expansionTriggered(_that);case NotificationSent() when notificationSent != null:
return notificationSent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VoteReceived value)  voteReceived,required TResult Function( StatusChanged value)  statusChanged,required TResult Function( DisplayUpdated value)  displayUpdated,required TResult Function( ExpansionTriggered value)  expansionTriggered,required TResult Function( NotificationSent value)  notificationSent,}){
final _that = this;
switch (_that) {
case VoteReceived():
return voteReceived(_that);case StatusChanged():
return statusChanged(_that);case DisplayUpdated():
return displayUpdated(_that);case ExpansionTriggered():
return expansionTriggered(_that);case NotificationSent():
return notificationSent(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VoteReceived value)?  voteReceived,TResult? Function( StatusChanged value)?  statusChanged,TResult? Function( DisplayUpdated value)?  displayUpdated,TResult? Function( ExpansionTriggered value)?  expansionTriggered,TResult? Function( NotificationSent value)?  notificationSent,}){
final _that = this;
switch (_that) {
case VoteReceived() when voteReceived != null:
return voteReceived(_that);case StatusChanged() when statusChanged != null:
return statusChanged(_that);case DisplayUpdated() when displayUpdated != null:
return displayUpdated(_that);case ExpansionTriggered() when expansionTriggered != null:
return expansionTriggered(_that);case NotificationSent() when notificationSent != null:
return notificationSent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String postId,  String userId,  VoteOption option,  DateTime timestamp,  int newVotesA,  int newVotesB)?  voteReceived,TResult Function( String postId,  VoteStatus newStatus,  DateTime timestamp,  String? reason)?  statusChanged,TResult Function( String postId,  int displayVotesA,  int displayVotesB,  int displayPercentA,  int displayPercentB,  DateTime timestamp)?  displayUpdated,TResult Function( String postId,  int pointsUsed,  int additionalReach,  DateTime timestamp)?  expansionTriggered,TResult Function( String postId,  List<String> recipientIds,  DateTime timestamp)?  notificationSent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VoteReceived() when voteReceived != null:
return voteReceived(_that.postId,_that.userId,_that.option,_that.timestamp,_that.newVotesA,_that.newVotesB);case StatusChanged() when statusChanged != null:
return statusChanged(_that.postId,_that.newStatus,_that.timestamp,_that.reason);case DisplayUpdated() when displayUpdated != null:
return displayUpdated(_that.postId,_that.displayVotesA,_that.displayVotesB,_that.displayPercentA,_that.displayPercentB,_that.timestamp);case ExpansionTriggered() when expansionTriggered != null:
return expansionTriggered(_that.postId,_that.pointsUsed,_that.additionalReach,_that.timestamp);case NotificationSent() when notificationSent != null:
return notificationSent(_that.postId,_that.recipientIds,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String postId,  String userId,  VoteOption option,  DateTime timestamp,  int newVotesA,  int newVotesB)  voteReceived,required TResult Function( String postId,  VoteStatus newStatus,  DateTime timestamp,  String? reason)  statusChanged,required TResult Function( String postId,  int displayVotesA,  int displayVotesB,  int displayPercentA,  int displayPercentB,  DateTime timestamp)  displayUpdated,required TResult Function( String postId,  int pointsUsed,  int additionalReach,  DateTime timestamp)  expansionTriggered,required TResult Function( String postId,  List<String> recipientIds,  DateTime timestamp)  notificationSent,}) {final _that = this;
switch (_that) {
case VoteReceived():
return voteReceived(_that.postId,_that.userId,_that.option,_that.timestamp,_that.newVotesA,_that.newVotesB);case StatusChanged():
return statusChanged(_that.postId,_that.newStatus,_that.timestamp,_that.reason);case DisplayUpdated():
return displayUpdated(_that.postId,_that.displayVotesA,_that.displayVotesB,_that.displayPercentA,_that.displayPercentB,_that.timestamp);case ExpansionTriggered():
return expansionTriggered(_that.postId,_that.pointsUsed,_that.additionalReach,_that.timestamp);case NotificationSent():
return notificationSent(_that.postId,_that.recipientIds,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String postId,  String userId,  VoteOption option,  DateTime timestamp,  int newVotesA,  int newVotesB)?  voteReceived,TResult? Function( String postId,  VoteStatus newStatus,  DateTime timestamp,  String? reason)?  statusChanged,TResult? Function( String postId,  int displayVotesA,  int displayVotesB,  int displayPercentA,  int displayPercentB,  DateTime timestamp)?  displayUpdated,TResult? Function( String postId,  int pointsUsed,  int additionalReach,  DateTime timestamp)?  expansionTriggered,TResult? Function( String postId,  List<String> recipientIds,  DateTime timestamp)?  notificationSent,}) {final _that = this;
switch (_that) {
case VoteReceived() when voteReceived != null:
return voteReceived(_that.postId,_that.userId,_that.option,_that.timestamp,_that.newVotesA,_that.newVotesB);case StatusChanged() when statusChanged != null:
return statusChanged(_that.postId,_that.newStatus,_that.timestamp,_that.reason);case DisplayUpdated() when displayUpdated != null:
return displayUpdated(_that.postId,_that.displayVotesA,_that.displayVotesB,_that.displayPercentA,_that.displayPercentB,_that.timestamp);case ExpansionTriggered() when expansionTriggered != null:
return expansionTriggered(_that.postId,_that.pointsUsed,_that.additionalReach,_that.timestamp);case NotificationSent() when notificationSent != null:
return notificationSent(_that.postId,_that.recipientIds,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class VoteReceived extends VotingUpdate {
  const VoteReceived({required this.postId, required this.userId, required this.option, required this.timestamp, required this.newVotesA, required this.newVotesB, final  String? $type}): $type = $type ?? 'voteReceived',super._();
  factory VoteReceived.fromJson(Map<String, dynamic> json) => _$VoteReceivedFromJson(json);

@override final  String postId;
 final  String userId;
 final  VoteOption option;
@override final  DateTime timestamp;
 final  int newVotesA;
 final  int newVotesB;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteReceivedCopyWith<VoteReceived> get copyWith => _$VoteReceivedCopyWithImpl<VoteReceived>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteReceivedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteReceived&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.option, option) || other.option == option)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.newVotesA, newVotesA) || other.newVotesA == newVotesA)&&(identical(other.newVotesB, newVotesB) || other.newVotesB == newVotesB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,userId,option,timestamp,newVotesA,newVotesB);

@override
String toString() {
  return 'VotingUpdate.voteReceived(postId: $postId, userId: $userId, option: $option, timestamp: $timestamp, newVotesA: $newVotesA, newVotesB: $newVotesB)';
}


}

/// @nodoc
abstract mixin class $VoteReceivedCopyWith<$Res> implements $VotingUpdateCopyWith<$Res> {
  factory $VoteReceivedCopyWith(VoteReceived value, $Res Function(VoteReceived) _then) = _$VoteReceivedCopyWithImpl;
@override @useResult
$Res call({
 String postId, String userId, VoteOption option, DateTime timestamp, int newVotesA, int newVotesB
});




}
/// @nodoc
class _$VoteReceivedCopyWithImpl<$Res>
    implements $VoteReceivedCopyWith<$Res> {
  _$VoteReceivedCopyWithImpl(this._self, this._then);

  final VoteReceived _self;
  final $Res Function(VoteReceived) _then;

/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? userId = null,Object? option = null,Object? timestamp = null,Object? newVotesA = null,Object? newVotesB = null,}) {
  return _then(VoteReceived(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,option: null == option ? _self.option : option // ignore: cast_nullable_to_non_nullable
as VoteOption,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,newVotesA: null == newVotesA ? _self.newVotesA : newVotesA // ignore: cast_nullable_to_non_nullable
as int,newVotesB: null == newVotesB ? _self.newVotesB : newVotesB // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class StatusChanged extends VotingUpdate {
  const StatusChanged({required this.postId, required this.newStatus, required this.timestamp, this.reason, final  String? $type}): $type = $type ?? 'statusChanged',super._();
  factory StatusChanged.fromJson(Map<String, dynamic> json) => _$StatusChangedFromJson(json);

@override final  String postId;
 final  VoteStatus newStatus;
@override final  DateTime timestamp;
 final  String? reason;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusChangedCopyWith<StatusChanged> get copyWith => _$StatusChangedCopyWithImpl<StatusChanged>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusChangedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusChanged&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,newStatus,timestamp,reason);

@override
String toString() {
  return 'VotingUpdate.statusChanged(postId: $postId, newStatus: $newStatus, timestamp: $timestamp, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $StatusChangedCopyWith<$Res> implements $VotingUpdateCopyWith<$Res> {
  factory $StatusChangedCopyWith(StatusChanged value, $Res Function(StatusChanged) _then) = _$StatusChangedCopyWithImpl;
@override @useResult
$Res call({
 String postId, VoteStatus newStatus, DateTime timestamp, String? reason
});




}
/// @nodoc
class _$StatusChangedCopyWithImpl<$Res>
    implements $StatusChangedCopyWith<$Res> {
  _$StatusChangedCopyWithImpl(this._self, this._then);

  final StatusChanged _self;
  final $Res Function(StatusChanged) _then;

/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? newStatus = null,Object? timestamp = null,Object? reason = freezed,}) {
  return _then(StatusChanged(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as VoteStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DisplayUpdated extends VotingUpdate {
  const DisplayUpdated({required this.postId, required this.displayVotesA, required this.displayVotesB, required this.displayPercentA, required this.displayPercentB, required this.timestamp, final  String? $type}): $type = $type ?? 'displayUpdated',super._();
  factory DisplayUpdated.fromJson(Map<String, dynamic> json) => _$DisplayUpdatedFromJson(json);

@override final  String postId;
 final  int displayVotesA;
 final  int displayVotesB;
 final  int displayPercentA;
 final  int displayPercentB;
@override final  DateTime timestamp;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayUpdatedCopyWith<DisplayUpdated> get copyWith => _$DisplayUpdatedCopyWithImpl<DisplayUpdated>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayUpdatedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayUpdated&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.displayVotesA, displayVotesA) || other.displayVotesA == displayVotesA)&&(identical(other.displayVotesB, displayVotesB) || other.displayVotesB == displayVotesB)&&(identical(other.displayPercentA, displayPercentA) || other.displayPercentA == displayPercentA)&&(identical(other.displayPercentB, displayPercentB) || other.displayPercentB == displayPercentB)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,displayVotesA,displayVotesB,displayPercentA,displayPercentB,timestamp);

@override
String toString() {
  return 'VotingUpdate.displayUpdated(postId: $postId, displayVotesA: $displayVotesA, displayVotesB: $displayVotesB, displayPercentA: $displayPercentA, displayPercentB: $displayPercentB, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $DisplayUpdatedCopyWith<$Res> implements $VotingUpdateCopyWith<$Res> {
  factory $DisplayUpdatedCopyWith(DisplayUpdated value, $Res Function(DisplayUpdated) _then) = _$DisplayUpdatedCopyWithImpl;
@override @useResult
$Res call({
 String postId, int displayVotesA, int displayVotesB, int displayPercentA, int displayPercentB, DateTime timestamp
});




}
/// @nodoc
class _$DisplayUpdatedCopyWithImpl<$Res>
    implements $DisplayUpdatedCopyWith<$Res> {
  _$DisplayUpdatedCopyWithImpl(this._self, this._then);

  final DisplayUpdated _self;
  final $Res Function(DisplayUpdated) _then;

/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? displayVotesA = null,Object? displayVotesB = null,Object? displayPercentA = null,Object? displayPercentB = null,Object? timestamp = null,}) {
  return _then(DisplayUpdated(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,displayVotesA: null == displayVotesA ? _self.displayVotesA : displayVotesA // ignore: cast_nullable_to_non_nullable
as int,displayVotesB: null == displayVotesB ? _self.displayVotesB : displayVotesB // ignore: cast_nullable_to_non_nullable
as int,displayPercentA: null == displayPercentA ? _self.displayPercentA : displayPercentA // ignore: cast_nullable_to_non_nullable
as int,displayPercentB: null == displayPercentB ? _self.displayPercentB : displayPercentB // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ExpansionTriggered extends VotingUpdate {
  const ExpansionTriggered({required this.postId, required this.pointsUsed, required this.additionalReach, required this.timestamp, final  String? $type}): $type = $type ?? 'expansionTriggered',super._();
  factory ExpansionTriggered.fromJson(Map<String, dynamic> json) => _$ExpansionTriggeredFromJson(json);

@override final  String postId;
 final  int pointsUsed;
 final  int additionalReach;
@override final  DateTime timestamp;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpansionTriggeredCopyWith<ExpansionTriggered> get copyWith => _$ExpansionTriggeredCopyWithImpl<ExpansionTriggered>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpansionTriggeredToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpansionTriggered&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.pointsUsed, pointsUsed) || other.pointsUsed == pointsUsed)&&(identical(other.additionalReach, additionalReach) || other.additionalReach == additionalReach)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,pointsUsed,additionalReach,timestamp);

@override
String toString() {
  return 'VotingUpdate.expansionTriggered(postId: $postId, pointsUsed: $pointsUsed, additionalReach: $additionalReach, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ExpansionTriggeredCopyWith<$Res> implements $VotingUpdateCopyWith<$Res> {
  factory $ExpansionTriggeredCopyWith(ExpansionTriggered value, $Res Function(ExpansionTriggered) _then) = _$ExpansionTriggeredCopyWithImpl;
@override @useResult
$Res call({
 String postId, int pointsUsed, int additionalReach, DateTime timestamp
});




}
/// @nodoc
class _$ExpansionTriggeredCopyWithImpl<$Res>
    implements $ExpansionTriggeredCopyWith<$Res> {
  _$ExpansionTriggeredCopyWithImpl(this._self, this._then);

  final ExpansionTriggered _self;
  final $Res Function(ExpansionTriggered) _then;

/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? pointsUsed = null,Object? additionalReach = null,Object? timestamp = null,}) {
  return _then(ExpansionTriggered(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,additionalReach: null == additionalReach ? _self.additionalReach : additionalReach // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
@JsonSerializable()

class NotificationSent extends VotingUpdate {
  const NotificationSent({required this.postId, required final  List<String> recipientIds, required this.timestamp, final  String? $type}): _recipientIds = recipientIds,$type = $type ?? 'notificationSent',super._();
  factory NotificationSent.fromJson(Map<String, dynamic> json) => _$NotificationSentFromJson(json);

@override final  String postId;
 final  List<String> _recipientIds;
 List<String> get recipientIds {
  if (_recipientIds is EqualUnmodifiableListView) return _recipientIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipientIds);
}

@override final  DateTime timestamp;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSentCopyWith<NotificationSent> get copyWith => _$NotificationSentCopyWithImpl<NotificationSent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSent&&(identical(other.postId, postId) || other.postId == postId)&&const DeepCollectionEquality().equals(other._recipientIds, _recipientIds)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,const DeepCollectionEquality().hash(_recipientIds),timestamp);

@override
String toString() {
  return 'VotingUpdate.notificationSent(postId: $postId, recipientIds: $recipientIds, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $NotificationSentCopyWith<$Res> implements $VotingUpdateCopyWith<$Res> {
  factory $NotificationSentCopyWith(NotificationSent value, $Res Function(NotificationSent) _then) = _$NotificationSentCopyWithImpl;
@override @useResult
$Res call({
 String postId, List<String> recipientIds, DateTime timestamp
});




}
/// @nodoc
class _$NotificationSentCopyWithImpl<$Res>
    implements $NotificationSentCopyWith<$Res> {
  _$NotificationSentCopyWithImpl(this._self, this._then);

  final NotificationSent _self;
  final $Res Function(NotificationSent) _then;

/// Create a copy of VotingUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? recipientIds = null,Object? timestamp = null,}) {
  return _then(NotificationSent(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,recipientIds: null == recipientIds ? _self._recipientIds : recipientIds // ignore: cast_nullable_to_non_nullable
as List<String>,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
