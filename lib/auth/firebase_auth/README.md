# Firebase Auth

Firebase 인증 시스템의 핵심 구현을 담당하는 디렉토리입니다.

## 📋 개요

Versus Space 앱의 다양한 인증 방식을 Firebase Auth를 통해 구현한 모듈입니다. 이메일, 구글, 애플, GitHub, 전화번호, 익명 로그인 및 JWT 토큰 기반 인증을 지원합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/auth/firebase_auth/
├── README.md                  # 이 문서
├── auth_util.dart            # 인증 유틸리티 및 현재 사용자 정보 헬퍼
├── firebase_auth_manager.dart # Firebase 인증 매니저 (메인 인증 로직)
├── firebase_user_provider.dart # Firebase 사용자 프로바이더
├── email_auth.dart           # 이메일 인증 구현
├── google_auth.dart          # Google OAuth 인증
├── apple_auth.dart           # Apple Sign In 인증
├── github_auth.dart          # GitHub OAuth 인증
├── anonymous_auth.dart       # 익명 인증
└── jwt_token_auth.dart       # JWT 토큰 기반 인증
```

## 🔧 주요 구성요소

### 1. FirebaseAuthManager (`firebase_auth_manager.dart`)

앱의 모든 인증 방식을 통합 관리하는 중앙 매니저 클래스입니다.

**주요 기능:**
- 다양한 인증 방식 통합 (이메일, Google, Apple, GitHub, 전화번호, 익명, JWT)
- 사용자 계정 관리 (생성, 로그인, 로그아웃, 삭제)
- 비밀번호 재설정 및 이메일 업데이트
- 전화번호 인증 플로우 관리

**핵심 메서드:**
```dart
// 로그인 메서드들
Future<BaseAuthUser?> signInWithEmail(context, email, password)
Future<BaseAuthUser?> signInWithGoogle(context)
Future<BaseAuthUser?> signInWithApple(context)
Future<BaseAuthUser?> signInWithGithub(context)
Future<BaseAuthUser?> signInAnonymously(context)
Future<BaseAuthUser?> signInWithJwtToken(context, jwtToken)

// 계정 관리
Future<BaseAuthUser?> createAccountWithEmail(context, email, password)
Future signOut()
Future deleteUser(context)
Future updateEmail(email, context)
Future updatePassword(newPassword, context)
Future resetPassword(email, context)

// 전화번호 인증
Future beginPhoneAuth(context, phoneNumber, onCodeSent)
Future verifySmsCode(context, smsCode)
```

### 2. Auth Util (`auth_util.dart`)

현재 로그인한 사용자 정보에 쉽게 접근할 수 있는 유틸리티 함수들을 제공합니다.

**전역 접근 가능한 정보:**
```dart
String get currentUserEmail        // 현재 사용자 이메일
String get currentUserUid          // 현재 사용자 UID
String get currentUserDisplayName  // 현재 사용자 표시 이름
String get currentUserPhoto        // 현재 사용자 프로필 사진 URL
String get currentPhoneNumber      // 현재 사용자 전화번호
String get currentJwtToken         // 현재 JWT 토큰
bool get currentUserEmailVerified  // 이메일 인증 여부
DocumentReference? get currentUserReference  // Firestore 사용자 문서 참조
```

**스트림:**
- `authenticatedUserStream`: 인증 상태 변경 감지 및 사용자 문서 자동 로드
- `jwtTokenStream`: JWT 토큰 자동 갱신 (Firebase는 매시간 토큰 재생성)

**위젯:**
- `AuthUserStreamWidget`: 인증 상태 변경을 자동으로 감지하는 StreamBuilder 래퍼

### 3. Firebase User Provider (`firebase_user_provider.dart`)

Firebase User 객체를 앱의 BaseAuthUser 인터페이스로 래핑합니다.

**VersusSpaceFirebaseUser 클래스:**
- Firebase User를 BaseAuthUser로 변환
- 사용자 정보 접근 (uid, email, displayName, photoUrl, phoneNumber)
- 사용자 관리 메서드 (delete, updateEmail, updatePassword, sendEmailVerification)
- 이메일 인증 상태 실시간 확인

### 4. 인증 방식별 구현

#### Email Auth (`email_auth.dart`)
```dart
Future<UserCredential?> emailSignInFunc(email, password)
Future<UserCredential?> emailCreateAccountFunc(email, password)
```
- 이메일/비밀번호 기반 로그인 및 계정 생성
- 이메일 트림 처리 자동 적용

#### Google Auth (`google_auth.dart`)
```dart
Future<UserCredential?> googleSignInFunc()
Future signOutWithGoogle()
```
- Google OAuth 2.0 인증
- 웹: 팝업 방식
- 모바일: Google Sign In SDK 사용
- profile, email 스코프 요청

#### Apple Auth (`apple_auth.dart`)
```dart
Future<UserCredential> appleSignIn()
```
- Apple Sign In 구현
- 웹: OAuth 팝업
- 모바일: sign_in_with_apple 패키지 사용
- nonce 기반 replay attack 방지
- 사용자 이름 자동 업데이트

#### GitHub Auth (`github_auth.dart`)
```dart
Future<UserCredential?> githubSignInFunc()
```
- GitHub OAuth 인증
- 팝업 방식 로그인

#### Anonymous Auth (`anonymous_auth.dart`)
```dart
Future<UserCredential?> anonymousSignInFunc()
```
- 익명 사용자 생성
- 임시 계정으로 앱 사용 가능

#### JWT Token Auth (`jwt_token_auth.dart`)
```dart
Future<UserCredential?> jwtTokenSignIn(jwtToken)
```
- 커스텀 JWT 토큰 기반 인증
- 서버 측에서 발급한 토큰으로 로그인

## 🔄 인증 플로우

### 일반 인증 플로우
1. 사용자가 로그인 방식 선택
2. `FirebaseAuthManager`의 해당 메서드 호출
3. `_signInOrCreateAccount` 내부 메서드가 실제 인증 처리
4. 성공 시 `maybeCreateUser`로 Firestore 사용자 문서 생성
5. `VersusSpaceFirebaseUser` 객체 반환
6. `authenticatedUserStream`이 자동으로 사용자 문서 로드

### 전화번호 인증 플로우
1. `beginPhoneAuth`로 전화번호 입력 및 SMS 발송
2. Firebase가 SMS 코드 전송
3. `onCodeSent` 콜백 실행으로 코드 입력 화면 전환
4. 사용자가 SMS 코드 입력
5. `verifySmsCode`로 코드 검증
6. 인증 성공 시 일반 플로우와 동일하게 진행

## 🔒 보안 고려사항

1. **에러 처리**: 모든 인증 메서드에 try-catch로 에러 처리
2. **사용자 피드백**: ScaffoldMessenger로 에러 메시지 표시
3. **재인증 요구**: 민감한 작업(이메일 변경, 계정 삭제) 시 재인증 필요
4. **Nonce 사용**: Apple Sign In에서 replay attack 방지
5. **토큰 자동 갱신**: JWT 토큰 만료 전 자동 갱신

## 🔍 에러 코드 처리

주요 Firebase Auth 에러 코드 처리:
- `email-already-in-use`: 이미 사용 중인 이메일
- `INVALID_LOGIN_CREDENTIALS`: 잘못된 로그인 정보
- `requires-recent-login`: 재인증 필요
- 기타 에러: 원본 메시지 표시

## 📱 플랫폼별 고려사항

### Web
- Google/Apple 로그인: 팝업 방식
- 전화번호 인증: `signInWithPhoneNumber` 사용

### Mobile (iOS/Android)
- Google 로그인: 네이티브 SDK 사용
- Apple 로그인: 네이티브 Sign In with Apple
- 전화번호 인증: `verifyPhoneNumber` 사용
- 자동 SMS 코드 감지 지원 (Android: SafetyNet, iOS: Silent notifications)

## 🚀 사용 예시

```dart
// 이메일 로그인
final user = await authManager.signInWithEmail(
  context, 
  'user@example.com', 
  'password123'
);

// Google 로그인
final user = await authManager.signInWithGoogle(context);

// 현재 사용자 정보 접근
print('Current user: $currentUserDisplayName');
print('User email: $currentUserEmail');

// 로그아웃
await authManager.signOut();

// 인증 상태 감지 위젯
AuthUserStreamWidget(
  builder: (context) => Text('Logged in: ${loggedIn}'),
)
```

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정 및 camelCase 네이밍 확인
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 초기: FlutterFlow 자동 생성 코드

## 🔗 관련 문서
- [상위 Auth 모듈](../README.md)
- [BaseAuthUserProvider](../base_auth_user_provider.dart)
- [AuthManager](../auth_manager.dart)
- [프로젝트 네이밍 컨벤션](../../../NAMING_CONVENTION.md)