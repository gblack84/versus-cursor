# Profile Domain Layer - Clean Architecture v4.0

> **Last Updated**: 2025-01-30
> **Architecture**: Clean Architecture v4.0 - Domain Layer
> **Pattern**: Repository Pattern + UseCase Pattern + Freezed Immutability
> **Dependencies**: Pure Dart (No Flutter/Firebase)

## Overview

**Profile Domain Layer**는 사용자 프로필 Feature의 핵심 비즈니스 로직과 규칙을 정의하는 순수 Dart 레이어입니다. Clean Architecture v4.0의 가장 안쪽 원으로, 외부 의존성이 전혀 없으며 프레임워크에 독립적입니다.

### Core Principles

1. **Framework Independence**: Flutter, Firebase 등 외부 프레임워크 의존성 제거
2. **Testability**: 모든 비즈니스 로직은 단위 테스트 가능
3. **Immutability**: Freezed를 통한 불변 엔티티 설계
4. **Type Safety**: Either 패턴으로 타입 안전한 에러 처리
5. **Single Responsibility**: UseCase 패턴으로 단일 책임 원칙 준수
6. **Dependency Inversion**: Repository 인터페이스로 의존성 역전

### Domain Layer vs Data Layer

| Aspect | Domain Layer | Data Layer |
|--------|-------------|------------|
| **Purpose** | 비즈니스 개념 정의 | 구체적 구현 |
| **Dependencies** | Pure Dart only | Firebase, UnifiedCache, etc |
| **Entities** | Domain models | Extensions, Cache |
| **Repositories** | Interfaces (abstract) | Implementations |
| **Focus** | What & Why | How |
| **Testing** | Unit tests (fast) | Integration tests (slow) |

---

## Directory Structure (42 files)

```
domain/
├── failures/
│   ├── profile_failure.dart              # 204 lines - 12 failure types
│   └── profile_failure.freezed.dart       # Generated
│
├── entities/ (6 main + 18 generated = 24 files)
│   ├── user_profile.dart                 # 146 lines - 42 fields (통합 모델)
│   ├── user_profile.freezed.dart         # Generated
│   ├── user_profile.g.dart               # Generated
│   ├── profile_info.dart                 # 65 lines - 10 fields (경량 조회)
│   ├── profile_info.freezed.dart         # Generated
│   ├── profile_info.g.dart               # Generated
│   ├── user_settings.dart                # 98 lines - 9 fields (설정)
│   ├── user_settings.freezed.dart        # Generated
│   ├── user_settings.g.dart              # Generated
│   ├── character.dart                    # 37 lines - 7 fields
│   ├── character.freezed.dart            # Generated
│   ├── character.g.dart                  # Generated
│   ├── interest.dart                     # 48 lines - 5 fields
│   ├── interest.freezed.dart             # Generated
│   ├── interest.g.dart                   # Generated
│   ├── interest_category.dart            # 36 lines - 4 fields
│   ├── interest_category.freezed.dart    # Generated
│   ├── interest_category.g.dart          # Generated
│   ├── user_profile_extensions.dart      # 314 lines - Extension methods
│   └── README.md                         # 213 lines - Model documentation
│
├── repositories/ (6 files)
│   ├── i_profile_repository.dart         # 102 lines - 3 methods (Phase 6: 85% 축소)
│   ├── i_user_repository.dart            # 293 lines - 12 methods
│   ├── i_settings_repository.dart        # 31 lines - 2 methods
│   ├── i_characters_repository.dart      # 21 lines - 1 method
│   ├── i_interests_repository.dart       # 76 lines - 4 methods
│   └── i_profile_storage_repository.dart # 43 lines - 2 methods
│
└── usecases/ (11 files)
    ├── profile/ (8 files)
    │   ├── get_current_user_profile_usecase.dart     # 47 lines
    │   ├── get_profile_completion_usecase.dart       # 52 lines
    │   ├── get_profile_info_usecase.dart             # 44 lines
    │   ├── get_user_profile_usecase.dart             # 49 lines
    │   ├── watch_user_profile_usecase.dart           # 164 lines (Real-time Stream)
    │   ├── update_user_profile_usecase.dart          # 68 lines
    │   ├── upload_profile_image_usecase.dart         # 63 lines
    │   └── delete_user_profile_usecase.dart          # 55 lines
    │
    ├── settings/ (2 files)
    │   ├── get_user_settings_usecase.dart            # 41 lines
    │   └── update_user_settings_usecase.dart         # 59 lines
    │
    ├── characters/ (1 file)
    │   └── get_available_characters_usecase.dart     # 38 lines
    │
    └── interests/ (2 files)
        ├── get_user_interests_usecase.dart           # 44 lines
        └── update_user_interests_usecase.dart        # 75 lines
```

**Total**: 24 entities + 6 repositories + 11 usecases + 1 README + 3 기타 = **45 files**

---

## failures/ - ProfileFailure Deep Dive

Domain Failures는 비즈니스 에러를 표현하는 불변 객체입니다. Freezed 패키지를 사용하여 sealed class로 구현되며, when/map 패턴 매칭을 지원합니다.

### ProfileFailure (12 Types)

**Architecture**: `@freezed sealed class ProfileFailure with _$ProfileFailure implements Failure`

```dart
@freezed
sealed class ProfileFailure with _$ProfileFailure implements Failure {
  const ProfileFailure._();

  // ==================== Failure Factory Constructors ====================

  /// 입력 검증 실패
  const factory ProfileFailure.validation(String field) = ValidationFailure;

  /// 프로필을 찾을 수 없음
  const factory ProfileFailure.profileNotFound({String? userId}) = ProfileNotFound;

  /// Firestore 읽기 실패
  const factory ProfileFailure.firestoreRead(String operation) = FirestoreRead;

  /// Firestore 쓰기 실패
  const factory ProfileFailure.firestoreWrite(String operation) = FirestoreWrite;

  /// Firebase Storage 작업 실패
  const factory ProfileFailure.storage(String operation) = StorageFailure;

  /// 네트워크 연결 오류
  const factory ProfileFailure.network() = NetworkFailure;

  /// 권한 거부
  const factory ProfileFailure.permissionDenied(String resource) = PermissionDenied;

  /// 인증 필요 (로그인 안 됨)
  const factory ProfileFailure.authenticationRequired() = AuthenticationRequired;

  /// 권한 없음 (다른 사용자 리소스 접근 시도)
  const factory ProfileFailure.unauthorizedAccess({
    @Default('권한이 없습니다') String message,
  }) = UnauthorizedAccess;

  /// 캐시 작업 실패
  const factory ProfileFailure.cache(String operation) = CacheFailure;

  /// 중복 작업 시도 (Idempotency 위반)
  const factory ProfileFailure.duplicateOperation(String message) = DuplicateOperation;

  /// 알 수 없는 오류
  const factory ProfileFailure.unknown([String? error]) = UnknownProfile;

  /// Convert to user-friendly message (Implements Failure.message)
  @override
  String get message {
    return when(
      validation: (field) => '입력 정보를 확인해주세요: $field',
      profileNotFound: (userId) => userId != null
          ? '프로필을 찾을 수 없습니다 (UID: $userId)'
          : '프로필을 찾을 수 없습니다',
      firestoreRead: (operation) => '데이터 읽기 실패: $operation',
      firestoreWrite: (operation) => '데이터 저장 실패: $operation',
      storage: (operation) => '파일 처리 실패: $operation',
      network: () => '네트워크 연결을 확인해주세요',
      permissionDenied: (resource) => '접근 권한이 없습니다: $resource',
      authenticationRequired: () => '로그인이 필요합니다',
      unauthorizedAccess: (msg) => msg,
      cache: (operation) => '캐시 작업 실패: $operation',
      duplicateOperation: (msg) => '이미 처리된 작업입니다: $msg',
      unknown: (error) => error ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

### Failure 사용 예시

```dart
// ✅ 입력 검증
if (userId.isEmpty) {
  return left(ProfileFailure.validation('userId'));
}

// ✅ 프로필 없음
if (profile == null) {
  return left(ProfileFailure.profileNotFound(userId: userId));
}

// ✅ Firestore 에러 처리
try {
  final doc = await firestore.collection('users').doc(uid).get();
} on FirebaseException catch (e) {
  return left(ProfileFailure.firestoreRead('user document'));
}

// ✅ 네트워크 에러
if (!await hasNetwork()) {
  return left(ProfileFailure.network());
}

// ✅ 권한 에러
if (user.uid != currentUid) {
  return left(ProfileFailure.unauthorizedAccess(
    message: 'Cannot update other user profile'
  ));
}

// ✅ Idempotency 위반
try {
  await idempotencyService.executeIdempotent(...);
} on IdempotencyViolation catch (e) {
  return left(ProfileFailure.duplicateOperation(e.message));
}
```

### Key Features

- ✅ **Sealed Class**: 컴파일 타임에 모든 케이스 검증
- ✅ **Pattern Matching**: when/map/maybeWhen 메서드 지원
- ✅ **User Message**: message getter로 사용자 친화적 메시지 제공
- ✅ **Type Safety**: 각 Failure 타입에 필요한 데이터만 포함
- ✅ **Immutable**: Freezed를 통한 불변성 보장

---

## entities/ - Domain Models Deep Dive

Domain Models는 비즈니스 개념을 표현하는 불변 객체입니다. Freezed 패키지를 사용하여 불변성, JSON 직렬화, copyWith, equality를 자동 생성합니다.

### 1. UserProfile (user_profile.dart)

**Purpose**: 사용자의 전체 프로필 정보를 표현하는 통합 모델 (42 fields)

**Key Characteristics**:
- 🎯 **통합 모델**: 모든 사용자 정보를 단일 객체로 표현
- 📊 **포인트 시스템**: pointsA, pointsQ, totalAPoints, totalQPoints
- 🏆 **랭킹 시스템**: currentRank, currentTitle, rankHistory, titleHistory
- 👥 **소셜 기능**: friends, activeChats, groupChats
- 🔔 **알림 설정**: receiveRankUpdateNotifications, receiveTitleUpdateNotifications
- 📍 **위치 정보**: LatLng location
- 🎭 **익명 활동**: anonymousPostsCount, anonymousCommentsCount, anonymousQuestionCount
- 💎 **프리미엄**: isPremiumUser, subscription

```dart
@freezed
sealed class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    // ============= Core Identity Fields =============
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,

    // ============= Profile Information =============
    @JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng? location,
    String? shortDescription,
    String? gender,
    DateTime? dateOfBirth,
    String? language,

    // ============= System Timestamps =============
    DateTime? createdTime,
    DateTime? lastActive,
    DateTime? lastActiveTime,

    // ============= Points System =============
    @Default(0) int pointsA,
    @Default(0) int pointsQ,
    @Default(0) int totalAPoints,
    @Default(0) int totalQPoints,

    // ============= Interests and Expertise =============
    @Default([]) List<String> interests,
    @Default([]) List<String> expertise,
    @Default([]) List<String> hobbies,
    String? jobCategory,
    String? jobName,

    // ============= Premium Status =============
    @Default(false) bool isPremiumUser,

    // ============= Anonymous Activity Counters =============
    @Default(0) int anonymousPostsCount,
    @Default(0) int anonymousCommentsCount,
    @Default(0) int anonymousQuestionCount,

    // ============= Ranking System =============
    String? currentRank,
    String? currentTitle,
    DateTime? rankChangeDate,
    DateTime? titleChangeDate,
    @Default(false) bool isRankEligible,
    @Default(0) int rankEvaluationCount,
    @Default([]) List<String> rankHistory,
    @Default([]) List<String> titleHistory,

    // ============= Notification Settings =============
    @Default(false) bool receiveRankUpdateNotifications,
    @Default(false) bool receiveTitleUpdateNotifications,

    // ============= Character Selection =============
    String? characterId,

    // ============= Social Connections =============
    @Default([]) List<String> friends,
    @Default([]) List<String> activeChats,
    @Default([]) List<String> groupChats,

    // ============= System Fields =============
    String? role,
    String? title,
    @Default({}) Map<String, dynamic> stats,
    @Default({}) Map<String, dynamic> subscription,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  // ============= Business Logic Getters =============

  /// 총 포인트 (A형 + Q형)
  int get totalPoints => pointsA + pointsQ;

  /// 총 활동 포인트 (전체 A형 + 전체 Q형)
  int get totalActivityPoints => totalAPoints + totalQPoints;

  /// 프로필 완성도 (0.0 ~ 1.0)
  double get completionRate {
    int completedFields = 0;
    const int totalRequiredFields = 10; // 주요 필드 개수

    if (displayName != null && displayName!.isNotEmpty) completedFields++;
    if (photoUrl != null && photoUrl!.isNotEmpty) completedFields++;
    if (shortDescription != null && shortDescription!.isNotEmpty) completedFields++;
    if (gender != null) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (language != null) completedFields++;
    if (jobCategory != null) completedFields++;
    if (jobName != null) completedFields++;
    if (interests.isNotEmpty) completedFields++;
    if (characterId != null) completedFields++;

    return completedFields / totalRequiredFields;
  }
}
```

**Business Logic**:
- `totalPoints`: A형 + Q형 포인트 합계
- `totalActivityPoints`: 전체 활동 포인트 합계
- `completionRate`: 프로필 완성도 계산 (0.0 ~ 1.0)

**Use Cases**:
- 프로필 화면 전체 정보 표시
- 프로필 수정 (updateUserProfile)
- 프로필 완성도 체크
- 포인트 시스템 업데이트
- 랭킹 시스템 업데이트

### 2. ProfileInfo (profile_info.dart)

**Purpose**: 경량 프로필 조회 모델 (10 fields)

**Key Characteristics**:
- 🚀 **성능 최적화**: UserProfile 대비 75% 대역폭 절감 (42개 → 10개 필드)
- 📱 **모바일 친화적**: 목록 표시에 필요한 최소 정보만 포함
- 🔍 **빠른 조회**: 네트워크 부하 최소화

```dart
@freezed
sealed class ProfileInfo with _$ProfileInfo {
  const factory ProfileInfo({
    // Core Fields
    required String userId, // Foreign key to AuthUser.uid
    required String displayName,
    String? photoUrl,

    // Profile Details
    String? shortDescription,
    String? gender,
    DateTime? dateOfBirth,
    @Default('en') String language,

    // Lists
    @Default([]) List<String> interests,
    @Default([]) List<String> expertise,

    // Location
    @JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng? location,
  }) = _ProfileInfo;

  factory ProfileInfo.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoFromJson(json);
}
```

**Use Cases**:
- 사용자 목록 표시 (검색 결과, 친구 목록)
- 댓글 작성자 정보 표시
- 채팅 참여자 정보 표시
- 투표 참여자 정보 표시

**Performance Comparison**:

| Model | Fields | Size (estimated) | Use Case |
|-------|--------|------------------|----------|
| **UserProfile** | 42 fields | ~2.5 KB | 전체 프로필 화면 |
| **ProfileInfo** | 10 fields | ~0.6 KB | 목록/카드 표시 |
| **Reduction** | 76% less | 75% less | - |

### 3. UserSettings (user_settings.dart)

**Purpose**: 사용자 설정 및 알림 환경설정 모델 (9 fields)

**Key Characteristics**:
- 🔔 **알림 설정**: 5가지 알림 타입 개별 제어
- 💎 **프리미엄 상태**: 구독 정보 포함
- 🔒 **프라이버시 설정**: 세부 프라이버시 옵션
- 📊 **통계 환경설정**: 사용자별 통계 표시 설정

```dart
@freezed
sealed class UserSettings with _$UserSettings {
  const UserSettings._();

  const factory UserSettings({
    // Core Fields
    required String userId, // Foreign key to AuthUser.uid

    // Premium Status
    @Default(false) bool isPremiumUser,

    // Notification Preferences
    @Default(true) bool receiveRankUpdateNotifications,
    @Default(true) bool receiveTitleUpdateNotifications,
    @Default(true) bool receiveVoteNotifications,
    @Default(true) bool receiveCommentNotifications,
    @Default(true) bool receiveFriendNotifications,

    // Complex Settings
    @Default({}) Map<String, dynamic> subscription, // Subscription details
    @Default({}) Map<String, dynamic> stats, // User statistics preferences
    @Default({}) Map<String, dynamic> privacySettings, // Privacy configurations
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  // ============= Business Logic Getters =============

  /// Check if user has any notification enabled
  bool get hasAnyNotificationEnabled =>
      receiveRankUpdateNotifications ||
      receiveTitleUpdateNotifications ||
      receiveVoteNotifications ||
      receiveCommentNotifications ||
      receiveFriendNotifications;

  /// Get all notification settings as a map
  Map<String, bool> get notificationSettings => {
        'rankUpdates': receiveRankUpdateNotifications,
        'titleUpdates': receiveTitleUpdateNotifications,
        'votes': receiveVoteNotifications,
        'comments': receiveCommentNotifications,
        'friends': receiveFriendNotifications,
      };
}
```

**Business Logic**:
- `hasAnyNotificationEnabled`: 알림이 하나라도 켜져있는지 확인
- `notificationSettings`: 알림 설정을 Map으로 변환
- `toFirestore()`: Firestore 저장용 Map 변환 (null 필드 제외)

**Use Cases**:
- 설정 화면 표시
- 알림 환경설정 업데이트
- 프리미엄 상태 확인
- FCM 토픽 구독 관리

### 4. Character (character.dart)

**Purpose**: 사용자 캐릭터/아바타 정보 모델 (7 fields)

**Key Characteristics**:
- 🎭 **캐릭터 선택**: 사용자가 프로필 이미지 대신 캐릭터 선택 가능
- 🏷️ **타입 분류**: 기본/프리미엄 캐릭터 구분
- ✅ **활성 상태**: 사용 가능 여부 관리

```dart
@freezed
sealed class Character with _$Character {
  const factory Character({
    /// 캐릭터 고유 ID
    required String characterId,

    /// 캐릭터 이름
    required String name,

    /// 캐릭터 이미지 URL
    required String imageUrl,

    /// 캐릭터 설명
    String? description,

    /// 활성 상태 (사용 가능 여부)
    @Default(true) bool isActive,

    /// 캐릭터 타입 (기본, 프리미엄 등)
    String? characterType,

    /// 생성일
    DateTime? createdAt,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
}
```

**Use Cases**:
- 캐릭터 선택 화면 목록 표시
- 프로필 이미지 대체
- 프리미엄 캐릭터 필터링

### 5. Interest (interest.dart)

**Purpose**: 사용자 관심사 모델 (5 fields)

**Key Characteristics**:
- 🏷️ **카테고리 분류**: job, expertise, hobby
- ⚖️ **가중치**: 관심사 우선순위 (0.0 ~ 1.0)
- 📅 **선택 날짜**: 관심사 추가 시점 추적

**Constraints**:
- expertise (전문성): 최대 4개
- hobbies (취미): 최대 8개

```dart
@freezed
sealed class Interest with _$Interest {
  const Interest._();

  const factory Interest({
    /// 관심사 고유 ID
    required String id,

    /// 관심사 이름
    required String name,

    /// 관심사 카테고리 (job, expertise, hobby)
    required String category,

    /// 가중치 (우선순위, 0.0 ~ 1.0)
    @Default(0.5) double weight,

    /// 선택된 날짜
    DateTime? selectedAt,
  }) = _Interest;

  factory Interest.fromJson(Map<String, dynamic> json) =>
      _$InterestFromJson(json);

  /// String으로부터 간단한 Interest 객체 생성
  factory Interest.fromString(String name, String category) {
    return Interest(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      category: category,
    );
  }
}
```

**Factory Methods**:
- `fromJson()`: JSON → Interest
- `fromString()`: 간단한 Interest 객체 생성 (UI용)

**Use Cases**:
- 관심사 선택 UI
- 사용자 매칭 알고리즘
- 추천 시스템
- 관심사 필터링

### 6. InterestCategory (interest_category.dart)

**Purpose**: Firestore의 interest 컬렉션 문서 모델 (4 fields)

**Key Characteristics**:
- 📚 **카테고리 관리**: 시스템에서 제공하는 관심사 카테고리
- 👥 **사용자 추적**: 해당 관심사를 선택한 사용자 ID 목록
- 🌲 **계층 구조**: 서브 카테고리 지원

```dart
@freezed
sealed class InterestCategory with _$InterestCategory {
  const factory InterestCategory({
    required String interestId,
    required String nameInterest,
    @Default([]) List<String> userIds,
    @Default([]) List<String> subCategories,
  }) = _InterestCategory;

  factory InterestCategory.fromJson(Map<String, dynamic> json) =>
      _$InterestCategoryFromJson(json);
}
```

**Use Cases**:
- 관심사 선택 화면 옵션 제공
- 인기 관심사 통계
- 관심사별 사용자 수 집계

### user_profile_extensions.dart

**Purpose**: Firebase-Centric v2.0 패턴의 핵심 - Extension으로 Entity ↔ Firestore 변환

**Key Features**:
- ✅ **Adapter/Mapper 불필요**: Extension 메서드로 간결하게 변환
- ✅ **Auth Feature 패턴 100% 일치**: 동일한 변환 패턴 사용
- ✅ **타입 안전성**: Extension이 원본 타입에 직접 메서드 추가

```dart
/// UserProfile Extension
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
      displayName: data['displayName'] as String?,
      // ... 42 fields
    );
  }

  /// UserProfile → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      // ... 42 fields
    };
  }
}

/// ProfileInfo Extension
extension ProfileInfoFirestore on ProfileInfo {
  static ProfileInfo fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}

/// UserSettings Extension
extension UserSettingsFirestore on UserSettings {
  static UserSettings fromFirestore(DocumentSnapshot doc) { ... }
  // toFirestore()는 UserSettings 클래스에 이미 정의됨
}
```

**Usage in Repository**:
```dart
// Read
final doc = await _firestore.collection('users').doc(userId).get();
final profile = UserProfileFirestore.fromFirestore(doc);

// Write
final profile = UserProfile(...);
final data = profile.toFirestore();
await _firestore.collection('users').doc(userId).set(data);
```

---

## repositories/ - Repository Interfaces Deep Dive

Repository 인터페이스는 Domain Layer와 Data Layer 사이의 계약(Contract)을 정의합니다. Clean Architecture의 Dependency Inversion Principle을 구현하는 핵심 요소입니다.

### 1. IProfileRepository (i_profile_repository.dart)

**Purpose**: 프로필 완성도 및 경량 조회 작업

**Phase 6 대규모 정리** (2025-01-21):
- 20개 → 3개 메서드로 축소 (85% 감소)
- 호출처 0건 메서드 완전 삭제
- DataSource 레벨 구현만 사용하는 메서드만 보존

```dart
abstract class IProfileRepository {
  // ============= 프로필 완성도 =============

  /// 프로필 완성도 확인
  ///
  /// **Returns**:
  /// - `Right(true)`: 프로필 완성
  /// - `Right(false)`: 프로필 미완성
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, bool>> isProfileComplete(String userId);

  /// 프로필 완성도 퍼센트
  ///
  /// **Returns**:
  /// - `Right(double)`: 완성도 퍼센트 (0.0 ~ 100.0)
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, double>> getProfileCompletionPercentage(String userId);

  // ============= 경량 프로필 조회 =============

  /// ProfileInfo 경량 조회 (10개 필드만)
  ///
  /// **성능**: UserProfile 대비 75% 대역폭 절감 (42개 → 10개 필드)
  ///
  /// **Returns**:
  /// - `Right(ProfileInfo)`: 경량 프로필 정보
  /// - `Left(ProfileFailure.profileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, ProfileInfo>> getProfileInfo(String userId);
}
```

**Deleted Methods** (2025-01-21):
- ❌ ProfileInfo 관리 (2개): getProfileInfoStream, updateProfileInfo
- ❌ UserSettings 관리 (3개): getUserSettings, getUserSettingsStream, updateUserSettings
- ❌ UserStats 관리 (3개): getUserStats, getUserStatsStream, updateUserStats
- ❌ 필드 업데이트 (2개): updateProfileField, updateProfileFields
- ❌ 프로필 사진 (2개): uploadProfilePhoto, deleteProfilePhoto
- ❌ 관심사 조회 (1개): getUserInterests
- ❌ 프로필 완성도 상세 (1개): getProfileCompletion
- ❌ 검색 및 추천 (2개): searchProfiles, getSuggestedProfiles
- ❌ 소셜 기능 (4개): blockUser, unblockUser, getBlockedUsers, reportUser

**Total Deleted**: 20개 메서드 → 이제 3개만 유지

### 2. IUserRepository (i_user_repository.dart)

**Purpose**: UserProfile 및 UserSettings CRUD 작업의 중심 Repository

**Key Features**:
- 🔄 **Real-time Streaming**: `watchUserProfile()` - Firestore WebSocket 기반
- 🔐 **Current User Operations**: AuthContract 통합
- ⚡ **Idempotency Support**: 중복 작업 방지
- 🎯 **Singleton Pattern**: 전역 접근 가능 (UserRepositoryImpl.instance)

```dart
abstract class IUserRepository {
  // ============= Basic CRUD Operations =============

  /// 사용자 조회 (UserProfile)
  Future<Either<ProfileFailure, UserProfile>> getUserByUid(String uid);

  /// 사용자 조회 (alias for getUserByUid)
  Future<Either<ProfileFailure, UserProfile>> getUser(String userId);

  // ============= 🆕 Real-time Streaming Operations =============

  /// 사용자 프로필 실시간 감시
  ///
  /// **Use Case**: 다른 사용자의 프로필을 볼 때 실시간 업데이트
  /// - 프로필 사진 변경 시 즉시 반영
  /// - 닉네임, 소개글 변경 시 자동 업데이트
  /// - 관심사, 직업 정보 변경 시 동기화
  ///
  /// **Returns**: Stream<UserProfile?>
  /// - null: 사용자가 존재하지 않거나 삭제됨
  /// - UserProfile: 실시간 업데이트되는 프로필 데이터
  ///
  /// **Performance**:
  /// - Firestore WebSocket 기반 실시간 리스닝
  /// - 문서 변경 시에만 이벤트 발생 (불필요한 읽기 없음)
  /// - 자동 재연결 (네트워크 끊김 시)
  ///
  /// **Added**: 2025-01-20 Profile Feature Real-time Sync
  Stream<UserProfile?> watchUserProfile(String userId);

  /// 사용자 생성
  Future<Either<ProfileFailure, Unit>> createUser(UserProfile user);

  /// 사용자 업데이트 (Map)
  Future<Either<ProfileFailure, Unit>> updateUser(
    String uid,
    Map<String, dynamic> data, {
    String? eventId, // Idempotency
  });

  /// 사용자 프로필 업데이트 (UserProfile)
  Future<Either<ProfileFailure, Unit>> updateUserProfile(
    UserProfile user, {
    String? eventId, // Idempotency
  });

  /// 사용자 삭제
  Future<Either<ProfileFailure, Unit>> deleteUser(
    String uid, {
    String? eventId, // Idempotency
  });

  /// 사용자 존재 여부 확인
  Future<Either<ProfileFailure, bool>> userExists(String uid);

  // ============= ProfileInfo & Stats 조회 =============

  /// UserSettings 조회
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(String uid);

  /// UserSettings 업데이트
  Future<Either<ProfileFailure, Unit>> updateUserSettings(
    String userId,
    Map<String, dynamic> settings, {
    String? eventId, // Idempotency
  });

  // ============= Current User Operations =============

  /// 현재 로그인한 사용자 프로필 조회
  ///
  /// **Phase 2**: AuthContract를 통해 현재 사용자 ID 획득
  /// Repository Implementation에서 AuthContract 주입받아 사용
  /// Presentation 레이어는 이 메서드만 호출하면 됨
  Future<Either<ProfileFailure, UserProfile>> getCurrentUserProfile();

  /// 현재 로그인한 사용자 프로필 업데이트
  ///
  /// **Phase 2**: 보안 검증 포함
  /// - 현재 사용자 ID와 업데이트하려는 프로필 ID 일치 여부 검증
  Future<Either<ProfileFailure, Unit>> updateCurrentUserProfile(UserProfile user);
}
```

**Method Count**: 12개 메서드

**Deleted Methods**:
- ❌ Search & Query (4개): searchUsersByName, getUsersByIds, getUserFriends, queryFriendsList
- ❌ Points & Ranking (2개): updateUserPoints, updateUserRanking
- ❌ Adapter Methods (3개): getUserBundleByUid, updateUserWithBundle, createUserFromBundle
- ❌ ProfileInfo & Stats (2개): getUserProfileInfo, getUserStats
- ❌ Auth 데이터 조회 (1개): getAuthUserData
- ❌ Query Methods (3개): queryUsers, queryUsersStream, getUsersCount
- ❌ Characters & Interest (4개): queryCharacters, getCharactersCount, queryInterests, getInterestsCount

### 3. ISettingsRepository (i_settings_repository.dart)

**Purpose**: UserSettings 전용 CRUD

**Simplicity**: 가장 간단한 Repository (2개 메서드만)

```dart
abstract class ISettingsRepository {
  /// 사용자 설정 조회
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(String userId);

  /// 사용자 설정 업데이트
  Future<Either<ProfileFailure, Unit>> updateUserSettings(
    String userId,
    UserSettings settings,
  );
}
```

**Deleted Methods** (Phase 6 Cleanup):
- ❌ watchUserSettings (Stream 미사용)
- ❌ getNotificationSettings (UserSettings.notificationSettings getter 사용)
- ❌ updateNotificationSettings (updateUserSettings로 충분)

### 4. ICharactersRepository (i_characters_repository.dart)

**Purpose**: 사용 가능한 캐릭터/아바타 조회

**Simplicity**: 가장 간단한 Repository (1개 메서드만)

```dart
abstract class ICharactersRepository {
  /// 이용 가능한 모든 캐릭터 조회
  Future<Either<ProfileFailure, List<Character>>> getAvailableCharacters();
}
```

**Deleted Methods** (Phase 6 Cleanup):
- ❌ getUserCharacter, setUserCharacter, clearUserCharacter
- ❌ watchUserCharacter (Stream 미사용)
- **현재 시스템**: photoUrl 직접 저장 (characterId 추적 안 함)

### 5. IInterestsRepository (i_interests_repository.dart)

**Purpose**: 사용자 관심사 관리

**Key Features**:
- 🏷️ **제약사항 검증**: expertise 최대 4개, hobbies 최대 8개
- 🔄 **레거시 지원**: Firestore arrayUnion/arrayRemove 패턴
- ⚡ **Idempotency**: updateUserInterests에 eventId 지원

```dart
abstract class IInterestsRepository {
  /// 사용자 관심사 전체 업데이트
  ///
  /// **제약사항**:
  /// - expertise: 최대 4개
  /// - hobbies: 최대 8개
  Future<Either<ProfileFailure, Unit>> updateUserInterests(
    String userId,
    List<Interest> interests, {
    String? eventId, // Idempotency
  });

  /// 관심사 개별 추가 (arrayUnion)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 370-380
  /// - hobbies_select_widget.dart: line 130-140
  Future<Either<ProfileFailure, Unit>> addInterest({
    required String userId,
    required Interest interest,
  });

  /// 관심사 개별 제거 (arrayRemove)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 559-569
  /// - hobbies_select_widget.dart: line 319-329
  Future<Either<ProfileFailure, Unit>> removeInterest({
    required String userId,
    required Interest interest,
  });

  /// 사용자 관심사 조회
  Future<Either<ProfileFailure, List<Interest>>> getUserInterests(
    String userId,
  );
}
```

**Method Count**: 4개 메서드

**Deleted Methods** (Phase 6 Cleanup):
- ❌ watchUserInterests (Stream 미사용)

### 6. IProfileStorageRepository (i_profile_storage_repository.dart)

**Purpose**: Firebase Storage 작업 (프로필 이미지 업로드/삭제)

**Key Features**:
- 📁 **Storage 추상화**: Domain Layer는 File 객체만 전달
- 🔒 **Dependency Inversion**: UseCase가 Domain의 Port에 의존
- 🎯 **Storage 전용**: Firestore와 분리된 별도 Repository

```dart
abstract class IProfileStorageRepository {
  /// 프로필 이미지 업로드
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID (Storage 경로에 사용)
  /// - `imageFile`: 업로드할 이미지 파일
  ///
  /// **Returns**:
  /// - `Right(String)`: 업로드된 이미지의 다운로드 URL
  /// - `Left(ProfileFailure.storage)`: 업로드 실패
  Future<Either<ProfileFailure, String>> uploadProfileImage({
    required String userId,
    required File imageFile,
  });

  /// 프로필 이미지 삭제
  ///
  /// **Parameters**:
  /// - `imageUrl`: 삭제할 이미지 URL
  ///
  /// **Returns**:
  /// - `Right(true)`: 삭제 성공
  /// - `Left(ProfileFailure.storage)`: 삭제 실패
  Future<Either<ProfileFailure, bool>> deleteProfileImage(String imageUrl);
}
```

**Method Count**: 2개 메서드

**Why Separate Repository?**:
- Firebase Storage는 Firestore와 완전히 다른 서비스
- File 업로드는 CRUD 패턴과 다름
- UseCase가 Storage 작업을 명확히 인식 가능

---

## usecases/ - UseCases Deep Dive

UseCases는 비즈니스 로직을 캡슐화하고 단일 책임 원칙을 구현합니다. 각 UseCase는 하나의 비즈니스 작업만 수행합니다.

### UseCase Architecture Pattern

**Standard Pattern**:
```dart
class SomeUseCase {
  final ISomeRepository _repository;

  SomeUseCase({required ISomeRepository repository})
      : _repository = repository;

  /// UseCase 실행
  ///
  /// **Parameters**: 필요한 파라미터
  ///
  /// **Returns**:
  /// - `Right(T)`: 성공
  /// - `Left(ProfileFailure)`: 실패
  Future<Either<ProfileFailure, T>> execute({...}) async {
    try {
      // 1. 입력 검증
      if (invalid) {
        return left(ProfileFailure.validation('field'));
      }

      // 2. Repository 호출
      final result = await _repository.someMethod(...);

      // 3. 결과 반환 (Repository가 이미 Either 반환)
      return result;
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

**Stream Pattern** (Real-time):
```dart
class WatchSomeUseCase {
  final ISomeRepository _repository;

  WatchSomeUseCase(this._repository);

  /// 실시간 감시
  ///
  /// **Returns**: Stream<Either<ProfileFailure, T>>
  Stream<Either<ProfileFailure, T>> execute({...}) async* {
    try {
      await for (final data in _repository.watchSome(...)) {
        if (data == null) {
          yield left(ProfileFailure.someNotFound());
        } else {
          yield right(data);
        }
      }
    } on ProfileFailure catch (e) {
      yield left(e);
    } catch (error) {
      yield left(ProfileFailure.firestoreRead('Failed to watch: $error'));
    }
  }
}
```

### Profile UseCases (8 files)

#### 1. GetCurrentUserProfileUseCase

**Purpose**: 현재 로그인한 사용자 프로필 조회

**Phase 2 추가** (2025-01-20):
- AuthContract를 통한 현재 사용자 작업 지원
- UI는 누구의 프로필인지 신경 쓸 필요 없음

```dart
class GetCurrentUserProfileUseCase {
  final IUserRepository _repository;

  GetCurrentUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 현재 사용자 프로필 조회 실행
  ///
  /// **Parameters**: 없음 (Repository가 AuthContract로 ID 획득)
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> execute() async {
    try {
      return await _repository.getCurrentUserProfile();
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

**Difference from GetUserProfileUseCase**:
- ❌ `userId` 파라미터 불필요
- ✅ Repository가 AuthContract로 ID 획득
- ✅ Presentation 레이어는 현재 사용자 ID를 몰라도 됨

#### 2. GetUserProfileUseCase

**Purpose**: 특정 사용자 프로필 조회 (다른 사용자 프로필 볼 때)

```dart
class GetUserProfileUseCase {
  final IUserRepository _repository;

  GetUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.getUserByUid(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 3. WatchUserProfileUseCase ⭐

**Purpose**: 사용자 프로필 실시간 감시 (Stream)

**Key Features**:
- 🔄 **Real-time Updates**: Firestore WebSocket 기반
- 📡 **Auto Reconnect**: 네트워크 끊김 시 자동 재연결
- ⚡ **Efficient**: 문서 변경 시에만 이벤트 발생

**Real-World Scenario**:
```
시나리오: 철수가 프로필을 수정하는데, 영희가 철수 프로필을 보고 있음

T+0s   영희: 철수 프로필 화면 진입
       → watchUserProfile('cheolsu_id') 시작
       → 현재 프로필 표시

T+10s  철수: 프로필 사진 + 소개글 수정
       → updateUserProfile() 호출
       → Firestore 문서 업데이트

T+10.2s 영희: 자동으로 새 프로필 표시! 🎉
       → Firestore가 스트림에 새 데이터 푸시
       → StreamBuilder가 UI 리빌드
       → 수동 새로고침 불필요
```

```dart
class WatchUserProfileUseCase {
  final IUserRepository _repository;

  WatchUserProfileUseCase(this._repository);

  /// 사용자 프로필 실시간 감시
  ///
  /// **Returns**: Stream<Either<ProfileFailure, UserProfile>>
  Stream<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async* {
    try {
      await for (final profile in _repository.watchUserProfile(userId)) {
        if (profile == null) {
          yield left(ProfileFailure.profileNotFound(userId: userId));
        } else {
          yield right(profile);
        }
      }
    } on ProfileFailure catch (e) {
      yield left(e);
    } catch (error) {
      yield left(ProfileFailure.firestoreRead('Failed to watch user profile: $error'));
    }
  }
}
```

**UI Usage Example**:
```dart
// Provider
Stream<UserProfile?> watchOtherUserProfile(String userId) {
  return _watchProfileUseCase
      .execute(userId: userId)
      .map((either) => either.fold(
            (failure) {
              _errorMessage = failure.message;
              notifyListeners();
              return null;
            },
            (profile) => profile,
          ));
}

// Widget
StreamBuilder<UserProfile?>(
  stream: provider.watchOtherUserProfile('user_123'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final profile = snapshot.data!;
      return ProfileHeader(profile: profile);  // 자동 업데이트!
    }
    return LoadingIndicator();
  },
);
```

#### 4. UpdateUserProfileUseCase

**Purpose**: 사용자 프로필 업데이트

**Key Features**:
- ✅ **입력 검증**: uid, email 필수 필드 체크
- ⚡ **Idempotency**: eventId 지원으로 중복 작업 방지

```dart
class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  UpdateUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, Unit>> execute({
    required UserProfile user,
    String? eventId,
  }) async {
    try {
      // 입력 검증
      if (user.uid.isEmpty) {
        return left(ProfileFailure.validation('uid'));
      }
      if (user.email.isEmpty) {
        return left(ProfileFailure.validation('email'));
      }

      return await _repository.updateUserProfile(user, eventId: eventId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 5. DeleteUserProfileUseCase

**Purpose**: 사용자 프로필 삭제 (계정 탈퇴)

```dart
class DeleteUserProfileUseCase {
  final IUserRepository _repository;

  DeleteUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
    String? eventId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.deleteUser(userId, eventId: eventId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 6. GetProfileInfoUseCase

**Purpose**: 경량 프로필 정보 조회 (10 fields)

**Performance**:
- 📊 **75% 대역폭 절감**: 42개 → 10개 필드
- 🚀 **빠른 로딩**: 목록 표시에 최적화

```dart
class GetProfileInfoUseCase {
  final IProfileRepository _repository;

  GetProfileInfoUseCase({required IProfileRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, ProfileInfo>> execute({
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.getProfileInfo(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 7. GetProfileCompletionUseCase

**Purpose**: 프로필 완성도 퍼센트 조회

```dart
class GetProfileCompletionUseCase {
  final IProfileRepository _repository;

  GetProfileCompletionUseCase({required IProfileRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, double>> execute({
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.getProfileCompletionPercentage(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 8. UploadProfileImageUseCase

**Purpose**: 프로필 이미지 업로드

**Key Features**:
- ✅ **파일 검증**: 존재 여부 + 크기 제한 (10MB)
- 📁 **Storage 작업**: IProfileStorageRepository 사용

```dart
class UploadProfileImageUseCase {
  final IProfileStorageRepository _storageRepository;

  UploadProfileImageUseCase({
    required IProfileStorageRepository storageRepository,
  }) : _storageRepository = storageRepository;

  Future<Either<ProfileFailure, String>> execute({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }
      if (!imageFile.existsSync()) {
        return left(ProfileFailure.validation('imageFile'));
      }

      // 2. 파일 크기 검증 (10MB 제한)
      final fileSize = imageFile.lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        return left(ProfileFailure.validation('imageFile.size'));
      }

      // 3. Storage 업로드 실행
      return await _storageRepository.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.storage(e.toString()));
    }
  }
}
```

### Settings UseCases (2 files)

#### 1. GetUserSettingsUseCase

**Purpose**: 사용자 설정 조회

```dart
class GetUserSettingsUseCase {
  final ISettingsRepository _repository;

  GetUserSettingsUseCase({required ISettingsRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, UserSettings>> execute({
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.getUserSettings(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 2. UpdateUserSettingsUseCase

**Purpose**: 사용자 설정 업데이트

```dart
class UpdateUserSettingsUseCase {
  final ISettingsRepository _repository;

  UpdateUserSettingsUseCase({required ISettingsRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
    required UserSettings settings,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.updateUserSettings(userId, settings);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

### Characters UseCases (1 file)

#### 1. GetAvailableCharactersUseCase

**Purpose**: 사용 가능한 캐릭터 목록 조회

```dart
class GetAvailableCharactersUseCase {
  final ICharactersRepository _repository;

  GetAvailableCharactersUseCase({required ICharactersRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, List<Character>>> execute() async {
    try {
      return await _repository.getAvailableCharacters();
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

### Interests UseCases (2 files)

#### 1. GetUserInterestsUseCase

**Purpose**: 사용자 관심사 조회

```dart
class GetUserInterestsUseCase {
  final IInterestsRepository _repository;

  GetUserInterestsUseCase({required IInterestsRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, List<Interest>>> execute({
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      return await _repository.getUserInterests(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

#### 2. UpdateUserInterestsUseCase

**Purpose**: 사용자 관심사 업데이트

**Key Features**:
- ✅ **제약사항 검증**: expertise 최대 4개, hobbies 최대 8개
- ⚡ **Idempotency**: eventId 지원

```dart
class UpdateUserInterestsUseCase {
  final IInterestsRepository _repository;

  UpdateUserInterestsUseCase({required IInterestsRepository repository})
      : _repository = repository;

  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
    required List<Interest> interests,
    String? eventId,
  }) async {
    try {
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      // 제약사항 검증은 Repository에서 수행
      return await _repository.updateUserInterests(
        userId,
        interests,
        eventId: eventId,
      );
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
```

---

## Clean Architecture v4.0 Principles

### Dependency Rule (의존성 규칙)

```
┌─────────────────────────────────────────────┐
│  Presentation Layer (UI, Providers)        │
│  ↓ depends on (UseCase Interface)          │
├─────────────────────────────────────────────┤
│  Domain Layer (Business Logic)             │  ← 이 레이어!
│  - UseCases                                 │
│  - Repository Interfaces                    │
│  - Models (Entities)                        │
│  - Failures                                 │
│  ↑ NO dependencies on outer layers!        │
├─────────────────────────────────────────────┤
│  Data Layer (Firebase, Cache)              │
│  ↓ implements (Repository Interface)       │
└─────────────────────────────────────────────┘
```

**핵심 원칙**:
1. ✅ Domain Layer는 **순수 Dart만** 의존
2. ❌ Flutter, Firebase 등 외부 프레임워크 의존성 **절대 금지**
3. ✅ Repository는 **인터페이스만** 정의, 구현은 Data Layer
4. ✅ UseCase는 **하나의 비즈니스 작업만** 수행

### Testability (테스트 가능성)

**Domain Layer는 100% 단위 테스트 가능**:

```dart
// ✅ Mock Repository로 UseCase 테스트 가능
class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  group('GetUserProfileUseCase', () {
    late MockUserRepository mockRepository;
    late GetUserProfileUseCase useCase;

    setUp(() {
      mockRepository = MockUserRepository();
      useCase = GetUserProfileUseCase(repository: mockRepository);
    });

    test('should return UserProfile when repository call succeeds', () async {
      // Arrange
      final testProfile = UserProfile(uid: '123', email: 'test@test.com');
      when(() => mockRepository.getUserByUid('123'))
          .thenAnswer((_) async => right(testProfile));

      // Act
      final result = await useCase.execute(userId: '123');

      // Assert
      expect(result, right(testProfile));
      verify(() => mockRepository.getUserByUid('123')).called(1);
    });
  });
}
```

### Type Safety (타입 안전성)

**Either<L, R> 패턴으로 컴파일 타임 에러 처리**:

```dart
// ✅ 타입 안전한 에러 처리
final result = await useCase.execute(userId: '123');

result.fold(
  (failure) {
    // ProfileFailure 타입 보장
    failure.when(
      profileNotFound: (userId) => print('User not found: $userId'),
      network: () => print('Network error'),
      // 모든 케이스 처리 강제 (컴파일 에러)
      orElse: () {},
    );
  },
  (profile) {
    // UserProfile 타입 보장
    print('Loaded profile: ${profile.displayName}');
  },
);
```

### Freezed Pattern Benefits

**Freezed를 사용한 불변성 및 생산성 향상**:

```dart
@freezed
sealed class UserProfile with _$UserProfile {
  const UserProfile._();
  const factory UserProfile({...}) = _UserProfile;

  // ✅ 자동 생성되는 기능들
  // - copyWith() - 부분 업데이트
  // - ==, hashCode - 값 비교
  // - toString() - 디버깅
  // - fromJson/toJson - JSON 직렬화
}

// 사용 예시
final updatedProfile = profile.copyWith(
  displayName: '새 이름',
  photoUrl: 'new_url',
);

// 값 비교 (Equatable 자동)
if (profile1 == profile2) {
  print('Same profile!');
}
```

---

## Freezed Pattern Guide

Profile Feature는 모든 Domain Models에서 Freezed 패턴을 100% 사용합니다.

### Why Freezed?

1. **Immutability**: 모든 필드가 final, 불변성 보장
2. **CopyWith**: 부분 업데이트 편리
3. **Equality**: == 연산자 자동 구현
4. **JSON Serialization**: fromJson/toJson 자동 생성
5. **Pattern Matching**: when/map 메서드 지원
6. **Code Reduction**: 70% 이상 boilerplate 코드 제거

### Freezed Model Template

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_name.freezed.dart';
part 'model_name.g.dart';

/// Model documentation
@freezed
sealed class ModelName with _$ModelName {
  const ModelName._();

  const factory ModelName({
    required String id,
    required String name,
    @Default('default') String description,
    @Default([]) List<String> tags,
  }) = _ModelName;

  factory ModelName.fromJson(Map<String, dynamic> json) =>
      _$ModelNameFromJson(json);

  // ============= Business Logic Getters =============

  /// Business logic getter example
  bool get hasDescription => description.isNotEmpty;
}
```

### Code Generation

```bash
# Freezed 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# Watch 모드 (파일 변경 시 자동 생성)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Freezed vs Manual

**Before Freezed** (352 lines):
```dart
class UserProfile {
  final String uid;
  final String email;
  // ... 42 fields

  UserProfile({required this.uid, required this.email, ...});

  // copyWith (50 lines)
  UserProfile copyWith({String? uid, String? email, ...}) { ... }

  // fromJson (80 lines)
  factory UserProfile.fromJson(Map<String, dynamic> json) { ... }

  // toJson (80 lines)
  Map<String, dynamic> toJson() { ... }

  // == operator (30 lines)
  @override
  bool operator ==(Object other) { ... }

  // hashCode (30 lines)
  @override
  int get hashCode { ... }

  // toString (30 lines)
  @override
  String toString() { ... }
}
```

**After Freezed** (107 lines, 70% reduction):
```dart
@freezed
sealed class UserProfile with _$UserProfile {
  const UserProfile._();
  const factory UserProfile({...}) = _UserProfile;
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  // Business logic only
  int get totalPoints => pointsA + pointsQ;
}
```

---

## Dependency Diagram

### Repository Dependency Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                          │
│  (ProfileProvider, SettingsProvider, CharactersProvider, etc.)     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ depends on
                           ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          Domain Layer                                │
│  ┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │   UseCases      │  │ Repository       │  │ Models/Failures  │  │
│  │                 │→ │ Interfaces       │  │                  │  │
│  │ - GetUser       │  │ - IUserRepo      │  │ - UserProfile    │  │
│  │ - UpdateUser    │  │ - IProfileRepo   │  │ - ProfileInfo    │  │
│  │ - WatchUser     │  │ - ISettingsRepo  │  │ - UserSettings   │  │
│  │ - UploadImage   │  │ - ICharacters    │  │ - Character      │  │
│  │ - GetInterests  │  │ - IInterests     │  │ - Interest       │  │
│  └─────────────────┘  │ - IStorage       │  │ - ProfileFailure │  │
│                       └──────────────────┘  └──────────────────┘  │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ implements
                           ↓
┌─────────────────────────────────────────────────────────────────────┐
│                           Data Layer                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           Repository Implementations                         │   │
│  │  - UserRepositoryImpl      (Singleton + Dual Interface)     │   │
│  │  - ProfileRepositoryImpl   (3 methods only)                 │   │
│  │  - SettingsRepositoryImpl  (2 methods)                      │   │
│  │  - CharactersRepositoryImpl (1 method)                      │   │
│  │  - InterestsRepositoryImpl  (4 methods)                     │   │
│  │  - ProfileStorageRepositoryImpl (2 methods)                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────┐  ┌───────────────┐  ┌─────────────────────┐     │
│  │ Extensions   │  │ Services      │  │ DataSources         │     │
│  │              │  │               │  │                     │     │
│  │ - UserProfile│  │ - Unified     │  │ - ProfileStorage    │     │
│  │   Firestore  │  │   Cache       │  │   DataSource        │     │
│  │ - ProfileInfo│  │ - Idempotency │  │                     │     │
│  │   Firestore  │  │ - Auth        │  │                     │     │
│  │ - Settings   │  │   Contract    │  │                     │     │
│  │   Firestore  │  │               │  │                     │     │
│  └──────────────┘  └───────────────┘  └─────────────────────┘     │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Firebase SDK                              │   │
│  │  - FirebaseFirestore (직접 사용)                            │   │
│  │  - FirebaseStorage (ProfileStorageDataSource를 통해)       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

### UserContract Sharing Pattern

**UserRepositoryImpl의 이중 역할**:

```
┌───────────────────────────────────────────────────────────────────┐
│                    Feature Boundaries                             │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐      ┌──────────────┐      ┌──────────────┐   │
│  │Auth Feature │      │Chat Feature  │      │Posts Feature │   │
│  │             │      │              │      │              │   │
│  │ - Login     │      │ - Messages   │      │ - Create Post│   │
│  │ - Signup    │      │ - ChatList   │      │ - Comments   │   │
│  │ - Logout    │      │              │      │              │   │
│  └──────┬──────┘      └──────┬───────┘      └──────┬───────┘   │
│         │                    │                     │           │
│         └────────────────────┼─────────────────────┘           │
│                              │                                 │
│                              ↓                                 │
│                    ┌──────────────────┐                        │
│                    │  UserContract    │  ← Interface           │
│                    │ (app/contracts/) │                        │
│                    └──────────────────┘                        │
│                              ↑                                 │
│                     implements by                              │
│                              │                                 │
│         ┌────────────────────┴────────────────────┐            │
│         │                                         │            │
│         ↓                                         ↓            │
│  ┌──────────────────┐              ┌──────────────────────┐   │
│  │ IUserRepository  │              │ UserContract         │   │
│  │ (Profile Domain) │              │ (App Contracts)      │   │
│  └──────────────────┘              └──────────────────────┘   │
│         ↑                                         ↑            │
│         │                                         │            │
│         └─────────────────┬─────────────────────┘            │
│                           │                                   │
│                           │ implements both                   │
│                           ↓                                   │
│              ┌───────────────────────────┐                    │
│              │ UserRepositoryImpl        │                    │
│              │ (Profile Data Layer)      │                    │
│              │                           │                    │
│              │ - Singleton Pattern       │                    │
│              │ - Dual Interface          │                    │
│              │ - Global Access           │                    │
│              └───────────────────────────┘                    │
│                           ↓                                   │
│                    Firebase Firestore                         │
│                    UnifiedCacheService                        │
│                                                               │
└───────────────────────────────────────────────────────────────┘

Usage Example:

// Auth Feature에서 사용
final user = await _userContract.getUserProfile(userId);

// Chat Feature에서 사용
final participants = await Future.wait(
  userIds.map((id) => _userContract.getUserProfile(id))
);

// Posts Feature에서 사용
final author = await _userContract.getUserProfile(authorId);
```

**Key Benefits**:
- ✅ **Feature Isolation**: 각 Feature는 UserContract만 의존
- ✅ **Singleton Access**: UserRepositoryImpl.instance로 전역 접근
- ✅ **Type Safety**: Interface 기반 타입 안전성
- ✅ **Testability**: Mock UserContract로 테스트 가능

### 3-Layer Caching Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Repository Layer                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ UserRepositoryImpl / ProfileRepositoryImpl               │  │
│  │                                                          │  │
│  │ getUserProfile(userId) {                                │  │
│  │   // 🔥 3-Layer Cache 조회 (Memory → Hive → Firestore) │  │
│  │   final profile = await _cacheService.getUserProfile(); │  │
│  │ }                                                        │  │
│  └───────────────────────┬──────────────────────────────────┘  │
└──────────────────────────┼──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                UnifiedCacheService (Singleton)                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Cache Orchestrator - 3-Layer 자동 프로모션             │  │
│  │                                                          │  │
│  │ getUserProfile(userId) {                                │  │
│  │   // Layer 1: Memory Cache                              │  │
│  │   if (memoryCache.has(key)) {                           │  │
│  │     return memoryCache.get(key);  // 🚀 <10ms          │  │
│  │   }                                                      │  │
│  │                                                          │  │
│  │   // Layer 2: Hive (Local DB)                           │  │
│  │   if (hiveCache.has(key)) {                             │  │
│  │     final data = hiveCache.get(key);                    │  │
│  │     memoryCache.set(key, data);  // ⬆️ Promote to L1   │  │
│  │     return data;  // ⚡ 10-30ms                          │  │
│  │   }                                                      │  │
│  │                                                          │  │
│  │   // Layer 3: Firestore (Remote + Offline Cache)        │  │
│  │   final doc = await firestore.get(userId);              │  │
│  │   final profile = UserProfileFirestore.fromFirestore(); │  │
│  │   hiveCache.set(key, profile);   // ⬆️ Promote to L2    │  │
│  │   memoryCache.set(key, profile); // ⬆️ Promote to L1    │  │
│  │   return profile;  // 🌐 300-500ms                       │  │
│  │ }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
┌──────────────┐  ┌────────────────┐  ┌────────────────┐
│   L1 Memory  │  │   L2 Hive      │  │ L3 Firestore   │
│   Cache      │  │   (Local DB)   │  │ (Remote + Off) │
├──────────────┤  ├────────────────┤  ├────────────────┤
│ SimpleMemory │  │ box.get(key)   │  │ Firebase SDK   │
│ Cache        │  │                │  │ + Offline      │
│              │  │ Persistent     │  │ Cache          │
│ LRU Eviction │  │ Unlimited Size │  │                │
│ 100 items    │  │                │  │ Auto Sync      │
│ 5min TTL     │  │ 24h TTL        │  │                │
├──────────────┤  ├────────────────┤  ├────────────────┤
│ Response:    │  │ Response:      │  │ Response:      │
│ <10ms        │  │ 10-30ms        │  │ 300-500ms      │
│ 60%+ Hit     │  │ 30% Hit        │  │ Cache Miss     │
└──────────────┘  └────────────────┘  └────────────────┘
```

**Performance Metrics**:
- 앱 재시작 후 성능: 300-500ms → 10-30ms (95% ↑)
- 오프라인 지원: 0% → 100%
- Firestore 비용: 97% 절감

---

## Best Practices

### 1. Repository 선택 가이드

**어떤 Repository를 사용해야 할까?**

| 작업 | Repository | 이유 |
|------|-----------|------|
| **전체 프로필 조회** | IUserRepository | 42개 필드 모두 필요 |
| **목록 표시** | IProfileRepository | 10개 필드만, 75% 대역폭 절감 |
| **프로필 완성도** | IProfileRepository | 완성도 계산 전용 |
| **설정 관리** | ISettingsRepository | 설정 전용 |
| **관심사 관리** | IInterestsRepository | 제약사항 검증 포함 |
| **캐릭터 선택** | ICharactersRepository | 캐릭터 목록 조회 |
| **이미지 업로드** | IProfileStorageRepository | Storage 작업 |

### 2. UseCase 패턴

**✅ DO**:
```dart
// 하나의 UseCase는 하나의 작업만
class GetUserProfileUseCase {
  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async {
    // 1. 검증
    if (userId.isEmpty) {
      return left(ProfileFailure.validation('userId'));
    }

    // 2. Repository 호출
    return await _repository.getUserByUid(userId);
  }
}
```

**❌ DON'T**:
```dart
// UseCase에 여러 작업 넣지 말기
class UserProfileUseCase {
  Future<Either<ProfileFailure, Map<String, dynamic>>> execute({
    required String userId,
  }) async {
    final profile = await _repository.getUserByUid(userId);
    final settings = await _repository.getUserSettings(userId);
    final interests = await _repository.getUserInterests(userId);

    // ❌ 여러 작업을 하나의 UseCase에 넣지 말 것
    return right({
      'profile': profile,
      'settings': settings,
      'interests': interests,
    });
  }
}
```

### 3. Real-time Sync 활용

**✅ DO** - 다른 사용자 프로필 볼 때:
```dart
// Stream으로 실시간 업데이트
Stream<UserProfile?> watchOtherUserProfile(String userId) {
  return _watchProfileUseCase
      .execute(userId: userId)
      .map((either) => either.getOrElse(null));
}
```

**❌ DON'T** - 현재 사용자 프로필:
```dart
// 현재 사용자는 Future로 충분 (setState로 업데이트)
Future<UserProfile?> getCurrentUserProfile() async {
  final result = await _getCurrentUserProfileUseCase.execute();
  return result.getOrElse(null);
}
```

### 4. Idempotency 활용

**✅ DO** - 중요한 작업에 eventId 전달:
```dart
// 프로필 업데이트 시 중복 방지
await updateUserProfileUseCase.execute(
  user: updatedProfile,
  eventId: 'profile_update_${DateTime.now().millisecondsSinceEpoch}',
);
```

**❌ DON'T** - 읽기 작업에 eventId 불필요:
```dart
// ❌ 조회 작업에는 eventId 불필요
await getUserProfileUseCase.execute(
  userId: userId,
  eventId: 'unnecessary', // 의미 없음
);
```

### 5. Failure 처리

**✅ DO** - Pattern Matching:
```dart
result.fold(
  (failure) {
    failure.when(
      profileNotFound: (userId) => _showError('프로필 없음'),
      network: () => _showError('네트워크 오류'),
      validation: (field) => _showError('입력 오류: $field'),
      orElse: () => _showError(failure.message),
    );
  },
  (profile) => _displayProfile(profile),
);
```

**❌ DON'T** - if-else 체인:
```dart
// ❌ Freezed의 when을 활용하지 않음
if (failure is ProfileNotFound) {
  _showError('프로필 없음');
} else if (failure is NetworkFailure) {
  _showError('네트워크 오류');
} else {
  _showError(failure.message);
}
```

---

## Migration History

### Phase 1: FlutterFlow → Pure Domain Models (2025-01-20)

**Before**:
- FirestoreRecord 상속
- Firebase 타입 직접 사용 (GeoPoint, Timestamp)
- 352줄의 boilerplate 코드

**After**:
- 순수 Dart 클래스
- LatLng, DateTime 사용
- Freezed sealed class (107줄, 70% 감소)

**Changes**:
```dart
// Before
class UserProfile extends FirebaseRecord {
  final String _uid;
  final GeoPoint? _location;

  String get uid => _uid;
  GeoPoint? get location => _location;

  UserProfile copyWith({...}) { ... } // 50 lines
}

// After
@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    @JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng? location,
  }) = _UserProfile;
}
```

### Phase 2: AuthContract Integration (2025-01-20)

**Added**:
- `getCurrentUserProfile()` - Repository에서 AuthContract로 현재 사용자 ID 획득
- `updateCurrentUserProfile()` - 보안 검증 포함
- `GetCurrentUserProfileUseCase` - UI는 userId를 몰라도 됨

**Benefits**:
- Presentation 레이어가 AuthContract에 의존하지 않음
- 단일 책임 원칙 준수
- 테스트 용이성 향상

### Phase 3: Firebase 타입 제거 (2025-01-20)

**Changes**:
- CollectionReference, DocumentReference, Query 제거
- 모든 메서드가 String uid 기반으로 변경
- 레거시 Query 메서드들 @Deprecated 처리

**Benefits**:
- Domain Layer가 Infrastructure에 의존하지 않음
- Clean Architecture 원칙 100% 준수

### Phase 4: Firebase-Centric v2.0 전환 (2025-01-29)

**Changes**:
- DataSource 제거 → FirebaseFirestore 직접 사용
- Extension 패턴으로 Entity ↔ Firestore 변환
- Auth Feature 패턴 100% 일치
- _mapFirebaseException() 메서드 추가

**Files**:
- user_profile_extensions.dart 생성 (314 lines)
- Adapter/Mapper 클래스 삭제

### Phase 6: 대규모 정리 (2025-01-21)

**IProfileRepository**:
- 20개 → 3개 메서드로 축소 (85% 감소)
- 호출처 0건 메서드 완전 삭제
- 프로필 완성도 + 경량 조회 메서드만 보존

**Deleted Methods**:
- ProfileInfo 관리 (2개)
- UserSettings 관리 (3개)
- UserStats 관리 (3개)
- 필드 업데이트 (2개)
- 프로필 사진 관리 (2개)
- 관심사 조회 (1개)
- 프로필 완성도 상세 (1개)
- 검색 및 추천 (2개)
- 소셜 기능 (4개)

**Total**: 20개 메서드 삭제

### Phase 7: 3-Layer 캐싱 시스템 통합 (2025-01-30)

**Changes**:
- SimpleMemoryCache → UnifiedCacheService 전환
- Memory → Hive → Firestore 3-Layer 캐싱 적용
- 앱 재시작 후 성능: 300-500ms → 10-30ms (95% ↑)
- 오프라인 지원: 0% → 100%
- Firestore 비용: 97% 절감

**Implementation**:
- CharactersRepositoryImpl: 완전 캐시 위임
- ProfileRepositoryImpl: 3-Layer Cache 조회
- UserRepositoryImpl: 캐시 서비스 통합

---

## References

### Related Documents

- [Profile Data Layer README](../data/README.md) - Repository 구현체 상세 설명
- [Profile Models README](./models/README.md) - Domain Models 상세 문서
- [Auth Domain Layer](../../auth/domain/README.md) - 유사 패턴 참조
- [Voting Domain Layer](../../voting/domain/README.md) - Domain Layer 패턴 참조

### Architecture Documents

- [Clean Architecture v4.0](../../../../docs/architecture/clean-architecture-v4.md)
- [Firebase-Centric v2.0](../../../../docs/architecture/firebase-centric-v2.md)
- [3-Layer Caching](../../../../docs/architecture/3-layer-caching.md)

### External Resources

- [Freezed Package](https://pub.dev/packages/freezed)
- [Dartz Package](https://pub.dev/packages/dartz)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2025-01-30 | v1.0.0 | Initial Domain Layer README creation |
| 2025-01-30 | v1.0.0 | 6 Repository Interfaces documented |
| 2025-01-30 | v1.0.0 | 13 UseCases documented |
| 2025-01-30 | v1.0.0 | 6 Domain Models detailed |
| 2025-01-30 | v1.0.0 | 12 ProfileFailure types explained |
| 2025-01-30 | v1.0.0 | Migration History (Phase 1-7) documented |

---

**Last Updated**: 2025-01-30
**Total Lines**: ~1,500 lines
**Status**: ✅ Complete
