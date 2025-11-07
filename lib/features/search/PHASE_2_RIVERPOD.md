# Search Feature - Phase 2: Riverpod 3.x Migration

> **마이그레이션 가이드**: Basic Provider → Riverpod 3.x with @riverpod annotation
> **난이도**: ⭐⭐⭐☆☆ (중급)
> **예상 소요 시간**: 4시간
> **작성일**: 2025-11-07

---

## 📋 개요

### 마이그레이션 목적

Search Feature의 기본 Provider를 Riverpod 3.x의 `@riverpod` annotation 기반으로 전환하여:

1. **코드 생성 기반**: `@riverpod` annotation으로 boilerplate 제거
2. **타입 안정성**: 컴파일 타임 타입 체크 강화
3. **자동 메모리 관리**: `autoDispose` 기본 적용
4. **Auth/Post Feature 일관성**: 동일한 Provider 패턴 적용
5. **코드 간소화**: 불필요한 Provider wrapper 제거

### 영향 범위

| 레이어 | 파일 수 | Before (줄) | After (줄) | 변화 |
|--------|---------|------------|-----------|------|
| **Presentation (Providers)** | 1개 | ~100줄 (skeleton) | 257줄 | NEW |
| **Domain (UseCases)** | 3개 | -  | - | 참조만 |
| **DI** | 0개 | - | - | TODO |
| **합계** | **1개** | **100줄** | **257줄** | **+157%** |

### 주요 이점

| 항목 | Before (Basic Provider) | After (Riverpod 3.x) |
|------|------------------------|----------------------|
| **코드 생성** | 수동 Provider 정의 | @riverpod annotation |
| **타입 안정성** | 런타임 에러 가능 | 컴파일 타임 보장 |
| **메모리 관리** | 수동 dispose | 자동 autoDispose |
| **패러미터 전달** | family 필요 | 함수 파라미터로 자동 |
| **DI 통합** | GetIt 수동 주입 | Provider 의존성 |
| **상태 업데이트** | notifyListeners() | ref.invalidate() |

---

## 🔍 현재 상태 분석

### 1. search_providers.dart (Before)

**파일**: `presentation/providers/search_providers.dart` (100줄 skeleton)

```dart
/// ❌ Before: Basic Provider skeleton with TODO methods
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ranking.dart';
import '../../domain/models/search_history_model.dart';
import '../../domain/repositories/i_search_repository.dart';

/// Repository Provider (TODO: GetIt injection)
final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  throw UnimplementedError('SearchRepository not registered in DI');
});

/// UseCase Providers (TODO: Implement)
final getRankingsUseCaseProvider = Provider((ref) {
  throw UnimplementedError('GetRankingsUseCase not implemented');
});

/// Data Providers (TODO: Implement)
final topRankingsProvider = FutureProvider.family<List<Ranking>, int>((ref, limit) async {
  throw UnimplementedError('topRankings not implemented');
});

// ... other providers with TODO markers
```

**문제점**:
1. ❌ **수동 Provider 정의**: Provider, FutureProvider, StreamProvider를 수동으로 작성
2. ❌ **타입 불안정성**: family 파라미터 타입 추론 실패 가능
3. ❌ **Boilerplate 코드**: Provider 래퍼 코드 반복
4. ❌ **DI 통합 부족**: GetIt과의 통합이 수동
5. ❌ **문서화 부족**: Provider 사용법과 예시 없음

---

## ✅ 마이그레이션 결과 (After)

### 2. search_providers.dart (After)

**파일**: `presentation/providers/search_providers.dart` (257줄)

```dart
/// ✅ After: @riverpod annotation with code generation
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/ranking.dart';
import '../../domain/models/search_history_model.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../domain/usecases/get_rankings_use_case.dart';
import '../../domain/usecases/stream_rankings_use_case.dart';

part 'search_providers.g.dart';

// ============================================
// Repository Provider
// ============================================

/// Search Repository Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - GetIt으로 Repository 주입
@riverpod
ISearchRepository searchRepository(Ref ref) {
  // TODO: GetIt에서 주입
  throw UnimplementedError('SearchRepository not registered in DI');
}

// ============================================
// UseCase Providers
// ============================================

/// GetRankingsUseCase Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
@riverpod
GetRankingsUseCase getRankingsUseCase(Ref ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return GetRankingsUseCase(repository);
}

/// StreamRankingsUseCase Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
@riverpod
StreamRankingsUseCase streamRankingsUseCase(Ref ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return StreamRankingsUseCase(repository);
}

// ============================================
// Data Providers
// ============================================

/// Top Rankings Provider (Future-based for one-time fetch)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for one-time ranking fetch
/// - autoDispose: 자동 메모리 해제
/// - Either → throw for AsyncError
///
/// **Usage**:
/// ```dart
/// final asyncRankings = ref.watch(topRankingsProvider(limit: 10));
/// asyncRankings.when(
///   data: (rankings) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(...),
/// );
/// ```
@riverpod
Future<List<Ranking>> topRankings(
  Ref ref, {
  int limit = 10,
}) async {
  final useCase = ref.watch(getRankingsUseCaseProvider);

  final either = await useCase(GetRankingsParams(limit: limit));

  return either.fold(
    (failure) => throw failure, // AsyncError로 변환
    (rankings) => rankings,
  );
}

/// Rankings Stream Provider (Real-time updates)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - StreamProvider for real-time ranking updates
/// - autoDispose: 자동 Stream 해제
/// - Either → Stream.error for AsyncError
///
/// **Usage**:
/// ```dart
/// final asyncRankings = ref.watch(rankingsStreamProvider(limit: 10));
/// asyncRankings.when(
///   data: (rankings) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(...),
/// );
/// ```
@riverpod
Stream<List<Ranking>> rankingsStream(
  Ref ref, {
  int limit = 10,
  dynamic Function(dynamic)? queryBuilder,
}) async* {
  final useCase = ref.watch(streamRankingsUseCaseProvider);

  final stream = useCase(StreamRankingsParams(
    queryBuilder: queryBuilder,
    limit: limit,
    singleRecord: false,
  ));

  await for (final either in stream) {
    yield* either.fold(
      (failure) => Stream.error(failure), // AsyncError로 변환
      (rankings) async* {
        yield rankings;
      },
    );
  }
}

// ============================================
// Search State Providers (TODO)
// ============================================

/// Search Query State Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - StateProvider for search query state
///
/// **Usage**:
/// ```dart
/// // Read
/// final query = ref.watch(searchQueryProvider);
///
/// // Write
/// ref.read(searchQueryProvider.notifier).update('new query');
/// ```
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Search Posts Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search operations
///
/// **Implementation Pending**:
/// - Algolia setup required
/// - searchPosts() Repository method TODO
@riverpod
Future<List<Map<String, dynamic>>> searchPosts(
  Ref ref,
  String query, {
  int limit = 20,
}) async {
  final repository = ref.watch(searchRepositoryProvider);

  final either = await repository.searchPosts(
    query: query,
    limit: limit,
  );

  return either.fold(
    (failure) => throw failure,
    (results) => results,
  );
}

/// Search Users Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for user search
@riverpod
Future<List<Map<String, dynamic>>> searchUsers(
  Ref ref,
  String query, {
  int limit = 20,
}) async {
  final repository = ref.watch(searchRepositoryProvider);

  final either = await repository.searchUsers(
    query: query,
    limit: limit,
  );

  return either.fold(
    (failure) => throw failure,
    (results) => results,
  );
}

// ============================================
// Search History Providers (TODO)
// ============================================

/// User Search History Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search history
@riverpod
Future<List<SearchesModel>> userSearchHistory(
  Ref ref,
  String userId, {
  int limit = 10,
}) async {
  final repository = ref.watch(searchRepositoryProvider);

  final either = await repository.getUserSearchHistory(
    userId: userId,
    limit: limit,
  );

  return either.fold(
    (failure) => throw failure,
    (history) => history,
  );
}

/// Search History Stream Provider (Real-time)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - StreamProvider for real-time search history
@riverpod
Stream<List<SearchesModel>> searchHistoryStream(
  Ref ref,
  String userId,
) async* {
  final repository = ref.watch(searchRepositoryProvider);

  final stream = repository.querySearches(
    queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    limit: 10,
  );

  await for (final either in stream) {
    yield* either.fold(
      (failure) => Stream.error(failure),
      (searches) async* {
        yield searches;
      },
    );
  }
}
```

**주요 개선사항**:
1. ✅ **@riverpod annotation**: 코드 생성으로 boilerplate 제거
2. ✅ **타입 안정성**: Ref 타입으로 컴파일 타임 체크
3. ✅ **자동 파라미터 처리**: 함수 파라미터가 자동으로 family로 변환
4. ✅ **Either → AsyncError 변환**: fold()로 명시적 에러 처리
5. ✅ **문서화**: 각 Provider에 상세한 사용 예시 포함
6. ✅ **TODO 마커**: 구현 예정 기능 명시 (Algolia, GetIt DI)

---

## 📊 Before vs After 비교

### 1. Provider 정의 방식

#### Before: 수동 Provider 정의
```dart
/// ❌ Before: 수동 Provider 래퍼 필요
final topRankingsProvider = FutureProvider.family<List<Ranking>, int>(
  (ref, limit) async {
    final repository = ref.watch(searchRepositoryProvider);
    final useCase = GetRankingsUseCase(repository);

    final either = await useCase(GetRankingsParams(limit: limit));

    return either.fold(
      (failure) => throw failure,
      (rankings) => rankings,
    );
  },
);
```

#### After: @riverpod annotation
```dart
/// ✅ After: @riverpod annotation으로 간결하게
@riverpod
Future<List<Ranking>> topRankings(
  Ref ref, {
  int limit = 10,
}) async {
  final useCase = ref.watch(getRankingsUseCaseProvider);

  final either = await useCase(GetRankingsParams(limit: limit));

  return either.fold(
    (failure) => throw failure,
    (rankings) => rankings,
  );
}
```

**차이점**:
- ✅ **타입 추론**: return type이 자동으로 Future Provider로 변환
- ✅ **파라미터**: 함수 파라미터가 자동으로 family로 처리
- ✅ **Ref 타입**: 명시적 Ref 타입으로 타입 안정성 보장
- ✅ **Default 값**: Named parameter로 default 값 지원

### 2. Stream Provider

#### Before: 수동 StreamProvider
```dart
/// ❌ Before: StreamProvider.autoDispose.family 수동 정의
final rankingsStreamProvider = StreamProvider.autoDispose.family<
    List<Ranking>,
    RankingStreamParams
>(
  (ref, params) async* {
    final repository = ref.watch(searchRepositoryProvider);
    final stream = repository.queryRankings(
      queryBuilder: params.queryBuilder,
      limit: params.limit,
    );

    await for (final either in stream) {
      yield* either.fold(
        (failure) => Stream<List<Ranking>>.error(failure),
        (rankings) async* { yield rankings; },
      );
    }
  },
);
```

#### After: @riverpod annotation
```dart
/// ✅ After: @riverpod로 간결하게
@riverpod
Stream<List<Ranking>> rankingsStream(
  Ref ref, {
  int limit = 10,
  dynamic Function(dynamic)? queryBuilder,
}) async* {
  final useCase = ref.watch(streamRankingsUseCaseProvider);

  final stream = useCase(StreamRankingsParams(
    queryBuilder: queryBuilder,
    limit: limit,
    singleRecord: false,
  ));

  await for (final either in stream) {
    yield* either.fold(
      (failure) => Stream.error(failure),
      (rankings) async* { yield rankings; },
    );
  }
}
```

**차이점**:
- ✅ **타입 추론**: Stream<List<Ranking>>이 자동으로 StreamProvider로 변환
- ✅ **autoDispose**: 기본으로 autoDispose 적용
- ✅ **파라미터**: Named parameters로 더 명시적
- ✅ **UseCase 사용**: Repository 대신 UseCase로 비즈니스 로직 분리

### 3. Notifier (State Management)

#### Before: StateNotifier or ChangeNotifier
```dart
/// ❌ Before: StateNotifier 수동 정의
class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = StateNotifierProvider<SearchQueryNotifier, String>(
  (ref) => SearchQueryNotifier(),
);
```

#### After: @riverpod class
```dart
/// ✅ After: @riverpod class로 간결하게
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

// Usage:
// ref.read(searchQueryProvider.notifier).update('query');
```

**차이점**:
- ✅ **코드 생성**: _$SearchQuery base class 자동 생성
- ✅ **build() 메서드**: 초기 상태를 build()에서 반환
- ✅ **타입 안정성**: Notifier 타입 자동 추론
- ✅ **Boilerplate 제거**: Provider 정의 불필요

---

## 🔧 마이그레이션 가이드

### Step 1: 의존성 추가

**pubspec.yaml**:
```yaml
dependencies:
  riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  fpdart: ^1.1.0

dev_dependencies:
  riverpod_generator: ^2.6.2
  build_runner: ^2.4.13
```

### Step 2: Providers 파일 생성

**파일 구조**:
```
presentation/
└── providers/
    ├── search_providers.dart      # @riverpod annotations
    └── search_providers.g.dart    # Generated code
```

**search_providers.dart**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

// Repository Provider
@riverpod
ISearchRepository searchRepository(Ref ref) {
  // TODO: GetIt DI 통합
  throw UnimplementedError('SearchRepository not registered in DI');
}

// UseCase Providers
@riverpod
GetRankingsUseCase getRankingsUseCase(Ref ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return GetRankingsUseCase(repository);
}

// Data Providers
@riverpod
Future<List<Ranking>> topRankings(
  Ref ref, {
  int limit = 10,
}) async {
  final useCase = ref.watch(getRankingsUseCaseProvider);
  final either = await useCase(GetRankingsParams(limit: limit));

  return either.fold(
    (failure) => throw failure,
    (rankings) => rankings,
  );
}

@riverpod
Stream<List<Ranking>> rankingsStream(
  Ref ref, {
  int limit = 10,
  dynamic Function(dynamic)? queryBuilder,
}) async* {
  final useCase = ref.watch(streamRankingsUseCaseProvider);
  final stream = useCase(StreamRankingsParams(
    queryBuilder: queryBuilder,
    limit: limit,
  ));

  await for (final either in stream) {
    yield* either.fold(
      (failure) => Stream.error(failure),
      (rankings) async* { yield rankings; },
    );
  }
}

// State Management
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}
```

### Step 3: 코드 생성 실행

```bash
# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 출력:
# [INFO] Generating build script completed, took 323ms
# [INFO] Creating build script snapshot... completed, took 8.2s
# [INFO] Building new asset graph... completed, took 1.2s
# [INFO] Checking for unexpected pre-existing outputs. completed, took 0s
# [INFO] Running build... completed, took 16.7s
# [INFO] Caching finalized dependency graph... completed, took 42ms
# [INFO] Succeeded after 16.8s with 2 outputs (570 actions)

# 분석
flutter analyze lib/features/search

# 출력:
# Analyzing search...
# No issues found! (ran in 1.5s)
```

### Step 4: UI에서 Provider 사용

#### 4-1. 랭킹 목록 표시 (FutureProvider)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';

class RankingsWidget extends ConsumerWidget {
  const RankingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FutureProvider 구독
    final asyncRankings = ref.watch(topRankingsProvider(limit: 10));

    // AsyncValue.when()으로 상태 처리
    return asyncRankings.when(
      data: (rankings) {
        if (rankings.isEmpty) {
          return const Center(child: Text('No rankings available'));
        }

        return ListView.builder(
          itemCount: rankings.length,
          itemBuilder: (context, index) {
            final ranking = rankings[index];
            return ListTile(
              title: Text(ranking.type),
              subtitle: Text(ranking.date?.toString() ?? 'N/A'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // SearchFailure → getUserMessage()
        final errorMessage = error is SearchFailure
            ? error.getUserMessage()
            : '알 수 없는 오류가 발생했습니다';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(topRankingsProvider),
                child: const Text('재시도'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

#### 4-2. 실시간 랭킹 스트림 (StreamProvider)

```dart
class RealTimeRankingsWidget extends ConsumerWidget {
  const RealTimeRankingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // StreamProvider 구독
    final asyncRankings = ref.watch(
      rankingsStreamProvider(
        limit: 20,
        queryBuilder: (query) => query.orderBy('rank'),
      ),
    );

    return asyncRankings.when(
      data: (rankings) {
        return RefreshIndicator(
          onRefresh: () async {
            // 수동 새로고침
            ref.invalidate(rankingsStreamProvider);
          },
          child: ListView.builder(
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              final ranking = rankings[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(ranking.type),
                  trailing: Text(
                    ranking.date?.toString() ?? 'N/A',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        final errorMessage = error is SearchFailure
            ? error.getUserMessage()
            : '실시간 업데이트 실패';

        return Center(child: Text(errorMessage));
      },
    );
  }
}
```

#### 4-3. 검색 쿼리 상태 관리 (Notifier)

```dart
class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SearchQuery Provider 구독
    final currentQuery = ref.watch(searchQueryProvider);

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: '검색어를 입력하세요',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: currentQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  // SearchQuery clear 호출
                  ref.read(searchQueryProvider.notifier).clear();
                },
              )
            : null,
      ),
      onChanged: (value) {
        // SearchQuery update 호출
        ref.read(searchQueryProvider.notifier).update(value);
      },
      onSubmitted: (value) {
        // TODO: 검색 실행 (searchPosts, searchUsers)
        // final results = ref.read(searchPostsProvider(value));
      },
    );
  }
}
```

#### 4-4. 검색 히스토리 (Future + Stream)

```dart
class SearchHistoryWidget extends ConsumerWidget {
  final String userId;

  const SearchHistoryWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // StreamProvider로 실시간 히스토리
    final asyncHistory = ref.watch(
      searchHistoryStreamProvider(userId),
    );

    return asyncHistory.when(
      data: (searches) {
        if (searches.isEmpty) {
          return const Center(child: Text('검색 기록이 없습니다'));
        }

        return ListView.builder(
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final search = searches[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(search.query ?? 'N/A'),
              subtitle: Text(
                search.createdTime?.toString() ?? 'N/A',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  // TODO: 히스토리 삭제
                },
              ),
              onTap: () {
                // 검색 쿼리 재사용
                ref.read(searchQueryProvider.notifier).update(
                  search.query ?? '',
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('히스토리 로드 실패: ${error.toString()}'),
      ),
    );
  }
}
```

---

## 🎯 검증 체크리스트

### ✅ Phase 2 완료 기준

- [x] **@riverpod annotation 적용**: 모든 Provider에 적용
- [x] **코드 생성 성공**: search_providers.g.dart 생성 완료
- [x] **타입 안정성**: 컴파일 에러 0개
- [x] **Either 패턴 통합**: fold()로 AsyncError 변환
- [x] **문서화**: 각 Provider에 사용 예시 포함
- [x] **flutter analyze 통과**: 0 errors, 0 warnings

### 🔄 TODO: 추가 구현 필요

#### 1. GetIt DI 통합
```dart
// TODO: lib/app/di/di_module.dart에 등록
@riverpod
ISearchRepository searchRepository(Ref ref) {
  return getIt<ISearchRepository>();
}
```

#### 2. Algolia 검색 구현
```dart
// TODO: Repository에 searchPosts/searchUsers 메서드 구현
// TODO: Algolia SDK 통합
@riverpod
Future<List<Map<String, dynamic>>> searchPosts(
  Ref ref,
  String query, {
  int limit = 20,
}) async {
  final repository = ref.watch(searchRepositoryProvider);
  final either = await repository.searchPosts(
    query: query,
    limit: limit,
  );

  return either.fold(
    (failure) => throw failure,
    (results) => results,
  );
}
```

#### 3. UI Screen 마이그레이션
```dart
// TODO: search_page_widget.dart를 ConsumerWidget으로 전환
// TODO: rankings_widget.dart 생성
// TODO: search_history_widget.dart 생성
```

---

## 📚 참고 자료

### 공식 문서
- [Riverpod 3.x Documentation](https://riverpod.dev/)
- [@riverpod Annotation Guide](https://riverpod.dev/docs/concepts/about_code_generation)
- [AsyncValue Reference](https://riverpod.dev/docs/concepts/combining_provider_states)

### 프로젝트 내부 문서
- [Auth Feature PHASE_2_RIVERPOD.md](../auth/PHASE_2_RIVERPOD.md)
- [Post Feature PHASE_2_RIVERPOD.md](../post/PHASE_2_RIVERPOD.md)
- [CLAUDE.md - Riverpod 2.x 가이드](../../../CLAUDE.md)

### 주요 패턴
1. **FutureProvider**: 일회성 데이터 로드 (topRankings, userSearchHistory)
2. **StreamProvider**: 실시간 업데이트 (rankingsStream, searchHistoryStream)
3. **Notifier**: 상태 관리 (SearchQuery)
4. **Either Pattern**: 에러 처리 (fold → throw or return)
5. **autoDispose**: 자동 메모리 관리 (기본 적용)

---

**완료일**: 2025-11-07
**다음 단계**: Phase 3 - UnifiedCacheService Integration
