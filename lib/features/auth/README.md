# 🔐 Auth Feature - Clean Architecture 마이그레이션 가이드

> **최종 업데이트**: 2025-01-20
> **버전**: 1.0.0 (Migration In Progress)
> **준수율**: Domain 70% | Data 60% | Presentation 40%
> **참조 모델**: Voting Feature (100% 완료)

## 📋 개요

Auth Feature는 Versus Space 앱의 인증 시스템을 담당합니다. 현재 Clean Architecture로 마이그레이션 진행 중이며, Voting Feature의 성공 사례를 참조 모델로 사용하고 있습니다.

### 🎯 핵심 특징
- 🔄 **마이그레이션 진행 중**: Clean Architecture v4.0 Direct Migration
- 📊 **다중 인증 방식**: Email, Google, Apple, Phone, GitHub, Anonymous
- 🔐 **Firebase Auth**: Firebase Authentication 통합
- 👤 **프로필 연동**: UserProfile과 통합
- 📱 **Phone Auth**: SMS OTP 인증 지원

### ⚠️ 현재 주요 문제점
- **Critical 위반**: 7개 Presentation → Data 직접 임포트
- **대형 파일**: 9개 (LoginPageWidget 1,378줄 등)
- **복합 책임**: UI와 비즈니스 로직 혼재
- **Feature 간 의존**: Profile 도메인 직접 참조

## 🏗️ 현재 디렉토리 구조

```
lib/features/auth/
│
├── 📁 domain/                          # 🧠 도메인 레이어 (부분 구현)
│   ├── 📁 models/
│   │   └── auth_user.dart              # 인증 사용자 모델
│   ├── 📁 repositories/
│   │   └── i_auth_repository.dart      # Repository 인터페이스
│   ├── 📁 services/
│   │   └── i_auth_service.dart         # 서비스 인터페이스
│   └── 📁 usecases/
│       └── auth_state_usecase.dart     # 상태 관리 UseCase (단일)
│
├── 📁 data/                            # 💾 데이터 레이어 (부분 마이그레이션)
│   ├── 📁 adapters/                    # Firebase 어댑터들
│   │   ├── auth_util.dart              # 🔴 레거시 유틸리티 (1,378줄)
│   │   ├── firebase_auth_manager.dart  # Auth 매니저 (364줄)
│   │   ├── auth_manager.dart           # 기본 Auth 매니저
│   │   ├── base_auth_user_provider.dart
│   │   ├── firebase_user_provider.dart
│   │   ├── email_auth.dart             # Email 인증
│   │   ├── google_auth.dart            # Google 인증
│   │   ├── apple_auth.dart             # Apple 인증
│   │   ├── github_auth.dart            # GitHub 인증
│   │   ├── anonymous_auth.dart         # 익명 인증
│   │   └── jwt_token_auth.dart         # JWT 토큰 인증
│   ├── 📁 repositories/
│   │   └── auth_repository_impl.dart   # Repository 구현
│   └── 📁 exports/
│       └── auth_models.dart            # 모델 export
│
└── 📁 presentation/                    # 🎨 프레젠테이션 레이어 (리팩토링 필요)
    └── 📁 screens/                     # 🔴 대형 파일들
        ├── login_page_widget.dart      # 🔴 1,378줄 (초대형)
        ├── create_account_widget.dart  # 🔴 883줄 (대형)
        ├── phonelogeinpincode_widget.dart # 🔴 701줄 (대형)
        ├── start_page_widget.dart      # 🔴 586줄 (대형)
        ├── phone_creat_account_widget.dart # 🔴 500줄 (대형)
        ├── popup_timer_email_widget.dart   # 432줄
        ├── forgot_password_widget.dart     # 355줄
        └── confirm_email_widget.dart   # 기타 화면들
```

## 📊 마이그레이션 현황

### 아키텍처 준수율

```
Domain:       70% ████████████████████████████████░░░░░░░░░░░░░ 🟡 진행 중
Data:         60% ████████████████████████████░░░░░░░░░░░░░░░░░░ 🟡 진행 중
Presentation: 40% ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░ 🔴 개선 필요
전체:         57% ███████████████████████████░░░░░░░░░░░░░░░░░░░ 🟡 진행 중
```

### 주요 위반 사항

| 문제 유형 | 건수 | 긴급도 | 상태 |
|-----------|-----|--------|------|
| Presentation → Data 직접 임포트 | 7 | 🔴 Critical | 대기 |
| 대형 파일 (>300줄) | 9 | 🟡 High | 대기 |
| 복합 책임 파일 | 5 | 🟡 High | 대기 |
| Feature 간 의존 | 2 | 🟠 Medium | 대기 |
| UseCase 부족 | 20+ | 🟡 High | 대기 |

## 🎯 마이그레이션 목표

### Phase 1: 분석 및 계획 ✅ 완료
- Inventory Scout로 현재 상태 파악
- 위반 사항 및 개선점 도출
- 마이그레이션 전략 수립

### Phase 2: UseCase 레이어 구축 🔄 진행 예정
- 대형 파일 분해 (CodeSurgeon 활용)
- 20+ UseCase 생성
- 비즈니스 로직 Domain으로 이동

### Phase 3: Repository 패턴 완성 🔄 진행 예정
- DataSource 인터페이스 정의
- Local/Remote DataSource 분리
- Repository 구현 완료

### Phase 4: Presentation 리팩토링 🔄 진행 예정
- 대형 위젯 컴포넌트 분해
- Provider 패턴 적용
- Clean Architecture 준수

### Phase 5: DI 및 통합 🔄 진행 예정
- GetIt DI 설정
- App 레이어 통합
- 라우터 설정

### Phase 6: 검증 및 완료 🔄 진행 예정
- 모든 테스트 통과
- 0 위반 달성
- 문서 업데이트

## 🚀 서브에이전트 활용 계획

```bash
# 현재 상태 분석 (완료)
/spawn inventory-scout "auth 피처 depth 5 스캔"

# UseCase 생성 (예정)
/spawn code-surgeon "--file login_page_widget.dart --strategy extract-usecases"
/spawn struct-weaver "--task mapper --bridge false"

# Repository 이동 (예정)
/spawn repo-mover "--feature auth --mode dry-run"

# DI 설정 (예정)
/spawn di-binder "--feature auth --mode detect"

# Import 수정 (예정)
/spawn import-guardian "--scope auth --mode fix"

# 최종 검증 (예정)
/spawn build-sentinel "full"
```

## 📈 예상 결과

### 마이그레이션 완료 후
- ✅ **100% Clean Architecture 준수**
- ✅ **모든 위반 사항 해결**
- ✅ **파일 크기 300줄 이하**
- ✅ **완전한 레이어 분리**
- ✅ **테스트 가능한 구조**

### 예상 구조 (Voting Feature 참조)
```
auth/
├── domain/
│   └── usecases/        # 20+ UseCase 파일
├── data/
│   ├── datasources/     # Local/Remote 분리
│   └── repositories/    # 완전한 구현
└── presentation/
    ├── providers/       # 상태 관리
    └── widgets/         # 작은 컴포넌트
```

## 🔗 관련 문서

- [MASTER_MIGRATION_GUIDE.md](./MASTER_MIGRATION_GUIDE.md) - 상세 마이그레이션 가이드
- [APP_LAYER_INTEGRATION.md](./APP_LAYER_INTEGRATION.md) - App 레이어 통합
- [ARCHITECTURE_RULES.md](/lib/ARCHITECTURE_RULES.md) - 아키텍처 규칙
- [Voting Feature README](../voting/README.md) - 참조 모델

## 📌 참고 사항

이 Feature는 현재 활발한 마이그레이션 중입니다. Voting Feature의 성공 사례를 참조하여 동일한 품질 수준을 달성할 예정입니다.

**마이그레이션 원칙:**
- 🎯 기존 코드 재사용 (새로 만들지 않기)
- 🎯 Direct Migration (Facade 없이)
- 🎯 원자적 커밋 (Feature 단위)
- 🎯 100% 테스트 커버리지