# 📧 Create Account - 이메일 계정 생성 페이지

> Firebase Authentication을 사용한 이메일/비밀번호 계정 생성 화면

## 📋 개요

`create_account` 디렉토리는 Versus Space 앱의 이메일 기반 계정 생성 화면을 구현합니다. 사용자가 이메일과 비밀번호를 입력하여 새 계정을 생성하고, 이메일 인증을 거쳐 회원가입을 완료할 수 있는 핵심 온보딩 화면입니다.

### 주요 기능
- 이메일/비밀번호 입력 및 유효성 검사
- 비밀번호 확인 필드
- 이메일 인증 프로세스
- 전화번호 계정 생성으로 전환
- 로그인 화면으로 이동

## 🎯 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `create_account_widget.dart`, `create_account_model.dart`
- ✅ **위젯/모델 접미사**: 역할을 명확히 구분

### 클래스명
- ✅ **PascalCase 사용**: `CreateAccountWidget`, `CreateAccountModel`
- ✅ **Widget/Model 접미사**: 컴포넌트 타입 명시

### 필드 및 메서드
- ✅ **camelCase 사용**: `emailAddressTextController`, `passwordVisibility`
- ✅ **private 필드**: `_emailAddressTextControllerValidator`
- ✅ **boolean 접두사**: `passwordVisibility`, `validateResult`

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. CreateAccountWidget (945줄)

**역할**: 계정 생성 UI 및 사용자 인터랙션 처리

**라우팅 정보**:
```dart
static String routeName = 'Create_Account';
static String routePath = '/createAccount';
```

**UI 구조**:
- **메인 컨테이너**: Row 레이아웃 (모바일/데스크탑 반응형)
- **좌측 영역 (flex: 8)**: 계정 생성 폼
  - 환영 헤더 (로고 + 텍스트)
  - 이메일 입력 필드
  - 비밀번호 입력 필드
  - 비밀번호 확인 필드
  - 계정 생성 버튼 (이메일)
  - 전화번호 계정 생성 버튼
  - 약관 동의 텍스트
  - 로그인 링크
- **우측 영역 (flex: 6)**: 데스크탑 전용 이미지 배경

**주요 위젯**:
```dart
Form(
  key: _model.formKey,
  autovalidateMode: AutovalidateMode.always,
  child: Container(
    // 폼 필드들
  )
)
```

### 2. CreateAccountModel (94줄)

**역할**: 상태 관리 및 비즈니스 로직

**상태 필드**:
```dart
// 폼 관리
final formKey = GlobalKey<FormState>();

// 이메일 필드
FocusNode? emailAddressFocusNode;
TextEditingController? emailAddressTextController;

// 비밀번호 필드
FocusNode? passwordFocusNode;
TextEditingController? passwordTextController;
late bool passwordVisibility;

// 비밀번호 확인 필드
FocusNode? passwordConfirmFocusNode;
TextEditingController? passwordConfirmTextController;
late bool passwordConfirmVisibility;

// 유효성 검사 결과
bool? validateResult;
```

**유효성 검사 규칙**:

1. **이메일 검증**:
   - 필수 입력
   - 정규식 패턴: `kTextValidatorEmailRegex`
   - 유효한 이메일 형식 확인

2. **비밀번호 검증**:
   - 필수 입력
   - 최소 8자, 최대 15자
   - 영문자 포함 필수
   - 숫자 포함 필수
   - 특수문자 포함 필수 (@$!%*#?&)
   - 정규식: `^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@\$!%*#?&])[A-Za-z\\d@\$!%*#?&]{8,15}\$`

3. **비밀번호 확인 검증**:
   - 필수 입력
   - 비밀번호와 일치 여부 확인 (Widget에서 처리)

## 🔄 계정 생성 프로세스

### 1. 입력 단계
```dart
// 이메일 입력
TextFormField(
  controller: _model.emailAddressTextController,
  autofillHints: [AutofillHints.email],
  validator: _model.emailAddressTextControllerValidator.asValidator(context),
)
```

### 2. 유효성 검사
```dart
if (_model.formKey.currentState == null || 
    !_model.formKey.currentState!.validate()) {
  setState(() => _model.validateResult = false);
  return;
}
```

### 3. 비밀번호 일치 확인
```dart
if (_model.passwordTextController.text != 
    _model.passwordConfirmTextController.text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Passwords don\'t match!'))
  );
  return;
}
```

### 4. Firebase 계정 생성
```dart
final user = await authManager.createAccountWithEmail(
  context,
  _model.emailAddressTextController.text,
  _model.passwordTextController.text,
);
```

### 5. 이메일 인증 발송
```dart
await authManager.sendEmailVerification();
```

### 6. 타이머 팝업 표시
```dart
await showDialog(
  barrierDismissible: false,
  context: context,
  builder: (dialogContext) {
    return Dialog(
      child: WebViewAware(child: PopupTimerEmailWidget()),
    );
  },
);
```

### 7. 사용자 정보 입력 화면으로 이동
```dart
context.pushNamedAuth(
  UserInfoInputWidget.routeName,
  context.mounted
);
```

## 🎨 UI/UX 특징

### 테마 적용
- **색상 스킴**: 
  - 배경: `Color(0xFFECECEC)` (밝은 회색)
  - 입력 필드: 흰색 배경
  - 버튼: 검은색 배경, 흰색 텍스트
  - 에러: `AppTheme.of(context).error`

### 입력 필드 스타일
```dart
InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppTheme.of(context).primary, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
  ),
  filled: true,
  fillColor: Colors.white,
)
```

### 반응형 디자인
- **모바일/태블릿**: 전체 화면 폼
- **데스크탑**: 좌측 폼 (flex: 8) + 우측 이미지 (flex: 6)

## 🌍 국제화 (i18n)

### 지원 언어
- 영어 (기본)
- 독일어 (번역 키 준비)

### 주요 번역 키
```dart
'hkdfn0nl' - "Welcome to Versus Space"
'r6bw196y' - "Create an account"
'vyjbjx7u' - "Let's get started by filling out the form below."
'b4wuzum8' - "Email"
'h5546n6k' - "Password"
'dpnl6798' - "Confirm Password"
'ifzwhrve' - "Create Account"
'kfty848b' - "Create Account With Phone"
'z9kzw84y' - "By signing up, you agree to Versus Space's Terms of Service..."
'0ksnf2xz' - "Already have an account?"
'do58zhdd' - "Log In here"
```

### 에러 메시지
```dart
'sfx28arj' - "Email is required"
'fg4iipv6' - "Please enter a valid email address"
'c10h5qqp' - "Password is required"
'nlyzshnr' - "Please enter at least 8 characters..."
'dv9ttawj' - "Confirm Password is required"
```

## 🔗 네비게이션 연결

### 진입 경로
- `/` (StartPage) → "Get Started" 버튼
- `/login` (LoginPage) → "Create Account" 링크

### 전환 가능 경로
```dart
// 전화번호 계정 생성으로 전환
context.pushNamed(
  PhoneCreatAccountWidget.routeName,
  queryParameters: {'phoneNumberParam': ''},
  extra: TransitionInfo(duration: Duration(milliseconds: 500))
);

// 로그인 페이지로 이동
context.pushNamed(LoginPageWidget.routeName);

// 성공 시 사용자 정보 입력으로 이동
context.pushNamedAuth(UserInfoInputWidget.routeName, context.mounted);
```

## 📱 위젯 트리 구조

```
Scaffold
├── Row (mainAxisSize: max)
│   ├── Expanded (flex: 8) - 폼 영역
│   │   └── Container
│   │       └── SingleChildScrollView
│   │           └── Column
│   │               ├── Container - 헤더
│   │               │   └── Row
│   │               │       ├── Image - 로고
│   │               │       └── Text - 환영 메시지
│   │               └── Form
│   │                   └── Container
│   │                       └── Column
│   │                           ├── Text - 제목
│   │                           ├── Text - 부제목
│   │                           ├── TextFormField - 이메일
│   │                           ├── TextFormField - 비밀번호
│   │                           ├── TextFormField - 비밀번호 확인
│   │                           ├── AppButtonWidget - 이메일 계정 생성
│   │                           ├── AppButtonWidget - 전화번호 계정 생성
│   │                           ├── Text - 약관 동의
│   │                           └── RichText - 로그인 링크
│   └── Expanded (flex: 6) - 이미지 영역 (데스크탑 전용)
│       └── Container
│           └── DecorationImage
```

## 🔒 보안 고려사항

1. **비밀번호 보안**:
   - 강력한 비밀번호 정책 적용
   - 비밀번호 필드 마스킹 (obscureText)
   - 비밀번호 가시성 토글 제공

2. **이메일 검증**:
   - Firebase Authentication 이메일 인증 필수
   - 인증 완료 전 계정 활성화 방지

3. **입력 검증**:
   - 클라이언트 측 실시간 유효성 검사
   - 서버 측 추가 검증 (Firebase)

4. **자동 완성 보안**:
   - AutofillHints 적절히 설정
   - 민감한 정보 노출 방지

## 🐛 알려진 이슈

1. **비밀번호 불일치 메시지**: 영어로만 표시됨 (i18n 필요)
2. **이메일 인증 타이머**: PopupTimerEmailWidget과의 연동 확인 필요
3. **에러 처리**: Firebase 에러 메시지 사용자 친화적 변환 필요

## 📈 개선 제안

1. **소셜 로그인 추가**: Google, Apple, GitHub 로그인 버튼 추가
2. **비밀번호 강도 표시기**: 실시간 비밀번호 강도 피드백
3. **이메일 자동 완성**: 도메인 제안 기능
4. **접근성 개선**: 스크린 리더 지원 강화
5. **로딩 상태 표시**: 계정 생성 중 로딩 인디케이터

## 📝 변경 이력

- **2025-08-23**: README 전면 재작성 (코드 분석 기반)
- **2025-08-22**: 초기 생성
- **2025-07-03**: FlutterFlow에서 Native Flutter로 마이그레이션

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-23  
**작성**: AI Assistant