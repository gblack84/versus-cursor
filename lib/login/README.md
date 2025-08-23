# 🔐 Login System - 인증 시스템

> Versus Space 앱의 완전한 인증 및 로그인 시스템을 제공하는 통합 모듈

## 📋 개요

이 디렉토리는 Versus Space 앱의 전체 인증 시스템을 담당합니다. 시작 화면부터 로그인, 비밀번호 재설정까지 사용자 인증과 관련된 모든 기능을 포함합니다. Firebase Authentication과 완벽하게 통합되어 이메일/비밀번호, 전화번호, 소셜 로그인(Apple, Google, Facebook, Instagram) 등 다양한 인증 방식을 지원합니다.

### 🎯 주요 목적
- **완전한 인증 플로우**: 시작→로그인/가입→인증→홈 이동
- **다양한 인증 방식**: 이메일, 전화번호, 소셜 로그인 지원
- **보안 강화**: Firebase Auth 통합 및 유효성 검증
- **사용자 경험 최적화**: 직관적이고 일관된 UI/UX

## 🏗️ 디렉토리 구조

```
/lib/login/
├── README.md                     # 현재 통합 문서
├── start_page/                   # 🎬 시작 화면 (첫 진입점)
│   ├── README.md                 # 498줄 상세 문서
│   ├── start_page_widget.dart    # 603줄 UI 구현
│   └── start_page_model.dart     # 23줄 상태 관리
├── login_page/                   # 🔑 로그인 화면
│   ├── README.md                 # 617줄 상세 문서
│   ├── login_page_widget.dart    # 1,175줄 UI 구현
│   └── login_page_model.dart     # 63줄 상태 관리
└── forgot_password/              # 🔑 비밀번호 재설정
    ├── README.md                 # 372줄 상세 문서
    ├── forgot_password_widget.dart # 393줄 UI 구현
    └── forgot_password_model.dart  # 23줄 상태 관리
```

### 📊 코드 통계
- **총 코드 라인**: 2,257줄
- **총 문서 라인**: 1,487줄
- **문서화 비율**: 65.9%
- **검증 등급**: ⭐⭐⭐⭐ (모든 하위 디렉토리)

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `start_page_widget.dart`, `login_page_model.dart`

### 클래스명
- **패턴**: PascalCase
- **예시**: `StartPageWidget`, `LoginPageModel`, `ForgotPasswordWidget`

### 필드명
- **패턴**: camelCase
- **예시**: `emailAddressLoginTextController`, `passwordLoginVisibility`

### 라우트 설정
| 화면 | routeName | routePath |
|------|-----------|-----------|
| StartPage | `'startPage'` | `'/startPage'` |
| LoginPage | `'Login_page'` | `'/loginPage'` |
| ForgotPassword | `'Forgot_Password'` | `'/forgotPassword'` |

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소 (Core Components)

### 1. Start Page - 시작 화면 🎬

**앱의 첫 진입점**으로 브랜드 메시지와 인증 옵션을 제공합니다.

#### 주요 특징
- **철학적 메시지**: "Life is a 'c' between 'b' and 'd'" (66px SourGummy 폰트)
- **VS 마크**: Versus Space 브랜드 로고 표시
- **인증 옵션**: 6가지 버튼 (Create Account, Sign In, 소셜 로그인 4종)
- **애니메이션**: Fade + Move + Tilt 복합 효과 (200ms 지연, 400ms 지속)

#### 소셜 로그인 지원
```dart
// 지원되는 소셜 로그인
- Apple (iOS 전용 - isAndroid ? Container() : ...)
- Google
- Facebook (현재 Google 로그인으로 구현)
- Instagram (현재 Google 로그인으로 구현)
```

#### 플로우
```
StartPageWidget
    ├─ Create Account → CreateAccountWidget
    ├─ Sign In → LoginPageWidget
    └─ Social Login → Firebase Auth → TestpageSelectWidget
```

### 2. Login Page - 로그인 화면 🔑

**메인 로그인 화면**으로 다양한 인증 방식과 테스트 계정을 제공합니다.

#### 주요 특징
- **듀얼 인증**: 이메일/비밀번호 & 전화번호 로그인
- **테스트 계정**: 5개 플랫폼별 테스트 계정 (Debug 모드)
- **자동 초기화 대기**: currentUserReference 최대 10초 대기
- **유효성 검증**: 이메일 형식, 비밀번호 최소 6자

#### 테스트 계정 시스템
```dart
// kReleaseMode가 false일 때만 표시
const testAccounts = {
  'ios': 'test_ios@versus.com',
  'android': 'test_android@versus.com',
  'web': 'test_web@versus.com',
  'macos': 'test_macos@versus.com',
  'windows': 'test_windows@versus.com'
};
// 모든 테스트 계정 비밀번호: 'password'
```

#### 전화번호 로그인 플로우
```dart
1. 전화번호 입력 (한국 번호만 지원)
2. SMS 코드 전송
3. 6자리 코드 입력
4. Firebase Auth 인증
5. 성공 시 TestpageSelectWidget으로 이동
```

### 3. Forgot Password - 비밀번호 재설정 🔑

**비밀번호 재설정 화면**으로 이메일을 통한 재설정 링크를 제공합니다.

#### 주요 특징
- **간단한 플로우**: 이메일 입력 → 링크 전송 → 이메일 확인
- **Firebase 통합**: authManager.resetPassword() 활용
- **에러 처리**: 빈 이메일 체크, 스낵바 피드백

#### 재설정 플로우
```
ForgotPasswordWidget
    ↓
이메일 입력 & 유효성 검증
    ↓
Firebase Auth resetPassword()
    ↓
이메일로 재설정 링크 발송
    ↓
사용자가 이메일에서 링크 클릭
    ↓
Firebase 호스팅 페이지에서 새 비밀번호 설정
```

## 🔄 인증 플로우 다이어그램

### 전체 인증 시스템 플로우
```
앱 시작
    ↓
StartPageWidget (시작 화면)
    ├─ "Go To Create Account" → CreateAccountWidget
    │       ↓
    │   계정 생성 플로우
    │       ↓
    │   TestpageSelectWidget
    │
    ├─ "Go To Sign in" → LoginPageWidget
    │       ├─ 이메일/비밀번호 로그인
    │       ├─ 전화번호 로그인
    │       └─ "Forgot Password?" → ForgotPasswordWidget
    │                                      ↓
    │                                  이메일 재설정
    │
    └─ 소셜 로그인 (Apple/Google/Facebook/Instagram)
            ↓
        Firebase Auth
            ↓
        lastActive 업데이트
            ↓
        TestpageSelectWidget → HomePage
```

### currentUserReference 초기화 시퀀스
```dart
// LoginPage에서의 초기화 대기 로직
int attempts = 0;
while (currentUserReference == null && attempts < 10) {
  await Future.delayed(Duration(seconds: 1));
  attempts++;
}
if (currentUserReference != null) {
  // Firestore 업데이트 수행
}
```

## 💡 사용 가이드

### 네비게이션 예시

#### 1. 프로그래매틱 네비게이션
```dart
// 라우트 이름으로 이동
context.pushNamed(LoginPageWidget.routeName);
context.pushNamed(ForgotPasswordWidget.routeName);

// 인증 후 이동
context.goNamedAuth(TestpageSelectWidget.routeName, context.mounted);
```

#### 2. 트랜지션 설정
```dart
context.pushNamed(
  LoginPageWidget.routeName,
  extra: <String, dynamic>{
    kTransitionInfoKey: TransitionInfo(
      hasTransition: true,
      duration: Duration(milliseconds: 500),
    ),
  },
);
```

### Firebase Auth 통합

#### 이메일 로그인
```dart
final user = await authManager.signInWithEmail(
  context,
  emailAddressLoginTextController.text,
  passwordLoginTextController.text,
);
```

#### 소셜 로그인
```dart
// Google
final user = await authManager.signInWithGoogle(context);

// Apple (iOS)
final user = await authManager.signInWithApple(context);

// 성공 후 lastActive 업데이트
if (user != null) {
  await currentUserReference!.update({
    'lastActive': FieldValue.serverTimestamp(),
  });
}
```

## 🎨 UI/UX 특징

### 통일된 디자인 시스템

#### 색상 팔레트
- **배경**: #ECECEC (연한 회색)
- **메인 버튼**: Colors.black (검은색)
- **보조 버튼**: Colors.white (흰색)
- **Facebook**: #005CFF
- **Instagram**: #FF8455
- **테두리**: #E0E3E7

#### 타이포그래피
- **메인 메시지**: SourGummy 66px (Start Page)
- **버튼 텍스트**: Plus Jakarta Sans Bold 14px
- **일반 텍스트**: 시스템 기본 폰트

#### 버튼 스타일
- **크기**: 230x44px (통일)
- **테두리**: 2px solid #E0E3E7
- **모서리**: 12px radius
- **Elevation**: 5-10px

### 애니메이션 시스템
- **페이지 진입**: Fade + Move + Tilt 효과
- **버튼 클릭**: Scale 95% 축소
- **지연 시간**: 200ms
- **지속 시간**: 400ms

## ⚡ 성능 최적화

### 위젯 생명주기 관리
```dart
@override
void initState() {
  super.initState();
  _model = createModel(context, () => PageModel());
  // 컨트롤러 초기화
  _model.emailController ??= TextEditingController();
}

@override
void dispose() {
  _model.dispose();
  // 컨트롤러 정리
  emailController?.dispose();
  passwordController?.dispose();
  super.dispose();
}
```

### 애니메이션 최적화
- TickerProviderStateMixin 사용
- 필요한 애니메이션만 선택적 초기화
- PostFrameCallback으로 초기 렌더링 최적화

## 🔒 보안 고려사항

### 구현된 보안 기능
- **Firebase Auth**: 검증된 인증 시스템 활용
- **비밀번호 마스킹**: passwordVisibility 토글
- **Context 체크**: context.mounted 확인
- **Null Safety**: user == null 체크
- **테스트 계정 격리**: kReleaseMode 체크

### 추가 보안 권장사항
1. **Rate Limiting**: 로그인 시도 횟수 제한
2. **2FA**: 2단계 인증 추가
3. **Session Management**: 자동 로그아웃 타이머
4. **CAPTCHA**: 봇 방지 시스템
5. **Audit Logging**: 로그인 시도 기록

## 🌍 국제화 (i18n)

### 지원 언어
- **English (en)**: 완전 번역
- **German (de)**: 번역 대기 중

### 텍스트 키 예시
```dart
AppLocalizations.of(context).getText(
  'ur72jrvo' /* Life is a 'c' between 'b' and ... */,
  'tkccfqfy' /* Go To Create Account */,
  '3gnrvqoi' /* Continue with Apple */,
  'b71h3bzp' /* Go To Sign in */,
  '7sfxx5v9' /* Back */,
  '4rzuk0hj' /* Send Link */,
)
```

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **소셜 로그인 미완성**: Facebook, Instagram이 Google 로그인 사용
2. **currentUserReference 지연**: 최대 10초 대기 필요
3. **이메일 검증 미구현**: ForgotPassword에서 형식 검증 없음
4. **중복 코드**: 소셜 로그인 버튼 로직 중복

### 개선 제안
1. **실제 소셜 SDK 통합**: Facebook, Instagram SDK 추가
2. **로딩 상태 표시**: 인증 중 스피너 추가
3. **에러 메시지 개선**: 구체적인 에러 피드백
4. **접근성 향상**: Semantics 위젯 추가
5. **생체 인증**: Face ID, Touch ID 지원

## 📊 통계 및 메트릭스

### 코드 복잡도
| 파일 | 라인 수 | 복잡도 | 유지보수성 |
|------|---------|---------|------------|
| start_page_widget.dart | 603 | 중간 | 양호 |
| login_page_widget.dart | 1,175 | 높음 | 리팩토링 필요 |
| forgot_password_widget.dart | 393 | 낮음 | 우수 |

### 테스트 커버리지
- **단위 테스트**: 미구현
- **위젯 테스트**: 미구현
- **통합 테스트**: 미구현
- **권장 커버리지**: 80% 이상

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 2.0.0 | 2025-08-23 | 통합 문서 작성 및 하위 디렉토리 문서 통합 | AI Assistant |
| 1.3.0 | 2025-08-23 | start_page 문서화 완료 | AI Assistant |
| 1.2.0 | 2025-08-23 | login_page 문서화 완료 | AI Assistant |
| 1.1.0 | 2025-08-23 | forgot_password 문서화 완료 | AI Assistant |
| 1.0.0 | 2025-08-22 | 초기 디렉토리 생성 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 인증 시스템 전체를 설명합니다.*
*하위 디렉토리별 상세 문서를 참조하시려면 각 디렉토리의 README.md를 확인하세요.*
*마지막 업데이트: 2025-08-23*