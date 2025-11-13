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

---

## 🏛️ BOUNDARIES - Clean Architecture 3-Layer 경계

Search Feature는 **Clean Architecture v4.0**의 3-Layer 구조를 따르며, 각 Layer 간 의존성 방향을 엄격히 준수합니다.

### 3-Layer 의존성 규칙

```
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                         │
│  • 의존: Domain Layer (UseCase, Entity, Repository          │
│          Interface)                                          │
│  • 금지: Data Layer, 다른 Feature Presentation               │
│  • 패턴: Riverpod Provider, ConsumerWidget, AsyncValue      │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 의존
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • 의존: 없음 (Pure Dart)                                    │
│  • 금지: Presentation, Data, Flutter SDK, Algolia            │
│  • 패턴: UseCase, Entity (Freezed), Repository Interface    │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 구현
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • 의존: Domain Layer (Entity, Repository Interface)         │
│  • 금지: Presentation Layer                                   │
│  • 패턴: Repository 구현, Algolia SDK 직접 사용              │
└─────────────────────────────────────────────────────────────┘
```

### 실전 예시

#### 1. ✅ Presentation → Domain (올바른 사용)

```dart
// presentation/providers/search_providers.dart
@riverpod
FutureOr<List<SearchResult>> searchPosts(
  SearchPostsRef ref,
  String query,
) async {
  final useCase = getIt<SearchPostsUseCase>();
  final result = await useCase.execute(query: query);

  return result.fold(
    (failure) => throw Exception(failure.getUserMessage()),
    (results) => results,
  );
}

@riverpod
FutureOr<void> saveSearchHistory(
  SaveSearchHistoryRef ref,
  String query,
) async {
  final useCase = getIt<SaveSearchHistoryUseCase>();
  final userId = ref.watch(currentUserIdProvider);

  final result = await useCase.execute(
    userId: userId,
    query: query,
  );

  return result.fold(
    (failure) => throw Exception(failure.getUserMessage()),
    (_) => null,
  );
}
```

#### 2. ✅ Domain → 독립성 (올바른 사용)

```dart
// domain/usecases/search_posts_usecase.dart
class SearchPostsUseCase {
  final ISearchRepository _repository;

  SearchPostsUseCase(this._repository);

  Future<Either<SearchFailure, List<SearchResult>>> execute({
    required String query,
  }) {
    return _repository.searchPosts(query);
  }
}

// domain/usecases/save_search_history_usecase.dart
class SaveSearchHistoryUseCase {
  final ISearchRepository _repository;

  SaveSearchHistoryUseCase(this._repository);

  Future<Either<SearchFailure, void>> execute({
    required String userId,
    required String query,
  }) {
    return _repository.saveSearchHistory(userId, query);
  }
}

// domain/entities/search_result.dart (Freezed)
@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String id,
    required String title,
    required String description,
    required SearchResultType type,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
```

#### 3. ✅ Data → Domain (올바른 사용)

```dart
// data/repositories/search_repository_impl.dart
class SearchRepositoryImpl implements ISearchRepository {
  final AlgoliaManager _algolia;
  final UnifiedCacheService _cacheService;

  @override
  Future<Either<SearchFailure, List<SearchResult>>> searchPosts(
    String query,
  ) async {
    try {
      // ✅ Data Layer는 Algolia SDK 직접 사용 허용
      final algoliaQuery = _algolia.index('posts').query(query);
      final snapshot = await algoliaQuery.getObjects();

      final results = snapshot.hits
          .map((hit) => SearchResult.fromAlgolia(hit))
          .toList();

      return right(results);
    } catch (e) {
      return left(SearchFailure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, void>> saveSearchHistory(
    String userId,
    String query,
  ) async {
    try {
      // ✅ Data Layer는 Firestore 직접 사용 허용
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .add({
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return right(null);
    } catch (e) {
      return left(SearchFailure.serverError(e.toString()));
    }
  }
}
```

#### 4. ❌ 잘못된 사용 패턴

```dart
// ❌ Presentation Layer에서 Algolia 직접 접근
@riverpod
FutureOr<List<SearchResult>> searchPosts(
  SearchPostsRef ref,
  String query,
) async {
  final algoliaQuery = Algolia.init(...).index('posts').query(query);
  final snapshot = await algoliaQuery.getObjects();

  return snapshot.hits.map((hit) => SearchResult.fromAlgolia(hit)).toList();
}

// ❌ Domain Layer에서 Algolia 의존성
class SearchPostsUseCase {
  Future<List<SearchResult>> execute(String query) async {
    final algoliaQuery = Algolia.init(...).index('posts').query(query);
    final snapshot = await algoliaQuery.getObjects();

    return snapshot.hits.map((hit) => SearchResult.fromAlgolia(hit)).toList();
  }
}
```

### Boundary 검증

#### 자동 검증 (Lint)

```bash
# Presentation → Data 위반 검사
grep -r "import.*search.*data" lib/features/search/presentation/

# Domain → Algolia/Firestore 의존성 검사
grep -r "import.*algolia" lib/features/search/domain/
grep -r "import.*firebase" lib/features/search/domain/

# 기대 결과: 발견되지 않아야 함
```

#### 수동 검증 체크리스트

- [ ] Presentation Layer는 UseCase만 호출하는가?
- [ ] Domain Layer는 Pure Dart만 사용하는가? (Algolia/Firebase SDK 없음)
- [ ] Data Layer는 Repository Interface를 구현하는가?
- [ ] GetIt으로 UseCase/Repository를 DI하는가?
- [ ] Either 패턴으로 에러를 반환하는가?

### 참고 문서

- **전체 프로젝트 Boundaries**: `/CLAUDE.md` - "## 🏛 BOUNDARIES" 섹션
- **App Layer Boundaries**: `/lib/app/README.md` - "### 🏛️ BOUNDARIES" 섹션
- **Search Domain Layer**: `domain/README.md` - UseCase, Entity, Failure
- **Search Data Layer**: `data/README.md` - Repository 구현
- **Search Presentation Layer**: `presentation/README.md` - Provider, Widget

---

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

## 🧭 Router 통합 (Navigation)

### Search Feature Routes (Phase 3 준비 완료)

Search Feature는 **Placeholder Routes 구조**를 가지고 있습니다. Phase 3에서 Routes 파일을 생성했으며, 실제 라우트는 Phase 4-5에서 구현 예정입니다.

**파일**: `lib/features/search/presentation/routes/search_routes.dart` (213줄)

### Route 구성 (현재 0개, 3개 예정)

| Route | Path | 상태 | requireAuth | 설명 |
|-------|------|------|-------------|------|
| **SearchResultsPage** | `/search/results` | ⏳ Phase 4-5 | false (PUBLIC) | 검색 결과 상세 페이지 |
| **SearchFilterPage** | `/search/filter` | ⏳ Phase 4-5 | false (PUBLIC) | 검색 필터 설정 |
| **SearchHistoryPage** | `/search/history` | ⏳ Phase 4-5 | true (PRIVATE) | 검색 기록 (로그인 필요) |

### 현재 상태 (Phase 3)

**✅ 완료**:
- Routes 파일 생성 (`search_routes.dart`)
- nav.dart 통합 완료 (`...SearchRoutes.routes(ref)` line 145)
- Type-safe navigation 상수 준비 (주석 처리)
- 상세 문서화 (213줄 인라인 문서)

**⏳ 대기 중**:
- 실제 라우트 구현 (Phase 4-5)
- SearchResultsWidget 생성
- SearchFilterWidget 생성
- SearchHistoryWidget 생성

### nav.dart 통합

**파일**: `/lib/app/router/navigation/nav.dart` (line 145)

```dart
routes: [
  ...SearchRoutes.routes(ref), // 현재 0개, 향후 3개 예정
],
```

### ShellRoute vs Feature Routes

**SearchPageWidget** (하단 네비게이션 검색 탭)은 **ShellRoute**에 있으며, `search_routes.dart`에 포함되지 않습니다:
- 위치: `/lib/app/router/navigation/nav.dart` lines 150-153
- 역할: 항상 표시되는 검색 탭 (하단 네비게이션 바)
- 경로: `/search` (ShellRoute 자식)
- 이유: ShellRoute 페이지는 nav.dart에서 직접 관리 (다른 4개 탭과 동일)

**SearchRoutes에 포함될 라우트**:
- 검색 결과 상세 페이지 (SearchPageWidget 외부)
- 검색 필터 설정 페이지
- 검색 기록 페이지
- 기타 검색 관련 독립 페이지

### 향후 구현 예정 (Phase 4-5)

#### 1. SearchResultsPage (검색 결과 상세)
```dart
AppRoute(
  name: 'searchResults',
  path: '/search/results',
  requireAuth: false,  // PUBLIC (검색은 누구나 가능)
  builder: (context, params) => SearchResultsWidget(
    query: params.getParam('query', ParamType.String),
    filters: params.getParam('filters', ParamType.JSON),
  ),
).toRoute(ref)
```

**기능**:
- 검색어 기반 게시물 필터링
- 실시간 검색 결과 업데이트 (Algolia Stream)
- 무한 스크롤 페이징
- 파라미터: `query` (필수), `filters` (선택)

#### 2. SearchFilterPage (검색 필터 설정)
```dart
AppRoute(
  name: 'searchFilter',
  path: '/search/filter',
  requireAuth: false,  // PUBLIC
  builder: (context, params) => SearchFilterWidget(
    currentFilters: params.getParam('currentFilters', ParamType.JSON),
  ),
).toRoute(ref)
```

**기능**:
- 카테고리, 날짜 범위, 정렬 방식 설정
- 필터 프리셋 저장 (로그인 사용자만)
- 파라미터: `currentFilters` (JSON)

#### 3. SearchHistoryPage (검색 기록)
```dart
AppRoute(
  name: 'searchHistory',
  path: '/search/history',
  requireAuth: true,  // 로그인 필요 (개인 기록)
  builder: (context, params) => const SearchHistoryWidget(),
).toRoute(ref)
```

**기능**:
- 사용자별 검색 기록 (Firestore 저장)
- 최근 검색어, 인기 검색어
- 기록 삭제 기능

### 구현 가이드 (Phase 4-5)

**Step 1**: 위젯 생성
```bash
# 검색 결과 페이지 생성
touch lib/features/search/presentation/screens/results/search_results_widget.dart
```

**Step 2**: routes() 메서드에 추가
```dart
static List<GoRoute> routes(WidgetRef ref) => [
  // 빈 리스트에서 실제 라우트 추가
  AppRoute(
    name: SearchResultsWidget.routeName,
    path: SearchResultsWidget.routePath,
    requireAuth: false,
    builder: (context, params) => SearchResultsWidget(
      query: params.getParam('query', ParamType.String),
    ),
  ).toRoute(ref),
];
```

**Step 3**: Type-safe navigation 상수 활성화
```dart
// 주석 제거
static String get searchResults => SearchResultsWidget.routeName;
static String get searchResultsPath => SearchResultsWidget.routePath;
```

**Step 4**: 사용
```dart
context.goNamed(
  SearchRoutes.searchResults,
  queryParameters: {'query': searchQuery},
);
```

### Public vs Private

Search Feature 라우트는 **대부분 PUBLIC** 권장:
- **SearchResultsPage**: requireAuth: false (비로그인 사용자도 검색 가능)
- **SearchFilterPage**: requireAuth: false (필터 설정도 public)
- **SearchHistoryPage**: requireAuth: true (개인 기록만 private)

**근거**:
- 사용자 획득: 검색 기능을 먼저 경험 → 회원가입 유도
- SEO: 검색 결과 페이지 크롤링 가능
- 공유: 검색 링크 공유 시 로그인 불필요

### 애니메이션

Search Feature 라우트는 **즉시 전환** (Duration.zero) 권장:
- 검색은 빈번한 이동 → 애니메이션 불필요
- AppRoute 패턴 기본 동작: NoTransitionPage

**단, SearchResultsPage는 Slide 애니메이션 고려 가능**:
- 사용자가 검색 → 결과 전환의 명확한 피드백
- 300ms Slide (왼쪽에서 오른쪽)

### 참조 문서

- [search/README.md](../README.md) - Search Feature 전체 가이드 (312줄)
- [search_routes.dart](./presentation/routes/search_routes.dart) - Routes 인라인 문서 (213줄)
- [/lib/app/router/README.md](/lib/app/router/README.md) - Router 시스템 개요
- [/lib/app/router/navigation/README.md](/lib/app/router/navigation/README.md) - Navigation 상세 가이드
- [PHASE_1_EITHER_PATTERN.md](./PHASE_1_EITHER_PATTERN.md) - Search Phase 1 완료
- [PHASE_2_RIVERPOD.md](./PHASE_2_RIVERPOD.md) - Search Phase 2 완료
- [PHASE_3_CACHE_INTEGRATION.md](./PHASE_3_CACHE_INTEGRATION.md) - Cache 통합 계획

### Phase 진행 상황

**Phase 완료**:
- ✅ Phase 1: Either Pattern (SearchFailure, Repository Interface)
- ✅ Phase 2: Riverpod 3.x (search_providers.dart 255줄)
- ✅ Phase 3: **Router 준비** (search_routes.dart 생성, nav.dart 통합)

**Phase 대기**:
- ⏳ Phase 4: Idempotency + Route 구현
- ⏳ Phase 5: Extension Pattern + Cache 통합

---

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