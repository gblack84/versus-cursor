// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteData {

// Timing Fields
@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteStartTime;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteEndTime; String get voteStatus; bool get voteCompleted; bool get isVotingComplete;// Vote Counts
 int get votesA; int get votesB; List<String> get votedUserIdsA; List<String> get votedUserIdsB; int get totalVotes;// Timeout & Completion
 bool get voteTimeout;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteCompletedAt;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get voteCancelledAt; String get voteCancelledReason;// Notification System
 bool get notificationsSent;@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? get notificationsSentAt;// Display Values (for animations/privacy)
 int get displayVotesA; int get displayVotesB; int get displayPercentA; int get displayPercentB;// Actual Values (for accuracy)
 int get actualVotesA; int get actualVotesB; int get actualTotalVotes;// Expansion System
 int get expansionPointsUsed; int get expandedUserCount; String get expansionStatus;
/// Create a copy of VoteData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteDataCopyWith<VoteData> get copyWith => _$VoteDataCopyWithImpl<VoteData>(this as VoteData, _$identity);

  /// Serializes this VoteData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteData&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.voteCompleted, voteCompleted) || other.voteCompleted == voteCompleted)&&(identical(other.isVotingComplete, isVotingComplete) || other.isVotingComplete == isVotingComplete)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&const DeepCollectionEquality().equals(other.votedUserIdsA, votedUserIdsA)&&const DeepCollectionEquality().equals(other.votedUserIdsB, votedUserIdsB)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes)&&(identical(other.voteTimeout, voteTimeout) || other.voteTimeout == voteTimeout)&&(identical(other.voteCompletedAt, voteCompletedAt) || other.voteCompletedAt == voteCompletedAt)&&(identical(other.voteCancelledAt, voteCancelledAt) || other.voteCancelledAt == voteCancelledAt)&&(identical(other.voteCancelledReason, voteCancelledReason) || other.voteCancelledReason == voteCancelledReason)&&(identical(other.notificationsSent, notificationsSent) || other.notificationsSent == notificationsSent)&&(identical(other.notificationsSentAt, notificationsSentAt) || other.notificationsSentAt == notificationsSentAt)&&(identical(other.displayVotesA, displayVotesA) || other.displayVotesA == displayVotesA)&&(identical(other.displayVotesB, displayVotesB) || other.displayVotesB == displayVotesB)&&(identical(other.displayPercentA, displayPercentA) || other.displayPercentA == displayPercentA)&&(identical(other.displayPercentB, displayPercentB) || other.displayPercentB == displayPercentB)&&(identical(other.actualVotesA, actualVotesA) || other.actualVotesA == actualVotesA)&&(identical(other.actualVotesB, actualVotesB) || other.actualVotesB == actualVotesB)&&(identical(other.actualTotalVotes, actualTotalVotes) || other.actualTotalVotes == actualTotalVotes)&&(identical(other.expansionPointsUsed, expansionPointsUsed) || other.expansionPointsUsed == expansionPointsUsed)&&(identical(other.expandedUserCount, expandedUserCount) || other.expandedUserCount == expandedUserCount)&&(identical(other.expansionStatus, expansionStatus) || other.expansionStatus == expansionStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,voteStartTime,voteEndTime,voteStatus,voteCompleted,isVotingComplete,votesA,votesB,const DeepCollectionEquality().hash(votedUserIdsA),const DeepCollectionEquality().hash(votedUserIdsB),totalVotes,voteTimeout,voteCompletedAt,voteCancelledAt,voteCancelledReason,notificationsSent,notificationsSentAt,displayVotesA,displayVotesB,displayPercentA,displayPercentB,actualVotesA,actualVotesB,actualTotalVotes,expansionPointsUsed,expandedUserCount,expansionStatus]);

@override
String toString() {
  return 'VoteData(voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, voteStatus: $voteStatus, voteCompleted: $voteCompleted, isVotingComplete: $isVotingComplete, votesA: $votesA, votesB: $votesB, votedUserIdsA: $votedUserIdsA, votedUserIdsB: $votedUserIdsB, totalVotes: $totalVotes, voteTimeout: $voteTimeout, voteCompletedAt: $voteCompletedAt, voteCancelledAt: $voteCancelledAt, voteCancelledReason: $voteCancelledReason, notificationsSent: $notificationsSent, notificationsSentAt: $notificationsSentAt, displayVotesA: $displayVotesA, displayVotesB: $displayVotesB, displayPercentA: $displayPercentA, displayPercentB: $displayPercentB, actualVotesA: $actualVotesA, actualVotesB: $actualVotesB, actualTotalVotes: $actualTotalVotes, expansionPointsUsed: $expansionPointsUsed, expandedUserCount: $expandedUserCount, expansionStatus: $expansionStatus)';
}


}

/// @nodoc
abstract mixin class $VoteDataCopyWith<$Res>  {
  factory $VoteDataCopyWith(VoteData value, $Res Function(VoteData) _then) = _$VoteDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteStartTime,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteEndTime, String voteStatus, bool voteCompleted, bool isVotingComplete, int votesA, int votesB, List<String> votedUserIdsA, List<String> votedUserIdsB, int totalVotes, bool voteTimeout,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCompletedAt,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCancelledAt, String voteCancelledReason, bool notificationsSent,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? notificationsSentAt, int displayVotesA, int displayVotesB, int displayPercentA, int displayPercentB, int actualVotesA, int actualVotesB, int actualTotalVotes, int expansionPointsUsed, int expandedUserCount, String expansionStatus
});




}
/// @nodoc
class _$VoteDataCopyWithImpl<$Res>
    implements $VoteDataCopyWith<$Res> {
  _$VoteDataCopyWithImpl(this._self, this._then);

  final VoteData _self;
  final $Res Function(VoteData) _then;

/// Create a copy of VoteData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voteStartTime = freezed,Object? voteEndTime = freezed,Object? voteStatus = null,Object? voteCompleted = null,Object? isVotingComplete = null,Object? votesA = null,Object? votesB = null,Object? votedUserIdsA = null,Object? votedUserIdsB = null,Object? totalVotes = null,Object? voteTimeout = null,Object? voteCompletedAt = freezed,Object? voteCancelledAt = freezed,Object? voteCancelledReason = null,Object? notificationsSent = null,Object? notificationsSentAt = freezed,Object? displayVotesA = null,Object? displayVotesB = null,Object? displayPercentA = null,Object? displayPercentB = null,Object? actualVotesA = null,Object? actualVotesB = null,Object? actualTotalVotes = null,Object? expansionPointsUsed = null,Object? expandedUserCount = null,Object? expansionStatus = null,}) {
  return _then(_self.copyWith(
voteStartTime: freezed == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as String,voteCompleted: null == voteCompleted ? _self.voteCompleted : voteCompleted // ignore: cast_nullable_to_non_nullable
as bool,isVotingComplete: null == isVotingComplete ? _self.isVotingComplete : isVotingComplete // ignore: cast_nullable_to_non_nullable
as bool,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,votedUserIdsA: null == votedUserIdsA ? _self.votedUserIdsA : votedUserIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,votedUserIdsB: null == votedUserIdsB ? _self.votedUserIdsB : votedUserIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,voteTimeout: null == voteTimeout ? _self.voteTimeout : voteTimeout // ignore: cast_nullable_to_non_nullable
as bool,voteCompletedAt: freezed == voteCompletedAt ? _self.voteCompletedAt : voteCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledAt: freezed == voteCancelledAt ? _self.voteCancelledAt : voteCancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledReason: null == voteCancelledReason ? _self.voteCancelledReason : voteCancelledReason // ignore: cast_nullable_to_non_nullable
as String,notificationsSent: null == notificationsSent ? _self.notificationsSent : notificationsSent // ignore: cast_nullable_to_non_nullable
as bool,notificationsSentAt: freezed == notificationsSentAt ? _self.notificationsSentAt : notificationsSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayVotesA: null == displayVotesA ? _self.displayVotesA : displayVotesA // ignore: cast_nullable_to_non_nullable
as int,displayVotesB: null == displayVotesB ? _self.displayVotesB : displayVotesB // ignore: cast_nullable_to_non_nullable
as int,displayPercentA: null == displayPercentA ? _self.displayPercentA : displayPercentA // ignore: cast_nullable_to_non_nullable
as int,displayPercentB: null == displayPercentB ? _self.displayPercentB : displayPercentB // ignore: cast_nullable_to_non_nullable
as int,actualVotesA: null == actualVotesA ? _self.actualVotesA : actualVotesA // ignore: cast_nullable_to_non_nullable
as int,actualVotesB: null == actualVotesB ? _self.actualVotesB : actualVotesB // ignore: cast_nullable_to_non_nullable
as int,actualTotalVotes: null == actualTotalVotes ? _self.actualTotalVotes : actualTotalVotes // ignore: cast_nullable_to_non_nullable
as int,expansionPointsUsed: null == expansionPointsUsed ? _self.expansionPointsUsed : expansionPointsUsed // ignore: cast_nullable_to_non_nullable
as int,expandedUserCount: null == expandedUserCount ? _self.expandedUserCount : expandedUserCount // ignore: cast_nullable_to_non_nullable
as int,expansionStatus: null == expansionStatus ? _self.expansionStatus : expansionStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteData].
extension VoteDataPatterns on VoteData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteData value)  $default,){
final _that = this;
switch (_that) {
case _VoteData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteData value)?  $default,){
final _that = this;
switch (_that) {
case _VoteData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteEndTime,  String voteStatus,  bool voteCompleted,  bool isVotingComplete,  int votesA,  int votesB,  List<String> votedUserIdsA,  List<String> votedUserIdsB,  int totalVotes,  bool voteTimeout, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCancelledAt,  String voteCancelledReason,  bool notificationsSent, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? notificationsSentAt,  int displayVotesA,  int displayVotesB,  int displayPercentA,  int displayPercentB,  int actualVotesA,  int actualVotesB,  int actualTotalVotes,  int expansionPointsUsed,  int expandedUserCount,  String expansionStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteData() when $default != null:
return $default(_that.voteStartTime,_that.voteEndTime,_that.voteStatus,_that.voteCompleted,_that.isVotingComplete,_that.votesA,_that.votesB,_that.votedUserIdsA,_that.votedUserIdsB,_that.totalVotes,_that.voteTimeout,_that.voteCompletedAt,_that.voteCancelledAt,_that.voteCancelledReason,_that.notificationsSent,_that.notificationsSentAt,_that.displayVotesA,_that.displayVotesB,_that.displayPercentA,_that.displayPercentB,_that.actualVotesA,_that.actualVotesB,_that.actualTotalVotes,_that.expansionPointsUsed,_that.expandedUserCount,_that.expansionStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteEndTime,  String voteStatus,  bool voteCompleted,  bool isVotingComplete,  int votesA,  int votesB,  List<String> votedUserIdsA,  List<String> votedUserIdsB,  int totalVotes,  bool voteTimeout, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCancelledAt,  String voteCancelledReason,  bool notificationsSent, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? notificationsSentAt,  int displayVotesA,  int displayVotesB,  int displayPercentA,  int displayPercentB,  int actualVotesA,  int actualVotesB,  int actualTotalVotes,  int expansionPointsUsed,  int expandedUserCount,  String expansionStatus)  $default,) {final _that = this;
switch (_that) {
case _VoteData():
return $default(_that.voteStartTime,_that.voteEndTime,_that.voteStatus,_that.voteCompleted,_that.isVotingComplete,_that.votesA,_that.votesB,_that.votedUserIdsA,_that.votedUserIdsB,_that.totalVotes,_that.voteTimeout,_that.voteCompletedAt,_that.voteCancelledAt,_that.voteCancelledReason,_that.notificationsSent,_that.notificationsSentAt,_that.displayVotesA,_that.displayVotesB,_that.displayPercentA,_that.displayPercentB,_that.actualVotesA,_that.actualVotesB,_that.actualTotalVotes,_that.expansionPointsUsed,_that.expandedUserCount,_that.expansionStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteEndTime,  String voteStatus,  bool voteCompleted,  bool isVotingComplete,  int votesA,  int votesB,  List<String> votedUserIdsA,  List<String> votedUserIdsB,  int totalVotes,  bool voteTimeout, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? voteCancelledAt,  String voteCancelledReason,  bool notificationsSent, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)  DateTime? notificationsSentAt,  int displayVotesA,  int displayVotesB,  int displayPercentA,  int displayPercentB,  int actualVotesA,  int actualVotesB,  int actualTotalVotes,  int expansionPointsUsed,  int expandedUserCount,  String expansionStatus)?  $default,) {final _that = this;
switch (_that) {
case _VoteData() when $default != null:
return $default(_that.voteStartTime,_that.voteEndTime,_that.voteStatus,_that.voteCompleted,_that.isVotingComplete,_that.votesA,_that.votesB,_that.votedUserIdsA,_that.votedUserIdsB,_that.totalVotes,_that.voteTimeout,_that.voteCompletedAt,_that.voteCancelledAt,_that.voteCancelledReason,_that.notificationsSent,_that.notificationsSentAt,_that.displayVotesA,_that.displayVotesB,_that.displayPercentA,_that.displayPercentB,_that.actualVotesA,_that.actualVotesB,_that.actualTotalVotes,_that.expansionPointsUsed,_that.expandedUserCount,_that.expansionStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteData extends VoteData {
  const _VoteData({@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteStartTime, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteEndTime, this.voteStatus = '', this.voteCompleted = false, this.isVotingComplete = false, this.votesA = 0, this.votesB = 0, final  List<String> votedUserIdsA = const [], final  List<String> votedUserIdsB = const [], this.totalVotes = 0, this.voteTimeout = false, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteCompletedAt, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.voteCancelledAt, this.voteCancelledReason = '', this.notificationsSent = false, @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) this.notificationsSentAt, this.displayVotesA = 0, this.displayVotesB = 0, this.displayPercentA = 0, this.displayPercentB = 0, this.actualVotesA = 0, this.actualVotesB = 0, this.actualTotalVotes = 0, this.expansionPointsUsed = 0, this.expandedUserCount = 0, this.expansionStatus = ''}): _votedUserIdsA = votedUserIdsA,_votedUserIdsB = votedUserIdsB,super._();
  factory _VoteData.fromJson(Map<String, dynamic> json) => _$VoteDataFromJson(json);

// Timing Fields
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteStartTime;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteEndTime;
@override@JsonKey() final  String voteStatus;
@override@JsonKey() final  bool voteCompleted;
@override@JsonKey() final  bool isVotingComplete;
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

@override@JsonKey() final  int totalVotes;
// Timeout & Completion
@override@JsonKey() final  bool voteTimeout;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteCompletedAt;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? voteCancelledAt;
@override@JsonKey() final  String voteCancelledReason;
// Notification System
@override@JsonKey() final  bool notificationsSent;
@override@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) final  DateTime? notificationsSentAt;
// Display Values (for animations/privacy)
@override@JsonKey() final  int displayVotesA;
@override@JsonKey() final  int displayVotesB;
@override@JsonKey() final  int displayPercentA;
@override@JsonKey() final  int displayPercentB;
// Actual Values (for accuracy)
@override@JsonKey() final  int actualVotesA;
@override@JsonKey() final  int actualVotesB;
@override@JsonKey() final  int actualTotalVotes;
// Expansion System
@override@JsonKey() final  int expansionPointsUsed;
@override@JsonKey() final  int expandedUserCount;
@override@JsonKey() final  String expansionStatus;

/// Create a copy of VoteData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteDataCopyWith<_VoteData> get copyWith => __$VoteDataCopyWithImpl<_VoteData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteData&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.voteCompleted, voteCompleted) || other.voteCompleted == voteCompleted)&&(identical(other.isVotingComplete, isVotingComplete) || other.isVotingComplete == isVotingComplete)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&const DeepCollectionEquality().equals(other._votedUserIdsA, _votedUserIdsA)&&const DeepCollectionEquality().equals(other._votedUserIdsB, _votedUserIdsB)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes)&&(identical(other.voteTimeout, voteTimeout) || other.voteTimeout == voteTimeout)&&(identical(other.voteCompletedAt, voteCompletedAt) || other.voteCompletedAt == voteCompletedAt)&&(identical(other.voteCancelledAt, voteCancelledAt) || other.voteCancelledAt == voteCancelledAt)&&(identical(other.voteCancelledReason, voteCancelledReason) || other.voteCancelledReason == voteCancelledReason)&&(identical(other.notificationsSent, notificationsSent) || other.notificationsSent == notificationsSent)&&(identical(other.notificationsSentAt, notificationsSentAt) || other.notificationsSentAt == notificationsSentAt)&&(identical(other.displayVotesA, displayVotesA) || other.displayVotesA == displayVotesA)&&(identical(other.displayVotesB, displayVotesB) || other.displayVotesB == displayVotesB)&&(identical(other.displayPercentA, displayPercentA) || other.displayPercentA == displayPercentA)&&(identical(other.displayPercentB, displayPercentB) || other.displayPercentB == displayPercentB)&&(identical(other.actualVotesA, actualVotesA) || other.actualVotesA == actualVotesA)&&(identical(other.actualVotesB, actualVotesB) || other.actualVotesB == actualVotesB)&&(identical(other.actualTotalVotes, actualTotalVotes) || other.actualTotalVotes == actualTotalVotes)&&(identical(other.expansionPointsUsed, expansionPointsUsed) || other.expansionPointsUsed == expansionPointsUsed)&&(identical(other.expandedUserCount, expandedUserCount) || other.expandedUserCount == expandedUserCount)&&(identical(other.expansionStatus, expansionStatus) || other.expansionStatus == expansionStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,voteStartTime,voteEndTime,voteStatus,voteCompleted,isVotingComplete,votesA,votesB,const DeepCollectionEquality().hash(_votedUserIdsA),const DeepCollectionEquality().hash(_votedUserIdsB),totalVotes,voteTimeout,voteCompletedAt,voteCancelledAt,voteCancelledReason,notificationsSent,notificationsSentAt,displayVotesA,displayVotesB,displayPercentA,displayPercentB,actualVotesA,actualVotesB,actualTotalVotes,expansionPointsUsed,expandedUserCount,expansionStatus]);

@override
String toString() {
  return 'VoteData(voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, voteStatus: $voteStatus, voteCompleted: $voteCompleted, isVotingComplete: $isVotingComplete, votesA: $votesA, votesB: $votesB, votedUserIdsA: $votedUserIdsA, votedUserIdsB: $votedUserIdsB, totalVotes: $totalVotes, voteTimeout: $voteTimeout, voteCompletedAt: $voteCompletedAt, voteCancelledAt: $voteCancelledAt, voteCancelledReason: $voteCancelledReason, notificationsSent: $notificationsSent, notificationsSentAt: $notificationsSentAt, displayVotesA: $displayVotesA, displayVotesB: $displayVotesB, displayPercentA: $displayPercentA, displayPercentB: $displayPercentB, actualVotesA: $actualVotesA, actualVotesB: $actualVotesB, actualTotalVotes: $actualTotalVotes, expansionPointsUsed: $expansionPointsUsed, expandedUserCount: $expandedUserCount, expansionStatus: $expansionStatus)';
}


}

/// @nodoc
abstract mixin class _$VoteDataCopyWith<$Res> implements $VoteDataCopyWith<$Res> {
  factory _$VoteDataCopyWith(_VoteData value, $Res Function(_VoteData) _then) = __$VoteDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteStartTime,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteEndTime, String voteStatus, bool voteCompleted, bool isVotingComplete, int votesA, int votesB, List<String> votedUserIdsA, List<String> votedUserIdsB, int totalVotes, bool voteTimeout,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCompletedAt,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? voteCancelledAt, String voteCancelledReason, bool notificationsSent,@JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp) DateTime? notificationsSentAt, int displayVotesA, int displayVotesB, int displayPercentA, int displayPercentB, int actualVotesA, int actualVotesB, int actualTotalVotes, int expansionPointsUsed, int expandedUserCount, String expansionStatus
});




}
/// @nodoc
class __$VoteDataCopyWithImpl<$Res>
    implements _$VoteDataCopyWith<$Res> {
  __$VoteDataCopyWithImpl(this._self, this._then);

  final _VoteData _self;
  final $Res Function(_VoteData) _then;

/// Create a copy of VoteData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voteStartTime = freezed,Object? voteEndTime = freezed,Object? voteStatus = null,Object? voteCompleted = null,Object? isVotingComplete = null,Object? votesA = null,Object? votesB = null,Object? votedUserIdsA = null,Object? votedUserIdsB = null,Object? totalVotes = null,Object? voteTimeout = null,Object? voteCompletedAt = freezed,Object? voteCancelledAt = freezed,Object? voteCancelledReason = null,Object? notificationsSent = null,Object? notificationsSentAt = freezed,Object? displayVotesA = null,Object? displayVotesB = null,Object? displayPercentA = null,Object? displayPercentB = null,Object? actualVotesA = null,Object? actualVotesB = null,Object? actualTotalVotes = null,Object? expansionPointsUsed = null,Object? expandedUserCount = null,Object? expansionStatus = null,}) {
  return _then(_VoteData(
voteStartTime: freezed == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as String,voteCompleted: null == voteCompleted ? _self.voteCompleted : voteCompleted // ignore: cast_nullable_to_non_nullable
as bool,isVotingComplete: null == isVotingComplete ? _self.isVotingComplete : isVotingComplete // ignore: cast_nullable_to_non_nullable
as bool,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,votedUserIdsA: null == votedUserIdsA ? _self._votedUserIdsA : votedUserIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,votedUserIdsB: null == votedUserIdsB ? _self._votedUserIdsB : votedUserIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,voteTimeout: null == voteTimeout ? _self.voteTimeout : voteTimeout // ignore: cast_nullable_to_non_nullable
as bool,voteCompletedAt: freezed == voteCompletedAt ? _self.voteCompletedAt : voteCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledAt: freezed == voteCancelledAt ? _self.voteCancelledAt : voteCancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voteCancelledReason: null == voteCancelledReason ? _self.voteCancelledReason : voteCancelledReason // ignore: cast_nullable_to_non_nullable
as String,notificationsSent: null == notificationsSent ? _self.notificationsSent : notificationsSent // ignore: cast_nullable_to_non_nullable
as bool,notificationsSentAt: freezed == notificationsSentAt ? _self.notificationsSentAt : notificationsSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayVotesA: null == displayVotesA ? _self.displayVotesA : displayVotesA // ignore: cast_nullable_to_non_nullable
as int,displayVotesB: null == displayVotesB ? _self.displayVotesB : displayVotesB // ignore: cast_nullable_to_non_nullable
as int,displayPercentA: null == displayPercentA ? _self.displayPercentA : displayPercentA // ignore: cast_nullable_to_non_nullable
as int,displayPercentB: null == displayPercentB ? _self.displayPercentB : displayPercentB // ignore: cast_nullable_to_non_nullable
as int,actualVotesA: null == actualVotesA ? _self.actualVotesA : actualVotesA // ignore: cast_nullable_to_non_nullable
as int,actualVotesB: null == actualVotesB ? _self.actualVotesB : actualVotesB // ignore: cast_nullable_to_non_nullable
as int,actualTotalVotes: null == actualTotalVotes ? _self.actualTotalVotes : actualTotalVotes // ignore: cast_nullable_to_non_nullable
as int,expansionPointsUsed: null == expansionPointsUsed ? _self.expansionPointsUsed : expansionPointsUsed // ignore: cast_nullable_to_non_nullable
as int,expandedUserCount: null == expandedUserCount ? _self.expandedUserCount : expandedUserCount // ignore: cast_nullable_to_non_nullable
as int,expansionStatus: null == expansionStatus ? _self.expansionStatus : expansionStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
