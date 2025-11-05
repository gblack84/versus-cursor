// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_audience_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TargetAudienceState {

/// Collection type: 'quick' (빠른 수집), 'public' (공개), 'custom' (맞춤)
 String get collectionType;/// Target response count
 int get targetCount;/// Premium tier status
 bool get isPremium;/// Selected interests (Custom mode)
 List<String> get selectedInterests;/// Selected age group (Custom mode)
 String get selectedAgeGroup;/// Selected gender: 'all', 'male', 'female'
 String get selectedGender;/// Active users only filter
 bool get activeUserOnly;/// Current wizard step (0: Type, 1: Count, 2: Custom)
 int get currentStep;
/// Create a copy of TargetAudienceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetAudienceStateCopyWith<TargetAudienceState> get copyWith => _$TargetAudienceStateCopyWithImpl<TargetAudienceState>(this as TargetAudienceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetAudienceState&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other.selectedInterests, selectedInterests)&&(identical(other.selectedAgeGroup, selectedAgeGroup) || other.selectedAgeGroup == selectedAgeGroup)&&(identical(other.selectedGender, selectedGender) || other.selectedGender == selectedGender)&&(identical(other.activeUserOnly, activeUserOnly) || other.activeUserOnly == activeUserOnly)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep));
}


@override
int get hashCode => Object.hash(runtimeType,collectionType,targetCount,isPremium,const DeepCollectionEquality().hash(selectedInterests),selectedAgeGroup,selectedGender,activeUserOnly,currentStep);

@override
String toString() {
  return 'TargetAudienceState(collectionType: $collectionType, targetCount: $targetCount, isPremium: $isPremium, selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, selectedGender: $selectedGender, activeUserOnly: $activeUserOnly, currentStep: $currentStep)';
}


}

/// @nodoc
abstract mixin class $TargetAudienceStateCopyWith<$Res>  {
  factory $TargetAudienceStateCopyWith(TargetAudienceState value, $Res Function(TargetAudienceState) _then) = _$TargetAudienceStateCopyWithImpl;
@useResult
$Res call({
 String collectionType, int targetCount, bool isPremium, List<String> selectedInterests, String selectedAgeGroup, String selectedGender, bool activeUserOnly, int currentStep
});




}
/// @nodoc
class _$TargetAudienceStateCopyWithImpl<$Res>
    implements $TargetAudienceStateCopyWith<$Res> {
  _$TargetAudienceStateCopyWithImpl(this._self, this._then);

  final TargetAudienceState _self;
  final $Res Function(TargetAudienceState) _then;

/// Create a copy of TargetAudienceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionType = null,Object? targetCount = null,Object? isPremium = null,Object? selectedInterests = null,Object? selectedAgeGroup = null,Object? selectedGender = null,Object? activeUserOnly = null,Object? currentStep = null,}) {
  return _then(_self.copyWith(
collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,selectedInterests: null == selectedInterests ? _self.selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAgeGroup: null == selectedAgeGroup ? _self.selectedAgeGroup : selectedAgeGroup // ignore: cast_nullable_to_non_nullable
as String,selectedGender: null == selectedGender ? _self.selectedGender : selectedGender // ignore: cast_nullable_to_non_nullable
as String,activeUserOnly: null == activeUserOnly ? _self.activeUserOnly : activeUserOnly // ignore: cast_nullable_to_non_nullable
as bool,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TargetAudienceState].
extension TargetAudienceStatePatterns on TargetAudienceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TargetAudienceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TargetAudienceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TargetAudienceState value)  $default,){
final _that = this;
switch (_that) {
case _TargetAudienceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TargetAudienceState value)?  $default,){
final _that = this;
switch (_that) {
case _TargetAudienceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly,  int currentStep)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TargetAudienceState() when $default != null:
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly,_that.currentStep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly,  int currentStep)  $default,) {final _that = this;
switch (_that) {
case _TargetAudienceState():
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly,_that.currentStep);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly,  int currentStep)?  $default,) {final _that = this;
switch (_that) {
case _TargetAudienceState() when $default != null:
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly,_that.currentStep);case _:
  return null;

}
}

}

/// @nodoc


class _TargetAudienceState implements TargetAudienceState {
  const _TargetAudienceState({this.collectionType = 'quick', this.targetCount = 100, this.isPremium = false, final  List<String> selectedInterests = const [], this.selectedAgeGroup = '전체', this.selectedGender = 'all', this.activeUserOnly = true, this.currentStep = 0}): _selectedInterests = selectedInterests;
  

/// Collection type: 'quick' (빠른 수집), 'public' (공개), 'custom' (맞춤)
@override@JsonKey() final  String collectionType;
/// Target response count
@override@JsonKey() final  int targetCount;
/// Premium tier status
@override@JsonKey() final  bool isPremium;
/// Selected interests (Custom mode)
 final  List<String> _selectedInterests;
/// Selected interests (Custom mode)
@override@JsonKey() List<String> get selectedInterests {
  if (_selectedInterests is EqualUnmodifiableListView) return _selectedInterests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedInterests);
}

/// Selected age group (Custom mode)
@override@JsonKey() final  String selectedAgeGroup;
/// Selected gender: 'all', 'male', 'female'
@override@JsonKey() final  String selectedGender;
/// Active users only filter
@override@JsonKey() final  bool activeUserOnly;
/// Current wizard step (0: Type, 1: Count, 2: Custom)
@override@JsonKey() final  int currentStep;

/// Create a copy of TargetAudienceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetAudienceStateCopyWith<_TargetAudienceState> get copyWith => __$TargetAudienceStateCopyWithImpl<_TargetAudienceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TargetAudienceState&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._selectedInterests, _selectedInterests)&&(identical(other.selectedAgeGroup, selectedAgeGroup) || other.selectedAgeGroup == selectedAgeGroup)&&(identical(other.selectedGender, selectedGender) || other.selectedGender == selectedGender)&&(identical(other.activeUserOnly, activeUserOnly) || other.activeUserOnly == activeUserOnly)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep));
}


@override
int get hashCode => Object.hash(runtimeType,collectionType,targetCount,isPremium,const DeepCollectionEquality().hash(_selectedInterests),selectedAgeGroup,selectedGender,activeUserOnly,currentStep);

@override
String toString() {
  return 'TargetAudienceState(collectionType: $collectionType, targetCount: $targetCount, isPremium: $isPremium, selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, selectedGender: $selectedGender, activeUserOnly: $activeUserOnly, currentStep: $currentStep)';
}


}

/// @nodoc
abstract mixin class _$TargetAudienceStateCopyWith<$Res> implements $TargetAudienceStateCopyWith<$Res> {
  factory _$TargetAudienceStateCopyWith(_TargetAudienceState value, $Res Function(_TargetAudienceState) _then) = __$TargetAudienceStateCopyWithImpl;
@override @useResult
$Res call({
 String collectionType, int targetCount, bool isPremium, List<String> selectedInterests, String selectedAgeGroup, String selectedGender, bool activeUserOnly, int currentStep
});




}
/// @nodoc
class __$TargetAudienceStateCopyWithImpl<$Res>
    implements _$TargetAudienceStateCopyWith<$Res> {
  __$TargetAudienceStateCopyWithImpl(this._self, this._then);

  final _TargetAudienceState _self;
  final $Res Function(_TargetAudienceState) _then;

/// Create a copy of TargetAudienceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionType = null,Object? targetCount = null,Object? isPremium = null,Object? selectedInterests = null,Object? selectedAgeGroup = null,Object? selectedGender = null,Object? activeUserOnly = null,Object? currentStep = null,}) {
  return _then(_TargetAudienceState(
collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,selectedInterests: null == selectedInterests ? _self._selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAgeGroup: null == selectedAgeGroup ? _self.selectedAgeGroup : selectedAgeGroup // ignore: cast_nullable_to_non_nullable
as String,selectedGender: null == selectedGender ? _self.selectedGender : selectedGender // ignore: cast_nullable_to_non_nullable
as String,activeUserOnly: null == activeUserOnly ? _self.activeUserOnly : activeUserOnly // ignore: cast_nullable_to_non_nullable
as bool,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
