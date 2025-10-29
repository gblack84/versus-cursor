# Phase 2: Either Pattern 마이그레이션

> **소요 시간**: 3일
> **난이도**: ⭐⭐⭐☆☆ (중간)
> **영향 범위**: Domain Layer (13 UseCases) + Data Layer (5 Repositories) + Presentation Layer (4 Providers)
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

Auth Feature와 Voting Feature의 함수형 에러 처리 패턴을 Profile Feature에 적용합니다:
- ✅ **Either<L,R> 패턴**: Result<T> → Either<ProfileFailure, T>
- ✅ **dartz 라이브러리**: 함수형 프로그래밍 지원
- ✅ **타입 안전성 향상**: 컴파일 타임 에러 체크
- ✅ **명시적 에러 처리**: left(failure) vs right(success)

### 1.2 변경 대상 (22개 파일)

| Layer | 파일 | 라인 | 변경 내용 |
|-------|------|------|----------|
| **Domain** | `get_user_profile_usecase.dart` | 92줄 | Result → Either |
| **Domain** | `get_current_user_profile_usecase.dart` | 78줄 | Result → Either |
| **Domain** | `update_user_profile_usecase.dart` | 156줄 | Result → Either |
| **Domain** | `upload_profile_image_usecase.dart` | 134줄 | Result → Either |
| **Domain** | `delete_profile_usecase.dart` | 89줄 | Result → Either |
| **Domain** | `watch_user_profile_usecase.dart` | 72줄 | Result → Either |
| **Domain** | `get_profile_completion_usecase.dart` | 65줄 | Result → Either |
| **Domain** | `get_profile_info_usecase.dart` | 58줄 | Result → Either |
| **Domain** | `get_user_settings_usecase.dart` | 67줄 | Result → Either |
| **Domain** | `update_user_settings_usecase.dart` | 98줄 | Result → Either |
| **Domain** | `get_available_characters_usecase.dart` | 54줄 | Result → Either |
| **Domain** | `get_interests_usecase.dart` | 62줄 | Result → Either |
| **Domain** | `update_interests_usecase.dart` | 89줄 | Result → Either |
| **Data** | `user_repository_impl.dart` | 245줄 | Result → Either |
| **Data** | `profile_repository_impl.dart` | 189줄 | Result → Either |
| **Data** | `characters_repository_impl.dart` | 112줄 | Result → Either |
| **Data** | `interests_repository_impl.dart` | 134줄 | Result → Either |
| **Data** | `profile_storage_repository_impl.dart` | 98줄 | Result → Either |
| **Presentation** | `profile_provider.dart` | 380줄 | Result.fold → Either.fold |
| **Presentation** | `characters_provider.dart` | 156줄 | Result.fold → Either.fold |
| **Presentation** | `settings_provider.dart` | 198줄 | Result.fold → Either.fold |
| **Presentation** | `interests_provider.dart` | 145줄 | Result.fold → Either.fold |

**총 변경**: 22개 파일, 2,771줄

### 1.3 왜 Either를 사용하는가?

**Result<T>의 한계**:
```dart
// ❌ Result<T> 패턴 (현재)
final result = await useCase.execute(userId: userId);

if (result is Success<UserProfile>) {
  final profile = result.data;  // ← 타입 캐스팅 필요
  // ...
} else if (result is ResultFailure<UserProfile>) {
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
final result = await useCase.execute(userId: userId);

result.fold(
  (failure) => handleError(failure),  // ← Left: 에러
  (profile) => handleSuccess(profile), // ← Right: 성공
);

// 장점:
// 1. 컴파일 타임에 타입 체크
// 2. fold를 강제하여 에러 처리 누락 방지
// 3. 함수형 프로그래밍 패턴 (map, flatMap 등)
// 4. Auth/Voting Feature와 100% 동일한 패턴
```

**Auth Feature 참조 패턴**:
```dart
// lib/features/auth/domain/usecases/sign_in_with_email_usecase.dart
Future<Either<AuthFailure, AuthUser>> execute({
  required String email,
  required String password,
}) async {
  try {
    // ...
    return right(user);  // ✅ 성공
  } on AuthFailure catch (e) {
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

**파일**: `lib/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart` (78줄)

```dart
// ❌ Before: Result<T> 패턴
import '/core/types/result.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/repositories/i_profile_repository.dart';

class GetCurrentUserProfileUseCase {
  final IProfileRepository _repository;

  const GetCurrentUserProfileUseCase(this._repository);

  /// 현재 사용자 프로필 조회
  ///
  /// **Returns**: Result<UserProfile>
  /// - Success(profile): 프로필 조회 성공
  /// - ResultFailure(ProfileNotFound): 프로필 없음
  Future<Result<UserProfile>> execute() async {
    try {
      final profile = await _repository.getCurrentUserProfile();

      if (profile == null) {
        return ResultFailure(ProfileNotFound(userId: 'current_user'));
      }

      return Success(profile);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
```

### 2.3 현재 Repository 예시

**파일**: `lib/features/profile/domain/repositories/i_profile_repository.dart`

```dart
// ❌ Before: Future<T?> 패턴
abstract class IProfileRepository {
  /// 프로필 완성도 확인
  Future<bool> isProfileComplete(String userId);

  /// 프로필 완성도 퍼센티지
  Future<double> getProfileCompletionPercentage(String userId);

  /// 프로필 정보 조회
  Future<ProfileInfo?> getProfileInfo(String userId);

  // ← Either 패턴 없음
  // ← 에러 처리가 null로 표현됨
}
```

### 2.4 현재 Provider 사용 예시

**파일**: `lib/features/profile/presentation/providers/profile_provider.dart` (일부)

```dart
// ❌ Before: Result.fold 패턴
Future<void> loadProfile(String userId) async {
  _isLoading = true;
  notifyListeners();

  final result = await _getProfileUseCase.execute(userId: userId);

  // Result 타입 체크 필요
  if (result is Success<UserProfile>) {
    _profile = result.data;
    _errorMessage = null;
  } else if (result is ResultFailure<UserProfile>) {
    _errorMessage = result.failure.message;
    _profile = null;
  }

  _isLoading = false;
  notifyListeners();
}
```

### 2.5 문제점 요약

| 문제 | 설명 | 해결 |
|------|------|------|
| **타입 안전성 부족** | `is` 체크로 런타임 판단 | Either로 컴파일 타임 체크 |
| **에러 처리 누락** | `else` 케이스 생략 가능 | fold 강제로 에러 처리 보장 |
| **보일러플레이트** | Success/ResultFailure 반복 | left/right로 간결화 |
| **Auth/Voting 불일치** | Result<T> vs Either<L,R> | Either로 통일 |
| **Repository null 반환** | Future<T?> 에러 표현 한계 | Either로 명시적 에러 |

---

## 3. 마이그레이션 목표

### 3.1 Either<L,R> 패턴 구조

```dart
// dartz 라이브러리
import 'package:dartz/dartz.dart';

// Either<Left, Right>
// - Left: 에러 (ProfileFailure)
// - Right: 성공 (UserProfile, void 등)

final Either<ProfileFailure, UserProfile> result = ...;

result.fold(
  (failure) => print('Error: ${failure.message}'),  // Left
  (profile) => print('Success: ${profile.userName}'), // Right
);
```

### 3.2 목표 UseCase 예시

**파일**: `lib/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart` (72줄)

```dart
// ✅ After: Either<L,R> 패턴
import 'package:dartz/dartz.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/repositories/i_profile_repository.dart';

class GetCurrentUserProfileUseCase {
  final IProfileRepository _repository;

  const GetCurrentUserProfileUseCase(this._repository);

  /// 현재 사용자 프로필 조회
  ///
  /// **Returns**: Either<ProfileFailure, UserProfile>
  /// - Left(ProfileNotFound): 프로필 없음
  /// - Right(profile): 프로필 조회 성공
  Future<Either<ProfileFailure, UserProfile>> execute() async {
    try {
      final result = await _repository.getCurrentUserProfile();

      // Repository가 Either 반환
      return result;
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknownProfile(e.toString()));
    }
  }
}
```

### 3.3 목표 Repository 예시

```dart
// ✅ After: Either<L,R> 패턴
abstract class IProfileRepository {
  /// 프로필 완성도 확인
  Future<Either<ProfileFailure, bool>> isProfileComplete(String userId);

  /// 프로필 완성도 퍼센티지
  Future<Either<ProfileFailure, double>> getProfileCompletionPercentage(String userId);

  /// 프로필 정보 조회
  Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId);

  /// 현재 사용자 프로필 조회
  Future<Either<ProfileFailure, UserProfile>> getCurrentUserProfile();

  // ← 에러가 Left로 명시적 표현
  // ← null 대신 Either 사용
}
```

### 3.4 목표 Provider 사용 예시

```dart
// ✅ After: Either.fold 패턴
Future<void> loadProfile(String userId) async {
  _isLoading = true;
  notifyListeners();

  final result = await _getProfileUseCase.execute(userId: userId);

  // fold 강제로 에러 처리 보장
  result.fold(
    (failure) {
      _errorMessage = failure.message;
      _profile = null;
    },
    (profile) {
      _profile = profile;
      _errorMessage = null;
    },
  );

  _isLoading = false;
  notifyListeners();
}
```

### 3.5 변경 요약

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **Import** | `import '/core/types/result.dart';` | `import 'package:dartz/dartz.dart';` | dartz |
| **반환 타입** | `Future<Result<UserProfile>>` | `Future<Either<ProfileFailure, UserProfile>>` | Either |
| **성공 반환** | `return Success(profile);` | `return right(profile);` | right |
| **실패 반환** | `return ResultFailure(failure);` | `return left(failure);` | left |
| **에러 처리** | `if (result is Success) { ... }` | `result.fold((l) => ..., (r) => ...)` | fold |
| **Repository** | `Future<T?>` | `Future<Either<ProfileFailure, T>>` | Either |
| **코드 라인** | 78줄 | 72줄 | -6줄 (8% 감소) |

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: 의존성 추가** (Auth Phase 2에서 이미 추가됨)

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
cp -r lib/features/profile/domain/usecases lib/features/profile/domain/usecases.backup

# Data Layer 백업
cp -r lib/features/profile/data/repositories lib/features/profile/data/repositories.backup

# Presentation Layer 백업
mkdir -p lib/features/profile/presentation/providers.backup
cp lib/features/profile/presentation/providers/*.dart \
   lib/features/profile/presentation/providers.backup/

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(profile): Backup before Either Pattern migration"
```

### 4.2 Repository 인터페이스 수정 (5개 파일)

**Step 3-1: IProfileRepository 반환 타입 변경**

**파일**: `lib/features/profile/domain/repositories/i_profile_repository.dart`

```dart
// Before
Future<bool> isProfileComplete(String userId);
Future<double> getProfileCompletionPercentage(String userId);
Future<ProfileInfo?> getProfileInfo(String userId);

// After
import 'package:dartz/dartz.dart';

Future<Either<ProfileFailure, bool>> isProfileComplete(String userId);
Future<Either<ProfileFailure, double>> getProfileCompletionPercentage(String userId);
Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId);
```

**Step 3-2: 나머지 4개 Repository 인터페이스 동일하게 수정**

- `i_user_repository.dart`
- `i_characters_repository.dart`
- `i_interests_repository.dart`
- `i_profile_storage_repository.dart`

### 4.3 Repository 구현체 수정 (5개 파일)

**Step 4-1: ProfileRepositoryImpl 예시**

**파일**: `lib/features/profile/data/repositories/profile_repository_impl.dart`

```dart
// Before
@override
Future<ProfileInfo?> getProfileInfo(String userId) async {
  try {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      return null;
    }

    return ProfileInfo.fromFirestore(doc);
  } catch (e) {
    return null;
  }
}

// After
@override
Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId) async {
  try {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      return left(ProfileFailure.profileNotFound(userId: userId));
    }

    final profileInfo = ProfileInfo.fromFirestore(doc);
    return right(profileInfo);
  } on FirebaseException catch (e) {
    return left(_mapFirebaseException(e));
  } catch (e) {
    return left(ProfileFailure.unknownProfile(e.toString()));
  }
}

// Helper 메서드
ProfileFailure _mapFirebaseException(FirebaseException e) {
  return switch (e.code) {
    'permission-denied' => ProfileFailure.permissionDenied(resource: 'profile'),
    'not-found' => ProfileFailure.profileNotFound(userId: ''),
    'unavailable' => const ProfileFailure.networkProfile(),
    _ => ProfileFailure.unknownProfile(e.message),
  };
}
```

**Step 4-2: 나머지 4개 Repository 구현체 동일하게 수정**

- `user_repository_impl.dart`
- `characters_repository_impl.dart`
- `interests_repository_impl.dart`
- `profile_storage_repository_impl.dart`

### 4.4 UseCases 수정 (13개 파일)

**패턴 1: 기본 UseCase 변경**

```dart
// Before
import '/core/types/result.dart';

class XxxUseCase {
  Future<Result<T>> execute(...) async {
    try {
      // ...
      return Success(data);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    }
  }
}

// After
import 'package:dartz/dartz.dart';

class XxxUseCase {
  Future<Either<ProfileFailure, T>> execute(...) async {
    try {
      // ...
      return right(data);
    } on ProfileFailure catch (e) {
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

Future<Either<ProfileFailure, Unit>> execute(...) async {
  // ...
  return right(unit);  // ← dartz의 Unit 타입 사용
}
```

**패턴 3: Repository 호출 처리**

```dart
// Before
final profile = await _repository.getProfileInfo(userId);

if (profile == null) {
  return ResultFailure(ProfileNotFound(userId: userId));
}

return Success(profile);

// After
final result = await _repository.getProfileInfo(userId);

return result;  // Repository가 Either 반환
```

### 4.5 Provider 수정 (4개 파일)

**Step 5-1: profile_provider.dart 수정**

**파일**: `lib/features/profile/presentation/providers/profile_provider.dart`

```dart
// Before: Result 패턴
Future<void> loadProfile(String userId) async {
  _isLoading = true;
  notifyListeners();

  final result = await _getProfileUseCase.execute(userId: userId);

  if (result is Success<UserProfile>) {
    _profile = result.data;
    _errorMessage = null;
  } else if (result is ResultFailure<UserProfile>) {
    _errorMessage = result.failure.message;
    _profile = null;
  }

  _isLoading = false;
  notifyListeners();
}

// After: Either 패턴
Future<void> loadProfile(String userId) async {
  _isLoading = true;
  notifyListeners();

  final result = await _getProfileUseCase.execute(userId: userId);

  result.fold(
    (failure) {
      _errorMessage = failure.message;
      _profile = null;
    },
    (profile) {
      _profile = profile;
      _errorMessage = null;
    },
  );

  _isLoading = false;
  notifyListeners();
}
```

**Step 5-2: 나머지 3개 Provider 동일하게 수정**

- `characters_provider.dart`
- `settings_provider.dart`
- `interests_provider.dart`

### 4.6 컴파일 확인

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 결과:
# - Result import 에러 → Either로 수정
# - Success/ResultFailure 미정의 에러 → right/left로 수정
```

### 4.7 수정 완료 검증

```bash
# UseCase 파일 확인
grep -r "Result<" lib/features/profile/domain/usecases/
# → 결과 없어야 함 (모두 Either로 변경됨)

grep -r "Either<" lib/features/profile/domain/usecases/
# → 13개 파일 발견되어야 함

# Repository 파일 확인
grep "Either<" lib/features/profile/data/repositories/*.dart
# → 5개 파일에서 Either 사용 확인

# Provider 파일 확인
grep "fold" lib/features/profile/presentation/providers/*.dart
# → 4개 파일에서 fold 패턴 사용 확인
```

---

## 5. Before/After 전체 코드

### 5.1 UseCase 예시 1: GetCurrentUserProfileUseCase

<details>
<summary>Before 코드 보기 (78줄)</summary>

```dart
// lib/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart
import '/core/types/result.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/repositories/i_profile_repository.dart';

class GetCurrentUserProfileUseCase {
  final IProfileRepository _repository;

  const GetCurrentUserProfileUseCase(this._repository);

  Future<Result<UserProfile>> execute() async {
    try {
      final profile = await _repository.getCurrentUserProfile();

      if (profile == null) {
        return ResultFailure(ProfileNotFound(userId: 'current_user'));
      }

      return Success(profile);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
```

</details>

<details>
<summary>After 코드 보기 (72줄)</summary>

```dart
// lib/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/repositories/i_profile_repository.dart';

class GetCurrentUserProfileUseCase {
  final IProfileRepository _repository;

  const GetCurrentUserProfileUseCase(this._repository);

  Future<Either<ProfileFailure, UserProfile>> execute() async {
    try {
      final result = await _repository.getCurrentUserProfile();

      // Repository가 Either 반환
      return result;
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknownProfile(e.toString()));
    }
  }
}
```

</details>

### 5.2 UseCase 예시 2: UpdateUserProfileUseCase (void 반환)

<details>
<summary>Before 코드 보기 (156줄)</summary>

```dart
// lib/features/profile/domain/usecases/profile/update_user_profile_usecase.dart
import '/core/types/result.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/repositories/i_user_repository.dart';

class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  Future<Result<void>> execute({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    try {
      // 유효성 검사
      if (updatedProfile.userName == null || updatedProfile.userName!.isEmpty) {
        return const ResultFailure(ValidationFailure('userName'));
      }

      // Repository 호출
      await _repository.updateUserProfile(userId, updatedProfile);

      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
```

</details>

<details>
<summary>After 코드 보기 (150줄)</summary>

```dart
// lib/features/profile/domain/usecases/profile/update_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/repositories/i_user_repository.dart';

class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    try {
      // 유효성 검사
      if (updatedProfile.userName == null || updatedProfile.userName!.isEmpty) {
        return left(const ProfileFailure.validation('userName'));
      }

      // Repository 호출
      final result = await _repository.updateUserProfile(userId, updatedProfile);

      return result;  // Repository가 Either<ProfileFailure, Unit> 반환
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknownProfile(e.toString()));
    }
  }
}
```

</details>

### 5.3 Repository 예시: ProfileRepositoryImpl

<details>
<summary>Before 코드 보기 (일부)</summary>

```dart
// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/profile/domain/entities/profile_info.dart';
import '/features/profile/domain/repositories/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl(this._firestore);

  @override
  Future<bool> isProfileComplete(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      return data['userName'] != null &&
             data['displayName'] != null &&
             data['age'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ProfileInfo?> getProfileInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return ProfileInfo.fromFirestore(doc);
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
// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/profile/domain/entities/profile_info.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/repositories/i_profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl(this._firestore);

  @override
  Future<Either<ProfileFailure, bool>> isProfileComplete(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      final data = doc.data()!;
      final isComplete = data['userName'] != null &&
                        data['displayName'] != null &&
                        data['age'] != null;

      return right(isComplete);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(ProfileFailure.unknownProfile(e.toString()));
    }
  }

  @override
  Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      final profileInfo = ProfileInfo.fromFirestore(doc);
      return right(profileInfo);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(ProfileFailure.unknownProfile(e.toString()));
    }
  }

  // Firebase Exception → ProfileFailure 매핑
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => ProfileFailure.permissionDenied(resource: 'profile'),
      'not-found' => ProfileFailure.profileNotFound(userId: ''),
      'unavailable' => const ProfileFailure.networkProfile(),
      'aborted' => ProfileFailure.firestoreWrite(operation: 'transaction aborted'),
      _ => ProfileFailure.unknownProfile(e.message),
    };
  }
}
```

</details>

### 5.4 Provider 예시: ProfileProvider

<details>
<summary>Before 코드 보기 (일부)</summary>

```dart
// lib/features/profile/presentation/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import '/core/types/result.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    if (result is Success<UserProfile>) {
      _profile = result.data;
      _errorMessage = null;
    } else if (result is ResultFailure<UserProfile>) {
      _errorMessage = result.failure.message;
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(
      userId: userId,
      updatedProfile: updatedProfile,
    );

    if (result is Success<void>) {
      _profile = updatedProfile;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result is ResultFailure<void>) {
      _errorMessage = result.failure.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return false;
  }
}
```

</details>

<details>
<summary>After 코드 보기 (일부)</summary>

```dart
// lib/features/profile/presentation/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _profile = null;
      },
      (profile) {
        _profile = profile;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(
      userId: userId,
      updatedProfile: updatedProfile,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _profile = updatedProfile;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}
```

</details>

### 5.5 차이점 비교

```diff
// UseCase
- import '/core/types/result.dart';
+ import 'package:dartz/dartz.dart';

- Future<Result<UserProfile>> execute(...) async {
+ Future<Either<ProfileFailure, UserProfile>> execute(...) async {

-     return ResultFailure(ProfileNotFound(userId: userId));
+     return left(ProfileFailure.profileNotFound(userId: userId));

-     return Success(profile);
+     return right(profile);

// Repository Interface
- Future<ProfileInfo?> getProfileInfo(String userId);
+ Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId);

// Repository Implementation
-   if (!doc.exists) {
-     return null;
-   }
-   return ProfileInfo.fromFirestore(doc);
+   if (!doc.exists) {
+     return left(ProfileFailure.profileNotFound(userId: userId));
+   }
+   return right(ProfileInfo.fromFirestore(doc));

// Provider
- if (result is Success<UserProfile>) {
-   _profile = result.data;
-   _errorMessage = null;
- } else if (result is ResultFailure<UserProfile>) {
-   _errorMessage = result.failure.message;
-   _profile = null;
- }

+ result.fold(
+   (failure) {
+     _errorMessage = failure.message;
+     _profile = null;
+   },
+   (profile) {
+     _profile = profile;
+     _errorMessage = null;
+   },
+ );
```

---

## 6. 백엔드-UI 연결

### 6.1 Phase 2에서는 UI 변경 없음

**중요**: Phase 2는 **Domain/Data Layer**만 수정합니다. UI는 Phase 3에서 변경됩니다.

**이유**:
- 4개 Provider들이 **추상화 레이어** 역할
- UI는 Provider만 바라보므로 내부 구현 변경 영향 없음
- Provider가 Either.fold를 내부적으로 처리하여 bool/void 반환

```dart
// UI Layer (변경 없음)
class ProfileEditScreen extends StatefulWidget {
  // ...

  Future<void> _handleSave() async {
    final success = await _profileProvider.updateProfile(
      userId: userId,
      updatedProfile: updatedProfile,
    );

    if (success) {
      context.pop();
    } else {
      // _profileProvider.errorMessage 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileProvider.errorMessage ?? 'Update failed')),
      );
    }
  }
}

// Provider Layer (내부만 변경)
class ProfileProvider extends ChangeNotifier {
  // ...

  Future<bool> updateProfile({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    final result = await _updateProfileUseCase.execute(...);

    // ✅ Either.fold로 처리, UI에는 bool 반환
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _profile = updatedProfile;
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
    ↓ _profileProvider.loadProfile()
    ↓ → void 반환 (success/error는 Provider 상태로 확인)

[Presentation Layer] (내부만 변경)
profile_provider.dart
    ↓ _getProfileUseCase.execute()
    ↓ ← Either<ProfileFailure, UserProfile> 반환
    ↓ .fold() 처리
    ↓ → 상태 업데이트 (profile, errorMessage)

[Domain Layer] (Either 적용)
get_current_user_profile_usecase.dart
    ↓ _repository.getCurrentUserProfile()
    ↓ ← Either<ProfileFailure, UserProfile> 반환
    ↓ → Either 그대로 반환

[Data Layer] (Either 적용)
profile_repository_impl.dart
    ↓ Firestore.collection('users').doc().get()
    ↓ ← DocumentSnapshot 반환
    ↓ → Either<ProfileFailure, UserProfile> 변환

[Firebase Backend]
Cloud Firestore
```

---

## 7. 테스트 전략

### 7.1 UseCase Unit Test

**테스트 파일**: `lib/features/profile/test/unit/domain/usecases/get_current_user_profile_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:versus_cursor/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart';
import 'package:versus_cursor/features/profile/domain/failures/profile_failure.dart';
import 'package:versus_cursor/features/profile/domain/entities/user_profile.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late GetCurrentUserProfileUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetCurrentUserProfileUseCase(mockRepository);
  });

  group('GetCurrentUserProfileUseCase - Either Pattern', () {
    final tProfile = UserProfile(
      uid: 'test-uid',
      email: 'test@example.com',
      userName: 'testuser',
      displayName: 'Test User',
    );

    test('성공 시 Right(UserProfile) 반환', () async {
      // Given
      when(() => mockRepository.getCurrentUserProfile())
          .thenAnswer((_) async => right(tProfile));

      // When
      final result = await useCase.execute();

      // Then
      expect(result, isA<Right<ProfileFailure, UserProfile>>());

      result.fold(
        (failure) => fail('Should not be failure'),
        (profile) {
          expect(profile.uid, tProfile.uid);
          expect(profile.userName, tProfile.userName);
        },
      );

      verify(() => mockRepository.getCurrentUserProfile()).called(1);
    });

    test('프로필 없음 시 Left(ProfileNotFound) 반환', () async {
      // Given
      when(() => mockRepository.getCurrentUserProfile())
          .thenAnswer((_) async => left(ProfileFailure.profileNotFound(userId: 'current_user')));

      // When
      final result = await useCase.execute();

      // Then
      expect(result, isA<Left<ProfileFailure, UserProfile>>());

      result.fold(
        (failure) {
          expect(failure, isA<ProfileNotFound>());
          expect(failure.message, contains('프로필을 찾을 수 없습니다'));
        },
        (profile) => fail('Should not be success'),
      );
    });

    test('fold로 두 케이스 모두 처리', () async {
      // Given
      when(() => mockRepository.getCurrentUserProfile())
          .thenAnswer((_) async => right(tProfile));

      // When
      final result = await useCase.execute();

      // Then
      final message = result.fold(
        (failure) => 'Error: ${failure.message}',
        (profile) => 'Success: ${profile.userName}',
      );

      expect(message, 'Success: testuser');
    });
  });
}
```

### 7.2 Repository Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    repository = ProfileRepositoryImpl(mockFirestore);
  });

  group('ProfileRepositoryImpl - Either Pattern', () {
    test('Firestore 성공 시 Right(ProfileInfo) 반환', () async {
      // Given
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'uid': 'test-uid',
        'userName': 'testuser',
        'displayName': 'Test User',
      });

      // When
      final result = await repository.getProfileInfo('test-uid');

      // Then
      expect(result, isA<Right<ProfileFailure, ProfileInfo>>());
    });

    test('Document 없을 시 Left(ProfileNotFound) 반환', () async {
      // Given
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);

      // When
      final result = await repository.getProfileInfo('test-uid');

      // Then
      result.fold(
        (failure) {
          expect(failure, isA<ProfileNotFound>());
        },
        (profile) => fail('Should not be success'),
      );
    });
  });
}
```

### 7.3 테스트 실행

```bash
# UseCase 테스트
flutter test lib/features/profile/test/unit/domain/usecases/

# Repository 테스트
flutter test lib/features/profile/test/unit/data/repositories/

# 전체 Profile 테스트
flutter test lib/features/profile/test/

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
git diff lib/features/profile/

# 단계별 롤백
# Domain Layer
git checkout HEAD -- lib/features/profile/domain/usecases/
git checkout HEAD -- lib/features/profile/domain/repositories/

# Data Layer
git checkout HEAD -- lib/features/profile/data/repositories/

# Presentation Layer
git checkout HEAD -- lib/features/profile/presentation/providers/
```

### 8.2 수동 롤백

```bash
# 백업 파일 복원
cp -r lib/features/profile/domain/usecases.backup lib/features/profile/domain/usecases
cp -r lib/features/profile/data/repositories.backup lib/features/profile/data/repositories
cp -r lib/features/profile/presentation/providers.backup/* \
      lib/features/profile/presentation/providers/

# 컴파일 확인
flutter analyze
```

### 8.3 롤백 검증

```bash
# Result 패턴 확인
grep -r "Result<" lib/features/profile/domain/usecases/
# → 13개 파일 발견되어야 함

# Either 패턴 확인 (없어야 함)
grep -r "Either<" lib/features/profile/
# → 결과 없어야 함

# 테스트 실행
flutter test lib/features/profile/test/

# 앱 실행 확인
flutter run
```

---

## 📊 Phase 2 완료 체크리스트

### Domain Layer (13 UseCases)
- [ ] `get_user_profile_usecase.dart` Either 적용
- [ ] `get_current_user_profile_usecase.dart` Either 적용
- [ ] `update_user_profile_usecase.dart` Either 적용
- [ ] `upload_profile_image_usecase.dart` Either 적용
- [ ] `delete_profile_usecase.dart` Either 적용
- [ ] `watch_user_profile_usecase.dart` Either 적용
- [ ] `get_profile_completion_usecase.dart` Either 적용
- [ ] `get_profile_info_usecase.dart` Either 적용
- [ ] `get_user_settings_usecase.dart` Either 적용
- [ ] `update_user_settings_usecase.dart` Either 적용
- [ ] `get_available_characters_usecase.dart` Either 적용
- [ ] `get_interests_usecase.dart` Either 적용
- [ ] `update_interests_usecase.dart` Either 적용

### Data Layer (5 Repositories)
- [ ] `user_repository_impl.dart` Either 적용
- [ ] `profile_repository_impl.dart` Either 적용
- [ ] `characters_repository_impl.dart` Either 적용
- [ ] `interests_repository_impl.dart` Either 적용
- [ ] `profile_storage_repository_impl.dart` Either 적용
- [ ] `_mapFirebaseException` 헬퍼 메서드 추가 (각 Repository)

### Presentation Layer (4 Providers)
- [ ] `profile_provider.dart` Either.fold 적용
- [ ] `characters_provider.dart` Either.fold 적용
- [ ] `settings_provider.dart` Either.fold 적용
- [ ] `interests_provider.dart` Either.fold 적용

### 공통
- [ ] `pubspec.yaml`에 dartz 의존성 추가 (Auth Phase 2에서 이미 추가됨)
- [ ] Git 커밋 (롤백 포인트)
- [ ] `flutter analyze` 통과 확인
- [ ] Unit 테스트 통과 확인 (20개 이상)
- [ ] UI 동작 확인 (5개 화면)

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | 20개 이상 테스트 전부 통과 |
| **Result 제거** | `grep -r "Result<" lib/features/profile/` 결과 없음 |
| **Either 적용** | 22개 파일 모두 Either 사용 |
| **UI 유지** | 5개 화면 정상 작동 |

---

## 🎯 다음 단계

Phase 2 완료 후 **Phase 3: Riverpod 2.x**로 진행합니다.

- **대상**: 4개 Provider → Riverpod 2.x + UI 5개 화면
- **작업**: ChangeNotifier → StreamProvider.family/StateNotifierProvider
- **소요 시간**: 2일

문서: `PHASE_3_RIVERPOD.md`
