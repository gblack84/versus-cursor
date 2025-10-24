// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_voting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostVoting {

// Core Identity
 String get postId;// Foreign key to PostCore.id
// Timing Fields
@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteStartTime;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteEndTime;@JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson) VoteStatus get voteStatus; bool get voteCompleted;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteCompletedAt;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteCancelledAt; String? get voteCancelledReason;@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration get voteTimeout;// Vote Counts
 int get votesA; int get votesB; List<String> get votedUserIdsA; List<String> get votedUserIdsB;// Display Values (for animations/privacy)
 int? get displayVotesA;// May differ from actual for animation
 int? get displayVotesB;// Notification System
 bool get notificationsSent;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get notificationsSentAt;// Expansion System
 int get expansionPointsUsed; int get expandedUserCount; String get expansionStatus;
/// Create a copy of PostVoting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostVotingCopyWith<PostVoting> get copyWith => _$PostVotingCopyWithImpl<PostVoting>(this as PostVoting, _$identity);

  /// Serializes this PostVoting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostVoting&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.voteCompleted, voteCompleted) || other.voteCompleted == voteCompleted)&&(identical(other.voteCompletedAt, voteCompletedAt) || other.voteCompletedAt == voteCompletedAt)&&(identical(other.voteCancelledAt, voteCancelledAt) || other.voteCancelledAt == voteCancelledAt)&&(identical(other.voteCancelledReason, voteCancelledReason) || other.voteCancelledReason == voteCancelledReason)&&(identical(other.voteTimeout, voteTimeout) || other.voteTimeout == voteTimeout)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&const DeepCollectionEquality().equals(other.votedUserIdsA, votedUserIdsA)&&const DeepCollectionEquality().equals(other.votedUserIdsB, votedUserIdsB)&&(identical(other.displayVotesA, displayVotesA) || other.displayVotesA == displayVotesA)&&(identical(other.displayVotesB, displayVotesB) || other.displayVotesB == displayVotesB)&&(identical(other.notificationsSent, notificationsSent) || other.notificationsSent == notificationsSent)&&(identical(other.notificationsSentAt, notificationsSentAt) || other.notificationsSentAt == notificationsSentAt)&&(identical(other.expansionPointsUsed, expansionPointsUsed) || other.expansionPointsUsed == expansionPointsUsed)&&(identical(other.expandedUserCount, expandedUserCount) || other.expandedUserCount == expandedUserCount)&&(identical(other.expansionStatus, expansionStatus) || other.expansionStatus == expansionStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,postId,voteStartTime,voteEndTime,voteStatus,voteCompleted,voteCompletedAt,voteCancelledAt,voteCancelledReason,voteTimeout,votesA,votesB,const DeepCollectionEquality().hash(votedUserIdsA),const DeepCollectionEquality().hash(votedUserIdsB),displayVotesA,displayVotesB,notificationsSent,notificationsSentAt,expansionPointsUsed,expandedUserCount,expansionStatus]);

@override
String toString() {
  return 'PostVoting(postId: $postId, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, voteStatus: $voteStatus, voteCompleted: $voteCompleted, voteCompletedAt: $voteCompletedAt, voteCancelledAt: $voteCancelledAt, voteCancelledReason: $voteCancelledReason, voteTimeout: $voteTimeout, votesA: $votesA, votesB: $votesB, votedUserIdsA: $votedUserIdsA, votedUserIdsB: $votedUserIdsB, displayVotesA: $displayVotesA, displayVotesB: $displayVotesB, notificationsSent: $notificationsSent, notificationsSentAt: $notificationsSentAt, expansionPointsUsed: $expansionPointsUsed, expandedUserCount: $expandedUserCount, expansionStatus: $expansionStatus)';
}


}

/// @nodoc
abstract mixin class $PostVotingCopyWith<$Res>  {
  factory $PostVotingCopyWith(PostVoting value, $Res Function(PostVoting) _then) = _$PostVotingCopyWithImpl;
@useResult
$Res call({
 String postId,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteStartTime,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteEndTime,@JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson) VoteStatus voteStatus, bool voteCompleted,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCompletedAt,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCancelledAt, String? voteCancelledReason,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration voteTimeout, int votesA, int votesB, List<String> votedUserIdsA, List<String> votedUserIdsB, int? displayVotesA, int? displayVotesB, bool notificationsSent,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? notificationsSentAt, int expansionPointsUsed, int expandedUserCount, String expansionStatus
});




}
/// @nodoc
class _$PostVotingCopyWithImpl<$Res>
    implements $PostVotingCopyWith<$Res> {
  _$PostVotingCopyWithImpl(this._self, this._then);

  final PostVoting _self;
  final $Res Function(PostVoting) _then;

/// Create a copy of PostVoting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? voteStartTime = freezed,Object? voteEndTime = freezed,Object? voteStatus = null,Object? voteCompleted = null,Object? voteCompletedAt = freezed,Object? voteCancelledAt = freezed,Object? voteCancelledReason = freezed,Object? voteTimeout = null,Object? votesA = null,Object? votesB = null,Object? votedUserIdsA = null,Object? votedUserIdsB = null,Object? displayVotesA = freezed,Object? displayVotesB = freezed,Object? notificationsSent = null,Object? notificationsSentAt = freezed,Object? expansionPointsUsed = null,Object? expandedUserCount = null,Object? expansionStatus = null,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,voteStartTime: freezed == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as VoteStatus,voteCompleted: null == voteCompleted ? _self.voteCompleted : voteCompleted // ignore: cast_nullable_to_non_nullable
as bool,voteCompletedAt: freezed == voteCompletedAt ? _self.voteCompletedAt : voteCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledAt: freezed == voteCancelledAt ? _self.voteCancelledAt : voteCancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledReason: freezed == voteCancelledReason ? _self.voteCancelledReason : voteCancelledReason // ignore: cast_nullable_to_non_nullable
as String?,voteTimeout: null == voteTimeout ? _self.voteTimeout : voteTimeout // ignore: cast_nullable_to_non_nullable
as Duration,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,votedUserIdsA: null == votedUserIdsA ? _self.votedUserIdsA : votedUserIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,votedUserIdsB: null == votedUserIdsB ? _self.votedUserIdsB : votedUserIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,displayVotesA: freezed == displayVotesA ? _self.displayVotesA : displayVotesA // ignore: cast_nullable_to_non_nullable
as int?,displayVotesB: freezed == displayVotesB ? _self.displayVotesB : displayVotesB // ignore: cast_nullable_to_non_nullable
as int?,notificationsSent: null == notificationsSent ? _self.notificationsSent : notificationsSent // ignore: cast_nullable_to_non_nullable
as bool,notificationsSentAt: freezed == notificationsSentAt ? _self.notificationsSentAt : notificationsSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expansionPointsUsed: null == expansionPointsUsed ? _self.expansionPointsUsed : expansionPointsUsed // ignore: cast_nullable_to_non_nullable
as int,expandedUserCount: null == expandedUserCount ? _self.expandedUserCount : expandedUserCount // ignore: cast_nullable_to_non_nullable
as int,expansionStatus: null == expansionStatus ? _self.expansionStatus : expansionStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostVoting].
extension PostVotingPatterns on PostVoting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostVoting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostVoting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostVoting value)  $default,){
final _that = this;
switch (_that) {
case _PostVoting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostVoting value)?  $default,){
final _that = this;
switch (_that) {
case _PostVoting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteEndTime, @JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson)  VoteStatus voteStatus,  bool voteCompleted, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCancelledAt,  String? voteCancelledReason, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration voteTimeout,  int votesA,  int votesB,  List<String> votedUserIdsA,  List<String> votedUserIdsB,  int? displayVotesA,  int? displayVotesB,  bool notificationsSent, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? notificationsSentAt,  int expansionPointsUsed,  int expandedUserCount,  String expansionStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostVoting() when $default != null:
return $default(_that.postId,_that.voteStartTime,_that.voteEndTime,_that.voteStatus,_that.voteCompleted,_that.voteCompletedAt,_that.voteCancelledAt,_that.voteCancelledReason,_that.voteTimeout,_that.votesA,_that.votesB,_that.votedUserIdsA,_that.votedUserIdsB,_that.displayVotesA,_that.displayVotesB,_that.notificationsSent,_that.notificationsSentAt,_that.expansionPointsUsed,_that.expandedUserCount,_that.expansionStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteEndTime, @JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson)  VoteStatus voteStatus,  bool voteCompleted, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCancelledAt,  String? voteCancelledReason, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration voteTimeout,  int votesA,  int votesB,  List<String> votedUserIdsA,  List<String> votedUserIdsB,  int? displayVotesA,  int? displayVotesB,  bool notificationsSent, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? notificationsSentAt,  int expansionPointsUsed,  int expandedUserCount,  String expansionStatus)  $default,) {final _that = this;
switch (_that) {
case _PostVoting():
return $default(_that.postId,_that.voteStartTime,_that.voteEndTime,_that.voteStatus,_that.voteCompleted,_that.voteCompletedAt,_that.voteCancelledAt,_that.voteCancelledReason,_that.voteTimeout,_that.votesA,_that.votesB,_that.votedUserIdsA,_that.votedUserIdsB,_that.displayVotesA,_that.displayVotesB,_that.notificationsSent,_that.notificationsSentAt,_that.expansionPointsUsed,_that.expandedUserCount,_that.expansionStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteEndTime, @JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson)  VoteStatus voteStatus,  bool voteCompleted, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCancelledAt,  String? voteCancelledReason, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)  Duration voteTimeout,  int votesA,  int votesB,  List<String> votedUserIdsA,  List<String> votedUserIdsB,  int? displayVotesA,  int? displayVotesB,  bool notificationsSent, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? notificationsSentAt,  int expansionPointsUsed,  int expandedUserCount,  String expansionStatus)?  $default,) {final _that = this;
switch (_that) {
case _PostVoting() when $default != null:
return $default(_that.postId,_that.voteStartTime,_that.voteEndTime,_that.voteStatus,_that.voteCompleted,_that.voteCompletedAt,_that.voteCancelledAt,_that.voteCancelledReason,_that.voteTimeout,_that.votesA,_that.votesB,_that.votedUserIdsA,_that.votedUserIdsB,_that.displayVotesA,_that.displayVotesB,_that.notificationsSent,_that.notificationsSentAt,_that.expansionPointsUsed,_that.expandedUserCount,_that.expansionStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostVoting extends PostVoting {
  const _PostVoting({required this.postId, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteEndTime, @JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson) this.voteStatus = VoteStatus.pending, this.voteCompleted = false, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteCancelledAt, this.voteCancelledReason, @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) this.voteTimeout = const Duration(minutes: 10), this.votesA = 0, this.votesB = 0, final  List<String> votedUserIdsA = const [], final  List<String> votedUserIdsB = const [], this.displayVotesA, this.displayVotesB, this.notificationsSent = false, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.notificationsSentAt, this.expansionPointsUsed = 0, this.expandedUserCount = 0, this.expansionStatus = 'none'}): _votedUserIdsA = votedUserIdsA,_votedUserIdsB = votedUserIdsB,super._();
  factory _PostVoting.fromJson(Map<String, dynamic> json) => _$PostVotingFromJson(json);

// Core Identity
@override final  String postId;
// Foreign key to PostCore.id
// Timing Fields
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteStartTime;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteEndTime;
@override@JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson) final  VoteStatus voteStatus;
@override@JsonKey() final  bool voteCompleted;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteCompletedAt;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteCancelledAt;
@override final  String? voteCancelledReason;
@override@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) final  Duration voteTimeout;
// Vote Counts
@override@JsonKey() final  int votesA;
@override@JsonKey() final  int votesB;
 final  List<String> _votedUserIdsA;
@override@JsonKey() List<String> get votedUserIdsA {
  if (_votedUserIdsA is EqualUnmodifiableListView) return _votedUserIdsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_votedUserIdsA);
}

 final  List<String> _votedUserIdsB;
@override@JsonKey() List<String> get votedUserIdsB {
  if (_votedUserIdsB is EqualUnmodifiableListView) return _votedUserIdsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_votedUserIdsB);
}

// Display Values (for animations/privacy)
@override final  int? displayVotesA;
// May differ from actual for animation
@override final  int? displayVotesB;
// Notification System
@override@JsonKey() final  bool notificationsSent;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? notificationsSentAt;
// Expansion System
@override@JsonKey() final  int expansionPointsUsed;
@override@JsonKey() final  int expandedUserCount;
@override@JsonKey() final  String expansionStatus;

/// Create a copy of PostVoting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostVotingCopyWith<_PostVoting> get copyWith => __$PostVotingCopyWithImpl<_PostVoting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostVotingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostVoting&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.voteCompleted, voteCompleted) || other.voteCompleted == voteCompleted)&&(identical(other.voteCompletedAt, voteCompletedAt) || other.voteCompletedAt == voteCompletedAt)&&(identical(other.voteCancelledAt, voteCancelledAt) || other.voteCancelledAt == voteCancelledAt)&&(identical(other.voteCancelledReason, voteCancelledReason) || other.voteCancelledReason == voteCancelledReason)&&(identical(other.voteTimeout, voteTimeout) || other.voteTimeout == voteTimeout)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&const DeepCollectionEquality().equals(other._votedUserIdsA, _votedUserIdsA)&&const DeepCollectionEquality().equals(other._votedUserIdsB, _votedUserIdsB)&&(identical(other.displayVotesA, displayVotesA) || other.displayVotesA == displayVotesA)&&(identical(other.displayVotesB, displayVotesB) || other.displayVotesB == displayVotesB)&&(identical(other.notificationsSent, notificationsSent) || other.notificationsSent == notificationsSent)&&(identical(other.notificationsSentAt, notificationsSentAt) || other.notificationsSentAt == notificationsSentAt)&&(identical(other.expansionPointsUsed, expansionPointsUsed) || other.expansionPointsUsed == expansionPointsUsed)&&(identical(other.expandedUserCount, expandedUserCount) || other.expandedUserCount == expandedUserCount)&&(identical(other.expansionStatus, expansionStatus) || other.expansionStatus == expansionStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,postId,voteStartTime,voteEndTime,voteStatus,voteCompleted,voteCompletedAt,voteCancelledAt,voteCancelledReason,voteTimeout,votesA,votesB,const DeepCollectionEquality().hash(_votedUserIdsA),const DeepCollectionEquality().hash(_votedUserIdsB),displayVotesA,displayVotesB,notificationsSent,notificationsSentAt,expansionPointsUsed,expandedUserCount,expansionStatus]);

@override
String toString() {
  return 'PostVoting(postId: $postId, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, voteStatus: $voteStatus, voteCompleted: $voteCompleted, voteCompletedAt: $voteCompletedAt, voteCancelledAt: $voteCancelledAt, voteCancelledReason: $voteCancelledReason, voteTimeout: $voteTimeout, votesA: $votesA, votesB: $votesB, votedUserIdsA: $votedUserIdsA, votedUserIdsB: $votedUserIdsB, displayVotesA: $displayVotesA, displayVotesB: $displayVotesB, notificationsSent: $notificationsSent, notificationsSentAt: $notificationsSentAt, expansionPointsUsed: $expansionPointsUsed, expandedUserCount: $expandedUserCount, expansionStatus: $expansionStatus)';
}


}

/// @nodoc
abstract mixin class _$PostVotingCopyWith<$Res> implements $PostVotingCopyWith<$Res> {
  factory _$PostVotingCopyWith(_PostVoting value, $Res Function(_PostVoting) _then) = __$PostVotingCopyWithImpl;
@override @useResult
$Res call({
 String postId,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteStartTime,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteEndTime,@JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson) VoteStatus voteStatus, bool voteCompleted,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCompletedAt,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCancelledAt, String? voteCancelledReason,@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson) Duration voteTimeout, int votesA, int votesB, List<String> votedUserIdsA, List<String> votedUserIdsB, int? displayVotesA, int? displayVotesB, bool notificationsSent,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? notificationsSentAt, int expansionPointsUsed, int expandedUserCount, String expansionStatus
});




}
/// @nodoc
class __$PostVotingCopyWithImpl<$Res>
    implements _$PostVotingCopyWith<$Res> {
  __$PostVotingCopyWithImpl(this._self, this._then);

  final _PostVoting _self;
  final $Res Function(_PostVoting) _then;

/// Create a copy of PostVoting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? voteStartTime = freezed,Object? voteEndTime = freezed,Object? voteStatus = null,Object? voteCompleted = null,Object? voteCompletedAt = freezed,Object? voteCancelledAt = freezed,Object? voteCancelledReason = freezed,Object? voteTimeout = null,Object? votesA = null,Object? votesB = null,Object? votedUserIdsA = null,Object? votedUserIdsB = null,Object? displayVotesA = freezed,Object? displayVotesB = freezed,Object? notificationsSent = null,Object? notificationsSentAt = freezed,Object? expansionPointsUsed = null,Object? expandedUserCount = null,Object? expansionStatus = null,}) {
  return _then(_PostVoting(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,voteStartTime: freezed == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as VoteStatus,voteCompleted: null == voteCompleted ? _self.voteCompleted : voteCompleted // ignore: cast_nullable_to_non_nullable
as bool,voteCompletedAt: freezed == voteCompletedAt ? _self.voteCompletedAt : voteCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledAt: freezed == voteCancelledAt ? _self.voteCancelledAt : voteCancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledReason: freezed == voteCancelledReason ? _self.voteCancelledReason : voteCancelledReason // ignore: cast_nullable_to_non_nullable
as String?,voteTimeout: null == voteTimeout ? _self.voteTimeout : voteTimeout // ignore: cast_nullable_to_non_nullable
as Duration,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,votedUserIdsA: null == votedUserIdsA ? _self._votedUserIdsA : votedUserIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,votedUserIdsB: null == votedUserIdsB ? _self._votedUserIdsB : votedUserIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,displayVotesA: freezed == displayVotesA ? _self.displayVotesA : displayVotesA // ignore: cast_nullable_to_non_nullable
as int?,displayVotesB: freezed == displayVotesB ? _self.displayVotesB : displayVotesB // ignore: cast_nullable_to_non_nullable
as int?,notificationsSent: null == notificationsSent ? _self.notificationsSent : notificationsSent // ignore: cast_nullable_to_non_nullable
as bool,notificationsSentAt: freezed == notificationsSentAt ? _self.notificationsSentAt : notificationsSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expansionPointsUsed: null == expansionPointsUsed ? _self.expansionPointsUsed : expansionPointsUsed // ignore: cast_nullable_to_non_nullable
as int,expandedUserCount: null == expandedUserCount ? _self.expandedUserCount : expandedUserCount // ignore: cast_nullable_to_non_nullable
as int,expansionStatus: null == expansionStatus ? _self.expansionStatus : expansionStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
