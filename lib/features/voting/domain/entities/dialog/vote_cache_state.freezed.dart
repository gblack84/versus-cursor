// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_cache_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteCacheState {

/// 사용자의 투표 선택 (A 또는 B)
 String? get option;/// 투표한 시간
 DateTime? get timestamp;/// 투표 완료 여부
 bool get completed;
/// Create a copy of VoteCacheState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteCacheStateCopyWith<VoteCacheState> get copyWith => _$VoteCacheStateCopyWithImpl<VoteCacheState>(this as VoteCacheState, _$identity);

  /// Serializes this VoteCacheState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteCacheState&&(identical(other.option, option) || other.option == option)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,option,timestamp,completed);

@override
String toString() {
  return 'VoteCacheState(option: $option, timestamp: $timestamp, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $VoteCacheStateCopyWith<$Res>  {
  factory $VoteCacheStateCopyWith(VoteCacheState value, $Res Function(VoteCacheState) _then) = _$VoteCacheStateCopyWithImpl;
@useResult
$Res call({
 String? option, DateTime? timestamp, bool completed
});




}
/// @nodoc
class _$VoteCacheStateCopyWithImpl<$Res>
    implements $VoteCacheStateCopyWith<$Res> {
  _$VoteCacheStateCopyWithImpl(this._self, this._then);

  final VoteCacheState _self;
  final $Res Function(VoteCacheState) _then;

/// Create a copy of VoteCacheState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? option = freezed,Object? timestamp = freezed,Object? completed = null,}) {
  return _then(_self.copyWith(
option: freezed == option ? _self.option : option // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteCacheState].
extension VoteCacheStatePatterns on VoteCacheState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteCacheState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteCacheState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteCacheState value)  $default,){
final _that = this;
switch (_that) {
case _VoteCacheState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteCacheState value)?  $default,){
final _that = this;
switch (_that) {
case _VoteCacheState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? option,  DateTime? timestamp,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteCacheState() when $default != null:
return $default(_that.option,_that.timestamp,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? option,  DateTime? timestamp,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _VoteCacheState():
return $default(_that.option,_that.timestamp,_that.completed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? option,  DateTime? timestamp,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _VoteCacheState() when $default != null:
return $default(_that.option,_that.timestamp,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteCacheState extends VoteCacheState {
  const _VoteCacheState({this.option, this.timestamp, this.completed = false}): super._();
  factory _VoteCacheState.fromJson(Map<String, dynamic> json) => _$VoteCacheStateFromJson(json);

/// 사용자의 투표 선택 (A 또는 B)
@override final  String? option;
/// 투표한 시간
@override final  DateTime? timestamp;
/// 투표 완료 여부
@override@JsonKey() final  bool completed;

/// Create a copy of VoteCacheState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteCacheStateCopyWith<_VoteCacheState> get copyWith => __$VoteCacheStateCopyWithImpl<_VoteCacheState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteCacheStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteCacheState&&(identical(other.option, option) || other.option == option)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,option,timestamp,completed);

@override
String toString() {
  return 'VoteCacheState(option: $option, timestamp: $timestamp, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$VoteCacheStateCopyWith<$Res> implements $VoteCacheStateCopyWith<$Res> {
  factory _$VoteCacheStateCopyWith(_VoteCacheState value, $Res Function(_VoteCacheState) _then) = __$VoteCacheStateCopyWithImpl;
@override @useResult
$Res call({
 String? option, DateTime? timestamp, bool completed
});




}
/// @nodoc
class __$VoteCacheStateCopyWithImpl<$Res>
    implements _$VoteCacheStateCopyWith<$Res> {
  __$VoteCacheStateCopyWithImpl(this._self, this._then);

  final _VoteCacheState _self;
  final $Res Function(_VoteCacheState) _then;

/// Create a copy of VoteCacheState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? option = freezed,Object? timestamp = freezed,Object? completed = null,}) {
  return _then(_VoteCacheState(
option: freezed == option ? _self.option : option // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
