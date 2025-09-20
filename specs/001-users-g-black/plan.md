# Implementation Plan: Auth Feature Clean Architecture Migration (격리 테스트 전략)

**Branch**: `001-users-g-black` | **Date**: 2025-01-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-users-g-black/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   ✓ Auth migration spec loaded successfully
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   ✓ Flutter/Dart with Firebase backend identified
   ✓ 격리 테스트 전략 필수 (앱 빌드 에러)
3. Fill the Constitution Check section
   ✓ 14 principles from Constitution v2.0.0 applied
4. Evaluate Constitution Check section
   ✓ All principles aligned with isolation strategy
   ✓ Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   ✓ 격리 전략 및 모킹 설계 완료
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, CLAUDE.md
   ✓ 도메인 모델 완성 (data-model.md)
   → Repository 인터페이스 생성 중 (contracts/)
7. Re-evaluate Constitution Check section
   → Direct Migration without Facade confirmed
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Task generation approach 설계
9. STOP - Ready for /tasks command
```

## Summary
Auth 피처를 Clean Architecture v4.0으로 완전 마이그레이션. 36개 외부 파일이 auth를 import하고 있으며, 1378줄 대형 파일 포함 총 20개 파일 리팩토링 필요. **앱 전체 빌드 불가로 격리된 단위 테스트 전략 채택 - 모킹과 stub을 활용한 개별 컴포넌트 검증**.

## Technical Context
**Language/Version**: Dart 3.0.0+ / Flutter 3.0.0+
**Primary Dependencies**: Firebase Auth, Cloud Firestore, GetIt (DI), Provider, Mockito (for testing)
**Storage**: Firebase Firestore for user data, SharedPreferences for local cache
**Testing**: flutter_test with mockito for isolated unit tests, mocktail for behavior verification
**Target Platform**: iOS 13.0+ / Android API 24+ / Web
**Project Type**: mobile - Flutter app with Firebase backend
**Performance Goals**: Auth operations < 500ms, Token refresh < 200ms, Unit test execution < 100ms
**Constraints**: 현재 앱 전체 빌드 불가, 개별 피처만 독립 테스트 가능
**Scale/Scope**: 20개 auth 파일, 6849 LOC, 36개 외부 의존성, 0% → 80% 테스트 커버리지

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Clean Architecture Principles ✅
- [x] **I. Feature-First Architecture**: auth를 독립적 모듈로 분리, 격리 테스트 가능
- [x] **II. Clean Architecture Compliance**: 3계층 구조 완전 분리
- [x] **III. Direct Migration Strategy v4.0**: Facade 없이 즉시 전환
- [x] **IV. Test-First Development**: 격리된 단위 테스트 우선 작성
- [x] **V. Dependency Rules**: 단방향 의존성, Mock을 통한 경계 분리
- [x] **VI. UseCase Granularity**: 1 UseCase = 1 File = 1 Unit Test
- [x] **VII. Repository Pattern**: Interface와 Mock 구현으로 테스트
- [x] **VIII. Sub-agent Orchestration**: 각 단계별 독립 검증
- [x] **IX. Import Hygiene**: Mock 경계를 통한 의존성 격리
- [x] **X. Quality Gates**: 단위 테스트 통과 후 진행
- [x] **XI. Atomic Commits**: 테스트 통과 코드만 커밋
- [x] **XII. Documentation as Code**: 테스트가 문서 역할
- [x] **XIII. Firebase Schema Integrity**: Mock data로 스키마 검증
- [x] **XIV. Observability & Monitoring**: 테스트 커버리지 추적

## Project Structure

### Documentation (this feature)
```
specs/001-users-g-black/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0: 격리 전략 및 모킹 설계
├── data-model.md        # Phase 1: 테스트용 도메인 모델
├── quickstart.md        # Phase 1: 테스트 실행 가이드
├── contracts/           # Phase 1: Repository interfaces for mocking
│   ├── i_auth_repository.dart
│   └── i_auth_datasource.dart
└── tasks.md             # Phase 2: Task list (/tasks command)
```

### Source Code (repository root) - Based on Voting Feature Structure
```
lib/features/auth/
├── di/
│   └── auth_di_module.dart         # DI configuration (like voting/di/voting_di_module.dart)
├── domain/
│   ├── models/
│   ├── repositories/               # Interfaces for mocking
│   ├── ports/                      # External service interfaces (NEW - from voting)
│   └── usecases/                   # Testable business logic
├── data/
│   ├── datasources/
│   │   ├── local/                  # Local data sources (NEW - from voting)
│   │   │   ├── services/           # Cache services
│   │   │   └── utils/              # Helper functions
│   │   └── remote/                 # Remote data sources (NEW - from voting)
│   │       ├── firebase/           # Firebase integrations
│   │       └── api/                # External API calls
│   ├── repositories/               # Implementations
│   └── adapters/
├── presentation/
└── test/                           # NEW: Feature-level tests
    ├── unit/                       # Isolated unit tests
    │   ├── usecases/              # UseCase tests with mocks
    │   ├── repositories/          # Repository tests with stubs
    │   └── adapters/              # Adapter tests with fakes
    ├── mocks/                     # Shared mock definitions
    │   ├── mock_auth_repository.dart
    │   ├── mock_firebase_auth.dart
    │   └── mock_firestore.dart
    └── fixtures/                   # Test data fixtures
        └── auth_fixtures.dart
```

## Phase 0: Outline & Research ✅

### 1. 격리 전략 연구 (Completed)
```yaml
problem_analysis:
  - 앱 전체 빌드 에러로 인한 통합 테스트 불가
  - Firebase 서비스 실제 연결 불가
  - 36개 외부 의존성 처리 필요

solution_approach:
  - 의존성 주입을 통한 경계 분리
  - 모든 외부 의존성에 대한 Mock 생성
  - 개별 컴포넌트 단위 테스트
  - 실제 Firebase 연결 없이 동작 검증
```

### 2. 모킹 의존성 매핑 (Completed)
```yaml
auth_boundaries:
  external_services:
    - FirebaseAuth → MockFirebaseAuth
    - FirebaseFirestore → MockFirebaseFirestore
    - GoogleSignIn → MockGoogleSignIn
    - AppleSignIn → MockAppleSignIn

  cross_feature:
    - Router → MockRouter
    - UserCache → MockUserCache
    - Analytics → MockAnalytics

  infrastructure:
    - SharedPreferences → MockSharedPreferences
    - NetworkInfo → MockNetworkInfo
```

**Output**: research.md with isolation strategy and mock design ✅

## Phase 1: Design & Contracts (진행중)

### 1. 도메인 모델 for Testing ✅
```dart
// data-model.md 내용
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;

  // 테스트 fixtures로 쉽게 mockable
  factory AuthUser.mock() => AuthUser(
    uid: 'test-uid',
    email: 'test@example.com',
    authProvider: AuthProviderType.email,
    createdAt: DateTime.now(),
  );
}
```

### 2. Ports 패턴 적용 (NEW - from Voting Feature)
```dart
// domain/ports/i_auth_service.dart
abstract class IAuthService {
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<void> signOut();
  Stream<User?> authStateChanges();
}

// domain/ports/i_token_service.dart
abstract class ITokenService {
  Future<String> getAccessToken();
  Future<String> refreshToken();
  bool isTokenExpired();
}

// domain/ports/i_notification_port.dart
abstract class INotificationPort {
  Future<void> sendAuthNotification(String userId, String type);
}
```

### 3. Repository 인터페이스 for Mocking (진행중)
```dart
// contracts/i_auth_repository.dart
abstract class IAuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<Result<AuthUser>> signInWithEmail(String email, String password);
  Future<Result<void>> signOut();
  // Result 타입으로 테스트 가능한 에러 처리
}
```

### 3. Mock 구현 계획
```dart
// test/mocks/mock_auth_repository.dart
class MockAuthRepository extends Mock implements IAuthRepository {
  // Mockito가 stub 메서드 자동 생성
  // 각 테스트에서 반환 값 설정 가능
}
```

### 4. 테스트 시나리오 (quickstart.md)
```yaml
test_execution_guide:
  setup:
    - Firebase emulator 불필요
    - 앱 시작 불필요
    - 테스트 직접 실행: flutter test lib/features/auth/test

  unit_tests:
    - GetCurrentUserUseCase with mock repository
    - SignInUseCase with various mock responses
    - SignOutUseCase with state verification

  coverage_command: |
    flutter test lib/features/auth/test --coverage
    genhtml coverage/lcov.info -o coverage/html

  verification:
    - 각 UseCase에 대응하는 test 파일
    - 모든 에러 케이스를 mock으로 커버
    - 실제 Firebase 호출 없음
```

### 5. CLAUDE.md 업데이트
```markdown
## Testing Strategy - Auth Feature

앱 전체 빌드 에러로 인한 격리 테스트 전략:
- 모든 테스트는 앱 없이 독립 실행
- Firebase 서비스에 대한 완전한 모킹
- 테스트 데이터 fixtures로 일관된 시나리오
- 커버리지 목표: 단위 테스트만으로 80%

Run auth tests:
\`\`\`bash
flutter test lib/features/auth/test/unit
\`\`\`
```

**Output**: data-model.md ✅, contracts/*, quickstart.md, CLAUDE.md

## Phase 2: Task Planning Approach (설계만)

### 격리된 Test-First 개발
```yaml
task_generation_strategy:
  1_setup_mocks:
    - Mock 인프라 생성
    - Test fixtures 정의
    - DI 테스트 설정

  2_write_tests_first:
    - 각 UseCase에 대한 실패하는 단위 테스트 작성
    - Mock을 사용한 기대 동작 정의
    - 실제 서비스와 통합 없음

  3_implement_usecases:
    - 테스트를 통과시킬 정도만 구현
    - 비즈니스 로직에만 집중
    - 의존성은 인터페이스로 주입

  4_verify_isolation:
    - Firebase 없이 테스트 실행
    - 커버리지 메트릭 확인
    - 외부 의존성 없음 확인
```

### 테스트 순서 전략
```yaml
testing_phases:
  phase1_mocks: "모든 Mock 인프라 먼저 생성"
  phase2_unit_tests: "각 UseCase별 테스트 작성"
  phase3_implementation: "테스트 통과를 위한 구현"
  phase4_coverage: "커버리지 갭 추가 테스트"

parallel_execution:
  - Mock 생성은 병렬 가능 [P]
  - Unit 테스트는 병렬 가능 [P]
  - UseCase 구현은 순차적
```

**예상 Output**: 격리 테스트 중심의 40-45 tasks

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 통합 테스트 없음 | 앱이 빌드되지 않음 | 단위 테스트로 80% 신뢰도 확보 가능 |
| Mock 중심 접근 | 실제 서비스 사용 불가 | 앱 안정화까지 격리 필요 |
| Feature 레벨 test 디렉토리 | 비표준 구조 | 중앙 test 폴더 빌드 에러 |

## 검증 전략 (격리된 검증) 🔄

### 📊 수정된 검증 체크포인트

```yaml
original_plan: "전체 앱 실행 검증"
modified_plan: "격리된 컴포넌트별 검증"

validation_checkpoints:
  usecase_creation:
    before: "앱 실행 확인"
    after: "단위 테스트 실행 확인"
    command: "flutter test lib/features/auth/test/unit/usecases/{usecase}_test.dart"

  import_updates:
    before: "전체 테스트 실행"
    after: "영향받는 단위 테스트만 실행"
    command: "flutter test lib/features/auth/test/unit --name '{affected}'"

  legacy_deletion:
    before: "수동 앱 테스트"
    after: "Mock 통합 테스트 실행"
    command: "flutter test lib/features/auth/test/unit --coverage"

  final_validation:
    before: "BuildSentinel 전체 검증"
    after: "격리된 피처 검증 스위트"
    command: |
      flutter analyze lib/features/auth
      flutter test lib/features/auth/test
      lcov --summary coverage/lcov.info
```

### 격리 테스트의 이점
1. **독립 실행**: 다른 피처 에러에 영향 없음
2. **빠른 피드백**: 단위 테스트는 밀리초 단위
3. **명확한 계약**: Mock이 인터페이스 계약 명시
4. **점진적 통합**: 나중에 통합 테스트 추가 가능

## Atomic Commit Strategy 🆕

### Commit Tracking System
```yaml
commit_prefix: "feat(auth): "
commit_strategy: "atomic"
tracking_file: "migration_tracking/commit_log.md"

phase_commits:
  phase_1_mocks:
    - "feat(auth): Add mock infrastructure and test fixtures"
    - "feat(auth): Create domain models with test factories"
    - "feat(auth): Add repository interfaces with Result type"

  phase_2_ports:
    - "feat(auth): Add Ports pattern interfaces"
    - "feat(auth): Create external service abstractions"

  phase_3_usecases:
    - "feat(auth): Add GetCurrentUserUseCase with tests"
    - "feat(auth): Add SignInWithEmailUseCase with tests"
    - "feat(auth): Add SignOutUseCase with tests"
    # ... one commit per UseCase

  phase_4_implementation:
    - "feat(auth): Implement AuthRepositoryImpl"
    - "feat(auth): Add Firebase adapters"
    - "feat(auth): Create datasource implementations"

  phase_5_di:
    - "feat(auth): Add DI module configuration"
    - "feat(auth): Register auth module in app/di.dart"

  phase_6_cleanup:
    - "feat(auth): Remove legacy auth code from backend/"
    - "feat(auth): Update imports to use feature module"
    - "feat(auth): Final validation and cleanup"
```

### Rollback Points
- **Each phase completion** creates a rollback point
- **Git tags** for major milestones: `auth-migration-phase-N`
- **Branch protection**: Work on `feature/auth-clean-architecture`
- **Merge strategy**: Squash merge to main after full validation

### Validation Checkpoints
```bash
# After each commit
flutter analyze lib/features/auth
flutter test lib/features/auth/test

# After each phase
flutter test --coverage lib/features/auth/test
lcov --summary coverage/lcov.info

# Before merge
flutter build ios --no-codesign
flutter build apk --debug
```

## Progress Tracking

**Phase Status**:
- [x] Phase 0: Research complete (격리 전략 수립)
- [x] Phase 1: Design complete (Mock 설계 완료)
- [x] Phase 2: Task planning complete (격리 테스트 중심)
- [x] Phase 3: Tasks generated (/tasks command) ✅ 2025-01-20
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] 격리 전략 정의됨
- [x] Mock 인프라 계획됨
- [x] Repository 인터페이스 작성 완료
- [x] 테스트 실행 가이드 작성 완료
- [x] 43개 상세 작업 목록 생성 완료 (tasks.md)

## Risk Mitigation (Updated)

### Critical Risks & Mitigations
1. **통합 문제 미발견**: Mock이 실제와 다를 수 있음
   - Mitigation: Mock은 Firebase 문서 기반으로 정확히 구현

2. **테스트 신뢰도**: 실제 환경과 다른 테스트
   - Mitigation: 추후 앱 안정화 시 통합 테스트 추가 계획

3. **Mock 유지보수**: Mock 코드 관리 부담
   - Mitigation: Mockito 자동 생성 활용, 인터페이스 기반 설계

4. **Coverage 한계**: UI 테스트 없이 80% 달성 어려움
   - Mitigation: Business logic 100% 커버로 전체 80% 달성

---
*Based on Constitution v2.0.0 - See `.specify/memory/constitution.md`*
*격리 테스트 전략으로 앱 빌드 에러 대응*