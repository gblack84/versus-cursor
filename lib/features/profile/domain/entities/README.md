# Profile Domain Models

> Clean Architecture v4.0 - Pure Domain Layer

## 개요

Profile Feature의 **Domain Models**를 정의합니다. Firebase 의존성이 제거된 순수 Dart 클래스로, 비즈니스 로직만 포함합니다.

### 아키텍처 원칙
- ✅ **Pure Domain**: Firebase/Infrastructure 의존성 없음
- ✅ **Immutable**: Final 필드, const 생성자
- ✅ **Type Safe**: Non-null by default, 명시적 nullable
- ✅ **Serializable**: JSON ↔ 모델 변환 지원 (캐싱용)

## 모델 목록

### 현재 Active 모델 (6개)

| 모델 | 파일 | 줄 수 | 역할 | 상태 |
|------|------|-------|------|------|
| **UserProfile** | user_profile.dart | 351 | 통합 사용자 프로필 (42 필드) | ✅ Active |
| **ProfileInfo** | profile_info.dart | 130 | 표시 정보 (10 필드) | ✅ Active (Phase 1 정리) |
| **UserSettings** | user_settings.dart | 170 | 설정/알림 (9 필드) | ✅ Active |
| **Character** | character.dart | 62 | 캐릭터 정보 (7 필드) | ✅ Active |
| **Interest** | interest.dart | 65 | 관심사 (5 필드) | ✅ Active |
| **InterestCategory** | interest_category.dart | 77 | 관심사 카테고리 (9 필드) | ✅ Active |

### 삭제된 모델

| 모델 | 삭제 날짜 | 사유 |
|------|-----------|------|
| **UserStats** | 2025-01-20 (Phase 2) | 미사용 (247줄), 포인트/랭킹 기능 미정 |
| **FriendsListModel** | 2025-01-19 | 데이터 중복, UserProfile 사용 |

## 주요 모델 상세

### UserProfile (통합 모델)

**역할**: 사용자의 모든 프로필 정보를 담는 메인 모델

**44개 필드 구성**:
```dart
// Core Identity (5)
uid, email, displayName, photoUrl, phoneNumber

// Profile Information (7)
location, country, countryCode, shortDescription, gender, dateOfBirth, language

// System Timestamps (3)
createdTime, lastActive, lastActiveTime

// Points System (4)
pointsA, pointsQ, totalAPoints, totalQPoints

// Interests and Expertise (5)
interests, expertise, hobbies, jobCategory, jobName

// Premium Status (1)
isPremiumUser

// Anonymous Activity (3)
anonymousPostsCount, anonymousCommentsCount, anonymousQuestionCount

// Ranking System (8)
currentRank, currentTitle, rankChangeDate, titleChangeDate,
isRankEligible, rankEvaluationCount, rankHistory, titleHistory

// Notification Settings (2)
receiveRankUpdateNotifications, receiveTitleUpdateNotifications

// Character Selection (1)
characterId

// Social Connections (3)
friends, activeChats, groupChats

// System Fields (4)
role, title, stats, subscription
```

**특징**:
- Pure Dart 클래스 (Firebase 의존성 제거 완료)
- 모든 필드 기본값 제공 (Adapter 호환)
- LatLng 타입 사용 (GeoPoint 제거)

### ProfileInfo (표시 정보)

**역할**: 화면에 표시되는 사용자 기본 정보

**10개 필드**:
- Core: `userId`, `displayName`, `photoUrl`
- Details: `shortDescription`, `gender`, `dateOfBirth`, `language`
- Location: `location` (LatLng)
- Lists: `interests[]`, `expertise[]`

**참고**: `country`와 `countryCode` 필드는 ProfileInfo에 없으며, **UserProfile에만 존재**합니다.

**변경 이력**:
- 2025-01-20 Phase 1: Firebase 의존성 제거
  - `cloud_firestore` import 삭제
  - `GeoPoint` → `LatLng` 변경
  - `fromDocument()`, `toFirestore()` 메서드 삭제 → DTO로 이동

### UserSettings (설정 정보)

**역할**: 사용자 설정 및 알림 관리

**9개 필드**:
- Core: `userId`
- Premium: `isPremiumUser`
- Notifications: `receiveRankUpdateNotifications`, `receiveTitleUpdateNotifications`,
  `receiveVoteNotifications`, `receiveCommentNotifications`, `receiveFriendNotifications`
- Complex: `subscription` (Map), `stats` (Map), `privacySettings` (Map)

**참고**: `stats` 필드는 `Map<String, dynamic>` 타입 (UserStats 모델 아님)

### Character (캐릭터)

**역할**: 사용자 프로필 캐릭터 정보

**7개 필드**:
- Core: `characterId`, `name`, `imageUrl`
- Details: `description`, `isActive`, `characterType`
- System: `createdAt`

### Interest (관심사)

**역할**: 단일 관심사 정보

**5개 필드**:
- Core: `id`, `name`, `category` (job/expertise/hobby)
- Details: `weight` (0.5 기본값)
- System: `selectedAt`

**제약사항**:
- expertise: 최대 4개
- hobbies: 최대 8개

### InterestCategory (관심사 카테고리)

**역할**: 관심사 그룹 정보

**9개 필드**:
- Core: `category` (enum: job, expertise, hobby)
- Details: `name`, `description`, `iconUrl`
- Lists: `items[]`, `subCategories[]`
- System: `isActive`, `order`, `createdAt`

## 아키텍처 개선 히스토리

### Phase 1: ProfileInfo Firebase 의존성 제거 (2025-01-20)
- ❌ 제거: `cloud_firestore` import
- ❌ 제거: `GeoPoint` 타입
- ❌ 제거: `fromDocument()`, `toFirestore()` 메서드
- ✅ 추가: `LatLng` 타입 (앱 전용)
- ✅ 추가: `fromJson()`, `toJson()` (캐싱 전용)
- **결과**: Pure Domain Model 달성

### Phase 2: UserStats 모델 삭제 (2025-01-20)
- ❌ 삭제: `user_stats.dart` (247줄)
- ❌ 삭제: `user_stats_dto.dart` (55줄)
- 🔄 수정: `UserProfileAdapter` (4 models → 3 models)
- **이유**: 단 1곳에서만 사용, 포인트/랭킹 기능 미정
- **결과**: 302줄 삭제, 3-모델 Clean Architecture

## UserProfileAdapter

**역할**: UserProfile ↔ (auth, ProfileInfo, UserSettings) 변환

**변환 패턴**:
```dart
// UserProfile → 3 models
toDomainModels(UserProfile) → (
  auth: Map<String, dynamic>,
  profile: ProfileInfo,
  settings: UserSettings,
)

// 3 models → UserProfile
fromDomainModels(
  auth: Map<String, dynamic>,
  profile: ProfileInfo,
  settings: UserSettings,
  reference: DocumentReference?,
) → UserProfile
```

**Phase 2 이후 변경**:
- UserStats 파라미터 제거
- 포인트/랭킹 필드는 UserProfile 기본값 사용

## 향후 계획

### Stats Feature (미정)
포인트/랭킹 기능이 확정되면:
1. `lib/features/stats/` 디렉토리 생성
2. UserStats 모델 복구 (Git history)
3. 리더보드, 마일스톤, 통계 대시보드 구현

### 추가 가능한 모델
- ❓ **AchievementModel**: 업적 시스템
- ❓ **BadgeModel**: 뱃지 시스템
- ❓ **UserActivityModel**: 활동 히스토리

## 참고 자료

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/tags/domain%20driven%20design.html)
- [MIGRATION_PLAN.md](../MIGRATION_PLAN.md) - Profile Feature 마이그레이션 가이드

---

**최종 업데이트**: 2025-01-20 (Phase 2 완료)
**다음 작업**: Phase 3 README 전면 업데이트, Phase 4 모델 네이밍 검토
