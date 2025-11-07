// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SearchFailure()';
}


}

/// @nodoc
class $SearchFailureCopyWith<$Res>  {
$SearchFailureCopyWith(SearchFailure _, $Res Function(SearchFailure) __);
}


/// Adds pattern-matching-related methods to [SearchFailure].
extension SearchFailurePatterns on SearchFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _NetworkError value)?  networkError,TResult Function( _Timeout value)?  timeout,TResult Function( _FirestoreReadFailed value)?  firestoreReadFailed,TResult Function( _FirestoreWriteFailed value)?  firestoreWriteFailed,TResult Function( _InvalidQuery value)?  invalidQuery,TResult Function( _QueryTooShort value)?  queryTooShort,TResult Function( _NotFound value)?  notFound,TResult Function( _TooManyResults value)?  tooManyResults,TResult Function( _IndexUnavailable value)?  indexUnavailable,TResult Function( _InsufficientPermissions value)?  insufficientPermissions,TResult Function( _Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that);case _Timeout() when timeout != null:
return timeout(_that);case _FirestoreReadFailed() when firestoreReadFailed != null:
return firestoreReadFailed(_that);case _FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that);case _InvalidQuery() when invalidQuery != null:
return invalidQuery(_that);case _QueryTooShort() when queryTooShort != null:
return queryTooShort(_that);case _NotFound() when notFound != null:
return notFound(_that);case _TooManyResults() when tooManyResults != null:
return tooManyResults(_that);case _IndexUnavailable() when indexUnavailable != null:
return indexUnavailable(_that);case _InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions(_that);case _Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _NetworkError value)  networkError,required TResult Function( _Timeout value)  timeout,required TResult Function( _FirestoreReadFailed value)  firestoreReadFailed,required TResult Function( _FirestoreWriteFailed value)  firestoreWriteFailed,required TResult Function( _InvalidQuery value)  invalidQuery,required TResult Function( _QueryTooShort value)  queryTooShort,required TResult Function( _NotFound value)  notFound,required TResult Function( _TooManyResults value)  tooManyResults,required TResult Function( _IndexUnavailable value)  indexUnavailable,required TResult Function( _InsufficientPermissions value)  insufficientPermissions,required TResult Function( _Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case _NetworkError():
return networkError(_that);case _Timeout():
return timeout(_that);case _FirestoreReadFailed():
return firestoreReadFailed(_that);case _FirestoreWriteFailed():
return firestoreWriteFailed(_that);case _InvalidQuery():
return invalidQuery(_that);case _QueryTooShort():
return queryTooShort(_that);case _NotFound():
return notFound(_that);case _TooManyResults():
return tooManyResults(_that);case _IndexUnavailable():
return indexUnavailable(_that);case _InsufficientPermissions():
return insufficientPermissions(_that);case _Unexpected():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _NetworkError value)?  networkError,TResult? Function( _Timeout value)?  timeout,TResult? Function( _FirestoreReadFailed value)?  firestoreReadFailed,TResult? Function( _FirestoreWriteFailed value)?  firestoreWriteFailed,TResult? Function( _InvalidQuery value)?  invalidQuery,TResult? Function( _QueryTooShort value)?  queryTooShort,TResult? Function( _NotFound value)?  notFound,TResult? Function( _TooManyResults value)?  tooManyResults,TResult? Function( _IndexUnavailable value)?  indexUnavailable,TResult? Function( _InsufficientPermissions value)?  insufficientPermissions,TResult? Function( _Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that);case _Timeout() when timeout != null:
return timeout(_that);case _FirestoreReadFailed() when firestoreReadFailed != null:
return firestoreReadFailed(_that);case _FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that);case _InvalidQuery() when invalidQuery != null:
return invalidQuery(_that);case _QueryTooShort() when queryTooShort != null:
return queryTooShort(_that);case _NotFound() when notFound != null:
return notFound(_that);case _TooManyResults() when tooManyResults != null:
return tooManyResults(_that);case _IndexUnavailable() when indexUnavailable != null:
return indexUnavailable(_that);case _InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions(_that);case _Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message)?  networkError,TResult Function( String? message)?  timeout,TResult Function( String collection,  String? message)?  firestoreReadFailed,TResult Function( String collection,  String? operation,  String? message)?  firestoreWriteFailed,TResult Function( String? message)?  invalidQuery,TResult Function( int? minLength)?  queryTooShort,TResult Function( String? message)?  notFound,TResult Function( String? message)?  tooManyResults,TResult Function( String? message)?  indexUnavailable,TResult Function( String? message)?  insufficientPermissions,TResult Function( String? message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that.message);case _Timeout() when timeout != null:
return timeout(_that.message);case _FirestoreReadFailed() when firestoreReadFailed != null:
return firestoreReadFailed(_that.collection,_that.message);case _FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that.collection,_that.operation,_that.message);case _InvalidQuery() when invalidQuery != null:
return invalidQuery(_that.message);case _QueryTooShort() when queryTooShort != null:
return queryTooShort(_that.minLength);case _NotFound() when notFound != null:
return notFound(_that.message);case _TooManyResults() when tooManyResults != null:
return tooManyResults(_that.message);case _IndexUnavailable() when indexUnavailable != null:
return indexUnavailable(_that.message);case _InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message)  networkError,required TResult Function( String? message)  timeout,required TResult Function( String collection,  String? message)  firestoreReadFailed,required TResult Function( String collection,  String? operation,  String? message)  firestoreWriteFailed,required TResult Function( String? message)  invalidQuery,required TResult Function( int? minLength)  queryTooShort,required TResult Function( String? message)  notFound,required TResult Function( String? message)  tooManyResults,required TResult Function( String? message)  indexUnavailable,required TResult Function( String? message)  insufficientPermissions,required TResult Function( String? message)  unexpected,}) {final _that = this;
switch (_that) {
case _NetworkError():
return networkError(_that.message);case _Timeout():
return timeout(_that.message);case _FirestoreReadFailed():
return firestoreReadFailed(_that.collection,_that.message);case _FirestoreWriteFailed():
return firestoreWriteFailed(_that.collection,_that.operation,_that.message);case _InvalidQuery():
return invalidQuery(_that.message);case _QueryTooShort():
return queryTooShort(_that.minLength);case _NotFound():
return notFound(_that.message);case _TooManyResults():
return tooManyResults(_that.message);case _IndexUnavailable():
return indexUnavailable(_that.message);case _InsufficientPermissions():
return insufficientPermissions(_that.message);case _Unexpected():
return unexpected(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message)?  networkError,TResult? Function( String? message)?  timeout,TResult? Function( String collection,  String? message)?  firestoreReadFailed,TResult? Function( String collection,  String? operation,  String? message)?  firestoreWriteFailed,TResult? Function( String? message)?  invalidQuery,TResult? Function( int? minLength)?  queryTooShort,TResult? Function( String? message)?  notFound,TResult? Function( String? message)?  tooManyResults,TResult? Function( String? message)?  indexUnavailable,TResult? Function( String? message)?  insufficientPermissions,TResult? Function( String? message)?  unexpected,}) {final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that.message);case _Timeout() when timeout != null:
return timeout(_that.message);case _FirestoreReadFailed() when firestoreReadFailed != null:
return firestoreReadFailed(_that.collection,_that.message);case _FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that.collection,_that.operation,_that.message);case _InvalidQuery() when invalidQuery != null:
return invalidQuery(_that.message);case _QueryTooShort() when queryTooShort != null:
return queryTooShort(_that.minLength);case _NotFound() when notFound != null:
return notFound(_that.message);case _TooManyResults() when tooManyResults != null:
return tooManyResults(_that.message);case _IndexUnavailable() when indexUnavailable != null:
return indexUnavailable(_that.message);case _InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkError extends SearchFailure {
  const _NetworkError([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkErrorCopyWith<_NetworkError> get copyWith => __$NetworkErrorCopyWithImpl<_NetworkError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.networkError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NetworkErrorCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$NetworkErrorCopyWith(_NetworkError value, $Res Function(_NetworkError) _then) = __$NetworkErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$NetworkErrorCopyWithImpl<$Res>
    implements _$NetworkErrorCopyWith<$Res> {
  __$NetworkErrorCopyWithImpl(this._self, this._then);

  final _NetworkError _self;
  final $Res Function(_NetworkError) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_NetworkError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Timeout extends SearchFailure {
  const _Timeout([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeoutCopyWith<_Timeout> get copyWith => __$TimeoutCopyWithImpl<_Timeout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Timeout&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.timeout(message: $message)';
}


}

/// @nodoc
abstract mixin class _$TimeoutCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$TimeoutCopyWith(_Timeout value, $Res Function(_Timeout) _then) = __$TimeoutCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$TimeoutCopyWithImpl<$Res>
    implements _$TimeoutCopyWith<$Res> {
  __$TimeoutCopyWithImpl(this._self, this._then);

  final _Timeout _self;
  final $Res Function(_Timeout) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Timeout(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _FirestoreReadFailed extends SearchFailure {
  const _FirestoreReadFailed({required this.collection, this.message}): super._();
  

 final  String collection;
 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FirestoreReadFailedCopyWith<_FirestoreReadFailed> get copyWith => __$FirestoreReadFailedCopyWithImpl<_FirestoreReadFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FirestoreReadFailed&&(identical(other.collection, collection) || other.collection == collection)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,collection,message);

@override
String toString() {
  return 'SearchFailure.firestoreReadFailed(collection: $collection, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FirestoreReadFailedCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$FirestoreReadFailedCopyWith(_FirestoreReadFailed value, $Res Function(_FirestoreReadFailed) _then) = __$FirestoreReadFailedCopyWithImpl;
@useResult
$Res call({
 String collection, String? message
});




}
/// @nodoc
class __$FirestoreReadFailedCopyWithImpl<$Res>
    implements _$FirestoreReadFailedCopyWith<$Res> {
  __$FirestoreReadFailedCopyWithImpl(this._self, this._then);

  final _FirestoreReadFailed _self;
  final $Res Function(_FirestoreReadFailed) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? collection = null,Object? message = freezed,}) {
  return _then(_FirestoreReadFailed(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _FirestoreWriteFailed extends SearchFailure {
  const _FirestoreWriteFailed({required this.collection, this.operation, this.message}): super._();
  

 final  String collection;
 final  String? operation;
 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FirestoreWriteFailedCopyWith<_FirestoreWriteFailed> get copyWith => __$FirestoreWriteFailedCopyWithImpl<_FirestoreWriteFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FirestoreWriteFailed&&(identical(other.collection, collection) || other.collection == collection)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,collection,operation,message);

@override
String toString() {
  return 'SearchFailure.firestoreWriteFailed(collection: $collection, operation: $operation, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FirestoreWriteFailedCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$FirestoreWriteFailedCopyWith(_FirestoreWriteFailed value, $Res Function(_FirestoreWriteFailed) _then) = __$FirestoreWriteFailedCopyWithImpl;
@useResult
$Res call({
 String collection, String? operation, String? message
});




}
/// @nodoc
class __$FirestoreWriteFailedCopyWithImpl<$Res>
    implements _$FirestoreWriteFailedCopyWith<$Res> {
  __$FirestoreWriteFailedCopyWithImpl(this._self, this._then);

  final _FirestoreWriteFailed _self;
  final $Res Function(_FirestoreWriteFailed) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? collection = null,Object? operation = freezed,Object? message = freezed,}) {
  return _then(_FirestoreWriteFailed(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as String,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _InvalidQuery extends SearchFailure {
  const _InvalidQuery([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidQueryCopyWith<_InvalidQuery> get copyWith => __$InvalidQueryCopyWithImpl<_InvalidQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidQuery&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.invalidQuery(message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvalidQueryCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$InvalidQueryCopyWith(_InvalidQuery value, $Res Function(_InvalidQuery) _then) = __$InvalidQueryCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$InvalidQueryCopyWithImpl<$Res>
    implements _$InvalidQueryCopyWith<$Res> {
  __$InvalidQueryCopyWithImpl(this._self, this._then);

  final _InvalidQuery _self;
  final $Res Function(_InvalidQuery) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_InvalidQuery(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _QueryTooShort extends SearchFailure {
  const _QueryTooShort({this.minLength}): super._();
  

 final  int? minLength;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueryTooShortCopyWith<_QueryTooShort> get copyWith => __$QueryTooShortCopyWithImpl<_QueryTooShort>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueryTooShort&&(identical(other.minLength, minLength) || other.minLength == minLength));
}


@override
int get hashCode => Object.hash(runtimeType,minLength);

@override
String toString() {
  return 'SearchFailure.queryTooShort(minLength: $minLength)';
}


}

/// @nodoc
abstract mixin class _$QueryTooShortCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$QueryTooShortCopyWith(_QueryTooShort value, $Res Function(_QueryTooShort) _then) = __$QueryTooShortCopyWithImpl;
@useResult
$Res call({
 int? minLength
});




}
/// @nodoc
class __$QueryTooShortCopyWithImpl<$Res>
    implements _$QueryTooShortCopyWith<$Res> {
  __$QueryTooShortCopyWithImpl(this._self, this._then);

  final _QueryTooShort _self;
  final $Res Function(_QueryTooShort) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minLength = freezed,}) {
  return _then(_QueryTooShort(
minLength: freezed == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _NotFound extends SearchFailure {
  const _NotFound([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotFoundCopyWith<_NotFound> get copyWith => __$NotFoundCopyWithImpl<_NotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotFound&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.notFound(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NotFoundCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$NotFoundCopyWith(_NotFound value, $Res Function(_NotFound) _then) = __$NotFoundCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$NotFoundCopyWithImpl<$Res>
    implements _$NotFoundCopyWith<$Res> {
  __$NotFoundCopyWithImpl(this._self, this._then);

  final _NotFound _self;
  final $Res Function(_NotFound) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_NotFound(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _TooManyResults extends SearchFailure {
  const _TooManyResults([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TooManyResultsCopyWith<_TooManyResults> get copyWith => __$TooManyResultsCopyWithImpl<_TooManyResults>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TooManyResults&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.tooManyResults(message: $message)';
}


}

/// @nodoc
abstract mixin class _$TooManyResultsCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$TooManyResultsCopyWith(_TooManyResults value, $Res Function(_TooManyResults) _then) = __$TooManyResultsCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$TooManyResultsCopyWithImpl<$Res>
    implements _$TooManyResultsCopyWith<$Res> {
  __$TooManyResultsCopyWithImpl(this._self, this._then);

  final _TooManyResults _self;
  final $Res Function(_TooManyResults) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_TooManyResults(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _IndexUnavailable extends SearchFailure {
  const _IndexUnavailable([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndexUnavailableCopyWith<_IndexUnavailable> get copyWith => __$IndexUnavailableCopyWithImpl<_IndexUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndexUnavailable&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.indexUnavailable(message: $message)';
}


}

/// @nodoc
abstract mixin class _$IndexUnavailableCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$IndexUnavailableCopyWith(_IndexUnavailable value, $Res Function(_IndexUnavailable) _then) = __$IndexUnavailableCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$IndexUnavailableCopyWithImpl<$Res>
    implements _$IndexUnavailableCopyWith<$Res> {
  __$IndexUnavailableCopyWithImpl(this._self, this._then);

  final _IndexUnavailable _self;
  final $Res Function(_IndexUnavailable) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_IndexUnavailable(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _InsufficientPermissions extends SearchFailure {
  const _InsufficientPermissions([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsufficientPermissionsCopyWith<_InsufficientPermissions> get copyWith => __$InsufficientPermissionsCopyWithImpl<_InsufficientPermissions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsufficientPermissions&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.insufficientPermissions(message: $message)';
}


}

/// @nodoc
abstract mixin class _$InsufficientPermissionsCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$InsufficientPermissionsCopyWith(_InsufficientPermissions value, $Res Function(_InsufficientPermissions) _then) = __$InsufficientPermissionsCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$InsufficientPermissionsCopyWithImpl<$Res>
    implements _$InsufficientPermissionsCopyWith<$Res> {
  __$InsufficientPermissionsCopyWithImpl(this._self, this._then);

  final _InsufficientPermissions _self;
  final $Res Function(_InsufficientPermissions) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_InsufficientPermissions(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Unexpected extends SearchFailure {
  const _Unexpected([this.message]): super._();
  

 final  String? message;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnexpectedCopyWith<_Unexpected> get copyWith => __$UnexpectedCopyWithImpl<_Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unexpected&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchFailure.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnexpectedCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory _$UnexpectedCopyWith(_Unexpected value, $Res Function(_Unexpected) _then) = __$UnexpectedCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$UnexpectedCopyWithImpl<$Res>
    implements _$UnexpectedCopyWith<$Res> {
  __$UnexpectedCopyWithImpl(this._self, this._then);

  final _Unexpected _self;
  final $Res Function(_Unexpected) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Unexpected(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
