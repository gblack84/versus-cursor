# Authentication System

Versus Space 앱의 인증 시스템을 관리하는 디렉토리입니다.

## 📋 개요

Firebase Authentication을 기반으로 다양한 인증 방법을 지원하며, 사용자 세션 관리와 권한 제어를 담당합니다.

## 디렉토리 구조

```
auth/
├── firebase_auth/          # Firebase Auth 통합
│   └── auth_util.dart     # 인증 유틸리티 함수
└── auth_manager.dart      # 인증 상태 관리
```

## 지원 인증 방법

### 1. 이메일/비밀번호 인증
```dart
// 회원가입
final user = await createAccountWithEmail(
  context,
  emailAddress: email,
  password: password,
);

// 로그인
final user = await signInWithEmail(
  context,
  emailAddress: email,
  password: password,
);
```

### 2. 소셜 로그인

#### Google 로그인
```dart
final user = await authManager.signInWithGoogle(context);
```

#### Apple 로그인 (iOS/macOS)
```dart
final user = await authManager.signInWithApple(context);
```

#### GitHub 로그인
```dart
final user = await signInWithGithub(context);
```

### 3. 전화번호 인증
```dart
// SMS 전송
await authManager.beginPhoneAuth(
  context: context,
  phoneNumber: '+8210XXXXXXXX',
  onCodeSent: () {
    // SMS 전송 완료
  },
);

// 인증 코드 확인
final user = await authManager.verifySmsCode(
  context: context,
  smsCode: '123456',
);
```

### 4. 익명 로그인
```dart
final user = await authManager.signInAnonymously(context);
```

## 인증 유틸리티 (auth_util.dart)

### 현재 사용자 정보
```dart
// 현재 사용자 가져오기
User? currentUser = currentUserReference;

// 사용자 UID
String? uid = currentUserUid;

// 사용자 문서 참조
DocumentReference? userRef = currentUserReference;

// 로그인 상태 확인
bool isLoggedIn = loggedIn;
```

### 사용자 스트림
```dart
// 사용자 문서 스트림
Stream<UsersModel> userStream = currentUserDocument();

// 사용 예제
StreamBuilder<UsersModel>(
  stream: currentUserDocument(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return LoadingWidget();
    }
    final user = snapshot.data!;
    return Text('안녕하세요, ${user.displayName}님!');
  },
)
```

### 로그아웃
```dart
await authManager.signOut();
GoRouter.of(context).go('/login');
```

## 권한 관리

### 사용자 역할
```dart
enum UserRole {
  user,     // 일반 사용자
  tester,   // 테스터
  admin,    // 관리자
}

// 역할 확인
final userDoc = await currentUserDocument().first;
final role = userDoc.role;

if (role == 'admin') {
  // 관리자 기능 표시
}
```

### 접근 제어
```dart
// 로그인 필수 페이지
if (!loggedIn) {
  context.go('/login');
  return;
}

// 특정 역할 필요
if (currentUser?.role != 'admin') {
  showToast('권한이 없습니다');
  return;
}
```

## 인증 플로우

### 1. 회원가입 플로우
```
StartPage → CreateAccountPage → 인증 방법 선택
  ↓
이메일 입력 → 비밀번호 설정 → 이메일 인증
  ↓
프로필 설정 → 관심사 선택 → 완료
```

### 2. 로그인 플로우
```
StartPage → LoginPage → 인증 방법 선택
  ↓
자격증명 입력 → 인증 → HomePage
```

### 3. 전화번호 인증 플로우
```
전화번호 입력 → SMS 전송 → 인증 코드 입력
  ↓
인증 확인 → 계정 생성/로그인
```

## 에러 처리

### 일반적인 에러
```dart
try {
  await signInWithEmail(context, email, password);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      showToast('존재하지 않는 계정입니다');
      break;
    case 'wrong-password':
      showToast('잘못된 비밀번호입니다');
      break;
    case 'invalid-email':
      showToast('유효하지 않은 이메일 형식입니다');
      break;
    default:
      showToast('로그인 중 오류가 발생했습니다');
  }
}
```

### 전화번호 인증 에러
```dart
// SMS 전송 제한
if (smsSentCount >= 3) {
  showToast('SMS 전송 한도를 초과했습니다. 24시간 후 다시 시도해주세요.');
  return;
}

// 인증 코드 만료
if (DateTime.now().difference(codeSentTime) > Duration(minutes: 10)) {
  showToast('인증 코드가 만료되었습니다. 다시 요청해주세요.');
  return;
}
```

## 보안 고려사항

### 1. 비밀번호 정책
- 최소 8자 이상
- 대소문자, 숫자, 특수문자 포함 권장
- 자주 사용되는 비밀번호 차단

### 2. 세션 관리
- 자동 로그아웃 (30일)
- 다중 기기 로그인 지원
- 의심스러운 활동 감지

### 3. 개인정보 보호
- 최소한의 정보만 수집
- 안전한 저장 (Firebase Auth)
- GDPR 준수

## 테스트 계정

### 플랫폼별 테스트 계정
```dart
// iOS 테스터
email: tester-ios@versus.test
password: test1234

// Android 테스터
email: tester-android@versus.test
password: test1234

// Web 테스터
email: tester-web@versus.test
password: test1234
```

### 테스트 모드 활성화
```dart
// 개발 환경에서만
if (kDebugMode) {
  // 플랫폼별 테스트 버튼 표시
  showPlatformTestButton();
}
```

## 성능 최적화

### 1. 인증 상태 캐싱
```dart
// SharedPreferences에 캐싱
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('ff_isLoggedIn', true);
await prefs.setString('ff_uid', user.uid);
```

### 2. 자동 로그인
```dart
// 앱 시작 시
if (await isLoggedIn()) {
  // 자동으로 홈으로 이동
  context.go('/');
} else {
  // 로그인 페이지로
  context.go('/start');
}
```

## 마이그레이션 가이드

### FlutterFlow에서 네이티브로
- `FFAppState` → `AppState`
- `currentUser` → `currentUserReference`
- FlutterFlow 인증 액션 → 직접 Firebase Auth 호출

## 향후 개선 사항

1. **생체 인증**
   - Face ID / Touch ID
   - 지문 인증 (Android)

2. **2단계 인증**
   - SMS OTP
   - 인증 앱 연동

3. **싱글 사인온 (SSO)**
   - 카카오 로그인
   - 네이버 로그인

4. **보안 강화**
   - 로그인 시도 제한
   - IP 기반 차단
   - 디바이스 신뢰도 관리