# 📦 Auth Provider Layer - 인증 상태 관리 계층

> Feature-First Architecture의 Presentation Layer 중 상태 관리 구현

## 📋 개요

이 디렉토리는 인증 기능의 **Provider Layer**를 담당합니다. Provider 패턴을 사용하여 인증 상태를 관리하고, UI와 비즈니스 로직 간의 반응형 연결을 제공합니다.

### 🎯 목적
- **상태 관리**: 인증 관련 모든 상태의 중앙 집중식 관리
- **반응형 UI**: ChangeNotifier를 통한 자동 UI 업데이트
- **세션 관리**: 사용자 세션 및 인증 상태 추적
- **캐시 관리**: 사용자 정보 및 토큰 캐싱

## 🏗️ 아키텍처 구조

```
presentation/providers/
├── auth_provider.dart                 # 메인 인증 상태 관리
├── firebase_user_provider.dart        # Firebase 사용자 상태
├── base_auth_provider.dart           # 기본 인증 인터페이스
├── session_provider.dart             # 세션 관리
├── biometric_auth_provider.dart     # 생체 인증 상태
└── onboarding_provider.dart         # 온보딩 프로세스 상태
```

## 📂 파일 상세 설명

### 1. auth_provider.dart (메인 인증 Provider)

**책임**: 전체 인증 상태 관리 및 UseCase 조정

**주요 상태**:
- `AuthStatus`: initial, loading, authenticated, unauthenticated, error
- `UserModel? user`: 현재 로그인된 사용자 정보
- `String? errorMessage`: 에러 메시지
- `bool isEmailVerified`: 이메일 인증 여부
- `bool rememberMe`: 자동 로그인 설정
- `DateTime? sessionExpiry`: 세션 만료 시간

**핵심 메서드**:
- `signInWithEmail()`: 이메일 로그인 처리
- `signInWithGoogle()`: Google OAuth 로그인
- `signInWithApple()`: Apple Sign In
- `signUp()`: 회원가입 처리
- `signOut()`: 로그아웃 및 세션 정리
- `refreshUserInfo()`: 사용자 정보 갱신

**계산된 속성**:
- `isSessionValid`: 세션 유효성 확인
- `userLevel`: 포인트 기반 레벨 계산 (1-5)

### 2. firebase_user_provider.dart (Firebase 사용자 Provider)

**책임**: Firebase Auth 사용자 상태 관리

**주요 기능**:
- Firebase Auth 상태 리스너 관리
- 사용자 정보 새로고침
- 이메일 인증 재발송
- 프로필 업데이트 (displayName, photoURL)
- ID 토큰 및 Custom Claims 관리
- 계정 삭제 처리

**Stream 관리**:
- RxDart의 BehaviorSubject 사용
- authStateChanges 스트림 제공

### 3. session_provider.dart (세션 관리 Provider)

**책임**: 사용자 세션 및 토큰 관리

**세션 설정**:
- `sessionDuration`: 24시간
- `inactivityTimeout`: 30분
- `warningBefore`: 만료 5분 전 경고

**주요 기능**:
- 세션 시작/종료 관리
- 활동 기반 세션 연장
- 세션 만료 타이머 관리
- 비활성 타임아웃 체크
- 세션 만료 경고 표시

### 4. biometric_auth_provider.dart (생체 인증 Provider)

**책임**: 생체 인증 상태 및 설정 관리

**지원 생체 인증**:
- Face ID (iOS)
- Touch ID (iOS)
- 지문 인증 (Android)

**주요 기능**:
- 생체 인증 가능 여부 확인
- 생체 인증 활성화/비활성화
- 생체 인증 수행
- 설정 저장 및 로드

## 🔄 상태 관리 플로우

### Provider 초기화 플로우
1. 앱 시작 → Provider 초기화
2. 캐시된 사용자 정보 확인
3. 있으면 → 캐시된 사용자 로드 → 인증 상태
4. 없으면 → 자동 로그인 확인
5. 활성화 → 토큰으로 로그인 → 인증 상태
6. 비활성화 → 미인증 상태 → 로그인 화면

### 인증 상태 변경 플로우
1. 사용자 액션 → Provider 메서드 호출
2. UseCase 실행
3. 성공 → 상태 업데이트 → notifyListeners() → UI 자동 업데이트
4. 실패 → 에러 상태 설정 → notifyListeners() → 에러 표시

## 🧪 테스트 전략

### Provider 단위 테스트
- AuthProvider 테스트: 로그인, 회원가입, 로그아웃
- SessionProvider 테스트: 세션 타이머, 만료 처리
- BiometricAuthProvider 테스트: 생체 인증 플로우

## 📊 성능 최적화

1. **상태 업데이트 최적화**
   - 불필요한 notifyListeners() 호출 최소화
   - 배치 업데이트 처리
   - Selective 리빌드 구현

2. **메모리 관리**
   - 미사용 Provider 자동 dispose
   - 스트림 구독 정리
   - 캐시 크기 제한

3. **비동기 처리**
   - Future.wait으로 병렬 처리
   - 백그라운드 작업 분리
   - 지연 로딩 구현

## 🔐 보안 고려사항

1. **토큰 관리**
   - 메모리에만 토큰 저장
   - 자동 토큰 갱신
   - 만료 시 자동 로그아웃

2. **세션 보안**
   - 비활성 타임아웃
   - 세션 하이재킹 방지
   - CSRF 토큰 구현

3. **생체 인증**
   - 안전한 키 저장
   - 폴백 메커니즘
   - 재시도 제한

## 🚀 마이그레이션 가이드

### 현재 코드에서 이동할 파일들

| 현재 위치 | 대상 위치 | 설명 |
|----------|----------|------|
| `/lib/auth/firebase_auth/firebase_user_provider.dart` | `firebase_user_provider.dart` | Firebase 사용자 Provider |
| `/lib/auth/base_auth_user_provider.dart` | `base_auth_provider.dart` | 기본 인증 인터페이스 |
| `/lib/auth/auth_manager.dart` 내 상태 | `auth_provider.dart` | 인증 상태 관리 로직 |
| `/lib/providers/navigation_provider.dart` | 유지 | 네비게이션은 별도 관리 |

### 마이그레이션 단계

1. **Provider 생성** (1시간)
   - 기본 Provider 클래스 생성
   - 상태 변수 정의
   - 메서드 구현

2. **UseCase 연결** (30분)
   - UseCase 의존성 주입
   - 에러 처리 구현
   - 결과 매핑

3. **UI 연결** (1시간)
   - Consumer 위젯 적용
   - Provider.of 사용
   - 상태 기반 UI 업데이트

4. **테스트 작성** (1시간)
   - Provider 테스트
   - 통합 테스트
   - UI 테스트

## 📋 체크리스트

### 구현 완료도
- [ ] `auth_provider.dart` 메인 인증 Provider
- [ ] `firebase_user_provider.dart` Firebase 사용자 상태
- [ ] `base_auth_provider.dart` 기본 인터페이스
- [ ] `session_provider.dart` 세션 관리
- [ ] `biometric_auth_provider.dart` 생체 인증
- [ ] `onboarding_provider.dart` 온보딩 상태
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성
- [ ] 문서화 완료

### 마이그레이션 체크포인트
- [ ] 기존 상태 관리 코드 분석
- [ ] Provider 구조 설계
- [ ] UseCase 연결 계획
- [ ] UI 업데이트 전략
- [ ] 테스트 계획 수립

## 🔗 관련 문서

- [Auth Feature 전체 마이그레이션 가이드](../../MIGRATION_AUTH.md)
- [Domain Layer - UseCases](../../domain/usecases/README.md)
- [Domain Layer - Models](../../domain/models/README.md)
- [Data Layer - Repository](../../data/repositories/README.md)
- [Presentation Layer - Screens](../screens/README.md)

---

*이 문서는 Feature-First Architecture의 Auth Provider Layer 구현 가이드입니다.*
*작성일: 2025-08-24*
*버전: 1.0*