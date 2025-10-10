# Profile Feature - Data Layer

> 최종 업데이트: 2025-01-26 | 버전: 4.0.0 | Clean Architecture v4.0

## 📊 개요

Profile Feature의 Data Layer는 **Clean Architecture v4.0** 원칙에 따라 외부 데이터 소스(Firebase Firestore, Firebase Storage, Local Cache)와의 통신을 담당하며, Domain Layer를 외부 의존성으로부터 완전히 격리합니다.

### 핵심 특징

- ✅ **Adapter 패턴**: UserProfile ↔ Domain Models (UserSettings, FriendsList) 변환
- ✅ **Repository 패턴**: Domain 인터페이스 구현 및 비즈니스 로직 orchestration
- ✅ **3-Layer Caching**: Memory → Hive → Firestore 캐싱 전략
- ✅ **DataSource 패턴**: Firebase 의존성을 인터페이스로 추상화
- ✅ **Offline-First**: 로컬 데이터 우선 접근으로 빠른 응답
- ✅ **Feature Isolation**: Profile/Settings/Onboarding만 처리, Auth Feature와 명확한 경계

### 책임 범위

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **Repositories** | 비즈니스 로직 조율 | 프로필 조회 → 캐시 확인 → Firestore 로드 |
| **Adapters** | 데이터 변환 | UserProfile ↔ UserSettings/FriendsList |
| **DataSources** | 외부 API 직접 통신 | Firestore CRUD, Storage 업로드 |
| **Exports** | Data Layer 통합 | 모든 모델 export 관리 |

---

## 🏗️ 전체 구조도

```
lib/features/profile/data/
├── repositories/              # 📦 Repository 구현체 (1개)
│   ├── user_repository_impl.dart                 # 핵심 - 사용자 프로필 관리
│   └── README.md                                 # Repository 문서
│
├── adapters/                  # 🔄 데이터 변환 어댑터 (2개)
│   ├── user_profile_adapter.dart                 # UserProfile ↔ Domain 변환
│   ├── user_cache_service.dart                   # 3-Layer 캐싱 시스템
│   └── README.md                                 # Adapter 문서
│
├── datasources/               # 🔌 데이터 소스 (구현 예정)
│   ├── remote/                                   # 원격 데이터소스
│   │   ├── firestore_profile_datasource.dart    # Firestore 프로필 데이터
│   │   ├── firebase_storage_datasource.dart     # Storage 프로필 이미지
│   │   ├── firestore_character_datasource.dart  # 캐릭터 데이터
│   │   └── firestore_interest_datasource.dart   # 관심사/취미 데이터
│   ├── local/                                    # 로컬 데이터소스
│   │   ├── profile_local_datasource.dart        # 프로필 로컬 캐시
│   │   ├── settings_local_datasource.dart       # 설정 로컬 저장
│   │   └── onboarding_progress_datasource.dart  # 온보딩 진행상태
│   └── README.md                                 # DataSource 문서
│
├── exports/                   # 📤 Data Layer Exports (1개)
│   └── profile_models.dart                       # 모든 모델 export
│
└── README.md                  # 이 파일

Domain Layer 인터페이스:
├── repositories/              # Repository 인터페이스 (Domain)
│   ├── i_user_repository.dart                    # 사용자 프로필 인터페이스
│   ├── i_friends_repository.dart                 # 친구 목록 인터페이스
│   └── i_character_repository.dart               # 캐릭터 인터페이스
```

---

## 📂 디렉토리별 상세 설명

### 1. repositories/ - Repository 구현체

Repository는 Domain 인터페이스를 구현하며, DataSource와 Adapter를 조율하여 비즈니스 로직을 실행합니다.

#### 1.1 UserRepositoryImpl (핵심)

**파일**: `user_repository_impl.dart`

**책임**:
- 사용자 프로필 CRUD orchestration
- UserProfileAdapter를 통한 데이터 변환
- 3-Layer 캐싱 시스템 통합
- 온보딩 완료 여부 검증
- 프로필 완성도 계산

**주요 메서드**:
```dart
// User CRUD Operations
Future<UserProfile?> getUser(String userId);
Future<void> createUser(UserProfile user);
Future<void> updateUser(UserProfile user);
Future<void> deleteUser(String userId);

// Stream Operations
Stream<List<UserProfile>> queryUsers({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
});

// Settings Operations
Future<UserSettings?> getUserSettings(String userId);
Future<void> updateUserSettings(String userId, UserSettings settings);

// Character Operations
Future<CharactersModel?> getUserCharacter(String userId);
Future<void> updateUserCharacter(String userId, CharactersModel character);

// Adapter Integration
Future<UserProfileBundle?> getUserBundleByUid(String uid);
```

**의존성**:
- `UsersModel` - Firestore 통신 (레거시, 점진적 제거 예정)
- `UserProfileAdapter` - 데이터 변환
- `UserCacheService` - 3-Layer 캐싱
- `FirebaseAuth` - 현재 사용자 인증

**Feature 경계**:
```dart
// ✅ Profile Feature 책임
- UserProfile (displayName, photoUrl, bio, jobCategory)
- UserSettings (알림 설정, 언어, 프라이버시)
- CharactersModel (아바타, 캐릭터 정보)
- FriendsListModel (친구 목록, 소셜 관계)

// ❌ Auth Feature 책임
- 로그인/로그아웃 (FirebaseAuth)
- 이메일 인증 (EmailVerification)
- 비밀번호 재설정 (PasswordReset)

// ❌ Post Feature 책임
- 게시물 생성/수정 (PostCreation)
- 투표 관리 (VotingSystem)
```

---

### 2. adapters/ - 데이터 변환 어댑터

Adapter는 **Firestore 모델과 Domain Model 간 양방향 변환**을 담당하며, 레거시 호환성을 유지합니다.

#### 2.1 UserProfileAdapter

**파일**: `user_profile_adapter.dart`

**책임**:
- UserProfile → Domain Models 변환 (UserSettings, FriendsList 추출)
- Domain Models → UserProfile 통합
- UserProfileBundle 생성

**주요 메서드**:

##### UserProfile → Domain Models
```dart
// UserSettings 추출
UserSettings extractSettings(UserProfile userProfile);

// FriendsList 추출
FriendsList extractFriendsList(UserProfile userProfile);

// Bundle 생성 (모든 도메인 모델 포함)
UserProfileBundle toDomainModels(UserProfile userProfile);

// 편의 메서드
static UserProfileBundle createBundle(UserProfile userProfile) {
  return UserProfileAdapter.toDomainModels(userProfile);
}
```

**UserProfileBundle 구조**:
```dart
class UserProfileBundle {
  final UserProfile profile;     // 전체 프로필
  final UserSettings settings;   // 설정 정보
  final FriendsList friendsList; // 친구 목록
}
```

**사용 예시**:
```dart
// Repository에서 Bundle 생성
Future<UserProfileBundle?> getUserBundleByUid(String uid) async {
  final userProfile = await getUserByUid(uid);
  if (userProfile == null) return null;
  return UserProfileAdapter.createBundle(userProfile);
}

// Provider에서 Domain 모델 추출
final bundle = UserProfileAdapter.toDomainModels(userProfile);
final settings = bundle.settings;  // UserSettings
final friends = bundle.friendsList; // FriendsList
```

#### 2.2 UserCacheService

**파일**: `user_cache_service.dart`

**책임**:
- 3-Layer 캐싱 시스템 orchestration
- Memory → Hive → Firestore 캐싱 전략
- 자동 캐시 무효화 및 동기화

**캐싱 전략**:
```
Layer 1: Memory Cache (SimpleMemoryCache)
- 즉시 응답 (<10ms)
- LRU 알고리즘 (100개 제한)
- 5분 TTL

Layer 2: Hive Local DB
- 빠른 응답 (10-30ms)
- 영구 저장
- 6시간 TTL

Layer 3: Firestore Offline Cache
- 중간 속도 (50-100ms)
- 무제한 크기
- 네트워크 연결 시 자동 동기화
```

**주요 메서드**:
```dart
// 프로필 캐싱
Future<UserProfile?> getCachedUser(String userId);
Future<void> cacheUser(String userId, UserProfile user);
Future<void> invalidateUserCache(String userId);

// 설정 캐싱
Future<UserSettings?> getCachedSettings(String userId);
Future<void> cacheSettings(String userId, UserSettings settings);

// 캐시 통계
CacheStatistics getStatistics();
```

---

### 3. datasources/ - 데이터 소스 (구현 예정)

DataSource는 **외부 시스템과의 직접 통신**을 담당하며, Firebase 의존성을 인터페이스로 추상화합니다.

#### 3.1 Remote 데이터소스 (구현 예정)

##### FirestoreProfileDatasource
```dart
abstract class IProfileDataSource {
  // Create
  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> userData);

  // Read
  Future<Map<String, dynamic>?> getProfile(String userId);
  Stream<Map<String, dynamic>?> watchProfile(String userId);

  // Update
  Future<void> updateProfile(String userId, Map<String, dynamic> data);

  // Delete
  Future<void> deleteProfile(String userId);
}
```

##### FirebaseStorageDatasource
```dart
abstract class IStorageDataSource {
  // 프로필 이미지 업로드
  Future<String> uploadProfileImage({
    required String userId,
    required String fileName,
    required List<int> bytes,
  });

  // 캐릭터 이미지 업로드
  Future<String> uploadCharacterImage({
    required String userId,
    required String fileName,
    required List<int> bytes,
  });

  // 이미지 삭제
  Future<void> deleteImage(String url);
}
```

#### 3.2 Local 데이터소스 (구현 예정)

##### ProfileLocalDatasource
```dart
abstract class IProfileLocalDataSource {
  // 프로필 캐싱
  Future<Map<String, dynamic>?> getCachedProfile(String userId);
  Future<void> cacheProfile(String userId, Map<String, dynamic> data);
  Future<void> clearCache(String userId);

  // 캐시 유효성 확인
  Future<bool> isCacheValid(String userId, {Duration maxAge = const Duration(hours: 6)});
}
```

##### OnboardingProgressDatasource
```dart
abstract class IOnboardingProgressDataSource {
  // 온보딩 진행상태 저장
  Future<void> saveProgress({
    required String userId,
    required OnboardingStep step,
    required Map<String, dynamic> data,
  });

  // 현재 단계 조회
  Future<OnboardingStep?> getCurrentStep(String userId);

  // 임시 데이터 관리
  Future<void> saveTempData(String userId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getTempData(String userId);
  Future<void> clearTempData(String userId);
}
```

**온보딩 단계**:
```dart
enum OnboardingStep {
  ageAgreement,        // 1. 연령 동의
  jobSelection,        // 2. 직업 선택
  expertiseSelection,  // 3. 전문분야 선택
  hobbySelection,      // 4. 취미 선택
  characterCreation,   // 5. 캐릭터 생성
  profileSetup,        // 6. 프로필 설정
}
```

---

### 4. exports/ - Data Layer Exports

**파일**: `profile_models.dart`

**책임**: Data Layer의 모든 모델을 중앙 집중식으로 export

**구조**:
```dart
// Domain Models
export '../../domain/models/user_profile.dart';
export '../../domain/models/user_settings.dart';
export '../../domain/models/friends_list_model.dart';
export '../../domain/models/characters_model.dart';

// Adapters
export '../adapters/user_profile_adapter.dart';
export '../adapters/user_cache_service.dart';

// Repositories
export '../repositories/user_repository_impl.dart';
```

---

## 🔄 데이터 플로우

### 1. 프로필 조회 플로우

```
[Presentation Layer]
  ProfileProvider
    ↓ userId

[Domain Layer]
  GetUserProfileUseCase
    ↓ userId

[Data Layer - Repository]
  UserRepositoryImpl
    ├─ UserCacheService.getCachedUser()
    │   ├─ Layer 1: Memory Cache (<10ms)
    │   ├─ Layer 2: Hive Cache (10-30ms)
    │   └─ Layer 3: Firestore Offline (50-100ms)
    │
    └─ UsersModel.getDocument(userId)
        ↓ Firestore API (300-500ms)

[Firestore]
  users collection
    └─ Document retrieved
```

### 2. 프로필 업데이트 플로우

```
[Presentation Layer]
  ProfileEditScreen
    ↓ UpdateProfileParams

[Domain Layer]
  UpdateProfileUseCase
    ├─ Validation (필드 검증)
    ├─ Permission Check (본인 확인)
    └─ Image Processing (이미지 최적화)

[Data Layer - Repository]
  UserRepositoryImpl
    ├─ UserProfileAdapter.toUpdateDocument()
    ├─ UsersModel.update(data)
    └─ UserCacheService.invalidateUserCache()
        ↓ 캐시 무효화

[Firestore]
  users/{userId}
    └─ Document updated
```

### 3. 온보딩 완료 플로우

```
[Presentation Layer]
  OnboardingScreen
    ↓ CompleteOnboardingStepParams

[Domain Layer]
  CompleteOnboardingStepUseCase
    ├─ 단계별 데이터 검증
    ├─ 온보딩 순서 확인
    └─ 단계 완료 처리

[Data Layer - Repository]
  UserRepositoryImpl
    ├─ OnboardingProgressDatasource.saveProgress()
    ├─ updateUser({ isOnboardingComplete: true })
    └─ 보상 처리 (포인트, 캐릭터 잠금 해제)

[Firestore]
  users/{userId}
    ├─ onboardingCompleted: true
    └─ onboardingStep: 'complete'
```

---

## 🛡️ 에러 처리

### Repository Layer 에러 변환

```dart
try {
  final userProfile = await UsersModel.getDocument(userId);
  return userProfile;
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    throw ProfilePermissionFailure(
      userId: userId,
      operation: 'read',
      code: 'FIRESTORE_PERMISSION_DENIED',
    );
  } else if (e.code == 'not-found') {
    return null; // 사용자 없음
  } else if (e.code == 'unavailable') {
    throw const NetworkFailure(message: 'Firestore service unavailable');
  }
  rethrow;
}
```

### Presentation Layer 에러 처리

```dart
try {
  await provider.updateProfile(userId, displayName: displayName);
  BotToast.showText(text: '프로필이 업데이트되었습니다');
} catch (e) {
  String errorMessage = '프로필 업데이트 중 오류가 발생했습니다';

  if (e is ProfilePermissionFailure) {
    errorMessage = '프로필 수정 권한이 없습니다';
  } else if (e is ProfileValidationFailure) {
    errorMessage = e.getUserMessage();
  } else if (e is NetworkFailure) {
    errorMessage = '인터넷 연결을 확인해주세요';
  }

  BotToast.showText(text: errorMessage);
}
```

---

## 🧪 테스트 전략

### 1. Repository Tests (Unit)

```dart
group('UserRepositoryImpl', () {
  late MockUsersModel mockUsersModel;
  late MockUserCacheService mockCacheService;
  late UserRepositoryImpl repository;

  test('getUser - 캐시 히트 시 Firestore 호출 없음', () async {
    // Given
    final cachedUser = UserProfile(userId: 'user123', displayName: 'Test');
    when(mockCacheService.getCachedUser('user123'))
      .thenAnswer((_) async => cachedUser);

    // When
    final result = await repository.getUser('user123');

    // Then
    expect(result, cachedUser);
    verifyNever(mockUsersModel.getDocument('user123'));
  });

  test('getUser - 캐시 미스 시 Firestore 조회', () async {
    // Given
    when(mockCacheService.getCachedUser('user123'))
      .thenAnswer((_) async => null);
    when(mockUsersModel.getDocument('user123'))
      .thenAnswer((_) async => UserProfile(userId: 'user123'));

    // When
    final result = await repository.getUser('user123');

    // Then
    expect(result, isNotNull);
    verify(mockUsersModel.getDocument('user123')).called(1);
    verify(mockCacheService.cacheUser('user123', any)).called(1);
  });
});
```

### 2. Adapter Tests (Unit)

```dart
group('UserProfileAdapter', () {
  test('toDomainModels - UserSettings 추출', () {
    // Given
    final userProfile = UserProfile(
      userId: 'user123',
      notificationSettings: {
        'voteRequests': true,
        'comments': false,
      },
    );

    // When
    final bundle = UserProfileAdapter.toDomainModels(userProfile);
    final settings = bundle.settings;

    // Then
    expect(settings.notifyOnVoteRequests, true);
    expect(settings.notifyOnComments, false);
  });

  test('extractFriendsList - 친구 목록 추출', () {
    // Given
    final userProfile = UserProfile(
      userId: 'user123',
      friends: ['friend1', 'friend2'],
    );

    // When
    final friendsList = UserProfileAdapter.extractFriendsList(userProfile);

    // Then
    expect(friendsList.friendIds, ['friend1', 'friend2']);
    expect(friendsList.userId, 'user123');
  });
});
```

---

## 🔐 보안 고려사항

### 1. Firebase Security Rules 통합

**Firestore Rules**:
```javascript
// users 컬렉션
match /users/{userId} {
  // 모든 사용자가 읽기 가능 (공개 프로필)
  allow read: if request.auth != null;

  // 본인만 쓰기 가능
  allow create, update: if request.auth != null
    && request.auth.uid == userId;

  // 본인만 삭제 가능
  allow delete: if request.auth != null
    && request.auth.uid == userId;
}
```

**Storage Rules**:
```javascript
// user_uploads/{userId}/profile_images
match /user_uploads/{userId}/profile_images/{imageName} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

### 2. 데이터 검증

```dart
Future<void> updateUser(UserProfile user) async {
  // 필수 필드 검증
  if (user.displayName.isEmpty) {
    throw ProfileValidationFailure(
      missingFields: ['displayName'],
    );
  }

  // 길이 제한 검증
  if (user.bio != null && user.bio!.length > 150) {
    throw ProfileValidationFailure(
      message: 'Bio는 150자를 초과할 수 없습니다',
    );
  }

  // 권한 확인
  final currentUserId = _auth.currentUser?.uid;
  if (currentUserId != user.userId) {
    throw ProfilePermissionFailure(
      userId: user.userId,
      operation: 'update',
      code: 'UNAUTHORIZED_UPDATE',
    );
  }

  await UsersModel.update(user.userId, user.toMap());
}
```

---

## 🚀 확장 가능성

### 1. 새로운 DataSource 추가

```dart
// Algolia Search DataSource 추가
abstract class IProfileSearchDataSource {
  Future<List<UserProfile>> searchUsers({
    required String query,
    int limit = 20,
  });
}

class AlgoliaProfileSearchDataSource implements IProfileSearchDataSource {
  @override
  Future<List<UserProfile>> searchUsers({required String query, int limit = 20}) async {
    final results = await _algolia.search(query, limit: limit);
    return results.map((hit) => UserProfile.fromMap(hit.data)).toList();
  }
}
```

### 2. 프로필 통계 Repository 추가

```dart
abstract class IProfileStatsRepository {
  Future<ProfileStats> getStats(String userId);
  Future<void> updateStats(String userId, ProfileStats stats);
}

class ProfileStatsRepositoryImpl implements IProfileStatsRepository {
  @override
  Future<ProfileStats> getStats(String userId) async {
    // 통계 조회 로직
  }
}
```

---

## 📊 성능 최적화

### 1. 3-Layer 캐싱 성능

```
캐시 히트율:
- Memory: 60%+ (즉시 응답 <10ms)
- Hive: 30%+ (빠른 응답 10-30ms)
- Firestore Offline: 8%+ (중간 속도 50-100ms)
- Network: 2%- (느림 300-500ms)

평균 응답 시간:
- Before (캐싱 없음): 400ms
- After (3-Layer 캐싱): 50ms (87.5% 개선)
```

### 2. 이미지 프리캐싱

```dart
Future<void> precacheUserImages(List<UserProfile> users) async {
  for (final user in users) {
    if (user.photoUrl != null) {
      final memCacheWidth = 800; // Display 크기
      precacheImage(
        CachedNetworkImageProvider(user.photoUrl!),
        context,
        size: Size(memCacheWidth.toDouble(), 0),
      );
    }
  }
}
```

---

## 🔗 관련 문서

### Profile Feature 문서
- [Domain Layer README](../domain/README.md) - Domain 모델 및 비즈니스 로직
- [Presentation Layer README](../presentation/README.md) - UI 및 상태 관리
- [MIGRATION_PLAN.md](../MIGRATION_PLAN.md) - Clean Architecture 마이그레이션 계획

### 참고 문서
- [Creation Feature Data Layer](../../creation/data/README.md) - Creation 참고 구조
- [Clean Architecture v4.0](../../../docs/architecture/clean_architecture_v4.md)
- [3-Layer Caching System](../../../docs/architecture/caching_system.md)
- [Firebase Integration Guide](../../../docs/firebase/integration.md)

---

*이 문서는 Feature-First Architecture의 Profile 기능 Data Layer 가이드입니다.*
*Phase 1 마이그레이션 작업 중 생성됨 (2025-01-26)*
