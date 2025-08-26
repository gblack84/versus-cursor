# 📂 Search Providers

> 검색 기능의 상태 관리 레이어

## 📋 개요

Providers는 검색 기능의 상태 관리를 담당합니다. Provider 패턴을 사용하여 위젯 트리 전체에서 상태를 공유하고 관리합니다.

## 🎯 Provider 설계 원칙

### 핵심 원칙
- **단일 책임**: 하나의 Provider = 하나의 도메인 상태
- **불변성**: 상태 변경은 새로운 객체 생성
- **반응성**: 상태 변경 시 자동 UI 업데이트
- **테스트 가능성**: 비즈니스 로직과 UI 분리
- **성능 최적화**: 필요한 부분만 리빌드

### Provider가 하는 일
- 상태 관리 및 업데이트
- UseCase 호출 조정
- 에러 처리
- 로딩 상태 관리
- 캐싱 관리

### Provider가 하지 않는 일
- 직접적인 API 호출
- 복잡한 비즈니스 로직
- UI 렌더링
- 네비게이션 결정

## 📁 파일 구조

```
providers/
├── search_provider.dart         # 메인 검색 상태 관리
├── search_filter_provider.dart  # 필터 상태 관리
├── search_history_provider.dart # 검색 기록 상태 관리
├── search_suggestions_provider.dart # 검색 제안 상태 관리
└── search_state.dart            # 검색 상태 모델
```

## 💻 Provider 사양

### SearchState (상태 모델)

**상태 타입:**
- `SearchInitial`: 초기 상태
- `SearchLoading`: 검색 중 상태 (query 포함)
- `SearchSuccess`: 검색 성공 (results, filter, hasMore, totalCount)
- `SearchError`: 검색 실패 (message, code)
- `SearchEmpty`: 검색 결과 없음

**SearchSuccess 필드:**
- query: String - 검색어
- results: List<SearchResult> - 검색 결과
- filter: SearchFilter? - 적용된 필터
- hasMore: bool - 추가 결과 존재 여부
- totalCount: int - 전체 결과 개수

### SearchProvider

**주요 기능:**
- 통합 검색 관리
- 페이지네이션 처리
- 검색 결과 캐싱
- 에러 처리

**주요 메서드:**
- `search(String query, SearchFilter? filter)`: 새로운 검색
- `loadMore()`: 추가 결과 로드
- `clearResults()`: 결과 초기화
- `applyFilter(SearchFilter filter)`: 필터 적용
- `retry()`: 실패한 검색 재시도

**내부 상태:**
- currentQuery: String?
- currentFilter: SearchFilter?
- currentPage: int
- isLoadingMore: bool
- cachedResults: Map<String, List<SearchResult>>

### SearchFilterProvider

**필터 상태 관리:**
- 선택된 타입 (posts, users, chats, all)
- 날짜 범위 (시작일, 종료일)
- 카테고리 목록
- 정렬 옵션 (관련성, 최신순, 인기순)
- 최소 관련성 점수

**주요 메서드:**
- `updateType(SearchResultType? type)`: 타입 변경
- `setDateRange(DateTime? start, DateTime? end)`: 날짜 설정
- `toggleCategory(String category)`: 카테고리 토글
- `setSortBy(SortOption option)`: 정렬 변경
- `resetFilters()`: 필터 초기화
- `getActiveFilter()`: 현재 필터 객체 반환

### SearchHistoryProvider

**기록 관리:**
- 최근 검색어 목록
- 검색 빈도 추적
- 개인화된 제안

**주요 메서드:**
- `loadHistory()`: 검색 기록 로드
- `addToHistory(String query)`: 기록 추가
- `removeFromHistory(String query)`: 특정 기록 삭제
- `clearHistory()`: 전체 기록 삭제
- `getRecentSearches(int limit)`: 최근 검색어 조회
- `getMostSearched(int limit)`: 자주 검색한 키워드

**상태 필드:**
- recentSearches: List<SearchHistory>
- isLoading: bool
- error: String?

### SearchSuggestionsProvider

**제안 기능:**
- 자동완성 제안
- 인기 검색어
- 관련 검색어

**주요 메서드:**
- `getSuggestions(String query)`: 입력 기반 제안
- `getTrendingSearches()`: 인기 검색어
- `getRelatedSearches(String query)`: 관련 검색어
- `refreshTrending()`: 인기 검색어 새로고침

**캐싱 전략:**
- 제안 결과 5분 캐싱
- 인기 검색어 30분 캐싱
- 관련 검색어 10분 캐싱

## 🔄 Provider 간 상호작용

### 의존 관계
```
SearchProvider (메인)
├── SearchFilterProvider (필터 상태)
├── SearchHistoryProvider (기록 관리)
└── SearchSuggestionsProvider (제안)
```

### 이벤트 플로우
1. 사용자 검색어 입력
2. SearchSuggestionsProvider → 제안 표시
3. 검색 실행 → SearchProvider
4. SearchHistoryProvider → 기록 저장
5. SearchFilterProvider → 필터 적용
6. UI 업데이트

## 🧪 테스트 전략

### Provider 테스트

**단위 테스트:**
- 상태 변경 테스트
- UseCase 호출 검증
- 에러 처리 테스트
- 캐싱 동작 검증

**통합 테스트:**
- Provider 간 상호작용
- 전체 검색 플로우
- 필터 적용 시나리오

### Mock 설정
- MockUseCase 생성
- 가짜 상태 생성
- 이벤트 시뮬레이션

## 🏗️ 의존성 주입

### Provider 등록
```
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SearchProvider()),
    ChangeNotifierProvider(create: (_) => SearchFilterProvider()),
    ChangeNotifierProvider(create: (_) => SearchHistoryProvider()),
    ChangeNotifierProvider(create: (_) => SearchSuggestionsProvider()),
  ],
)
```

### UseCase 주입
- GetIt을 통한 UseCase 주입
- Provider 생성자에서 수신
- 의존성 체인 관리

## 📊 성능 최적화

### 최적화 전략

**선택적 리빌드:**
- Selector 위젯 활용
- Consumer 범위 최소화
- 불필요한 리빌드 방지

**상태 분리:**
- 독립적인 상태는 별도 Provider
- 자주 변경되는 상태 격리
- 무거운 연산 결과 캐싱

**메모리 관리:**
- 사용하지 않는 상태 정리
- 캐시 크기 제한
- 약한 참조 활용

## 🎯 설계 고려사항

### 1. 상태 불변성
- 모든 상태는 불변 객체
- copyWith 패턴 사용
- 깊은 복사 보장

### 2. 에러 처리
- 모든 에러 상태 정의
- 사용자 친화적 메시지
- 재시도 메커니즘

### 3. 성능
- 데바운싱 적용
- 캐싱 전략
- 페이지네이션

### 4. 확장성
- 새로운 상태 추가 용이
- Provider 조합 가능
- 테스트 용이성

## 📝 마이그레이션 체크리스트

- [ ] State 모델 정의
  - [ ] SearchState 기본 클래스
  - [ ] 각 상태별 클래스
  - [ ] Equatable 구현
- [ ] Provider 구현
  - [ ] SearchProvider
  - [ ] SearchFilterProvider
  - [ ] SearchHistoryProvider
  - [ ] SearchSuggestionsProvider
- [ ] UseCase 연결
  - [ ] 의존성 주입 설정
  - [ ] UseCase 호출 구현
  - [ ] 에러 처리
- [ ] 캐싱 구현
  - [ ] 메모리 캐시
  - [ ] 캐시 무효화 전략
  - [ ] TTL 설정
- [ ] 테스트 작성
  - [ ] 각 Provider별 단위 테스트
  - [ ] 통합 테스트
  - [ ] 성능 테스트

---

*Providers는 검색 기능의 상태를 관리하고 UI와 비즈니스 로직을 연결합니다.*