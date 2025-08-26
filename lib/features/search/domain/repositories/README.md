# 📂 Search Repository Interface

> Domain Layer의 Repository 추상화 - 데이터 접근 계약

## 📋 개요

Repository Interface는 Domain Layer에서 데이터 접근을 추상화한 인터페이스입니다. 구체적인 구현 세부사항 없이 비즈니스 요구사항만을 정의합니다.

## 🎯 Repository 패턴의 목적

### 핵심 역할
- 데이터 소스 추상화
- 비즈니스 로직과 데이터 접근 분리
- 테스트 가능성 향상
- 구현 유연성 제공
- 의존성 역전 원칙 적용

### Repository Interface가 정의하는 것
- 데이터 접근 메서드 시그니처
- 반환 타입 (Domain Models)
- 비즈니스 요구사항
- 예외 타입

### Repository Interface가 정의하지 않는 것
- 구현 세부사항
- 데이터 소스 특정 로직
- 캐싱 전략
- 트랜잭션 관리

## 📁 파일 구조

```
repositories/
└── search_repository.dart    # 검색 리포지토리 인터페이스
```

## 🔄 마이그레이션 대상

### 새로 생성할 파일
```bash
touch lib/features/search/domain/repositories/search_repository.dart
```

## 💻 SearchRepository Interface 사양

### 검색 기능 메서드

**통합 검색:**
- `search()`: 모든 타입의 콘텐츠 검색
  - 파라미터: query (String), filter (SearchFilter?)
  - 반환: Either<Failure, List<SearchResult>>

**타입별 검색:**
- `searchPosts()`: 게시물만 검색
- `searchUsers()`: 사용자 프로필 검색
- `searchChats()`: 채팅 메시지 검색
- `advancedSearch()`: SearchQuery 모델 사용한 고급 검색

### 검색 기록 메서드

- `saveSearchHistory()`: 검색 기록 저장
- `getSearchHistory()`: 사용자 검색 기록 조회
- `getSearchHistoryStream()`: 실시간 검색 기록 스트림
- `clearSearchHistory()`: 모든 검색 기록 삭제
- `deleteSearchHistory()`: 특정 검색 기록 삭제

### 검색 제안 메서드

- `getTrendingSearches()`: 인기 검색어 조회
- `getSearchSuggestions()`: 자동완성 제안
- `getRelatedSearches()`: 관련 검색어 제공

### 검색 통계 메서드

- `getSearchStatistics()`: 검색 관련 통계 조회
  - SearchStatistics 모델 반환
  - totalSearches, uniqueUsers, topQueries 등 포함

### 인덱싱 메서드

- `indexContent()`: 새 콘텐츠 인덱스 추가
- `updateIndex()`: 기존 인덱스 업데이트
- `removeFromIndex()`: 인덱스에서 제거

## 🔄 Failure 타입 사양

### 기본 Failure 타입
- **Failure**: 추상 기본 클래스
  - message: String - 오류 메시지
  - code: String? - 오류 코드 (선택)
  - Equatable 상속

### 도메인별 Failure 타입
- **SearchFailure**: 검색 관련 실패
- **ValidationFailure**: 입력 검증 실패
- **AuthFailure**: 인증 관련 실패
- **NetworkFailure**: 네트워크 연결 실패
- **CacheFailure**: 캐시 처리 실패
- **ServerFailure**: 서버 응답 실패 (statusCode 포함)
- **UnknownFailure**: 알 수 없는 오류
- **PermissionFailure**: 권한 부족
- **RateLimitFailure**: API 요청 제한 초과 (retryAfter 포함)

## 🧪 테스트 전략

### Mock Repository 구현
- Mockito를 사용한 MockSearchRepository 생성
- Repository 인터페이스 모킹
- UseCase 테스트에서 활용

### 테스트 시나리오
- 검색 결과 반환 검증
- 필터 적용 테스트
- 실패 케이스 처리
- 리포지토리 호출 검증

## 🏗️ 의존성 주입 설정

### GetIt 등록
- SearchModule 생성 (Injectable 패턴)
- Repository 인터페이스와 구현체 바인딩
- 필요한 DataSource와 Service 주입:
  - AlgoliaDataSource
  - LocalSearchDataSource
  - FirestoreSearchDataSource
  - SearchCacheService
  - SearchFilterService
- Lazy Singleton 패턴으로 등록

## 📊 Repository 메서드 분류

### 1. Query Methods (조회)
- `search()` - 통합 검색
- `searchPosts()` - 게시물 검색
- `searchUsers()` - 사용자 검색
- `searchChats()` - 채팅 검색
- `advancedSearch()` - 고급 검색

### 2. History Methods (기록)
- `saveSearchHistory()` - 기록 저장
- `getSearchHistory()` - 기록 조회
- `getSearchHistoryStream()` - 실시간 기록
- `clearSearchHistory()` - 기록 삭제
- `deleteSearchHistory()` - 특정 기록 삭제

### 3. Suggestion Methods (제안)
- `getTrendingSearches()` - 인기 검색어
- `getSearchSuggestions()` - 자동완성
- `getRelatedSearches()` - 관련 검색어

### 4. Analytics Methods (통계)
- `getSearchStatistics()` - 검색 통계

### 5. Index Methods (인덱싱)
- `indexContent()` - 콘텐츠 추가
- `updateIndex()` - 인덱스 업데이트
- `removeFromIndex()` - 인덱스 제거

## 🎯 설계 고려사항

### 1. Either 패턴 사용
- 모든 메서드는 `Either<Failure, T>` 반환
- 명시적인 에러 처리
- 함수형 프로그래밍 패러다임

### 2. Stream 지원
- 실시간 데이터를 위한 Stream 메서드
- 검색 기록 실시간 업데이트

### 3. 확장성
- 새로운 검색 타입 추가 가능
- 필터 옵션 확장 가능
- 통계 메서드 추가 가능

### 4. 테스트 용이성
- 인터페이스 기반 설계
- Mock 객체 생성 용이
- 의존성 주입 지원

## 📝 마이그레이션 체크리스트

- [ ] SearchRepository 인터페이스 생성
  - [ ] 검색 메서드 정의
  - [ ] 기록 메서드 정의
  - [ ] 제안 메서드 정의
  - [ ] 통계 메서드 정의
  - [ ] 인덱싱 메서드 정의
- [ ] Failure 타입 정의
  - [ ] 기본 Failure 클래스
  - [ ] 도메인별 Failure 타입
- [ ] 의존성 주입 설정
  - [ ] GetIt 모듈 생성
  - [ ] Repository 바인딩
- [ ] 테스트 환경 구성
  - [ ] Mock Repository 생성
  - [ ] 테스트 헬퍼 작성

---

*Repository Interface는 검색 기능의 데이터 접근 계약을 정의합니다.*