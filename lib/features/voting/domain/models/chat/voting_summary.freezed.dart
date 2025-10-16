// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voting_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VotingSummary {

 String get postId; VoteStatus get status; int get votesA; int get votesB; double get percentA; double get percentB; Duration get remainingTime; bool get hasUserVoted; VoteOption? get userVote; DateTime? get endTime; DateTime? get completedAt;
/// Create a copy of VotingSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VotingSummaryCopyWith<VotingSummary> get copyWith => _$VotingSummaryCopyWithImpl<VotingSummary>(this as VotingSummary, _$identity);

  /// Serializes this VotingSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VotingSummary&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.status, status) || other.status == status)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&(identical(other.percentA, percentA) || other.percentA == percentA)&&(identical(other.percentB, percentB) || other.percentB == percentB)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.hasUserVoted, hasUserVoted) || other.hasUserVoted == hasUserVoted)&&(identical(other.userVote, userVote) || other.userVote == userVote)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,status,votesA,votesB,percentA,percentB,remainingTime,hasUserVoted,userVote,endTime,completedAt);

@override
String toString() {
  return 'VotingSummary(postId: $postId, status: $status, votesA: $votesA, votesB: $votesB, percentA: $percentA, percentB: $percentB, remainingTime: $remainingTime, hasUserVoted: $hasUserVoted, userVote: $userVote, endTime: $endTime, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $VotingSummaryCopyWith<$Res>  {
  factory $VotingSummaryCopyWith(VotingSummary value, $Res Function(VotingSummary) _then) = _$VotingSummaryCopyWithImpl;
@useResult
$Res call({
 String postId, VoteStatus status, int votesA, int votesB, double percentA, double percentB, Duration remainingTime, bool hasUserVoted, VoteOption? userVote, DateTime? endTime, DateTime? completedAt
});




}
/// @nodoc
class _$VotingSummaryCopyWithImpl<$Res>
    implements $VotingSummaryCopyWith<$Res> {
  _$VotingSummaryCopyWithImpl(this._self, this._then);

  final VotingSummary _self;
  final $Res Function(VotingSummary) _then;

/// Create a copy of VotingSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? status = null,Object? votesA = null,Object? votesB = null,Object? percentA = null,Object? percentB = null,Object? remainingTime = null,Object? hasUserVoted = null,Object? userVote = freezed,Object? endTime = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoteStatus,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,percentA: null == percentA ? _self.percentA : percentA // ignore: cast_nullable_to_non_nullable
as double,percentB: null == percentB ? _self.percentB : percentB // ignore: cast_nullable_to_non_nullable
as double,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as Duration,hasUserVoted: null == hasUserVoted ? _self.hasUserVoted : hasUserVoted // ignore: cast_nullable_to_non_nullable
as bool,userVote: freezed == userVote ? _self.userVote : userVote // ignore: cast_nullable_to_non_nullable
as VoteOption?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VotingSummary].
extension VotingSummaryPatterns on VotingSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VotingSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VotingSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VotingSummary value)  $default,){
final _that = this;
switch (_that) {
case _VotingSummary():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VotingSummary value)?  $default,){
final _that = this;
switch (_that) {
case _VotingSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  VoteStatus status,  int votesA,  int votesB,  double percentA,  double percentB,  Duration remainingTime,  bool hasUserVoted,  VoteOption? userVote,  DateTime? endTime,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VotingSummary() when $default != null:
return $default(_that.postId,_that.status,_that.votesA,_that.votesB,_that.percentA,_that.percentB,_that.remainingTime,_that.hasUserVoted,_that.userVote,_that.endTime,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  VoteStatus status,  int votesA,  int votesB,  double percentA,  double percentB,  Duration remainingTime,  bool hasUserVoted,  VoteOption? userVote,  DateTime? endTime,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _VotingSummary():
return $default(_that.postId,_that.status,_that.votesA,_that.votesB,_that.percentA,_that.percentB,_that.remainingTime,_that.hasUserVoted,_that.userVote,_that.endTime,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  VoteStatus status,  int votesA,  int votesB,  double percentA,  double percentB,  Duration remainingTime,  bool hasUserVoted,  VoteOption? userVote,  DateTime? endTime,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _VotingSummary() when $default != null:
return $default(_that.postId,_that.status,_that.votesA,_that.votesB,_that.percentA,_that.percentB,_that.remainingTime,_that.hasUserVoted,_that.userVote,_that.endTime,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VotingSummary extends VotingSummary {
  const _VotingSummary({required this.postId, required this.status, required this.votesA, required this.votesB, required this.percentA, required this.percentB, required this.remainingTime, required this.hasUserVoted, this.userVote, this.endTime, this.completedAt}): super._();
  factory _VotingSummary.fromJson(Map<String, dynamic> json) => _$VotingSummaryFromJson(json);

@override final  String postId;
@override final  VoteStatus status;
@override final  int votesA;
@override final  int votesB;
@override final  double percentA;
@override final  double percentB;
@override final  Duration remainingTime;
@override final  bool hasUserVoted;
@override final  VoteOption? userVote;
@override final  DateTime? endTime;
@override final  DateTime? completedAt;

/// Create a copy of VotingSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VotingSummaryCopyWith<_VotingSummary> get copyWith => __$VotingSummaryCopyWithImpl<_VotingSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VotingSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VotingSummary&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.status, status) || other.status == status)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&(identical(other.percentA, percentA) || other.percentA == percentA)&&(identical(other.percentB, percentB) || other.percentB == percentB)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&(identical(other.hasUserVoted, hasUserVoted) || other.hasUserVoted == hasUserVoted)&&(identical(other.userVote, userVote) || other.userVote == userVote)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,status,votesA,votesB,percentA,percentB,remainingTime,hasUserVoted,userVote,endTime,completedAt);

@override
String toString() {
  return 'VotingSummary(postId: $postId, status: $status, votesA: $votesA, votesB: $votesB, percentA: $percentA, percentB: $percentB, remainingTime: $remainingTime, hasUserVoted: $hasUserVoted, userVote: $userVote, endTime: $endTime, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$VotingSummaryCopyWith<$Res> implements $VotingSummaryCopyWith<$Res> {
  factory _$VotingSummaryCopyWith(_VotingSummary value, $Res Function(_VotingSummary) _then) = __$VotingSummaryCopyWithImpl;
@override @useResult
$Res call({
 String postId, VoteStatus status, int votesA, int votesB, double percentA, double percentB, Duration remainingTime, bool hasUserVoted, VoteOption? userVote, DateTime? endTime, DateTime? completedAt
});




}
/// @nodoc
class __$VotingSummaryCopyWithImpl<$Res>
    implements _$VotingSummaryCopyWith<$Res> {
  __$VotingSummaryCopyWithImpl(this._self, this._then);

  final _VotingSummary _self;
  final $Res Function(_VotingSummary) _then;

/// Create a copy of VotingSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? status = null,Object? votesA = null,Object? votesB = null,Object? percentA = null,Object? percentB = null,Object? remainingTime = null,Object? hasUserVoted = null,Object? userVote = freezed,Object? endTime = freezed,Object? completedAt = freezed,}) {
  return _then(_VotingSummary(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoteStatus,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,percentA: null == percentA ? _self.percentA : percentA // ignore: cast_nullable_to_non_nullable
as double,percentB: null == percentB ? _self.percentB : percentB // ignore: cast_nullable_to_non_nullable
as double,remainingTime: null == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as Duration,hasUserVoted: null == hasUserVoted ? _self.hasUserVoted : hasUserVoted // ignore: cast_nullable_to_non_nullable
as bool,userVote: freezed == userVote ? _self.userVote : userVote // ignore: cast_nullable_to_non_nullable
as VoteOption?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
