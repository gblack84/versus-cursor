// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_notifiers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileUIState {

 bool get isLoading; String? get error;
/// Create a copy of ProfileUIState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUIStateCopyWith<ProfileUIState> get copyWith => _$ProfileUIStateCopyWithImpl<ProfileUIState>(this as ProfileUIState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUIState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,error);

@override
String toString() {
  return 'ProfileUIState(isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $ProfileUIStateCopyWith<$Res>  {
  factory $ProfileUIStateCopyWith(ProfileUIState value, $Res Function(ProfileUIState) _then) = _$ProfileUIStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? error
});




}
/// @nodoc
class _$ProfileUIStateCopyWithImpl<$Res>
    implements $ProfileUIStateCopyWith<$Res> {
  _$ProfileUIStateCopyWithImpl(this._self, this._then);

  final ProfileUIState _self;
  final $Res Function(ProfileUIState) _then;

/// Create a copy of ProfileUIState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileUIState].
extension ProfileUIStatePatterns on ProfileUIState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileUIState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileUIState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileUIState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileUIState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileUIState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileUIState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileUIState() when $default != null:
return $default(_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ProfileUIState():
return $default(_that.isLoading,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ProfileUIState() when $default != null:
return $default(_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileUIState implements ProfileUIState {
  const _ProfileUIState({this.isLoading = false, this.error});
  

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of ProfileUIState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileUIStateCopyWith<_ProfileUIState> get copyWith => __$ProfileUIStateCopyWithImpl<_ProfileUIState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileUIState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,error);

@override
String toString() {
  return 'ProfileUIState(isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ProfileUIStateCopyWith<$Res> implements $ProfileUIStateCopyWith<$Res> {
  factory _$ProfileUIStateCopyWith(_ProfileUIState value, $Res Function(_ProfileUIState) _then) = __$ProfileUIStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? error
});




}
/// @nodoc
class __$ProfileUIStateCopyWithImpl<$Res>
    implements _$ProfileUIStateCopyWith<$Res> {
  __$ProfileUIStateCopyWithImpl(this._self, this._then);

  final _ProfileUIState _self;
  final $Res Function(_ProfileUIState) _then;

/// Create a copy of ProfileUIState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? error = freezed,}) {
  return _then(_ProfileUIState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SettingsUIState {

 bool get isLoading; String? get error;
/// Create a copy of SettingsUIState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsUIStateCopyWith<SettingsUIState> get copyWith => _$SettingsUIStateCopyWithImpl<SettingsUIState>(this as SettingsUIState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsUIState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,error);

@override
String toString() {
  return 'SettingsUIState(isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $SettingsUIStateCopyWith<$Res>  {
  factory $SettingsUIStateCopyWith(SettingsUIState value, $Res Function(SettingsUIState) _then) = _$SettingsUIStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? error
});




}
/// @nodoc
class _$SettingsUIStateCopyWithImpl<$Res>
    implements $SettingsUIStateCopyWith<$Res> {
  _$SettingsUIStateCopyWithImpl(this._self, this._then);

  final SettingsUIState _self;
  final $Res Function(SettingsUIState) _then;

/// Create a copy of SettingsUIState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsUIState].
extension SettingsUIStatePatterns on SettingsUIState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsUIState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsUIState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsUIState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsUIState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsUIState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsUIState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsUIState() when $default != null:
return $default(_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _SettingsUIState():
return $default(_that.isLoading,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _SettingsUIState() when $default != null:
return $default(_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsUIState implements SettingsUIState {
  const _SettingsUIState({this.isLoading = false, this.error});
  

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of SettingsUIState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsUIStateCopyWith<_SettingsUIState> get copyWith => __$SettingsUIStateCopyWithImpl<_SettingsUIState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsUIState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,error);

@override
String toString() {
  return 'SettingsUIState(isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$SettingsUIStateCopyWith<$Res> implements $SettingsUIStateCopyWith<$Res> {
  factory _$SettingsUIStateCopyWith(_SettingsUIState value, $Res Function(_SettingsUIState) _then) = __$SettingsUIStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? error
});




}
/// @nodoc
class __$SettingsUIStateCopyWithImpl<$Res>
    implements _$SettingsUIStateCopyWith<$Res> {
  __$SettingsUIStateCopyWithImpl(this._self, this._then);

  final _SettingsUIState _self;
  final $Res Function(_SettingsUIState) _then;

/// Create a copy of SettingsUIState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? error = freezed,}) {
  return _then(_SettingsUIState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ImageUploadState {

 bool get isUploading; double get progress;// 0.0 to 1.0
 String? get error; String? get uploadedUrl;
/// Create a copy of ImageUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageUploadStateCopyWith<ImageUploadState> get copyWith => _$ImageUploadStateCopyWithImpl<ImageUploadState>(this as ImageUploadState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageUploadState&&(identical(other.isUploading, isUploading) || other.isUploading == isUploading)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error)&&(identical(other.uploadedUrl, uploadedUrl) || other.uploadedUrl == uploadedUrl));
}


@override
int get hashCode => Object.hash(runtimeType,isUploading,progress,error,uploadedUrl);

@override
String toString() {
  return 'ImageUploadState(isUploading: $isUploading, progress: $progress, error: $error, uploadedUrl: $uploadedUrl)';
}


}

/// @nodoc
abstract mixin class $ImageUploadStateCopyWith<$Res>  {
  factory $ImageUploadStateCopyWith(ImageUploadState value, $Res Function(ImageUploadState) _then) = _$ImageUploadStateCopyWithImpl;
@useResult
$Res call({
 bool isUploading, double progress, String? error, String? uploadedUrl
});




}
/// @nodoc
class _$ImageUploadStateCopyWithImpl<$Res>
    implements $ImageUploadStateCopyWith<$Res> {
  _$ImageUploadStateCopyWithImpl(this._self, this._then);

  final ImageUploadState _self;
  final $Res Function(ImageUploadState) _then;

/// Create a copy of ImageUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isUploading = null,Object? progress = null,Object? error = freezed,Object? uploadedUrl = freezed,}) {
  return _then(_self.copyWith(
isUploading: null == isUploading ? _self.isUploading : isUploading // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,uploadedUrl: freezed == uploadedUrl ? _self.uploadedUrl : uploadedUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageUploadState].
extension ImageUploadStatePatterns on ImageUploadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageUploadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageUploadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageUploadState value)  $default,){
final _that = this;
switch (_that) {
case _ImageUploadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageUploadState value)?  $default,){
final _that = this;
switch (_that) {
case _ImageUploadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isUploading,  double progress,  String? error,  String? uploadedUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageUploadState() when $default != null:
return $default(_that.isUploading,_that.progress,_that.error,_that.uploadedUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isUploading,  double progress,  String? error,  String? uploadedUrl)  $default,) {final _that = this;
switch (_that) {
case _ImageUploadState():
return $default(_that.isUploading,_that.progress,_that.error,_that.uploadedUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isUploading,  double progress,  String? error,  String? uploadedUrl)?  $default,) {final _that = this;
switch (_that) {
case _ImageUploadState() when $default != null:
return $default(_that.isUploading,_that.progress,_that.error,_that.uploadedUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ImageUploadState implements ImageUploadState {
  const _ImageUploadState({this.isUploading = false, this.progress = 0.0, this.error, this.uploadedUrl});
  

@override@JsonKey() final  bool isUploading;
@override@JsonKey() final  double progress;
// 0.0 to 1.0
@override final  String? error;
@override final  String? uploadedUrl;

/// Create a copy of ImageUploadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageUploadStateCopyWith<_ImageUploadState> get copyWith => __$ImageUploadStateCopyWithImpl<_ImageUploadState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageUploadState&&(identical(other.isUploading, isUploading) || other.isUploading == isUploading)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error)&&(identical(other.uploadedUrl, uploadedUrl) || other.uploadedUrl == uploadedUrl));
}


@override
int get hashCode => Object.hash(runtimeType,isUploading,progress,error,uploadedUrl);

@override
String toString() {
  return 'ImageUploadState(isUploading: $isUploading, progress: $progress, error: $error, uploadedUrl: $uploadedUrl)';
}


}

/// @nodoc
abstract mixin class _$ImageUploadStateCopyWith<$Res> implements $ImageUploadStateCopyWith<$Res> {
  factory _$ImageUploadStateCopyWith(_ImageUploadState value, $Res Function(_ImageUploadState) _then) = __$ImageUploadStateCopyWithImpl;
@override @useResult
$Res call({
 bool isUploading, double progress, String? error, String? uploadedUrl
});




}
/// @nodoc
class __$ImageUploadStateCopyWithImpl<$Res>
    implements _$ImageUploadStateCopyWith<$Res> {
  __$ImageUploadStateCopyWithImpl(this._self, this._then);

  final _ImageUploadState _self;
  final $Res Function(_ImageUploadState) _then;

/// Create a copy of ImageUploadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isUploading = null,Object? progress = null,Object? error = freezed,Object? uploadedUrl = freezed,}) {
  return _then(_ImageUploadState(
isUploading: null == isUploading ? _self.isUploading : isUploading // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,uploadedUrl: freezed == uploadedUrl ? _self.uploadedUrl : uploadedUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
