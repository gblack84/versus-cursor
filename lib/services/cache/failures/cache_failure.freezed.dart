// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cache_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CacheFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CacheFailure()';
}


}

/// @nodoc
class $CacheFailureCopyWith<$Res>  {
$CacheFailureCopyWith(CacheFailure _, $Res Function(CacheFailure) __);
}


/// Adds pattern-matching-related methods to [CacheFailure].
extension CacheFailurePatterns on CacheFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CacheNotFound value)?  notFound,TResult Function( CacheTypeMismatch value)?  typeMismatch,TResult Function( CacheHiveError value)?  hiveError,TResult Function( CacheFirestoreError value)?  firestoreError,TResult Function( CacheSerializationError value)?  serializationError,TResult Function( CacheExpired value)?  expired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CacheNotFound() when notFound != null:
return notFound(_that);case CacheTypeMismatch() when typeMismatch != null:
return typeMismatch(_that);case CacheHiveError() when hiveError != null:
return hiveError(_that);case CacheFirestoreError() when firestoreError != null:
return firestoreError(_that);case CacheSerializationError() when serializationError != null:
return serializationError(_that);case CacheExpired() when expired != null:
return expired(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CacheNotFound value)  notFound,required TResult Function( CacheTypeMismatch value)  typeMismatch,required TResult Function( CacheHiveError value)  hiveError,required TResult Function( CacheFirestoreError value)  firestoreError,required TResult Function( CacheSerializationError value)  serializationError,required TResult Function( CacheExpired value)  expired,}){
final _that = this;
switch (_that) {
case CacheNotFound():
return notFound(_that);case CacheTypeMismatch():
return typeMismatch(_that);case CacheHiveError():
return hiveError(_that);case CacheFirestoreError():
return firestoreError(_that);case CacheSerializationError():
return serializationError(_that);case CacheExpired():
return expired(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CacheNotFound value)?  notFound,TResult? Function( CacheTypeMismatch value)?  typeMismatch,TResult? Function( CacheHiveError value)?  hiveError,TResult? Function( CacheFirestoreError value)?  firestoreError,TResult? Function( CacheSerializationError value)?  serializationError,TResult? Function( CacheExpired value)?  expired,}){
final _that = this;
switch (_that) {
case CacheNotFound() when notFound != null:
return notFound(_that);case CacheTypeMismatch() when typeMismatch != null:
return typeMismatch(_that);case CacheHiveError() when hiveError != null:
return hiveError(_that);case CacheFirestoreError() when firestoreError != null:
return firestoreError(_that);case CacheSerializationError() when serializationError != null:
return serializationError(_that);case CacheExpired() when expired != null:
return expired(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message)?  notFound,TResult Function( String expected,  String actual)?  typeMismatch,TResult Function( String message)?  hiveError,TResult Function( String message)?  firestoreError,TResult Function( String message)?  serializationError,TResult Function()?  expired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CacheNotFound() when notFound != null:
return notFound(_that.message);case CacheTypeMismatch() when typeMismatch != null:
return typeMismatch(_that.expected,_that.actual);case CacheHiveError() when hiveError != null:
return hiveError(_that.message);case CacheFirestoreError() when firestoreError != null:
return firestoreError(_that.message);case CacheSerializationError() when serializationError != null:
return serializationError(_that.message);case CacheExpired() when expired != null:
return expired();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message)  notFound,required TResult Function( String expected,  String actual)  typeMismatch,required TResult Function( String message)  hiveError,required TResult Function( String message)  firestoreError,required TResult Function( String message)  serializationError,required TResult Function()  expired,}) {final _that = this;
switch (_that) {
case CacheNotFound():
return notFound(_that.message);case CacheTypeMismatch():
return typeMismatch(_that.expected,_that.actual);case CacheHiveError():
return hiveError(_that.message);case CacheFirestoreError():
return firestoreError(_that.message);case CacheSerializationError():
return serializationError(_that.message);case CacheExpired():
return expired();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message)?  notFound,TResult? Function( String expected,  String actual)?  typeMismatch,TResult? Function( String message)?  hiveError,TResult? Function( String message)?  firestoreError,TResult? Function( String message)?  serializationError,TResult? Function()?  expired,}) {final _that = this;
switch (_that) {
case CacheNotFound() when notFound != null:
return notFound(_that.message);case CacheTypeMismatch() when typeMismatch != null:
return typeMismatch(_that.expected,_that.actual);case CacheHiveError() when hiveError != null:
return hiveError(_that.message);case CacheFirestoreError() when firestoreError != null:
return firestoreError(_that.message);case CacheSerializationError() when serializationError != null:
return serializationError(_that.message);case CacheExpired() when expired != null:
return expired();case _:
  return null;

}
}

}

/// @nodoc


class CacheNotFound implements CacheFailure {
  const CacheNotFound([this.message]);
  

 final  String? message;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheNotFoundCopyWith<CacheNotFound> get copyWith => _$CacheNotFoundCopyWithImpl<CacheNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheNotFound&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CacheFailure.notFound(message: $message)';
}


}

/// @nodoc
abstract mixin class $CacheNotFoundCopyWith<$Res> implements $CacheFailureCopyWith<$Res> {
  factory $CacheNotFoundCopyWith(CacheNotFound value, $Res Function(CacheNotFound) _then) = _$CacheNotFoundCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$CacheNotFoundCopyWithImpl<$Res>
    implements $CacheNotFoundCopyWith<$Res> {
  _$CacheNotFoundCopyWithImpl(this._self, this._then);

  final CacheNotFound _self;
  final $Res Function(CacheNotFound) _then;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(CacheNotFound(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CacheTypeMismatch implements CacheFailure {
  const CacheTypeMismatch({required this.expected, required this.actual});
  

 final  String expected;
 final  String actual;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheTypeMismatchCopyWith<CacheTypeMismatch> get copyWith => _$CacheTypeMismatchCopyWithImpl<CacheTypeMismatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheTypeMismatch&&(identical(other.expected, expected) || other.expected == expected)&&(identical(other.actual, actual) || other.actual == actual));
}


@override
int get hashCode => Object.hash(runtimeType,expected,actual);

@override
String toString() {
  return 'CacheFailure.typeMismatch(expected: $expected, actual: $actual)';
}


}

/// @nodoc
abstract mixin class $CacheTypeMismatchCopyWith<$Res> implements $CacheFailureCopyWith<$Res> {
  factory $CacheTypeMismatchCopyWith(CacheTypeMismatch value, $Res Function(CacheTypeMismatch) _then) = _$CacheTypeMismatchCopyWithImpl;
@useResult
$Res call({
 String expected, String actual
});




}
/// @nodoc
class _$CacheTypeMismatchCopyWithImpl<$Res>
    implements $CacheTypeMismatchCopyWith<$Res> {
  _$CacheTypeMismatchCopyWithImpl(this._self, this._then);

  final CacheTypeMismatch _self;
  final $Res Function(CacheTypeMismatch) _then;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? expected = null,Object? actual = null,}) {
  return _then(CacheTypeMismatch(
expected: null == expected ? _self.expected : expected // ignore: cast_nullable_to_non_nullable
as String,actual: null == actual ? _self.actual : actual // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CacheHiveError implements CacheFailure {
  const CacheHiveError(this.message);
  

 final  String message;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheHiveErrorCopyWith<CacheHiveError> get copyWith => _$CacheHiveErrorCopyWithImpl<CacheHiveError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheHiveError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CacheFailure.hiveError(message: $message)';
}


}

/// @nodoc
abstract mixin class $CacheHiveErrorCopyWith<$Res> implements $CacheFailureCopyWith<$Res> {
  factory $CacheHiveErrorCopyWith(CacheHiveError value, $Res Function(CacheHiveError) _then) = _$CacheHiveErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CacheHiveErrorCopyWithImpl<$Res>
    implements $CacheHiveErrorCopyWith<$Res> {
  _$CacheHiveErrorCopyWithImpl(this._self, this._then);

  final CacheHiveError _self;
  final $Res Function(CacheHiveError) _then;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CacheHiveError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CacheFirestoreError implements CacheFailure {
  const CacheFirestoreError(this.message);
  

 final  String message;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheFirestoreErrorCopyWith<CacheFirestoreError> get copyWith => _$CacheFirestoreErrorCopyWithImpl<CacheFirestoreError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheFirestoreError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CacheFailure.firestoreError(message: $message)';
}


}

/// @nodoc
abstract mixin class $CacheFirestoreErrorCopyWith<$Res> implements $CacheFailureCopyWith<$Res> {
  factory $CacheFirestoreErrorCopyWith(CacheFirestoreError value, $Res Function(CacheFirestoreError) _then) = _$CacheFirestoreErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CacheFirestoreErrorCopyWithImpl<$Res>
    implements $CacheFirestoreErrorCopyWith<$Res> {
  _$CacheFirestoreErrorCopyWithImpl(this._self, this._then);

  final CacheFirestoreError _self;
  final $Res Function(CacheFirestoreError) _then;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CacheFirestoreError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CacheSerializationError implements CacheFailure {
  const CacheSerializationError(this.message);
  

 final  String message;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheSerializationErrorCopyWith<CacheSerializationError> get copyWith => _$CacheSerializationErrorCopyWithImpl<CacheSerializationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheSerializationError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CacheFailure.serializationError(message: $message)';
}


}

/// @nodoc
abstract mixin class $CacheSerializationErrorCopyWith<$Res> implements $CacheFailureCopyWith<$Res> {
  factory $CacheSerializationErrorCopyWith(CacheSerializationError value, $Res Function(CacheSerializationError) _then) = _$CacheSerializationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CacheSerializationErrorCopyWithImpl<$Res>
    implements $CacheSerializationErrorCopyWith<$Res> {
  _$CacheSerializationErrorCopyWithImpl(this._self, this._then);

  final CacheSerializationError _self;
  final $Res Function(CacheSerializationError) _then;

/// Create a copy of CacheFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CacheSerializationError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CacheExpired implements CacheFailure {
  const CacheExpired();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CacheFailure.expired()';
}


}




// dart format on
