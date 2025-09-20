# Feature Specification: Auth Feature Clean Architecture Migration

**Feature Branch**: `001-users-g-black`
**Created**: 2025-01-19
**Updated**: 2025-01-20
**Status**: Revised - Voting 피처 참조 모델 추가
**Reference Model**: `/lib/features/voting` - 기존 성공 구조 참조
**Input**: User description: "auth 피처를 Clean Architecture v4.0 Direct Migration 전략으로 마이그레이션"

## Execution Flow (main)
```
1. Parse user description from Input
   ✓ Auth feature migration to Clean Architecture identified
2. Extract key concepts from description
   ✓ Feature: Auth, Action: Migration, Standard: Clean Architecture v4.0
3. For each unclear aspect:
   ✓ All aspects clear based on ARCHITECTURE_RULES.md and voting feature
4. Fill User Scenarios & Testing section
   ✓ Migration workflow defined with sub-agent orchestration
5. Generate Functional Requirements
   ✓ Each requirement maps to migration step
6. Identify Key Entities
   ✓ Auth domain models and repository patterns identified
7. Run Review Checklist
   ✓ No implementation details, focused on migration goals
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT needs migration and WHY (Clean Architecture compliance)
- ✅ Sub-agent orchestration for systematic migration
- ✅ Direct Migration v4.0 - no Facade patterns
- ✅ Voting feature as reference model for structure

---

## User Scenarios & Testing

### Primary User Story
사용자가 auth 피처를 Clean Architecture로 마이그레이션하여 테스트 가능하고 유지보수 가능한 구조를 만듭니다. voting 피처의 성공적인 구조를 참조하여 동일한 패턴을 적용합니다.

### Acceptance Scenarios
1. **Given** auth 피처가 현재 Clean Architecture 위반 상태, **When** 마이그레이션을 실행, **Then** 3계층 구조(presentation/domain/data)가 완성됨
2. **Given** voting 피처의 DI/Ports 구조, **When** auth에 동일 패턴 적용, **Then** 일관된 아키텍처 달성
3. **Given** 앱 빌드 에러로 통합 테스트 불가, **When** 격리 테스트 전략 적용, **Then** Mock 기반 단위 테스트로 80% 커버리지 달성
4. **Given** 기존 Firebase 의존성, **When** Ports 패턴으로 격리, **Then** 외부 서비스 경계 명확화
5. **Given** 마이그레이션 완료, **When** 모든 테스트 실행, **Then** 격리 환경에서 모든 테스트 통과

### Edge Cases
- 마이그레이션 중 외부 의존성 발견 시 Mock 생성 필요
- 기존 코드와 호환성 유지를 위한 점진적 마이그레이션
- Firebase 서비스 없이도 비즈니스 로직 테스트 가능

## Requirements

### Functional Requirements
- **FR-001**: 시스템은 auth 피처를 3계층 Clean Architecture로 구조화해야 함 (presentation/domain/data)
- **FR-002**: 시스템은 모든 비즈니스 로직을 단일 UseCase 파일로 분리해야 함 (1 UseCase = 1 파일)
- **FR-003**: 시스템은 Repository 인터페이스를 domain 계층에, 구현체를 data 계층에 배치해야 함
- **FR-004**: 시스템은 Firebase 의존성을 data/adapters로 격리해야 함
- **FR-005**: 시스템은 DI 설정을 중앙화해야 함 (voting/di/voting_di_module.dart 참조)
- **FR-006**: 시스템은 DataSource를 local/remote로 계층화해야 함 (voting 구조 참조)
- **FR-007**: 시스템은 외부 서비스를 Ports 패턴으로 추상화해야 함 (domain/ports/)
- **FR-008**: 시스템은 모든 import 규칙을 준수해야 함 (cross-feature, reverse dependency 금지)
- **FR-009**: 시스템은 각 UseCase에 대한 단위 테스트를 제공해야 함 (80%+ coverage)
- **FR-010**: 시스템은 마이그레이션 완료 후 모든 의존성 체크를 통과해야 함

### Migration Requirements
- **MR-001**: 마이그레이션은 순차적 sub-agent 체인을 따라야 함 (InventoryScout → RepoMover → StructWeaver → DIBinder → ImportGuardian → BuildSentinel)
- **MR-002**: 각 단계별 dry-run 모드로 변경 사항 검증해야 함
- **MR-003**: voting 피처 구조를 참조 모델로 사용해야 함
- **MR-004**: 격리 테스트 전략으로 앱 빌드 없이 검증 가능해야 함
- **MR-005**: 모든 단계는 rollback 가능해야 함

### Key Entities
- **User**: 사용자 인증 정보 (uid, email, displayName, photoUrl, authProvider)
- **AuthState**: 인증 상태 (authenticated, unauthenticated, loading)
- **AuthToken**: 인증 토큰 정보 (accessToken, refreshToken, expirationTime)
- **AuthProvider**: 인증 제공자 정보 (Google, Apple, Email, Phone, GitHub, Anonymous)
- **UserSession**: 세션 정보 (sessionId, createdAt, lastActivityAt)

---

## Sub-agent Orchestration Plan (Based on Voting Feature Success)

### Phase 1: Discovery & Analysis
```yaml
agent: inventory-scout
purpose: "Compare auth with voting feature structure and identify gaps"
reference: "/lib/features/voting"
command: |
  /spawn inventory-scout "--feature auth --depth 5 --scope lib/ --line-threshold 300"
expected_output:
  - reports/inventory_auth.json      # 전체 auth 관련 파일 맵핑
  - reports/tree_lib.txt              # 디렉토리 구조 트리
  - reports/candidates_decompose.txt # 분해 대상 파일 (>300줄)
  - reports/violations.txt           # Clean Architecture 위반
  - reports/00_inventory.yml         # 마이그레이션 베이스라인
decision_point: |
  - candidates_decompose.txt 확인 → auth_util.dart (1378줄) 발견 시 Phase 3 진행
  - violations.txt 확인 → 36개 외부 의존성 발견 시 Phase 5 필수
success_criteria: |
  - 모든 auth 관련 파일 식별 완료
  - voting 피처와 구조 차이 문서화
```

### Phase 2: Repository Migration
```yaml
agent: repo-mover
purpose: "Repository 구조를 Clean Architecture로 이동"
commands:
  - /spawn repo-mover "--feature auth --mode dry-run --include repositories,adapters,firebase"
  - # Review: reports/plan_auth.md
  - /spawn repo-mover "--feature auth --mode apply --include repositories,adapters"
expected_output:
  dry_run:
    - reports/plan_auth.md           # 이동 계획서
    - logs/dry_run_auth.log          # 시뮬레이션 로그
  apply:
    - logs/move_auth.log              # 실제 이동 로그
    - Git history 보존된 파일 이동
expected_changes:
  - lib/backend/auth/auth_util.dart → lib/features/auth/data/adapters/
  - lib/backend/firebase/firebase_auth_manager.dart → lib/features/auth/data/adapters/
  - lib/backend/auth/auth_manager.dart → lib/features/auth/data/datasources/remote/firebase/
decision_point: |
  - dry-run 결과 검토 → 의도하지 않은 이동 없는지 확인
  - Git history 보존 확인 → apply 진행
rollback_strategy: |
  - git reset --hard HEAD^ (이동 취소)
  - 수동 이동으로 전환
```

### Phase 3: Structure Decomposition
```yaml
agent: struct-weaver
purpose: "대형 파일 분해 및 UseCase 생성"
commands:
  - /spawn struct-weaver "--task mapper --mode detect --bridge false --source lib/features/auth/data/adapters/auth_util.dart"
  - # Review: patches/struct_weaver_auth_util.diff
  - /spawn struct-weaver "--task mapper --mode apply --bridge false"
expected_output:
  detect:
    - patches/struct_weaver_auth_util.diff  # 분해 패치 (미적용)
    - reports/struct_weaver_auth_util.yml   # 분해 계획
  apply:
    - lib/features/auth/domain/usecases/*.dart (25개 파일)
    - 원본 파일에 @Deprecated 태그 (bridge false로 재내보내기 없음)
expected_results:
  - auth_util.dart (1378 lines) → 25개 individual UseCases
  - 각 UseCase 30-80 lines (단일 책임 원칙)
  - 1 UseCase = 1 File = 1 Business Rule
validation: |
  ls -la lib/features/auth/domain/usecases/*.dart | wc -l
  # Expected: 25+
critical_flag: "--bridge false"
  # Direct Migration v4.0 필수 - Facade/재내보내기 생성 방지
```

### Phase 4: DI Configuration
```yaml
agent: di-binder
purpose: "의존성 주입 설정 (voting_di_module 참조)"
reference: "/lib/features/voting/di/voting_di_module.dart"
commands:
  - /spawn di-binder "--feature auth --pattern voting --mode detect"
  - # Review: reports/di_auth_analysis.yml
  - /spawn di-binder "--feature auth --pattern voting --mode apply"
expected_output:
  detect:
    - reports/di_auth_analysis.yml    # DI 구조 분석
    - voting 패턴과 비교 결과
  apply:
    - lib/features/auth/di/auth_di_module.dart  # DI 모듈 생성
    - app/di.dart 업데이트 (registerAuthModule 추가)
di_structure:
  - Ports registration (IAuthService, ITokenService, ISessionService)
  - Repository bindings (IAuthRepository → AuthRepositoryImpl)
  - UseCase registrations (25개 모든 UseCases)
  - DataSource registrations (local/remote)
validation: |
  grep "registerAuthModule" app/di.dart
  # Expected: AuthDIModule.configureDependencies(getIt);
```

### Phase 5: Import Validation
```yaml
agent: import-guardian
purpose: "import 규칙 검증 및 수정"
commands:
  - /spawn import-guardian "--scope auth --mode detect"
  - # Review: reports/import_violations_auth.txt
  - /spawn import-guardian "--scope auth --mode fix --apply false"
  - # Review: patches/import_guardian_fix.diff
  - git apply patches/import_guardian_fix.diff
expected_output:
  detect:
    - reports/import_violations_auth.txt  # 위반 목록 (예상: 36개 파일)
  fix:
    - patches/import_guardian_fix.diff    # import 수정 패치
expected_result:
  - 0 import violations (최종)
  - No cross-feature imports
  - No reverse dependencies (presentation → data 금지)
  - 36개 외부 파일 모두 새 경로 사용
critical_imports_to_fix:
  - lib/backend/auth → lib/features/auth/domain/usecases
  - FFAppState.auth → 제거 또는 AuthProvider 사용
  - firebase_auth 직접 import → Port 인터페이스 사용
```

### Phase 6: Quality Gates
```yaml
agent: build-sentinel
purpose: "품질 검증 및 테스트 실행"
commands:
  - /spawn build-sentinel "quick --feature auth"
  - # Review: reports/build_quick_auth.txt
  - /spawn build-sentinel "full --feature auth --isolated"
  - # Review: reports/build_full_auth.txt
expected_output:
  quick:
    - reports/build_quick_auth.txt    # 빠른 검증 결과
    - flutter analyze 결과
    - 기본 테스트 통과 여부
  full:
    - reports/build_full_auth.txt     # 전체 검증 결과
    - coverage/lcov.info               # 테스트 커버리지
    - 격리 테스트 실행 로그
expected_status:
  - flutter analyze: 0 issues
  - flutter test: 80%+ coverage (Business logic 90%+)
  - Isolated tests pass without app build
  - No Firebase service calls during tests
final_validation: |
  cat reports/build_full_auth.txt | grep "Coverage:"
  # Expected: 80%+ overall, 90%+ business logic
success_gate: |
  - All sub-agent phases completed
  - Test coverage target achieved
  - Zero import violations
  - Ready for production merge
```

---

## Voting Feature Reference Structure

### 성공적인 voting 피처 구조 (참조 모델)
```
lib/features/voting/
├── di/
│   └── voting_di_module.dart      # GetIt 의존성 주입 설정
├── domain/
│   ├── models/                    # 도메인 모델
│   ├── repositories/               # Repository 인터페이스
│   ├── ports/                      # 외부 서비스 인터페이스
│   └── usecases/                   # 비즈니스 로직 (1 file per UseCase)
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── services/          # 로컬 캐시 서비스
│   │   │   └── utils/             # 헬퍼 함수
│   │   └── remote/
│   │       ├── firebase/          # Firebase 통합
│   │       └── api/               # 외부 API
│   ├── repositories/               # Repository 구현체
│   └── adapters/                   # 외부 서비스 어댑터
└── presentation/
    ├── screens/                    # UI 스크린
    ├── widgets/                    # UI 컴포넌트
    └── providers/                  # 상태 관리
```

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified
- [x] Voting feature reference model specified

---

## Execution Status

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed
- [x] Voting feature reference integrated
- [x] Sub-agent orchestration plan updated

---