// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'popup_timer_email_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PopupTimerEmailState {

/// Resend count (maximum 3 times)
 int get resendCount;/// Email verification status
 bool get isVerifiedEmail;/// Timer current milliseconds
 int get timerMilliseconds;/// Timer display value (formatted string)
 String get timerValue;
/// Create a copy of PopupTimerEmailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopupTimerEmailStateCopyWith<PopupTimerEmailState> get copyWith => _$PopupTimerEmailStateCopyWithImpl<PopupTimerEmailState>(this as PopupTimerEmailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopupTimerEmailState&&(identical(other.resendCount, resendCount) || other.resendCount == resendCount)&&(identical(other.isVerifiedEmail, isVerifiedEmail) || other.isVerifiedEmail == isVerifiedEmail)&&(identical(other.timerMilliseconds, timerMilliseconds) || other.timerMilliseconds == timerMilliseconds)&&(identical(other.timerValue, timerValue) || other.timerValue == timerValue));
}


@override
int get hashCode => Object.hash(runtimeType,resendCount,isVerifiedEmail,timerMilliseconds,timerValue);

@override
String toString() {
  return 'PopupTimerEmailState(resendCount: $resendCount, isVerifiedEmail: $isVerifiedEmail, timerMilliseconds: $timerMilliseconds, timerValue: $timerValue)';
}


}

/// @nodoc
abstract mixin class $PopupTimerEmailStateCopyWith<$Res>  {
  factory $PopupTimerEmailStateCopyWith(PopupTimerEmailState value, $Res Function(PopupTimerEmailState) _then) = _$PopupTimerEmailStateCopyWithImpl;
@useResult
$Res call({
 int resendCount, bool isVerifiedEmail, int timerMilliseconds, String timerValue
});




}
/// @nodoc
class _$PopupTimerEmailStateCopyWithImpl<$Res>
    implements $PopupTimerEmailStateCopyWith<$Res> {
  _$PopupTimerEmailStateCopyWithImpl(this._self, this._then);

  final PopupTimerEmailState _self;
  final $Res Function(PopupTimerEmailState) _then;

/// Create a copy of PopupTimerEmailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resendCount = null,Object? isVerifiedEmail = null,Object? timerMilliseconds = null,Object? timerValue = null,}) {
  return _then(_self.copyWith(
resendCount: null == resendCount ? _self.resendCount : resendCount // ignore: cast_nullable_to_non_nullable
as int,isVerifiedEmail: null == isVerifiedEmail ? _self.isVerifiedEmail : isVerifiedEmail // ignore: cast_nullable_to_non_nullable
as bool,timerMilliseconds: null == timerMilliseconds ? _self.timerMilliseconds : timerMilliseconds // ignore: cast_nullable_to_non_nullable
as int,timerValue: null == timerValue ? _self.timerValue : timerValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PopupTimerEmailState].
extension PopupTimerEmailStatePatterns on PopupTimerEmailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PopupTimerEmailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PopupTimerEmailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PopupTimerEmailState value)  $default,){
final _that = this;
switch (_that) {
case _PopupTimerEmailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PopupTimerEmailState value)?  $default,){
final _that = this;
switch (_that) {
case _PopupTimerEmailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int resendCount,  bool isVerifiedEmail,  int timerMilliseconds,  String timerValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PopupTimerEmailState() when $default != null:
return $default(_that.resendCount,_that.isVerifiedEmail,_that.timerMilliseconds,_that.timerValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int resendCount,  bool isVerifiedEmail,  int timerMilliseconds,  String timerValue)  $default,) {final _that = this;
switch (_that) {
case _PopupTimerEmailState():
return $default(_that.resendCount,_that.isVerifiedEmail,_that.timerMilliseconds,_that.timerValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int resendCount,  bool isVerifiedEmail,  int timerMilliseconds,  String timerValue)?  $default,) {final _that = this;
switch (_that) {
case _PopupTimerEmailState() when $default != null:
return $default(_that.resendCount,_that.isVerifiedEmail,_that.timerMilliseconds,_that.timerValue);case _:
  return null;

}
}

}

/// @nodoc


class _PopupTimerEmailState extends PopupTimerEmailState {
  const _PopupTimerEmailState({this.resendCount = 0, this.isVerifiedEmail = false, this.timerMilliseconds = 180000, this.timerValue = '03:00'}): super._();
  

/// Resend count (maximum 3 times)
@override@JsonKey() final  int resendCount;
/// Email verification status
@override@JsonKey() final  bool isVerifiedEmail;
/// Timer current milliseconds
@override@JsonKey() final  int timerMilliseconds;
/// Timer display value (formatted string)
@override@JsonKey() final  String timerValue;

/// Create a copy of PopupTimerEmailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PopupTimerEmailStateCopyWith<_PopupTimerEmailState> get copyWith => __$PopupTimerEmailStateCopyWithImpl<_PopupTimerEmailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PopupTimerEmailState&&(identical(other.resendCount, resendCount) || other.resendCount == resendCount)&&(identical(other.isVerifiedEmail, isVerifiedEmail) || other.isVerifiedEmail == isVerifiedEmail)&&(identical(other.timerMilliseconds, timerMilliseconds) || other.timerMilliseconds == timerMilliseconds)&&(identical(other.timerValue, timerValue) || other.timerValue == timerValue));
}


@override
int get hashCode => Object.hash(runtimeType,resendCount,isVerifiedEmail,timerMilliseconds,timerValue);

@override
String toString() {
  return 'PopupTimerEmailState(resendCount: $resendCount, isVerifiedEmail: $isVerifiedEmail, timerMilliseconds: $timerMilliseconds, timerValue: $timerValue)';
}


}

/// @nodoc
abstract mixin class _$PopupTimerEmailStateCopyWith<$Res> implements $PopupTimerEmailStateCopyWith<$Res> {
  factory _$PopupTimerEmailStateCopyWith(_PopupTimerEmailState value, $Res Function(_PopupTimerEmailState) _then) = __$PopupTimerEmailStateCopyWithImpl;
@override @useResult
$Res call({
 int resendCount, bool isVerifiedEmail, int timerMilliseconds, String timerValue
});




}
/// @nodoc
class __$PopupTimerEmailStateCopyWithImpl<$Res>
    implements _$PopupTimerEmailStateCopyWith<$Res> {
  __$PopupTimerEmailStateCopyWithImpl(this._self, this._then);

  final _PopupTimerEmailState _self;
  final $Res Function(_PopupTimerEmailState) _then;

/// Create a copy of PopupTimerEmailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resendCount = null,Object? isVerifiedEmail = null,Object? timerMilliseconds = null,Object? timerValue = null,}) {
  return _then(_PopupTimerEmailState(
resendCount: null == resendCount ? _self.resendCount : resendCount // ignore: cast_nullable_to_non_nullable
as int,isVerifiedEmail: null == isVerifiedEmail ? _self.isVerifiedEmail : isVerifiedEmail // ignore: cast_nullable_to_non_nullable
as bool,timerMilliseconds: null == timerMilliseconds ? _self.timerMilliseconds : timerMilliseconds // ignore: cast_nullable_to_non_nullable
as int,timerValue: null == timerValue ? _self.timerValue : timerValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
