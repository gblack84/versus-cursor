// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_encoding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoEncoding {

 String get id; String get videoId; String get status; double get progress; DateTime? get createdAt; DateTime? get updatedAt; String? get outputUrl; String? get errorMessage;
/// Create a copy of VideoEncoding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoEncodingCopyWith<VideoEncoding> get copyWith => _$VideoEncodingCopyWithImpl<VideoEncoding>(this as VideoEncoding, _$identity);

  /// Serializes this VideoEncoding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoEncoding&&(identical(other.id, id) || other.id == id)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.outputUrl, outputUrl) || other.outputUrl == outputUrl)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,videoId,status,progress,createdAt,updatedAt,outputUrl,errorMessage);

@override
String toString() {
  return 'VideoEncoding(id: $id, videoId: $videoId, status: $status, progress: $progress, createdAt: $createdAt, updatedAt: $updatedAt, outputUrl: $outputUrl, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $VideoEncodingCopyWith<$Res>  {
  factory $VideoEncodingCopyWith(VideoEncoding value, $Res Function(VideoEncoding) _then) = _$VideoEncodingCopyWithImpl;
@useResult
$Res call({
 String id, String videoId, String status, double progress, DateTime? createdAt, DateTime? updatedAt, String? outputUrl, String? errorMessage
});




}
/// @nodoc
class _$VideoEncodingCopyWithImpl<$Res>
    implements $VideoEncodingCopyWith<$Res> {
  _$VideoEncodingCopyWithImpl(this._self, this._then);

  final VideoEncoding _self;
  final $Res Function(VideoEncoding) _then;

/// Create a copy of VideoEncoding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? videoId = null,Object? status = null,Object? progress = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? outputUrl = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outputUrl: freezed == outputUrl ? _self.outputUrl : outputUrl // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoEncoding].
extension VideoEncodingPatterns on VideoEncoding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoEncoding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoEncoding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoEncoding value)  $default,){
final _that = this;
switch (_that) {
case _VideoEncoding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoEncoding value)?  $default,){
final _that = this;
switch (_that) {
case _VideoEncoding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String videoId,  String status,  double progress,  DateTime? createdAt,  DateTime? updatedAt,  String? outputUrl,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoEncoding() when $default != null:
return $default(_that.id,_that.videoId,_that.status,_that.progress,_that.createdAt,_that.updatedAt,_that.outputUrl,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String videoId,  String status,  double progress,  DateTime? createdAt,  DateTime? updatedAt,  String? outputUrl,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _VideoEncoding():
return $default(_that.id,_that.videoId,_that.status,_that.progress,_that.createdAt,_that.updatedAt,_that.outputUrl,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String videoId,  String status,  double progress,  DateTime? createdAt,  DateTime? updatedAt,  String? outputUrl,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _VideoEncoding() when $default != null:
return $default(_that.id,_that.videoId,_that.status,_that.progress,_that.createdAt,_that.updatedAt,_that.outputUrl,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoEncoding extends VideoEncoding {
  const _VideoEncoding({required this.id, required this.videoId, required this.status, this.progress = 0.0, this.createdAt, this.updatedAt, this.outputUrl, this.errorMessage}): super._();
  factory _VideoEncoding.fromJson(Map<String, dynamic> json) => _$VideoEncodingFromJson(json);

@override final  String id;
@override final  String videoId;
@override final  String status;
@override@JsonKey() final  double progress;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? outputUrl;
@override final  String? errorMessage;

/// Create a copy of VideoEncoding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoEncodingCopyWith<_VideoEncoding> get copyWith => __$VideoEncodingCopyWithImpl<_VideoEncoding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoEncodingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoEncoding&&(identical(other.id, id) || other.id == id)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.outputUrl, outputUrl) || other.outputUrl == outputUrl)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,videoId,status,progress,createdAt,updatedAt,outputUrl,errorMessage);

@override
String toString() {
  return 'VideoEncoding(id: $id, videoId: $videoId, status: $status, progress: $progress, createdAt: $createdAt, updatedAt: $updatedAt, outputUrl: $outputUrl, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$VideoEncodingCopyWith<$Res> implements $VideoEncodingCopyWith<$Res> {
  factory _$VideoEncodingCopyWith(_VideoEncoding value, $Res Function(_VideoEncoding) _then) = __$VideoEncodingCopyWithImpl;
@override @useResult
$Res call({
 String id, String videoId, String status, double progress, DateTime? createdAt, DateTime? updatedAt, String? outputUrl, String? errorMessage
});




}
/// @nodoc
class __$VideoEncodingCopyWithImpl<$Res>
    implements _$VideoEncodingCopyWith<$Res> {
  __$VideoEncodingCopyWithImpl(this._self, this._then);

  final _VideoEncoding _self;
  final $Res Function(_VideoEncoding) _then;

/// Create a copy of VideoEncoding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? videoId = null,Object? status = null,Object? progress = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? outputUrl = freezed,Object? errorMessage = freezed,}) {
  return _then(_VideoEncoding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outputUrl: freezed == outputUrl ? _self.outputUrl : outputUrl // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
