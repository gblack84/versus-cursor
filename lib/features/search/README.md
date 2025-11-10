# 🔍 Search Feature

> Feature-First Architecture 기반 검색 모듈

## 📋 개요

Search Feature는 포스트, 사용자, 해시태그 검색 기능을 제공합니다.
Algolia를 활용한 고급 검색과 검색 기록 관리를 담당합니다.

## 🏗️ 아키텍처

```
search/
├── data/                  # 데이터 레이어
│   ├── adapters/         # Algolia serialization (serialization_util.dart)
│   ├── datasources/      # Algolia, Firestore 검색
│   ├── repositories/     # SearchRepository 구현
│   ├── services/         # 검색 인덱싱, 필터링
│   └── utils/            # Algolia 변환 유틸리티 (algolia_converters.dart) ✨ NEW
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

### 🔥 Algolia Converters (2025-11-10)

**Migration**: `/lib/core/firebase/utils/schema_util.dart` → `/lib/features/search/data/utils/algolia_converters.dart`

**Why This Change?**
- ❌ **Before**: Core importing from Feature (architecture violation)
- ✅ **After**: Feature owns its conversion logic (Clean Architecture compliant)

**What Was Moved?**
- `convertAlgoliaStruct()` - Algolia search result → app struct 변환
- `convertAlgoliaParam()` - Algolia parameter 타입 변환
- `getStructList()`, `getColorsList()`, `getDataList()` - 리스트 추출 헬퍼
- `StructBuilder<T>` typedef, `BaseStruct` abstract class

**Usage Example**:
```dart
// lib/features/search/data/repositories/search_repository_impl.dart

import '../utils/algolia_converters.dart';

class SearchRepositoryImpl {
  Future<List<Post>> searchPosts(String query) async {
    final snapshot = await _algolia.index('posts').search(query).getObjects();

    // Algolia 결과 → Post 엔티티 변환
    final posts = snapshot.hits.map((hit) {
      return convertAlgoliaStruct<Post>(
        hit.data,
        ParamType.DataStruct,
        false,
        structBuilder: (data) => Post.fromAlgolia(data),
      );
    }).whereType<Post>().toList();

    return posts;
  }
}
```

**Related Documentation**:
- [Algolia Converters README](./data/utils/README.md) - 상세 사용법 및 API 레퍼런스
- [Core Firebase README](/lib/core/firebase/README.md) - Generic 유틸리티
- [Services Firebase README](/lib/services/firebase/README.md) - Legacy 패턴

## ✅ Structure Cleanup Status (2025-01-20)

**현재 상태**: 기본 스켈레톤 구조 완료, 실제 구현 대기중

### 완료 항목
- [x] Clean Architecture v4.0 디렉토리 구조
- [x] 4개 Domain Models 스켈레톤 (SearchQuery, SearchFilter, SearchResult, AlgoliaResult)
- [x] SearchProvider 기본 구조 (상태 관리 프레임워크)
- [x] DI 등록 (Repository Singleton, Provider Factory)

### 구현 필요 항목 (31 TODO)

#### Domain Layer (9개)
- **UseCases** (5개):
  - SearchPostsUseCase
  - SearchUsersUseCase
  - SearchHashtagsUseCase
  - SaveSearchHistoryUseCase
  - GetTrendingSearchesUseCase

- **Models JSON Serialization** (4개):
  - SearchQuery.toJson/fromJson
  - SearchFilter.toJson/fromJson
  - SearchResult.toJson/fromJson
  - AlgoliaResult.fromJson

#### Data Layer (7개)
- **DataSources** (3개):
  - AlgoliaDataSource (Algolia API 통합)
  - FirestoreSearchDataSource (Firestore 쿼리)
  - LocalSearchDataSource (로컬 검색 기록)

- **Services/Adapters** (4개):
  - SearchIndexService (인덱싱 관리)
  - SearchCacheService (결과 캐싱)
  - SearchFilterService (필터 처리)
  - SearchAnalyticsService (분석)

#### Presentation Layer (15개)
- **Provider** (1개):
  - SearchProvider에 UseCases 통합

- **Screens** (3개):
  - SearchPageWidget (기본 Scaffold만 존재)
  - SearchResultsWidget
  - TrendingSearchesWidget

- **Widgets** (11개):
  - SearchBarWidget
  - SearchResultCardWidget
  - SearchFilterWidget
  - RecentSearchesWidget
  - TrendingTagsWidget
  - SearchSuggestionsWidget
  - NoResultsWidget
  - SearchLoadingWidget
  - SearchErrorWidget
  - FilterChipWidget
  - SortOptionsWidget

### 기술 노트
- `SearchRepositoryImpl`: Singleton 패턴 사용 (private constructor)
- SearchHistoryModel: 이미 구현 완료 (115줄)
- AlgoliaManager: 이미 구현 완료 (90줄)
- ChatSearchBar: 이미 구현 완료 (314줄, Chat Feature에서 사용)

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
- `core/firebase`: Generic Firestore 유틸리티 (`safeGet`, `toRef`)
- `services/cache`: 검색 결과 캐싱

### 외부 패키지
```yaml
algolia: ^1.1.1
from_css_color: ^2.0.0    # CSS 색상 파싱 (Algolia 변환용)
```

### Feature 내부 의존성
- `data/utils/algolia_converters.dart`: Algolia 검색 결과 변환
- `data/adapters/serialization_util.dart`: Algolia 직렬화

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

### v0.2.0 (2025-11-10) - Algolia Converters Migration
- **Architecture Fix**: `schema_util.dart` → `algolia_converters.dart`
  - Core → Feature 역방향 의존성 제거 (Clean Architecture 준수)
  - Algolia-specific 로직을 Feature Data Layer로 이동
  - 포괄적인 README.md 작성 (1,000+ 줄)
- **Documentation**: data/utils/README.md 추가
  - Algolia 변환 API 레퍼런스
  - 사용 예시 및 Best Practices
  - 마이그레이션 가이드

### v0.1.0 (2025-01-20) - Structure Cleanup
- Clean Architecture v4.0 구조 확립
- 4개 Domain Models 스켈레톤 생성
- SearchProvider 기본 구조 구현
- DI 등록 완료 (Singleton Repository, Factory Provider)
- 31개 TODO 항목 문서화

### v1.0.0 (예정)
- Feature-First Architecture 마이그레이션 완료 예정
- Algolia 통합 예정
- 실시간 검색 구현 예정
- 검색 필터 시스템 추가 예정