# 🎨 /lib/features/profile/presentation/providers

> Feature-First Architecture - Profile Provider 계층

## 📋 개요

프로필 기능의 **State Management Layer**를 담당하는 디렉토리입니다. Provider 패턴을 사용하여 프로필 관련 상태를 관리하고 UI와 비즈니스 로직을 연결합니다.

### 🎯 목적
- **상태 관리**: 프로필 관련 전역 및 로컬 상태 관리
- **반응형 UI**: 상태 변경에 따른 자동 UI 업데이트
- **비즈니스 로직 분리**: UI와 비즈니스 로직의 명확한 분리
- **테스트 용이성**: 독립적으로 테스트 가능한 상태 관리

## 🏗️ 디렉토리 구조

```
providers/
├── profile_provider.dart        # 프로필 메인 상태 관리
├── settings_provider.dart       # 설정 상태 관리
├── onboarding_provider.dart     # 온보딩 플로우 상태
├── character_provider.dart      # 캐릭터 선택 상태
├── interest_provider.dart       # 관심사 선택 상태
├── friends_provider.dart        # 친구 목록 상태
└── premium_provider.dart        # 프리미엄 상태
```

## 📂 주요 Provider 구현

### ProfileProvider

**역할**: 프로필 메인 상태 관리

**주요 기능**:
- 현재 사용자 프로필 로드 및 캐싱
- 다른 사용자 프로필 보기
- 프로필 업데이트 (displayName, bio, 관심사 등)
- 아바타 이미지 업로드 및 진행률 추적
- 프로필 통계 관리

**의존성**:
- GetProfileUseCase
- UpdateProfileUseCase
- UploadAvatarUseCase
- UserCacheService

**관리하는 상태**:
- currentProfile: 현재 사용자 프로필
- viewingProfile: 보고 있는 다른 사용자 프로필
- isLoading: 로딩 상태
- isUpdating: 업데이트 중 상태
- errorMessage: 에러 메시지
- profileStats: 프로필 통계
- uploadProgress: 업로드 진행률
- isUploadingAvatar: 아바타 업로드 중 상태

**주요 메서드**:
- initialize(): 초기화
- loadCurrentUserProfile(): 현재 사용자 프로필 로드
- viewUserProfile(): 다른 사용자 프로필 보기
- updateProfile(): 프로필 정보 업데이트
- uploadAvatar(): 아바타 이미지 업로드
- loadProfileStats(): 프로필 통계 로드
- refresh(): 프로필 리프레시
- reset(): 상태 초기화

### OnboardingProvider

**역할**: 온보딩 플로우 상태 관리

**주요 기능**:
- 온보딩 상태 조회 및 추적
- 단계별 데이터 임시 저장
- 나이 검증 (13세 이상)
- 직업/관심사/취미 선택 관리
- 캐릭터 선택 및 프로필 설정
- 온보딩 건너뛰기 기능

**의존성**:
- CompleteOnboardingStepUseCase
- SkipOnboardingUseCase
- GetOnboardingStateUseCase

**관리하는 상태**:
- state: 현재 온보딩 상태
- isLoading: 로딩 상태
- errorMessage: 에러 메시지
- progressPercentage: 진행률
- currentStep: 현재 단계
- birthYear: 선택된 출생년도
- selectedJobCategory: 선택된 직업 카테고리
- selectedJobName: 선택된 직업명
- selectedExpertise: 선택된 전문분야 (최대 4개)
- selectedHobbies: 선택된 취미 (최대 8개)
- selectedCharacterId: 선택된 캐릭터 ID

**주요 메서드**:
- initialize(): 온보딩 상태 초기화
- verifyAge(): 나이 검증
- selectJob(): 직업 선택
- toggleExpertise(): 전문분야 토글
- saveExpertise(): 전문분야 저장
- toggleHobby(): 취미 토글
- saveHobbies(): 취미 저장
- selectCharacter(): 캐릭터 선택
- completeProfileSetup(): 프로필 설정 완료
- skipOnboarding(): 온보딩 건너뛰기
- goToPreviousStep(): 이전 단계로
- reset(): 상태 초기화

### SettingsProvider

**역할**: 설정 상태 관리 Provider

**주요 기능**:
- 언어 설정 변경 및 저장
- 테마 모드 관리 (라이트/다크/시스템)
- 알림 설정 토글
- 자동 로그인 설정
- 생체 인증 설정
- 로컬 설정 저장

**의존성**:
- ChangeSettingsUseCase
- ChangeLanguageUseCase
- ToggleNotificationsUseCase
- SharedPreferences/Hive (로컬 저장)

**관리하는 상태**:
- settings: SettingsModel 인스턴스
- isLoading: 설정 로딩 상태
- isSaving: 설정 저장 중 상태
- errorMessage: 에러 메시지
- language: 현재 언어 설정
- themeMode: 테마 모드
- notificationsEnabled: 알림 활성화 여부
- autoLogin: 자동 로그인 여부
- biometricEnabled: 생체 인증 사용 여부

**주요 메서드**:
- initialize(): 초기 설정 로드
- loadSettings(): 설정 불러오기
- changeLanguage(languageCode): 언어 변경
- changeTheme(theme): 테마 변경
- toggleNotifications(enabled): 알림 토글
- setAutoLogin(enabled): 자동 로그인 설정
- setBiometricAuth(enabled): 생체 인증 설정

## 🔄 Provider 통합

**Provider 통합 설정**:
- ProfileProviderConfig 클래스로 중앙 관리
- getProviders() 메서드로 모든 Provider 리스트 반환
- GetIt을 통한 의존성 주입
- initialize() 호출로 초기화 수행

**등록되는 Provider**:
- ProfileProvider (초기화 필요)
- OnboardingProvider
- SettingsProvider (초기화 필요)
- CharacterProvider
- InterestProvider
- FriendsProvider
- PremiumProvider

**사용 방법**:
- MyApp 최상위에서 MultiProvider 설정
- ProfileProviderConfig.getProviders() 호출
- 하위 위젯에서 context.watch/read 사용

## 🧪 테스트 전략

### Provider 테스트

**테스트 구조**:
- 각 Provider별 독립적인 테스트 그룹
- Mock 객체를 사용한 의존성 격리
- setUp/tearDown으로 테스트 환경 관리

**주요 테스트 케이스**:
- 프로필 로드 성공 시나리오
- 프로필 로드 실패 처리
- 프로필 업데이트 검증
- 상태 변경 알림 확인
- 에러 메시지 처리
- 로딩 상태 관리

**Mock 객체**:
- MockGetProfileUseCase
- MockUpdateProfileUseCase
- MockUploadAvatarUseCase
- MockUserCacheService

**검증 항목**:
- 상태 값 정확성
- 에러 처리 적절성
- notifyListeners 호출 여부
- 비동기 작업 완료 확인

## ✅ 체크리스트

### 구현 완료
- [ ] ProfileProvider
- [ ] OnboardingProvider
- [ ] SettingsProvider
- [ ] CharacterProvider
- [ ] InterestProvider
- [ ] FriendsProvider
- [ ] PremiumProvider

### 구현 예정
- [ ] ProfileSearchProvider
- [ ] ProfileStatsProvider
- [ ] AchievementProvider

## 📚 참고 자료

- [Provider Documentation](https://pub.dev/packages/provider)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [ChangeNotifier Pattern](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)

---

*이 문서는 Feature-First Architecture의 Profile 기능 Provider 가이드입니다.*
*최종 업데이트: 2025-08-25*