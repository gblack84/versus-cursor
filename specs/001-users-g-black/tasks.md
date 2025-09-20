# Tasks: Auth Feature Clean Architecture Migration (Isolated Testing Strategy)

**Branch**: `001-users-g-black` | **Date**: 2025-01-20 | **Spec**: [spec.md](./spec.md)

## Task Categories & Execution Strategy

This task list implements the **Isolated Testing Strategy** from [plan.md](./plan.md) to migrate auth feature to Clean Architecture v4.0 without requiring app to build. All tasks use comprehensive mocking and unit tests only.

### Execution Phases:
1. **Phase 1: Mock Infrastructure Setup** (Tasks 0-12) - Foundation for isolated testing (DI, Ports, DataSources)
2. **Phase 2: Write Unit Tests First (TDD)** (Tasks 13-25) - Write failing tests before implementation
3. **Phase 3: Implement UseCases to Pass Tests** (Tasks 26-38) - Business logic implementation
4. **Phase 4: Verification & Migration** (Tasks 39-43) - Coverage validation and legacy cleanup

### Task Complexity Scale:
- **S** (Small): 1-2 hours, single file, straightforward implementation
- **M** (Medium): 3-6 hours, multiple files, moderate complexity
- **L** (Large): 6+ hours, complex integration, high impact

---

## Phase 1: Mock Infrastructure Setup 🏗️

### Category: Test Infrastructure & Mocking

**T000. Create DI Module (Based on Voting Feature Structure)** 🆕
- **Description**: Create auth_di_module.dart following voting_di_module.dart pattern
- **Files**:
  - `lib/features/auth/di/auth_di_module.dart`
- **🤖 Automated Option (Recommended)**:
  ```bash
  # Analyze voting pattern and create DI module
  /spawn di-binder "--feature auth --pattern voting --mode detect"
  # Review: reports/di_auth_analysis.yml

  /spawn di-binder "--feature auth --pattern voting --mode apply"
  # Creates: lib/features/auth/di/auth_di_module.dart
  # Updates: app/di.dart with registerAuthModule()
  ```
- **Manual Implementation**:
  ```dart
  class AuthDIModule {
    static void configureDependencies(GetIt getIt) {
      // Ports (External Services)
      getIt.registerLazySingleton<IAuthService>(
        () => FirebaseAuthService(),
      );
      getIt.registerLazySingleton<ITokenService>(
        () => TokenServiceImpl(),
      );

      // Repositories
      getIt.registerLazySingleton<IAuthRepository>(
        () => AuthRepositoryImpl(
          authService: getIt(),
          tokenService: getIt(),
        ),
      );

      // UseCases (25 total - 1 per file)
      getIt.registerFactory(() => SignInWithEmailUseCase(getIt()));
      getIt.registerFactory(() => SignOutUseCase(getIt()));
      getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
      // ... 22 more UseCases
    }
  }
  ```
- **Reference**: `/lib/features/voting/di/voting_di_module.dart`
- **Dependencies**: GetIt package
- **Validation**: Module registers all dependencies, compiles without errors
- **Complexity**: M

**T0.5. Legacy Code Search and Tracking** 🆕
- **Description**: Comprehensive grep search to identify all auth-related legacy code that needs migration
- **Manual Command**:
  ```bash
  # Search for all auth-related files and patterns
  grep -r "auth" lib/ --include="*.dart" | grep -v "lib/features/auth"
  grep -r "FFAppState.*auth" lib/
  grep -r "firebase_auth" lib/ --include="*.dart"
  grep -r "currentUser" lib/ --include="*.dart"
  ```
- **🤖 Automated Option (Recommended)**:
  ```bash
  /spawn inventory-scout "--feature auth --depth 5 --scope lib/ --line-threshold 300"
  # Output: reports/inventory_auth.json, candidates_decompose.txt, violations.txt
  ```
- **Expected Findings**:
  - Backend auth utilities in `lib/backend/`
  - Global state auth references in `lib/app/`
  - Direct Firebase Auth imports outside feature
  - Auth-related widgets in `lib/components/`
- **Output**: `migration_tracking/legacy_auth_code.md` or `reports/inventory_auth.json`
- **Dependencies**: None
- **Validation**: All auth references documented and categorized
- **Complexity**: S

**T001. Create Mock Infrastructure Directory Structure**
- **Description**: Set up feature-level test directory structure for isolated testing
- **Files**:
  - `lib/features/auth/test/unit/usecases/`
  - `lib/features/auth/test/unit/repositories/`
  - `lib/features/auth/test/unit/adapters/`
  - `lib/features/auth/test/mocks/`
  - `lib/features/auth/test/fixtures/`
- **Dependencies**: None
- **Validation**: Directory structure exists, matches Clean Architecture
- **Complexity**: S

**T002. Create Domain Models from Specification**
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

**T003. Create Repository Interfaces for Mocking**
- **Description**: Define repository contracts with Result<T> return types for testable error handling
- **Files**:
  - `lib/features/auth/domain/repositories/i_auth_repository.dart` (copy from contracts/)
  - `lib/features/auth/domain/repositories/repository_exports.dart`
- **Dependencies**: Domain models, contracts/i_auth_repository.dart
- **Validation**: Interfaces compile, all methods return Result<T>
- **Complexity**: S

**T003.5. Create Ports Interfaces (Based on Voting Feature)** 🆕
- **Description**: Define external service interfaces following Ports pattern
- **Files**:
  - `lib/features/auth/domain/ports/`
  - `lib/features/auth/domain/ports/i_auth_service.dart`
  - `lib/features/auth/domain/ports/i_token_service.dart`
  - `lib/features/auth/domain/ports/i_session_service.dart`
  - `lib/features/auth/domain/ports/i_notification_port.dart`
  - `lib/features/auth/domain/ports/ports_exports.dart`
- **Reference**: `/lib/features/voting/domain/ports/` structure
- **Dependencies**: Firebase Auth types, domain models
- **Validation**: All ports compile, methods clearly define external boundaries
- **Complexity**: M

**T004. Create DataSource Structure (Based on Voting Feature)** 🔄
- **Description**: Create hierarchical datasource structure following voting feature pattern
- **Manual Approach**:
  - Create directories and files manually
  - Copy structure from voting feature
- **🤖 Automated Option (Recommended)**:
  ```bash
  # Step 1: Move existing backend files to feature
  /spawn repo-mover "--feature auth --mode dry-run --include repositories,firebase,api"
  # Review: reports/plan_auth.md
  /spawn repo-mover "--feature auth --mode apply"

  # Step 2: Create remaining structure
  # Note: Local services and utils may still need manual creation
  ```
- **Files**:
  - `lib/features/auth/data/datasources/local/`
  - `lib/features/auth/data/datasources/local/services/`
    - `auth_cache_service.dart`
    - `token_storage_service.dart`
    - `session_cache_service.dart`
  - `lib/features/auth/data/datasources/local/utils/`
    - `cache_keys.dart`
    - `cache_helpers.dart`
  - `lib/features/auth/data/datasources/remote/`
  - `lib/features/auth/data/datasources/remote/firebase/`
    - `firebase_auth_datasource.dart`
    - `firestore_user_datasource.dart`
  - `lib/features/auth/data/datasources/remote/api/`
    - `external_auth_api.dart`
- **Reference**: `/lib/features/voting/data/datasources/` structure
- **Dependencies**: Domain models, Firebase packages, SharedPreferences
- **Validation**: All datasources compile, follow voting structure pattern
- **Complexity**: M

**T005. Create Firebase Service Mocks**
- **Description**: Mock Firebase Auth and Firestore for isolated testing
- **Files**:
  - `lib/features/auth/test/mocks/mock_firebase_auth.dart`
  - `lib/features/auth/test/mocks/mock_firebase_firestore.dart`
  - `lib/features/auth/test/mocks/mock_firebase_user.dart`
  - `lib/features/auth/test/mocks/mock_user_credential.dart`
- **Dependencies**: firebase_auth, cloud_firestore packages
- **Validation**: flutter test lib/features/auth/test/mocks --dry-run passes
- **Complexity**: M

**T006. Create Social Auth Service Mocks**
- **Description**: Mock Google, Apple, and GitHub sign-in services
- **Files**:
  - `lib/features/auth/test/mocks/mock_google_sign_in.dart`
  - `lib/features/auth/test/mocks/mock_apple_sign_in.dart`
  - `lib/features/auth/test/mocks/mock_github_sign_in.dart`
- **Dependencies**: google_sign_in, sign_in_with_apple packages
- **Validation**: Mock classes compile and implement correct interfaces
- **Complexity**: M

**T007. Create Cross-Feature Dependency Mocks**
- **Description**: Mock navigation, user cache, and analytics services
- **Files**:
  - `lib/features/auth/test/mocks/mock_router.dart`
  - `lib/features/auth/test/mocks/mock_user_cache_service.dart`
  - `lib/features/auth/test/mocks/mock_analytics_service.dart`
  - `lib/features/auth/test/mocks/mock_shared_preferences.dart`
- **Dependencies**: go_router, existing service interfaces
- **Validation**: Mocks compile, methods stubbed with Mockito
- **Complexity**: M

**T008. Create Repository Mocks**
- **Description**: Mock repository implementations for UseCase testing
- **Files**:
  - `lib/features/auth/test/mocks/mock_auth_repository.dart`
  - `lib/features/auth/test/mocks/mock_auth_local_datasource.dart`
  - `lib/features/auth/test/mocks/mock_user_datasource.dart`
  - `lib/features/auth/test/mocks/mock_exports.dart`
- **Dependencies**: Repository interfaces, Mockito
- **Validation**: All repository methods are mockable with Result<T> returns
- **Complexity**: S

**T009. Create Test Fixtures for Auth Data**
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

**T010. Create Test DI Configuration**
- **Description**: Dependency injection setup for isolated testing
- **Files**:
  - `lib/features/auth/test/test_di_module.dart`
  - `lib/features/auth/di/auth_di_module.dart` (production DI)
- **Dependencies**: get_it, all mocks, interfaces
- **Validation**: DI configuration compiles, registers all dependencies
- **Complexity**: M

**T011. Create Mock Network and Infrastructure Services**
- **Description**: Mock connectivity, device info, and other infrastructure
- **Files**:
  - `lib/features/auth/test/mocks/mock_network_info.dart`
  - `lib/features/auth/test/mocks/mock_device_info.dart`
  - `lib/features/auth/test/mocks/mock_package_info.dart`
- **Dependencies**: connectivity_plus, device_info_plus packages
- **Validation**: Infrastructure mocks compile and implement interfaces
- **Complexity**: S

**T012. Create Test Helper Utilities**
- **Description**: Common test utilities and setup functions
- **Files**:
  - `lib/features/auth/test/helpers/test_helpers.dart`
  - `lib/features/auth/test/helpers/mock_setup_helpers.dart`
  - `lib/features/auth/test/helpers/assertion_helpers.dart`
- **Dependencies**: flutter_test, all mocks
- **Validation**: Helper functions reduce test boilerplate
- **Complexity**: S

---

## Phase 2: Write Unit Tests First (TDD) 📝

### Category: Test-Driven Development (Failing Tests)

**T013. Write GetCurrentUserUseCase Tests**
- **Description**: Write failing tests for getting current authenticated user
- **Files**:
  - `lib/features/auth/test/unit/usecases/get_current_user_usecase_test.dart`
- **Dependencies**: Mock repository, test fixtures
- **Validation**: Tests fail initially (no implementation), cover success/error cases
- **Complexity**: S

**T014. Write Email SignIn UseCase Tests**
- **Description**: Write failing tests for email/password authentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_in_with_email_usecase_test.dart`
- **Dependencies**: Mock repository, email validation, error fixtures
- **Validation**: Tests fail initially, cover invalid email, wrong password, success cases
- **Complexity**: M

**T015. Write Email SignUp UseCase Tests**
- **Description**: Write failing tests for email account creation
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_up_with_email_usecase_test.dart`
- **Dependencies**: Mock repository, password validation, error fixtures
- **Validation**: Tests fail initially, cover weak password, email in use, success cases
- **Complexity**: M

**T016. Write Social SignIn UseCase Tests**
- **Description**: Write failing tests for Google, Apple, GitHub authentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_in_with_google_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/sign_in_with_apple_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/sign_in_with_github_usecase_test.dart`
- **Dependencies**: Mock repository, social auth fixtures
- **Validation**: Tests fail initially, cover cancelled sign-in, network errors, success
- **Complexity**: M

**T017. Write Phone Auth UseCase Tests**
- **Description**: Write failing tests for SMS-based authentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/send_sms_code_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/verify_sms_code_usecase_test.dart`
- **Dependencies**: Mock repository, phone number validation
- **Validation**: Tests fail initially, cover invalid phone, wrong code, success cases
- **Complexity**: M

**T018. Write Anonymous Auth UseCase Tests**
- **Description**: Write failing tests for anonymous authentication and linking
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_in_anonymously_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/link_anonymous_account_usecase_test.dart`
- **Dependencies**: Mock repository, credential fixtures
- **Validation**: Tests fail initially, cover linking errors, success cases
- **Complexity**: M

**T019. Write Password Management UseCase Tests**
- **Description**: Write failing tests for password reset and updates
- **Files**:
  - `lib/features/auth/test/unit/usecases/send_password_reset_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/update_password_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/verify_email_usecase_test.dart`
- **Dependencies**: Mock repository, email validation, error fixtures
- **Validation**: Tests fail initially, cover invalid email, weak password, success
- **Complexity**: M

**T020. Write Token Management UseCase Tests**
- **Description**: Write failing tests for token operations
- **Files**:
  - `lib/features/auth/test/unit/usecases/get_access_token_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/refresh_token_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/validate_token_usecase_test.dart`
- **Dependencies**: Mock repository, token fixtures
- **Validation**: Tests fail initially, cover expired tokens, refresh errors, success
- **Complexity**: M

**T021. Write Profile Management UseCase Tests**
- **Description**: Write failing tests for user profile updates
- **Files**:
  - `lib/features/auth/test/unit/usecases/update_display_name_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/update_photo_url_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/update_email_usecase_test.dart`
- **Dependencies**: Mock repository, validation fixtures
- **Validation**: Tests fail initially, cover validation errors, reauthentication needs
- **Complexity**: M

**T022. Write Account Management UseCase Tests**
- **Description**: Write failing tests for account deletion and reauthentication
- **Files**:
  - `lib/features/auth/test/unit/usecases/delete_account_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/reauthenticate_usecase_test.dart`
- **Dependencies**: Mock repository, credential fixtures
- **Validation**: Tests fail initially, cover wrong password, success cases
- **Complexity**: M

**T023. Write Session Management UseCase Tests**
- **Description**: Write failing tests for sign out and session handling
- **Files**:
  - `lib/features/auth/test/unit/usecases/sign_out_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/sign_out_all_devices_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/get_active_sessions_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/revoke_session_usecase_test.dart`
- **Dependencies**: Mock repository, session fixtures
- **Validation**: Tests fail initially, cover network errors, success cases
- **Complexity**: M

**T024. Write User Metadata UseCase Tests**
- **Description**: Write failing tests for user metadata operations
- **Files**:
  - `lib/features/auth/test/unit/usecases/save_user_metadata_usecase_test.dart`
  - `lib/features/auth/test/unit/usecases/get_user_metadata_usecase_test.dart`
- **Dependencies**: Mock repository, metadata fixtures
- **Validation**: Tests fail initially, cover invalid data, Firestore errors
- **Complexity**: S

**T025. Write Auth State Stream UseCase Tests**
- **Description**: Write failing tests for reactive auth state monitoring
- **Files**:
  - `lib/features/auth/test/unit/usecases/watch_auth_state_usecase_test.dart`
- **Dependencies**: Mock repository, state stream fixtures
- **Validation**: Tests fail initially, cover state changes, stream errors
- **Complexity**: M

---

## Phase 3: Implement UseCases to Pass Tests ⚙️

### Category: Business Logic Implementation

**T026. Create UseCase Base Classes and Interfaces**
- **Description**: Base classes for consistent UseCase implementation
- **Files**:
  - `lib/features/auth/domain/usecases/base_usecase.dart`
  - `lib/features/auth/domain/usecases/usecase_exports.dart`
- **Dependencies**: Result type, repository interfaces
- **Validation**: Base classes provide common functionality, compile without errors
- **Complexity**: S

**T027. Implement GetCurrentUserUseCase**
- **Description**: Business logic for getting current authenticated user
- **Files**:
  - `lib/features/auth/domain/usecases/get_current_user_usecase.dart`
- **Dependencies**: IAuthRepository, Result type
- **Validation**: Tests T013 pass, handles null user gracefully
- **Complexity**: S

**T028. Implement Email Authentication UseCases**
- **Description**: Business logic for email-based authentication
- **Files**:
  - `lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart`
- **Dependencies**: Email/Password value objects, IAuthRepository
- **Validation**: Tests T014, T015 pass, validates input, handles Firebase errors
- **Complexity**: M

**T029. Implement Social Authentication UseCases**
- **Description**: Business logic for social provider authentication
- **Files**:
  - `lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_in_with_apple_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_in_with_github_usecase.dart`
- **Dependencies**: IAuthRepository, social credential types
- **Validation**: Tests T016 pass, handles provider cancellation, network errors
- **Complexity**: M

**T030. Implement Phone Authentication UseCases**
- **Description**: Business logic for SMS-based authentication
- **Files**:
  - `lib/features/auth/domain/usecases/send_sms_code_usecase.dart`
  - `lib/features/auth/domain/usecases/verify_sms_code_usecase.dart`
- **Dependencies**: Phone validation, IAuthRepository
- **Validation**: Tests T017 pass, validates phone format, handles verification errors
- **Complexity**: M

**T031. Implement Anonymous Authentication UseCases**
- **Description**: Business logic for anonymous user handling
- **Files**:
  - `lib/features/auth/domain/usecases/sign_in_anonymously_usecase.dart`
  - `lib/features/auth/domain/usecases/link_anonymous_account_usecase.dart`
- **Dependencies**: IAuthRepository, AuthCredentials
- **Validation**: Tests T018 pass, handles linking conflicts
- **Complexity**: M

**T032. Implement Password Management UseCases**
- **Description**: Business logic for password operations
- **Files**:
  - `lib/features/auth/domain/usecases/send_password_reset_usecase.dart`
  - `lib/features/auth/domain/usecases/update_password_usecase.dart`
  - `lib/features/auth/domain/usecases/verify_email_usecase.dart`
- **Dependencies**: Email validation, Password strength validation
- **Validation**: Tests T019 pass, enforces password policies
- **Complexity**: M

**T033. Implement Token Management UseCases**
- **Description**: Business logic for authentication token handling
- **Files**:
  - `lib/features/auth/domain/usecases/get_access_token_usecase.dart`
  - `lib/features/auth/domain/usecases/refresh_token_usecase.dart`
  - `lib/features/auth/domain/usecases/validate_token_usecase.dart`
- **Dependencies**: AuthToken model, IAuthRepository
- **Validation**: Tests T020 pass, handles token expiration, refresh failures
- **Complexity**: M

**T034. Implement Profile Management UseCases**
- **Description**: Business logic for user profile updates
- **Files**:
  - `lib/features/auth/domain/usecases/update_display_name_usecase.dart`
  - `lib/features/auth/domain/usecases/update_photo_url_usecase.dart`
  - `lib/features/auth/domain/usecases/update_email_usecase.dart`
- **Dependencies**: Profile validation, reauthentication handling
- **Validation**: Tests T021 pass, validates URLs, requires reauthentication for email
- **Complexity**: M

**T035. Implement Account Management UseCases**
- **Description**: Business logic for sensitive account operations
- **Files**:
  - `lib/features/auth/domain/usecases/delete_account_usecase.dart`
  - `lib/features/auth/domain/usecases/reauthenticate_usecase.dart`
- **Dependencies**: IAuthRepository, AuthCredentials
- **Validation**: Tests T022 pass, requires reauthentication, handles deletion errors
- **Complexity**: M

**T036. Implement Session Management UseCases**
- **Description**: Business logic for session handling
- **Files**:
  - `lib/features/auth/domain/usecases/sign_out_usecase.dart`
  - `lib/features/auth/domain/usecases/sign_out_all_devices_usecase.dart`
  - `lib/features/auth/domain/usecases/get_active_sessions_usecase.dart`
  - `lib/features/auth/domain/usecases/revoke_session_usecase.dart`
- **Dependencies**: UserSession model, IAuthRepository
- **Validation**: Tests T023 pass, clears local cache on sign out
- **Complexity**: M

**T037. Implement User Metadata UseCases**
- **Description**: Business logic for user metadata operations
- **Files**:
  - `lib/features/auth/domain/usecases/save_user_metadata_usecase.dart`
  - `lib/features/auth/domain/usecases/get_user_metadata_usecase.dart`
- **Dependencies**: Metadata validation, IUserDataSource
- **Validation**: Tests T024 pass, validates metadata structure
- **Complexity**: S

**T038. Implement Auth State Stream UseCase**
- **Description**: Business logic for reactive auth state monitoring
- **Files**:
  - `lib/features/auth/domain/usecases/watch_auth_state_usecase.dart`
- **Dependencies**: Stream handling, AuthState model
- **Validation**: Tests T025 pass, provides real-time auth state updates
- **Complexity**: M

---

## Phase 4: Verification & Migration 🔍

### Category: Validation & Coverage

**T039. Run Comprehensive Unit Test Suite**
- **Description**: Execute all unit tests and verify 80%+ coverage target
- **Files**: All test files created in Phase 2
- **Dependencies**: All UseCases implemented, test infrastructure complete
- **Commands**:
  ```bash
  flutter test lib/features/auth/test/unit --coverage
  genhtml coverage/lcov.info -o coverage/html
  lcov --summary coverage/lcov.info
  ```
- **Validation**:
  - All tests pass ✅
  - Business logic coverage ≥ 90%
  - Overall feature coverage ≥ 80%
  - No Firebase calls during tests (verified by mock assertions)
- **Complexity**: M

**T040. Static Analysis and Code Quality**
- **Description**: Ensure code follows Clean Architecture principles and Dart conventions
- **Files**: All auth feature files
- **Dependencies**: Implementation complete
- **Commands**:
  ```bash
  flutter analyze lib/features/auth
  dart format lib/features/auth --set-exit-if-changed
  ```
- **Validation**:
  - Zero analyzer warnings/errors
  - Consistent code formatting
  - Clean Architecture boundaries respected
  - No circular dependencies
- **Complexity**: S

**T041. Create Integration Preparation Documentation**
- **Description**: Document how to integrate with real Firebase when app builds
- **Files**:
  - `lib/features/auth/test/integration_readiness.md`
  - `lib/features/auth/README.md`
- **Dependencies**: Complete implementation
- **Validation**: Clear instructions for future integration testing
- **Complexity**: S

### Category: Legacy Migration & Cleanup

**T042. Update External Imports (Safe Mode)**
- **Description**: Update the 36 external files to use new auth interfaces (gradual approach)
- **Files**: All files that import auth utilities (identified in spec.md)
- **Manual Strategy**:
  - Phase 4a: Update imports to use new interfaces
  - Phase 4b: Replace direct calls with UseCase calls
  - Phase 4c: Remove legacy dependencies
- **🤖 Automated Option (Highly Recommended)**:
  ```bash
  # Step 1: Detect all import violations
  /spawn import-guardian "--scope auth --mode detect"
  # Output: reports/import_violations_auth.txt

  # Step 2: Generate fix patches
  /spawn import-guardian "--scope auth --mode fix --apply false"
  # Output: patches/import_guardian_fix.diff

  # Step 3: Review and apply patches
  git diff patches/import_guardian_fix.diff  # Review changes
  git apply patches/import_guardian_fix.diff  # Apply if satisfied

  # Step 4: Verify no violations remain
  /spawn import-guardian "--scope auth --mode detect"
  # Expected: 0 violations
  ```
- **Dependencies**: All UseCases implemented and tested
- **Validation**:
  - flutter analyze passes
  - No broken imports
  - External files use new auth contracts
- **Complexity**: L (Manual) / M (Automated)

**T043. Archive Legacy Auth Files**
- **Description**: Remove or archive legacy auth implementations
- **Files**:
  - `lib/auth_util.dart` (1378 lines) → archive
  - `lib/firebase_auth_manager.dart` → archive
  - Other legacy auth utilities
- **Strategy**: Move to `/archived` directory rather than delete
- **Dependencies**: External imports updated (T042)
- **Validation**:
  - No references to archived files
  - App builds without legacy auth code (if app can build)
  - All auth functionality available through new UseCases
- **Complexity**: M

---

## Validation Checkpoints 🎯

### Per-Phase Validation

**Phase 1 Complete**:
```bash
flutter test lib/features/auth/test/mocks --dry-run
# Expected: All mock files compile, no syntax errors

# 🤖 Automated Validation:
/spawn build-sentinel "quick --feature auth --phase mock"
```

**Phase 2 Complete**:
```bash
flutter test lib/features/auth/test/unit --dry-run
# Expected: All test files compile, tests fail (no implementation)
```

**Phase 3 Complete**:
```bash
flutter test lib/features/auth/test/unit
# Expected: All tests pass, business logic works correctly

# 🤖 Automated Validation:
/spawn build-sentinel "quick --feature auth"
```

**Phase 4 Complete**:
```bash
flutter analyze lib/features/auth
flutter test lib/features/auth/test --coverage
lcov --summary coverage/lcov.info | grep "lines.*: [8-9][0-9]"
# Expected: Clean analysis, 80%+ coverage achieved

# 🤖 Automated Validation:
/spawn build-sentinel "full --feature auth --isolated"
# Output: reports/build_full_auth.txt with coverage metrics
```

### Quality Gates

1. **Mock Validation Gate**: All external dependencies are mocked, no real service calls
2. **Test Coverage Gate**: Business logic ≥ 90%, overall ≥ 80%
3. **Static Analysis Gate**: Zero warnings, clean architecture compliance
4. **Integration Readiness Gate**: Clear path to real Firebase integration

### Risk Mitigation

**High Risk Tasks**: T042 (External imports), T043 (Legacy cleanup)
- **Mitigation**: Create git branches for rollback, test each external file individually

**Medium Risk Tasks**: All UseCase implementations (T027-T038)
- **Mitigation**: Tests must pass before proceeding, validate mock assumptions

**Low Risk Tasks**: Infrastructure setup (T001-T012)
- **Mitigation**: Incremental validation, fix compilation errors immediately

---

## Success Criteria 🎯

### Technical Criteria
- [ ] 80%+ test coverage through unit tests only
- [ ] Zero Firebase service calls during tests
- [ ] All UseCases have corresponding unit tests
- [ ] Clean Architecture boundaries respected
- [ ] External dependencies properly mocked

### Business Criteria
- [ ] All auth operations work in isolation
- [ ] Error handling covers all Firebase scenarios
- [ ] Token management is robust and testable
- [ ] User session handling is secure
- [ ] Profile management validates properly

### Integration Readiness
- [ ] Clear contracts defined for Firebase integration
- [ ] Mock behavior matches expected Firebase behavior
- [ ] Integration test plan documented
- [ ] Rollback strategy documented
- [ ] External file updates are safe and reversible

---

*Total: 43 tasks implementing isolated testing strategy for auth feature migration to Clean Architecture v4.0*

**Estimated Effort**: 15-20 development days
**Critical Path**: Mock Infrastructure → Failing Tests → UseCase Implementation → Coverage Validation
**Key Success Factor**: Maintaining 100% isolation from Firebase during development and testing