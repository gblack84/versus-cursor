# 📂 Search Feature - Domain Layer

> 검색 기능의 비즈니스 로직과 도메인 모델을 정의하는 레이어

## 📋 개요

Domain Layer는 검색 기능의 핵심 비즈니스 로직을 포함합니다. 외부 의존성 없이 순수한 Dart 코드로 구성되며, 비즈니스 규칙과 도메인 모델을 정의합니다.

## 🏗️ 구조

```
domain/
├── models/                  # 도메인 모델
│   ├── search_result_model.dart      # 검색 결과 모델
│   ├── search_filter_model.dart      # 검색 필터 모델
│   ├── search_history_model.dart     # 검색 기록 모델
│   ├── search_query_model.dart       # 검색 쿼리 모델
│   └── algolia_result_model.dart     # Algolia 결과 모델
│
├── repositories/            # 리포지토리 인터페이스
│   └── search_repository.dart        # 검색 리포지토리 추상화
│
└── usecases/                # 유스케이스
    ├── search_posts_usecase.dart     # 게시물 검색
    ├── search_users_usecase.dart     # 사용자 검색
    ├── search_chats_usecase.dart     # 채팅 검색
    ├── get_search_history_usecase.dart # 검색 기록 조회
    ├── clear_search_history_usecase.dart # 검색 기록 삭제
    └── save_search_query_usecase.dart   # 검색어 저장
```

## 📦 주요 컴포넌트

### 1. Domain Models

#### SearchResult Model
**역할**: 통합 검색 결과 표현

**핵심 필드**:
- id: String - 고유 식별자
- title: String - 제목
- description: String? - 설명
- imageUrl: String? - 이미지 URL
- type: SearchResultType - 결과 타입
- metadata: Map<String, dynamic> - 메타데이터
- relevanceScore: double - 관련성 점수
- createdAt: DateTime - 생성일시

**SearchResultType Enum**:
- post: 게시물
- user: 사용자
- chat: 채팅
- comment: 댓글

**비즈니스 규칙**:
- 관련성 점수는 0.0 ~ 1.0 범위
- 제목은 필수 필드
- Equatable 구현으로 값 동등성 보장

#### SearchFilter Model
**역할**: 검색 필터 및 옵션 관리

**핵심 필드**:
- type: SearchResultType? - 검색 타입
- category: String? - 카테고리
- dateRange: DateTimeRange? - 날짜 범위
- tags: List<String>? - 태그 목록
- minRelevance: double? - 최소 관련성
- sortOrder: SearchSortOrder - 정렬 순서
- limit: int - 결과 개수 제한 (기본 20)
- offset: int - 페이지 오프셋 (기본 0)

**SearchSortOrder Enum**:
- relevance: 관련성
- dateDesc: 최신순
- dateAsc: 오래된순
- popularityDesc: 인기순
- popularityAsc: 인기역순

**주요 메서드**:
- copyWith(): 불변 객체 복사
- 페이지네이션 헬퍼 메서드

#### SearchHistory Model
**역할**: 사용자 검색 기록 저장

**핵심 필드**:
- id: String - 고유 식별자
- userId: String - 사용자 ID
- query: String - 검색어
- type: SearchResultType? - 검색 타입
- resultCount: int - 결과 개수
- timestamp: DateTime - 검색 시간

**변환 메서드**:
- fromFirestore(): Firestore 문서에서 생성
- toFirestore(): Firestore 저장 형식으로 변환

#### SearchQuery Model
**역할**: 검색 쿼리 구조화 및 변환

**핵심 필드**:
- text: String - 원본 검색어
- keywords: List<String> - 추출된 키워드
- isExactMatch: bool - 정확한 매칭 여부
- language: String? - 언어 설정

**주요 메서드**:
- _extractKeywords(): 키워드 자동 추출
- toAlgoliaQuery(): Algolia 쿼리 변환
- 불용어 제거 및 정규화

#### AlgoliaResult Model
**역할**: Algolia 검색 결과 래핑

**핵심 필드**:
- objectId: String - Algolia 오브젝트 ID
- data: Map<String, dynamic> - 원본 데이터
- highlightResult: Map<String, dynamic> - 하이라이트 결과
- rankingInfo: int? - 랭킹 정보

**변환 메서드**:
- fromSnapshot(): Algolia 스냅샷에서 생성
- toSearchResult(): SearchResult로 변환
- _determineType(): 데이터 기반 타입 결정
- _calculateRelevance(): 관련성 점수 계산

### 2. Repository Interface

#### SearchRepository
**역할**: 데이터 접근 계약 정의

**주요 메서드**:
- `search()`: 통합 검색
  - 파라미터: query (String), filter (SearchFilter?)
  - 반환: Future<List<SearchResult>>
  
- `searchPosts()`: 게시물 검색
  - 파라미터: query (String), filter (SearchFilter?)
  - 반환: Future<List<SearchResult>>
  
- `searchUsers()`: 사용자 검색
  - 파라미터: query (String), limit (int?)
  - 반환: Future<List<SearchResult>>
  
- `searchChats()`: 채팅 검색
  - 파라미터: query (String), userId (String?)
  - 반환: Future<List<SearchResult>>
  
- `saveSearchHistory()`: 검색 기록 저장
  - 파라미터: history (SearchHistory)
  - 반환: Future<void>
  
- `getSearchHistory()`: 검색 기록 조회
  - 파라미터: userId (String), limit (int?)
  - 반환: Future<List<SearchHistory>>
  
- `getSearchHistoryStream()`: 실시간 검색 기록
  - 파라미터: userId (String)
  - 반환: Stream<List<SearchHistory>>
  
- `clearSearchHistory()`: 전체 기록 삭제
  - 파라미터: userId (String)
  - 반환: Future<void>
  
- `deleteSearchHistory()`: 특정 기록 삭제
  - 파라미터: historyId (String)
  - 반환: Future<void>
  
- `getTrendingSearches()`: 인기 검색어
  - 파라미터: limit (int?)
  - 반환: Future<List<String>>
  
- `getSearchSuggestions()`: 검색 제안
  - 파라미터: query (String)
  - 반환: Future<List<String>>

### 3. Use Cases

#### SearchPostsUseCase
**역할**: 게시물 검색 비즈니스 로직

**프로세스**:
1. 검색어 검증 (공백 제거, 길이 확인)
2. 필터 설정 (타입을 post로 고정)
3. Repository 호출
4. 검색 기록 비동기 저장
5. 결과 반환 (Either 패턴)

**검증 규칙**:
- 검색어 필수
- 공백만 있는 검색어 거부

#### SearchUsersUseCase
**역할**: 사용자 검색 비즈니스 로직

**프로세스**:
1. 검색어 길이 검증 (최소 2글자)
2. Repository 호출
3. 결과 제한 적용 (기본 10개)
4. 결과 반환

**검증 규칙**:
- 최소 2글자 이상
- 기본 limit 10개

#### GetSearchHistoryUseCase
**역할**: 검색 기록 조회 및 스트림 제공

**프로세스**:
1. 사용자 인증 확인
2. Repository 스트림 구독
3. 시간순 정렬
4. 개수 제한 적용
5. 에러 처리

**특징**:
- 실시간 업데이트 지원
- 최신순 자동 정렬

#### ClearSearchHistoryUseCase
**역할**: 검색 기록 전체 삭제

**프로세스**:
1. 사용자 인증 확인
2. Repository 호출
3. 성공/실패 반환

**보안**:
- 로그인 사용자만 가능
- 본인 기록만 삭제

## 🔗 의존성

### 외부 패키지
- `equatable: ^2.0.5` - 값 비교
- `dartz: ^0.10.1` - 함수형 프로그래밍 (Either)
- `injectable: ^2.1.0` - 의존성 주입

### 내부 의존성
- 없음 (Domain Layer는 독립적)

## 📊 비즈니스 규칙

### 검색어 규칙
1. 최소 1글자 이상 (게시물/채팅)
2. 최소 2글자 이상 (사용자 검색)
3. 최대 100글자 제한
4. 특수문자 필터링

### 검색 결과 규칙
1. 기본 20개씩 페이지네이션
2. 최대 100개까지 조회 가능
3. 관련성 점수 0.3 이상만 표시
4. 차단된 사용자 제외

### 검색 기록 규칙
1. 사용자당 최대 50개 저장
2. 30일 이상 지난 기록 자동 삭제
3. 중복 검색어는 최신 것만 유지
4. 익명 사용자는 저장 안 함

## ⚠️ 에러 처리

### Failure 타입
**기본 Failure 클래스**:
- message: String - 에러 메시지
- Equatable 상속

**파생 Failure 타입**:
- SearchFailure: 검색 관련 실패
- ValidationFailure: 입력 검증 실패
- AuthFailure: 인증 관련 실패

## ✅ 테스트 전략

### 모델 테스트
- Equatable 동작 검증
- copyWith 메서드 정확성
- 키워드 추출 로직
- 변환 메서드 정확성

### UseCase 테스트
- 성공 케이스 (Right 반환)
- 검증 실패 케이스 (Left 반환)
- Repository 호출 검증
- 에러 처리 동작

### Repository 테스트
- Mock 구현으로 계약 검증
- 메서드 시그니처 준수
- 예외 처리 동작

---

*Domain Layer는 검색 기능의 핵심 비즈니스 로직을 담당합니다.*