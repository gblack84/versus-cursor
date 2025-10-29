# Phase 1: ProfileFailure 아키텍처 결정

> **⚠️ 중요**: ProfileFailure는 이미 sealed class로 구현되어 있습니다.
> 이 문서는 @freezed 마이그레이션 여부를 결정하기 위한 의사결정 가이드입니다.

> **소요 시간**: 1일 (Option A 선택 시) / 0일 (Option B 선택 시)
> **난이도**: ⭐⭐☆☆☆ (낮음)
> **영향 범위**: Domain Layer (profile_failure.dart 단일 파일)
> **UI 영향**: ❌ 없음 (내부 구조만 변경)

---

## 📋 목차

1. [현재 상태 분석](#1-현재-상태-분석)
2. [Cross-Feature 일관성 분석](#2-cross-feature-일관성-분석)
3. [아키텍처 결정](#3-아키텍처-결정)
4. [Option A: @freezed 마이그레이션](#4-option-a-freezed-마이그레이션)
5. [Option B: 현재 패턴 유지](#5-option-b-현재-패턴-유지)
6. [권장사항](#6-권장사항)
7. [테스트 전략](#7-테스트-전략)

---

## 1. 현재 상태 분석

### 1.1 ProfileFailure 현재 구현

ProfileFailure는 **이미 sealed class + switch 패턴으로 완성**되어 있습니다:

```dart
// lib/features/profile/domain/failures/profile_failure.dart
import '/core/errors/failure.dart';

/// ProfileFailure sealed class
///
/// **Clean Architecture v4.0 - Result Pattern**:
/// - Sealed class로 컴파일 타임 타입 안전성 보장
/// - Core Failure 상속으로 Result<T>와 완벽 호환
/// - Switch 패턴 매칭으로 한국어 메시지 중앙 관리
sealed class ProfileFailure extends Failure {
  const ProfileFailure() : super(message: '');

  @override
  String get message {
    return switch (this) {
      ValidationFailure(:final field) => '입력 정보를 확인해주세요: $field',
      ProfileNotFound(:final userId) => userId != null
          ? '프로필을 찾을 수 없습니다 (UID: $userId)'
          : '프로필을 찾을 수 없습니다',
      FirestoreRead(:final operation) => '데이터 읽기 실패: $operation',
      FirestoreWrite(:final operation) => '데이터 쓰기 실패: $operation',
      FirebaseStorage(:final operation) => '파일 업로드 실패: $operation',
      InvalidInput(:final field, :final reason) => '$field: $reason',
      PermissionDenied(:final resource) => '접근 권한이 없습니다: $resource',
      NetworkProfile() => '네트워크 연결을 확인해주세요',
      UnknownProfile(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// 9개의 Failure 서브클래스 (수동 구현)
class ValidationFailure extends ProfileFailure {
  final String field;
  const ValidationFailure(this.field) : super();
}
// ... 8개 더
```

### 1.2 현재 패턴의 장점

✅ **Dart 3.0 네이티브 기능**:
- 추가 의존성 없음 (freezed, build_runner 불필요)
- switch 표현식으로 컴파일 타임 타입 안전성 보장
- 패턴 매칭 (Pattern Matching) 완벽 지원

✅ **간결하고 명확한 코드**:
- sealed class로 모든 케이스 처리 강제
- switch 표현식으로 가독성 높은 메시지 관리
- 수동 구현으로 완전한 제어 가능

✅ **빌드 프로세스 단순화**:
- 코드 생성 불필요
- `flutter pub run build_runner build` 단계 제거
- 더 빠른 컴파일 속도

### 1.3 현재 패턴의 단점

❌ **보일러플레이트 코드**:
- 9개 Failure 클래스 수동 작성 필요
- 새 Failure 추가 시 클래스 선언 필수

❌ **유틸리티 메서드 부족**:
- `copyWith()` 없음
- `==` 연산자 수동 구현 필요
- `toString()` 일관성 없음

❌ **when 메서드 없음**:
- switch 표현식만 사용 가능
- map/maybeWhen/maybeMap 등 없음

---

## 2. Cross-Feature 일관성 분석

### 2.1 Feature별 Failure 패턴 비교

| Feature | 패턴 | 파일 크기 | when 메서드 | 자동 생성 |
|---------|------|----------|------------|----------|
| **Auth** | `@freezed sealed class` | 91줄 + 자동 생성 | ✅ Freezed | ✅ Yes |
| **Voting** | `abstract class` | 83줄 | ✅ 수동 구현 | ❌ No |
| **Profile** | `sealed class` | 209줄 | ❌ switch only | ❌ No |

### 2.2 Auth Feature 패턴 (현재 표준)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failures.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  // Email & Password errors
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
  // ... 14개 factory

  @override
  String get message {
    return when(
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      weakPassword: () => '비밀번호가 너무 약합니다',
      // ...
    );
  }
}
```

**Auth 패턴의 장점**:
- ✅ 자동 코드 생성 (copyWith, ==, hashCode, toString)
- ✅ when/map 메서드 풍부
- ✅ 간결한 factory 선언
- ✅ Freezed 생태계 (json_serializable 등)

### 2.3 Voting Feature 패턴

```dart
abstract class VotingFailure extends Failure {
  const VotingFailure({
    String? message,
    String? code,
  }) : super(message: message ?? 'Voting error occurred', code: code);

  T when<T>({
    required T Function() serverError,
    required T Function() networkError,
    required T Function() notFound,
    // ...
  }) {
    if (this is ServerError) return serverError();
    if (this is NetworkError) return networkError();
    // ... 수동 타입 체크
  }
}
```

**Voting 패턴의 문제점**:
- ❌ abstract class는 sealed가 아님 (컴파일 타임 체크 부족)
- ❌ when 메서드 수동 구현 (유지보수 어려움)
- ⚠️ **Profile보다 나쁜 패턴** (sealed class 미사용)

---

## 3. 아키텍처 결정

### 3.1 선택지

**Option A: @freezed 패턴으로 마이그레이션** (Auth 일치)
- Auth Feature와 동일한 패턴 적용
- Freezed의 강력한 기능 활용
- 프로젝트 전체 일관성 확보

**Option B: 현재 sealed class 유지** (Dart 3.0 네이티브)
- 이미 잘 작동하는 코드 유지
- 추가 의존성 없음
- 더 간단한 빌드 프로세스

### 3.2 결정 매트릭스

| 고려 사항 | Option A (@freezed) | Option B (sealed class) |
|----------|-------------------|----------------------|
| **Auth와 일관성** | ✅ 완벽 일치 | ❌ 패턴 불일치 |
| **코드 간결성** | ✅ Factory만 선언 | ⚠️ 클래스 수동 작성 |
| **유틸리티 메서드** | ✅ 자동 생성 | ❌ 없음 |
| **의존성** | ❌ freezed 필요 | ✅ 없음 |
| **빌드 속도** | ❌ 코드 생성 시간 | ✅ 빠름 |
| **Dart 3.0 활용** | ⚠️ 부분적 | ✅ 완전 활용 |
| **현재 상태** | ❌ 마이그레이션 필요 | ✅ 완성됨 |

---

## 4. Option A: @freezed 마이그레이션

### 4.1 마이그레이션 단계

**Step 1: 백업 생성**

```bash
cp lib/features/profile/domain/failures/profile_failure.dart \
   lib/features/profile/domain/failures/profile_failure.dart.backup

git add .
git commit -m "chore(profile): Backup before Freezed migration"
```

**Step 2: 코드 변경**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failure.dart';

part 'profile_failure.freezed.dart';

@freezed
sealed class ProfileFailure with _$ProfileFailure implements Failure {
  const ProfileFailure._();

  // Factory 생성자들 (9개)
  const factory ProfileFailure.validation(String field) = ValidationFailure;
  const factory ProfileFailure.profileNotFound([String? userId]) = ProfileNotFound;
  const factory ProfileFailure.firestoreRead(String operation) = FirestoreRead;
  const factory ProfileFailure.firestoreWrite(String operation) = FirestoreWrite;
  const factory ProfileFailure.firebaseStorage(String operation) = FirebaseStorage;
  const factory ProfileFailure.invalidInput(String field, String reason) = InvalidInput;
  const factory ProfileFailure.permissionDenied(String resource) = PermissionDenied;
  const factory ProfileFailure.networkProfile() = NetworkProfile;
  const factory ProfileFailure.unknownProfile([String? errorMessage]) = UnknownProfile;

  @override
  String get message {
    return when(
      validation: (field) => '입력 정보를 확인해주세요: $field',
      profileNotFound: (userId) => userId != null
          ? '프로필을 찾을 수 없습니다 (UID: $userId)'
          : '프로필을 찾을 수 없습니다',
      firestoreRead: (operation) => '데이터 읽기 실패: $operation',
      firestoreWrite: (operation) => '데이터 쓰기 실패: $operation',
      firebaseStorage: (operation) => '파일 업로드 실패: $operation',
      invalidInput: (field, reason) => '$field: $reason',
      permissionDenied: (resource) => '접근 권한이 없습니다: $resource',
      networkProfile: () => '네트워크 연결을 확인해주세요',
      unknownProfile: (errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}

// 수동 클래스 9개 삭제
```

**Step 3: 코드 생성**

```bash
flutter pub run build_runner build --delete-conflicting-outputs

# 생성 확인
ls -la lib/features/profile/domain/failures/
# profile_failure.dart
# profile_failure.freezed.dart  ← 새로 생성됨
```

**Step 4: 검증**

```bash
flutter analyze
flutter test lib/features/profile/test/unit/domain/failures/
```

### 4.2 Before/After 비교

| 항목 | Before (sealed class) | After (@freezed) | 변화 |
|------|---------------------|-----------------|------|
| **파일 크기** | 209줄 | ~100줄 + 자동 생성 | 52% 감소 |
| **수동 클래스** | 9개 | 0개 | 완전 제거 |
| **Factory 선언** | 없음 | 9개 | 간결한 선언 |
| **when 메서드** | switch만 | when/map/maybeWhen/maybeMap | 풍부 |
| **copyWith** | 없음 | 자동 생성 | ✅ |
| **==, hashCode** | 없음 | 자동 생성 | ✅ |

---

## 5. Option B: 현재 패턴 유지

### 5.1 유지 가이드

**현재 코드는 이미 완성된 상태이므로 추가 작업 불필요**

**개선 사항 (선택적)**:

```dart
// 1. == 연산자 추가 (선택)
sealed class ProfileFailure extends Failure {
  const ProfileFailure() : super(message: '');

  // Equatable 구현
  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;

  // 기존 message getter
  @override
  String get message { ... }
}

// 2. 각 Failure 클래스에 props 추가
class ValidationFailure extends ProfileFailure {
  final String field;
  const ValidationFailure(this.field) : super();

  @override
  List<Object?> get props => [field];
}
```

### 5.2 문서화 개선

```dart
/// ProfileFailure - Dart 3.0 네이티브 sealed class
///
/// **아키텍처 결정**: @freezed 대신 sealed class 선택
///
/// **선택 이유**:
/// - Dart 3.0 네이티브 기능 완전 활용
/// - 추가 의존성 없음 (freezed, build_runner 불필요)
/// - Switch 표현식으로 충분한 타입 안전성 보장
/// - 더 빠른 컴파일 속도
///
/// **트레이드오프**:
/// - Auth Feature와 패턴 불일치 (Auth는 @freezed 사용)
/// - copyWith, when/map 등 유틸리티 메서드 없음
/// - 새 Failure 추가 시 클래스 수동 작성 필요
sealed class ProfileFailure extends Failure {
  // ...
}
```

---

## 6. 권장사항

### 6.1 프로젝트 전체 일관성 우선

**권장: Option A (@freezed 마이그레이션)** ⭐⭐⭐⭐⭐

**이유**:
1. **Auth Feature와 일관성**: Auth는 이미 @freezed 사용 중
2. **확장성**: 향후 Voting Feature도 @freezed로 통일 가능
3. **유지보수**: 팀 전체가 하나의 패턴만 학습하면 됨
4. **기능 풍부**: copyWith, when/map 등 강력한 기능
5. **커뮤니티 표준**: Freezed는 Flutter 커뮤니티 표준 패턴

**단점 수용**:
- freezed 의존성 추가 → 이미 프로젝트에 있음 (Auth 사용)
- 코드 생성 시간 → 초기 1회만 영향, 이후 incremental build
- 학습 곡선 → 팀이 이미 Auth에서 사용 중

### 6.2 Dart 3.0 네이티브 우선

**대안: Option B (현재 패턴 유지)** ⭐⭐⭐☆☆

**선택 시나리오**:
1. 팀이 Dart 3.0 기능에 익숙함
2. 빌드 속도가 매우 중요함
3. 의존성 최소화가 우선순위
4. 현재 코드가 모든 요구사항 충족

**이 경우 해야 할 일**:
1. **Voting Feature 마이그레이션**: abstract class → sealed class
2. **Auth Feature 고려**: 향후 @freezed 제거 검토
3. **문서화**: 아키텍처 결정 명확히 기록

### 6.3 최종 권장

```yaml
추천 순서:
  1. Option A (@freezed 마이그레이션) - 90% 상황에서 추천
  2. Option B (현재 유지) - 특수한 경우만 선택

결정 기준:
  - 팀 크기 2명 이상: Option A (일관성 중요)
  - 팀 크기 1명: Option B도 가능 (개인 선호)
  - 프로젝트 규모 큼: Option A (확장성 중요)
  - 프로젝트 규모 작음: Option B도 가능
```

---

## 7. 테스트 전략

### 7.1 Option A 선택 시

```dart
// lib/features/profile/test/unit/domain/failures/profile_failure_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_cursor/features/profile/domain/failures/profile_failure.dart';

void main() {
  group('ProfileFailure - Freezed Pattern', () {
    test('Factory 생성자로 Failure 생성', () {
      final failure = ProfileFailure.validation('displayName');

      expect(failure, isA<ValidationFailure>());
      expect(failure, isA<ProfileFailure>());
    });

    test('when 메서드로 패턴 매칭', () {
      final failure = ProfileFailure.unknownProfile('Custom error');

      final result = failure.when(
        validation: (field) => 'Validation error',
        profileNotFound: (userId) => 'Profile not found',
        firestoreRead: (op) => 'Firestore read error',
        firestoreWrite: (op) => 'Firestore write error',
        firebaseStorage: (op) => 'Storage error',
        invalidInput: (field, reason) => 'Invalid input',
        permissionDenied: (resource) => 'Permission denied',
        networkProfile: () => 'Network error',
        unknownProfile: (msg) => 'Unknown: $msg',
      );

      expect(result, 'Unknown: Custom error');
    });

    test('== 연산자가 올바르게 작동', () {
      final failure1 = ProfileFailure.validation('name');
      final failure2 = ProfileFailure.validation('name');
      final failure3 = ProfileFailure.validation('email');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('copyWith가 올바르게 작동', () {
      final failure = ProfileFailure.invalidInput('email', 'invalid format');
      // Note: Freezed는 sealed class에 copyWith 미지원
      // 대신 새 인스턴스 생성
      final newFailure = ProfileFailure.invalidInput('email', 'required');

      expect(newFailure, isNot(equals(failure)));
    });
  });
}
```

### 7.2 Option B 선택 시

```dart
// 현재 코드 테스트 (이미 작동 중)
void main() {
  group('ProfileFailure - Sealed Class Pattern', () {
    test('Sealed class로 Failure 생성', () {
      final failure = ValidationFailure('displayName');

      expect(failure, isA<ValidationFailure>());
      expect(failure, isA<ProfileFailure>());
    });

    test('Switch 표현식으로 메시지 가져오기', () {
      final failures = [
        ValidationFailure('displayName'),
        ProfileNotFound(),
        NetworkProfile(),
      ];

      expect(failures[0].message, '입력 정보를 확인해주세요: displayName');
      expect(failures[1].message, '프로필을 찾을 수 없습니다');
      expect(failures[2].message, '네트워크 연결을 확인해주세요');
    });

    test('Switch 표현식으로 패턴 매칭', () {
      final failure = UnknownProfile('Custom error');

      final result = switch (failure) {
        ValidationFailure(:final field) => 'Validation error: $field',
        ProfileNotFound() => 'Profile not found',
        UnknownProfile(:final errorMessage) => 'Unknown: $errorMessage',
        _ => 'Other error',
      };

      expect(result, 'Unknown: Custom error');
    });
  });
}
```

---

## 📊 Phase 1 완료 체크리스트

### Option A 선택 시

- [ ] 아키텍처 결정 문서화 (Option A 선택 이유)
- [ ] `profile_failure.dart` 백업 생성
- [ ] Git 커밋 (롤백 포인트)
- [ ] `@freezed` 어노테이션 추가
- [ ] `part 'profile_failure.freezed.dart';` 추가
- [ ] 9개 Factory 생성자 작성
- [ ] `switch` → `when` 변경
- [ ] 9개 수동 클래스 삭제
- [ ] `flutter pub run build_runner build` 실행
- [ ] `profile_failure.freezed.dart` 생성 확인
- [ ] `flutter analyze` 통과 확인
- [ ] Unit 테스트 통과 확인
- [ ] 기존 UseCase 코드 정상 작동 확인

### Option B 선택 시

- [ ] 아키텍처 결정 문서화 (Option B 선택 이유)
- [ ] profile_failure.dart 주석에 결정 이유 추가
- [ ] Voting Feature 마이그레이션 계획 수립
- [ ] Unit 테스트 작성 (sealed class 패턴)
- [ ] `flutter analyze` 통과 확인
- [ ] 기존 코드 정상 작동 확인

---

## ✅ 성공 기준

| 항목 | Option A | Option B |
|------|----------|----------|
| **컴파일** | `flutter analyze` 0 issues | `flutter analyze` 0 issues |
| **테스트** | 모든 테스트 통과 | 모든 테스트 통과 |
| **일관성** | Auth와 동일 패턴 | 문서화된 결정 사유 |
| **생성 파일** | `profile_failure.freezed.dart` 존재 | 추가 파일 없음 |
| **기능 유지** | 기존 UseCase 코드 정상 작동 | 기존 UseCase 코드 정상 작동 |

---

## 🎯 다음 단계

Phase 1 완료 후 **Phase 2: Either Pattern**으로 진행합니다.

- **대상**: 13개 UseCase + Repository Interfaces + 4개 Provider
- **작업**: `Result<T>` → `Either<ProfileFailure, T>` 마이그레이션
- **소요 시간**: 2일

문서: `PHASE_2_EITHER_PATTERN.md`

---

## 📚 참고 자료

### Auth Feature 참고 파일

- `lib/features/auth/domain/failures/auth_failure.dart` - @freezed 패턴 예시
- `lib/features/auth/domain/usecases/` - Either 사용 예시

### Dart 3.0 sealed class 자료

- [Dart 3.0 Release](https://medium.com/dartlang/announcing-dart-3-53f065a10635)
- [Sealed Classes in Dart](https://dart.dev/language/class-modifiers#sealed)
- [Pattern Matching](https://dart.dev/language/patterns)

### Freezed 자료

- [Freezed Package](https://pub.dev/packages/freezed)
- [Freezed Documentation](https://github.com/rrousselGit/freezed)
