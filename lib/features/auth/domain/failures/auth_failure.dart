/// Authentication Failure
///
/// Domain Layer - 인증 관련 실패 케이스 정의
/// Sealed Class for Functional Error Handling
sealed class AuthFailure {
  const AuthFailure();

  /// Convert to user-friendly message
  String get message {
    return switch (this) {
      InvalidEmail() => 'Invalid email address',
      WeakPassword() => 'Password is too weak',
      EmailAlreadyInUse() => 'Email is already in use',
      InvalidCredentials() => 'Invalid email or password',
      InvalidPhoneNumber() => 'Invalid phone number',
      InvalidSmsCode() => 'Invalid SMS code',
      SmsCodeExpired() => 'SMS code has expired',
      CancelledByUser() => 'Sign in cancelled by user',
      SocialSignInFailed() => 'Social sign in failed',
      NetworkError() => 'Network connection error',
      ServerError() => 'Server error occurred',
      UserNotFound() => 'User not found',
      UserDisabled() => 'User account is disabled',
      EmailNotVerified() => 'Email is not verified',
      InsufficientPermission() => 'Insufficient permission',
      RequiresRecentLogin() => 'Please login again to continue',
      UserNameAlreadyTaken() => 'Username is already taken',
      ProfileIncomplete() => 'Profile is incomplete',
      Unexpected(message: final msg) => msg ?? 'An unexpected error occurred',
    };
  }
}

// Email & Password errors
class InvalidEmail extends AuthFailure {
  const InvalidEmail();
}

class WeakPassword extends AuthFailure {
  const WeakPassword();
}

class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
}

// Phone auth errors
class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber();
}

class InvalidSmsCode extends AuthFailure {
  const InvalidSmsCode();
}

class SmsCodeExpired extends AuthFailure {
  const SmsCodeExpired();
}

// Social auth errors
class CancelledByUser extends AuthFailure {
  const CancelledByUser();
}

class SocialSignInFailed extends AuthFailure {
  const SocialSignInFailed();
}

// Network errors
class NetworkError extends AuthFailure {
  const NetworkError();
}

class ServerError extends AuthFailure {
  const ServerError();
}

// User state errors
class UserNotFound extends AuthFailure {
  const UserNotFound();
}

class UserDisabled extends AuthFailure {
  const UserDisabled();
}

class EmailNotVerified extends AuthFailure {
  const EmailNotVerified();
}

// Permission errors
class InsufficientPermission extends AuthFailure {
  const InsufficientPermission();
}

class RequiresRecentLogin extends AuthFailure {
  const RequiresRecentLogin();
}

// Profile errors
class UserNameAlreadyTaken extends AuthFailure {
  const UserNameAlreadyTaken();
}

class ProfileIncomplete extends AuthFailure {
  const ProfileIncomplete();
}

// Generic error
class Unexpected extends AuthFailure {
  final String? errorMessage;
  const Unexpected([this.errorMessage]);
}