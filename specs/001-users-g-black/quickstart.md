# Auth Feature - Quick Start Testing Guide 🚀

**격리 테스트 환경에서 Auth 기능을 빠르게 검증하기 위한 가이드**

> ⚠️ **중요**: 현재 앱 전체 빌드 에러로 인해 격리된 단위 테스트만 실행 가능합니다.
> 이 가이드는 Firebase나 앱 실행 없이 Auth 기능을 테스트하는 방법을 설명합니다.

## 📋 Prerequisites

```bash
# Flutter 환경 확인
flutter --version  # 3.0.0+ required

# 의존성 설치
flutter pub get

# Mockito 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🏃‍♂️ Quick Test Execution

### 1. 단일 UseCase 테스트
```bash
# 특정 UseCase만 테스트
flutter test lib/features/auth/test/unit/usecases/get_current_user_test.dart

# 특정 테스트 케이스만 실행
flutter test lib/features/auth/test/unit/usecases/sign_in_test.dart \
  --name "should return user when credentials are valid"
```

### 2. 전체 Auth Feature 테스트
```bash
# 모든 auth 단위 테스트 실행
flutter test lib/features/auth/test/unit

# 커버리지와 함께 실행
flutter test lib/features/auth/test/unit --coverage

# HTML 커버리지 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
```

### 3. 격리 검증 테스트
```bash
# Firebase 의존성 없음 확인
flutter test lib/features/auth/test/unit \
  --name "should not have Firebase dependencies"

# Mock만 사용 확인
flutter test lib/features/auth/test/unit \
  --name "should use only mocks"
```

## 🧪 Test Scenarios

### Scenario 1: Email 로그인 성공
```dart
// test/unit/usecases/sign_in_with_email_test.dart
test('should sign in user with valid email and password', () async {
  // Arrange
  final mockRepo = MockAuthRepository();
  final useCase = SignInWithEmailUseCase(mockRepo);

  when(mockRepo.signInWithEmail(
    email: 'test@example.com',
    password: 'password123',
  )).thenAnswer((_) async => Result.success(AuthFixtures.testUser));

  // Act
  final result = await useCase.execute(
    email: 'test@example.com',
    password: 'password123',
  );

  // Assert
  expect(result.isSuccess, true);
  expect(result.data?.email, 'test@example.com');
  verify(mockRepo.signInWithEmail(
    email: 'test@example.com',
    password: 'password123',
  )).called(1);
});
```

### Scenario 2: 토큰 만료 처리
```dart
// test/unit/usecases/refresh_token_test.dart
test('should refresh token when expired', () async {
  // Arrange
  final mockRepo = MockAuthRepository();
  final useCase = RefreshTokenUseCase(mockRepo);

  when(mockRepo.isTokenValid())
    .thenAnswer((_) async => Result.success(false));
  when(mockRepo.refreshToken())
    .thenAnswer((_) async => Result.success(TokenFixtures.validToken));

  // Act
  final result = await useCase.execute();

  // Assert
  expect(result.isSuccess, true);
  expect(result.data?.isExpired, false);
});
```

### Scenario 3: 소셜 로그인 (Google)
```dart
// test/unit/usecases/sign_in_with_google_test.dart
test('should sign in with Google successfully', () async {
  // Arrange
  final mockRepo = MockAuthRepository();
  final useCase = SignInWithGoogleUseCase(mockRepo);

  when(mockRepo.signInWithGoogle())
    .thenAnswer((_) async => Result.success(AuthFixtures.googleUser));

  // Act
  final result = await useCase.execute();

  // Assert
  expect(result.isSuccess, true);
  expect(result.data?.authProvider, AuthProviderType.google);
});
```

### Scenario 4: 에러 처리
```dart
// test/unit/usecases/sign_in_error_test.dart
test('should handle invalid credentials error', () async {
  // Arrange
  final mockRepo = MockAuthRepository();
  final useCase = SignInWithEmailUseCase(mockRepo);

  when(mockRepo.signInWithEmail(
    email: any,
    password: any,
  )).thenAnswer((_) async => Result.failure('auth/wrong-password'));

  // Act
  final result = await useCase.execute(
    email: 'test@example.com',
    password: 'wrong',
  );

  // Assert
  expect(result.isFailure, true);
  expect(result.error, 'auth/wrong-password');
});
```

## 🏗️ Test Setup

### Mock 인프라 생성
```bash
# 1. Mock 생성 디렉토리 구조
mkdir -p lib/features/auth/test/mocks
mkdir -p lib/features/auth/test/fixtures
mkdir -p lib/features/auth/test/unit/usecases
mkdir -p lib/features/auth/test/unit/repositories

# 2. Mockito 어노테이션 추가
cat > lib/features/auth/test/mocks/generate_mocks.dart << 'EOF'
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_auth_repository.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
])
@GenerateMocks([IAuthRepository])
void main() {}
EOF

# 3. Mock 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test Fixtures 설정
```dart
// test/fixtures/auth_fixtures.dart
class AuthFixtures {
  static final testUser = AuthUser(
    uid: 'test-user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    authProvider: AuthProviderType.email,
    isEmailVerified: true,
    createdAt: DateTime.now(),
  );

  static final googleUser = AuthUser(
    uid: 'google-user-456',
    email: 'google@example.com',
    displayName: 'Google User',
    authProvider: AuthProviderType.google,
    isEmailVerified: true,
    createdAt: DateTime.now(),
  );

  static final unverifiedUser = AuthUser(
    uid: 'unverified-789',
    email: 'unverified@example.com',
    displayName: 'Unverified User',
    authProvider: AuthProviderType.email,
    isEmailVerified: false,
    createdAt: DateTime.now(),
  );
}

class TokenFixtures {
  static final validToken = AuthToken(
    accessToken: 'valid-access-token',
    refreshToken: 'valid-refresh-token',
    expiresAt: DateTime.now().add(Duration(hours: 1)),
  );

  static final expiredToken = AuthToken(
    accessToken: 'expired-access-token',
    refreshToken: 'expired-refresh-token',
    expiresAt: DateTime.now().subtract(Duration(hours: 1)),
  );
}

class ErrorFixtures {
  static const wrongPassword = 'auth/wrong-password';
  static const userNotFound = 'auth/user-not-found';
  static const networkError = 'auth/network-request-failed';
  static const tooManyRequests = 'auth/too-many-requests';
}
```

## 📊 Coverage Targets

### 현재 상태 vs 목표
| Component | Current | Target | Strategy |
|-----------|---------|---------|----------|
| UseCases | 0% | 100% | 모든 UseCase에 대한 단위 테스트 |
| Repositories | 0% | 90% | Mock을 사용한 동작 검증 |
| Adapters | 0% | 80% | 데이터 변환 로직 테스트 |
| **Overall** | **0%** | **80%+** | Business logic 중심 |

### 커버리지 확인 명령어
```bash
# 커버리지 요약 보기
lcov --summary coverage/lcov.info

# 특정 파일 커버리지 확인
lcov --list coverage/lcov.info | grep auth

# 커버리지 임계값 확인 (80% 이상)
coverage_percent=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
if (( $(echo "$coverage_percent >= 80" | bc -l) )); then
  echo "✅ Coverage target met: $coverage_percent%"
else
  echo "❌ Coverage below target: $coverage_percent% (target: 80%)"
fi
```

## 🔍 Debug & Troubleshooting

### Common Issues

#### 1. Mock 생성 실패
```bash
# 해결책: build_runner 캐시 삭제
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. 테스트 타임아웃
```dart
// 해결책: 타임아웃 시간 증가
test('long running test', () async {
  // test code
}, timeout: Timeout(Duration(seconds: 10)));
```

#### 3. Mock 동작 안 함
```dart
// 해결책: when() 설정 확인
// 잘못된 예
when(mockRepo.signIn()) // 파라미터 없음

// 올바른 예
when(mockRepo.signIn(
  email: anyNamed('email'),
  password: anyNamed('password'),
))
```

## 🚦 Validation Steps

### Step 1: Mock 인프라 검증
```bash
# Mock 파일 생성 확인
ls -la lib/features/auth/test/mocks/*.mocks.dart

# Mock import 확인
grep -r "import.*\.mocks\.dart" lib/features/auth/test/
```

### Step 2: 격리 검증
```bash
# Firebase import 없음 확인
if grep -r "import 'package:firebase" lib/features/auth/test/unit/; then
  echo "❌ Firebase dependencies found in unit tests"
else
  echo "✅ No Firebase dependencies in unit tests"
fi
```

### Step 3: 테스트 실행 검증
```bash
# 모든 테스트 실행 및 결과 저장
flutter test lib/features/auth/test/unit --machine > test-results.json

# 실패한 테스트 확인
cat test-results.json | jq '.[] | select(.result == "error")'
```

## 📈 Progress Monitoring

### 테스트 진행 상황 추적
```bash
# 테스트 개수 확인
find lib/features/auth/test/unit -name "*_test.dart" | wc -l

# UseCase별 테스트 상태
for file in lib/features/auth/domain/usecases/*.dart; do
  usecase=$(basename "$file" .dart)
  test_file="lib/features/auth/test/unit/usecases/${usecase}_test.dart"
  if [ -f "$test_file" ]; then
    echo "✅ $usecase: Test exists"
  else
    echo "❌ $usecase: Test missing"
  fi
done
```

## 🎯 Next Steps

### Phase 1: Mock 인프라 구축 (Day 1)
- [ ] Mock 생성 스크립트 실행
- [ ] Test fixtures 파일 생성
- [ ] DI 테스트 설정 구성

### Phase 2: 단위 테스트 작성 (Day 2-3)
- [ ] 각 UseCase별 테스트 파일 생성
- [ ] Happy path 테스트 작성
- [ ] Error case 테스트 추가
- [ ] Edge case 테스트 보완

### Phase 3: UseCase 구현 (Day 4-5)
- [ ] 테스트를 통과시키는 최소 구현
- [ ] Business logic 구현
- [ ] 에러 처리 로직 추가

### Phase 4: 커버리지 달성 (Day 6)
- [ ] 커버리지 분석 및 gap 파악
- [ ] 추가 테스트 작성
- [ ] 80% 커버리지 확인

## 📝 Notes

### 격리 테스트의 장점
✅ **빠른 피드백**: 밀리초 단위 실행 시간
✅ **독립성**: 다른 피처 에러에 영향 없음
✅ **예측 가능**: Mock으로 일관된 결과
✅ **점진적 통합**: 나중에 통합 테스트 추가 가능

### 제약사항
⚠️ 실제 Firebase 동작과 차이 가능
⚠️ 네트워크 레이어 테스트 불가
⚠️ UI 레이어 테스트 제외
⚠️ 실제 토큰 유효성 검증 불가

## 🔄 Atomic Commit Tracking

### Commit Guidelines
```bash
# Each test/implementation pair gets its own commit
git add lib/features/auth/domain/usecases/sign_in_use_case.dart
git add lib/features/auth/test/unit/usecases/sign_in_use_case_test.dart
git commit -m "feat(auth): Add SignInUseCase with tests"

# Track progress in manifest
echo "- [x] SignInUseCase implemented and tested" >> migration_tracking/commit_log.md
```

### Phase Completion Checklist
```bash
# After completing each phase
git tag -a "auth-migration-phase-1" -m "Phase 1: Mock infrastructure complete"
git push origin feature/auth-clean-architecture --tags

# Validate before moving to next phase
flutter analyze lib/features/auth
flutter test lib/features/auth/test --coverage
```

### 마이그레이션 후 TODO
- [ ] 앱 빌드 에러 해결 후 통합 테스트 추가
- [ ] Firebase 에뮬레이터 활용한 E2E 테스트
- [ ] UI 테스트 추가로 90%+ 커버리지 달성
- [ ] 실제 환경에서 smoke test 실행

---

**🚀 Ready to start testing!**

```bash
# Quick start command
flutter test lib/features/auth/test/unit --coverage && \
  echo "Coverage: $(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}')"
```