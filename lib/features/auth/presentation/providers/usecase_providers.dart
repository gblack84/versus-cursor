import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
// Sign In
import '/features/auth/domain/usecases/sign_in/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_in/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_in/sign_in_with_apple_usecase.dart';
// Phone Authentication (New SRP location)
import '/features/auth/domain/usecases/phone/sign_in_with_phone_usecase.dart';
import '/features/auth/domain/usecases/phone/send_phone_otp_usecase.dart';
// Sign Up
import '/features/auth/domain/usecases/sign_up/sign_up_with_email_usecase.dart';
// Account Management
import '/features/auth/domain/usecases/account/password_management_usecase.dart';
import '/features/auth/domain/usecases/account/email_verification_usecase.dart';
import '/features/auth/domain/usecases/account/account_management_usecase.dart';
// Session
import '/features/auth/domain/usecases/session/get_current_user_usecase.dart';
import '/features/auth/domain/usecases/session/sign_out_usecase.dart';

part 'usecase_providers.g.dart';

/// UseCase Providers for Auth Feature (Riverpod 3.x)
///
/// GetIt에 등록된 UseCase들을 Riverpod Provider로 노출합니다.
/// Creation Feature 패턴 100% 적용.

// ========================================
// Sign In UseCase Providers
// ========================================

/// Sign In with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 로그인
/// **의존성**: IAuthRepository
/// **사용처**: SignInScreen
@riverpod
SignInWithEmailUseCase signInWithEmailUseCase(Ref ref) {
  return getIt<SignInWithEmailUseCase>();
}

/// Sign In with Google UseCase Provider
///
/// **역할**: Google OAuth 로그인
/// **의존성**: IAuthRepository, GoogleSignIn
/// **사용처**: SignInScreen, SocialLoginButtons
@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return getIt<SignInWithGoogleUseCase>();
}

/// Sign In with Apple UseCase Provider
///
/// **역할**: Apple Sign In (iOS/macOS)
/// **의존성**: IAuthRepository, SignInWithApple
/// **사용처**: SignInScreen, SocialLoginButtons
@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return getIt<SignInWithAppleUseCase>();
}

/// Sign In with Phone UseCase Provider
///
/// **역할**: 전화번호 OTP 로그인 (인증 코드 검증)
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneLoginPincodeScreen
@riverpod
SignInWithPhoneUseCase signInWithPhoneUseCase(Ref ref) {
  return getIt<SignInWithPhoneUseCase>();
}

/// Send Phone OTP UseCase Provider
///
/// **역할**: SMS OTP 전송 (전화번호 인증 시작)
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneCreateAccountScreen, PhoneLoginPincodeScreen (resend)
@riverpod
SendPhoneOtpUseCase sendPhoneOtpUseCase(Ref ref) {
  return getIt<SendPhoneOtpUseCase>();
}

// ========================================
// Sign Up UseCase Providers
// ========================================

/// Sign Up with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 회원가입
/// **의존성**: IAuthRepository
/// **사용처**: SignUpScreen
@riverpod
SignUpWithEmailUseCase signUpWithEmailUseCase(Ref ref) {
  return getIt<SignUpWithEmailUseCase>();
}

// ========================================
// Account Management UseCase Providers
// ========================================

/// Password Management UseCase Provider
///
/// **역할**: 비밀번호 변경, 재설정
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, ForgotPasswordScreen
@riverpod
PasswordManagementUseCase passwordManagementUseCase(Ref ref) {
  return getIt<PasswordManagementUseCase>();
}

/// Email Verification UseCase Provider
///
/// **역할**: 이메일 인증 발송, 확인
/// **의존성**: IAuthRepository
/// **사용처**: EmailVerificationScreen
@riverpod
EmailVerificationUseCase emailVerificationUseCase(Ref ref) {
  return getIt<EmailVerificationUseCase>();
}

/// Account Management UseCase Provider
///
/// **역할**: 계정 삭제, 이메일 변경
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, DeleteAccountDialog
@riverpod
AccountManagementUseCase accountManagementUseCase(Ref ref) {
  return getIt<AccountManagementUseCase>();
}

// ========================================
// Session UseCase Providers
// ========================================

/// Get Current User UseCase Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회
/// **의존성**: IAuthRepository
/// **사용처**: currentUserProvider (FutureProvider)
@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return getIt<GetCurrentUserUseCase>();
}

/// Sign Out UseCase Provider
///
/// **역할**: 로그아웃
/// **의존성**: IAuthRepository
/// **사용처**: ProfileScreen, SettingsScreen
@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return getIt<SignOutUseCase>();
}
