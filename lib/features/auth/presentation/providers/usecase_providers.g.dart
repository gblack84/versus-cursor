// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(signInWithEmailUseCase)
const signInWithEmailUseCaseProvider = SignInWithEmailUseCaseProvider._();

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

final class SignInWithEmailUseCaseProvider
    extends
        $FunctionalProvider<
          SignInWithEmailUseCase,
          SignInWithEmailUseCase,
          SignInWithEmailUseCase
        >
    with $Provider<SignInWithEmailUseCase> {
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
  const SignInWithEmailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithEmailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithEmailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignInWithEmailUseCase create(Ref ref) {
    return signInWithEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithEmailUseCase>(value),
    );
  }
}

String _$signInWithEmailUseCaseHash() =>
    r'a2b2341ebc564b973060c5a9ca59389c4bba5e46';

/// Sign In with Google UseCase Provider
///
/// **역할**: Google OAuth 로그인
/// **의존성**: IAuthRepository, GoogleSignIn
/// **사용처**: SignInScreen, SocialLoginButtons

@ProviderFor(signInWithGoogleUseCase)
const signInWithGoogleUseCaseProvider = SignInWithGoogleUseCaseProvider._();

/// Sign In with Google UseCase Provider
///
/// **역할**: Google OAuth 로그인
/// **의존성**: IAuthRepository, GoogleSignIn
/// **사용처**: SignInScreen, SocialLoginButtons

final class SignInWithGoogleUseCaseProvider
    extends
        $FunctionalProvider<
          SignInWithGoogleUseCase,
          SignInWithGoogleUseCase,
          SignInWithGoogleUseCase
        >
    with $Provider<SignInWithGoogleUseCase> {
  /// Sign In with Google UseCase Provider
  ///
  /// **역할**: Google OAuth 로그인
  /// **의존성**: IAuthRepository, GoogleSignIn
  /// **사용처**: SignInScreen, SocialLoginButtons
  const SignInWithGoogleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithGoogleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithGoogleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithGoogleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignInWithGoogleUseCase create(Ref ref) {
    return signInWithGoogleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithGoogleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithGoogleUseCase>(value),
    );
  }
}

String _$signInWithGoogleUseCaseHash() =>
    r'965538c661cf0ad29b5ca4509082eb3af2c41a0d';

/// Sign In with Apple UseCase Provider
///
/// **역할**: Apple Sign In (iOS/macOS)
/// **의존성**: IAuthRepository, SignInWithApple
/// **사용처**: SignInScreen, SocialLoginButtons

@ProviderFor(signInWithAppleUseCase)
const signInWithAppleUseCaseProvider = SignInWithAppleUseCaseProvider._();

/// Sign In with Apple UseCase Provider
///
/// **역할**: Apple Sign In (iOS/macOS)
/// **의존성**: IAuthRepository, SignInWithApple
/// **사용처**: SignInScreen, SocialLoginButtons

final class SignInWithAppleUseCaseProvider
    extends
        $FunctionalProvider<
          SignInWithAppleUseCase,
          SignInWithAppleUseCase,
          SignInWithAppleUseCase
        >
    with $Provider<SignInWithAppleUseCase> {
  /// Sign In with Apple UseCase Provider
  ///
  /// **역할**: Apple Sign In (iOS/macOS)
  /// **의존성**: IAuthRepository, SignInWithApple
  /// **사용처**: SignInScreen, SocialLoginButtons
  const SignInWithAppleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithAppleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithAppleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithAppleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignInWithAppleUseCase create(Ref ref) {
    return signInWithAppleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithAppleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithAppleUseCase>(value),
    );
  }
}

String _$signInWithAppleUseCaseHash() =>
    r'd18fb761fe7e040ae99d777262185006bbd6bf33';

/// Sign In with Phone UseCase Provider
///
/// **역할**: 전화번호 OTP 로그인 (인증 코드 검증)
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneLoginPincodeScreen

@ProviderFor(signInWithPhoneUseCase)
const signInWithPhoneUseCaseProvider = SignInWithPhoneUseCaseProvider._();

/// Sign In with Phone UseCase Provider
///
/// **역할**: 전화번호 OTP 로그인 (인증 코드 검증)
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneLoginPincodeScreen

final class SignInWithPhoneUseCaseProvider
    extends
        $FunctionalProvider<
          SignInWithPhoneUseCase,
          SignInWithPhoneUseCase,
          SignInWithPhoneUseCase
        >
    with $Provider<SignInWithPhoneUseCase> {
  /// Sign In with Phone UseCase Provider
  ///
  /// **역할**: 전화번호 OTP 로그인 (인증 코드 검증)
  /// **의존성**: IAuthRepository, Firebase Phone Auth
  /// **사용처**: PhoneLoginPincodeScreen
  const SignInWithPhoneUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithPhoneUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithPhoneUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithPhoneUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignInWithPhoneUseCase create(Ref ref) {
    return signInWithPhoneUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithPhoneUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithPhoneUseCase>(value),
    );
  }
}

String _$signInWithPhoneUseCaseHash() =>
    r'c1b5c2f5801f4a6001ef29348f73c2fe20b477b6';

/// Send Phone OTP UseCase Provider
///
/// **역할**: SMS OTP 전송 (전화번호 인증 시작)
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneCreateAccountScreen, PhoneLoginPincodeScreen (resend)

@ProviderFor(sendPhoneOtpUseCase)
const sendPhoneOtpUseCaseProvider = SendPhoneOtpUseCaseProvider._();

/// Send Phone OTP UseCase Provider
///
/// **역할**: SMS OTP 전송 (전화번호 인증 시작)
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneCreateAccountScreen, PhoneLoginPincodeScreen (resend)

final class SendPhoneOtpUseCaseProvider
    extends
        $FunctionalProvider<
          SendPhoneOtpUseCase,
          SendPhoneOtpUseCase,
          SendPhoneOtpUseCase
        >
    with $Provider<SendPhoneOtpUseCase> {
  /// Send Phone OTP UseCase Provider
  ///
  /// **역할**: SMS OTP 전송 (전화번호 인증 시작)
  /// **의존성**: IAuthRepository, Firebase Phone Auth
  /// **사용처**: PhoneCreateAccountScreen, PhoneLoginPincodeScreen (resend)
  const SendPhoneOtpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendPhoneOtpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendPhoneOtpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SendPhoneOtpUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SendPhoneOtpUseCase create(Ref ref) {
    return sendPhoneOtpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendPhoneOtpUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendPhoneOtpUseCase>(value),
    );
  }
}

String _$sendPhoneOtpUseCaseHash() =>
    r'689df11443ac416cd54f5223c47a67d4a5592d34';

/// Sign Up with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 회원가입
/// **의존성**: IAuthRepository
/// **사용처**: SignUpScreen

@ProviderFor(signUpWithEmailUseCase)
const signUpWithEmailUseCaseProvider = SignUpWithEmailUseCaseProvider._();

/// Sign Up with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 회원가입
/// **의존성**: IAuthRepository
/// **사용처**: SignUpScreen

final class SignUpWithEmailUseCaseProvider
    extends
        $FunctionalProvider<
          SignUpWithEmailUseCase,
          SignUpWithEmailUseCase,
          SignUpWithEmailUseCase
        >
    with $Provider<SignUpWithEmailUseCase> {
  /// Sign Up with Email UseCase Provider
  ///
  /// **역할**: 이메일/비밀번호 회원가입
  /// **의존성**: IAuthRepository
  /// **사용처**: SignUpScreen
  const SignUpWithEmailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpWithEmailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpWithEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignUpWithEmailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignUpWithEmailUseCase create(Ref ref) {
    return signUpWithEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpWithEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpWithEmailUseCase>(value),
    );
  }
}

String _$signUpWithEmailUseCaseHash() =>
    r'528d699062d7fdbad9f85a8c740a69f8fab07151';

/// Password Management UseCase Provider
///
/// **역할**: 비밀번호 변경, 재설정
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, ForgotPasswordScreen

@ProviderFor(passwordManagementUseCase)
const passwordManagementUseCaseProvider = PasswordManagementUseCaseProvider._();

/// Password Management UseCase Provider
///
/// **역할**: 비밀번호 변경, 재설정
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, ForgotPasswordScreen

final class PasswordManagementUseCaseProvider
    extends
        $FunctionalProvider<
          PasswordManagementUseCase,
          PasswordManagementUseCase,
          PasswordManagementUseCase
        >
    with $Provider<PasswordManagementUseCase> {
  /// Password Management UseCase Provider
  ///
  /// **역할**: 비밀번호 변경, 재설정
  /// **의존성**: IAuthRepository
  /// **사용처**: SettingsScreen, ForgotPasswordScreen
  const PasswordManagementUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordManagementUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordManagementUseCaseHash();

  @$internal
  @override
  $ProviderElement<PasswordManagementUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PasswordManagementUseCase create(Ref ref) {
    return passwordManagementUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordManagementUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordManagementUseCase>(value),
    );
  }
}

String _$passwordManagementUseCaseHash() =>
    r'd488964f304c536b5cdbcd6e32d1d2d9ba172bc1';

/// Email Verification UseCase Provider
///
/// **역할**: 이메일 인증 발송, 확인
/// **의존성**: IAuthRepository
/// **사용처**: EmailVerificationScreen

@ProviderFor(emailVerificationUseCase)
const emailVerificationUseCaseProvider = EmailVerificationUseCaseProvider._();

/// Email Verification UseCase Provider
///
/// **역할**: 이메일 인증 발송, 확인
/// **의존성**: IAuthRepository
/// **사용처**: EmailVerificationScreen

final class EmailVerificationUseCaseProvider
    extends
        $FunctionalProvider<
          EmailVerificationUseCase,
          EmailVerificationUseCase,
          EmailVerificationUseCase
        >
    with $Provider<EmailVerificationUseCase> {
  /// Email Verification UseCase Provider
  ///
  /// **역할**: 이메일 인증 발송, 확인
  /// **의존성**: IAuthRepository
  /// **사용처**: EmailVerificationScreen
  const EmailVerificationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailVerificationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailVerificationUseCaseHash();

  @$internal
  @override
  $ProviderElement<EmailVerificationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmailVerificationUseCase create(Ref ref) {
    return emailVerificationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmailVerificationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmailVerificationUseCase>(value),
    );
  }
}

String _$emailVerificationUseCaseHash() =>
    r'a45ab69b048204d727b5ad62d7a4d6a7b54e1988';

/// Account Management UseCase Provider
///
/// **역할**: 계정 삭제, 이메일 변경
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, DeleteAccountDialog

@ProviderFor(accountManagementUseCase)
const accountManagementUseCaseProvider = AccountManagementUseCaseProvider._();

/// Account Management UseCase Provider
///
/// **역할**: 계정 삭제, 이메일 변경
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, DeleteAccountDialog

final class AccountManagementUseCaseProvider
    extends
        $FunctionalProvider<
          AccountManagementUseCase,
          AccountManagementUseCase,
          AccountManagementUseCase
        >
    with $Provider<AccountManagementUseCase> {
  /// Account Management UseCase Provider
  ///
  /// **역할**: 계정 삭제, 이메일 변경
  /// **의존성**: IAuthRepository
  /// **사용처**: SettingsScreen, DeleteAccountDialog
  const AccountManagementUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountManagementUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountManagementUseCaseHash();

  @$internal
  @override
  $ProviderElement<AccountManagementUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountManagementUseCase create(Ref ref) {
    return accountManagementUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountManagementUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountManagementUseCase>(value),
    );
  }
}

String _$accountManagementUseCaseHash() =>
    r'313c207ad4bbfe950a9a57b3618bac58d808566c';

/// Get Current User UseCase Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회
/// **의존성**: IAuthRepository
/// **사용처**: currentUserProvider (FutureProvider)

@ProviderFor(getCurrentUserUseCase)
const getCurrentUserUseCaseProvider = GetCurrentUserUseCaseProvider._();

/// Get Current User UseCase Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회
/// **의존성**: IAuthRepository
/// **사용처**: currentUserProvider (FutureProvider)

final class GetCurrentUserUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentUserUseCase,
          GetCurrentUserUseCase,
          GetCurrentUserUseCase
        >
    with $Provider<GetCurrentUserUseCase> {
  /// Get Current User UseCase Provider
  ///
  /// **역할**: 현재 로그인한 사용자 정보 조회
  /// **의존성**: IAuthRepository
  /// **사용처**: currentUserProvider (FutureProvider)
  const GetCurrentUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentUserUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentUserUseCase create(Ref ref) {
    return getCurrentUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentUserUseCase>(value),
    );
  }
}

String _$getCurrentUserUseCaseHash() =>
    r'2fb99a898a909efc085eb27a447f110890b03064';

/// Sign Out UseCase Provider
///
/// **역할**: 로그아웃
/// **의존성**: IAuthRepository
/// **사용처**: ProfileScreen, SettingsScreen

@ProviderFor(signOutUseCase)
const signOutUseCaseProvider = SignOutUseCaseProvider._();

/// Sign Out UseCase Provider
///
/// **역할**: 로그아웃
/// **의존성**: IAuthRepository
/// **사용처**: ProfileScreen, SettingsScreen

final class SignOutUseCaseProvider
    extends $FunctionalProvider<SignOutUseCase, SignOutUseCase, SignOutUseCase>
    with $Provider<SignOutUseCase> {
  /// Sign Out UseCase Provider
  ///
  /// **역할**: 로그아웃
  /// **의존성**: IAuthRepository
  /// **사용처**: ProfileScreen, SettingsScreen
  const SignOutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignOutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutUseCase create(Ref ref) {
    return signOutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutUseCase>(value),
    );
  }
}

String _$signOutUseCaseHash() => r'd405ca6556edf2bac6c98685b4c001f82237ea8e';
