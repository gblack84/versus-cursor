# Profile Feature - 통합 문서

> **최종 업데이트**: 2025-11-11
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0 + 3-Layer Caching
> **상태 관리**: Riverpod 3.x with @riverpod code generation
> **Migration Status**: ✅ Phase 2, 4, 6, 6.5, 7, B-2 Complete (100%)

## 📋 목차

- [전체 디렉토리 구조](#-전체-디렉토리-구조)
- [아키텍처 개요](#-아키텍처-개요)
- [🔥 Phase 7 성과: 3-Layer 캐싱 시스템](#-phase-7-성과-3-layer-캐싱-시스템)
- [빠른 참조 가이드](#-빠른-참조-가이드)
- [레이어별 README 안내](#-레이어별-readme-안내)
- [주요 파일 위치](#-주요-파일-위치)
- [DI (Dependency Injection)](#-di-dependency-injection)
- [통계](#-통계)
- [시작하기](#-시작하기)
- [자주 찾는 질문](#-자주-찾는-질문)

---

## 🗂 전체 디렉토리 구조

```
lib/features/profile/
├── 📂 data/                              # Data Layer (Firebase-Centric v2.0 + 3-Layer Caching)
│   ├── 📂 repositories/                  # Repository 구현체 (7개)
│   │   ├── profile_repository_impl.dart          # 267줄 - ProfileInfo + Completion
│   │   ├── user_repository_impl.dart             # 743줄 - ⭐ User CRUD + Singleton
│   │   ├── settings_repository_impl.dart         # 132줄 - UserSettings
│   │   ├── interests_repository_impl.dart        # 278줄 - Interests + Constraints
│   │   ├── characters_repository_impl.dart       # 82줄 - Characters
│   │   ├── profile_storage_repository_impl.dart  # 61줄 - Storage Wrapper
│   │   └── profile_post_repository_impl.dart     # 102줄 - ⭐ My Posts (Phase 6.5)
│   ├── 📂 datasources/                   # DataSource (4개 - Storage 추상화)
│   │   ├── profile_storage_datasource.dart       # 44줄 - Interface
│   │   ├── profile_storage_datasource_impl.dart  # 55줄 - Implementation
│   │   ├── 📂 interfaces/
│   │   │   └── i_storage_datasource.dart         # (Deprecated)
│   │   └── 📂 implementations/
│   │       └── firebase_storage_datasource.dart  # (Deprecated)
│   └── 📄 README.md                      # Data Layer 상세 문서 (1,621줄)
│
├── 📂 domain/                            # Domain Layer (Clean Architecture v4.0)
│   ├── 📂 failures/
│   │   ├── profile_failure.dart                  # 204줄 - 12 failure types
│   │   └── profile_failure.freezed.dart          # Generated
│   ├── 📂 entities/                      # Domain Models (6 main + 18 generated = 24 files)
│   │   ├── user_profile.dart                     # 146줄 - 44 fields (통합 모델, includes country, countryCode)
│   │   ├── user_profile.freezed.dart             # Generated
│   │   ├── user_profile.g.dart                   # Generated
│   │   ├── profile_info.dart                     # 65줄 - 12 fields (경량 조회, includes country, countryCode)
│   │   ├── profile_info.freezed.dart             # Generated
│   │   ├── profile_info.g.dart                   # Generated
│   │   ├── user_settings.dart                    # 98줄 - 9 fields
│   │   ├── user_settings.freezed.dart            # Generated
│   │   ├── user_settings.g.dart                  # Generated
│   │   ├── character.dart                        # 37줄 - 7 fields
│   │   ├── character.freezed.dart                # Generated
│   │   ├── character.g.dart                      # Generated
│   │   ├── interest.dart                         # 48줄 - 5 fields
│   │   ├── interest.freezed.dart                 # Generated
│   │   ├── interest.g.dart                       # Generated
│   │   ├── interest_category.dart                # 36줄 - 4 fields
│   │   ├── interest_category.freezed.dart        # Generated
│   │   ├── interest_category.g.dart              # Generated
│   │   ├── user_profile_extensions.dart          # 313줄 - 🔥 Extension methods
│   │   └── README.md                             # 213줄 - Model documentation
│   ├── 📂 repositories/                  # Repository Interfaces (7 files)
│   │   ├── i_profile_repository.dart             # 102줄 - 3 methods (Phase 6: 85% 축소)
│   │   ├── i_user_repository.dart                # 293줄 - 12 methods
│   │   ├── i_settings_repository.dart            # 31줄 - 2 methods
│   │   ├── i_characters_repository.dart          # 21줄 - 1 method
│   │   ├── i_interests_repository.dart           # 76줄 - 4 methods
│   │   ├── i_profile_storage_repository.dart     # 43줄 - 2 methods
│   │   └── i_profile_post_repository.dart        # 29줄 - 1 method (Phase 6.5: Feature 독립성)
│   ├── 📂 usecases/                      # UseCases (11 files)
│   │   ├── 📂 profile/                   # 8 files
│   │   │   ├── get_current_user_profile_usecase.dart     # 47줄
│   │   │   ├── get_profile_completion_usecase.dart       # 52줄
│   │   │   ├── get_profile_info_usecase.dart             # 44줄
│   │   │   ├── get_user_profile_usecase.dart             # 49줄
│   │   │   ├── watch_user_profile_usecase.dart           # 164줄 - Real-time Stream
│   │   │   ├── update_user_profile_usecase.dart          # 68줄
│   │   │   ├── upload_profile_image_usecase.dart         # 63줄
│   │   │   └── delete_user_profile_usecase.dart          # 55줄
│   │   ├── 📂 settings/                  # 2 files
│   │   │   ├── get_user_settings_usecase.dart            # 41줄
│   │   │   └── update_user_settings_usecase.dart         # 59줄
│   │   ├── 📂 characters/                # 1 file
│   │   │   └── get_available_characters_usecase.dart     # 38줄
│   │   └── 📂 interests/                 # 2 files
│   │       ├── get_user_interests_usecase.dart           # 44줄
│   │       └── update_user_interests_usecase.dart        # 75줄
│   └── 📄 README.md                      # Domain Layer 상세 문서 (2,249줄)
│
├── 📂 presentation/                      # Presentation Layer (Riverpod 3.x)
│   ├── 📂 providers/                     # 상태 관리
│   │   ├── profile_providers.dart                # 561줄 - ⭐ 25개 Provider 정의
│   │   ├── profile_post_providers.dart           # 100줄 - 3개 Provider (Phase 6.5)
│   │   ├── profile_post_providers.g.dart         # Generated (Riverpod 3.x)
│   │   └── README.md                             # Provider 가이드
│   ├── 📂 screens/                       # 화면 (10개)
│   │   ├── 📂 profile_main/              # 메인 프로필 화면
│   │   │   └── profile_page_widget.dart
│   │   ├── 📂 profile_edit/              # 프로필 편집
│   │   │   └── profile_edit_screen.dart
│   │   ├── 📂 settings/                  # 설정 화면
│   │   │   └── settings_screen.dart
│   │   ├── 📂 onboarding/                # 온보딩 플로우
│   │   │   ├── onboarding_flow_screen.dart
│   │   │   └── 📂 interest_selection/
│   │   │       ├── 📂 agreed_select/     # 직업 선택
│   │   │       ├── 📂 expertise_select/  # 전문분야 (최대 4개)
│   │   │       └── 📂 hobbies_select/    # 취미 (최대 8개)
│   │   ├── 📂 user_info/                 # 사용자 정보
│   │   │   ├── 📂 user_info_display/     # 정보 표시 (Phase 6.1)
│   │   │   ├── 📂 character_detail/      # 캐릭터 상세
│   │   │   └── 📂 language_selector/     # 언어 선택
│   │   ├── 📂 user_info_input/           # 정보 입력
│   │   │   ├── user_info_input_widget.dart
│   │   │   └── user_info_input_model.dart
│   │   └── 📂 user_posts_list/           # 사용자 게시물 목록
│   │       └── user_posts_list_screen.dart
│   ├── 📂 widgets/                       # 재사용 위젯 (18개)
│   │   ├── 📂 common/                    # 공통 위젯
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_message.dart
│   │   ├── 📂 profile/                   # 프로필 위젯
│   │   │   ├── profile_header.dart
│   │   │   ├── profile_avatar.dart
│   │   │   ├── profile_stats_card.dart
│   │   │   └── profile_completion_card.dart
│   │   ├── 📂 interest_selection/        # 관심사 선택
│   │   │   ├── interest_selection_widget.dart
│   │   │   ├── interest_selection_model.dart
│   │   │   └── interest_category.dart
│   │   ├── 📂 interests/                 # 관심사 표시
│   │   │   └── interest_chip.dart
│   │   └── 📂 settings/                  # 설정 위젯
│   │       ├── settings_section.dart
│   │       └── settings_toggle.dart
│   └── 📄 README.md                      # Presentation Layer 상세 문서 (2,176줄)
│
├── 📂 di/
│   └── profile_di_module.dart            # Dependency Injection 모듈
│
└── 📄 README.md                          # 👈 이 문서 (통합 가이드)
```

**총 파일 수**: 약 105개 (생성된 Freezed 파일 포함)
- Data Layer: 10개 (활성 파일)
- Domain Layer: 42개 (24 models + 6 repositories + 11 usecases + 1 README)
- Presentation Layer: 53개 (providers + screens + widgets)
- DI: 1개
- 문서: 4개

---

## 🏗 아키텍처 개요

### 3-Layer Clean Architecture 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  • Riverpod 3.x 상태 관리 (@riverpod code generation)         │
│  • StreamProvider.autoDispose.family                         │
│  • 28개 Providers (UseCase 13, Stream 4, Future 4, State 6) │
│  • AsyncValue State Management                              │
│  • ⭐ Feature 독립성: ProfilePostProviders (Phase 6.5)        │
│  • 56개 파일 (~2,276줄)                                       │
└──────────────────┬──────────────────────────────────────────┘
                   │ Provider 의존성 (ref.watch)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • Pure Dart (프레임워크 독립)                                 │
│  • Freezed 불변 엔티티                                         │
│  • Either<Failure, Success> 패턴                             │
│  • 12 ProfileFailure types                                  │
│  • UserProfile (44 fields), ProfileInfo (10 fields)         │
│  • ⭐ UserPostItem (5 fields) - Phase 6.5 경량 DTO           │
│  • 7 Repository Interfaces + 11 UseCases                    │
│  • 44개 파일 (~2,278줄)                                       │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository 인터페이스 의존성
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • Firebase-Centric Architecture v2.0                        │
│  • Direct Firebase SDK 사용                                   │
│  • 🔥 3-Layer Caching (Memory → Hive → Firestore)           │
│  • Extension Pattern (Mapper 대체)                           │
│  • UnifiedCacheService Integration                          │
│  • UserRepository Singleton                                 │
│  • IdempotencyService (UUID 기반 중복 방지)                   │
│  • 10개 파일 (~1,621줄)                                       │
└─────────────────────────────────────────────────────────────┘
                   │
                   ▼
              Firebase Services
        (Firestore, Storage, Functions)
           + UnifiedCacheService
            (Memory, Hive, Offline)
```

### 핵심 디자인 패턴

| 패턴 | 레이어 | 목적 | 예시 파일 |
|------|--------|------|-----------|
| **Extension Pattern** | Data | Firestore 직렬화 (Mapper 대체) | `user_profile_extensions.dart` |
| **Repository Pattern** | Domain/Data | 데이터 소스 추상화 | `i_user_repository.dart` |
| **UseCase Pattern** | Domain | 비즈니스 로직 캡슐화 | `update_user_profile_usecase.dart` |
| **Freezed Pattern** | Domain | 불변 엔티티 + 코드 생성 | `user_profile.dart` |
| **Either Pattern** | Domain | 타입 안전 에러 처리 | `Either<ProfileFailure, UserProfile>` |
| **StreamProvider.family** | Presentation | 실시간 상태 관리 | `profileStreamProvider` |
| **Singleton Pattern** | Data | UserRepository 전역 접근 | `UserRepositoryImpl.instance` |
| **3-Layer Caching** | Data | 성능 최적화 | `UnifiedCacheService` |
| **Idempotency** | Data | 중복 방지 (UUID v4 기반) | `IdempotencyService` |
| **Feature Isolation** | All | Feature 독립성 확보 (Phase 6.5) | `ProfilePostRepository` |

---

## ⭐ Phase 6.5: Feature 독립성 확보 (2025-01-07)

### 목표: Post Feature 의존성 제거

Profile Feature의 "내 게시물 관리"는 Profile Feature의 책임입니다. 이전에는 Post Feature에 의존했지만, Clean Architecture 원칙에 따라 **Feature → Infrastructure** 패턴으로 변경했습니다.

### 핵심 변경사항

**Before (문제 상황)**:
```
Profile Feature → Post Feature → PostRepository → Firestore
(Feature 간 직접 의존성 - Clean Architecture 위배)
```

**After (해결 방법)**:
```
Profile Feature → ProfilePostRepository → Firestore
(Feature → Infrastructure 패턴 - Clean Architecture 준수)
```

### 구현 내역

#### 1. Domain Layer 추가 (1개 파일)
- **`domain/repositories/i_profile_post_repository.dart`**
  - Interface: `Stream<Either<ProfileFailure, List<UserPostItem>>> watchMyPosts(userId)`
  - 내 게시물만 조회하는 Repository 계약 정의

- **`domain/entities/user_post_item.dart`**
  - 5개 필드: `id`, `questionTitle`, `totalVotes`, `commentCount`, `createdAt`
  - PostDisplay (20+ fields) → UserPostItem (5 fields) 경량화 (75% 축소)

#### 2. Data Layer 추가 (1개 파일)
- **`data/repositories/profile_post_repository_impl.dart`**
  - Firebase-Centric v2.0 패턴: Direct Firestore Access
  - Firestore 쿼리: `collection('posts').where('userId', isEqualTo: userId)`
  - Extension Pattern: `UserPostItem.fromFirestore(doc)`
  - Either 패턴: 타입 안전 에러 처리

#### 3. Presentation Layer 추가 (2개 파일)
- **`presentation/providers/profile_post_providers.dart`**
  - Riverpod 3.x with @riverpod code generation
  - 3개 Provider:
    1. `profilePostRepositoryProvider` - GetIt DI wrapper
    2. `myPostsStreamProvider` - 내 게시물 전체 (UserPostsListScreen 사용)
    3. `profileUserPostsStreamProvider` - 최근 5개 (ProfilePageWidget 사용)

- **`presentation/providers/profile_post_providers.g.dart`**
  - Riverpod 3.x 코드 생성 결과

#### 4. DI 설정 업데이트
- **`di/profile_di_module.dart`**
  - ProfilePostRepository GetIt 등록

#### 5. Widget 업데이트 (2개 파일)
- **`presentation/screens/user_posts_list/user_posts_list_screen.dart`**
  - Provider 변경: `userPostsStreamProvider` → `myPostsStreamProvider`

- **`presentation/screens/profile_main/profile_page_widget.dart`**
  - Import 변경: `PostDisplay` → `UserPostItem`
  - Provider 변경: `userPostsStreamProvider` → `profileUserPostsStreamProvider`

### 성과 및 개선 효과

| 항목 | Before (Post 의존) | After (독립) | 개선율 |
|------|-------------------|-------------|--------|
| **Feature 의존성** | ❌ Profile → Post | ✅ Profile → Firestore | 독립성 100% |
| **Data Model** | PostDisplay (20+ fields) | UserPostItem (5 fields) | 75% 경량화 |
| **코드 복잡도** | 복잡 (Feature 결합) | 단순 (직접 쿼리) | 간결성 향상 |
| **유지보수성** | 낮음 (결합도 높음) | 높음 (독립성 확보) | 유지보수 용이 |

### Clean Architecture 원칙 준수

**Feature 독립성 규칙**:
- ❌ **잘못된 패턴**: Profile Feature → Post Feature 의존
- ✅ **올바른 패턴**: Profile Feature → Firestore (Infrastructure)

**핵심 원리**:
- Features는 서로 의존하지 않음
- Features는 공유 Infrastructure (Firestore)에 의존 가능
- 같은 컬렉션 (`posts`), 다른 쿼리 조건 (where userId = me)

**실제 구현**:
- **Profile Feature**: `where('userId', '==', userId)` - 내 것만!
- **Post Feature**: 전체 쿼리 - 소셜 피드용

### 코드 예시

```dart
// Domain: Repository Interface
abstract class IProfilePostRepository {
  Stream<Either<ProfileFailure, List<UserPostItem>>> watchMyPosts(String userId);
}

// Data: Repository Implementation
class ProfilePostRepositoryImpl implements IProfilePostRepository {
  final FirebaseFirestore _firestore;

  @override
  Stream<Either<ProfileFailure, List<UserPostItem>>> watchMyPosts(String userId) {
    return _firestore
      .collection('posts')
      .where('userId', isEqualTo: userId)  // 🎯 내 것만!
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final posts = snapshot.docs
          .map((doc) => UserPostItem.fromFirestore(doc))
          .toList();
        return right<ProfileFailure, List<UserPostItem>>(posts);
      });
  }
}

// Presentation: Riverpod 3.x Provider
@riverpod
Stream<List<UserPostItem>> myPostsStream(Ref ref, String userId) {
  final repository = ref.watch(profilePostRepositoryProvider);
  return repository.watchMyPosts(userId).map(
    (either) => either.fold(
      (failure) => <UserPostItem>[],
      (posts) => posts,
    ),
  );
}
```

### Phase 6.5 문서

- ✅ Feature 독립성 확보 완료
- ✅ Clean Architecture 원칙 준수
- ✅ Firebase-Centric v2.0 패턴 적용
- ✅ Riverpod 3.x 마이그레이션 완료

---

## 🔥 Phase 7 성과: 3-Layer 캐싱 시스템

### 성능 개선 메트릭 (2025-01-30 통합 완료)

| 메트릭 | Before | After | 개선율 |
|--------|--------|-------|--------|
| **앱 재시작 성능** | 300-500ms | 10-30ms | **95% ↑** |
| **Cache Hit Rate** | 60% (Memory만) | 95% (Memory+Hive) | **58% ↑** |
| **오프라인 지원** | 0% | 100% | **∞** |
| **Firestore 읽기** | 10,000/day | 500/day | **95% ↓** |
| **월간 비용** | $6.48 | $0.07 (per 10K users) | **97% ↓** |

### 아키텍처: Memory → Hive → Firestore

```
┌──────────────────────────────────────────────────────────┐
│                  UnifiedCacheService                      │
│                   (Singleton Instance)                    │
└───────────┬─────────────┬────────────────────────────────┘
            │             │
    ┌───────▼──────┐ ┌───▼──────────┐ ┌──────────────────┐
    │ L1: Memory   │ │ L2: Hive     │ │ L3: Firestore    │
    │              │ │              │ │                  │
    │ LRU Cache    │ │ Local DB     │ │ Offline Cache    │
    │ 100 items    │ │ Unlimited    │ │ Unlimited        │
    │ 5min TTL     │ │ 24hr TTL     │ │ On-demand sync   │
    │              │ │              │ │                  │
    │ <1ms         │ │ 10-30ms      │ │ 50-100ms         │
    │ 80% hits     │ │ 15% hits     │ │ 5% hits          │
    └──────────────┘ └──────────────┘ └──────────────────┘
```

### Integration: 6개 Repository 통합

1. **ProfileRepositoryImpl**: ProfileInfo, Completion (TTL 30min-1hr)
2. **UserRepositoryImpl**: UserProfile CRUD (TTL 1hr)
3. **SettingsRepositoryImpl**: UserSettings (TTL 1hr)
4. **InterestsRepositoryImpl**: Interests (TTL 30min)
5. **CharactersRepositoryImpl**: Characters (TTL 24hr)
6. **ProfileStorageRepositoryImpl**: Image URLs (no cache)

### 캐시 전략

| 데이터 타입 | TTL | Cache Layer | 이유 |
|------------|-----|-------------|------|
| **UserProfile** | 1hr | Memory + Hive | 자주 조회, 크기 큼 (44 fields, including country, countryCode) |
| **ProfileInfo** | 1hr | Memory + Hive | 자주 조회, 경량 (10 fields, no country/countryCode) |
| **Completion** | 30min | Memory + Hive | 자주 변경 |
| **Settings** | 1hr | Memory + Hive | 변경 빈도 낮음 |
| **Interests** | 30min | Memory only | 변경 가능성 있음 |
| **Characters** | 24hr | Memory + Hive | 거의 변경 없음 |

**Cache Promotion**: L3(Firestore) hit → L2(Hive) 저장 → L1(Memory) 승격

---

## 🏛️ BOUNDARIES - Clean Architecture 3-Layer 경계

### Layer 의존성 규칙

```
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                         │
│  • 의존: Domain Layer (UseCase, Entity, Repository          │
│          Interface)                                          │
│  • 금지: Data Layer, 다른 Feature Presentation               │
│  • 패턴: Riverpod Provider, ConsumerWidget, AsyncValue      │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 의존
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • 의존: 없음 (Pure Dart)                                    │
│  • 금지: Presentation, Data, Flutter SDK, Firebase           │
│  • 패턴: UseCase, Entity (Freezed), Repository Interface     │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 구현
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • 의존: Domain Layer (Entity, Repository Interface)         │
│  • 금지: Presentation Layer                                   │
│  • 패턴: Repository 구현, Extension (fromFirestore,          │
│          toFirestore), Firebase SDK 직접 사용                │
└─────────────────────────────────────────────────────────────┘
```

### 실무 예시

#### ✅ Presentation → Domain (올바른 사용)

```dart
// Provider에서 UseCase 사용
@riverpod
FutureOr<UserProfile> userProfile(Ref ref, String userId) async {
  final useCase = getIt<GetUserProfileUseCase>();  // GetIt DI
  final result = await useCase.execute(userId: userId);

  return result.fold(
    (failure) => throw Exception(failure.getUserMessage()),
    (profile) => profile,
  );
}
```

#### ✅ Domain → 독립성 (올바른 사용)

```dart
// Pure Dart (의존성 없음)
class GetUserProfileUseCase {
  final IProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) {
    return _repository.getUserProfile(userId);
  }
}
```

#### ✅ Data → Domain (올바른 사용)

```dart
// Repository 구현 (Domain Interface 구현)
class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId) async {
    try {
      // ✅ 3-Layer 캐싱 사용
      final cached = await _cacheService.get<UserProfile>(
        ProfileCacheKeys.userProfile(userId),
      );
      if (cached != null) return right(cached);

      // ✅ Data Layer는 Firestore 직접 접근 허용
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return left(ProfileFailure.notFound());

      final profile = UserProfile.fromFirestore(doc);
      await _cacheService.set(ProfileCacheKeys.userProfile(userId), profile);

      return right(profile);
    } catch (e) {
      return left(ProfileFailure.serverError(e.toString()));
    }
  }
}
```

#### ❌ 잘못된 사용

```dart
// ❌ Presentation → Data (Layer 건너뛰기)
import '/features/profile/data/repositories/profile_repository_impl.dart';
final repository = ProfileRepositoryImpl();  // 직접 인스턴스화

// ❌ Domain → Presentation (역방향 의존)
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Flutter SDK

// ❌ Domain → Data (Layer 건너뛰기)
import '/features/profile/data/repositories/profile_repository_impl.dart';

// ❌ Presentation → Firestore (Layer 책임 위반)
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
```

### 경계 준수 검증

#### 자동 검사

```bash
# Presentation → Data 위반 검사
grep -r "import.*data.*repositories" lib/features/profile/presentation/

# Domain → Flutter 위반 검사
grep -r "import.*flutter" lib/features/profile/domain/

# Domain → Firebase 위반 검사
grep -r "import.*firebase" lib/features/profile/domain/

# 기대 결과: 모두 발견되지 않아야 함
```

#### 수동 체크리스트

**Presentation Layer**:
- [x] Data Layer import 없음
- [x] UseCase/Entity/Repository Interface만 의존
- [x] Firebase SDK 사용 없음
- [x] Riverpod Provider 패턴 사용

**Domain Layer**:
- [x] Flutter/Firebase import 없음
- [x] Pure Dart 코드만 (외부 의존성 없음)
- [x] Freezed, fpdart 등 Pure Dart 라이브러리만 허용
- [x] Repository Interface 정의

**Data Layer**:
- [x] Presentation Layer import 없음
- [x] Domain Layer (Entity, Repository Interface)만 의존
- [x] Firebase SDK 사용 허용 (Firestore)
- [x] 3-Layer 캐싱 시스템 통합

### 참고 문서

- **전체 아키텍처**: [CLAUDE.md - BOUNDARIES 섹션](../../../CLAUDE.md#boundaries)
- **App Layer 경계**: [lib/app/README.md - BOUNDARIES](../../../lib/app/README.md#boundaries)
- **Feature 내부 README**: [Presentation](presentation/README.md) | [Domain](domain/README.md) | [Data](data/README.md)

---

## 🎯 빠른 참조 가이드

### 찾고자 하는 것 → 참조할 README 섹션

| 무엇을 찾을 때 | 어느 README | 어느 섹션 | 파일 위치 |
|---------------|-------------|-----------|-----------|
| **3-Layer 캐싱 동작 원리** | `data/README.md` | 3-Layer 캐싱 시스템 | `data/repositories/*.dart` |
| **UserRepository Singleton** | `data/README.md` | UserRepository | `data/repositories/user_repository_impl.dart` |
| **UserProfile 모델 구조** | `domain/README.md` | Models 섹션 | `domain/models/user_profile.dart` |
| **ProfileFailure 타입** | `domain/README.md` | Failures 섹션 | `domain/failures/profile_failure.dart` |
| **프로필 업데이트 로직** | `domain/README.md` | UseCases 섹션 | `domain/usecases/profile/update_user_profile_usecase.dart` |
| **Real-time 프로필 동기화** | `data/README.md` | Real-time Streaming | `data/repositories/user_repository_impl.dart` |
| **Riverpod Provider** | `presentation/README.md` | Provider 섹션 | `presentation/providers/profile_providers.dart` |
| **프로필 화면 UI** | `presentation/README.md` | Screens 섹션 | `presentation/screens/profile_main/` |
| **관심사 선택 제약사항** | `data/README.md` | InterestsRepository | `data/repositories/interests_repository_impl.dart` |
| **Extension Pattern** | `data/README.md` | Extension Pattern | `domain/models/user_profile_extensions.dart` |
| **IdempotencyService 사용** | `data/README.md` | Idempotency | `data/repositories/interests_repository_impl.dart` |
| **DI 설정** | `di/profile_di_module.dart` | - | `di/profile_di_module.dart` |

---

## 🗺 Router Integration

Profile Feature는 GoRouter 기반 라우팅을 사용하며, **Phase 6.5 Feature 독립성** 패턴을 준수합니다.

### 라우트 구성

**파일 위치**: `lib/features/profile/presentation/routes/profile_routes.dart` (123줄)

Profile Feature는 **6개의 라우트**를 제공합니다:

| # | 라우트 이름 | 경로 | requireAuth | 파라미터 | 목적 |
|---|------------|------|-------------|---------|------|
| 1 | `ProfileEditPageWidget.routeName` | `/profileEdit` | ✅ true (PRIVATE) | - | 프로필 편집 (DisplayName, Bio, Interests) |
| 2 | `SettingsPageWidget.routeName` | `/settings` | ✅ true (PRIVATE) | - | 앱 설정 (Notifications, Privacy, Theme) |
| 3 | `UserPostsListWidget.routeName` | `/myPosts` | ✅ true (PRIVATE) | `userId` (String, 선택) | 내 게시물 목록 (Phase 6.5: Feature 독립성) |
| 4 | `OnboardingFlowWidget.routeName` | `/onboarding` | ✅ true (PRIVATE) | - | 온보딩 플로우 (Character, Interests 선택) |
| 5 | `UserInfoDisplayScreen.routeName` | `/profile/:userId` | ❌ false (PUBLIC) | `userId` (String, 필수, PathParameter) | 다른 사용자 프로필 조회 |
| 6 | `UserInfoInputWidget.routeName` | `/profileInput` | ✅ true (PRIVATE) | - | 프로필 초기 입력 (회원가입 후) |

**총 라우트**: 6개 (5개 PRIVATE + 1개 PUBLIC)

### PUBLIC vs PRIVATE Routes

Profile Feature는 **5:1 비율**로 PRIVATE 라우트가 우세합니다.

#### PRIVATE Routes (5개) - requireAuth: true

```dart
// ✅ PRIVATE - 본인만 접근 가능
AppRoute(
  name: ProfileEditPageWidget.routeName,
  path: ProfileEditPageWidget.routePath,
  requireAuth: true,  // AuthGuard 자동 적용
  builder: (context, params) => ProfileEditPageWidget(),
).toRoute(ref),
```

**PRIVATE 라우트**:
1. **ProfileEdit** - 자신의 프로필 편집 (DisplayName, Bio, Interests, ProfileImage)
2. **Settings** - 앱 설정 변경 (Notifications, Privacy, Theme, Language)
3. **UserPostsList** - 자신이 작성한 게시물 목록 (Phase 6.5: Post Feature 독립)
4. **OnboardingFlow** - 온보딩 완료 (Character 선택, Interests 설정)
5. **UserInfoInput** - 프로필 초기 입력 (회원가입 직후)

#### PUBLIC Route (1개) - requireAuth: false

```dart
// ✅ PUBLIC - 누구나 접근 가능
AppRoute(
  name: UserInfoDisplayScreen.routeName,
  path: UserInfoDisplayScreen.routePath, // '/profile/:userId'
  requireAuth: false,  // 로그인 없이 프로필 조회 가능
  builder: (context, params) => UserInfoDisplayScreen(
    userID: params.getParam('userId', ParamType.String),
  ),
).toRoute(ref),
```

**PUBLIC 라우트**:
- **UserInfoDisplay** (`/profile/:userId`) - 다른 사용자 프로필 조회
  - **왜 PUBLIC?** 프로필 링크 공유 시 로그인 없이 조회 가능 (바이럴 효과)
  - **SEO 친화**: 크롤러가 프로필 페이지 인덱싱 가능
  - **딥링크 지원**: `versus://profile/abc123` → 직접 프로필 접근

**근거**:
| Route | Access Level | 이유 |
|-------|--------------|------|
| **ProfileEdit, Settings, UserInfoInput** | PRIVATE | 본인만 수정 가능 |
| **UserPostsList** | PRIVATE | 본인 게시물 관리 (Phase 6.5: Feature 독립성) |
| **OnboardingFlow** | PRIVATE | 회원가입 후 1회만 접근 |
| **UserInfoDisplay** | PUBLIC | 프로필 공유 + SEO + 바이럴 |

### Phase 6.5 Feature 독립성

Profile Feature는 **Phase 6.5**에서 Post Feature 의존성을 제거했습니다.

#### Before Phase 6.5

```dart
// ❌ 문제: Post Feature에 직접 의존
AppRoute(
  name: 'myPosts',
  path: '/myPosts',
  requireAuth: true,
  builder: (context, params) {
    // Post Feature의 PostListWidget 직접 사용
    return PostFeature.PostListWidget(userId: currentUserId);
  },
).toRoute(ref),
```

**문제점**:
- Feature 간 순환 의존성 발생 가능
- Post Feature 변경 시 Profile Feature도 영향
- 테스트 격리 불가능

#### After Phase 6.5

```dart
// ✅ 해결: Profile Feature 자체 MyPosts 구현
AppRoute(
  name: UserPostsListWidget.routeName,
  path: UserPostsListWidget.routePath,
  requireAuth: true,
  builder: (context, params) => UserPostsListWidget(
    userId: params.getParam('userId', ParamType.String),
  ),
).toRoute(ref),
```

**개선사항**:
1. **독립성**: Profile Feature가 Post Feature에 의존하지 않음
2. **Infrastructure 계층 공유**: PostRepository는 Infrastructure에서 공유
3. **테스트 용이**: Feature 단독 테스트 가능
4. **유지보수성**: Post Feature 변경이 Profile에 영향 없음

**Architecture**:
```
Profile Feature → Infrastructure (PostRepository Interface)
Post Feature    → Infrastructure (PostRepository Interface)

(Feature들은 서로를 모르지만, Infrastructure를 통해 통신)
```

### 3-Layer 캐싱 통합

Profile Feature의 라우트는 **3-Layer 캐싱 시스템**과 통합되어 있습니다.

#### 캐싱 적용 라우트

| Route | 캐싱 대상 | L1 Memory | L2 Hive | L3 Firestore |
|-------|----------|-----------|---------|--------------|
| **ProfileEdit** | UserProfile (44 fields) | 5분 TTL | 영구 | 오프라인 캐시 |
| **Settings** | UserSettings (9 fields) | 5분 TTL | 영구 | 오프라인 캐시 |
| **UserPostsList** | Post[] (Phase 6.5) | 5분 TTL | 영구 | 오프라인 캐시 |
| **UserInfoDisplay** | ProfileInfo (12 fields, 경량) | 5분 TTL | 영구 | 오프라인 캐시 |
| **UserInfoInput** | Draft (자동 저장) | 30초 TTL | 1일 | - |

#### 캐싱 성능 (Phase 7 완료)

**Before 3-Layer Caching**:
```dart
// ❌ 매번 Firestore 조회 (300-500ms)
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref, String userId) async {
  final doc = await firestore.collection('users').doc(userId).get();
  return UserProfile.fromFirestore(doc);
}
```

**After 3-Layer Caching**:
```dart
// ✅ 3-Layer 캐싱 (L1 Hit: <10ms, 95% 성능 향상)
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref, String userId) async {
  // L1 Memory 확인 (LRU 100개, 5분 TTL)
  final cached = _memoryCache.get<UserProfile>('profile_$userId');
  if (cached != null) return cached;  // <10ms

  // L2 Hive 확인 (영구 저장)
  final local = await _hiveCache.get('profile_$userId');
  if (local != null) {
    _memoryCache.set('profile_$userId', local);  // L1에 승격
    return local;  // 10-30ms
  }

  // L3 Firestore 조회 (오프라인 캐시 지원)
  final doc = await firestore.collection('users').doc(userId).get();
  final profile = UserProfile.fromFirestore(doc);

  // 모든 레이어에 저장
  await _cacheService.set('profile_$userId', profile);
  return profile;  // 50-100ms
}
```

**성능 지표** (Phase 7 완료):
- **앱 재시작 시간**: 300-500ms → 10-30ms (95% 향상)
- **Cache Hit Rate**: 60% → 95%
- **오프라인 지원**: 0% → 100%
- **Firestore 비용**: 97% 절감

### 사용 예시

#### 1. 타입 안전 네비게이션 (권장)

```dart
// 프로필 편집 화면으로 이동
context.goNamed(ProfileRoutes.profileEdit);

// 설정 화면으로 이동
context.goNamed(ProfileRoutes.settings);

// 온보딩 플로우 시작
context.goNamed(ProfileRoutes.onboardingFlow);

// 내 게시물 목록 (Phase 6.5: Feature 독립성)
context.goNamed(ProfileRoutes.myPosts);
```

#### 2. PathParameter 사용 (UserInfoDisplay)

```dart
// 다른 사용자 프로필 조회 (PUBLIC 라우트)
context.goNamed(
  ProfileRoutes.profileDisplay,
  pathParameters: {
    'userId': targetUserId,  // PathParameter (필수)
  },
);

// URL: /profile/abc123def456
// GoRouter가 자동으로 userId 파싱
```

#### 3. 조건부 네비게이션 (AuthGuard 통합)

```dart
// AuthGuard가 자동으로 인증 체크 (requireAuth: true)
context.goNamed(ProfileRoutes.profileEdit);

// 미인증 시 자동 리다이렉션 → /startPage
// 인증 후 원래 경로로 복귀
```

#### 4. 캐싱과 함께 사용

```dart
// Provider에서 3-Layer 캐싱 자동 적용
final profileAsync = ref.watch(userProfileProvider(userId));

profileAsync.when(
  data: (profile) {
    // L1 Memory Hit: <10ms (95% 케이스)
    // L2 Hive Hit: 10-30ms (앱 재시작 시)
    // L3 Firestore: 50-100ms (캐시 Miss 시)
    return ProfileWidget(profile: profile);
  },
  loading: () => CircularProgressIndicator(),
  error: (e, s) => ErrorWidget(error: e),
);
```

#### 5. Push 네비게이션 (스택에 추가)

```dart
// 프로필 편집 화면을 스택에 추가 (뒤로가기 가능)
context.pushNamed(ProfileRoutes.profileEdit);

// 다른 사용자 프로필 Push
context.pushNamed(
  ProfileRoutes.profileDisplay,
  pathParameters: {'userId': userId},
);
```

#### 6. Phase 6.5 패턴: My Posts 라우트

```dart
// Profile Feature 내에서 내 게시물 조회 (Feature 독립성)
context.goNamed(
  ProfileRoutes.myPosts,
  queryParameters: {
    'userId': currentUserId,  // 선택적 파라미터
  },
);

// UserPostsListWidget 내부에서 Infrastructure의 PostRepository 사용
// Post Feature에 직접 의존하지 않음 (Phase 6.5: Feature 독립성)
```

### nav.dart 통합

Profile Feature의 6개 라우트는 `lib/app/router/navigation/nav.dart`에 통합되어 있습니다.

```dart
// /lib/app/router/navigation/nav.dart (line 137)
routes: [
  ...AuthRoutes.routes(ref),        // 6개 (최우선)
  ...ProfileRoutes.routes(ref),     // 6개 (5 PRIVATE + 1 PUBLIC)
  ...ChatRoutes.routes(ref),        // 2개
  // ... 다른 Feature Routes
],
```

**병합 순서**:
1. AuthRoutes (6개) - 앱 진입점
2. **ProfileRoutes (6개)** - 프로필 관리 (Phase 6.5: Feature 독립성)
3. ChatRoutes (2개)
4. VotingRoutes (0개 - 다이얼로그)
5. CreationRoutes (2개)
6. NotificationRoutes (4개)
7. PostRoutes (3개)
8. SearchRoutes (0개 - Phase 4-5 대기)

### Type-Safe Navigation 상수

Profile Feature는 타입 안전 네비게이션을 위한 static getter를 제공합니다:

```dart
// lib/features/profile/presentation/routes/profile_routes.dart

class ProfileRoutes {
  /// Route names for type-safe navigation
  static String get profileEdit => ProfileEditPageWidget.routeName;
  static String get settings => SettingsPageWidget.routeName;
  static String get myPosts => UserPostsListWidget.routeName;
  static String get onboardingFlow => OnboardingFlowWidget.routeName;
  static String get profileDisplay => UserInfoDisplayScreen.routeName;
  static String get profileInput => UserInfoInputWidget.routeName;

  /// Route paths for reference
  static String get profileEditPath => ProfileEditPageWidget.routePath;
  static String get settingsPath => SettingsPageWidget.routePath;
  static String get myPostsPath => UserPostsListWidget.routePath;
  static String get onboardingFlowPath => OnboardingFlowWidget.routePath;
  static String get profileDisplayPath => UserInfoDisplayScreen.routePath;
  static String get profileInputPath => UserInfoInputWidget.routePath;
}
```

**사용법**:
```dart
// ✅ 타입 안전 (컴파일 타임 체크)
context.goNamed(ProfileRoutes.profileEdit);

// ❌ 하드코딩 (오타 위험)
context.goNamed('profileEditPage');
```

### 딥링크 지원

Profile Feature는 외부 링크로 직접 접근 가능합니다 (PUBLIC 라우트만):

```dart
// 외부 링크로 프로필 조회 (PUBLIC)
https://versus.app/profile/abc123def456

// GoRouter가 자동으로 라우팅:
// 1. /profile/abc123def456 경로 파싱
// 2. UserInfoDisplayScreen.routePath 매칭 ('/profile/:userId')
// 3. userId 파라미터 추출 (abc123def456)
// 4. UserInfoDisplayScreen 렌더링 (3-Layer 캐싱 적용)
```

**지원 딥링크**:
- `versus://profile/:userId` - 사용자 프로필 조회 (PUBLIC)
- `versus://profileEdit` - 프로필 편집 (PRIVATE - AuthGuard 체크)
- `versus://settings` - 설정 (PRIVATE)
- `versus://myPosts` - 내 게시물 (PRIVATE, Phase 6.5)
- `versus://onboarding` - 온보딩 (PRIVATE)
- `versus://profileInput` - 프로필 입력 (PRIVATE)

### 참조 문서

- [profile_routes.dart 소스 코드](./presentation/routes/profile_routes.dart) (123줄)
- [Phase 6.5: Feature 독립성](./PHASE_6_5_FEATURE_ISOLATION.md) - Post Feature 의존성 제거
- [Phase 7: 3-Layer 캐싱](./PHASE_7_THREE_LAYER_CACHING.md) - 95% 성능 향상
- [GoRouter 공식 문서](https://pub.dev/packages/go_router)
- [AppRoute 패턴](/lib/app/router/README.md)
- [Navigation 상세 가이드](/lib/app/router/navigation/README.md)

---

## 📚 레이어별 README 안내

### 1. Data Layer README (`data/README.md` - 1,621줄)

**📌 핵심 내용**:
- Firebase-Centric Architecture v2.0 설명
- 🔥 **3-Layer 캐싱 시스템** (Memory → Hive → Firestore)
- UnifiedCacheService Integration (95% 성능 향상)
- Extension Pattern 사용법 (Mapper 대체)
- UserRepository Singleton 패턴
- IdempotencyService 중복 방지
- Real-time Streaming 지원

**📖 주요 섹션**:
1. **아키텍처 개요**: Firebase-Centric v2.0 vs v1.0
2. **3-Layer 캐싱 시스템**: Memory/Hive/Firestore 통합 설명 🔥
3. **6개 Repository 구현**: Profile, User, Settings, Interests, Characters, Storage
4. **UserRepository Singleton**: 수동 초기화, getInstance() 패턴
5. **Extension Pattern**: UserProfileFirestore extension 예시
6. **Real-time Streaming**: watchUserProfile() Stream 구현
7. **IdempotencyService**: UUID v4 기반 중복 방지
8. **Migration History**: Phase 2, 4, 6, 7 변경사항

**💡 언제 참조?**
- **3-Layer 캐싱 시스템**을 이해하고 싶을 때 🔥
- Firebase Firestore 연동 방법을 알고 싶을 때
- UserRepository Singleton 초기화가 필요할 때
- Extension Pattern 사용법을 배우고 싶을 때
- Real-time 프로필 동기화를 구현하고 싶을 때
- IdempotencyService 사용법을 확인하고 싶을 때

**🚀 특별 하이라이트**:
- 앱 재시작: 300-500ms → 10-30ms (95% 향상)
- Cache Hit Rate: 60% → 95%
- 오프라인 지원: 0% → 100%
- Firestore 비용: 97% 절감

**🔗 바로가기**: [data/README.md](./data/README.md)

---

### 2. Domain Layer README (`domain/README.md` - 2,249줄)

**📌 핵심 내용**:
- Clean Architecture v4.0 원칙
- Freezed 불변 엔티티 패턴
- Either<Failure, Success> 에러 처리
- 12개 ProfileFailure 타입 정의
- UserProfile (44 fields) vs ProfileInfo (10 fields) - country/countryCode는 UserProfile에만 존재
- 6개 Repository Interfaces
- 11개 UseCases (Single Responsibility)

**📖 주요 섹션**:
1. **Failures**: 12개 실패 타입 (ProfileNotFound, PermissionDenied, Network 등)
2. **Models**: 6개 핵심 모델 (UserProfile 44 fields, ProfileInfo 10 fields - country/countryCode는 UserProfile에만 존재)
3. **Repository Interfaces**: 6개 계약 정의 (IUserRepository 12 methods 등)
4. **UseCases**: 11개 비즈니스 로직 (Profile 8, Settings 2, Interests 2)
5. **Extension Methods**: UserProfileFirestore, ProfileInfoFirestore 등
6. **Phase 6 Cleanup**: 20→3 메서드 축소 (85% 감소)

**💡 언제 참조?**
- 비즈니스 로직을 이해하고 싶을 때
- 엔티티 구조를 확인하고 싶을 때
- 에러 처리 방법을 알고 싶을 때
- Repository 계약을 확인하고 싶을 때
- UserProfile vs ProfileInfo 차이를 알고 싶을 때
- Extension 메서드 사용법을 배우고 싶을 때

**🔗 바로가기**: [domain/README.md](./domain/README.md)

---

### 3. Presentation Layer README (`presentation/README.md` - 2,176줄)

**📌 핵심 내용**:
- Riverpod 2.x 상태 관리
- **25개 Providers** (UseCase 13, Stream 2, Future 4, State 6)
- StreamProvider.autoDispose.family 패턴
- ProfileActions Helper (5개 static methods)
- AsyncValue.when() 패턴
- Feature Isolation: userPostsStreamProvider
- Real-time 프로필 동기화

**📖 주요 섹션**:
1. **Providers**: 25개 Provider 상세 (UseCase, Stream, Future, State)
2. **ProfileActions Helper**: updateProfile, uploadImage, delete, updateSettings, updateInterests
3. **Screens**: 10개 화면 (Main, Edit, Settings, Onboarding, UserInfo 등)
4. **Widgets**: 18개 재사용 위젯 (Profile, Interest, Settings, Common)
5. **Data Flow Diagrams**: 4가지 플로우 (프로필 조회, 업데이트, Real-time, Settings)
6. **Performance Optimization**: 3-Layer Caching 활용법

**💡 언제 참조?**
- UI 컴포넌트를 수정하고 싶을 때
- Riverpod Provider 사용법을 알고 싶을 때
- ProfileActions Helper 사용법을 확인하고 싶을 때
- Real-time 프로필 동기화를 구현하고 싶을 때
- AsyncValue 에러 처리를 배우고 싶을 때
- 3-Layer 캐싱을 UI에서 활용하고 싶을 때

**🔗 바로가기**: [presentation/README.md](./presentation/README.md)

---

## 📍 주요 파일 위치

### A. 프로필 조회 플로우 (3-Layer Caching 활용)

```
UI Widget → Provider → UseCase → Repository → UnifiedCacheService → Firebase
   ↓          ↓          ↓            ↓              ↓                  ↓
Screen   Stream      Get      UserRepository   Memory→Hive→Firestore  Firestore
         Provider   UseCase     (Singleton)     (95% hit rate)        (5% miss)
```

1. **UI 렌더링**: `presentation/screens/profile_main/profile_page_widget.dart`
2. **Provider 구독**: `presentation/providers/profile_providers.dart` (profileStreamProvider)
3. **UseCase 실행**: `domain/usecases/profile/watch_user_profile_usecase.dart`
4. **Repository 호출**: `domain/repositories/i_user_repository.dart` (watchUserProfile)
5. **Data 구현**: `data/repositories/user_repository_impl.dart` (Singleton)
6. **🔥 Cache 조회**: `UnifiedCacheService.getUserProfile()` (Memory → Hive → Firestore)
7. **Extension 변환**: `domain/models/user_profile_extensions.dart` (UserProfileFirestore)
8. **Firebase 스트림**: Firestore `users/{userId}` 문서 실시간 감시

### B. 프로필 업데이트 플로우 (IdempotencyService + Cache Invalidation)

```
UI Action → ProfileActions → UseCase → Repository → IdempotencyService → Firebase
     ↓             ↓            ↓            ↓              ↓                ↓
 Button      updateProfile   Update      UserRepository   UUID v4        Firestore
  Click        Helper        UseCase      (Singleton)   Duplicate Check   Write
                                                             ↓
                                                    Cache Invalidation
                                                   (Memory + Hive 삭제)
```

1. **UI 이벤트**: `presentation/screens/profile_edit/profile_edit_screen.dart`
2. **ProfileActions 호출**: `ProfileActions.updateProfile()` (UUID v4 생성)
3. **UseCase 실행**: `domain/usecases/profile/update_user_profile_usecase.dart`
4. **Repository 호출**: `domain/repositories/i_user_repository.dart` (updateUserProfile)
5. **Data 구현**: `data/repositories/user_repository_impl.dart`
6. **IdempotencyService**: UUID v4 기반 중복 방지
7. **Extension 변환**: `UserProfileFirestore.toFirestore(profile)`
8. **Firebase 업데이트**: Firestore Transaction + Timestamp
9. **🔥 Cache 무효화**: `UnifiedCacheService.clearUserProfile(userId)` (Memory + Hive 삭제)

### C. Real-time 프로필 동기화 플로우

```
Firestore Change → Stream → Extension → Cache Update → Provider → UI Update
       ↓              ↓          ↓           ↓             ↓          ↓
  Document      Repository  fromFirestore  Set Cache  StreamProvider  AsyncValue
  Snapshot      watchUser   (Extension)    (Memory)   (rebuild)      .when()
```

1. **Firestore 변경 감지**: `users/{userId}` 문서 WebSocket 스냅샷
2. **Repository Stream**: `data/repositories/user_repository_impl.dart` (watchUserProfile)
3. **Extension 변환**: `UserProfileFirestore.fromFirestore(doc)`
4. **🔥 Cache 업데이트**: Memory cache 갱신 (Hive 비동기 저장)
5. **Provider Stream**: `presentation/providers/profile_providers.dart` (profileStreamProvider)
6. **UI 자동 업데이트**: AsyncValue.when() 패턴

---

## 🔧 DI (Dependency Injection)

**파일**: `di/profile_di_module.dart`

### 등록되는 의존성

**Repository 구현체** (6개):
- ProfileRepositoryImpl (Firestore + UnifiedCache)
- **UserRepositoryImpl.instance** (Singleton - 수동 초기화 필수)
- SettingsRepositoryImpl
- InterestsRepositoryImpl
- CharactersRepositoryImpl
- ProfileStorageRepositoryImpl

**DataSource**:
- ProfileStorageDataSourceImpl (Firebase Storage 추상화)

**UseCases** (11개):
- Profile: GetCurrentUser, GetProfile, GetProfileInfo, GetCompletion, WatchUserProfile, UpdateProfile, UploadImage, DeleteProfile
- Settings: GetSettings, UpdateSettings
- Interests: GetInterests, UpdateInterests

**공유 서비스**:
- UnifiedCacheService.instance (Singleton)
- IdempotencyService (UUID v4 중복 방지)
- AuthContract (Auth Feature 연동)
- UserContract (다른 Feature에 프로필 제공)

### ⚠️ UserRepository Singleton 초기화 주의사항

```dart
// ❌ Bad: GetIt 등록 없이 사용하면 에러
final user = await UserRepositoryImpl.instance.getCurrentUser();

// ✅ Good: main.dart에서 초기화
await ProfileDIModule.initialize();  // GetIt 등록
await UserRepositoryImpl.initialize();  // Singleton 초기화

// ✅ Good: Provider에서 사용
final repository = GetIt.instance<IUserRepository>();
```

**초기화 순서** (중요):
1. `main.dart`: `ProfileDIModule.initialize()`
2. `main.dart`: `UserRepositoryImpl.initialize()`
3. Provider/Widget: `GetIt.instance<IUserRepository>()` 사용

---

## 📊 통계

| 구분 | 파일 수 | 총 라인 수 | 주요 패턴 |
|------|---------|-----------|-----------|
| **Data** | 11 | ~1,813 | Extension, 3-Layer Caching, Singleton, Idempotency, Feature Isolation |
| **Domain** | 47 | ~2,426 | Freezed, Either, UseCase, Repository Interface |
| **Presentation** | 34 | ~6,922 | Riverpod 3.x, StreamProvider.family, ProfileActions |
| **DI** | 1 | ~157 | GetIt 등록, Singleton 초기화 |
| **문서** | 4 | ~6,200 | 통합 가이드 + 레이어별 상세 문서 |
| **총합** | **97** | **~17,518** | Clean Architecture v4.0 + 3-Layer Caching + Feature Isolation |

### Phase별 통계

| Phase | 날짜 | 변경사항 | 영향 |
|-------|------|---------|------|
| **Phase 2** | 2025-01-20 | DataSource 추상화 제거 (Storage 제외) | 코드 간결성 50% 향상 |
| **Phase 4** | 2025-01-29 | Extension Pattern 도입 | Mapper/DTO 제거, Auth Feature 100% 일치 |
| **Phase 6** | 2025-01-21 | 대규모 정리 (20→3 메서드) | 85% 메서드 축소, 1,329줄 삭제 |
| **Phase 6.5** | 2025-01-07 | ⭐ Feature 독립성 확보 | Post 의존 제거, 75% 데이터 경량화 |
| **Phase 7** | 2025-01-30 | 🔥 3-Layer 캐싱 통합 | 95% 성능 향상, 97% 비용 절감 |
| **Phase B-2** | 2025-11-11 | ✅ UpdateLastActiveUseCase 생성 | Clean Architecture 준수, app.dart → UseCase 패턴 |

---

## 🚀 시작하기

### 1. 새로운 프로필 기능 추가 시

**8단계 체크리스트**:

1. **Domain Entity 정의**: `domain/entities/` (Freezed 사용)
2. **Repository 인터페이스**: `domain/repositories/i_*_repository.dart`
3. **UseCase 생성**: `domain/usecases/*/` (Single Responsibility)
4. **Repository 구현**: `data/repositories/*_repository_impl.dart`
5. **Extension 작성**: `domain/entities/*_extensions.dart` (Firestore 변환)
6. **캐싱 전략**: `UnifiedCacheService` 메서드 추가 (필요 시)
7. **Provider 생성**: `presentation/providers/profile_providers.dart`
8. **DI 등록**: `di/profile_di_module.dart`

**예시: 새로운 '뱃지' 기능 추가**:
```dart
// 1. Domain Entity
@freezed class Badge with _$Badge {
  factory Badge({required String id, required String name}) = _Badge;
}

// 2. Repository Interface
abstract class IBadgeRepository {
  Future<Either<ProfileFailure, List<Badge>>> getUserBadges(String userId);
}

// 3. UseCase
class GetUserBadgesUseCase {
  final IBadgeRepository _repository;
  Future<Either<ProfileFailure, List<Badge>>> execute(String userId) =>
      _repository.getUserBadges(userId);
}

// 4. Repository Impl (3-Layer Caching)
class BadgeRepositoryImpl implements IBadgeRepository {
  final UnifiedCacheService _cache = UnifiedCacheService.instance;

  Future<Either<ProfileFailure, List<Badge>>> getUserBadges(String userId) async {
    // Cache 조회
    final cached = await _cache.getUserBadges(userId);
    if (cached != null) return right(cached);

    // Firestore 조회
    final doc = await _firestore.collection('users').doc(userId).get();
    // ... Extension으로 변환

    // Cache 저장
    await _cache.setUserBadges(userId, badges);
    return right(badges);
  }
}

// 5. Extension
extension BadgeFirestore on Badge {
  Map<String, dynamic> toFirestore() => {'id': id, 'name': name};
  static Badge fromFirestore(Map<String, dynamic> data) =>
      Badge(id: data['id'], name: data['name']);
}

// 6. Provider
final userBadgesProvider = FutureProvider.autoDispose.family<List<Badge>, String>(
  (ref, userId) async {
    final useCase = GetIt.instance<GetUserBadgesUseCase>();
    final result = await useCase.execute(userId);
    return result.fold((l) => throw l, (r) => r);
  },
);
```

### 2. 버그 수정 시

**문제 진단 플로우**:

1. **증상 파악**: 어느 레이어에서 발생? (UI/비즈니스/데이터)
   - UI 에러 → `presentation/README.md` 참조
   - 비즈니스 로직 에러 → `domain/README.md` 참조
   - Firebase/캐싱 에러 → `data/README.md` 참조

2. **해당 레이어 README 확인**: 섹션별 상세 설명 읽기

3. **파일 위치 찾기**: 위 "주요 파일 위치" 섹션 참조

4. **플로우 추적**:
   - 프로필 조회 에러 → A. 프로필 조회 플로우
   - 업데이트 에러 → B. 프로필 업데이트 플로우
   - Real-time 동기화 에러 → C. Real-time 플로우

5. **에러 타입 확인**: `domain/failures/profile_failure.dart` (12개 타입)

### 3. 성능 최적화 시 (3-Layer 캐싱 활용)

**최적화 체크리스트**:

1. **Cache Hit Rate 확인**:
   ```dart
   final stats = UnifiedCacheService.instance.getStatistics();
   print('Memory Hit: ${stats.memoryHitRate}%');  // Target: 80%+
   print('Hive Hit: ${stats.hiveHitRate}%');      // Target: 15%+
   ```

2. **TTL 조정**: `data/README.md` > 캐싱 전략 섹션
   - 자주 조회되는 데이터: TTL 늘리기 (1hr → 2hr)
   - 자주 변경되는 데이터: TTL 줄이기 (1hr → 30min)

3. **Provider 최적화**: `presentation/README.md` > keepAlive 패턴
   - StreamProvider: autoDispose → keepAlive 변경 (필요 시)
   - FutureProvider: cacheTime 조정

4. **Extension 효율성**: `data/README.md` > Extension Pattern 섹션
   - 불필요한 필드 변환 제거
   - 중첩 객체 변환 최적화

5. **Firestore 읽기 최소화**:
   - Cache 우선 조회 확인
   - 불필요한 watchUserProfile() Stream 제거
   - 배치 조회 활용 (`getMultipleProfiles()`)

---

## 🔍 자주 찾는 질문

<details>
<summary><strong>Q1. UserRepository는 왜 Singleton인가요?</strong></summary>

**A**: UserRepository는 앱 전체에서 **단일 사용자 세션**을 관리하기 때문입니다.

**이유**:
1. **전역 상태**: 현재 로그인한 사용자 정보는 앱 전체에서 공유
2. **캐시 공유**: 3-Layer 캐싱 효율성 극대화 (UnifiedCacheService Singleton 활용)
3. **Real-time 동기화**: 단일 Firestore Stream 구독 (메모리 효율)
4. **Auth 연동**: AuthContract와 1:1 대응

**초기화 필수**:
```dart
// main.dart
await ProfileDIModule.initialize();
await UserRepositoryImpl.initialize();
```

📖 상세: `data/README.md` > UserRepository 섹션
</details>

<details>
<summary><strong>Q2. 3-Layer 캐싱은 어떻게 동작하나요?</strong></summary>

**A**: **Memory → Hive → Firestore** 순차 조회로 95% Hit Rate 달성.

**플로우**:
1. **L1 Memory**: `SimpleMemoryCache` (LRU, 100 items, 5min TTL) → 80% hit (<1ms)
2. **L2 Hive**: Local DB (Unlimited, 24hr TTL) → 15% hit (10-30ms)
3. **L3 Firestore**: Offline Cache + Network → 5% hit (50-500ms)

**Cache Promotion**:
- L3 hit → L2 저장 → L1 승격 (다음 조회 시 <1ms)

**Cache Invalidation**:
- 업데이트 시: Memory + Hive 즉시 삭제
- TTL 만료 시: 자동 삭제 후 재조회

📖 상세: `data/README.md` > 3-Layer 캐싱 시스템 섹션
</details>

<details>
<summary><strong>Q3. UserProfile vs ProfileInfo 차이는?</strong></summary>

**A**: **UserProfile (44 fields)**은 통합 모델, **ProfileInfo (10 fields)**는 경량 조회용.

**중요**: country와 countryCode 필드는 **UserProfile에만 존재**합니다. ProfileInfo에는 포함되지 않습니다.

| 항목 | UserProfile | ProfileInfo |
|------|-------------|-------------|
| **필드 수** | 44개 (includes country, countryCode) | 10개 (no country/countryCode) |
| **용도** | CRUD 전체 작업 | 조회 전용 (경량) |
| **크기** | ~2KB | ~500B (75% 작음) |
| **사용 예** | 프로필 편집, 업데이트 | 목록 표시, 카드 |
| **Repository** | IUserRepository | IProfileRepository |

**언제 사용?**:
- **UserProfile**: 프로필 편집 화면, 상세 정보, CRUD
- **ProfileInfo**: 사용자 목록, 카드 위젯, 간단한 표시 (Phase 6.1 도입)

📖 상세: `domain/README.md` > Models 섹션
</details>

<details>
<summary><strong>Q4. Real-time 프로필 동기화는 어떻게 구현하나요?</strong></summary>

**A**: `StreamProvider.autoDispose.family` + Firestore WebSocket Stream.

**구현 패턴**:
```dart
// 1. Provider 정의
final profileStreamProvider = StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    yield null;  // 초기값

    final watchUseCase = ref.read(watchUserProfileUseCaseProvider);
    final stream = watchUseCase.execute(userId: params.userId);

    await for (final either in stream) {
      either.fold(
        (failure) => throw failure,
        (profile) => profile,
      );
      yield either.fold((l) => null, (r) => r);
    }
    ref.keepAlive();  // 캐싱 유지
  },
);

// 2. UI에서 사용
ref.watch(profileStreamProvider(ProfileStreamParams(userId: userId))).when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (profile) => profile == null ? Text('No data') : ProfileWidget(profile),
)
```

**Firestore Stream**: `users/{userId}` 문서 WebSocket 실시간 감시

📖 상세: `presentation/README.md` > Data Flow Diagrams 섹션
</details>

<details>
<summary><strong>Q5. Extension Pattern과 Mapper Pattern의 차이는?</strong></summary>

**A**:
- **Extension Pattern** (현재 사용): Dart Extension으로 변환 로직 추가, 간결하고 타입 안전
- **Mapper Pattern** (기존 방식): 별도 Mapper 클래스 + DTO 클래스, 보일러플레이트 많음

**Extension Pattern 장점**:
```dart
// ✅ Extension Pattern (간결)
extension UserProfileFirestore on UserProfile {
  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'email': email,
    'country': country,           // 🆕 IP-based auto-detection
    'countryCode': countryCode,   // 🆕 ISO 3166-1 alpha-2
    // ... 44 fields total
  };

  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      displayName: data['displayName'],
      email: data['email'],
      // ...
    );
  }
}

// 사용
final map = profile.toFirestore();  // 직관적
final profile = UserProfileFirestore.fromFirestore(doc);

// ❌ Mapper Pattern (복잡)
class UserProfileMapper {
  UserProfileDTO toDTO(UserProfile profile) { ... }
  UserProfile fromDTO(UserProfileDTO dto) { ... }
}
class UserProfileDTO { ... }  // 중복 클래스

// 사용
final mapper = UserProfileMapper();
final dto = mapper.toDTO(profile);  // 번거로움
```

📖 상세: `data/README.md` > Extension Pattern 섹션
</details>

<details>
<summary><strong>Q6. Phase 7 마이그레이션의 핵심은?</strong></summary>

**A**: **UnifiedCacheService 통합**으로 6개 Repository에 3-Layer 캐싱 적용.

**변경사항**:
1. **Repository 수정**: `SimpleMemoryCache` → `UnifiedCacheService.instance`
2. **Cache 메서드**: `getUserProfile()`, `setUserProfile()`, `clearUserProfile()` 등
3. **Hive 직렬화**: `MessagesModel.toJson()/fromJson()` 추가
4. **TTL 전략**: 데이터 타입별 캐시 수명 설정

**성과**:
- 95% 성능 향상 (300-500ms → 10-30ms)
- 97% 비용 절감 ($6.48 → $0.07)
- 100% 오프라인 지원

📖 상세: `data/README.md` > Phase 7 Migration 섹션
</details>

<details>
<summary><strong>Q7. 관심사 선택 제약사항은?</strong></summary>

**A**: **Expertise 최대 4개**, **Hobbies 최대 8개**.

**검증 위치**:
- **Repository**: `InterestsRepositoryImpl.updateUserInterests()` (line 46-58)
- **UseCase**: `UpdateUserInterestsUseCase` (비즈니스 규칙)
- **UI**: 선택 시 버튼 비활성화

**에러 타입**:
```dart
ProfileFailure.validation('expertise')  // 4개 초과
ProfileFailure.validation('hobbies')    // 8개 초과
```

📖 상세: `data/README.md` > InterestsRepository 섹션
</details>

---

## 📝 기여 가이드

### 코드 수정 시

1. **레이어 규칙 준수**:
   - Presentation → Domain → Data 방향으로만 의존
   - Domain은 프레임워크 독립 (Pure Dart)
   - Data는 Firebase SDK + UnifiedCacheService 사용

2. **패턴 일관성**:
   - Entity는 Freezed 사용
   - Repository는 Either 패턴
   - Extension으로 Firestore 변환
   - Provider는 Riverpod 2.x
   - 3-Layer Caching은 UnifiedCacheService 활용

3. **문서 업데이트**:
   - 파일 추가 시: 해당 레이어 README 업데이트
   - 아키텍처 변경 시: 이 통합 README 업데이트
   - Phase 추가 시: Migration History 기록

4. **테스트 작성**:
   - Domain Layer: 단위 테스트 (Mock Repository)
   - Data Layer: 통합 테스트 (Firebase Emulator)
   - Presentation Layer: Widget 테스트 (ProviderScope)

---

## 📞 문의 및 지원

- **버그 리포트**: GitHub Issues
- **아키텍처 질문**: 각 레이어 README의 "자주 찾는 질문" 섹션 참조
- **기능 제안**: Feature Request 템플릿 사용
- **3-Layer 캐싱 문의**: `data/README.md` > 3-Layer 캐싱 시스템 섹션

---

**마지막 업데이트**: 2025-01-30
**버전**: v4.0.0 (Phase 7 완료)
**작성자**: Profile Feature Team
