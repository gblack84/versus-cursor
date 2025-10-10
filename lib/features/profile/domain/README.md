# Profile Feature - Domain Layer

> 최종 업데이트: 2025-01-26 | 버전: 4.0.0 | Clean Architecture v4.0

## 🎯 개요

Domain Layer는 Clean Architecture의 가장 내부 계층으로, **비즈니스 로직과 규칙**을 정의합니다. 이 계층은 프레임워크, UI, 데이터베이스 등 외부 요소에 **전혀 의존하지 않는** 순수한 Dart 코드로 구성됩니다.

### 📌 현재 구현 상태

- ✅ **models**: 12개 Domain Models 구현 완료
  - UserProfile, UserSettings, FriendsListModel
  - CharactersModel, OnboardingProgress
  - JobCategory, Interest, Premium
- ✅ **repositories**: 3개 인터페이스 정의
  - IUserRepository (사용자 프로필)
  - IFriendsRepository (친구 목록)
  - ICharacterRepository (캐릭터)
- ⏳ **usecases**: 구현 예정 (Phase 2)
  - GetUserProfileUseCase, UpdateProfileUseCase
  - CompleteOnboardingStepUseCase
- ⏳ **services**: 구현 예정 (Phase 2)
  - IProfileValidationService
  - IOnboardingProgressService
- ⏳ **failures**: 구현 예정 (Phase 3)
  - ProfileFailures (8개 클래스)

### 핵심 원칙

- ✅ **독립성**: 외부 패키지나 프레임워크 의존성 없음
- ✅ **순수성**: 순수 Dart 코드만 사용 (Firebase, Flutter 의존성 제거 예정)
- ✅ **테스트 가능성**: 100% 단위 테스트 가능
- ✅ **비즈니스 중심**: 기술이 아닌 비즈니스 규칙에 집중
- ✅ **Feature 격리**: Profile/Settings/Onboarding만 책임, Auth Feature와 명확한 경계

---

## 🏗️ 전체 구조도

```
lib/features/profile/domain/
│
├── 📁 models/                  # 비즈니스 엔티티 (12개)
│   ├── user_profile.dart       # 사용자 프로필 (핵심)
│   ├── user_settings.dart      # 사용자 설정
│   ├── friends_list_model.dart # 친구 목록
│   ├── characters_model.dart   # 캐릭터/아바타
│   ├── onboarding_progress.dart # 온보딩 진행상태
│   ├── job_category.dart       # 직업 카테고리
│   ├── interest.dart           # 관심사/취미
│   ├── premium_model.dart      # 프리미엄 구독
│   ├── profile_stats.dart      # 프로필 통계
│   ├── notification_settings.dart # 알림 설정
│   ├── privacy_settings.dart   # 프라이버시 설정
│   ├── user_profile_bundle.dart # 프로필 번들
│   └── README.md               # Models 상세 문서
│
├── 📁 repositories/            # Repository 인터페이스 (3개)
│   ├── i_user_repository.dart  # 사용자 프로필 인터페이스
│   ├── i_friends_repository.dart # 친구 목록 인터페이스
│   └── i_character_repository.dart # 캐릭터 인터페이스
│
├── 📁 usecases/                # 비즈니스 유스케이스 (구현 예정)
│   ├── profile/
│   │   ├── get_profile_usecase.dart # 프로필 조회
│   │   ├── update_profile_usecase.dart # 프로필 수정
│   │   └── upload_avatar_usecase.dart # 아바타 업로드
│   ├── settings/
│   │   ├── change_settings_usecase.dart # 설정 변경
│   │   └── change_language_usecase.dart # 언어 변경
│   ├── onboarding/
│   │   ├── complete_onboarding_step_usecase.dart # 온보딩 단계 완료
│   │   └── get_onboarding_progress_usecase.dart # 진행상태 조회
│   └── README.md               # UseCases 상세 문서
│
├── 📁 services/                # 도메인 서비스 인터페이스 (구현 예정)
│   ├── i_profile_validation_service.dart # 프로필 검증
│   └── i_onboarding_progress_service.dart # 온보딩 진행
│
├── 📁 failures/                # 도메인 예외 (구현 예정)
│   └── profile_failures.dart   # Profile 전용 Failure 클래스
│
└── domain.dart                 # Domain Layer Exports
```

---

## 📂 디렉토리별 상세 설명

### 1. models/ - 비즈니스 엔티티

**목적**: 비즈니스 도메인의 핵심 개념을 표현하는 순수 데이터 모델

#### 1.1 핵심 모델

##### 📄 user_profile.dart
**책임**: 사용자 프로필의 모든 정보

```dart
class UserProfile extends Equatable {
  // Core Identity
  final String userId;              // 사용자 고유 ID
  final String? displayName;        // 표시 이름
  final String? email;              // 이메일
  final String? photoUrl;           // 프로필 사진 URL
  final String? phoneNumber;        // 전화번호

  // Timestamps
  final DateTime? createdTime;      // 가입 시간
  final DateTime? lastActive;       // 마지막 활동 시간

  // Profile Info
  final String? bio;                // 자기소개 (150자 제한)
  final String? website;            // 웹사이트
  final String? username;           // 사용자명 (고유)
  final bool isPublic;              // 공개 프로필 여부

  // Points & Ranking
  final int pointsA;                // 답변 포인트
  final int pointsQ;                // 질문 포인트
  final int totalPoints;            // 총 포인트
  final int? rank;                  // 랭킹 순위

  // Job & Interests
  final String? jobCategory;        // 직업 카테고리
  final String? jobName;            // 직업명
  final List<String> expertise;     // 전문분야 (최대 4개)
  final List<String> hobbies;       // 취미 (최대 8개)
  final List<String> interests;     // 관심사 통합

  // Friends & Social
  final List<String> friends;       // 친구 ID 리스트
  final List<String> blockedUsers;  // 차단 사용자 리스트

  // Character
  final String? characterId;        // 캐릭터 ID
  final String? characterUrl;       // 캐릭터 이미지 URL

  // Settings
  final String language;            // 언어 설정 (en, de)
  final Map<String, dynamic>? notificationSettings; // 알림 설정
  final Map<String, dynamic>? privacySettings;      // 프라이버시 설정

  // Premium
  final bool isPremiumUser;         // 프리미엄 여부
  final DateTime? premiumExpiresAt; // 프리미엄 만료 시간

  // Onboarding
  final bool isOnboardingComplete;  // 온보딩 완료 여부
  final String? onboardingStep;     // 현재 온보딩 단계

  // System
  final String? role;               // 역할 (admin, tester, user)
  final String? uid;                // Firebase Auth UID (동기화)
}
```

**특징**:
- 🎯 불변 객체 (immutable) - `const` 생성자
- 🔒 Firebase 의존성 제거 예정 - `Map<String, dynamic>` 활용
- 🛡️ Null safety 완벽 지원
- 📦 `fromMap()`, `toMap()`, `toJson()`, `fromJson()` 제공
- 🔄 Equatable 상속 - 값 비교 가능

**Feature 경계**:
- ✅ Profile Feature 책임: UserProfile 전체 필드
- ❌ Auth Feature 책임: 로그인/로그아웃, 이메일 인증
- ❌ Post Feature 책임: 게시물 생성, 투표 관리

##### 📄 user_settings.dart
**책임**: 사용자 설정 (알림, 언어, 프라이버시)

```dart
class UserSettings extends Equatable {
  final String userId;              // 사용자 ID

  // Notification Settings (알림 설정)
  final bool notifyOnVoteRequests;  // 투표 요청 알림
  final bool notifyOnComments;      // 댓글 알림
  final bool notifyOnLikes;         // 좋아요 알림
  final bool notifyOnFriendRequests; // 친구 요청 알림
  final bool notifyOnMessages;      // 메시지 알림

  // Language Settings (언어 설정)
  final String language;            // 'en', 'de'

  // Privacy Settings (프라이버시 설정)
  final Map<String, bool> privacySettings; // {showEmail, showPhone, showProfile}

  // Display Settings (표시 설정)
  final bool showOnlineStatus;      // 온라인 상태 표시
  final bool allowFriendRequests;   // 친구 요청 허용

  // 비즈니스 메서드
  bool get hasNotifications => notifyOnVoteRequests || notifyOnComments || notifyOnLikes;
  bool get isPublicProfile => privacySettings['showProfile'] ?? true;
}
```

**특징**:
- 📢 5개 알림 설정 (투표, 댓글, 좋아요, 친구, 메시지)
- 🌐 다국어 지원 (영어, 독일어)
- 🔒 프라이버시 설정 Map 기반 (유연한 확장)

##### 📄 friends_list_model.dart
**책임**: 친구 목록 및 소셜 관계

```dart
class FriendsListModel extends Equatable {
  final String userId;              // 사용자 ID
  final List<String> friendIds;     // 친구 ID 리스트
  final List<String> pendingRequests; // 대기 중 요청
  final List<String> sentRequests;  // 보낸 요청
  final DateTime? updatedAt;        // 마지막 업데이트

  // 비즈니스 메서드
  bool isFriend(String otherUserId) => friendIds.contains(otherUserId);
  bool hasPendingRequest(String otherUserId) => pendingRequests.contains(otherUserId);
  int get friendCount => friendIds.length;
}
```

##### 📄 characters_model.dart
**책임**: 캐릭터/아바타 정보

```dart
class CharactersModel extends Equatable {
  final String id;                  // 캐릭터 ID
  final String userId;              // 소유자 ID
  final String characterUrl;        // 캐릭터 이미지 URL
  final String? characterName;      // 캐릭터 이름
  final Map<String, dynamic>? metadata; // 메타데이터 (색상, 스타일 등)
  final DateTime createdAt;         // 생성 시간
  final bool isDefault;             // 기본 캐릭터 여부
}
```

#### 1.2 온보딩 모델

##### 📄 onboarding_progress.dart
**책임**: 온보딩 진행상태

```dart
class OnboardingProgress extends Equatable {
  final String userId;              // 사용자 ID
  final OnboardingStep currentStep; // 현재 단계
  final Map<String, dynamic> completedSteps; // 완료된 단계 데이터
  final DateTime? lastUpdated;      // 마지막 업데이트
  final bool isComplete;            // 온보딩 완료 여부

  // 비즈니스 메서드
  bool isStepCompleted(OnboardingStep step) => completedSteps.containsKey(step.name);
  double get progressPercentage => (completedSteps.length / OnboardingStep.values.length) * 100;
}

/// 온보딩 단계 Enum
enum OnboardingStep {
  ageAgreement,        // 1. 연령 동의 (13세 이상)
  jobSelection,        // 2. 직업 선택
  expertiseSelection,  // 3. 전문분야 선택 (최대 4개)
  hobbySelection,      // 4. 취미 선택 (최대 8개)
  characterCreation,   // 5. 캐릭터 생성
  profileSetup,        // 6. 프로필 설정 (displayName, bio)
}
```

**온보딩 플로우**:
```
1. AgeAgreement (13세 확인)
   ↓
2. JobSelection (직업 카테고리 → 직업명)
   ↓
3. ExpertiseSelection (전문분야 최대 4개)
   ↓
4. HobbySelection (취미 최대 8개)
   ↓
5. CharacterCreation (아바타 선택/생성)
   ↓
6. ProfileSetup (이름, 자기소개 입력)
   ↓
Complete (isOnboardingComplete = true)
```

#### 1.3 보조 모델

##### 📄 job_category.dart
```dart
class JobCategory extends Equatable {
  final String id;                  // 카테고리 ID
  final String name;                // 카테고리 이름
  final List<String> jobNames;      // 직업명 리스트
}
```

##### 📄 interest.dart
```dart
class Interest extends Equatable {
  final String id;                  // 관심사 ID
  final String name;                // 관심사 이름
  final String category;            // 카테고리 (expertise, hobby)
  final int weight;                 // 가중치 (인기도)
}
```

##### 📄 premium_model.dart
```dart
class PremiumModel extends Equatable {
  final String userId;              // 사용자 ID
  final bool isPremium;             // 프리미엄 여부
  final DateTime? startDate;        // 시작 날짜
  final DateTime? expiresAt;        // 만료 날짜
  final String? subscriptionType;   // 구독 타입 (monthly, yearly)
}
```

##### 📄 user_profile_bundle.dart
**책임**: 프로필 관련 모든 도메인 모델 통합

```dart
class UserProfileBundle extends Equatable {
  final UserProfile profile;        // 사용자 프로필
  final UserSettings settings;      // 설정 정보
  final FriendsListModel friendsList; // 친구 목록

  const UserProfileBundle({
    required this.profile,
    required this.settings,
    required this.friendsList,
  });

  // 편의 getter
  String get userId => profile.userId;
  String? get displayName => profile.displayName;
  bool get hasNotifications => settings.hasNotifications;
}
```

**특징**:
- 🎯 집합 루트 패턴 - UserProfileAdapter와 함께 사용
- 📦 여러 Domain Model을 하나로 통합
- 🔄 Equatable 상속 - 값 비교 가능

---

### 2. repositories/ - Repository 인터페이스

**목적**: Data Layer와의 계약을 정의하는 추상 인터페이스

#### 2.1 IUserRepository (핵심)

**파일**: `i_user_repository.dart`

**책임**: 사용자 프로필의 모든 작업 정의

```dart
abstract class IUserRepository {
  // ====== User CRUD Operations ======

  /// 사용자 조회
  Future<UserProfile?> getUser(String userId);

  /// 사용자 생성
  Future<void> createUser(UserProfile user);

  /// 사용자 업데이트
  Future<void> updateUser(UserProfile user);

  /// 사용자 삭제
  Future<void> deleteUser(String userId);

  // ====== User Query Operations ======

  /// 사용자 스트림 조회
  Stream<List<UserProfile>> queryUsers({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// 사용자 개수 조회
  Future<int> queryUsersCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // ====== Settings Operations ======

  /// 설정 조회
  Future<UserSettings?> getUserSettings(String userId);

  /// 설정 업데이트
  Future<void> updateUserSettings(String userId, UserSettings settings);

  // ====== Character Operations ======

  /// 캐릭터 조회
  Future<CharactersModel?> getUserCharacter(String userId);

  /// 캐릭터 업데이트
  Future<void> updateUserCharacter(String userId, CharactersModel character);

  // ====== Helper Methods ======

  /// Firestore 레퍼런스 조회
  DocumentReference getUserReference(String userId);

  /// 사용자 ID로 조회 (레거시)
  Future<UserProfile?> getUserById(String userId);
}
```

#### 2.2 IFriendsRepository

**파일**: `i_friends_repository.dart`

**책임**: 친구 목록 관리

```dart
abstract class IFriendsRepository {
  // ====== Friends CRUD Operations ======

  /// 친구 목록 조회
  Future<FriendsListModel?> getFriendsList(String userId);

  /// 친구 추가
  Future<void> addFriend(String userId, String friendId);

  /// 친구 삭제
  Future<void> removeFriend(String userId, String friendId);

  // ====== Friend Request Operations ======

  /// 친구 요청 보내기
  Future<void> sendFriendRequest(String fromUserId, String toUserId);

  /// 친구 요청 수락
  Future<void> acceptFriendRequest(String userId, String requesterId);

  /// 친구 요청 거절
  Future<void> rejectFriendRequest(String userId, String requesterId);

  // ====== Query Operations ======

  /// 친구 목록 스트림
  Stream<List<FriendsListModel>> queryFriendsList({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// 친구 개수 조회
  Future<int> queryFriendsListCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });
}
```

#### 2.3 ICharacterRepository

**파일**: `i_character_repository.dart`

**책임**: 캐릭터/아바타 관리

```dart
abstract class ICharacterRepository {
  // ====== Character CRUD Operations ======

  /// 캐릭터 조회
  Future<CharactersModel?> getCharacter(String characterId);

  /// 캐릭터 생성
  Future<String> createCharacter(CharactersModel character);

  /// 캐릭터 업데이트
  Future<void> updateCharacter(String characterId, CharactersModel character);

  /// 캐릭터 삭제
  Future<void> deleteCharacter(String characterId);

  // ====== Query Operations ======

  /// 캐릭터 스트림 조회
  Stream<List<CharactersModel>> queryCharacters({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// 캐릭터 개수 조회
  Future<int> queryCharactersCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });
}
```

---

### 3. usecases/ - 비즈니스 유스케이스 (구현 예정)

**목적**: 단일 비즈니스 작업을 수행하는 순수 로직

#### 3.1 profile/ - 프로필 관련 UseCases

##### 📄 GetUserProfileUseCase
**책임**: 프로필 조회 비즈니스 로직

```dart
class GetUserProfileUseCase {
  final IUserRepository _userRepository;

  /// 프로필 조회
  Future<Result<UserProfile>> execute({
    required String userId,
    bool forceRefresh = false,
    bool allowIncomplete = true,
  }) async {
    // 1. 캐시 확인 (forceRefresh = false일 때만)
    // 2. Firestore 조회
    // 3. 온보딩 완료 여부 검증
    // 4. 프로필 통계 업데이트 (비동기)
    // 5. UserProfile 반환
  }
}
```

##### 📄 UpdateProfileUseCase
**책임**: 프로필 업데이트 비즈니스 로직

```dart
class UpdateProfileUseCase {
  final IUserRepository _userRepository;
  final IProfileValidationService _validationService;
  final IMediaRepository _mediaRepository;

  /// 프로필 업데이트
  Future<Result<void>> execute({
    required String userId,
    String? displayName,
    String? photoUrl,
    List<int>? photoBytes,
    String? bio,
    String? jobCategory,
    String? jobName,
    List<String>? expertise,
    List<String>? hobbies,
  }) async {
    // 1. 입력 검증
    // 2. 권한 확인 (본인만 수정 가능)
    // 3. 이미지 업로드 (photoBytes가 있을 경우)
    // 4. UserProfile 업데이트
    // 5. 캐시 무효화
    // 6. 이벤트 발행 (프로필 변경됨)
  }
}
```

**UpdateProfileParams**:
```dart
class UpdateProfileParams {
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final List<int>? photoBytes;
  final String? bio;
  final String? jobCategory;
  final String? jobName;
  final List<String>? expertise;
  final List<String>? hobbies;
}
```

##### 📄 UploadAvatarUseCase
**책임**: 아바타 업로드 비즈니스 로직

```dart
class UploadAvatarUseCase {
  final IMediaRepository _mediaRepository;
  final IUserRepository _userRepository;

  /// 아바타 업로드
  Future<Result<String>> execute({
    required String userId,
    required List<int> imageBytes,
    Function(double)? onProgress,
  }) async {
    // 1. 이미지 압축 및 리사이징
    // 2. Firebase Storage 업로드
    // 3. 이전 아바타 삭제
    // 4. UserProfile photoUrl 업데이트
    // 5. 다운로드 URL 반환
  }
}
```

#### 3.2 settings/ - 설정 관련 UseCases

##### 📄 ChangeSettingsUseCase
```dart
class ChangeSettingsUseCase {
  final IUserRepository _userRepository;

  /// 설정 변경
  Future<Result<void>> execute({
    required String userId,
    required UserSettings settings,
  }) async {
    // 1. 설정 검증
    // 2. UserSettings 업데이트
    // 3. 캐시 무효화
  }
}
```

##### 📄 ChangeLanguageUseCase
```dart
class ChangeLanguageUseCase {
  final IUserRepository _userRepository;

  /// 언어 변경
  Future<Result<void>> execute({
    required String userId,
    required String language, // 'en', 'de'
  }) async {
    // 1. 지원 언어 확인
    // 2. UserSettings.language 업데이트
    // 3. 로컬라이제이션 리로드
  }
}
```

#### 3.3 onboarding/ - 온보딩 관련 UseCases

##### 📄 CompleteOnboardingStepUseCase
**책임**: 온보딩 단계 완료 비즈니스 로직

```dart
class CompleteOnboardingStepUseCase {
  final IUserRepository _userRepository;
  final IOnboardingProgressService _progressService;

  /// 온보딩 단계 완료
  Future<Result<void>> execute({
    required String userId,
    required OnboardingStep step,
    required Map<String, dynamic> data,
  }) async {
    // 1. 온보딩 단계 순서 검증
    // 2. 단계별 데이터 검증
    //    - AgeAgreement: age >= 13
    //    - ExpertiseSelection: expertise.length <= 4
    //    - HobbySelection: hobbies.length <= 8
    // 3. OnboardingProgress 업데이트
    // 4. 단계 완료 후처리
    //    - CharacterCreation: 캐릭터 잠금 해제
    //    - ProfileSetup: 온보딩 보너스 지급
    // 5. 온보딩 완료 확인
  }
}
```

**CompleteOnboardingStepParams**:
```dart
class CompleteOnboardingStepParams {
  final String userId;
  final OnboardingStep step;
  final Map<String, dynamic> data;
}
```

##### 📄 GetOnboardingProgressUseCase
```dart
class GetOnboardingProgressUseCase {
  final IOnboardingProgressService _progressService;

  /// 온보딩 진행상태 조회
  Future<Result<OnboardingProgress>> execute(String userId) async {
    // 1. 진행상태 조회
    // 2. 다음 단계 제안
    // 3. 진행률 계산 (percentage)
  }
}
```

---

### 4. services/ - 도메인 서비스 인터페이스 (구현 예정)

**목적**: 여러 엔티티에 걸친 비즈니스 로직 정의

#### 📄 IProfileValidationService
**책임**: 프로필 검증 비즈니스 로직

```dart
abstract class IProfileValidationService {
  /// 프로필 필드 검증
  ValidationResult validateProfile({
    String? displayName,
    String? bio,
    List<String>? expertise,
    List<String>? hobbies,
  });

  /// 표시 이름 검증
  ValidationResult validateDisplayName(String displayName);

  /// 자기소개 검증
  ValidationResult validateBio(String bio);

  /// 전문분야 검증 (최대 4개)
  ValidationResult validateExpertise(List<String> expertise);

  /// 취미 검증 (최대 8개)
  ValidationResult validateHobbies(List<String> hobbies);
}
```

**ValidationResult**:
```dart
class ValidationResult {
  final bool isValid;
  final String? error;
  final Map<String, String>? fieldErrors;
}
```

#### 📄 IOnboardingProgressService
**책임**: 온보딩 진행상태 관리

```dart
abstract class IOnboardingProgressService {
  /// 진행상태 조회
  Future<OnboardingProgress> getProgress(String userId);

  /// 단계 완료 처리
  Future<void> completeStep({
    required String userId,
    required OnboardingStep step,
    required Map<String, dynamic> data,
  });

  /// 다음 단계 제안
  OnboardingStep? getNextStep(OnboardingProgress progress);

  /// 온보딩 완료 확인
  bool isComplete(OnboardingProgress progress);
}
```

---

### 5. failures/ - 도메인 예외 (구현 예정)

**목적**: Profile Feature 전용 에러 클래스 정의

#### 📄 profile_failures.dart

##### 5.1 기본 Failure 클래스

```dart
/// Base class for all Profile failures
typedef Failure = core.Failure;

/// Profile operation failures
class ProfileFailure extends core.Failure {
  const ProfileFailure([String message = 'Profile operation failed', String? code])
      : super(message: message, code: code);
}

/// Profile validation failures
class ProfileValidationFailure extends ProfileFailure {
  final Map<String, String> fieldErrors;

  const ProfileValidationFailure(
    String message, {
    this.fieldErrors = const {},
    String? code,
  }) : super(message, code);

  @override
  String getUserMessage() {
    if (fieldErrors.isEmpty) {
      return message;
    }
    final missingFields = fieldErrors.keys.join(', ');
    return '필수 항목을 입력해주세요: $missingFields';
  }
}
```

##### 5.2 권한 관련 Failures

```dart
/// Profile permission failures
class ProfilePermissionFailure extends ProfileFailure {
  final String userId;
  final String operation; // 'read', 'write', 'delete'

  const ProfilePermissionFailure({
    required this.userId,
    required this.operation,
    String? message,
    String? code,
  }) : super(message ?? 'Profile permission denied', code);

  @override
  String getUserMessage() {
    switch (operation) {
      case 'write':
      case 'update':
        return '프로필 수정 권한이 없습니다';
      case 'delete':
        return '프로필 삭제 권한이 없습니다';
      default:
        return '프로필 접근 권한이 없습니다';
    }
  }
}
```

##### 5.3 온보딩 관련 Failures

```dart
/// Onboarding failures
class OnboardingFailure extends ProfileFailure {
  final OnboardingStep? failedStep;

  const OnboardingFailure(
    String message, {
    this.failedStep,
    String? code,
  }) : super(message, code);

  @override
  String getUserMessage() {
    if (failedStep != null) {
      return '온보딩 ${failedStep!.name} 단계에서 오류가 발생했습니다';
    }
    return '온보딩 중 오류가 발생했습니다';
  }
}

/// Incomplete profile failures
class IncompleteProfileFailure extends ProfileFailure {
  final List<String> missingFields;

  const IncompleteProfileFailure({
    required this.missingFields,
    String? message,
    String? code,
  }) : super(message ?? 'Profile is incomplete', code);

  @override
  String getUserMessage() {
    return '프로필이 완성되지 않았습니다. 온보딩을 완료해주세요.';
  }
}
```

##### 5.4 Repository Layer Failures

```dart
/// Profile Repository 실패
class ProfileRepositoryFailure extends ProfileFailure {
  final String operation; // 'create', 'update', 'delete'
  final String? userId;

  const ProfileRepositoryFailure(
    String message, {
    required this.operation,
    this.userId,
    String? code,
  }) : super(message, code);
}

/// Firestore Read 실패
class FirestoreReadFailure extends ProfileFailure {
  final String collectionPath;
  final String? documentId;

  const FirestoreReadFailure({
    required this.collectionPath,
    this.documentId,
    String? message,
    String? code,
  }) : super(message ?? 'Firestore read failed', code);

  @override
  String getUserMessage() {
    if (code == 'NOT_FOUND') {
      return '사용자 정보를 찾을 수 없습니다';
    }
    return '데이터를 불러오는 중 오류가 발생했습니다';
  }
}
```

**Failure 클래스 전체 목록 (8개)**:
1. ProfileFailure
2. ProfileValidationFailure
3. ProfilePermissionFailure
4. OnboardingFailure
5. IncompleteProfileFailure
6. ProfileRepositoryFailure
7. FirestoreReadFailure
8. ImageProcessingFailure (from Core)

---

## 🔗 관련 문서

### Profile Feature 문서
- [Data Layer README](../data/README.md) - Data Layer 아키텍처
- [Presentation Layer README](../presentation/README.md) - Presentation Layer 아키텍처
- [MIGRATION_PLAN.md](../MIGRATION_PLAN.md) - Clean Architecture 마이그레이션 계획

### Domain 서브디렉토리 문서
- [Models README](./models/README.md) - 모델 계층 상세
- [UseCases README](./usecases/README.md) - UseCase 상세

### 참고 문서
- [Creation Feature Domain Layer](../../creation/domain/README.md) - Creation 참고 구조
- [Auth Feature Domain Layer](../../auth/domain/README.md) - Auth 참고 구조
- [Clean Architecture v4.0](../../../docs/architecture/clean_architecture_v4.md)
- [Result Pattern Guide](../../../docs/patterns/result_pattern.md)

---

*이 문서는 Feature-First Architecture의 Profile 기능 Domain Layer 가이드입니다.*
*Phase 1 마이그레이션 작업 중 생성됨 (2025-01-26)*
