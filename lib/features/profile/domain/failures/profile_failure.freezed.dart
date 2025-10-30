// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFailure&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}

/// @nodoc
class $ProfileFailureCopyWith<$Res>  {
$ProfileFailureCopyWith(ProfileFailure _, $Res Function(ProfileFailure) __);
}


/// Adds pattern-matching-related methods to [ProfileFailure].
extension ProfileFailurePatterns on ProfileFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ValidationFailure value)?  validation,TResult Function( ProfileNotFound value)?  profileNotFound,TResult Function( FirestoreRead value)?  firestoreRead,TResult Function( FirestoreWrite value)?  firestoreWrite,TResult Function( StorageFailure value)?  storage,TResult Function( NetworkFailure value)?  network,TResult Function( PermissionDenied value)?  permissionDenied,TResult Function( AuthenticationRequired value)?  authenticationRequired,TResult Function( UnauthorizedAccess value)?  unauthorizedAccess,TResult Function( CacheFailure value)?  cache,TResult Function( DuplicateOperation value)?  duplicateOperation,TResult Function( UnknownProfile value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ValidationFailure() when validation != null:
return validation(_that);case ProfileNotFound() when profileNotFound != null:
return profileNotFound(_that);case FirestoreRead() when firestoreRead != null:
return firestoreRead(_that);case FirestoreWrite() when firestoreWrite != null:
return firestoreWrite(_that);case StorageFailure() when storage != null:
return storage(_that);case NetworkFailure() when network != null:
return network(_that);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case AuthenticationRequired() when authenticationRequired != null:
return authenticationRequired(_that);case UnauthorizedAccess() when unauthorizedAccess != null:
return unauthorizedAccess(_that);case CacheFailure() when cache != null:
return cache(_that);case DuplicateOperation() when duplicateOperation != null:
return duplicateOperation(_that);case UnknownProfile() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ValidationFailure value)  validation,required TResult Function( ProfileNotFound value)  profileNotFound,required TResult Function( FirestoreRead value)  firestoreRead,required TResult Function( FirestoreWrite value)  firestoreWrite,required TResult Function( StorageFailure value)  storage,required TResult Function( NetworkFailure value)  network,required TResult Function( PermissionDenied value)  permissionDenied,required TResult Function( AuthenticationRequired value)  authenticationRequired,required TResult Function( UnauthorizedAccess value)  unauthorizedAccess,required TResult Function( CacheFailure value)  cache,required TResult Function( DuplicateOperation value)  duplicateOperation,required TResult Function( UnknownProfile value)  unknown,}){
final _that = this;
switch (_that) {
case ValidationFailure():
return validation(_that);case ProfileNotFound():
return profileNotFound(_that);case FirestoreRead():
return firestoreRead(_that);case FirestoreWrite():
return firestoreWrite(_that);case StorageFailure():
return storage(_that);case NetworkFailure():
return network(_that);case PermissionDenied():
return permissionDenied(_that);case AuthenticationRequired():
return authenticationRequired(_that);case UnauthorizedAccess():
return unauthorizedAccess(_that);case CacheFailure():
return cache(_that);case DuplicateOperation():
return duplicateOperation(_that);case UnknownProfile():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ValidationFailure value)?  validation,TResult? Function( ProfileNotFound value)?  profileNotFound,TResult? Function( FirestoreRead value)?  firestoreRead,TResult? Function( FirestoreWrite value)?  firestoreWrite,TResult? Function( StorageFailure value)?  storage,TResult? Function( NetworkFailure value)?  network,TResult? Function( PermissionDenied value)?  permissionDenied,TResult? Function( AuthenticationRequired value)?  authenticationRequired,TResult? Function( UnauthorizedAccess value)?  unauthorizedAccess,TResult? Function( CacheFailure value)?  cache,TResult? Function( DuplicateOperation value)?  duplicateOperation,TResult? Function( UnknownProfile value)?  unknown,}){
final _that = this;
switch (_that) {
case ValidationFailure() when validation != null:
return validation(_that);case ProfileNotFound() when profileNotFound != null:
return profileNotFound(_that);case FirestoreRead() when firestoreRead != null:
return firestoreRead(_that);case FirestoreWrite() when firestoreWrite != null:
return firestoreWrite(_that);case StorageFailure() when storage != null:
return storage(_that);case NetworkFailure() when network != null:
return network(_that);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case AuthenticationRequired() when authenticationRequired != null:
return authenticationRequired(_that);case UnauthorizedAccess() when unauthorizedAccess != null:
return unauthorizedAccess(_that);case CacheFailure() when cache != null:
return cache(_that);case DuplicateOperation() when duplicateOperation != null:
return duplicateOperation(_that);case UnknownProfile() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String field)?  validation,TResult Function( String? userId)?  profileNotFound,TResult Function( String operation)?  firestoreRead,TResult Function( String operation)?  firestoreWrite,TResult Function( String operation)?  storage,TResult Function()?  network,TResult Function( String resource)?  permissionDenied,TResult Function()?  authenticationRequired,TResult Function( String message)?  unauthorizedAccess,TResult Function( String operation)?  cache,TResult Function( String message)?  duplicateOperation,TResult Function( String? error)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ValidationFailure() when validation != null:
return validation(_that.field);case ProfileNotFound() when profileNotFound != null:
return profileNotFound(_that.userId);case FirestoreRead() when firestoreRead != null:
return firestoreRead(_that.operation);case FirestoreWrite() when firestoreWrite != null:
return firestoreWrite(_that.operation);case StorageFailure() when storage != null:
return storage(_that.operation);case NetworkFailure() when network != null:
return network();case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that.resource);case AuthenticationRequired() when authenticationRequired != null:
return authenticationRequired();case UnauthorizedAccess() when unauthorizedAccess != null:
return unauthorizedAccess(_that.message);case CacheFailure() when cache != null:
return cache(_that.operation);case DuplicateOperation() when duplicateOperation != null:
return duplicateOperation(_that.message);case UnknownProfile() when unknown != null:
return unknown(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String field)  validation,required TResult Function( String? userId)  profileNotFound,required TResult Function( String operation)  firestoreRead,required TResult Function( String operation)  firestoreWrite,required TResult Function( String operation)  storage,required TResult Function()  network,required TResult Function( String resource)  permissionDenied,required TResult Function()  authenticationRequired,required TResult Function( String message)  unauthorizedAccess,required TResult Function( String operation)  cache,required TResult Function( String message)  duplicateOperation,required TResult Function( String? error)  unknown,}) {final _that = this;
switch (_that) {
case ValidationFailure():
return validation(_that.field);case ProfileNotFound():
return profileNotFound(_that.userId);case FirestoreRead():
return firestoreRead(_that.operation);case FirestoreWrite():
return firestoreWrite(_that.operation);case StorageFailure():
return storage(_that.operation);case NetworkFailure():
return network();case PermissionDenied():
return permissionDenied(_that.resource);case AuthenticationRequired():
return authenticationRequired();case UnauthorizedAccess():
return unauthorizedAccess(_that.message);case CacheFailure():
return cache(_that.operation);case DuplicateOperation():
return duplicateOperation(_that.message);case UnknownProfile():
return unknown(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String field)?  validation,TResult? Function( String? userId)?  profileNotFound,TResult? Function( String operation)?  firestoreRead,TResult? Function( String operation)?  firestoreWrite,TResult? Function( String operation)?  storage,TResult? Function()?  network,TResult? Function( String resource)?  permissionDenied,TResult? Function()?  authenticationRequired,TResult? Function( String message)?  unauthorizedAccess,TResult? Function( String operation)?  cache,TResult? Function( String message)?  duplicateOperation,TResult? Function( String? error)?  unknown,}) {final _that = this;
switch (_that) {
case ValidationFailure() when validation != null:
return validation(_that.field);case ProfileNotFound() when profileNotFound != null:
return profileNotFound(_that.userId);case FirestoreRead() when firestoreRead != null:
return firestoreRead(_that.operation);case FirestoreWrite() when firestoreWrite != null:
return firestoreWrite(_that.operation);case StorageFailure() when storage != null:
return storage(_that.operation);case NetworkFailure() when network != null:
return network();case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that.resource);case AuthenticationRequired() when authenticationRequired != null:
return authenticationRequired();case UnauthorizedAccess() when unauthorizedAccess != null:
return unauthorizedAccess(_that.message);case CacheFailure() when cache != null:
return cache(_that.operation);case DuplicateOperation() when duplicateOperation != null:
return duplicateOperation(_that.message);case UnknownProfile() when unknown != null:
return unknown(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ValidationFailure extends ProfileFailure {
  const ValidationFailure(this.field): super._();
  

 final  String field;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationFailureCopyWith<ValidationFailure> get copyWith => _$ValidationFailureCopyWithImpl<ValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationFailure&&super == other&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,field);



}

/// @nodoc
abstract mixin class $ValidationFailureCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $ValidationFailureCopyWith(ValidationFailure value, $Res Function(ValidationFailure) _then) = _$ValidationFailureCopyWithImpl;
@useResult
$Res call({
 String field
});




}
/// @nodoc
class _$ValidationFailureCopyWithImpl<$Res>
    implements $ValidationFailureCopyWith<$Res> {
  _$ValidationFailureCopyWithImpl(this._self, this._then);

  final ValidationFailure _self;
  final $Res Function(ValidationFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field = null,}) {
  return _then(ValidationFailure(
null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProfileNotFound extends ProfileFailure {
  const ProfileNotFound({this.userId}): super._();
  

 final  String? userId;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileNotFoundCopyWith<ProfileNotFound> get copyWith => _$ProfileNotFoundCopyWithImpl<ProfileNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileNotFound&&super == other&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,userId);



}

/// @nodoc
abstract mixin class $ProfileNotFoundCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $ProfileNotFoundCopyWith(ProfileNotFound value, $Res Function(ProfileNotFound) _then) = _$ProfileNotFoundCopyWithImpl;
@useResult
$Res call({
 String? userId
});




}
/// @nodoc
class _$ProfileNotFoundCopyWithImpl<$Res>
    implements $ProfileNotFoundCopyWith<$Res> {
  _$ProfileNotFoundCopyWithImpl(this._self, this._then);

  final ProfileNotFound _self;
  final $Res Function(ProfileNotFound) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = freezed,}) {
  return _then(ProfileNotFound(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class FirestoreRead extends ProfileFailure {
  const FirestoreRead(this.operation): super._();
  

 final  String operation;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirestoreReadCopyWith<FirestoreRead> get copyWith => _$FirestoreReadCopyWithImpl<FirestoreRead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirestoreRead&&super == other&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,operation);



}

/// @nodoc
abstract mixin class $FirestoreReadCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $FirestoreReadCopyWith(FirestoreRead value, $Res Function(FirestoreRead) _then) = _$FirestoreReadCopyWithImpl;
@useResult
$Res call({
 String operation
});




}
/// @nodoc
class _$FirestoreReadCopyWithImpl<$Res>
    implements $FirestoreReadCopyWith<$Res> {
  _$FirestoreReadCopyWithImpl(this._self, this._then);

  final FirestoreRead _self;
  final $Res Function(FirestoreRead) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operation = null,}) {
  return _then(FirestoreRead(
null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FirestoreWrite extends ProfileFailure {
  const FirestoreWrite(this.operation): super._();
  

 final  String operation;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirestoreWriteCopyWith<FirestoreWrite> get copyWith => _$FirestoreWriteCopyWithImpl<FirestoreWrite>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirestoreWrite&&super == other&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,operation);



}

/// @nodoc
abstract mixin class $FirestoreWriteCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $FirestoreWriteCopyWith(FirestoreWrite value, $Res Function(FirestoreWrite) _then) = _$FirestoreWriteCopyWithImpl;
@useResult
$Res call({
 String operation
});




}
/// @nodoc
class _$FirestoreWriteCopyWithImpl<$Res>
    implements $FirestoreWriteCopyWith<$Res> {
  _$FirestoreWriteCopyWithImpl(this._self, this._then);

  final FirestoreWrite _self;
  final $Res Function(FirestoreWrite) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operation = null,}) {
  return _then(FirestoreWrite(
null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class StorageFailure extends ProfileFailure {
  const StorageFailure(this.operation): super._();
  

 final  String operation;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StorageFailureCopyWith<StorageFailure> get copyWith => _$StorageFailureCopyWithImpl<StorageFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StorageFailure&&super == other&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,operation);



}

/// @nodoc
abstract mixin class $StorageFailureCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $StorageFailureCopyWith(StorageFailure value, $Res Function(StorageFailure) _then) = _$StorageFailureCopyWithImpl;
@useResult
$Res call({
 String operation
});




}
/// @nodoc
class _$StorageFailureCopyWithImpl<$Res>
    implements $StorageFailureCopyWith<$Res> {
  _$StorageFailureCopyWithImpl(this._self, this._then);

  final StorageFailure _self;
  final $Res Function(StorageFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operation = null,}) {
  return _then(StorageFailure(
null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NetworkFailure extends ProfileFailure {
  const NetworkFailure(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class PermissionDenied extends ProfileFailure {
  const PermissionDenied(this.resource): super._();
  

 final  String resource;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionDeniedCopyWith<PermissionDenied> get copyWith => _$PermissionDeniedCopyWithImpl<PermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDenied&&super == other&&(identical(other.resource, resource) || other.resource == resource));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,resource);



}

/// @nodoc
abstract mixin class $PermissionDeniedCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $PermissionDeniedCopyWith(PermissionDenied value, $Res Function(PermissionDenied) _then) = _$PermissionDeniedCopyWithImpl;
@useResult
$Res call({
 String resource
});




}
/// @nodoc
class _$PermissionDeniedCopyWithImpl<$Res>
    implements $PermissionDeniedCopyWith<$Res> {
  _$PermissionDeniedCopyWithImpl(this._self, this._then);

  final PermissionDenied _self;
  final $Res Function(PermissionDenied) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? resource = null,}) {
  return _then(PermissionDenied(
null == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthenticationRequired extends ProfileFailure {
  const AuthenticationRequired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationRequired&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class UnauthorizedAccess extends ProfileFailure {
  const UnauthorizedAccess({this.message = '권한이 없습니다'}): super._();
  

@JsonKey() final  String message;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnauthorizedAccessCopyWith<UnauthorizedAccess> get copyWith => _$UnauthorizedAccessCopyWithImpl<UnauthorizedAccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthorizedAccess&&super == other&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,message);



}

/// @nodoc
abstract mixin class $UnauthorizedAccessCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $UnauthorizedAccessCopyWith(UnauthorizedAccess value, $Res Function(UnauthorizedAccess) _then) = _$UnauthorizedAccessCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$UnauthorizedAccessCopyWithImpl<$Res>
    implements $UnauthorizedAccessCopyWith<$Res> {
  _$UnauthorizedAccessCopyWithImpl(this._self, this._then);

  final UnauthorizedAccess _self;
  final $Res Function(UnauthorizedAccess) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(UnauthorizedAccess(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CacheFailure extends ProfileFailure {
  const CacheFailure(this.operation): super._();
  

 final  String operation;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheFailureCopyWith<CacheFailure> get copyWith => _$CacheFailureCopyWithImpl<CacheFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheFailure&&super == other&&(identical(other.operation, operation) || other.operation == operation));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,operation);



}

/// @nodoc
abstract mixin class $CacheFailureCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $CacheFailureCopyWith(CacheFailure value, $Res Function(CacheFailure) _then) = _$CacheFailureCopyWithImpl;
@useResult
$Res call({
 String operation
});




}
/// @nodoc
class _$CacheFailureCopyWithImpl<$Res>
    implements $CacheFailureCopyWith<$Res> {
  _$CacheFailureCopyWithImpl(this._self, this._then);

  final CacheFailure _self;
  final $Res Function(CacheFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operation = null,}) {
  return _then(CacheFailure(
null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DuplicateOperation extends ProfileFailure {
  const DuplicateOperation(this.message): super._();
  

 final  String message;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateOperationCopyWith<DuplicateOperation> get copyWith => _$DuplicateOperationCopyWithImpl<DuplicateOperation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateOperation&&super == other&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,message);



}

/// @nodoc
abstract mixin class $DuplicateOperationCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $DuplicateOperationCopyWith(DuplicateOperation value, $Res Function(DuplicateOperation) _then) = _$DuplicateOperationCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DuplicateOperationCopyWithImpl<$Res>
    implements $DuplicateOperationCopyWith<$Res> {
  _$DuplicateOperationCopyWithImpl(this._self, this._then);

  final DuplicateOperation _self;
  final $Res Function(DuplicateOperation) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DuplicateOperation(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownProfile extends ProfileFailure {
  const UnknownProfile([this.error]): super._();
  

 final  String? error;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownProfileCopyWith<UnknownProfile> get copyWith => _$UnknownProfileCopyWithImpl<UnknownProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownProfile&&super == other&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,error);



}

/// @nodoc
abstract mixin class $UnknownProfileCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $UnknownProfileCopyWith(UnknownProfile value, $Res Function(UnknownProfile) _then) = _$UnknownProfileCopyWithImpl;
@useResult
$Res call({
 String? error
});




}
/// @nodoc
class _$UnknownProfileCopyWithImpl<$Res>
    implements $UnknownProfileCopyWith<$Res> {
  _$UnknownProfileCopyWithImpl(this._self, this._then);

  final UnknownProfile _self;
  final $Res Function(UnknownProfile) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,}) {
  return _then(UnknownProfile(
freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
