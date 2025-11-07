// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileInfo {

// Core Fields
 String get userId;// Foreign key to AuthUser.uid
 String get displayName; String? get photoUrl;// Profile Details
 String? get shortDescription; String? get gender; DateTime? get dateOfBirth; String get language;// Lists
 List<String> get interests; List<String> get expertise;// Location
@LatLngConverter() LatLng? get location;
/// Create a copy of ProfileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileInfoCopyWith<ProfileInfo> get copyWith => _$ProfileInfoCopyWithImpl<ProfileInfo>(this as ProfileInfo, _$identity);

  /// Serializes this ProfileInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileInfo&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.language, language) || other.language == language)&&const DeepCollectionEquality().equals(other.interests, interests)&&const DeepCollectionEquality().equals(other.expertise, expertise)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,photoUrl,shortDescription,gender,dateOfBirth,language,const DeepCollectionEquality().hash(interests),const DeepCollectionEquality().hash(expertise),location);

@override
String toString() {
  return 'ProfileInfo(userId: $userId, displayName: $displayName, photoUrl: $photoUrl, shortDescription: $shortDescription, gender: $gender, dateOfBirth: $dateOfBirth, language: $language, interests: $interests, expertise: $expertise, location: $location)';
}


}

/// @nodoc
abstract mixin class $ProfileInfoCopyWith<$Res>  {
  factory $ProfileInfoCopyWith(ProfileInfo value, $Res Function(ProfileInfo) _then) = _$ProfileInfoCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String? photoUrl, String? shortDescription, String? gender, DateTime? dateOfBirth, String language, List<String> interests, List<String> expertise,@LatLngConverter() LatLng? location
});




}
/// @nodoc
class _$ProfileInfoCopyWithImpl<$Res>
    implements $ProfileInfoCopyWith<$Res> {
  _$ProfileInfoCopyWithImpl(this._self, this._then);

  final ProfileInfo _self;
  final $Res Function(ProfileInfo) _then;

/// Create a copy of ProfileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? photoUrl = freezed,Object? shortDescription = freezed,Object? gender = freezed,Object? dateOfBirth = freezed,Object? language = null,Object? interests = null,Object? expertise = null,Object? location = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,shortDescription: freezed == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as List<String>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileInfo].
extension ProfileInfoPatterns on ProfileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileInfo value)  $default,){
final _that = this;
switch (_that) {
case _ProfileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? photoUrl,  String? shortDescription,  String? gender,  DateTime? dateOfBirth,  String language,  List<String> interests,  List<String> expertise, @LatLngConverter()  LatLng? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileInfo() when $default != null:
return $default(_that.userId,_that.displayName,_that.photoUrl,_that.shortDescription,_that.gender,_that.dateOfBirth,_that.language,_that.interests,_that.expertise,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? photoUrl,  String? shortDescription,  String? gender,  DateTime? dateOfBirth,  String language,  List<String> interests,  List<String> expertise, @LatLngConverter()  LatLng? location)  $default,) {final _that = this;
switch (_that) {
case _ProfileInfo():
return $default(_that.userId,_that.displayName,_that.photoUrl,_that.shortDescription,_that.gender,_that.dateOfBirth,_that.language,_that.interests,_that.expertise,_that.location);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String? photoUrl,  String? shortDescription,  String? gender,  DateTime? dateOfBirth,  String language,  List<String> interests,  List<String> expertise, @LatLngConverter()  LatLng? location)?  $default,) {final _that = this;
switch (_that) {
case _ProfileInfo() when $default != null:
return $default(_that.userId,_that.displayName,_that.photoUrl,_that.shortDescription,_that.gender,_that.dateOfBirth,_that.language,_that.interests,_that.expertise,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileInfo implements ProfileInfo {
  const _ProfileInfo({required this.userId, required this.displayName, this.photoUrl, this.shortDescription, this.gender, this.dateOfBirth, this.language = 'en', final  List<String> interests = const [], final  List<String> expertise = const [], @LatLngConverter() this.location}): _interests = interests,_expertise = expertise;
  factory _ProfileInfo.fromJson(Map<String, dynamic> json) => _$ProfileInfoFromJson(json);

// Core Fields
@override final  String userId;
// Foreign key to AuthUser.uid
@override final  String displayName;
@override final  String? photoUrl;
// Profile Details
@override final  String? shortDescription;
@override final  String? gender;
@override final  DateTime? dateOfBirth;
@override@JsonKey() final  String language;
// Lists
 final  List<String> _interests;
// Lists
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  List<String> _expertise;
@override@JsonKey() List<String> get expertise {
  if (_expertise is EqualUnmodifiableListView) return _expertise;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expertise);
}

// Location
@override@LatLngConverter() final  LatLng? location;

/// Create a copy of ProfileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileInfoCopyWith<_ProfileInfo> get copyWith => __$ProfileInfoCopyWithImpl<_ProfileInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileInfo&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.language, language) || other.language == language)&&const DeepCollectionEquality().equals(other._interests, _interests)&&const DeepCollectionEquality().equals(other._expertise, _expertise)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,photoUrl,shortDescription,gender,dateOfBirth,language,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_expertise),location);

@override
String toString() {
  return 'ProfileInfo(userId: $userId, displayName: $displayName, photoUrl: $photoUrl, shortDescription: $shortDescription, gender: $gender, dateOfBirth: $dateOfBirth, language: $language, interests: $interests, expertise: $expertise, location: $location)';
}


}

/// @nodoc
abstract mixin class _$ProfileInfoCopyWith<$Res> implements $ProfileInfoCopyWith<$Res> {
  factory _$ProfileInfoCopyWith(_ProfileInfo value, $Res Function(_ProfileInfo) _then) = __$ProfileInfoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String? photoUrl, String? shortDescription, String? gender, DateTime? dateOfBirth, String language, List<String> interests, List<String> expertise,@LatLngConverter() LatLng? location
});




}
/// @nodoc
class __$ProfileInfoCopyWithImpl<$Res>
    implements _$ProfileInfoCopyWith<$Res> {
  __$ProfileInfoCopyWithImpl(this._self, this._then);

  final _ProfileInfo _self;
  final $Res Function(_ProfileInfo) _then;

/// Create a copy of ProfileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? photoUrl = freezed,Object? shortDescription = freezed,Object? gender = freezed,Object? dateOfBirth = freezed,Object? language = null,Object? interests = null,Object? expertise = null,Object? location = freezed,}) {
  return _then(_ProfileInfo(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,shortDescription: freezed == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,expertise: null == expertise ? _self._expertise : expertise // ignore: cast_nullable_to_non_nullable
as List<String>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,
  ));
}


}

// dart format on
