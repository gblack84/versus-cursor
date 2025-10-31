// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voting_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VotingFailure {

 String? get message;
/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VotingFailureCopyWith<VotingFailure> get copyWith => _$VotingFailureCopyWithImpl<VotingFailure>(this as VotingFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VotingFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure(message: $message)';
}


}

/// @nodoc
abstract mixin class $VotingFailureCopyWith<$Res>  {
  factory $VotingFailureCopyWith(VotingFailure value, $Res Function(VotingFailure) _then) = _$VotingFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$VotingFailureCopyWithImpl<$Res>
    implements $VotingFailureCopyWith<$Res> {
  _$VotingFailureCopyWithImpl(this._self, this._then);

  final VotingFailure _self;
  final $Res Function(VotingFailure) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message! : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VotingFailure].
extension VotingFailurePatterns on VotingFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _NetworkError value)?  networkError,TResult Function( _Timeout value)?  timeout,TResult Function( _ServerError value)?  serverError,TResult Function( _NotFound value)?  notFound,TResult Function( _PermissionDenied value)?  permissionDenied,TResult Function( _Unauthenticated value)?  unauthenticated,TResult Function( _Unauthorized value)?  unauthorized,TResult Function( _AlreadyExists value)?  alreadyExists,TResult Function( _QuotaExceeded value)?  quotaExceeded,TResult Function( _Cancelled value)?  cancelled,TResult Function( _Aborted value)?  aborted,TResult Function( _InvalidArgument value)?  invalidArgument,TResult Function( _InvalidData value)?  invalidData,TResult Function( _FailedPrecondition value)?  failedPrecondition,TResult Function( _AlreadyVoted value)?  alreadyVoted,TResult Function( _VotingClosed value)?  votingClosed,TResult Function( _CacheError value)?  cacheError,TResult Function( _Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that);case _Timeout() when timeout != null:
return timeout(_that);case _ServerError() when serverError != null:
return serverError(_that);case _NotFound() when notFound != null:
return notFound(_that);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Unauthorized() when unauthorized != null:
return unauthorized(_that);case _AlreadyExists() when alreadyExists != null:
return alreadyExists(_that);case _QuotaExceeded() when quotaExceeded != null:
return quotaExceeded(_that);case _Cancelled() when cancelled != null:
return cancelled(_that);case _Aborted() when aborted != null:
return aborted(_that);case _InvalidArgument() when invalidArgument != null:
return invalidArgument(_that);case _InvalidData() when invalidData != null:
return invalidData(_that);case _FailedPrecondition() when failedPrecondition != null:
return failedPrecondition(_that);case _AlreadyVoted() when alreadyVoted != null:
return alreadyVoted(_that);case _VotingClosed() when votingClosed != null:
return votingClosed(_that);case _CacheError() when cacheError != null:
return cacheError(_that);case _Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _NetworkError value)  networkError,required TResult Function( _Timeout value)  timeout,required TResult Function( _ServerError value)  serverError,required TResult Function( _NotFound value)  notFound,required TResult Function( _PermissionDenied value)  permissionDenied,required TResult Function( _Unauthenticated value)  unauthenticated,required TResult Function( _Unauthorized value)  unauthorized,required TResult Function( _AlreadyExists value)  alreadyExists,required TResult Function( _QuotaExceeded value)  quotaExceeded,required TResult Function( _Cancelled value)  cancelled,required TResult Function( _Aborted value)  aborted,required TResult Function( _InvalidArgument value)  invalidArgument,required TResult Function( _InvalidData value)  invalidData,required TResult Function( _FailedPrecondition value)  failedPrecondition,required TResult Function( _AlreadyVoted value)  alreadyVoted,required TResult Function( _VotingClosed value)  votingClosed,required TResult Function( _CacheError value)  cacheError,required TResult Function( _Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case _NetworkError():
return networkError(_that);case _Timeout():
return timeout(_that);case _ServerError():
return serverError(_that);case _NotFound():
return notFound(_that);case _PermissionDenied():
return permissionDenied(_that);case _Unauthenticated():
return unauthenticated(_that);case _Unauthorized():
return unauthorized(_that);case _AlreadyExists():
return alreadyExists(_that);case _QuotaExceeded():
return quotaExceeded(_that);case _Cancelled():
return cancelled(_that);case _Aborted():
return aborted(_that);case _InvalidArgument():
return invalidArgument(_that);case _InvalidData():
return invalidData(_that);case _FailedPrecondition():
return failedPrecondition(_that);case _AlreadyVoted():
return alreadyVoted(_that);case _VotingClosed():
return votingClosed(_that);case _CacheError():
return cacheError(_that);case _Unexpected():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _NetworkError value)?  networkError,TResult? Function( _Timeout value)?  timeout,TResult? Function( _ServerError value)?  serverError,TResult? Function( _NotFound value)?  notFound,TResult? Function( _PermissionDenied value)?  permissionDenied,TResult? Function( _Unauthenticated value)?  unauthenticated,TResult? Function( _Unauthorized value)?  unauthorized,TResult? Function( _AlreadyExists value)?  alreadyExists,TResult? Function( _QuotaExceeded value)?  quotaExceeded,TResult? Function( _Cancelled value)?  cancelled,TResult? Function( _Aborted value)?  aborted,TResult? Function( _InvalidArgument value)?  invalidArgument,TResult? Function( _InvalidData value)?  invalidData,TResult? Function( _FailedPrecondition value)?  failedPrecondition,TResult? Function( _AlreadyVoted value)?  alreadyVoted,TResult? Function( _VotingClosed value)?  votingClosed,TResult? Function( _CacheError value)?  cacheError,TResult? Function( _Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that);case _Timeout() when timeout != null:
return timeout(_that);case _ServerError() when serverError != null:
return serverError(_that);case _NotFound() when notFound != null:
return notFound(_that);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Unauthorized() when unauthorized != null:
return unauthorized(_that);case _AlreadyExists() when alreadyExists != null:
return alreadyExists(_that);case _QuotaExceeded() when quotaExceeded != null:
return quotaExceeded(_that);case _Cancelled() when cancelled != null:
return cancelled(_that);case _Aborted() when aborted != null:
return aborted(_that);case _InvalidArgument() when invalidArgument != null:
return invalidArgument(_that);case _InvalidData() when invalidData != null:
return invalidData(_that);case _FailedPrecondition() when failedPrecondition != null:
return failedPrecondition(_that);case _AlreadyVoted() when alreadyVoted != null:
return alreadyVoted(_that);case _VotingClosed() when votingClosed != null:
return votingClosed(_that);case _CacheError() when cacheError != null:
return cacheError(_that);case _Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message)?  networkError,TResult Function( String? message)?  timeout,TResult Function( String? message)?  serverError,TResult Function( String? message)?  notFound,TResult Function( String? message)?  permissionDenied,TResult Function( String? message)?  unauthenticated,TResult Function( String? message)?  unauthorized,TResult Function( String? message)?  alreadyExists,TResult Function( String? message)?  quotaExceeded,TResult Function( String? message)?  cancelled,TResult Function( String? message)?  aborted,TResult Function( String? message)?  invalidArgument,TResult Function( String? message)?  invalidData,TResult Function( String? message)?  failedPrecondition,TResult Function( String? message)?  alreadyVoted,TResult Function( String? message)?  votingClosed,TResult Function( String? message)?  cacheError,TResult Function( String message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that.message);case _Timeout() when timeout != null:
return timeout(_that.message);case _ServerError() when serverError != null:
return serverError(_that.message);case _NotFound() when notFound != null:
return notFound(_that.message);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that.message);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that.message);case _Unauthorized() when unauthorized != null:
return unauthorized(_that.message);case _AlreadyExists() when alreadyExists != null:
return alreadyExists(_that.message);case _QuotaExceeded() when quotaExceeded != null:
return quotaExceeded(_that.message);case _Cancelled() when cancelled != null:
return cancelled(_that.message);case _Aborted() when aborted != null:
return aborted(_that.message);case _InvalidArgument() when invalidArgument != null:
return invalidArgument(_that.message);case _InvalidData() when invalidData != null:
return invalidData(_that.message);case _FailedPrecondition() when failedPrecondition != null:
return failedPrecondition(_that.message);case _AlreadyVoted() when alreadyVoted != null:
return alreadyVoted(_that.message);case _VotingClosed() when votingClosed != null:
return votingClosed(_that.message);case _CacheError() when cacheError != null:
return cacheError(_that.message);case _Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message)  networkError,required TResult Function( String? message)  timeout,required TResult Function( String? message)  serverError,required TResult Function( String? message)  notFound,required TResult Function( String? message)  permissionDenied,required TResult Function( String? message)  unauthenticated,required TResult Function( String? message)  unauthorized,required TResult Function( String? message)  alreadyExists,required TResult Function( String? message)  quotaExceeded,required TResult Function( String? message)  cancelled,required TResult Function( String? message)  aborted,required TResult Function( String? message)  invalidArgument,required TResult Function( String? message)  invalidData,required TResult Function( String? message)  failedPrecondition,required TResult Function( String? message)  alreadyVoted,required TResult Function( String? message)  votingClosed,required TResult Function( String? message)  cacheError,required TResult Function( String message)  unexpected,}) {final _that = this;
switch (_that) {
case _NetworkError():
return networkError(_that.message);case _Timeout():
return timeout(_that.message);case _ServerError():
return serverError(_that.message);case _NotFound():
return notFound(_that.message);case _PermissionDenied():
return permissionDenied(_that.message);case _Unauthenticated():
return unauthenticated(_that.message);case _Unauthorized():
return unauthorized(_that.message);case _AlreadyExists():
return alreadyExists(_that.message);case _QuotaExceeded():
return quotaExceeded(_that.message);case _Cancelled():
return cancelled(_that.message);case _Aborted():
return aborted(_that.message);case _InvalidArgument():
return invalidArgument(_that.message);case _InvalidData():
return invalidData(_that.message);case _FailedPrecondition():
return failedPrecondition(_that.message);case _AlreadyVoted():
return alreadyVoted(_that.message);case _VotingClosed():
return votingClosed(_that.message);case _CacheError():
return cacheError(_that.message);case _Unexpected():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message)?  networkError,TResult? Function( String? message)?  timeout,TResult? Function( String? message)?  serverError,TResult? Function( String? message)?  notFound,TResult? Function( String? message)?  permissionDenied,TResult? Function( String? message)?  unauthenticated,TResult? Function( String? message)?  unauthorized,TResult? Function( String? message)?  alreadyExists,TResult? Function( String? message)?  quotaExceeded,TResult? Function( String? message)?  cancelled,TResult? Function( String? message)?  aborted,TResult? Function( String? message)?  invalidArgument,TResult? Function( String? message)?  invalidData,TResult? Function( String? message)?  failedPrecondition,TResult? Function( String? message)?  alreadyVoted,TResult? Function( String? message)?  votingClosed,TResult? Function( String? message)?  cacheError,TResult? Function( String message)?  unexpected,}) {final _that = this;
switch (_that) {
case _NetworkError() when networkError != null:
return networkError(_that.message);case _Timeout() when timeout != null:
return timeout(_that.message);case _ServerError() when serverError != null:
return serverError(_that.message);case _NotFound() when notFound != null:
return notFound(_that.message);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that.message);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that.message);case _Unauthorized() when unauthorized != null:
return unauthorized(_that.message);case _AlreadyExists() when alreadyExists != null:
return alreadyExists(_that.message);case _QuotaExceeded() when quotaExceeded != null:
return quotaExceeded(_that.message);case _Cancelled() when cancelled != null:
return cancelled(_that.message);case _Aborted() when aborted != null:
return aborted(_that.message);case _InvalidArgument() when invalidArgument != null:
return invalidArgument(_that.message);case _InvalidData() when invalidData != null:
return invalidData(_that.message);case _FailedPrecondition() when failedPrecondition != null:
return failedPrecondition(_that.message);case _AlreadyVoted() when alreadyVoted != null:
return alreadyVoted(_that.message);case _VotingClosed() when votingClosed != null:
return votingClosed(_that.message);case _CacheError() when cacheError != null:
return cacheError(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkError extends VotingFailure {
  const _NetworkError([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
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
  return 'VotingFailure.networkError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NetworkErrorCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$NetworkErrorCopyWith(_NetworkError value, $Res Function(_NetworkError) _then) = __$NetworkErrorCopyWithImpl;
@override @useResult
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

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_NetworkError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Timeout extends VotingFailure {
  const _Timeout([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
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
  return 'VotingFailure.timeout(message: $message)';
}


}

/// @nodoc
abstract mixin class _$TimeoutCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$TimeoutCopyWith(_Timeout value, $Res Function(_Timeout) _then) = __$TimeoutCopyWithImpl;
@override @useResult
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

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Timeout(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ServerError extends VotingFailure {
  const _ServerError([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerErrorCopyWith<_ServerError> get copyWith => __$ServerErrorCopyWithImpl<_ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.serverError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ServerErrorCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$ServerErrorCopyWith(_ServerError value, $Res Function(_ServerError) _then) = __$ServerErrorCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$ServerErrorCopyWithImpl<$Res>
    implements _$ServerErrorCopyWith<$Res> {
  __$ServerErrorCopyWithImpl(this._self, this._then);

  final _ServerError _self;
  final $Res Function(_ServerError) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_ServerError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _NotFound extends VotingFailure {
  const _NotFound([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
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
  return 'VotingFailure.notFound(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NotFoundCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$NotFoundCopyWith(_NotFound value, $Res Function(_NotFound) _then) = __$NotFoundCopyWithImpl;
@override @useResult
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

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_NotFound(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _PermissionDenied extends VotingFailure {
  const _PermissionDenied([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PermissionDeniedCopyWith<_PermissionDenied> get copyWith => __$PermissionDeniedCopyWithImpl<_PermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionDenied&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.permissionDenied(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PermissionDeniedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$PermissionDeniedCopyWith(_PermissionDenied value, $Res Function(_PermissionDenied) _then) = __$PermissionDeniedCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$PermissionDeniedCopyWithImpl<$Res>
    implements _$PermissionDeniedCopyWith<$Res> {
  __$PermissionDeniedCopyWithImpl(this._self, this._then);

  final _PermissionDenied _self;
  final $Res Function(_PermissionDenied) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_PermissionDenied(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Unauthenticated extends VotingFailure {
  const _Unauthenticated([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnauthenticatedCopyWith<_Unauthenticated> get copyWith => __$UnauthenticatedCopyWithImpl<_Unauthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthenticated&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.unauthenticated(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnauthenticatedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$UnauthenticatedCopyWith(_Unauthenticated value, $Res Function(_Unauthenticated) _then) = __$UnauthenticatedCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$UnauthenticatedCopyWithImpl<$Res>
    implements _$UnauthenticatedCopyWith<$Res> {
  __$UnauthenticatedCopyWithImpl(this._self, this._then);

  final _Unauthenticated _self;
  final $Res Function(_Unauthenticated) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Unauthenticated(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Unauthorized extends VotingFailure {
  const _Unauthorized([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnauthorizedCopyWith<_Unauthorized> get copyWith => __$UnauthorizedCopyWithImpl<_Unauthorized>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthorized&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.unauthorized(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnauthorizedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$UnauthorizedCopyWith(_Unauthorized value, $Res Function(_Unauthorized) _then) = __$UnauthorizedCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$UnauthorizedCopyWithImpl<$Res>
    implements _$UnauthorizedCopyWith<$Res> {
  __$UnauthorizedCopyWithImpl(this._self, this._then);

  final _Unauthorized _self;
  final $Res Function(_Unauthorized) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Unauthorized(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _AlreadyExists extends VotingFailure {
  const _AlreadyExists([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlreadyExistsCopyWith<_AlreadyExists> get copyWith => __$AlreadyExistsCopyWithImpl<_AlreadyExists>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlreadyExists&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.alreadyExists(message: $message)';
}


}

/// @nodoc
abstract mixin class _$AlreadyExistsCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$AlreadyExistsCopyWith(_AlreadyExists value, $Res Function(_AlreadyExists) _then) = __$AlreadyExistsCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$AlreadyExistsCopyWithImpl<$Res>
    implements _$AlreadyExistsCopyWith<$Res> {
  __$AlreadyExistsCopyWithImpl(this._self, this._then);

  final _AlreadyExists _self;
  final $Res Function(_AlreadyExists) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_AlreadyExists(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _QuotaExceeded extends VotingFailure {
  const _QuotaExceeded([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotaExceededCopyWith<_QuotaExceeded> get copyWith => __$QuotaExceededCopyWithImpl<_QuotaExceeded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotaExceeded&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.quotaExceeded(message: $message)';
}


}

/// @nodoc
abstract mixin class _$QuotaExceededCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$QuotaExceededCopyWith(_QuotaExceeded value, $Res Function(_QuotaExceeded) _then) = __$QuotaExceededCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$QuotaExceededCopyWithImpl<$Res>
    implements _$QuotaExceededCopyWith<$Res> {
  __$QuotaExceededCopyWithImpl(this._self, this._then);

  final _QuotaExceeded _self;
  final $Res Function(_QuotaExceeded) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_QuotaExceeded(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Cancelled extends VotingFailure {
  const _Cancelled([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelledCopyWith<_Cancelled> get copyWith => __$CancelledCopyWithImpl<_Cancelled>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cancelled&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.cancelled(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CancelledCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$CancelledCopyWith(_Cancelled value, $Res Function(_Cancelled) _then) = __$CancelledCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$CancelledCopyWithImpl<$Res>
    implements _$CancelledCopyWith<$Res> {
  __$CancelledCopyWithImpl(this._self, this._then);

  final _Cancelled _self;
  final $Res Function(_Cancelled) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Cancelled(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Aborted extends VotingFailure {
  const _Aborted([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbortedCopyWith<_Aborted> get copyWith => __$AbortedCopyWithImpl<_Aborted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Aborted&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.aborted(message: $message)';
}


}

/// @nodoc
abstract mixin class _$AbortedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$AbortedCopyWith(_Aborted value, $Res Function(_Aborted) _then) = __$AbortedCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$AbortedCopyWithImpl<$Res>
    implements _$AbortedCopyWith<$Res> {
  __$AbortedCopyWithImpl(this._self, this._then);

  final _Aborted _self;
  final $Res Function(_Aborted) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Aborted(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _InvalidArgument extends VotingFailure {
  const _InvalidArgument([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidArgumentCopyWith<_InvalidArgument> get copyWith => __$InvalidArgumentCopyWithImpl<_InvalidArgument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidArgument&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.invalidArgument(message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvalidArgumentCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$InvalidArgumentCopyWith(_InvalidArgument value, $Res Function(_InvalidArgument) _then) = __$InvalidArgumentCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$InvalidArgumentCopyWithImpl<$Res>
    implements _$InvalidArgumentCopyWith<$Res> {
  __$InvalidArgumentCopyWithImpl(this._self, this._then);

  final _InvalidArgument _self;
  final $Res Function(_InvalidArgument) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_InvalidArgument(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _InvalidData extends VotingFailure {
  const _InvalidData([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidDataCopyWith<_InvalidData> get copyWith => __$InvalidDataCopyWithImpl<_InvalidData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidData&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.invalidData(message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvalidDataCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$InvalidDataCopyWith(_InvalidData value, $Res Function(_InvalidData) _then) = __$InvalidDataCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$InvalidDataCopyWithImpl<$Res>
    implements _$InvalidDataCopyWith<$Res> {
  __$InvalidDataCopyWithImpl(this._self, this._then);

  final _InvalidData _self;
  final $Res Function(_InvalidData) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_InvalidData(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _FailedPrecondition extends VotingFailure {
  const _FailedPrecondition([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailedPreconditionCopyWith<_FailedPrecondition> get copyWith => __$FailedPreconditionCopyWithImpl<_FailedPrecondition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FailedPrecondition&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.failedPrecondition(message: $message)';
}


}

/// @nodoc
abstract mixin class _$FailedPreconditionCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$FailedPreconditionCopyWith(_FailedPrecondition value, $Res Function(_FailedPrecondition) _then) = __$FailedPreconditionCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$FailedPreconditionCopyWithImpl<$Res>
    implements _$FailedPreconditionCopyWith<$Res> {
  __$FailedPreconditionCopyWithImpl(this._self, this._then);

  final _FailedPrecondition _self;
  final $Res Function(_FailedPrecondition) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_FailedPrecondition(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _AlreadyVoted extends VotingFailure {
  const _AlreadyVoted([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlreadyVotedCopyWith<_AlreadyVoted> get copyWith => __$AlreadyVotedCopyWithImpl<_AlreadyVoted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlreadyVoted&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.alreadyVoted(message: $message)';
}


}

/// @nodoc
abstract mixin class _$AlreadyVotedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$AlreadyVotedCopyWith(_AlreadyVoted value, $Res Function(_AlreadyVoted) _then) = __$AlreadyVotedCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$AlreadyVotedCopyWithImpl<$Res>
    implements _$AlreadyVotedCopyWith<$Res> {
  __$AlreadyVotedCopyWithImpl(this._self, this._then);

  final _AlreadyVoted _self;
  final $Res Function(_AlreadyVoted) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_AlreadyVoted(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _VotingClosed extends VotingFailure {
  const _VotingClosed([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VotingClosedCopyWith<_VotingClosed> get copyWith => __$VotingClosedCopyWithImpl<_VotingClosed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VotingClosed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.votingClosed(message: $message)';
}


}

/// @nodoc
abstract mixin class _$VotingClosedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$VotingClosedCopyWith(_VotingClosed value, $Res Function(_VotingClosed) _then) = __$VotingClosedCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$VotingClosedCopyWithImpl<$Res>
    implements _$VotingClosedCopyWith<$Res> {
  __$VotingClosedCopyWithImpl(this._self, this._then);

  final _VotingClosed _self;
  final $Res Function(_VotingClosed) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_VotingClosed(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _CacheError extends VotingFailure {
  const _CacheError([this.message]): super._();
  

@override final  String? message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CacheErrorCopyWith<_CacheError> get copyWith => __$CacheErrorCopyWithImpl<_CacheError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CacheError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VotingFailure.cacheError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CacheErrorCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$CacheErrorCopyWith(_CacheError value, $Res Function(_CacheError) _then) = __$CacheErrorCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$CacheErrorCopyWithImpl<$Res>
    implements _$CacheErrorCopyWith<$Res> {
  __$CacheErrorCopyWithImpl(this._self, this._then);

  final _CacheError _self;
  final $Res Function(_CacheError) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_CacheError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Unexpected extends VotingFailure {
  const _Unexpected(this.message): super._();
  

@override final  String message;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
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
  return 'VotingFailure.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnexpectedCopyWith<$Res> implements $VotingFailureCopyWith<$Res> {
  factory _$UnexpectedCopyWith(_Unexpected value, $Res Function(_Unexpected) _then) = __$UnexpectedCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$UnexpectedCopyWithImpl<$Res>
    implements _$UnexpectedCopyWith<$Res> {
  __$UnexpectedCopyWithImpl(this._self, this._then);

  final _Unexpected _self;
  final $Res Function(_Unexpected) _then;

/// Create a copy of VotingFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Unexpected(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
