# Login System

Versus Space 앱의 로그인 및 인증 화면들을 관리하는 디렉토리입니다.

## 📋 디렉토리 구조

```
login/
├── start_page/               # 시작 화면 (로그인/회원가입 선택)
│   ├── start_page_model.dart
│   └── start_page_widget.dart
├── login_page/               # 로그인 화면
│   ├── login_page_model.dart
│   └── login_page_widget.dart
└── forgot_password/          # 비밀번호 찾기
    ├── forgot_password_model.dart
    └── forgot_password_widget.dart
```

## 주요 화면

### 1. 시작 화면 (StartPage)

앱 실행 시 처음 보이는 화면으로, 로그인과 회원가입을 선택할 수 있습니다.

```dart
StartPage
├── 로고 및 브랜딩
├── "로그인" 버튼 → LoginPage
├── "회원가입" 버튼 → CreateAccountPage
├── 소셜 로그인 옵션들
│   ├── Google 로그인
│   ├── Apple 로그인 (iOS/macOS)
│   └── GitHub 로그인
└── 플랫폼 테스트 버튼 (개발 모드)
```

**주요 기능:**
- **자동 로그인 체크**: 이전 로그인 정보가 있으면 자동으로 홈으로 이동
- **소셜 로그인**: 원클릭 소셜 로그인
- **언어 선택**: 독일어/영어 선택 가능
- **테스트 모드**: 개발 환경에서 플랫폼별 테스트 계정 제공

### 2. 로그인 화면 (LoginPage)

이메일/비밀번호 또는 전화번호로 로그인하는 화면입니다.

```dart
LoginPage
├── AppBar (뒤로가기)
├── 로그인 방식 탭
│   ├── 이메일 로그인
│   └── 전화번호 로그인
├── 입력 필드
│   ├── 이메일/전화번호
│   └── 비밀번호/인증코드
├── "로그인" 버튼
├── "비밀번호를 잊으셨나요?" 링크
└── 소셜 로그인 옵션
```

**이메일 로그인:**
```dart
// 유효성 검사
if (!isValidEmail(emailController.text)) {
  showSnackbar(context, '올바른 이메일을 입력해주세요');
  return;
}

// 로그인 시도
try {
  await authManager.signInWithEmail(
    context,
    emailAddress: emailController.text,
    password: passwordController.text,
  );
  
  // 성공 시 홈으로 이동
  context.goNamed('HomePage');
} catch (e) {
  showSnackbar(context, '로그인에 실패했습니다');
}
```

**전화번호 로그인:**
```dart
// SMS 전송
await authManager.beginPhoneAuth(
  context: context,
  phoneNumber: '+82${phoneController.text}',
  onCodeSent: () {
    setState(() {
      isCodeSent = true;
    });
  },
);

// 인증 코드 확인
final user = await authManager.verifySmsCode(
  context: context,
  smsCode: smsCodeController.text,
);
```

### 3. 비밀번호 찾기 (ForgotPasswordPage)

비밀번호를 잊어버린 사용자를 위한 재설정 화면입니다.

```dart
ForgotPasswordPage
├── AppBar (뒤로가기)
├── 안내 텍스트
├── 이메일 입력 필드
├── "재설정 링크 전송" 버튼
└── 성공/실패 메시지
```

**비밀번호 재설정 플로우:**
```dart
// 이메일 유효성 검사
if (!isValidEmail(emailController.text)) {
  showSnackbar(context, '올바른 이메일을 입력해주세요');
  return;
}

// 재설정 이메일 전송
try {
  await authManager.sendPasswordResetEmail(
    email: emailController.text,
  );
  
  showSnackbar(
    context, 
    '비밀번호 재설정 링크가 이메일로 전송되었습니다'
  );
  
  // 로그인 페이지로 돌아가기
  context.pop();
} catch (e) {
  showSnackbar(context, '이메일 전송에 실패했습니다');
}
```

## 인증 플로우

### 1. 첫 실행 플로우
```
앱 시작 → StartPage → 로그인/회원가입 선택
                ↓
         LoginPage or CreateAccountPage
                ↓
         인증 성공 → HomePage
```

### 2. 자동 로그인 플로우
```
앱 시작 → 저장된 인증 정보 확인 → 있음 → HomePage
                              ↓
                              없음 → StartPage
```

### 3. 소셜 로그인 플로우
```
소셜 로그인 버튼 클릭 → OAuth 화면 → 권한 승인
                                ↓
                          계정 연결/생성
                                ↓
                    신규 사용자? → 프로필 설정
                              ↓
                         HomePage
```

## UI/UX 가이드라인

### 1. 디자인 원칙
- **일관성**: 모든 인증 화면에서 동일한 스타일 사용
- **명확성**: 명확한 레이블과 에러 메시지
- **접근성**: 큰 터치 영역, 명확한 대비

### 2. 색상 사용
```dart
// 주요 색상
primary: Color(0xFFFDCB00)    // 노란색 (주요 버튼)
secondary: Color(0xFF000000)   // 검은색 (텍스트)
error: Color(0xFFFF0040)       // 빨간색 (에러)
background: Color(0xFFF1F4F8)  // 밝은 회색 (배경)
```

### 3. 입력 필드 스타일
```dart
TextFormField(
  controller: controller,
  decoration: InputDecoration(
    labelText: '이메일',
    hintText: 'example@email.com',
    prefixIcon: Icon(Icons.email),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    errorText: errorText,
  ),
  validator: (value) => isValidEmail(value) ? null : '올바른 이메일을 입력하세요',
)
```

## 에러 처리

### 일반적인 에러
```dart
// 에러 코드별 메시지
switch (e.code) {
  case 'user-not-found':
    return '존재하지 않는 계정입니다';
  case 'wrong-password':
    return '잘못된 비밀번호입니다';
  case 'too-many-requests':
    return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요';
  case 'network-request-failed':
    return '네트워크 연결을 확인해주세요';
  default:
    return '로그인 중 오류가 발생했습니다';
}
```

### 입력 유효성 검사
```dart
// 이메일 검증
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

// 전화번호 검증
bool isValidPhoneNumber(String phone) {
  // 한국 전화번호 형식
  return RegExp(r'^01[0-9]{8,9}$').hasMatch(phone);
}

// 비밀번호 강도 검증
bool isStrongPassword(String password) {
  return password.length >= 8 &&
         RegExp(r'[A-Z]').hasMatch(password) &&
         RegExp(r'[a-z]').hasMatch(password) &&
         RegExp(r'[0-9]').hasMatch(password);
}
```

## 보안 고려사항

### 1. 비밀번호 보안
- 최소 8자 이상 요구
- 입력 시 마스킹 처리
- 보기/숨기기 토글 제공

### 2. 로그인 시도 제한
- 5회 실패 시 일시적 차단
- SMS 인증은 3회로 제한
- IP 기반 제한 (Firebase 자동)

### 3. 세션 관리
- 30일 후 자동 로그아웃
- 비정상 활동 감지
- 다중 기기 로그인 관리

## 테스트

### 테스트 계정
```dart
// 개발 환경에서만 사용 가능
const testAccounts = {
  'ios': 'tester-ios@versus.test',
  'android': 'tester-android@versus.test',
  'web': 'tester-web@versus.test',
  'macos': 'tester-macos@versus.test',
};
```

### 단위 테스트
```dart
test('이메일 유효성 검사', () {
  expect(isValidEmail('test@example.com'), true);
  expect(isValidEmail('invalid.email'), false);
  expect(isValidEmail(''), false);
});

test('비밀번호 강도 검사', () {
  expect(isStrongPassword('Test1234'), true);
  expect(isStrongPassword('weak'), false);
  expect(isStrongPassword('12345678'), false);
});
```

## 접근성

### 1. 스크린 리더 지원
```dart
Semantics(
  label: '이메일 입력 필드',
  child: TextFormField(...),
)
```

### 2. 키보드 네비게이션
- Tab 키로 필드 간 이동
- Enter 키로 폼 제출
- Escape 키로 취소

### 3. 시각적 피드백
- 포커스 상태 명확히 표시
- 에러 상태 색상 구분
- 로딩 상태 표시

## 향후 개선 사항

1. **생체 인증 추가**
   - Face ID / Touch ID
   - 지문 인증

2. **2단계 인증**
   - TOTP 지원
   - 백업 코드

3. **추가 소셜 로그인**
   - 카카오
   - 네이버
   - 페이스북

4. **보안 강화**
   - 캡차 추가
   - 디바이스 신뢰도 관리