// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaContent {

 String get text; List<String> get imageUrls; String get videoUrl; String get youtubeUrl; double? get aspectRatio;// Single aspect ratio (backward compatibility)
 List<double> get aspectRatios;// Multiple aspect ratios for multi-image support
 String get layoutType; String get thumbnailUrl; String get mediaType; int? get duration; int? get fileSize; Map<String, dynamic> get dimensions;
/// Create a copy of MediaContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaContentCopyWith<MediaContent> get copyWith => _$MediaContentCopyWithImpl<MediaContent>(this as MediaContent, _$identity);

  /// Serializes this MediaContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaContent&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&const DeepCollectionEquality().equals(other.aspectRatios, aspectRatios)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&const DeepCollectionEquality().equals(other.dimensions, dimensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(imageUrls),videoUrl,youtubeUrl,aspectRatio,const DeepCollectionEquality().hash(aspectRatios),layoutType,thumbnailUrl,mediaType,duration,fileSize,const DeepCollectionEquality().hash(dimensions));

@override
String toString() {
  return 'MediaContent(text: $text, imageUrls: $imageUrls, videoUrl: $videoUrl, youtubeUrl: $youtubeUrl, aspectRatio: $aspectRatio, aspectRatios: $aspectRatios, layoutType: $layoutType, thumbnailUrl: $thumbnailUrl, mediaType: $mediaType, duration: $duration, fileSize: $fileSize, dimensions: $dimensions)';
}


}

/// @nodoc
abstract mixin class $MediaContentCopyWith<$Res>  {
  factory $MediaContentCopyWith(MediaContent value, $Res Function(MediaContent) _then) = _$MediaContentCopyWithImpl;
@useResult
$Res call({
 String text, List<String> imageUrls, String videoUrl, String youtubeUrl, double? aspectRatio, List<double> aspectRatios, String layoutType, String thumbnailUrl, String mediaType, int? duration, int? fileSize, Map<String, dynamic> dimensions
});




}
/// @nodoc
class _$MediaContentCopyWithImpl<$Res>
    implements $MediaContentCopyWith<$Res> {
  _$MediaContentCopyWithImpl(this._self, this._then);

  final MediaContent _self;
  final $Res Function(MediaContent) _then;

/// Create a copy of MediaContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? imageUrls = null,Object? videoUrl = null,Object? youtubeUrl = null,Object? aspectRatio = freezed,Object? aspectRatios = null,Object? layoutType = null,Object? thumbnailUrl = null,Object? mediaType = null,Object? duration = freezed,Object? fileSize = freezed,Object? dimensions = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,aspectRatios: null == aspectRatios ? _self.aspectRatios : aspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>,layoutType: null == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,dimensions: null == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaContent].
extension MediaContentPatterns on MediaContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaContent value)  $default,){
final _that = this;
switch (_that) {
case _MediaContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaContent value)?  $default,){
final _that = this;
switch (_that) {
case _MediaContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<String> imageUrls,  String videoUrl,  String youtubeUrl,  double? aspectRatio,  List<double> aspectRatios,  String layoutType,  String thumbnailUrl,  String mediaType,  int? duration,  int? fileSize,  Map<String, dynamic> dimensions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaContent() when $default != null:
return $default(_that.text,_that.imageUrls,_that.videoUrl,_that.youtubeUrl,_that.aspectRatio,_that.aspectRatios,_that.layoutType,_that.thumbnailUrl,_that.mediaType,_that.duration,_that.fileSize,_that.dimensions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<String> imageUrls,  String videoUrl,  String youtubeUrl,  double? aspectRatio,  List<double> aspectRatios,  String layoutType,  String thumbnailUrl,  String mediaType,  int? duration,  int? fileSize,  Map<String, dynamic> dimensions)  $default,) {final _that = this;
switch (_that) {
case _MediaContent():
return $default(_that.text,_that.imageUrls,_that.videoUrl,_that.youtubeUrl,_that.aspectRatio,_that.aspectRatios,_that.layoutType,_that.thumbnailUrl,_that.mediaType,_that.duration,_that.fileSize,_that.dimensions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<String> imageUrls,  String videoUrl,  String youtubeUrl,  double? aspectRatio,  List<double> aspectRatios,  String layoutType,  String thumbnailUrl,  String mediaType,  int? duration,  int? fileSize,  Map<String, dynamic> dimensions)?  $default,) {final _that = this;
switch (_that) {
case _MediaContent() when $default != null:
return $default(_that.text,_that.imageUrls,_that.videoUrl,_that.youtubeUrl,_that.aspectRatio,_that.aspectRatios,_that.layoutType,_that.thumbnailUrl,_that.mediaType,_that.duration,_that.fileSize,_that.dimensions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaContent extends MediaContent {
  const _MediaContent({this.text = '', final  List<String> imageUrls = const [], this.videoUrl = '', this.youtubeUrl = '', this.aspectRatio, final  List<double> aspectRatios = const [], this.layoutType = '', this.thumbnailUrl = '', this.mediaType = 'text', this.duration, this.fileSize, final  Map<String, dynamic> dimensions = const {}}): _imageUrls = imageUrls,_aspectRatios = aspectRatios,_dimensions = dimensions,super._();
  factory _MediaContent.fromJson(Map<String, dynamic> json) => _$MediaContentFromJson(json);

@override@JsonKey() final  String text;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  String videoUrl;
@override@JsonKey() final  String youtubeUrl;
@override final  double? aspectRatio;
// Single aspect ratio (backward compatibility)
 final  List<double> _aspectRatios;
// Single aspect ratio (backward compatibility)
@override@JsonKey() List<double> get aspectRatios {
  if (_aspectRatios is EqualUnmodifiableListView) return _aspectRatios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatios);
}

// Multiple aspect ratios for multi-image support
@override@JsonKey() final  String layoutType;
@override@JsonKey() final  String thumbnailUrl;
@override@JsonKey() final  String mediaType;
@override final  int? duration;
@override final  int? fileSize;
 final  Map<String, dynamic> _dimensions;
@override@JsonKey() Map<String, dynamic> get dimensions {
  if (_dimensions is EqualUnmodifiableMapView) return _dimensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dimensions);
}


/// Create a copy of MediaContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaContentCopyWith<_MediaContent> get copyWith => __$MediaContentCopyWithImpl<_MediaContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaContent&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&const DeepCollectionEquality().equals(other._aspectRatios, _aspectRatios)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&const DeepCollectionEquality().equals(other._dimensions, _dimensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_imageUrls),videoUrl,youtubeUrl,aspectRatio,const DeepCollectionEquality().hash(_aspectRatios),layoutType,thumbnailUrl,mediaType,duration,fileSize,const DeepCollectionEquality().hash(_dimensions));

@override
String toString() {
  return 'MediaContent(text: $text, imageUrls: $imageUrls, videoUrl: $videoUrl, youtubeUrl: $youtubeUrl, aspectRatio: $aspectRatio, aspectRatios: $aspectRatios, layoutType: $layoutType, thumbnailUrl: $thumbnailUrl, mediaType: $mediaType, duration: $duration, fileSize: $fileSize, dimensions: $dimensions)';
}


}

/// @nodoc
abstract mixin class _$MediaContentCopyWith<$Res> implements $MediaContentCopyWith<$Res> {
  factory _$MediaContentCopyWith(_MediaContent value, $Res Function(_MediaContent) _then) = __$MediaContentCopyWithImpl;
@override @useResult
$Res call({
 String text, List<String> imageUrls, String videoUrl, String youtubeUrl, double? aspectRatio, List<double> aspectRatios, String layoutType, String thumbnailUrl, String mediaType, int? duration, int? fileSize, Map<String, dynamic> dimensions
});




}
/// @nodoc
class __$MediaContentCopyWithImpl<$Res>
    implements _$MediaContentCopyWith<$Res> {
  __$MediaContentCopyWithImpl(this._self, this._then);

  final _MediaContent _self;
  final $Res Function(_MediaContent) _then;

/// Create a copy of MediaContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? imageUrls = null,Object? videoUrl = null,Object? youtubeUrl = null,Object? aspectRatio = freezed,Object? aspectRatios = null,Object? layoutType = null,Object? thumbnailUrl = null,Object? mediaType = null,Object? duration = freezed,Object? fileSize = freezed,Object? dimensions = null,}) {
  return _then(_MediaContent(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,aspectRatios: null == aspectRatios ? _self._aspectRatios : aspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>,layoutType: null == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,dimensions: null == dimensions ? _self._dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
