# 📱 Auth Screens Layer - 인증 화면 구현 계층

> Feature-First Architecture의 Presentation Layer 중 UI 화면 구현
> 최종 업데이트: 2025-08-25

## 📋 개요

이 디렉토리는 인증 기능의 **Screens Layer**를 담당합니다. 사용자가 직접 상호작용하는 모든 인증 관련 화면들을 포함하며, Provider와 연동하여 반응형 UI를 구현합니다.

### ⚠️ 의존성
- **Common Feature**: 공통 위젯 및 유틸리티 사용
- **App Feature**: 테마 시스템 및 라우팅 통합

### 🎯 목적
- **사용자 인터페이스 구현**: 직관적이고 사용하기 쉬운 인증 화면 제공
- **반응형 UI**: Provider와 연동한 실시간 상태 업데이트
- **재사용 가능한 위젯**: 공통 컴포넌트 활용으로 일관성 유지
- **접근성 지원**: 모든 사용자가 쉽게 사용할 수 있는 UI

## 🏗️ 아키텍처 구조

```
presentation/screens/
├── start/                           # 시작 화면
│   ├── start_page_widget.dart      # 앱 시작 화면 (로그인/회원가입 선택)
│   └── start_page_model.dart       # 시작 화면 상태 관리
│
├── login/                           # 로그인 화면
│   ├── login_page_widget.dart      # 이메일 로그인 화면
│   ├── login_page_model.dart       # 로그인 화면 상태
│   └── social_login_widget.dart    # 소셜 로그인 버튼들
│
├── signup/                          # 회원가입 화면
│   ├── create_account_widget.dart  # 계정 생성 화면
│   ├── create_account_model.dart   # 계정 생성 상태
│   ├── terms_agreement_widget.dart # 약관 동의 화면
│   └── profile_setup_widget.dart   # 프로필 설정 화면
│
├── forgot_password/                 # 비밀번호 재설정
│   ├── forgot_password_widget.dart # 비밀번호 찾기 화면
│   ├── forgot_password_model.dart  # 비밀번호 찾기 상태
│   └── reset_success_widget.dart   # 재설정 성공 화면
│
├── phone_auth/                      # 전화번호 인증
│   ├── phone_create_account_widget.dart  # 전화번호 회원가입
│   ├── phone_login_pincode_widget.dart   # PIN 코드 입력
│   ├── phone_verification_widget.dart    # 전화번호 인증
│   └── max_attempts/
│       └── phone_maximum_widget.dart     # 최대 시도 초과 화면
│
├── email_verification/              # 이메일 인증
│   ├── popup_timer_email_widget.dart    # 이메일 인증 타이머
│   ├── email_verification_model.dart    # 이메일 인증 상태
│   └── resend_email_widget.dart         # 재발송 화면
│
└── onboarding/                      # 온보딩 프로세스
    ├── user_info_input_widget.dart      # 사용자 정보 입력
    ├── interests_selection_widget.dart  # 관심사 선택
    ├── job_selection_widget.dart        # 직업 선택
    └── onboarding_complete_widget.dart  # 온보딩 완료
```

## 📂 화면별 상세 설명

### 1. start/start_page_widget.dart (시작 화면)

**책임**: 앱 시작 시 첫 화면, 로그인/회원가입 선택

**주요 구성요소**:
- VS 로고 및 앱 타이틀 표시
- 이메일 로그인 버튼
- 회원가입 버튼
- 소셜 로그인 버튼 (Google, Apple, GitHub)
- 게스트 모드 옵션

**상태 관리**:
- `StartPageModel`: 화면 상태 관리
- 자동 로그인 체크 로직
- 애니메이션 설정 (로고, 버튼)

**라우팅**:
- `routeName`: 'startPage'
- `routePath`: '/start'

### 2. login/login_page_widget.dart (로그인 화면)

**책임**: 이메일/비밀번호 로그인 처리

**주요 구성요소**:
- 이메일 입력 필드 (유효성 검증 포함)
- 비밀번호 입력 필드 (숨김/표시 토글)
- Remember Me 체크박스
- 로그인 버튼
- 비밀번호 찾기 링크
- 회원가입 링크

**상태 관리**:
- `LoginPageModel`: 폼 상태 및 입력값 관리
- Form 유효성 검증
- 로딩 상태 처리
- 에러 메시지 표시

**라우팅**:
- `routeName`: 'loginPage'
- `routePath`: '/login'

### 3. signup/create_account_widget.dart (회원가입 화면)

**책임**: 새 계정 생성

**주요 구성요소**:
- 이메일 입력 필드
- 비밀번호 입력 필드 (강도 표시)
- 비밀번호 확인 필드
- 디스플레이 이름 입력
- 약관 동의 체크박스
- 회원가입 버튼

**상태 관리**:
- `CreateAccountModel`: 회원가입 폼 상태
- 비밀번호 강도 계산
- 약관 동의 상태 관리

### 4. forgot_password/forgot_password_widget.dart (비밀번호 재설정)

**책임**: 비밀번호 재설정 이메일 발송

**주요 구성요소**:
- 이메일 입력 필드
- 재설정 이메일 발송 버튼
- 성공/실패 메시지 표시

### 5. phone_auth/ (전화번호 인증)

**전화번호 회원가입 프로세스**:
1. `phone_create_account_widget.dart`: 전화번호 입력
2. `phone_verification_widget.dart`: SMS 코드 입력
3. `phone_login_pincode_widget.dart`: PIN 코드 설정
4. `phone_maximum_widget.dart`: 최대 시도 초과 시

**특징**:
- 국가 코드 선택
- SMS 재발송 (최대 3회)
- 60초 타이머
- PIN 코드 보안

### 6. email_verification/ (이메일 인증)

**책임**: 이메일 인증 프로세스

**주요 구성요소**:
- 인증 이메일 발송 안내
- 10분 타이머
- 재발송 버튼
- 이메일 주소 변경 옵션

### 7. onboarding/ (온보딩 프로세스)

**단계별 온보딩**:
1. `user_info_input_widget.dart`: 생년월일, 성별 입력
2. `job_selection_widget.dart`: 직업 카테고리 선택
3. `interests_selection_widget.dart`: 관심사 선택 (최대 8개)
4. `onboarding_complete_widget.dart`: 완료 및 홈 이동

## 🎨 UI/UX 디자인 가이드라인

### 색상 시스템
- **Primary**: #4B39EF (메인 브랜드 색상)
- **Secondary**: #39D2C0 (강조 색상)
- **Background**: #F1F4F8 (Primary), #FFFFFF (Secondary)
- **Text**: #14181B (Primary), #57636C (Secondary)
- **State**: Success(#04A24C), Warning(#FFA130), Error(#FF5963)

### 타이포그래피
- **Display**: 36-57px, Bold
- **Title**: 14-22px, Medium
- **Body**: 12-16px, Regular
- **Label**: 11-14px, Medium

### 스페이싱 시스템
- **Padding/Margin**: 4px(xs), 8px(sm), 16px(md), 24px(lg), 32px(xl), 48px(xxl)
- **Border Radius**: 4px(small), 8px(medium), 12px(large), 16px(extraLarge)

## 🔄 화면 네비게이션 플로우

1. **시작** → 로그인/회원가입 선택
2. **로그인** → 성공 시 이메일 인증 확인 → 홈 또는 이메일 인증
3. **회원가입** → 약관 동의 → 프로필 설정 → 관심사 선택 → 이메일 인증
4. **비밀번호 재설정** → 이메일 입력 → 성공 메시지 → 로그인
5. **전화번호 인증** → SMS 코드 → PIN 설정 → 완료
6. **온보딩** → 정보 입력 → 직업 선택 → 관심사 선택 → 완료

## 📱 반응형 디자인

### 브레이크포인트
- **Mobile**: < 600px
- **Tablet**: 600px - 1024px
- **Desktop**: > 1024px

### 반응형 전략
- Mobile First 접근
- 유동적 레이아웃
- 터치 친화적 UI (최소 44px 터치 영역)

## ♿ 접근성 지원

1. **스크린 리더 지원**
   - Semantics 위젯 사용
   - 의미 있는 라벨 제공
   - 포커스 순서 관리

2. **키보드 네비게이션**
   - Tab 키 지원
   - Enter/Space 키 동작
   - Escape 키로 닫기

3. **시각적 피드백**
   - 충분한 색상 대비
   - 포커스 인디케이터
   - 에러 메시지 명확화

4. **텍스트 크기 조절**
   - 시스템 텍스트 크기 지원
   - 최소/최대 크기 제한

## 🚀 마이그레이션 가이드

### 현재 화면에서 이동할 파일들

| 현재 위치 | 대상 위치 | 설명 |
|----------|----------|------|
| `/lib/login/start_page/` | `start/` | 시작 화면 |
| `/lib/login/login_page/` | `login/` | 로그인 화면 |
| `/lib/login/forgot_password/` | `forgot_password/` | 비밀번호 재설정 |
| `/lib/createaccount/create_account/` | `signup/` | 회원가입 화면 |
| `/lib/createaccount/phoneauth/` | `phone_auth/` | 전화번호 인증 |
| `/lib/createaccount/popup_timer_email/` | `email_verification/` | 이메일 인증 |
| `/lib/pages/jop/` | `onboarding/` | 온보딩 프로세스 |

### 마이그레이션 단계

1. **화면 파일 이동** (2시간)
   - git mv 명령으로 파일 이동
   - 디렉토리 구조 정리
   - import 경로 수정

2. **Provider 연결** (1시간)
   - Consumer 위젯 적용
   - Provider 의존성 주입
   - 상태 기반 UI 업데이트

3. **공통 위젯 추출** (1시간)
   - 중복 코드 제거
   - 재사용 가능한 컴포넌트 생성
   - 위젯 라이브러리 구축

4. **테스트 작성** (2시간)
   - Widget 테스트
   - Integration 테스트
   - Golden 테스트

## 📋 체크리스트

### 구현 완료도
- [ ] 시작 화면 (start_page_widget.dart)
- [ ] 로그인 화면 (login_page_widget.dart)
- [ ] 회원가입 화면 (create_account_widget.dart)
- [ ] 비밀번호 재설정 (forgot_password_widget.dart)
- [ ] 전화번호 인증 (phone_auth 디렉토리)
- [ ] 이메일 인증 (email_verification 디렉토리)
- [ ] 온보딩 프로세스 (onboarding 디렉토리)
- [ ] 소셜 로그인 통합
- [ ] 에러 처리 UI
- [ ] 로딩 상태 UI

### 마이그레이션 체크포인트
- [ ] 현재 화면 분석 완료
- [ ] 파일 이동 계획 수립
- [ ] Provider 연결 설계
- [ ] UI/UX 일관성 확인
- [ ] 접근성 요구사항 충족
- [ ] 테스트 커버리지 80% 이상

## 🔗 관련 문서

- [Auth Feature 전체 마이그레이션 가이드](../../MIGRATION_AUTH.md)
- [Presentation Layer - Providers](../providers/README.md)
- [Presentation Layer - Widgets](../widgets/README.md)
- [Domain Layer - UseCases](../../domain/usecases/README.md)
- [Core - App Theme](../../../../core/README.md)

---

*이 문서는 Feature-First Architecture의 Auth Screens Layer 구현 가이드입니다.*
*작성일: 2025-08-24*
*버전: 1.0*