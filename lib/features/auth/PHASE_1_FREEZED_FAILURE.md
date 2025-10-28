# Phase 1: Freezed Failure 마이그레이션

> **소요 시간**: 1일
> **난이도**: ⭐⭐☆☆☆ (낮음)
> **영향 범위**: Domain Layer (auth_failure.dart 단일 파일)
> **UI 영향**: ❌ 없음 (내부 구조만 변경)

---

## 📋 목차

1. [개요](#1-개요)
2. [현재 상태 분석](#2-현재-상태-분석)
3. [마이그레이션 목표](#3-마이그레이션-목표)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [테스트 전략](#6-테스트-전략)
7. [롤백 계획](#7-롤백-계획)

---

## 1. 개요

### 1.1 Phase 1의 목적

Voting Feature의 고급 패턴을 Auth Feature에 적용합니다:
- ✅ **Freezed 자동 생성**: Manual Sealed Class → Freezed Pattern
- ✅ **코드 라인 감소**: 126줄 → 82줄 (35% 감소)
- ✅ **유지보수성 향상**: 수동 구현 → 자동 생성

### 1.2 변경 대상

| 항목 | 내용 |
|------|------|
| **파일** | `lib/features/auth/domain/failures/auth_failure.dart` |
| **현재 라인** | 126줄 |
| **목표 라인** | 82줄 (44줄 감소) |
| **Failure 타입** | 18개 |
| **의존성 추가** | `freezed`, `freezed_annotation` |

### 1.3 왜 Freezed를 사용하는가?

**Manual Sealed Class의 문제점**:
```dart
// ❌ 수동 구현 (85줄)
class InvalidEmail extends AuthFailure {
  const InvalidEmail() : super();
}

class WeakPassword extends AuthFailure {
  const WeakPassword() : super();
}

class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse() : super();
}

// ... 15개 더 (반복적인 보일러플레이트)
```

**Freezed의 장점**:
```dart
// ✅ 자동 생성 (18줄)
@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
  // ... 15개 더 (간결한 factory 선언)
}

// 자동 생성되는 기능:
// - copyWith() 메서드
// - == 연산자 오버라이드
// - hashCode 구현
// - toString() 구현
// - when/map/maybeWhen/maybeMap 메서드
```

---

## 2. 현재 상태 분석

### 2.1 현재 파일 구조

```
lib/features/auth/domain/failures/
└── auth_failure.dart (126줄)
    ├── sealed class AuthFailure (기본 클래스)
    ├── 18개 Failure 서브클래스 (수동 구현)
    └── message getter (switch 표현식)
```

### 2.2 현재 코드 전체 (Before)

```dart
// lib/features/auth/domain/failures/auth_failure.dart
import '/core/errors/failure.dart';

/// Auth Feature의 실패 케이스를 나타내는 sealed class
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - UseCase에서 발생하는 모든 에러를 타입 안전하게 표현
/// - UI에서 사용자 친화적인 에러 메시지 제공
sealed class AuthFailure extends Failure {
  const AuthFailure() : super(message: '');

  @override
  String get message {
    return switch (this) {
      InvalidEmail() => '이메일 형식이 올바르지 않습니다',
      WeakPassword() => '비밀번호가 너무 약합니다 (최소 6자 이상)',
      EmailAlreadyInUse() => '이미 사용 중인 이메일입니다',
      UserNotFound() => '존재하지 않는 사용자입니다',
      WrongPassword() => '비밀번호가 일치하지 않습니다',
      UserDisabled() => '비활성화된 계정입니다',
      TooManyRequests() => '너무 많은 요청입니다. 잠시 후 다시 시도해주세요',
      NetworkError() => '네트워크 연결을 확인해주세요',
      InvalidCredentials() => '이메일 또는 비밀번호가 올바르지 않습니다',
      InvalidVerificationCode() => '인증 코드가 올바르지 않습니다',
      InvalidVerificationId() => '인증 ID가 올바르지 않습니다',
      PhoneNumberAlreadyInUse() => '이미 사용 중인 전화번호입니다',
      InvalidPhoneNumber() => '전화번호 형식이 올바르지 않습니다',
      SessionExpired() => '세션이 만료되었습니다. 다시 로그인해주세요',
      EmailNotVerified() => '이메일 인증이 필요합니다',
      OperationNotAllowed() => '허용되지 않은 작업입니다',
      RequiresRecentLogin() => '보안을 위해 다시 로그인이 필요합니다',
      Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// ❌ 수동으로 구현된 18개 Failure 클래스 (85줄)
// 이 부분이 Freezed로 자동 생성됩니다

/// 이메일 형식이 올바르지 않음
class InvalidEmail extends AuthFailure {
  const InvalidEmail() : super();
}

/// 비밀번호가 너무 약함 (최소 6자 미만)
class WeakPassword extends AuthFailure {
  const WeakPassword() : super();
}

/// 이미 사용 중인 이메일
class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse() : super();
}

/// 존재하지 않는 사용자
class UserNotFound extends AuthFailure {
  const UserNotFound() : super();
}

/// 비밀번호 불일치
class WrongPassword extends AuthFailure {
  const WrongPassword() : super();
}

/// 비활성화된 계정
class UserDisabled extends AuthFailure {
  const UserDisabled() : super();
}

/// 너무 많은 요청 (Rate Limiting)
class TooManyRequests extends AuthFailure {
  const TooManyRequests() : super();
}

/// 네트워크 연결 오류
class NetworkError extends AuthFailure {
  const NetworkError() : super();
}

/// 잘못된 인증 정보
class InvalidCredentials extends AuthFailure {
  const InvalidCredentials() : super();
}

/// 잘못된 인증 코드 (휴대폰 인증)
class InvalidVerificationCode extends AuthFailure {
  const InvalidVerificationCode() : super();
}

/// 잘못된 인증 ID (휴대폰 인증)
class InvalidVerificationId extends AuthFailure {
  const InvalidVerificationId() : super();
}

/// 이미 사용 중인 전화번호
class PhoneNumberAlreadyInUse extends AuthFailure {
  const PhoneNumberAlreadyInUse() : super();
}

/// 잘못된 전화번호 형식
class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber() : super();
}

/// 세션 만료
class SessionExpired extends AuthFailure {
  const SessionExpired() : super();
}

/// 이메일 미인증
class EmailNotVerified extends AuthFailure {
  const EmailNotVerified() : super();
}

/// 허용되지 않은 작업
class OperationNotAllowed extends AuthFailure {
  const OperationNotAllowed() : super();
}

/// 재로그인 필요
class RequiresRecentLogin extends AuthFailure {
  const RequiresRecentLogin() : super();
}

/// 예상치 못한 오류
class Unexpected extends AuthFailure {
  const Unexpected([this.errorMessage]) : super();
  final String? errorMessage;
}
```

### 2.3 문제점 분석

| 문제 | 설명 | 해결 |
|------|------|------|
| **보일러플레이트** | 18개 클래스 수동 작성 (85줄) | Freezed 자동 생성 |
| **유지보수 어려움** | 새 Failure 추가 시 수동 작업 | Factory 선언만 추가 |
| **== 연산자 없음** | Failure 비교 불가능 | Freezed 자동 구현 |
| **copyWith 없음** | Failure 수정 불가능 | Freezed 자동 구현 |
| **toString 일관성** | 수동 구현 필요 | Freezed 자동 구현 |

---

## 3. 마이그레이션 목표

### 3.1 목표 코드 (After)

```dart
// lib/features/auth/domain/failures/auth_failure.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failure.dart';

part 'auth_failure.freezed.dart';

/// Auth Feature의 실패 케이스를 나타내는 Freezed sealed class
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
///
/// **Voting Feature 패턴 100% 적용**:
/// ```dart
/// @freezed
/// sealed class VoteFailure with _$VoteFailure {
///   const factory VoteFailure.alreadyVoted() = AlreadyVoted;
///   // ...
/// }
/// ```
@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  // ✅ Freezed Factory 생성자들 (18개, 간결한 선언)

  /// 이메일 형식이 올바르지 않음
  const factory AuthFailure.invalidEmail() = InvalidEmail;

  /// 비밀번호가 너무 약함 (최소 6자 미만)
  const factory AuthFailure.weakPassword() = WeakPassword;

  /// 이미 사용 중인 이메일
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;

  /// 존재하지 않는 사용자
  const factory AuthFailure.userNotFound() = UserNotFound;

  /// 비밀번호 불일치
  const factory AuthFailure.wrongPassword() = WrongPassword;

  /// 비활성화된 계정
  const factory AuthFailure.userDisabled() = UserDisabled;

  /// 너무 많은 요청 (Rate Limiting)
  const factory AuthFailure.tooManyRequests() = TooManyRequests;

  /// 네트워크 연결 오류
  const factory AuthFailure.networkError() = NetworkError;

  /// 잘못된 인증 정보
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;

  /// 잘못된 인증 코드 (휴대폰 인증)
  const factory AuthFailure.invalidVerificationCode() = InvalidVerificationCode;

  /// 잘못된 인증 ID (휴대폰 인증)
  const factory AuthFailure.invalidVerificationId() = InvalidVerificationId;

  /// 이미 사용 중인 전화번호
  const factory AuthFailure.phoneNumberAlreadyInUse() = PhoneNumberAlreadyInUse;

  /// 잘못된 전화번호 형식
  const factory AuthFailure.invalidPhoneNumber() = InvalidPhoneNumber;

  /// 세션 만료
  const factory AuthFailure.sessionExpired() = SessionExpired;

  /// 이메일 미인증
  const factory AuthFailure.emailNotVerified() = EmailNotVerified;

  /// 허용되지 않은 작업
  const factory AuthFailure.operationNotAllowed() = OperationNotAllowed;

  /// 재로그인 필요
  const factory AuthFailure.requiresRecentLogin() = RequiresRecentLogin;

  /// 예상치 못한 오류
  const factory AuthFailure.unexpected([String? errorMessage]) = Unexpected;

  // ✅ Failure 인터페이스 구현
  @override
  String get message {
    return when(
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      weakPassword: () => '비밀번호가 너무 약합니다 (최소 6자 이상)',
      emailAlreadyInUse: () => '이미 사용 중인 이메일입니다',
      userNotFound: () => '존재하지 않는 사용자입니다',
      wrongPassword: () => '비밀번호가 일치하지 않습니다',
      userDisabled: () => '비활성화된 계정입니다',
      tooManyRequests: () => '너무 많은 요청입니다. 잠시 후 다시 시도해주세요',
      networkError: () => '네트워크 연결을 확인해주세요',
      invalidCredentials: () => '이메일 또는 비밀번호가 올바르지 않습니다',
      invalidVerificationCode: () => '인증 코드가 올바르지 않습니다',
      invalidVerificationId: () => '인증 ID가 올바르지 않습니다',
      phoneNumberAlreadyInUse: () => '이미 사용 중인 전화번호입니다',
      invalidPhoneNumber: () => '전화번호 형식이 올바르지 않습니다',
      sessionExpired: () => '세션이 만료되었습니다. 다시 로그인해주세요',
      emailNotVerified: () => '이메일 인증이 필요합니다',
      operationNotAllowed: () => '허용되지 않은 작업입니다',
      requiresRecentLogin: () => '보안을 위해 다시 로그인이 필요합니다',
      unexpected: (errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

### 3.2 변경 요약

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **파일 라인** | 126줄 | 82줄 | -44줄 (35% 감소) |
| **수동 클래스** | 18개 (85줄) | 0개 (자동 생성) | -85줄 |
| **Factory 선언** | 없음 | 18개 (18줄) | +18줄 |
| **when 메서드** | 수동 switch | Freezed 자동 | 자동 생성 |
| **==, hashCode** | 없음 | Freezed 자동 | 자동 생성 |
| **copyWith** | 없음 | Freezed 자동 | 자동 생성 |

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: 의존성 추가**

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
```

```bash
flutter pub get
```

**Step 2: 백업 생성**

```bash
# 현재 파일 백업
cp lib/features/auth/domain/failures/auth_failure.dart \
   lib/features/auth/domain/failures/auth_failure.dart.backup

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(auth): Backup before Freezed migration"
```

### 4.2 코드 변경

**Step 3: auth_failure.dart 수정**

```dart
// 1. Import 추가
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failure.dart';

// 2. Part 선언 추가
part 'auth_failure.freezed.dart';

// 3. 클래스 선언 변경
@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();  // Private 생성자 추가

  // 4. Factory 생성자들로 교체
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  // ... (18개 전부)

  // 5. message getter를 when으로 변경
  @override
  String get message {
    return when(
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      // ...
    );
  }
}

// 6. 수동 클래스들 전부 삭제 (85줄)
// ❌ class InvalidEmail extends AuthFailure { ... }
// ❌ class WeakPassword extends AuthFailure { ... }
// ... (18개 삭제)
```

**Step 4: Code Generation 실행**

```bash
# Freezed 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 생성 확인
ls -la lib/features/auth/domain/failures/
# auth_failure.dart
# auth_failure.freezed.dart  ← 새로 생성됨
```

**Step 5: 생성된 코드 확인**

```dart
// auth_failure.freezed.dart (자동 생성됨)
//
// 이 파일에는 다음이 포함됩니다:
// - 18개 Failure 클래스 구현
// - copyWith() 메서드
// - == 연산자
// - hashCode 구현
// - toString() 구현
// - when/map/maybeWhen/maybeMap 메서드
```

### 4.3 동작 확인

**Step 6: 컴파일 체크**

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 결과: 0 issues found
```

**Step 7: 기존 코드 동작 확인**

```dart
// 기존 코드는 변경 없이 동작
// (Phase 2에서 Either Pattern으로 마이그레이션)

// 예시: sign_in_with_email_usecase.dart
if (!_isValidEmail(email)) {
  return const ResultFailure(InvalidEmail());  // ✅ 여전히 작동
}

// Freezed로 생성된 클래스 사용
final failure = AuthFailure.invalidEmail();
print(failure.message);  // "이메일 형식이 올바르지 않습니다"
```

### 4.4 테스트 실행

```bash
# Unit 테스트
flutter test lib/features/auth/test/unit/domain/failures/

# 전체 테스트
flutter test

# 예상 결과: All tests passed
```

---

## 5. Before/After 전체 코드

### 5.1 Before (126줄)

<details>
<summary>전체 코드 보기 (클릭)</summary>

```dart
import '/core/errors/failure.dart';

sealed class AuthFailure extends Failure {
  const AuthFailure() : super(message: '');

  @override
  String get message {
    return switch (this) {
      InvalidEmail() => '이메일 형식이 올바르지 않습니다',
      WeakPassword() => '비밀번호가 너무 약합니다 (최소 6자 이상)',
      EmailAlreadyInUse() => '이미 사용 중인 이메일입니다',
      UserNotFound() => '존재하지 않는 사용자입니다',
      WrongPassword() => '비밀번호가 일치하지 않습니다',
      UserDisabled() => '비활성화된 계정입니다',
      TooManyRequests() => '너무 많은 요청입니다. 잠시 후 다시 시도해주세요',
      NetworkError() => '네트워크 연결을 확인해주세요',
      InvalidCredentials() => '이메일 또는 비밀번호가 올바르지 않습니다',
      InvalidVerificationCode() => '인증 코드가 올바르지 않습니다',
      InvalidVerificationId() => '인증 ID가 올바르지 않습니다',
      PhoneNumberAlreadyInUse() => '이미 사용 중인 전화번호입니다',
      InvalidPhoneNumber() => '전화번호 형식이 올바르지 않습니다',
      SessionExpired() => '세션이 만료되었습니다. 다시 로그인해주세요',
      EmailNotVerified() => '이메일 인증이 필요합니다',
      OperationNotAllowed() => '허용되지 않은 작업입니다',
      RequiresRecentLogin() => '보안을 위해 다시 로그인이 필요합니다',
      Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

class InvalidEmail extends AuthFailure {
  const InvalidEmail() : super();
}

class WeakPassword extends AuthFailure {
  const WeakPassword() : super();
}

class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse() : super();
}

class UserNotFound extends AuthFailure {
  const UserNotFound() : super();
}

class WrongPassword extends AuthFailure {
  const WrongPassword() : super();
}

class UserDisabled extends AuthFailure {
  const UserDisabled() : super();
}

class TooManyRequests extends AuthFailure {
  const TooManyRequests() : super();
}

class NetworkError extends AuthFailure {
  const NetworkError() : super();
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials() : super();
}

class InvalidVerificationCode extends AuthFailure {
  const InvalidCredentials() : super();
}

class InvalidVerificationId extends AuthFailure {
  const InvalidVerificationId() : super();
}

class PhoneNumberAlreadyInUse extends AuthFailure {
  const PhoneNumberAlreadyInUse() : super();
}

class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber() : super();
}

class SessionExpired extends AuthFailure {
  const SessionExpired() : super();
}

class EmailNotVerified extends AuthFailure {
  const EmailNotVerified() : super();
}

class OperationNotAllowed extends AuthFailure {
  const OperationNotAllowed() : super();
}

class RequiresRecentLogin extends AuthFailure {
  const RequiresRecentLogin() : super();
}

class Unexpected extends AuthFailure {
  const Unexpected([this.errorMessage]) : super();
  final String? errorMessage;
}
```

</details>

### 5.2 After (82줄)

<details>
<summary>전체 코드 보기 (클릭)</summary>

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failure.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
  const factory AuthFailure.userNotFound() = UserNotFound;
  const factory AuthFailure.wrongPassword() = WrongPassword;
  const factory AuthFailure.userDisabled() = UserDisabled;
  const factory AuthFailure.tooManyRequests() = TooManyRequests;
  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.invalidVerificationCode() = InvalidVerificationCode;
  const factory AuthFailure.invalidVerificationId() = InvalidVerificationId;
  const factory AuthFailure.phoneNumberAlreadyInUse() = PhoneNumberAlreadyInUse;
  const factory AuthFailure.invalidPhoneNumber() = InvalidPhoneNumber;
  const factory AuthFailure.sessionExpired() = SessionExpired;
  const factory AuthFailure.emailNotVerified() = EmailNotVerified;
  const factory AuthFailure.operationNotAllowed() = OperationNotAllowed;
  const factory AuthFailure.requiresRecentLogin() = RequiresRecentLogin;
  const factory AuthFailure.unexpected([String? errorMessage]) = Unexpected;

  @override
  String get message {
    return when(
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      weakPassword: () => '비밀번호가 너무 약합니다 (최소 6자 이상)',
      emailAlreadyInUse: () => '이미 사용 중인 이메일입니다',
      userNotFound: () => '존재하지 않는 사용자입니다',
      wrongPassword: () => '비밀번호가 일치하지 않습니다',
      userDisabled: () => '비활성화된 계정입니다',
      tooManyRequests: () => '너무 많은 요청입니다. 잠시 후 다시 시도해주세요',
      networkError: () => '네트워크 연결을 확인해주세요',
      invalidCredentials: () => '이메일 또는 비밀번호가 올바르지 않습니다',
      invalidVerificationCode: () => '인증 코드가 올바르지 않습니다',
      invalidVerificationId: () => '인증 ID가 올바르지 않습니다',
      phoneNumberAlreadyInUse: () => '이미 사용 중인 전화번호입니다',
      invalidPhoneNumber: () => '전화번호 형식이 올바르지 않습니다',
      sessionExpired: () => '세션이 만료되었습니다. 다시 로그인해주세요',
      emailNotVerified: () => '이메일 인증이 필요합니다',
      operationNotAllowed: () => '허용되지 않은 작업입니다',
      requiresRecentLogin: () => '보안을 위해 다시 로그인이 필요합니다',
      unexpected: (errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

</details>

### 5.3 차이점 비교

```diff
+ import 'package:freezed_annotation/freezed_annotation.dart';
  import '/core/errors/failure.dart';

+ part 'auth_failure.freezed.dart';

+ @freezed
- sealed class AuthFailure extends Failure {
+ sealed class AuthFailure with _$AuthFailure implements Failure {
+   const AuthFailure._();

-   const AuthFailure() : super(message: '');

+   const factory AuthFailure.invalidEmail() = InvalidEmail;
+   const factory AuthFailure.weakPassword() = WeakPassword;
+   // ... (18개 factory 생성자)

    @override
    String get message {
-     return switch (this) {
+     return when(
-       InvalidEmail() => '이메일 형식이 올바르지 않습니다',
+       invalidEmail: () => '이메일 형식이 올바르지 않습니다',
        // ...
-     };
+     );
    }
- }

- class InvalidEmail extends AuthFailure {
-   const InvalidEmail() : super();
- }
- // ... (18개 수동 클래스 삭제, 85줄)
```

---

## 6. 테스트 전략

### 6.1 Unit Test

**테스트 파일**: `lib/features/auth/test/unit/domain/failures/auth_failure_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_cursor/features/auth/domain/failures/auth_failure.dart';

void main() {
  group('AuthFailure - Freezed Pattern', () {
    test('Factory 생성자로 Failure 생성', () {
      // Given
      final failure = AuthFailure.invalidEmail();

      // Then
      expect(failure, isA<InvalidEmail>());
      expect(failure, isA<AuthFailure>());
    });

    test('message getter가 올바른 한국어 메시지 반환', () {
      // Given
      final failures = [
        AuthFailure.invalidEmail(),
        AuthFailure.weakPassword(),
        AuthFailure.emailAlreadyInUse(),
      ];

      // When & Then
      expect(failures[0].message, '이메일 형식이 올바르지 않습니다');
      expect(failures[1].message, '비밀번호가 너무 약합니다 (최소 6자 이상)');
      expect(failures[2].message, '이미 사용 중인 이메일입니다');
    });

    test('when 메서드로 패턴 매칭', () {
      // Given
      final failure = AuthFailure.unexpected('Custom error');

      // When
      final result = failure.when(
        invalidEmail: () => 'Email error',
        weakPassword: () => 'Password error',
        emailAlreadyInUse: () => 'Email in use',
        userNotFound: () => 'User not found',
        wrongPassword: () => 'Wrong password',
        userDisabled: () => 'User disabled',
        tooManyRequests: () => 'Too many requests',
        networkError: () => 'Network error',
        invalidCredentials: () => 'Invalid credentials',
        invalidVerificationCode: () => 'Invalid code',
        invalidVerificationId: () => 'Invalid ID',
        phoneNumberAlreadyInUse: () => 'Phone in use',
        invalidPhoneNumber: () => 'Invalid phone',
        sessionExpired: () => 'Session expired',
        emailNotVerified: () => 'Email not verified',
        operationNotAllowed: () => 'Operation not allowed',
        requiresRecentLogin: () => 'Requires login',
        unexpected: (msg) => 'Unexpected: $msg',
      );

      // Then
      expect(result, 'Unexpected: Custom error');
    });

    test('== 연산자가 올바르게 작동', () {
      // Given
      final failure1 = AuthFailure.invalidEmail();
      final failure2 = AuthFailure.invalidEmail();
      final failure3 = AuthFailure.weakPassword();

      // Then
      expect(failure1, equals(failure2));  // ✅ 같은 타입
      expect(failure1, isNot(equals(failure3)));  // ❌ 다른 타입
    });

    test('hashCode가 올바르게 생성', () {
      // Given
      final failure1 = AuthFailure.invalidEmail();
      final failure2 = AuthFailure.invalidEmail();

      // Then
      expect(failure1.hashCode, equals(failure2.hashCode));
    });

    test('toString이 올바르게 작동', () {
      // Given
      final failure = AuthFailure.unexpected('Test error');

      // When
      final string = failure.toString();

      // Then
      expect(string, contains('Unexpected'));
      expect(string, contains('Test error'));
    });

    test('copyWith으로 Failure 복사 (Unexpected만 가능)', () {
      // Given
      final failure = AuthFailure.unexpected('Original message');

      // When
      final copied = failure.maybeWhen(
        unexpected: (msg) => AuthFailure.unexpected('New message'),
        orElse: () => failure,
      );

      // Then
      expect(copied.message, contains('New message'));
    });
  });
}
```

### 6.2 테스트 실행

```bash
# Failure 테스트만 실행
flutter test lib/features/auth/test/unit/domain/failures/

# 전체 Auth 테스트
flutter test lib/features/auth/test/

# 커버리지 포함
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 6.3 예상 결과

```
✅ 00:02 +7: All tests passed!
```

---

## 7. 롤백 계획

### 7.1 Git 롤백

```bash
# 변경사항 확인
git status
git diff lib/features/auth/domain/failures/auth_failure.dart

# 단일 파일 롤백
git checkout HEAD -- lib/features/auth/domain/failures/auth_failure.dart

# 생성된 파일 삭제
rm lib/features/auth/domain/failures/auth_failure.freezed.dart

# 의존성 제거 (선택사항)
# pubspec.yaml에서 freezed 관련 제거 후
flutter pub get
```

### 7.2 수동 롤백

```bash
# 백업 파일 복원
cp lib/features/auth/domain/failures/auth_failure.dart.backup \
   lib/features/auth/domain/failures/auth_failure.dart

# 생성된 파일 삭제
rm lib/features/auth/domain/failures/auth_failure.freezed.dart

# 컴파일 확인
flutter analyze
```

### 7.3 롤백 검증

```bash
# 기존 코드로 정상 작동 확인
flutter test lib/features/auth/test/

# 앱 실행 확인
flutter run
```

---

## 📊 Phase 1 완료 체크리스트

- [ ] `pubspec.yaml`에 Freezed 의존성 추가
- [ ] `auth_failure.dart` 백업 생성
- [ ] Git 커밋 (롤백 포인트)
- [ ] `@freezed` 어노테이션 추가
- [ ] `part 'auth_failure.freezed.dart';` 추가
- [ ] 18개 Factory 생성자 작성
- [ ] `switch` → `when` 변경
- [ ] 85줄 수동 클래스 삭제
- [ ] `flutter pub run build_runner build` 실행
- [ ] `auth_failure.freezed.dart` 생성 확인
- [ ] `flutter analyze` 통과 확인
- [ ] Unit 테스트 7개 통과 확인
- [ ] 기존 UseCase 코드 정상 작동 확인

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | 7개 테스트 전부 통과 |
| **코드 감소** | 126줄 → 82줄 (35% 감소) |
| **생성 파일** | `auth_failure.freezed.dart` 존재 |
| **기능 유지** | 기존 UseCase 코드 정상 작동 |

---

## 🎯 다음 단계

Phase 1 완료 후 **Phase 2: Either Pattern**으로 진행합니다.

- **대상**: 9개 UseCase + 1개 Repository + 1개 Provider
- **작업**: `Result<T>` → `Either<AuthFailure, T>` 마이그레이션
- **소요 시간**: 2일

문서: `PHASE_2_EITHER_PATTERN.md`
