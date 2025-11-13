// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phonelogeinpincode_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhonelogeinpincodeState {

/// Phone verification status
 bool? get isVerified;/// Whether user can resend verification code
 bool get canResendCode;/// Resend attempt count
 int get canResendCount;/// Timer current milliseconds
 int get timerMilliseconds;/// Timer display value (formatted string)
 String get timerValue;
/// Create a copy of PhonelogeinpincodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhonelogeinpincodeStateCopyWith<PhonelogeinpincodeState> get copyWith => _$PhonelogeinpincodeStateCopyWithImpl<PhonelogeinpincodeState>(this as PhonelogeinpincodeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhonelogeinpincodeState&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.canResendCode, canResendCode) || other.canResendCode == canResendCode)&&(identical(other.canResendCount, canResendCount) || other.canResendCount == canResendCount)&&(identical(other.timerMilliseconds, timerMilliseconds) || other.timerMilliseconds == timerMilliseconds)&&(identical(other.timerValue, timerValue) || other.timerValue == timerValue));
}


@override
int get hashCode => Object.hash(runtimeType,isVerified,canResendCode,canResendCount,timerMilliseconds,timerValue);

@override
String toString() {
  return 'PhonelogeinpincodeState(isVerified: $isVerified, canResendCode: $canResendCode, canResendCount: $canResendCount, timerMilliseconds: $timerMilliseconds, timerValue: $timerValue)';
}


}

/// @nodoc
abstract mixin class $PhonelogeinpincodeStateCopyWith<$Res>  {
  factory $PhonelogeinpincodeStateCopyWith(PhonelogeinpincodeState value, $Res Function(PhonelogeinpincodeState) _then) = _$PhonelogeinpincodeStateCopyWithImpl;
@useResult
$Res call({
 bool? isVerified, bool canResendCode, int canResendCount, int timerMilliseconds, String timerValue
});




}
/// @nodoc
class _$PhonelogeinpincodeStateCopyWithImpl<$Res>
    implements $PhonelogeinpincodeStateCopyWith<$Res> {
  _$PhonelogeinpincodeStateCopyWithImpl(this._self, this._then);

  final PhonelogeinpincodeState _self;
  final $Res Function(PhonelogeinpincodeState) _then;

/// Create a copy of PhonelogeinpincodeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isVerified = freezed,Object? canResendCode = null,Object? canResendCount = null,Object? timerMilliseconds = null,Object? timerValue = null,}) {
  return _then(_self.copyWith(
isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,canResendCode: null == canResendCode ? _self.canResendCode : canResendCode // ignore: cast_nullable_to_non_nullable
as bool,canResendCount: null == canResendCount ? _self.canResendCount : canResendCount // ignore: cast_nullable_to_non_nullable
as int,timerMilliseconds: null == timerMilliseconds ? _self.timerMilliseconds : timerMilliseconds // ignore: cast_nullable_to_non_nullable
as int,timerValue: null == timerValue ? _self.timerValue : timerValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PhonelogeinpincodeState].
extension PhonelogeinpincodeStatePatterns on PhonelogeinpincodeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhonelogeinpincodeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhonelogeinpincodeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhonelogeinpincodeState value)  $default,){
final _that = this;
switch (_that) {
case _PhonelogeinpincodeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhonelogeinpincodeState value)?  $default,){
final _that = this;
switch (_that) {
case _PhonelogeinpincodeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? isVerified,  bool canResendCode,  int canResendCount,  int timerMilliseconds,  String timerValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhonelogeinpincodeState() when $default != null:
return $default(_that.isVerified,_that.canResendCode,_that.canResendCount,_that.timerMilliseconds,_that.timerValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? isVerified,  bool canResendCode,  int canResendCount,  int timerMilliseconds,  String timerValue)  $default,) {final _that = this;
switch (_that) {
case _PhonelogeinpincodeState():
return $default(_that.isVerified,_that.canResendCode,_that.canResendCount,_that.timerMilliseconds,_that.timerValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? isVerified,  bool canResendCode,  int canResendCount,  int timerMilliseconds,  String timerValue)?  $default,) {final _that = this;
switch (_that) {
case _PhonelogeinpincodeState() when $default != null:
return $default(_that.isVerified,_that.canResendCode,_that.canResendCount,_that.timerMilliseconds,_that.timerValue);case _:
  return null;

}
}

}

/// @nodoc


class _PhonelogeinpincodeState extends PhonelogeinpincodeState {
  const _PhonelogeinpincodeState({this.isVerified, this.canResendCode = false, this.canResendCount = 0, this.timerMilliseconds = 120000, this.timerValue = '02:00'}): super._();
  

/// Phone verification status
@override final  bool? isVerified;
/// Whether user can resend verification code
@override@JsonKey() final  bool canResendCode;
/// Resend attempt count
@override@JsonKey() final  int canResendCount;
/// Timer current milliseconds
@override@JsonKey() final  int timerMilliseconds;
/// Timer display value (formatted string)
@override@JsonKey() final  String timerValue;

/// Create a copy of PhonelogeinpincodeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhonelogeinpincodeStateCopyWith<_PhonelogeinpincodeState> get copyWith => __$PhonelogeinpincodeStateCopyWithImpl<_PhonelogeinpincodeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhonelogeinpincodeState&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.canResendCode, canResendCode) || other.canResendCode == canResendCode)&&(identical(other.canResendCount, canResendCount) || other.canResendCount == canResendCount)&&(identical(other.timerMilliseconds, timerMilliseconds) || other.timerMilliseconds == timerMilliseconds)&&(identical(other.timerValue, timerValue) || other.timerValue == timerValue));
}


@override
int get hashCode => Object.hash(runtimeType,isVerified,canResendCode,canResendCount,timerMilliseconds,timerValue);

@override
String toString() {
  return 'PhonelogeinpincodeState(isVerified: $isVerified, canResendCode: $canResendCode, canResendCount: $canResendCount, timerMilliseconds: $timerMilliseconds, timerValue: $timerValue)';
}


}

/// @nodoc
abstract mixin class _$PhonelogeinpincodeStateCopyWith<$Res> implements $PhonelogeinpincodeStateCopyWith<$Res> {
  factory _$PhonelogeinpincodeStateCopyWith(_PhonelogeinpincodeState value, $Res Function(_PhonelogeinpincodeState) _then) = __$PhonelogeinpincodeStateCopyWithImpl;
@override @useResult
$Res call({
 bool? isVerified, bool canResendCode, int canResendCount, int timerMilliseconds, String timerValue
});




}
/// @nodoc
class __$PhonelogeinpincodeStateCopyWithImpl<$Res>
    implements _$PhonelogeinpincodeStateCopyWith<$Res> {
  __$PhonelogeinpincodeStateCopyWithImpl(this._self, this._then);

  final _PhonelogeinpincodeState _self;
  final $Res Function(_PhonelogeinpincodeState) _then;

/// Create a copy of PhonelogeinpincodeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isVerified = freezed,Object? canResendCode = null,Object? canResendCount = null,Object? timerMilliseconds = null,Object? timerValue = null,}) {
  return _then(_PhonelogeinpincodeState(
isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,canResendCode: null == canResendCode ? _self.canResendCode : canResendCode // ignore: cast_nullable_to_non_nullable
as bool,canResendCount: null == canResendCount ? _self.canResendCount : canResendCount // ignore: cast_nullable_to_non_nullable
as int,timerMilliseconds: null == timerMilliseconds ? _self.timerMilliseconds : timerMilliseconds // ignore: cast_nullable_to_non_nullable
as int,timerValue: null == timerValue ? _self.timerValue : timerValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
