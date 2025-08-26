# 📚 Profile Data Repositories Layer

> Feature-First Architecture - Profile 리포지토리 계층

## 📋 개요

프로필 기능의 **Repository Layer**를 담당하는 디렉토리입니다. 데이터 소스와 도메인 계층 사이의 추상화를 제공하며, 비즈니스 로직과 데이터 접근을 분리합니다.

### 🎯 목적
- **데이터 추상화**: Remote/Local 데이터 소스 통합 관리
- **캐싱 전략**: 3-Layer 캐싱 시스템 구현
- **에러 처리**: 통일된 에러 처리 및 변환
- **비즈니스 로직**: 도메인 특화 로직 구현

## 🏗️ 디렉토리 구조

```
repositories/
├── profile_repository_impl.dart    # 프로필 리포지토리 구현
├── settings_repository_impl.dart   # 설정 리포지토리 구현
├── character_repository_impl.dart  # 캐릭터 리포지토리 구현
├── interest_repository_impl.dart   # 관심사 리포지토리 구현
├── friends_repository_impl.dart    # 친구 리포지토리 구현
└── premium_repository_impl.dart    # 프리미엄 리포지토리 구현
```

## 📂 주요 리포지토리 사양

### ProfileRepositoryImpl
- **역할**: 프로필 데이터 관리 중앙화
- **주요 기능**:
  - 3-Layer 캐싱 (Memory → Hive → Firestore)
  - 프로필 CRUD 작업
  - 아바타 업로드 및 최적화
  - 프로필 통계 스트림
- **의존성**: ProfileService, UserCacheService, CharacterService
- **에러 처리**: Either<Failure, T> 패턴

### SettingsRepositoryImpl
- **역할**: 사용자 설정 관리
- **주요 기능**:
  - 언어 설정 변경
  - 알림 설정 관리
  - 테마 설정 변경
  - 로컬/원격 동기화
- **의존성**: SettingsService, SharedPreferences
- **오프라인 지원**: 로컬 우선 전략

### InterestRepositoryImpl
- **역할**: 관심사/취미 관리
- **주요 기능**:
  - 사용자 관심사 조회/업데이트
  - 전체 관심사 목록 제공
  - 유효성 검증 (최대 개수 제한)
- **제한사항**:
  - 전문분야: 최대 4개
  - 취미: 최대 8개

### FriendsRepositoryImpl
- **역할**: 친구 관계 관리
- **주요 기능**:
  - 친구 목록 조회
  - 친구 추가/삭제 (양방향)
  - 친구 상태 관리

### CharacterRepositoryImpl
- **역할**: 캐릭터 데이터 관리
- **주요 기능**:
  - 캐릭터 목록 제공
  - 사용자 캐릭터 선택
  - 캐릭터 이미지 캐싱

### PremiumRepositoryImpl
- **역할**: 프리미엄 구독 관리
- **주요 기능**:
  - 구독 상태 조회
  - 프리미엄 업그레이드
  - 구독 갱신 처리

## 🔄 데이터 흐름

```
UseCase Layer
    ↓
Repository Interface
    ↓
Repository Implementation
    ↓
[Cache Check] → Hit → Return Cached Data
    ↓ Miss
[Remote Fetch] → Success → Update Cache → Return Data
    ↓ Failure
[Offline Mode] → Local Data → Return Data
```

## 🧪 테스트 전략

### 단위 테스트
- Mock 데이터소스 사용
- 캐시 히트/미스 시나리오
- 오프라인 모드 테스트
- 에러 처리 검증

### 통합 테스트
- 실제 데이터소스 연동
- 캐시 동기화 검증
- 네트워크 전환 테스트

## ⚠️ 에러 처리

### 에러 타입
- **ProfileFailure**: 프로필 관련 에러
- **SettingsFailure**: 설정 관련 에러
- **ValidationFailure**: 유효성 검증 실패
- **NetworkFailure**: 네트워크 에러
- **CacheFailure**: 캐시 에러

### Either 패턴
```
Future<Either<Failure, T>> method() async {
  try {
    // 성공 케이스
    return Right(result);
  } catch (e) {
    // 실패 케이스
    return Left(Failure(e.toString()));
  }
}
```

## ✅ 체크리스트

### 구현 완료
- [ ] ProfileRepositoryImpl
- [ ] SettingsRepositoryImpl
- [ ] CharacterRepositoryImpl
- [ ] InterestRepositoryImpl
- [ ] FriendsRepositoryImpl
- [ ] PremiumRepositoryImpl

### 구현 예정
- [ ] 오프라인 동기화 로직
- [ ] 충돌 해결 전략
- [ ] 배치 업데이트 최적화
- [ ] 트랜잭션 처리

---

*이 문서는 Feature-First Architecture의 Profile 기능 리포지토리 가이드입니다.*
*최종 업데이트: 2025-08-25*