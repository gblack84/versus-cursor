# 📱 PhoneLoginPincode - 전화번호 PIN 인증

## 📋 개요

전화번호 기반 SMS PIN 코드 인증을 테스트하기 위한 페이지입니다. Firebase Phone Auth와 연동되어 있으며, 현재는 레거시 테스트 코드입니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`PhoneloginpincodeWidget`, `PhoneloginpincodeModel`)
- **라우트명**: 라우트 미설정 (미사용 페이지)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
phoneloginpincode/
├── phoneloginpincode_widget.dart    # PIN 입력 UI
└── phoneloginpincode_model.dart     # 상태 관리
```

## 📱 기능

### 주요 컴포넌트
- **PIN 코드 입력**: 6자리 PIN 코드 입력 필드
- **타이머**: 60초 카운트다운 타이머
- **재전송 버튼**: SMS 재전송 기능
- **자동 인증**: PIN 입력 완료 시 자동 검증
- **VS 마크**: VsmarkWidget 참조

### 인증 플로우
1. SMS로 PIN 코드 수신
2. 6자리 코드 입력
3. Firebase Phone Auth 검증
4. 성공 시 UserInfoInput 페이지로 이동

## 💻 코드 분석

### PhoneloginpincodeWidget
```dart
// PIN 코드 필드 사용
PinCodeTextField(
  length: 6,
  autoFocus: true,
  autoDisposeControllers: false,
  // 60초 타이머 연동
  // Firebase Auth 통합
)
```

### 타이머 기능
```dart
// StopWatchTimer 사용
_model.timerController.onStartTimer();
// 60초 후 자동 종료
// 재전송 버튼 활성화
```

## 🚫 문제점

### 코드 품질 이슈
1. **하드코딩된 타이머**: 60초 고정값
2. **미완성 에러 처리**: PIN 검증 실패 처리 부재
3. **레거시 의존성**: vsmark 위젯 직접 참조

### 보안 이슈
- PIN 재시도 제한 없음
- 타이머 우회 가능
- 에러 메시지 노출

## 🔄 대체 구현

### 프로덕션 인증
```dart
// 실제 사용 경로
/lib/createaccount/phoneconfirm/    # 전화번호 확인
/lib/auth/                          # 인증 서비스
```

## 📊 통계

- **위젯 파일**: 약 200줄
- **모델 파일**: 약 50줄
- **상태**: 🔴 미사용 (레거시)
- **의존성**: Firebase Auth, PinCodeFields, StopWatchTimer

## ⚠️ 주의사항

> **경고**: 테스트 목적으로만 생성된 코드입니다.
> 프로덕션에서 사용하지 마세요.

### 권장 사항
- ✅ `/lib/createaccount/phoneconfirm/` 사용
- ✅ 재시도 제한 구현
- ✅ 적절한 에러 처리

## 🗑️ 제거 계획

- **Phase 1**: 의존성 확인 ✅
- **Phase 2**: vsmark 참조 제거 필요
- **Phase 3**: 다음 정리 작업 시 제거 예정 📅

## 📝 변경 이력
- 2025-08-24: 문서화 완료
- 2025-08-22: 초기 생성

---

*이 디렉토리는 레거시 테스트 코드를 포함하고 있으며, 향후 제거될 예정입니다.*
