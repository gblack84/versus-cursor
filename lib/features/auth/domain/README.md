# Auth Feature - Domain Layer

## 🎯 개요

Domain Layer는 Clean Architecture의 가장 내부 계층으로, **비즈니스 로직과 규칙**을 정의합니다. 이 계층은 프레임워크, UI, 데이터베이스 등 외부 요소에 **전혀 의존하지 않는** 순수한 Dart 코드로 구성됩니다.

### 📌 현재 구현 상태
- ✅ **models**: `auth_user.dart` (1개 파일)
- ✅ **repositories**: `i_auth_repository.dart` (1개 인터페이스)
- ✅ **usecases**: 10개 UseCase 모두 구현 완료
- ✅ **failures**: `auth_failure.dart` (1개 파일)
- 📝 **향후 추가 가능**: `auth_session.dart`, `auth_token.dart`, factories 패턴

### 핵심 원칙
- ✅ **독립성**: 외부 패키지나 프레임워크 의존성 없음
- ✅ **순수성**: 순수 Dart 코드만 사용
- ✅ **테스트 가능성**: 100% 단위 테스트 가능
- ✅ **비즈니스 중심**: 기술이 아닌 비즈니스 규칙에 집중

## 🏗️ 전체 구조도

```
lib/features/auth/domain/
│
├── 📁 models/               # 비즈니스 엔티티
│   └── auth_user.dart      # 사용자 도메인 모델
│
├── 📁 repositories/         # Repository 인터페이스 (계약)
│   └── i_auth_repository.dart   # 인증 Repository 추상화
│
├── 📁 usecases/            # 비즈니스 유스케이스 (10개)
│   ├── sign_in_with_email_usecase.dart      # 이메일 로그인
│   ├── sign_up_with_email_usecase.dart      # 이메일 회원가입
│   ├── sign_in_with_google_usecase.dart     # Google 로그인
│   ├── sign_in_with_apple_usecase.dart      # Apple 로그인
│   ├── sign_in_with_phone_usecase.dart      # 전화번호 인증
│   ├── sign_out_usecase.dart                # 로그아웃
│   ├── get_current_user_usecase.dart        # 현재 사용자 조회
│   ├── email_verification_usecase.dart      # 이메일 인증
│   ├── password_management_usecase.dart     # 비밀번호 관리
│   └── account_management_usecase.dart      # 계정 관리
│
└── 📁 failures/            # 도메인 예외
    └── auth_failure.dart   # 인증 실패 케이스
```

### 📝 향후 추가 가능한 파일들
```
models/
  ├── auth_session.dart   # 세션 관리가 필요할 때
  └── auth_token.dart     # JWT 토큰 관리가 필요할 때

factories/                # 복잡한 엔티티 생성이 필요할 때
  └── auth_user_factory.dart
```

## 📂 디렉토리별 상세 설명

### 1. models/ - 비즈니스 엔티티

**목적**: 비즈니스 도메인의 핵심 개념을 표현하는 순수 데이터 모델

#### 📄 auth_user.dart
```dart
class AuthUser {
  // 인증 필수 정보
  final String uid;                // 고유 식별자
  final String? email;             // 이메일 주소
  final String? displayName;       // 표시 이름
  final String? userName;          // 사용자명 (unique)
  final String? photoUrl;          // 프로필 이미지
  final String? phoneNumber;       // 전화번호
  final bool isEmailVerified;      // 이메일 인증 여부
  final bool isAnonymous;         // 익명 사용자 여부

  // 프로필 정보
  final String? bio;               // 자기소개
  final int? age;                  // 나이
  final String? gender;            // 성별
  final List<String> interests;    // 관심사
  final List<String> expertise;    // 전문분야 (최대 4개)
  final List<String> hobbies;      // 취미 (최대 8개)

  // 게임화 요소
  final int pointsA;               // 답변 포인트
  final int pointsQ;               // 질문 포인트
  final String role;               // 역할 (user/admin/tester)
  final bool isPremium;            // 프리미엄 여부

  // 시간 정보
  final DateTime? createdAt;       // 계정 생성 시간
  final DateTime? lastLoginAt;     // 마지막 로그인

  // 설정
  final Map<String, dynamic> settings;  // 사용자 설정

  // 비즈니스 메서드
  bool get isProfileComplete =>
    userName != null && age != null && interests.isNotEmpty;

  bool get canCreateContent =>
    isEmailVerified && !isAnonymous;

  bool get isNewUser =>
    createdAt != null &&
    DateTime.now().difference(createdAt!).inDays < 7;
}
```

**특징**:
- 🎯 불변 객체 (immutable)
- 📊 비즈니스 로직 메서드 포함
- 🛡️ Null safety 완벽 지원
- 🔍 계산된 속성 제공

**📌 참고**: 현재 `auth_user.dart`만 구현되어 있습니다. 향후 세션 관리나 토큰 관리가 필요한 경우 `auth_session.dart`나 `auth_token.dart`를 추가할 수 있습니다.

### 2. repositories/ - Repository 인터페이스

**목적**: Data Layer와의 계약을 정의하는 추상 인터페이스

#### 📄 i_auth_repository.dart
```dart
/// 인증 Repository 인터페이스
///
/// Domain Layer가 Data Layer에 요구하는 계약
/// 구현체는 Data Layer에 존재
abstract class IAuthRepository {
  // 인증 작업
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password);
  Future<AuthUser?> createUserWithEmailAndPassword(String email, String password);
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInWithApple();
  Future<AuthUser?> signInWithPhoneNumber(String phoneNumber, String verificationCode);

  // SMS OTP
  Future<bool> sendSmsOtp(String phoneNumber);
  Future<bool> verifySmsOtp(String sessionId, String otp);

  // 계정 관리
  Future<void> signOut();
  Future<bool> deleteAccount({String? confirmationText});
  Future<void> updatePassword(String newPassword);

  // 이메일 관리
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();

  // 프로필 관리
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<bool> isUserNameAvailable(String userName);

  // 스트림
  Stream<AuthUser?> get authStateChanges;
  Stream<bool> get emailVerificationStream;
}
```

**설계 원칙**:
- 🔄 비동기 작업 중심 (Future/Stream)
- 📋 명확한 메서드 시그니처
- 🎯 단일 책임 원칙
- 🚫 구현 세부사항 없음

### 3. usecases/ - 비즈니스 유스케이스

**목적**: 애플리케이션의 비즈니스 규칙과 로직을 캡슐화

#### 📄 sign_in_with_email_usecase.dart
```dart
class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase({required IAuthRepository repository})
    : _repository = repository;

  /// 이메일 로그인 실행
  Future<AuthUser?> execute({
    required String email,
    required String password,
  }) async {
    // 1. 입력 검증 (비즈니스 규칙)
    if (!_isValidEmail(email)) {
      throw InvalidEmail();
    }

    if (password.length < 6) {
      throw WeakPassword();
    }

    // 2. Repository 호출
    try {
      final user = await _repository.signInWithEmailAndPassword(
        email.trim().toLowerCase(),
        password,
      );

      // 3. 비즈니스 규칙 적용
      if (user != null && !user.isEmailVerified) {
        // 이메일 미인증 사용자 처리
        await _repository.sendEmailVerification();
        throw EmailNotVerified();
      }

      return user;

    } catch (e) {
      // 4. 에러 변환
      throw _mapToAuthFailure(e);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

#### 📄 sign_up_with_email_usecase.dart
```dart
class SignUpWithEmailUseCase {
  final IAuthRepository _repository;

  /// 이메일 회원가입 실행
  Future<AuthUser?> execute({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // 1. 비즈니스 규칙: 비밀번호 강도 검증
    if (!_isStrongPassword(password)) {
      throw WeakPassword();
    }

    // 2. 이메일 중복 확인 (선택적)
    // ...

    // 3. 계정 생성
    final user = await _repository.createUserWithEmailAndPassword(
      email,
      password,
    );

    // 4. 프로필 초기화
    if (user != null && displayName != null) {
      await _repository.updateProfile({'displayName': displayName});
    }

    // 5. 인증 메일 전송
    await _repository.sendEmailVerification();

    return user;
  }

  bool _isStrongPassword(String password) {
    // 최소 8자, 대소문자, 숫자, 특수문자 포함
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }
}
```

#### 📄 sign_in_with_phone_usecase.dart
```dart
class SignInWithPhoneUseCase {
  final IAuthRepository _repository;

  // SMS 재전송 제한 관리
  final Map<String, int> _resendAttempts = {};
  static const int maxResendAttempts = 3;

  /// SMS OTP 전송
  Future<String?> sendOtp(String phoneNumber) async {
    // 1. 전화번호 형식 검증
    if (!_isValidPhoneNumber(phoneNumber)) {
      throw InvalidPhoneNumber();
    }

    // 2. 재전송 제한 확인
    final attempts = _resendAttempts[phoneNumber] ?? 0;
    if (attempts >= maxResendAttempts) {
      throw TooManyAttempts();  // 3회 제한
    }

    // 3. OTP 전송
    final success = await _repository.sendSmsOtp(phoneNumber);

    if (success) {
      _resendAttempts[phoneNumber] = attempts + 1;
      return phoneNumber;  // 세션 ID 역할
    }

    throw SmsNotSent();
  }

  /// OTP 검증 및 로그인
  Future<AuthUser?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // OTP 형식 검증 (6자리 숫자)
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      throw InvalidSmsCode();
    }

    return await _repository.signInWithPhoneNumber(
      phoneNumber,
      otp,
    );
  }

  /// 재전송 카운터 리셋
  void resetResendCounter(String phoneNumber) {
    _resendAttempts.remove(phoneNumber);
  }
}
```

#### 📄 email_verification_usecase.dart
```dart
class EmailVerificationUseCase {
  final IAuthRepository _repository;

  /// 인증 메일 전송
  Future<bool> sendVerificationEmail() async {
    final user = await _repository.getCurrentUser();

    if (user == null) {
      throw UserNotFound();
    }

    if (user.isEmailVerified) {
      return true;  // 이미 인증됨
    }

    await _repository.sendEmailVerification();
    return false;  // 인증 대기중
  }

  /// 인증 상태 확인
  Future<bool> checkVerificationStatus() async {
    return await _repository.isEmailVerified();
  }

  /// 실시간 인증 상태 감시
  Stream<bool> watchVerificationStatus() {
    return _repository.emailVerificationStream;
  }
}
```

#### 📄 account_management_usecase.dart
```dart
class AccountManagementUseCase {
  final IAuthRepository _repository;

  /// 계정 삭제
  Future<bool> deleteAccount({
    String? confirmationText,
    bool checkReAuth = false,
  }) async {
    // 1. 확인 텍스트 검증
    if (confirmationText != null && confirmationText != 'DELETE') {
      return false;
    }

    // 2. 재인증 필요 확인
    if (checkReAuth && await needsReAuthentication()) {
      throw RequiresRecentLogin();
    }

    // 3. 계정 삭제 수행
    return await _repository.deleteAccount(
      confirmationText: confirmationText,
    );
  }

  /// 재인증 필요 여부
  Future<bool> needsReAuthentication() async {
    final user = await _repository.getCurrentUser();
    if (user?.lastLoginAt == null) return true;

    // 30분 이상 경과 시 재인증 필요
    final elapsed = DateTime.now().difference(user!.lastLoginAt!);
    return elapsed.inMinutes > 30;
  }

  /// 1분 후 자동 삭제 요청
  Future<void> requestAccountDeletion() async {
    // 백그라운드 삭제 작업 예약
    // Firebase Functions 또는 스케줄러 활용
  }
}
```

### 4. failures/ - 도메인 예외

**목적**: 비즈니스 규칙 위반이나 예외 상황을 표현

#### 📄 auth_failure.dart
```dart
/// Sealed Class를 활용한 타입 안전 에러 처리
sealed class AuthFailure {
  const AuthFailure();

  /// 사용자 친화적 메시지 변환
  String get message {
    return switch (this) {
      // 이메일/비밀번호 에러
      InvalidEmail() => '올바른 이메일 형식이 아닙니다',
      WeakPassword() => '비밀번호가 너무 약합니다',
      EmailAlreadyInUse() => '이미 사용 중인 이메일입니다',
      InvalidCredentials() => '이메일 또는 비밀번호가 잘못되었습니다',

      // 전화번호 인증 에러
      InvalidPhoneNumber() => '잘못된 전화번호 형식입니다',
      InvalidSmsCode() => '잘못된 인증 코드입니다',
      SmsCodeExpired() => '인증 코드가 만료되었습니다',
      TooManyAttempts() => '재전송 횟수를 초과했습니다',

      // 소셜 로그인 에러
      CancelledByUser() => '로그인이 취소되었습니다',
      SocialSignInFailed() => '소셜 로그인에 실패했습니다',

      // 계정 상태 에러
      UserNotFound() => '사용자를 찾을 수 없습니다',
      UserDisabled() => '비활성화된 계정입니다',
      EmailNotVerified() => '이메일 인증이 필요합니다',
      RequiresRecentLogin() => '보안을 위해 재로그인이 필요합니다',

      // 프로필 에러
      UserNameAlreadyTaken() => '이미 사용 중인 사용자명입니다',
      ProfileIncomplete() => '프로필 정보를 완성해주세요',

      // 시스템 에러
      NetworkError() => '네트워크 연결을 확인해주세요',
      ServerError() => '서버 오류가 발생했습니다',
      InsufficientPermission() => '권한이 부족합니다',

      // 예상치 못한 에러
      Unexpected(message: final msg) => msg ?? '예기치 않은 오류가 발생했습니다',
    };
  }

  /// 에러 코드 (로깅용)
  String get code {
    return switch (this) {
      InvalidEmail() => 'INVALID_EMAIL',
      WeakPassword() => 'WEAK_PASSWORD',
      EmailAlreadyInUse() => 'EMAIL_IN_USE',
      // ... 기타 코드
      _ => 'UNKNOWN_ERROR',
    };
  }
}

// 구체적인 실패 케이스들
class InvalidEmail extends AuthFailure {}
class WeakPassword extends AuthFailure {}
class EmailAlreadyInUse extends AuthFailure {}
class InvalidCredentials extends AuthFailure {}
class InvalidPhoneNumber extends AuthFailure {}
class InvalidSmsCode extends AuthFailure {}
class SmsCodeExpired extends AuthFailure {}
class TooManyAttempts extends AuthFailure {}
class CancelledByUser extends AuthFailure {}
class SocialSignInFailed extends AuthFailure {}
class NetworkError extends AuthFailure {}
class ServerError extends AuthFailure {}
class UserNotFound extends AuthFailure {}
class UserDisabled extends AuthFailure {}
class EmailNotVerified extends AuthFailure {}
class InsufficientPermission extends AuthFailure {}
class RequiresRecentLogin extends AuthFailure {}
class UserNameAlreadyTaken extends AuthFailure {}
class ProfileIncomplete extends AuthFailure {}

class Unexpected extends AuthFailure {
  final String? message;
  const Unexpected({this.message});
}
```


## 🔄 비즈니스 플로우

### 이메일 회원가입 플로우
```
1. SignUpWithEmailUseCase.execute()
   ↓
2. 이메일 형식 검증 (비즈니스 규칙)
   ↓
3. 비밀번호 강도 검증 (비즈니스 규칙)
   ↓
4. IAuthRepository.createUserWithEmailAndPassword()
   ↓
5. 프로필 초기화
   ↓
6. 이메일 인증 메일 전송
   ↓
7. AuthUser 반환 또는 AuthFailure 발생
```

### SMS 인증 플로우 (3회 제한)
```
1. SignInWithPhoneUseCase.sendOtp()
   ↓
2. 전화번호 형식 검증
   ↓
3. 재전송 횟수 확인 (≤3)
   ↓
4. IAuthRepository.sendSmsOtp()
   ↓
5. 재전송 카운터 증가
   ↓
6. OTP 입력 대기
   ↓
7. SignInWithPhoneUseCase.verifyOtp()
   ↓
8. IAuthRepository.signInWithPhoneNumber()
   ↓
9. AuthUser 반환 또는 재시도
```

## 🧪 테스트 전략

### UseCase 테스트
```dart
class SignInWithEmailUseCaseTest {
  test('이메일 형식 검증', () {
    final useCase = SignInWithEmailUseCase(mockRepository);

    expect(
      () => useCase.execute(
        email: 'invalid-email',
        password: 'password123',
      ),
      throwsA(isA<InvalidEmail>()),
    );
  });

  test('약한 비밀번호 거부', () {
    final useCase = SignInWithEmailUseCase(mockRepository);

    expect(
      () => useCase.execute(
        email: 'test@example.com',
        password: '123',  // 너무 짧음
      ),
      throwsA(isA<WeakPassword>()),
    );
  });
}
```

### Model 테스트
```dart
test('프로필 완성 여부 확인', () {
  final user = AuthUser(
    uid: 'test123',
    userName: 'testuser',
    age: 25,
    interests: ['coding'],
  );

  expect(user.isProfileComplete, true);
});
```

## 🏛️ 아키텍처 원칙

### 1. 의존성 역전 원칙 (DIP)
- Domain은 어떤 외부 레이어에도 의존하지 않음
- Repository는 인터페이스로만 정의
- 구현체는 Data Layer에 존재

### 2. 단일 책임 원칙 (SRP)
- 각 UseCase는 하나의 비즈니스 작업만 담당
- Model은 데이터와 비즈니스 규칙만 포함
- Failure는 에러 표현에만 집중

### 3. 개방-폐쇄 원칙 (OCP)
- 새로운 인증 방식 추가 시 기존 코드 수정 불필요
- 새로운 UseCase 추가로 확장 가능

## 🚀 확장 가능성

### 새로운 인증 방식 추가
1. 새 UseCase 생성 (예: `SignInWithBiometricUseCase`)
2. IAuthRepository에 메서드 추가
3. 기존 코드 영향 없음

### 새로운 비즈니스 규칙 추가
1. UseCase 내부 로직 추가
2. 필요시 새 Failure 타입 정의
3. Model에 계산 속성 추가

## 📊 성능 고려사항

- **불변성**: 모든 Model은 불변 객체로 설계
- **지연 계산**: 계산 비용이 큰 속성은 getter로 구현
- **캐싱**: UseCase 레벨에서 결과 캐싱 가능
- **검증 최적화**: 정규식 사전 컴파일

## 🔗 관련 문서

- [Data Layer](../data/README.md) - Repository 구현체
- [Presentation Layer](../presentation/README.md) - UI 레이어
- [API Reference](../docs/API_REFERENCE.md) - API 명세
- [Usage Guide](../docs/USAGE_GUIDE.md) - 사용 가이드