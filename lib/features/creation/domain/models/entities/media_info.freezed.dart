// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
MediaInfo _$MediaInfoFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'image':
          return ImageInfo.fromJson(
            json
          );
                case 'video':
          return VideoInfo.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'MediaInfo',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$MediaInfo {

 String get id; String get url; String? get parentId; double? get aspectRatio; double? get width; double? get height; int? get size; String? get mimeType; DateTime? get createdAt; String? get thumbnailUrl; Map<String, dynamic>? get metadata;
/// Create a copy of MediaInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaInfoCopyWith<MediaInfo> get copyWith => _$MediaInfoCopyWithImpl<MediaInfo>(this as MediaInfo, _$identity);

  /// Serializes this MediaInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.size, size) || other.size == size)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,parentId,aspectRatio,width,height,size,mimeType,createdAt,thumbnailUrl,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'MediaInfo(id: $id, url: $url, parentId: $parentId, aspectRatio: $aspectRatio, width: $width, height: $height, size: $size, mimeType: $mimeType, createdAt: $createdAt, thumbnailUrl: $thumbnailUrl, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MediaInfoCopyWith<$Res>  {
  factory $MediaInfoCopyWith(MediaInfo value, $Res Function(MediaInfo) _then) = _$MediaInfoCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? parentId, double? aspectRatio, double? width, double? height, int? size, String? mimeType, DateTime? createdAt, String? thumbnailUrl, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$MediaInfoCopyWithImpl<$Res>
    implements $MediaInfoCopyWith<$Res> {
  _$MediaInfoCopyWithImpl(this._self, this._then);

  final MediaInfo _self;
  final $Res Function(MediaInfo) _then;

/// Create a copy of MediaInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? parentId = freezed,Object? aspectRatio = freezed,Object? width = freezed,Object? height = freezed,Object? size = freezed,Object? mimeType = freezed,Object? createdAt = freezed,Object? thumbnailUrl = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaInfo].
extension MediaInfoPatterns on MediaInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImageInfo value)?  image,TResult Function( VideoInfo value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImageInfo() when image != null:
return image(_that);case VideoInfo() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImageInfo value)  image,required TResult Function( VideoInfo value)  video,}){
final _that = this;
switch (_that) {
case ImageInfo():
return image(_that);case VideoInfo():
return video(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImageInfo value)?  image,TResult? Function( VideoInfo value)?  video,}){
final _that = this;
switch (_that) {
case ImageInfo() when image != null:
return image(_that);case VideoInfo() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String url,  String? parentId,  double? aspectRatio,  double? width,  double? height,  int? size,  String? mimeType,  DateTime? createdAt,  String? thumbnailUrl,  Map<String, dynamic>? metadata)?  image,TResult Function( String id,  String url,  String? parentId,  double? width,  double? height,  double? duration,  int? size,  String? mimeType,  DateTime? createdAt,  String? thumbnailUrl,  double? aspectRatio,  Map<String, dynamic>? metadata)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImageInfo() when image != null:
return image(_that.id,_that.url,_that.parentId,_that.aspectRatio,_that.width,_that.height,_that.size,_that.mimeType,_that.createdAt,_that.thumbnailUrl,_that.metadata);case VideoInfo() when video != null:
return video(_that.id,_that.url,_that.parentId,_that.width,_that.height,_that.duration,_that.size,_that.mimeType,_that.createdAt,_that.thumbnailUrl,_that.aspectRatio,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String url,  String? parentId,  double? aspectRatio,  double? width,  double? height,  int? size,  String? mimeType,  DateTime? createdAt,  String? thumbnailUrl,  Map<String, dynamic>? metadata)  image,required TResult Function( String id,  String url,  String? parentId,  double? width,  double? height,  double? duration,  int? size,  String? mimeType,  DateTime? createdAt,  String? thumbnailUrl,  double? aspectRatio,  Map<String, dynamic>? metadata)  video,}) {final _that = this;
switch (_that) {
case ImageInfo():
return image(_that.id,_that.url,_that.parentId,_that.aspectRatio,_that.width,_that.height,_that.size,_that.mimeType,_that.createdAt,_that.thumbnailUrl,_that.metadata);case VideoInfo():
return video(_that.id,_that.url,_that.parentId,_that.width,_that.height,_that.duration,_that.size,_that.mimeType,_that.createdAt,_that.thumbnailUrl,_that.aspectRatio,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String url,  String? parentId,  double? aspectRatio,  double? width,  double? height,  int? size,  String? mimeType,  DateTime? createdAt,  String? thumbnailUrl,  Map<String, dynamic>? metadata)?  image,TResult? Function( String id,  String url,  String? parentId,  double? width,  double? height,  double? duration,  int? size,  String? mimeType,  DateTime? createdAt,  String? thumbnailUrl,  double? aspectRatio,  Map<String, dynamic>? metadata)?  video,}) {final _that = this;
switch (_that) {
case ImageInfo() when image != null:
return image(_that.id,_that.url,_that.parentId,_that.aspectRatio,_that.width,_that.height,_that.size,_that.mimeType,_that.createdAt,_that.thumbnailUrl,_that.metadata);case VideoInfo() when video != null:
return video(_that.id,_that.url,_that.parentId,_that.width,_that.height,_that.duration,_that.size,_that.mimeType,_that.createdAt,_that.thumbnailUrl,_that.aspectRatio,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ImageInfo implements MediaInfo {
  const ImageInfo({required this.id, required this.url, this.parentId, this.aspectRatio, this.width, this.height, this.size, this.mimeType, this.createdAt, this.thumbnailUrl, final  Map<String, dynamic>? metadata, final  String? $type}): _metadata = metadata,$type = $type ?? 'image';
  factory ImageInfo.fromJson(Map<String, dynamic> json) => _$ImageInfoFromJson(json);

@override final  String id;
@override final  String url;
@override final  String? parentId;
@override final  double? aspectRatio;
@override final  double? width;
@override final  double? height;
@override final  int? size;
@override final  String? mimeType;
@override final  DateTime? createdAt;
@override final  String? thumbnailUrl;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of MediaInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageInfoCopyWith<ImageInfo> get copyWith => _$ImageInfoCopyWithImpl<ImageInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.size, size) || other.size == size)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,parentId,aspectRatio,width,height,size,mimeType,createdAt,thumbnailUrl,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'MediaInfo.image(id: $id, url: $url, parentId: $parentId, aspectRatio: $aspectRatio, width: $width, height: $height, size: $size, mimeType: $mimeType, createdAt: $createdAt, thumbnailUrl: $thumbnailUrl, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ImageInfoCopyWith<$Res> implements $MediaInfoCopyWith<$Res> {
  factory $ImageInfoCopyWith(ImageInfo value, $Res Function(ImageInfo) _then) = _$ImageInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? parentId, double? aspectRatio, double? width, double? height, int? size, String? mimeType, DateTime? createdAt, String? thumbnailUrl, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ImageInfoCopyWithImpl<$Res>
    implements $ImageInfoCopyWith<$Res> {
  _$ImageInfoCopyWithImpl(this._self, this._then);

  final ImageInfo _self;
  final $Res Function(ImageInfo) _then;

/// Create a copy of MediaInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? parentId = freezed,Object? aspectRatio = freezed,Object? width = freezed,Object? height = freezed,Object? size = freezed,Object? mimeType = freezed,Object? createdAt = freezed,Object? thumbnailUrl = freezed,Object? metadata = freezed,}) {
  return _then(ImageInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VideoInfo implements MediaInfo {
  const VideoInfo({required this.id, required this.url, this.parentId, this.width, this.height, this.duration, this.size, this.mimeType, this.createdAt, this.thumbnailUrl, this.aspectRatio, final  Map<String, dynamic>? metadata, final  String? $type}): _metadata = metadata,$type = $type ?? 'video';
  factory VideoInfo.fromJson(Map<String, dynamic> json) => _$VideoInfoFromJson(json);

@override final  String id;
@override final  String url;
@override final  String? parentId;
@override final  double? width;
@override final  double? height;
 final  double? duration;
@override final  int? size;
@override final  String? mimeType;
@override final  DateTime? createdAt;
@override final  String? thumbnailUrl;
@override final  double? aspectRatio;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of MediaInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoInfoCopyWith<VideoInfo> get copyWith => _$VideoInfoCopyWithImpl<VideoInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.size, size) || other.size == size)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,parentId,width,height,duration,size,mimeType,createdAt,thumbnailUrl,aspectRatio,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'MediaInfo.video(id: $id, url: $url, parentId: $parentId, width: $width, height: $height, duration: $duration, size: $size, mimeType: $mimeType, createdAt: $createdAt, thumbnailUrl: $thumbnailUrl, aspectRatio: $aspectRatio, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $VideoInfoCopyWith<$Res> implements $MediaInfoCopyWith<$Res> {
  factory $VideoInfoCopyWith(VideoInfo value, $Res Function(VideoInfo) _then) = _$VideoInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? parentId, double? width, double? height, double? duration, int? size, String? mimeType, DateTime? createdAt, String? thumbnailUrl, double? aspectRatio, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$VideoInfoCopyWithImpl<$Res>
    implements $VideoInfoCopyWith<$Res> {
  _$VideoInfoCopyWithImpl(this._self, this._then);

  final VideoInfo _self;
  final $Res Function(VideoInfo) _then;

/// Create a copy of MediaInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? parentId = freezed,Object? width = freezed,Object? height = freezed,Object? duration = freezed,Object? size = freezed,Object? mimeType = freezed,Object? createdAt = freezed,Object? thumbnailUrl = freezed,Object? aspectRatio = freezed,Object? metadata = freezed,}) {
  return _then(VideoInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
