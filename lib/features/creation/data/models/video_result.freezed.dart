// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoResult {

 String get id; String get url; int get duration; String get params; String? get sourceVideoUrl; String? get thumbUrl; String? get ownerUid; String? get status; DateTime? get createdAt; String? get parentId;
/// Create a copy of VideoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoResultCopyWith<VideoResult> get copyWith => _$VideoResultCopyWithImpl<VideoResult>(this as VideoResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoResult&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.params, params) || other.params == params)&&(identical(other.sourceVideoUrl, sourceVideoUrl) || other.sourceVideoUrl == sourceVideoUrl)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,duration,params,sourceVideoUrl,thumbUrl,ownerUid,status,createdAt,parentId);

@override
String toString() {
  return 'VideoResult(id: $id, url: $url, duration: $duration, params: $params, sourceVideoUrl: $sourceVideoUrl, thumbUrl: $thumbUrl, ownerUid: $ownerUid, status: $status, createdAt: $createdAt, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $VideoResultCopyWith<$Res>  {
  factory $VideoResultCopyWith(VideoResult value, $Res Function(VideoResult) _then) = _$VideoResultCopyWithImpl;
@useResult
$Res call({
 String id, String url, int duration, String params, String? sourceVideoUrl, String? thumbUrl, String? ownerUid, String? status, DateTime? createdAt, String? parentId
});




}
/// @nodoc
class _$VideoResultCopyWithImpl<$Res>
    implements $VideoResultCopyWith<$Res> {
  _$VideoResultCopyWithImpl(this._self, this._then);

  final VideoResult _self;
  final $Res Function(VideoResult) _then;

/// Create a copy of VideoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? duration = null,Object? params = null,Object? sourceVideoUrl = freezed,Object? thumbUrl = freezed,Object? ownerUid = freezed,Object? status = freezed,Object? createdAt = freezed,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as String,sourceVideoUrl: freezed == sourceVideoUrl ? _self.sourceVideoUrl : sourceVideoUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,ownerUid: freezed == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoResult].
extension VideoResultPatterns on VideoResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoResult value)  $default,){
final _that = this;
switch (_that) {
case _VideoResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoResult value)?  $default,){
final _that = this;
switch (_that) {
case _VideoResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  int duration,  String params,  String? sourceVideoUrl,  String? thumbUrl,  String? ownerUid,  String? status,  DateTime? createdAt,  String? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoResult() when $default != null:
return $default(_that.id,_that.url,_that.duration,_that.params,_that.sourceVideoUrl,_that.thumbUrl,_that.ownerUid,_that.status,_that.createdAt,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  int duration,  String params,  String? sourceVideoUrl,  String? thumbUrl,  String? ownerUid,  String? status,  DateTime? createdAt,  String? parentId)  $default,) {final _that = this;
switch (_that) {
case _VideoResult():
return $default(_that.id,_that.url,_that.duration,_that.params,_that.sourceVideoUrl,_that.thumbUrl,_that.ownerUid,_that.status,_that.createdAt,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  int duration,  String params,  String? sourceVideoUrl,  String? thumbUrl,  String? ownerUid,  String? status,  DateTime? createdAt,  String? parentId)?  $default,) {final _that = this;
switch (_that) {
case _VideoResult() when $default != null:
return $default(_that.id,_that.url,_that.duration,_that.params,_that.sourceVideoUrl,_that.thumbUrl,_that.ownerUid,_that.status,_that.createdAt,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc


class _VideoResult implements VideoResult {
  const _VideoResult({required this.id, required this.url, required this.duration, required this.params, this.sourceVideoUrl, this.thumbUrl, this.ownerUid, this.status, this.createdAt, this.parentId});
  

@override final  String id;
@override final  String url;
@override final  int duration;
@override final  String params;
@override final  String? sourceVideoUrl;
@override final  String? thumbUrl;
@override final  String? ownerUid;
@override final  String? status;
@override final  DateTime? createdAt;
@override final  String? parentId;

/// Create a copy of VideoResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoResultCopyWith<_VideoResult> get copyWith => __$VideoResultCopyWithImpl<_VideoResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoResult&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.params, params) || other.params == params)&&(identical(other.sourceVideoUrl, sourceVideoUrl) || other.sourceVideoUrl == sourceVideoUrl)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,duration,params,sourceVideoUrl,thumbUrl,ownerUid,status,createdAt,parentId);

@override
String toString() {
  return 'VideoResult(id: $id, url: $url, duration: $duration, params: $params, sourceVideoUrl: $sourceVideoUrl, thumbUrl: $thumbUrl, ownerUid: $ownerUid, status: $status, createdAt: $createdAt, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$VideoResultCopyWith<$Res> implements $VideoResultCopyWith<$Res> {
  factory _$VideoResultCopyWith(_VideoResult value, $Res Function(_VideoResult) _then) = __$VideoResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, int duration, String params, String? sourceVideoUrl, String? thumbUrl, String? ownerUid, String? status, DateTime? createdAt, String? parentId
});




}
/// @nodoc
class __$VideoResultCopyWithImpl<$Res>
    implements _$VideoResultCopyWith<$Res> {
  __$VideoResultCopyWithImpl(this._self, this._then);

  final _VideoResult _self;
  final $Res Function(_VideoResult) _then;

/// Create a copy of VideoResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? duration = null,Object? params = null,Object? sourceVideoUrl = freezed,Object? thumbUrl = freezed,Object? ownerUid = freezed,Object? status = freezed,Object? createdAt = freezed,Object? parentId = freezed,}) {
  return _then(_VideoResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as String,sourceVideoUrl: freezed == sourceVideoUrl ? _self.sourceVideoUrl : sourceVideoUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,ownerUid: freezed == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
