// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phone_creat_account_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhoneCreatAccountState {

/// Selected country code (e.g., "+82", "+1")
 String? get selectedCountryCode;/// Selected country name (e.g., "South Korea", "United States")
 String? get selectedCountryName;
/// Create a copy of PhoneCreatAccountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhoneCreatAccountStateCopyWith<PhoneCreatAccountState> get copyWith => _$PhoneCreatAccountStateCopyWithImpl<PhoneCreatAccountState>(this as PhoneCreatAccountState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhoneCreatAccountState&&(identical(other.selectedCountryCode, selectedCountryCode) || other.selectedCountryCode == selectedCountryCode)&&(identical(other.selectedCountryName, selectedCountryName) || other.selectedCountryName == selectedCountryName));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCountryCode,selectedCountryName);

@override
String toString() {
  return 'PhoneCreatAccountState(selectedCountryCode: $selectedCountryCode, selectedCountryName: $selectedCountryName)';
}


}

/// @nodoc
abstract mixin class $PhoneCreatAccountStateCopyWith<$Res>  {
  factory $PhoneCreatAccountStateCopyWith(PhoneCreatAccountState value, $Res Function(PhoneCreatAccountState) _then) = _$PhoneCreatAccountStateCopyWithImpl;
@useResult
$Res call({
 String? selectedCountryCode, String? selectedCountryName
});




}
/// @nodoc
class _$PhoneCreatAccountStateCopyWithImpl<$Res>
    implements $PhoneCreatAccountStateCopyWith<$Res> {
  _$PhoneCreatAccountStateCopyWithImpl(this._self, this._then);

  final PhoneCreatAccountState _self;
  final $Res Function(PhoneCreatAccountState) _then;

/// Create a copy of PhoneCreatAccountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCountryCode = freezed,Object? selectedCountryName = freezed,}) {
  return _then(_self.copyWith(
selectedCountryCode: freezed == selectedCountryCode ? _self.selectedCountryCode : selectedCountryCode // ignore: cast_nullable_to_non_nullable
as String?,selectedCountryName: freezed == selectedCountryName ? _self.selectedCountryName : selectedCountryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhoneCreatAccountState].
extension PhoneCreatAccountStatePatterns on PhoneCreatAccountState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhoneCreatAccountState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhoneCreatAccountState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhoneCreatAccountState value)  $default,){
final _that = this;
switch (_that) {
case _PhoneCreatAccountState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhoneCreatAccountState value)?  $default,){
final _that = this;
switch (_that) {
case _PhoneCreatAccountState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedCountryCode,  String? selectedCountryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhoneCreatAccountState() when $default != null:
return $default(_that.selectedCountryCode,_that.selectedCountryName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedCountryCode,  String? selectedCountryName)  $default,) {final _that = this;
switch (_that) {
case _PhoneCreatAccountState():
return $default(_that.selectedCountryCode,_that.selectedCountryName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedCountryCode,  String? selectedCountryName)?  $default,) {final _that = this;
switch (_that) {
case _PhoneCreatAccountState() when $default != null:
return $default(_that.selectedCountryCode,_that.selectedCountryName);case _:
  return null;

}
}

}

/// @nodoc


class _PhoneCreatAccountState extends PhoneCreatAccountState {
  const _PhoneCreatAccountState({this.selectedCountryCode, this.selectedCountryName}): super._();
  

/// Selected country code (e.g., "+82", "+1")
@override final  String? selectedCountryCode;
/// Selected country name (e.g., "South Korea", "United States")
@override final  String? selectedCountryName;

/// Create a copy of PhoneCreatAccountState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhoneCreatAccountStateCopyWith<_PhoneCreatAccountState> get copyWith => __$PhoneCreatAccountStateCopyWithImpl<_PhoneCreatAccountState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhoneCreatAccountState&&(identical(other.selectedCountryCode, selectedCountryCode) || other.selectedCountryCode == selectedCountryCode)&&(identical(other.selectedCountryName, selectedCountryName) || other.selectedCountryName == selectedCountryName));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCountryCode,selectedCountryName);

@override
String toString() {
  return 'PhoneCreatAccountState(selectedCountryCode: $selectedCountryCode, selectedCountryName: $selectedCountryName)';
}


}

/// @nodoc
abstract mixin class _$PhoneCreatAccountStateCopyWith<$Res> implements $PhoneCreatAccountStateCopyWith<$Res> {
  factory _$PhoneCreatAccountStateCopyWith(_PhoneCreatAccountState value, $Res Function(_PhoneCreatAccountState) _then) = __$PhoneCreatAccountStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedCountryCode, String? selectedCountryName
});




}
/// @nodoc
class __$PhoneCreatAccountStateCopyWithImpl<$Res>
    implements _$PhoneCreatAccountStateCopyWith<$Res> {
  __$PhoneCreatAccountStateCopyWithImpl(this._self, this._then);

  final _PhoneCreatAccountState _self;
  final $Res Function(_PhoneCreatAccountState) _then;

/// Create a copy of PhoneCreatAccountState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCountryCode = freezed,Object? selectedCountryName = freezed,}) {
  return _then(_PhoneCreatAccountState(
selectedCountryCode: freezed == selectedCountryCode ? _self.selectedCountryCode : selectedCountryCode // ignore: cast_nullable_to_non_nullable
as String?,selectedCountryName: freezed == selectedCountryName ? _self.selectedCountryName : selectedCountryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
