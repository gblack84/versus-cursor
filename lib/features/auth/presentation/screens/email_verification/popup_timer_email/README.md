# ✉️ Popup Timer Email - 이메일 인증 타이머 팝업

> 이메일 인증 대기 중 표시되는 실시간 타이머 팝업 컴포넌트

## 📋 개요

`popup_timer_email` 디렉토리는 Versus Space 앱의 이메일 인증 프로세스 중 표시되는 팝업 컴포넌트를 구현합니다. 사용자가 계정 생성 후 이메일 인증을 기다리는 동안 3분 카운트다운 타이머와 함께 인증 상태를 실시간으로 확인하고, 이메일 재전송 및 수정 기능을 제공합니다.

### 주요 기능
- 3분(180초) 카운트다운 타이머
- 실시간 이메일 인증 상태 확인
- 이메일 재전송 기능 (최대 3회)
- 이메일 주소 수정 옵션
- 인증 성공 시 자동 네비게이션
- 타임아웃 시 계정 자동 삭제

## 🎯 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `popup_timer_email_widget.dart`, `popup_timer_email_model.dart`
- ✅ **위젯/모델 접미사**: 역할을 명확히 구분

### 클래스명
- ✅ **PascalCase 사용**: `PopupTimerEmailWidget`, `PopupTimerEmailModel`
- ✅ **Widget/Model 접미사**: 컴포넌트 타입 명시

### 필드 및 메서드
- ✅ **camelCase 사용**: `resendCount`, `isVerifiedEmail`, `timerController`
- ✅ **boolean 접두사**: `isVerifiedEmail`
- ✅ **카운터 변수**: `resendCount`, `timerMilliseconds`

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. PopupTimerEmailWidget (472줄)

**역할**: 이메일 인증 대기 UI 및 실시간 상태 업데이트

**라우팅 정보**:
- 직접 라우팅 없음 (모달/팝업으로 표시)
- `showDialog()` 또는 오버레이로 표시

**UI 구조**:
- **컨테이너**: 300x350px 고정 크기, 둥근 모서리 (30px)
- **VS 로고**: VsmarkWidget 통합 (200.5 x 56.5)
- **상태 메시지**: "Email verification in progress..."
- **인증 버튼**: 상태에 따라 동적 변경
- **사용자 이메일**: 현재 이메일 주소 표시
- **액션 버튼**: Edit Email, Re Send
- **타이머**: 3분 카운트다운 표시

**주요 상태 관리**:
```dart
// 이메일 인증 상태 확인
AuthUserStreamWidget(
  builder: (context) => AppButtonWidget(
    onPressed: !currentUserEmailVerified
        ? null  // 인증 전: 비활성화
        : () async {
            // 인증 성공: 프로필 설정 후 다음 페이지로
            await currentUserReference!.update(createUsersModelData(
              photoUrl: 'default_image_url',
            ));
            Navigator.pop(context);
            context.pushNamed(UserInfoInputWidget.routeName);
          },
    text: currentUserEmailVerified
        ? 'Success!! Navigate To..!'
        : 'ing....',
  ),
)
```

### 2. PopupTimerEmailModel (41줄)

**역할**: 타이머 관리 및 재전송 카운트 추적

**로컬 상태 필드**:
```dart
int resendCount = 0;        // 재전송 시도 횟수
bool isVerifiedEmail = false;  // 이메일 인증 여부
```

**타이머 설정**:
```dart
final timerInitialTimeMs = 180000;  // 3분 (180초)
int timerMilliseconds = 180000;
AppTimerController timerController;  // 카운트다운 타이머
```

## 🔄 이메일 인증 프로세스

### Step 1: 팝업 표시 및 타이머 시작
```dart
@override
void initState() {
  super.initState();
  // 컴포넌트 로드 시 타이머 자동 시작
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    _model.timerController.onStartTimer();
  });
}
```

### Step 2: 실시간 인증 상태 확인
- `AuthUserStreamWidget`으로 Firebase Auth 상태 실시간 감지
- `currentUserEmailVerified` 플래그로 인증 여부 확인
- 인증 완료 시 버튼 자동 활성화

### Step 3: 이메일 재전송 로직
```dart
onPressed: () async {
  if (_model.resendCount < 3) {
    // 3회 미만: 재전송 허용
    _model.resendCount = _model.resendCount + 1;
    setState(() {});
    
    // 타이머 리셋 (2분으로 재설정)
    _model.timerController.timer.setPresetTime(mSec: 120000, add: false);
    _model.timerController.onResetTimer();
    _model.timerController.onStartTimer();
    
    // 이메일 재발송
    await authManager.sendEmailVerification();
  } else {
    // 3회 초과: 계정 삭제 및 재시작
    await currentUserReference!.delete();
    await authManager.deleteUser(context);
    Navigator.pop(context);
    
    // 에러 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You've exceeded the 3 attempt limit...'),
        duration: Duration(milliseconds: 4000),
        backgroundColor: Color(0xFFD2394E),
      ),
    );
    
    // 계정 생성 페이지로 리다이렉션
    context.pushNamed(CreateAccountWidget.routeName);
  }
}
```

### Step 4: 이메일 수정 옵션
```dart
// Edit Email 버튼
onPressed: () async {
  // 현재 계정 삭제
  await currentUserReference!.delete();
  await authManager.deleteUser(context);
  Navigator.pop(context);
  
  // 계정 생성 페이지로 돌아가기
  context.pushNamed(CreateAccountWidget.routeName);
}
```

### Step 5: 타임아웃 처리
```dart
AppTimer(
  onEnded: () async {
    // 3분 타임아웃: 자동 계정 삭제
    await authManager.deleteUser(context);
    Navigator.pop(context);
    
    // 시작 페이지로 리다이렉션
    context.pushNamed(StartPageWidget.routeName);
  },
)
```

## 🎨 UI/UX 특징

### 디자인 스타일
- **크기**: 300x350px 고정
- **배경**: `secondaryBackground` 테마 색상
- **모서리**: 30px 둥근 모서리
- **정렬**: 중앙 정렬

### 버튼 상태별 스타일
```dart
// 인증 대기 중
disabledColor: Color(0xFFFC9C9C),  // 연한 빨간색
disabledTextColor: Color(0xFFA50000),  // 진한 빨간색

// 활성 상태
color: Colors.black,
textStyle: Colors.white,

// 인증 완료
color: Colors.white,
borderColor: Color(0xFF14181B),
```

### 타이머 스타일
- **색상**: `#FF4E00` (주황색)
- **폰트**: Plus Jakarta Sans
- **크기**: headlineSmall
- **형식**: MM:SS (시간 제외, 밀리초 제외)

## 🌍 국제화 (i18n)

### 번역 키
```dart
'ajk36y0p' - "Email verification in progress..."
'zustpgk9' - "Check your Email,\n"
'c3ope0t7' - "Edit Email.."
'yqb182uz' - "Re Send.."
```

### 지원 언어
- **English (en)**: 기본 언어
- **German (de)**: 번역 키 준비

## 📱 위젯 트리 구조

```
Align (center)
└── Container (300x350, rounded 30px)
    └── Column
        ├── Container (VS Logo)
        │   └── VsmarkWidget
        ├── Container (Status Message)
        │   └── Text ("Email verification...")
        ├── AuthUserStreamWidget
        │   └── AppButtonWidget (Success/ing button)
        ├── Container (Email Display)
        │   └── RichText (user email)
        ├── Row (Action Buttons)
        │   ├── AppButtonWidget (Edit Email)
        │   └── AppButtonWidget (Re Send)
        └── AppTimer (Countdown)
```

## 🔗 네비게이션 플로우

### 진입 경로
- `/createAccount` → 이메일 계정 생성 후 자동 표시

### 이동 경로
- **인증 성공**: → `/userInfoInput` (사용자 정보 입력)
- **이메일 수정**: → `/createAccount` (계정 생성 재시작)
- **타임아웃**: → `/startPage` (시작 페이지)
- **3회 초과**: → `/createAccount` (계정 생성 재시작)

## 🛡️ 보안 고려사항

### 재전송 제한
- **최대 3회**: 무한 재전송 방지
- **타이머 리셋**: 재전송 시 2분으로 단축
- **3회 초과 시**: 계정 자동 삭제 및 재시작

### 타임아웃 보안
- **3분 제한**: 초기 인증 시간 제한
- **자동 삭제**: 타임아웃 시 미인증 계정 삭제
- **세션 관리**: Firebase Auth 세션 정리

### 계정 보호
- **이메일 수정 시**: 기존 계정 완전 삭제
- **중복 방지**: 동일 이메일 재사용 가능
- **실시간 검증**: AuthUserStream으로 상태 감지

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **하드코딩된 메시지**: 영어 에러 메시지 하드코딩
2. **고정 크기**: 300x350px 고정으로 반응형 미지원
3. **중복 스타일**: fontWeight, fontStyle 중복 설정
4. **기본 이미지 URL**: 프로필 이미지 URL 하드코딩

### 개선 제안
1. **반응형 디자인**: 화면 크기에 따른 동적 크기 조정
2. **이메일 변경 없이 재전송**: 계정 삭제 없이 재전송만 가능하도록
3. **프로그레스 인디케이터**: 인증 확인 중 로딩 표시
4. **더 나은 피드백**: 재전송 성공/실패 메시지 추가
5. **접근성**: 스크린 리더 지원 강화

## 📊 성능 메트릭

### 예상 시나리오
- **평균 인증 시간**: 30초 ~ 1분
- **재전송 비율**: 약 20-30%
- **타임아웃 비율**: 5% 미만
- **3회 초과 비율**: 1% 미만

### 최적화 포인트
- **실시간 업데이트**: AuthUserStream 효율적 사용
- **타이머 정확도**: 1초 단위 업데이트
- **메모리 관리**: dispose()에서 타이머 정리

## 💡 모범 사례

### 사용 방법
```dart
// 모달로 표시
showDialog(
  context: context,
  barrierDismissible: false,  // 배경 클릭 방지
  builder: (context) => PopupTimerEmailWidget(),
);
```

### 상태 관리
- Firebase Auth 상태와 동기화
- 타이머와 UI 상태 일치
- 네비게이션 전 리소스 정리

## 📝 변경 이력

- **2025-08-23**: README 전면 재작성 (코드 분석 기반)
- **2025-08-22**: 초기 생성
- **2025-07-03**: FlutterFlow에서 Native Flutter로 마이그레이션

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-23  
**작성**: AI Assistant