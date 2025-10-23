// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_counts_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteCounts {

 int get votesA; int get votesB; int get totalVotes;
/// Create a copy of VoteCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteCountsCopyWith<VoteCounts> get copyWith => _$VoteCountsCopyWithImpl<VoteCounts>(this as VoteCounts, _$identity);

  /// Serializes this VoteCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteCounts&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,votesA,votesB,totalVotes);

@override
String toString() {
  return 'VoteCounts(votesA: $votesA, votesB: $votesB, totalVotes: $totalVotes)';
}


}

/// @nodoc
abstract mixin class $VoteCountsCopyWith<$Res>  {
  factory $VoteCountsCopyWith(VoteCounts value, $Res Function(VoteCounts) _then) = _$VoteCountsCopyWithImpl;
@useResult
$Res call({
 int votesA, int votesB, int totalVotes
});




}
/// @nodoc
class _$VoteCountsCopyWithImpl<$Res>
    implements $VoteCountsCopyWith<$Res> {
  _$VoteCountsCopyWithImpl(this._self, this._then);

  final VoteCounts _self;
  final $Res Function(VoteCounts) _then;

/// Create a copy of VoteCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? votesA = null,Object? votesB = null,Object? totalVotes = null,}) {
  return _then(_self.copyWith(
votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteCounts].
extension VoteCountsPatterns on VoteCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteCounts value)  $default,){
final _that = this;
switch (_that) {
case _VoteCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteCounts value)?  $default,){
final _that = this;
switch (_that) {
case _VoteCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int votesA,  int votesB,  int totalVotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteCounts() when $default != null:
return $default(_that.votesA,_that.votesB,_that.totalVotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int votesA,  int votesB,  int totalVotes)  $default,) {final _that = this;
switch (_that) {
case _VoteCounts():
return $default(_that.votesA,_that.votesB,_that.totalVotes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int votesA,  int votesB,  int totalVotes)?  $default,) {final _that = this;
switch (_that) {
case _VoteCounts() when $default != null:
return $default(_that.votesA,_that.votesB,_that.totalVotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteCounts extends VoteCounts {
  const _VoteCounts({required this.votesA, required this.votesB, required this.totalVotes}): super._();
  factory _VoteCounts.fromJson(Map<String, dynamic> json) => _$VoteCountsFromJson(json);

@override final  int votesA;
@override final  int votesB;
@override final  int totalVotes;

/// Create a copy of VoteCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteCountsCopyWith<_VoteCounts> get copyWith => __$VoteCountsCopyWithImpl<_VoteCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteCountsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteCounts&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,votesA,votesB,totalVotes);

@override
String toString() {
  return 'VoteCounts(votesA: $votesA, votesB: $votesB, totalVotes: $totalVotes)';
}


}

/// @nodoc
abstract mixin class _$VoteCountsCopyWith<$Res> implements $VoteCountsCopyWith<$Res> {
  factory _$VoteCountsCopyWith(_VoteCounts value, $Res Function(_VoteCounts) _then) = __$VoteCountsCopyWithImpl;
@override @useResult
$Res call({
 int votesA, int votesB, int totalVotes
});




}
/// @nodoc
class __$VoteCountsCopyWithImpl<$Res>
    implements _$VoteCountsCopyWith<$Res> {
  __$VoteCountsCopyWithImpl(this._self, this._then);

  final _VoteCounts _self;
  final $Res Function(_VoteCounts) _then;

/// Create a copy of VoteCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? votesA = null,Object? votesB = null,Object? totalVotes = null,}) {
  return _then(_VoteCounts(
votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
