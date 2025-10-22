import '/core/errors/failures.dart';

/// Authentication Failure
///
/// Domain Layer - 인증 관련 실패 케이스 정의
/// Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Failure Pattern**:
/// - Sealed Class 패턴으로 타입 안전성 보장
/// - Core Failure 상속으로 Result<T> 호환성 확보
/// - Pattern Matching으로 누락 케이스 컴파일 체크
/// - 중앙 집중식 에러 메시지 관리
sealed class AuthFailure extends Failure {
  const AuthFailure() : super(message: '');

  /// Convert to user-friendly message (Override Failure.message)
  @override
  String get message {
    return switch (this) {
      InvalidEmail() => '이메일 형식이 올바르지 않습니다',
      WeakPassword() => '비밀번호가 너무 약합니다',
      EmailAlreadyInUse() => '이미 사용 중인 이메일입니다',
      InvalidCredentials() => '이메일 또는 비밀번호가 틀렸습니다',
      InvalidPhoneNumber() => '전화번호 형식이 올바르지 않습니다',
      InvalidSmsCode() => 'SMS 인증 코드가 올바르지 않습니다',
      SmsCodeExpired() => 'SMS 인증 코드가 만료되었습니다',
      CancelledByUser() => '사용자가 로그인을 취소했습니다',
      SocialSignInFailed() => '소셜 로그인에 실패했습니다',
      NetworkError() => '네트워크 연결 오류가 발생했습니다',
      ServerError() => '서버 오류가 발생했습니다',
      UserNotFound() => '사용자를 찾을 수 없습니다',
      UserDisabled() => '사용자 계정이 비활성화되었습니다',
      EmailNotVerified() => '이메일이 인증되지 않았습니다',
      InsufficientPermission() => '권한이 부족합니다',
      RequiresRecentLogin() => '계속하려면 다시 로그인해주세요',
      UserNameAlreadyTaken() => '이미 사용 중인 사용자 이름입니다',
      ProfileIncomplete() => '프로필이 완성되지 않았습니다',
      Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// Email & Password errors
class InvalidEmail extends AuthFailure {
  const InvalidEmail() : super();
}

class WeakPassword extends AuthFailure {
  const WeakPassword() : super();
}

class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse() : super();
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials() : super();
}

// Phone auth errors
class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber() : super();
}

class InvalidSmsCode extends AuthFailure {
  const InvalidSmsCode() : super();
}

class SmsCodeExpired extends AuthFailure {
  const SmsCodeExpired() : super();
}

// Social auth errors
class CancelledByUser extends AuthFailure {
  const CancelledByUser() : super();
}

class SocialSignInFailed extends AuthFailure {
  const SocialSignInFailed() : super();
}

// Network errors
class NetworkError extends AuthFailure {
  const NetworkError() : super();
}

class ServerError extends AuthFailure {
  const ServerError() : super();
}

// User state errors
class UserNotFound extends AuthFailure {
  const UserNotFound() : super();
}

class UserDisabled extends AuthFailure {
  const UserDisabled() : super();
}

class EmailNotVerified extends AuthFailure {
  const EmailNotVerified() : super();
}

// Permission errors
class InsufficientPermission extends AuthFailure {
  const InsufficientPermission() : super();
}

class RequiresRecentLogin extends AuthFailure {
  const RequiresRecentLogin() : super();
}

// Profile errors
class UserNameAlreadyTaken extends AuthFailure {
  const UserNameAlreadyTaken() : super();
}

class ProfileIncomplete extends AuthFailure {
  const ProfileIncomplete() : super();
}

// Generic error
class Unexpected extends AuthFailure {
  final String? errorMessage;
  const Unexpected([this.errorMessage]) : super();
}