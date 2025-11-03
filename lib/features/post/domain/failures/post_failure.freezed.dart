// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostFailure()';
}


}

/// @nodoc
class $PostFailureCopyWith<$Res>  {
$PostFailureCopyWith(PostFailure _, $Res Function(PostFailure) __);
}


/// Adds pattern-matching-related methods to [PostFailure].
extension PostFailurePatterns on PostFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkError value)?  networkError,TResult Function( ServerError value)?  serverError,TResult Function( TimeoutError value)?  timeout,TResult Function( InsufficientPermissions value)?  insufficientPermissions,TResult Function( Unauthorized value)?  unauthorized,TResult Function( PostNotFound value)?  postNotFound,TResult Function( UserNotFound value)?  userNotFound,TResult Function( InvalidInput value)?  invalidInput,TResult Function( ContentTooLong value)?  contentTooLong,TResult Function( CreateFailed value)?  createFailed,TResult Function( UpdateFailed value)?  updateFailed,TResult Function( DeleteFailed value)?  deleteFailed,TResult Function( SearchFailed value)?  searchFailed,TResult Function( QueryFailed value)?  queryFailed,TResult Function( Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkError() when networkError != null:
return networkError(_that);case ServerError() when serverError != null:
return serverError(_that);case TimeoutError() when timeout != null:
return timeout(_that);case InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions(_that);case Unauthorized() when unauthorized != null:
return unauthorized(_that);case PostNotFound() when postNotFound != null:
return postNotFound(_that);case UserNotFound() when userNotFound != null:
return userNotFound(_that);case InvalidInput() when invalidInput != null:
return invalidInput(_that);case ContentTooLong() when contentTooLong != null:
return contentTooLong(_that);case CreateFailed() when createFailed != null:
return createFailed(_that);case UpdateFailed() when updateFailed != null:
return updateFailed(_that);case DeleteFailed() when deleteFailed != null:
return deleteFailed(_that);case SearchFailed() when searchFailed != null:
return searchFailed(_that);case QueryFailed() when queryFailed != null:
return queryFailed(_that);case Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkError value)  networkError,required TResult Function( ServerError value)  serverError,required TResult Function( TimeoutError value)  timeout,required TResult Function( InsufficientPermissions value)  insufficientPermissions,required TResult Function( Unauthorized value)  unauthorized,required TResult Function( PostNotFound value)  postNotFound,required TResult Function( UserNotFound value)  userNotFound,required TResult Function( InvalidInput value)  invalidInput,required TResult Function( ContentTooLong value)  contentTooLong,required TResult Function( CreateFailed value)  createFailed,required TResult Function( UpdateFailed value)  updateFailed,required TResult Function( DeleteFailed value)  deleteFailed,required TResult Function( SearchFailed value)  searchFailed,required TResult Function( QueryFailed value)  queryFailed,required TResult Function( Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case NetworkError():
return networkError(_that);case ServerError():
return serverError(_that);case TimeoutError():
return timeout(_that);case InsufficientPermissions():
return insufficientPermissions(_that);case Unauthorized():
return unauthorized(_that);case PostNotFound():
return postNotFound(_that);case UserNotFound():
return userNotFound(_that);case InvalidInput():
return invalidInput(_that);case ContentTooLong():
return contentTooLong(_that);case CreateFailed():
return createFailed(_that);case UpdateFailed():
return updateFailed(_that);case DeleteFailed():
return deleteFailed(_that);case SearchFailed():
return searchFailed(_that);case QueryFailed():
return queryFailed(_that);case Unexpected():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkError value)?  networkError,TResult? Function( ServerError value)?  serverError,TResult? Function( TimeoutError value)?  timeout,TResult? Function( InsufficientPermissions value)?  insufficientPermissions,TResult? Function( Unauthorized value)?  unauthorized,TResult? Function( PostNotFound value)?  postNotFound,TResult? Function( UserNotFound value)?  userNotFound,TResult? Function( InvalidInput value)?  invalidInput,TResult? Function( ContentTooLong value)?  contentTooLong,TResult? Function( CreateFailed value)?  createFailed,TResult? Function( UpdateFailed value)?  updateFailed,TResult? Function( DeleteFailed value)?  deleteFailed,TResult? Function( SearchFailed value)?  searchFailed,TResult? Function( QueryFailed value)?  queryFailed,TResult? Function( Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case NetworkError() when networkError != null:
return networkError(_that);case ServerError() when serverError != null:
return serverError(_that);case TimeoutError() when timeout != null:
return timeout(_that);case InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions(_that);case Unauthorized() when unauthorized != null:
return unauthorized(_that);case PostNotFound() when postNotFound != null:
return postNotFound(_that);case UserNotFound() when userNotFound != null:
return userNotFound(_that);case InvalidInput() when invalidInput != null:
return invalidInput(_that);case ContentTooLong() when contentTooLong != null:
return contentTooLong(_that);case CreateFailed() when createFailed != null:
return createFailed(_that);case UpdateFailed() when updateFailed != null:
return updateFailed(_that);case DeleteFailed() when deleteFailed != null:
return deleteFailed(_that);case SearchFailed() when searchFailed != null:
return searchFailed(_that);case QueryFailed() when queryFailed != null:
return queryFailed(_that);case Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  networkError,TResult Function( String? message)?  serverError,TResult Function()?  timeout,TResult Function()?  insufficientPermissions,TResult Function()?  unauthorized,TResult Function( String postId)?  postNotFound,TResult Function( String userId)?  userNotFound,TResult Function( String field)?  invalidInput,TResult Function( int maxLength)?  contentTooLong,TResult Function( String? reason)?  createFailed,TResult Function( String? reason)?  updateFailed,TResult Function( String? reason)?  deleteFailed,TResult Function( String? query)?  searchFailed,TResult Function( String? reason)?  queryFailed,TResult Function( String? message,  Object? error,  StackTrace? stackTrace)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkError() when networkError != null:
return networkError();case ServerError() when serverError != null:
return serverError(_that.message);case TimeoutError() when timeout != null:
return timeout();case InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions();case Unauthorized() when unauthorized != null:
return unauthorized();case PostNotFound() when postNotFound != null:
return postNotFound(_that.postId);case UserNotFound() when userNotFound != null:
return userNotFound(_that.userId);case InvalidInput() when invalidInput != null:
return invalidInput(_that.field);case ContentTooLong() when contentTooLong != null:
return contentTooLong(_that.maxLength);case CreateFailed() when createFailed != null:
return createFailed(_that.reason);case UpdateFailed() when updateFailed != null:
return updateFailed(_that.reason);case DeleteFailed() when deleteFailed != null:
return deleteFailed(_that.reason);case SearchFailed() when searchFailed != null:
return searchFailed(_that.query);case QueryFailed() when queryFailed != null:
return queryFailed(_that.reason);case Unexpected() when unexpected != null:
return unexpected(_that.message,_that.error,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  networkError,required TResult Function( String? message)  serverError,required TResult Function()  timeout,required TResult Function()  insufficientPermissions,required TResult Function()  unauthorized,required TResult Function( String postId)  postNotFound,required TResult Function( String userId)  userNotFound,required TResult Function( String field)  invalidInput,required TResult Function( int maxLength)  contentTooLong,required TResult Function( String? reason)  createFailed,required TResult Function( String? reason)  updateFailed,required TResult Function( String? reason)  deleteFailed,required TResult Function( String? query)  searchFailed,required TResult Function( String? reason)  queryFailed,required TResult Function( String? message,  Object? error,  StackTrace? stackTrace)  unexpected,}) {final _that = this;
switch (_that) {
case NetworkError():
return networkError();case ServerError():
return serverError(_that.message);case TimeoutError():
return timeout();case InsufficientPermissions():
return insufficientPermissions();case Unauthorized():
return unauthorized();case PostNotFound():
return postNotFound(_that.postId);case UserNotFound():
return userNotFound(_that.userId);case InvalidInput():
return invalidInput(_that.field);case ContentTooLong():
return contentTooLong(_that.maxLength);case CreateFailed():
return createFailed(_that.reason);case UpdateFailed():
return updateFailed(_that.reason);case DeleteFailed():
return deleteFailed(_that.reason);case SearchFailed():
return searchFailed(_that.query);case QueryFailed():
return queryFailed(_that.reason);case Unexpected():
return unexpected(_that.message,_that.error,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  networkError,TResult? Function( String? message)?  serverError,TResult? Function()?  timeout,TResult? Function()?  insufficientPermissions,TResult? Function()?  unauthorized,TResult? Function( String postId)?  postNotFound,TResult? Function( String userId)?  userNotFound,TResult? Function( String field)?  invalidInput,TResult? Function( int maxLength)?  contentTooLong,TResult? Function( String? reason)?  createFailed,TResult? Function( String? reason)?  updateFailed,TResult? Function( String? reason)?  deleteFailed,TResult? Function( String? query)?  searchFailed,TResult? Function( String? reason)?  queryFailed,TResult? Function( String? message,  Object? error,  StackTrace? stackTrace)?  unexpected,}) {final _that = this;
switch (_that) {
case NetworkError() when networkError != null:
return networkError();case ServerError() when serverError != null:
return serverError(_that.message);case TimeoutError() when timeout != null:
return timeout();case InsufficientPermissions() when insufficientPermissions != null:
return insufficientPermissions();case Unauthorized() when unauthorized != null:
return unauthorized();case PostNotFound() when postNotFound != null:
return postNotFound(_that.postId);case UserNotFound() when userNotFound != null:
return userNotFound(_that.userId);case InvalidInput() when invalidInput != null:
return invalidInput(_that.field);case ContentTooLong() when contentTooLong != null:
return contentTooLong(_that.maxLength);case CreateFailed() when createFailed != null:
return createFailed(_that.reason);case UpdateFailed() when updateFailed != null:
return updateFailed(_that.reason);case DeleteFailed() when deleteFailed != null:
return deleteFailed(_that.reason);case SearchFailed() when searchFailed != null:
return searchFailed(_that.query);case QueryFailed() when queryFailed != null:
return queryFailed(_that.reason);case Unexpected() when unexpected != null:
return unexpected(_that.message,_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class NetworkError implements PostFailure {
  const NetworkError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostFailure.networkError()';
}


}




/// @nodoc


class ServerError implements PostFailure {
  const ServerError({this.message});
  

 final  String? message;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorCopyWith<ServerError> get copyWith => _$ServerErrorCopyWithImpl<ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostFailure.serverError(message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerErrorCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $ServerErrorCopyWith(ServerError value, $Res Function(ServerError) _then) = _$ServerErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$ServerErrorCopyWithImpl<$Res>
    implements $ServerErrorCopyWith<$Res> {
  _$ServerErrorCopyWithImpl(this._self, this._then);

  final ServerError _self;
  final $Res Function(ServerError) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(ServerError(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TimeoutError implements PostFailure {
  const TimeoutError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostFailure.timeout()';
}


}




/// @nodoc


class InsufficientPermissions implements PostFailure {
  const InsufficientPermissions();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsufficientPermissions);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostFailure.insufficientPermissions()';
}


}




/// @nodoc


class Unauthorized implements PostFailure {
  const Unauthorized();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unauthorized);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostFailure.unauthorized()';
}


}




/// @nodoc


class PostNotFound implements PostFailure {
  const PostNotFound({required this.postId});
  

 final  String postId;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostNotFoundCopyWith<PostNotFound> get copyWith => _$PostNotFoundCopyWithImpl<PostNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostNotFound&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode => Object.hash(runtimeType,postId);

@override
String toString() {
  return 'PostFailure.postNotFound(postId: $postId)';
}


}

/// @nodoc
abstract mixin class $PostNotFoundCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $PostNotFoundCopyWith(PostNotFound value, $Res Function(PostNotFound) _then) = _$PostNotFoundCopyWithImpl;
@useResult
$Res call({
 String postId
});




}
/// @nodoc
class _$PostNotFoundCopyWithImpl<$Res>
    implements $PostNotFoundCopyWith<$Res> {
  _$PostNotFoundCopyWithImpl(this._self, this._then);

  final PostNotFound _self;
  final $Res Function(PostNotFound) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? postId = null,}) {
  return _then(PostNotFound(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UserNotFound implements PostFailure {
  const UserNotFound({required this.userId});
  

 final  String userId;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserNotFoundCopyWith<UserNotFound> get copyWith => _$UserNotFoundCopyWithImpl<UserNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNotFound&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'PostFailure.userNotFound(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $UserNotFoundCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $UserNotFoundCopyWith(UserNotFound value, $Res Function(UserNotFound) _then) = _$UserNotFoundCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class _$UserNotFoundCopyWithImpl<$Res>
    implements $UserNotFoundCopyWith<$Res> {
  _$UserNotFoundCopyWithImpl(this._self, this._then);

  final UserNotFound _self;
  final $Res Function(UserNotFound) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(UserNotFound(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidInput implements PostFailure {
  const InvalidInput({required this.field});
  

 final  String field;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidInputCopyWith<InvalidInput> get copyWith => _$InvalidInputCopyWithImpl<InvalidInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidInput&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,field);

@override
String toString() {
  return 'PostFailure.invalidInput(field: $field)';
}


}

/// @nodoc
abstract mixin class $InvalidInputCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $InvalidInputCopyWith(InvalidInput value, $Res Function(InvalidInput) _then) = _$InvalidInputCopyWithImpl;
@useResult
$Res call({
 String field
});




}
/// @nodoc
class _$InvalidInputCopyWithImpl<$Res>
    implements $InvalidInputCopyWith<$Res> {
  _$InvalidInputCopyWithImpl(this._self, this._then);

  final InvalidInput _self;
  final $Res Function(InvalidInput) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field = null,}) {
  return _then(InvalidInput(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ContentTooLong implements PostFailure {
  const ContentTooLong({required this.maxLength});
  

 final  int maxLength;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentTooLongCopyWith<ContentTooLong> get copyWith => _$ContentTooLongCopyWithImpl<ContentTooLong>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentTooLong&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength));
}


@override
int get hashCode => Object.hash(runtimeType,maxLength);

@override
String toString() {
  return 'PostFailure.contentTooLong(maxLength: $maxLength)';
}


}

/// @nodoc
abstract mixin class $ContentTooLongCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $ContentTooLongCopyWith(ContentTooLong value, $Res Function(ContentTooLong) _then) = _$ContentTooLongCopyWithImpl;
@useResult
$Res call({
 int maxLength
});




}
/// @nodoc
class _$ContentTooLongCopyWithImpl<$Res>
    implements $ContentTooLongCopyWith<$Res> {
  _$ContentTooLongCopyWithImpl(this._self, this._then);

  final ContentTooLong _self;
  final $Res Function(ContentTooLong) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? maxLength = null,}) {
  return _then(ContentTooLong(
maxLength: null == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class CreateFailed implements PostFailure {
  const CreateFailed({this.reason});
  

 final  String? reason;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateFailedCopyWith<CreateFailed> get copyWith => _$CreateFailedCopyWithImpl<CreateFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateFailed&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'PostFailure.createFailed(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $CreateFailedCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $CreateFailedCopyWith(CreateFailed value, $Res Function(CreateFailed) _then) = _$CreateFailedCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$CreateFailedCopyWithImpl<$Res>
    implements $CreateFailedCopyWith<$Res> {
  _$CreateFailedCopyWithImpl(this._self, this._then);

  final CreateFailed _self;
  final $Res Function(CreateFailed) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(CreateFailed(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class UpdateFailed implements PostFailure {
  const UpdateFailed({this.reason});
  

 final  String? reason;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateFailedCopyWith<UpdateFailed> get copyWith => _$UpdateFailedCopyWithImpl<UpdateFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateFailed&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'PostFailure.updateFailed(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $UpdateFailedCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $UpdateFailedCopyWith(UpdateFailed value, $Res Function(UpdateFailed) _then) = _$UpdateFailedCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$UpdateFailedCopyWithImpl<$Res>
    implements $UpdateFailedCopyWith<$Res> {
  _$UpdateFailedCopyWithImpl(this._self, this._then);

  final UpdateFailed _self;
  final $Res Function(UpdateFailed) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(UpdateFailed(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DeleteFailed implements PostFailure {
  const DeleteFailed({this.reason});
  

 final  String? reason;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteFailedCopyWith<DeleteFailed> get copyWith => _$DeleteFailedCopyWithImpl<DeleteFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteFailed&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'PostFailure.deleteFailed(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $DeleteFailedCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $DeleteFailedCopyWith(DeleteFailed value, $Res Function(DeleteFailed) _then) = _$DeleteFailedCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$DeleteFailedCopyWithImpl<$Res>
    implements $DeleteFailedCopyWith<$Res> {
  _$DeleteFailedCopyWithImpl(this._self, this._then);

  final DeleteFailed _self;
  final $Res Function(DeleteFailed) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(DeleteFailed(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SearchFailed implements PostFailure {
  const SearchFailed({this.query});
  

 final  String? query;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFailedCopyWith<SearchFailed> get copyWith => _$SearchFailedCopyWithImpl<SearchFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFailed&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'PostFailure.searchFailed(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchFailedCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $SearchFailedCopyWith(SearchFailed value, $Res Function(SearchFailed) _then) = _$SearchFailedCopyWithImpl;
@useResult
$Res call({
 String? query
});




}
/// @nodoc
class _$SearchFailedCopyWithImpl<$Res>
    implements $SearchFailedCopyWith<$Res> {
  _$SearchFailedCopyWithImpl(this._self, this._then);

  final SearchFailed _self;
  final $Res Function(SearchFailed) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = freezed,}) {
  return _then(SearchFailed(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class QueryFailed implements PostFailure {
  const QueryFailed({this.reason});
  

 final  String? reason;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueryFailedCopyWith<QueryFailed> get copyWith => _$QueryFailedCopyWithImpl<QueryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueryFailed&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'PostFailure.queryFailed(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $QueryFailedCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $QueryFailedCopyWith(QueryFailed value, $Res Function(QueryFailed) _then) = _$QueryFailedCopyWithImpl;
@useResult
$Res call({
 String? reason
});




}
/// @nodoc
class _$QueryFailedCopyWithImpl<$Res>
    implements $QueryFailedCopyWith<$Res> {
  _$QueryFailedCopyWithImpl(this._self, this._then);

  final QueryFailed _self;
  final $Res Function(QueryFailed) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,}) {
  return _then(QueryFailed(
reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class Unexpected implements PostFailure {
  const Unexpected({this.message, this.error, this.stackTrace});
  

 final  String? message;
 final  Object? error;
 final  StackTrace? stackTrace;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedCopyWith<Unexpected> get copyWith => _$UnexpectedCopyWithImpl<Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unexpected&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'PostFailure.unexpected(message: $message, error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $UnexpectedCopyWith<$Res> implements $PostFailureCopyWith<$Res> {
  factory $UnexpectedCopyWith(Unexpected value, $Res Function(Unexpected) _then) = _$UnexpectedCopyWithImpl;
@useResult
$Res call({
 String? message, Object? error, StackTrace? stackTrace
});




}
/// @nodoc
class _$UnexpectedCopyWithImpl<$Res>
    implements $UnexpectedCopyWith<$Res> {
  _$UnexpectedCopyWithImpl(this._self, this._then);

  final Unexpected _self;
  final $Res Function(Unexpected) _then;

/// Create a copy of PostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? error = freezed,Object? stackTrace = freezed,}) {
  return _then(Unexpected(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error ,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
