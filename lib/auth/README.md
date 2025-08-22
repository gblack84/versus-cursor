# Auth System

Versus Space 앱의 통합 인증 시스템을 관리하는 최상위 디렉토리입니다.

## 📋 개요

Firebase Authentication을 기반으로 다양한 인증 방법을 지원하며, 추상화된 인터페이스를 통해 확장 가능한 인증 아키텍처를 제공합니다. 사용자 세션 관리, 권한 제어, 그리고 7가지 인증 방식을 통합 관리합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/auth/
├── README.md                     # 이 문서
├── auth_manager.dart            # 추상 인증 매니저 및 믹스인 정의
├── base_auth_user_provider.dart # 기본 사용자 인터페이스 정의
└── firebase_auth/               # Firebase 인증 구현체
    ├── README.md                # Firebase Auth 상세 문서
    ├── auth_util.dart          # 인증 유틸리티 함수
    ├── firebase_auth_manager.dart # Firebase 인증 매니저 구현
    ├── firebase_user_provider.dart # Firebase 사용자 프로바이더
    ├── email_auth.dart         # 이메일 인증
    ├── google_auth.dart        # Google OAuth
    ├── apple_auth.dart         # Apple Sign In
    ├── github_auth.dart        # GitHub OAuth
    ├── anonymous_auth.dart     # 익명 인증
    └── jwt_token_auth.dart     # JWT 토큰 인증
```

## 🏗️ 아키텍처

### 계층 구조

```
┌─────────────────────────────────────┐
│         Application Layer           │
│  (Pages, Components, Widgets)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Auth Abstraction            │
│   (AuthManager, BaseAuthUser)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Firebase Auth Implementation   │
│    (FirebaseAuthManager + Mixins)   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Firebase Services           │
│    (Firebase Auth, Firestore)       │
└─────────────────────────────────────┘
```

## 🔧 주요 구성요소

### 1. AuthManager (`auth_manager.dart`)

모든 인증 구현체가 상속해야 하는 추상 클래스입니다.

**핵심 메서드:**
```dart
abstract class AuthManager {
  Future signOut();
  Future deleteUser(BuildContext context);
  Future updateEmail({required String email, required BuildContext context});
  Future resetPassword({required String email, required BuildContext context});
  Future sendEmailVerification();
  Future refreshUser();
}
```

**인증 방식별 Mixin:**
- `EmailSignInManager`: 이메일/비밀번호 인증
- `GoogleSignInManager`: Google OAuth
- `AppleSignInManager`: Apple Sign In  
- `GithubSignInManager`: GitHub OAuth
- `PhoneSignInManager`: 전화번호 인증
- `AnonymousSignInManager`: 익명 인증
- `JwtSignInManager`: JWT 토큰 인증
- `FacebookSignInManager`: Facebook 로그인 (인터페이스만 정의)
- `MicrosoftSignInManager`: Microsoft 로그인 (인터페이스만 정의)

### 2. BaseAuthUserProvider (`base_auth_user_provider.dart`)

사용자 정보를 추상화한 인터페이스입니다.

**AuthUserInfo 클래스:**
```dart
class AuthUserInfo {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
}
```

**BaseAuthUser 추상 클래스:**
```dart
abstract class BaseAuthUser {
  bool get loggedIn;
  bool get emailVerified;
  AuthUserInfo get authUserInfo;
  
  // 사용자 관리 메서드
  Future? delete();
  Future? updateEmail(String email);
  Future? updatePassword(String newPassword);
  Future? sendEmailVerification();
  Future refreshUser();
}
```

**전역 접근:**
```dart
BaseAuthUser? currentUser;  // 현재 로그인한 사용자
bool get loggedIn => currentUser?.loggedIn ?? false;  // 로그인 상태
```

### 3. Firebase Auth 구현체 (`firebase_auth/`)

실제 Firebase Authentication과 통합되는 구현체입니다.

**FirebaseAuthManager:**
- `AuthManager`를 상속하고 모든 인증 Mixin을 구현
- 7가지 인증 방식 완벽 지원
- 전화번호 인증 전용 `FirebasePhoneAuthManager` 포함
- 플랫폼별 최적화 (Web/Mobile)

자세한 내용은 [firebase_auth/README.md](firebase_auth/README.md) 참조

## 🔐 지원 인증 방식

### 1. 이메일/비밀번호 인증
```dart
// 회원가입
final user = await authManager.createAccountWithEmail(
  context,
  email,
  password,
);

// 로그인
final user = await authManager.signInWithEmail(
  context,
  email,
  password,
);
```

### 2. Google OAuth
```dart
final user = await authManager.signInWithGoogle(context);
```

### 3. Apple Sign In
```dart
final user = await authManager.signInWithApple(context);
```

### 4. GitHub OAuth
```dart
final user = await authManager.signInWithGithub(context);
```

### 5. 전화번호 인증
```dart
// SMS 전송
await authManager.beginPhoneAuth(
  context: context,
  phoneNumber: '+821012345678',
  onCodeSent: (context) {
    // SMS 전송 완료 후 처리
  },
);

// 인증 코드 확인
final user = await authManager.verifySmsCode(
  context: context,
  smsCode: '123456',
);
```

### 6. 익명 인증
```dart
final user = await authManager.signInAnonymously(context);
```

### 7. JWT 토큰 인증
```dart
final user = await authManager.signInWithJwtToken(
  context,
  jwtToken,
);
```

## 🔄 인증 플로우

### 일반 인증 플로우
```
1. 사용자가 인증 방식 선택
    ↓
2. AuthManager의 해당 메서드 호출
    ↓
3. FirebaseAuthManager가 실제 인증 처리
    ↓
4. BaseAuthUser 객체 생성 및 반환
    ↓
5. 전역 currentUser 업데이트
    ↓
6. Firestore 사용자 문서 생성/업데이트
```

### 전화번호 인증 플로우
```
1. beginPhoneAuth() 호출
    ↓
2. Firebase가 SMS 발송
    ↓
3. onCodeSent 콜백 실행
    ↓
4. 사용자가 SMS 코드 입력
    ↓
5. verifySmsCode() 호출
    ↓
6. 인증 성공 시 일반 플로우와 동일
```

## 📊 사용자 정보 접근

### 전역 헬퍼 함수 (auth_util.dart)
```dart
// 현재 사용자 정보
String get currentUserEmail
String get currentUserUid
String get currentUserDisplayName
String get currentUserPhoto
String get currentPhoneNumber
String get currentJwtToken
bool get currentUserEmailVerified

// Firestore 참조
DocumentReference? get currentUserReference
UsersModel? currentUserDocument

// 스트림
Stream<UsersModel?> authenticatedUserStream
Stream<String?> jwtTokenStream
```

### AuthUserStreamWidget
인증 상태 변경을 자동으로 감지하는 위젯:
```dart
AuthUserStreamWidget(
  builder: (context) => Text('Logged in: $loggedIn'),
)
```

## 🛡️ 보안 고려사항

### 1. 에러 처리
- 모든 인증 메서드에 try-catch 블록
- 사용자 친화적인 에러 메시지
- ScaffoldMessenger를 통한 피드백

### 2. 재인증 요구
- 민감한 작업 시 재인증 필요
- 이메일 변경, 비밀번호 변경, 계정 삭제

### 3. 플랫폼별 보안
- **Apple Sign In**: Nonce 기반 replay attack 방지
- **전화번호 인증**: SMS 전송 제한 (3회/24시간)
- **JWT 토큰**: 자동 갱신 메커니즘

### 4. 세션 관리
- Firebase Auth 자동 세션 관리
- JWT 토큰 매시간 자동 갱신
- 30일 후 자동 로그아웃

## 🧪 테스트

### 테스트 계정
```dart
// 개발 환경에서만 사용
if (kDebugMode) {
  // iOS 테스터
  email: 'tester-ios@versus.test'
  password: 'test1234'
  
  // Android 테스터
  email: 'tester-android@versus.test'
  password: 'test1234'
}
```

### 단위 테스트
```dart
test('Email sign in', () async {
  final user = await authManager.signInWithEmail(
    context,
    'test@example.com',
    'password123',
  );
  expect(user, isNotNull);
  expect(user?.email, 'test@example.com');
});
```

## 📈 성능 최적화

### 1. 인증 상태 캐싱
- SharedPreferences 활용
- 앱 재시작 시 빠른 상태 복원

### 2. 스트림 최적화
- BroadcastStream 사용으로 다중 구독 지원
- debounce를 통한 불필요한 업데이트 방지

### 3. 비동기 처리
- 모든 인증 작업 비동기 처리
- UI 블로킹 방지

## 🔮 향후 개선 계획

### 구현 예정
1. **Facebook 로그인**: FacebookSignInManager 구현
2. **Microsoft 로그인**: MicrosoftSignInManager 구현
3. **생체 인증**: Face ID, Touch ID, 지문 인증
4. **2단계 인증**: TOTP, SMS OTP

### 고려 중
- 카카오 로그인 통합
- 네이버 로그인 통합
- WebAuthn 지원
- Passkey 지원

## 📝 마이그레이션 노트

### FlutterFlow → Native Flutter (2025-07-03)
- `FFAppState` → `AppState`
- `currentUser` → `currentUserReference`
- FlutterFlow 인증 액션 → 직접 Firebase Auth 호출

### Snake_case → CamelCase (2025-08-21)
- 모든 필드명 camelCase 변환 완료
- Backward compatibility 제거

## 📚 관련 문서
- [Firebase Auth 구현체 상세](firebase_auth/README.md)
- [프로젝트 네이밍 컨벤션](../../NAMING_CONVENTION.md)
- [프로젝트 아키텍처](../../ARCHITECTURE.md)
- [인증 플로우 다이어그램](../../docs/AUTH_FLOW.md)

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정, firebase_auth 하위 디렉토리와 통합
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 2025-07-03: FlutterFlow → Native Flutter 마이그레이션
- 초기: FlutterFlow 자동 생성 코드

---

*이 문서는 `/lib/auth` 디렉토리의 메인 문서입니다.*
*하위 구현체 상세 사항은 [firebase_auth/README.md](firebase_auth/README.md)를 참조하세요.*