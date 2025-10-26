// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteOptions {

 String get optionATitle; String get optionBTitle; String? get optionADescription; String? get optionBDescription; List<String> get optionAImageUrls; List<String> get optionBImageUrls; double? get optionAAspectRatio; double? get optionBAspectRatio; List<String> get relatedInterests; Map<String, dynamic> get metadata;
/// Create a copy of VoteOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteOptionsCopyWith<VoteOptions> get copyWith => _$VoteOptionsCopyWithImpl<VoteOptions>(this as VoteOptions, _$identity);

  /// Serializes this VoteOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteOptions&&(identical(other.optionATitle, optionATitle) || other.optionATitle == optionATitle)&&(identical(other.optionBTitle, optionBTitle) || other.optionBTitle == optionBTitle)&&(identical(other.optionADescription, optionADescription) || other.optionADescription == optionADescription)&&(identical(other.optionBDescription, optionBDescription) || other.optionBDescription == optionBDescription)&&const DeepCollectionEquality().equals(other.optionAImageUrls, optionAImageUrls)&&const DeepCollectionEquality().equals(other.optionBImageUrls, optionBImageUrls)&&(identical(other.optionAAspectRatio, optionAAspectRatio) || other.optionAAspectRatio == optionAAspectRatio)&&(identical(other.optionBAspectRatio, optionBAspectRatio) || other.optionBAspectRatio == optionBAspectRatio)&&const DeepCollectionEquality().equals(other.relatedInterests, relatedInterests)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optionATitle,optionBTitle,optionADescription,optionBDescription,const DeepCollectionEquality().hash(optionAImageUrls),const DeepCollectionEquality().hash(optionBImageUrls),optionAAspectRatio,optionBAspectRatio,const DeepCollectionEquality().hash(relatedInterests),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'VoteOptions(optionATitle: $optionATitle, optionBTitle: $optionBTitle, optionADescription: $optionADescription, optionBDescription: $optionBDescription, optionAImageUrls: $optionAImageUrls, optionBImageUrls: $optionBImageUrls, optionAAspectRatio: $optionAAspectRatio, optionBAspectRatio: $optionBAspectRatio, relatedInterests: $relatedInterests, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $VoteOptionsCopyWith<$Res>  {
  factory $VoteOptionsCopyWith(VoteOptions value, $Res Function(VoteOptions) _then) = _$VoteOptionsCopyWithImpl;
@useResult
$Res call({
 String optionATitle, String optionBTitle, String? optionADescription, String? optionBDescription, List<String> optionAImageUrls, List<String> optionBImageUrls, double? optionAAspectRatio, double? optionBAspectRatio, List<String> relatedInterests, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$VoteOptionsCopyWithImpl<$Res>
    implements $VoteOptionsCopyWith<$Res> {
  _$VoteOptionsCopyWithImpl(this._self, this._then);

  final VoteOptions _self;
  final $Res Function(VoteOptions) _then;

/// Create a copy of VoteOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? optionATitle = null,Object? optionBTitle = null,Object? optionADescription = freezed,Object? optionBDescription = freezed,Object? optionAImageUrls = null,Object? optionBImageUrls = null,Object? optionAAspectRatio = freezed,Object? optionBAspectRatio = freezed,Object? relatedInterests = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
optionATitle: null == optionATitle ? _self.optionATitle : optionATitle // ignore: cast_nullable_to_non_nullable
as String,optionBTitle: null == optionBTitle ? _self.optionBTitle : optionBTitle // ignore: cast_nullable_to_non_nullable
as String,optionADescription: freezed == optionADescription ? _self.optionADescription : optionADescription // ignore: cast_nullable_to_non_nullable
as String?,optionBDescription: freezed == optionBDescription ? _self.optionBDescription : optionBDescription // ignore: cast_nullable_to_non_nullable
as String?,optionAImageUrls: null == optionAImageUrls ? _self.optionAImageUrls : optionAImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,optionBImageUrls: null == optionBImageUrls ? _self.optionBImageUrls : optionBImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,optionAAspectRatio: freezed == optionAAspectRatio ? _self.optionAAspectRatio : optionAAspectRatio // ignore: cast_nullable_to_non_nullable
as double?,optionBAspectRatio: freezed == optionBAspectRatio ? _self.optionBAspectRatio : optionBAspectRatio // ignore: cast_nullable_to_non_nullable
as double?,relatedInterests: null == relatedInterests ? _self.relatedInterests : relatedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteOptions].
extension VoteOptionsPatterns on VoteOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteOptions value)  $default,){
final _that = this;
switch (_that) {
case _VoteOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteOptions value)?  $default,){
final _that = this;
switch (_that) {
case _VoteOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String optionATitle,  String optionBTitle,  String? optionADescription,  String? optionBDescription,  List<String> optionAImageUrls,  List<String> optionBImageUrls,  double? optionAAspectRatio,  double? optionBAspectRatio,  List<String> relatedInterests,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteOptions() when $default != null:
return $default(_that.optionATitle,_that.optionBTitle,_that.optionADescription,_that.optionBDescription,_that.optionAImageUrls,_that.optionBImageUrls,_that.optionAAspectRatio,_that.optionBAspectRatio,_that.relatedInterests,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String optionATitle,  String optionBTitle,  String? optionADescription,  String? optionBDescription,  List<String> optionAImageUrls,  List<String> optionBImageUrls,  double? optionAAspectRatio,  double? optionBAspectRatio,  List<String> relatedInterests,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _VoteOptions():
return $default(_that.optionATitle,_that.optionBTitle,_that.optionADescription,_that.optionBDescription,_that.optionAImageUrls,_that.optionBImageUrls,_that.optionAAspectRatio,_that.optionBAspectRatio,_that.relatedInterests,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String optionATitle,  String optionBTitle,  String? optionADescription,  String? optionBDescription,  List<String> optionAImageUrls,  List<String> optionBImageUrls,  double? optionAAspectRatio,  double? optionBAspectRatio,  List<String> relatedInterests,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _VoteOptions() when $default != null:
return $default(_that.optionATitle,_that.optionBTitle,_that.optionADescription,_that.optionBDescription,_that.optionAImageUrls,_that.optionBImageUrls,_that.optionAAspectRatio,_that.optionBAspectRatio,_that.relatedInterests,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteOptions extends VoteOptions {
  const _VoteOptions({required this.optionATitle, required this.optionBTitle, this.optionADescription, this.optionBDescription, final  List<String> optionAImageUrls = const [], final  List<String> optionBImageUrls = const [], this.optionAAspectRatio, this.optionBAspectRatio, final  List<String> relatedInterests = const [], final  Map<String, dynamic> metadata = const {}}): _optionAImageUrls = optionAImageUrls,_optionBImageUrls = optionBImageUrls,_relatedInterests = relatedInterests,_metadata = metadata,super._();
  factory _VoteOptions.fromJson(Map<String, dynamic> json) => _$VoteOptionsFromJson(json);

@override final  String optionATitle;
@override final  String optionBTitle;
@override final  String? optionADescription;
@override final  String? optionBDescription;
 final  List<String> _optionAImageUrls;
@override@JsonKey() List<String> get optionAImageUrls {
  if (_optionAImageUrls is EqualUnmodifiableListView) return _optionAImageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_optionAImageUrls);
}

 final  List<String> _optionBImageUrls;
@override@JsonKey() List<String> get optionBImageUrls {
  if (_optionBImageUrls is EqualUnmodifiableListView) return _optionBImageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_optionBImageUrls);
}

@override final  double? optionAAspectRatio;
@override final  double? optionBAspectRatio;
 final  List<String> _relatedInterests;
@override@JsonKey() List<String> get relatedInterests {
  if (_relatedInterests is EqualUnmodifiableListView) return _relatedInterests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedInterests);
}

 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of VoteOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteOptionsCopyWith<_VoteOptions> get copyWith => __$VoteOptionsCopyWithImpl<_VoteOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteOptions&&(identical(other.optionATitle, optionATitle) || other.optionATitle == optionATitle)&&(identical(other.optionBTitle, optionBTitle) || other.optionBTitle == optionBTitle)&&(identical(other.optionADescription, optionADescription) || other.optionADescription == optionADescription)&&(identical(other.optionBDescription, optionBDescription) || other.optionBDescription == optionBDescription)&&const DeepCollectionEquality().equals(other._optionAImageUrls, _optionAImageUrls)&&const DeepCollectionEquality().equals(other._optionBImageUrls, _optionBImageUrls)&&(identical(other.optionAAspectRatio, optionAAspectRatio) || other.optionAAspectRatio == optionAAspectRatio)&&(identical(other.optionBAspectRatio, optionBAspectRatio) || other.optionBAspectRatio == optionBAspectRatio)&&const DeepCollectionEquality().equals(other._relatedInterests, _relatedInterests)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,optionATitle,optionBTitle,optionADescription,optionBDescription,const DeepCollectionEquality().hash(_optionAImageUrls),const DeepCollectionEquality().hash(_optionBImageUrls),optionAAspectRatio,optionBAspectRatio,const DeepCollectionEquality().hash(_relatedInterests),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'VoteOptions(optionATitle: $optionATitle, optionBTitle: $optionBTitle, optionADescription: $optionADescription, optionBDescription: $optionBDescription, optionAImageUrls: $optionAImageUrls, optionBImageUrls: $optionBImageUrls, optionAAspectRatio: $optionAAspectRatio, optionBAspectRatio: $optionBAspectRatio, relatedInterests: $relatedInterests, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$VoteOptionsCopyWith<$Res> implements $VoteOptionsCopyWith<$Res> {
  factory _$VoteOptionsCopyWith(_VoteOptions value, $Res Function(_VoteOptions) _then) = __$VoteOptionsCopyWithImpl;
@override @useResult
$Res call({
 String optionATitle, String optionBTitle, String? optionADescription, String? optionBDescription, List<String> optionAImageUrls, List<String> optionBImageUrls, double? optionAAspectRatio, double? optionBAspectRatio, List<String> relatedInterests, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$VoteOptionsCopyWithImpl<$Res>
    implements _$VoteOptionsCopyWith<$Res> {
  __$VoteOptionsCopyWithImpl(this._self, this._then);

  final _VoteOptions _self;
  final $Res Function(_VoteOptions) _then;

/// Create a copy of VoteOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? optionATitle = null,Object? optionBTitle = null,Object? optionADescription = freezed,Object? optionBDescription = freezed,Object? optionAImageUrls = null,Object? optionBImageUrls = null,Object? optionAAspectRatio = freezed,Object? optionBAspectRatio = freezed,Object? relatedInterests = null,Object? metadata = null,}) {
  return _then(_VoteOptions(
optionATitle: null == optionATitle ? _self.optionATitle : optionATitle // ignore: cast_nullable_to_non_nullable
as String,optionBTitle: null == optionBTitle ? _self.optionBTitle : optionBTitle // ignore: cast_nullable_to_non_nullable
as String,optionADescription: freezed == optionADescription ? _self.optionADescription : optionADescription // ignore: cast_nullable_to_non_nullable
as String?,optionBDescription: freezed == optionBDescription ? _self.optionBDescription : optionBDescription // ignore: cast_nullable_to_non_nullable
as String?,optionAImageUrls: null == optionAImageUrls ? _self._optionAImageUrls : optionAImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,optionBImageUrls: null == optionBImageUrls ? _self._optionBImageUrls : optionBImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,optionAAspectRatio: freezed == optionAAspectRatio ? _self.optionAAspectRatio : optionAAspectRatio // ignore: cast_nullable_to_non_nullable
as double?,optionBAspectRatio: freezed == optionBAspectRatio ? _self.optionBAspectRatio : optionBAspectRatio // ignore: cast_nullable_to_non_nullable
as double?,relatedInterests: null == relatedInterests ? _self._relatedInterests : relatedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
