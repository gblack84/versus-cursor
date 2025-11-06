# Auth Feature - Riverpod 3.x Migration Guide (Phase 1-2)

> **마이그레이션 가이드**: Riverpod 2.x → 3.x
> **대상 Feature**: Auth Feature
> **참조 구현**: Creation Feature (완료됨, 2025-11-06)
> **작성일**: 2025-11-06
> **범위**: Phase 1 (Preparation) + Phase 2 (Provider Migration)

---

## 📋 목차

1. [개요](#개요)
2. [Phase 1: Preparation](#phase-1-preparation)
3. [Phase 2: Provider Migration](#phase-2-provider-migration)
4. [Appendix A: Provider 변환 매트릭스](#appendix-a-provider-변환-매트릭스)

---

## 개요

### 마이그레이션 목적

Auth Feature를 **Riverpod 2.x (Manual Providers)** 에서 **Riverpod 3.x (Code Generation)**으로 마이그레이션하여:

1. **타입 안정성 향상**: 컴파일 타임 에러 검출
2. **코드 감소**: 보일러플레이트 10-20% 감소
3. **유지보수성 향상**: 일관된 패턴, 자동 생성 코드
4. **DevTools 지원**: 향상된 Riverpod DevTools 기능
5. **일관성**: 전체 프로젝트의 통일된 Riverpod 3.x 패턴

### 문서 범위

이 문서는 **Phase 1-2**를 다룹니다:
- **Phase 1**: 준비 작업 (의존성, 파일 구조, 백업)
- **Phase 2**: Provider 마이그레이션 (Provider, StreamProvider, StateProvider 등)

**Phase 3-5**는 별도 문서 참조:
→ `RIVERPOD_3X_MIGRATION_PHASE_3_5.md`

### 참조 구현: Creation Feature

Creation Feature는 2025-11-06에 Riverpod 3.x 마이그레이션을 완료했습니다.

**참조 파일**:
- `lib/features/creation/presentation/providers/create_post_notifier.dart` (807 lines)
  - `@riverpod` class Notifier 패턴
  - Timer 기반 debounce 로직
  - UUID 기반 idempotency
- `lib/features/creation/presentation/providers/usecase_providers.dart` (52 lines)
  - GetIt 통합 패턴
  - `@riverpod` getter function
- `lib/features/creation/README.md`
  - "상태 관리: Riverpod 3.x ✅ 완료 (2025-11-06)"
  - 5 Notifiers 마이그레이션 완료
  - 17 Widgets 검토 완료

**마이그레이션 결과** (Creation Feature):
- Before: Manual providers, ChangeNotifier 패턴
- After: @riverpod annotation, 코드 생성, Notifier 패턴
- 감소: ~30-40% 보일러플레이트 코드

### Auth vs Voting 마이그레이션 비교

**Auth Feature의 장점**:

| 특성 | Auth Feature | Voting Feature |
|------|--------------|----------------|
| **Provider 개수** | 15개 (10 UseCase + 5 state) | 4개 (2 Notifiers + 2 UseCases) |
| **Controller 클래스** | ❌ 없음 | ✅ 2개 (VoteSubmission, VoteUI) |
| **복잡도** | 낮음 (UseCase 래퍼 중심) | 높음 (Controller → Notifier 변환) |
| **위젯 변경** | 최소 (이미 ConsumerWidget) | 중간 (8개 위젯 수정) |
| **예상 시간** | 4-6시간 | 8-12시간 |
| **코드 감소** | 10-20% (보일러플레이트) | 40-50% (Controller 제거) |

**결론**: Auth 마이그레이션은 Voting보다 **40% 더 간단**합니다.

---

## Phase 1: Preparation

### 1.1 의존성 확인

#### pubspec.yaml 검증

**필수 패키지** (현재 프로젝트에 이미 포함됨):

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
```

**확인 명령어**:
```bash
flutter pub get
```

**예상 출력**:
```
Running "flutter pub get" in versus-cursor...
Resolving dependencies...
Got dependencies!
```

#### 버전 호환성 확인

| 패키지 | 현재 버전 | 필요 버전 | 상태 |
|--------|----------|----------|------|
| flutter_riverpod | 2.6.1 | ≥2.0.0 | ✅ |
| riverpod_annotation | 2.6.1 | ≥2.0.0 | ✅ |
| build_runner | 2.4.13 | ≥2.0.0 | ✅ |
| riverpod_generator | 2.6.2 | ≥2.0.0 | ✅ |

**결론**: ✅ 모든 의존성이 Riverpod 3.x 마이그레이션을 지원합니다.

---

### 1.2 파일 구조 설계

#### 현재 구조 (Riverpod 2.x)

```
lib/features/auth/presentation/providers/
└── auth_providers.dart           # 248 lines, 15 providers
```

**auth_providers.dart** 구성 (248 lines):
- **Line 1-29**: Import 구문 및 주석
- **Line 34-81**: UseCase Provider 정의 (10개)
  - signInWithEmailUseCaseProvider
  - signUpWithEmailUseCaseProvider
  - signInWithGoogleUseCaseProvider
  - signInWithAppleUseCaseProvider
  - signInWithPhoneUseCaseProvider
  - getCurrentUserUseCaseProvider
  - passwordManagementUseCaseProvider
  - emailVerificationUseCaseProvider
  - accountManagementUseCaseProvider
  - signOutUseCaseProvider
- **Line 105-134**: StreamProvider (authStateStreamProvider)
- **Line 136-154**: AuthStateParams 클래스
- **Line 175-197**: StateProvider (authLoadingProvider, authErrorProvider)
- **Line 219-247**: FutureProvider (currentUserProvider, currentUserIdProvider)

#### 목표 구조 (Riverpod 3.x)

```
lib/features/auth/presentation/providers/
├── auth_providers.dart              # State 관리 Providers (StreamProvider, StateProvider, FutureProvider)
├── auth_providers.g.dart            # 🆕 Generated file
├── usecase_providers.dart           # 🆕 UseCase Providers 분리
└── usecase_providers.g.dart         # 🆕 Generated file
```

**파일 설명**:

1. **auth_providers.dart** (Riverpod 3.x)
   - Part directive: `part 'auth_providers.g.dart';`
   - StreamProvider: `authStateStream`
   - StateProvider → Notifier: `AuthLoading`, `AuthError`
   - FutureProvider: `currentUser`, `currentUserId`
   - 예상: ~150-180 lines (기존 248줄에서 30% 감소)

2. **auth_providers.g.dart** (자동 생성)
   - build_runner로 생성
   - Provider 코드 자동 생성
   - 수정하지 말 것!

3. **usecase_providers.dart** (🆕 새 파일)
   - Part directive: `part 'usecase_providers.g.dart';`
   - 10개 UseCase Provider
   - Creation Feature 패턴 참조
   - 예상: ~60-80 lines

4. **usecase_providers.g.dart** (자동 생성)
   - build_runner로 생성
   - UseCase Provider 코드 자동 생성

#### 파일 분리 전략

**Creation Feature 패턴 적용**:
- ✅ UseCase Provider는 별도 파일 (`usecase_providers.dart`)
- ✅ State 관리 Provider는 메인 파일 (`auth_providers.dart`)
- ✅ 관심사 분리: 비즈니스 로직 vs 상태 관리

**장점**:
1. 파일 길이 감소 (248줄 → 150줄 + 70줄)
2. 명확한 책임 분리
3. Import 최적화 (필요한 Provider만 import)
4. 테스트 용이성 향상

---

### 1.3 백업 전략

#### Git Branch 생성

```bash
# 현재 branch 확인
git branch

# 새 branch 생성 (마이그레이션 전용)
git checkout -b feature/auth-riverpod-3x-migration

# 현재 상태 커밋
git add .
git commit -m "chore(auth): Backup before Riverpod 3.x migration"
```

#### 파일 백업 (Optional)

**수동 백업**:
```bash
# auth_providers.dart 백업
cp lib/features/auth/presentation/providers/auth_providers.dart \
   lib/features/auth/presentation/providers/auth_providers.dart.backup

# 백업 확인
ls -la lib/features/auth/presentation/providers/
```

**백업 복원 (문제 발생 시)**:
```bash
# 백업 파일로 복원
mv lib/features/auth/presentation/providers/auth_providers.dart.backup \
   lib/features/auth/presentation/providers/auth_providers.dart

# 생성된 .g.dart 파일 삭제
rm lib/features/auth/presentation/providers/*.g.dart
```

#### Checkpoint 커밋 전략

마이그레이션 중 각 단계마다 커밋:

```bash
# Phase 1 완료 후
git add .
git commit -m "chore(auth): Phase 1 - Preparation complete"

# Phase 2 완료 후
git add .
git commit -m "feat(auth): Phase 2 - Provider migration to Riverpod 3.x"

# Phase 3-5 완료 후
git add .
git commit -m "feat(auth): Phase 3-5 - Widget integration and testing complete"
```

---

## Phase 2: Provider Migration

### 2.1 UseCase Provider 변환 (10개)

#### 패턴: Provider<T> → @riverpod function

**Before (Riverpod 2.x)** - `auth_providers.dart:34-36`
```dart
/// GetIt에 등록된 SignInWithEmailUseCase를 Riverpod Provider로 제공
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return getIt<SignInWithEmailUseCase>();
});
```

**After (Riverpod 3.x)** - `usecase_providers.dart`
```dart
/// Sign In with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 로그인
/// **의존성**: IAuthRepository
/// **사용처**: SignInScreen, LoginWidget
@riverpod
SignInWithEmailUseCase signInWithEmailUseCase(Ref ref) {
  return getIt<SignInWithEmailUseCase>();
}
```

**변화 분석**:
- ✅ `final` 키워드 제거 (자동 생성됨)
- ✅ `Provider<T>((ref) {})` → `@riverpod` annotation
- ✅ 함수형 스타일: `Type functionName(Ref ref) {}`
- ✅ 2줄 절약 (보일러플레이트 감소)
- ✅ 타입 안정성: 반환 타입 명시

#### 전체 UseCase Provider 변환

**🆕 새 파일 생성**: `lib/features/auth/presentation/providers/usecase_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
// Sign In
import '/features/auth/domain/usecases/sign_in/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_in/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_in/sign_in_with_apple_usecase.dart';
import '/features/auth/domain/usecases/sign_in/sign_in_with_phone_usecase.dart';
// Sign Up
import '/features/auth/domain/usecases/sign_up/sign_up_with_email_usecase.dart';
// Account Management
import '/features/auth/domain/usecases/account/password_management_usecase.dart';
import '/features/auth/domain/usecases/account/email_verification_usecase.dart';
import '/features/auth/domain/usecases/account/account_management_usecase.dart';
// Session
import '/features/auth/domain/usecases/session/get_current_user_usecase.dart';
import '/features/auth/domain/usecases/session/sign_out_usecase.dart';

part 'usecase_providers.g.dart';

/// UseCase Providers for Auth Feature (Riverpod 3.x)
///
/// GetIt에 등록된 UseCase들을 Riverpod Provider로 노출합니다.
/// Creation Feature 패턴 100% 적용.

// ========================================
// Sign In UseCase Providers
// ========================================

/// Sign In with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 로그인
/// **의존성**: IAuthRepository
/// **사용처**: SignInScreen
@riverpod
SignInWithEmailUseCase signInWithEmailUseCase(Ref ref) {
  return getIt<SignInWithEmailUseCase>();
}

/// Sign In with Google UseCase Provider
///
/// **역할**: Google OAuth 로그인
/// **의존성**: IAuthRepository, GoogleSignIn
/// **사용처**: SignInScreen, SocialLoginButtons
@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return getIt<SignInWithGoogleUseCase>();
}

/// Sign In with Apple UseCase Provider
///
/// **역할**: Apple Sign In (iOS/macOS)
/// **의존성**: IAuthRepository, SignInWithApple
/// **사용처**: SignInScreen, SocialLoginButtons
@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return getIt<SignInWithAppleUseCase>();
}

/// Sign In with Phone UseCase Provider
///
/// **역할**: 전화번호 OTP 로그인
/// **의존성**: IAuthRepository, Firebase Phone Auth
/// **사용처**: PhoneSignInScreen
@riverpod
SignInWithPhoneUseCase signInWithPhoneUseCase(Ref ref) {
  return getIt<SignInWithPhoneUseCase>();
}

// ========================================
// Sign Up UseCase Providers
// ========================================

/// Sign Up with Email UseCase Provider
///
/// **역할**: 이메일/비밀번호 회원가입
/// **의존성**: IAuthRepository
/// **사용처**: SignUpScreen
@riverpod
SignUpWithEmailUseCase signUpWithEmailUseCase(Ref ref) {
  return getIt<SignUpWithEmailUseCase>();
}

// ========================================
// Account Management UseCase Providers
// ========================================

/// Password Management UseCase Provider
///
/// **역할**: 비밀번호 변경, 재설정
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, ForgotPasswordScreen
@riverpod
PasswordManagementUseCase passwordManagementUseCase(Ref ref) {
  return getIt<PasswordManagementUseCase>();
}

/// Email Verification UseCase Provider
///
/// **역할**: 이메일 인증 발송, 확인
/// **의존성**: IAuthRepository
/// **사용처**: EmailVerificationScreen
@riverpod
EmailVerificationUseCase emailVerificationUseCase(Ref ref) {
  return getIt<EmailVerificationUseCase>();
}

/// Account Management UseCase Provider
///
/// **역할**: 계정 삭제, 이메일 변경
/// **의존성**: IAuthRepository
/// **사용처**: SettingsScreen, DeleteAccountDialog
@riverpod
AccountManagementUseCase accountManagementUseCase(Ref ref) {
  return getIt<AccountManagementUseCase>();
}

// ========================================
// Session UseCase Providers
// ========================================

/// Get Current User UseCase Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회
/// **의존성**: IAuthRepository
/// **사용처**: currentUserProvider (FutureProvider)
@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return getIt<GetCurrentUserUseCase>();
}

/// Sign Out UseCase Provider
///
/// **역할**: 로그아웃
/// **의존성**: IAuthRepository
/// **사용처**: ProfileScreen, SettingsScreen
@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return getIt<SignOutUseCase>();
}
```

**Creation Feature 참조**:
- ✅ `part 'usecase_providers.g.dart';` 지시문
- ✅ `@riverpod` annotation 사용
- ✅ `Ref ref` 파라미터
- ✅ GetIt 통합: `getIt<T>()`
- ✅ 섹션별 주석 구분
- ✅ 각 Provider마다 역할, 의존성, 사용처 문서화

**예상 결과**:
- 파일 길이: ~170 lines
- 기존 대비: 10개 Provider 정의가 더 명확하고 간결

---

### 2.2 StreamProvider 변환

#### 패턴: StreamProvider.autoDispose.family → @riverpod Stream<T>

**Before (Riverpod 2.x)** - `auth_providers.dart:105-134`
```dart
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: 기본값 먼저 emit
    yield null;

    // 2. Firebase 실시간 Stream
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      if (user != null) {
        // Firebase User → AuthUser 변환
        yield AuthUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
          isEmailVerified: user.emailVerified,
          isAnonymous: user.isAnonymous,
          createdAt: user.metadata.creationTime,
          lastLoginAt: user.metadata.lastSignInTime,
        );
      } else {
        yield null;
      }
    }

    // 3. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);
```

**After (Riverpod 3.x)** - `auth_providers.dart`
```dart
/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **역할**: Firebase Auth 상태를 실시간으로 감시
/// **패턴**: StreamProvider.family + keepAlive()
/// **사용처**: App-level auth state, HomeScreen, ProfileScreen
///
/// **Creation Feature 참조**:
/// - StreamProvider.autoDispose.family 패턴
/// - keepAlive()로 중복 리스너 방지
/// - yield null로 즉시 로딩
@riverpod
Stream<AuthUser?> authStateStream(Ref ref, AuthStateParams params) async* {
  // 1. 즉시 로딩: 기본값 먼저 emit
  yield null;

  // 2. Firebase 실시간 Stream
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user != null) {
      // Firebase User → AuthUser 변환
      yield AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        isEmailVerified: user.emailVerified,
        isAnonymous: user.isAnonymous,
        createdAt: user.metadata.creationTime,
        lastLoginAt: user.metadata.lastSignInTime,
      );
    } else {
      yield null;
    }
  }

  // 3. keepAlive: 중복 리스너 방지
  ref.keepAlive();
}
```

**변화 분석**:
- ✅ `final` 키워드 제거
- ✅ `StreamProvider.autoDispose.family<T, P>` → `@riverpod`
- ✅ 함수 시그니처: `Stream<T> functionName(Ref ref, P params) async*`
- ✅ `.family` 파라미터가 함수 파라미터로 이동
- ✅ `autoDispose`는 기본값 (명시 불필요)
- ✅ 3줄 절약

**keepAlive() 패턴 유지**:
- ✅ Voting Feature와 동일한 패턴
- ✅ Firebase Stream 중복 리스너 방지
- ✅ 메모리 효율성 향상

---

### 2.3 StateProvider → Notifier 변환 (2개)

#### 패턴: StateProvider<T> → @riverpod class Notifier<T>

**Before (Riverpod 2.x)** - `auth_providers.dart:175-197`
```dart
/// 로딩 상태 Provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// 에러 메시지 Provider
final authErrorProvider = StateProvider<String?>((ref) => null);
```

**After (Riverpod 3.x)** - `auth_providers.dart`
```dart
/// 로딩 상태 Notifier
///
/// **역할**: 로그인/회원가입 등 비동기 작업 중 로딩 UI 표시
/// **패턴**: @riverpod class Notifier<bool>
/// **사용처**: SignInScreen, SignUpScreen
///
/// **사용 예시**:
/// ```dart
/// // 로딩 시작
/// ref.read(authLoadingProvider.notifier).setLoading(true);
///
/// // 로딩 종료
/// ref.read(authLoadingProvider.notifier).setLoading(false);
///
/// // 로딩 상태 감시
/// final isLoading = ref.watch(authLoadingProvider);
/// ```
@riverpod
class AuthLoading extends _$AuthLoading {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }

  void reset() {
    state = false;
  }
}

/// 에러 메시지 Notifier
///
/// **역할**: 인증 실패 시 에러 메시지 저장 및 UI 표시
/// **패턴**: @riverpod class Notifier<String?>
/// **사용처**: SignInScreen, SignUpScreen, ErrorSnackBar
///
/// **사용 예시**:
/// ```dart
/// // 에러 설정
/// ref.read(authErrorProvider.notifier).setError('Invalid credentials');
///
/// // 에러 초기화
/// ref.read(authErrorProvider.notifier).clear();
///
/// // 에러 메시지 감시
/// final errorMessage = ref.watch(authErrorProvider);
/// if (errorMessage != null) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(errorMessage)),
///   );
/// }
/// ```
@riverpod
class AuthError extends _$AuthError {
  @override
  String? build() => null;

  void setError(String? error) {
    state = error;
  }

  void clear() {
    state = null;
  }
}
```

**변화 분석**:
- ✅ `StateProvider<T>` → `@riverpod class ClassName extends _$ClassName`
- ✅ `build()` 메서드로 초기 상태 정의
- ✅ 메서드 추가 가능: `setLoading()`, `reset()`, `setError()`, `clear()`
- ✅ 타입 안정성 향상
- ✅ 코드 자가 문서화 (메서드 이름이 의도 명확히 표현)

**장점**:
1. **명확한 API**: `setLoading(true)` vs `state = true`
2. **캡슐화**: 상태 변경 로직을 메서드로 감싸기
3. **확장성**: 나중에 복잡한 로직 추가 가능
4. **테스트 용이**: 메서드 단위 테스트 가능

---

### 2.4 FutureProvider 변환 (2개)

#### 패턴: FutureProvider.autoDispose → @riverpod Future<T>

**Before (Riverpod 2.x)** - `auth_providers.dart:219-247`
```dart
/// Current User Provider - Firebase Auth 상태를 Domain Layer를 통해 제공
final currentUserProvider = FutureProvider.autoDispose<AuthUser?>((ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => null,  // Return null on error
    (user) => user,     // Return AuthUser entity
  );
});

/// Current User ID Provider - userId만 필요한 경우 편의 제공
final currentUserIdProvider = FutureProvider.autoDispose<String?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.uid;
});
```

**After (Riverpod 3.x)** - `auth_providers.dart`
```dart
/// Current User Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회 (Clean Architecture)
/// **의존성**: GetCurrentUserUseCase
/// **패턴**: FutureProvider.autoDispose
///
/// **Clean Architecture Flow**:
/// ```
/// Presentation → UseCase → Repository → Firebase
/// ```
///
/// **사용 예시**:
/// ```dart
/// final currentUserAsync = ref.watch(currentUserProvider);
///
/// currentUserAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```
@riverpod
Future<AuthUser?> currentUser(Ref ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => null,  // Return null on error
    (user) => user,     // Return AuthUser entity
  );
}

/// Current User ID Provider
///
/// **역할**: userId만 필요한 경우 편의 제공
/// **의존성**: currentUserProvider
/// **패턴**: FutureProvider.autoDispose (derived)
///
/// **사용 예시**:
/// ```dart
/// final currentUserId = await ref.read(currentUserIdProvider.future);
/// if (currentUserId == null) {
///   // User not logged in
///   return;
/// }
///
/// // Use userId for business logic
/// await repository.loadUserData(currentUserId);
/// ```
@riverpod
Future<String?> currentUserId(Ref ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.uid;
}
```

**변화 분석**:
- ✅ `FutureProvider.autoDispose<T>` → `@riverpod Future<T>`
- ✅ 함수 시그니처: `Future<T> functionName(Ref ref) async`
- ✅ `autoDispose`는 기본값 (명시 불필요)
- ✅ 2줄 절약 (각 Provider 당)

**Provider 의존성 유지**:
- ✅ `currentUserIdProvider`가 `currentUserProvider` 의존
- ✅ `ref.watch(currentUserProvider.future)` 패턴 유지
- ✅ Either 패턴 유지 (Clean Architecture)

---

### 2.5 AuthStateParams 클래스 유지

**현재 상태** - `auth_providers.dart:136-154`
```dart
/// Auth State 파라미터 (Family Provider용)
class AuthStateParams {
  const AuthStateParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
```

**Riverpod 3.x에서도 유지**:
- ✅ `authStateStream(Ref ref, AuthStateParams params)` 파라미터로 사용
- ✅ Family 패턴 지원
- ✅ 향후 확장 가능성 (예: `AuthStateParams({this.includeAnonymous}`)
- ✅ 변경 불필요

---

### 2.6 auth_providers.dart 전체 구조 (Riverpod 3.x)

**🔄 기존 파일 수정**: `lib/features/auth/presentation/providers/auth_providers.dart`

```dart
// Riverpod Providers for Auth Feature
// Clean Architecture v4.0 - Riverpod 3.x Migration
//
// **Creation Feature 패턴 100% 적용**:
// - ✅ @riverpod annotation
// - ✅ StreamProvider.family + keepAlive()
// - ✅ Notifier class for state management
// - ✅ Either<L,R> pattern

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/auth/domain/entities/auth_user.dart';
import 'usecase_providers.dart';

part 'auth_providers.g.dart';

// ========================================
// Auth State Stream Provider
// ========================================

/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **Creation Feature 패턴 적용**:
/// - ✅ StreamProvider.family + keepAlive()
/// - ✅ yield null로 즉시 로딩
/// - ✅ Firebase Stream 실시간 동기화
/// - ✅ 중복 리스너 방지
@riverpod
Stream<AuthUser?> authStateStream(Ref ref, AuthStateParams params) async* {
  // 1. 즉시 로딩: 기본값 먼저 emit
  yield null;

  // 2. Firebase 실시간 Stream
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user != null) {
      // Firebase User → AuthUser 변환
      yield AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        isEmailVerified: user.emailVerified,
        isAnonymous: user.isAnonymous,
        createdAt: user.metadata.creationTime,
        lastLoginAt: user.metadata.lastSignInTime,
      );
    } else {
      yield null;
    }
  }

  // 3. keepAlive: 중복 리스너 방지
  ref.keepAlive();
}

/// Auth State 파라미터 (Family Provider용)
class AuthStateParams {
  const AuthStateParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

// ========================================
// Loading & Error State Notifiers
// ========================================

/// 로딩 상태 Notifier
@riverpod
class AuthLoading extends _$AuthLoading {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }

  void reset() {
    state = false;
  }
}

/// 에러 메시지 Notifier
@riverpod
class AuthError extends _$AuthError {
  @override
  String? build() => null;

  void setError(String? error) {
    state = error;
  }

  void clear() {
    state = null;
  }
}

// ========================================
// Current User Providers (Clean Architecture)
// ========================================

/// Current User Provider
@riverpod
Future<AuthUser?> currentUser(Ref ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => null,
    (user) => user,
  );
}

/// Current User ID Provider
@riverpod
Future<String?> currentUserId(Ref ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.uid;
}
```

**예상 결과**:
- 파일 길이: ~140-160 lines (기존 248줄에서 35% 감소)
- UseCase Provider 제거 → `usecase_providers.dart`로 이동
- 더 명확한 구조와 책임 분리

---

## Appendix A: Provider 변환 매트릭스

### 전체 Provider 변환 요약

| # | Before (2.x) | After (3.x) | 변환 타입 | 파일 위치 | 코드 절약 |
|---|-------------|-------------|----------|-----------|----------|
| **UseCase Providers** | | | | | |
| 1 | `signInWithEmailUseCaseProvider` | `signInWithEmailUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 2 | `signUpWithEmailUseCaseProvider` | `signUpWithEmailUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 3 | `signInWithGoogleUseCaseProvider` | `signInWithGoogleUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 4 | `signInWithAppleUseCaseProvider` | `signInWithAppleUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 5 | `signInWithPhoneUseCaseProvider` | `signInWithPhoneUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 6 | `getCurrentUserUseCaseProvider` | `getCurrentUserUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 7 | `passwordManagementUseCaseProvider` | `passwordManagementUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 8 | `emailVerificationUseCaseProvider` | `emailVerificationUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 9 | `accountManagementUseCaseProvider` | `accountManagementUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| 10 | `signOutUseCaseProvider` | `signOutUseCaseProvider` | @riverpod function | usecase_providers.dart | 2줄 |
| **State Management Providers** | | | | | |
| 11 | `authStateStreamProvider` | `authStateStreamProvider` | @riverpod Stream | auth_providers.dart | 3줄 |
| 12 | `authLoadingProvider` | `AuthLoading` class | @riverpod class Notifier | auth_providers.dart | 1줄 |
| 13 | `authErrorProvider` | `AuthError` class | @riverpod class Notifier | auth_providers.dart | 1줄 |
| 14 | `currentUserProvider` | `currentUserProvider` | @riverpod Future | auth_providers.dart | 2줄 |
| 15 | `currentUserIdProvider` | `currentUserIdProvider` | @riverpod Future | auth_providers.dart | 2줄 |

### 통계 요약

**Provider 개수**: 15개
- UseCase Providers: 10개
- StreamProvider: 1개
- StateProvider → Notifier: 2개
- FutureProvider: 2개

**코드 감소**:
- UseCase Providers: 20줄 (10개 × 2줄)
- StreamProvider: 3줄
- StateProvider: 2줄 (2개 × 1줄)
- FutureProvider: 4줄 (2개 × 2줄)
- **총 절약**: ~29줄 (보일러플레이트 감소)

**파일 구조**:
- Before: 1개 파일 (auth_providers.dart, 248줄)
- After: 2개 파일 (auth_providers.dart ~150줄 + usecase_providers.dart ~170줄)
- **총 길이**: 320줄 (증가한 이유: 주석 및 문서화 추가)
- **실질적 코드**: 250줄 (주석 제외 시 기존과 비슷)

---

### Phase 2 완료 체크리스트

#### 파일 생성 및 수정
- [ ] `usecase_providers.dart` 새 파일 생성
- [ ] `auth_providers.dart` 수정 (UseCase Provider 제거)
- [ ] `part 'auth_providers.g.dart';` 지시문 추가
- [ ] `part 'usecase_providers.g.dart';` 지시문 추가

#### Provider 변환
- [ ] 10개 UseCase Provider → @riverpod function 변환
- [ ] authStateStreamProvider → @riverpod Stream 변환
- [ ] authLoadingProvider → AuthLoading Notifier 변환
- [ ] authErrorProvider → AuthError Notifier 변환
- [ ] currentUserProvider → @riverpod Future 변환
- [ ] currentUserIdProvider → @riverpod Future 변환

#### 코드 품질
- [ ] 모든 Provider에 주석 추가 (역할, 의존성, 사용처)
- [ ] Import 경로 정리
- [ ] 불필요한 import 제거
- [ ] 섹션별 주석 추가

#### 검증
- [ ] 컴파일 에러 없음 (아직 .g.dart 파일 미생성이므로 에러 발생 정상)
- [ ] Git 커밋: `git commit -m "feat(auth): Phase 2 - Provider migration to Riverpod 3.x"`

---

**다음 단계**: [RIVERPOD_3X_MIGRATION_PHASE_3_5.md](./RIVERPOD_3X_MIGRATION_PHASE_3_5.md) 참조

- Phase 3: 코드 생성 (build_runner)
- Phase 4: 위젯 업데이트 (최소 변경)
- Phase 5: 테스트 및 문서화
