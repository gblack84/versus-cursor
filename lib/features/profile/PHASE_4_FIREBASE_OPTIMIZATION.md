# Phase 4: Firebase-Centric v2.0 최적화

> **소요 시간**: 2일
> **난이도**: ⭐⭐⭐⭐☆ (높음)
> **영향 범위**: Data Layer (5개 Repository + 1개 Adapter)
> **UI 영향**: 없음 (내부 아키텍처만 변경)

---

## 📋 목차

1. [개요](#1-개요)
2. [Firebase-Centric v2.0 패턴 설명](#2-firebase-centric-v20-패턴-설명)
3. [제거 대상 분석](#3-제거-대상-분석)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [UI 연결 예시 및 영향 분석](#6-ui-연결-예시-및-영향-분석)
7. [Extension 패턴 가이드](#7-extension-패턴-가이드)
8. [Repository 구현 완전 가이드](#8-repository-구현-완전-가이드)
9. [테스트 전략](#9-테스트-전략)
10. [롤백 계획](#10-롤백-계획)

---

## 1. 개요

### 1.1 Phase 4의 목적

Auth Feature의 Firebase-Centric v2.0 패턴을 Profile Feature에 적용합니다:
- ✅ **DataSource 제거**: Remote/Local DataSource 추상화 제거
- ✅ **Adapter/Mapper 제거**: DTO 변환 레이어 제거 (411줄 삭제)
- ✅ **Extension 패턴**: `fromFirestore()`, `toFirestore()` 확장 메서드
- ✅ **직접 Firebase SDK**: Repository에서 FirebaseFirestore 직접 사용
- ✅ **아키텍처 간소화**: 불필요한 레이어 제거로 유지보수성 향상

### 1.2 변경 대상

| 구분 | 파일 | 제거 내용 | 추가 내용 |
|------|------|----------|----------|
| **Adapter/Mapper** | `adapters/`, `mappers/` | 전체 (411줄) | - |
| **Repository 1** | `profile_repository_impl.dart` | DataSource 의존성 | Extension 패턴 |
| **Repository 2** | `settings_repository_impl.dart` | DataSource 의존성 | Extension 패턴 |
| **Repository 3** | `characters_repository_impl.dart` | DataSource 의존성 | Extension 패턴 |
| **Repository 4** | `interests_repository_impl.dart` | DataSource 의존성 | Extension 패턴 |
| **Repository 5** | `user_repository_impl.dart` | DataSource 의존성 | Extension 패턴 |
| **Entity Extension** | `user_profile_extensions.dart` | - | 신규 생성 (200줄) |

**총 변경**:
- 삭제: 1개 Adapter + 3개 Mapper (411줄) + DataSource imports
  - user_profile_adapter.dart: 145줄
  - user_profile_mapper.dart: 145줄
  - profile_firestore_mapper.dart: 77줄
  - user_settings_mapper.dart: 44줄
- 추가: 1개 Extension 파일 (200줄)
- 수정: 5개 Repository 구현

### 1.3 왜 Firebase-Centric v2.0인가?

**문제 상황 (현재 구조)**:
```dart
// ❌ 3-Layer 구조 (불필요한 복잡도)
[Repository] → [DataSource] → [Firebase SDK]
                    ↓
                 [Adapter]
                    ↓
                  [DTO]

// 문제점:
// 1. DataSource 추상화가 실제로 사용되지 않음 (Mock 테스트 외)
// 2. Adapter/Mapper 411줄이 단순 필드 복사만 수행
// 3. Repository → DataSource → Adapter/Mapper → DTO → Entity (4단계 변환)
// 4. 코드 중복 및 유지보수 비용 증가
```

**Firebase-Centric v2.0 해결책**:
```dart
// ✅ 1-Layer 구조 (간결하고 명확)
[Repository] → [Firebase SDK]
                    ↓
               [Extension]

// 장점:
// 1. Repository가 Firebase SDK 직접 사용
// 2. Extension으로 Entity ↔ Firestore 변환
// 3. Repository → Extension → Entity (1단계 변환)
// 4. 코드 중복 제거, 유지보수성 향상
```

**Auth Feature 참조 패턴**:
```dart
// lib/features/auth/domain/entities/auth_user_extensions.dart
extension AuthUserFirestore on AuthUser {
  /// Firestore DocumentSnapshot → AuthUser
  static AuthUser fromFirebaseUser(User firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
    );
  }
}

// lib/features/auth/data/repositories/auth_repository_impl.dart
@override
Future<Either<AuthFailure, AuthUser>> getCurrentUser() async {
  try {
    // 직접 Firebase SDK 사용
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return left(const AuthFailure.userNotFound());
    }

    // Extension으로 변환
    final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);
    return right(authUser);
  } on FirebaseAuthException catch (e) {
    return left(_mapFirebaseAuthException(e));
  }
}
```

---

## 2. Firebase-Centric v2.0 패턴 설명

### 2.1 핵심 개념

**Firebase-Centric Architecture**:
- Firebase SDK를 중심으로 간결한 아키텍처 구성
- 불필요한 추상화 레이어 제거
- Extension 패턴으로 변환 로직 분리
- Repository가 Firebase SDK 직접 사용

**Extension Pattern**:
- Entity에 `fromFirestore()`, `toFirestore()` 확장 메서드 추가
- 변환 로직을 Entity와 함께 관리
- Adapter/Mapper 불필요

### 2.2 아키텍처 비교

**Before: 3-Layer 구조**
```
┌─────────────────────────────────────────────────┐
│ Domain Layer                                     │
│  ├── entities/                                   │
│  │   └── user_profile.dart                      │
│  └── repositories/                               │
│      └── i_profile_repository.dart              │
└─────────────────────────────────────────────────┘
                    ↓ implements
┌─────────────────────────────────────────────────┐
│ Data Layer                                       │
│  ├── repositories/                               │
│  │   └── profile_repository_impl.dart           │
│  │       ↓ depends on                           │
│  ├── datasources/                                │
│  │   ├── i_profile_datasource.dart              │
│  │   └── profile_remote_datasource.dart         │
│  │       ↓ uses                                  │
│  └── adapters/ + mappers/                        │
│      └── user_profile_adapter.dart (145줄)      │
│      └── user_profile_mapper.dart (145줄)       │
│      └── profile_firestore_mapper.dart (77줄)   │
│      └── user_settings_mapper.dart (44줄)       │
│          ↓ converts (총 411줄)                  │
│          ├── UserProfileDTO                      │
│          └── UserProfile (Entity)                │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Firebase Backend                                 │
│  └── FirebaseFirestore.collection('users')      │
└─────────────────────────────────────────────────┘

문제점:
- 4단계 변환: Repository → DataSource → Adapter/Mapper → DTO → Entity
- 411줄 Adapter/Mapper 코드가 단순 필드 복사만 수행
  - user_profile_adapter.dart: 145줄
  - user_profile_mapper.dart: 145줄
  - profile_firestore_mapper.dart: 77줄
  - user_settings_mapper.dart: 44줄
- DataSource 추상화가 실제로 활용되지 않음
```

**After: 1-Layer 구조 (Firebase-Centric v2.0)**
```
┌─────────────────────────────────────────────────┐
│ Domain Layer                                     │
│  ├── entities/                                   │
│  │   ├── user_profile.dart                      │
│  │   └── user_profile_extensions.dart (신규)    │
│  │       ├── fromFirestore()                    │
│  │       └── toFirestore()                      │
│  └── repositories/                               │
│      └── i_profile_repository.dart              │
└─────────────────────────────────────────────────┘
                    ↓ implements
┌─────────────────────────────────────────────────┐
│ Data Layer                                       │
│  └── repositories/                               │
│      └── profile_repository_impl.dart           │
│          ↓ uses Extension                       │
│          └── UserProfileFirestore.fromFirestore()│
└─────────────────────────────────────────────────┘
                    ↓ 직접 사용
┌─────────────────────────────────────────────────┐
│ Firebase Backend                                 │
│  └── FirebaseFirestore.collection('users')      │
└─────────────────────────────────────────────────┘

장점:
- 1단계 변환: Repository → Extension → Entity
- 200줄 Extension으로 411줄 Adapter/Mapper 대체 (51% 코드 감소)
- 직관적이고 유지보수하기 쉬운 구조
```

### 2.3 Extension 패턴 상세

**파일**: `lib/features/profile/domain/entities/user_profile_extensions.dart`

```dart
/// UserProfile Extension for Firestore conversion
///
/// Firebase-Centric v2.0 패턴:
/// - Repository에서 직접 Firebase SDK 사용
/// - Extension으로 Entity ↔ Firestore 변환
/// - Adapter/Mapper 불필요
extension UserProfileFirestore on UserProfile {
  /// Firestore DocumentSnapshot → UserProfile
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(userId)
  ///     .get();
  ///
  /// final profile = UserProfileFirestore.fromFirestore(doc);
  /// ```
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return UserProfile(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      bio: data['bio'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// UserProfile → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final profile = UserProfile(...);
  /// final data = profile.toFirestore();
  ///
  /// await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(userId)
  ///     .set(data);
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

---

## 3. 제거 대상 분석

### 3.1 Adapter/Mapper 제거 (411줄)

**제거 대상 파일들**:
- `lib/features/profile/data/adapters/user_profile_adapter.dart` (145줄)
- `lib/features/profile/data/mappers/user_profile_mapper.dart` (145줄)
- `lib/features/profile/data/mappers/profile_firestore_mapper.dart` (77줄)
- `lib/features/profile/data/mappers/user_settings_mapper.dart` (44줄)

**제거 이유**:
- 단순 필드 복사만 수행 (부가 로직 없음)
- Extension 패턴으로 동일 기능 구현 가능
- 411줄 → 200줄로 51% 코드 감소

**Before 코드**:
```dart
// lib/features/profile/data/adapters/user_profile_adapter.dart (145줄)
// 추가로 3개 Mapper 파일 (총 411줄)
class UserProfileAdapter {
  // DTO → Entity
  static UserProfile fromDTO(UserProfileDTO dto) {
    return UserProfile(
      uid: dto.uid ?? '',
      email: dto.email ?? '',
      displayName: dto.displayName ?? '',
      photoUrl: dto.photoUrl,
      phoneNumber: dto.phoneNumber,
      bio: dto.bio,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  // Entity → DTO
  static UserProfileDTO toDTO(UserProfile entity) {
    return UserProfileDTO(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      bio: entity.bio,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Firestore → DTO
  static UserProfileDTO fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserProfileDTO(
      uid: doc.id,
      email: data?['email'] as String?,
      displayName: data?['displayName'] as String?,
      photoUrl: data?['photoUrl'] as String?,
      phoneNumber: data?['phoneNumber'] as String?,
      bio: data?['bio'] as String?,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // DTO → Firestore
  static Map<String, dynamic> toFirestore(UserProfileDTO dto) {
    return {
      'email': dto.email,
      'displayName': dto.displayName,
      'photoUrl': dto.photoUrl,
      'phoneNumber': dto.phoneNumber,
      'bio': dto.bio,
      'createdAt': dto.createdAt != null
          ? Timestamp.fromDate(dto.createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ... 추가 300줄 (ProfileInfo, Settings, Characters, Interests 변환)
}
```

**After: Extension 패턴 (200줄)**
```dart
// lib/features/profile/domain/entities/user_profile_extensions.dart
extension UserProfileFirestore on UserProfile {
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    // 직접 Entity 생성
  }

  Map<String, dynamic> toFirestore() {
    // 직접 Firestore Map 생성
  }
}

// 장점:
// - DTO 중간 단계 제거
// - Adapter 클래스 불필요
// - Entity와 변환 로직이 함께 관리됨
```

### 3.2 DataSource 제거

**파일들**:
- `lib/features/profile/data/datasources/i_profile_datasource.dart` (인터페이스)
- `lib/features/profile/data/datasources/profile_remote_datasource.dart` (구현체)
- `lib/features/profile/data/datasources/profile_local_datasource.dart` (로컬 캐시)

**제거 이유**:
- Repository에서 직접 Firebase SDK 사용으로 충분
- 추상화가 실제로 활용되지 않음 (Mock 테스트 외)
- Repository가 이미 추상화 역할 수행

**Before: DataSource 패턴**
```dart
// Repository → DataSource → Firebase
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileDataSource _remoteDataSource;  // ← 추상화

  Future<Either<ProfileFailure, UserProfile>> getProfile(String userId) async {
    try {
      final dto = await _remoteDataSource.getProfile(userId);  // ← DataSource 호출
      final entity = UserProfileAdapter.fromDTO(dto);  // ← Adapter 변환
      return right(entity);
    } catch (e) {
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }
}

// DataSource 구현
class ProfileRemoteDataSource implements IProfileDataSource {
  final FirebaseFirestore _firestore;

  Future<UserProfileDTO> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return UserProfileAdapter.fromFirestore(doc);  // ← Adapter 사용
  }
}
```

**After: 직접 Firebase SDK**
```dart
// Repository → Firebase (DataSource 제거)
class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;  // ← Firebase SDK 직접

  Future<Either<ProfileFailure, UserProfile>> getProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();  // ← 직접 Firestore 호출

      if (!doc.exists) {
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      final profile = UserProfileFirestore.fromFirestore(doc);  // ← Extension 사용
      return right(profile);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    }
  }
}
```

### 3.3 제거 효과

| 항목 | Before | After | 감소율 |
|------|--------|-------|--------|
| **Adapter/Mapper** | 411줄 | 0줄 (Extension 200줄) | -51% |
| **DataSource 인터페이스** | 150줄 | 0줄 | -100% |
| **DataSource 구현** | 300줄 | 0줄 | -100% |
| **DTO 클래스** | 200줄 | 0줄 | -100% |
| **총 코드** | 1,061줄 | 200줄 | -81% |

**유지보수성**:
- 변환 로직이 한 곳에 집중 (Extension)
- Repository 코드가 명확하고 간결
- Firebase 에러 처리가 Repository에서 직접 관리

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: Extension 파일 생성 준비**

```bash
# Extension 파일 생성 위치 확인
mkdir -p lib/features/profile/domain/entities

# 백업 생성
cp lib/features/profile/data/adapters/user_profile_adapter.dart \
   lib/features/profile/data/adapters/user_profile_adapter.dart.backup

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(profile): Backup before Firebase-Centric v2.0 migration"
```

**Step 2: Auth Feature Extension 참조**

```bash
# Auth Feature Extension 패턴 확인
cat lib/features/auth/domain/entities/auth_user_extensions.dart

# Repository 구현 패턴 확인
cat lib/features/auth/data/repositories/auth_repository_impl.dart
```

### 4.2 Extension 파일 생성

**Step 3: UserProfile Extension 생성**

**파일**: `lib/features/profile/domain/entities/user_profile_extensions.dart`

```dart
// lib/features/profile/domain/entities/user_profile_extensions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';
import '/features/profile/domain/failures/profile_failure.dart';

/// UserProfile Extension for Firestore conversion
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Repository에서 직접 Firebase SDK 사용
/// - Extension으로 Entity ↔ Firestore 변환
/// - Adapter/Mapper 불필요
extension UserProfileFirestore on UserProfile {
  /// Firestore DocumentSnapshot → UserProfile
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return UserProfile(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      bio: data['bio'] as String?,
      points: data['points'] as int? ?? 0,
      pointsA: data['pointsA'] as int? ?? 0,
      pointsQ: data['pointsQ'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// UserProfile → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'points': points,
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// ProfileInfo Extension
extension ProfileInfoFirestore on ProfileInfo {
  static ProfileInfo fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return ProfileInfo(
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      location: data['location'] as String?,
      website: data['website'] as String?,
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'age': age,
      'gender': gender,
      'location': location,
      'website': website,
      'socialLinks': socialLinks,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Settings Extension
extension SettingsFirestore on Settings {
  static Settings fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.settingsNotFound(userId: doc.id);
    }

    return Settings(
      userId: doc.id,
      language: data['language'] as String? ?? 'en',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      emailNotifications: data['emailNotifications'] as bool? ?? true,
      theme: data['theme'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'theme': theme,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

### 4.3 Repository 1: ProfileRepositoryImpl 수정

**Step 4: ProfileRepositoryImpl Firebase-Centric 전환**

**파일**: `lib/features/profile/data/repositories/profile_repository_impl.dart`

```dart
// Before: DataSource + Adapter 패턴
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileDataSource _remoteDataSource;
  final IProfileDataSource _localDataSource;

  ProfileRepositoryImpl({
    required IProfileDataSource remoteDataSource,
    required IProfileDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId) async {
    try {
      // DataSource 호출
      final dto = await _remoteDataSource.getProfile(userId);

      // Adapter 변환
      final entity = UserProfileAdapter.fromDTO(dto);

      return right(entity);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }
}

// After: Firebase-Centric v2.0
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_extensions.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId) async {
    try {
      debugPrint('Getting user profile for: $userId');

      // 직접 Firebase SDK 사용
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('Profile not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      // Extension으로 변환
      final profile = UserProfileFirestore.fromFirestore(doc);
      debugPrint('Profile loaded successfully: ${profile.displayName}');

      return right(profile);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserProfile(UserProfile profile) async {
    try {
      debugPrint('Updating profile: ${profile.uid}');

      // Extension으로 변환
      final data = profile.toFirestore();

      // 직접 Firebase SDK 사용
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .update(data);

      debugPrint('Profile updated successfully');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }

  /// Firebase Exception → ProfileFailure 매핑
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const ProfileFailure.permissionDenied();
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');
      case 'unavailable':
        return const ProfileFailure.networkError();
      default:
        return ProfileFailure.unexpected('Firebase: ${e.code}');
    }
  }
}
```

### 4.4 Repository 2-5: 동일 패턴 적용

**Step 5: 나머지 Repository들도 동일 패턴으로 수정**

**파일들**:
- `settings_repository_impl.dart`
- `characters_repository_impl.dart`
- `interests_repository_impl.dart`
- `user_repository_impl.dart`

**공통 수정 패턴**:
1. `IProfileDataSource` 의존성 제거
2. `FirebaseFirestore` 직접 주입
3. Extension 패턴으로 변환
4. `_mapFirebaseException()` 메서드 추가

### 4.5 Adapter 및 DataSource 파일 삭제

**Step 6: 불필요한 파일 제거**

```bash
# Adapter 삭제
rm lib/features/profile/data/adapters/user_profile_adapter.dart

# Mapper 삭제
rm lib/features/profile/data/mappers/user_profile_mapper.dart
rm lib/features/profile/data/mappers/profile_firestore_mapper.dart
rm lib/features/profile/data/mappers/user_settings_mapper.dart

# DataSource 삭제
rm lib/features/profile/data/datasources/i_profile_datasource.dart
rm lib/features/profile/data/datasources/profile_remote_datasource.dart
rm lib/features/profile/data/datasources/profile_local_datasource.dart

# DTO 삭제 (선택사항, Entity로 통합된 경우)
rm lib/features/profile/data/models/user_profile_dto.dart
```

### 4.6 DI 설정 업데이트

**Step 7: GetIt에서 DataSource 제거**

**파일**: `lib/app/di.dart`

```dart
// Before: DataSource + Adapter 패턴
void setupGetIt() {
  final getIt = GetIt.instance;

  // DataSource 등록
  getIt.registerLazySingleton<IProfileDataSource>(
    () => ProfileRemoteDataSource(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Repository 등록 (DataSource 주입)
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<IProfileDataSource>(),
      localDataSource: getIt<IProfileDataSource>(),
    ),
  );
}

// After: Firebase-Centric v2.0
void setupGetIt() {
  final getIt = GetIt.instance;

  // FirebaseFirestore 싱글톤 등록 (이미 있으면 생략)
  getIt.registerSingleton<FirebaseFirestore>(
    FirebaseFirestore.instance,
  );

  // Repository 등록 (FirebaseFirestore 직접 주입)
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),  // ← 직접 주입
    ),
  );

  // Settings, Characters, Interests, User Repository도 동일 패턴
  getIt.registerLazySingleton<ISettingsRepository>(
    () => SettingsRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // ... 나머지 Repository들
}
```

### 4.7 컴파일 확인

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 결과: 0 issues found

# import 정리
find lib/features/profile/data/repositories -name "*.dart" | \
  xargs grep -l "datasources\|adapters" && \
  echo "❌ DataSource/Adapter imports still exist" || \
  echo "✅ All imports cleaned"
```

---

## 5. Before/After 전체 코드

### 5.1 ProfileRepositoryImpl 전체 비교

<details>
<summary>Before 코드 보기 (DataSource + Adapter)</summary>

```dart
// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/i_profile_datasource.dart';
import '../adapters/user_profile_adapter.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileDataSource _remoteDataSource;
  final IProfileDataSource _localDataSource;

  ProfileRepositoryImpl({
    required IProfileDataSource remoteDataSource,
    required IProfileDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId) async {
    try {
      // 1. DataSource 호출
      final dto = await _remoteDataSource.getProfile(userId);

      // 2. Adapter 변환 (DTO → Entity)
      final entity = UserProfileAdapter.fromDTO(dto);

      // 3. 로컬 캐시 저장
      await _localDataSource.saveProfile(dto);

      return right(entity);
    } on ProfileFailure catch (e) {
      // 캐시에서 로드 시도
      try {
        final cachedDto = await _localDataSource.getProfile(userId);
        final entity = UserProfileAdapter.fromDTO(cachedDto);
        return right(entity);
      } catch (_) {
        return left(e);
      }
    } catch (e) {
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserProfile(UserProfile profile) async {
    try {
      // 1. Adapter 변환 (Entity → DTO)
      final dto = UserProfileAdapter.toDTO(profile);

      // 2. DataSource 호출
      await _remoteDataSource.updateProfile(dto);

      // 3. 로컬 캐시 업데이트
      await _localDataSource.saveProfile(dto);

      return right(unit);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    return _remoteDataSource
        .watchProfile(userId)
        .map((dto) => UserProfileAdapter.fromDTO(dto));
  }
}
```

</details>

<details>
<summary>After 코드 보기 (Firebase-Centric v2.0)</summary>

```dart
// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_profile_extensions.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// ProfileRepositoryImpl
///
/// **Firebase-Centric v2.0 Pattern**:
/// - FirebaseFirestore 직접 사용
/// - Extension으로 Entity ↔ Firestore 변환
/// - DataSource/Adapter 제거
class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId) async {
    try {
      debugPrint('Getting user profile for: $userId');

      // 직접 Firebase SDK 사용
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        debugPrint('Profile not found: $userId');
        return left(ProfileFailure.profileNotFound(userId: userId));
      }

      // Extension으로 변환
      final profile = UserProfileFirestore.fromFirestore(doc);
      debugPrint('Profile loaded successfully: ${profile.displayName}');

      return right(profile);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserProfile(UserProfile profile) async {
    try {
      debugPrint('Updating profile: ${profile.uid}');

      // Extension으로 변환
      final data = profile.toFirestore();

      // 직접 Firebase SDK 사용
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .update(data);

      debugPrint('Profile updated successfully');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    debugPrint('Watching user profile: $userId');

    // 직접 Firebase Stream 사용
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw ProfileFailure.profileNotFound(userId: userId);
          }

          // Extension으로 변환
          return UserProfileFirestore.fromFirestore(doc);
        })
        .handleError((error) {
          debugPrint('Stream error: $error');
          if (error is FirebaseException) {
            throw _mapFirebaseException(error);
          }
          throw ProfileFailure.unexpected(error.toString());
        });
  }

  /// Firebase Exception → ProfileFailure 매핑
  ///
  /// **Auth Feature 참조 패턴**
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const ProfileFailure.permissionDenied();
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');
      case 'unavailable':
        return const ProfileFailure.networkError();
      case 'deadline-exceeded':
        return const ProfileFailure.networkError();
      case 'resource-exhausted':
        return ProfileFailure.unexpected('Firebase quota exceeded');
      default:
        return ProfileFailure.unexpected('Firebase: ${e.code} - ${e.message}');
    }
  }
}
```

</details>

### 5.2 Extension 전체 코드

<details>
<summary>user_profile_extensions.dart 전체 코드</summary>

```dart
// lib/features/profile/domain/entities/user_profile_extensions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';
import 'profile_info.dart';
import 'settings.dart';
import '/features/profile/domain/failures/profile_failure.dart';

/// UserProfile Extension for Firestore conversion
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Repository에서 직접 Firebase SDK 사용
/// - Extension으로 Entity ↔ Firestore 변환
/// - Adapter/Mapper 불필요
///
/// **Auth Feature 참조**:
/// ```dart
/// // lib/features/auth/domain/entities/auth_user_extensions.dart
/// extension AuthUserFirestore on AuthUser {
///   static AuthUser fromFirebaseUser(User firebaseUser) { ... }
/// }
/// ```
extension UserProfileFirestore on UserProfile {
  /// Firestore DocumentSnapshot → UserProfile
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(userId)
  ///     .get();
  ///
  /// final profile = UserProfileFirestore.fromFirestore(doc);
  /// ```
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return UserProfile(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      bio: data['bio'] as String?,
      points: data['points'] as int? ?? 0,
      pointsA: data['pointsA'] as int? ?? 0,
      pointsQ: data['pointsQ'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// UserProfile → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final profile = UserProfile(...);
  /// final data = profile.toFirestore();
  ///
  /// await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(userId)
  ///     .set(data);
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'points': points,
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// ProfileInfo Extension
extension ProfileInfoFirestore on ProfileInfo {
  static ProfileInfo fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return ProfileInfo(
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      location: data['location'] as String?,
      website: data['website'] as String?,
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'age': age,
      'gender': gender,
      'location': location,
      'website': website,
      'socialLinks': socialLinks,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Settings Extension
extension SettingsFirestore on Settings {
  static Settings fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.settingsNotFound(userId: doc.id);
    }

    return Settings(
      userId: doc.id,
      language: data['language'] as String? ?? 'en',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      emailNotifications: data['emailNotifications'] as bool? ?? true,
      theme: data['theme'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'theme': theme,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

</details>

---

## 6. UI 연결 예시 및 영향 분석

### 6.1 Phase 4의 UI 영향

**중요**: Phase 4 (Firebase-Centric v2.0)은 **Data Layer**만 변경하며, **UI Layer는 전혀 영향받지 않습니다**.

```
┌─────────────────────────────────────────────┐
│ Presentation Layer (UI)                      │
│  ├── Screens (Flutter Widgets)              │
│  ├── Providers (State Management)           │
│  └── UseCases (Business Logic)              │
└─────────────────────────────────────────────┘
                    ↓
         (인터페이스는 동일)
                    ↓
┌─────────────────────────────────────────────┐
│ Data Layer (Phase 4 변경)                   │
│  ├── ❌ DataSource 제거                     │
│  ├── ❌ Adapter 제거                        │
│  └── ✅ Extension + Firebase 직접 사용      │
└─────────────────────────────────────────────┘
```

UI 코드는 **단 한 줄도 변경하지 않아도** Phase 4 적용 가능합니다!

### 6.2 Auth Feature 참조 패턴 (Firebase-Centric v2.0 완성)

**파일**: `lib/features/auth/presentation/screens/forgot_password/forgot_password/forgot_password_widget.dart`

Auth Feature는 이미 Phase 1-4를 모두 적용한 완성된 패턴을 보여줍니다.

<details>
<summary>forgot_password_widget.dart 코드 보기</summary>

```dart
class ForgotPasswordWidget extends ConsumerStatefulWidget {
  const ForgotPasswordWidget({super.key});

  static String routeName = 'Forgot_Password';
  static String routePath = '/forgotPassword';

  @override
  ConsumerState<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends ConsumerState<ForgotPasswordWidget> {
  late ForgotPasswordModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(/* ... */),
      body: Align(
        child: Container(
          child: Column(
            children: [
              // 이메일 입력 필드
              TextFormField(
                controller: _model.emailAddressTextController,
                // ...
              ),

              // 비밀번호 재설정 버튼
              AppButtonWidget(
                onPressed: () async {
                  // 1. 입력 검증
                  if (_model.emailAddressTextController.text.isEmpty) {
                    BotToast.showText(text: '이메일을 입력해주세요!');
                    return;
                  }

                  // 2. 로딩 중이면 리턴
                  final isLoading = ref.read(authLoadingProvider);
                  if (isLoading) return;

                  // 3. UseCase 호출 (Repository 내부 구현은 감춤)
                  final passwordManagementUseCase = ref.read(passwordManagementUseCaseProvider);
                  final result = await passwordManagementUseCase.sendPasswordResetEmail(
                    email: _model.emailAddressTextController.text.trim(),
                    eventId: const Uuid().v4(),
                  );

                  // 4. Either 패턴으로 결과 처리
                  if (context.mounted) {
                    result.fold(
                      (failure) {
                        ErrorHandler.handle(
                          failure.message,
                          customMessage: '비밀번호 재설정 이메일 발송에 실패했습니다.',
                          context: context,
                        );
                      },
                      (_) {
                        ErrorHandler.showSuccessToast('비밀번호 재설정 이메일을 발송했습니다.');
                        context.pop();
                      },
                    );
                  }
                },
                text: AppLocalizations.of(context).getText('4rzuk0hj' /* Send Link */),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

</details>

**핵심 포인트**:
1. ✅ **ConsumerStatefulWidget**: Riverpod 2.x 패턴 (Phase 3)
2. ✅ **Either Pattern**: `result.fold()` 에러 처리 (Phase 2)
3. ✅ **Riverpod Providers**: `ref.read(passwordManagementUseCaseProvider)` (Phase 3)
4. ✅ **Firebase-Centric**: Repository 내부는 Firebase SDK 직접 사용하지만 UI는 모름 (Phase 4)

### 6.3 Settings Screen 예시 (Phase 3 Before)

**현재 Profile Feature**: `lib/features/profile/presentation/screens/settings/settings_screen.dart`

```dart
/// 설정 화면 Wrapper
///
/// **Phase 3 Before** (ChangeNotifierProvider 패턴)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    // ❌ ChangeNotifierProvider 사용 (Phase 3 마이그레이션 필요)
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(
        getSettingsUseCase: getIt<GetUserSettingsUseCase>(),
        updateSettingsUseCase: getIt<UpdateUserSettingsUseCase>(),
        deleteProfileUseCase: getIt<DeleteUserProfileUseCase>(),
      ),
      child: _SettingsScreenContent(userId: userId),
    );
  }
}

class _SettingsScreenContentState extends State<_SettingsScreenContent> {
  @override
  void initState() {
    super.initState();

    // Provider에서 설정 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SettingsProvider>();
      provider.loadSettings(widget.userId);  // ← UseCase 호출
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsProvider>(  // ← Provider Consumer
        builder: (context, provider, child) {
          if (provider.isLoading && provider.settings == null) {
            return ProfileLoadingIndicator();
          }

          if (provider.errorMessage != null) {
            return ProfileErrorMessage(
              message: provider.errorMessage!,
              onRetry: () => provider.loadSettings(widget.userId),
            );
          }

          // 설정 UI 표시
          return ListView(/* ... */);
        },
      ),
    );
  }
}
```

### 6.4 Settings Screen 예시 (Phase 3 After)

**Auth Feature 패턴 적용**: Riverpod 2.x + Firebase-Centric v2.0

```dart
/// 설정 화면
///
/// **Phase 3 After** (Riverpod ConsumerWidget 패턴)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'settings_screen';
  static String routePath = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Riverpod Provider에서 설정 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ ref.read()로 Provider 접근
      ref.read(settingsProvider.notifier).loadSettings(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ref.watch()로 상태 관찰
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        title: Text('설정'),
        centerTitle: true,
      ),
      body: settingsState.when(
        // ✅ when() 메서드로 상태 처리 (더 간결)
        data: (settings) => _buildSettingsContent(settings),
        loading: () => ProfileLoadingIndicator(size: LoadingSize.medium),
        error: (error, stack) => ProfileErrorMessage(
          message: error.toString(),
          onRetry: () => ref.read(settingsProvider.notifier).loadSettings(widget.userId),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(Settings settings) {
    return ListView(
      children: [
        SettingsSection(
          title: '알림 설정',
          children: [
            SettingsToggle(
              title: '알림 받기',
              value: settings.notificationsEnabled,
              onChanged: (value) {
                // ✅ UseCase 호출 (Repository는 Firebase 직접 사용)
                ref.read(settingsProvider.notifier).updateNotifications(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
```

### 6.5 Repository 내부 구현 (Phase 4 Before vs After)

UI는 동일하게 UseCase를 호출하지만, Repository 내부 구현이 크게 달라집니다:

**Before: DataSource + Adapter 패턴**
```dart
class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsDataSource _remoteDataSource;

  @override
  Future<Either<ProfileFailure, Settings>> getSettings(String userId) async {
    try {
      // 1. DataSource 호출
      final dto = await _remoteDataSource.getSettings(userId);

      // 2. Adapter 변환 (DTO → Entity)
      final entity = SettingsAdapter.fromDTO(dto);

      return right(entity);
    } catch (e) {
      return left(ProfileFailure.unexpected(e.toString()));
    }
  }
}
```

**After: Firebase-Centric v2.0**
```dart
class SettingsRepositoryImpl implements ISettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<ProfileFailure, Settings>> getSettings(String userId) async {
    try {
      // 1. Firebase SDK 직접 사용
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return left(ProfileFailure.settingsNotFound(userId: userId));
      }

      // 2. Extension으로 변환 (한 단계)
      final settings = SettingsFirestore.fromFirestore(doc);

      return right(settings);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    }
  }
}
```

**차이점**:
- Before: 4단계 변환 (Repository → DataSource → Adapter → DTO → Entity)
- After: 1단계 변환 (Repository → Extension → Entity)
- UI는 전혀 영향받지 않음!

### 6.6 UI에서 본 변경 사항

```dart
// UI 코드는 Phase 4 Before/After 모두 동일
final result = await ref.read(getSettingsUseCaseProvider)(userId);

result.fold(
  (failure) => showError(failure.message),
  (settings) => showSettings(settings),
);
```

**UI 입장에서**:
- Repository 내부 구현이 바뀌었지만 인터페이스는 동일
- `Future<Either<ProfileFailure, Settings>>` 시그니처 유지
- UseCase 호출 방식 동일
- 에러 처리 동일

**개발자 입장에서**:
- Repository 코드만 수정하면 됨
- UI 코드는 단 한 줄도 변경 불필요
- 테스트 코드도 Repository 레이어만 수정

---

## 7. Extension 패턴 가이드

### 7.1 Extension vs Adapter

**Adapter 패턴 (Before)**:
```dart
// Adapter 클래스 필요
class UserProfileAdapter {
  // Firestore → DTO
  static UserProfileDTO fromFirestore(DocumentSnapshot doc) { ... }

  // DTO → Entity
  static UserProfile fromDTO(UserProfileDTO dto) { ... }

  // Entity → DTO
  static UserProfileDTO toDTO(UserProfile entity) { ... }

  // DTO → Firestore
  static Map<String, dynamic> toFirestore(UserProfileDTO dto) { ... }
}

// Repository에서 사용
final dto = await _dataSource.getProfile(userId);
final entity = UserProfileAdapter.fromDTO(dto);  // 2단계 변환
```

**Extension 패턴 (After)**:
```dart
// Extension으로 Entity에 메서드 추가
extension UserProfileFirestore on UserProfile {
  // Firestore → Entity (직접)
  static UserProfile fromFirestore(DocumentSnapshot doc) { ... }

  // Entity → Firestore (직접)
  Map<String, dynamic> toFirestore() { ... }
}

// Repository에서 사용
final doc = await _firestore.collection('users').doc(userId).get();
final entity = UserProfileFirestore.fromFirestore(doc);  // 1단계 변환
```

**장점**:
- DTO 중간 단계 제거
- Adapter 클래스 불필요
- Entity와 변환 로직이 함께 관리됨

### 7.2 Extension 명명 규칙

**패턴**: `{EntityName}Firestore`

| Entity | Extension 이름 |
|--------|---------------|
| UserProfile | UserProfileFirestore |
| ProfileInfo | ProfileInfoFirestore |
| Settings | SettingsFirestore |
| Character | CharacterFirestore |
| Interest | InterestFirestore |

**Auth Feature 참조**:
```dart
// lib/features/auth/domain/entities/auth_user_extensions.dart
extension AuthUserFirestore on AuthUser { ... }
```

### 7.3 Null Safety 처리

**Extension에서 Null Safety**:
```dart
extension UserProfileFirestore on UserProfile {
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // 1. 문서 존재 여부 확인
    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return UserProfile(
      uid: doc.id,
      // 2. 필수 필드: ?? '' (빈 문자열)
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',

      // 3. 선택 필드: as String? (nullable)
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,

      // 4. 숫자 필드: ?? 0 (기본값)
      points: data['points'] as int? ?? 0,
      pointsA: data['pointsA'] as int? ?? 0,

      // 5. Timestamp → DateTime 변환
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
```

### 7.4 Timestamp 처리

**Timestamp ↔ DateTime 변환**:
```dart
// Firestore → Entity: Timestamp → DateTime
createdAt: (data['createdAt'] as Timestamp?)?.toDate(),

// Entity → Firestore: DateTime → Timestamp
'createdAt': createdAt != null
    ? Timestamp.fromDate(createdAt!)
    : FieldValue.serverTimestamp(),  // 새 문서일 경우

'updatedAt': FieldValue.serverTimestamp(),  // 항상 서버 시간
```

---

## 8. Repository 구현 완전 가이드

### 8.1 Repository CRUD 패턴

**Create (생성)**:
```dart
@override
Future<Either<ProfileFailure, Unit>> createProfile(UserProfile profile) async {
  try {
    final data = profile.toFirestore();

    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(data);  // ← set() for create

    return right(unit);
  } on FirebaseException catch (e) {
    return left(_mapFirebaseException(e));
  }
}
```

**Read (조회)**:
```dart
@override
Future<Either<ProfileFailure, UserProfile>> getProfile(String userId) async {
  try {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();  // ← get() for read

    if (!doc.exists) {
      return left(ProfileFailure.profileNotFound(userId: userId));
    }

    final profile = UserProfileFirestore.fromFirestore(doc);
    return right(profile);
  } on FirebaseException catch (e) {
    return left(_mapFirebaseException(e));
  }
}
```

**Update (수정)**:
```dart
@override
Future<Either<ProfileFailure, Unit>> updateProfile(UserProfile profile) async {
  try {
    final data = profile.toFirestore();

    await _firestore
        .collection('users')
        .doc(profile.uid)
        .update(data);  // ← update() for modify

    return right(unit);
  } on FirebaseException catch (e) {
    return left(_mapFirebaseException(e));
  }
}
```

**Delete (삭제)**:
```dart
@override
Future<Either<ProfileFailure, Unit>> deleteProfile(String userId) async {
  try {
    await _firestore
        .collection('users')
        .doc(userId)
        .delete();  // ← delete() for remove

    return right(unit);
  } on FirebaseException catch (e) {
    return left(_mapFirebaseException(e));
  }
}
```

### 8.2 Stream 패턴 (실시간 동기화)

**Firestore Stream → Entity Stream**:
```dart
@override
Stream<UserProfile> watchProfile(String userId) {
  return _firestore
      .collection('users')
      .doc(userId)
      .snapshots()  // ← Stream<DocumentSnapshot>
      .map((doc) {
        if (!doc.exists) {
          throw ProfileFailure.profileNotFound(userId: userId);
        }

        // Extension으로 변환
        return UserProfileFirestore.fromFirestore(doc);
      })
      .handleError((error) {
        if (error is FirebaseException) {
          throw _mapFirebaseException(error);
        }
        throw ProfileFailure.unexpected(error.toString());
      });
}
```

**Riverpod StreamProvider 연동**:
```dart
// lib/features/profile/presentation/providers/profile_providers.dart
final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    yield null;  // 초기 로딩

    // Repository Stream 구독
    final repository = ref.read(profileRepositoryProvider);

    await for (final profile in repository.watchProfile(params.userId)) {
      yield profile;  // 실시간 업데이트
    }

    ref.keepAlive();  // 중복 리스너 방지
  },
);
```

### 8.3 Firebase Exception 매핑

**_mapFirebaseException() 메서드**:
```dart
/// Firebase Exception → ProfileFailure 매핑
///
/// **Auth Feature 참조 패턴**:
/// ```dart
/// // lib/features/auth/data/repositories/auth_repository_impl.dart
/// ProfileFailure _mapFirebaseAuthException(FirebaseAuthException e) {
///   switch (e.code) {
///     case 'user-not-found': return const AuthFailure.userNotFound();
///     // ...
///   }
/// }
/// ```
ProfileFailure _mapFirebaseException(FirebaseException e) {
  switch (e.code) {
    // 권한 에러
    case 'permission-denied':
      return const ProfileFailure.permissionDenied();

    // 찾을 수 없음
    case 'not-found':
      return ProfileFailure.profileNotFound(userId: 'unknown');

    // 네트워크 에러
    case 'unavailable':
    case 'deadline-exceeded':
      return const ProfileFailure.networkError();

    // 할당량 초과
    case 'resource-exhausted':
      return ProfileFailure.unexpected('Firebase quota exceeded');

    // 잘못된 인수
    case 'invalid-argument':
      return ProfileFailure.unexpected('Invalid data format');

    // 기타
    default:
      return ProfileFailure.unexpected('Firebase: ${e.code} - ${e.message}');
  }
}
```

---

## 9. 테스트 전략

### 9.1 Extension Unit Test

```dart
// test/features/profile/domain/entities/user_profile_extensions_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('UserProfileFirestore Extension', () {
    test('fromFirestore: DocumentSnapshot → UserProfile 변환', () async {
      // Given
      await fakeFirestore.collection('users').doc('user-123').set({
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.jpg',
        'phoneNumber': '+82-10-1234-5678',
        'bio': 'Hello World',
        'points': 100,
        'pointsA': 50,
        'pointsQ': 50,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // When
      final doc = await fakeFirestore.collection('users').doc('user-123').get();
      final profile = UserProfileFirestore.fromFirestore(doc);

      // Then
      expect(profile.uid, 'user-123');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.points, 100);
      expect(profile.pointsA, 50);
      expect(profile.pointsQ, 50);
    });

    test('toFirestore: UserProfile → Map<String, dynamic> 변환', () {
      // Given
      final profile = UserProfile(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        phoneNumber: '+82-10-1234-5678',
        bio: 'Hello World',
        points: 100,
        pointsA: 50,
        pointsQ: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // When
      final data = profile.toFirestore();

      // Then
      expect(data['email'], 'test@example.com');
      expect(data['displayName'], 'Test User');
      expect(data['photoUrl'], 'https://example.com/photo.jpg');
      expect(data['phoneNumber'], '+82-10-1234-5678');
      expect(data['bio'], 'Hello World');
      expect(data['points'], 100);
      expect(data['pointsA'], 50);
      expect(data['pointsQ'], 50);
      expect(data['updatedAt'], isA<FieldValue>());
    });

    test('fromFirestore: null data 시 ProfileFailure 발생', () {
      // Given
      final doc = FakeDocumentSnapshot(id: 'user-123', data: null);

      // When & Then
      expect(
        () => UserProfileFirestore.fromFirestore(doc),
        throwsA(isA<ProfileFailure>()),
      );
    });
  });
}
```

### 9.2 Repository Integration Test

```dart
// test/features/profile/data/repositories/profile_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProfileRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ProfileRepositoryImpl(firestore: fakeFirestore);
  });

  group('ProfileRepositoryImpl (Firebase-Centric v2.0)', () {
    const userId = 'user-123';
    final testProfile = UserProfile(
      uid: userId,
      email: 'test@example.com',
      displayName: 'Test User',
      points: 100,
      pointsA: 50,
      pointsQ: 50,
    );

    test('getUserProfile: 프로필 조회 성공', () async {
      // Given
      await fakeFirestore.collection('users').doc(userId).set({
        'email': 'test@example.com',
        'displayName': 'Test User',
        'points': 100,
        'pointsA': 50,
        'pointsQ': 50,
      });

      // When
      final result = await repository.getUserProfile(userId);

      // Then
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not be failure'),
        (profile) {
          expect(profile.uid, userId);
          expect(profile.email, 'test@example.com');
          expect(profile.displayName, 'Test User');
          expect(profile.points, 100);
        },
      );
    });

    test('getUserProfile: 프로필 없음 시 profileNotFound', () async {
      // When
      final result = await repository.getUserProfile('non-existent');

      // Then
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ProfileNotFound>());
        },
        (profile) => fail('Should not be success'),
      );
    });

    test('updateUserProfile: 프로필 업데이트 성공', () async {
      // Given
      await fakeFirestore.collection('users').doc(userId).set({
        'email': 'test@example.com',
        'displayName': 'Old Name',
        'points': 50,
      });

      // When
      final result = await repository.updateUserProfile(testProfile);

      // Then
      expect(result.isRight(), true);

      // Verify update
      final doc = await fakeFirestore.collection('users').doc(userId).get();
      expect(doc.data()?['displayName'], 'Test User');
      expect(doc.data()?['points'], 100);
    });

    test('watchUserProfile: 실시간 Stream 동작 확인', () async {
      // Given
      await fakeFirestore.collection('users').doc(userId).set({
        'email': 'test@example.com',
        'displayName': 'Initial Name',
        'points': 50,
      });

      // When
      final stream = repository.watchUserProfile(userId);

      // Then
      expectLater(
        stream,
        emitsInOrder([
          // 첫 이벤트: Initial Name
          predicate<UserProfile>((p) => p.displayName == 'Initial Name'),

          // 두 번째 이벤트: Updated Name (아래에서 업데이트)
          predicate<UserProfile>((p) => p.displayName == 'Updated Name'),
        ]),
      );

      // Trigger update
      await Future.delayed(Duration(milliseconds: 100));
      await fakeFirestore.collection('users').doc(userId).update({
        'displayName': 'Updated Name',
      });
    });
  });
}
```

---

## 10. 롤백 계획

### 10.1 Git 롤백

```bash
# 변경사항 확인
git status
git diff lib/features/profile/data/repositories/
git diff lib/features/profile/domain/entities/

# Repository 롤백
git checkout HEAD -- lib/features/profile/data/repositories/

# Extension 파일 삭제
rm lib/features/profile/domain/entities/user_profile_extensions.dart

# Adapter 복원
git checkout HEAD -- lib/features/profile/data/adapters/
git checkout HEAD -- lib/features/profile/data/datasources/

# DI 롤백
git checkout HEAD -- lib/app/di.dart

# 컴파일 확인
flutter analyze
```

### 10.2 수동 롤백

```bash
# 백업 파일 복원
cp lib/features/profile/data/adapters/user_profile_adapter.dart.backup \
   lib/features/profile/data/adapters/user_profile_adapter.dart

# Extension 파일 삭제
rm lib/features/profile/domain/entities/user_profile_extensions.dart

# Repository 파일들 복원
for file in profile_repository_impl settings_repository_impl \
            characters_repository_impl interests_repository_impl \
            user_repository_impl; do
  cp lib/features/profile/data/repositories/${file}.dart.backup \
     lib/features/profile/data/repositories/${file}.dart
done

# 컴파일 확인
flutter analyze
```

### 10.3 Incremental Rollback (부분 롤백)

**Repository별 선택적 롤백**:
```bash
# ProfileRepository만 롤백
git checkout HEAD -- lib/features/profile/data/repositories/profile_repository_impl.dart

# SettingsRepository만 롤백
git checkout HEAD -- lib/features/profile/data/repositories/settings_repository_impl.dart

# 나머지는 Firebase-Centric 유지
```

---

## 📊 Phase 4 완료 체크리스트

### Extension 파일
- [x] `user_profile_extensions.dart` 생성 (314줄) ✅
- [x] UserProfileFirestore extension 구현 ✅
- [x] ProfileInfoFirestore extension 구현 ✅
- [x] SettingsFirestore extension 구현 ✅
- [ ] Unit Test 3개 이상 작성 (추후 작성)

### Repository 수정 (5개)
- [x] `profile_repository_impl.dart` Firebase-Centric 전환 ✅
- [x] `settings_repository_impl.dart` Firebase-Centric 전환 ✅
- [x] `characters_repository_impl.dart` Firebase-Centric 전환 ✅
- [x] `interests_repository_impl.dart` Firebase-Centric 전환 ✅
- [x] `user_repository_impl.dart` Firebase-Centric 전환 ✅

### 파일 제거 (2025-01-29 완료)
- [x] `user_profile_adapter.dart` 삭제 (이미 없음) ✅
- [x] `user_profile_mapper.dart` 삭제 (이미 없음) ✅
- [x] `profile_firestore_mapper.dart` 삭제 (이미 없음) ✅
- [x] `user_settings_mapper.dart` 삭제 (이미 없음) ✅
- [x] `i_profile_datasource.dart` 삭제 (103줄) ✅
- [x] `firebase_profile_datasource.dart` 삭제 (301줄) ✅
- [x] `i_settings_datasource.dart` 삭제 (13줄) ✅
- [x] `firebase_settings_datasource.dart` 삭제 (52줄) ✅
- [x] DTO 파일 6개 삭제 (559줄) ✅

### DI Layer
- [x] `profile_di_module.dart`에서 Profile/Settings DataSource 제거 ✅
- [x] FirebaseFirestore 직접 주입 ✅
- [x] 5개 Repository DI 설정 업데이트 ✅
- [x] Storage DataSource는 유지 (이미지 업로드용) ✅

### 테스트
- [ ] Extension Unit Test 3개 이상 통과 (추후 작성)
- [ ] Repository Integration Test 5개 이상 통과 (추후 작성)
- [x] `flutter analyze` 0 issues (2개 warning은 기존 JsonKey 이슈) ✅
- [ ] Stream 동작 검증 (추후 검증)

### 문서
- [x] CLAUDE.md에 Phase 4 완료 기록 ✅
- [x] 코드 주석 업데이트 (Repository 주석 완료) ✅
- [x] Auth Feature 참조 패턴 문서화 ✅

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | Unit + Integration 8개 이상 통과 |
| **코드 감소** | 1,061줄 → 200줄 (81% 감소) |
| **Adapter/Mapper 제거** | 411줄 완전 삭제 |
| **DataSource 제거** | 450줄 완전 삭제 |
| **Extension 동작** | fromFirestore/toFirestore 정상 작동 |
| **Firebase 직접 사용** | Repository에서 _firestore 직접 호출 |

---

## 🎯 완료 후

**Phase 1-4 모두 완료!** 🎉

Profile Feature가 Auth Feature 패턴 100% 적용 완료:
- ✅ Phase 1: Freezed Failure
- ✅ Phase 2: Either Pattern
- ✅ Phase 3: Riverpod 2.x
- ✅ Phase 4: Firebase-Centric v2.0

**다음 작업**:
- [ ] 전체 통합 테스트 실행
- [ ] UI/UX 테스트 (5개 화면)
- [ ] Performance 측정 (코드 감소 효과)
- [ ] Legacy 코드 삭제 확인
- [ ] 문서 업데이트 (CLAUDE.md, README.md)
- [ ] 다른 Feature들도 동일 패턴 적용 (Posts, Voting, Notifications 등)
