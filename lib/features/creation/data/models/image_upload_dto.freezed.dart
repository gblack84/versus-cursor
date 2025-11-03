// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_upload_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageUploadDto {

 List<File> get images; String get box;// 'A' or 'B' to identify which option
 String get userId;
/// Create a copy of ImageUploadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageUploadDtoCopyWith<ImageUploadDto> get copyWith => _$ImageUploadDtoCopyWithImpl<ImageUploadDto>(this as ImageUploadDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageUploadDto&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.box, box) || other.box == box)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(images),box,userId);

@override
String toString() {
  return 'ImageUploadDto(images: $images, box: $box, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $ImageUploadDtoCopyWith<$Res>  {
  factory $ImageUploadDtoCopyWith(ImageUploadDto value, $Res Function(ImageUploadDto) _then) = _$ImageUploadDtoCopyWithImpl;
@useResult
$Res call({
 List<File> images, String box, String userId
});




}
/// @nodoc
class _$ImageUploadDtoCopyWithImpl<$Res>
    implements $ImageUploadDtoCopyWith<$Res> {
  _$ImageUploadDtoCopyWithImpl(this._self, this._then);

  final ImageUploadDto _self;
  final $Res Function(ImageUploadDto) _then;

/// Create a copy of ImageUploadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? images = null,Object? box = null,Object? userId = null,}) {
  return _then(_self.copyWith(
images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<File>,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageUploadDto].
extension ImageUploadDtoPatterns on ImageUploadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageUploadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageUploadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageUploadDto value)  $default,){
final _that = this;
switch (_that) {
case _ImageUploadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageUploadDto value)?  $default,){
final _that = this;
switch (_that) {
case _ImageUploadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<File> images,  String box,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageUploadDto() when $default != null:
return $default(_that.images,_that.box,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<File> images,  String box,  String userId)  $default,) {final _that = this;
switch (_that) {
case _ImageUploadDto():
return $default(_that.images,_that.box,_that.userId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<File> images,  String box,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _ImageUploadDto() when $default != null:
return $default(_that.images,_that.box,_that.userId);case _:
  return null;

}
}

}

/// @nodoc


class _ImageUploadDto implements ImageUploadDto {
  const _ImageUploadDto({required final  List<File> images, required this.box, required this.userId}): _images = images;
  

 final  List<File> _images;
@override List<File> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String box;
// 'A' or 'B' to identify which option
@override final  String userId;

/// Create a copy of ImageUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageUploadDtoCopyWith<_ImageUploadDto> get copyWith => __$ImageUploadDtoCopyWithImpl<_ImageUploadDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageUploadDto&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.box, box) || other.box == box)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_images),box,userId);

@override
String toString() {
  return 'ImageUploadDto(images: $images, box: $box, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$ImageUploadDtoCopyWith<$Res> implements $ImageUploadDtoCopyWith<$Res> {
  factory _$ImageUploadDtoCopyWith(_ImageUploadDto value, $Res Function(_ImageUploadDto) _then) = __$ImageUploadDtoCopyWithImpl;
@override @useResult
$Res call({
 List<File> images, String box, String userId
});




}
/// @nodoc
class __$ImageUploadDtoCopyWithImpl<$Res>
    implements _$ImageUploadDtoCopyWith<$Res> {
  __$ImageUploadDtoCopyWithImpl(this._self, this._then);

  final _ImageUploadDto _self;
  final $Res Function(_ImageUploadDto) _then;

/// Create a copy of ImageUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? images = null,Object? box = null,Object? userId = null,}) {
  return _then(_ImageUploadDto(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<File>,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
