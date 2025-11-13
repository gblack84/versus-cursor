// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_info_input_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserInfoInputState {

/// Selected language
 String? get selectedLanguage;/// Selected country display name (e.g., "South Korea")
 String? get selectedCountry;/// Selected country code (e.g., "KR")
 String? get selectedCountryCode;/// User agreed to 13+ age requirement
 bool get agreed13old;/// Fetched user profile document
 UserProfile? get userDocument;/// ChoiceChips selected value (gender selection)
 String? get choiceChipsValue;/// Checkbox value (terms agreement)
 bool? get checkboxValue;
/// Create a copy of UserInfoInputState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserInfoInputStateCopyWith<UserInfoInputState> get copyWith => _$UserInfoInputStateCopyWithImpl<UserInfoInputState>(this as UserInfoInputState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserInfoInputState&&(identical(other.selectedLanguage, selectedLanguage) || other.selectedLanguage == selectedLanguage)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.selectedCountryCode, selectedCountryCode) || other.selectedCountryCode == selectedCountryCode)&&(identical(other.agreed13old, agreed13old) || other.agreed13old == agreed13old)&&(identical(other.userDocument, userDocument) || other.userDocument == userDocument)&&(identical(other.choiceChipsValue, choiceChipsValue) || other.choiceChipsValue == choiceChipsValue)&&(identical(other.checkboxValue, checkboxValue) || other.checkboxValue == checkboxValue));
}


@override
int get hashCode => Object.hash(runtimeType,selectedLanguage,selectedCountry,selectedCountryCode,agreed13old,userDocument,choiceChipsValue,checkboxValue);

@override
String toString() {
  return 'UserInfoInputState(selectedLanguage: $selectedLanguage, selectedCountry: $selectedCountry, selectedCountryCode: $selectedCountryCode, agreed13old: $agreed13old, userDocument: $userDocument, choiceChipsValue: $choiceChipsValue, checkboxValue: $checkboxValue)';
}


}

/// @nodoc
abstract mixin class $UserInfoInputStateCopyWith<$Res>  {
  factory $UserInfoInputStateCopyWith(UserInfoInputState value, $Res Function(UserInfoInputState) _then) = _$UserInfoInputStateCopyWithImpl;
@useResult
$Res call({
 String? selectedLanguage, String? selectedCountry, String? selectedCountryCode, bool agreed13old, UserProfile? userDocument, String? choiceChipsValue, bool? checkboxValue
});


$UserProfileCopyWith<$Res>? get userDocument;

}
/// @nodoc
class _$UserInfoInputStateCopyWithImpl<$Res>
    implements $UserInfoInputStateCopyWith<$Res> {
  _$UserInfoInputStateCopyWithImpl(this._self, this._then);

  final UserInfoInputState _self;
  final $Res Function(UserInfoInputState) _then;

/// Create a copy of UserInfoInputState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedLanguage = freezed,Object? selectedCountry = freezed,Object? selectedCountryCode = freezed,Object? agreed13old = null,Object? userDocument = freezed,Object? choiceChipsValue = freezed,Object? checkboxValue = freezed,}) {
  return _then(_self.copyWith(
selectedLanguage: freezed == selectedLanguage ? _self.selectedLanguage : selectedLanguage // ignore: cast_nullable_to_non_nullable
as String?,selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as String?,selectedCountryCode: freezed == selectedCountryCode ? _self.selectedCountryCode : selectedCountryCode // ignore: cast_nullable_to_non_nullable
as String?,agreed13old: null == agreed13old ? _self.agreed13old : agreed13old // ignore: cast_nullable_to_non_nullable
as bool,userDocument: freezed == userDocument ? _self.userDocument : userDocument // ignore: cast_nullable_to_non_nullable
as UserProfile?,choiceChipsValue: freezed == choiceChipsValue ? _self.choiceChipsValue : choiceChipsValue // ignore: cast_nullable_to_non_nullable
as String?,checkboxValue: freezed == checkboxValue ? _self.checkboxValue : checkboxValue // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of UserInfoInputState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get userDocument {
    if (_self.userDocument == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.userDocument!, (value) {
    return _then(_self.copyWith(userDocument: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserInfoInputState].
extension UserInfoInputStatePatterns on UserInfoInputState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserInfoInputState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserInfoInputState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserInfoInputState value)  $default,){
final _that = this;
switch (_that) {
case _UserInfoInputState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserInfoInputState value)?  $default,){
final _that = this;
switch (_that) {
case _UserInfoInputState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedLanguage,  String? selectedCountry,  String? selectedCountryCode,  bool agreed13old,  UserProfile? userDocument,  String? choiceChipsValue,  bool? checkboxValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserInfoInputState() when $default != null:
return $default(_that.selectedLanguage,_that.selectedCountry,_that.selectedCountryCode,_that.agreed13old,_that.userDocument,_that.choiceChipsValue,_that.checkboxValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedLanguage,  String? selectedCountry,  String? selectedCountryCode,  bool agreed13old,  UserProfile? userDocument,  String? choiceChipsValue,  bool? checkboxValue)  $default,) {final _that = this;
switch (_that) {
case _UserInfoInputState():
return $default(_that.selectedLanguage,_that.selectedCountry,_that.selectedCountryCode,_that.agreed13old,_that.userDocument,_that.choiceChipsValue,_that.checkboxValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedLanguage,  String? selectedCountry,  String? selectedCountryCode,  bool agreed13old,  UserProfile? userDocument,  String? choiceChipsValue,  bool? checkboxValue)?  $default,) {final _that = this;
switch (_that) {
case _UserInfoInputState() when $default != null:
return $default(_that.selectedLanguage,_that.selectedCountry,_that.selectedCountryCode,_that.agreed13old,_that.userDocument,_that.choiceChipsValue,_that.checkboxValue);case _:
  return null;

}
}

}

/// @nodoc


class _UserInfoInputState extends UserInfoInputState {
  const _UserInfoInputState({this.selectedLanguage, this.selectedCountry, this.selectedCountryCode, this.agreed13old = false, this.userDocument, this.choiceChipsValue, this.checkboxValue}): super._();
  

/// Selected language
@override final  String? selectedLanguage;
/// Selected country display name (e.g., "South Korea")
@override final  String? selectedCountry;
/// Selected country code (e.g., "KR")
@override final  String? selectedCountryCode;
/// User agreed to 13+ age requirement
@override@JsonKey() final  bool agreed13old;
/// Fetched user profile document
@override final  UserProfile? userDocument;
/// ChoiceChips selected value (gender selection)
@override final  String? choiceChipsValue;
/// Checkbox value (terms agreement)
@override final  bool? checkboxValue;

/// Create a copy of UserInfoInputState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserInfoInputStateCopyWith<_UserInfoInputState> get copyWith => __$UserInfoInputStateCopyWithImpl<_UserInfoInputState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserInfoInputState&&(identical(other.selectedLanguage, selectedLanguage) || other.selectedLanguage == selectedLanguage)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.selectedCountryCode, selectedCountryCode) || other.selectedCountryCode == selectedCountryCode)&&(identical(other.agreed13old, agreed13old) || other.agreed13old == agreed13old)&&(identical(other.userDocument, userDocument) || other.userDocument == userDocument)&&(identical(other.choiceChipsValue, choiceChipsValue) || other.choiceChipsValue == choiceChipsValue)&&(identical(other.checkboxValue, checkboxValue) || other.checkboxValue == checkboxValue));
}


@override
int get hashCode => Object.hash(runtimeType,selectedLanguage,selectedCountry,selectedCountryCode,agreed13old,userDocument,choiceChipsValue,checkboxValue);

@override
String toString() {
  return 'UserInfoInputState(selectedLanguage: $selectedLanguage, selectedCountry: $selectedCountry, selectedCountryCode: $selectedCountryCode, agreed13old: $agreed13old, userDocument: $userDocument, choiceChipsValue: $choiceChipsValue, checkboxValue: $checkboxValue)';
}


}

/// @nodoc
abstract mixin class _$UserInfoInputStateCopyWith<$Res> implements $UserInfoInputStateCopyWith<$Res> {
  factory _$UserInfoInputStateCopyWith(_UserInfoInputState value, $Res Function(_UserInfoInputState) _then) = __$UserInfoInputStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedLanguage, String? selectedCountry, String? selectedCountryCode, bool agreed13old, UserProfile? userDocument, String? choiceChipsValue, bool? checkboxValue
});


@override $UserProfileCopyWith<$Res>? get userDocument;

}
/// @nodoc
class __$UserInfoInputStateCopyWithImpl<$Res>
    implements _$UserInfoInputStateCopyWith<$Res> {
  __$UserInfoInputStateCopyWithImpl(this._self, this._then);

  final _UserInfoInputState _self;
  final $Res Function(_UserInfoInputState) _then;

/// Create a copy of UserInfoInputState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedLanguage = freezed,Object? selectedCountry = freezed,Object? selectedCountryCode = freezed,Object? agreed13old = null,Object? userDocument = freezed,Object? choiceChipsValue = freezed,Object? checkboxValue = freezed,}) {
  return _then(_UserInfoInputState(
selectedLanguage: freezed == selectedLanguage ? _self.selectedLanguage : selectedLanguage // ignore: cast_nullable_to_non_nullable
as String?,selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as String?,selectedCountryCode: freezed == selectedCountryCode ? _self.selectedCountryCode : selectedCountryCode // ignore: cast_nullable_to_non_nullable
as String?,agreed13old: null == agreed13old ? _self.agreed13old : agreed13old // ignore: cast_nullable_to_non_nullable
as bool,userDocument: freezed == userDocument ? _self.userDocument : userDocument // ignore: cast_nullable_to_non_nullable
as UserProfile?,choiceChipsValue: freezed == choiceChipsValue ? _self.choiceChipsValue : choiceChipsValue // ignore: cast_nullable_to_non_nullable
as String?,checkboxValue: freezed == checkboxValue ? _self.checkboxValue : checkboxValue // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of UserInfoInputState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get userDocument {
    if (_self.userDocument == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.userDocument!, (value) {
    return _then(_self.copyWith(userDocument: value));
  });
}
}

// dart format on
