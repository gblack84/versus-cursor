// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search Repository Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - GetIt으로 Repository 주입

@ProviderFor(searchRepository)
const searchRepositoryProvider = SearchRepositoryProvider._();

/// Search Repository Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - GetIt으로 Repository 주입

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          ISearchRepository,
          ISearchRepository,
          ISearchRepository
        >
    with $Provider<ISearchRepository> {
  /// Search Repository Provider
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - GetIt으로 Repository 주입
  const SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'7c115b9d84e4603df22472855dfcb3013a84b170';

/// GetRankingsUseCase Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration

@ProviderFor(getRankingsUseCase)
const getRankingsUseCaseProvider = GetRankingsUseCaseProvider._();

/// GetRankingsUseCase Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration

final class GetRankingsUseCaseProvider
    extends
        $FunctionalProvider<
          GetRankingsUseCase,
          GetRankingsUseCase,
          GetRankingsUseCase
        >
    with $Provider<GetRankingsUseCase> {
  /// GetRankingsUseCase Provider
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  const GetRankingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRankingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRankingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRankingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRankingsUseCase create(Ref ref) {
    return getRankingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRankingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRankingsUseCase>(value),
    );
  }
}

String _$getRankingsUseCaseHash() =>
    r'3d6afc98737c1b8faca3925266f9a018d20b8831';

/// StreamRankingsUseCase Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration

@ProviderFor(streamRankingsUseCase)
const streamRankingsUseCaseProvider = StreamRankingsUseCaseProvider._();

/// StreamRankingsUseCase Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration

final class StreamRankingsUseCaseProvider
    extends
        $FunctionalProvider<
          StreamRankingsUseCase,
          StreamRankingsUseCase,
          StreamRankingsUseCase
        >
    with $Provider<StreamRankingsUseCase> {
  /// StreamRankingsUseCase Provider
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  const StreamRankingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamRankingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamRankingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<StreamRankingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StreamRankingsUseCase create(Ref ref) {
    return streamRankingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamRankingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreamRankingsUseCase>(value),
    );
  }
}

String _$streamRankingsUseCaseHash() =>
    r'899c11f53fdd92ee115d4e74d4491d428be64383';

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

@ProviderFor(topRankings)
const topRankingsProvider = TopRankingsFamily._();

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

final class TopRankingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ranking>>,
          List<Ranking>,
          FutureOr<List<Ranking>>
        >
    with $FutureModifier<List<Ranking>>, $FutureProvider<List<Ranking>> {
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
  const TopRankingsProvider._({
    required TopRankingsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'topRankingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topRankingsHash();

  @override
  String toString() {
    return r'topRankingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Ranking>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ranking>> create(Ref ref) {
    final argument = this.argument as int;
    return topRankings(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopRankingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topRankingsHash() => r'413d62777465c79379c3f9a76c892dc3b662f5ec';

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

final class TopRankingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Ranking>>, int> {
  const TopRankingsFamily._()
    : super(
        retry: null,
        name: r'topRankingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  TopRankingsProvider call({int limit = 10}) =>
      TopRankingsProvider._(argument: limit, from: this);

  @override
  String toString() => r'topRankingsProvider';
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

@ProviderFor(rankingsStream)
const rankingsStreamProvider = RankingsStreamFamily._();

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

final class RankingsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ranking>>,
          List<Ranking>,
          Stream<List<Ranking>>
        >
    with $FutureModifier<List<Ranking>>, $StreamProvider<List<Ranking>> {
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
  const RankingsStreamProvider._({
    required RankingsStreamFamily super.from,
    required ({int limit, dynamic Function(dynamic)? queryBuilder})
    super.argument,
  }) : super(
         retry: null,
         name: r'rankingsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rankingsStreamHash();

  @override
  String toString() {
    return r'rankingsStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Ranking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Ranking>> create(Ref ref) {
    final argument =
        this.argument as ({int limit, dynamic Function(dynamic)? queryBuilder});
    return rankingsStream(
      ref,
      limit: argument.limit,
      queryBuilder: argument.queryBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RankingsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rankingsStreamHash() => r'6d20e5c8703f327f43279539ec6379a75de18c3c';

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

final class RankingsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Ranking>>,
          ({int limit, dynamic Function(dynamic)? queryBuilder})
        > {
  const RankingsStreamFamily._()
    : super(
        retry: null,
        name: r'rankingsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  RankingsStreamProvider call({
    int limit = 10,
    dynamic Function(dynamic)? queryBuilder,
  }) => RankingsStreamProvider._(
    argument: (limit: limit, queryBuilder: queryBuilder),
    from: this,
  );

  @override
  String toString() => r'rankingsStreamProvider';
}

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

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

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
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
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
  const SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'b07ebd22fb9cb0db36c8d833cc6e21f4fcbd9b7b';

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

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
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

@ProviderFor(searchPosts)
const searchPostsProvider = SearchPostsFamily._();

/// Search Posts Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search operations
///
/// **Implementation Pending**:
/// - Algolia setup required
/// - searchPosts() Repository method TODO

final class SearchPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Search Posts Provider (TODO: Implement when Algolia ready)
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - FutureProvider for search operations
  ///
  /// **Implementation Pending**:
  /// - Algolia setup required
  /// - searchPosts() Repository method TODO
  const SearchPostsProvider._({
    required SearchPostsFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'searchPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchPostsHash();

  @override
  String toString() {
    return r'searchPostsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return searchPosts(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchPostsHash() => r'dc2d77cc8ee6a4331cc7dfb6aedf4903b982e8b3';

/// Search Posts Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search operations
///
/// **Implementation Pending**:
/// - Algolia setup required
/// - searchPosts() Repository method TODO

final class SearchPostsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          (String, {int limit})
        > {
  const SearchPostsFamily._()
    : super(
        retry: null,
        name: r'searchPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Search Posts Provider (TODO: Implement when Algolia ready)
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - FutureProvider for search operations
  ///
  /// **Implementation Pending**:
  /// - Algolia setup required
  /// - searchPosts() Repository method TODO

  SearchPostsProvider call(String query, {int limit = 20}) =>
      SearchPostsProvider._(argument: (query, limit: limit), from: this);

  @override
  String toString() => r'searchPostsProvider';
}

/// Search Users Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for user search

@ProviderFor(searchUsers)
const searchUsersProvider = SearchUsersFamily._();

/// Search Users Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for user search

final class SearchUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Search Users Provider (TODO: Implement when Algolia ready)
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - FutureProvider for user search
  const SearchUsersProvider._({
    required SearchUsersFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'searchUsersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchUsersHash();

  @override
  String toString() {
    return r'searchUsersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return searchUsers(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchUsersHash() => r'3c9b843abe3b9113574e52a30524f22b7b78ad1a';

/// Search Users Provider (TODO: Implement when Algolia ready)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for user search

final class SearchUsersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          (String, {int limit})
        > {
  const SearchUsersFamily._()
    : super(
        retry: null,
        name: r'searchUsersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Search Users Provider (TODO: Implement when Algolia ready)
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - FutureProvider for user search

  SearchUsersProvider call(String query, {int limit = 20}) =>
      SearchUsersProvider._(argument: (query, limit: limit), from: this);

  @override
  String toString() => r'searchUsersProvider';
}

/// User Search History Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search history

@ProviderFor(userSearchHistory)
const userSearchHistoryProvider = UserSearchHistoryFamily._();

/// User Search History Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search history

final class UserSearchHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchesModel>>,
          List<SearchesModel>,
          FutureOr<List<SearchesModel>>
        >
    with
        $FutureModifier<List<SearchesModel>>,
        $FutureProvider<List<SearchesModel>> {
  /// User Search History Provider
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - FutureProvider for search history
  const UserSearchHistoryProvider._({
    required UserSearchHistoryFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'userSearchHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userSearchHistoryHash();

  @override
  String toString() {
    return r'userSearchHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SearchesModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchesModel>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return userSearchHistory(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSearchHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSearchHistoryHash() => r'4759856ec655c0ce04c0d0f80386407bd80c26b3';

/// User Search History Provider
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - FutureProvider for search history

final class UserSearchHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SearchesModel>>,
          (String, {int limit})
        > {
  const UserSearchHistoryFamily._()
    : super(
        retry: null,
        name: r'userSearchHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User Search History Provider
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - FutureProvider for search history

  UserSearchHistoryProvider call(String userId, {int limit = 10}) =>
      UserSearchHistoryProvider._(argument: (userId, limit: limit), from: this);

  @override
  String toString() => r'userSearchHistoryProvider';
}

/// Search History Stream Provider (Real-time)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - StreamProvider for real-time search history

@ProviderFor(searchHistoryStream)
const searchHistoryStreamProvider = SearchHistoryStreamFamily._();

/// Search History Stream Provider (Real-time)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - StreamProvider for real-time search history

final class SearchHistoryStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchesModel>>,
          List<SearchesModel>,
          Stream<List<SearchesModel>>
        >
    with
        $FutureModifier<List<SearchesModel>>,
        $StreamProvider<List<SearchesModel>> {
  /// Search History Stream Provider (Real-time)
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - StreamProvider for real-time search history
  const SearchHistoryStreamProvider._({
    required SearchHistoryStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchHistoryStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryStreamHash();

  @override
  String toString() {
    return r'searchHistoryStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SearchesModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SearchesModel>> create(Ref ref) {
    final argument = this.argument as String;
    return searchHistoryStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchHistoryStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchHistoryStreamHash() =>
    r'd602632e6b0bb04d28e6445b41338b5b94067e3e';

/// Search History Stream Provider (Real-time)
///
/// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
/// - StreamProvider for real-time search history

final class SearchHistoryStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SearchesModel>>, String> {
  const SearchHistoryStreamFamily._()
    : super(
        retry: null,
        name: r'searchHistoryStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Search History Stream Provider (Real-time)
  ///
  /// **Phase 2 (2025-11-07)**: Riverpod 3.x Migration
  /// - StreamProvider for real-time search history

  SearchHistoryStreamProvider call(String userId) =>
      SearchHistoryStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'searchHistoryStreamProvider';
}
