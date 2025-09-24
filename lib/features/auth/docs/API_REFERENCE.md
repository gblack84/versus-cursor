# Auth Feature - API 레퍼런스

## 📚 API 개요
Auth Feature는 Clean Architecture의 레이어별로 명확히 정의된 API를 제공합니다. 이 문서는 개발자가 Auth 모듈을 사용하기 위한 상세한 API 명세를 제공합니다.

## 🎯 핵심 인터페이스

### IAuthRepository (Domain Layer)
Auth Feature의 핵심 계약(Contract)을 정의하는 인터페이스입니다.

```dart
abstract class IAuthRepository {
  /// 현재 인증된 사용자 조회
  /// @return AuthUser? - 로그인한 사용자 또는 null
  Future<AuthUser?> getCurrentUser();

  /// 이메일/비밀번호로 로그인
  /// @param email - 사용자 이메일
  /// @param password - 사용자 비밀번호
  /// @return AuthUser? - 인증된 사용자 정보
  /// @throws AuthFailure - 인증 실패 시
  Future<AuthUser?> signInWithEmailAndPassword(
    String email,
    String password
  );

  /// 이메일/비밀번호로 계정 생성
  /// @param email - 신규 사용자 이메일
  /// @param password - 신규 사용자 비밀번호
  /// @return AuthUser? - 생성된 사용자 정보
  /// @throws AuthFailure - 계정 생성 실패 시
  Future<AuthUser?> createUserWithEmailAndPassword(
    String email,
    String password
  );

  /// Google 계정으로 로그인
  /// @return AuthUser? - Google 인증 사용자
  /// @throws AuthFailure - Google 로그인 실패
  Future<AuthUser?> signInWithGoogle();

  /// Apple 계정으로 로그인
  /// @return AuthUser? - Apple 인증 사용자
  /// @throws AuthFailure - Apple 로그인 실패
  Future<AuthUser?> signInWithApple();

  /// 전화번호로 로그인
  /// @param phoneNumber - 전화번호
  /// @param verificationCode - SMS 인증 코드
  /// @return AuthUser? - 전화번호 인증 사용자
  Future<AuthUser?> signInWithPhoneNumber(
    String phoneNumber,
    String verificationCode
  );

  /// SMS OTP 전송
  /// @param phoneNumber - 수신 전화번호
  /// @return bool - 전송 성공 여부
  Future<bool> sendSmsOtp(String phoneNumber);

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정 이메일 전송
  /// @param email - 대상 이메일
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증 메일 전송
  Future<void> sendEmailVerification();

  /// 이메일 인증 상태 확인
  /// @return bool - 인증 완료 여부
  Future<bool> isEmailVerified();

  /// 계정 삭제
  /// @param confirmationText - 삭제 확인 텍스트
  /// @return bool - 삭제 성공 여부
  Future<bool> deleteAccount({String? confirmationText});

  /// 비밀번호 업데이트
  /// @param newPassword - 새 비밀번호
  Future<void> updatePassword(String newPassword);
}
```

## 🔧 UseCases (비즈니스 로직)

### SignInWithEmailUseCase
이메일/비밀번호 로그인 비즈니스 로직

```dart
class SignInWithEmailUseCase {
  /// 실행
  /// @param email - 사용자 이메일
  /// @param password - 사용자 비밀번호
  /// @return AuthUser - 인증된 사용자
  /// @throws
  ///   - InvalidEmailFailure: 잘못된 이메일 형식
  ///   - WrongPasswordFailure: 잘못된 비밀번호
  ///   - UserNotFoundFailure: 사용자 없음
  ///   - UserDisabledFailure: 계정 비활성화
  Future<AuthUser> execute(String email, String password);
}
```

### SignUpWithEmailUseCase
이메일 회원가입 비즈니스 로직

```dart
class SignUpWithEmailUseCase {
  /// 실행
  /// @param email - 신규 이메일
  /// @param password - 신규 비밀번호
  /// @return AuthUser - 생성된 사용자
  /// @throws
  ///   - WeakPasswordFailure: 약한 비밀번호
  ///   - EmailAlreadyInUseFailure: 이미 사용 중인 이메일
  ///   - InvalidEmailFailure: 잘못된 이메일 형식
  Future<AuthUser> execute(String email, String password);
}
```

### SignInWithPhoneUseCase
전화번호 인증 비즈니스 로직

```dart
class SignInWithPhoneUseCase {
  /// SMS OTP 전송
  /// @param phoneNumber - 전화번호 (+821012345678 형식)
  /// @return String - 세션 ID
  /// @throws
  ///   - InvalidPhoneNumberFailure: 잘못된 전화번호
  ///   - TooManyRequestsFailure: 요청 제한 초과
  Future<String> sendOtp(String phoneNumber);

  /// OTP 검증 및 로그인
  /// @param sessionId - OTP 세션 ID
  /// @param otpCode - 6자리 OTP 코드
  /// @return AuthUser - 인증된 사용자
  /// @throws
  ///   - InvalidOtpFailure: 잘못된 OTP
  ///   - SessionExpiredFailure: 세션 만료
  Future<AuthUser> verifyOtp(String sessionId, String otpCode);
}
```

### EmailVerificationUseCase
이메일 인증 관리

```dart
class EmailVerificationUseCase {
  /// 인증 메일 전송
  /// @return bool - 전송 성공 여부
  Future<bool> sendVerificationEmail();

  /// 인증 상태 확인
  /// @return bool - 인증 완료 여부
  Future<bool> checkVerificationStatus();

  /// 인증 상태 실시간 감시
  /// @return Stream<bool> - 인증 상태 스트림
  Stream<bool> watchVerificationStatus();
}
```

### AccountManagementUseCase
계정 관리 기능

```dart
class AccountManagementUseCase {
  /// 계정 삭제
  /// @param confirmationText - "DELETE" 확인 텍스트
  /// @param checkReAuth - 재인증 필요 여부
  /// @return bool - 삭제 성공 여부
  /// @throws
  ///   - RequiresRecentLogin: 재인증 필요
  ///   - OperationNotAllowed: 작업 불가
  Future<bool> deleteAccount({
    String? confirmationText,
    bool checkReAuth = false,
  });

  /// 재인증 필요 여부 확인
  /// @return bool - 재인증 필요 여부
  Future<bool> needsReAuthentication();

  /// 사용자 데이터 삭제 요청 (1분 후 자동 삭제)
  Future<void> requestAccountDeletion();
}
```

### PasswordManagementUseCase
비밀번호 관리 기능

```dart
class PasswordManagementUseCase {
  /// 비밀번호 재설정 이메일 전송
  /// @param email - 대상 이메일
  /// @throws
  ///   - UserNotFoundFailure: 사용자 없음
  Future<void> sendPasswordResetEmail(String email);

  /// 비밀번호 변경
  /// @param currentPassword - 현재 비밀번호
  /// @param newPassword - 새 비밀번호
  /// @throws
  ///   - WrongPasswordFailure: 현재 비밀번호 불일치
  ///   - WeakPasswordFailure: 약한 새 비밀번호
  ///   - RequiresRecentLogin: 재인증 필요
  Future<void> changePassword(
    String currentPassword,
    String newPassword
  );
}
```

## 📦 Provider API

### AuthProvider (Presentation Layer)
UI에서 사용하는 상태 관리 Provider

```dart
class AuthProvider extends ChangeNotifier {
  // 싱글톤 인스턴스 획득
  static AuthProvider get instance => GetIt.instance<AuthProvider>();

  // 상태 속성
  AuthUser? get currentUser;
  bool get isLoading;
  String? get errorMessage;
  bool get isInitialized;
  bool get isEmailVerified;
  bool get loggedIn;

  // 인증 메서드
  Future<bool> signInWithEmail(String email, String password);
  Future<bool> signUpWithEmail(String email, String password);
  Future<bool> signInWithGoogle();
  Future<bool> signInWithApple();
  Future<bool> signInWithPhone(String phone, String otp);
  Future<void> signOut();

  // 이메일 인증
  Future<bool> sendEmailVerification();
  Future<void> checkEmailVerificationStatus();

  // 비밀번호 관리
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> updatePassword(String newPassword);

  // 계정 관리
  Future<bool> deleteAccount({String? confirmationText});

  // SMS OTP
  Future<String?> sendSmsOtp(String phoneNumber);
  Future<bool> verifySmsOtp(String sessionId, String otp);

  // 초기화
  Future<void> initialize();
  void dispose();
}
```

## 🔗 Model Classes

### AuthUser
인증된 사용자 정보 모델

```dart
class AuthUser {
  final String uid;           // 사용자 고유 ID
  final String? email;        // 이메일 주소
  final String? displayName;  // 표시 이름
  final String? phoneNumber;  // 전화번호
  final String? photoURL;     // 프로필 이미지 URL
  final bool isEmailVerified; // 이메일 인증 여부
  final bool isAnonymous;     // 익명 사용자 여부
  final DateTime createdAt;   // 계정 생성 시간
  final DateTime lastSignIn;  // 마지막 로그인 시간

  // JSON 변환
  Map<String, dynamic> toJson();
  factory AuthUser.fromJson(Map<String, dynamic> json);

  // Firestore 변환
  factory AuthUser.fromFirebaseUser(User user);
}
```

### AuthFailure
인증 실패 예외 클래스

```dart
abstract class AuthFailure implements Exception {
  final String message;
  final String? code;
}

// 구체적 실패 유형
class ServerFailure extends AuthFailure;
class EmailAlreadyInUseFailure extends AuthFailure;
class InvalidEmailFailure extends AuthFailure;
class WrongPasswordFailure extends AuthFailure;
class UserNotFoundFailure extends AuthFailure;
class UserDisabledFailure extends AuthFailure;
class WeakPasswordFailure extends AuthFailure;
class InvalidCredentialFailure extends AuthFailure;
class OperationNotAllowedFailure extends AuthFailure;
class InvalidPhoneNumberFailure extends AuthFailure;
class InvalidOtpFailure extends AuthFailure;
class SessionExpiredFailure extends AuthFailure;
class TooManyRequestsFailure extends AuthFailure;
class RequiresRecentLogin extends AuthFailure;
class NetworkFailure extends AuthFailure;
class UnknownFailure extends AuthFailure;
```

## 🔌 Dependency Injection

### GetIt 설정
```dart
// app/di.dart
void setupDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl()
  );

  // UseCases
  getIt.registerLazySingleton(() => SignInWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithGoogleUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithAppleUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithPhoneUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton(() => EmailVerificationUseCase(getIt()));
  getIt.registerLazySingleton(() => AccountManagementUseCase(getIt()));
  getIt.registerLazySingleton(() => PasswordManagementUseCase(getIt()));

  // Provider
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider()
  );
}
```

## 🌐 레거시 호환성 API

### auth_util.dart (Backward Compatibility)
기존 코드와의 호환성을 위한 전역 함수

```dart
// 현재 사용자 (프록시)
BaseAuthUser? get currentUser;
bool get loggedIn;
Stream<BaseAuthUser> get authUserStream;

// 사용자 정보
String get currentUserEmail;
String get currentUserUid;
String get currentUserDisplayName;
String get currentUserPhoto;
DocumentReference? get currentUserReference;
bool get currentPhoneNumber;
bool get currentUserEmailVerified;
String get currentJwtToken;

// 레거시 전역 변수 (Deprecated)
@Deprecated('Use AuthProvider.instance instead')
VersusSpaceFirebaseUser? vsFirebaseUserAuthUserRecord;
```

## 📝 에러 처리 가이드

### 에러 처리 패턴
```dart
try {
  final user = await authProvider.signInWithEmail(email, password);
  // 성공 처리
} on InvalidEmailFailure {
  // 잘못된 이메일 형식
  showError('올바른 이메일 주소를 입력해주세요');
} on WrongPasswordFailure {
  // 잘못된 비밀번호
  showError('비밀번호가 일치하지 않습니다');
} on UserNotFoundFailure {
  // 사용자 없음
  showError('등록되지 않은 사용자입니다');
} on AuthFailure catch (e) {
  // 기타 인증 실패
  showError(e.message);
} catch (e) {
  // 예상치 못한 에러
  showError('오류가 발생했습니다. 다시 시도해주세요');
}
```

## 🔄 스트림 처리

### 인증 상태 감시
```dart
// 인증 상태 스트림
authProvider.authStateChanges.listen((user) {
  if (user != null) {
    // 로그인 상태
    navigateToHome();
  } else {
    // 로그아웃 상태
    navigateToLogin();
  }
});

// 이메일 인증 상태 감시
authProvider.emailVerificationStream.listen((verified) {
  if (verified) {
    // 이메일 인증 완료
    enableFullFeatures();
  }
});
```

## 🚀 성능 최적화 팁

1. **Provider 재사용**: GetIt을 통해 싱글톤 인스턴스 사용
2. **스트림 구독 해제**: dispose()에서 반드시 스트림 구독 해제
3. **에러 캐싱**: 반복적인 에러는 로컬 캐싱
4. **비동기 초기화**: 앱 시작 시 병렬 초기화

## 📌 버전 정보
- **현재 버전**: 1.0.0
- **최소 Flutter**: 3.0.0
- **Firebase Auth**: 5.3.3+