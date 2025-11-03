// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_audience_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TargetAudienceDto {

 String get collectionType; int get targetCount; bool get isPremium; List<String> get selectedInterests; String get selectedAgeGroup; String get selectedGender; bool get activeUserOnly;
/// Create a copy of TargetAudienceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetAudienceDtoCopyWith<TargetAudienceDto> get copyWith => _$TargetAudienceDtoCopyWithImpl<TargetAudienceDto>(this as TargetAudienceDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetAudienceDto&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other.selectedInterests, selectedInterests)&&(identical(other.selectedAgeGroup, selectedAgeGroup) || other.selectedAgeGroup == selectedAgeGroup)&&(identical(other.selectedGender, selectedGender) || other.selectedGender == selectedGender)&&(identical(other.activeUserOnly, activeUserOnly) || other.activeUserOnly == activeUserOnly));
}


@override
int get hashCode => Object.hash(runtimeType,collectionType,targetCount,isPremium,const DeepCollectionEquality().hash(selectedInterests),selectedAgeGroup,selectedGender,activeUserOnly);

@override
String toString() {
  return 'TargetAudienceDto(collectionType: $collectionType, targetCount: $targetCount, isPremium: $isPremium, selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, selectedGender: $selectedGender, activeUserOnly: $activeUserOnly)';
}


}

/// @nodoc
abstract mixin class $TargetAudienceDtoCopyWith<$Res>  {
  factory $TargetAudienceDtoCopyWith(TargetAudienceDto value, $Res Function(TargetAudienceDto) _then) = _$TargetAudienceDtoCopyWithImpl;
@useResult
$Res call({
 String collectionType, int targetCount, bool isPremium, List<String> selectedInterests, String selectedAgeGroup, String selectedGender, bool activeUserOnly
});




}
/// @nodoc
class _$TargetAudienceDtoCopyWithImpl<$Res>
    implements $TargetAudienceDtoCopyWith<$Res> {
  _$TargetAudienceDtoCopyWithImpl(this._self, this._then);

  final TargetAudienceDto _self;
  final $Res Function(TargetAudienceDto) _then;

/// Create a copy of TargetAudienceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionType = null,Object? targetCount = null,Object? isPremium = null,Object? selectedInterests = null,Object? selectedAgeGroup = null,Object? selectedGender = null,Object? activeUserOnly = null,}) {
  return _then(_self.copyWith(
collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,selectedInterests: null == selectedInterests ? _self.selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAgeGroup: null == selectedAgeGroup ? _self.selectedAgeGroup : selectedAgeGroup // ignore: cast_nullable_to_non_nullable
as String,selectedGender: null == selectedGender ? _self.selectedGender : selectedGender // ignore: cast_nullable_to_non_nullable
as String,activeUserOnly: null == activeUserOnly ? _self.activeUserOnly : activeUserOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TargetAudienceDto].
extension TargetAudienceDtoPatterns on TargetAudienceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TargetAudienceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TargetAudienceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TargetAudienceDto value)  $default,){
final _that = this;
switch (_that) {
case _TargetAudienceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TargetAudienceDto value)?  $default,){
final _that = this;
switch (_that) {
case _TargetAudienceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TargetAudienceDto() when $default != null:
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly)  $default,) {final _that = this;
switch (_that) {
case _TargetAudienceDto():
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly)?  $default,) {final _that = this;
switch (_that) {
case _TargetAudienceDto() when $default != null:
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly);case _:
  return null;

}
}

}

/// @nodoc


class _TargetAudienceDto implements TargetAudienceDto {
  const _TargetAudienceDto({required this.collectionType, required this.targetCount, required this.isPremium, required final  List<String> selectedInterests, required this.selectedAgeGroup, required this.selectedGender, required this.activeUserOnly}): _selectedInterests = selectedInterests;
  

@override final  String collectionType;
@override final  int targetCount;
@override final  bool isPremium;
 final  List<String> _selectedInterests;
@override List<String> get selectedInterests {
  if (_selectedInterests is EqualUnmodifiableListView) return _selectedInterests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedInterests);
}

@override final  String selectedAgeGroup;
@override final  String selectedGender;
@override final  bool activeUserOnly;

/// Create a copy of TargetAudienceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetAudienceDtoCopyWith<_TargetAudienceDto> get copyWith => __$TargetAudienceDtoCopyWithImpl<_TargetAudienceDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TargetAudienceDto&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._selectedInterests, _selectedInterests)&&(identical(other.selectedAgeGroup, selectedAgeGroup) || other.selectedAgeGroup == selectedAgeGroup)&&(identical(other.selectedGender, selectedGender) || other.selectedGender == selectedGender)&&(identical(other.activeUserOnly, activeUserOnly) || other.activeUserOnly == activeUserOnly));
}


@override
int get hashCode => Object.hash(runtimeType,collectionType,targetCount,isPremium,const DeepCollectionEquality().hash(_selectedInterests),selectedAgeGroup,selectedGender,activeUserOnly);

@override
String toString() {
  return 'TargetAudienceDto(collectionType: $collectionType, targetCount: $targetCount, isPremium: $isPremium, selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, selectedGender: $selectedGender, activeUserOnly: $activeUserOnly)';
}


}

/// @nodoc
abstract mixin class _$TargetAudienceDtoCopyWith<$Res> implements $TargetAudienceDtoCopyWith<$Res> {
  factory _$TargetAudienceDtoCopyWith(_TargetAudienceDto value, $Res Function(_TargetAudienceDto) _then) = __$TargetAudienceDtoCopyWithImpl;
@override @useResult
$Res call({
 String collectionType, int targetCount, bool isPremium, List<String> selectedInterests, String selectedAgeGroup, String selectedGender, bool activeUserOnly
});




}
/// @nodoc
class __$TargetAudienceDtoCopyWithImpl<$Res>
    implements _$TargetAudienceDtoCopyWith<$Res> {
  __$TargetAudienceDtoCopyWithImpl(this._self, this._then);

  final _TargetAudienceDto _self;
  final $Res Function(_TargetAudienceDto) _then;

/// Create a copy of TargetAudienceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionType = null,Object? targetCount = null,Object? isPremium = null,Object? selectedInterests = null,Object? selectedAgeGroup = null,Object? selectedGender = null,Object? activeUserOnly = null,}) {
  return _then(_TargetAudienceDto(
collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,selectedInterests: null == selectedInterests ? _self._selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAgeGroup: null == selectedAgeGroup ? _self.selectedAgeGroup : selectedAgeGroup // ignore: cast_nullable_to_non_nullable
as String,selectedGender: null == selectedGender ? _self.selectedGender : selectedGender // ignore: cast_nullable_to_non_nullable
as String,activeUserOnly: null == activeUserOnly ? _self.activeUserOnly : activeUserOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
