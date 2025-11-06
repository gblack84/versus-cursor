// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_audience.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TargetAudience {

/// Collection type: 'quick', 'public', or 'custom'
 String get collectionType;/// Target response count
 int get targetCount;/// Premium user flag
 bool get isPremium;/// Selected interests for custom targeting
 List<String> get selectedInterests;/// Selected age group for custom targeting (Korean format)
 String get selectedAgeGroup;/// Selected gender for custom targeting: 'all', 'male', 'female'
 String get selectedGender;/// Active users only flag for custom targeting
 bool get activeUserOnly;/// Creation timestamp
 DateTime get createdAt;/// Current status: 'pending', 'active', 'completed'
 String get status;
/// Create a copy of TargetAudience
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<TargetAudience> get copyWith => _$TargetAudienceCopyWithImpl<TargetAudience>(this as TargetAudience, _$identity);

  /// Serializes this TargetAudience to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetAudience&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other.selectedInterests, selectedInterests)&&(identical(other.selectedAgeGroup, selectedAgeGroup) || other.selectedAgeGroup == selectedAgeGroup)&&(identical(other.selectedGender, selectedGender) || other.selectedGender == selectedGender)&&(identical(other.activeUserOnly, activeUserOnly) || other.activeUserOnly == activeUserOnly)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,collectionType,targetCount,isPremium,const DeepCollectionEquality().hash(selectedInterests),selectedAgeGroup,selectedGender,activeUserOnly,createdAt,status);

@override
String toString() {
  return 'TargetAudience(collectionType: $collectionType, targetCount: $targetCount, isPremium: $isPremium, selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, selectedGender: $selectedGender, activeUserOnly: $activeUserOnly, createdAt: $createdAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $TargetAudienceCopyWith<$Res>  {
  factory $TargetAudienceCopyWith(TargetAudience value, $Res Function(TargetAudience) _then) = _$TargetAudienceCopyWithImpl;
@useResult
$Res call({
 String collectionType, int targetCount, bool isPremium, List<String> selectedInterests, String selectedAgeGroup, String selectedGender, bool activeUserOnly, DateTime createdAt, String status
});




}
/// @nodoc
class _$TargetAudienceCopyWithImpl<$Res>
    implements $TargetAudienceCopyWith<$Res> {
  _$TargetAudienceCopyWithImpl(this._self, this._then);

  final TargetAudience _self;
  final $Res Function(TargetAudience) _then;

/// Create a copy of TargetAudience
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionType = null,Object? targetCount = null,Object? isPremium = null,Object? selectedInterests = null,Object? selectedAgeGroup = null,Object? selectedGender = null,Object? activeUserOnly = null,Object? createdAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,selectedInterests: null == selectedInterests ? _self.selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAgeGroup: null == selectedAgeGroup ? _self.selectedAgeGroup : selectedAgeGroup // ignore: cast_nullable_to_non_nullable
as String,selectedGender: null == selectedGender ? _self.selectedGender : selectedGender // ignore: cast_nullable_to_non_nullable
as String,activeUserOnly: null == activeUserOnly ? _self.activeUserOnly : activeUserOnly // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TargetAudience].
extension TargetAudiencePatterns on TargetAudience {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TargetAudience value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TargetAudience() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TargetAudience value)  $default,){
final _that = this;
switch (_that) {
case _TargetAudience():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TargetAudience value)?  $default,){
final _that = this;
switch (_that) {
case _TargetAudience() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly,  DateTime createdAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TargetAudience() when $default != null:
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly,_that.createdAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly,  DateTime createdAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _TargetAudience():
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly,_that.createdAt,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String collectionType,  int targetCount,  bool isPremium,  List<String> selectedInterests,  String selectedAgeGroup,  String selectedGender,  bool activeUserOnly,  DateTime createdAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _TargetAudience() when $default != null:
return $default(_that.collectionType,_that.targetCount,_that.isPremium,_that.selectedInterests,_that.selectedAgeGroup,_that.selectedGender,_that.activeUserOnly,_that.createdAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TargetAudience extends TargetAudience {
  const _TargetAudience({this.collectionType = 'quick', this.targetCount = 100, this.isPremium = false, final  List<String> selectedInterests = const [], this.selectedAgeGroup = '전체', this.selectedGender = 'all', this.activeUserOnly = true, required this.createdAt, this.status = 'pending'}): _selectedInterests = selectedInterests,super._();
  factory _TargetAudience.fromJson(Map<String, dynamic> json) => _$TargetAudienceFromJson(json);

/// Collection type: 'quick', 'public', or 'custom'
@override@JsonKey() final  String collectionType;
/// Target response count
@override@JsonKey() final  int targetCount;
/// Premium user flag
@override@JsonKey() final  bool isPremium;
/// Selected interests for custom targeting
 final  List<String> _selectedInterests;
/// Selected interests for custom targeting
@override@JsonKey() List<String> get selectedInterests {
  if (_selectedInterests is EqualUnmodifiableListView) return _selectedInterests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedInterests);
}

/// Selected age group for custom targeting (Korean format)
@override@JsonKey() final  String selectedAgeGroup;
/// Selected gender for custom targeting: 'all', 'male', 'female'
@override@JsonKey() final  String selectedGender;
/// Active users only flag for custom targeting
@override@JsonKey() final  bool activeUserOnly;
/// Creation timestamp
@override final  DateTime createdAt;
/// Current status: 'pending', 'active', 'completed'
@override@JsonKey() final  String status;

/// Create a copy of TargetAudience
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetAudienceCopyWith<_TargetAudience> get copyWith => __$TargetAudienceCopyWithImpl<_TargetAudience>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TargetAudienceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TargetAudience&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._selectedInterests, _selectedInterests)&&(identical(other.selectedAgeGroup, selectedAgeGroup) || other.selectedAgeGroup == selectedAgeGroup)&&(identical(other.selectedGender, selectedGender) || other.selectedGender == selectedGender)&&(identical(other.activeUserOnly, activeUserOnly) || other.activeUserOnly == activeUserOnly)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,collectionType,targetCount,isPremium,const DeepCollectionEquality().hash(_selectedInterests),selectedAgeGroup,selectedGender,activeUserOnly,createdAt,status);

@override
String toString() {
  return 'TargetAudience(collectionType: $collectionType, targetCount: $targetCount, isPremium: $isPremium, selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, selectedGender: $selectedGender, activeUserOnly: $activeUserOnly, createdAt: $createdAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$TargetAudienceCopyWith<$Res> implements $TargetAudienceCopyWith<$Res> {
  factory _$TargetAudienceCopyWith(_TargetAudience value, $Res Function(_TargetAudience) _then) = __$TargetAudienceCopyWithImpl;
@override @useResult
$Res call({
 String collectionType, int targetCount, bool isPremium, List<String> selectedInterests, String selectedAgeGroup, String selectedGender, bool activeUserOnly, DateTime createdAt, String status
});




}
/// @nodoc
class __$TargetAudienceCopyWithImpl<$Res>
    implements _$TargetAudienceCopyWith<$Res> {
  __$TargetAudienceCopyWithImpl(this._self, this._then);

  final _TargetAudience _self;
  final $Res Function(_TargetAudience) _then;

/// Create a copy of TargetAudience
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionType = null,Object? targetCount = null,Object? isPremium = null,Object? selectedInterests = null,Object? selectedAgeGroup = null,Object? selectedGender = null,Object? activeUserOnly = null,Object? createdAt = null,Object? status = null,}) {
  return _then(_TargetAudience(
collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,selectedInterests: null == selectedInterests ? _self._selectedInterests : selectedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAgeGroup: null == selectedAgeGroup ? _self.selectedAgeGroup : selectedAgeGroup // ignore: cast_nullable_to_non_nullable
as String,selectedGender: null == selectedGender ? _self.selectedGender : selectedGender // ignore: cast_nullable_to_non_nullable
as String,activeUserOnly: null == activeUserOnly ? _self.activeUserOnly : activeUserOnly // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
