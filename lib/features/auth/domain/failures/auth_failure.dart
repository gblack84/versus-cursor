import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failures.dart';

part 'auth_failure.freezed.dart';

/// Authentication Failure
///
/// Domain Layer - 인증 관련 실패 케이스 정의
/// Freezed Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
/// - Core Failure 인터페이스 구현으로 Result<T> 호환성 확보
@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  // Equatable implementation (required by Failure interface)
  @override
  List<Object?> get props => [message, code];

  @override
  String? get code => null;

  @override
  bool? get stringify => true;

  // Email & Password errors
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;

  // Phone auth errors
  const factory AuthFailure.invalidPhoneNumber() = InvalidPhoneNumber;
  const factory AuthFailure.invalidSmsCode() = InvalidSmsCode;
  const factory AuthFailure.smsCodeExpired() = SmsCodeExpired;

  // Social auth errors
  const factory AuthFailure.cancelledByUser() = CancelledByUser;
  const factory AuthFailure.socialSignInFailed() = SocialSignInFailed;

  // Network errors
  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.serverError() = ServerError;

  // User state errors
  const factory AuthFailure.userNotFound() = UserNotFound;
  const factory AuthFailure.userDisabled() = UserDisabled;
  const factory AuthFailure.emailNotVerified() = EmailNotVerified;

  // Permission errors
  const factory AuthFailure.insufficientPermission() = InsufficientPermission;
  const factory AuthFailure.requiresRecentLogin() = RequiresRecentLogin;

  // Profile errors
  const factory AuthFailure.userNameAlreadyTaken() = UserNameAlreadyTaken;
  const factory AuthFailure.profileIncomplete() = ProfileIncomplete;

  // Generic error
  const factory AuthFailure.unexpected([String? errorMessage]) = Unexpected;

  /// Convert to user-friendly message (Implements Failure.message)
  @override
  String get message {
    return when(
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      weakPassword: () => '비밀번호가 너무 약합니다',
      emailAlreadyInUse: () => '이미 사용 중인 이메일입니다',
      invalidCredentials: () => '이메일 또는 비밀번호가 틀렸습니다',
      invalidPhoneNumber: () => '전화번호 형식이 올바르지 않습니다',
      invalidSmsCode: () => 'SMS 인증 코드가 올바르지 않습니다',
      smsCodeExpired: () => 'SMS 인증 코드가 만료되었습니다',
      cancelledByUser: () => '사용자가 로그인을 취소했습니다',
      socialSignInFailed: () => '소셜 로그인에 실패했습니다',
      networkError: () => '네트워크 연결 오류가 발생했습니다',
      serverError: () => '서버 오류가 발생했습니다',
      userNotFound: () => '사용자를 찾을 수 없습니다',
      userDisabled: () => '사용자 계정이 비활성화되었습니다',
      emailNotVerified: () => '이메일이 인증되지 않았습니다',
      insufficientPermission: () => '권한이 부족합니다',
      requiresRecentLogin: () => '계속하려면 다시 로그인해주세요',
      userNameAlreadyTaken: () => '이미 사용 중인 사용자 이름입니다',
      profileIncomplete: () => '프로필이 완성되지 않았습니다',
      unexpected: (errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
