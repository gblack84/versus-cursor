# 🔍 Search Feature

> Feature-First Architecture 기반 검색 모듈

## 📋 개요

Search Feature는 포스트, 사용자, 해시태그 검색 기능을 제공합니다.
Algolia를 활용한 고급 검색과 검색 기록 관리를 담당합니다.

## 🏗️ 아키텍처

```
search/
├── data/                  # 데이터 레이어
│   ├── datasources/      # Algolia, Firestore 검색
│   ├── repositories/     # SearchRepository 구현
│   └── services/         # 검색 인덱싱, 필터링
│
├── domain/               # 도메인 레이어
│   ├── models/          # SearchQuery, SearchResult
│   ├── repositories/    # SearchRepository 인터페이스
│   └── usecases/        # 검색 실행, 기록 관리
│
└── presentation/         # 프레젠테이션 레이어
    ├── screens/         # 검색 화면, 결과 화면
    ├── widgets/         # 검색바, 결과 카드
    └── providers/       # SearchProvider 상태 관리
```

## 🎯 주요 기능

### 검색 대상
- **포스트 검색**: 제목, 설명, 해시태그
- **사용자 검색**: 이름, 사용자명
- **해시태그 검색**: 트렌딩 태그

### 검색 기능
- **실시간 검색**: 타이핑 중 즉시 결과
- **자동완성**: 검색어 추천
- **필터링**: 카테고리, 날짜, 인기도
- **검색 기록**: 최근 검색어 저장

### Algolia 통합
- **인덱싱**: 자동 데이터 동기화
- **패싯 검색**: 다중 필터
- **관련성 순위**: AI 기반 정렬

## 📦 의존성

### 전역 레이어 사용
- `backend/algolia`: Algolia 설정
- `core/utils`: 검색 유틸리티
- `services/cache`: 검색 결과 캐싱

### 외부 패키지
```yaml
algolia: ^1.1.1
```

## 🔄 상태 관리

### SearchProvider
```dart
class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<SearchResult> _results = [];
  List<String> _recentSearches = [];
  SearchFilter _filter = SearchFilter();
  
  // 검색어
  String get query => _query;
  
  // 검색 결과
  List<SearchResult> get results => _results;
  
  // 검색 실행
  Future<void> search(String query) async {
    _query = query;
    // Algolia 검색
    final results = await searchRepository.search(query, _filter);
    _results = results;
    notifyListeners();
  }
  
  // 필터 적용
  void applyFilter(SearchFilter filter) {
    _filter = filter;
    if (_query.isNotEmpty) {
      search(_query);
    }
  }
}
```

## 🔀 다른 Feature와의 통신

### Posts Feature 연동
```dart
// 포스트 인덱싱
eventBus.on<PostCreatedEvent>().listen((event) {
  searchService.indexPost(event.post);
});
```

### Profile Feature 연동
```dart
// 사용자 프로필 인덱싱
eventBus.on<ProfileUpdatedEvent>().listen((event) {
  searchService.indexUser(event.profile);
});
```

## 🎨 UI 컴포넌트

### SearchBar
- 실시간 검색어 입력
- 자동완성 드롭다운
- 음성 검색 지원

### SearchResultCard
- 포스트/사용자 미리보기
- 하이라이트된 검색어
- 빠른 액션 버튼

### SearchFilter
- 카테고리 선택
- 날짜 범위
- 정렬 옵션

## 📊 검색 분석

### SearchAnalytics
- 인기 검색어
- 검색 -> 클릭 전환율
- 검색 결과 없음 비율
- 사용자별 검색 패턴

## 📋 API 레퍼런스

### UseCases
- `SearchPostsUseCase`: 포스트 검색
- `SearchUsersUseCase`: 사용자 검색
- `SearchHashtagsUseCase`: 해시태그 검색
- `SaveSearchHistoryUseCase`: 검색 기록 저장
- `GetTrendingSearchesUseCase`: 인기 검색어

### Models
- `SearchQuery`: 검색 쿼리
- `SearchResult`: 검색 결과
- `SearchFilter`: 검색 필터
- `SearchHistory`: 검색 기록

### Services
- `AlgoliaService`: Algolia API 연동
- `SearchIndexService`: 인덱싱 관리
- `SearchCacheService`: 결과 캐싱

## 🧪 테스트

```bash
# 유닛 테스트
flutter test test/features/search/domain/

# 통합 테스트
flutter test test/features/search/integration/

# Algolia 테스트
flutter test test/features/search/algolia/
```

## 📝 변경 이력

### v1.0.0 (2025-08-27)
- Feature-First Architecture 마이그레이션 완료
- Algolia 통합 완료
- 실시간 검색 구현
- 검색 필터 시스템 추가