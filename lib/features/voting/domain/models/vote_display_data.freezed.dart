// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_display_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteDisplayData {

 String get question; String get optionA; String get optionB; String? get imageUrlA; String? get imageUrlB; List<String>? get imageUrlsA; List<String>? get imageUrlsB; String get description; double? get aspectRatioA; double? get aspectRatioB; String? get layoutType; String? get authorName;
/// Create a copy of VoteDisplayData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteDisplayDataCopyWith<VoteDisplayData> get copyWith => _$VoteDisplayDataCopyWithImpl<VoteDisplayData>(this as VoteDisplayData, _$identity);

  /// Serializes this VoteDisplayData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteDisplayData&&(identical(other.question, question) || other.question == question)&&(identical(other.optionA, optionA) || other.optionA == optionA)&&(identical(other.optionB, optionB) || other.optionB == optionB)&&(identical(other.imageUrlA, imageUrlA) || other.imageUrlA == imageUrlA)&&(identical(other.imageUrlB, imageUrlB) || other.imageUrlB == imageUrlB)&&const DeepCollectionEquality().equals(other.imageUrlsA, imageUrlsA)&&const DeepCollectionEquality().equals(other.imageUrlsB, imageUrlsB)&&(identical(other.description, description) || other.description == description)&&(identical(other.aspectRatioA, aspectRatioA) || other.aspectRatioA == aspectRatioA)&&(identical(other.aspectRatioB, aspectRatioB) || other.aspectRatioB == aspectRatioB)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,optionA,optionB,imageUrlA,imageUrlB,const DeepCollectionEquality().hash(imageUrlsA),const DeepCollectionEquality().hash(imageUrlsB),description,aspectRatioA,aspectRatioB,layoutType,authorName);

@override
String toString() {
  return 'VoteDisplayData(question: $question, optionA: $optionA, optionB: $optionB, imageUrlA: $imageUrlA, imageUrlB: $imageUrlB, imageUrlsA: $imageUrlsA, imageUrlsB: $imageUrlsB, description: $description, aspectRatioA: $aspectRatioA, aspectRatioB: $aspectRatioB, layoutType: $layoutType, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class $VoteDisplayDataCopyWith<$Res>  {
  factory $VoteDisplayDataCopyWith(VoteDisplayData value, $Res Function(VoteDisplayData) _then) = _$VoteDisplayDataCopyWithImpl;
@useResult
$Res call({
 String question, String optionA, String optionB, String? imageUrlA, String? imageUrlB, List<String>? imageUrlsA, List<String>? imageUrlsB, String description, double? aspectRatioA, double? aspectRatioB, String? layoutType, String? authorName
});




}
/// @nodoc
class _$VoteDisplayDataCopyWithImpl<$Res>
    implements $VoteDisplayDataCopyWith<$Res> {
  _$VoteDisplayDataCopyWithImpl(this._self, this._then);

  final VoteDisplayData _self;
  final $Res Function(VoteDisplayData) _then;

/// Create a copy of VoteDisplayData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? optionA = null,Object? optionB = null,Object? imageUrlA = freezed,Object? imageUrlB = freezed,Object? imageUrlsA = freezed,Object? imageUrlsB = freezed,Object? description = null,Object? aspectRatioA = freezed,Object? aspectRatioB = freezed,Object? layoutType = freezed,Object? authorName = freezed,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,optionA: null == optionA ? _self.optionA : optionA // ignore: cast_nullable_to_non_nullable
as String,optionB: null == optionB ? _self.optionB : optionB // ignore: cast_nullable_to_non_nullable
as String,imageUrlA: freezed == imageUrlA ? _self.imageUrlA : imageUrlA // ignore: cast_nullable_to_non_nullable
as String?,imageUrlB: freezed == imageUrlB ? _self.imageUrlB : imageUrlB // ignore: cast_nullable_to_non_nullable
as String?,imageUrlsA: freezed == imageUrlsA ? _self.imageUrlsA : imageUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrlsB: freezed == imageUrlsB ? _self.imageUrlsB : imageUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,aspectRatioA: freezed == aspectRatioA ? _self.aspectRatioA : aspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,aspectRatioB: freezed == aspectRatioB ? _self.aspectRatioB : aspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,layoutType: freezed == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteDisplayData].
extension VoteDisplayDataPatterns on VoteDisplayData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteDisplayData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteDisplayData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteDisplayData value)  $default,){
final _that = this;
switch (_that) {
case _VoteDisplayData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteDisplayData value)?  $default,){
final _that = this;
switch (_that) {
case _VoteDisplayData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String question,  String optionA,  String optionB,  String? imageUrlA,  String? imageUrlB,  List<String>? imageUrlsA,  List<String>? imageUrlsB,  String description,  double? aspectRatioA,  double? aspectRatioB,  String? layoutType,  String? authorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteDisplayData() when $default != null:
return $default(_that.question,_that.optionA,_that.optionB,_that.imageUrlA,_that.imageUrlB,_that.imageUrlsA,_that.imageUrlsB,_that.description,_that.aspectRatioA,_that.aspectRatioB,_that.layoutType,_that.authorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String question,  String optionA,  String optionB,  String? imageUrlA,  String? imageUrlB,  List<String>? imageUrlsA,  List<String>? imageUrlsB,  String description,  double? aspectRatioA,  double? aspectRatioB,  String? layoutType,  String? authorName)  $default,) {final _that = this;
switch (_that) {
case _VoteDisplayData():
return $default(_that.question,_that.optionA,_that.optionB,_that.imageUrlA,_that.imageUrlB,_that.imageUrlsA,_that.imageUrlsB,_that.description,_that.aspectRatioA,_that.aspectRatioB,_that.layoutType,_that.authorName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String question,  String optionA,  String optionB,  String? imageUrlA,  String? imageUrlB,  List<String>? imageUrlsA,  List<String>? imageUrlsB,  String description,  double? aspectRatioA,  double? aspectRatioB,  String? layoutType,  String? authorName)?  $default,) {final _that = this;
switch (_that) {
case _VoteDisplayData() when $default != null:
return $default(_that.question,_that.optionA,_that.optionB,_that.imageUrlA,_that.imageUrlB,_that.imageUrlsA,_that.imageUrlsB,_that.description,_that.aspectRatioA,_that.aspectRatioB,_that.layoutType,_that.authorName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteDisplayData extends VoteDisplayData {
  const _VoteDisplayData({required this.question, required this.optionA, required this.optionB, this.imageUrlA, this.imageUrlB, final  List<String>? imageUrlsA, final  List<String>? imageUrlsB, this.description = '', this.aspectRatioA, this.aspectRatioB, this.layoutType, this.authorName}): _imageUrlsA = imageUrlsA,_imageUrlsB = imageUrlsB,super._();
  factory _VoteDisplayData.fromJson(Map<String, dynamic> json) => _$VoteDisplayDataFromJson(json);

@override final  String question;
@override final  String optionA;
@override final  String optionB;
@override final  String? imageUrlA;
@override final  String? imageUrlB;
 final  List<String>? _imageUrlsA;
@override List<String>? get imageUrlsA {
  final value = _imageUrlsA;
  if (value == null) return null;
  if (_imageUrlsA is EqualUnmodifiableListView) return _imageUrlsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _imageUrlsB;
@override List<String>? get imageUrlsB {
  final value = _imageUrlsB;
  if (value == null) return null;
  if (_imageUrlsB is EqualUnmodifiableListView) return _imageUrlsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  String description;
@override final  double? aspectRatioA;
@override final  double? aspectRatioB;
@override final  String? layoutType;
@override final  String? authorName;

/// Create a copy of VoteDisplayData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteDisplayDataCopyWith<_VoteDisplayData> get copyWith => __$VoteDisplayDataCopyWithImpl<_VoteDisplayData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteDisplayDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteDisplayData&&(identical(other.question, question) || other.question == question)&&(identical(other.optionA, optionA) || other.optionA == optionA)&&(identical(other.optionB, optionB) || other.optionB == optionB)&&(identical(other.imageUrlA, imageUrlA) || other.imageUrlA == imageUrlA)&&(identical(other.imageUrlB, imageUrlB) || other.imageUrlB == imageUrlB)&&const DeepCollectionEquality().equals(other._imageUrlsA, _imageUrlsA)&&const DeepCollectionEquality().equals(other._imageUrlsB, _imageUrlsB)&&(identical(other.description, description) || other.description == description)&&(identical(other.aspectRatioA, aspectRatioA) || other.aspectRatioA == aspectRatioA)&&(identical(other.aspectRatioB, aspectRatioB) || other.aspectRatioB == aspectRatioB)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,optionA,optionB,imageUrlA,imageUrlB,const DeepCollectionEquality().hash(_imageUrlsA),const DeepCollectionEquality().hash(_imageUrlsB),description,aspectRatioA,aspectRatioB,layoutType,authorName);

@override
String toString() {
  return 'VoteDisplayData(question: $question, optionA: $optionA, optionB: $optionB, imageUrlA: $imageUrlA, imageUrlB: $imageUrlB, imageUrlsA: $imageUrlsA, imageUrlsB: $imageUrlsB, description: $description, aspectRatioA: $aspectRatioA, aspectRatioB: $aspectRatioB, layoutType: $layoutType, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class _$VoteDisplayDataCopyWith<$Res> implements $VoteDisplayDataCopyWith<$Res> {
  factory _$VoteDisplayDataCopyWith(_VoteDisplayData value, $Res Function(_VoteDisplayData) _then) = __$VoteDisplayDataCopyWithImpl;
@override @useResult
$Res call({
 String question, String optionA, String optionB, String? imageUrlA, String? imageUrlB, List<String>? imageUrlsA, List<String>? imageUrlsB, String description, double? aspectRatioA, double? aspectRatioB, String? layoutType, String? authorName
});




}
/// @nodoc
class __$VoteDisplayDataCopyWithImpl<$Res>
    implements _$VoteDisplayDataCopyWith<$Res> {
  __$VoteDisplayDataCopyWithImpl(this._self, this._then);

  final _VoteDisplayData _self;
  final $Res Function(_VoteDisplayData) _then;

/// Create a copy of VoteDisplayData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? optionA = null,Object? optionB = null,Object? imageUrlA = freezed,Object? imageUrlB = freezed,Object? imageUrlsA = freezed,Object? imageUrlsB = freezed,Object? description = null,Object? aspectRatioA = freezed,Object? aspectRatioB = freezed,Object? layoutType = freezed,Object? authorName = freezed,}) {
  return _then(_VoteDisplayData(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,optionA: null == optionA ? _self.optionA : optionA // ignore: cast_nullable_to_non_nullable
as String,optionB: null == optionB ? _self.optionB : optionB // ignore: cast_nullable_to_non_nullable
as String,imageUrlA: freezed == imageUrlA ? _self.imageUrlA : imageUrlA // ignore: cast_nullable_to_non_nullable
as String?,imageUrlB: freezed == imageUrlB ? _self.imageUrlB : imageUrlB // ignore: cast_nullable_to_non_nullable
as String?,imageUrlsA: freezed == imageUrlsA ? _self._imageUrlsA : imageUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrlsB: freezed == imageUrlsB ? _self._imageUrlsB : imageUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,aspectRatioA: freezed == aspectRatioA ? _self.aspectRatioA : aspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,aspectRatioB: freezed == aspectRatioB ? _self.aspectRatioB : aspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,layoutType: freezed == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
