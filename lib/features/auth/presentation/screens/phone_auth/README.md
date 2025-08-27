# 🔐 Phone Login PIN Code - 전화번호 인증 코드 확인 페이지

> SMS로 받은 6자리 인증 코드를 입력하여 전화번호 인증을 완료하는 화면

## 📋 개요

`phonelogeinpincode` 디렉토리는 Versus Space 앱의 전화번호 인증 프로세스의 두 번째 단계를 구현합니다. 사용자가 SMS로 받은 6자리 인증 코드를 입력하여 전화번호를 검증하고, Firebase Phone Authentication을 완료하는 핵심 인증 화면입니다. 타이머와 재전송 기능을 통해 안정적인 인증 경험을 제공합니다.

### 주요 기능
- 6자리 PIN 코드 입력 UI (PinCodeTextField)
- 2분 카운트다운 타이머
- SMS 재전송 기능 (최대 3회)
- 실시간 인증 상태 표시
- Firebase Phone Auth 검증
- 인증 성공 시 사용자 정보 입력 화면으로 이동

## 🎯 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `phonelogeinpincode_widget.dart`, `phonelogeinpincode_model.dart`
- ✅ **위젯/모델 접미사**: 역할을 명확히 구분

### 클래스명
- ✅ **PascalCase 사용**: `PhonelogeinpincodeWidget`, `PhonelogeinpincodeModel`
- ✅ **Widget/Model 접미사**: 컴포넌트 타입 명시

### 필드 및 메서드
- ✅ **camelCase 사용**: `pinCodeController`, `timerController`, `isVerified`
- ✅ **boolean 접두사**: `isVerified`, `canResendCode`
- ✅ **카운터 변수**: `canResendCount`, `timerMilliseconds`

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. PhonelogeinpincodeWidget (752줄)

**역할**: PIN 코드 입력 UI 및 SMS 인증 검증 처리

**라우팅 정보**:
```dart
static String routeName = 'Phonelogeinpincode';
static String routePath = '/phonelogeinpincode';
```

**Props**:
```dart
final String? phoneNumberParam;  // 전달받은 전화번호
```

**UI 구조**:
- **AppBar**: 뒤로가기 버튼 + "Back" 텍스트 + 로고 이미지
- **메인 컨테이너**: 최대 너비 570px (반응형)
- **헤더 섹션**:
  - "Phone Login" 제목
  - 안내 메시지 텍스트
- **인증 카드** (흰색 배경, 둥근 모서리):
  - 전화번호 표시
  - 6자리 PIN 입력 필드
  - 인증 상태 메시지
  - 타이머 디스플레이
  - 재전송 버튼
  - 도움말 텍스트
- **Next 버튼**: 인증 성공 시 활성화

**초기화 로직**:
```dart
// 페이지 로드 시 타이머 시작 및 재전송 활성화 설정
SchedulerBinding.instance.addPostFrameCallback((_) async {
  _model.timerController.onStartTimer();
  await Future.delayed(const Duration(milliseconds: 30000));  // 30초 후
  _model.canResendCode = true;
  setState(() {});
});
```

### 2. PhonelogeinpincodeModel (48줄)

**역할**: 상태 관리 및 타이머 제어

**로컬 상태 필드**:
```dart
bool? isVerified;        // 인증 성공 여부
bool canResendCode = false;  // 재전송 가능 여부
int canResendCount = 0;      // 재전송 시도 횟수
```

**위젯 상태 필드**:
```dart
// PIN 코드 입력 필드
TextEditingController? pinCodeController;
FocusNode? pinCodeFocusNode;
String? Function(BuildContext, String?)? pinCodeControllerValidator;

// 타이머 관련
final timerInitialTimeMs = 120000;  // 2분 (120초)
int timerMilliseconds = 120000;
String timerValue = StopWatchTimer.getDisplayTime(...);
AppTimerController timerController;  // 카운트다운 타이머
```

## 🔄 SMS 인증 프로세스

### 1. PIN 코드 입력
```dart
PinCodeTextField(
  length: 6,
  keyboardType: TextInputType.number,
  autoFocus: true,
  focusNode: _model.pinCodeFocusNode,
  controller: _model.pinCodeController,
  onCompleted: (_) async {
    // 6자리 입력 완료 시 자동 검증
  },
  pinTheme: PinTheme(
    fieldHeight: 44.0,
    fieldWidth: 44.0,
    borderWidth: 2.0,
    borderRadius: BorderRadius.circular(12.0),
    shape: PinCodeFieldShape.box,
  ),
)
```

### 2. SMS 코드 검증
```dart
onCompleted: (_) async {
  GoRouter.of(context).prepareAuthEvent();
  final smsCodeVal = _model.pinCodeController!.text;
  
  if (smsCodeVal.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enter SMS verification code.'))
    );
    return;
  }
  
  // Firebase SMS 코드 검증
  final phoneVerifiedUser = await authManager.verifySmsCode(
    context: context,
    smsCode: smsCodeVal,
  );
  
  if (phoneVerifiedUser == null) {
    return;
  }
  
  // 인증 상태 업데이트
  if (loggedIn) {
    _model.isVerified = true;  // 성공
  } else {
    _model.isVerified = false;  // 실패
  }
}
```

### 3. 타이머 관리
```dart
AppTimer(
  initialTime: _model.timerInitialTimeMs,  // 120초
  controller: _model.timerController,
  updateStateInterval: Duration(milliseconds: 1000),
  onChanged: (value, displayTime, shouldUpdate) {
    _model.timerMilliseconds = value;
    _model.timerValue = displayTime;
    if (shouldUpdate) setState(() {});
  },
)
```

### 4. SMS 재전송 로직
```dart
AppButtonWidget(
  onPressed: (_model.timerMilliseconds > 90000)  // 30초 이상 남았으면 비활성화
      ? null
      : () async {
          if (_model.canResendCount < 3) {
            _model.canResendCount += 1;
            
            // 타이머 리셋 (60초)
            _model.timerController.timer.setPresetTime(mSec: 60000, add: false);
            _model.timerController.onResetTimer();
            _model.timerController.onStartTimer();
            
            // SMS 재전송
            await authManager.beginPhoneAuth(
              context: context,
              phoneNumber: widget.phoneNumberParam,
              onCodeSent: (context) async {
                // 재전송 성공 처리
              },
            );
            
            // 안내 메시지
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message resent. After 3 attempts...'))
            );
          } else {
            // 3회 초과 시 처음 화면으로
            context.pushNamed(PhoneCreatAccountWidget.routeName);
          }
        },
  text: 'Re Code',
)
```

### 5. 인증 성공 처리
```dart
// Next 버튼 - 인증 성공 시만 활성화
AppButtonWidget(
  onPressed: (_model.isVerified != true)
      ? null
      : () async {
          // 기본 프로필 이미지 설정
          await currentUserReference!.update(createUsersModelData(
            photoUrl: 'https://firebasestorage.googleapis.com/.../defaultimage.jpg',
          ));
          
          // 사용자 정보 입력 화면으로 이동
          context.pushNamed(
            UserInfoInputWidget.routeName,
            extra: <String, dynamic>{
              kTransitionInfoKey: TransitionInfo(
                hasTransition: true,
                duration: Duration(milliseconds: 500),
              ),
            },
          );
        },
  text: 'Next',
)
```

## 🎨 UI/UX 특징

### 테마 적용
- **배경색**:
  - Scaffold: `primaryBackground`
  - AppBar: 흰색 (`Colors.white`)
  - 메인 컨테이너: 밝은 회색 (`#ECECEC`)
  - 인증 카드: 흰색 배경
- **상태 색상**:
  - 성공: 보라색 (`#8000FD`)
  - 실패: 빨간색 (`#FF0000`)
  - 비활성: 회색 (`#57636C`)

### PIN 입력 필드 스타일
```dart
PinTheme(
  fieldHeight: 44.0,
  fieldWidth: 44.0,
  borderWidth: 2.0,
  borderRadius: BorderRadius.circular(12.0),
  shape: PinCodeFieldShape.box,
  activeColor: AppTheme.of(context).primaryText,
  inactiveColor: AppTheme.of(context).alternate,
  selectedColor: AppTheme.of(context).primary,
)
```

### 인증 상태 표시
- **성공 메시지**: "Authentication succeeded!!" (보라색, 20px)
- **실패 메시지**: "Authentication failed. Please try again." (빨간색, 20px)
- **조건부 렌더링**: `_model.isVerified` 상태에 따라 동적 표시

## 🌍 국제화 (i18n)

### 주요 번역 키
```dart
'bjt41bts' - "Back"
'daf828ek' - "Phone Login"
'ddk0vrr5' - "Please enter your phone number..."
'6lsg39md' - "Enter the 6-digit code sent to..."
'ep61t57h' - "Authentication succeeded!!"
'85h4oe02' - "Authentication failed. Please try again."
'7ezietmr' - "Re Code"
'pyfnfxye' - "Tip. If you haven't received it..."
'xjt78grf' - "Next"
```

## 🔗 네비게이션 연결

### 진입 경로
- `/phoneCreatAccount` → SMS 코드 발송 후 자동 이동

### 네비게이션 플로우
```dart
// 이전 화면으로 돌아가기
context.pushNamed(
  PhoneCreatAccountWidget.routeName,
  queryParameters: {
    'phoneNumberParam': serializeParam('', ParamType.String),
  },
);

// 인증 성공 시 사용자 정보 입력으로 이동
context.pushNamed(
  UserInfoInputWidget.routeName,
  extra: <String, dynamic>{
    kTransitionInfoKey: TransitionInfo(
      hasTransition: true,
      duration: Duration(milliseconds: 500),
    ),
  },
);
```

## 📱 위젯 트리 구조

```
Scaffold
├── AppBar
│   ├── leading: AppIconButton (뒤로가기)
│   ├── title: Row
│   │   ├── Text ("Back")
│   │   └── ClipRRect
│   │       └── Image.asset (로고)
│   └── centerTitle: false
└── body: Align (top-center)
    └── Container (maxWidth: 570px)
        └── Column
            ├── Text ("Phone Login")
            ├── Text (설명)
            ├── Container (인증 카드)
            │   └── Column
            │       ├── RichText (전화번호 + 안내)
            │       ├── PinCodeTextField (6자리)
            │       ├── Container (상태 메시지)
            │       │   └── Text (성공/실패)
            │       └── Container (타이머 섹션)
            │           ├── AppTimer
            │           ├── AppButtonWidget ("Re Code")
            │           └── Text (도움말)
            └── AppButtonWidget ("Next")
```

## 🔒 보안 고려사항

1. **재전송 제한**:
   - 최대 3회 재전송 허용
   - 30초 대기 시간 강제
   - 3회 초과 시 처음부터 다시 시작

2. **타이머 보안**:
   - 초기 2분 타이머
   - 재전송 시 60초로 단축
   - 클라이언트 측 조작 방지

3. **입력 검증**:
   - 6자리 숫자만 허용
   - 자동 완성 비활성화
   - Firebase 서버 검증

4. **세션 관리**:
   - Firebase Auth 상태 감지
   - 인증 후 자동 로그인
   - 실패 시 명확한 피드백

## 🐛 알려진 이슈

1. **하드코딩된 메시지**: 일부 에러 메시지가 영어로 하드코딩됨 (i18n 필요)
2. **타이머 동기화**: 백그라운드 상태에서 타이머 동기화 문제 가능
3. **재전송 카운터**: 카운터 증가 로직 수정 필요 (`= 1` → `+= 1`)
4. **빈 전화번호**: 재전송 시 전화번호가 빈 문자열로 전달되는 문제

## 📈 개선 제안

1. **UX 개선**:
   - 자동 SMS 읽기 기능 추가
   - 진동/소리 피드백 추가
   - 로딩 상태 표시 개선
   - 부분 입력 상태에서도 검증 시도 방지

2. **보안 강화**:
   - Rate limiting 서버 측 구현
   - 브루트포스 공격 방지
   - IP 기반 차단 메커니즘
   - 비정상 패턴 감지

3. **에러 처리**:
   - 네트워크 오류 처리 개선
   - 타임아웃 처리 추가
   - 더 구체적인 에러 메시지

4. **접근성**:
   - 스크린 리더 지원
   - 키보드 네비게이션 개선
   - 고대비 모드 지원

## 📝 변경 이력

- **2025-08-23**: README 전면 재작성 (코드 분석 기반)
- **2025-08-22**: 초기 생성
- **2025-07-03**: FlutterFlow에서 Native Flutter로 마이그레이션

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-23  
**작성**: AI Assistant