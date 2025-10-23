// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'versus_box_size_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VersusBoxSizeData {

/// 레이아웃 타입 (가로/세로/단일 배치)
 LayoutType get layoutType;/// A 이미지 비율 (width/height)
 double? get aspectRatioA;/// B 이미지 비율 (width/height)
 double? get aspectRatioB;/// 질문 작성 시 A 박스 크기
@SizeConverter() Size get originalSizeA;/// 질문 작성 시 B 박스 크기 (B박스가 없으면 Size.zero)
@SizeConverter() Size get originalSizeB;/// 질문 작성 시 화면 너비
 double get screenWidth;/// 데이터 생성 시간
 DateTime get createdAt;/// A박스에 이미지가 있는지 여부
 bool get hasImageA;/// B박스에 이미지가 있는지 여부
 bool get hasImageB;
/// Create a copy of VersusBoxSizeData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersusBoxSizeDataCopyWith<VersusBoxSizeData> get copyWith => _$VersusBoxSizeDataCopyWithImpl<VersusBoxSizeData>(this as VersusBoxSizeData, _$identity);

  /// Serializes this VersusBoxSizeData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersusBoxSizeData&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.aspectRatioA, aspectRatioA) || other.aspectRatioA == aspectRatioA)&&(identical(other.aspectRatioB, aspectRatioB) || other.aspectRatioB == aspectRatioB)&&(identical(other.originalSizeA, originalSizeA) || other.originalSizeA == originalSizeA)&&(identical(other.originalSizeB, originalSizeB) || other.originalSizeB == originalSizeB)&&(identical(other.screenWidth, screenWidth) || other.screenWidth == screenWidth)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.hasImageA, hasImageA) || other.hasImageA == hasImageA)&&(identical(other.hasImageB, hasImageB) || other.hasImageB == hasImageB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layoutType,aspectRatioA,aspectRatioB,originalSizeA,originalSizeB,screenWidth,createdAt,hasImageA,hasImageB);

@override
String toString() {
  return 'VersusBoxSizeData(layoutType: $layoutType, aspectRatioA: $aspectRatioA, aspectRatioB: $aspectRatioB, originalSizeA: $originalSizeA, originalSizeB: $originalSizeB, screenWidth: $screenWidth, createdAt: $createdAt, hasImageA: $hasImageA, hasImageB: $hasImageB)';
}


}

/// @nodoc
abstract mixin class $VersusBoxSizeDataCopyWith<$Res>  {
  factory $VersusBoxSizeDataCopyWith(VersusBoxSizeData value, $Res Function(VersusBoxSizeData) _then) = _$VersusBoxSizeDataCopyWithImpl;
@useResult
$Res call({
 LayoutType layoutType, double? aspectRatioA, double? aspectRatioB,@SizeConverter() Size originalSizeA,@SizeConverter() Size originalSizeB, double screenWidth, DateTime createdAt, bool hasImageA, bool hasImageB
});




}
/// @nodoc
class _$VersusBoxSizeDataCopyWithImpl<$Res>
    implements $VersusBoxSizeDataCopyWith<$Res> {
  _$VersusBoxSizeDataCopyWithImpl(this._self, this._then);

  final VersusBoxSizeData _self;
  final $Res Function(VersusBoxSizeData) _then;

/// Create a copy of VersusBoxSizeData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layoutType = null,Object? aspectRatioA = freezed,Object? aspectRatioB = freezed,Object? originalSizeA = null,Object? originalSizeB = null,Object? screenWidth = null,Object? createdAt = null,Object? hasImageA = null,Object? hasImageB = null,}) {
  return _then(_self.copyWith(
layoutType: null == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as LayoutType,aspectRatioA: freezed == aspectRatioA ? _self.aspectRatioA : aspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,aspectRatioB: freezed == aspectRatioB ? _self.aspectRatioB : aspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,originalSizeA: null == originalSizeA ? _self.originalSizeA : originalSizeA // ignore: cast_nullable_to_non_nullable
as Size,originalSizeB: null == originalSizeB ? _self.originalSizeB : originalSizeB // ignore: cast_nullable_to_non_nullable
as Size,screenWidth: null == screenWidth ? _self.screenWidth : screenWidth // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasImageA: null == hasImageA ? _self.hasImageA : hasImageA // ignore: cast_nullable_to_non_nullable
as bool,hasImageB: null == hasImageB ? _self.hasImageB : hasImageB // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VersusBoxSizeData].
extension VersusBoxSizeDataPatterns on VersusBoxSizeData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersusBoxSizeData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersusBoxSizeData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersusBoxSizeData value)  $default,){
final _that = this;
switch (_that) {
case _VersusBoxSizeData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersusBoxSizeData value)?  $default,){
final _that = this;
switch (_that) {
case _VersusBoxSizeData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LayoutType layoutType,  double? aspectRatioA,  double? aspectRatioB, @SizeConverter()  Size originalSizeA, @SizeConverter()  Size originalSizeB,  double screenWidth,  DateTime createdAt,  bool hasImageA,  bool hasImageB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersusBoxSizeData() when $default != null:
return $default(_that.layoutType,_that.aspectRatioA,_that.aspectRatioB,_that.originalSizeA,_that.originalSizeB,_that.screenWidth,_that.createdAt,_that.hasImageA,_that.hasImageB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LayoutType layoutType,  double? aspectRatioA,  double? aspectRatioB, @SizeConverter()  Size originalSizeA, @SizeConverter()  Size originalSizeB,  double screenWidth,  DateTime createdAt,  bool hasImageA,  bool hasImageB)  $default,) {final _that = this;
switch (_that) {
case _VersusBoxSizeData():
return $default(_that.layoutType,_that.aspectRatioA,_that.aspectRatioB,_that.originalSizeA,_that.originalSizeB,_that.screenWidth,_that.createdAt,_that.hasImageA,_that.hasImageB);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LayoutType layoutType,  double? aspectRatioA,  double? aspectRatioB, @SizeConverter()  Size originalSizeA, @SizeConverter()  Size originalSizeB,  double screenWidth,  DateTime createdAt,  bool hasImageA,  bool hasImageB)?  $default,) {final _that = this;
switch (_that) {
case _VersusBoxSizeData() when $default != null:
return $default(_that.layoutType,_that.aspectRatioA,_that.aspectRatioB,_that.originalSizeA,_that.originalSizeB,_that.screenWidth,_that.createdAt,_that.hasImageA,_that.hasImageB);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VersusBoxSizeData extends VersusBoxSizeData {
  const _VersusBoxSizeData({required this.layoutType, this.aspectRatioA, this.aspectRatioB, @SizeConverter() required this.originalSizeA, @SizeConverter() required this.originalSizeB, required this.screenWidth, required this.createdAt, this.hasImageA = false, this.hasImageB = false}): super._();
  factory _VersusBoxSizeData.fromJson(Map<String, dynamic> json) => _$VersusBoxSizeDataFromJson(json);

/// 레이아웃 타입 (가로/세로/단일 배치)
@override final  LayoutType layoutType;
/// A 이미지 비율 (width/height)
@override final  double? aspectRatioA;
/// B 이미지 비율 (width/height)
@override final  double? aspectRatioB;
/// 질문 작성 시 A 박스 크기
@override@SizeConverter() final  Size originalSizeA;
/// 질문 작성 시 B 박스 크기 (B박스가 없으면 Size.zero)
@override@SizeConverter() final  Size originalSizeB;
/// 질문 작성 시 화면 너비
@override final  double screenWidth;
/// 데이터 생성 시간
@override final  DateTime createdAt;
/// A박스에 이미지가 있는지 여부
@override@JsonKey() final  bool hasImageA;
/// B박스에 이미지가 있는지 여부
@override@JsonKey() final  bool hasImageB;

/// Create a copy of VersusBoxSizeData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersusBoxSizeDataCopyWith<_VersusBoxSizeData> get copyWith => __$VersusBoxSizeDataCopyWithImpl<_VersusBoxSizeData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VersusBoxSizeDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersusBoxSizeData&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.aspectRatioA, aspectRatioA) || other.aspectRatioA == aspectRatioA)&&(identical(other.aspectRatioB, aspectRatioB) || other.aspectRatioB == aspectRatioB)&&(identical(other.originalSizeA, originalSizeA) || other.originalSizeA == originalSizeA)&&(identical(other.originalSizeB, originalSizeB) || other.originalSizeB == originalSizeB)&&(identical(other.screenWidth, screenWidth) || other.screenWidth == screenWidth)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.hasImageA, hasImageA) || other.hasImageA == hasImageA)&&(identical(other.hasImageB, hasImageB) || other.hasImageB == hasImageB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layoutType,aspectRatioA,aspectRatioB,originalSizeA,originalSizeB,screenWidth,createdAt,hasImageA,hasImageB);

@override
String toString() {
  return 'VersusBoxSizeData(layoutType: $layoutType, aspectRatioA: $aspectRatioA, aspectRatioB: $aspectRatioB, originalSizeA: $originalSizeA, originalSizeB: $originalSizeB, screenWidth: $screenWidth, createdAt: $createdAt, hasImageA: $hasImageA, hasImageB: $hasImageB)';
}


}

/// @nodoc
abstract mixin class _$VersusBoxSizeDataCopyWith<$Res> implements $VersusBoxSizeDataCopyWith<$Res> {
  factory _$VersusBoxSizeDataCopyWith(_VersusBoxSizeData value, $Res Function(_VersusBoxSizeData) _then) = __$VersusBoxSizeDataCopyWithImpl;
@override @useResult
$Res call({
 LayoutType layoutType, double? aspectRatioA, double? aspectRatioB,@SizeConverter() Size originalSizeA,@SizeConverter() Size originalSizeB, double screenWidth, DateTime createdAt, bool hasImageA, bool hasImageB
});




}
/// @nodoc
class __$VersusBoxSizeDataCopyWithImpl<$Res>
    implements _$VersusBoxSizeDataCopyWith<$Res> {
  __$VersusBoxSizeDataCopyWithImpl(this._self, this._then);

  final _VersusBoxSizeData _self;
  final $Res Function(_VersusBoxSizeData) _then;

/// Create a copy of VersusBoxSizeData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layoutType = null,Object? aspectRatioA = freezed,Object? aspectRatioB = freezed,Object? originalSizeA = null,Object? originalSizeB = null,Object? screenWidth = null,Object? createdAt = null,Object? hasImageA = null,Object? hasImageB = null,}) {
  return _then(_VersusBoxSizeData(
layoutType: null == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as LayoutType,aspectRatioA: freezed == aspectRatioA ? _self.aspectRatioA : aspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,aspectRatioB: freezed == aspectRatioB ? _self.aspectRatioB : aspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,originalSizeA: null == originalSizeA ? _self.originalSizeA : originalSizeA // ignore: cast_nullable_to_non_nullable
as Size,originalSizeB: null == originalSizeB ? _self.originalSizeB : originalSizeB // ignore: cast_nullable_to_non_nullable
as Size,screenWidth: null == screenWidth ? _self.screenWidth : screenWidth // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasImageA: null == hasImageA ? _self.hasImageA : hasImageA // ignore: cast_nullable_to_non_nullable
as bool,hasImageB: null == hasImageB ? _self.hasImageB : hasImageB // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
