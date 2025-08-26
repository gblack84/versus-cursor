# 📱 /lib/features/profile/presentation/screens

> Feature-First Architecture - Profile 화면 계층

## 📋 개요

프로필 기능의 **Screens Layer**를 담당하는 디렉토리입니다. 사용자 프로필, 설정, 온보딩 등의 전체 화면을 구성하고 관리합니다.

### 🎯 목적
- **화면 구성**: 프로필 관련 전체 화면 구현
- **네비게이션**: 화면 간 전환 및 라우팅 관리
- **상태 연결**: Provider와 UI의 연결
- **레이아웃 관리**: 반응형 레이아웃 구현

## 🏗️ 디렉토리 구조

```
screens/
├── profile_main/                    # 프로필 메인 화면
│   ├── profile_page_widget.dart
│   └── profile_page_model.dart
├── profile_edit/                    # 프로필 편집 화면
│   ├── profile_edit_widget.dart
│   └── profile_edit_model.dart
├── user_info/                       # 사용자 정보 화면
│   ├── user_info_widget.dart
│   ├── user_info_model.dart
│   ├── character_detail/            # 캐릭터 상세
│   └── language_selector/           # 언어 선택
├── user_info_input/                 # 정보 입력 화면
│   ├── user_info_input_widget.dart
│   └── user_info_input_model.dart
├── onboarding/                      # 온보딩 플로우
│   ├── job_selection/               # 직업 선택
│   ├── interest_selection/          # 관심사 선택
│   └── character_creation/          # 캐릭터 생성
├── settings/                        # 설정 화면
│   ├── settings_widget.dart
│   ├── privacy_settings/
│   └── notification_settings/
└── premium/                         # 프리미엄 화면
    ├── premium_widget.dart
    └── premium_model.dart
```

## 📂 주요 화면 구현

### ProfilePageWidget (프로필 메인)

**역할**: 프로필 메인 화면 위젯

**주요 기능**:
- 사용자 프로필 정보 표시
- 통계 카드 (포인트, 게시물, 투표, 순위)
- 탭 네비게이션 (게시물, 투표, 친구)
- 프로필 편집 및 설정 접근
- Hero 애니메이션으로 프로필 이미지 전환

**화면 구성 요소**:
- SliverAppBar: 확장 가능한 헤더 (300px)
- 프로필 헤더: 이미지, 이름, 직업, 소개, 캐릭터
- 통계 카드: 4개 통계 항목
- TabBar: 3개 탭 (게시물, 투표, 친구)
- TabBarView: 각 탭 콘텐츠

**Props**:
- userId: 표시할 사용자 ID (null이면 현재 사용자)

**사용하는 Provider**:
- ProfileProvider
- FriendsProvider
- CharacterProvider

**네비게이션**:
- /profile/edit: 프로필 편집
- /settings: 설정 화면
- /profile/{userId}: 다른 사용자 프로필

### OnboardingFlow (온보딩 플로우)

**역할**: 온보딩 플로우 관리 화면

**주요 기능**:
- 6단계 온보딩 프로세스 관리
- 진행률 표시 및 추적
- 단계별 네비게이션
- 건너뛰기 기능
- 중단점 저장 및 복원

**온보딩 단계**:
1. AgeVerificationScreen: 나이 확인 (13세 이상)
2. JobSelectionScreen: 직업 선택
3. ExpertiseSelectionScreen: 전문분야 선택 (최대 4개)
4. HobbiesSelectionScreen: 취미 선택 (최대 8개)
5. CharacterCreationScreen: 캐릭터 생성
6. ProfileSetupScreen: 프로필 설정 완료

**화면 구성**:
- PageView: 스와이프 비활성화된 페이지 뷰
- LinearProgressIndicator: 진행률 표시
- 건너뛰기 버튼: 첫 단계 이후 표시
- 로딩 오버레이: 저장 중 표시

**사용하는 Provider**:
- OnboardingProvider

**네비게이션**:
- 완료 시: /home으로 이동
- 건너뛰기: 확인 후 /home으로 이동

## 🎨 화면 구성 가이드

### 레이아웃 원칙
- **반응형 디자인**: 다양한 화면 크기 지원
- **일관된 여백**: 16px 기본 패딩
- **접근성**: 최소 터치 영역 48x48
- **다크모드 지원**: 테마 적응형 색상

### 네비게이션 패턴
- **GoRouter**: 선언적 라우팅
- **Hero 애니메이션**: 화면 전환 효과
- **Bottom Navigation**: 주요 섹션 접근
- **Tab Navigation**: 관련 콘텐츠 그룹화

## 🧪 테스트 전략

### Widget 테스트

**테스트 전략**:
- Widget 테스트로 UI 컴포넌트 검증
- Mock Provider 사용으로 의존성 격리
- Golden 테스트로 시각적 회귀 방지

**주요 테스트 케이스**:
- 프로필 정보 표시 확인
- 탭 네비게이션 동작 검증
- 로딩 상태 표시 확인
- 빈 프로필 상태 처리
- 온보딩 플로우 진행 테스트

**Mock 객체**:
- MockProfileProvider
- MockOnboardingProvider
- MockFriendsProvider

**검증 항목**:
- UI 요소 존재 여부
- 텍스트 콘텐츠 정확성
- 이벤트 핸들링
- 네비게이션 동작

## ✅ 체크리스트

### 구현 완료
- [ ] ProfilePageWidget
- [ ] ProfileEditWidget
- [ ] UserInfoWidget
- [ ] OnboardingFlowWidget
- [ ] SettingsWidget
- [ ] PremiumWidget

### 구현 예정
- [ ] ProfileSearchWidget
- [ ] AchievementsWidget
- [ ] ProfileShareWidget

## 📚 참고 자료

- [Flutter Layout](https://flutter.dev/docs/development/ui/layout)
- [Material Design](https://material.io/design)
- [GoRouter](https://pub.dev/packages/go_router)

---

*이 문서는 Feature-First Architecture의 Profile 기능 화면 가이드입니다.*
*최종 업데이트: 2025-08-25*