// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editviedo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditviedoState {

/// Uploaded video file
 AppUploadedFile? get uploadedVideo;/// Video start time in seconds
 double get startSec;/// Video end time in seconds
 double get endSec;/// Slider 1 value (start time slider)
 double? get sliderValue1;/// Slider 2 value (end time slider)
 double? get sliderValue2;
/// Create a copy of EditviedoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditviedoStateCopyWith<EditviedoState> get copyWith => _$EditviedoStateCopyWithImpl<EditviedoState>(this as EditviedoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditviedoState&&(identical(other.uploadedVideo, uploadedVideo) || other.uploadedVideo == uploadedVideo)&&(identical(other.startSec, startSec) || other.startSec == startSec)&&(identical(other.endSec, endSec) || other.endSec == endSec)&&(identical(other.sliderValue1, sliderValue1) || other.sliderValue1 == sliderValue1)&&(identical(other.sliderValue2, sliderValue2) || other.sliderValue2 == sliderValue2));
}


@override
int get hashCode => Object.hash(runtimeType,uploadedVideo,startSec,endSec,sliderValue1,sliderValue2);

@override
String toString() {
  return 'EditviedoState(uploadedVideo: $uploadedVideo, startSec: $startSec, endSec: $endSec, sliderValue1: $sliderValue1, sliderValue2: $sliderValue2)';
}


}

/// @nodoc
abstract mixin class $EditviedoStateCopyWith<$Res>  {
  factory $EditviedoStateCopyWith(EditviedoState value, $Res Function(EditviedoState) _then) = _$EditviedoStateCopyWithImpl;
@useResult
$Res call({
 AppUploadedFile? uploadedVideo, double startSec, double endSec, double? sliderValue1, double? sliderValue2
});




}
/// @nodoc
class _$EditviedoStateCopyWithImpl<$Res>
    implements $EditviedoStateCopyWith<$Res> {
  _$EditviedoStateCopyWithImpl(this._self, this._then);

  final EditviedoState _self;
  final $Res Function(EditviedoState) _then;

/// Create a copy of EditviedoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadedVideo = freezed,Object? startSec = null,Object? endSec = null,Object? sliderValue1 = freezed,Object? sliderValue2 = freezed,}) {
  return _then(_self.copyWith(
uploadedVideo: freezed == uploadedVideo ? _self.uploadedVideo : uploadedVideo // ignore: cast_nullable_to_non_nullable
as AppUploadedFile?,startSec: null == startSec ? _self.startSec : startSec // ignore: cast_nullable_to_non_nullable
as double,endSec: null == endSec ? _self.endSec : endSec // ignore: cast_nullable_to_non_nullable
as double,sliderValue1: freezed == sliderValue1 ? _self.sliderValue1 : sliderValue1 // ignore: cast_nullable_to_non_nullable
as double?,sliderValue2: freezed == sliderValue2 ? _self.sliderValue2 : sliderValue2 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [EditviedoState].
extension EditviedoStatePatterns on EditviedoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditviedoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditviedoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditviedoState value)  $default,){
final _that = this;
switch (_that) {
case _EditviedoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditviedoState value)?  $default,){
final _that = this;
switch (_that) {
case _EditviedoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppUploadedFile? uploadedVideo,  double startSec,  double endSec,  double? sliderValue1,  double? sliderValue2)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditviedoState() when $default != null:
return $default(_that.uploadedVideo,_that.startSec,_that.endSec,_that.sliderValue1,_that.sliderValue2);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppUploadedFile? uploadedVideo,  double startSec,  double endSec,  double? sliderValue1,  double? sliderValue2)  $default,) {final _that = this;
switch (_that) {
case _EditviedoState():
return $default(_that.uploadedVideo,_that.startSec,_that.endSec,_that.sliderValue1,_that.sliderValue2);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppUploadedFile? uploadedVideo,  double startSec,  double endSec,  double? sliderValue1,  double? sliderValue2)?  $default,) {final _that = this;
switch (_that) {
case _EditviedoState() when $default != null:
return $default(_that.uploadedVideo,_that.startSec,_that.endSec,_that.sliderValue1,_that.sliderValue2);case _:
  return null;

}
}

}

/// @nodoc


class _EditviedoState extends EditviedoState {
  const _EditviedoState({this.uploadedVideo, this.startSec = 0.0, this.endSec = 60.0, this.sliderValue1, this.sliderValue2}): super._();
  

/// Uploaded video file
@override final  AppUploadedFile? uploadedVideo;
/// Video start time in seconds
@override@JsonKey() final  double startSec;
/// Video end time in seconds
@override@JsonKey() final  double endSec;
/// Slider 1 value (start time slider)
@override final  double? sliderValue1;
/// Slider 2 value (end time slider)
@override final  double? sliderValue2;

/// Create a copy of EditviedoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditviedoStateCopyWith<_EditviedoState> get copyWith => __$EditviedoStateCopyWithImpl<_EditviedoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditviedoState&&(identical(other.uploadedVideo, uploadedVideo) || other.uploadedVideo == uploadedVideo)&&(identical(other.startSec, startSec) || other.startSec == startSec)&&(identical(other.endSec, endSec) || other.endSec == endSec)&&(identical(other.sliderValue1, sliderValue1) || other.sliderValue1 == sliderValue1)&&(identical(other.sliderValue2, sliderValue2) || other.sliderValue2 == sliderValue2));
}


@override
int get hashCode => Object.hash(runtimeType,uploadedVideo,startSec,endSec,sliderValue1,sliderValue2);

@override
String toString() {
  return 'EditviedoState(uploadedVideo: $uploadedVideo, startSec: $startSec, endSec: $endSec, sliderValue1: $sliderValue1, sliderValue2: $sliderValue2)';
}


}

/// @nodoc
abstract mixin class _$EditviedoStateCopyWith<$Res> implements $EditviedoStateCopyWith<$Res> {
  factory _$EditviedoStateCopyWith(_EditviedoState value, $Res Function(_EditviedoState) _then) = __$EditviedoStateCopyWithImpl;
@override @useResult
$Res call({
 AppUploadedFile? uploadedVideo, double startSec, double endSec, double? sliderValue1, double? sliderValue2
});




}
/// @nodoc
class __$EditviedoStateCopyWithImpl<$Res>
    implements _$EditviedoStateCopyWith<$Res> {
  __$EditviedoStateCopyWithImpl(this._self, this._then);

  final _EditviedoState _self;
  final $Res Function(_EditviedoState) _then;

/// Create a copy of EditviedoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadedVideo = freezed,Object? startSec = null,Object? endSec = null,Object? sliderValue1 = freezed,Object? sliderValue2 = freezed,}) {
  return _then(_EditviedoState(
uploadedVideo: freezed == uploadedVideo ? _self.uploadedVideo : uploadedVideo // ignore: cast_nullable_to_non_nullable
as AppUploadedFile?,startSec: null == startSec ? _self.startSec : startSec // ignore: cast_nullable_to_non_nullable
as double,endSec: null == endSec ? _self.endSec : endSec // ignore: cast_nullable_to_non_nullable
as double,sliderValue1: freezed == sliderValue1 ? _self.sliderValue1 : sliderValue1 // ignore: cast_nullable_to_non_nullable
as double?,sliderValue2: freezed == sliderValue2 ? _self.sliderValue2 : sliderValue2 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
