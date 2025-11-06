# Auth Feature - Riverpod 3.x Migration Guide (Phase 3-5)

**문서 버전**: 1.0.0
**작성일**: 2025-11-06
**대상 Feature**: Auth
**참조 Feature**: Creation (Riverpod 3.x 완료)
**이전 문서**: [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)

---

## 📋 목차

- [Phase 3: Code Generation (코드 생성)](#phase-3-code-generation-코드-생성)
- [Phase 4: Widget Updates (위젯 업데이트)](#phase-4-widget-updates-위젯-업데이트)
- [Phase 5: Testing & Documentation (테스트 및 문서화)](#phase-5-testing--documentation-테스트-및-문서화)
- [Appendix B: Creation Feature 참조](#appendix-b-creation-feature-참조)
- [Appendix C: Auth Feature 현재 구조](#appendix-c-auth-feature-현재-구조)
- [Appendix D: 전체 마이그레이션 체크리스트](#appendix-d-전체-마이그레이션-체크리스트)

---

## Phase 3: Code Generation (코드 생성)

**목표**: build_runner로 .g.dart 파일 생성
**소요 시간**: 15-30분
**난이도**: 하 (★☆☆☆☆)

### 3.1 build_runner 실행

#### 3.1.1 코드 생성 명령어

**방법 1: 일회성 생성 (추천)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**방법 2: Watch 모드 (개발 중)**
```bash
dart run build_runner watch --delete-conflicting-outputs
```

**예상 출력**:
```
[INFO] Generating build script completed, took 423ms
[INFO] Creating build script snapshot... completed, took 12.3s
[INFO] Initializing inputs
[INFO] Building new asset graph completed, took 1.2s
[INFO] Checking for unexpected pre-existing outputs. completed, took 1ms
[INFO] Running build completed, took 8.4s
[INFO] Caching finalized dependency graph completed, took 54ms
[INFO] Succeeded after 8.5s with 2 outputs (4 actions)

Generated files:
  lib/features/auth/presentation/providers/auth_providers.g.dart
  lib/features/auth/presentation/providers/usecase_providers.g.dart
```

#### 3.1.2 생성된 파일 확인

```bash
# 생성된 파일 목록 확인
ls -la lib/features/auth/presentation/providers/*.g.dart

# 예상 출력:
# -rw-r--r--  1 user  staff  3456 Nov  6 15:30 auth_providers.g.dart
# -rw-r--r--  1 user  staff  2891 Nov  6 15:30 usecase_providers.g.dart
```

**파일 내용 샘플** (`auth_providers.g.dart` 일부):
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateStreamHash() => r'e1c5a8b9...'; // Auto-generated hash

/// Firebase Authentication 실시간 상태 Stream Provider
@ProviderFor(authStateStream)
final authStateStreamProvider =
    AutoDisposeStreamProviderFamily<AuthUser?, AuthStateParams>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateStreamRef
    = AutoDisposeStreamProviderRef<AuthUser?>;

// ... (more generated code)
```

---

### 3.2 에러 처리 및 해결

#### 3.2.1 일반적인 에러

**에러 1: Part directive 누락**
```
Error: The part directive uses '...' which is not a part of the augmentation libraries of this library.
```

**해결**:
```dart
// auth_providers.dart 상단에 추가
part 'auth_providers.g.dart';

// usecase_providers.dart 상단에 추가
part 'usecase_providers.g.dart';
```

**에러 2: Import 경로 오류**
```
Error: Can't use 'Ref' as a type because it's imported with a prefix.
```

**해결**:
```dart
// 올바른 import
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 잘못된 import (제거)
import 'package:flutter_riverpod/legacy.dart';
```

**에러 3: build_runner 버전 충돌**
```
Error: The plugin `riverpod_generator` uses a deprecated API that is incompatible with your version of `build_runner`.
```

**해결**:
```bash
# pubspec.yaml 버전 확인 및 업데이트
flutter pub upgrade riverpod_generator
flutter pub upgrade build_runner

# 캐시 정리 후 재시도
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 3.2.2 에러 해결 체크리스트

- [ ] `part 'xxx.g.dart';` 지시문 추가 확인
- [ ] `import 'package:riverpod_annotation/riverpod_annotation.dart';` 추가 확인
- [ ] `@riverpod` annotation 정확히 사용 확인
- [ ] 함수 시그니처 확인: `Type functionName(Ref ref, [params]) {}`
- [ ] Notifier 클래스: `class ClassName extends _$ClassName`
- [ ] build_runner 버전 확인 (pubspec.yaml)

---

### 3.3 생성된 코드 검증

#### 3.3.1 자동 생성된 Provider 확인

**usecase_providers.g.dart 검증**:
```bash
# 10개 UseCase Provider 생성 확인
grep -c "Provider" lib/features/auth/presentation/providers/usecase_providers.g.dart
# 예상: 10 이상
```

**auth_providers.g.dart 검증**:
```bash
# 5개 Provider 생성 확인 (Stream, 2 Notifiers, 2 Future)
grep -c "Provider" lib/features/auth/presentation/providers/auth_providers.g.dart
# 예상: 5 이상
```

#### 3.3.2 컴파일 확인

```bash
# Dart 분석
flutter analyze

# 예상 출력:
# Analyzing versus-cursor...
# No issues found!
```

**컴파일 테스트**:
```bash
# 앱 빌드 테스트 (컴파일만, 실행 안 함)
flutter build apk --debug --target-platform android-arm64

# 또는 iOS
flutter build ios --simulator

# 성공 시:
# ✓ Built build/app/outputs/flutter-apk/app-debug.apk.
```

---

### Phase 3 완료 체크리스트

- [ ] `dart run build_runner build --delete-conflicting-outputs` 실행 완료
- [ ] `auth_providers.g.dart` 파일 생성 확인
- [ ] `usecase_providers.g.dart` 파일 생성 확인
- [ ] 컴파일 에러 없음 (`flutter analyze` 통과)
- [ ] Git 커밋: `git commit -m "chore(auth): Phase 3 - Code generation complete"`

---

## Phase 4: Widget Updates (위젯 업데이트)

**목표**: Provider 이름 변경에 따른 위젯 업데이트
**소요 시간**: 30분-1시간
**난이도**: 하 (★☆☆☆☆)

**Note**: Auth 위젯은 이미 `ConsumerWidget` 및 `ref.watch/read` 패턴을 사용하고 있으므로, **대부분 변경 불필요**합니다.

### 4.1 영향받는 위젯 확인

#### 4.1.1 Provider 사용처 검색

```bash
# authLoadingProvider 사용처 검색
grep -r "authLoadingProvider" lib/features/auth/presentation/

# authErrorProvider 사용처 검색
grep -r "authErrorProvider" lib/features/auth/presentation/

# authStateStreamProvider 사용처 검색
grep -r "authStateStreamProvider" lib/features/auth/presentation/

# UseCase Provider 사용처 검색
grep -r "signInWithEmailUseCaseProvider" lib/features/auth/presentation/
```

#### 4.1.2 예상 영향 위젯 목록

| 위젯 파일 | 사용 Provider | 변경 필요 여부 |
|-----------|--------------|--------------|
| `sign_in_screen.dart` | signInWithEmailUseCaseProvider | ❌ 불필요 |
| `sign_in_screen.dart` | authLoadingProvider | ✅ 필요 |
| `sign_in_screen.dart` | authErrorProvider | ✅ 필요 |
| `sign_up_screen.dart` | signUpWithEmailUseCaseProvider | ❌ 불필요 |
| `sign_up_screen.dart` | authLoadingProvider | ✅ 필요 |
| `profile_screen.dart` | currentUserProvider | ❌ 불필요 |
| `settings_screen.dart` | signOutUseCaseProvider | ❌ 불필요 |

**변경 필요 이유**:
- ✅ **StateProvider → Notifier**: `.notifier.state` → `.notifier.setLoading()`
- ❌ **UseCase/Stream/Future Provider**: Provider 이름 동일, 변경 불필요

---

### 4.2 StateProvider → Notifier 변경

#### 4.2.1 authLoadingProvider 변경

**Before (Riverpod 2.x)**:
```dart
// 로딩 시작
ref.read(authLoadingProvider.notifier).state = true;

// 로딩 종료
ref.read(authLoadingProvider.notifier).state = false;

// 로딩 상태 감시
final isLoading = ref.watch(authLoadingProvider);
if (isLoading) return CircularProgressIndicator();
```

**After (Riverpod 3.x)**:
```dart
// 로딩 시작
ref.read(authLoadingProvider.notifier).setLoading(true);

// 로딩 종료
ref.read(authLoadingProvider.notifier).setLoading(false);

// 로딩 상태 감시 (동일)
final isLoading = ref.watch(authLoadingProvider);
if (isLoading) return CircularProgressIndicator();
```

**변화**:
- ✅ `.notifier.state = value` → `.notifier.setLoading(value)`
- ✅ `ref.watch()` 사용법은 동일

#### 4.2.2 authErrorProvider 변경

**Before (Riverpod 2.x)**:
```dart
// 에러 설정
ref.read(authErrorProvider.notifier).state = 'Invalid credentials';

// 에러 초기화
ref.read(authErrorProvider.notifier).state = null;

// 에러 메시지 감시
final errorMessage = ref.watch(authErrorProvider);
if (errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}
```

**After (Riverpod 3.x)**:
```dart
// 에러 설정
ref.read(authErrorProvider.notifier).setError('Invalid credentials');

// 에러 초기화
ref.read(authErrorProvider.notifier).clear();

// 에러 메시지 감시 (동일)
final errorMessage = ref.watch(authErrorProvider);
if (errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}
```

**변화**:
- ✅ `.notifier.state = error` → `.notifier.setError(error)`
- ✅ `.notifier.state = null` → `.notifier.clear()`
- ✅ `ref.watch()` 사용법은 동일

---

### 4.3 UseCase Provider 사용법 (변경 불필요)

**Provider 이름이 동일**하므로 위젯 코드 변경 불필요:

```dart
// Before (Riverpod 2.x) - 동일
final useCase = ref.read(signInWithEmailUseCaseProvider);
final result = await useCase(email: email, password: password);

// After (Riverpod 3.x) - 동일
final useCase = ref.read(signInWithEmailUseCaseProvider);
final result = await useCase(email: email, password: password);
```

**이유**:
- ✅ Provider 이름 동일 (`signInWithEmailUseCaseProvider`)
- ✅ 반환 타입 동일 (`SignInWithEmailUseCase`)
- ✅ 사용법 동일 (`ref.read()`)

---

### 4.4 StreamProvider 사용법 (변경 불필요)

```dart
// Before (Riverpod 2.x) - 동일
final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));

authState.when(
  loading: () => CircularProgressIndicator(),
  error: (e, s) => ErrorWidget(e),
  data: (user) => user == null ? LoginScreen() : HomeScreen(),
);

// After (Riverpod 3.x) - 동일
final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));

authState.when(
  loading: () => CircularProgressIndicator(),
  error: (e, s) => ErrorWidget(e),
  data: (user) => user == null ? LoginScreen() : HomeScreen(),
);
```

**이유**:
- ✅ Provider 이름 동일 (`authStateStreamProvider`)
- ✅ 파라미터 타입 동일 (`AuthStateParams`)
- ✅ AsyncValue 패턴 동일

---

### 4.5 FutureProvider 사용법 (변경 불필요)

```dart
// Before (Riverpod 2.x) - 동일
final currentUserAsync = ref.watch(currentUserProvider);

currentUserAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
  data: (user) => user == null ? LoginScreen() : HomeScreen(),
);

// After (Riverpod 3.x) - 동일
final currentUserAsync = ref.watch(currentUserProvider);

currentUserAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
  data: (user) => user == null ? LoginScreen() : HomeScreen(),
);
```

**이유**:
- ✅ Provider 이름 동일 (`currentUserProvider`)
- ✅ 반환 타입 동일 (`Future<AuthUser?>`)
- ✅ AsyncValue 패턴 동일

---

### 4.6 실제 위젯 변경 예시

#### 예시 1: SignInScreen (가상)

**Before (Riverpod 2.x)**:
```dart
class SignInScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  Future<void> _handleSignIn() async {
    // 로딩 시작
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;  // 에러 초기화

    try {
      final useCase = ref.read(signInWithEmailUseCaseProvider);
      final result = await useCase(
        email: _emailController.text,
        password: _passwordController.text,
      );

      result.fold(
        (failure) {
          // 에러 처리
          ref.read(authErrorProvider.notifier).state = failure.message;
        },
        (user) {
          // 성공 처리
          Navigator.pushReplacementNamed(context, '/home');
        },
      );
    } finally {
      // 로딩 종료
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final errorMessage = ref.watch(authErrorProvider);

    return Scaffold(
      body: Column(
        children: [
          if (errorMessage != null)
            ErrorBanner(message: errorMessage),

          ElevatedButton(
            onPressed: isLoading ? null : _handleSignIn,
            child: isLoading
                ? CircularProgressIndicator()
                : Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

**After (Riverpod 3.x)**:
```dart
class SignInScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  Future<void> _handleSignIn() async {
    // 로딩 시작
    ref.read(authLoadingProvider.notifier).setLoading(true);
    ref.read(authErrorProvider.notifier).clear();  // 에러 초기화

    try {
      final useCase = ref.read(signInWithEmailUseCaseProvider);
      final result = await useCase(
        email: _emailController.text,
        password: _passwordController.text,
      );

      result.fold(
        (failure) {
          // 에러 처리
          ref.read(authErrorProvider.notifier).setError(failure.message);
        },
        (user) {
          // 성공 처리
          Navigator.pushReplacementNamed(context, '/home');
        },
      );
    } finally {
      // 로딩 종료
      ref.read(authLoadingProvider.notifier).setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final errorMessage = ref.watch(authErrorProvider);

    return Scaffold(
      body: Column(
        children: [
          if (errorMessage != null)
            ErrorBanner(message: errorMessage),

          ElevatedButton(
            onPressed: isLoading ? null : _handleSignIn,
            child: isLoading
                ? CircularProgressIndicator()
                : Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

**변경 사항 요약**:
1. `.notifier.state = true` → `.notifier.setLoading(true)`
2. `.notifier.state = false` → `.notifier.setLoading(false)`
3. `.notifier.state = null` → `.notifier.clear()`
4. `.notifier.state = error` → `.notifier.setError(error)`
5. 나머지 코드는 **동일**

---

### Phase 4 완료 체크리스트

- [ ] authLoadingProvider 사용처 모두 변경 (`.state` → `.setLoading()`)
- [ ] authErrorProvider 사용처 모두 변경 (`.state` → `.setError()`/`.clear()`)
- [ ] 컴파일 에러 없음
- [ ] 위젯 Hot Reload 테스트
- [ ] Git 커밋: `git commit -m "refactor(auth): Phase 4 - Update widgets for Notifier API"`

---

## Phase 5: Testing & Documentation (테스트 및 문서화)

**목표**: 마이그레이션 검증 및 문서 업데이트
**소요 시간**: 1-2시간
**난이도**: 중 (★★★☆☆)

### 5.1 수동 테스트

#### 5.1.1 인증 플로우 테스트

**테스트 체크리스트**:

**이메일/비밀번호 로그인**:
- [ ] 로그인 화면 표시
- [ ] 이메일/비밀번호 입력
- [ ] "로그인" 버튼 클릭
- [ ] 로딩 인디케이터 표시 확인
- [ ] 성공 시 홈 화면 이동
- [ ] 실패 시 에러 메시지 표시

**소셜 로그인 (Google)**:
- [ ] "Google로 로그인" 버튼 클릭
- [ ] Google 로그인 팝업 표시
- [ ] 계정 선택
- [ ] 성공 시 홈 화면 이동
- [ ] 실패 시 에러 메시지 표시

**소셜 로그인 (Apple)** (iOS/macOS만):
- [ ] "Apple로 로그인" 버튼 클릭
- [ ] Face ID/Touch ID 인증
- [ ] 성공 시 홈 화면 이동
- [ ] 실패 시 에러 메시지 표시

**회원가입**:
- [ ] 회원가입 화면 표시
- [ ] 이메일/비밀번호/비밀번호 확인 입력
- [ ] "회원가입" 버튼 클릭
- [ ] 로딩 인디케이터 표시
- [ ] 성공 시 이메일 인증 화면 이동
- [ ] 실패 시 에러 메시지 표시

**비밀번호 재설정**:
- [ ] "비밀번호를 잊으셨나요?" 클릭
- [ ] 이메일 입력
- [ ] "재설정 링크 보내기" 클릭
- [ ] 성공 메시지 표시
- [ ] 이메일 수신 확인

**로그아웃**:
- [ ] 프로필/설정 화면에서 "로그아웃" 클릭
- [ ] 확인 다이얼로그 표시
- [ ] "확인" 클릭
- [ ] 로그인 화면 이동

**계정 삭제**:
- [ ] 설정 화면에서 "계정 삭제" 클릭
- [ ] 경고 다이얼로그 표시
- [ ] "삭제" 확인
- [ ] 재인증 요구 (필요 시)
- [ ] 계정 삭제 성공
- [ ] 로그인 화면 이동

#### 5.1.2 Provider 상태 검증

**Riverpod DevTools 사용**:
```bash
# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools
```

**확인 사항**:
- [ ] authStateStreamProvider: Firebase Auth 상태 실시간 반영
- [ ] authLoadingProvider: 로딩 상태 정확히 변경
- [ ] authErrorProvider: 에러 메시지 정확히 설정/초기화
- [ ] currentUserProvider: 현재 사용자 정보 정확
- [ ] UseCaseProvider들: GetIt에서 정상 주입

---

### 5.2 자동 테스트

#### 5.2.1 Provider 테스트

**예시: authLoadingProvider 테스트**

```dart
// test/features/auth/presentation/providers/auth_loading_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_space/features/auth/presentation/providers/auth_providers.dart';

void main() {
  group('AuthLoading Notifier', () {
    test('initial state is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authLoadingProvider);
      expect(state, false);
    });

    test('setLoading changes state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 로딩 시작
      container.read(authLoadingProvider.notifier).setLoading(true);
      expect(container.read(authLoadingProvider), true);

      // 로딩 종료
      container.read(authLoadingProvider.notifier).setLoading(false);
      expect(container.read(authLoadingProvider), false);
    });

    test('reset sets state to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 로딩 시작
      container.read(authLoadingProvider.notifier).setLoading(true);
      expect(container.read(authLoadingProvider), true);

      // 리셋
      container.read(authLoadingProvider.notifier).reset();
      expect(container.read(authLoadingProvider), false);
    });
  });
}
```

**예시: authErrorProvider 테스트**

```dart
// test/features/auth/presentation/providers/auth_error_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_space/features/auth/presentation/providers/auth_providers.dart';

void main() {
  group('AuthError Notifier', () {
    test('initial state is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authErrorProvider);
      expect(state, null);
    });

    test('setError changes state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const errorMessage = 'Invalid credentials';
      container.read(authErrorProvider.notifier).setError(errorMessage);

      expect(container.read(authErrorProvider), errorMessage);
    });

    test('clear sets state to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 에러 설정
      container.read(authErrorProvider.notifier).setError('Some error');
      expect(container.read(authErrorProvider), 'Some error');

      // 초기화
      container.read(authErrorProvider.notifier).clear();
      expect(container.read(authErrorProvider), null);
    });
  });
}
```

#### 5.2.2 테스트 실행

```bash
# 모든 Auth Provider 테스트 실행
flutter test test/features/auth/presentation/providers/

# 특정 테스트 실행
flutter test test/features/auth/presentation/providers/auth_loading_test.dart

# 커버리지 포함
flutter test --coverage test/features/auth/presentation/providers/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

### 5.3 문서 업데이트

#### 5.3.1 README.md 업데이트

**파일**: `lib/features/auth/README.md`

**추가할 섹션**:

```markdown
## 상태 관리

**Riverpod 3.x** ✅ 완료 (2025-11-06)

### Provider 구조

**UseCase Providers** (`usecase_providers.dart`):
- 10개 UseCase Provider
- GetIt 통합
- @riverpod function 패턴

**State Providers** (`auth_providers.dart`):
- 1개 StreamProvider: `authStateStream`
- 2개 Notifier: `AuthLoading`, `AuthError`
- 2개 FutureProvider: `currentUser`, `currentUserId`

### 마이그레이션 완료

- ✅ Phase 1: Preparation (2025-11-06)
- ✅ Phase 2: Provider Migration (2025-11-06)
- ✅ Phase 3: Code Generation (2025-11-06)
- ✅ Phase 4: Widget Updates (2025-11-06)
- ✅ Phase 5: Testing & Documentation (2025-11-06)

**참조 문서**:
- [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)
- [RIVERPOD_3X_MIGRATION_PHASE_3_5.md](./RIVERPOD_3X_MIGRATION_PHASE_3_5.md)

### 코드 감소

- Before: 248 lines (1 file)
- After: ~320 lines (2 files)
- Boilerplate 감소: ~29 lines
- 실질적 코드: ~250 lines (주석 제외)
```

#### 5.3.2 프로젝트 루트 CLAUDE.md 업데이트

**파일**: `/CLAUDE.md`

**Feature 상태 테이블 업데이트**:

```markdown
| Feature | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 | Status |
|---------|---------|---------|---------|---------|---------|--------|
| **Auth** | ✅ Riverpod 3.x | ✅ Riverpod 3.x | ✅ Riverpod 3.x | ✅ Riverpod 3.x | ✅ Riverpod 3.x | 🟢 100% |
| **Profile** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Extension | - | 🟢 100% |
| **Chat** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Idempotency | ✅ Extension | 🟢 100% |
| **Notifications** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Idempotency | ✅ Extension | 🟢 100% |
| **Post** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Idempotency | ✅ Extension | 🟢 100% |
| Creation | 🔄 | 🔄 | 🔄 | 🔄 | 🔄 | 🟡 In Progress |
| Search | 🔄 | 🔄 | 🔄 | 🔄 | 🔄 | 🟡 In Progress |
| Voting | 🔄 | 🔄 | 🔄 | 🔄 | 🔄 | 🟡 In Progress |
```

---

### Phase 5 완료 체크리스트

#### 수동 테스트
- [ ] 이메일/비밀번호 로그인 테스트
- [ ] Google 소셜 로그인 테스트 (Android/iOS)
- [ ] Apple 소셜 로그인 테스트 (iOS/macOS)
- [ ] 회원가입 플로우 테스트
- [ ] 비밀번호 재설정 테스트
- [ ] 로그아웃 테스트
- [ ] 계정 삭제 테스트

#### 자동 테스트
- [ ] authLoadingProvider 테스트 작성 및 통과
- [ ] authErrorProvider 테스트 작성 및 통과
- [ ] 기존 Widget 테스트 통과 확인
- [ ] 커버리지 80% 이상

#### 문서화
- [ ] `lib/features/auth/README.md` 업데이트
- [ ] 프로젝트 루트 `CLAUDE.md` Feature 상태 업데이트
- [ ] 마이그레이션 노트 추가

#### 최종 검증
- [ ] `flutter analyze` 통과 (no issues)
- [ ] `flutter test` 통과 (all tests pass)
- [ ] 앱 실행 및 전체 플로우 테스트
- [ ] Git 커밋: `git commit -m "docs(auth): Phase 5 - Complete Riverpod 3.x migration"`

---

## Appendix B: Creation Feature 참조

### Creation Feature Riverpod 3.x 패턴

**파일**: `lib/features/creation/presentation/providers/usecase_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/create_post_usecase.dart';

part 'usecase_providers.g.dart';

/// Create Post UseCase Provider
@riverpod
CreatePostUseCase createPostUseCase(Ref ref) {
  return getIt<CreatePostUseCase>();
}
```

**패턴**:
- ✅ `@riverpod` annotation
- ✅ `Ref ref` 파라미터
- ✅ GetIt 통합: `getIt<T>()`
- ✅ 간결한 함수형 스타일

**Auth Feature 적용**:
- ✅ 동일한 패턴 사용
- ✅ 10개 UseCase Provider 모두 동일 구조
- ✅ 섹션별 주석으로 구분

---

## Appendix C: Auth Feature 현재 구조

### Before Riverpod 3.x Migration

```
lib/features/auth/presentation/providers/
└── auth_providers.dart           # 248 lines, 15 providers
    ├── UseCase Providers (10)    # Line 34-81
    ├── StreamProvider (1)        # Line 105-134
    ├── StateProvider (2)         # Line 175-197
    └── FutureProvider (2)        # Line 219-247
```

### After Riverpod 3.x Migration

```
lib/features/auth/presentation/providers/
├── auth_providers.dart           # ~150 lines (state management)
│   ├── StreamProvider (1)        # authStateStream
│   ├── Notifier (2)              # AuthLoading, AuthError
│   └── FutureProvider (2)        # currentUser, currentUserId
├── auth_providers.g.dart         # 🆕 Generated (~3.5KB)
├── usecase_providers.dart        # ~170 lines (UseCase wrappers)
│   └── UseCase Providers (10)    # GetIt integration
└── usecase_providers.g.dart      # 🆕 Generated (~2.9KB)
```

---

## Appendix D: 전체 마이그레이션 체크리스트

### Phase 1: Preparation
- [x] 의존성 확인 (pubspec.yaml)
- [x] 파일 구조 설계
- [x] Git 브랜치 생성
- [x] 백업 전략 수립

### Phase 2: Provider Migration
- [x] usecase_providers.dart 새 파일 생성
- [x] 10개 UseCase Provider 변환
- [x] authStateStreamProvider 변환
- [x] authLoadingProvider → Notifier 변환
- [x] authErrorProvider → Notifier 변환
- [x] currentUserProvider 변환
- [x] currentUserIdProvider 변환
- [x] part 지시문 추가
- [x] Import 경로 정리

### Phase 3: Code Generation
- [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
- [ ] auth_providers.g.dart 생성 확인
- [ ] usecase_providers.g.dart 생성 확인
- [ ] 컴파일 에러 해결
- [ ] `flutter analyze` 통과

### Phase 4: Widget Updates
- [ ] authLoadingProvider 사용처 변경
- [ ] authErrorProvider 사용처 변경
- [ ] 위젯 컴파일 확인
- [ ] Hot Reload 테스트

### Phase 5: Testing & Documentation
- [ ] 수동 테스트 (로그인/회원가입/로그아웃)
- [ ] 자동 테스트 작성 및 실행
- [ ] README.md 업데이트
- [ ] CLAUDE.md Feature 상태 업데이트
- [ ] 최종 검증

### 최종 완료
- [ ] 모든 테스트 통과
- [ ] 문서 업데이트 완료
- [ ] Git 커밋 및 푸시
- [ ] PR 생성 (선택)

---

**마이그레이션 완료!** 🎉

Auth Feature가 성공적으로 Riverpod 3.x로 마이그레이션되었습니다.

**다음 단계**:
- Voting Feature 마이그레이션 (더 복잡, Auth 경험 활용)
- Creation Feature 완성도 향상
- 전체 프로젝트 Riverpod 3.x 통일
