// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_images_usecase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadResult {

 List<String> get uploadedUrls; List<double> get aspectRatios; int get rejectedCount; Map<String, String> get rejectedReasons;
/// Create a copy of UploadResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadResultCopyWith<UploadResult> get copyWith => _$UploadResultCopyWithImpl<UploadResult>(this as UploadResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadResult&&const DeepCollectionEquality().equals(other.uploadedUrls, uploadedUrls)&&const DeepCollectionEquality().equals(other.aspectRatios, aspectRatios)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&const DeepCollectionEquality().equals(other.rejectedReasons, rejectedReasons));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(uploadedUrls),const DeepCollectionEquality().hash(aspectRatios),rejectedCount,const DeepCollectionEquality().hash(rejectedReasons));

@override
String toString() {
  return 'UploadResult(uploadedUrls: $uploadedUrls, aspectRatios: $aspectRatios, rejectedCount: $rejectedCount, rejectedReasons: $rejectedReasons)';
}


}

/// @nodoc
abstract mixin class $UploadResultCopyWith<$Res>  {
  factory $UploadResultCopyWith(UploadResult value, $Res Function(UploadResult) _then) = _$UploadResultCopyWithImpl;
@useResult
$Res call({
 List<String> uploadedUrls, List<double> aspectRatios, int rejectedCount, Map<String, String> rejectedReasons
});




}
/// @nodoc
class _$UploadResultCopyWithImpl<$Res>
    implements $UploadResultCopyWith<$Res> {
  _$UploadResultCopyWithImpl(this._self, this._then);

  final UploadResult _self;
  final $Res Function(UploadResult) _then;

/// Create a copy of UploadResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadedUrls = null,Object? aspectRatios = null,Object? rejectedCount = null,Object? rejectedReasons = null,}) {
  return _then(_self.copyWith(
uploadedUrls: null == uploadedUrls ? _self.uploadedUrls : uploadedUrls // ignore: cast_nullable_to_non_nullable
as List<String>,aspectRatios: null == aspectRatios ? _self.aspectRatios : aspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,rejectedReasons: null == rejectedReasons ? _self.rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadResult].
extension UploadResultPatterns on UploadResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadResult value)  $default,){
final _that = this;
switch (_that) {
case _UploadResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadResult value)?  $default,){
final _that = this;
switch (_that) {
case _UploadResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> uploadedUrls,  List<double> aspectRatios,  int rejectedCount,  Map<String, String> rejectedReasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadResult() when $default != null:
return $default(_that.uploadedUrls,_that.aspectRatios,_that.rejectedCount,_that.rejectedReasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> uploadedUrls,  List<double> aspectRatios,  int rejectedCount,  Map<String, String> rejectedReasons)  $default,) {final _that = this;
switch (_that) {
case _UploadResult():
return $default(_that.uploadedUrls,_that.aspectRatios,_that.rejectedCount,_that.rejectedReasons);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> uploadedUrls,  List<double> aspectRatios,  int rejectedCount,  Map<String, String> rejectedReasons)?  $default,) {final _that = this;
switch (_that) {
case _UploadResult() when $default != null:
return $default(_that.uploadedUrls,_that.aspectRatios,_that.rejectedCount,_that.rejectedReasons);case _:
  return null;

}
}

}

/// @nodoc


class _UploadResult extends UploadResult {
  const _UploadResult({required final  List<String> uploadedUrls, required final  List<double> aspectRatios, required this.rejectedCount, final  Map<String, String> rejectedReasons = const {}}): _uploadedUrls = uploadedUrls,_aspectRatios = aspectRatios,_rejectedReasons = rejectedReasons,super._();
  

 final  List<String> _uploadedUrls;
@override List<String> get uploadedUrls {
  if (_uploadedUrls is EqualUnmodifiableListView) return _uploadedUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadedUrls);
}

 final  List<double> _aspectRatios;
@override List<double> get aspectRatios {
  if (_aspectRatios is EqualUnmodifiableListView) return _aspectRatios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatios);
}

@override final  int rejectedCount;
 final  Map<String, String> _rejectedReasons;
@override@JsonKey() Map<String, String> get rejectedReasons {
  if (_rejectedReasons is EqualUnmodifiableMapView) return _rejectedReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rejectedReasons);
}


/// Create a copy of UploadResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadResultCopyWith<_UploadResult> get copyWith => __$UploadResultCopyWithImpl<_UploadResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadResult&&const DeepCollectionEquality().equals(other._uploadedUrls, _uploadedUrls)&&const DeepCollectionEquality().equals(other._aspectRatios, _aspectRatios)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&const DeepCollectionEquality().equals(other._rejectedReasons, _rejectedReasons));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_uploadedUrls),const DeepCollectionEquality().hash(_aspectRatios),rejectedCount,const DeepCollectionEquality().hash(_rejectedReasons));

@override
String toString() {
  return 'UploadResult(uploadedUrls: $uploadedUrls, aspectRatios: $aspectRatios, rejectedCount: $rejectedCount, rejectedReasons: $rejectedReasons)';
}


}

/// @nodoc
abstract mixin class _$UploadResultCopyWith<$Res> implements $UploadResultCopyWith<$Res> {
  factory _$UploadResultCopyWith(_UploadResult value, $Res Function(_UploadResult) _then) = __$UploadResultCopyWithImpl;
@override @useResult
$Res call({
 List<String> uploadedUrls, List<double> aspectRatios, int rejectedCount, Map<String, String> rejectedReasons
});




}
/// @nodoc
class __$UploadResultCopyWithImpl<$Res>
    implements _$UploadResultCopyWith<$Res> {
  __$UploadResultCopyWithImpl(this._self, this._then);

  final _UploadResult _self;
  final $Res Function(_UploadResult) _then;

/// Create a copy of UploadResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadedUrls = null,Object? aspectRatios = null,Object? rejectedCount = null,Object? rejectedReasons = null,}) {
  return _then(_UploadResult(
uploadedUrls: null == uploadedUrls ? _self._uploadedUrls : uploadedUrls // ignore: cast_nullable_to_non_nullable
as List<String>,aspectRatios: null == aspectRatios ? _self._aspectRatios : aspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,rejectedReasons: null == rejectedReasons ? _self._rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$SingleUploadResult {

 String get uploadedUrl; double get aspectRatio; String? get assetId;
/// Create a copy of SingleUploadResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SingleUploadResultCopyWith<SingleUploadResult> get copyWith => _$SingleUploadResultCopyWithImpl<SingleUploadResult>(this as SingleUploadResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SingleUploadResult&&(identical(other.uploadedUrl, uploadedUrl) || other.uploadedUrl == uploadedUrl)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.assetId, assetId) || other.assetId == assetId));
}


@override
int get hashCode => Object.hash(runtimeType,uploadedUrl,aspectRatio,assetId);

@override
String toString() {
  return 'SingleUploadResult(uploadedUrl: $uploadedUrl, aspectRatio: $aspectRatio, assetId: $assetId)';
}


}

/// @nodoc
abstract mixin class $SingleUploadResultCopyWith<$Res>  {
  factory $SingleUploadResultCopyWith(SingleUploadResult value, $Res Function(SingleUploadResult) _then) = _$SingleUploadResultCopyWithImpl;
@useResult
$Res call({
 String uploadedUrl, double aspectRatio, String? assetId
});




}
/// @nodoc
class _$SingleUploadResultCopyWithImpl<$Res>
    implements $SingleUploadResultCopyWith<$Res> {
  _$SingleUploadResultCopyWithImpl(this._self, this._then);

  final SingleUploadResult _self;
  final $Res Function(SingleUploadResult) _then;

/// Create a copy of SingleUploadResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadedUrl = null,Object? aspectRatio = null,Object? assetId = freezed,}) {
  return _then(_self.copyWith(
uploadedUrl: null == uploadedUrl ? _self.uploadedUrl : uploadedUrl // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SingleUploadResult].
extension SingleUploadResultPatterns on SingleUploadResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SingleUploadResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SingleUploadResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SingleUploadResult value)  $default,){
final _that = this;
switch (_that) {
case _SingleUploadResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SingleUploadResult value)?  $default,){
final _that = this;
switch (_that) {
case _SingleUploadResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uploadedUrl,  double aspectRatio,  String? assetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SingleUploadResult() when $default != null:
return $default(_that.uploadedUrl,_that.aspectRatio,_that.assetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uploadedUrl,  double aspectRatio,  String? assetId)  $default,) {final _that = this;
switch (_that) {
case _SingleUploadResult():
return $default(_that.uploadedUrl,_that.aspectRatio,_that.assetId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uploadedUrl,  double aspectRatio,  String? assetId)?  $default,) {final _that = this;
switch (_that) {
case _SingleUploadResult() when $default != null:
return $default(_that.uploadedUrl,_that.aspectRatio,_that.assetId);case _:
  return null;

}
}

}

/// @nodoc


class _SingleUploadResult extends SingleUploadResult {
  const _SingleUploadResult({required this.uploadedUrl, required this.aspectRatio, this.assetId}): super._();
  

@override final  String uploadedUrl;
@override final  double aspectRatio;
@override final  String? assetId;

/// Create a copy of SingleUploadResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SingleUploadResultCopyWith<_SingleUploadResult> get copyWith => __$SingleUploadResultCopyWithImpl<_SingleUploadResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SingleUploadResult&&(identical(other.uploadedUrl, uploadedUrl) || other.uploadedUrl == uploadedUrl)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.assetId, assetId) || other.assetId == assetId));
}


@override
int get hashCode => Object.hash(runtimeType,uploadedUrl,aspectRatio,assetId);

@override
String toString() {
  return 'SingleUploadResult(uploadedUrl: $uploadedUrl, aspectRatio: $aspectRatio, assetId: $assetId)';
}


}

/// @nodoc
abstract mixin class _$SingleUploadResultCopyWith<$Res> implements $SingleUploadResultCopyWith<$Res> {
  factory _$SingleUploadResultCopyWith(_SingleUploadResult value, $Res Function(_SingleUploadResult) _then) = __$SingleUploadResultCopyWithImpl;
@override @useResult
$Res call({
 String uploadedUrl, double aspectRatio, String? assetId
});




}
/// @nodoc
class __$SingleUploadResultCopyWithImpl<$Res>
    implements _$SingleUploadResultCopyWith<$Res> {
  __$SingleUploadResultCopyWithImpl(this._self, this._then);

  final _SingleUploadResult _self;
  final $Res Function(_SingleUploadResult) _then;

/// Create a copy of SingleUploadResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadedUrl = null,Object? aspectRatio = null,Object? assetId = freezed,}) {
  return _then(_SingleUploadResult(
uploadedUrl: null == uploadedUrl ? _self.uploadedUrl : uploadedUrl // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
