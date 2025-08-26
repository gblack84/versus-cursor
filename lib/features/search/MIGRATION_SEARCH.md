# 📦 /lib/features/search 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Search Feature 독립 모듈  
> 최종 업데이트: 2025-08-25 | 문서화 100% 완료

## 🎯 목적

검색 관련 모든 기능을 `/lib/features/search` 폴더로 통합하여 독립적이고 재사용 가능한 검색 모듈을 구성합니다.

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 검색 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 검색 유틸리티 | Import 경로 변경 |
| **FF 접두사 제거** | 검색 위젯 | `FFSearchWidget` → `AppSearchWidget` |
| **AppTheme 통합** | 검색 UI 테마 | `AppTheme.of(context)` 사용 |

### Import 변경 예시
```dart
// Before (FlutterFlow)
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_algolia_search.dart';

// After (Native Flutter)
import '/core/app_theme.dart';
import '/core/utils/algolia_search.dart';
```

## 📚 하위 디렉토리 문서

모든 하위 디렉토리에 상세한 README 문서가 작성되었습니다:

### Data Layer 문서
- 📄 [data/datasources/README.md](./data/datasources/README.md) - 데이터 소스 구현체
- 📄 [data/repositories/README.md](./data/repositories/README.md) - 리포지토리 구현
- 📄 [data/services/README.md](./data/services/README.md) - 서비스 레이어

### Domain Layer 문서  
- 📄 [domain/models/README.md](./domain/models/README.md) - 도메인 모델 정의
- 📄 [domain/repositories/README.md](./domain/repositories/README.md) - 리포지토리 인터페이스
- 📄 [domain/usecases/README.md](./domain/usecases/README.md) - 비즈니스 로직

### Presentation Layer 문서
- 📄 [presentation/screens/README.md](./presentation/screens/README.md) - 화면 컴포넌트
- 📄 [presentation/widgets/README.md](./presentation/widgets/README.md) - 재사용 위젯
- 📄 [presentation/providers/README.md](./presentation/providers/README.md) - 상태 관리

## 📋 현재 상태 분석

### 검색 관련 파일 현황
| 디렉토리/파일 | 파일 수 | 설명 | 영향도 |
|--------------|---------|------|--------|
| `/lib/backend/algolia/` | 2개 | Algolia 검색 엔진 통합 | 매우 높음 |
| `/lib/pages/search/` | 1개 | 검색 페이지 UI | 높음 |
| `/lib/pages/chat/chat_search/` | 1개 | 채팅 검색 UI | 중간 |
| `/lib/backend/schema/searches_model.dart` | 1개 | 검색 기록 모델 | 높음 |
| **총합** | **5개** | **검색 관련 파일** | - |

### 🔄 Core/App 마이그레이션 의존성
기존 FlutterFlow 마이그레이션으로 인한 영향:
- `FFAppState` → `AppState` 변경
- `flutter_flow/` → `core/` 폴더 구조 변경
- `FFLocalizations` → `AppLocalizations` 변경
- 모든 FF 접두사가 App 접두사로 변경됨

## 🏗️ Feature-First 구조 매핑

```
/lib/features/search/
├── data/                          # 데이터 레이어
│   ├── datasources/              # 데이터 소스
│   │   ├── algolia_datasource.dart        # Algolia API 통신
│   │   ├── local_search_datasource.dart   # 로컬 검색 캐싱
│   │   └── firestore_search_datasource.dart # Firestore 검색
│   │
│   ├── repositories/             # 리포지토리 구현
│   │   └── search_repository_impl.dart    # 검색 리포지토리 구현체
│   │
│   └── services/                 # 검색 서비스
│       ├── algolia_manager.dart          # Algolia 매니저 (기존)
│       ├── search_cache_service.dart     # 검색 결과 캐싱
│       ├── search_history_service.dart   # 검색 기록 관리
│       └── search_filter_service.dart    # 검색 필터 처리
│
├── domain/                       # 도메인 레이어
│   ├── models/                  # 도메인 모델
│   │   ├── search_result_model.dart      # 검색 결과 모델
│   │   ├── search_filter_model.dart      # 검색 필터 모델
│   │   ├── search_history_model.dart     # 검색 기록 모델
│   │   ├── search_query_model.dart       # 검색 쿼리 모델
│   │   └── algolia_result_model.dart     # Algolia 결과 모델
│   │
│   ├── repositories/            # 리포지토리 인터페이스
│   │   └── search_repository.dart        # 검색 리포지토리 추상화
│   │
│   └── usecases/                # 유스케이스
│       ├── search_posts_usecase.dart     # 게시물 검색
│       ├── search_users_usecase.dart     # 사용자 검색
│       ├── search_chats_usecase.dart     # 채팅 검색
│       ├── get_search_history_usecase.dart # 검색 기록 조회
│       ├── clear_search_history_usecase.dart # 검색 기록 삭제
│       └── save_search_query_usecase.dart   # 검색어 저장
│
└── presentation/                 # 프레젠테이션 레이어
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

## 📁 상세 파일 이동 계획

### Phase 0: 준비 작업

```bash
# 현재 상태 저장
git add .
git commit -m "chore: save current state before search migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/search-migration

# 디렉토리 구조 생성
mkdir -p lib/features/search/data/{datasources,repositories,services}
mkdir -p lib/features/search/domain/{models,repositories,usecases}
mkdir -p lib/features/search/presentation/{screens,widgets,providers,constants}
mkdir -p lib/features/search/presentation/screens/{search_page,search_results,chat_search}
mkdir -p lib/features/search/presentation/widgets/{search_bar,search_results,search_history}
```

### Phase 1: Services 이동 (data/services/)

```bash
# Algolia 서비스 이동
git mv lib/backend/algolia/algolia_manager.dart lib/features/search/data/services/
git mv lib/backend/algolia/serialization_util.dart lib/features/search/data/services/

# 새로 생성할 서비스
echo "// TODO: Implement search cache service" > lib/features/search/data/services/search_cache_service.dart
echo "// TODO: Implement search history service" > lib/features/search/data/services/search_history_service.dart
echo "// TODO: Implement search filter service" > lib/features/search/data/services/search_filter_service.dart

# 커밋
git add .
git commit -m "feat(search): migrate services to feature module"
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 검색 모델 이동
git mv lib/backend/schema/searches_model.dart lib/features/search/domain/models/search_history_model.dart

# 새로 생성할 모델
echo "// TODO: Implement search result model" > lib/features/search/domain/models/search_result_model.dart
echo "// TODO: Implement search filter model" > lib/features/search/domain/models/search_filter_model.dart
echo "// TODO: Implement search query model" > lib/features/search/domain/models/search_query_model.dart
echo "// TODO: Implement algolia result model" > lib/features/search/domain/models/algolia_result_model.dart

# 커밋
git add .
git commit -m "feat(search): migrate models to domain layer"
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 검색 페이지 이동
git mv lib/pages/search/search_page_widget.dart lib/features/search/presentation/screens/search_page/
echo "// TODO: Implement search page model" > lib/features/search/presentation/screens/search_page/search_page_model.dart

# 채팅 검색 이동
git mv lib/pages/chat/chat_search/chat_search_widget.dart lib/features/search/presentation/screens/chat_search/
echo "// TODO: Implement chat search model" > lib/features/search/presentation/screens/chat_search/chat_search_model.dart

# 검색 결과 화면 생성
echo "// TODO: Implement search results widget" > lib/features/search/presentation/screens/search_results/search_results_widget.dart
echo "// TODO: Implement search results model" > lib/features/search/presentation/screens/search_results/search_results_model.dart

# 테스트 코드 이동 (선택적)
mkdir -p lib/features/search/test/widget_test
git mv lib/etc/testalgoria/testalgoria_widget.dart lib/features/search/test/widget_test/algolia_test_widget.dart
git mv lib/etc/testalgoria/testalgoria_model.dart lib/features/search/test/widget_test/algolia_test_model.dart

# 커밋
git add .
git commit -m "feat(search): migrate screens to presentation layer"
```

### Phase 4: Widgets 생성 (presentation/widgets/)

```bash
# 검색바 컴포넌트 이동
git mv lib/pages/chat/chat_detail_v2/components/chat_search_bar.dart lib/features/search/presentation/widgets/search_bar/search_bar_widget.dart

# 위젯 생성
echo "// TODO: Implement search suggestions" > lib/features/search/presentation/widgets/search_bar/search_suggestions.dart
echo "// TODO: Implement search filters" > lib/features/search/presentation/widgets/search_bar/search_filters.dart
echo "// TODO: Implement search result item" > lib/features/search/presentation/widgets/search_results/search_result_item.dart
echo "// TODO: Implement search result list" > lib/features/search/presentation/widgets/search_results/search_result_list.dart
echo "// TODO: Implement search result grid" > lib/features/search/presentation/widgets/search_results/search_result_grid.dart
echo "// TODO: Implement search empty state" > lib/features/search/presentation/widgets/search_results/search_empty_state.dart
echo "// TODO: Implement highlight text" > lib/features/search/presentation/widgets/search_results/highlight_text.dart
echo "// TODO: Implement search history list" > lib/features/search/presentation/widgets/search_history/search_history_list.dart
echo "// TODO: Implement search history item" > lib/features/search/presentation/widgets/search_history/search_history_item.dart
echo "// TODO: Implement search loading" > lib/features/search/presentation/widgets/search_loading.dart

# 커밋
git add .
git commit -m "feat(search): create reusable widgets"
```

### Phase 5: Repository 및 UseCases 생성

```bash
# Datasources 생성
echo "// TODO: Implement algolia datasource" > lib/features/search/data/datasources/algolia_datasource.dart
echo "// TODO: Implement local search datasource" > lib/features/search/data/datasources/local_search_datasource.dart
echo "// TODO: Implement firestore search datasource" > lib/features/search/data/datasources/firestore_search_datasource.dart

# Repository 생성
echo "// TODO: Implement search repository interface" > lib/features/search/domain/repositories/search_repository.dart
echo "// TODO: Implement search repository" > lib/features/search/data/repositories/search_repository_impl.dart

# UseCases 생성
echo "// TODO: Implement search posts usecase" > lib/features/search/domain/usecases/search_posts_usecase.dart
echo "// TODO: Implement search users usecase" > lib/features/search/domain/usecases/search_users_usecase.dart
echo "// TODO: Implement search chats usecase" > lib/features/search/domain/usecases/search_chats_usecase.dart
echo "// TODO: Implement get search history usecase" > lib/features/search/domain/usecases/get_search_history_usecase.dart
echo "// TODO: Implement clear search history usecase" > lib/features/search/domain/usecases/clear_search_history_usecase.dart
echo "// TODO: Implement save search query usecase" > lib/features/search/domain/usecases/save_search_query_usecase.dart

# Providers 생성
echo "// TODO: Implement search provider" > lib/features/search/presentation/providers/search_provider.dart
echo "// TODO: Implement search history provider" > lib/features/search/presentation/providers/search_history_provider.dart
echo "// TODO: Implement search filter provider" > lib/features/search/presentation/providers/search_filter_provider.dart

# Constants 생성
echo "// TODO: Implement search constraints" > lib/features/search/presentation/constants/search_constraints.dart
echo "// TODO: Implement search strings" > lib/features/search/presentation/constants/search_strings.dart
echo "// TODO: Implement algolia config" > lib/features/search/presentation/constants/algolia_config.dart

# 커밋
git add .
git commit -m "feat(search): create repository and usecases structure"
```

### Phase 6: Import 경로 업데이트 및 테스트

```bash
# Import 경로 일괄 업데이트
echo "📝 Updating import paths..."

# Service imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/backend/algolia/algolia_manager.dart'|import '/features/search/data/services/algolia_manager.dart'|g" \
  -e "s|import '/backend/algolia/serialization_util.dart'|import '/features/search/data/services/serialization_util.dart'|g" {} +

# Screen imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/pages/search/search_page_widget.dart'|import '/features/search/presentation/screens/search_page/search_page_widget.dart'|g" \
  -e "s|import '/pages/chat/chat_search/chat_search_widget.dart'|import '/features/search/presentation/screens/chat_search/chat_search_widget.dart'|g" {} +

# Model imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/backend/schema/searches_model.dart'|import '/features/search/domain/models/search_history_model.dart'|g" {} +

# Widget imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/pages/chat/chat_detail_v2/components/chat_search_bar.dart'|import '/features/search/presentation/widgets/search_bar/search_bar_widget.dart'|g" {} +

# Core/App 마이그레이션 관련 imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/flutter_flow/|import '/core/|g" \
  -e "s|FFAppState|AppState|g" \
  -e "s|FFLocalizations|AppLocalizations|g" {} +

# 빌드 테스트
flutter clean
flutter pub get
flutter analyze

# 테스트 실행
flutter test

# 커밋
git add .
git commit -m "feat(search): update import paths and verify build"
```

### Phase 7: 의존성 주입 설정 (선택적)

```bash
# 의존성 주입 모듈 생성
mkdir -p lib/features/search/di
cat > lib/features/search/di/search_module.dart << 'EOF'
// TODO: Implement dependency injection module
// lib/features/search/di/search_module.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@module
abstract class SearchModule {
  // Data Sources
  @lazySingleton
  AlgoliaDataSource provideAlgoliaDataSource() => AlgoliaDataSource(
    applicationId: '0GAS0MPT9Z',
    apiKey: const String.fromEnvironment('ALGOLIA_API_KEY'),
  );
  
  @lazySingleton
  LocalSearchDataSource provideLocalSearchDataSource() => 
      LocalSearchDataSource();
  
  @lazySingleton
  FirestoreSearchDataSource provideFirestoreSearchDataSource() => 
      FirestoreSearchDataSource();
  
  // Services
  @lazySingleton
  AlgoliaManager provideAlgoliaManager() => AlgoliaManager.instance;
  
  @lazySingleton
  SearchCacheService provideSearchCacheService() => SearchCacheService();
  
  // Repository
  @lazySingleton
  SearchRepository provideSearchRepository(
    AlgoliaDataSource algoliaDataSource,
    LocalSearchDataSource localDataSource,
    FirestoreSearchDataSource firestoreDataSource,
    SearchCacheService cacheService,
  ) => SearchRepositoryImpl(
    algoliaDataSource: algoliaDataSource,
    localDataSource: localDataSource,
    firestoreDataSource: firestoreDataSource,
    cacheService: cacheService,
  );
  
  // Use Cases
  @lazySingleton
  SearchPostsUseCase provideSearchPostsUseCase(
    SearchRepository repository,
  ) => SearchPostsUseCase(repository);
  
  @lazySingleton
  SearchUsersUseCase provideSearchUsersUseCase(
    SearchRepository repository,
  ) => SearchUsersUseCase(repository);
  
  @lazySingleton
  SearchChatsUseCase provideSearchChatsUseCase(
    SearchRepository repository,
  ) => SearchChatsUseCase(repository);
  
  // Providers
  @lazySingleton
  SearchProvider provideSearchProvider(
    SearchPostsUseCase searchPostsUseCase,
    SearchUsersUseCase searchUsersUseCase,
    SearchChatsUseCase searchChatsUseCase,
  ) => SearchProvider(
    searchPostsUseCase: searchPostsUseCase,
    searchUsersUseCase: searchUsersUseCase,
    searchChatsUseCase: searchChatsUseCase,
  );
}
```

### Phase 5: Import 경로 일괄 업데이트

```dart
// Before
import '/backend/algolia/algolia_manager.dart';
import '/pages/search/search_page_widget.dart';
import '/backend/schema/searches_model.dart';
import '/pages/chat/chat_search/chat_search_widget.dart';
import '/pages/chat/chat_detail_v2/components/chat_search_bar.dart';

// After
import '/features/search/data/services/algolia_manager.dart';
import '/features/search/presentation/screens/search_page/search_page_widget.dart';
import '/features/search/domain/models/search_history_model.dart';
import '/features/search/presentation/screens/chat_search/chat_search_widget.dart';
import '/features/search/presentation/widgets/search_bar/search_bar_widget.dart';
```

### Phase 6: Import 경로 자동화 스크립트

```bash
# VS Code에서 Find & Replace 사용 (정규식 모드)
# Find: import '(/|\.\./)backend/algolia/(.+)\.dart';
# Replace: import '/features/search/data/services/$2.dart';

# Find: import '(/|\.\./)pages/search/(.+)\.dart';
# Replace: import '/features/search/presentation/screens/search_page/$2.dart';

# Find: import '(/|\.\./)backend/schema/searches_model\.dart';
# Replace: import '/features/search/domain/models/search_history_model.dart';

# Find: import '(/|\.\./)pages/chat/chat_search/(.+)\.dart';
# Replace: import '/features/search/presentation/screens/chat_search/$2.dart';
```

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 네비게이션 | 3개+ | 검색 페이지 라우팅 |
| 채팅 페이지 | 5개+ | 채팅 검색 기능 |
| 홈 피드 | 2개+ | 검색 바 위젯 |
| 백엔드 | 3개+ | Algolia 통합 |

### Import 변경 예시

```dart
// navigation provider
// Before
import '/pages/search/search_page_widget.dart';

// After
import '/features/search/presentation/screens/search_page/search_page_widget.dart';

// chat detail
// Before
import '/pages/chat/chat_detail_v2/components/chat_search_bar.dart';

// After
import '/features/search/presentation/widgets/search_bar/search_bar_widget.dart';
```

## ⚙️ 검색 기능 통합

### Algolia 통합
- **Application ID**: 0GAS0MPT9Z
- **API Key**: 환경 변수 관리 필요
- **인덱스**: posts, users, chats
- **실시간 동기화**: Firestore 트리거 사용

### 검색 유형
1. **게시물 검색**: 제목, 내용, 태그
2. **사용자 검색**: 이름, 이메일, 프로필
3. **채팅 검색**: 메시지 내용, 참여자

### 캐싱 전략
- **메모리 캐시**: 최근 10개 검색 결과
- **로컬 스토리지**: Hive로 검색 기록 저장
- **TTL**: 5분 캐시 유효 시간

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. Algolia 검색
- [ ] 게시물 검색 정상 작동
- [ ] 사용자 검색 정상 작동
- [ ] 실시간 인덱싱 확인
- [ ] 검색 필터 적용

#### 2. 검색 UI
- [ ] 검색바 자동완성
- [ ] 검색 결과 표시
- [ ] 검색 기록 저장/삭제
- [ ] 빈 상태 처리

#### 3. 성능
- [ ] 검색 응답 시간 < 500ms
- [ ] 캐시 히트율 > 60%
- [ ] 메모리 사용량 모니터링

#### 4. 통합 테스트
- [ ] 네비게이션 정상 작동
- [ ] 딥링크 지원
- [ ] 오프라인 모드 처리

## 🎯 마이그레이션 체크리스트

### Phase별 완료 확인
- [ ] **Phase 0**: 브랜치 생성 및 디렉토리 구조 준비
- [ ] **Phase 1**: Services 이동 (2개 파일 - algolia_manager.dart, serialization_util.dart)
- [ ] **Phase 2**: Models 이동 (1개 파일 - searches_model.dart)
- [ ] **Phase 3**: Screens 이동 (2개 파일 - search_page_widget.dart, chat_search_widget.dart)
- [ ] **Phase 4**: Widgets 생성 (10개+ 파일)
- [ ] **Phase 5**: Repository/UseCases 구조 생성
- [ ] **Phase 6**: Import 경로 업데이트 (Core/App 마이그레이션 포함)
- [ ] **Phase 7**: DI 설정 (선택적)

### 기능 검증
- [ ] Algolia 검색 정상 작동
- [ ] 검색 페이지 접근 가능
- [ ] 검색 결과 표시 정상
- [ ] 검색 기록 저장/조회
- [ ] 채팅 내 검색 기능 정상

### 성능 검증
- [ ] 빌드 시간 증가 없음
- [ ] 런타임 에러 없음
- [ ] 검색 응답 시간 < 500ms

## ⚠️ 주의사항

### 1. API 키 보안
- Algolia API 키를 환경 변수로 관리
- 검색 전용 키 사용 (읽기 권한만)
- 키 노출 방지

### 2. 인덱싱 동기화
- Firestore 변경 시 자동 인덱싱
- 배치 업데이트로 API 호출 최적화
- 인덱싱 실패 시 재시도 로직

### 3. 검색 결과 필터링
- 사용자 권한에 따른 결과 필터
- 부적절한 콘텐츠 제외
- 개인정보 보호

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Algolia** | 매우 높음 | 2개 | 핵심 검색 엔진 |
| **검색 UI** | 높음 | 3개 | 사용자 인터페이스 |
| **캐싱** | 중간 | 2개 | 성능 최적화 |
| **네비게이션** | 낮음 | 3개 | 라우팅 업데이트 |
| **총 영향** | **높음** | **10개+** | 검색 기능 전체 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout flutterflow

# 또는 백업 브랜치로 복귀
git checkout backup/before-search-migration
```

## 🧪 테스트 전략

### 단위 테스트

```dart
// test/features/search/domain/usecases/search_posts_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  group('SearchPostsUseCase', () {
    late SearchPostsUseCase useCase;
    late MockSearchRepository mockRepository;
    
    setUp(() {
      mockRepository = MockSearchRepository();
      useCase = SearchPostsUseCase(mockRepository);
    });
    
    test('검색 결과 반환 테스트', () async {
      // Given
      final expectedResults = [
        SearchResult(id: '1', title: 'Test', type: SearchResultType.post),
      ];
      
      when(mockRepository.searchPosts(
        query: anyNamed('query'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) async => Right(expectedResults));
      
      // When
      final result = await useCase(query: 'test');
      
      // Then
      expect(result, Right(expectedResults));
      verify(mockRepository.searchPosts(query: 'test'));
    });
  });
}
```

### 통합 테스트

```dart
// test/features/search/integration/search_flow_test.dart
void main() {
  group('검색 플로우 통합 테스트', () {
    testWidgets('검색어 입력 → 결과 표시', (tester) async {
      // 검색 페이지 로드
      await tester.pumpWidget(SearchPageWidget());
      
      // 검색어 입력
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump(Duration(milliseconds: 500)); // debounce
      
      // 결과 확인
      expect(find.text('flutter'), findsWidgets);
      expect(find.byType(SearchResultItem), findsWidgets);
    });
  });
}
```

## 📊 구현 우선순위

### Priority 1: Core (필수)
1. **AlgoliaDataSource** - 검색 엔진 핵심
2. **SearchRepository** - 데이터 접근 계층
3. **SearchPostsUseCase** - 기본 검색 기능
4. **SearchProvider** - 상태 관리
5. **SearchBarWidget** - 검색 UI

### Priority 2: Features (주요 기능)
1. **SearchHistoryService** - 검색 기록
2. **SearchFilterService** - 필터링
3. **SearchResultItem** - 결과 표시
4. **SearchSuggestions** - 자동완성
5. **HighlightText** - 검색어 하이라이트

### Priority 3: Optimization (최적화)
1. **SearchCacheService** - 캐싱
2. **LocalSearchDataSource** - 오프라인
3. **SearchResultGrid** - 그리드 뷰
4. **SearchEmptyState** - 빈 상태 UI
5. **SearchLoading** - 로딩 표시

## 📅 예상 소요 시간

| Phase | 작업 내용 | 소요 시간 | 난이도 | 체크포인트 |
|-------|----------|----------|--------|------------|
| Phase 0: 준비 | 백업 및 브랜치 생성 | 10분 | ⭐ | 브랜치 생성 확인 |
| Phase 1: Services | 2개 서비스 이동 | 20분 | ⭐ | Import 에러 없음 |
| Phase 2: Models | 1개 모델 이동 | 15분 | ⭐ | 모델 컴파일 성공 |
| Phase 3: Screens | 2개 화면 이동 | 25분 | ⭐⭐ | 화면 라우팅 정상 |
| Phase 4: Widgets | 10개+ 위젯 생성 | 40분 | ⭐⭐ | UI 렌더링 정상 |
| Phase 5: Repository | Repository/UseCases 생성 | 45분 | ⭐⭐⭐ | UseCase 연결 확인 |
| Phase 6: 테스트 | Import 업데이트 및 검증 | 30분 | ⭐⭐ | 전체 빌드 성공 |
| Phase 7: DI 설정 | 의존성 주입 (선택적) | 20분 | ⭐⭐ | DI 컨테이너 설정 |
| **총 소요 시간** | **전체 마이그레이션** | **3시간 25분** | ⭐⭐ | 검색 기능 정상 작동 |

## 🚀 마이그레이션 실행 단계

### Step 1: 백업 및 브랜치 생성
```bash
# 현재 상태 백업
git add .
git commit -m "chore: backup before search feature migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/search-migration
```

### Step 2: 문서 기반 구현
```bash
# 각 디렉토리의 README.md를 참조하여 구현
# 1. data/datasources/README.md → 데이터소스 구현
# 2. data/repositories/README.md → 리포지토리 구현
# 3. data/services/README.md → 서비스 구현
# 4. domain/models/README.md → 모델 구현
# 5. domain/repositories/README.md → 인터페이스 정의
# 6. domain/usecases/README.md → 유스케이스 구현
# 7. presentation/screens/README.md → 화면 구현
# 8. presentation/widgets/README.md → 위젯 구현
# 9. presentation/providers/README.md → 상태관리 구현
```

### Step 3: 검증 및 테스트
```bash
# 단위 테스트 실행
flutter test test/features/search/

# 통합 테스트 실행
flutter test integration_test/search/

# 앱 실행 테스트
flutter run
```

### Step 4: PR 생성
```bash
# 변경사항 커밋
git add .
git commit -m "feat: migrate search feature to Feature-First Architecture

- Move Algolia integration to data layer
- Implement Clean Architecture 3-layer pattern
- Add comprehensive documentation for all subdirectories
- Setup dependency injection with GetIt
- Create unit and integration tests"

# PR 생성
git push origin feature/search-migration
```

## ✅ 최종 체크리스트

### 문서화
- [x] 모든 하위 디렉토리에 README.md 생성 완료
- [x] 각 레이어별 구현 예제 제공
- [x] 마이그레이션 가이드 작성

### 구현 준비
- [ ] 디렉토리 구조 생성
- [ ] 기존 파일 이동 (git mv)
- [ ] 새 파일 생성 (touch)
- [ ] 의존성 주입 설정

### Core 구현
- [ ] AlgoliaDataSource
- [ ] SearchRepository & SearchRepositoryImpl
- [ ] SearchPostsUseCase
- [ ] SearchProvider
- [ ] SearchBarWidget

### Features 구현
- [ ] 검색 기록 관리
- [ ] 필터링 시스템
- [ ] 자동완성 기능
- [ ] 결과 하이라이트

### 테스트
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성
- [ ] E2E 테스트 실행
- [ ] 성능 테스트

### 최종 확인
- [ ] Import 경로 모두 업데이트
- [ ] 앱 정상 실행 확인
- [ ] Algolia 검색 작동 확인
- [ ] 검색 기록 저장/조회 확인

## 🚀 실행 가이드

### 단계별 실행 방법

1. **준비 단계**
   ```bash
   # 현재 브랜치 확인
   git status
   # Phase 0 실행
   ```

2. **순차 실행**
   - 각 Phase를 순서대로 실행
   - Phase 완료 후 커밋 확인
   - Algolia 서비스 이동 시 주의

3. **검증 단계**
   - Phase 6에서 전체 빌드 테스트
   - Algolia 검색 기능 테스트
   - 검색 기록 기능 테스트

4. **완료 후**
   ```bash
   # PR 생성
   git push origin feature/search-migration
   # main 브랜치에 머지 요청
   ```

---

*이 문서는 Feature-First Architecture 마이그레이션의 Search 기능 통합 가이드입니다.*  
*최종 업데이트: 2025-08-25*  
*업데이트: Phase별 실행 계획 추가*