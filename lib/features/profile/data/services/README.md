# 🛠️ /lib/features/profile/data/services

> Feature-First Architecture - Profile 서비스 계층

## 📋 개요

프로필 기능의 **Service Layer**를 담당하는 디렉토리입니다. 비즈니스 로직 구현, 외부 API 통합, 데이터 처리 및 변환을 담당합니다.

### 🎯 목적
- **비즈니스 로직**: 프로필 관련 핵심 비즈니스 로직 구현
- **데이터 처리**: 데이터 변환, 검증, 포맷팅
- **외부 통합**: Firebase, Storage 등 외부 서비스 통합
- **캐싱 관리**: 프로필 데이터 캐싱 전략

## 🏗️ 디렉토리 구조

```
services/
├── profile_service.dart           # 프로필 CRUD 서비스
├── user_cache_service.dart        # 사용자 캐싱 서비스
├── character_service.dart         # 캐릭터 관리 서비스
├── interest_service.dart          # 관심사 관리 서비스
├── job_service.dart               # 직업 정보 서비스
├── friends_service.dart           # 친구 관리 서비스
├── premium_service.dart           # 프리미엄 관리 서비스
└── onboarding_service.dart        # 온보딩 플로우 서비스
```

## 📂 주요 서비스 사양

### ProfileService

**역할**: 프로필 관리 핵심 서비스

**주요 기능**:
- 원격/로컬 프로필 조회
- 프로필 업데이트 및 캐싱
- 아바타 업로드 및 관리
- 프로필 통계 조회
- 실시간 프로필 스트림

**의존성**:
- FirebaseFirestore
- FirebaseStorage  
- Hive (로컬 캐싱)

**메서드 사양**:
- `getRemoteProfile(userId)`: Firebase에서 프로필 조회
- `getLocalProfile(userId)`: 로컬 캐시에서 프로필 조회
- `saveLocalProfile(userId, profile)`: 로컬에 프로필 저장
- `updateProfile(userId, updates)`: 프로필 업데이트
- `uploadAvatar(userId, imageBytes)`: 아바타 업로드
- `profileStream(userId)`: 실시간 프로필 스트림
- `clearLocalProfile(userId)`: 로컬 캐시 클리어

**캐싱 전략**:
- 로컬 캐시: Hive Box 사용
- 캐시 유효 시간: 24시간
- 업데이트 시 자동 무효화
- 통계 정보 백그라운드 업데이트

**에러 처리**:
- ProfileServiceException: 일반 프로필 에러
- ProfileNotFoundException: 프로필 없음
- StorageException: 스토리지 에러
- CacheException: 캐시 에러

### CharacterService

**역할**: 캐릭터 관리 서비스

**주요 기능**:
- 사용 가능한 캐릭터 목록 조회
- 사용자 캐릭터 조회 및 선택
- 캐릭터 커스터마이징
- 프리미엄 캐릭터 잠금 해제

**의존성**:
- FirebaseFirestore
- FirebaseStorage

**메서드 사양**:
- `getAvailableCharacters()`: 사용 가능한 캐릭터 목록 조회
- `getUserCharacter(userId)`: 사용자의 현재 캐릭터 조회
- `updateUserCharacter(userId, characterId)`: 캐릭터 선택/변경
- `customizeCharacter(userId, customization)`: 캐릭터 커스터마이징
- `unlockPremiumCharacter(userId, characterId)`: 프리미엄 캐릭터 잠금 해제

**컬렉션**:
- `characters`: 캐릭터 정보
- `users`: 사용자 캐릭터 매핑

**트랜잭션 처리**:
- 프리미엄 캐릭터 잠금 해제 시 트랜잭션 사용
- 원자적 업데이트 보장

### InterestService

**역할**: 관심사 관리 서비스

**주요 기능**:
- 모든 관심사 카테고리 조회
- 직업 카테고리 및 직업명 조회
- 인기 관심사 조회
- 사용자 관심사 업데이트
- 관심사 추천

**의존성**:
- FirebaseFirestore

**메서드 사양**:
- `getAllCategories()`: 모든 관심사 카테고리 조회 (가중치순)
- `getJobCategories()`: 직업 카테고리 목록 조회
- `getJobNames(categoryId)`: 카테고리별 직업명 조회
- `getPopularInterests(limit)`: 인기 관심사 조회 (기본 20개)
- `updateUserInterests(userId, expertise, hobbies)`: 사용자 관심사 업데이트
- `getRecommendedInterests(userId)`: AI 기반 관심사 추천

**제약사항**:
- 전문분야: 최대 4개
- 취미: 최대 8개

**추천 알고리즘**:
- 유사 사용자 기반 추천
- 관심사 가중치 자동 업데이트
- 상위 10개 추천 반환

### OnboardingService

**역할**: 온보딩 플로우 관리 서비스

**주요 기능**:
- 온보딩 상태 조회
- 온보딩 단계 완료 처리
- 온보딩 건너뛰기
- 온보딩 초기화
  
  /// 온보딩 상태 조회
  Future<OnboardingState> getOnboardingState(String userId) async {
    try {
      // 로컬 진행 상태
      final localProgress = _prefs.getStringList(_onboardingKey) ?? [];
      
      // 서버 상태
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        return OnboardingState.notStarted();
      }
      
      final data = userDoc.data()!;
      
      return OnboardingState(
        isCompleted: data['onboardingCompleted'] ?? false,
        currentStep: data['onboardingStep'] ?? 0,
        completedSteps: localProgress,
        agreedToTerms: data['agreedToTerms'] ?? false,
        ageVerified: data['ageVerified'] ?? false,
        hasSelectedJob: data['jobCategory'] != null,
        hasSelectedExpertise: (data['expertise'] as List?)?.isNotEmpty ?? false,
        hasSelectedHobbies: (data['hobbies'] as List?)?.isNotEmpty ?? false,
        hasCreatedCharacter: data['characterId'] != null,
      );
    } catch (e) {
      return OnboardingState.notStarted();
    }
  }
  
  /// 온보딩 단계 완료
  Future<void> completeStep({
    required String userId,
    required OnboardingStep step,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 로컬 진행 상태 업데이트
      final progress = _prefs.getStringList(_onboardingKey) ?? [];
      if (!progress.contains(step.name)) {
        progress.add(step.name);
        await _prefs.setStringList(_onboardingKey, progress);
      }
      
      // 서버 업데이트
      final updates = <String, dynamic>{
        'onboardingStep': step.index + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // 단계별 데이터 저장
      switch (step) {
        case OnboardingStep.ageVerification:
          updates['ageVerified'] = true;
          updates['birthYear'] = data?['birthYear'];
          break;
          
        case OnboardingStep.jobSelection:
          updates['jobCategory'] = data?['category'];
          updates['jobName'] = data?['name'];
          break;
          
        case OnboardingStep.expertiseSelection:
          updates['expertise'] = data?['expertise'];
          break;
          
        case OnboardingStep.hobbiesSelection:
          updates['hobbies'] = data?['hobbies'];
          break;
          
        case OnboardingStep.characterCreation:
          updates['characterId'] = data?['characterId'];
          break;
          
        case OnboardingStep.profileSetup:
          updates['displayName'] = data?['displayName'];
          updates['photoURL'] = data?['photoURL'];
          updates['bio'] = data?['bio'];
          updates['onboardingCompleted'] = true;
          break;
      }
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw OnboardingServiceException('Failed to complete step: $e');
    }
  }
  
  /// 온보딩 건너뛰기
  Future<void> skipOnboarding(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'onboardingSkipped': true,
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await _prefs.setBool('onboarding_skipped', true);
    } catch (e) {
      throw OnboardingServiceException('Failed to skip onboarding: $e');
    }
  }
  
  /// 온보딩 초기화
  Future<void> resetOnboarding(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'onboardingCompleted': false,
        'onboardingStep': 0,
        'onboardingSkipped': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await _prefs.remove(_onboardingKey);
      await _prefs.remove('onboarding_skipped');
    } catch (e) {
      throw OnboardingServiceException('Failed to reset onboarding: $e');
    }
  }
}
```

## 🔧 유틸리티 서비스

### UserCacheService
- **역할**: 사용자 데이터 캐싱 서비스
- **주요 기능**:
  - 메모리 기반 캐싱 (30분 TTL)
  - 사용자별 데이터 캐싱 및 조회
  - 캐시 무효화 및 전체 클리어
  - 자동 만료 관리
- **캐싱 전략**:
  - Memory Map 기반
  - 30분 캐시 유효 시간
  - LRU 방식 고려 중
- **의존성**: 없음 (Standalone)

## 🧪 테스트 전략

### 서비스 테스트
- **단위 테스트**: Mock 데이터소스 사용
- **통합 테스트**: 실제 Firebase 연동
- **성능 테스트**: 캐시 히트율 측정
- **에러 시나리오**: 네트워크 실패, 권한 에러

## ⚠️ 에러 처리

### 서비스 예외 타입
- **ProfileServiceException**: 프로필 관련 예외
- **ProfileNotFoundException**: 프로필 없음
- **CharacterServiceException**: 캐릭터 관련 예외
- **CharacterNotFoundException**: 캐릭터 없음
- **InterestServiceException**: 관심사 관련 예외
- **OnboardingServiceException**: 온보딩 관련 예외
- **StorageException**: 저장소 관련 예외
- **CacheException**: 캐시 관련 예외
- **ValidationException**: 유효성 검사 예외

## ✅ 체크리스트

### 구현 완료
- [ ] ProfileService
- [ ] UserCacheService (기존 마이그레이션)
- [ ] CharacterService
- [ ] InterestService
- [ ] JobService
- [ ] FriendsService
- [ ] PremiumService
- [ ] OnboardingService

### 구현 예정
- [ ] ProfileMigrationService (데이터 마이그레이션)
- [ ] ProfileAnalyticsService (분석)
- [ ] ProfileBackupService (백업/복원)

## 📚 참고 자료

- [Firebase Documentation](https://firebase.google.com/docs)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter Caching Strategies](https://flutter.dev/docs/cookbook/networking/cached-images)

---

*이 문서는 Feature-First Architecture의 Profile 기능 서비스 가이드입니다.*
*최종 업데이트: 2025-08-25*