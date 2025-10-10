# 📋 Profile Feature → Clean Architecture v4.0 마이그레이션 계획

> **버전**: v2.0 | **최종 업데이트**: 2025-01-20 | **참조**: [Creation Feature README.md](../creation/README.md)

## 🎯 전체 목표

- **현재**: 36개 파일 (불완전한 구조)
- **목표**: 122개 파일 (Creation Feature 패턴 적용)
- **기간**: 10일 (Phase 0-5 + Phase 4.5 하이브리드 운영)
- **패턴**: Clean Architecture v4.0 + Phase 5 Coordinator + 점진적 마이그레이션

---

## 📊 Phase 0: 현재 상태 분석 및 삭제 계획 (Day 0, 2시간)

### 현재 구조 (36개 파일)

```
lib/features/profile/
├── data/ (10개)
│   ├── adapters/ (2개) ✅ 유지
│   ├── models/ (5개) ❌ 전체 삭제 예정
│   └── repositories/ (1개) ⚠️ 리팩토링 필요
│
├── domain/ (12개)
│   ├── models/ (12개) ⚠️ FirestoreRecord 제거 필요
│   ├── repositories/ (3개) ✅ 유지 (인터페이스만)
│   └── usecases/ (0개) ❌ 생성 필요
│
└── presentation/ (14개)
    ├── screens/ (10개) ✅ 유지 및 확장
    └── providers/ (0개) ❌ 생성 필요
```

### 삭제 대상 파일 (5개)

```
❌ data/models/
   ├── settings_model.dart          → domain/models/user_settings.dart로 대체
   ├── point_model.dart              → user_profile.pointsA/Q로 통합
   ├── contents_interests_model.dart → user_profile.interests로 통합
   ├── transactions_model.dart       → 별도 Feature로 분리 검토
   └── user_contents_model.dart      → Post Feature로 이동
```

**삭제 이유**:
1. **settings_model.dart** (113줄):
   - `domain/models/user_settings.dart` (148줄)와 기능 중복
   - UserSettings가 더 완전한 구현 (5개 알림 설정, Map 타입 privacySettings)
   - SettingsModel은 List<String> privacySettings로 제한적

2. **point_model.dart** (128줄):
   - `user_profile.pointsA`, `user_profile.pointsQ` 필드가 이미 존재
   - 별도 컬렉션 불필요, UserProfile에 통합 가능

3. **contents_interests_model.dart** (105줄):
   - userId + createdAt만 존재하는 미니멀 모델
   - `user_profile.interests` 필드로 통합 가능

4. **transactions_model.dart** (146줄):
   - 독립적인 트랜잭션 이력 기능
   - 별도 Feature로 분리 검토 필요 (Transactions Feature)

5. **user_contents_model.dart** (159줄):
   - Post Feature 경계에 속함 (contentType, visibility, tags)
   - Profile Feature에서 제거, Post Feature로 이동

---

## 🚀 Phase 1: 구조 정리 및 삭제 (Day 1, 4시간)

### 작업 내용

1. **data/models 삭제** (5개 파일)
2. **IUserRepository 리팩토링** (SettingsModel 제거)
3. **README 파일 생성** (각 레이어별)

### After Phase 1

```diff
lib/features/profile/
├── data/
│   ├── adapters/ (2개) ✅
-   ├── models/ (5개) ❌ 삭제 완료
│   ├── repositories/ (1개) ♻️ 리팩토링 완료
+   ├── datasources/ (0개 → 4개 생성 예정)
+   ├── dto/ (0개 → 8개 생성 예정)
+   └── mappers/ (0개 → 4개 생성 예정)
│
├── domain/
│   ├── models/ (12개) ⚠️
│   ├── repositories/ (3개 → 인터페이스 정리)
+   ├── usecases/ (0개 → 10개 생성 예정)
+   └── failures/ (0개 → 8개 생성 예정)
```

### 핵심 작업: IUserRepository 리팩토링

**Before** (`domain/repositories/i_user_repository.dart`):
```dart
import '../models/settings_model.dart';  // ❌ 삭제 예정

abstract class IUserRepository {
  // Settings queries
  Stream<List<SettingsModel>> querySettings({...});  // ❌
  Future<SettingsModel?> getUserSettings(String userId);  // ❌
  Future<void> updateUserSettings(String userId, SettingsModel settings);  // ❌
}
```

**After**:
```dart
import '../models/user_settings.dart';  // ✅ UserSettings 사용

abstract class IUserRepository {
  // Settings queries
  Stream<List<UserSettings>> querySettings({...});  // ✅
  Future<UserSettings?> getUserSettings(String userId);  // ✅
  Future<void> updateUserSettings(String userId, UserSettings settings);  // ✅
}
```

### README 생성 체크리스트

- [ ] `data/README.md` - Data Layer 설명
- [ ] `domain/README.md` - Domain Layer 설명
- [ ] `presentation/README.md` - Presentation Layer 설명

### 1.4. UserProfileAdapter 활용 전략

**발견된 기회**: `data/repositories/user_repository_impl.dart` (Lines 206-259)에 이미 UserProfileAdapter가 존재하지만 현재 마이그레이션 계획에서 언급되지 않음

**현재 Adapter 구조**:
```dart
// Lines 211-214: Bundle 생성 메서드
Future<UserProfileBundle?> getUserBundleByUid(String uid) async {
  final userProfile = await getUserByUid(uid);
  if (userProfile == null) return null;
  return UserProfileAdapter.createBundle(userProfile);
}

// Lines 226-231: Domain 모델 추출
Future<UserSettings?> getUserSettings(String uid) async {
  final userProfile = await getUserByUid(uid);
  if (userProfile == null) return null;
  final bundle = UserProfileAdapter.toDomainModels(userProfile);
  return bundle.settings;
}
```

**활용 방안**: UserProfileAdapter를 하이브리드 Provider의 브릿지로 활용

#### Adapter 기반 하이브리드 Provider 패턴

**파일**: `presentation/providers/profile_provider.dart` (Phase 4.5에서 구현)

```dart
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UserProfileAdapter _adapter;  // ✅ 기존 Adapter 활용

  // ━━━ 레거시 지원: StreamBuilder 유지 ━━━
  Stream<UserProfile> watchProfileLegacy(String userId) {
    return UsersModel.getDocument(ref).map((usersModel) {
      // 기존 UsersModel → Domain으로 변환
      return _adapter.toDomain(usersModel);
    });
  }

  // ━━━ 신규 방식: UseCase 기반 ━━━
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);
    result.fold(
      (failure) => _errorMessage = failure.getUserMessage(),
      (profile) => _profile = profile,
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

**점진적 전환 전략 (Week-by-Week)**:

| 주차 | 작업 내용 | 상태 |
|------|----------|------|
| **Week 1-2** | Adapter 기반 Provider 생성, 레거시 Stream 메서드 유지 | 병렬 시스템 테스트 |
| **Week 3-4** | 위젯별 순차 전환: StreamBuilder → Consumer + watchProfileLegacy() | 하이브리드 운영 |
| **Week 5-6** | UseCase 기반 메서드로 전환, Stream 메서드 @Deprecated | 신규 시스템 전환 |
| **Week 7** | 레거시 Stream 메서드 완전 제거 | 마이그레이션 완료 |

**Adapter 장점**:
1. **무중단 마이그레이션**: Stream 메서드를 유지하면서 UseCase 추가 가능
2. **기존 인프라 활용**: 이미 검증된 UserProfileAdapter 코드 재사용
3. **리스크 최소화**: 위젯별 순차 전환으로 롤백 용이

---

## 🏗️ Phase 2: Domain Layer 완성 (Day 2-3, 12시간)

### 2.1. UseCases 생성 (10개)

```
domain/usecases/
├── profile/
│   ├── get_user_profile_usecase.dart        # 프로필 조회
│   ├── update_user_profile_usecase.dart     # 프로필 업데이트
│   ├── upload_profile_image_usecase.dart    # 프로필 이미지 업로드
│   └── delete_user_profile_usecase.dart     # 프로필 삭제
│
├── settings/
│   ├── get_user_settings_usecase.dart       # 설정 조회
│   └── update_user_settings_usecase.dart    # 설정 업데이트
│
├── friends/
│   ├── get_friends_list_usecase.dart        # 친구 목록 조회
│   ├── add_friend_usecase.dart              # 친구 추가
│   └── remove_friend_usecase.dart           # 친구 제거
│
└── interests/
    └── update_user_interests_usecase.dart   # 관심사 업데이트
```

### UseCase 예제 코드 (Creation 패턴 적용)

**파일**: `domain/usecases/profile/get_user_profile_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 프로필 조회 UseCase
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 프로필 데이터 조회
/// - 에러 처리 및 Failure 변환
class GetUserProfileUseCase {
  final IProfileRepository _repository;

  GetUserProfileUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 프로필 조회 실행
  ///
  /// **Parameters**:
  /// - `userId`: 조회할 사용자 ID
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure('User ID cannot be empty'));
      }

      // 2. Repository 호출
      final profile = await _repository.getUserProfile(userId);

      // 3. 결과 검증
      if (profile == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      return Right(profile);
    } on FirebaseException catch (e) {
      return Left(FirestoreReadFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
```

**파일**: `domain/usecases/profile/update_user_profile_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 프로필 업데이트 UseCase
class UpdateUserProfileUseCase {
  final IProfileRepository _repository;

  UpdateUserProfileUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 프로필 업데이트 실행
  Future<Either<ProfileFailure, void>> execute({
    required UserProfile profile,
  }) async {
    try {
      // 1. 프로필 검증
      if (profile.userId.isEmpty) {
        return Left(ValidationFailure('User ID is required'));
      }
      if (profile.displayName.isEmpty) {
        return Left(ValidationFailure('Display name is required'));
      }

      // 2. Repository 호출
      await _repository.updateUserProfile(profile);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreWriteFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
```

### 2.2. Failures 생성 (8개)

```
domain/failures/
├── profile_failures.dart              # 기본 ProfileFailure
├── validation_failure.dart            # 유효성 검증 실패
├── firestore_read_failure.dart        # Firestore 읽기 실패
├── firestore_write_failure.dart       # Firestore 쓰기 실패
├── storage_failure.dart               # Storage 업로드 실패
├── network_failure.dart               # 네트워크 실패
├── profile_not_found_failure.dart     # 프로필 미발견
└── permission_denied_failure.dart     # 권한 거부
```

### Failure 패턴 (Domain Layer)

**파일**: `domain/failures/profile_failures.dart`

```dart
/// Profile Feature의 모든 Failure 기본 클래스
///
/// **Failure 패턴**: `getUserMessage()` 메서드로 사용자 친화적 에러 메시지 제공
abstract class ProfileFailure implements Exception {
  final String message;

  const ProfileFailure({required this.message});

  /// 사용자에게 표시할 친화적 에러 메시지
  ///
  /// **예시**:
  /// - 개발자용: "Firestore read failed: permission denied"
  /// - 사용자용: "프로필을 불러올 수 없습니다. 다시 시도해주세요."
  String getUserMessage();

  @override
  String toString() => 'ProfileFailure: $message';
}
```

**파일**: `domain/failures/validation_failure.dart`

```dart
import 'profile_failures.dart';

/// 유효성 검증 실패 Failure
class ValidationFailure extends ProfileFailure {
  const ValidationFailure(String message)
      : super(message: message);

  @override
  String getUserMessage() => '입력 정보를 확인해주세요: $message';
}
```

**파일**: `domain/failures/profile_not_found_failure.dart`

```dart
import 'profile_failures.dart';

/// 프로필 미발견 Failure
class ProfileNotFoundFailure extends ProfileFailure {
  final String userId;

  const ProfileNotFoundFailure({required this.userId})
      : super(message: 'Profile not found for user: $userId');

  @override
  String getUserMessage() => '프로필을 찾을 수 없습니다.';
}
```

**파일**: `domain/failures/firestore_read_failure.dart`

```dart
import 'profile_failures.dart';

/// Firestore 읽기 실패 Failure
class FirestoreReadFailure extends ProfileFailure {
  const FirestoreReadFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '데이터를 불러올 수 없습니다. 네트워크 연결을 확인해주세요.';
}
```

**파일**: `domain/failures/firestore_write_failure.dart`

```dart
import 'profile_failures.dart';

/// Firestore 쓰기 실패 Failure
class FirestoreWriteFailure extends ProfileFailure {
  const FirestoreWriteFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '저장에 실패했습니다. 다시 시도해주세요.';
}
```

**파일**: `domain/failures/storage_failure.dart`

```dart
import 'profile_failures.dart';

/// Storage 업로드 실패 Failure
class StorageFailure extends ProfileFailure {
  const StorageFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '이미지 업로드에 실패했습니다. 다시 시도해주세요.';
}
```

**파일**: `domain/failures/network_failure.dart`

```dart
import 'profile_failures.dart';

/// 네트워크 실패 Failure
class NetworkFailure extends ProfileFailure {
  const NetworkFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '네트워크 연결을 확인해주세요.';
}
```

**파일**: `domain/failures/permission_denied_failure.dart`

```dart
import 'profile_failures.dart';

/// 권한 거부 Failure
class PermissionDeniedFailure extends ProfileFailure {
  const PermissionDeniedFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '접근 권한이 없습니다.';
}
```

### 2.3. Domain Models 정리 (12개 → 순수 Dart 클래스)

**현재 문제**: 9개 모델이 FirestoreRecord 상속 (Clean Architecture 위반)

**해결 방안**: **실용적 접근** - 일단 유지, 이후 단계적 리팩토링

**이유**:
1. FirestoreRecord 제거는 대규모 리팩토링 필요 (기존 536줄 UserProfile 등)
2. 현재 마이그레이션 목표는 레이어 분리 완성
3. Domain Layer 순수성은 Phase 6 (향후 계획)에서 처리

```
domain/models/
├── core/                              # 핵심 엔티티
│   ├── user_profile.dart             ⚠️ FirestoreRecord → 나중에 리팩토링
│   ├── profile_info.dart             ✅ 이미 순수 Dart
│   └── user_stats.dart               ✅ 이미 순수 Dart
│
├── value_objects/                     # Value Objects
│   ├── user_settings.dart            ✅ 이미 순수 Dart
│   └── interest_model.dart           ⚠️ FirestoreRecord
│
└── supporting/                        # 지원 모델
    ├── friends_list_model.dart       ⚠️ FirestoreRecord
    ├── characters_model.dart         ⚠️ FirestoreRecord
    ├── premium_users_model.dart      ⚠️ FirestoreRecord
    └── jops_category_model.dart      ⚠️ FirestoreRecord + Algolia 의존성
```

---

## 🔧 Phase 3: Data Layer 구축 ✅ 완료 (Day 4-5, 실제 16시간)

> **완료일**: 2025-01-20
> **실제 작업 시간**: 16시간 (예상 14시간 대비 +2시간)
> **주요 차이점**: 모든 메서드 완전 구현 (Option 2 선택)

### 📊 계획 vs 실제 비교

| 항목 | 원래 계획 | 실제 구현 | 차이 |
|------|----------|----------|------|
| **DataSource 메서드** | ~20개 (4개 DS × 5개) | **46개** | +26개 (130% 증가) |
| **Repository 메서드** | ~30개 (6개 Repo × 5개) | **78개** | +48개 (160% 증가) |
| **Domain Models** | 12개 (기존) | **14개** (+2개) | Interest, Character 추가 |
| **DTOs** | 8개 | **8개** | 계획대로 |
| **Mappers** | 4개 | **4개** | 계획대로 |
| **고급 기능** | 없음 | **7개** | Haversine, 추천, 배치 등 |
| **총 코드 라인** | ~1,500줄 예상 | **~3,500줄** | +133% |

### 3.1. DataSources 생성 ✅ 완료 (8개 파일, 46개 메서드)

```
data/datasources/
├── interfaces/ (4개)
│   ├── i_profile_datasource.dart      ✅ 14개 메서드 (계획: 5개)
│   ├── i_friends_datasource.dart      ✅ 25개 메서드 (신규: 0개)
│   ├── i_settings_datasource.dart     ✅ 3개 메서드
│   └── i_storage_datasource.dart      ✅ 4개 메서드
│
└── implementations/ (4개)
    ├── firebase_profile_datasource.dart    ✅ 250줄
    ├── firebase_friends_datasource.dart    ✅ 440줄 (가장 복잡)
    ├── firebase_settings_datasource.dart   ✅ 40줄
    └── firebase_storage_datasource.dart    ✅ 80줄
```

#### 🔥 주요 확장 사항

**1. IProfileDataSource (5→14 메서드)**
```dart
// 원래 계획 (5개 기본 메서드)
- getProfile()
- updateProfile()
- watchProfile()
- updateField()
- updateFields()

// 실제 추가된 고급 메서드 (9개)
+ searchProfiles()           // 복합 검색 (이름, 관심사, 성별, 나이, 거리)
+ getSuggestedProfiles()     // AI 추천
+ blockUser() / unblockUser()
+ getBlockedUsers()
+ reportUser()
+ isProfileComplete()
+ getProfileCompletionPercentage()
```

**추가 이유**:
- Phase 4 Providers가 필요로 하는 모든 기능 미리 구현
- 사용자 검색/추천 시스템의 완전한 구현
- 프로필 완성도 추적 기능

**2. IFriendsDataSource (0→25 메서드, 완전 신규)**
```dart
// 친구 관리 (4개)
- getFriends(), getFriendProfiles(), watchFriends(), removeFriend()

// 친구 요청 (6개)
- sendFriendRequest(), acceptFriendRequest(), rejectFriendRequest()
- cancelFriendRequest(), getPendingFriendRequests(), getSentFriendRequests()

// 친구 상태 (3개)
- areFriends(), hasPendingFriendRequest(), getFriendsCount()

// 검색 & 추천 (4개)
- getMutualFriends(), getFriendSuggestions(), searchFriends(), getFriendsByInterest()

// 온라인 상태 (2개)
- getOnlineFriends(), watchOnlineFriends()

// 활동 & 메타데이터 (2개)
- getRecentFriendsActivity(), updateFriendshipMetadata()
```

**추가 이유**:
- IFriendsRepository 인터페이스가 25개 메서드 요구
- 완전한 소셜 기능 구현 필요

#### 🛠️ 구현된 고급 기술 (7가지)

1. **Haversine Formula (지리적 거리 계산)**
   - 파일: `firebase_profile_datasource.dart:236-248`
   - 목적: 사용자 위치 기반 검색 (maxDistance 필터)
   - 정확도: ±10m (지구 곡률 고려)

2. **Friend Recommendation Algorithm (친구 추천)**
   - 파일: `firebase_friends_datasource.dart:240-280`
   - 로직: 친구의 친구 분석 → 상호 친구 수로 정렬
   - 성능: 최대 5명의 친구만 분석하여 O(n) 유지

3. **Online Status Tracking (온라인 상태)**
   - 파일: `firebase_friends_datasource.dart:302-318`
   - 기준: 최근 5분 내 활동 감지
   - 실시간: Stream으로 변경사항 감시

4. **Batch Operations (원자적 업데이트)**
   - 파일: `firebase_friends_datasource.dart:78-95`
   - 목적: 친구 요청 양방향 업데이트의 원자성 보장
   - 사용: WriteBatch로 2개 문서 동시 업데이트

5. **Chunked Queries (대량 쿼리)**
   - 파일: `firebase_friends_datasource.dart:268-278`
   - 문제: Firestore whereIn 최대 10개 제한
   - 해결: ID 리스트를 10개씩 분할하여 순차 쿼리

6. **Stream.asyncMap (비동기 변환)**
   - 파일: `characters_repository_impl.dart:96-113`
   - 목적: 실시간 스트림에서 추가 Firestore 쿼리
   - 사용: 사용자 캐릭터 ID → 캐릭터 상세 정보 조회

7. **Type Conversion Logic (타입 안전성)**
   - 파일: `user_profile_mapper.dart:14-24`
   - 문제: LatLng (Flutter) ↔ GeoPoint (Firestore) 불일치
   - 해결: 양방향 변환 로직 구현

---

### DataSource 패턴 (Creation 적용)

**파일**: `data/datasources/interfaces/i_profile_datasource.dart`

```dart
/// 프로필 DataSource 인터페이스
///
/// **책임**: Firestore 'users' 컬렉션과의 직접 통신
abstract class IProfileDataSource {
  /// 프로필 조회
  Future<Map<String, dynamic>?> getProfile(String userId);

  /// 프로필 생성
  Future<void> createProfile(String userId, Map<String, dynamic> data);

  /// 프로필 업데이트
  Future<void> updateProfile(String userId, Map<String, dynamic> data);

  /// 프로필 삭제
  Future<void> deleteProfile(String userId);

  /// 프로필 실시간 감시
  Stream<Map<String, dynamic>?> watchProfile(String userId);
}
```

**파일**: `data/datasources/implementations/firebase_profile_datasource.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/i_profile_datasource.dart';

/// Firebase Firestore 프로필 DataSource 구현
class FirebaseProfileDataSource implements IProfileDataSource {
  final FirebaseFirestore _firestore;

  FirebaseProfileDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  @override
  Future<void> createProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  @override
  Future<void> deleteProfile(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Stream<Map<String, dynamic>?> watchProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }
}
```

### 3.2. DTOs 생성 ✅ 완료 (8개 파일, 113개 필드)

```
data/dto/
├── user_profile_dto.dart       ✅ 44 필드 (Firestore 직렬화)
├── profile_info_dto.dart       ✅ 15 필드
├── user_settings_dto.dart      ✅ 18 필드
├── user_stats_dto.dart         ✅ 12 필드
├── interest_dto.dart           ✅ 5 필드
├── character_dto.dart          ✅ 7 필드
├── auth_user_dto.dart          ✅ 8 필드
└── storage_upload_dto.dart     ✅ 4 필드
```

**총 DTO 필드**: 113개 (100+ DTO 필드 정의)

### DTO 패턴 (Firestore ↔ Dart)

**파일**: `data/dto/user_profile_dto.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// UserProfile DTO
///
/// **책임**: Firestore 문서 구조와 Dart 객체 간 변환
class UserProfileDto {
  final String? userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final int? pointsA;
  final int? pointsQ;
  final DateTime? createdAt;
  final DateTime? lastActive;
  // ... 44 fields from UserProfile

  const UserProfileDto({
    this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.pointsA,
    this.pointsQ,
    this.createdAt,
    this.lastActive,
  });

  /// Firestore → DTO
  factory UserProfileDto.fromFirestore(Map<String, dynamic> data) {
    return UserProfileDto(
      userId: data['userId'] as String?,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      pointsA: data['pointsA'] as int?,
      pointsQ: data['pointsQ'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (pointsA != null) 'pointsA': pointsA,
      if (pointsQ != null) 'pointsQ': pointsQ,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (lastActive != null) 'lastActive': Timestamp.fromDate(lastActive!),
    };
  }
}
```

### 3.3. Mappers 생성 ✅ 완료 (4개 파일)

```
data/mappers/
├── user_profile_mapper.dart    ✅ LatLng ↔ GeoPoint 변환
├── profile_info_mapper.dart    ✅
├── user_settings_mapper.dart   ✅ Map null-safety 처리
└── user_stats_mapper.dart      ✅
```

#### 🐛 해결된 타입 이슈

**Issue #1: LatLng vs GeoPoint**
- **문제**: UserProfile은 LatLng 사용, Firestore는 GeoPoint 요구
- **해결**: Mapper에서 수동 변환 로직 구현
- **파일**: `user_profile_mapper.dart:14-24, 36-46`

**Issue #2: Map Null Safety**
- **문제**: UserSettings의 Map<String, dynamic> 필드가 non-nullable
- **해결**: `Map<String, dynamic>.from(data['field'] ?? {})` 패턴 적용
- **파일**: `profile_repository_impl.dart:85-95`

---

### Mapper 패턴 (DTO ↔ Domain Model)

**파일**: `data/mappers/user_profile_mapper.dart`

```dart
import '../../domain/models/user_profile.dart';
import '../dto/user_profile_dto.dart';

/// UserProfile Mapper
///
/// **책임**: DTO와 Domain Model 간 양방향 변환
class UserProfileMapper {
  /// DTO → Domain Model
  static UserProfile toDomain(UserProfileDto dto) {
    return UserProfile(
      userId: dto.userId ?? '',
      email: dto.email ?? '',
      displayName: dto.displayName ?? '',
      photoUrl: dto.photoUrl,
      pointsA: dto.pointsA ?? 0,
      pointsQ: dto.pointsQ ?? 0,
      createdAt: dto.createdAt ?? DateTime.now(),
      lastActive: dto.lastActive ?? DateTime.now(),
    );
  }

  /// Domain Model → DTO
  static UserProfileDto fromDomain(UserProfile profile) {
    return UserProfileDto(
      userId: profile.userId,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      pointsA: profile.pointsA,
      pointsQ: profile.pointsQ,
      createdAt: profile.createdAt,
      lastActive: profile.lastActive,
    );
  }
}
```

### 3.4. Repositories 구현 ✅ 완료 (6개 파일 + 2개 도메인 모델)

```
data/repositories/
├── profile_repository_impl.dart      ✅ 21개 메서드 (계획: 5개)
├── friends_repository_impl.dart      ✅ 25개 메서드 (계획: 5개)
├── settings_repository_impl.dart     ✅ 3개 메서드
├── interests_repository_impl.dart    ✅ 3개 메서드 (validation 포함)
├── characters_repository_impl.dart   ✅ 5개 메서드
└── user_repository_impl.dart         ♻️ 인터페이스 리팩토링

domain/models/ (추가 생성)
├── interest.dart                     ✅ 신규 도메인 모델
└── character.dart                    ✅ 신규 도메인 모델
```

#### 📝 추가된 도메인 모델

**Interest (관심사)**
- 파일: `domain/models/interest.dart`
- 필드: id, name, category, weight, selectedAt
- 제약: expertise 최대 4개, hobbies 최대 8개
- 비고: 원래 계획에 없었지만 IInterestsRepository 요구사항으로 생성

**Character (캐릭터/아바타)**
- 파일: `domain/models/character.dart`
- 필드: characterId, name, imageUrl, description, isActive, characterType, createdAt
- 구조: 2-collection (users.characterId → characters 컬렉션 참조)
- 비고: 원래 계획에 없었지만 ICharactersRepository 요구사항으로 생성

#### 🔥 Repository 확장 사항

**ProfileRepositoryImpl (5→21 메서드)**
```dart
// 원래 계획 (5개 기본 메서드)
- getUserProfile()
- updateUserProfile()
- deleteUserProfile()
- getUserProfileStream()
- uploadProfileImage()

// 실제 추가된 메서드 (16개)
+ getProfileInfo()              // 경량 프로필 조회
+ getUserSettings()             // 설정 조회
+ getUserStats()                // 통계 조회
+ getAuthUser()                 // 인증 정보
+ updateProfileInfo()           // 부분 업데이트
+ searchProfiles()              // 복합 검색
+ getSuggestedProfiles()        // 추천
+ blockUser() / unblockUser()   // 차단 관리
+ getBlockedUsers()             // 차단 목록
+ reportUser()                  // 신고
+ isProfileComplete()           // 완성도 확인
+ getProfileCompletionPercentage() // 완성도 %
+ updateProfileImage()          // 이미지 업데이트
+ deleteProfileImage()          // 이미지 삭제
```

**FriendsRepositoryImpl (0→25 메서드, 완전 신규)**
```dart
// 모든 25개 메서드 구현 완료
// (친구 관리 4개 + 친구 요청 6개 + 상태 3개 + 검색/추천 4개 + 온라인 2개 + 메타데이터 2개)
```

**InterestsRepositoryImpl (3개 메서드 + Validation)**
```dart
- updateUserInterests()   // expertise 4개, hobbies 8개 제약 검증
- getUserInterests()      // List<String> → List<Interest> 변환
- watchUserInterests()    // 실시간 감시

// Phase 5 TODO: 'interest' 컬렉션 조회하여 category, weight 가져오기
```

**CharactersRepositoryImpl (5개 메서드)**
```dart
- getUserCharacter()      // 2-collection 조회 (users + characters)
- setUserCharacter()      // 캐릭터 존재 여부 검증
- clearUserCharacter()    // 캐릭터 선택 해제
- watchUserCharacter()    // Stream.asyncMap으로 실시간 조회
- getAvailableCharacters() // 활성 캐릭터 목록
```

---

### Repository 패턴 (Domain ↔ Data)

**파일**: `data/repositories/profile_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/failures/profile_failures.dart';
import '../datasources/interfaces/i_profile_datasource.dart';
import '../mappers/user_profile_mapper.dart';
import '../dto/user_profile_dto.dart';

/// ProfileRepository 구현
///
/// **책임**:
/// - DataSource를 통한 데이터 접근
/// - DTO ↔ Domain Model 변환 (Mapper 사용)
/// - 에러 처리 및 Failure 변환
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileDataSource _dataSource;
  final UserProfileMapper _mapper;

  ProfileRepositoryImpl({
    required IProfileDataSource dataSource,
    required UserProfileMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(
    String userId,
  ) async {
    try {
      final data = await _dataSource.getProfile(userId);

      if (data == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      final dto = UserProfileDto.fromFirestore(data);
      final profile = _mapper.toDomain(dto);

      return Right(profile);
    } on FirebaseException catch (e) {
      return Left(FirestoreReadFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<ProfileFailure, void>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      final dto = _mapper.fromDomain(profile);
      final data = dto.toFirestore();

      await _dataSource.updateProfile(profile.userId, data);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirestoreWriteFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
```

### 📈 Phase 3 완료 통계

| 항목 | 수량 | 비고 |
|------|------|------|
| **생성된 파일** | 26개 | DataSources(8) + DTOs(8) + Mappers(4) + Repos(6) |
| **총 코드 라인** | ~3,500줄 | 계획 대비 +133% |
| **DataSource 메서드** | 46개 | IProfile(14) + IFriends(25) + ISettings(3) + IStorage(4) |
| **Repository 메서드** | 78개 | Profile(21) + Friends(25) + Settings(3) + Interests(3) + Characters(5) + User(21) |
| **DTO 필드** | 113개 | 100+ 필드 정의 |
| **Mapper 변환** | 4개 | 양방향 변환 (Domain ↔ DTO) |
| **고급 기능** | 7가지 | Haversine, 추천, 배치, 청크, Stream 등 |
| **추가 Domain Models** | 2개 | Interest, Character (계획에 없었음) |

### ⚠️ 계획 대비 주요 차이점

#### 1. Option 2 선택 (모든 메서드 완전 구현)
- **결정 시점**: Phase 3.1 시작 전
- **선택 이유**: Phase 4 Providers가 필요로 하는 모든 기능을 미리 구현
- **영향**: 작업 시간 14시간 → 16시간 (+2시간)

#### 2. 도메인 모델 추가 생성
- **추가된 모델**: Interest, Character
- **생성 이유**: IInterestsRepository, ICharactersRepository가 요구
- **원래 계획**: Phase 2에서 생성 예정이었으나 누락

#### 3. 고급 기능 구현
- **계획**: 기본 CRUD만 구현
- **실제**: 7가지 고급 알고리즘/패턴 구현 (Haversine, 친구 추천 등)
- **정당성**: 완전한 소셜 앱 기능 제공

#### 4. Freezed 포기
- **시도**: Interest, Character를 Freezed로 생성 시도
- **문제**: build_runner가 코드 생성 실패 (0 outputs)
- **해결**: 일반 Dart 클래스로 전환 (fromJson/toJson 수동 구현)

### ✅ Phase 3 체크리스트

- [x] Phase 3.1: DataSources 생성 (8개 파일, 46개 메서드)
- [x] Phase 3.2: DTOs 생성 (8개 파일, 113개 필드)
- [x] Phase 3.3: Mappers 생성 (4개 파일)
- [x] Phase 3.4: Repositories 구현 (6개 파일, 78개 메서드)
- [x] Phase 3.4: 누락된 Domain Models 생성 (Interest, Character)
- [x] 타입 안전성 이슈 해결 (LatLng ↔ GeoPoint)
- [x] Null Safety 이슈 해결 (Map 타입)
- [x] ProfileFailure 사용법 수정 (factory → 구체 클래스)
- [x] IUserRepository 인터페이스 리팩토링

---

## 🔮 Phase 3 확장이 Phase 4-5에 미치는 영향

> **작성일**: 2025-01-20
> **목적**: Phase 3 완전 구현이 향후 작업에 미치는 긍정적/부정적 영향 분석

### ✅ 긍정적 영향

#### 1. Phase 4 Providers 작업 간소화
**변경 전 예상**:
- Providers가 부족한 Repository 메서드를 우회하기 위해 복잡한 로직 필요
- 예: 친구 추천 기능을 Provider에서 수동으로 구현해야 했음

**변경 후 실제**:
- Providers는 UseCase만 호출하면 됨 (비즈니스 로직 불필요)
- 예: `await _getFriendSuggestionsUseCase.execute()` 한 줄로 완료

**예상 시간 절감**: Phase 4 작업 16시간 → 12-14시간 예상

#### 2. Phase 5 Coordinators의 풍부한 기능
**추가된 기능**:
- OnboardingCoordinator에서 프로필 완성도 추적 가능 (`getProfileCompletionPercentage()`)
- FriendsCoordinator에서 친구 추천 시스템 즉시 활용 가능
- SearchCoordinator에서 복합 검색 (거리, 나이, 관심사) 바로 구현 가능

**비즈니스 가치**: MVP 출시 시 경쟁력 있는 기능 제공

#### 3. 확장성 확보
**미래 기능 대비**:
- 온라인 상태 표시 (`getOnlineFriends()`) - 채팅 기능 확장 시 바로 활용
- 친구 활동 피드 (`getRecentFriendsActivity()`) - 소셜 피드 구현 시 활용
- 사용자 차단/신고 (`blockUser()`, `reportUser()`) - 안전 기능 즉시 활용

#### 4. 테스트 용이성
**단위 테스트**:
- 각 Repository 메서드가 단일 책임 → 테스트 작성 간단
- Mock DataSource로 모든 시나리오 격리 테스트 가능

### ⚠️ 주의 사항

#### 1. Phase 4 UseCase 수 증가
**원래 계획**: 10개 UseCase
**예상 실제**: 30-40개 UseCase 필요

**이유**:
- 각 Repository 메서드마다 UseCase 필요
- 예: ProfileRepository 21개 메서드 → 21개 UseCase

**대응 방안**:
- 유사한 UseCase 그룹화 (예: UpdateProfileUseCase에 여러 업데이트 통합)
- 자주 사용되는 메서드만 UseCase 생성, 나머지는 Provider에서 직접 Repository 호출 허용

#### 2. Phase 4 작업 우선순위 조정 필요
**원래 계획**: 모든 Provider를 동시에 구현
**권장 방식**: 핵심 Provider부터 순차 구현

**권장 순서**:
1. ProfileProvider (가장 자주 사용)
2. SettingsProvider (온보딩 필수)
3. InterestsProvider (온보딩 필수)
4. FriendsProvider (소셜 기능)
5. CharactersProvider (선택 기능)

#### 3. 문서화 부담 증가
**Phase 3 문서화 부족**:
- 46개 DataSource 메서드 중 상세 문서화된 것: 약 50%
- 고급 알고리즘 (Haversine, 추천) 설명 부족

**Phase 4 전 필요 작업**:
- [ ] README.md 업데이트: 각 Repository 메서드 용도 설명
- [ ] API 문서 생성: 복잡한 메서드 (searchProfiles, getFriendSuggestions) 상세 설명
- [ ] 예제 코드: 자주 사용될 패턴의 사용 예제 작성

### 📊 Phase 4-5 작업량 재추정

| Phase | 원래 예상 | 새 예상 | 변동 | 이유 |
|-------|----------|---------|------|------|
| **Phase 4** | 16시간 | **12-14시간** | -2~4시간 | Repository 완성으로 Provider 로직 간소화 |
| **Phase 5** | 8시간 | **6-8시간** | -0~2시간 | Coordinator가 활용할 기능 이미 준비됨 |
| **문서화** | 2시간 | **4-6시간** | +2~4시간 | 확장된 API 문서화 필요 |
| **총계** | 26시간 | **22-28시간** | -4~+2시간 | 순 작업량 비슷하거나 약간 감소 |

### 🎯 Phase 4 업데이트 계획

#### UseCase 생성 전략 수정

**원래 계획**:
```
domain/usecases/profile/
├── get_user_profile_usecase.dart
├── update_user_profile_usecase.dart
├── upload_profile_image_usecase.dart
└── delete_user_profile_usecase.dart
```

**업데이트된 계획**:
```
domain/usecases/profile/
├── get_user_profile_usecase.dart
├── update_user_profile_usecase.dart
├── upload_profile_image_usecase.dart
├── delete_user_profile_usecase.dart
├── get_profile_info_usecase.dart           # 신규
├── search_profiles_usecase.dart            # 신규 (복합 검색)
├── get_suggested_profiles_usecase.dart     # 신규 (추천)
├── block_user_usecase.dart                 # 신규
├── report_user_usecase.dart                # 신규
└── get_profile_completion_usecase.dart     # 신규

domain/usecases/friends/
├── get_friends_list_usecase.dart
├── send_friend_request_usecase.dart        # 신규
├── accept_friend_request_usecase.dart      # 신규
├── reject_friend_request_usecase.dart      # 신규
├── remove_friend_usecase.dart
├── get_friend_suggestions_usecase.dart     # 신규 (추천 알고리즘)
├── get_mutual_friends_usecase.dart         # 신규
├── search_friends_usecase.dart             # 신규
└── get_online_friends_usecase.dart         # 신규

domain/usecases/interests/
├── update_user_interests_usecase.dart      # validation 포함
└── get_user_interests_usecase.dart

domain/usecases/characters/
├── get_user_character_usecase.dart
├── set_user_character_usecase.dart
└── get_available_characters_usecase.dart
```

**총 UseCase 수**: 10개 → **28개** (+18개)

#### Provider 구현 전략 수정

**ProfileProvider 확장**:
```dart
class ProfileProvider extends ChangeNotifier {
  // 원래 계획된 메서드 (4개)
  Future<void> loadProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<void> uploadProfileImage(File image);
  Future<void> deleteProfile();

  // 추가 필요 메서드 (8개)
  Future<void> searchUsers(String query, {filters});  // 복합 검색
  Future<void> loadSuggestedProfiles();               // 추천
  Future<void> blockUser(String userId);              // 차단
  Future<void> reportUser(String userId, String reason); // 신고
  double getProfileCompletionPercentage();            // 완성도
  Future<void> loadBlockedUsers();                    // 차단 목록
  Future<void> unblockUser(String userId);            // 차단 해제
  Future<void> loadProfileInfo(String userId);        // 경량 조회
}
```

**FriendsProvider (신규)**:
```dart
class FriendsProvider extends ChangeNotifier {
  // 친구 관리 (4개)
  Future<void> loadFriends();
  Future<void> removeFriend(String friendId);

  // 친구 요청 (6개)
  Future<void> sendFriendRequest(String userId);
  Future<void> acceptFriendRequest(String requesterId);
  Future<void> rejectFriendRequest(String requesterId);
  Future<void> cancelFriendRequest(String userId);
  Future<void> loadPendingRequests();
  Future<void> loadSentRequests();

  // 검색 & 추천 (4개)
  Future<void> loadFriendSuggestions();              // 추천 알고리즘
  Future<void> searchFriends(String query);
  Future<void> loadMutualFriends(String userId);
  Future<void> loadFriendsByInterest(String interest);

  // 온라인 상태 (1개)
  Future<void> loadOnlineFriends();

  // 총 15개 메서드 (원래 계획: 3개)
}
```

### 📝 Phase 5 TODO 항목

**InterestsRepositoryImpl에서 발견된 미완성 기능**:
```dart
// TODO: Phase 5 - 'interest' 컬렉션 조회하여 category, weight 가져오기
// 현재: List<String> interests에서 name만 추출하여 기본값(category='hobby', weight=0.5) 사용
// 개선: Firestore 'interest' 컬렉션 조회하여 실제 category, weight, icon 등 가져오기
```

**CharactersRepositoryImpl에서 발견된 레거시 필드**:
```dart
// 'characters' 컬렉션 필드명이 레거시 (CharactersName, CharactersImageUrl)
// Phase 5에서 Firestore 필드명 정규화 필요: CharactersName → name
```

---

## 🧩 Phase 4.0: Domain Layer - UseCases 생성 (Day 6, 10-12시간)

### 개요

**목표**: 비즈니스 로직을 담당하는 28개 UseCase 생성
**의존성**: Phase 3 완료 (Repositories 78개 메서드 준비됨)
**패턴**: 단일 책임 원칙 + Repository 추상화 + `Either<Failure, Result>` 반환

**핵심 원칙**:
- 각 UseCase는 단일 비즈니스 작업만 담당
- Repository 인터페이스에만 의존 (구현체 독립)
- `Either<ProfileFailure, T>` 패턴으로 에러 처리
- UI/Framework 독립적인 순수 비즈니스 로직

### 4.0.1. UseCase 파일 구조 (28개)

```
domain/usecases/
├── profile/ (10개)
│   ├── get_user_profile_usecase.dart
│   ├── update_user_profile_usecase.dart
│   ├── upload_profile_image_usecase.dart
│   ├── delete_user_profile_usecase.dart
│   ├── get_profile_info_usecase.dart           # 경량 조회
│   ├── search_profiles_usecase.dart            # 복합 검색 (거리, 나이, 관심사)
│   ├── get_suggested_profiles_usecase.dart     # 추천 알고리즘
│   ├── block_user_usecase.dart                 # 사용자 차단
│   ├── report_user_usecase.dart                # 사용자 신고
│   └── get_profile_completion_usecase.dart     # 프로필 완성도 (%)
│
├── friends/ (9개)
│   ├── get_friends_list_usecase.dart
│   ├── send_friend_request_usecase.dart        # 친구 요청 전송
│   ├── accept_friend_request_usecase.dart      # 친구 요청 수락
│   ├── reject_friend_request_usecase.dart      # 친구 요청 거부
│   ├── remove_friend_usecase.dart
│   ├── get_friend_suggestions_usecase.dart     # 친구 추천 (상호 친구 기반)
│   ├── get_mutual_friends_usecase.dart         # 상호 친구 목록
│   ├── search_friends_usecase.dart             # 친구 검색
│   └── get_online_friends_usecase.dart         # 온라인 친구 목록
│
├── interests/ (2개)
│   ├── update_user_interests_usecase.dart      # validation 포함 (expertise ≤4, hobbies ≤8)
│   └── get_user_interests_usecase.dart
│
├── characters/ (3개)
│   ├── get_user_character_usecase.dart
│   ├── set_user_character_usecase.dart
│   └── get_available_characters_usecase.dart
│
└── settings/ (4개)
    ├── get_user_settings_usecase.dart
    ├── update_user_settings_usecase.dart
    ├── get_notification_settings_usecase.dart
    └── update_notification_settings_usecase.dart
```

**총 28개 UseCase**

### 4.0.2. 핵심 UseCase 구현 예시

#### GetUserProfileUseCase (기본 패턴)

**파일**: `domain/usecases/profile/get_user_profile_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 사용자 프로필 조회 UseCase
///
/// **책임**: 단일 사용자의 전체 프로필 정보 조회
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, UserProfile>
class GetUserProfileUseCase {
  final IProfileRepository _repository;

  GetUserProfileUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 사용자 프로필 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(UserProfile)`: 프로필 조회 성공
  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async {
    return await _repository.getUserProfile(userId);
  }
}
```

#### SearchProfilesUseCase (복합 검색)

**파일**: `domain/usecases/profile/search_profiles_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 사용자 프로필 복합 검색 UseCase
///
/// **책임**: 거리, 나이, 관심사 기반 사용자 검색
/// **의존성**: IProfileRepository (Haversine 공식 사용)
/// **반환**: Either<ProfileFailure, List<UserProfile>>
class SearchProfilesUseCase {
  final IProfileRepository _repository;

  SearchProfilesUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 복합 검색 실행
  ///
  /// **Parameters**:
  /// - `lat`: 기준 위도
  /// - `lng`: 기준 경도
  /// - `radiusKm`: 검색 반경 (km)
  /// - `minAge`: 최소 나이 (선택)
  /// - `maxAge`: 최대 나이 (선택)
  /// - `interests`: 관심사 필터 (선택)
  /// - `limit`: 최대 결과 수 (기본 20)
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 잘못된 파라미터 (lat/lng 범위 초과)
  /// - `Left(FirestoreReadFailure)`: Firestore 쿼리 실패
  /// - `Right(List<UserProfile>)`: 검색 결과 (거리순 정렬)
  Future<Either<ProfileFailure, List<UserProfile>>> execute({
    required double lat,
    required double lng,
    required double radiusKm,
    int? minAge,
    int? maxAge,
    List<String>? interests,
    int limit = 20,
  }) async {
    // 위도/경도 범위 검증
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return Left(ValidationFailure(
        message: '잘못된 위도/경도 값입니다.',
      ));
    }

    // Repository 검색 메서드 호출
    return await _repository.searchProfiles(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      minAge: minAge,
      maxAge: maxAge,
      interests: interests,
      limit: limit,
    );
  }
}
```

#### UpdateUserInterestsUseCase (Validation 로직 포함)

**파일**: `domain/usecases/interests/update_user_interests_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/interest.dart';
import '../../failures/profile_failures.dart';

/// 사용자 관심사 업데이트 UseCase
///
/// **책임**: 관심사 validation + Repository 업데이트
/// **제약사항**: expertise ≤ 4개, hobbies ≤ 8개
/// **의존성**: IProfileRepository
class UpdateUserInterestsUseCase {
  final IProfileRepository _repository;

  UpdateUserInterestsUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 관심사 업데이트
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `interests`: 업데이트할 관심사 리스트
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 제약 조건 위반
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(void)`: 업데이트 성공
  Future<Either<ProfileFailure, void>> execute({
    required String userId,
    required List<Interest> interests,
  }) async {
    // Validation: expertise 개수 확인
    final expertiseCount = interests
        .where((interest) => interest.category == 'expertise')
        .length;
    if (expertiseCount > 4) {
      return Left(ValidationFailure(
        message: '전문 분야는 최대 4개까지 선택 가능합니다.',
      ));
    }

    // Validation: hobbies 개수 확인
    final hobbiesCount = interests
        .where((interest) => interest.category == 'hobby')
        .length;
    if (hobbiesCount > 8) {
      return Left(ValidationFailure(
        message: '취미는 최대 8개까지 선택 가능합니다.',
      ));
    }

    // Repository 업데이트 호출
    return await _repository.updateUserInterests(userId, interests);
  }
}
```

### 4.0.3. UseCase 작업 우선순위

**P0 (필수 - Day 6 전반, 4-5시간)**:
프로필 페이지 및 온보딩 화면에 필수적인 UseCase

1. `GetUserProfileUseCase` - 프로필 메인 페이지
2. `UpdateUserProfileUseCase` - 프로필 편집
3. `GetUserSettingsUseCase` - 설정 화면
4. `UpdateUserSettingsUseCase` - 설정 저장
5. `GetUserInterestsUseCase` - 관심사 표시
6. `UpdateUserInterestsUseCase` - 관심사 온보딩
7. `GetUserCharacterUseCase` - 캐릭터 표시
8. `SetUserCharacterUseCase` - 캐릭터 선택
9. `GetAvailableCharactersUseCase` - 캐릭터 목록
10. `UploadProfileImageUseCase` - 프로필 이미지 업로드

**P1 (중요 - Day 6 후반, 3-4시간)**:
친구 기능 및 추가 프로필 기능

11. `GetFriendsListUseCase` - 친구 목록 표시
12. `SendFriendRequestUseCase` - 친구 요청
13. `AcceptFriendRequestUseCase` - 친구 수락
14. `RejectFriendRequestUseCase` - 친구 거부
15. `RemoveFriendUseCase` - 친구 삭제
16. `GetProfileInfoUseCase` - 경량 프로필 조회
17. `GetProfileCompletionUseCase` - 프로필 완성도
18. `GetNotificationSettingsUseCase` - 알림 설정 조회
19. `UpdateNotificationSettingsUseCase` - 알림 설정 저장

**P2 (선택 - 필요 시, 2-3시간)**:
고급 기능 및 소셜 기능

20. `SearchProfilesUseCase` - 복합 검색 (거리, 나이, 관심사)
21. `GetSuggestedProfilesUseCase` - 프로필 추천
22. `GetFriendSuggestionsUseCase` - 친구 추천
23. `GetMutualFriendsUseCase` - 상호 친구
24. `SearchFriendsUseCase` - 친구 검색
25. `GetOnlineFriendsUseCase` - 온라인 친구
26. `BlockUserUseCase` - 사용자 차단
27. `ReportUserUseCase` - 사용자 신고
28. `DeleteUserProfileUseCase` - 프로필 삭제

### 4.0.4. UseCase 구현 체크리스트

- [ ] **P0 UseCase 10개 구현** (4-5시간)
  - [ ] GetUserProfileUseCase
  - [ ] UpdateUserProfileUseCase
  - [ ] GetUserSettingsUseCase
  - [ ] UpdateUserSettingsUseCase
  - [ ] GetUserInterestsUseCase
  - [ ] UpdateUserInterestsUseCase (validation 포함)
  - [ ] GetUserCharacterUseCase
  - [ ] SetUserCharacterUseCase
  - [ ] GetAvailableCharactersUseCase
  - [ ] UploadProfileImageUseCase

- [ ] **P1 UseCase 9개 구현** (3-4시간)
  - [ ] Friends UseCase 5개
  - [ ] Profile 추가 기능 4개

- [ ] **P2 UseCase 9개 구현** (2-3시간)
  - [ ] 고급 검색 및 추천 기능

**예상 총 작업 시간**: 10-12시간

---

## 🎨 Phase 4.1: Presentation Layer - Providers 생성 (Day 7, 12-14시간)

### 4.1. Providers 생성 (7개)

```
presentation/providers/
├── profile_provider.dart              # 프로필 상태 관리
├── profile_edit_provider.dart         # 프로필 편집 상태
├── settings_provider.dart             # 설정 상태 관리
├── friends_provider.dart              # 친구 목록 상태
├── interests_provider.dart            # 관심사 선택 상태
└── characters_provider.dart           # 캐릭터 선택 상태
```

### Characters Provider (캐릭터/아바타 관리)

**파일**: `presentation/providers/characters_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../domain/usecases/characters/get_user_character_usecase.dart';
import '../../domain/usecases/characters/set_user_character_usecase.dart';
import '../../domain/usecases/characters/get_available_characters_usecase.dart';
import '../../domain/models/character.dart';

/// 캐릭터/아바타 선택 Provider
///
/// **책임**:
/// - 사용자 캐릭터 상태 관리
/// - 사용 가능한 캐릭터 목록 관리
/// - UseCase를 통한 비즈니스 로직 실행
class CharactersProvider extends ChangeNotifier {
  final GetUserCharacterUseCase _getUserCharacterUseCase;
  final SetUserCharacterUseCase _setUserCharacterUseCase;
  final GetAvailableCharactersUseCase _getAvailableCharactersUseCase;

  Character? _currentCharacter;
  List<Character> _availableCharacters = [];
  bool _isLoading = false;
  String? _errorMessage;

  CharactersProvider({
    required GetUserCharacterUseCase getUserCharacterUseCase,
    required SetUserCharacterUseCase setUserCharacterUseCase,
    required GetAvailableCharactersUseCase getAvailableCharactersUseCase,
  })  : _getUserCharacterUseCase = getUserCharacterUseCase,
        _setUserCharacterUseCase = setUserCharacterUseCase,
        _getAvailableCharactersUseCase = getAvailableCharactersUseCase;

  // Getters
  Character? get currentCharacter => _currentCharacter;
  List<Character> get availableCharacters => _availableCharacters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 사용자 현재 캐릭터 로드
  Future<void> loadUserCharacter(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getUserCharacterUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _currentCharacter = null;
      },
      (character) {
        _currentCharacter = character;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 사용자 캐릭터 설정
  Future<void> setUserCharacter(String userId, String characterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _setUserCharacterUseCase.execute(
      userId: userId,
      characterId: characterId,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (character) {
        _currentCharacter = character;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 사용 가능한 캐릭터 목록 로드
  Future<void> loadAvailableCharacters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAvailableCharactersUseCase.execute();

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _availableCharacters = [];
      },
      (characters) {
        _availableCharacters = characters;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

### Profile Provider (일반 Provider)

**파일**: `presentation/providers/profile_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 프로필 Provider
///
/// **책임**:
/// - 프로필 상태 관리
/// - UseCase를 통한 비즈니스 로직 실행
/// - UI 상태 업데이트 (로딩, 에러)
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadImageUseCase;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({
    required GetUserProfileUseCase getProfileUseCase,
    required UpdateUserProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadImageUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadImageUseCase = uploadImageUseCase;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 프로필 로드
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
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

  /// 프로필 이미지 업로드
  Future<void> uploadProfileImage(String userId, File imageFile) async {
    _isLoading = true;
    notifyListeners();

    final result = await _uploadImageUseCase.execute(
      userId: userId,
      imageFile: imageFile,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (imageUrl) {
        if (_profile != null) {
          _profile = _profile!.copyWith(photoUrl: imageUrl);
        }
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

### 4.2. Screens 리팩토링 (10개 → 15개)

```
presentation/screens/
├── profile_main/
│   ├── profile_page_widget.dart       # 프로필 메인 (기존)
│   └── profile_page_model.dart        # ViewModel 패턴 (기존)
│
├── profile_edit/                      # 신규 생성
│   ├── profile_edit_screen.dart       # 프로필 편집 화면
│   └── profile_edit_model.dart        # ViewModel
│
├── onboarding/
│   ├── interest_selection/
│   │   ├── agreed_select/             # 기존
│   │   ├── expertise_select/          # 기존
│   │   └── hobbies_select/            # 기존
│   └── onboarding_flow_screen.dart    # 신규: 온보딩 플로우 통합
│
├── user_info/
│   ├── character_detail/              # 기존
│   ├── language_selector/             # 기존
│   └── user_info_display/             # 신규: 정보 표시 화면
│
└── user_info_input/
    └── user_info_input_widget.dart    # 기존
```

### 4.3. Widgets 생성 (0개 → 25개)

```
presentation/widgets/
├── profile/
│   ├── profile_avatar.dart            # 프로필 이미지 위젯
│   ├── profile_header.dart            # 프로필 헤더
│   ├── profile_stats_card.dart        # 포인트/통계 카드
│   └── profile_action_button.dart     # 액션 버튼
│
├── settings/
│   ├── settings_section.dart          # 설정 섹션
│   ├── settings_toggle.dart           # 토글 스위치
│   └── settings_list_tile.dart        # 설정 항목
│
├── friends/
│   ├── friend_list_item.dart          # 친구 목록 아이템
│   ├── friend_request_card.dart       # 친구 요청 카드
│   └── empty_friends_state.dart       # 빈 상태 위젯
│
├── interests/
│   ├── interest_chip.dart             # 관심사 칩
│   ├── interest_category_grid.dart    # 관심사 그리드
│   └── interest_selection_bottom_sheet.dart
│
└── common/
    ├── loading_indicator.dart         # 로딩 인디케이터
    ├── error_message.dart             # 에러 메시지
    ├── empty_state.dart               # 빈 상태
    └── custom_text_field.dart         # 커스텀 텍스트 필드
```

### 4.4. Constants 생성 (0개 → 5개)

```
presentation/constants/
├── profile_constants.dart             # 프로필 상수
├── dimensions.dart                    # UI 치수
├── colors.dart                        # 색상 정의
├── strings.dart                       # 문자열 상수
└── validation_rules.dart              # 유효성 규칙
```

### 4.5. 레거시 위젯 전환 가이드

**발견된 Gap**: 마이그레이션 계획에 레거시 위젯 전환 전략이 부재. 10개 이상의 기존 화면 위젯이 Clean Architecture와 연결되는 구체적인 방법이 명시되지 않음.

#### 4.5.1. 레거시 위젯 분석 (10개 화면)

| 위젯 파일 | Clean Architecture 위반 사항 | 전환 난이도 | 우선순위 |
|----------|---------------------------|-----------|---------|
| **profile_page_widget.dart** (535줄) | StreamBuilder 직접 사용, 수동 UseCase 초기화 | ⭐⭐⭐ 중간 | P0 - 최우선 |
| **expertise_select_widget.dart** (847줄) | Firestore 직접 쓰기, No Provider, No UseCase, No Error handling | ⭐⭐⭐⭐⭐ 높음 | P0 - 최우선 |
| **hobbies_select_widget.dart** | 유사한 구조 (expertise와 동일 패턴) | ⭐⭐⭐⭐ 중간-높음 | P1 |
| **agreed_select_widget.dart** | 유사한 구조 (expertise와 동일 패턴) | ⭐⭐⭐⭐ 중간-높음 | P1 |
| **user_info_input_widget.dart** | 데이터/비즈니스 혼재 | ⭐⭐⭐ 중간 | P1 |
| **character_detail_page_widget.dart** | StreamBuilder 직접 사용 | ⭐⭐ 낮음-중간 | P2 |
| **language_selector_widget.dart** | 단순 UI, 최소 로직 | ⭐ 낮음 | P2 |
| **profile_page_model.dart** (ViewModel) | Provider로 전환 필요 | ⭐⭐ 낮음-중간 | P2 |
| **user_info_input_model.dart** (ViewModel) | Provider로 전환 필요 | ⭐⭐ 낮음-중간 | P2 |
| **character_detail_page_model.dart** (ViewModel) | Provider로 전환 필요 | ⭐ 낮음 | P3 |

**총 10개 레거시 위젯**:
- **P0 (최우선)**: 2개 - profile_page_widget, expertise_select_widget
- **P1 (우선)**: 3개 - hobbies_select, agreed_select, user_info_input
- **P2 (중간)**: 4개 - character_detail, language_selector, 2개 ViewModel
- **P3 (낮음)**: 1개 - character_detail_model

#### 4.5.2. 전환 패턴 1: StreamBuilder → Consumer (profile_page_widget.dart)

**현재 문제점** (Lines 115-128):
- StreamBuilder를 직접 사용하여 Firestore와 강결합
- Provider 없이 수동 UseCase 초기화 (Lines 34-51)
- 중앙 집중식 상태 관리 부재

**BEFORE** (`presentation/screens/profile_main/profile_page_widget.dart`):
```dart
class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  SignOutUseCase? _signOutUseCase;
  late final UserPostsProvider _userPostsProvider;

  // ❌ 문제 1: 수동 UseCase 초기화 (GetIt 사용 불일치)
  Future<void> _initializeUseCases() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalDataSource(prefs: prefs);
    final repository = AuthRepositoryImpl(
      remoteDataSource: FirebaseAuthRemoteDataSource(/*...*/),
      localDataSource: localDataSource,
    );
    setState(() {
      _signOutUseCase = SignOutUseCase(repository: repository);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeUseCases();  // ❌ 수동 초기화
    _userPostsProvider = GetIt.instance<UserPostsProvider>();  // ✅ 하지만 이건 GetIt
  }

  @override
  Widget build(BuildContext context) {
    return currentUser == null
        ? /* 로그인 안내 */
        // ❌ 문제 2: StreamBuilder 직접 사용 (Firestore 강결합)
        : StreamBuilder<UsersModel>(
            stream: UsersModel.getDocument(currentUserReference!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final user = snapshot.data!;  // ❌ UsersModel 직접 사용

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // ❌ 문제 3: 필드 직접 접근 (비즈니스 로직 없음)
                    Text(user.displayName.isNotEmpty ? user.displayName : '이름 없음'),
                    Text(user.email),
                    Row(
                      children: [
                        _buildPointInfo(context, '답변 포인트', user.pointsA.toString(), /*...*/),
                        _buildPointInfo(context, '질문 포인트', user.pointsQ.toString(), /*...*/),
                      ],
                    ),
                    // UserPostsProvider는 GetIt으로 이미 사용 중 (하이브리드 상태)
                    ChangeNotifierProvider.value(
                      value: _userPostsProvider,
                      child: _buildUserPostsSection(context, user.uid),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
```

**AFTER** (Phase 4.5 목표 구조):
```dart
class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  late final ProfileProvider _profileProvider;     // ✅ Provider로 통일
  late final SignOutUseCase _signOutUseCase;       // ✅ GetIt으로 주입
  late final UserPostsProvider _userPostsProvider;

  @override
  void initState() {
    super.initState();
    // ✅ 모든 의존성을 GetIt에서 주입
    _profileProvider = GetIt.instance<ProfileProvider>();
    _signOutUseCase = GetIt.instance<SignOutUseCase>();
    _userPostsProvider = GetIt.instance<UserPostsProvider>();

    // ✅ 프로필 로드 (UseCase 기반)
    if (currentUser != null) {
      _profileProvider.loadProfile(currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return currentUser == null
        ? /* 로그인 안내 */
        // ✅ StreamBuilder → Consumer 전환
        : Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              // ✅ 로딩/에러 상태 처리
              if (provider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage != null) {
                return Center(child: Text(provider.errorMessage!));
              }

              final profile = provider.profile!;  // ✅ Domain Model 사용

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // ✅ Domain 모델 필드 접근
                    Text(profile.displayName.isNotEmpty ? profile.displayName : '이름 없음'),
                    Text(profile.email),
                    Row(
                      children: [
                        _buildPointInfo(context, '답변 포인트', profile.pointsA.toString(), /*...*/),
                        _buildPointInfo(context, '질문 포인트', profile.pointsQ.toString(), /*...*/),
                      ],
                    ),
                    // ✅ 이미 Provider 패턴 사용 중 (유지)
                    ChangeNotifierProvider.value(
                      value: _userPostsProvider,
                      child: _buildUserPostsSection(context, profile.userId),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
```

**전환 단계**:
1. **ProfileProvider 생성** (Phase 4.1에서 이미 생성)
2. **GetIt 등록** (Phase 5.1 DI Module에서 등록)
3. **initState 수정**: 수동 초기화 → GetIt 주입
4. **StreamBuilder 제거**: Consumer<ProfileProvider>로 대체
5. **UsersModel 제거**: UserProfile (Domain) 사용
6. **테스트 및 검증**: 기능 동일성 확인

#### 4.5.3. 전환 패턴 2: 직접 Firestore 쓰기 → Provider + UseCase (expertise_select_widget.dart)

**현재 문제점** (Lines 469-480):
- 위젯에서 Firestore에 직접 쓰기 (Clean Architecture 심각 위반)
- 유효성 검증 없음
- 에러 처리 없음
- Provider 없음

**BEFORE** (`presentation/screens/onboarding/interest_selection/expertise_select/expertise_select_widget.dart`):
```dart
class _ExpertiseSelectWidgetState extends State<ExpertiseSelectWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: _model.expertiseTextController),
          AppButtonWidget(
            text: '추가',
            // ❌ 문제: 위젯에서 직접 Firestore 쓰기
            onPressed: () async {
              await currentUserReference!.update({
                ...mapToFirestore({
                  'expertise': FieldValue.arrayUnion([
                    _model.expertiseTextController.text,  // ❌ 유효성 검증 없음
                  ]),
                }),
              });  // ❌ 에러 처리 없음
              setState(() {
                _model.expertiseTextController?.clear();
              });
            },
          ),
        ],
      ),
    );
  }
}
```

**AFTER** (Phase 4.5 목표 구조):
```dart
class _ExpertiseSelectWidgetState extends State<ExpertiseSelectWidget> {
  late final InterestsProvider _interestsProvider;  // ✅ Provider 주입

  @override
  void initState() {
    super.initState();
    _interestsProvider = GetIt.instance<InterestsProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<InterestsProvider>(  // ✅ Provider 기반 상태 관리
        builder: (context, provider, child) {
          return Column(
            children: [
              TextField(
                controller: _model.expertiseTextController,
                // ✅ 에러 메시지 표시
                errorText: provider.expertiseError,
              ),
              // ✅ 로딩 상태 표시
              if (provider.isLoading) CircularProgressIndicator(),
              AppButtonWidget(
                text: '추가',
                // ✅ Provider를 통한 UseCase 호출
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final expertise = _model.expertiseTextController.text;

                        // ✅ UseCase 실행 (유효성 검증 + 에러 처리 포함)
                        final success = await provider.addExpertise(
                          userId: currentUser!.uid,
                          expertise: expertise,
                        );

                        if (success) {
                          setState(() {
                            _model.expertiseTextController?.clear();
                          });
                          // ✅ 사용자 친화적 피드백
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('전문 분야가 추가되었습니다')),
                          );
                        } else {
                          // ✅ 에러 메시지는 provider.expertiseError에 자동 설정됨
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.expertiseError!)),
                          );
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}
```

**필요한 InterestsProvider 구현**:
```dart
class InterestsProvider extends ChangeNotifier {
  final UpdateUserInterestsUseCase _updateInterestsUseCase;

  bool _isLoading = false;
  String? _expertiseError;

  InterestsProvider({
    required UpdateUserInterestsUseCase updateInterestsUseCase,
  }) : _updateInterestsUseCase = updateInterestsUseCase;

  bool get isLoading => _isLoading;
  String? get expertiseError => _expertiseError;

  /// 전문 분야 추가
  Future<bool> addExpertise({
    required String userId,
    required String expertise,
  }) async {
    _isLoading = true;
    _expertiseError = null;
    notifyListeners();

    // ✅ UseCase를 통한 비즈니스 로직 실행
    final result = await _updateInterestsUseCase.addExpertise(
      userId: userId,
      expertise: expertise,
    );

    result.fold(
      (failure) {
        _expertiseError = failure.getUserMessage();  // ✅ Phase 3 Failure 패턴
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}
```

**전환 단계**:
1. **UpdateUserInterestsUseCase 생성** (Phase 2.1)
2. **InterestsProvider 생성** (Phase 4.1)
3. **GetIt 등록** (Phase 5.1 DI Module)
4. **직접 Firestore 쓰기 제거**: Provider.addExpertise() 호출로 대체
5. **유효성 검증 추가**: UseCase 내부에서 처리
6. **에러 처리 추가**: Failure 객체로 사용자 친화적 메시지 제공

#### 4.5.4. 전환 체크리스트 (10개 위젯)

- [ ] **profile_page_widget.dart** (P0)
  - [ ] ProfileProvider 생성 및 GetIt 등록
  - [ ] StreamBuilder → Consumer 전환
  - [ ] UsersModel → UserProfile (Domain) 전환
  - [ ] 수동 SignOutUseCase 초기화 제거
  - [ ] 테스트: 프로필 표시, 로그아웃 기능

- [ ] **expertise_select_widget.dart** (P0)
  - [ ] UpdateUserInterestsUseCase 생성
  - [ ] InterestsProvider 생성 및 GetIt 등록
  - [ ] 직접 Firestore 쓰기 제거
  - [ ] Consumer<InterestsProvider> 적용
  - [ ] 테스트: 전문 분야 추가, 에러 처리

- [ ] **hobbies_select_widget.dart** (P1)
  - [ ] InterestsProvider.addHobby() 메서드 추가
  - [ ] 동일 패턴 적용 (expertise와 유사)

- [ ] **agreed_select_widget.dart** (P1)
  - [ ] InterestsProvider.addAgreed() 메서드 추가
  - [ ] 동일 패턴 적용 (expertise와 유사)

- [ ] **user_info_input_widget.dart** (P1)
  - [ ] ProfileEditProvider 적용
  - [ ] 폼 유효성 검사 UseCase 통합

- [ ] **character_detail_page_widget.dart** (P2)
  - [ ] StreamBuilder → Consumer 전환
  - [ ] CharactersProvider 생성 (필요 시)

- [ ] **language_selector_widget.dart** (P2)
  - [ ] SettingsProvider.updateLanguage() 적용

- [ ] **profile_page_model.dart** (P2)
  - [ ] ProfileProvider로 완전 대체

- [ ] **user_info_input_model.dart** (P2)
  - [ ] ProfileEditProvider로 완전 대체

- [ ] **character_detail_page_model.dart** (P3)
  - [ ] CharactersProvider로 대체 (필요 시)

---

## 🔄 Phase 4.5: 레거시 위젯 분석 및 전환 패턴 (Day 7.5, 4시간)

### 개요

**목표**: 10개 레거시 위젯의 전환 순서 및 롤백 전략 수립

**전환 원칙**:
1. **무중단 마이그레이션**: 레거시 시스템 유지하면서 신규 Provider 추가
2. **우선순위 기반 전환**: P0 → P1 → P2 → P3 순차 전환
3. **하이브리드 Provider**: Section 1.4의 UserProfileAdapter 활용
4. **점진적 검증**: 위젯별 전환 후 즉시 테스트

### 4.5.1. 위젯별 전환 순서

| 주차 | 위젯 | 작업 내용 | 상태 |
|------|-----|----------|------|
| **Week 1-2** | - | 하이브리드 Provider 구축 | 병렬 시스템 테스트 |
| **Week 3** | profile_page_widget.dart (P0) | StreamBuilder → Consumer 전환 | 하이브리드 운영 |
| **Week 3** | expertise_select_widget.dart (P0) | 직접 Firestore 쓰기 제거 | 하이브리드 운영 |
| **Week 4** | hobbies_select_widget.dart (P1) | InterestsProvider 적용 | 신규 시스템 전환 |
| **Week 4** | agreed_select_widget.dart (P1) | InterestsProvider 적용 | 신규 시스템 전환 |
| **Week 5** | user_info_input_widget.dart (P1) | ProfileEditProvider 적용 | 신규 시스템 전환 |
| **Week 5** | character_detail_page_widget.dart (P2) | CharactersProvider 적용 | 신규 시스템 전환 |
| **Week 6** | language_selector_widget.dart (P2) | SettingsProvider 적용 | 신규 시스템 전환 |
| **Week 6** | 3개 ViewModel (P2-P3) | Provider로 완전 대체 | 신규 시스템 전환 |
| **Week 7** | - | 레거시 코드 완전 제거 | 마이그레이션 완료 |

### 4.5.2. 롤백 시나리오

**상황별 롤백 전략**:

**시나리오 1: P0 위젯 전환 실패**
- **원인**: Consumer<ProfileProvider>가 예상대로 작동하지 않음
- **조치**:
  1. 하이브리드 코드에서 StreamBuilder만 남기고 Consumer 제거
  2. `watchProfileLegacy()` 메서드 유지
  3. 문제 분석 후 재시도

**시나리오 2: InterestsProvider 버그 발견**
- **원인**: addExpertise() 메서드 에러 처리 누락
- **조치**:
  1. 직접 Firestore 쓰기 코드로 임시 복원
  2. InterestsProvider 수정 후 재배포
  3. expertise_select_widget 재전환

**시나리오 3: 데이터 불일치 발견**
- **원인**: Legacy와 New 시스템 출력이 다름
- **조치**:
  1. 병렬 테스트 코드로 차이점 로깅
  2. UserProfileAdapter 매핑 로직 수정
  3. 데이터 일관성 검증 후 재시작

### 4.5.3. Phase 4.5 체크리스트

- [ ] **위젯 전환 우선순위 분석**
  - [ ] P0 위젯 2개 식별 (profile_page, expertise_select)
  - [ ] P1 위젯 3개 식별 (hobbies, agreed, user_info_input)
  - [ ] P2/P3 위젯 5개 식별 (character_detail, language, 3 ViewModel)

- [ ] **전환 패턴 문서화**
  - [ ] StreamBuilder → Consumer 전환 패턴 작성
  - [ ] 직접 Firestore 쓰기 → Provider 전환 패턴 작성
  - [ ] ViewModel → Provider 전환 패턴 작성

- [ ] **롤백 전략 수립**
  - [ ] 3가지 롤백 시나리오 문서화 완료
  - [ ] 각 시나리오별 복구 절차 검증

---

## 🔀 Phase 4.6: 하이브리드 운영 전략 (Day 8-9.5, 8시간)

### 개요

**목표**: 레거시 시스템과 신규 Clean Architecture 시스템을 병렬 운영하면서 점진적 전환

### 4.6.1. 하이브리드 운영 전략 (Week 1-7)

#### Week 1-2: 하이브리드 Provider 구축 및 병렬 시스템 테스트

**작업 내용**:
- ProfileProvider에 레거시 Stream 메서드 추가 (Section 1.4 패턴 적용)
- InterestsProvider 생성 (UseCase 기반 + 레거시 지원)
- 신규 Provider와 레거시 StreamBuilder 병렬 실행
- 데이터 일관성 검증 (두 시스템의 출력 비교)

**파일 수정**:
```dart
// presentation/providers/profile_provider.dart
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UserProfileAdapter _adapter;  // ✅ Section 1.4 Adapter 활용

  // ━━━ 레거시 지원: StreamBuilder 유지 ━━━
  Stream<UserProfile> watchProfileLegacy(String userId) {
    final ref = FirebaseFirestore.instance.collection('users').doc(userId);
    return UsersModel.getDocument(ref).map((usersModel) {
      return _adapter.toDomain(usersModel);  // ✅ UsersModel → UserProfile 변환
    });
  }

  // ━━━ 신규 방식: UseCase 기반 ━━━
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    final result = await _getProfileUseCase.execute(userId: userId);
    result.fold(
      (failure) => _errorMessage = failure.getUserMessage(),
      (profile) => _profile = profile,
    );
    _isLoading = false;
    notifyListeners();
  }
}
```

**병렬 시스템 테스트 코드**:
```dart
// test/hybrid_validation_test.dart
void main() {
  test('Legacy Stream vs New Provider output consistency', () async {
    final userId = 'test_user_123';

    // Legacy System
    final legacyProfile = await ProfileProvider()
        .watchProfileLegacy(userId)
        .first;

    // New System
    final newProvider = ProfileProvider();
    await newProvider.loadProfile(userId);
    final newProfile = newProvider.profile!;

    // 데이터 일관성 검증
    expect(newProfile.userId, equals(legacyProfile.userId));
    expect(newProfile.displayName, equals(legacyProfile.displayName));
    expect(newProfile.pointsA, equals(legacyProfile.pointsA));
  });
}
```

#### Week 3-4: P0 위젯 전환 (하이브리드 운영)

**작업 순서**:

**1. profile_page_widget.dart** (Day 8-9):
- StreamBuilder는 유지한 채로 ProfileProvider 추가
- Consumer<ProfileProvider>와 StreamBuilder 병렬 렌더링
- 두 UI 출력 비교 (개발 모드)
- 일치 확인 후 StreamBuilder 제거

**하이브리드 코드 (임시)**:
```dart
// ⚠️ 개발 중에만 사용 (두 시스템 비교용)
class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  late final ProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = GetIt.instance<ProfileProvider>();
    if (currentUser != null) {
      _profileProvider.loadProfile(currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ━━━ 레거시 시스템 (검증용) ━━━
          if (kDebugMode)
            StreamBuilder<UsersModel>(
              stream: UsersModel.getDocument(currentUserReference!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final legacyUser = snapshot.data!;
                return Text('Legacy: ${legacyUser.displayName}');
              },
            ),

          // ━━━ 신규 시스템 ━━━
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return CircularProgressIndicator();
              if (provider.errorMessage != null) return Text(provider.errorMessage!);
              final profile = provider.profile!;
              return Text('New: ${profile.displayName}');
            },
          ),
        ],
      ),
    );
  }
}
```

**2. expertise_select_widget.dart** (Day 9-10):
- InterestsProvider 통합
- 직접 Firestore 쓰기 제거
- Consumer<InterestsProvider> 적용
- 에러 처리 및 유효성 검증 추가

#### Week 5-6: P1/P2 위젯 전환 (신규 시스템 전환)

**작업 순서**:

**P1 위젯** (3개):
1. hobbies_select_widget.dart → InterestsProvider.addHobby()
2. agreed_select_widget.dart → InterestsProvider.addAgreed()
3. user_info_input_widget.dart → ProfileEditProvider

**P2 위젯** (4개):
1. character_detail_page_widget.dart → CharactersProvider (필요 시)
2. language_selector_widget.dart → SettingsProvider.updateLanguage()
3. profile_page_model.dart → ProfileProvider로 완전 대체
4. user_info_input_model.dart → ProfileEditProvider로 완전 대체

**전환 후 검증**:
- [ ] 기능 동일성 확인 (레거시와 동일하게 작동)
- [ ] 에러 처리 확인 (Phase 3 Failure 메시지 표시)
- [ ] 로딩 상태 확인 (isLoading, errorMessage)

#### Week 7: 레거시 Stream 메서드 완전 제거

**작업 내용**:
- ProfileProvider에서 `watchProfileLegacy()` 메서드 제거
- `@Deprecated` 어노테이션 제거
- 모든 레거시 코드 정리 (StreamBuilder, 수동 UseCase 초기화)
- 최종 통합 테스트

**삭제 대상**:
```dart
// ❌ 제거 예정
Stream<UserProfile> watchProfileLegacy(String userId) {
  return UsersModel.getDocument(ref).map((usersModel) {
    return _adapter.toDomain(usersModel);
  });
}
```

---

## 🔗 Phase 5: 의존성 주입 및 통합 (Day 10, 4시간)

### 5.1. DI Module 생성

**파일**: `lib/app/di/profile_module.dart`

```dart
import 'package:get_it/get_it.dart';

// DataSources
import '../../features/profile/data/datasources/interfaces/i_profile_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_profile_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_settings_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_settings_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_friends_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_friends_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_storage_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_storage_datasource.dart';

// Mappers
import '../../features/profile/data/mappers/user_profile_mapper.dart';
import '../../features/profile/data/mappers/user_settings_mapper.dart';
import '../../features/profile/data/mappers/friends_mapper.dart';

// Repositories
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/i_settings_repository.dart';
import '../../features/profile/data/repositories/settings_repository_impl.dart';
import '../../features/profile/domain/repositories/i_friends_repository.dart';
import '../../features/profile/data/repositories/friends_repository_impl.dart';

// UseCases
import '../../features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../features/profile/domain/usecases/settings/get_user_settings_usecase.dart';
import '../../features/profile/domain/usecases/settings/update_user_settings_usecase.dart';
import '../../features/profile/domain/usecases/friends/get_friends_list_usecase.dart';
import '../../features/profile/domain/usecases/friends/add_friend_usecase.dart';
import '../../features/profile/domain/usecases/friends/remove_friend_usecase.dart';

// Providers
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/providers/settings_provider.dart';
import '../../features/profile/presentation/providers/friends_provider.dart';
import '../../features/profile/presentation/providers/interests_provider.dart';
import '../../features/profile/presentation/providers/profile_edit_provider.dart';
import '../../features/profile/presentation/providers/onboarding_coordinator.dart';

/// Profile Feature DI Module
class ProfileModule {
  static void registerDependencies(GetIt getIt) {
    // DataSources
    getIt.registerLazySingleton<IProfileDataSource>(
      () => FirebaseProfileDataSource(),
    );
    getIt.registerLazySingleton<ISettingsDataSource>(
      () => FirebaseSettingsDataSource(),
    );
    getIt.registerLazySingleton<IFriendsDataSource>(
      () => FirebaseFriendsDataSource(),
    );
    getIt.registerLazySingleton<IStorageDataSource>(
      () => FirebaseStorageDataSource(),
    );

    // Mappers
    getIt.registerLazySingleton(() => UserProfileMapper());
    getIt.registerLazySingleton(() => UserSettingsMapper());
    getIt.registerLazySingleton(() => FriendsMapper());

    // Repositories
    getIt.registerLazySingleton<IProfileRepository>(
      () => ProfileRepositoryImpl(
        dataSource: getIt(),
        mapper: getIt(),
      ),
    );
    getIt.registerLazySingleton<ISettingsRepository>(
      () => SettingsRepositoryImpl(
        dataSource: getIt(),
        mapper: getIt(),
      ),
    );
    getIt.registerLazySingleton<IFriendsRepository>(
      () => FriendsRepositoryImpl(
        dataSource: getIt(),
        mapper: getIt(),
      ),
    );

    // UseCases (28개)
    // Profile UseCases (10개)
    getIt.registerFactory(() => GetUserProfileUseCase(repository: getIt()));
    getIt.registerFactory(() => UpdateUserProfileUseCase(repository: getIt()));
    getIt.registerFactory(() => UploadProfileImageUseCase(repository: getIt()));
    getIt.registerFactory(() => DeleteUserProfileUseCase(repository: getIt()));
    getIt.registerFactory(() => GetProfileInfoUseCase(repository: getIt()));
    getIt.registerFactory(() => SearchProfilesUseCase(repository: getIt()));
    getIt.registerFactory(() => GetSuggestedProfilesUseCase(repository: getIt()));
    getIt.registerFactory(() => BlockUserUseCase(repository: getIt()));
    getIt.registerFactory(() => ReportUserUseCase(repository: getIt()));
    getIt.registerFactory(() => GetProfileCompletionUseCase(repository: getIt()));

    // Friends UseCases (9개)
    getIt.registerFactory(() => GetFriendsListUseCase(repository: getIt()));
    getIt.registerFactory(() => AddFriendUseCase(repository: getIt()));
    getIt.registerFactory(() => RemoveFriendUseCase(repository: getIt()));
    getIt.registerFactory(() => SearchFriendsUseCase(repository: getIt()));
    getIt.registerFactory(() => GetPendingFriendRequestsUseCase(repository: getIt()));
    getIt.registerFactory(() => AcceptFriendRequestUseCase(repository: getIt()));
    getIt.registerFactory(() => DeclineFriendRequestUseCase(repository: getIt()));
    getIt.registerFactory(() => GetMutualFriendsUseCase(repository: getIt()));
    getIt.registerFactory(() => GetFriendDetailsUseCase(repository: getIt()));

    // Interests UseCases (2개)
    getIt.registerFactory(() => GetUserInterestsUseCase(repository: getIt()));
    getIt.registerFactory(() => UpdateUserInterestsUseCase(repository: getIt()));

    // Characters UseCases (3개)
    getIt.registerFactory(() => GetUserCharacterUseCase(repository: getIt()));
    getIt.registerFactory(() => SetUserCharacterUseCase(repository: getIt()));
    getIt.registerFactory(() => GetAvailableCharactersUseCase(repository: getIt()));

    // Settings UseCases (4개)
    getIt.registerFactory(() => GetUserSettingsUseCase(repository: getIt()));
    getIt.registerFactory(() => UpdateUserSettingsUseCase(repository: getIt()));
    getIt.registerFactory(() => GetNotificationSettingsUseCase(repository: getIt()));
    getIt.registerFactory(() => UpdateNotificationSettingsUseCase(repository: getIt()));

    // Providers (7개)
    getIt.registerFactory(() => ProfileProvider(
      getProfileUseCase: getIt(),
      updateProfileUseCase: getIt(),
      uploadImageUseCase: getIt(),
    ));
    getIt.registerFactory(() => SettingsProvider(
      getSettingsUseCase: getIt(),
      updateSettingsUseCase: getIt(),
    ));
    getIt.registerFactory(() => FriendsProvider(
      getFriendsListUseCase: getIt(),
      addFriendUseCase: getIt(),
      removeFriendUseCase: getIt(),
    ));
    getIt.registerFactory(() => InterestsProvider(
      getUserInterestsUseCase: getIt(),
      updateUserInterestsUseCase: getIt(),
    ));
    getIt.registerFactory(() => ProfileEditProvider(
      updateProfileUseCase: getIt(),
    ));
    getIt.registerFactory(() => CharactersProvider(
      getUserCharacterUseCase: getIt(),
      setUserCharacterUseCase: getIt(),
      getAvailableCharactersUseCase: getIt(),
    ));
  }
}
```

### 5.2. main.dart 통합

**파일**: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // DI 초기화
  final getIt = GetIt.instance;

  // 각 Feature Module 등록
  AuthModule.registerDependencies(getIt);
  CreationModule.registerDependencies(getIt);
  PostModule.registerDependencies(getIt);
  ProfileModule.registerDependencies(getIt);  // ✅ 신규 추가

  runApp(MyApp());
}
```

### 5.3. Coordinators 생성 (Phase 5 패턴)

#### OnboardingCoordinator

**파일**: `presentation/providers/onboarding_coordinator.dart`

```dart
import 'package:flutter/foundation.dart';
import 'interests_provider.dart';
import 'profile_edit_provider.dart';
import 'settings_provider.dart';

/// 온보딩 플로우 조정자 (Phase 5 Coordinator 패턴)
///
/// **책임**:
/// - 3개 Provider (Interests, ProfileEdit, Settings) 통합
/// - 단일 진입점으로 복잡한 온보딩 플로우 관리
/// - 진행률 추적 및 에러 처리
class OnboardingCoordinator extends ChangeNotifier {
  final InterestsProvider _interestsProvider;
  final ProfileEditProvider _profileEditProvider;
  final SettingsProvider _settingsProvider;

  OnboardingCoordinator({
    required InterestsProvider interestsProvider,
    required ProfileEditProvider profileEditProvider,
    required SettingsProvider settingsProvider,
  })  : _interestsProvider = interestsProvider,
        _profileEditProvider = profileEditProvider,
        _settingsProvider = settingsProvider;

  /// 단일 진입점: 온보딩 완료 처리
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `onProgress`: 진행률 콜백 (0-100)
  Future<void> completeOnboarding({
    required String userId,
    required Function(int) onProgress,
  }) async {
    try {
      // 1. 관심사 저장 (0-33%)
      onProgress(0);
      await _interestsProvider.saveInterests(userId);
      onProgress(33);

      // 2. 프로필 정보 저장 (33-66%)
      await _profileEditProvider.saveProfile(userId);
      onProgress(66);

      // 3. 설정 초기화 (66-100%)
      await _settingsProvider.initializeSettings(userId);
      onProgress(100);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
```

#### DI 등록 (profile_module.dart에 추가)

```dart
// Coordinators
getIt.registerFactory(() => OnboardingCoordinator(
  interestsProvider: getIt(),
  profileEditProvider: getIt(),
  settingsProvider: getIt(),
));
```

### 5.4. 중복 Repository 통합 전략

**발견된 문제**: Phase 3.4에서 6개 Repository를 생성하지만, 기존 `user_repository_impl.dart`와 신규 `profile_repository_impl.dart` 간 기능 중복 존재

#### 현재 상황 분석

**기존 Repository** (`data/repositories/user_repository_impl.dart`):
- UserProfile CRUD 메서드 포함
- UserProfileAdapter 활용 (Lines 206-259)
- UserSettings, Friends 관련 메서드 혼재
- 536줄의 대규모 파일

**신규 Repository** (`data/repositories/profile_repository_impl.dart`):
- Phase 3에서 생성 예정
- Clean Architecture 패턴 적용 (DataSource + Mapper 분리)
- 단일 책임 원칙 준수 (Profile만 담당)

#### 통합 전략 (3단계)

**Step 1: 기존 user_repository_impl.dart 분석** (Day 10.0, 1시간)

```yaml
기능_분류:
  profile_crud:
    - getUserByUid()
    - updateUserProfile()
    - getUserBundleByUid()  # UserProfileAdapter 사용

  settings:
    - getUserSettings()
    - updateUserSettings()

  friends:
    - getFriendsList()
    - addFriend()
    - removeFriend()

  interests:
    - updateUserInterests()

  characters:
    - getUserCharacter()
    - updateCharacter()
```

**Step 2: Repository 분할 맵핑** (Day 10.1, 1시간)

| 기존 메서드 | 이동 대상 Repository | 비고 |
|------------|---------------------|------|
| getUserByUid() | ProfileRepositoryImpl | ✅ 신규 구현으로 대체 |
| updateUserProfile() | ProfileRepositoryImpl | ✅ 신규 구현으로 대체 |
| getUserBundleByUid() | ProfileRepositoryImpl | ⚠️ UserProfileAdapter 재활용 |
| getUserSettings() | SettingsRepositoryImpl | 🔄 메서드 이동 |
| updateUserSettings() | SettingsRepositoryImpl | 🔄 메서드 이동 |
| getFriendsList() | FriendsRepositoryImpl | 🔄 메서드 이동 |
| addFriend() | FriendsRepositoryImpl | 🔄 메서드 이동 |
| removeFriend() | FriendsRepositoryImpl | 🔄 메서드 이동 |
| updateUserInterests() | InterestsRepositoryImpl | 🔄 메서드 이동 |
| getUserCharacter() | CharactersRepositoryImpl | 🔄 메서드 이동 |

**Step 3: 점진적 통합 프로세스** (Day 10.2-10.5, 2시간)

**Phase A: 신규 Repository 생성** (30분)
```dart
// ✅ 이미 Phase 3에서 생성 완료
// - ProfileRepositoryImpl (with DataSource + Mapper)
// - SettingsRepositoryImpl
// - FriendsRepositoryImpl
// - InterestsRepositoryImpl
// - CharactersRepositoryImpl
```

**Phase B: 기존 메서드 복사 및 리팩토링** (1시간)

**예시: SettingsRepositoryImpl**
```dart
// BEFORE (user_repository_impl.dart Lines 226-231)
Future<UserSettings?> getUserSettings(String uid) async {
  final userProfile = await getUserByUid(uid);
  if (userProfile == null) return null;
  final bundle = UserProfileAdapter.toDomainModels(userProfile);
  return bundle.settings;
}

// AFTER (settings_repository_impl.dart)
@override
Future<Either<ProfileFailure, UserSettings>> getUserSettings(
  String userId,
) async {
  try {
    // 1. DataSource를 통한 데이터 조회
    final data = await _settingsDataSource.getSettings(userId);

    if (data == null) {
      return Left(SettingsNotFoundFailure(userId: userId));
    }

    // 2. DTO → Domain 변환
    final dto = UserSettingsDto.fromFirestore(data);
    final settings = _mapper.toDomain(dto);

    return Right(settings);
  } on FirebaseException catch (e) {
    return Left(FirestoreReadFailure(message: e.message ?? 'Unknown error'));
  } catch (e) {
    return Left(UnknownProfileFailure(message: e.toString()));
  }
}
```

**Phase C: 기존 Repository Deprecation** (30분)

```dart
// data/repositories/user_repository_impl.dart

@Deprecated('Use ProfileRepositoryImpl.getUserProfile() instead')
Future<UserProfile?> getUserByUid(String uid) async {
  // ⚠️ 레거시 지원 (Phase 4.5 하이브리드 운영 중)
  // Week 7 이후 완전 제거 예정
  return _profileRepositoryImpl.getUserProfile(uid).then(
    (either) => either.fold(
      (failure) => null,
      (profile) => profile,
    ),
  );
}

@Deprecated('Use SettingsRepositoryImpl.getUserSettings() instead')
Future<UserSettings?> getUserSettings(String uid) async {
  return _settingsRepositoryImpl.getUserSettings(uid).then(
    (either) => either.fold(
      (failure) => null,
      (profile) => null,
    ),
  );
}

// ... 모든 메서드에 @Deprecated 추가
```

#### UserProfileAdapter 재활용 전략

**현재 Adapter 위치**: `data/adapters/user_profile_adapter.dart`

**Phase 4.5 하이브리드 운영 기간**:
- ProfileProvider에서 `watchProfileLegacy()` 메서드로 활용 (Section 1.4)
- UsersModel → UserProfile 변환 브릿지로 사용

**Week 7 이후 (레거시 제거)**:
```dart
// ❌ 제거 대상
class UserProfileAdapter {
  static UserProfile toDomain(UsersModel usersModel) { ... }
  static UserProfileBundle createBundle(UserProfile profile) { ... }
}

// ✅ 대체: UserProfileMapper (Phase 3.3에서 이미 생성)
class UserProfileMapper {
  static UserProfile toDomain(UserProfileDto dto) { ... }
  static UserProfileDto fromDomain(UserProfile profile) { ... }
}
```

#### 통합 체크리스트

- [ ] **Step 1: 기존 Repository 분석**
  - [ ] user_repository_impl.dart 메서드 목록 추출
  - [ ] 각 메서드의 기능 분류 (Profile, Settings, Friends, Interests, Characters)
  - [ ] UserProfileAdapter 사용 위치 파악

- [ ] **Step 2: Repository 분할 맵핑**
  - [ ] 6개 신규 Repository 역할 정의
  - [ ] 기존 메서드 → 신규 Repository 맵핑 테이블 작성
  - [ ] 중복 제거 계획 수립

- [ ] **Step 3: 점진적 통합**
  - [ ] Phase A: 신규 Repository 생성 (Phase 3 완료)
  - [ ] Phase B: 기존 메서드 리팩토링 및 복사
  - [ ] Phase C: 기존 메서드 @Deprecated 처리
  - [ ] Phase D: Week 7 이후 user_repository_impl.dart 완전 제거

- [ ] **UserProfileAdapter 처리**
  - [ ] Phase 4.5 하이브리드 기간 유지
  - [ ] Week 7 레거시 제거 시 삭제
  - [ ] UserProfileMapper로 완전 대체

#### 예상 결과

**Before (1개 Repository)**:
```
data/repositories/
└── user_repository_impl.dart (536줄, 모든 기능 혼재)
```

**After (6개 Repository)**:
```
data/repositories/
├── profile_repository_impl.dart    (150줄, Profile CRUD만)
├── user_repository_impl.dart       (❌ Week 7 삭제 예정)
├── friends_repository_impl.dart    (100줄, Friends만)
├── settings_repository_impl.dart   (80줄, Settings만)
├── interests_repository_impl.dart  (70줄, Interests만)
└── characters_repository_impl.dart (60줄, Characters만)
```

**이점**:
1. **단일 책임 원칙 준수**: 각 Repository가 하나의 도메인만 담당
2. **유지보수성 향상**: 536줄 → 평균 92줄 (83% 감소)
3. **테스트 용이성**: 도메인별 독립 테스트 가능
4. **확장성**: 새로운 기능 추가 시 해당 Repository만 수정

---

## 📈 최종 구조 (After All Phases)

```
lib/features/profile/                         # Profile Feature 루트
├── data/                                     # 데이터 레이어 (35개 파일)
│   ├── repositories/                        # 6개 Repository 구현체
│   │   ├── profile_repository_impl.dart
│   │   ├── user_repository_impl.dart
│   │   ├── friends_repository_impl.dart
│   │   ├── settings_repository_impl.dart
│   │   ├── interests_repository_impl.dart
│   │   └── characters_repository_impl.dart
│   │
│   ├── datasources/                         # 8개 DataSource (4 인터페이스 + 4 구현)
│   │   ├── interfaces/
│   │   │   ├── i_profile_datasource.dart
│   │   │   ├── i_settings_datasource.dart
│   │   │   ├── i_friends_datasource.dart
│   │   │   └── i_storage_datasource.dart
│   │   └── implementations/
│   │       ├── firebase_profile_datasource.dart
│   │       ├── firebase_settings_datasource.dart
│   │       ├── firebase_friends_datasource.dart
│   │       └── firebase_storage_datasource.dart
│   │
│   ├── dto/                                 # 8개 DTO
│   │   ├── user_profile_dto.dart
│   │   ├── profile_info_dto.dart
│   │   ├── user_settings_dto.dart
│   │   ├── user_stats_dto.dart
│   │   ├── friend_dto.dart
│   │   ├── interest_dto.dart
│   │   ├── character_dto.dart
│   │   └── premium_status_dto.dart
│   │
│   ├── mappers/                             # 4개 Mapper
│   │   ├── user_profile_mapper.dart
│   │   ├── user_settings_mapper.dart
│   │   ├── friends_mapper.dart
│   │   └── profile_firestore_mapper.dart
│   │
│   └── adapters/                            # 2개 Adapter (유지)
│       ├── user_cache_service.dart
│       └── user_profile_adapter.dart
│
├── domain/                                   # 도메인 레이어 (42개 파일)
│   ├── models/                              # 12개 도메인 모델 (기존 유지)
│   │   ├── core/
│   │   │   ├── user_profile.dart
│   │   │   ├── profile_info.dart
│   │   │   └── user_stats.dart
│   │   ├── value_objects/
│   │   │   ├── user_settings.dart
│   │   │   └── interest_model.dart
│   │   └── supporting/
│   │       ├── friends_list_model.dart
│   │       ├── characters_model.dart
│   │       ├── premium_users_model.dart
│   │       ├── jops_category_model.dart
│   │       ├── jops_name_model.dart
│   │       └── chat_interest_jops_model.dart
│   │
│   ├── usecases/                            # 10개 UseCase
│   │   ├── profile/
│   │   │   ├── get_user_profile_usecase.dart
│   │   │   ├── update_user_profile_usecase.dart
│   │   │   ├── upload_profile_image_usecase.dart
│   │   │   └── delete_user_profile_usecase.dart
│   │   ├── settings/
│   │   │   ├── get_user_settings_usecase.dart
│   │   │   └── update_user_settings_usecase.dart
│   │   ├── friends/
│   │   │   ├── get_friends_list_usecase.dart
│   │   │   ├── add_friend_usecase.dart
│   │   │   └── remove_friend_usecase.dart
│   │   └── interests/
│   │       └── update_user_interests_usecase.dart
│   │
│   ├── repositories/                        # 6개 Repository 인터페이스
│   │   ├── specialized/
│   │   │   ├── i_settings_repository.dart
│   │   │   ├── i_interests_repository.dart
│   │   │   └── i_characters_repository.dart
│   │   ├── i_profile_repository.dart
│   │   ├── i_user_repository.dart
│   │   └── i_friends_repository.dart
│   │
│   ├── failures/                            # 8개 Phase 3 Failure 클래스
│   │   ├── profile_failures.dart
│   │   ├── validation_failure.dart
│   │   ├── firestore_read_failure.dart
│   │   ├── firestore_write_failure.dart
│   │   ├── storage_failure.dart
│   │   ├── network_failure.dart
│   │   ├── profile_not_found_failure.dart
│   │   └── permission_denied_failure.dart
│   │
│   └── constants/                           # 2개 상수 파일
│       ├── validation_constants.dart
│       └── profile_constants.dart
│
└── presentation/                             # 프레젠테이션 레이어 (45개 파일)
    ├── screens/                             # 15개 화면
    │   ├── profile_main/
    │   │   ├── profile_page_widget.dart
    │   │   └── profile_page_model.dart
    │   ├── profile_edit/
    │   │   ├── profile_edit_screen.dart
    │   │   └── profile_edit_model.dart
    │   ├── onboarding/
    │   │   ├── interest_selection/
    │   │   │   ├── agreed_select/
    │   │   │   │   ├── agrred_select_widget.dart
    │   │   │   │   └── agrred_select_model.dart
    │   │   │   ├── expertise_select/
    │   │   │   │   ├── expertise_select_widget.dart
    │   │   │   │   └── expertise_select_model.dart
    │   │   │   └── hobbies_select/
    │   │   │       ├── hobbies_select_widget.dart
    │   │   │       └── hobbies_select_model.dart
    │   │   └── onboarding_flow_screen.dart
    │   ├── user_info/
    │   │   ├── character_detail/
    │   │   │   ├── character_detail_page_widget.dart
    │   │   │   └── character_detail_page_model.dart
    │   │   ├── language_selector/
    │   │   │   ├── language_selector_widget.dart
    │   │   │   └── language_selector_model.dart
    │   │   └── user_info_display/
    │   │       └── user_info_display_widget.dart
    │   └── user_info_input/
    │       ├── user_info_input_widget.dart
    │       └── user_info_input_model.dart
    │
    ├── providers/                           # 7개 Provider + Coordinators (Phase 5)
    │   ├── profile_provider.dart
    │   ├── profile_edit_provider.dart
    │   ├── settings_provider.dart
    │   ├── friends_provider.dart
    │   ├── interests_provider.dart
    │   └── onboarding_coordinator.dart      # Phase 5 Coordinator
    │
    ├── widgets/                             # 25개 위젯
    │   ├── profile/
    │   │   ├── profile_avatar.dart
    │   │   ├── profile_header.dart
    │   │   ├── profile_stats_card.dart
    │   │   └── profile_action_button.dart
    │   ├── settings/
    │   │   ├── settings_section.dart
    │   │   ├── settings_toggle.dart
    │   │   └── settings_list_tile.dart
    │   ├── friends/
    │   │   ├── friend_list_item.dart
    │   │   ├── friend_request_card.dart
    │   │   └── empty_friends_state.dart
    │   ├── interests/
    │   │   ├── interest_chip.dart
    │   │   ├── interest_category_grid.dart
    │   │   └── interest_selection_bottom_sheet.dart
    │   └── common/
    │       ├── loading_indicator.dart
    │       ├── error_message.dart
    │       ├── empty_state.dart
    │       └── custom_text_field.dart
    │
    └── constants/                           # 5개 상수 파일
        ├── profile_constants.dart
        ├── dimensions.dart
        ├── colors.dart
        ├── strings.dart
        └── validation_rules.dart
```

---

## 📊 최종 통계

| 레이어 | 현재 | 목표 | 증가 |
|--------|------|------|------|
| **Data** | 10개 | 35개 | +250% |
| **Domain** | 12개 | 42개 | +250% |
| **Presentation** | 14개 | 45개 | +221% |
| **총계** | **36개** | **122개** | **+239%** |

**마이그레이션 기간**: 10일 (하이브리드 운영 기간 포함)
- Phase 1-5: 8일 (기존 계획)
- Phase 4.5: 2일 (레거시 위젯 전환 및 하이브리드 운영)

**주요 개선 사항**:
- ✅ UserProfileAdapter 하이브리드 Provider 활용 (Section 1.4)
- ✅ 레거시 위젯 전환 가이드 10개 (Section 4.5)
- ✅ 7주 점진적 하이브리드 운영 전략 (Phase 4.5)
- ✅ 중복 Repository 통합 전략 (Section 5.3, 83% 코드 감소)

---

## ✅ 체크리스트

### Phase 1: 구조 정리 (Day 1)
- [x] data/models 5개 파일 삭제
- [x] IUserRepository SettingsModel 제거
- [ ] 각 레이어별 README 생성

### Phase 2: Domain Layer (Day 2-3)
- [x] 10개 UseCase 생성
- [x] 8개 Failure 클래스 생성
- [x] Domain Models 정리 (실용적 접근 - 일단 유지)

### Phase 3: Data Layer (Day 4-5)
- [x] 8개 DataSource 생성 (4 인터페이스 + 4 구현)
- [x] 8개 DTO 생성
- [x] 4개 Mapper 생성
- [ ] 6개 Repository 구현체 생성

### Phase 4: Presentation Layer (Day 6-7)
- [ ] 7개 Provider 생성 + Coordinators (Phase 5)
- [ ] 15개 Screen 생성/리팩토링
- [ ] 25개 Widget 생성
- [ ] 5개 Constants 파일 생성

### Phase 4.5: 레거시 위젯 전환 및 하이브리드 운영 (Day 7.5-9.5)

#### Week 1-2: 하이브리드 Provider 구축
- [ ] UserProfileAdapter 기반 하이브리드 Provider 생성 (Section 1.4)
- [ ] watchProfileLegacy() 메서드 구현 (레거시 지원)
- [ ] loadProfile() 메서드 구현 (신규 UseCase 방식)
- [ ] 병렬 시스템 테스트 코드 작성
- [ ] InterestsProvider 완전 구현 (addExpertise, removeExpertise 등)

#### Week 3: P0 위젯 전환 (최우선)
- [ ] profile_page_widget.dart (535줄): StreamBuilder → Consumer 전환
- [ ] expertise_select_widget.dart (847줄): 직접 Firestore 쓰기 → Provider + UseCase

#### Week 4: P0 위젯 전환 (계속)
- [ ] hobbies_select_widget.dart (1,073줄): 동일 패턴 전환
- [ ] agreed_select_widget.dart (1,020줄): 동일 패턴 전환

#### Week 5-6: P1/P2 위젯 전환
- [ ] character_detail_page_widget.dart (P1, 596줄)
- [ ] language_selector_widget.dart (P2, 235줄)
- [ ] profile_edit_screen.dart (P1, 예상 400줄)
- [ ] user_info_input_widget.dart (P2, 692줄)
- [ ] user_info_display_widget.dart (P3, 341줄)
- [ ] onboarding_flow_screen.dart (P1, 예상 300줄)

#### Week 7: 레거시 코드 완전 제거
- [ ] watchProfileLegacy() 메서드 제거
- [ ] 하이브리드 테스트 코드 제거
- [ ] kDebugMode 조건부 레거시 UI 제거
- [ ] @Deprecated 어노테이션 제거
- [ ] UserProfileAdapter 제거 (UserProfileMapper로 완전 대체)

### Phase 5: 통합 및 중복 제거 (Day 10-10.5)

#### 5.1. DI 및 라우팅 (Day 10.0, 2시간)
- [ ] DI Module 생성 (profile_module.dart)
- [ ] main.dart 통합
- [ ] GoRouter 경로 등록
- [ ] 전체 빌드 테스트

#### 5.2. Phase 5 Coordinator (Day 10.2, 1시간)
- [ ] OnboardingCoordinator 생성
- [ ] 3개 Provider 통합 (Interests, ProfileEdit, Settings)

#### 5.3. 중복 Repository 통합 (Day 10.3-10.5, 4시간)

**Step 1: 기존 user_repository_impl.dart 분석** (1시간)
- [ ] 10개 메서드 기능별 분류 완료
- [ ] 6개 신규 Repository 맵핑 테이블 작성

**Step 2: Repository 분할 맵핑** (1시간)
- [ ] SettingsRepositoryImpl로 이동 (getUserSettings, updateUserSettings)
- [ ] FriendsRepositoryImpl로 이동 (getFriendsList, addFriend, removeFriend)
- [ ] InterestsRepositoryImpl로 이동 (updateUserInterests)
- [ ] CharactersRepositoryImpl로 이동 (getUserCharacter, updateCharacter)
- [ ] ProfileRepositoryImpl로 대체 (getUserByUid → getUserProfile)

**Step 3: 점진적 통합** (2시간)
- [ ] 각 신규 Repository에 메서드 이동 완료
- [ ] @Deprecated 어노테이션 추가 (기존 메서드)
- [ ] UserProfileAdapter 재활용 전략 확인 (Phase 4.5 Week 7 이후 제거)
- [ ] 통합 테스트 실행 및 검증

---

## ★ Insight ─────────────────────────────────────

**Creation Feature 패턴 적용의 핵심 포인트**:

1. **DataSource 레이어 추가**: Firestore와의 직접 통신을 분리하여 테스트 가능성 향상
   - 인터페이스 기반으로 Firebase 의존성 격리
   - Mock 객체로 단위 테스트 작성 가능

2. **DTO/Mapper 패턴**: Firestore ↔ Domain Model 변환을 명확히 분리하여 데이터 흐름 추적 용이
   - DTO: Firestore 문서 구조에 맞춘 순수 데이터 객체
   - Mapper: 양방향 변환 로직 중앙 집중

3. **Phase 3 Failure 클래스**: `getUserMessage()` 메서드로 사용자 친화적 에러 처리
   - 개발자용 메시지와 사용자용 메시지 분리
   - 에러 타입별 적절한 안내 제공

4. **Phase 5 Coordinator**: OnboardingCoordinator로 복잡한 멀티 프로바이더 플로우를 단일 진입점으로 관리
   - 3개 Provider (Interests, ProfileEdit, Settings) 통합
   - 진행률 추적 및 에러 처리 일원화

5. **UseCase 패턴**: 비즈니스 로직을 Repository에서 분리하여 단일 책임 원칙 준수
   - 각 UseCase는 하나의 비즈니스 작업만 담당
   - Repository는 데이터 접근만, 로직은 UseCase에서 처리

─────────────────────────────────────────────────

---

## 🚀 향후 작업 로드맵 (Phase 3 완료 후)

> **업데이트일**: 2025-01-20
> **현재 위치**: Phase 3 완료, Phase 4 준비 중

### 📅 Week-by-Week 계획

#### Week 3: Phase 4 준비 및 문서화 (2일)
**Day 8-9**:
- [ ] Phase 3 API 문서 작성 (4시간)
  - DataSource 메서드 설명
  - Repository 메서드 용도
  - 고급 알고리즘 (Haversine, 추천) 상세 설명
- [ ] Phase 4 UseCase 목록 확정 (2시간)
  - 필수 UseCase 28개 선정
  - 선택 UseCase 5개 별도 분류
- [ ] README.md 업데이트 (2시간)
  - data/README.md: Phase 3 구현 내용 반영
  - domain/README.md: 새 도메인 모델 (Interest, Character) 설명

#### Week 4-5: Phase 4.1-4.3 (UseCases & Providers)
**Day 10-12** (Phase 4.1: UseCases 생성, 10시간):
- [ ] Profile UseCases (10개) - 4시간
- [ ] Friends UseCases (9개) - 3시간
- [ ] Settings/Interests/Characters UseCases (9개) - 3시간

**Day 13-14** (Phase 4.2: Core Providers, 8시간):
- [ ] ProfileProvider (확장) - 3시간
- [ ] SettingsProvider - 2시간
- [ ] InterestsProvider - 3시간

**Day 15** (Phase 4.3: Social Providers, 4시간):
- [ ] FriendsProvider (신규, 15개 메서드) - 3시간
- [ ] CharactersProvider - 1시간

#### Week 6: Phase 5 (Coordinators)
**Day 16-17** (6-8시간):
- [ ] OnboardingCoordinator (4시간)
  - InterestsProvider + ProfileEditProvider + SettingsProvider 통합
  - 프로필 완성도 추적 (`getProfileCompletionPercentage()` 활용)
- [ ] SearchCoordinator (2-3시간)
  - 복합 검색 UI와 `searchProfiles()` 연동
- [ ] FriendsCoordinator (선택, 1-2시간)
  - 친구 추천 UI와 `getFriendSuggestions()` 연동

#### Week 7: Phase 4.5 (하이브리드 운영 준비)
**Day 18** (2시간):
- [ ] UserProfileAdapter 활용 Provider 구현
- [ ] 레거시 Stream 메서드 유지
- [ ] 병렬 시스템 테스트 환경 구축

### ✅ 다음 작업 체크리스트

**즉시 (Day 8)**:
- [x] 이 업데이트 계획서를 MIGRATION_PLAN.md에 반영
- [x] Phase 3 완료 표시 업데이트
- [x] Phase 4-5 예상 작업량 수정

**이번 주 (Day 8-9)**:
- [ ] data/README.md 작성
  - DataSource 패턴 설명
  - DTO 패턴 설명
  - Mapper 패턴 설명
  - 46개 DataSource 메서드 요약표
- [ ] domain/README.md 업데이트
  - Interest 모델 설명
  - Character 모델 설명
  - 78개 Repository 메서드 요약표

**다음 주 (Week 4)**:
- [ ] Phase 4 시작: UseCases 생성

---

## 📚 참고 자료

### Phase 3 완료 리포트
- **완료일**: 2025-01-20
- **총 작업 시간**: 16시간
- **생성된 파일**: 26개
- **작성된 코드**: ~3,500줄
- **구현된 메서드**: 124개 (DataSource 46 + Repository 78)

### 주요 결정 사항
1. **Option 2 선택**: 모든 메서드 완전 구현 (사용자 승인: "진행해")
2. **도메인 모델 추가**: Interest, Character (사용자 승인: "진행해")
3. **Freezed 포기**: build_runner 실패로 일반 클래스 사용 (자체 결정)

### 교훈
- **계획의 유연성**: 초기 계획이 실제 요구사항과 다를 수 있음을 인정
- **완전성 vs 속도**: 완전한 구현이 장기적으로 시간 절약
- **문서화의 중요성**: 확장된 API는 더 많은 문서가 필요

---

**마지막 업데이트**: 2025-01-20
**버전**: v2.1 (Profile Feature Clean Architecture v4.0 Migration - Phase 3 Complete)
**유지관리자**: Profile Feature Team

**v2.1 변경 사항** (2025-01-20):
- ✅ Phase 3 완료 상태 반영 (26개 파일, 124개 메서드, ~3,500줄)
- ✅ 계획 vs 실제 비교 표 추가 (DataSource +130%, Repository +160%)
- ✅ Phase 4-5 영향 분석 섹션 신규 추가
- ✅ UseCase 수 10개 → 28개로 업데이트
- ✅ Provider 구현 전략 수정 (ProfileProvider 12개 메서드, FriendsProvider 15개 메서드)
- ✅ 향후 작업 로드맵 추가 (Week 3-7 계획)
- ✅ Phase 3 완료 리포트 및 교훈 문서화

**v2.0 변경 사항**:
- ✅ Section 1.4 추가: UserProfileAdapter 하이브리드 활용 전략
- ✅ Section 4.5 추가: 레거시 위젯 전환 가이드 (10개 위젯 분석)
- ✅ Phase 4.5 신규: 레거시 위젯 전환 및 7주 하이브리드 운영 계획
- ✅ Section 5.3 추가: 중복 Repository 통합 전략 (83% 코드 감소)
- ✅ 마이그레이션 기간: 8일 → 10일 (하이브리드 운영 기간 포함)
- ✅ 체크리스트 확장: Phase 4.5 (Week 1-7), Phase 5.3 (Step 1-3)
