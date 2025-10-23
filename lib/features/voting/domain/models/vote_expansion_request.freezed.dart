// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_expansion_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteExpansionRequest {

/// 요청한 사용자 ID (필수)
 String get userId;/// 사용한 포인트 (필수)
 int get pointsUsed;/// 추가로 요청한 사용자 수 (필수)
 int get additionalUserCount;/// 생성 시간 (nullable)
 DateTime? get createdAt;
/// Create a copy of VoteExpansionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteExpansionRequestCopyWith<VoteExpansionRequest> get copyWith => _$VoteExpansionRequestCopyWithImpl<VoteExpansionRequest>(this as VoteExpansionRequest, _$identity);

  /// Serializes this VoteExpansionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteExpansionRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pointsUsed, pointsUsed) || other.pointsUsed == pointsUsed)&&(identical(other.additionalUserCount, additionalUserCount) || other.additionalUserCount == additionalUserCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,pointsUsed,additionalUserCount,createdAt);

@override
String toString() {
  return 'VoteExpansionRequest(userId: $userId, pointsUsed: $pointsUsed, additionalUserCount: $additionalUserCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VoteExpansionRequestCopyWith<$Res>  {
  factory $VoteExpansionRequestCopyWith(VoteExpansionRequest value, $Res Function(VoteExpansionRequest) _then) = _$VoteExpansionRequestCopyWithImpl;
@useResult
$Res call({
 String userId, int pointsUsed, int additionalUserCount, DateTime? createdAt
});




}
/// @nodoc
class _$VoteExpansionRequestCopyWithImpl<$Res>
    implements $VoteExpansionRequestCopyWith<$Res> {
  _$VoteExpansionRequestCopyWithImpl(this._self, this._then);

  final VoteExpansionRequest _self;
  final $Res Function(VoteExpansionRequest) _then;

/// Create a copy of VoteExpansionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? pointsUsed = null,Object? additionalUserCount = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,additionalUserCount: null == additionalUserCount ? _self.additionalUserCount : additionalUserCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteExpansionRequest].
extension VoteExpansionRequestPatterns on VoteExpansionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteExpansionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteExpansionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteExpansionRequest value)  $default,){
final _that = this;
switch (_that) {
case _VoteExpansionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteExpansionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VoteExpansionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int pointsUsed,  int additionalUserCount,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteExpansionRequest() when $default != null:
return $default(_that.userId,_that.pointsUsed,_that.additionalUserCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int pointsUsed,  int additionalUserCount,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _VoteExpansionRequest():
return $default(_that.userId,_that.pointsUsed,_that.additionalUserCount,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int pointsUsed,  int additionalUserCount,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VoteExpansionRequest() when $default != null:
return $default(_that.userId,_that.pointsUsed,_that.additionalUserCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteExpansionRequest extends VoteExpansionRequest {
  const _VoteExpansionRequest({this.userId = '', this.pointsUsed = 0, this.additionalUserCount = 0, this.createdAt}): super._();
  factory _VoteExpansionRequest.fromJson(Map<String, dynamic> json) => _$VoteExpansionRequestFromJson(json);

/// 요청한 사용자 ID (필수)
@override@JsonKey() final  String userId;
/// 사용한 포인트 (필수)
@override@JsonKey() final  int pointsUsed;
/// 추가로 요청한 사용자 수 (필수)
@override@JsonKey() final  int additionalUserCount;
/// 생성 시간 (nullable)
@override final  DateTime? createdAt;

/// Create a copy of VoteExpansionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteExpansionRequestCopyWith<_VoteExpansionRequest> get copyWith => __$VoteExpansionRequestCopyWithImpl<_VoteExpansionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteExpansionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteExpansionRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pointsUsed, pointsUsed) || other.pointsUsed == pointsUsed)&&(identical(other.additionalUserCount, additionalUserCount) || other.additionalUserCount == additionalUserCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,pointsUsed,additionalUserCount,createdAt);

@override
String toString() {
  return 'VoteExpansionRequest(userId: $userId, pointsUsed: $pointsUsed, additionalUserCount: $additionalUserCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VoteExpansionRequestCopyWith<$Res> implements $VoteExpansionRequestCopyWith<$Res> {
  factory _$VoteExpansionRequestCopyWith(_VoteExpansionRequest value, $Res Function(_VoteExpansionRequest) _then) = __$VoteExpansionRequestCopyWithImpl;
@override @useResult
$Res call({
 String userId, int pointsUsed, int additionalUserCount, DateTime? createdAt
});




}
/// @nodoc
class __$VoteExpansionRequestCopyWithImpl<$Res>
    implements _$VoteExpansionRequestCopyWith<$Res> {
  __$VoteExpansionRequestCopyWithImpl(this._self, this._then);

  final _VoteExpansionRequest _self;
  final $Res Function(_VoteExpansionRequest) _then;

/// Create a copy of VoteExpansionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? pointsUsed = null,Object? additionalUserCount = null,Object? createdAt = freezed,}) {
  return _then(_VoteExpansionRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pointsUsed: null == pointsUsed ? _self.pointsUsed : pointsUsed // ignore: cast_nullable_to_non_nullable
as int,additionalUserCount: null == additionalUserCount ? _self.additionalUserCount : additionalUserCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
