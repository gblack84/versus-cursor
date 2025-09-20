# Tasks: Auth Feature Clean Architecture Migration v2.0

**Branch**: `001-users-g-black` | **Created**: 2025-01-20 | **Updated**: 2025-09-20
**Strategy**: Clean Architecture v4.0 Direct Migration (Isolated Testing)
**Target Coverage**: 80% (Unit Tests Only)

---

## 📋 Executive Summary

이 마이그레이션은 **70% 자동화 + 30% 수동 작업**으로 구성됩니다.
- **자동화**: Sub-Agent들이 구조 이동, 파일 분해, DI 설정, Import 수정을 자동 처리
- **수동**: 비즈니스 로직(UseCase)과 테스트 작성만 수동으로 진행
- **예상 기간**: 7-10일 (기존 15-20일 → 50% 단축)

## 🎯 Migration Metadata

| 항목 | 값 | 설명 |
|------|-----|------|
| **Feature** | auth | 인증/인가 전체 기능 |
| **Legacy Files** | 2개 주요 파일 | auth_util.dart (1,378줄), firebase_auth_manager.dart |
| **External Dependencies** | 36개 파일 | 레거시 auth를 import하는 외부 파일들 |
| **Target UseCases** | 25개 | 모든 인증 관련 비즈니스 로직 |
| **Risk Level** | Medium | 앱 빌드 에러로 격리 테스트 전략 필요 |

## 🚀 Execution Workflow

### Pre-flight Checklist ✅

- [ ] Git branch 생성: `git checkout -b feature/auth-clean-architecture`
- [ ] 현재 상태 백업: `git add . && git stash save "auth migration backup"`
- [ ] 작업 디렉토리 확인: `pwd` (프로젝트 루트여야 함)

---

## Phase 0: Discovery & Analysis 🔍
**자동화율: 100% | 예상 시간: 30분**

### T001. [AUTO] Legacy Code Discovery
**Agent**: inventory-scout | **이전 수동 작업**: T0.5 대체

#### 실행 명령:
```bash
/spawn inventory-scout "--feature auth --depth 5 --scope lib/ --line-threshold 300"
```

#### 예상 결과:
- `reports/inventory_auth.json` - 전체 auth 관련 파일 맵핑
- `reports/candidates_decompose.txt` - 분해 필요 파일 (300줄 이상)
- `reports/violations.txt` - Clean Architecture 위반 사항
- `reports/00_inventory.yml` - 마이그레이션 베이스라인

#### 검증:
```bash
cat reports/candidates_decompose.txt | grep auth_util
# Expected: lib/backend/auth/auth_util.dart (1378 lines)
```

---

## Phase 1: Repository Structure Migration 📦
**자동화율: 100% | 예상 시간: 1시간**

### T002. [AUTO] Repository Migration Planning
**Agent**: repo-mover | **이전 수동 작업**: T004 대체

#### 실행 명령 (Dry Run):
```bash
/spawn repo-mover "--feature auth --mode dry-run --include repositories,adapters,firebase,api"
```

#### 계획 검토:
```bash
cat reports/plan_auth.md
# 이동 계획 확인:
# - lib/backend/auth/ → lib/features/auth/data/
# - lib/backend/firebase/firebase_auth_manager.dart → lib/features/auth/data/adapters/
```

### T003. [AUTO] Repository Migration Execution
#### 실행 명령 (Apply):
```bash
/spawn repo-mover "--feature auth --mode apply --include repositories,adapters,firebase,api"
```

#### 검증:
```bash
git status | grep "renamed:"
ls -la lib/features/auth/data/adapters/
# Expected: auth_util.dart, firebase_auth_manager.dart 이동 완료
```

---

## Phase 2: Large File Decomposition 🔨
**자동화율: 100% | 예상 시간: 2시간**

### T004. [AUTO] Decompose auth_util.dart (1,378 lines)
**Agent**: struct-weaver | **이전 수동 작업**: 수동 분해 대체
#### 분석 명령:
```bash
/spawn struct-weaver "--task mapper --mode detect --bridge false --source lib/features/auth/data/adapters/auth_util.dart"
```

#### 분해 계획 검토:
```bash
cat reports/struct_weaver_auth_util.yml | grep "usecases:"
# Expected: 25개 UseCase로 분해 예정
```

#### 적용 명령:
```bash
/spawn struct-weaver "--task mapper --mode apply --bridge false"
```

#### 검증:
```bash
ls -la lib/features/auth/domain/usecases/*.dart | wc -l
# Expected: 25 (각 UseCase별 파일 생성됨)
```

---

## Phase 3: Dependency Injection Setup 💉
**자동화율: 100% | 예상 시간: 30분**

### T005. [AUTO] DI Module Creation
**Agent**: di-binder | **이전 수동 작업**: T000 대체
#### 패턴 분석:
```bash
/spawn di-binder "--feature auth --pattern voting --mode detect"
cat reports/di_auth_analysis.yml  # Voting 패턴과 비교 분석
```

#### DI 모듈 생성:
```bash
/spawn di-binder "--feature auth --pattern voting --mode apply"
```

#### 검증:
```bash
grep "registerAuthModule" app/di.dart
# Expected: AuthDIModule.configureDependencies(getIt);
```

---

## Phase 4: Import Cleanup & Validation 🧹
**자동화율: 100% | 예상 시간: 30분**

### T006. [AUTO] Import Violation Detection
**Agent**: import-guardian | **이전 수동 작업**: T042 일부 대체
#### 위반 감지:
```bash
/spawn import-guardian "--scope auth --mode detect"
cat reports/import_violations_auth.txt | wc -l
# Expected: 36개 파일이 레거시 auth import 사용
```

### T007. [AUTO] Import Auto-Fix
#### 패치 생성:
```bash
/spawn import-guardian "--scope auth --mode fix --apply false"
```

#### 패치 적용:
```bash
git apply patches/import_guardian_fix.diff
```

#### 검증:
```bash
/spawn import-guardian "--scope auth --mode detect"
# Expected: 0 violations

---

## Phase 5: Quality Validation 🎯
**자동화율: 100% | 예상 시간: 1시간**

### T008. [AUTO] Quick Quality Check
**Agent**: build-sentinel
#### 실행 명령:
```bash
/spawn build-sentinel "quick --feature auth"
```

#### 예상 결과:
- `reports/build_quick_auth.txt` - flutter analyze 결과
- 기본 테스트 통과 여부
- 컴파일 에러 검증

### T009. [AUTO] Full Isolated Testing
**Agent**: build-sentinel | **이전 수동 작업**: T039-T040 대체
#### 실행 명령:
```bash
/spawn build-sentinel "full --feature auth --isolated"
```

#### 예상 결과:
- `reports/build_full_auth.txt` - 전체 검증 리포트
- 테스트 커버리지 분석
- 격리 테스트 결과

---

## Phase 6: Manual Implementation (수동 작업 필수) ✍️
**자동화율: 0% | 예상 시간: 5-7일**

> ⚠️ **중요**: 이 단계는 도메인 특화 비즈니스 로직이므로 Sub-Agent로 자동화 불가능합니다.
> 개발자가 직접 TDD 방식으로 구현해야 합니다.

### 6.1 Mock Infrastructure Setup

**T010. Create Domain Models from Specification**
- **Description**: Implement immutable domain models with factory constructors for testing
- **Files**:
  - `lib/features/auth/domain/models/auth_user.dart`
  - `lib/features/auth/domain/models/auth_state.dart`
  - `lib/features/auth/domain/models/auth_token.dart`
  - `lib/features/auth/domain/models/auth_credentials.dart`
  - `lib/features/auth/domain/models/user_session.dart`
  - `lib/features/auth/domain/models/value_objects.dart`
  - `lib/features/auth/domain/models/result.dart`
- **Dependencies**: data-model.md specification
- **Validation**: All models compile, have .mock() factory constructors
- **Complexity**: M

**T011. Create Repository Interfaces**
- **Description**: Define repository contracts with Result<T> return types
- **Files**:
  - `lib/features/auth/domain/repositories/i_auth_repository.dart`
  - `lib/features/auth/domain/repositories/repository_exports.dart`
- **Dependencies**: Domain models from T010
- **Validation**: All methods return Result<T>
- **Complexity**: S

**T012. Create Ports Interfaces**
- **Description**: External service interfaces following Ports pattern (voting 구조 참조)
- **Files**:
  - `lib/features/auth/domain/ports/i_auth_service.dart`
  - `lib/features/auth/domain/ports/i_token_service.dart`
  - `lib/features/auth/domain/ports/i_session_service.dart`
- **Reference**: `/lib/features/voting/domain/ports/`
- **Dependencies**: Domain models, Firebase Auth types
- **Validation**: Clear external boundaries defined
- **Complexity**: M

### 6.2 Test Infrastructure

**T013. Create Firebase Service Mocks**
- **Description**: Mock Firebase Auth and Firestore for isolated testing
- **Files**:
  - `lib/features/auth/test/mocks/mock_firebase_auth.dart`
  - `lib/features/auth/test/mocks/mock_firebase_firestore.dart`
  - `lib/features/auth/test/mocks/mock_firebase_user.dart`
  - `lib/features/auth/test/mocks/mock_user_credential.dart`
- **Dependencies**: firebase_auth, cloud_firestore packages
- **Validation**: flutter test lib/features/auth/test/mocks --dry-run passes
- **Complexity**: M

**T014. Create Social Auth Service Mocks**
- **Description**: Mock Google, Apple, and GitHub sign-in services
- **Files**:
  - `lib/features/auth/test/mocks/mock_google_sign_in.dart`
  - `lib/features/auth/test/mocks/mock_apple_sign_in.dart`
  - `lib/features/auth/test/mocks/mock_github_sign_in.dart`
- **Dependencies**: google_sign_in, sign_in_with_apple packages
- **Validation**: Mock classes compile and implement correct interfaces
- **Complexity**: M

**T015. Create Cross-Feature Dependency Mocks**
- **Description**: Mock navigation, user cache, and analytics services
- **Files**:
  - `lib/features/auth/test/mocks/mock_router.dart`
  - `lib/features/auth/test/mocks/mock_user_cache_service.dart`
  - `lib/features/auth/test/mocks/mock_analytics_service.dart`
  - `lib/features/auth/test/mocks/mock_shared_preferences.dart`
- **Dependencies**: go_router, existing service interfaces
- **Validation**: Mocks compile, methods stubbed with Mockito
- **Complexity**: M

**T016. Create Repository Mocks**
- **Description**: Mock repository implementations for UseCase testing
- **Files**:
  - `lib/features/auth/test/mocks/mock_auth_repository.dart`
  - `lib/features/auth/test/mocks/mock_auth_local_datasource.dart`
  - `lib/features/auth/test/mocks/mock_user_datasource.dart`
  - `lib/features/auth/test/mocks/mock_exports.dart`
- **Dependencies**: Repository interfaces, Mockito
- **Validation**: All repository methods are mockable with Result<T> returns
- **Complexity**: S

**T017. Create Test Fixtures**
- **Description**: Define consistent test data for all scenarios
- **Files**:
  - `lib/features/auth/test/fixtures/auth_fixtures.dart`
  - `lib/features/auth/test/fixtures/auth_state_fixtures.dart`
  - `lib/features/auth/test/fixtures/token_fixtures.dart`
  - `lib/features/auth/test/fixtures/error_fixtures.dart`
  - `lib/features/auth/test/fixtures/firebase_fixtures.dart`
- **Dependencies**: Domain models, error code constants
- **Validation**: All fixtures create valid domain objects
- **Complexity**: M

**T018. Create Test DI Configuration**
- **Description**: Dependency injection setup for isolated testing
- **Files**:
  - `lib/features/auth/test/test_di_module.dart`
  - `lib/features/auth/di/auth_di_module.dart` (production DI)
- **Dependencies**: get_it, all mocks, interfaces
- **Validation**: DI configuration compiles, registers all dependencies
- **Complexity**: M

**T019. Create Infrastructure Mocks**
- **Description**: Mock connectivity, device info, and other infrastructure
- **Files**:
  - `lib/features/auth/test/mocks/mock_network_info.dart`
  - `lib/features/auth/test/mocks/mock_device_info.dart`
  - `lib/features/auth/test/mocks/mock_package_info.dart`
- **Dependencies**: connectivity_plus, device_info_plus packages
- **Validation**: Infrastructure mocks compile and implement interfaces
- **Complexity**: S

**T020. Create Test Helpers**
- **Description**: Common test utilities and setup functions
- **Files**:
  - `lib/features/auth/test/helpers/test_helpers.dart`
  - `lib/features/auth/test/helpers/mock_setup_helpers.dart`
  - `lib/features/auth/test/helpers/assertion_helpers.dart`
- **Dependencies**: flutter_test, all mocks
- **Validation**: Helper functions reduce test boilerplate
- **Complexity**: S

### 6.3 TDD - Write Failing Tests First

**T021. Write GetCurrentUserUseCase Tests**
- **Description**: Write failing tests for getting current authenticated user
- **Files**:
  - `lib/features/auth/test/unit/usecases/get_current_user_usecase_test.dart`
- **Dependencies**: Mock repository, test fixtures
- **Validation**: Tests fail initially (no implementation), cover success/error cases
- **Complexity**: S

**T022. Write Email SignIn UseCase Tests**
- **Description**: Write failing tests for email/password authentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_in_with_email_usecase_test.dart`
- **Dependencies**: Mock repository, email validation, error fixtures
- **Validation**: Tests fail initially, cover invalid email, wrong password, success cases
- **Complexity**: M

**T023. Write Email SignUp UseCase Tests**
- **Description**: Write failing tests for email account creation
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_up_with_email_usecase_test.dart`
- **Dependencies**: Mock repository, password validation, error fixtures
- **Validation**: Tests fail initially, cover weak password, email in use, success cases
- **Complexity**: M

**T024. Write Social SignIn UseCase Tests**
- **Description**: Write failing tests for Google, Apple, GitHub authentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_in_with_google_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/sign_in_with_apple_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/sign_in_with_github_usecase_test.dart`
- **Dependencies**: Mock repository, social auth fixtures
- **Validation**: Tests fail initially, cover cancelled sign-in, network errors, success
- **Complexity**: M

**T025. Write Phone Auth UseCase Tests**
- **Description**: Write failing tests for SMS-based authentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/send_sms_code_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/verify_sms_code_usecase_test.dart`
- **Dependencies**: Mock repository, phone number validation
- **Validation**: Tests fail initially, cover invalid phone, wrong code, success cases
- **Complexity**: M

**T026. Write Anonymous Auth UseCase Tests**
- **Description**: Write failing tests for anonymous authentication and linking
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_in_anonymously_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/link_anonymous_account_usecase_test.dart`
- **Dependencies**: Mock repository, credential fixtures
- **Validation**: Tests fail initially, cover linking errors, success cases
- **Complexity**: M

**T027. Write Password Management UseCase Tests**
- **Description**: Write failing tests for password reset and updates
- **Files**:
  - `lib/features/auth/test/unit/usecases/send_password_reset_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/update_password_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/verify_email_usecase_test.dart`
- **Dependencies**: Mock repository, email validation, error fixtures
- **Validation**: Tests fail initially, cover invalid email, weak password, success
- **Complexity**: M

**T028. Write Token Management UseCase Tests**
- **Description**: Write failing tests for token operations
- **Files**:
  - `lib/features/auth/test/unit/usecases/get_access_token_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/refresh_token_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/validate_token_usecase_test.dart`
- **Dependencies**: Mock repository, token fixtures
- **Validation**: Tests fail initially, cover expired tokens, refresh errors, success
- **Complexity**: M

**T029. Write Profile Management UseCase Tests**
- **Description**: Write failing tests for user profile updates
- **Files**:
  - `lib/features/auth/test/unit/usecases/update_display_name_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/update_photo_url_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/update_email_usecase_test.dart`
- **Dependencies**: Mock repository, validation fixtures
- **Validation**: Tests fail initially, cover validation errors, reauthentication needs
- **Complexity**: M

**T030. Write Account Management UseCase Tests**
- **Description**: Write failing tests for account deletion and reauthentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/delete_account_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/reauthenticate_usecase_test.dart`
- **Dependencies**: Mock repository, credential fixtures
- **Validation**: Tests fail initially, cover wrong password, success cases
- **Complexity**: M

**T031. Write Session Management UseCase Tests**
- **Description**: Write failing tests for sign out and session handling
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_out_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/sign_out_all_devices_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/get_active_sessions_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/revoke_session_usecase_test.dart`
- **Dependencies**: Mock repository, session fixtures
- **Validation**: Tests fail initially, cover network errors, success cases
- **Complexity**: M

**T032. Write User Metadata UseCase Tests**
- **Description**: Write failing tests for user metadata operations
- **Files**:
  - `lib/features/auth/test/unit/usecases/save_user_metadata_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/get_user_metadata_usecase_test.dart`
- **Dependencies**: Mock repository, metadata fixtures
- **Validation**: Tests fail initially, cover invalid data, Firestore errors
- **Complexity**: S

**T033. Write Auth State Stream UseCase Tests**
- **Description**: Write failing tests for reactive auth state monitoring
- **Files**:
  - `lib/features/auth/test/unit/usecases/watch_auth_state_usecase_test.dart`
- **Dependencies**: Mock repository, state stream fixtures
- **Validation**: Tests fail initially, cover state changes, stream errors
- **Complexity**: M

### 6.4 UseCase Implementation

**T034. Create UseCase Base Classes**
- **Description**: Base classes for consistent UseCase implementation
- **Files**:
  - `lib/features/auth/domain/usecases/base_usecase.dart`
  - `lib/features/auth/domain/usecases/usecase_exports.dart`
- **Dependencies**: Result type, repository interfaces
- **Validation**: Base classes provide common functionality, compile without errors
- **Complexity**: S

**T035. Implement GetCurrentUserUseCase**
- **Description**: Business logic for getting current authenticated user
- **Files**:
  - `lib/features/auth/domain/usecases/get_current_user_usecase.dart`
- **Dependencies**: IAuthRepository, Result type
- **Validation**: Tests T021 pass, handles null user gracefully
- **Complexity**: S

**T036. Implement Email Authentication UseCases**
- **Description**: Business logic for email-based authentication
- **Files**:
  - `lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart`
- **Dependencies**: Email/Password value objects, IAuthRepository
- **Validation**: Tests T022, T023 pass, validates input, handles Firebase errors
- **Complexity**: M

**T037. Implement Social Authentication UseCases**
- **Description**: Business logic for social provider authentication
- **Files**:
  - `lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_in_with_apple_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_in_with_github_usecase.dart`
- **Dependencies**: IAuthRepository, social credential types
- **Validation**: Tests T024 pass, handles provider cancellation, network errors
- **Complexity**: M

**T038. Implement Phone Authentication UseCases**
- **Description**: Business logic for SMS-based authentication
- **Files**:
  - `lib/features/auth/domain/usecases/send_sms_code_usecase.dart`
  - `lib/features/auth/domain/usecases/verify_sms_code_usecase.dart`
- **Dependencies**: Phone validation, IAuthRepository
- **Validation**: Tests T025 pass, validates phone format, handles verification errors
- **Complexity**: M

**T039. Implement Anonymous Authentication UseCases**
- **Description**: Business logic for anonymous user handling
- **Files**:
  - `lib/features/auth/domain/usecases/sign_in_anonymously_usecase.dart`
  - `lib/features/auth/domain/usecases/link_anonymous_account_usecase.dart`
- **Dependencies**: IAuthRepository, AuthCredentials
- **Validation**: Tests T026 pass, handles linking conflicts
- **Complexity**: M

**T040. Implement Password Management UseCases**
- **Description**: Business logic for password operations
- **Files**:
  - `lib/features/auth/domain/usecases/send_password_reset_usecase.dart`
  - `lib/features/auth/domain/usecases/update_password_usecase.dart`
  - `lib/features/auth/domain/usecases/verify_email_usecase.dart`
- **Dependencies**: Email validation, Password strength validation
- **Validation**: Tests T027 pass, enforces password policies
- **Complexity**: M

**T041. Implement Token Management UseCases**
- **Description**: Business logic for authentication token handling
- **Files**:
  - `lib/features/auth/domain/usecases/get_access_token_usecase.dart`
  - `lib/features/auth/domain/usecases/refresh_token_usecase.dart`
  - `lib/features/auth/domain/usecases/validate_token_usecase.dart`
- **Dependencies**: AuthToken model, IAuthRepository
- **Validation**: Tests T028 pass, handles token expiration, refresh failures
- **Complexity**: M

**T042. Implement Profile Management UseCases**
- **Description**: Business logic for user profile updates
- **Files**:
  - `lib/features/auth/domain/usecases/update_display_name_usecase.dart`
  - `lib/features/auth/domain/usecases/update_photo_url_usecase.dart`
  - `lib/features/auth/domain/usecases/update_email_usecase.dart`
- **Dependencies**: Profile validation, reauthentication handling
- **Validation**: Tests T029 pass, validates URLs, requires reauthentication for email
- **Complexity**: M

**T043. Implement Account Management UseCases**
- **Description**: Business logic for sensitive account operations
- **Files**:
  - `lib/features/auth/domain/usecases/delete_account_usecase.dart`
  - `lib/features/auth/domain/usecases/reauthenticate_usecase.dart`
- **Dependencies**: IAuthRepository, AuthCredentials
- **Validation**: Tests T030 pass, requires reauthentication, handles deletion errors
- **Complexity**: M

**T044. Implement Session Management UseCases**
- **Description**: Business logic for session handling
- **Files**:
  - `lib/features/auth/domain/usecases/sign_out_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_out_all_devices_usecase.dart`
  - `lib/features/auth/domain/usecases/get_active_sessions_usecase.dart`
  - `lib/features/auth/domain/usecases/revoke_session_usecase.dart`
- **Dependencies**: UserSession model, IAuthRepository
- **Validation**: Tests T031 pass, clears local cache on sign out
- **Complexity**: M

**T045. Implement User Metadata UseCases**
- **Description**: Business logic for user metadata operations
- **Files**:
  - `lib/features/auth/domain/usecases/save_user_metadata_usecase.dart`
  - `lib/features/auth/domain/usecases/get_user_metadata_usecase.dart`
- **Dependencies**: Metadata validation, IUserDataSource
- **Validation**: Tests T032 pass, validates metadata structure
- **Complexity**: S

**T046. Implement Auth State Stream UseCase**
- **Description**: Business logic for reactive auth state monitoring
- **Files**:
  - `lib/features/auth/domain/usecases/watch_auth_state_usecase.dart`
- **Dependencies**: Stream handling, AuthState model
- **Validation**: Tests T033 pass, provides real-time auth state updates
- **Complexity**: M

---

## Phase 7: Final Validation & Rollback (수동) 🎆

### 전체 테스트 실행 및 커버리지 확인

**T047. Run Comprehensive Test Suite**
- **Description**: 모든 UseCase 테스트 실행 및 80%+ 커버리지 확인
- **Commands**:
  ```bash
  flutter test lib/features/auth/test/unit --coverage
  lcov --summary coverage/lcov.info
  ```
- **Expected**:
  - 모든 테스트 통과 ✅
  - Business logic coverage ≥ 90%
  - Overall coverage ≥ 80%
- **Complexity**: M

**T048. Archive Legacy Code**
- **Description**: 레거시 auth 파일들을 `/archived` 디렉토리로 이동
- **Files**:
  - `lib/backend/auth/auth_util.dart` (1,378줄)
  - `lib/backend/firebase/firebase_auth_manager.dart`
- **Strategy**: 삭제 대신 보관 (rollback 가능)
- **Validation**: 레거시 코드 참조 0건
- **Complexity**: M

---

## Validation Checkpoints 🎯

### 페이즈별 검증 체크포인트

**Phase 0-1 (Automated)**:
```bash
cat reports/inventory_auth.json  # 파일 맵핑 확인
git status | grep "renamed:"    # 파일 이동 확인
```

**Phase 2-3 (Automated)**:
```bash
ls -la lib/features/auth/domain/usecases/*.dart | wc -l  # 25개 UseCase 확인
grep "registerAuthModule" app/di.dart  # DI 등록 확인
```

**Phase 4-5 (Automated)**:
```bash
/spawn import-guardian "--scope auth --mode detect"  # 0 violations
/spawn build-sentinel "full --feature auth --isolated"  # 테스트 커버리지
```

**Phase 6 (Manual)**:
```bash
flutter test lib/features/auth/test/unit  # 모든 테스트 통과
lcov --summary coverage/lcov.info | grep "lines.*: [8-9][0-9]"  # 80%+ coverage
```

---

## Success Criteria 🎯

### 기술적 성공 기준
- [ ] **Coverage**: 80%+ 단위 테스트 커버리지
- [ ] **Isolation**: Firebase 서비스 호출 0건
- [ ] **Architecture**: Clean Architecture 규칙 100% 준수
- [ ] **Automation**: Phase 0-5 자동화 성공
- [ ] **Manual**: Phase 6 UseCase/Test 구현 완료

### 비즈니스 성공 기준
- [ ] 모든 인증 기능 격리 테스트 가능
- [ ] 에러 처리 코드 100% 커버
- [ ] 토큰 관리 로직 테스트된 상태
- [ ] 세션 보안 처리 완료

---

## 프로젝트 요약

**총 작업**: 48개 태스크 (70% 자동화 + 30% 수동)
- **Phase 0-5**: Sub-Agent 자동화 (9개 태스크)
- **Phase 6**: 수동 구현 (37개 태스크)
- **Phase 7**: 검증 (2개 태스크)

**예상 기간**: 7-10일 (기존 15-20일에서 50% 단축)
- **자동화**: 1-2일
- **수동 작업**: 5-7일
- **검증**: 1일

**핵심 성공 요소**: Sub-Agent 활용으로 구조 이동/DI/Import 자동화
**위험 관리**: 각 페이즈 완료 후 git commit으로 rollback 가능