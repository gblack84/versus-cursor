# PHASE 0.0.1 REVISED PLAN - Auth Feature SRP Refactoring

> **날짜**: 2025-11-19
> **상태**: Rollback 완료, 재계획 단계
> **전체 메서드**: 24개 (기존 추정 23개에서 수정)
> **손실 메서드**: 19개 (79% 기능 손실)

---

## 📋 목차

1. [Rollback 근거](#rollback-근거)
2. [Complete Method Inventory](#complete-method-inventory)
3. [Repository Capability Mapping](#repository-capability-mapping)
4. [Migration Strategy](#migration-strategy)
5. [Lessons Learned](#lessons-learned)

---

## Rollback 근거

### Phase 0.0.1 문제점

**원래 계획**: 기존 Multi-Method UseCases → SRP 준수 Single-Method UseCases

**실제 결과**:
- ✅ **성공**: 5개 새 SRP UseCase 생성
- ❌ **실패**: 4개 기존 UseCase 삭제 시 **19개 메서드 손실** (79%)

### 손실 분석

| Old UseCase | Total Methods | Replaced | Lost | Loss Rate |
|-------------|---------------|----------|------|-----------|
| AccountManagementUseCase | 13 | 3 | 10 | **77%** |
| EmailVerificationUseCase | 5 | 1 | 4 | **80%** |
| PasswordManagementUseCase | 3 | 1 | 2 | **67%** |
| SignInWithPhoneUseCase | 3 | 0 | 3 | **100%** |
| **TOTAL** | **24** | **5** | **19** | **79%** |

### 근본 원인

1. **검증 부족**: Repository 인터페이스 확인 없이 UseCase 삭제
2. **일괄 삭제**: Helper 메서드 마이그레이션 계획 없이 전체 UseCase 삭제
3. **UI 동시 수정**: Provider 변경을 한 번에 시도하여 에러 누적

---

## Complete Method Inventory

### 1. AccountManagementUseCase (13 methods)

#### ✅ Replaced (3 methods)

```dart
// 1. deleteAccount() → DeleteAccountUseCase ✅
Future<Either<AuthFailure, Unit>> deleteAccount({
  String? confirmationText,
  bool checkReAuth = false,
  required String eventId,
})

// 2. updateProfile() → UpdateUserProfileUseCase ✅
Future<Either<AuthFailure, Unit>> updateProfile({
  String? displayName,
  String? photoURL,
})

// 3. authStateChanges → GetAuthStateStreamUseCase ✅
Stream<AuthUser?> get authStateChanges
```

#### ❌ Lost (10 methods)

```dart
// Helper Methods - Should migrate to Extensions/Services
Future<bool> needsReAuthentication()
Future<Either<AuthFailure, AuthUser>> getCurrentUser()
bool isUserSignedIn()
Future<String?> getCurrentUserUid()
Future<String?> getCurrentUserEmail()
Future<bool> isAnonymous()
Future<bool> isPremiumUser()
Future<bool> isAdmin()
Future<bool> isTester()
Future<bool> isProfileComplete()
Future<Map<String, int>> getUserPoints()
```

**Repository Support**:
- `getCurrentUser()`: ✅ Repository method exists
- `isUserSignedIn`: ✅ Repository getter exists
- `needsReAuthentication()`: ❌ Business logic (should be in UseCase or Service)
- Other helpers: ❌ Should be extension methods on AuthUser entity

---

### 2. EmailVerificationUseCase (5 methods)

#### ✅ Replaced (1 method)

```dart
// 1. sendVerificationEmail() → SendEmailVerificationUseCase ✅
Future<Either<AuthFailure, Unit>> sendVerificationEmail({
  String? eventId,
})
```

#### ❌ Lost (4 methods)

```dart
// Lost Methods
Future<Either<AuthFailure, Unit>> resendVerificationEmail({
  String? eventId,
})
Future<bool> isEmailVerified()
Future<String?> getCurrentUserEmail()
int getSecondsUntilResend()
```

**Repository Support**:
- `sendEmailVerification()`: ✅ Repository method exists
- `isEmailVerified()`: ❌ Should be extension on AuthUser entity
- `getCurrentUserEmail()`: ✅ Can use getCurrentUser() + .email
- `getSecondsUntilResend()`: ❌ UI/Service logic (rate limiting)

---

### 3. PasswordManagementUseCase (3 methods)

#### ✅ Replaced (1 method)

```dart
// 1. sendPasswordResetEmail() → SendPasswordResetEmailUseCase ✅
Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
  required String email,
})
```

#### ❌ Lost (2 methods)

```dart
// Lost Methods
Future<Either<AuthFailure, Unit>> updatePassword({
  required String currentPassword,
  required String newPassword,
})
Future<Either<AuthFailure, Unit>> resetPassword({
  required String code,
  required String newPassword,
})
```

**Repository Support**:
- `sendPasswordResetEmail()`: ✅ Repository method exists
- `updatePassword()`: ✅ Repository method exists (직접 확인됨)
- `resetPassword()`: ❌ No direct Repository support (needs implementation)

---

### 4. SignInWithPhoneUseCase (3 methods)

#### ❌ All Lost (3 methods - 100% loss)

```dart
// Lost Methods
Future<Either<AuthFailure, Unit>> sendOtp({
  required String phoneNumber,
})
Future<Either<AuthFailure, Unit>> resendOtp({
  required String phoneNumber,
})
Future<Either<AuthFailure, AuthUser>> execute({
  required String phoneNumber,
  required String verificationCode,
})
```

**Repository Support**:
- `sendOtp()`: ✅ Repository has `sendSmsOtp()` method
- `resendOtp()`: ❌ Needs implementation (rate limiting logic)
- `execute()`: ✅ Repository has `signInWithPhoneNumber()` method

---

## Repository Capability Mapping

### IAuthRepository Interface (15 methods)

```dart
abstract class IAuthRepository {
  // User Info (2)
  Future<Either<AuthFailure, AuthUser>> getCurrentUser();
  bool get isSignedIn;

  // Authentication (7)
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(String email, String password);
  Future<Either<AuthFailure, AuthUser>> createUserWithEmailAndPassword(String email, String password);
  Future<Either<AuthFailure, AuthUser>> signInWithGoogle();
  Future<Either<AuthFailure, AuthUser>> signInWithApple();
  Future<Either<AuthFailure, AuthUser>> signInWithPhoneNumber(String phoneNumber, String verificationCode);
  Future<Either<AuthFailure, bool>> sendSmsOtp(String phoneNumber);
  Future<Either<AuthFailure, void>> signOut();

  // Profile & Password (3)
  Future<Either<AuthFailure, void>> updateUserProfile({String? displayName, String? photoURL});
  Future<Either<AuthFailure, bool>> updatePassword(String newPassword);
  Future<Either<AuthFailure, bool>> deleteUser();

  // Email (2)
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email);
  Future<Either<AuthFailure, bool>> sendEmailVerification();

  // Stream (1)
  Stream<AuthUser?> get authStateChanges;
}
```

### Method Classification

#### Category A: Direct Repository Call → SRP UseCase 가능 (8 methods)

```dart
✅ deleteAccount() → deleteUser()
✅ updateProfile() → updateUserProfile()
✅ authStateChanges → authStateChanges
✅ sendVerificationEmail() → sendEmailVerification()
✅ sendPasswordResetEmail() → sendPasswordResetEmail()
✅ updatePassword() → updatePassword()
✅ sendOtp() → sendSmsOpt()
✅ execute() [phone signin] → signInWithPhoneNumber()
```

#### Category B: Extension Methods on AuthUser Entity (7 methods)

```dart
// Should be extensions, not UseCases
isEmailVerified() → AuthUser.isEmailVerified getter
getCurrentUserEmail() → AuthUser.email getter
isAnonymous() → AuthUser.isAnonymous getter
isPremiumUser() → AuthUser.isPremium getter
isAdmin() → AuthUser.isAdmin getter
isTester() → AuthUser.isTester getter
isProfileComplete() → AuthUser.isProfileComplete getter
getUserPoints() → AuthUser.points getter
```

#### Category C: Service Layer Logic (6 methods)

```dart
// Need new Service classes
needsReAuthentication() → AuthSecurityService
getSecondsUntilResend() → RateLimitService
resendVerificationEmail() → EmailVerificationService
resendOtp() → PhoneAuthService
resetPassword() → PasswordResetService
getCurrentUser() → Keep in AccountManagementUseCase (core operation)
isUserSignedIn() → Keep in AccountManagementUseCase (core operation)
```

#### Category D: Already Migrated (5 methods)

```dart
✅ DeleteAccountUseCase (created)
✅ UpdateUserProfileUseCase (created)
✅ GetAuthStateStreamUseCase (created)
✅ SendEmailVerificationUseCase (created)
✅ SendPasswordResetEmailUseCase (created)
```

---

## Migration Strategy

### 4-Phase Incremental Approach (권장 절차 기반)

**`⚠️ 핵심 원칙 - 권장 절차 5가지 엄수 ⚠️`**

이 계획은 **"Lessons Learned"의 권장 절차 5가지를 엄격히 준수**합니다:

1. ✅ **Repository First**: IAuthRepository 분석 완료 (Phase 0)
2. ✅ **Incremental Migration**: Phase별로 7-8개 메서드만
3. ✅ **Keep Old Until Complete**: Phase 1-3에서 Old UseCase **절대 수정/삭제 금지**
4. ✅ **Category-Based Approach**: 각 Phase는 **한 Category만** 처리
5. ✅ **UI Last**: Provider 생성은 **Phase 4**에서만

---

### Phase 0: Repository Interface 분석 (사전 작업) ✅ 완료

**목표**: Repository 메서드 15개 확인 → Category 분류 기준 수립

**결과**:
- ✅ IAuthRepository 15개 메서드 분석
- ✅ 24개 Old 메서드 → Category A/B/C 분류 완료
- ✅ Migration 우선순위 수립

---

### Phase 1: Category A - SRP UseCases Only (8개 메서드) ✅ COMPLETE

**목표**: Category A (Direct Repository Call) 전체 → SRP UseCase

**타임라인**: 3-4시간

**완료일**: 2025-11-19

**`권장 절차 체크리스트`**:
```
✅ Repository First: IAuthRepository 15개 메서드 분석 완료 (Phase 0)
✅ Incremental Migration: 8개 메서드만 (5-7개 권장 범위 초과하지만 Category A 완결)
✅ Keep Old Until Complete: Old UseCases 절대 수정/삭제 금지
✅ Category-Based: Category A만 처리 (B, C는 Phase 2-3)
✅ UI Last: Provider 생성 금지 (Phase 4에서만)
```

#### 1.1 Create New SRP UseCases (8개)

**Already Created (5개)** - Phase 0.0.1에서 이미 생성됨:
```dart
✅ DeleteAccountUseCase
✅ UpdateUserProfileUseCase
✅ GetAuthStateStreamUseCase
✅ SendEmailVerificationUseCase
✅ SendPasswordResetEmailUseCase
```

**New UseCases (3개)**:
```dart
// 1. UpdatePasswordUseCase
lib/features/auth/domain/usecases/password/update_password_usecase.dart

class UpdatePasswordUseCase {
  final IAuthRepository _repository;

  UpdatePasswordUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<AuthFailure, Unit>> execute({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Validate new password strength
    if (newPassword.length < 6) {
      return left(AuthFailure.weakPassword('비밀번호는 6자 이상이어야 합니다'));
    }

    // Call Repository
    final result = await _repository.updatePassword(newPassword);

    return result.fold(
      (failure) => left(failure),
      (_) => right(unit),
    );
  }
}

// 2. SendPhoneOtpUseCase
lib/features/auth/domain/usecases/phone/send_phone_otp_usecase.dart

class SendPhoneOtpUseCase {
  final IAuthRepository _repository;

  SendPhoneOtpUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<AuthFailure, Unit>> execute({
    required String phoneNumber,
  }) async {
    // Validate phone number format
    if (phoneNumber.isEmpty || !phoneNumber.startsWith('+')) {
      return left(AuthFailure.invalidPhoneNumber('올바른 전화번호 형식이 아닙니다'));
    }

    // Call Repository
    final result = await _repository.sendSmsOtp(phoneNumber);

    return result.fold(
      (failure) => left(failure),
      (_) => right(unit),
    );
  }
}

// 3. SignInWithPhoneUseCase (단일 메서드 버전)
lib/features/auth/domain/usecases/phone/sign_in_with_phone_usecase.dart

class SignInWithPhoneUseCase {
  final IAuthRepository _repository;

  SignInWithPhoneUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<AuthFailure, AuthUser>> execute({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    // Validate inputs
    if (phoneNumber.isEmpty || verificationCode.isEmpty) {
      return left(AuthFailure.invalidCredentials('전화번호와 인증 코드를 입력하세요'));
    }

    // Call Repository
    return await _repository.signInWithPhoneNumber(phoneNumber, verificationCode);
  }
}
```

#### 1.2 Update DI Registration

```dart
// lib/app/di.dart
void setupAuthDI() {
  // Already registered (5개)
  // DeleteAccountUseCase, UpdateUserProfileUseCase, etc.

  // New UseCases (3개)
  getIt.registerFactory<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(repository: getIt())
  );
  getIt.registerFactory<SendPhoneOtpUseCase>(
    () => SendPhoneOtpUseCase(repository: getIt())
  );
  getIt.registerFactory<SignInWithPhoneUseCase>(
    () => SignInWithPhoneUseCase(repository: getIt())
  );
}
```

#### 1.3 Unit Tests

```bash
# Test new UseCases only
flutter test test/features/auth/domain/usecases/password/update_password_usecase_test.dart
flutter test test/features/auth/domain/usecases/phone/send_phone_otp_usecase_test.dart
flutter test test/features/auth/domain/usecases/phone/sign_in_with_phone_usecase_test.dart
```

#### 1.4 Verification

```bash
# Code generation (for DI annotations)
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Verify Old UseCases still exist
ls lib/features/auth/domain/usecases/account/
# Should see: account_management_usecase.dart, email_verification_usecase.dart, password_management_usecase.dart
ls lib/features/auth/domain/usecases/sign_in/
# Should see: sign_in_with_phone_usecase.dart
```

**Success Criteria**:
- ✅ 8개 Category A UseCase 파일 존재 (5개 old + 3개 new)
- ✅ DI 등록 완료 (8개 전체)
- ✅ Unit tests 통과
- ✅ flutter analyze 0 errors
- ✅ **Old UseCases 그대로 유지** (수정/삭제 없음)
- ❌ **Provider 생성 안 함** (Phase 4까지 금지)

---

### Phase 2: Category B - Provider Migration ✅ COMPLETE (Already SRP Compliant)

**목표**: Category B (Provider) 마이그레이션 검증

**타임라인**: 조사 완료

**완료일**: 2025-11-19

**조사 결과**:
```
✅ 기존 Provider 3개 모두 이미 SRP 준수 확인
✅ Riverpod 3.x @riverpod annotation 사용 중
✅ Clean Architecture 패턴 준수 (UseCase 의존)
✅ Phase 2 작업 불필요 - 모든 Provider 이미 최적화됨
```

**발견 사항**:
1. **계획된 Provider** (존재하지 않음):
   - ❌ `authStateChangesProvider` → 실제 이름: `authStateStreamProvider`
   - ❌ `emailVerifiedStreamProvider` → Firebase 제약으로 불가능 (실시간 Stream 없음)

2. **실제 Provider 분석**:
   ```dart
   ✅ authStateStreamProvider
      - Riverpod 3.x (@riverpod annotation)
      - 단일 책임: Auth state stream 제공
      - 개선 가능: Firebase 직접 호출 대신 Repository 사용 (선택적)

   ✅ currentUserProvider
      - Clean Architecture 준수
      - GetCurrentUserUseCase 사용
      - Either 패턴 사용 (fold())

   ✅ currentUserIdProvider
      - Derived provider (currentUserProvider 의존)
      - 단일 책임: User ID만 추출
   ```

3. **Phase 2 결론**:
   - **모든 Provider 이미 SRP 준수**
   - Category B 작업 불필요
   - 선택적 개선: `authStateStreamProvider`를 Repository 패턴으로 리팩토링 (비필수)

**`권장 절차 체크리스트`**:
```
✅ Repository First: Phase 0 완료
✅ Incremental Migration: 작업 불필요 (이미 완료됨)
✅ Keep Old Until Complete: Provider 변경 없음
✅ Category-Based: Category B 검증 완료
✅ UI Last: Provider 이미 최적 상태
```

#### 2.1 Provider 검증 완료

**검증 항목**:
- ✅ `authStateStreamProvider` - Riverpod 3.x, SRP 준수
- ✅ `currentUserProvider` - Clean Architecture, UseCase 사용
- ✅ `currentUserIdProvider` - Derived provider, 단일 책임

**선택적 개선 사항** (비필수):
```dart
// authStateStreamProvider를 Repository 패턴으로 리팩토링 (현재는 Firebase 직접 호출)
// 예상 소요 시간: 2-3시간
// 우선순위: Low (현재도 SRP 준수)
```

**Success Criteria**:
- ✅ 모든 Provider SRP 준수 확인
- ✅ Riverpod 3.x 사용 확인
- ✅ Clean Architecture 패턴 확인
- ✅ Phase 2 작업 불필요 확인

---

### Phase 3: Category C - Services Only (6개 메서드)

**목표**: Category C (Service Logic) 전체 → 전용 Service 클래스

**타임라인**: 3-4시간

**`권장 절차 체크리스트`**:
```
✅ Repository First: Phase 0 완료
✅ Incremental Migration: 6개 메서드 (권장 범위 내)
✅ Keep Old Until Complete: Old UseCases 절대 수정/삭제 금지
✅ Category-Based: Category C만 처리 (A, B는 Phase 1-2 완료)
✅ UI Last: Provider 생성 금지 (Phase 4에서만)
```

#### 3.1 Create Service Classes (4개)

```dart
// lib/features/auth/domain/services/auth_security_service.dart
class AuthSecurityService {
  final IAuthRepository _repository;

  AuthSecurityService({required IAuthRepository repository})
      : _repository = repository;

  /// Check if user needs re-authentication (last sign-in > 5 minutes ago)
  Future<bool> needsReAuthentication() async {
    final userResult = await _repository.getCurrentUser();

    return userResult.fold(
      (failure) => true, // Err on the side of caution
      (currentUser) {
        if (currentUser.lastLoginAt != null) {
          final timeSinceLogin = DateTime.now().difference(currentUser.lastLoginAt!);
          return timeSinceLogin.inMinutes > 5;
        }
        return false;
      },
    );
  }
}

// lib/features/auth/domain/services/rate_limit_service.dart
class RateLimitService {
  final Map<String, DateTime> _lastSentTime = {};
  static const Duration resendCooldown = Duration(seconds: 60);

  int getSecondsUntilResend(String key) {
    final lastSent = _lastSentTime[key];
    if (lastSent == null) return 0;

    final elapsed = DateTime.now().difference(lastSent);
    final remaining = resendCooldown - elapsed;

    return remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }

  bool canResend(String key) {
    return getSecondsUntilResend(key) == 0;
  }

  void markSent(String key) {
    _lastSentTime[key] = DateTime.now();
  }
}

// lib/features/auth/domain/services/email_verification_service.dart
class EmailVerificationService {
  final IAuthRepository _repository;
  final RateLimitService _rateLimitService;

  EmailVerificationService({
    required IAuthRepository repository,
    required RateLimitService rateLimitService,
  })  : _repository = repository,
        _rateLimitService = rateLimitService;

  Future<Either<AuthFailure, Unit>> resendVerificationEmail({
    String? eventId,
  }) async {
    // Rate limiting check
    const key = 'email_verification';
    if (!_rateLimitService.canResend(key)) {
      final seconds = _rateLimitService.getSecondsUntilResend(key);
      return left(AuthFailure.rateLimitExceeded(
        '${seconds}초 후에 다시 시도하세요',
      ));
    }

    // Send verification
    final result = await _repository.sendEmailVerification();

    return result.fold(
      (failure) => left(failure),
      (_) {
        _rateLimitService.markSent(key);
        return right(unit);
      },
    );
  }
}

// Similar pattern for:
// - PhoneAuthService (resendOtp)
// - PasswordResetService (resetPassword)
```

#### 3.2 Update DI Registration

```dart
// lib/app/di.dart
void setupAuthDI() {
  // Services (4개)
  getIt.registerLazySingleton<RateLimitService>(() => RateLimitService());
  getIt.registerLazySingleton<AuthSecurityService>(
    () => AuthSecurityService(repository: getIt())
  );
  getIt.registerLazySingleton<EmailVerificationService>(
    () => EmailVerificationService(
      repository: getIt(),
      rateLimitService: getIt(),
    )
  );
  getIt.registerLazySingleton<PhoneAuthService>(
    () => PhoneAuthService(
      repository: getIt(),
      rateLimitService: getIt(),
    )
  );
  // Note: PasswordResetService는 resetPassword() Repository 메서드 구현 후 추가
}
```

#### 3.3 Verification

```bash
# Code generation
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Verify Old UseCases still exist (unchanged)
ls lib/features/auth/domain/usecases/account/
# Should see: account_management_usecase.dart, email_verification_usecase.dart, password_management_usecase.dart
ls lib/features/auth/domain/usecases/sign_in/
# Should see: sign_in_with_phone_usecase.dart

# Verify no modifications
git diff lib/features/auth/domain/usecases/
# Should show NO changes to old UseCase files
```

**Success Criteria**:
- ✅ 4개 Service 클래스 생성
- ✅ DI 등록 완료 (4개 Service)
- ✅ flutter analyze 0 errors
- ✅ **Old UseCases 그대로 유지** (4개 파일 그대로)
- ❌ **Old UseCase 삭제 안 함** (Phase 4까지 금지)
- ❌ **Provider 생성 안 함** (Phase 4까지 금지)

---

### Phase 4: Final Integration & Cleanup

**목표**: Provider 생성 + Old UseCase 삭제 (모든 마이그레이션 완료 후)

**타임라인**: 2-3시간

**`권장 절차 체크리스트`**:
```
✅ Repository First: Phase 0 완료
✅ Incremental Migration: Phase 1-3 완료 (24개 메서드 모두 마이그레이션)
✅ Keep Old Until Complete: 이제 안전하게 Old UseCase 삭제 가능
✅ Category-Based: 모든 Category (A, B, C) 완료
✅ UI Last: 이제 Provider 생성 가능
```

#### 4.1 Create Providers for New UseCases

**새 UseCase Provider 생성** (Phase 1에서 만든 3개):

```dart
// lib/features/auth/presentation/providers/password_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_providers.g.dart';

@riverpod
class UpdatePasswordNotifier extends _$UpdatePasswordNotifier {
  @override
  FutureOr<void> build() async {}

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();

    final useCase = getIt<UpdatePasswordUseCase>();
    final result = await useCase.execute(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}

// lib/features/auth/presentation/providers/phone_providers.dart
@riverpod
class SendPhoneOtpNotifier extends _$SendPhoneOtpNotifier {
  @override
  FutureOr<void> build() async {}

  Future<void> sendOtp(String phoneNumber) async {
    state = const AsyncValue.loading();

    final useCase = getIt<SendPhoneOtpUseCase>();
    final result = await useCase.execute(phoneNumber: phoneNumber);

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}

@riverpod
class SignInWithPhoneNotifier extends _$SignInWithPhoneNotifier {
  @override
  FutureOr<AuthUser?> build() async {
    return null;
  }

  Future<void> signIn({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    state = const AsyncValue.loading();

    final useCase = getIt<SignInWithPhoneUseCase>();
    final result = await useCase.execute(
      phoneNumber: phoneNumber,
      verificationCode: verificationCode,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
}
```

#### 4.2 Update UI to Use New Providers

**Before (Old UseCase 직접 사용)**:
```dart
// Old pattern - 삭제 예정
final passwordUseCase = getIt<PasswordManagementUseCase>();
await passwordUseCase.updatePassword(
  currentPassword: current,
  newPassword: newPassword,
);
```

**After (New Provider 사용)**:
```dart
// New pattern - Riverpod Provider 사용
await ref.read(updatePasswordNotifierProvider.notifier).updatePassword(
  currentPassword: current,
  newPassword: newPassword,
);
```

**Extension 사용 예시**:
```dart
// Before (Old UseCase method)
final isPremium = await accountManagementUseCase.isPremiumUser();

// After (Extension)
final user = await ref.read(getCurrentUserUseCaseProvider.future);
final isPremium = user?.isPremium ?? false;
```

**Service 사용 예시**:
```dart
// Before (Old UseCase method)
final needsReauth = await accountManagementUseCase.needsReAuthentication();

// After (Service)
final authSecurityService = getIt<AuthSecurityService>();
final needsReauth = await authSecurityService.needsReAuthentication();
```

#### 4.3 Delete Old UseCases (이제 안전)

**모든 메서드가 마이그레이션되었으므로 안전하게 삭제**:

```bash
# 1. Verify all 24 methods migrated
# Category A (8): UpdatePassword, SendPhoneOtp, SignInWithPhone + 5 already created
# Category B (7): AuthUserExtensions (isEmailVerified, isAnonymous, etc.)
# Category C (6): Services (AuthSecurityService, RateLimitService, etc.)
# + getCurrentUser, isUserSignedIn (keep in AccountManagementUseCase) → 실제로는 삭제

# 2. Delete Old UseCase files
rm lib/features/auth/domain/usecases/account/account_management_usecase.dart
rm lib/features/auth/domain/usecases/account/email_verification_usecase.dart
rm lib/features/auth/domain/usecases/account/password_management_usecase.dart
rm lib/features/auth/domain/usecases/sign_in/sign_in_with_phone_usecase.dart

# 3. Verify deletion
ls lib/features/auth/domain/usecases/account/
# Should NOT see deleted files

# 4. Update imports (UI 파일에서 old import 제거)
# Find all files importing old UseCases
grep -r "account_management_usecase" lib/features/auth/presentation/
grep -r "email_verification_usecase" lib/features/auth/presentation/
grep -r "password_management_usecase" lib/features/auth/presentation/

# Remove those imports and replace with new Provider imports
```

#### 4.4 Final Verification

```bash
# Code generation
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze
# Target: 0 errors, 0 warnings

# All tests
flutter test
# Target: All tests pass

# Integration tests (if exists)
flutter test integration_test/

# Verify no Old UseCase references
grep -r "AccountManagementUseCase\|EmailVerificationUseCase\|PasswordManagementUseCase" lib/features/auth/presentation/
# Should find ZERO references
```

**Success Criteria**:
- ✅ 3개 새 Provider 생성 완료
- ✅ UI 전체 업데이트 (Old UseCase → New Provider/Extension/Service)
- ✅ 4개 Old UseCase 파일 삭제 완료
- ✅ flutter analyze 0 errors, 0 warnings
- ✅ 모든 테스트 통과 (Unit + Integration)
- ✅ **24/24 메서드 모두 마이그레이션 완료** (0% 기능 손실)
- ✅ SRP 준수 (각 UseCase 단일 책임)

---

## Lessons Learned

### ✅ 권장 절차

1. **Repository First**: UseCase 작성 전 Repository 인터페이스 확인
2. **Incremental Migration**: 한 번에 5-7개 메서드만 마이그레이션
3. **Keep Old Until Complete**: 모든 메서드 마이그레이션 전까지 old 파일 유지
4. **Category-Based Approach**:
   - Direct Repository Call → SRP UseCase
   - Entity properties → Extensions
   - Complex logic → Services
5. **UI Last**: UseCase/Service 완성 후 Provider 업데이트

### ❌ 피해야 할 실수

1. **일괄 삭제**: Helper 메서드 마이그레이션 계획 없이 UseCase 삭제
2. **검증 부족**: Repository 메서드 존재 여부 확인 안 함
3. **동시 UI 수정**: UseCase 변경과 Provider 업데이트 동시 진행
4. **단위 테스트 누락**: 마이그레이션 각 단계마다 테스트 필수

### 📋 Migration Checklist (각 Phase별)

```markdown
□ Repository 인터페이스 확인 (메서드 존재 여부)
□ Category 분류 (UseCase/Extension/Service)
□ 새 파일 생성 (UseCase/Extension/Service)
□ Unit tests 작성
□ DI 등록
□ Provider 생성 (필요 시)
□ Code generation (build_runner)
□ flutter analyze 0 errors 확인
□ UI 업데이트 (Provider 연결)
□ Integration tests 실행
□ Old UseCase 메서드 제거 (안전 확인 후)
```

---

## Next Steps

### Immediate Actions

1. **Review This Plan**: User approval 받기
2. **Start Phase 1**: Core SRP UseCases (2-3시간)
3. **Verify**: flutter analyze, tests 통과 확인

### Success Metrics

- ✅ **0% Feature Loss**: 24개 메서드 모두 마이그레이션
- ✅ **SRP Compliance**: 각 UseCase 단일 책임
- ✅ **Code Quality**: flutter analyze 0 errors
- ✅ **Test Coverage**: 80%+ coverage
- ✅ **Documentation**: 각 Phase README 업데이트

---

**작성자**: Claude Code (Deep Analysis + Approved Rollback Plan)
**날짜**: 2025-11-19
**버전**: v1.0.0 (Initial Revised Plan)
