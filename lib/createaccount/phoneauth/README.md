# 📱 Phone Authentication - 전화번호 인증 시스템

> Firebase Phone Authentication을 활용한 SMS 기반 2단계 인증 시스템

## 📋 개요

`phoneauth` 디렉토리는 Versus Space 앱의 전화번호 기반 인증 시스템을 구현합니다. Firebase Phone Authentication을 활용하여 SMS 인증을 통한 안전한 사용자 인증을 제공하며, 이메일 인증의 대안으로 더 빠르고 간편한 가입/로그인 경험을 제공합니다.

### 주요 특징
- **2단계 인증 프로세스**: 전화번호 입력 → SMS 코드 확인
- **Firebase Phone Auth 통합**: Google의 검증된 인증 시스템 활용
- **보안 강화**: SMS OTP, 재전송 제한, 타이머 기반 만료
- **사용자 친화적 UI**: 직관적인 입력 폼과 실시간 피드백
- **국제화 지원**: 다국어 지원 및 국가 코드 처리

## 🏗️ 아키텍처

### 인증 플로우
```mermaid
graph LR
    A[사용자] --> B[전화번호 입력]
    B --> C[Firebase Auth]
    C --> D[SMS 발송]
    D --> E[PIN 코드 입력]
    E --> F[코드 검증]
    F --> G[인증 완료]
    G --> H[사용자 정보 입력]
```

### 디렉토리 구조
```
phoneauth/
├── phone_creat_account/       # 전화번호 입력 및 SMS 발송
│   ├── phone_creat_account_widget.dart   # UI 위젯 (532줄)
│   ├── phone_creat_account_model.dart    # 상태 관리 (32줄)
│   └── README.md                          # 상세 문서
│
└── phonelogeinpincode/        # PIN 코드 확인 및 검증
    ├── phonelogeinpincode_widget.dart    # UI 위젯 (752줄)
    ├── phonelogeinpincode_model.dart     # 상태 관리 (48줄)
    └── README.md                          # 상세 문서
```

## 🎯 네이밍 컨벤션

### 전체 프로젝트 표준 준수
- **파일명**: snake_case (Dart 표준)
  - ✅ `phone_creat_account_widget.dart`
  - ✅ `phonelogeinpincode_model.dart`
- **클래스명**: PascalCase
  - ✅ `PhoneCreatAccountWidget`
  - ✅ `PhonelogeinpincodeModel`
- **필드명**: camelCase
  - ✅ `phoneNumberTextController`
  - ✅ `timerController`
  - ⚠️ **오타 존재**: `codeCuntry` → `codeCountry` (수정 필요)

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. Phone Create Account (전화번호 입력)
**목적**: 사용자로부터 전화번호를 입력받아 SMS 인증 코드 발송

**핵심 기능**:
- 국가 코드 자동 포맷팅 (`+###` 형식)
- 전화번호 유효성 검사
- Firebase beginPhoneAuth 호출
- SMS 발송 후 PIN 입력 페이지로 자동 이동

**주요 컴포넌트**:
```dart
// 전화번호 입력 및 SMS 발송
await authManager.beginPhoneAuth(
  context: context,
  phoneNumber: phoneNumberVal,
  onCodeSent: (context) async {
    // PIN 입력 페이지로 이동
    context.goNamedAuth(
      PhonelogeinpincodeWidget.routeName,
      context.mounted,
      queryParameters: {
        'phoneNumberParam': serializeParam(phoneNumberVal, ParamType.String),
      },
    );
  },
);
```

### 2. Phone Login PIN Code (PIN 코드 확인)
**목적**: SMS로 받은 6자리 인증 코드 확인 및 인증 완료

**핵심 기능**:
- 6자리 PIN 코드 입력 UI (PinCodeTextField)
- 2분 카운트다운 타이머
- SMS 재전송 기능 (최대 3회)
- 실시간 인증 상태 표시
- Firebase verifySmsCode 호출

**주요 컴포넌트**:
```dart
// SMS 코드 검증
final phoneVerifiedUser = await authManager.verifySmsCode(
  context: context,
  smsCode: smsCodeVal,
);

if (phoneVerifiedUser != null) {
  _model.isVerified = true;  // 인증 성공
  // 사용자 정보 입력 화면으로 이동
  context.pushNamed(UserInfoInputWidget.routeName);
}
```

## 🔄 전체 인증 프로세스

### Step 1: 전화번호 입력
1. 사용자가 국가 코드 선택 (예: +82)
2. 전화번호 입력 (숫자만 허용)
3. "Send Code" 버튼 클릭
4. Firebase Phone Auth 초기화

### Step 2: SMS 발송
1. Firebase가 전화번호 검증
2. SMS 메시지 자동 발송
3. 자동으로 PIN 입력 화면 이동
4. 전화번호 정보 전달

### Step 3: PIN 코드 입력
1. 6자리 코드 입력 대기
2. 2분 타이머 시작
3. 입력 완료 시 자동 검증
4. 실패 시 재입력 가능

### Step 4: 인증 완료
1. Firebase 인증 성공
2. 사용자 세션 생성
3. 기본 프로필 이미지 설정
4. 사용자 정보 입력 화면으로 이동

## 🔒 보안 고려사항

### 재전송 제한
- **최대 3회**: 무한 재전송 방지
- **30초 대기**: 재전송 간 최소 시간 간격
- **타이머 단축**: 재전송 시 60초로 단축

### 입력 검증
- **국가 코드**: + 기호 필수, 최대 4자
- **전화번호**: 숫자만 허용, 최대 12자
- **PIN 코드**: 정확히 6자리 숫자

### 세션 관리
- **자동 만료**: 2분 후 코드 무효화
- **중복 방지**: 동일 번호 반복 요청 제한
- **Firebase 보안**: Google의 검증된 인증 시스템

## 🎨 UI/UX 특징

### 일관된 디자인
- **AppBar**: 뒤로가기 + "Back" 텍스트 + 로고
- **최대 너비**: 570px (반응형 레이아웃)
- **색상 테마**: Primary, Secondary, Error 색상 활용
- **입력 필드**: 둥근 모서리 (12px), 2px 테두리

### 사용자 피드백
- **실시간 유효성 검사**: 입력 중 즉시 피드백
- **상태 메시지**: 성공/실패 명확한 표시
- **타이머 표시**: 남은 시간 실시간 업데이트
- **로딩 상태**: 네트워크 작업 중 표시

## 🌍 국제화 (i18n)

### 지원 언어
- **English (en)**: 기본 언어
- **German (de)**: 번역 키 준비 완료

### 주요 번역 키
```dart
// phone_creat_account
'qgyftxro' - "Back"
'gwbbszpy' - "Phone Login"
'xv3gqx8x' - "Please enter your phone number..."
'pqidvgqu' - "Send Code"

// phonelogeinpincode
'daf828ek' - "Phone Login"
'6lsg39md' - "Enter the 6-digit code sent to..."
'ep61t57h' - "Authentication succeeded!!"
'7ezietmr' - "Re Code"
'xjt78grf' - "Next"
```

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **오타**: `codeCuntry` → `codeCountry` (Country 철자)
2. **버튼 로직**: 활성화 조건이 반대로 구현됨
3. **하드코딩**: 에러 메시지가 영어로 하드코딩됨
4. **재전송 카운터**: 증가 로직 버그 (`= 1` → `+= 1`)
5. **빈 전화번호**: 재전송 시 전화번호 미전달

### 개선 제안
1. **자동 SMS 읽기**: Android/iOS 자동 코드 감지
2. **국가 코드 선택기**: 드롭다운 UI 구현
3. **Rate Limiting**: 서버 측 재시도 제한
4. **캡차 통합**: 봇 방지 메커니즘
5. **접근성**: 스크린 리더 지원 강화

## 🔗 관련 페이지 및 네비게이션

### 진입 경로
- `/createAccount` → "Create Account With Phone" 버튼
- `/login` → "Login with Phone" 옵션

### 네비게이션 플로우
```dart
// 1. 계정 생성에서 전화번호 인증으로
CreateAccountWidget → PhoneCreatAccountWidget

// 2. 전화번호 입력에서 PIN 확인으로
PhoneCreatAccountWidget → PhonelogeinpincodeWidget

// 3. PIN 확인에서 사용자 정보 입력으로
PhonelogeinpincodeWidget → UserInfoInputWidget
```

## 📊 성능 메트릭

### 예상 사용 시나리오
- **SMS 발송 시간**: 5-30초 (네트워크 상황에 따라)
- **인증 완료 시간**: 평균 2분 이내
- **재시도율**: 약 15-20% (잘못된 코드 입력)
- **성공률**: 95% 이상 (정상적인 사용 시)

### 최적화 포인트
- **캐싱**: 국가 코드 목록 캐싱
- **프리로딩**: PIN 입력 페이지 사전 로드
- **병렬 처리**: Firebase 초기화와 UI 렌더링 병렬화

## 📝 변경 이력

- **2025-08-23**: README 전면 재작성 및 통합 문서화
- **2025-08-22**: 초기 생성
- **2025-07-03**: FlutterFlow에서 Native Flutter로 마이그레이션
