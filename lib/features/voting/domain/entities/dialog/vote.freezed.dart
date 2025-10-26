// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vote {

/// 게시물 ID
 String get postId;/// 사용자 ID
 String get userId;/// 투표 선택 (A 또는 B)
 String get choice;/// 투표 시간
 DateTime? get timestamp;
/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteCopyWith<Vote> get copyWith => _$VoteCopyWithImpl<Vote>(this as Vote, _$identity);

  /// Serializes this Vote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vote&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.choice, choice) || other.choice == choice)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,userId,choice,timestamp);

@override
String toString() {
  return 'Vote(postId: $postId, userId: $userId, choice: $choice, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $VoteCopyWith<$Res>  {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) _then) = _$VoteCopyWithImpl;
@useResult
$Res call({
 String postId, String userId, String choice, DateTime? timestamp
});




}
/// @nodoc
class _$VoteCopyWithImpl<$Res>
    implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._self, this._then);

  final Vote _self;
  final $Res Function(Vote) _then;

/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? userId = null,Object? choice = null,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,choice: null == choice ? _self.choice : choice // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Vote].
extension VotePatterns on Vote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vote value)  $default,){
final _that = this;
switch (_that) {
case _Vote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vote value)?  $default,){
final _that = this;
switch (_that) {
case _Vote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  String userId,  String choice,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vote() when $default != null:
return $default(_that.postId,_that.userId,_that.choice,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  String userId,  String choice,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _Vote():
return $default(_that.postId,_that.userId,_that.choice,_that.timestamp);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  String userId,  String choice,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _Vote() when $default != null:
return $default(_that.postId,_that.userId,_that.choice,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vote extends Vote {
  const _Vote({required this.postId, required this.userId, required this.choice, this.timestamp}): super._();
  factory _Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);

/// 게시물 ID
@override final  String postId;
/// 사용자 ID
@override final  String userId;
/// 투표 선택 (A 또는 B)
@override final  String choice;
/// 투표 시간
@override final  DateTime? timestamp;

/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteCopyWith<_Vote> get copyWith => __$VoteCopyWithImpl<_Vote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vote&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.choice, choice) || other.choice == choice)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,userId,choice,timestamp);

@override
String toString() {
  return 'Vote(postId: $postId, userId: $userId, choice: $choice, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$VoteCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$VoteCopyWith(_Vote value, $Res Function(_Vote) _then) = __$VoteCopyWithImpl;
@override @useResult
$Res call({
 String postId, String userId, String choice, DateTime? timestamp
});




}
/// @nodoc
class __$VoteCopyWithImpl<$Res>
    implements _$VoteCopyWith<$Res> {
  __$VoteCopyWithImpl(this._self, this._then);

  final _Vote _self;
  final $Res Function(_Vote) _then;

/// Create a copy of Vote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? userId = null,Object? choice = null,Object? timestamp = freezed,}) {
  return _then(_Vote(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,choice: null == choice ? _self.choice : choice // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
