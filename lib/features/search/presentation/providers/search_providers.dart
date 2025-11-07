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
/// ref.read(searchQueryProvider.notifier).state = 'new query';
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
