# 📦 Auth Widgets Layer - 인증 위젯 컴포넌트

> Feature-First Architecture의 Presentation Layer 중 재사용 가능한 위젯 구현

## 📋 개요

이 디렉토리는 인증 기능의 **Widgets Layer**를 담당합니다. 모든 인증 관련 화면에서 공통으로 사용되는 재사용 가능한 UI 컴포넌트들을 제공합니다.

### 🎯 목적
- **재사용성**: 인증 플로우 전반에서 사용되는 공통 컴포넌트
- **일관성**: 통일된 디자인 시스템과 UX 패턴 적용
- **모듈화**: 독립적으로 테스트 가능한 위젯 단위
- **접근성**: WCAG 2.1 AA 기준 준수

## 🏗️ 아키텍처 구조

```
presentation/widgets/
├── fields/                        # 입력 필드 컴포넌트
│   ├── auth_text_field.dart     # 공통 텍스트 입력 필드
│   ├── password_field.dart      # 비밀번호 입력 (보기/숨기기 토글)
│   ├── email_field.dart         # 이메일 입력 (실시간 검증)
│   ├── phone_input_field.dart   # 전화번호 입력 (국가 코드 선택)
│   └── pin_code_field.dart      # PIN 코드 입력 (6자리)
│
├── buttons/                       # 버튼 컴포넌트
│   ├── auth_button.dart          # 기본 인증 버튼
│   ├── social_login_button.dart  # 소셜 로그인 버튼 (개별)
│   ├── social_login_group.dart   # 소셜 로그인 버튼 그룹
│   ├── gradient_button.dart      # 그라데이션 버튼
│   └── text_button_link.dart     # 텍스트 링크 버튼
│
├── dialogs/                       # 다이얼로그 & 모달
│   ├── auth_dialog.dart          # 공통 다이얼로그 템플릿
│   ├── error_dialog.dart         # 에러 메시지 다이얼로그
│   ├── loading_overlay.dart      # 로딩 오버레이
│   ├── email_verification_modal.dart  # 이메일 인증 모달
│   └── phone_verification_sheet.dart  # 전화 인증 바텀시트
│
├── indicators/                    # 상태 표시 컴포넌트
│   ├── auth_progress_indicator.dart   # 단계별 진행 표시
│   ├── password_strength_meter.dart   # 비밀번호 강도 측정기
│   ├── timer_display.dart            # 카운트다운 타이머
│   └── verification_status.dart      # 인증 상태 표시
│
├── security/                      # 보안 컴포넌트
│   ├── biometric_auth_button.dart    # 생체 인증 버튼
│   ├── captcha_widget.dart          # reCAPTCHA 위젯
│   └── terms_checkbox.dart          # 약관 동의 체크박스
│
└── layout/                        # 레이아웃 컴포넌트
    ├── auth_header.dart          # 인증 화면 헤더
    ├── auth_footer.dart          # 인증 화면 푸터
    ├── divider_with_text.dart    # OR 구분선
    └── auth_scaffold.dart        # 인증 화면 기본 레이아웃
```

## 📂 컴포넌트별 상세 설명

### 1. fields/ - 입력 필드 컴포넌트

#### auth_text_field.dart
**책임**: 인증 화면에서 사용되는 공통 텍스트 입력 필드

**주요 속성**:
- `controller`: TextEditingController
- `hintText`: 플레이스홀더 텍스트
- `labelText`: 라벨 텍스트
- `errorText`: 에러 메시지
- `prefixIcon`: 앞쪽 아이콘
- `validator`: 유효성 검증 함수
- `keyboardType`: 키보드 타입

**특징**:
- 일관된 스타일링
- 자동 에러 표시
- 포커스 상태 관리
- 접근성 라벨 지원

#### password_field.dart
**책임**: 비밀번호 입력 전용 필드

**주요 기능**:
- 비밀번호 표시/숨기기 토글
- 비밀번호 강도 표시 (선택적)
- 최소 길이 검증
- 특수문자/숫자 포함 검증

#### email_field.dart
**책임**: 이메일 입력 전용 필드

**주요 기능**:
- 이메일 형식 실시간 검증
- 자동 소문자 변환
- @ 기호 자동 추가 (선택적)
- 도메인 자동완성

#### phone_input_field.dart
**책임**: 전화번호 입력 필드

**주요 기능**:
- 국가 코드 선택 드롭다운
- 전화번호 형식 자동 포맷팅
- 국제 전화번호 검증
- 숫자 키패드 자동 표시

#### pin_code_field.dart
**책임**: PIN 코드 입력 (OTP)

**주요 기능**:
- 6자리 개별 입력 박스
- 자동 포커스 이동
- 붙여넣기 지원
- 숫자만 입력 가능

### 2. buttons/ - 버튼 컴포넌트

#### auth_button.dart
**책임**: 기본 인증 버튼

**타입**:
- Primary: 주요 액션 (로그인, 회원가입)
- Secondary: 보조 액션 (취소, 뒤로가기)
- Outline: 테두리만 있는 버튼
- Text: 텍스트만 있는 버튼

**상태**:
- Normal: 기본 상태
- Loading: 로딩 중
- Disabled: 비활성화
- Success: 성공
- Error: 에러

#### social_login_button.dart
**책임**: 개별 소셜 로그인 버튼

**지원 플랫폼**:
- Google
- Apple
- GitHub
- Facebook (예정)
- Twitter (예정)

**특징**:
- 플랫폼별 브랜드 색상
- 플랫폼별 아이콘
- 일관된 크기와 스타일

#### social_login_group.dart
**책임**: 소셜 로그인 버튼 그룹

**레이아웃**:
- 가로 배열 (기본)
- 세로 배열 (선택적)
- 그리드 배열 (많은 옵션)

### 3. dialogs/ - 다이얼로그 & 모달

#### auth_dialog.dart
**책임**: 공통 다이얼로그 템플릿

**구성요소**:
- 타이틀
- 내용
- 액션 버튼 (확인, 취소)
- 닫기 버튼

#### error_dialog.dart
**책임**: 에러 메시지 표시

**타입**:
- Network Error
- Validation Error
- Server Error
- Permission Error

#### loading_overlay.dart
**책임**: 로딩 상태 표시

**특징**:
- 전체 화면 오버레이
- 로딩 메시지 표시
- 취소 가능 옵션
- 진행률 표시 (선택적)

#### email_verification_modal.dart
**책임**: 이메일 인증 안내

**구성요소**:
- 이메일 발송 안내
- 재발송 버튼
- 타이머 표시
- 이메일 변경 옵션

### 4. indicators/ - 상태 표시 컴포넌트

#### auth_progress_indicator.dart
**책임**: 단계별 진행 상태 표시

**스타일**:
- Linear: 선형 진행바
- Circular: 원형 진행바
- Steps: 단계별 표시

#### password_strength_meter.dart
**책임**: 비밀번호 강도 측정 및 표시

**강도 레벨**:
1. 매우 약함 (빨강)
2. 약함 (주황)
3. 보통 (노랑)
4. 강함 (연두)
5. 매우 강함 (초록)

**평가 기준**:
- 길이 (8자 이상)
- 대문자 포함
- 소문자 포함
- 숫자 포함
- 특수문자 포함

#### timer_display.dart
**책임**: 카운트다운 타이머 표시

**사용 사례**:
- 이메일 인증 제한 시간
- SMS 재발송 대기 시간
- 세션 만료 경고

### 5. security/ - 보안 컴포넌트

#### biometric_auth_button.dart
**책임**: 생체 인증 버튼

**지원 타입**:
- Face ID (iOS)
- Touch ID (iOS)
- 지문 인증 (Android)
- 얼굴 인증 (Android)

#### captcha_widget.dart
**책임**: reCAPTCHA 통합

**기능**:
- reCAPTCHA v2 지원
- reCAPTCHA v3 지원
- 자동 검증
- 에러 처리

#### terms_checkbox.dart
**책임**: 약관 동의 체크박스

**구성요소**:
- 체크박스
- 약관 텍스트
- 약관 보기 링크
- 필수/선택 표시

### 6. layout/ - 레이아웃 컴포넌트

#### auth_header.dart
**책임**: 인증 화면 공통 헤더

**구성요소**:
- 로고
- 타이틀
- 서브타이틀
- 뒤로가기 버튼

#### auth_footer.dart
**책임**: 인증 화면 공통 푸터

**구성요소**:
- 도움말 링크
- 이용약관 링크
- 개인정보처리방침 링크
- 저작권 정보

#### divider_with_text.dart
**책임**: 텍스트가 있는 구분선

**사용 예**:
- "또는"
- "OR"
- "다른 방법으로 로그인"

#### auth_scaffold.dart
**책임**: 인증 화면 기본 레이아웃

**구성요소**:
- SafeArea
- 키보드 회피
- 스크롤 가능
- 배경 그라데이션

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: #4B39EF
- **Secondary**: #39D2C0
- **Error**: #FF5963
- **Success**: #04A24C
- **Warning**: #FFA130

### 타이포그래피
- **Title**: 24px, Bold
- **Subtitle**: 18px, Medium
- **Body**: 16px, Regular
- **Caption**: 14px, Regular

### 스페이싱
- **xs**: 4px
- **sm**: 8px
- **md**: 16px
- **lg**: 24px
- **xl**: 32px

### 반경(Border Radius)
- **small**: 4px
- **medium**: 8px
- **large**: 12px
- **circular**: 50%

## ♿ 접근성 지원

### Semantics 적용
- 모든 인터랙티브 요소에 라벨 제공
- 상태 변경 알림
- 포커스 순서 관리

### 키보드 네비게이션
- Tab 키 지원
- Enter/Space 키 동작
- Escape 키로 닫기

### 스크린 리더
- 의미 있는 설명 제공
- 에러 메시지 자동 읽기
- 진행 상태 알림

## 📱 반응형 디자인

### 브레이크포인트
- **Mobile**: < 600px
- **Tablet**: 600px - 1024px
- **Desktop**: > 1024px

### 적응형 레이아웃
- 화면 크기에 따른 레이아웃 변경
- 터치 타겟 최소 44px
- 적절한 여백과 패딩

## 🚀 마이그레이션 가이드

### 현재 위젯에서 이동할 파일들

| 현재 위치 | 대상 위치 | 설명 |
|----------|----------|------|
| `/lib/components/auth/` | `fields/`, `buttons/` | 인증 관련 컴포넌트 |
| `/lib/widgets/common/` | `layout/` | 공통 레이아웃 위젯 |
| `/lib/dialogs/` | `dialogs/` | 다이얼로그 컴포넌트 |

### 마이그레이션 단계

1. **위젯 분류** (1시간)
   - 기능별 분류
   - 디렉토리 생성
   - 파일 이동

2. **스타일 통합** (1시간)
   - 공통 테마 적용
   - 디자인 시스템 통일
   - 색상/타이포그래피 정리

3. **접근성 개선** (1시간)
   - Semantics 추가
   - 키보드 네비게이션
   - 스크린 리더 지원

4. **테스트 작성** (2시간)
   - Widget 테스트
   - Golden 테스트
   - 접근성 테스트

## 📋 체크리스트

### 구현 완료도
- [ ] 기본 입력 필드 컴포넌트
- [ ] 버튼 컴포넌트 세트
- [ ] 다이얼로그 시스템
- [ ] 상태 표시 위젯
- [ ] 보안 컴포넌트
- [ ] 레이아웃 템플릿
- [ ] 다크 모드 지원
- [ ] 국제화 지원

### 마이그레이션 체크포인트
- [ ] 기존 위젯 분석
- [ ] 분류 체계 수립
- [ ] 스타일 가이드 정의
- [ ] 접근성 요구사항 확인
- [ ] 테스트 계획 수립

## 🔗 관련 문서

- [Auth Feature 전체 마이그레이션 가이드](../../MIGRATION_AUTH.md)
- [Presentation Layer - Screens](../screens/README.md)
- [Presentation Layer - Providers](../providers/README.md)
- [Core - App Theme](../../../../core/README.md)
- [Common Widgets](../../../../common/widgets/README.md)

---

*이 문서는 Feature-First Architecture의 Auth Widgets Layer 구현 가이드입니다.*
*작성일: 2025-08-24*
*버전: 1.0*