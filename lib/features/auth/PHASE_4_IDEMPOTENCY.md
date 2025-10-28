# Phase 4: IdempotencyService 통합

> **소요 시간**: 1일
> **난이도**: ⭐⭐⭐☆☆ (중간)
> **영향 범위**: Domain Layer (3개 UseCases)
> **UI 영향**: ⚠️ 부분 (에러 메시지 추가)

---

## 📋 목차

1. [개요](#1-개요)
2. [IdempotencyService 패턴 설명](#2-idempotencyservice-패턴-설명)
3. [적용 대상 분석](#3-적용-대상-분석)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [백엔드-UI 연결 완전 가이드](#6-백엔드-ui-연결-완전-가이드)
7. [Firebase Firestore 구조](#7-firebase-firestore-구조)
8. [테스트 전략](#8-테스트-전략)
9. [롤백 계획](#9-롤백-계획)

---

## 1. 개요

### 1.1 Phase 4의 목적

Voting Feature의 중복 방지 패턴을 Auth Feature에 적용합니다:
- ✅ **IdempotencyService**: UUID 기반 중복 작업 방지
- ✅ **네트워크 재시도 허용**: 동일 eventId는 안전하게 재시도
- ✅ **실제 중복 차단**: 다른 eventId는 IdempotencyViolation 발생
- ✅ **3가지 시나리오**: 회원가입, 이메일 인증, 비밀번호 리셋

### 1.2 변경 대상 (3개 UseCases)

| UseCase | 파일 | 적용 이유 |
|---------|------|----------|
| **SignUpWithEmailUseCase** | `sign_up_with_email_usecase.dart` | 중복 가입 방지 |
| **EmailVerificationUseCase** | `email_verification_usecase.dart` | 스팸 이메일 방지 |
| **PasswordManagementUseCase** | `password_management_usecase.dart` | 스팸 리셋 방지 |

**총 변경**: 3개 UseCase, 약 60줄 추가

### 1.3 왜 IdempotencyService를 사용하는가?

**문제 상황**:
```dart
// ❌ 중복 방지 없이 (현재)
Future<Either<AuthFailure, AuthUser>> signUp({
  required String email,
  required String password,
}) async {
  // 문제 1: 네트워크 재시도 vs 실제 중복 구분 불가
  final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // 문제 2: 이미 가입된 이메일이면?
  // - 네트워크 오류로 재시도? → ✅ 허용해야 함
  // - 실제로 다시 가입 시도? → ❌ 차단해야 함

  // 문제 3: 이메일 인증 스팸
  // - 사용자가 "인증 메일 재전송" 버튼을 10번 연타
  // - Firebase에서 10개 이메일 전송 (비용 증가)

  // 문제 4: 비밀번호 리셋 스팸
  // - 악의적인 사용자가 특정 이메일로 100번 요청
  // - Firebase에서 100개 이메일 전송 (공격 가능)
}
```

**IdempotencyService 해결책**:
```dart
// ✅ 중복 방지 적용
Future<Either<AuthFailure, AuthUser>> signUp({
  required String email,
  required String password,
  required String eventId,  // ← 클라이언트가 생성한 UUID
}) async {
  return _idempotencyService.executeIdempotent<AuthUser>(
    entityType: 'auth_signup',
    entityId: email,
    userId: email,
    eventId: eventId,
    operation: (transaction) async {
      // ✅ 첫 실행: 회원가입 진행
      // ✅ 재시도 (동일 eventId): 안전하게 스킵
      // ❌ 중복 (다른 eventId): IdempotencyViolation 발생

      final user = await _repository.signUpWithEmailAndPassword(
        email,
        password,
      );

      return user.fold(
        (failure) => throw failure,
        (user) => user,
      );
    },
  ).then((user) => right(user))
   .catchError((e) {
     if (e is IdempotencyViolation) {
       return left(const AuthFailure.emailAlreadyInUse());
     }
     return left(AuthFailure.unexpected(e.toString()));
   });
}

// 클라이언트 사용 예시:
final eventId = const Uuid().v4();  // 클라이언트가 UUID 생성

await signUpUseCase.execute(
  email: email,
  password: password,
  eventId: eventId,
);
```

**Voting Feature 참조 패턴**:
```dart
// lib/features/voting/domain/usecases/vote_usecase.dart
Future<Either<VoteFailure, Unit>> execute({
  required String postId,
  required String userId,
  required String choice,
  required String eventId,  // ← UUID
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'vote',
    entityId: postId,
    userId: userId,
    eventId: eventId,
    operation: (transaction) async {
      // 투표 로직
      return unit;
    },
  ).then((unit) => right(unit))
   .catchError((e) => left(VoteFailure.alreadyVoted()));
}
```

---

## 2. IdempotencyService 패턴 설명

### 2.1 핵심 개념

**Idempotency (멱등성)**:
- 동일한 요청을 여러 번 해도 결과가 같음
- 네트워크 재시도를 안전하게 허용
- 실제 중복 작업은 차단

**eventId (UUID v4)**:
- 클라이언트가 생성하는 고유 ID
- 네트워크 재시도 시 동일한 eventId 사용
- 실제 중복 시도 시 새로운 eventId 생성

### 2.2 동작 원리

```
┌─────────────────────────────────────────────────┐
│ 시나리오 1: 첫 실행                              │
└─────────────────────────────────────────────────┘

UI → UseCase.execute(eventId: "uuid-123")
       ↓
IdempotencyService.executeIdempotent()
       ↓
Firestore Transaction 시작
       ↓
idempotency/auth_signup_user@test.com_user@test.com 문서 확인
       ↓ (문서 없음)
       ↓
✅ 첫 실행: operation() 호출
       ↓
회원가입 진행
       ↓
idempotency 문서 생성 { eventId: "uuid-123", timestamp: ... }
       ↓
Transaction 커밋
       ↓
UI ← right(AuthUser(...))


┌─────────────────────────────────────────────────┐
│ 시나리오 2: 네트워크 재시도 (동일 eventId)        │
└─────────────────────────────────────────────────┘

UI → UseCase.execute(eventId: "uuid-123")  // 동일
       ↓
IdempotencyService.executeIdempotent()
       ↓
Firestore Transaction 시작
       ↓
idempotency/auth_signup_user@test.com_user@test.com 문서 확인
       ↓ (문서 있음: eventId = "uuid-123")
       ↓
eventId 비교: "uuid-123" == "uuid-123"
       ↓
✅ 재시도: operation() 스킵, null 반환
       ↓
Transaction 커밋 (변경 없음)
       ↓
UI ← right(null) → 성공 처리


┌─────────────────────────────────────────────────┐
│ 시나리오 3: 실제 중복 시도 (다른 eventId)         │
└─────────────────────────────────────────────────┘

UI → UseCase.execute(eventId: "uuid-456")  // 다름
       ↓
IdempotencyService.executeIdempotent()
       ↓
Firestore Transaction 시작
       ↓
idempotency/auth_signup_user@test.com_user@test.com 문서 확인
       ↓ (문서 있음: eventId = "uuid-123")
       ↓
eventId 비교: "uuid-456" != "uuid-123"
       ↓
❌ 실제 중복: throw IdempotencyViolation
       ↓
Transaction 롤백
       ↓
UI ← left(AuthFailure.emailAlreadyInUse())
```

### 2.3 IdempotencyService API

**파일**: `lib/core/utils/idempotency_service.dart`

```dart
class IdempotencyService {
  /// Idempotent 작업 실행
  ///
  /// [entityType]: 작업 타입 (auth_signup, auth_email_verify 등)
  /// [entityId]: 엔티티 ID (이메일, userId 등)
  /// [userId]: 사용자 ID
  /// [eventId]: 클라이언트 생성 UUID v4
  /// [operation]: 실제 실행할 작업 (Transaction 내부)
  ///
  /// **Returns**: T (operation 반환값)
  ///
  /// **Throws**:
  /// - IdempotencyViolation: 다른 eventId로 중복 시도
  Future<T> executeIdempotent<T>({
    required String entityType,
    required String entityId,
    required String userId,
    required String? eventId,
    required Future<T> Function(Transaction transaction) operation,
  });

  /// Idempotency 기록 정리 (옵션)
  Future<void> cleanupIdempotency({
    required String entityType,
    required String entityId,
    required String userId,
  });
}

/// Idempotency 위반 예외
class IdempotencyViolation implements Exception {
  final String message;
  IdempotencyViolation(this.message);
}
```

---

## 3. 적용 대상 분석

### 3.1 UseCase 1: SignUpWithEmailUseCase

**적용 이유**: 중복 가입 방지

**시나리오**:
1. 사용자가 회원가입 버튼 클릭
2. 네트워크 오류로 응답 못 받음
3. 사용자가 다시 버튼 클릭 (동일 eventId)
4. → ✅ 안전하게 재시도

5. 악의적 사용자가 같은 이메일로 계속 가입 시도 (새 eventId)
6. → ❌ IdempotencyViolation 발생

**Firebase 구조**:
```
idempotency/
  auth_signup_{email}_{email}/
    eventId: "uuid-v4"
    timestamp: ServerTimestamp
    entityType: "auth_signup"
```

### 3.2 UseCase 2: EmailVerificationUseCase

**적용 이유**: 스팸 이메일 방지

**시나리오**:
1. 사용자가 "인증 메일 재전송" 버튼 연타 (10번)
2. 첫 번째: 이메일 전송 ✅
3. 2-10번째: IdempotencyService가 스킵 ✅
4. → Firebase 이메일 1개만 전송 (비용 절약)

**Firebase 구조**:
```
idempotency/
  auth_email_verify_{userId}_{userId}/
    eventId: "uuid-v4"
    timestamp: ServerTimestamp
    entityType: "auth_email_verify"
```

### 3.3 UseCase 3: PasswordManagementUseCase

**적용 이유**: 비밀번호 리셋 스팸 방지

**시나리오**:
1. 악의적 사용자가 특정 이메일로 비밀번호 리셋 100번 요청
2. 첫 번째: 이메일 전송 ✅
3. 2-100번째: IdempotencyService가 스킵 ✅
4. → Firebase 이메일 1개만 전송 (공격 차단)

**Firebase 구조**:
```
idempotency/
  auth_password_reset_{email}_{email}/
    eventId: "uuid-v4"
    timestamp: ServerTimestamp
    entityType: "auth_password_reset"
```

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: IdempotencyService 확인**

```bash
# IdempotencyService 파일 확인
ls -la lib/core/utils/idempotency_service.dart

# 이미 존재하면 사용, 없으면 Voting에서 복사
```

**Step 2: UUID 패키지 추가**

```yaml
# pubspec.yaml
dependencies:
  uuid: ^4.4.0
```

```bash
flutter pub get
```

**Step 3: 백업 생성**

```bash
# UseCase 백업
cp lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart \
   lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart.backup

cp lib/features/auth/domain/usecases/email_verification_usecase.dart \
   lib/features/auth/domain/usecases/email_verification_usecase.dart.backup

cp lib/features/auth/domain/usecases/password_management_usecase.dart \
   lib/features/auth/domain/usecases/password_management_usecase.dart.backup

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(auth): Backup before IdempotencyService integration"
```

### 4.2 UseCase 1: SignUpWithEmailUseCase 수정

**Step 4: IdempotencyService 주입 및 적용**

**파일**: `lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart`

```dart
// Before
class SignUpWithEmailUseCase {
  final IAuthRepository _repository;

  const SignUpWithEmailUseCase(this._repository);

  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _repository.signUpWithEmailAndPassword(
        email,
        password,
      );

      return result;
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}

// After
import '/core/utils/idempotency_service.dart';

class SignUpWithEmailUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  const SignUpWithEmailUseCase(
    this._repository,
    this._idempotencyService,
  );

  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
    required String eventId,  // ← 추가
  }) async {
    try {
      // IdempotencyService로 래핑
      final user = await _idempotencyService.executeIdempotent<AuthUser>(
        entityType: 'auth_signup',
        entityId: email,
        userId: email,
        eventId: eventId,
        operation: (transaction) async {
          final result = await _repository.signUpWithEmailAndPassword(
            email,
            password,
          );

          return result.fold(
            (failure) => throw failure,
            (user) => user,
          );
        },
      );

      return right(user);
    } on IdempotencyViolation catch (_) {
      return left(const AuthFailure.emailAlreadyInUse());
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

### 4.3 UseCase 2: EmailVerificationUseCase 수정

**Step 5: 이메일 인증 스팸 방지**

```dart
// Before
class EmailVerificationUseCase {
  final IAuthRepository _repository;

  Future<Either<AuthFailure, Unit>> sendVerificationEmail() async {
    try {
      await _repository.sendEmailVerification();
      return right(unit);
    } on AuthFailure catch (e) {
      return left(e);
    }
  }
}

// After
import '/core/utils/idempotency_service.dart';

class EmailVerificationUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  const EmailVerificationUseCase(
    this._repository,
    this._idempotencyService,
  );

  Future<Either<AuthFailure, Unit>> sendVerificationEmail({
    required String userId,
    required String eventId,  // ← 추가
  }) async {
    try {
      await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'auth_email_verify',
        entityId: userId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          await _repository.sendEmailVerification();
          return unit;
        },
      );

      return right(unit);
    } on IdempotencyViolation catch (_) {
      // 이미 전송됨 (스킵)
      return right(unit);  // ← 에러가 아닌 성공 처리
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

### 4.4 UseCase 3: PasswordManagementUseCase 수정

**Step 6: 비밀번호 리셋 스팸 방지**

```dart
// Before
class PasswordManagementUseCase {
  final IAuthRepository _repository;

  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return right(unit);
    } on AuthFailure catch (e) {
      return left(e);
    }
  }
}

// After
import '/core/utils/idempotency_service.dart';

class PasswordManagementUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  const PasswordManagementUseCase(
    this._repository,
    this._idempotencyService,
  );

  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
    required String eventId,  // ← 추가
  }) async {
    try {
      await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'auth_password_reset',
        entityId: email,
        userId: email,
        eventId: eventId,
        operation: (transaction) async {
          await _repository.sendPasswordResetEmail(email);
          return unit;
        },
      );

      return right(unit);
    } on IdempotencyViolation catch (_) {
      // 이미 전송됨 (스킵)
      return right(unit);  // ← 에러가 아닌 성공 처리
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

### 4.5 DI 설정 업데이트

**Step 7: GetIt에 IdempotencyService 등록**

**파일**: `lib/app/di.dart`

```dart
// GetIt 설정
void setupGetIt() {
  final getIt = GetIt.instance;

  // IdempotencyService 등록 (Singleton)
  getIt.registerSingleton<IdempotencyService>(
    IdempotencyService(),
  );

  // UseCases 등록 (IdempotencyService 주입)
  getIt.registerLazySingleton<SignUpWithEmailUseCase>(
    () => SignUpWithEmailUseCase(
      getIt<IAuthRepository>(),
      getIt<IdempotencyService>(),  // ← 추가
    ),
  );

  getIt.registerLazySingleton<EmailVerificationUseCase>(
    () => EmailVerificationUseCase(
      getIt<IAuthRepository>(),
      getIt<IdempotencyService>(),  // ← 추가
    ),
  );

  getIt.registerLazySingleton<PasswordManagementUseCase>(
    () => PasswordManagementUseCase(
      getIt<IAuthRepository>(),
      getIt<IdempotencyService>(),  // ← 추가
    ),
  );

  // ... 나머지 UseCases
}
```

### 4.6 UI 변경 (eventId 생성)

**Step 8: UI에서 UUID 생성**

**파일**: `lib/features/auth/presentation/screens/signup/create_account_widget.dart`

```dart
// Before
Future<void> _handleSignUp() async {
  final signUpUseCase = ref.read(signUpWithEmailUseCaseProvider);

  final result = await signUpUseCase.execute(
    email: email,
    password: password,
  );

  // ...
}

// After
import 'package:uuid/uuid.dart';

Future<void> _handleSignUp() async {
  final eventId = const Uuid().v4();  // ← UUID 생성

  final signUpUseCase = ref.read(signUpWithEmailUseCaseProvider);

  final result = await signUpUseCase.execute(
    email: email,
    password: password,
    eventId: eventId,  // ← 전달
  );

  // ...
}
```

**동일한 패턴으로 2개 UI 추가 수정**:
- `popup_timer_email_widget.dart` - 이메일 인증 버튼
- `forgot_password_widget.dart` - 비밀번호 리셋 버튼

### 4.7 컴파일 확인

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 결과: 0 issues found
```

---

## 5. Before/After 전체 코드

### 5.1 UseCase 1: SignUpWithEmailUseCase

<details>
<summary>Before 코드 보기</summary>

```dart
// lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart
import 'package:dartz/dartz.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class SignUpWithEmailUseCase {
  final IAuthRepository _repository;

  const SignUpWithEmailUseCase(this._repository);

  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return left(const AuthFailure.invalidEmail());
      }

      if (password.length < 6) {
        return left(const AuthFailure.weakPassword());
      }

      final result = await _repository.signUpWithEmailAndPassword(
        email,
        password,
      );

      return result;
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

</details>

<details>
<summary>After 코드 보기</summary>

```dart
// lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart
import 'package:dartz/dartz.dart';
import '/core/utils/idempotency_service.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class SignUpWithEmailUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  const SignUpWithEmailUseCase(
    this._repository,
    this._idempotencyService,
  );

  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
    required String eventId,  // ← UUID v4
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return left(const AuthFailure.invalidEmail());
      }

      if (password.length < 6) {
        return left(const AuthFailure.weakPassword());
      }

      // IdempotencyService로 래핑
      final user = await _idempotencyService.executeIdempotent<AuthUser>(
        entityType: 'auth_signup',
        entityId: email,
        userId: email,
        eventId: eventId,
        operation: (transaction) async {
          final result = await _repository.signUpWithEmailAndPassword(
            email,
            password,
          );

          return result.fold(
            (failure) => throw failure,
            (user) => user,
          );
        },
      );

      return right(user);
    } on IdempotencyViolation catch (_) {
      return left(const AuthFailure.emailAlreadyInUse());
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

</details>

### 5.2 UseCase 2: EmailVerificationUseCase

<details>
<summary>Before/After 코드 비교</summary>

```dart
// Before
class EmailVerificationUseCase {
  final IAuthRepository _repository;

  Future<Either<AuthFailure, Unit>> sendVerificationEmail() async {
    await _repository.sendEmailVerification();
    return right(unit);
  }
}

// After
import '/core/utils/idempotency_service.dart';

class EmailVerificationUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  Future<Either<AuthFailure, Unit>> sendVerificationEmail({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'auth_email_verify',
        entityId: userId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          await _repository.sendEmailVerification();
          return unit;
        },
      );

      return right(unit);
    } on IdempotencyViolation catch (_) {
      return right(unit);  // 이미 전송됨, 성공 처리
    }
  }
}
```

</details>

### 5.3 UseCase 3: PasswordManagementUseCase

<details>
<summary>Before/After 코드 비교</summary>

```dart
// Before
class PasswordManagementUseCase {
  final IAuthRepository _repository;

  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    await _repository.sendPasswordResetEmail(email);
    return right(unit);
  }
}

// After
import '/core/utils/idempotency_service.dart';

class PasswordManagementUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
    required String eventId,
  }) async {
    try {
      await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'auth_password_reset',
        entityId: email,
        userId: email,
        eventId: eventId,
        operation: (transaction) async {
          await _repository.sendPasswordResetEmail(email);
          return unit;
        },
      );

      return right(unit);
    } on IdempotencyViolation catch (_) {
      return right(unit);  // 이미 전송됨, 성공 처리
    }
  }
}
```

</details>

---

## 6. 백엔드-UI 연결 완전 가이드

### 6.1 회원가입 플로우 (IdempotencyService 포함)

```
[UI Layer] create_account_widget.dart
    ↓ 사용자가 "회원가입" 버튼 클릭
    ↓ final eventId = const Uuid().v4()
    ↓ → "12345678-abcd-1234-abcd-123456789abc"
    ↓
    ↓ signUpUseCase.execute(email, password, eventId)

[Domain Layer] sign_up_with_email_usecase.dart
    ↓ IdempotencyService.executeIdempotent(
    │   entityType: 'auth_signup',
    │   entityId: email,
    │   userId: email,
    │   eventId: eventId,
    │   operation: ...
    │ )

[IdempotencyService] idempotency_service.dart
    ↓ Firestore Transaction 시작
    ↓
    ↓ 문서 참조: idempotency/auth_signup_{email}_{email}
    ↓ transaction.get(idempotencyRef)
    │
    ├─ 케이스 1: 문서 없음 (첫 실행)
    │  ↓ operation() 호출
    │  ↓ → _repository.signUpWithEmailAndPassword(email, password)
    │  ↓
    │  ↓ [Data Layer] auth_repository_impl.dart
    │  ↓ FirebaseAuth.createUserWithEmailAndPassword()
    │  ↓
    │  ↓ [Firebase Backend]
    │  ↓ POST https://identitytoolkit.googleapis.com/v1/accounts:signUp
    │  │
    │  ├─ 성공: UserCredential 반환
    │  │  ↓ Firestore users 컬렉션 문서 생성
    │  │  ↓ transaction.set(idempotencyRef, { eventId: ..., timestamp: ... })
    │  │  ↓ Transaction 커밋
    │  │  └─ UI ← right(AuthUser(...))
    │  │
    │  └─ 실패: FirebaseAuthException
    │     ↓ throw AuthFailure.emailAlreadyInUse()
    │     ↓ Transaction 롤백
    │     └─ UI ← left(AuthFailure.emailAlreadyInUse())
    │
    ├─ 케이스 2: 문서 있음 + eventId 동일 (네트워크 재시도)
    │  ↓ prevEventId == eventId
    │  ↓ → "12345678-abcd-1234-abcd-123456789abc" == "12345678-..."
    │  ↓
    │  ✅ 재시도 감지: operation() 스킵
    │  ↓ return null (성공 처리)
    │  ↓ Transaction 커밋 (변경 없음)
    │  └─ UI ← right(null) → 이메일 인증 페이지로 이동
    │
    └─ 케이스 3: 문서 있음 + eventId 다름 (실제 중복)
       ↓ prevEventId != eventId
       ↓ → "12345678-..." != "87654321-..."
       ↓
       ❌ 실제 중복: throw IdempotencyViolation
       ↓ Transaction 롤백
       ↓ catch (IdempotencyViolation)
       ↓ return left(AuthFailure.emailAlreadyInUse())
       └─ UI ← left(AuthFailure.emailAlreadyInUse())
          ↓ ScaffoldMessenger: "이미 사용 중인 이메일입니다"
```

### 6.2 이메일 인증 플로우 (스팸 방지)

```
[UI Layer] popup_timer_email_widget.dart
    ↓ 사용자가 "인증 메일 재전송" 버튼 연타 (5번)
    │
    ├─ 클릭 1: eventId = "uuid-001"
    │  ↓ emailVerificationUseCase.sendVerificationEmail(userId, eventId)
    │  ↓ IdempotencyService.executeIdempotent()
    │  ↓ → 문서 없음
    │  ↓ → operation() 호출
    │  ↓ → Firebase.sendEmailVerification()
    │  ↓ → 이메일 전송 ✅
    │  ↓ → idempotency 문서 생성 { eventId: "uuid-001" }
    │  └─ UI: "인증 메일을 전송했습니다"
    │
    ├─ 클릭 2-5: eventId = "uuid-001" (동일)
    │  ↓ IdempotencyService.executeIdempotent()
    │  ↓ → 문서 있음 + eventId 동일
    │  ↓ → operation() 스킵 ✅
    │  ↓ → 이메일 전송 안 함 (비용 절약)
    │  └─ UI: "인증 메일을 전송했습니다" (사용자는 정상 처리로 인식)
    │
    └─ 결과: Firebase 이메일 1개만 전송 (5개 아님)
```

### 6.3 비밀번호 리셋 플로우 (공격 차단)

```
[악의적 사용자] 특정 이메일로 100번 요청
    ↓
    ├─ 요청 1: eventId = "uuid-attack-001"
    │  ↓ passwordManagementUseCase.sendPasswordResetEmail(email, eventId)
    │  ↓ IdempotencyService.executeIdempotent()
    │  ↓ → 문서 없음
    │  ↓ → operation() 호출
    │  ↓ → Firebase.sendPasswordResetEmail()
    │  ↓ → 비밀번호 리셋 이메일 전송 ✅
    │  ↓ → idempotency 문서 생성 { eventId: "uuid-attack-001" }
    │  └─ 성공
    │
    ├─ 요청 2-100: eventId = "uuid-attack-001" (동일)
    │  ↓ IdempotencyService.executeIdempotent()
    │  ↓ → 문서 있음 + eventId 동일
    │  ↓ → operation() 스킵 ✅
    │  ↓ → 이메일 전송 안 함 (공격 차단)
    │  └─ 성공 (공격자는 알 수 없음)
    │
    └─ 결과: Firebase 이메일 1개만 전송 (100개 아님)
       → 공격 무력화 ✅
```

---

## 7. Firebase Firestore 구조

### 7.1 Idempotency 컬렉션 구조

```
Firestore
├── idempotency/  (컬렉션)
│   ├── auth_signup_{email}_{email}  (문서)
│   │   ├── eventId: "12345678-abcd-1234-abcd-123456789abc"
│   │   ├── timestamp: Timestamp(2025-01-20 10:30:00)
│   │   ├── entityType: "auth_signup"
│   │   ├── entityId: "user@example.com"
│   │   └── userId: "user@example.com"
│   │
│   ├── auth_email_verify_{userId}_{userId}  (문서)
│   │   ├── eventId: "87654321-dcba-4321-dcba-987654321cba"
│   │   ├── timestamp: Timestamp(2025-01-20 10:35:00)
│   │   ├── entityType: "auth_email_verify"
│   │   ├── entityId: "firebase-user-id-123"
│   │   └── userId: "firebase-user-id-123"
│   │
│   └── auth_password_reset_{email}_{email}  (문서)
│       ├── eventId: "abcdef12-3456-7890-abcd-ef1234567890"
│       ├── timestamp: Timestamp(2025-01-20 10:40:00)
│       ├── entityType: "auth_password_reset"
│       ├── entityId: "user@example.com"
│       └── userId: "user@example.com"
```

### 7.2 문서 ID 패턴

| UseCase | 문서 ID 패턴 | 예시 |
|---------|------------|------|
| **SignUp** | `auth_signup_{email}_{email}` | `auth_signup_user@test.com_user@test.com` |
| **EmailVerify** | `auth_email_verify_{userId}_{userId}` | `auth_email_verify_firebase123_firebase123` |
| **PasswordReset** | `auth_password_reset_{email}_{email}` | `auth_password_reset_user@test.com_user@test.com` |

### 7.3 정리 전략 (옵션)

**수동 정리**:
```dart
// 회원가입 완료 후 (선택사항)
await _idempotencyService.cleanupIdempotency(
  entityType: 'auth_signup',
  entityId: email,
  userId: email,
);
```

**Cloud Function 자동 정리** (권장):
```javascript
// firebase/functions/index.js
exports.cleanupIdempotency = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const cutoff = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)  // 7일 전
    );

    const snapshot = await admin.firestore()
      .collection('idempotency')
      .where('timestamp', '<', cutoff)
      .get();

    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));

    await batch.commit();
    console.log(`Deleted ${snapshot.size} old idempotency records`);
  });
```

---

## 8. 테스트 전략

### 8.1 Unit Test: IdempotencyService

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late IdempotencyService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = IdempotencyService(firestore: fakeFirestore);
  });

  group('IdempotencyService', () {
    test('첫 실행 시 operation 호출 및 eventId 저장', () async {
      // Given
      const eventId = 'test-uuid-123';
      var operationCalled = false;

      // When
      await service.executeIdempotent<void>(
        entityType: 'test',
        entityId: 'entity-1',
        userId: 'user-1',
        eventId: eventId,
        operation: (transaction) async {
          operationCalled = true;
        },
      );

      // Then
      expect(operationCalled, true);

      final doc = await fakeFirestore
          .collection('idempotency')
          .doc('test_entity-1_user-1')
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['eventId'], eventId);
    });

    test('동일 eventId 재시도 시 operation 스킵', () async {
      // Given
      const eventId = 'test-uuid-123';

      // 첫 실행
      await service.executeIdempotent<void>(
        entityType: 'test',
        entityId: 'entity-1',
        userId: 'user-1',
        eventId: eventId,
        operation: (transaction) async {},
      );

      // When: 재시도 (동일 eventId)
      var secondCallExecuted = false;

      await service.executeIdempotent<void>(
        entityType: 'test',
        entityId: 'entity-1',
        userId: 'user-1',
        eventId: eventId,
        operation: (transaction) async {
          secondCallExecuted = true;
        },
      );

      // Then: operation 실행 안 됨
      expect(secondCallExecuted, false);
    });

    test('다른 eventId 시도 시 IdempotencyViolation 발생', () async {
      // Given
      await service.executeIdempotent<void>(
        entityType: 'test',
        entityId: 'entity-1',
        userId: 'user-1',
        eventId: 'uuid-first',
        operation: (transaction) async {},
      );

      // When & Then: 다른 eventId
      expect(
        () => service.executeIdempotent<void>(
          entityType: 'test',
          entityId: 'entity-1',
          userId: 'user-1',
          eventId: 'uuid-second',  // ← 다름
          operation: (transaction) async {},
        ),
        throwsA(isA<IdempotencyViolation>()),
      );
    });
  });
}
```

### 8.2 Integration Test: SignUpWithEmailUseCase

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late SignUpWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;
  late IdempotencyService idempotencyService;

  setUp(() {
    mockRepository = MockAuthRepository();
    idempotencyService = IdempotencyService(
      firestore: FakeFirebaseFirestore(),
    );
    useCase = SignUpWithEmailUseCase(
      mockRepository,
      idempotencyService,
    );
  });

  group('SignUpWithEmailUseCase + IdempotencyService', () {
    const email = 'test@example.com';
    const password = 'password123';
    const eventId = 'test-uuid-123';

    test('첫 회원가입 성공', () async {
      // Given
      final user = AuthUser(uid: 'user-123', email: email);

      when(() => mockRepository.signUpWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => right(user));

      // When
      final result = await useCase.execute(
        email: email,
        password: password,
        eventId: eventId,
      );

      // Then
      expect(result.isRight(), true);
      verify(() => mockRepository.signUpWithEmailAndPassword(email, password))
          .called(1);
    });

    test('네트워크 재시도 시 중복 회원가입 방지', () async {
      // Given
      final user = AuthUser(uid: 'user-123', email: email);

      when(() => mockRepository.signUpWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => right(user));

      // 첫 실행
      await useCase.execute(
        email: email,
        password: password,
        eventId: eventId,
      );

      // When: 재시도 (동일 eventId)
      final result = await useCase.execute(
        email: email,
        password: password,
        eventId: eventId,
      );

      // Then: Repository 호출 안 됨
      verify(() => mockRepository.signUpWithEmailAndPassword(email, password))
          .called(1);  // ← 여전히 1번만

      expect(result.isRight(), true);
    });

    test('실제 중복 가입 시도 시 IdempotencyViolation', () async {
      // Given
      final user = AuthUser(uid: 'user-123', email: email);

      when(() => mockRepository.signUpWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => right(user));

      // 첫 실행
      await useCase.execute(
        email: email,
        password: password,
        eventId: 'uuid-first',
      );

      // When: 다른 eventId로 재시도
      final result = await useCase.execute(
        email: email,
        password: password,
        eventId: 'uuid-second',  // ← 다름
      );

      // Then: EmailAlreadyInUse 에러
      result.fold(
        (failure) {
          expect(failure, isA<EmailAlreadyInUse>());
        },
        (user) => fail('Should not be success'),
      );
    });
  });
}
```

---

## 9. 롤백 계획

### 9.1 Git 롤백

```bash
# 변경사항 확인
git status
git diff lib/features/auth/domain/usecases/

# UseCase 롤백
git checkout HEAD -- lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart
git checkout HEAD -- lib/features/auth/domain/usecases/email_verification_usecase.dart
git checkout HEAD -- lib/features/auth/domain/usecases/password_management_usecase.dart

# UI 롤백 (eventId 생성 제거)
git checkout HEAD -- lib/features/auth/presentation/screens/signup/
git checkout HEAD -- lib/features/auth/presentation/screens/email_verification/
git checkout HEAD -- lib/features/auth/presentation/screens/forgot_password/

# DI 롤백
git checkout HEAD -- lib/app/di.dart

# 의존성 제거 (선택사항)
# pubspec.yaml에서 uuid 제거 후
flutter pub get
```

### 9.2 수동 롤백

```bash
# 백업 파일 복원
cp lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart.backup \
   lib/features/auth/domain/usecases/sign_up_with_email_usecase.dart

cp lib/features/auth/domain/usecases/email_verification_usecase.dart.backup \
   lib/features/auth/domain/usecases/email_verification_usecase.dart

cp lib/features/auth/domain/usecases/password_management_usecase.dart.backup \
   lib/features/auth/domain/usecases/password_management_usecase.dart

# 컴파일 확인
flutter analyze
```

### 9.3 Firestore 정리 (선택사항)

```bash
# Firebase Console에서 idempotency 컬렉션 삭제
# 또는 Cloud Function 배포 제거
```

---

## 📊 Phase 4 완료 체크리스트

### UseCases (3개)
- [ ] `sign_up_with_email_usecase.dart` IdempotencyService 적용
- [ ] `email_verification_usecase.dart` IdempotencyService 적용
- [ ] `password_management_usecase.dart` IdempotencyService 적용

### DI Layer
- [ ] `lib/app/di.dart`에 IdempotencyService 등록
- [ ] 3개 UseCase에 IdempotencyService 주입

### UI Layer (3개 화면)
- [ ] `create_account_widget.dart` UUID 생성 추가
- [ ] `popup_timer_email_widget.dart` UUID 생성 추가
- [ ] `forgot_password_widget.dart` UUID 생성 추가

### Firestore
- [ ] idempotency 컬렉션 구조 확인
- [ ] Cloud Function 정리 스크립트 배포 (선택사항)

### 공통
- [ ] `pubspec.yaml`에 uuid 의존성 추가
- [ ] Git 커밋 (롤백 포인트)
- [ ] `flutter analyze` 통과 확인
- [ ] Integration 테스트 6개 통과 확인
- [ ] 3가지 시나리오 수동 테스트 (첫 실행, 재시도, 중복)

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | Integration 테스트 6개 이상 통과 |
| **IdempotencyService** | 3개 UseCase 모두 적용 |
| **Firestore 구조** | idempotency 컬렉션 정상 생성 |
| **시나리오 검증** | 첫 실행/재시도/중복 모두 정상 작동 |

---

## 🎯 완료 후

**Phase 1-4 모두 완료!** 🎉

Auth Feature가 Voting Feature 패턴 100% 적용 완료:
- ✅ Phase 1: Freezed Failure
- ✅ Phase 2: Either Pattern
- ✅ Phase 3: Riverpod 2.x
- ✅ Phase 4: IdempotencyService

**다음 작업**:
- [ ] 전체 통합 테스트 실행
- [ ] UI/UX 테스트 (8개 화면)
- [ ] Performance 측정
- [ ] Legacy 코드 삭제 (auth_provider.dart)
- [ ] 문서 업데이트 (CLAUDE.md, README.md)
