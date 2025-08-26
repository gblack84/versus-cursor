# 📂 Search Feature - Presentation Layer

> 검색 기능의 UI 컴포넌트와 상태 관리를 담당하는 레이어

## 📋 개요

Presentation Layer는 검색 기능의 모든 UI 요소와 사용자 상호작용을 관리합니다. Provider 패턴을 사용한 상태 관리와 재사용 가능한 위젯으로 구성됩니다.

## 🏗️ 구조

```
presentation/
├── screens/                  # 화면
│   ├── search_page/         # 메인 검색 화면
│   │   ├── search_page_widget.dart
│   │   └── search_page_model.dart
│   │
│   ├── search_results/      # 검색 결과 화면
│   │   ├── search_results_widget.dart
│   │   └── search_results_model.dart
│   │
│   └── chat_search/         # 채팅 검색 화면
│       ├── chat_search_widget.dart
│       └── chat_search_model.dart
│
├── widgets/                  # 재사용 위젯
│   ├── search_bar/          # 검색바 컴포넌트
│   │   ├── search_bar_widget.dart
│   │   ├── search_suggestions.dart
│   │   └── search_filters.dart
│   │
│   ├── search_results/      # 검색 결과 표시
│   │   ├── search_result_item.dart
│   │   ├── search_result_list.dart
│   │   ├── search_result_grid.dart
│   │   └── search_empty_state.dart
│   │
│   ├── search_history/      # 검색 기록
│   │   ├── search_history_list.dart
│   │   └── search_history_item.dart
│   │
│   └── search_loading.dart  # 검색 로딩 표시
│
├── providers/               # 상태 관리
│   ├── search_provider.dart         # 검색 상태 관리
│   ├── search_filter_provider.dart  # 필터 상태 관리
│   └── search_history_provider.dart # 기록 상태 관리
│
└── constants/               # 상수
    ├── search_constraints.dart       # 검색 제약사항
    ├── search_strings.dart           # 검색 문자열
    └── algolia_config.dart          # Algolia 설정
```

## 📦 주요 컴포넌트

### 1. Screens

#### SearchPageWidget
**역할**: 메인 검색 화면 구현

**라우팅 정보**:
- routeName: 'search_page'
- routePath: '/search'

**주요 구성요소**:
- SearchBarWidget - 검색 입력
- SearchResultsList - 결과 표시
- SearchHistoryList - 기록 표시
- SearchEmptyState - 빈 상태

**상태 관리**:
- SearchPageModel 사용
- Consumer<SearchProvider> 패턴
- 디바운싱 검색 (500ms)

#### SearchPageModel
**역할**: 검색 페이지 비즈니스 로직

**주요 기능**:
- 검색 실행 및 기록 저장
- 자동완성 제안 관리
- 텍스트 입력 디바운싱
- Provider 조정

**의존성**:
- SearchProvider
- SearchHistoryProvider
- GetIt 의존성 주입

#### ChatSearchWidget
**역할**: 채팅 내 검색 기능

**Props**:
- chatId: String? - 특정 채팅방 ID

**특징**:
- 독립적인 검색 UI
- 44px 높이 고정
- 둥근 검색바 디자인
- Clear 버튼 자동 표시

### 2. Widgets

#### SearchBarWidget
**역할**: 재사용 가능한 검색바

**Props**:
- onSearch: Function(String) - 검색 실행 콜백
- onFilterTap: VoidCallback? - 필터 버튼 콜백
- suggestions: List<String>? - 자동완성 제안

**UI 사양**:
- 48px 높이
- 24px 둥근 모서리
- 검색 아이콘 (prefix)
- 필터 버튼 (optional suffix)

#### SearchResultItem
**역할**: 개별 검색 결과 표시

**Props**:
- result: SearchResult - 결과 데이터
- onTap: VoidCallback? - 탭 콜백

**표시 요소**:
- 60x60 썸네일 이미지
- 타입 배지 (색상 구분)
- 제목 (1줄)
- 설명 (2줄)

**타입별 색상**:
- post: 파란색
- user: 초록색
- chat: 주황색
- 기타: 회색

#### SearchEmptyState
**역할**: 검색 결과 없음 표시

**Props**:
- query: String - 검색한 쿼리
- onRetry: VoidCallback? - 재시도 콜백

**표시 요소**:
- 64px 검색 오프 아이콘
- 검색어 포함 메시지
- 재시도 버튼 (선택적)

### 3. Providers

#### SearchProvider
**역할**: 메인 검색 상태 관리

**상태 필드**:
- searchResults: List<SearchResult> - 검색 결과
- query: String - 현재 검색어
- isSearching: bool - 검색 중 여부
- filter: SearchFilter - 적용된 필터
- error: String? - 에러 메시지

**주요 메서드**:
- search(String query): 검색 실행
- updateFilter(SearchFilter): 필터 업데이트
- loadMore(): 페이지네이션
- clearSearch(): 검색 초기화

**의존성**:
- SearchPostsUseCase
- SearchUsersUseCase

#### SearchHistoryProvider
**역할**: 검색 기록 상태 관리

**상태 필드**:
- searchHistory: List<SearchHistory> - 검색 기록
- recentQueries: List<String> - 최근 검색어

**주요 메서드**:
- loadHistory(): 기록 로드
- addToHistory(String): 기록 추가
- clearHistory(): 기록 삭제

**특징**:
- Stream 구독 관리
- 중복 제거
- 최근 10개 제한

### 4. Constants

#### SearchConstraints
**검색어 제약**:
- minQueryLength: 1
- maxQueryLength: 100
- minUserQueryLength: 2

**결과 제약**:
- defaultPageSize: 20
- maxPageSize: 100
- minRelevanceScore: 0.3

**검색 기록**:
- maxHistoryItems: 50
- historyRetentionDays: 30

**캐싱**:
- cacheTimeout: 5분
- maxCacheItems: 100

#### SearchStrings
**화면 제목**:
- searchPageTitle: '검색'
- searchResultsTitle: '검색 결과'

**플레이스홀더**:
- searchPlaceholder: '검색어를 입력하세요'
- chatSearchPlaceholder: '채팅에서 검색...'

**빈 상태**:
- emptyResultsTitle: '검색 결과가 없습니다'
- emptyResultsMessage: '다른 검색어로 시도해보세요'

**에러 메시지**:
- searchError: '검색 중 오류가 발생했습니다'
- networkError: '네트워크 연결을 확인해주세요'
- minLengthError: '최소 {min}글자 이상 입력해주세요'

**버튼**:
- retryButton: '다시 시도'
- clearHistoryButton: '기록 지우기'
- filterButton: '필터'

## 🎨 UI/UX 가이드라인

### 디자인 원칙
1. **즉각적 피드백**: 검색 중 로딩 표시
2. **자동완성**: 500ms 디바운스로 제안 표시
3. **검색 기록**: 최근 10개 표시
4. **무한 스크롤**: 자동 더 불러오기

### 접근성
- 모든 인터랙티브 요소에 semanticLabel 추가
- 키보드 네비게이션 지원
- 충분한 터치 영역 (최소 44x44)

### 반응형 디자인
- 태블릿: 그리드 뷰로 전환
- 가로 모드: 2열 레이아웃
- 다크 모드 지원

## ✅ 테스트 전략

### Widget 테스트
**테스트 범위**:
- SearchBarWidget: 텍스트 입력 및 제출
- SearchResultItem: 데이터 표시 정확성
- SearchEmptyState: 빈 상태 렌더링
- 사용자 상호작용 이벤트

### Provider 테스트
**테스트 범위**:
- 검색 실행 및 결과 업데이트
- 필터 적용 및 재검색
- 페이지네이션 동작
- 에러 처리 시나리오

### 통합 테스트
**테스트 시나리오**:
- 전체 검색 플로우
- 검색 기록 저장 및 조회
- 필터 적용 후 검색
- 네트워크 오류 처리

---

*Presentation Layer는 검색 기능의 사용자 인터페이스를 담당합니다.*