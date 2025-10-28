// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}

/// @nodoc
class $AuthFailureCopyWith<$Res>  {
$AuthFailureCopyWith(AuthFailure _, $Res Function(AuthFailure) __);
}


/// Adds pattern-matching-related methods to [AuthFailure].
extension AuthFailurePatterns on AuthFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InvalidEmail value)?  invalidEmail,TResult Function( WeakPassword value)?  weakPassword,TResult Function( EmailAlreadyInUse value)?  emailAlreadyInUse,TResult Function( InvalidCredentials value)?  invalidCredentials,TResult Function( InvalidPhoneNumber value)?  invalidPhoneNumber,TResult Function( InvalidSmsCode value)?  invalidSmsCode,TResult Function( SmsCodeExpired value)?  smsCodeExpired,TResult Function( CancelledByUser value)?  cancelledByUser,TResult Function( SocialSignInFailed value)?  socialSignInFailed,TResult Function( NetworkError value)?  networkError,TResult Function( ServerError value)?  serverError,TResult Function( UserNotFound value)?  userNotFound,TResult Function( UserDisabled value)?  userDisabled,TResult Function( EmailNotVerified value)?  emailNotVerified,TResult Function( InsufficientPermission value)?  insufficientPermission,TResult Function( RequiresRecentLogin value)?  requiresRecentLogin,TResult Function( UserNameAlreadyTaken value)?  userNameAlreadyTaken,TResult Function( ProfileIncomplete value)?  profileIncomplete,TResult Function( Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail(_that);case WeakPassword() when weakPassword != null:
return weakPassword(_that);case EmailAlreadyInUse() when emailAlreadyInUse != null:
return emailAlreadyInUse(_that);case InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case InvalidPhoneNumber() when invalidPhoneNumber != null:
return invalidPhoneNumber(_that);case InvalidSmsCode() when invalidSmsCode != null:
return invalidSmsCode(_that);case SmsCodeExpired() when smsCodeExpired != null:
return smsCodeExpired(_that);case CancelledByUser() when cancelledByUser != null:
return cancelledByUser(_that);case SocialSignInFailed() when socialSignInFailed != null:
return socialSignInFailed(_that);case NetworkError() when networkError != null:
return networkError(_that);case ServerError() when serverError != null:
return serverError(_that);case UserNotFound() when userNotFound != null:
return userNotFound(_that);case UserDisabled() when userDisabled != null:
return userDisabled(_that);case EmailNotVerified() when emailNotVerified != null:
return emailNotVerified(_that);case InsufficientPermission() when insufficientPermission != null:
return insufficientPermission(_that);case RequiresRecentLogin() when requiresRecentLogin != null:
return requiresRecentLogin(_that);case UserNameAlreadyTaken() when userNameAlreadyTaken != null:
return userNameAlreadyTaken(_that);case ProfileIncomplete() when profileIncomplete != null:
return profileIncomplete(_that);case Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InvalidEmail value)  invalidEmail,required TResult Function( WeakPassword value)  weakPassword,required TResult Function( EmailAlreadyInUse value)  emailAlreadyInUse,required TResult Function( InvalidCredentials value)  invalidCredentials,required TResult Function( InvalidPhoneNumber value)  invalidPhoneNumber,required TResult Function( InvalidSmsCode value)  invalidSmsCode,required TResult Function( SmsCodeExpired value)  smsCodeExpired,required TResult Function( CancelledByUser value)  cancelledByUser,required TResult Function( SocialSignInFailed value)  socialSignInFailed,required TResult Function( NetworkError value)  networkError,required TResult Function( ServerError value)  serverError,required TResult Function( UserNotFound value)  userNotFound,required TResult Function( UserDisabled value)  userDisabled,required TResult Function( EmailNotVerified value)  emailNotVerified,required TResult Function( InsufficientPermission value)  insufficientPermission,required TResult Function( RequiresRecentLogin value)  requiresRecentLogin,required TResult Function( UserNameAlreadyTaken value)  userNameAlreadyTaken,required TResult Function( ProfileIncomplete value)  profileIncomplete,required TResult Function( Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case InvalidEmail():
return invalidEmail(_that);case WeakPassword():
return weakPassword(_that);case EmailAlreadyInUse():
return emailAlreadyInUse(_that);case InvalidCredentials():
return invalidCredentials(_that);case InvalidPhoneNumber():
return invalidPhoneNumber(_that);case InvalidSmsCode():
return invalidSmsCode(_that);case SmsCodeExpired():
return smsCodeExpired(_that);case CancelledByUser():
return cancelledByUser(_that);case SocialSignInFailed():
return socialSignInFailed(_that);case NetworkError():
return networkError(_that);case ServerError():
return serverError(_that);case UserNotFound():
return userNotFound(_that);case UserDisabled():
return userDisabled(_that);case EmailNotVerified():
return emailNotVerified(_that);case InsufficientPermission():
return insufficientPermission(_that);case RequiresRecentLogin():
return requiresRecentLogin(_that);case UserNameAlreadyTaken():
return userNameAlreadyTaken(_that);case ProfileIncomplete():
return profileIncomplete(_that);case Unexpected():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InvalidEmail value)?  invalidEmail,TResult? Function( WeakPassword value)?  weakPassword,TResult? Function( EmailAlreadyInUse value)?  emailAlreadyInUse,TResult? Function( InvalidCredentials value)?  invalidCredentials,TResult? Function( InvalidPhoneNumber value)?  invalidPhoneNumber,TResult? Function( InvalidSmsCode value)?  invalidSmsCode,TResult? Function( SmsCodeExpired value)?  smsCodeExpired,TResult? Function( CancelledByUser value)?  cancelledByUser,TResult? Function( SocialSignInFailed value)?  socialSignInFailed,TResult? Function( NetworkError value)?  networkError,TResult? Function( ServerError value)?  serverError,TResult? Function( UserNotFound value)?  userNotFound,TResult? Function( UserDisabled value)?  userDisabled,TResult? Function( EmailNotVerified value)?  emailNotVerified,TResult? Function( InsufficientPermission value)?  insufficientPermission,TResult? Function( RequiresRecentLogin value)?  requiresRecentLogin,TResult? Function( UserNameAlreadyTaken value)?  userNameAlreadyTaken,TResult? Function( ProfileIncomplete value)?  profileIncomplete,TResult? Function( Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail(_that);case WeakPassword() when weakPassword != null:
return weakPassword(_that);case EmailAlreadyInUse() when emailAlreadyInUse != null:
return emailAlreadyInUse(_that);case InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case InvalidPhoneNumber() when invalidPhoneNumber != null:
return invalidPhoneNumber(_that);case InvalidSmsCode() when invalidSmsCode != null:
return invalidSmsCode(_that);case SmsCodeExpired() when smsCodeExpired != null:
return smsCodeExpired(_that);case CancelledByUser() when cancelledByUser != null:
return cancelledByUser(_that);case SocialSignInFailed() when socialSignInFailed != null:
return socialSignInFailed(_that);case NetworkError() when networkError != null:
return networkError(_that);case ServerError() when serverError != null:
return serverError(_that);case UserNotFound() when userNotFound != null:
return userNotFound(_that);case UserDisabled() when userDisabled != null:
return userDisabled(_that);case EmailNotVerified() when emailNotVerified != null:
return emailNotVerified(_that);case InsufficientPermission() when insufficientPermission != null:
return insufficientPermission(_that);case RequiresRecentLogin() when requiresRecentLogin != null:
return requiresRecentLogin(_that);case UserNameAlreadyTaken() when userNameAlreadyTaken != null:
return userNameAlreadyTaken(_that);case ProfileIncomplete() when profileIncomplete != null:
return profileIncomplete(_that);case Unexpected() when unexpected != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  invalidEmail,TResult Function()?  weakPassword,TResult Function()?  emailAlreadyInUse,TResult Function()?  invalidCredentials,TResult Function()?  invalidPhoneNumber,TResult Function()?  invalidSmsCode,TResult Function()?  smsCodeExpired,TResult Function()?  cancelledByUser,TResult Function()?  socialSignInFailed,TResult Function()?  networkError,TResult Function()?  serverError,TResult Function()?  userNotFound,TResult Function()?  userDisabled,TResult Function()?  emailNotVerified,TResult Function()?  insufficientPermission,TResult Function()?  requiresRecentLogin,TResult Function()?  userNameAlreadyTaken,TResult Function()?  profileIncomplete,TResult Function( String? errorMessage)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail();case WeakPassword() when weakPassword != null:
return weakPassword();case EmailAlreadyInUse() when emailAlreadyInUse != null:
return emailAlreadyInUse();case InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case InvalidPhoneNumber() when invalidPhoneNumber != null:
return invalidPhoneNumber();case InvalidSmsCode() when invalidSmsCode != null:
return invalidSmsCode();case SmsCodeExpired() when smsCodeExpired != null:
return smsCodeExpired();case CancelledByUser() when cancelledByUser != null:
return cancelledByUser();case SocialSignInFailed() when socialSignInFailed != null:
return socialSignInFailed();case NetworkError() when networkError != null:
return networkError();case ServerError() when serverError != null:
return serverError();case UserNotFound() when userNotFound != null:
return userNotFound();case UserDisabled() when userDisabled != null:
return userDisabled();case EmailNotVerified() when emailNotVerified != null:
return emailNotVerified();case InsufficientPermission() when insufficientPermission != null:
return insufficientPermission();case RequiresRecentLogin() when requiresRecentLogin != null:
return requiresRecentLogin();case UserNameAlreadyTaken() when userNameAlreadyTaken != null:
return userNameAlreadyTaken();case ProfileIncomplete() when profileIncomplete != null:
return profileIncomplete();case Unexpected() when unexpected != null:
return unexpected(_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  invalidEmail,required TResult Function()  weakPassword,required TResult Function()  emailAlreadyInUse,required TResult Function()  invalidCredentials,required TResult Function()  invalidPhoneNumber,required TResult Function()  invalidSmsCode,required TResult Function()  smsCodeExpired,required TResult Function()  cancelledByUser,required TResult Function()  socialSignInFailed,required TResult Function()  networkError,required TResult Function()  serverError,required TResult Function()  userNotFound,required TResult Function()  userDisabled,required TResult Function()  emailNotVerified,required TResult Function()  insufficientPermission,required TResult Function()  requiresRecentLogin,required TResult Function()  userNameAlreadyTaken,required TResult Function()  profileIncomplete,required TResult Function( String? errorMessage)  unexpected,}) {final _that = this;
switch (_that) {
case InvalidEmail():
return invalidEmail();case WeakPassword():
return weakPassword();case EmailAlreadyInUse():
return emailAlreadyInUse();case InvalidCredentials():
return invalidCredentials();case InvalidPhoneNumber():
return invalidPhoneNumber();case InvalidSmsCode():
return invalidSmsCode();case SmsCodeExpired():
return smsCodeExpired();case CancelledByUser():
return cancelledByUser();case SocialSignInFailed():
return socialSignInFailed();case NetworkError():
return networkError();case ServerError():
return serverError();case UserNotFound():
return userNotFound();case UserDisabled():
return userDisabled();case EmailNotVerified():
return emailNotVerified();case InsufficientPermission():
return insufficientPermission();case RequiresRecentLogin():
return requiresRecentLogin();case UserNameAlreadyTaken():
return userNameAlreadyTaken();case ProfileIncomplete():
return profileIncomplete();case Unexpected():
return unexpected(_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  invalidEmail,TResult? Function()?  weakPassword,TResult? Function()?  emailAlreadyInUse,TResult? Function()?  invalidCredentials,TResult? Function()?  invalidPhoneNumber,TResult? Function()?  invalidSmsCode,TResult? Function()?  smsCodeExpired,TResult? Function()?  cancelledByUser,TResult? Function()?  socialSignInFailed,TResult? Function()?  networkError,TResult? Function()?  serverError,TResult? Function()?  userNotFound,TResult? Function()?  userDisabled,TResult? Function()?  emailNotVerified,TResult? Function()?  insufficientPermission,TResult? Function()?  requiresRecentLogin,TResult? Function()?  userNameAlreadyTaken,TResult? Function()?  profileIncomplete,TResult? Function( String? errorMessage)?  unexpected,}) {final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail();case WeakPassword() when weakPassword != null:
return weakPassword();case EmailAlreadyInUse() when emailAlreadyInUse != null:
return emailAlreadyInUse();case InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case InvalidPhoneNumber() when invalidPhoneNumber != null:
return invalidPhoneNumber();case InvalidSmsCode() when invalidSmsCode != null:
return invalidSmsCode();case SmsCodeExpired() when smsCodeExpired != null:
return smsCodeExpired();case CancelledByUser() when cancelledByUser != null:
return cancelledByUser();case SocialSignInFailed() when socialSignInFailed != null:
return socialSignInFailed();case NetworkError() when networkError != null:
return networkError();case ServerError() when serverError != null:
return serverError();case UserNotFound() when userNotFound != null:
return userNotFound();case UserDisabled() when userDisabled != null:
return userDisabled();case EmailNotVerified() when emailNotVerified != null:
return emailNotVerified();case InsufficientPermission() when insufficientPermission != null:
return insufficientPermission();case RequiresRecentLogin() when requiresRecentLogin != null:
return requiresRecentLogin();case UserNameAlreadyTaken() when userNameAlreadyTaken != null:
return userNameAlreadyTaken();case ProfileIncomplete() when profileIncomplete != null:
return profileIncomplete();case Unexpected() when unexpected != null:
return unexpected(_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class InvalidEmail extends AuthFailure {
  const InvalidEmail(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidEmail&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class WeakPassword extends AuthFailure {
  const WeakPassword(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeakPassword&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailAlreadyInUse&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class InvalidCredentials extends AuthFailure {
  const InvalidCredentials(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidCredentials&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidPhoneNumber&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class InvalidSmsCode extends AuthFailure {
  const InvalidSmsCode(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidSmsCode&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class SmsCodeExpired extends AuthFailure {
  const SmsCodeExpired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmsCodeExpired&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class CancelledByUser extends AuthFailure {
  const CancelledByUser(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelledByUser&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class SocialSignInFailed extends AuthFailure {
  const SocialSignInFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialSignInFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NetworkError extends AuthFailure {
  const NetworkError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class ServerError extends AuthFailure {
  const ServerError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class UserNotFound extends AuthFailure {
  const UserNotFound(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNotFound&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class UserDisabled extends AuthFailure {
  const UserDisabled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDisabled&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class EmailNotVerified extends AuthFailure {
  const EmailNotVerified(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailNotVerified&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class InsufficientPermission extends AuthFailure {
  const InsufficientPermission(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsufficientPermission&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class RequiresRecentLogin extends AuthFailure {
  const RequiresRecentLogin(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequiresRecentLogin&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class UserNameAlreadyTaken extends AuthFailure {
  const UserNameAlreadyTaken(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNameAlreadyTaken&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class ProfileIncomplete extends AuthFailure {
  const ProfileIncomplete(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileIncomplete&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class Unexpected extends AuthFailure {
  const Unexpected([this.errorMessage]): super._();
  

 final  String? errorMessage;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedCopyWith<Unexpected> get copyWith => _$UnexpectedCopyWithImpl<Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unexpected&&super == other&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,errorMessage);



}

/// @nodoc
abstract mixin class $UnexpectedCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory $UnexpectedCopyWith(Unexpected value, $Res Function(Unexpected) _then) = _$UnexpectedCopyWithImpl;
@useResult
$Res call({
 String? errorMessage
});




}
/// @nodoc
class _$UnexpectedCopyWithImpl<$Res>
    implements $UnexpectedCopyWith<$Res> {
  _$UnexpectedCopyWithImpl(this._self, this._then);

  final Unexpected _self;
  final $Res Function(Unexpected) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorMessage = freezed,}) {
  return _then(Unexpected(
freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
