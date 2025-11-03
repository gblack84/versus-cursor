# Auth Domain Layer - Clean Architecture v4.0

> **Last Updated**: 2025-01-20
> **Architecture**: Firebase-Centric Clean Architecture v4.0
> **Migration Status**: 90% Complete (AuthContract removed, Firebase direct integration)

## 📋 Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [entities/ - Domain Entities Deep Dive](#entities---domain-entities-deep-dive)
- [enums/ - Business Logic Enums](#enums---business-logic-enums)
- [failures/ - Domain Errors](#failures---domain-errors)
- [repositories/ - Repository Interfaces](#repositories---repository-interfaces)
- [usecases/ - Business Logic Encapsulation](#usecases---business-logic-encapsulation)
- [Clean Architecture v4.0 Principles](#clean-architecture-v40-principles)
- [Freezed Usage Guide](#freezed-usage-guide)
- [Best Practices](#best-practices)
- [Summary](#summary)

---

## Overview

**Auth Domain Layer**는 인증(Authentication) 및 사용자 관리(User Management) 기능의 **핵심 비즈니스 로직**을 담당하는 순수 Dart 레이어입니다.

### Responsibilities

| 책임 | 설명 |
|------|------|
| **User Identity** | 사용자 인증 정보 및 프로필 관리 |
| **Authentication** | 로그인, 회원가입, 로그아웃 비즈니스 로직 |
| **Authorization** | 역할 기반 권한 관리 (admin/tester/user) |
| **Account Management** | 비밀번호 재설정, 이메일 인증, 계정 삭제 |
| **Multi-Provider Support** | Email, Google, Apple, Phone, GitHub, Anonymous |
| **Error Handling** | 18개의 도메인 특화 실패 타입 정의 |

### Architecture Highlights

```dart
// ✅ Firebase-Centric Architecture v4.0
// - No Contract/Port/Adapter abstraction layers
// - Repository uses Firebase SDK directly
// - Domain defines pure business logic
// - Data layer implements Firebase integration

Domain (Pure Dart)
  ↓ defines interfaces
Data (Firebase Implementation)
  ↓ uses directly
Firebase SDK (Auth, Firestore, Storage)
```

### Key Features

- **Freezed Entities**: Immutable `AuthUser` with 30+ fields and rich business logic
- **10 UseCases**: Complete authentication flow coverage (sign in, sign up, sign out, account management)
- **18 Failure Types**: Comprehensive error handling with user-friendly messages
- **Role-Based Access**: Admin, Tester, User roles with permission checks
- **Firebase Integration**: Seamless conversion between Firebase User ↔ Domain AuthUser
- **Type Safety**: Strong typing with Either pattern for error handling

---

## Directory Structure

```
lib/features/auth/domain/
├── entities/                    # 도메인 엔티티 (1개 주 엔티티 + 확장)
│   ├── auth_user.dart          # [128 lines] 핵심 사용자 도메인 엔티티 (Freezed)
│   ├── auth_user_extensions.dart # [208 lines] Firebase User ↔ AuthUser 변환 로직
│   ├── user_role_converter.dart  # [36 lines] UserRole JSON 직렬화 커스텀 컨버터
│   ├── auth_user.freezed.dart   # [자동 생성] Freezed 코드 (copyWith, ==, hashCode)
│   └── auth_user.g.dart        # [자동 생성] json_serializable 코드
│
├── enums/                       # 비즈니스 로직을 가진 열거형
│   └── user_role.dart          # [39 lines] 사용자 역할 (admin/tester/user)
│
├── failures/                    # 도메인 에러 타입 정의
│   └── auth_failure.dart       # [90 lines] 18개 인증 실패 타입 (Freezed sealed class)
│
├── repositories/                # 레포지토리 인터페이스 (Data 레이어가 구현)
│   └── i_auth_repository.dart  # [62 lines] 14개 인증 메서드 추상 인터페이스
│
└── usecases/                    # 비즈니스 로직 캡슐화 (10개 유스케이스 - 관심사별 정리)
    ├── sign_in/                 # 로그인 UseCases (4개)
    │   ├── sign_in_with_email_usecase.dart   # [88 lines]  이메일 로그인
    │   ├── sign_in_with_google_usecase.dart  # [50 lines]  Google 소셜 로그인
    │   ├── sign_in_with_apple_usecase.dart   # [56 lines]  Apple 소셜 로그인
    │   └── sign_in_with_phone_usecase.dart   # [192 lines] 전화번호(SMS OTP) 인증
    ├── sign_up/                 # 회원가입 UseCases (1개)
    │   └── sign_up_with_email_usecase.dart   # [135 lines] 이메일 회원가입 + Firestore 사용자 생성
    ├── session/                 # 세션 관리 UseCases (2개)
    │   ├── sign_out_usecase.dart            # [57 lines]  로그아웃
    │   └── get_current_user_usecase.dart     # [17 lines]  현재 로그인 사용자 조회
    └── account/                 # 계정 관리 UseCases (3개)
        ├── account_management_usecase.dart   # [294 lines] 계정 관리 (프로필, 삭제)
        ├── email_verification_usecase.dart   # [200 lines] 이메일 인증 발송 및 확인
        └── password_management_usecase.dart  # [209 lines] 비밀번호 재설정 및 변경

📊 Total: 16 main files, 1,861 lines
```

### File Organization Principles

| 디렉토리 | 용도 | 파일 수 | 의존성 |
|---------|------|--------|--------|
| **entities/** | 도메인 엔티티 정의 | 4개 (+ 2 generated) | 0 (순수 Dart) |
| **enums/** | 비즈니스 로직 열거형 | 1개 | 0 (순수 Dart) |
| **failures/** | 도메인 에러 타입 | 1개 | 0 (순수 Dart) |
| **repositories/** | 추상 인터페이스 | 1개 | entities, failures |
| **usecases/** | 비즈니스 로직 | 10개 | repositories, entities, failures |

---

## entities/ - Domain Entities Deep Dive

### 1. AuthUser - 핵심 사용자 도메인 엔티티

`auth_user.dart` (128 lines)

**완전한 사용자 정보를 담는 불변 도메인 엔티티**입니다. Freezed를 사용하여 타입 안전성, 불변성, JSON 직렬화를 보장합니다.

#### Entity Structure

```dart
@freezed
sealed class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    // ==================== Authentication fields ====================
    required String uid,              // Firebase UID
    String? email,                    // 이메일 주소
    String? displayName,              // 표시 이름
    String? userName,                 // 고유 사용자 이름
    String? photoUrl,                 // 프로필 사진 URL
    String? phoneNumber,              // 전화번호
    @Default(false) bool isEmailVerified,  // 이메일 인증 여부
    @Default(false) bool isAnonymous,      // 익명 사용자 여부
    String? providerId,               // 로그인 제공자 (google, apple, email 등)

    // ==================== Profile fields ====================
    String? bio,                      // 자기소개
    int? age,                         // 나이
    String? gender,                   // 성별
    @Default([]) List<String> interests,    // 관심사 목록
    @Default([]) List<String> expertise,    // 전문 분야 (최대 4개)
    @Default([]) List<String> hobbies,      // 취미 (최대 8개)

    // ==================== Points & Rewards ====================
    @Default(0) int pointsA,          // A 포인트 (답변으로 얻은 포인트)
    @Default(0) int pointsQ,          // Q 포인트 (질문으로 얻은 포인트)

    // ==================== Role & Premium ====================
    @UserRoleConverter()
    @Default(UserRole.user)
    UserRole role,                    // 사용자 역할 (admin/tester/user)
    @Default(false) bool isPremium,   // 프리미엄 사용자 여부

    // ==================== Timestamps ====================
    DateTime? createdAt,              // 계정 생성 시간
    DateTime? lastLoginAt,            // 마지막 로그인 시간

    // ==================== Additional ====================
    @Default({}) Map<String, dynamic> settings,  // 사용자 설정
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

  // ==================== Computed Properties ====================

  /// 프로필 완성도 확인
  bool get isProfileComplete {
    return userName != null &&
        displayName != null &&
        age != null &&
        interests.isNotEmpty;
  }

  /// 관리자 여부
  bool get isAdmin => role.isAdmin;

  /// 테스터 여부 (admin도 포함)
  bool get isTester => role.isTester;

  /// 총 포인트 (A 포인트 + Q 포인트)
  int get totalPoints => pointsA + pointsQ;
}
```

#### Key Features

**1. Rich Business Logic**:
```dart
// ✅ Computed properties for domain logic
bool get isProfileComplete => userName != null && displayName != null && age != null && interests.isNotEmpty;
bool get isAdmin => role.isAdmin;
bool get isTester => role.isTester;
int get totalPoints => pointsA + pointsQ;
```

**2. Custom JSON Converter**:
```dart
// ✅ Freezed-compatible UserRole serialization
@UserRoleConverter()  // Replaces @JsonKey pattern
@Default(UserRole.user)
UserRole role,
```

**3. Type Safety**:
```dart
// ✅ Strong typing with defaults
@Default(false) bool isEmailVerified,
@Default([]) List<String> interests,
@Default(0) int pointsA,
@Default(UserRole.user) UserRole role,
```

**4. Immutability**:
```dart
// ✅ Freezed generates copyWith for safe updates
final updatedUser = currentUser.copyWith(
  displayName: 'New Name',
  pointsA: currentUser.pointsA + 10,
);
```

#### Field Categories

| 카테고리 | 필드 수 | 설명 |
|---------|--------|------|
| **Authentication** | 9개 | Firebase 인증 관련 (uid, email, provider 등) |
| **Profile** | 6개 | 사용자 프로필 정보 (bio, age, interests 등) |
| **Points** | 2개 | 포인트 시스템 (pointsA, pointsQ) |
| **Role** | 2개 | 역할 및 프리미엄 상태 |
| **Timestamps** | 2개 | 생성/로그인 시간 |
| **Additional** | 1개 | 확장 가능한 설정 맵 |

---

### 2. AuthUserExtensions - Firebase 통합 확장

`auth_user_extensions.dart` (208 lines)

**Firebase User와 Domain AuthUser 간의 타입 안전한 변환을 담당**합니다.

#### Extension Methods

```dart
extension AuthUserFirestore on User {
  /// Firebase User → Domain AuthUser 변환
  ///
  /// **사용 시나리오**:
  /// - Firebase 로그인 성공 후 도메인 엔티티로 변환
  /// - authStateChanges 스트림에서 받은 User 변환
  ///
  /// **변환 규칙**:
  /// - uid는 필수 (Firebase User.uid)
  /// - 나머지 필드는 optional로 매핑
  /// - createdAt은 metadata.creationTime 사용
  /// - lastLoginAt은 metadata.lastSignInTime 사용
  Future<AuthUser> toDomainUser() async {
    // Firestore에서 추가 사용자 정보 조회
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = userDoc.data();

    return AuthUser(
      uid: uid,
      email: email,
      displayName: displayName,
      userName: data?['userName'] as String?,
      photoUrl: photoURL,
      phoneNumber: phoneNumber,
      isEmailVerified: emailVerified,
      isAnonymous: isAnonymous,
      providerId: providerData.isNotEmpty ? providerData.first.providerId : null,

      // Profile fields from Firestore
      bio: data?['bio'] as String?,
      age: data?['age'] as int?,
      gender: data?['gender'] as String?,
      interests: (data?['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      expertise: (data?['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
      hobbies: (data?['hobbies'] as List<dynamic>?)?.cast<String>() ?? [],

      // Points from Firestore
      pointsA: data?['pointsA'] as int? ?? 0,
      pointsQ: data?['pointsQ'] as int? ?? 0,

      // Role & Premium from Firestore
      role: data?['role'] != null
          ? UserRole.fromValue(data!['role'] as String)
          : UserRole.user,
      isPremium: data?['isPremium'] as bool? ?? false,

      // Timestamps
      createdAt: metadata.creationTime,
      lastLoginAt: metadata.lastSignInTime,

      // Settings from Firestore
      settings: data?['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Domain AuthUser → Firestore Map 변환
  ///
  /// **사용 시나리오**:
  /// - 회원가입 시 Firestore에 사용자 문서 생성
  /// - 프로필 업데이트 시 Firestore 문서 업데이트
  ///
  /// **저장 규칙**:
  /// - Firebase Auth 필드는 제외 (uid, email 등은 Auth가 관리)
  /// - Profile, Points, Role, Settings만 Firestore에 저장
  Map<String, dynamic> toFirestore() {
    return {
      // Profile fields
      'userName': userName,
      'bio': bio,
      'age': age,
      'gender': gender,
      'interests': interests,
      'expertise': expertise,
      'hobbies': hobbies,

      // Points
      'pointsA': pointsA,
      'pointsQ': pointsQ,

      // Role & Premium
      'role': role.toValue(),
      'isPremium': isPremium,

      // Settings
      'settings': settings,

      // Timestamps
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }
}
```

#### Usage Examples

```dart
// ✅ Firebase User → Domain User
final firebaseUser = FirebaseAuth.instance.currentUser!;
final domainUser = await firebaseUser.toDomainUser();
print('Welcome, ${domainUser.displayName}!');

// ✅ Domain User → Firestore Map
final newUser = AuthUser(
  uid: firebaseUser.uid,
  email: firebaseUser.email,
  displayName: 'John Doe',
  role: UserRole.user,
);
await FirebaseFirestore.instance
    .collection('users')
    .doc(newUser.uid)
    .set(newUser.toFirestore());
```

---

### 3. UserRoleConverter - Custom JSON Converter

`user_role_converter.dart` (36 lines)

**Freezed-compatible UserRole JSON 직렬화를 위한 커스텀 컨버터**입니다.

#### Implementation

```dart
import 'package:json_annotation/json_annotation.dart';
import '../enums/user_role.dart';

/// UserRole <-> String JSON Converter for Freezed
///
/// **Purpose**:
/// - Freezed-compatible JSON serialization for UserRole enum
/// - Replaces @JsonKey pattern with @JsonConverter
/// - Reusable converter class
///
/// **Usage**:
/// ```dart
/// @freezed
/// class AuthUser with _$AuthUser {
///   const factory AuthUser({
///     @UserRoleConverter()  // ← Use this
///     @Default(UserRole.user)
///     UserRole role,
///   }) = _AuthUser;
/// }
/// ```
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  /// Convert JSON string to UserRole enum
  @override
  UserRole fromJson(String json) {
    return UserRole.fromValue(json);
  }

  /// Convert UserRole enum to JSON string
  @override
  String toJson(UserRole role) {
    return role.toValue();
  }
}
```

#### Why This Pattern?

**❌ Old Pattern (Deprecated)**:
```dart
// Caused warning: invalid_annotation_target
@JsonKey(
  fromJson: _userRoleFromJson,
  toJson: _userRoleToJson,
)
@Default(UserRole.user)
UserRole role,
```

**✅ New Pattern (Recommended)**:
```dart
// Freezed-compatible, no warnings
@UserRoleConverter()
@Default(UserRole.user)
UserRole role,
```

---

## enums/ - Business Logic Enums

### UserRole - 사용자 역할 관리

`user_role.dart` (39 lines)

**비즈니스 로직을 포함한 사용자 역할 열거형**입니다.

#### Complete Implementation

```dart
enum UserRole {
  /// 관리자 - 모든 권한 보유
  admin,

  /// 테스터 - 테스트 기능 접근 가능
  tester,

  /// 일반 사용자 - 기본 권한
  user;

  /// 관리자 여부 확인
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (currentUser.role.isAdmin) {
  ///   showAdminPanel();
  /// }
  /// ```
  bool get isAdmin => this == UserRole.admin;

  /// 테스터 여부 확인 (관리자도 테스터 권한 보유)
  ///
  /// **비즈니스 규칙**:
  /// - admin은 tester 권한도 가짐 (상위 호환)
  /// - tester는 테스트 기능 접근 가능
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (currentUser.role.isTester) {
  ///   showTestFeatures();
  /// }
  /// ```
  bool get isTester => this == UserRole.tester || this == UserRole.admin;

  /// String 값으로 변환 (Firestore 저장용)
  ///
  /// **사용 예시**:
  /// ```dart
  /// await firestore.doc('users/$uid').update({
  ///   'role': UserRole.admin.toValue(),  // 'admin'
  /// });
  /// ```
  String toValue() {
    return switch (this) {
      UserRole.admin => 'admin',
      UserRole.tester => 'tester',
      UserRole.user => 'user',
    };
  }

  /// String 값에서 UserRole 생성 (Firestore 읽기용)
  ///
  /// **안전성**:
  /// - 알 수 없는 값은 기본값 UserRole.user로 처리
  /// - null-safe 파싱
  ///
  /// **사용 예시**:
  /// ```dart
  /// final role = UserRole.fromValue(data['role'] as String);
  /// ```
  static UserRole fromValue(String value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'tester' => UserRole.tester,
      'user' => UserRole.user,
      _ => UserRole.user, // 기본값
    };
  }
}
```

#### Business Logic Examples

```dart
// ✅ Role hierarchy
final admin = UserRole.admin;
assert(admin.isAdmin == true);
assert(admin.isTester == true);  // Admin has tester privileges

final tester = UserRole.tester;
assert(tester.isAdmin == false);
assert(tester.isTester == true);

final user = UserRole.user;
assert(user.isAdmin == false);
assert(user.isTester == false);

// ✅ Permission checks
void showAdminPanel(AuthUser user) {
  if (!user.role.isAdmin) {
    throw AuthFailure.insufficientPermissions();
  }
  // Show admin panel
}

void showTestFeatures(AuthUser user) {
  if (!user.role.isTester) {
    return;  // Hide test features
  }
  // Show test features
}

// ✅ Firestore integration
await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .update({
      'role': UserRole.admin.toValue(),  // 'admin'
    });

final roleStr = snapshot.data()?['role'] as String;
final role = UserRole.fromValue(roleStr);  // Safe parsing
```

---

## failures/ - Domain Errors

### AuthFailure - 인증 실패 타입 정의

`auth_failure.dart` (90 lines)

**18개의 도메인 특화 인증 실패 타입을 정의**합니다. Freezed sealed class로 타입 안전한 에러 처리를 보장합니다.

#### Complete Implementation

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/failures/failure.dart';

part 'auth_failure.freezed.dart';

/// Auth Feature의 모든 실패 케이스를 나타내는 Domain Error
///
/// **Clean Architecture v4.0 규칙**:
/// - Domain 레이어에 정의 (외부 의존성 없음)
/// - Freezed sealed class로 모든 케이스 명시
/// - 사용자 친화적 메시지 제공
/// - Pattern matching으로 exhaustive 처리
@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  // ==================== Email/Password Errors ====================
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.emailAlreadyInUse() = EmailAlreadyInUse;
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.wrongPassword() = WrongPassword;
  const factory AuthFailure.userNotFound() = UserNotFound;

  // ==================== Account State Errors ====================
  const factory AuthFailure.userDisabled() = UserDisabled;
  const factory AuthFailure.accountExistsWithDifferentCredential() = AccountExistsWithDifferentCredential;
  const factory AuthFailure.emailNotVerified() = EmailNotVerified;

  // ==================== Operation Errors ====================
  const factory AuthFailure.operationNotAllowed() = OperationNotAllowed;
  const factory AuthFailure.tooManyRequests() = TooManyRequests;
  const factory AuthFailure.requiresRecentLogin() = RequiresRecentLogin;

  // ==================== Phone Auth Errors ====================
  const factory AuthFailure.invalidPhoneNumber() = InvalidPhoneNumber;
  const factory AuthFailure.invalidVerificationCode() = InvalidVerificationCode;
  const factory AuthFailure.invalidVerificationId() = InvalidVerificationId;

  // ==================== Network & System Errors ====================
  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.insufficientPermissions() = InsufficientPermissions;
  const factory AuthFailure.unexpected([String? message]) = Unexpected;

  /// 사용자에게 표시할 에러 메시지
  ///
  /// **다국어 지원 고려**:
  /// - 현재는 한국어 메시지
  /// - 향후 AppLocalizations 통합 가능
  @override
  String get message {
    return when(
      // Email/Password Errors
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      weakPassword: () => '비밀번호가 너무 약합니다. 최소 6자 이상 입력해주세요',
      emailAlreadyInUse: () => '이미 사용 중인 이메일입니다',
      invalidCredentials: () => '이메일 또는 비밀번호가 올바르지 않습니다',
      wrongPassword: () => '비밀번호가 올바르지 않습니다',
      userNotFound: () => '존재하지 않는 사용자입니다',

      // Account State Errors
      userDisabled: () => '비활성화된 계정입니다. 관리자에게 문의하세요',
      accountExistsWithDifferentCredential: () => '다른 로그인 방법으로 이미 등록된 계정입니다',
      emailNotVerified: () => '이메일 인증이 필요합니다',

      // Operation Errors
      operationNotAllowed: () => '허용되지 않는 작업입니다',
      tooManyRequests: () => '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요',
      requiresRecentLogin: () => '보안을 위해 다시 로그인해주세요',

      // Phone Auth Errors
      invalidPhoneNumber: () => '올바르지 않은 전화번호 형식입니다',
      invalidVerificationCode: () => '인증 코드가 올바르지 않습니다',
      invalidVerificationId: () => '인증 세션이 만료되었습니다. 다시 시도해주세요',

      // Network & System Errors
      networkError: () => '네트워크 연결을 확인해주세요',
      insufficientPermissions: () => '권한이 부족합니다',
      unexpected: (msg) => msg ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

#### Failure Hierarchy

```
AuthFailure (sealed class)
├── Email/Password Errors (6개)
│   ├── InvalidEmail
│   ├── WeakPassword
│   ├── EmailAlreadyInUse
│   ├── InvalidCredentials
│   ├── WrongPassword
│   └── UserNotFound
├── Account State Errors (3개)
│   ├── UserDisabled
│   ├── AccountExistsWithDifferentCredential
│   └── EmailNotVerified
├── Operation Errors (3개)
│   ├── OperationNotAllowed
│   ├── TooManyRequests
│   └── RequiresRecentLogin
├── Phone Auth Errors (3개)
│   ├── InvalidPhoneNumber
│   ├── InvalidVerificationCode
│   └── InvalidVerificationId
└── Network & System Errors (3개)
    ├── NetworkError
    ├── InsufficientPermissions
    └── Unexpected
```

#### Usage Examples

```dart
// ✅ Pattern matching (exhaustive)
final result = await signInUseCase.execute(email: email, password: password);

result.fold(
  (failure) {
    // Freezed sealed class guarantees exhaustive matching
    return failure.when(
      invalidEmail: () => showSnackBar('이메일 형식이 올바르지 않습니다'),
      weakPassword: () => showSnackBar('비밀번호가 너무 약합니다'),
      emailAlreadyInUse: () => showSnackBar('이미 사용 중인 이메일입니다'),
      invalidCredentials: () => showSnackBar('이메일 또는 비밀번호가 올바르지 않습니다'),
      wrongPassword: () => showSnackBar('비밀번호가 올바르지 않습니다'),
      userNotFound: () => showSnackBar('존재하지 않는 사용자입니다'),
      userDisabled: () => showSnackBar('비활성화된 계정입니다'),
      accountExistsWithDifferentCredential: () => showSnackBar('다른 로그인 방법으로 이미 등록된 계정입니다'),
      emailNotVerified: () => showSnackBar('이메일 인증이 필요합니다'),
      operationNotAllowed: () => showSnackBar('허용되지 않는 작업입니다'),
      tooManyRequests: () => showSnackBar('너무 많은 요청이 발생했습니다'),
      requiresRecentLogin: () => showSnackBar('보안을 위해 다시 로그인해주세요'),
      invalidPhoneNumber: () => showSnackBar('올바르지 않은 전화번호 형식입니다'),
      invalidVerificationCode: () => showSnackBar('인증 코드가 올바르지 않습니다'),
      invalidVerificationId: () => showSnackBar('인증 세션이 만료되었습니다'),
      networkError: () => showSnackBar('네트워크 연결을 확인해주세요'),
      insufficientPermissions: () => showSnackBar('권한이 부족합니다'),
      unexpected: (msg) => showSnackBar(msg ?? '알 수 없는 오류가 발생했습니다'),
    );
  },
  (user) => navigateToHome(user),
);

// ✅ Simple message display
try {
  await signIn(email, password);
} on AuthFailure catch (e) {
  showSnackBar(e.message);  // User-friendly message
}

// ✅ Type-safe error creation
if (!_isValidEmail(email)) {
  return left(const AuthFailure.invalidEmail());
}

if (password.length < 6) {
  return left(const AuthFailure.weakPassword());
}
```

---

## repositories/ - Repository Interfaces

### IAuthRepository - 인증 레포지토리 인터페이스

`i_auth_repository.dart` (62 lines)

**14개의 인증 관련 메서드를 정의하는 추상 인터페이스**입니다. Data 레이어의 `AuthRepositoryImpl`이 이를 구현합니다.

#### Complete Interface

```dart
import 'package:dartz/dartz.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';

/// Auth Repository Interface - Domain Layer
///
/// **Clean Architecture v4.0 규칙**:
/// - Domain 레이어에 인터페이스 정의
/// - Data 레이어에서 구현 (AuthRepositoryImpl)
/// - Presentation 레이어에서 DI로 주입
///
/// **Firebase-Centric Architecture**:
/// - Repository가 Firebase SDK 직접 사용
/// - Contract/Port/Adapter 추상화 제거
/// - 단순하고 명확한 인터페이스
abstract class IAuthRepository {
  // ==================== User State ====================

  /// 현재 로그인된 사용자 정보 조회
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 시 사용자 정보
  /// - `Left(AuthFailure.userNotFound)`: 미로그인 시
  ///
  /// **사용 예시**:
  /// ```dart
  /// final result = await repository.getCurrentUser();
  /// result.fold(
  ///   (failure) => print('Not logged in: ${failure.message}'),
  ///   (user) => print('Logged in as ${user.displayName}'),
  /// );
  /// ```
  Future<Either<AuthFailure, AuthUser>> getCurrentUser();

  /// 로그인 상태 확인
  ///
  /// **반환값**:
  /// - `true`: 로그인됨
  /// - `false`: 미로그인
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (repository.isSignedIn) {
  ///   print('User is logged in');
  /// }
  /// ```
  bool get isSignedIn;

  /// 인증 상태 변경 스트림
  ///
  /// **사용 시나리오**:
  /// - 로그인/로그아웃 시 자동 UI 업데이트
  /// - AppStateNotifier에서 구독
  ///
  /// **사용 예시**:
  /// ```dart
  /// repository.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     navigateToHome();
  ///   } else {
  ///     navigateToLogin();
  ///   }
  /// });
  /// ```
  Stream<AuthUser?> get authStateChanges;

  // ==================== Sign In ====================

  /// 이메일/비밀번호 로그인
  ///
  /// **파라미터**:
  /// - `email`: 이메일 주소
  /// - `password`: 비밀번호
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패 (InvalidCredentials, InvalidEmail, WeakPassword 등)
  ///
  /// **사용 예시**:
  /// ```dart
  /// final result = await repository.signInWithEmailAndPassword(
  ///   'user@example.com',
  ///   'password123',
  /// );
  /// result.fold(
  ///   (failure) => print('Login failed: ${failure.message}'),
  ///   (user) => print('Welcome ${user.displayName}!'),
  /// );
  /// ```
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Google 소셜 로그인
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패 (CancelledByUser, NetworkError 등)
  ///
  /// **사용 예시**:
  /// ```dart
  /// final result = await repository.signInWithGoogle();
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (user) => navigateToHome(user),
  /// );
  /// ```
  Future<Either<AuthFailure, AuthUser>> signInWithGoogle();

  /// Apple 소셜 로그인
  ///
  /// **플랫폼 지원**:
  /// - iOS, macOS: 네이티브 Sign in with Apple
  /// - Android, Web: Apple OAuth
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패
  Future<Either<AuthFailure, AuthUser>> signInWithApple();

  /// 전화번호 로그인 (SMS OTP)
  ///
  /// **프로세스**:
  /// 1. sendSmsOtp()로 인증 코드 발송
  /// 2. 사용자가 입력한 코드로 signInWithPhoneNumber() 호출
  ///
  /// **파라미터**:
  /// - `phoneNumber`: 전화번호 (+82 10-1234-5678)
  /// - `verificationCode`: SMS로 받은 6자리 코드
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패 (InvalidVerificationCode 등)
  Future<Either<AuthFailure, AuthUser>> signInWithPhoneNumber(
    String phoneNumber,
    String verificationCode,
  );

  /// SMS OTP 발송
  ///
  /// **파라미터**:
  /// - `phoneNumber`: 전화번호 (+82 10-1234-5678)
  ///
  /// **반환값**:
  /// - `true`: 발송 성공
  /// - `false`: 발송 실패
  Future<bool> sendSmsOtp(String phoneNumber);

  // ==================== Sign Up ====================

  /// 이메일/비밀번호 회원가입
  ///
  /// **프로세스**:
  /// 1. Firebase Auth에 계정 생성
  /// 2. Firestore users 컬렉션에 문서 생성
  ///
  /// **파라미터**:
  /// - `email`: 이메일 주소
  /// - `password`: 비밀번호 (최소 6자)
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 회원가입 성공
  /// - `Left(AuthFailure)`: 실패 (EmailAlreadyInUse, WeakPassword 등)
  Future<Either<AuthFailure, AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  // ==================== Sign Out ====================

  /// 로그아웃
  ///
  /// **효과**:
  /// - Firebase Auth 세션 종료
  /// - authStateChanges에 null 이벤트 발생
  /// - 로컬 캐시 정리
  Future<void> signOut();

  // ==================== Account Management ====================

  /// 비밀번호 재설정 이메일 발송
  ///
  /// **파라미터**:
  /// - `email`: 비밀번호를 재설정할 계정의 이메일
  ///
  /// **프로세스**:
  /// 1. Firebase가 재설정 링크 이메일 발송
  /// 2. 사용자가 링크 클릭하여 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증 메일 발송
  ///
  /// **반환값**:
  /// - `true`: 발송 성공
  /// - `false`: 발송 실패 (이미 인증됨, 네트워크 에러 등)
  Future<bool> sendEmailVerification();

  /// 계정 삭제
  ///
  /// **보안 요구사항**:
  /// - 최근 로그인 필요 (RequiresRecentLogin 에러 발생 가능)
  ///
  /// **프로세스**:
  /// 1. Firebase Auth 계정 삭제
  /// 2. Firestore users 문서 삭제
  /// 3. 관련 데이터 정리 (Cloud Function)
  ///
  /// **반환값**:
  /// - `true`: 삭제 성공
  /// - `false`: 삭제 실패
  Future<bool> deleteUser();

  /// 사용자 프로필 업데이트
  ///
  /// **파라미터**:
  /// - `displayName`: 표시 이름 (optional)
  /// - `photoURL`: 프로필 사진 URL (optional)
  ///
  /// **업데이트 대상**:
  /// - Firebase Auth User Profile
  /// - Firestore users 문서
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// 비밀번호 변경
  ///
  /// **보안 요구사항**:
  /// - 최근 로그인 필요
  ///
  /// **파라미터**:
  /// - `newPassword`: 새 비밀번호 (최소 6자)
  ///
  /// **반환값**:
  /// - `true`: 변경 성공
  /// - `false`: 변경 실패
  Future<Either<AuthFailure, bool>> updatePassword(String newPassword);
}
```

#### Method Categories

| 카테고리 | 메서드 수 | 설명 |
|---------|---------|------|
| **User State** | 3개 | 현재 사용자 조회, 로그인 상태, 상태 변경 스트림 |
| **Sign In** | 5개 | Email, Google, Apple, Phone 로그인 + OTP 발송 |
| **Sign Up** | 1개 | 이메일 회원가입 |
| **Sign Out** | 1개 | 로그아웃 |
| **Account Management** | 4개 | 비밀번호 재설정, 이메일 인증, 계정 삭제, 프로필 업데이트 |

---

### Firebase Error Mapping

**Repository 구현체는 Firebase 에러를 Domain 실패 타입으로 변환**합니다. 이는 `AuthRepositoryImpl`의 `_mapFirebaseAuthException()` 메서드에서 처리됩니다.

#### Complete Mapping Table (11 Codes)

| Firebase 에러 코드 | Domain 실패 타입 | 사용자 메시지 (한국어) |
|------------------|----------------|---------------------|
| `invalid-email` | `AuthFailure.invalidEmail()` | 이메일 형식이 올바르지 않습니다 |
| `weak-password` | `AuthFailure.weakPassword()` | 비밀번호가 너무 약합니다. 최소 6자 이상 입력해주세요 |
| `email-already-in-use` | `AuthFailure.emailAlreadyInUse()` | 이미 사용 중인 이메일입니다 |
| `user-not-found` | `AuthFailure.userNotFound()` | 존재하지 않는 사용자입니다 |
| `wrong-password` | `AuthFailure.invalidCredentials()` | 이메일 또는 비밀번호가 올바르지 않습니다 |
| `invalid-phone-number` | `AuthFailure.invalidPhoneNumber()` | 올바르지 않은 전화번호 형식입니다 |
| `invalid-verification-code` | `AuthFailure.invalidSmsCode()` | 인증 코드가 올바르지 않습니다 |
| `expired-action-code` | `AuthFailure.smsCodeExpired()` | 인증 코드가 만료되었습니다 |
| `user-disabled` | `AuthFailure.userDisabled()` | 비활성화된 계정입니다. 관리자에게 문의하세요 |
| `requires-recent-login` | `AuthFailure.requiresRecentLogin()` | 보안을 위해 다시 로그인해주세요 |
| `network-request-failed` | `AuthFailure.networkError()` | 네트워크 연결을 확인해주세요 |
| **기타 모든 코드** | `AuthFailure.unexpected(message)` | 알 수 없는 오류가 발생했습니다 |

#### Mapping Implementation Example

```dart
// Data Layer: auth_repository_impl.dart
AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return const AuthFailure.invalidEmail();
    case 'weak-password':
      return const AuthFailure.weakPassword();
    case 'email-already-in-use':
      return const AuthFailure.emailAlreadyInUse();
    case 'user-not-found':
      return const AuthFailure.userNotFound();
    case 'wrong-password':
      return const AuthFailure.invalidCredentials();
    case 'invalid-phone-number':
      return const AuthFailure.invalidPhoneNumber();
    case 'invalid-verification-code':
      return const AuthFailure.invalidSmsCode();
    case 'expired-action-code':
      return const AuthFailure.smsCodeExpired();
    case 'user-disabled':
      return const AuthFailure.userDisabled();
    case 'requires-recent-login':
      return const AuthFailure.requiresRecentLogin();
    case 'network-request-failed':
      return const AuthFailure.networkError();
    default:
      return AuthFailure.unexpected(
        e.message ?? 'Firebase Auth Error: ${e.code}',
      );
  }
}
```

#### Usage in Repository Methods

```dart
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
    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      return left(const AuthFailure.userNotFound());
    }

    final authUser = await firebaseUser.toDomainUser();
    return right(authUser);
  } on FirebaseAuthException catch (e) {
    // Firebase 에러를 Domain 실패로 변환
    return left(_mapFirebaseAuthException(e));
  } catch (e) {
    return left(AuthFailure.unexpected(e.toString()));
  }
}
```

#### Benefits of Error Mapping

**1. Type Safety**: 컴파일 타임에 모든 에러 케이스 검증
```dart
result.fold(
  (failure) {
    // Freezed sealed class가 모든 케이스 체크 강제
    return failure.when(
      invalidEmail: () => ...,
      weakPassword: () => ...,
      // Missing case? Compile error!
    );
  },
  (user) => ...,
);
```

**2. Consistency**: 모든 Repository 메서드가 동일한 에러 변환 로직 사용

**3. User-Friendly**: 한국어 메시지로 사용자 친화적 피드백

**4. Testability**: Mock Repository로 특정 실패 시나리오 쉽게 테스트
```dart
// Test code
when(mockRepository.signIn(any, any))
    .thenAnswer((_) async => left(const AuthFailure.invalidCredentials()));
```

---

## usecases/ - Business Logic Encapsulation

### UseCase Pattern Overview

**UseCase는 단일 비즈니스 작업을 캡슐화**합니다. Clean Architecture v4.0에서 UseCase는:

1. **Single Responsibility**: 하나의 비즈니스 작업만 담당
2. **Testable**: Repository를 Mock하여 독립적 테스트 가능
3. **Reusable**: 여러 Presentation 레이어에서 재사용
4. **Type-Safe**: Either 패턴으로 타입 안전한 에러 처리

### UseCase Structure

```dart
// ✅ Standard UseCase pattern
class XxxUseCase {
  final IAuthRepository _repository;

  XxxUseCase({required IAuthRepository repository}) : _repository = repository;

  Future<Either<AuthFailure, T>> execute({
    // Parameters
  }) async {
    try {
      // 1. Validate input
      // 2. Call repository
      // 3. Handle errors
      // 4. Return result
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

### 10 UseCases Deep Dive

#### 1. SignInWithEmailUseCase (88 lines)

**이메일/비밀번호 로그인 비즈니스 로직**

```dart
class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase({required IAuthRepository repository})
      : _repository = repository;

  /// 이메일/비밀번호로 로그인
  ///
  /// **비즈니스 규칙**:
  /// 1. 이메일 형식 검증 (정규식)
  /// 2. 비밀번호 비어있지 않은지 확인
  /// 3. Repository 호출
  /// 4. 사용자 정보 반환
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 실패 (InvalidEmail, InvalidCredentials 등)
  ///
  /// **Either Pattern**:
  /// - Repository already returns Either
  /// - UseCase adds input validation
  /// - Uses fold() for business logic
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    debugPrint('Attempting to sign in with email...');

    // 1. Validate email format (Business Logic)
    if (!_isValidEmail(email)) {
      return left(const AuthFailure.invalidEmail());
    }

    // 2. Validate password (Business Logic)
    if (password.isEmpty) {
      return left(const AuthFailure.weakPassword());
    }

    // 3. Call repository (Returns Either)
    final result = await _repository.signInWithEmailAndPassword(email, password);

    // 4. Use fold() for business logic
    return result.fold(
      (failure) {
        debugPrint('Sign in failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (user) {
        if (!user.isEmailVerified) {
          debugPrint('Warning: User email is not verified');
        }
        debugPrint('Sign in successful for user: ${user.uid}');
        return right(user);
      },
    );
  }

  /// 이메일 형식 검증 (RFC 5322 간소화 버전)
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
```

**Usage**:
```dart
// Presentation layer
final result = await signInUseCase.execute(
  email: emailController.text,
  password: passwordController.text,
);

result.fold(
  (failure) => showSnackBar(failure.message),
  (user) => navigateToHome(user),
);
```

---

#### 2. SignUpWithEmailUseCase (135 lines)

**이메일 회원가입 + Firestore 사용자 문서 생성**

```dart
class SignUpWithEmailUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  SignUpWithEmailUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  }) : _repository = repository,
       _idempotencyService = idempotencyService;

  /// 이메일/비밀번호로 회원가입
  ///
  /// **비즈니스 규칙**:
  /// 1. 이메일 형식 검증
  /// 2. 비밀번호 강도 검증 (최소 6자)
  /// 3. Firebase Auth 계정 생성
  /// 4. Firestore users 문서 생성 (멱등성 보장)
  /// 5. 이메일 인증 메일 자동 발송 (optional)
  ///
  /// **멱등성 보장**:
  /// - IdempotencyService로 중복 가입 방지
  /// - 네트워크 재시도 시 안전
  ///
  /// **Either Pattern with IdempotencyService**:
  /// - Repository returns Either
  /// - IdempotencyService operation throws on failure
  /// - Use fold() within operation to handle Repository Either
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
    required String eventId,
    String? displayName,
  }) async {
    try {
      debugPrint('Attempting to sign up with email...');

      // 1. Validate email format (Business Logic)
      if (!_isValidEmail(email)) {
        return left(const AuthFailure.invalidEmail());
      }

      // 2. Validate password strength (Business Logic)
      if (password.length < 6) {
        return left(const AuthFailure.weakPassword());
      }

      // 3. Execute with IdempotencyService
      await _idempotencyService.executeIdempotent<AuthUser>(
        entityType: 'auth_signup',
        entityId: email,
        userId: email,
        eventId: eventId,
        operation: (transaction) async {
          debugPrint('Idempotency check passed, creating account...');

          // Repository returns Either - use fold to extract or throw
          final userResult = await _repository.createUserWithEmailAndPassword(
            email,
            password,
          );
          final user = userResult.fold(
            (failure) {
              debugPrint('Failed to create account');
              throw failure;  // Throw for IdempotencyService to catch
            },
            (user) => user,  // Return success
          );

          // 4. Update display name if provided (Repository returns Either)
          if (displayName != null && displayName.isNotEmpty) {
            final updateResult = await _repository.updateUserProfile(
              displayName: displayName,
            );
            updateResult.fold(
              (failure) => debugPrint('Failed to update display name: ${failure.message}'),
              (_) => debugPrint('Display name updated'),
            );
          }

          // 5. Send email verification (optional)
          final verifyResult = await _repository.sendEmailVerification();
          verifyResult.fold(
            (failure) => debugPrint('Failed to send verification email: ${failure.message}'),
            (_) => debugPrint('Verification email sent'),
          );

          return user;
        },
      );

      return right(user);

    } on IdempotencyViolation catch (e) {
      debugPrint('Duplicate signup attempt prevented: $e');
      return left(const AuthFailure.emailAlreadyInUse());
    } on AuthFailure catch (e) {
      debugPrint('Sign up failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Sign up failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
```

---

#### 3. SignInWithGoogleUseCase (50 lines)

**Google 소셜 로그인**

```dart
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;

  SignInWithGoogleUseCase({required IAuthRepository repository})
      : _repository = repository;

  /// Google 소셜 로그인
  ///
  /// **프로세스**:
  /// 1. Google Sign-In 팝업 표시
  /// 2. 사용자 계정 선택
  /// 3. Firebase Auth 연동
  /// 4. Firestore 사용자 문서 자동 생성/업데이트
  ///
  /// **첫 로그인 시**:
  /// - Firestore users 문서 자동 생성
  /// - 프로필 사진, 이름 자동 동기화
  ///
  /// **Either Pattern - Simple Pass-Through**:
  /// - Repository already returns Either
  /// - UseCase adds logging only
  /// - Direct fold() for business logic
  Future<Either<AuthFailure, AuthUser>> execute() async {
    debugPrint('Executing Google Sign In...');

    final result = await _repository.signInWithGoogle();

    return result.fold(
      (failure) {
        debugPrint('Google Sign In failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (user) {
        debugPrint('Google Sign In successful: ${user.email}');
        return right(user);
      },
    );
  }
}
```

---

#### 4. SignInWithAppleUseCase (56 lines)

**Apple 소셜 로그인**

```dart
class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase({required IAuthRepository repository})
      : _repository = repository;

  /// Apple 소셜 로그인
  ///
  /// **플랫폼별 동작**:
  /// - iOS/macOS: 네이티브 Sign in with Apple
  /// - Android/Web: Apple OAuth
  ///
  /// **프라이버시 기능**:
  /// - 이메일 숨기기 지원 (Hide My Email)
  /// - 최소 정보만 공유
  Future<Either<AuthFailure, AuthUser>> execute() async {
    try {
      final result = await _repository.signInWithApple();
      return result;
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

---

#### 5. SignInWithPhoneUseCase (192 lines)

**전화번호 로그인 (SMS OTP)**

```dart
class SignInWithPhoneUseCase {
  final IAuthRepository _repository;

  SignInWithPhoneUseCase({required IAuthRepository repository})
      : _repository = repository;

  /// SMS OTP 발송
  ///
  /// **비즈니스 규칙**:
  /// 1. 전화번호 형식 검증 (+82 10-1234-5678)
  /// 2. 최대 재발송 횟수 제한 (3회)
  /// 3. Firebase가 SMS 발송
  /// 4. 30초 타이머 시작
  Future<Either<AuthFailure, bool>> sendOtp({
    required String phoneNumber,
  }) async {
    try {
      // 1. Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        return left(const AuthFailure.invalidPhoneNumber());
      }

      // 2. Send SMS OTP
      final success = await _repository.sendSmsOtp(phoneNumber);

      if (!success) {
        return left(const AuthFailure.tooManyRequests());
      }

      return right(true);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// SMS 인증 코드로 로그인
  ///
  /// **비즈니스 규칙**:
  /// 1. 인증 코드 6자리 검증
  /// 2. Firebase 인증 처리
  /// 3. Firestore 사용자 문서 생성/업데이트
  Future<Either<AuthFailure, AuthUser>> verifyOtp({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      // 1. Validate verification code (6 digits)
      if (verificationCode.length != 6) {
        return left(const AuthFailure.invalidVerificationCode());
      }

      // 2. Verify OTP with Firebase
      final result = await _repository.signInWithPhoneNumber(
        phoneNumber,
        verificationCode,
      );

      return result;

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// 전화번호 형식 검증 (한국 번호)
  ///
  /// **허용 형식**:
  /// - +82 10-1234-5678
  /// - +82 10 1234 5678
  /// - 010-1234-5678
  /// - 01012345678
  bool _isValidPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Korean phone number patterns
    final patterns = [
      RegExp(r'^\+8210\d{8}$'),  // +82 10XXXXXXXX
      RegExp(r'^010\d{8}$'),     // 010XXXXXXXX
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleaned));
  }
}
```

---

#### 6. SignOutUseCase (57 lines)

**로그아웃**

```dart
class SignOutUseCase {
  final IAuthRepository _repository;

  SignOutUseCase({required IAuthRepository repository})
      : _repository = repository;

  /// 로그아웃
  ///
  /// **프로세스**:
  /// 1. Firebase Auth 세션 종료
  /// 2. 로컬 캐시 정리
  /// 3. authStateChanges에 null 이벤트 발생
  /// 4. UI 자동 업데이트
  ///
  /// **효과**:
  /// - 모든 Firebase 리스너 자동 해제
  /// - 보안 토큰 무효화
  /// - 로그인 화면으로 자동 이동
  Future<Either<AuthFailure, void>> execute() async {
    try {
      await _repository.signOut();
      return right(null);
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

---

#### 7. PasswordManagementUseCase (209 lines)

**비밀번호 재설정 및 변경**

```dart
class PasswordManagementUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  PasswordManagementUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  }) : _repository = repository,
       _idempotencyService = idempotencyService;

  /// 비밀번호 재설정 이메일 발송
  ///
  /// **프로세스**:
  /// 1. 이메일 형식 검증
  /// 2. 중복 발송 방지 (5분 내)
  /// 3. Firebase가 재설정 링크 이메일 발송
  /// 4. 사용자가 링크 클릭하여 재설정
  Future<Either<AuthFailure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    final idempotencyKey = 'password_reset_$email';

    try {
      // 1. Validate email format
      if (!_isValidEmail(email)) {
        return left(const AuthFailure.invalidEmail());
      }

      // 2. Check idempotency (5분 내 중복 방지)
      if (_idempotencyService.isDuplicate(idempotencyKey)) {
        return left(const AuthFailure.tooManyRequests());
      }

      // 3. Send password reset email
      await _repository.sendPasswordResetEmail(email);

      // 4. Mark as processed
      _idempotencyService.markProcessed(idempotencyKey);

      return right(null);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// 비밀번호 변경
  ///
  /// **보안 요구사항**:
  /// - 최근 로그인 필요 (5분 이내)
  /// - 새 비밀번호 강도 검증
  ///
  /// **비즈니스 규칙**:
  /// 1. 새 비밀번호 강도 검증 (최소 6자, 숫자/문자 조합 권장)
  /// 2. Firebase 비밀번호 업데이트
  /// 3. 모든 세션 재인증 필요
  Future<Either<AuthFailure, void>> updatePassword({
    required String newPassword,
  }) async {
    try {
      // 1. Validate password strength
      if (newPassword.length < 6) {
        return left(const AuthFailure.weakPassword());
      }

      // 2. Update password
      final success = await _repository.updatePassword(newPassword);

      if (!success) {
        return left(const AuthFailure.requiresRecentLogin());
      }

      return right(null);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
```

---

#### 8. EmailVerificationUseCase (200 lines)

**이메일 인증 발송 및 확인**

```dart
class EmailVerificationUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  EmailVerificationUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  }) : _repository = repository,
       _idempotencyService = idempotencyService;

  /// 이메일 인증 메일 발송
  ///
  /// **비즈니스 규칙**:
  /// 1. 이미 인증된 경우 발송 안 함
  /// 2. 중복 발송 방지 (5분 내)
  /// 3. 최대 재발송 횟수 제한 (3회)
  ///
  /// **프로세스**:
  /// 1. 현재 사용자 조회
  /// 2. 인증 상태 확인
  /// 3. Firebase가 인증 이메일 발송
  /// 4. 사용자가 링크 클릭하여 인증
  Future<Either<AuthFailure, bool>> sendVerificationEmail() async {
    try {
      // 1. Get current user
      final user = await _repository.getCurrentUser();
      if (user == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 2. Check if already verified
      if (user.isEmailVerified) {
        return right(false);  // Already verified
      }

      // 3. Check idempotency (5분 내 중복 방지)
      final idempotencyKey = 'email_verification_${user.uid}';
      if (_idempotencyService.isDuplicate(idempotencyKey)) {
        return left(const AuthFailure.tooManyRequests());
      }

      // 4. Send verification email
      final success = await _repository.sendEmailVerification();

      if (!success) {
        return left(const AuthFailure.networkError());
      }

      // 5. Mark as processed
      _idempotencyService.markProcessed(idempotencyKey);

      return right(true);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// 이메일 인증 상태 새로고침
  ///
  /// **사용 시나리오**:
  /// - 사용자가 이메일 링크 클릭 후 앱으로 돌아왔을 때
  /// - 주기적으로 인증 상태 확인
  ///
  /// **프로세스**:
  /// 1. Firebase에서 최신 사용자 정보 조회
  /// 2. isEmailVerified 상태 반환
  Future<Either<AuthFailure, bool>> checkVerificationStatus() async {
    try {
      // 1. Refresh user data from Firebase
      final user = await _repository.getCurrentUser();

      if (user == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 2. Return verification status
      return right(user.isEmailVerified);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

---

#### 9. AccountManagementUseCase (294 lines)

**계정 관리 (프로필 업데이트, 계정 삭제)**

```dart
class AccountManagementUseCase {
  final IAuthRepository _repository;

  AccountManagementUseCase({required IAuthRepository repository})
      : _repository = repository;

  /// 사용자 프로필 업데이트
  ///
  /// **업데이트 가능 필드**:
  /// - displayName: 표시 이름
  /// - photoURL: 프로필 사진 URL
  ///
  /// **프로세스**:
  /// 1. Firebase Auth User Profile 업데이트
  /// 2. Firestore users 문서 업데이트
  /// 3. 변경사항 즉시 반영
  Future<Either<AuthFailure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      // 1. Validate at least one field is provided
      if (displayName == null && photoURL == null) {
        return left(const AuthFailure.unexpected('업데이트할 필드가 없습니다'));
      }

      // 2. Update Firebase Auth profile
      await _repository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      return right(null);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// 계정 삭제
  ///
  /// **보안 요구사항**:
  /// - 최근 로그인 필요 (5분 이내)
  /// - 사용자 재확인 권장
  ///
  /// **프로세스**:
  /// 1. Firebase Auth 계정 삭제
  /// 2. Firestore users 문서 삭제
  /// 3. Cloud Function이 관련 데이터 정리:
  ///    - 작성한 게시물
  ///    - 댓글
  ///    - 채팅 메시지
  ///    - Storage 파일 (프로필 사진 등)
  ///
  /// **복구 불가**:
  /// - 삭제된 계정은 복구 불가
  /// - 사용자에게 경고 메시지 필수
  Future<Either<AuthFailure, void>> deleteAccount() async {
    try {
      // 1. Delete account
      final success = await _repository.deleteUser();

      if (!success) {
        return left(const AuthFailure.requiresRecentLogin());
      }

      return right(null);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// 프로필 사진 업로드 및 업데이트
  ///
  /// **프로세스**:
  /// 1. 이미지 파일 Storage에 업로드
  /// 2. 다운로드 URL 획득
  /// 3. updateProfile()로 URL 업데이트
  ///
  /// **파일 크기 제한**:
  /// - 최대 5MB
  /// - 권장 해상도: 512x512 이상
  Future<Either<AuthFailure, String>> uploadProfilePhoto({
    required String imagePath,
  }) async {
    try {
      // 1. Get current user
      final user = await _repository.getCurrentUser();
      if (user == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 2. Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');

      final file = File(imagePath);
      await storageRef.putFile(file);

      // 3. Get download URL
      final downloadURL = await storageRef.getDownloadURL();

      // 4. Update profile with new photo URL
      await updateProfile(photoURL: downloadURL);

      return right(downloadURL);

    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}
```

---

#### 10. GetCurrentUserUseCase (17 lines)

**현재 로그인 사용자 조회**

```dart
class GetCurrentUserUseCase {
  final IAuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// 현재 로그인된 사용자 정보 조회
  ///
  /// **반환값**:
  /// - `Right(AuthUser)`: 로그인 상태
  /// - `Left(AuthFailure.userNotFound)`: 미로그인
  ///
  /// **사용 시나리오**:
  /// - 앱 시작 시 로그인 상태 확인
  /// - 프로필 페이지 진입 시 사용자 정보 조회
  /// - 인증이 필요한 작업 전 로그인 확인
  ///
  /// **Either Pattern - Direct Pass-Through**:
  /// - Repository already returns Either<AuthFailure, AuthUser>
  /// - No additional business logic needed
  /// - Direct pass-through for maximum simplicity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final result = await getCurrentUserUseCase.execute();
  /// result.fold(
  ///   (failure) => showLoginScreen(),
  ///   (user) => showProfile(user),
  /// );
  /// ```
  Future<Either<AuthFailure, AuthUser>> call() async {
    // Repository already returns Either - direct pass-through
    return await _authRepository.getCurrentUser();
  }
}
```

---

## Clean Architecture v4.0 Principles

### 1. Domain Independence

**Domain 레이어는 외부 의존성이 전혀 없는 순수 Dart 코드**입니다.

```dart
// ✅ GOOD: Domain은 외부 패키지에 의존하지 않음
dependencies:
  - dartz: ^0.10.1          # Either, Option 등 함수형 유틸
  - freezed_annotation: ^2.4.1  # 코드 생성 어노테이션만
  - json_annotation: ^4.8.1     # JSON 어노테이션만

// ❌ BAD: Firebase, HTTP, Storage 등 외부 패키지 의존 금지
X firebase_auth
X dio
X shared_preferences
```

### 2. Dependency Inversion

**Domain이 인터페이스를 정의하고, Data가 구현**합니다.

```dart
// ✅ Domain defines interface
// lib/features/auth/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  );
}

// ✅ Data implements interface
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;

  @override
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Firebase SDK를 직접 사용
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return right(credential.user!.toDomainUser());
  }
}
```

### 3. Firebase-Centric Architecture

**Contract/Port/Adapter 추상화를 제거하고 Firebase SDK를 직접 사용**합니다.

```dart
// ❌ OLD: Contract/Port/Adapter pattern (제거됨)
AuthContract (App) → UserContract (App) → AuthPort (Domain) → AuthAdapter (Data)

// ✅ NEW: Firebase-Centric (현재)
Domain Interface → Data Implementation → Firebase SDK
```

**Benefits**:
- 불필요한 추상화 제거
- 코드 라인 40% 감소
- 명확한 의존성 흐름
- Firebase 기능 100% 활용

### 4. Either Pattern for Error Handling

**Either<L, R> 패턴으로 타입 안전한 에러 처리**를 구현합니다.

```dart
// ✅ Either pattern
Future<Either<AuthFailure, AuthUser>> signIn(String email, String password) async {
  try {
    final user = await repository.signInWithEmailAndPassword(email, password);
    return right(user);  // Success
  } on AuthFailure catch (e) {
    return left(e);  // Domain error
  } catch (e) {
    return left(AuthFailure.unexpected(e.toString()));  // Unexpected error
  }
}

// ✅ Usage with pattern matching
final result = await signInUseCase.execute(email: email, password: password);

result.fold(
  (failure) {
    // Handle error (type-safe)
    print('Login failed: ${failure.message}');
  },
  (user) {
    // Handle success
    navigateToHome(user);
  },
);

// ❌ BAD: Exception-based error handling
try {
  final user = await signIn(email, password);
  navigateToHome(user);
} catch (e) {
  print('Error: $e');  // Not type-safe
}
```

### 5. Single Responsibility (UseCases)

**각 UseCase는 하나의 비즈니스 작업만 담당**합니다.

```dart
// ✅ GOOD: Single responsibility
class SignInWithEmailUseCase {
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  });
}

class SignOutUseCase {
  Future<Either<AuthFailure, void>> execute();
}

// ❌ BAD: Multiple responsibilities
class AuthUseCase {
  Future<Either<AuthFailure, AuthUser>> signIn(...);
  Future<Either<AuthFailure, void>> signOut();
  Future<Either<AuthFailure, AuthUser>> signUp(...);
  // Too many responsibilities!
}
```

### 6. Immutability (Freezed)

**Freezed로 불변 엔티티를 보장**합니다.

```dart
// ✅ Freezed immutable entity
@freezed
sealed class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    String? email,
    @Default(UserRole.user) UserRole role,
  }) = _AuthUser;
}

// ✅ copyWith for updates
final updatedUser = currentUser.copyWith(
  displayName: 'New Name',
  pointsA: currentUser.pointsA + 10,
);

// ❌ BAD: Mutable class
class AuthUser {
  String uid;
  String? email;

  void updateEmail(String newEmail) {
    email = newEmail;  // Mutation!
  }
}
```

### 7. Type Safety (Sealed Classes + Pattern Matching)

**Freezed sealed class로 exhaustive pattern matching을 강제**합니다.

```dart
// ✅ Sealed class guarantees exhaustive matching
@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.userNotFound() = UserNotFound;
  // ... 18 types total
}

// ✅ Compiler checks all cases
result.fold(
  (failure) {
    return failure.when(
      invalidEmail: () => print('Invalid email'),
      weakPassword: () => print('Weak password'),
      userNotFound: () => print('User not found'),
      // Missing case? Compile error!
    );
  },
  (user) => print('Success'),
);

// ❌ BAD: No exhaustive checking
if (failure is InvalidEmail) {
  print('Invalid email');
} else if (failure is WeakPassword) {
  print('Weak password');
}
// Missing cases? No compile error, runtime bugs!
```

---

## Freezed Usage Guide

### Installation

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1
```

### Code Generation Commands

```bash
# Generate code
flutter pub run build_runner build

# Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch
```

### Freezed Entity Pattern

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';  // Generated by freezed
part 'auth_user.g.dart';        // Generated by json_serializable

@freezed
sealed class AuthUser with _$AuthUser {
  const AuthUser._();  // Private constructor for custom methods

  const factory AuthUser({
    required String uid,
    String? email,
    @Default(false) bool isEmailVerified,
    @Default(UserRole.user) UserRole role,
  }) = _AuthUser;

  // JSON serialization
  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

  // Custom methods
  bool get isProfileComplete => email != null && isEmailVerified;
}
```

### Freezed Sealed Class Pattern (Failures)

```dart
@freezed
sealed class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  const factory AuthFailure.invalidEmail() = InvalidEmail;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.unexpected([String? message]) = Unexpected;

  @override
  String get message {
    return when(
      invalidEmail: () => '이메일 형식이 올바르지 않습니다',
      weakPassword: () => '비밀번호가 너무 약합니다',
      unexpected: (msg) => msg ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

### Generated Code Structure

```
lib/features/auth/domain/entities/
├── auth_user.dart           # Your code
├── auth_user.freezed.dart   # Generated by Freezed
└── auth_user.g.dart        # Generated by json_serializable

Generated files contain:
- copyWith() method
- == operator and hashCode
- toString() method
- JSON fromJson() and toJson()
- Pattern matching (when, map, maybeWhen, maybeMap)
```

### Freezed Best Practices

```dart
// ✅ DO: Use @Default for optional fields
@Default(false) bool isEmailVerified,
@Default([]) List<String> interests,
@Default(UserRole.user) UserRole role,

// ✅ DO: Use sealed class for exhaustive matching
@freezed
sealed class AuthFailure with _$AuthFailure {
  // Compiler guarantees all cases are handled
}

// ✅ DO: Use private constructor for custom methods
const AuthUser._();

bool get isProfileComplete => ...;

// ❌ DON'T: Mutate Freezed objects
final user = AuthUser(uid: '123');
user.email = 'new@email.com';  // Compile error!

// ✅ DO: Use copyWith for updates
final updatedUser = user.copyWith(email: 'new@email.com');

// ❌ DON'T: Add mutable fields
@freezed
class AuthUser with _$AuthUser {
  List<String> interests = [];  // Compile error!
}
```

---

## Best Practices

### Entity Design

#### ✅ DO

```dart
// ✅ Use Freezed for immutability
@freezed
sealed class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    String? email,
  }) = _AuthUser;
}

// ✅ Add computed properties
bool get isProfileComplete => email != null && displayName != null;
int get totalPoints => pointsA + pointsQ;

// ✅ Use @Default for optional fields
@Default(false) bool isEmailVerified,
@Default([]) List<String> interests,

// ✅ Use custom JSON converters for complex types
@UserRoleConverter()
@Default(UserRole.user)
UserRole role,
```

#### ❌ DON'T

```dart
// ❌ Mutable class
class AuthUser {
  String uid;
  String? email;
}

// ❌ Business logic in getters
bool get isAdmin {
  // Complex business logic
  final user = await fetchUserFromFirebase();
  return user.role == 'admin';
}

// ❌ External dependencies
import 'package:firebase_auth/firebase_auth.dart';  // NO!

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required User firebaseUser,  // External dependency!
  }) = _AuthUser;
}
```

---

### Repository Design

#### ✅ DO

```dart
// ✅ Abstract interface in Domain
abstract class IAuthRepository {
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  );
}

// ✅ Simple method signatures
Future<AuthUser?> getCurrentUser();
bool get isSignedIn;
Stream<AuthUser?> get authStateChanges;

// ✅ Return Either for operations that can fail
Future<Either<AuthFailure, AuthUser>> signIn(...);

// ✅ Return nullable for queries
Future<AuthUser?> getCurrentUser();
```

#### ❌ DON'T

```dart
// ❌ Concrete implementation in Domain
class AuthRepository {
  final FirebaseAuth _firebaseAuth;  // Implementation detail!
}

// ❌ Throw exceptions
Future<AuthUser> signIn(String email, String password) async {
  throw AuthException('Failed');  // No type safety!
}

// ❌ Return bool for complex operations
Future<bool> signIn(String email, String password);  // Lost error info!
```

---

### UseCase Design

#### ✅ DO

```dart
// ✅ Single responsibility
class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    // 1. Validate input
    if (!_isValidEmail(email)) {
      return left(const AuthFailure.invalidEmail());
    }

    // 2. Call repository
    return await _repository.signInWithEmailAndPassword(email, password);
  }
}

// ✅ Input validation in UseCase
bool _isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
}

// ✅ Handle all error cases
try {
  return await _repository.signIn(email, password);
} on AuthFailure catch (e) {
  return left(e);
} catch (e) {
  return left(AuthFailure.unexpected(e.toString()));
}
```

#### ❌ DON'T

```dart
// ❌ Multiple responsibilities
class AuthUseCase {
  Future<AuthUser> signIn(...);
  Future<void> signOut();
  Future<AuthUser> signUp(...);
  Future<void> resetPassword(...);
  // Too many responsibilities!
}

// ❌ No input validation
Future<Either<AuthFailure, AuthUser>> execute({
  required String email,
  required String password,
}) async {
  // Directly call repository without validation
  return await _repository.signIn(email, password);
}

// ❌ Business logic in Repository
class AuthRepository {
  Future<Either<AuthFailure, AuthUser>> signIn(email, password) {
    // Validation should be in UseCase!
    if (!_isValidEmail(email)) {
      return left(const AuthFailure.invalidEmail());
    }
  }
}
```

---

### Error Handling

#### ✅ DO

```dart
// ✅ Use Either pattern
Future<Either<AuthFailure, AuthUser>> signIn(...) async {
  try {
    final user = await _repository.signIn(email, password);
    return right(user);
  } on AuthFailure catch (e) {
    return left(e);
  } catch (e) {
    return left(AuthFailure.unexpected(e.toString()));
  }
}

// ✅ Pattern matching in UI
result.fold(
  (failure) {
    return failure.when(
      invalidEmail: () => showSnackBar('Invalid email'),
      weakPassword: () => showSnackBar('Weak password'),
      // ... handle all cases
    );
  },
  (user) => navigateToHome(user),
);

// ✅ User-friendly error messages
@override
String get message {
  return when(
    invalidEmail: () => '이메일 형식이 올바르지 않습니다',
    weakPassword: () => '비밀번호가 너무 약합니다',
    // ...
  );
}
```

#### ❌ DON'T

```dart
// ❌ Throw exceptions
Future<AuthUser> signIn(...) async {
  if (!_isValidEmail(email)) {
    throw Exception('Invalid email');  // No type safety!
  }
}

// ❌ Vague error messages
@override
String get message => 'Error occurred';  // Not helpful!

// ❌ Ignore errors
try {
  await signIn(email, password);
} catch (e) {
  // Do nothing!
}
```

---

## Summary

### Auth Domain Layer Key Highlights

| 항목 | 내용 |
|-----|------|
| **Entity** | 1개 (AuthUser) - 30+ 필드, rich business logic |
| **Enum** | 1개 (UserRole) - admin/tester/user with permissions |
| **Failure** | 18개 타입 - 6 Email/Password, 3 Account State, 3 Operation, 3 Phone, 3 Network |
| **Repository** | 1개 인터페이스 - 14개 메서드 (3 User State, 5 Sign In, 1 Sign Up, 1 Sign Out, 4 Account) - **100% Either 패턴** |
| **UseCases** | 10개 - Sign In (4), Sign Up (1), Sign Out (1), Password (1), Email Verification (1), Account (1), Get User (1) - **fold() 패턴 적용** |
| **Architecture** | Firebase-Centric Clean Architecture v4.0 - No Contract/Port/Adapter - **Voting Feature와 100% 일관성** |
| **Code Generation** | Freezed + json_serializable - Immutability, JSON, Pattern Matching |
| **Error Handling** | Either pattern - Type-safe error handling with exhaustive matching - **11개 Firebase 에러 매핑** |
| **Code Reduction** | UseCase 평균 **15-20% 코드 감소** (try-catch 제거, fold() 패턴 적용) |

### Clean Architecture Benefits

- **Domain Independence**: 순수 Dart, 외부 의존성 0
- **Testability**: Repository를 Mock하여 100% 격리 테스트 가능
- **Type Safety**: Freezed sealed class로 컴파일 타임 안전성 보장
- **Maintainability**: 단일 책임 원칙으로 명확한 코드 구조
- **Scalability**: UseCase 패턴으로 비즈니스 로직 확장 용이
- **Firebase Integration**: 직접 SDK 사용으로 모든 기능 100% 활용

### Related Documentation

- **Data Layer**: [auth/data/README.md](../data/README.md) - Repository 구현체, UnifiedCacheService 통합, Firebase 직접 사용
- **Presentation Layer**: [auth/presentation/README.md](../presentation/README.md) - Provider, Widget, UI
- **DI Module**: [auth/di/auth_di_module.dart](../di/auth_di_module.dart) - Dependency Injection 설정
- **Migration Plan**: [/specs/001-users-g-black/plan.md](/specs/001-users-g-black/plan.md) - Auth Feature 마이그레이션 계획
- **Test Quickstart**: [/specs/001-users-g-black/quickstart.md](/specs/001-users-g-black/quickstart.md) - 격리 테스트 전략

---

**마지막 업데이트**: 2025-01-20
**작성자**: Claude Code
**버전**: v1.0.0
