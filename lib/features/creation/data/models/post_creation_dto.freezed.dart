// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_creation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostCreationDto {

 String get userId; String get title; String get description; List<File> get imagesA; List<File> get imagesB; TargetAudience? get targetAudience; bool get isAnonymous;
/// Create a copy of PostCreationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCreationDtoCopyWith<PostCreationDto> get copyWith => _$PostCreationDtoCopyWithImpl<PostCreationDto>(this as PostCreationDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreationDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.imagesA, imagesA)&&const DeepCollectionEquality().equals(other.imagesB, imagesB)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}


@override
int get hashCode => Object.hash(runtimeType,userId,title,description,const DeepCollectionEquality().hash(imagesA),const DeepCollectionEquality().hash(imagesB),targetAudience,isAnonymous);

@override
String toString() {
  return 'PostCreationDto(userId: $userId, title: $title, description: $description, imagesA: $imagesA, imagesB: $imagesB, targetAudience: $targetAudience, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class $PostCreationDtoCopyWith<$Res>  {
  factory $PostCreationDtoCopyWith(PostCreationDto value, $Res Function(PostCreationDto) _then) = _$PostCreationDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String title, String description, List<File> imagesA, List<File> imagesB, TargetAudience? targetAudience, bool isAnonymous
});


$TargetAudienceCopyWith<$Res>? get targetAudience;

}
/// @nodoc
class _$PostCreationDtoCopyWithImpl<$Res>
    implements $PostCreationDtoCopyWith<$Res> {
  _$PostCreationDtoCopyWithImpl(this._self, this._then);

  final PostCreationDto _self;
  final $Res Function(PostCreationDto) _then;

/// Create a copy of PostCreationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? title = null,Object? description = null,Object? imagesA = null,Object? imagesB = null,Object? targetAudience = freezed,Object? isAnonymous = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imagesA: null == imagesA ? _self.imagesA : imagesA // ignore: cast_nullable_to_non_nullable
as List<File>,imagesB: null == imagesB ? _self.imagesB : imagesB // ignore: cast_nullable_to_non_nullable
as List<File>,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as TargetAudience?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PostCreationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<$Res>? get targetAudience {
    if (_self.targetAudience == null) {
    return null;
  }

  return $TargetAudienceCopyWith<$Res>(_self.targetAudience!, (value) {
    return _then(_self.copyWith(targetAudience: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostCreationDto].
extension PostCreationDtoPatterns on PostCreationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostCreationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostCreationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostCreationDto value)  $default,){
final _that = this;
switch (_that) {
case _PostCreationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostCreationDto value)?  $default,){
final _that = this;
switch (_that) {
case _PostCreationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String title,  String description,  List<File> imagesA,  List<File> imagesB,  TargetAudience? targetAudience,  bool isAnonymous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostCreationDto() when $default != null:
return $default(_that.userId,_that.title,_that.description,_that.imagesA,_that.imagesB,_that.targetAudience,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String title,  String description,  List<File> imagesA,  List<File> imagesB,  TargetAudience? targetAudience,  bool isAnonymous)  $default,) {final _that = this;
switch (_that) {
case _PostCreationDto():
return $default(_that.userId,_that.title,_that.description,_that.imagesA,_that.imagesB,_that.targetAudience,_that.isAnonymous);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String title,  String description,  List<File> imagesA,  List<File> imagesB,  TargetAudience? targetAudience,  bool isAnonymous)?  $default,) {final _that = this;
switch (_that) {
case _PostCreationDto() when $default != null:
return $default(_that.userId,_that.title,_that.description,_that.imagesA,_that.imagesB,_that.targetAudience,_that.isAnonymous);case _:
  return null;

}
}

}

/// @nodoc


class _PostCreationDto implements PostCreationDto {
  const _PostCreationDto({required this.userId, required this.title, required this.description, required final  List<File> imagesA, required final  List<File> imagesB, this.targetAudience, this.isAnonymous = false}): _imagesA = imagesA,_imagesB = imagesB;
  

@override final  String userId;
@override final  String title;
@override final  String description;
 final  List<File> _imagesA;
@override List<File> get imagesA {
  if (_imagesA is EqualUnmodifiableListView) return _imagesA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagesA);
}

 final  List<File> _imagesB;
@override List<File> get imagesB {
  if (_imagesB is EqualUnmodifiableListView) return _imagesB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagesB);
}

@override final  TargetAudience? targetAudience;
@override@JsonKey() final  bool isAnonymous;

/// Create a copy of PostCreationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCreationDtoCopyWith<_PostCreationDto> get copyWith => __$PostCreationDtoCopyWithImpl<_PostCreationDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostCreationDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._imagesA, _imagesA)&&const DeepCollectionEquality().equals(other._imagesB, _imagesB)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}


@override
int get hashCode => Object.hash(runtimeType,userId,title,description,const DeepCollectionEquality().hash(_imagesA),const DeepCollectionEquality().hash(_imagesB),targetAudience,isAnonymous);

@override
String toString() {
  return 'PostCreationDto(userId: $userId, title: $title, description: $description, imagesA: $imagesA, imagesB: $imagesB, targetAudience: $targetAudience, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class _$PostCreationDtoCopyWith<$Res> implements $PostCreationDtoCopyWith<$Res> {
  factory _$PostCreationDtoCopyWith(_PostCreationDto value, $Res Function(_PostCreationDto) _then) = __$PostCreationDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String title, String description, List<File> imagesA, List<File> imagesB, TargetAudience? targetAudience, bool isAnonymous
});


@override $TargetAudienceCopyWith<$Res>? get targetAudience;

}
/// @nodoc
class __$PostCreationDtoCopyWithImpl<$Res>
    implements _$PostCreationDtoCopyWith<$Res> {
  __$PostCreationDtoCopyWithImpl(this._self, this._then);

  final _PostCreationDto _self;
  final $Res Function(_PostCreationDto) _then;

/// Create a copy of PostCreationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? title = null,Object? description = null,Object? imagesA = null,Object? imagesB = null,Object? targetAudience = freezed,Object? isAnonymous = null,}) {
  return _then(_PostCreationDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imagesA: null == imagesA ? _self._imagesA : imagesA // ignore: cast_nullable_to_non_nullable
as List<File>,imagesB: null == imagesB ? _self._imagesB : imagesB // ignore: cast_nullable_to_non_nullable
as List<File>,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as TargetAudience?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PostCreationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<$Res>? get targetAudience {
    if (_self.targetAudience == null) {
    return null;
  }

  return $TargetAudienceCopyWith<$Res>(_self.targetAudience!, (value) {
    return _then(_self.copyWith(targetAudience: value));
  });
}
}

// dart format on
