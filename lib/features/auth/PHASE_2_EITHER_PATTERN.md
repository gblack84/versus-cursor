# Phase 2: Either Pattern 마이그레이션

> **소요 시간**: 2일
> **난이도**: ⭐⭐⭐☆☆ (중간)
> **영향 범위**: Domain Layer (9 UseCases) + Data Layer (1 Repository) + Presentation Layer (1 Provider)
> **UI 영향**: ❌ 없음 (Provider가 추상화 - Phase 3에서 UI 변경)

---

## 📋 목차

1. [개요](#1-개요)
2. [현재 상태 분석](#2-현재-상태-분석)
3. [마이그레이션 목표](#3-마이그레이션-목표)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [백엔드-UI 연결](#6-백엔드-ui-연결)
7. [테스트 전략](#7-테스트-전략)
8. [롤백 계획](#8-롤백-계획)

---

## 1. 개요

### 1.1 Phase 2의 목적

Voting Feature의 함수형 에러 처리 패턴을 Auth Feature에 적용합니다:
- ✅ **Either<L,R> 패턴**: Result<T> → Either<AuthFailure, T>
- ✅ **dartz 라이브러리**: 함수형 프로그래밍 지원
- ✅ **타입 안전성 향상**: 컴파일 타임 에러 체크
- ✅ **명시적 에러 처리**: left(failure) vs right(success)

### 1.2 변경 대상 (11개 파일)

| Layer | 파일 | 라인 | 변경 내용 |
|-------|------|------|----------|
| **Domain** | `sign_in_with_email_usecase.dart` | 88줄 | Result → Either |
| **Domain** | `sign_up_with_email_usecase.dart` | 95줄 | Result → Either |
| **Domain** | `sign_in_with_google_usecase.dart` | 72줄 | Result → Either |
| **Domain** | `sign_in_with_apple_usecase.dart` | 68줄 | Result → Either |
| **Domain** | `sign_in_with_phone_usecase.dart` | 145줄 | Result → Either |
| **Domain** | `get_current_user_usecase.dart` | 45줄 | Result → Either |
| **Domain** | `password_management_usecase.dart` | 89줄 | Result → Either |
| **Domain** | `email_verification_usecase.dart` | 67줄 | Result → Either |
| **Domain** | `account_management_usecase.dart` | 156줄 | Result → Either |
| **Data** | `auth_repository_impl.dart` | 200줄 | Result → Either |
| **Presentation** | `auth_provider.dart` | 662줄 | Result.fold → Either.fold |

**총 변경**: 11개 파일, 1,687줄

### 1.3 왜 Either를 사용하는가?

**Result<T>의 한계**:
```dart
// ❌ Result<T> 패턴 (현재)
final result = await useCase.execute();

if (result is Success<AuthUser>) {
  final user = result.data;  // ← 타입 캐스팅 필요
  // ...
} else if (result is ResultFailure<AuthUser>) {
  final failure = result.failure;  // ← 타입 캐스팅 필요
  // ...
}

// 문제점:
// 1. 타입 캐스팅이 런타임에 발생
// 2. is 체크를 깜빡하면 런타임 에러
// 3. fold 패턴이 Optional
```

**Either<L,R>의 장점**:
```dart
// ✅ Either<L,R> 패턴 (목표)
final result = await useCase.execute();

result.fold(
  (failure) => handleError(failure),  // ← Left: 에러
  (user) => handleSuccess(user),     // ← Right: 성공
);

// 장점:
// 1. 컴파일 타임에 타입 체크
// 2. fold를 강제하여 에러 처리 누락 방지
// 3. 함수형 프로그래밍 패턴 (map, flatMap 등)
// 4. Voting Feature와 100% 동일한 패턴
```

**Voting Feature 참조 패턴**:
```dart
// lib/features/voting/domain/usecases/vote_usecase.dart
Future<Either<VoteFailure, void>> execute({
  required String postId,
  required String userId,
  required String choice,
}) async {
  try {
    // ...
    return right(unit);  // ✅ 성공
  } on VoteFailure catch (e) {
    return left(e);  // ❌ 실패
  }
}
```

---

## 2. 현재 상태 분석

### 2.1 Result<T> 패턴 구조

```dart
// lib/core/types/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
```

### 2.2 현재 UseCase 예시

**파일**: `lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart` (88줄)

```dart
// ❌ Before: Result<T> 패턴
import '/core/types/result.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  const SignInWithEmailUseCase(this._repository);

  /// 이메일/비밀번호로 로그인
  ///
  /// **Returns**: Result<AuthUser>
  /// - Success(user): 로그인 성공
  /// - ResultFailure(InvalidEmail): 이메일 형식 오류
  /// - ResultFailure(InvalidCredentials): 인증 실패
  Future<Result<AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    try {
      // 1. 이메일 형식 검증
      if (!_isValidEmail(email)) {
        return const ResultFailure(InvalidEmail());
      }

      // 2. 비밀번호 길이 검증
      if (password.length < 6) {
        return const ResultFailure(WeakPassword());
      }

      // 3. Repository 호출
      final user = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      // 4. 결과 확인
      if (user == null) {
        return const ResultFailure(InvalidCredentials());
      }

      return Success(user);
    } on AuthFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(Unexpected(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

### 2.3 현재 Provider 사용 예시

**파일**: `lib/features/auth/presentation/providers/auth_provider.dart` (일부)

```dart
// ❌ Before: Result.fold 패턴
Future<bool> signInWithEmail({
  required String email,
  required String password,
}) async {
  _setLoading(true);

  final result = await _signInWithEmailUseCase.execute(
    email: email,
    password: password,
  );

  // Result 타입 체크 필요
  if (result is Success<AuthUser>) {
    _currentUser = result.data;
    notifyListeners();
    return true;
  } else if (result is ResultFailure<AuthUser>) {
    _setError(result.failure.message);
    return false;
  }

  return false;
}
```

### 2.4 문제점 요약

| 문제 | 설명 | 해결 |
|------|------|------|
| **타입 안전성 부족** | `is` 체크로 런타임 판단 | Either로 컴파일 타임 체크 |
| **에러 처리 누락** | `else` 케이스 생략 가능 | fold 강제로 에러 처리 보장 |
| **보일러플레이트** | Success/ResultFailure 반복 | left/right로 간결화 |
| **Voting 불일치** | Result<T> vs Either<L,R> | Either로 통일 |

---

## 3. 마이그레이션 목표

### 3.1 Either<L,R> 패턴 구조

```dart
// dartz 라이브러리
import 'package:dartz/dartz.dart';

// Either<Left, Right>
// - Left: 에러 (AuthFailure)
// - Right: 성공 (AuthUser, void 등)

final Either<AuthFailure, AuthUser> result = ...;

result.fold(
  (failure) => print('Error: ${failure.message}'),  // Left
  (user) => print('Success: ${user.displayName}'),  // Right
);
```

### 3.2 목표 UseCase 예시

**파일**: `lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart` (82줄)

```dart
// ✅ After: Either<L,R> 패턴
import 'package:dartz/dartz.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  const SignInWithEmailUseCase(this._repository);

  /// 이메일/비밀번호로 로그인
  ///
  /// **Returns**: Either<AuthFailure, AuthUser>
  /// - Left(InvalidEmail): 이메일 형식 오류
  /// - Left(InvalidCredentials): 인증 실패
  /// - Right(user): 로그인 성공
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    try {
      // 1. 이메일 형식 검증
      if (!_isValidEmail(email)) {
        return left(const AuthFailure.invalidEmail());
      }

      // 2. 비밀번호 길이 검증
      if (password.length < 6) {
        return left(const AuthFailure.weakPassword());
      }

      // 3. Repository 호출
      final user = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      // 4. 결과 확인
      if (user == null) {
        return left(const AuthFailure.invalidCredentials());
      }

      return right(user);
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

### 3.3 목표 Provider 사용 예시

```dart
// ✅ After: Either.fold 패턴
Future<bool> signInWithEmail({
  required String email,
  required String password,
}) async {
  _setLoading(true);

  final result = await _signInWithEmailUseCase.execute(
    email: email,
    password: password,
  );

  // fold 강제로 에러 처리 보장
  return result.fold(
    (failure) {
      _setError(failure.message);
      return false;
    },
    (user) {
      _currentUser = user;
      notifyListeners();
      return true;
    },
  );
}
```

### 3.4 변경 요약

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **Import** | `import '/core/types/result.dart';` | `import 'package:dartz/dartz.dart';` | dartz |
| **반환 타입** | `Future<Result<AuthUser>>` | `Future<Either<AuthFailure, AuthUser>>` | Either |
| **성공 반환** | `return Success(user);` | `return right(user);` | right |
| **실패 반환** | `return ResultFailure(failure);` | `return left(failure);` | left |
| **에러 처리** | `if (result is Success) { ... }` | `result.fold((l) => ..., (r) => ...)` | fold |
| **코드 라인** | 88줄 | 82줄 | -6줄 (7% 감소) |

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: 의존성 추가**

```yaml
# pubspec.yaml
dependencies:
  dartz: ^0.10.1
```

```bash
flutter pub get
```

**Step 2: 백업 생성**

```bash
# Domain Layer 백업
cp -r lib/features/auth/domain/usecases lib/features/auth/domain/usecases.backup

# Data Layer 백업
cp -r lib/features/auth/data/repositories lib/features/auth/data/repositories.backup

# Presentation Layer 백업
cp lib/features/auth/presentation/providers/auth_provider.dart \
   lib/features/auth/presentation/providers/auth_provider.dart.backup

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(auth): Backup before Either Pattern migration"
```

### 4.2 Repository 인터페이스 수정

**Step 3: IAuthRepository 반환 타입 변경**

**파일**: `lib/features/auth/domain/repositories/i_auth_repository.dart`

```dart
// Before
Future<AuthUser?> signInWithEmailAndPassword(String email, String password);
Future<AuthUser?> signUpWithEmailAndPassword(String email, String password);
// ...

// After
import 'package:dartz/dartz.dart';

Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
  String email,
  String password,
);

Future<Either<AuthFailure, AuthUser>> signUpWithEmailAndPassword(
  String email,
  String password,
);
// ...
```

**Step 4: AuthRepositoryImpl 구현 변경**

**파일**: `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
// Before
@override
Future<AuthUser?> signInWithEmailAndPassword(
  String email,
  String password,
) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user?.toAuthUser();
  } catch (e) {
    return null;
  }
}

// After
@override
Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
  String email,
  String password,
) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user?.toAuthUser();

    if (user == null) {
      return left(const AuthFailure.invalidCredentials());
    }

    return right(user);
  } on FirebaseAuthException catch (e) {
    return left(_mapFirebaseException(e));
  } catch (e) {
    return left(AuthFailure.unexpected(e.toString()));
  }
}

// Helper 메서드
AuthFailure _mapFirebaseException(FirebaseAuthException e) {
  return switch (e.code) {
    'user-not-found' => const AuthFailure.userNotFound(),
    'wrong-password' => const AuthFailure.wrongPassword(),
    'invalid-email' => const AuthFailure.invalidEmail(),
    'user-disabled' => const AuthFailure.userDisabled(),
    'too-many-requests' => const AuthFailure.tooManyRequests(),
    'network-request-failed' => const AuthFailure.networkError(),
    _ => AuthFailure.unexpected(e.message),
  };
}
```

### 4.3 UseCases 수정 (9개 파일)

**패턴 1: 기본 UseCase 변경**

```dart
// Before
import '/core/types/result.dart';

class XxxUseCase {
  Future<Result<T>> execute(...) async {
    try {
      // ...
      return Success(data);
    } on AuthFailure catch (e) {
      return ResultFailure(e);
    }
  }
}

// After
import 'package:dartz/dartz.dart';

class XxxUseCase {
  Future<Either<AuthFailure, T>> execute(...) async {
    try {
      // ...
      return right(data);
    } on AuthFailure catch (e) {
      return left(e);
    }
  }
}
```

**패턴 2: void 반환 UseCase**

```dart
// Before
Future<Result<void>> execute(...) async {
  // ...
  return const Success(null);  // ← void를 null로 표현
}

// After
import 'package:dartz/dartz.dart';

Future<Either<AuthFailure, Unit>> execute(...) async {
  // ...
  return right(unit);  // ← dartz의 Unit 타입 사용
}
```

### 4.4 Provider 수정

**Step 5: auth_provider.dart 수정**

**파일**: `lib/features/auth/presentation/providers/auth_provider.dart`

```dart
// Before: Result 패턴
Future<bool> signInWithEmail({
  required String email,
  required String password,
}) async {
  _setLoading(true);

  final result = await _signInWithEmailUseCase.execute(
    email: email,
    password: password,
  );

  if (result is Success<AuthUser>) {
    _currentUser = result.data;
    notifyListeners();
    return true;
  } else if (result is ResultFailure<AuthUser>) {
    _setError(result.failure.message);
    return false;
  }

  return false;
}

// After: Either 패턴
Future<bool> signInWithEmail({
  required String email,
  required String password,
}) async {
  _setLoading(true);

  final result = await _signInWithEmailUseCase.execute(
    email: email,
    password: password,
  );

  return result.fold(
    (failure) {
      _setError(failure.message);
      return false;
    },
    (user) {
      _currentUser = user;
      notifyListeners();
      return true;
    },
  );
}
```

### 4.5 컴파일 확인

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 결과:
# - Result import 에러 → Either로 수정
# - Success/ResultFailure 미정의 에러 → right/left로 수정
```

### 4.6 수정 완료 검증

```bash
# UseCase 파일 확인
grep -r "Result<" lib/features/auth/domain/usecases/
# → 결과 없어야 함 (모두 Either로 변경됨)

grep -r "Either<" lib/features/auth/domain/usecases/
# → 9개 파일 발견되어야 함

# Repository 파일 확인
grep "Either<" lib/features/auth/data/repositories/auth_repository_impl.dart
# → Either 사용 확인

# Provider 파일 확인
grep "fold" lib/features/auth/presentation/providers/auth_provider.dart
# → fold 패턴 사용 확인
```

---

## 5. Before/After 전체 코드

### 5.1 UseCase 예시 1: SignInWithEmailUseCase

<details>
<summary>Before 코드 보기 (88줄)</summary>

```dart
// lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart
import '/core/types/result.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  const SignInWithEmailUseCase(this._repository);

  Future<Result<AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return const ResultFailure(InvalidEmail());
      }

      if (password.length < 6) {
        return const ResultFailure(WeakPassword());
      }

      final user = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user == null) {
        return const ResultFailure(InvalidCredentials());
      }

      return Success(user);
    } on AuthFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(Unexpected(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

</details>

<details>
<summary>After 코드 보기 (82줄)</summary>

```dart
// lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart
import 'package:dartz/dartz.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  const SignInWithEmailUseCase(this._repository);

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

      final result = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      return result;  // Repository가 Either 반환
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

### 5.2 UseCase 예시 2: EmailVerificationUseCase (void 반환)

<details>
<summary>Before 코드 보기 (67줄)</summary>

```dart
// lib/features/auth/domain/usecases/email_verification_usecase.dart
import '/core/types/result.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class EmailVerificationUseCase {
  final IAuthRepository _repository;

  const EmailVerificationUseCase(this._repository);

  Future<Result<void>> sendVerificationEmail() async {
    try {
      await _repository.sendEmailVerification();
      return const Success(null);
    } on AuthFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(Unexpected(e.toString()));
    }
  }

  Future<Result<void>> checkEmailVerified() async {
    try {
      final isVerified = await _repository.isEmailVerified();

      if (!isVerified) {
        return const ResultFailure(EmailNotVerified());
      }

      return const Success(null);
    } on AuthFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(Unexpected(e.toString()));
    }
  }
}
```

</details>

<details>
<summary>After 코드 보기 (65줄)</summary>

```dart
// lib/features/auth/domain/usecases/email_verification_usecase.dart
import 'package:dartz/dartz.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class EmailVerificationUseCase {
  final IAuthRepository _repository;

  const EmailVerificationUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> sendVerificationEmail() async {
    try {
      await _repository.sendEmailVerification();
      return right(unit);  // ← dartz의 Unit 사용
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  Future<Either<AuthFailure, Unit>> checkEmailVerified() async {
    try {
      final isVerified = await _repository.isEmailVerified();

      if (!isVerified) {
        return left(const AuthFailure.emailNotVerified());
      }

      return right(unit);  // ← dartz의 Unit 사용
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

</details>

### 5.3 Repository 예시: AuthRepositoryImpl

<details>
<summary>Before 코드 보기 (일부)</summary>

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.toAuthUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUser?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.toAuthUser();
    } catch (e) {
      return null;
    }
  }
}
```

</details>

<details>
<summary>After 코드 보기 (일부)</summary>

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user?.toAuthUser();

      if (user == null) {
        return left(const AuthFailure.invalidCredentials());
      }

      return right(user);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user?.toAuthUser();

      if (user == null) {
        return left(const AuthFailure.unexpected('Failed to create user'));
      }

      return right(user);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  // Firebase Exception → AuthFailure 매핑
  AuthFailure _mapFirebaseException(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const AuthFailure.userNotFound(),
      'wrong-password' => const AuthFailure.wrongPassword(),
      'invalid-email' => const AuthFailure.invalidEmail(),
      'email-already-in-use' => const AuthFailure.emailAlreadyInUse(),
      'weak-password' => const AuthFailure.weakPassword(),
      'user-disabled' => const AuthFailure.userDisabled(),
      'too-many-requests' => const AuthFailure.tooManyRequests(),
      'network-request-failed' => const AuthFailure.networkError(),
      'invalid-credential' => const AuthFailure.invalidCredentials(),
      'requires-recent-login' => const AuthFailure.requiresRecentLogin(),
      _ => AuthFailure.unexpected(e.message),
    };
  }
}
```

</details>

### 5.4 차이점 비교

```diff
// UseCase
- import '/core/types/result.dart';
+ import 'package:dartz/dartz.dart';

- Future<Result<AuthUser>> execute(...) async {
+ Future<Either<AuthFailure, AuthUser>> execute(...) async {

-     return const ResultFailure(InvalidEmail());
+     return left(const AuthFailure.invalidEmail());

-     return Success(user);
+     return right(user);

// Repository
- Future<AuthUser?> signInWithEmailAndPassword(...) async {
+ Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(...) async {

-   return credential.user?.toAuthUser();
+   final user = credential.user?.toAuthUser();
+   if (user == null) {
+     return left(const AuthFailure.invalidCredentials());
+   }
+   return right(user);

// Provider
- if (result is Success<AuthUser>) {
-   _currentUser = result.data;
-   return true;
- } else if (result is ResultFailure<AuthUser>) {
-   _setError(result.failure.message);
-   return false;
- }

+ return result.fold(
+   (failure) {
+     _setError(failure.message);
+     return false;
+   },
+   (user) {
+     _currentUser = user;
+     notifyListeners();
+     return true;
+   },
+ );
```

---

## 6. 백엔드-UI 연결

### 6.1 Phase 2에서는 UI 변경 없음

**중요**: Phase 2는 **Domain/Data Layer**만 수정합니다. UI는 Phase 3에서 변경됩니다.

**이유**:
- `auth_provider.dart`가 **추상화 레이어** 역할
- UI는 Provider만 바라보므로 내부 구현 변경 영향 없음
- Provider가 Either.fold를 내부적으로 처리하여 bool 반환

```dart
// UI Layer (변경 없음)
class LoginPageWidget extends StatefulWidget {
  // ...

  Future<void> _handleLogin() async {
    final success = await _authProvider.signInWithEmail(
      email: email,
      password: password,
    );

    if (success) {
      context.goNamed('HomePage');
    } else {
      // _authProvider.errorMessage 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authProvider.errorMessage ?? 'Login failed')),
      );
    }
  }
}

// Provider Layer (내부만 변경)
class AuthProvider extends ChangeNotifier {
  // ...

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _signInWithEmailUseCase.execute(...);

    // ✅ Either.fold로 처리, UI에는 bool 반환
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }
}
```

### 6.2 데이터 플로우 (Phase 2)

```
[UI Layer] (변경 없음)
    ↓ _authProvider.signInWithEmail()
    ↓ → bool 반환

[Presentation Layer] (내부만 변경)
auth_provider.dart
    ↓ _signInWithEmailUseCase.execute()
    ↓ ← Either<AuthFailure, AuthUser> 반환
    ↓ .fold() 처리
    ↓ → bool 변환

[Domain Layer] (Either 적용)
sign_in_with_email_usecase.dart
    ↓ _repository.signInWithEmailAndPassword()
    ↓ ← Either<AuthFailure, AuthUser> 반환
    ↓ → Either 그대로 반환

[Data Layer] (Either 적용)
auth_repository_impl.dart
    ↓ FirebaseAuth.signInWithEmailAndPassword()
    ↓ ← UserCredential 반환
    ↓ → Either<AuthFailure, AuthUser> 변환

[Firebase Backend]
Firebase Auth
```

---

## 7. 테스트 전략

### 7.1 UseCase Unit Test

**테스트 파일**: `lib/features/auth/test/unit/domain/usecases/sign_in_with_email_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:versus_cursor/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:versus_cursor/features/auth/domain/failures/auth_failure.dart';
import 'package:versus_cursor/features/auth/domain/entities/auth_user.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignInWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmailUseCase(mockRepository);
  });

  group('SignInWithEmailUseCase - Either Pattern', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tUser = AuthUser(
      uid: 'test-uid',
      email: tEmail,
      displayName: 'Test User',
    );

    test('성공 시 Right(AuthUser) 반환', () async {
      // Given
      when(() => mockRepository.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => right(tUser));

      // When
      final result = await useCase.execute(
        email: tEmail,
        password: tPassword,
      );

      // Then
      expect(result, isA<Right<AuthFailure, AuthUser>>());

      result.fold(
        (failure) => fail('Should not be failure'),
        (user) {
          expect(user.uid, tUser.uid);
          expect(user.email, tUser.email);
        },
      );

      verify(() => mockRepository.signInWithEmailAndPassword(tEmail, tPassword))
          .called(1);
    });

    test('이메일 형식 오류 시 Left(InvalidEmail) 반환', () async {
      // Given
      const invalidEmail = 'invalid-email';

      // When
      final result = await useCase.execute(
        email: invalidEmail,
        password: tPassword,
      );

      // Then
      expect(result, isA<Left<AuthFailure, AuthUser>>());

      result.fold(
        (failure) {
          expect(failure, isA<InvalidEmail>());
          expect(failure.message, '이메일 형식이 올바르지 않습니다');
        },
        (user) => fail('Should not be success'),
      );

      verifyNever(() => mockRepository.signInWithEmailAndPassword(any(), any()));
    });

    test('비밀번호 길이 오류 시 Left(WeakPassword) 반환', () async {
      // Given
      const weakPassword = '12345';  // 6자 미만

      // When
      final result = await useCase.execute(
        email: tEmail,
        password: weakPassword,
      );

      // Then
      result.fold(
        (failure) {
          expect(failure, isA<WeakPassword>());
        },
        (user) => fail('Should not be success'),
      );
    });

    test('Repository 에러 시 Left(AuthFailure) 반환', () async {
      // Given
      when(() => mockRepository.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => left(const AuthFailure.userNotFound()));

      // When
      final result = await useCase.execute(
        email: tEmail,
        password: tPassword,
      );

      // Then
      result.fold(
        (failure) {
          expect(failure, isA<UserNotFound>());
        },
        (user) => fail('Should not be success'),
      );
    });

    test('fold로 두 케이스 모두 처리', () async {
      // Given
      when(() => mockRepository.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => right(tUser));

      // When
      final result = await useCase.execute(
        email: tEmail,
        password: tPassword,
      );

      // Then
      final message = result.fold(
        (failure) => 'Error: ${failure.message}',
        (user) => 'Success: ${user.email}',
      );

      expect(message, 'Success: test@example.com');
    });
  });
}
```

### 7.2 Repository Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(mockFirebaseAuth);
  });

  group('AuthRepositoryImpl - Either Pattern', () {
    test('Firebase 성공 시 Right(AuthUser) 반환', () async {
      // Given
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockCredential.user).thenReturn(mockUser);

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockCredential);

      // When
      final result = await repository.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Then
      expect(result, isA<Right<AuthFailure, AuthUser>>());
    });

    test('Firebase Exception 시 Left(AuthFailure) 반환', () async {
      // Given
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // When
      final result = await repository.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Then
      result.fold(
        (failure) {
          expect(failure, isA<UserNotFound>());
        },
        (user) => fail('Should not be success'),
      );
    });
  });
}
```

### 7.3 테스트 실행

```bash
# UseCase 테스트
flutter test lib/features/auth/test/unit/domain/usecases/

# Repository 테스트
flutter test lib/features/auth/test/unit/data/repositories/

# 전체 Auth 테스트
flutter test lib/features/auth/test/

# 커버리지 포함
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 8. 롤백 계획

### 8.1 Git 롤백

```bash
# 변경사항 확인
git status
git diff lib/features/auth/

# 단계별 롤백
# Domain Layer
git checkout HEAD -- lib/features/auth/domain/usecases/
git checkout HEAD -- lib/features/auth/domain/repositories/

# Data Layer
git checkout HEAD -- lib/features/auth/data/repositories/

# Presentation Layer
git checkout HEAD -- lib/features/auth/presentation/providers/auth_provider.dart

# 의존성 제거 (선택사항)
# pubspec.yaml에서 dartz 제거 후
flutter pub get
```

### 8.2 수동 롤백

```bash
# 백업 파일 복원
cp -r lib/features/auth/domain/usecases.backup lib/features/auth/domain/usecases
cp -r lib/features/auth/data/repositories.backup lib/features/auth/data/repositories
cp lib/features/auth/presentation/providers/auth_provider.dart.backup \
   lib/features/auth/presentation/providers/auth_provider.dart

# 컴파일 확인
flutter analyze
```

### 8.3 롤백 검증

```bash
# Result 패턴 확인
grep -r "Result<" lib/features/auth/domain/usecases/
# → 9개 파일 발견되어야 함

# Either 패턴 확인 (없어야 함)
grep -r "Either<" lib/features/auth/
# → 결과 없어야 함

# 테스트 실행
flutter test lib/features/auth/test/

# 앱 실행 확인
flutter run
```

---

## 📊 Phase 2 완료 체크리스트

### Domain Layer (9 UseCases)
- [ ] `sign_in_with_email_usecase.dart` Either 적용
- [ ] `sign_up_with_email_usecase.dart` Either 적용
- [ ] `sign_in_with_google_usecase.dart` Either 적용
- [ ] `sign_in_with_apple_usecase.dart` Either 적용
- [ ] `sign_in_with_phone_usecase.dart` Either 적용
- [ ] `get_current_user_usecase.dart` Either 적용
- [ ] `password_management_usecase.dart` Either 적용
- [ ] `email_verification_usecase.dart` Either 적용
- [ ] `account_management_usecase.dart` Either 적용

### Data Layer (1 Repository)
- [ ] `auth_repository_impl.dart` Either 적용
- [ ] `_mapFirebaseException` 헬퍼 메서드 추가

### Presentation Layer (1 Provider)
- [ ] `auth_provider.dart` Either.fold 적용

### 공통
- [ ] `pubspec.yaml`에 dartz 의존성 추가
- [ ] Git 커밋 (롤백 포인트)
- [ ] `flutter analyze` 통과 확인
- [ ] Unit 테스트 통과 확인 (15개 이상)
- [ ] UI 동작 확인 (8개 화면)

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | 15개 이상 테스트 전부 통과 |
| **Result 제거** | `grep -r "Result<" lib/features/auth/` 결과 없음 |
| **Either 적용** | 11개 파일 모두 Either 사용 |
| **UI 유지** | 8개 화면 정상 작동 |

---

## 🎯 다음 단계

Phase 2 완료 후 **Phase 3: Riverpod 2.x**로 진행합니다.

- **대상**: auth_provider.dart → auth_providers.dart (Riverpod) + UI 8개 화면
- **작업**: ChangeNotifier → StreamProvider.family + keepAlive()
- **소요 시간**: 1.5일

문서: `PHASE_3_RIVERPOD.md`
