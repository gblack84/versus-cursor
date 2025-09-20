# Research: Auth Feature Isolation Strategy

**Date**: 2025-01-19
**Feature**: Auth Feature Clean Architecture Migration
**Constraint**: App-wide build errors prevent full execution

## Problem Analysis

### Current State
- **Build Status**: Multiple errors preventing app compilation
- **Test Execution**: Cannot run integration or E2E tests
- **Dependencies**: 36 external files depend on auth internals
- **Legacy Structure**: Mixed responsibilities in auth_util.dart and firebase_auth_manager.dart

### Challenges
1. Cannot validate changes through app execution
2. No way to run existing integration tests
3. External dependencies might break during migration
4. Firebase services require real connection for testing

## Solution: Isolated Testing Strategy

### Core Approach
```yaml
strategy: "Complete Feature Isolation"
method: "Dependency Injection + Comprehensive Mocking"
validation: "Unit Tests Only"
coverage_target: "80% through business logic tests"
```

### Decision Rationale
- **Why Isolation**: App won't build, so we must test in isolation
- **Why Mocks**: Real Firebase requires app initialization
- **Why Unit Tests**: Can run without full app context
- **Alternatives Considered**:
  - Firebase emulator: Still requires app to build
  - Manual testing: Not reproducible or automated
  - Delay migration: Tech debt continues to grow

## Mock Infrastructure Design

### External Service Mocks
```dart
// Firebase Auth Mock
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  // Stubbed methods:
  // - signInWithEmailAndPassword()
  // - signInWithCredential()
  // - signOut()
  // - authStateChanges()
  // - currentUser
}

// Firestore Mock
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  // Stubbed methods:
  // - collection()
  // - doc()
  // - set/get/update/delete operations
}

// Google Sign In Mock
class MockGoogleSignIn extends Mock implements GoogleSignIn {
  // Stubbed methods:
  // - signIn()
  // - signOut()
  // - currentUser
}
```

### Cross-Feature Dependency Mocks
```dart
// Router Mock (for navigation)
class MockRouter extends Mock implements AppRouter {
  // Verify navigation calls without actual routing
}

// User Cache Mock
class MockUserCache extends Mock implements UserCacheService {
  // Return test fixtures for cached data
}

// Analytics Mock
class MockAnalytics extends Mock implements AnalyticsService {
  // Verify events without sending to Firebase
}
```

### Infrastructure Mocks
```dart
// Shared Preferences Mock
class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, dynamic> _store = {};
  // In-memory storage for tests
}

// Network Info Mock
class MockNetworkInfo extends Mock implements NetworkInfo {
  // Control network state for testing offline scenarios
}
```

## Test Fixtures Design

### User Fixtures
```dart
class AuthFixtures {
  static final testUser = AuthUser(
    uid: 'test-user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://example.com/photo.jpg',
    authProvider: AuthProviderType.email,
    isEmailVerified: true,
  );

  static final adminUser = AuthUser(
    uid: 'admin-user-456',
    email: 'admin@example.com',
    displayName: 'Admin User',
    role: 'admin',
  );
}
```

### Auth State Fixtures
```dart
class AuthStateFixtures {
  static final authenticated = AuthState(
    status: AuthStatus.authenticated,
    user: AuthFixtures.testUser,
    error: null,
  );

  static final unauthenticated = AuthState(
    status: AuthStatus.unauthenticated,
    user: null,
    error: null,
  );

  static final loading = AuthState(
    status: AuthStatus.loading,
    user: null,
    error: null,
  );

  static final error = AuthState(
    status: AuthStatus.error,
    user: null,
    error: 'Invalid credentials',
  );
}
```

### Token Fixtures
```dart
class TokenFixtures {
  static final validToken = AuthToken(
    accessToken: 'mock-access-token-abc123',
    refreshToken: 'mock-refresh-token-xyz789',
    expiresAt: DateTime.now().add(Duration(hours: 1)),
  );

  static final expiredToken = AuthToken(
    accessToken: 'expired-access-token',
    refreshToken: 'expired-refresh-token',
    expiresAt: DateTime.now().subtract(Duration(hours: 1)),
  );
}
```

## Error Scenario Fixtures

### Common Error Cases
```dart
class AuthErrorFixtures {
  static const invalidCredentials = 'auth/wrong-password';
  static const userNotFound = 'auth/user-not-found';
  static const userDisabled = 'auth/user-disabled';
  static const networkError = 'auth/network-request-failed';
  static const tooManyRequests = 'auth/too-many-requests';
  static const invalidEmail = 'auth/invalid-email';
  static const emailInUse = 'auth/email-already-in-use';
  static const weakPassword = 'auth/weak-password';
}
```

## Dependency Injection for Tests

### Test DI Configuration
```dart
class TestDIModule {
  static void configureDependencies(GetIt getIt) {
    // Register mocks instead of real implementations
    getIt.registerSingleton<FirebaseAuth>(MockFirebaseAuth());
    getIt.registerSingleton<FirebaseFirestore>(MockFirebaseFirestore());
    getIt.registerSingleton<GoogleSignIn>(MockGoogleSignIn());

    // Register real implementations that depend on mocks
    getIt.registerFactory<IAuthRepository>(
      () => AuthRepositoryImpl(
        firebaseAuth: getIt<FirebaseAuth>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    );

    // Register UseCases with mocked dependencies
    getIt.registerFactory(
      () => GetCurrentUserUseCase(getIt<IAuthRepository>()),
    );
  }
}
```

## Test Execution Strategy

### Unit Test Structure
```dart
void main() {
  late MockAuthRepository mockRepository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  group('GetCurrentUserUseCase', () {
    test('should return current user when authenticated', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
        .thenAnswer((_) async => Result.success(AuthFixtures.testUser));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, AuthFixtures.testUser);
      verify(mockRepository.getCurrentUser()).called(1);
    });

    test('should return error when not authenticated', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
        .thenAnswer((_) async => Result.failure('No user'));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'No user');
    });
  });
}
```

## Coverage Strategy

### Target Areas
```yaml
business_logic:
  usecases: 100% coverage required
  repositories: 90% coverage required
  adapters: 80% coverage required

data_layer:
  datasources: Mock-based testing only
  mappers: 100% coverage for transformations

presentation:
  providers: State management testing
  widgets: Excluded from initial migration
```

### Coverage Commands
```bash
# Run tests with coverage
flutter test lib/features/auth/test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View coverage
open coverage/html/index.html

# Check coverage threshold
lcov --summary coverage/lcov.info | grep lines
# Expected: lines......: 80.0% or higher
```

## Validation Without App Execution

### Phase 1: Mock Validation
- Verify all mocks compile
- Ensure mock interfaces match real services
- Test fixture data is valid

### Phase 2: Unit Test Validation
- Each UseCase has passing tests
- All error scenarios covered
- No real Firebase calls

### Phase 3: Coverage Validation
- Business logic at 100%
- Overall feature at 80%+
- No untested UseCases

### Phase 4: Static Analysis
- `flutter analyze lib/features/auth`
- No linter warnings
- Clean architecture rules followed

## Migration Safety

### Rollback Points
1. Before UseCase creation - tag: `pre-usecase-creation`
2. After mock infrastructure - tag: `mock-infra-complete`
3. After unit tests written - tag: `tests-complete`
4. After implementation - tag: `implementation-complete`

### Verification at Each Step
```bash
# After mock creation
flutter test lib/features/auth/test/mocks

# After test writing
flutter test lib/features/auth/test/unit --dry-run

# After implementation
flutter test lib/features/auth/test/unit

# Final verification
flutter analyze lib/features/auth && \
flutter test lib/features/auth/test --coverage
```

## Conclusions

### Key Decisions
1. **Full Isolation**: Test auth feature completely independently
2. **Mock Everything**: All external dependencies mocked
3. **Unit Tests Only**: No integration tests until app builds
4. **80% Coverage**: Through business logic testing alone
5. **Incremental Validation**: Test each component as created

### Benefits of This Approach
- Can proceed despite app build errors
- Fast test execution (milliseconds)
- Clear contracts through mocks
- High confidence in business logic
- Foundation for future integration tests

### Next Steps
1. Create mock infrastructure
2. Write failing tests for each UseCase
3. Implement UseCases to pass tests
4. Verify coverage meets targets
5. Plan integration tests for when app stabilizes

---
*This research establishes the isolation strategy necessary due to current build constraints*