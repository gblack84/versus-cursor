# Create Account System

Versus Space 앱의 회원가입 및 계정 생성 프로세스를 관리하는 디렉토리입니다.

## 📋 디렉토리 구조

```
createaccount/
├── create_account/              # 이메일 회원가입
│   ├── create_account_model.dart
│   └── create_account_widget.dart
├── phoneauth/                   # 전화번호 인증
│   ├── phone_creat_account/     # 전화번호 회원가입
│   │   ├── phone_creat_account_model.dart
│   │   └── phone_creat_account_widget.dart
│   └── phonelogeinpincode/      # SMS 인증 코드 입력
│       ├── phonelogeinpincode_model.dart
│       └── phonelogeinpincode_widget.dart
├── phonemaximum/                # SMS 발송 한도 초과
│   ├── phonemaximum_model.dart
│   └── phonemaximum_widget.dart
└── popup_timer_email/           # 이메일 인증 타이머
    ├── popup_timer_email_model.dart
    └── popup_timer_email_widget.dart
```

## 회원가입 플로우

### 1. 전체 플로우 다이어그램
```
StartPage → 회원가입 선택
    ↓
이메일/전화번호 선택
    ↓
CreateAccount or PhoneCreatAccount
    ↓
인증 (이메일 확인 or SMS)
    ↓
프로필 설정 (UserInfoInputPage)
    ↓
관심사 선택 (JopSelectPages)
    ↓
가입 완료 → HomePage
```

## 주요 화면

### 1. 이메일 회원가입 (CreateAccountPage)

이메일과 비밀번호로 계정을 생성하는 화면입니다.

```dart
CreateAccountPage
├── AppBar (뒤로가기)
├── 이메일 입력 필드
├── 비밀번호 입력 필드
├── 비밀번호 확인 필드
├── 이용약관 동의 체크박스
├── "계정 만들기" 버튼
└── 소셜 회원가입 옵션
```

**주요 기능:**
```dart
// 입력 유효성 검사
bool validateInputs() {
  // 이메일 형식 검사
  if (!isValidEmail(emailController.text)) {
    showError('올바른 이메일 주소를 입력하세요');
    return false;
  }
  
  // 비밀번호 강도 검사
  if (passwordController.text.length < 8) {
    showError('비밀번호는 8자 이상이어야 합니다');
    return false;
  }
  
  // 비밀번호 일치 검사
  if (passwordController.text != confirmPasswordController.text) {
    showError('비밀번호가 일치하지 않습니다');
    return false;
  }
  
  // 이용약관 동의 검사
  if (!agreeToTerms) {
    showError('이용약관에 동의해주세요');
    return false;
  }
  
  return true;
}

// 계정 생성
Future<void> createAccount() async {
  if (!validateInputs()) return;
  
  setState(() => isLoading = true);
  
  try {
    // Firebase Auth 계정 생성
    final user = await authManager.createAccountWithEmail(
      context,
      emailAddress: emailController.text,
      password: passwordController.text,
    );
    
    // Firestore 사용자 문서 생성
    await UsersModel.createDocument(
      user!.uid,
      createUsersModelData(
        email: emailController.text,
        createdTime: DateTime.now(),
        role: 'user',
      ),
    );
    
    // 이메일 인증 전송
    await user.sendEmailVerification();
    
    // 이메일 인증 팝업 표시
    await showDialog(
      context: context,
      builder: (_) => PopupTimerEmailWidget(
        email: emailController.text,
      ),
    );
    
    // 프로필 설정으로 이동
    context.goNamed('UserInfoInput');
    
  } catch (e) {
    handleAuthError(e);
  } finally {
    setState(() => isLoading = false);
  }
}
```

### 2. 전화번호 회원가입 (PhoneCreatAccountPage)

전화번호와 SMS 인증으로 계정을 생성하는 화면입니다.

```dart
PhoneCreatAccountPage
├── AppBar (뒤로가기)
├── 전화번호 입력 필드
├── 국가 코드 선택 (+82)
├── "인증번호 전송" 버튼
├── 발송 횟수 표시 (최대 3회)
└── 이용약관 동의
```

**SMS 발송 로직:**
```dart
// SMS 발송 제한 관리
class SmsLimitManager {
  static const int maxAttempts = 3;
  static const Duration resetDuration = Duration(hours: 24);
  
  Future<bool> canSendSms(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'sms_attempts_$phoneNumber';
    final lastResetKey = 'sms_reset_$phoneNumber';
    
    final lastReset = prefs.getInt(lastResetKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 24시간 경과 시 리셋
    if (now - lastReset > resetDuration.inMilliseconds) {
      await prefs.setInt(key, 0);
      await prefs.setInt(lastResetKey, now);
    }
    
    final attempts = prefs.getInt(key) ?? 0;
    return attempts < maxAttempts;
  }
  
  Future<void> incrementAttempts(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'sms_attempts_$phoneNumber';
    final attempts = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, attempts + 1);
  }
}

// SMS 전송
Future<void> sendSmsCode() async {
  final phoneNumber = '+82${phoneController.text}';
  
  // 발송 제한 확인
  if (!await SmsLimitManager.canSendSms(phoneNumber)) {
    // 제한 초과 페이지로 이동
    context.pushNamed('PhoneMaximum');
    return;
  }
  
  try {
    await authManager.beginPhoneAuth(
      context: context,
      phoneNumber: phoneNumber,
      onCodeSent: () async {
        // 발송 횟수 증가
        await SmsLimitManager.incrementAttempts(phoneNumber);
        
        // 인증 코드 입력 페이지로 이동
        context.pushNamed(
          'PhoneLoginPincode',
          queryParams: {'phoneNumber': phoneNumber},
        );
      },
    );
  } catch (e) {
    showError('SMS 전송에 실패했습니다');
  }
}
```

### 3. SMS 인증 코드 입력 (PhoneLoginPincodePage)

SMS로 받은 6자리 인증 코드를 입력하는 화면입니다.

```dart
PhoneLoginPincodePage
├── AppBar (뒤로가기)
├── 설명 텍스트 (전화번호 표시)
├── 6자리 PIN 입력 필드
├── 남은 시간 타이머 (10분)
├── "확인" 버튼
└── "재전송" 버튼
```

**PIN 코드 검증:**
```dart
// 10분 타이머
class SmsCodeTimer {
  static const Duration timeout = Duration(minutes: 10);
  Timer? _timer;
  DateTime? _sentTime;
  
  void startTimer(VoidCallback onTimeout) {
    _sentTime = DateTime.now();
    _timer?.cancel();
    
    _timer = Timer(timeout, () {
      onTimeout();
    });
  }
  
  Duration get remainingTime {
    if (_sentTime == null) return Duration.zero;
    
    final elapsed = DateTime.now().difference(_sentTime!);
    final remaining = timeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

// 인증 코드 확인
Future<void> verifySmsCode() async {
  if (pinController.text.length != 6) {
    showError('6자리 인증 코드를 입력하세요');
    return;
  }
  
  // 타임아웃 확인
  if (timer.remainingTime == Duration.zero) {
    showError('인증 시간이 만료되었습니다. 다시 요청하세요.');
    return;
  }
  
  try {
    final credential = await authManager.verifySmsCode(
      context: context,
      smsCode: pinController.text,
    );
    
    if (credential != null) {
      // 신규 사용자인 경우
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        // 사용자 문서 생성
        await createUserDocument(credential.user!);
        
        // 프로필 설정으로 이동
        context.goNamed('UserInfoInput');
      } else {
        // 기존 사용자는 홈으로
        context.goNamed('HomePage');
      }
    }
  } catch (e) {
    showError('잘못된 인증 코드입니다');
  }
}
```

### 4. SMS 발송 한도 초과 (PhoneMaximumPage)

SMS 발송 한도를 초과했을 때 표시되는 안내 화면입니다.

```dart
PhoneMaximumPage
├── 경고 아이콘
├── 안내 메시지
├── 남은 대기 시간 표시
├── "다른 방법으로 가입" 버튼
└── "홈으로" 버튼
```

### 5. 이메일 인증 타이머 (PopupTimerEmailPage)

이메일 인증 링크 전송 후 표시되는 팝업입니다.

```dart
PopupTimerEmailWidget
├── 이메일 아이콘
├── 전송 완료 메시지
├── 이메일 주소 표시
├── 재전송 타이머 (60초)
├── "재전송" 버튼
└── "확인" 버튼
```

**재전송 로직:**
```dart
// 재전송 제한
class EmailResendManager {
  static const Duration cooldown = Duration(seconds: 60);
  DateTime? _lastSent;
  
  bool canResend() {
    if (_lastSent == null) return true;
    return DateTime.now().difference(_lastSent!) > cooldown;
  }
  
  Future<void> resendEmail() async {
    if (!canResend()) {
      final remaining = cooldown - DateTime.now().difference(_lastSent!);
      showError('${remaining.inSeconds}초 후에 다시 시도하세요');
      return;
    }
    
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      _lastSent = DateTime.now();
      showSuccess('인증 이메일을 재전송했습니다');
    } catch (e) {
      showError('이메일 전송에 실패했습니다');
    }
  }
}
```

## 유효성 검사

### 1. 이메일 검증
```dart
// 이메일 형식 검증
bool isValidEmail(String email) {
  return RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  ).hasMatch(email);
}

// 중복 이메일 확인
Future<bool> isEmailAvailable(String email) async {
  try {
    final methods = await FirebaseAuth.instance
      .fetchSignInMethodsForEmail(email);
    return methods.isEmpty;
  } catch (e) {
    return false;
  }
}
```

### 2. 전화번호 검증
```dart
// 한국 전화번호 형식
bool isValidKoreanPhone(String phone) {
  // 010, 011, 016, 017, 018, 019로 시작
  return RegExp(r'^01[0-9]{8,9}$').hasMatch(phone);
}

// 국제 전화번호 형식
bool isValidInternationalPhone(String phone) {
  // + 로 시작하고 숫자만 포함
  return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone);
}
```

### 3. 비밀번호 검증
```dart
// 비밀번호 강도 확인
enum PasswordStrength { weak, medium, strong }

PasswordStrength checkPasswordStrength(String password) {
  if (password.length < 8) return PasswordStrength.weak;
  
  int strength = 0;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
  if (RegExp(r'[a-z]').hasMatch(password)) strength++;
  if (RegExp(r'[0-9]').hasMatch(password)) strength++;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
  
  if (strength >= 3) return PasswordStrength.strong;
  if (strength >= 2) return PasswordStrength.medium;
  return PasswordStrength.weak;
}
```

## 에러 처리

### Firebase Auth 에러
```dart
void handleAuthError(dynamic error) {
  String message = '회원가입 중 오류가 발생했습니다';
  
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        message = '이미 사용 중인 이메일입니다';
        break;
      case 'invalid-email':
        message = '유효하지 않은 이메일 형식입니다';
        break;
      case 'weak-password':
        message = '비밀번호가 너무 약합니다';
        break;
      case 'invalid-phone-number':
        message = '유효하지 않은 전화번호입니다';
        break;
      case 'too-many-requests':
        message = '너무 많은 요청이 있었습니다. 잠시 후 다시 시도하세요';
        break;
    }
  }
  
  showSnackbar(context, message);
}
```

## 보안 고려사항

1. **비밀번호 정책**
   - 최소 8자 이상
   - 대소문자, 숫자 포함 권장
   - 특수문자 포함 시 보안 강도 증가

2. **SMS 발송 제한**
   - 전화번호당 24시간 내 3회로 제한
   - 남용 방지를 위한 쿨다운 시간

3. **이메일 인증**
   - 가입 후 이메일 인증 필수
   - 인증 전까지 일부 기능 제한

4. **데이터 보호**
   - 비밀번호는 Firebase Auth에서 암호화
   - 전화번호는 해시 처리 후 저장

## 향후 개선 사항

1. **가입 프로세스 간소화**
   - 단계 축소
   - 선택 항목 최소화

2. **추가 인증 방법**
   - 생체 인증 연동
   - OAuth 제공자 추가

3. **사용자 경험 개선**
   - 실시간 유효성 검사
   - 자동 완성 기능
   - 진행 상태 표시

4. **보안 강화**
   - reCAPTCHA 추가
   - 이상 패턴 감지