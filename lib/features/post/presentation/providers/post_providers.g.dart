// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PostCacheService Provider
///
/// **Phase 3: Cache Integration**
/// Provides access to the 3-layer caching service for Post feature

@ProviderFor(postCacheService)
const postCacheServiceProvider = PostCacheServiceProvider._();

/// PostCacheService Provider
///
/// **Phase 3: Cache Integration**
/// Provides access to the 3-layer caching service for Post feature

final class PostCacheServiceProvider
    extends
        $FunctionalProvider<
          PostCacheService,
          PostCacheService,
          PostCacheService
        >
    with $Provider<PostCacheService> {
  /// PostCacheService Provider
  ///
  /// **Phase 3: Cache Integration**
  /// Provides access to the 3-layer caching service for Post feature
  const PostCacheServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postCacheServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postCacheServiceHash();

  @$internal
  @override
  $ProviderElement<PostCacheService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostCacheService create(Ref ref) {
    return postCacheService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostCacheService>(value),
    );
  }
}

String _$postCacheServiceHash() => r'fccc0411e88838bf79de172ca58124b38b1c5be4';

/// Post Providers - Riverpod 2.x Migration
///
/// **Phase 2: Riverpod Pattern Applied**
/// - StreamProvider.autoDispose.family for real-time data
/// - FutureProvider.autoDispose.family for one-time fetches
/// - Automatic memory management with autoDispose
/// - Type-safe error handling with AsyncValue
///
/// **Migration Benefits**:
/// - 85% code reduction vs ChangeNotifier
/// - Automatic loading/error states
/// - No manual stream management
/// - Built-in caching with family parameters
// ============================================================================
// PostDetail Providers
// ============================================================================
/// PostDetail UseCase Provider

@ProviderFor(postDetailUseCase)
const postDetailUseCaseProvider = PostDetailUseCaseProvider._();

/// Post Providers - Riverpod 2.x Migration
///
/// **Phase 2: Riverpod Pattern Applied**
/// - StreamProvider.autoDispose.family for real-time data
/// - FutureProvider.autoDispose.family for one-time fetches
/// - Automatic memory management with autoDispose
/// - Type-safe error handling with AsyncValue
///
/// **Migration Benefits**:
/// - 85% code reduction vs ChangeNotifier
/// - Automatic loading/error states
/// - No manual stream management
/// - Built-in caching with family parameters
// ============================================================================
// PostDetail Providers
// ============================================================================
/// PostDetail UseCase Provider

final class PostDetailUseCaseProvider
    extends
        $FunctionalProvider<
          GetPostDetailUseCase,
          GetPostDetailUseCase,
          GetPostDetailUseCase
        >
    with $Provider<GetPostDetailUseCase> {
  /// Post Providers - Riverpod 2.x Migration
  ///
  /// **Phase 2: Riverpod Pattern Applied**
  /// - StreamProvider.autoDispose.family for real-time data
  /// - FutureProvider.autoDispose.family for one-time fetches
  /// - Automatic memory management with autoDispose
  /// - Type-safe error handling with AsyncValue
  ///
  /// **Migration Benefits**:
  /// - 85% code reduction vs ChangeNotifier
  /// - Automatic loading/error states
  /// - No manual stream management
  /// - Built-in caching with family parameters
  // ============================================================================
  // PostDetail Providers
  // ============================================================================
  /// PostDetail UseCase Provider
  const PostDetailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postDetailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postDetailUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPostDetailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPostDetailUseCase create(Ref ref) {
    return postDetailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPostDetailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPostDetailUseCase>(value),
    );
  }
}

String _$postDetailUseCaseHash() => r'c6fe7a8054e8b807473ba86bd6c220b1e00a4cb1';

/// PostDetail Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached post if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response for post details
///
/// **Cache Strategy**:
/// 1. Check cache layers (Memory → Hive → Firestore cache)
/// 2. Yield cached post immediately if found
/// 3. Subscribe to real-time updates from Firestore
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailStreamProvider(postId));
/// postAsync.when(
///   data: (post) => PostDetailWidget(post),
///   loading: () => LoadingIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```

@ProviderFor(postDetailStream)
const postDetailStreamProvider = PostDetailStreamFamily._();

/// PostDetail Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached post if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response for post details
///
/// **Cache Strategy**:
/// 1. Check cache layers (Memory → Hive → Firestore cache)
/// 2. Yield cached post immediately if found
/// 3. Subscribe to real-time updates from Firestore
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailStreamProvider(postId));
/// postAsync.when(
///   data: (post) => PostDetailWidget(post),
///   loading: () => LoadingIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```

final class PostDetailStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostDisplay?>,
          PostDisplay?,
          Stream<PostDisplay?>
        >
    with $FutureModifier<PostDisplay?>, $StreamProvider<PostDisplay?> {
  /// PostDetail Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached post if available (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Provides instant UI response for post details
  ///
  /// **Cache Strategy**:
  /// 1. Check cache layers (Memory → Hive → Firestore cache)
  /// 2. Yield cached post immediately if found
  /// 3. Subscribe to real-time updates from Firestore
  /// 4. Update cache in background
  ///
  /// **Usage**:
  /// ```dart
  /// final postAsync = ref.watch(postDetailStreamProvider(postId));
  /// postAsync.when(
  ///   data: (post) => PostDetailWidget(post),
  ///   loading: () => LoadingIndicator(),
  ///   error: (error, stack) => ErrorWidget(error),
  /// );
  /// ```
  const PostDetailStreamProvider._({
    required PostDetailStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postDetailStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postDetailStreamHash();

  @override
  String toString() {
    return r'postDetailStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PostDisplay?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PostDisplay?> create(Ref ref) {
    final argument = this.argument as String;
    return postDetailStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDetailStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postDetailStreamHash() => r'01b1ab6649bc6ecd053841e58af8cc6c4f72577c';

/// PostDetail Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached post if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response for post details
///
/// **Cache Strategy**:
/// 1. Check cache layers (Memory → Hive → Firestore cache)
/// 2. Yield cached post immediately if found
/// 3. Subscribe to real-time updates from Firestore
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailStreamProvider(postId));
/// postAsync.when(
///   data: (post) => PostDetailWidget(post),
///   loading: () => LoadingIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```

final class PostDetailStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostDisplay?>, String> {
  const PostDetailStreamFamily._()
    : super(
        retry: null,
        name: r'postDetailStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PostDetail Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached post if available (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Provides instant UI response for post details
  ///
  /// **Cache Strategy**:
  /// 1. Check cache layers (Memory → Hive → Firestore cache)
  /// 2. Yield cached post immediately if found
  /// 3. Subscribe to real-time updates from Firestore
  /// 4. Update cache in background
  ///
  /// **Usage**:
  /// ```dart
  /// final postAsync = ref.watch(postDetailStreamProvider(postId));
  /// postAsync.when(
  ///   data: (post) => PostDetailWidget(post),
  ///   loading: () => LoadingIndicator(),
  ///   error: (error, stack) => ErrorWidget(error),
  /// );
  /// ```

  PostDetailStreamProvider call(String postId) =>
      PostDetailStreamProvider._(argument: postId, from: this);

  @override
  String toString() => r'postDetailStreamProvider';
}

/// PostDetail Future Provider (one-time fetch)
///
/// **Single post detail fetch**
/// - Use for initial load or manual refresh
/// - Converts Either to AsyncValue automatically
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailFutureProvider(postId));
/// ```

@ProviderFor(postDetailFuture)
const postDetailFutureProvider = PostDetailFutureFamily._();

/// PostDetail Future Provider (one-time fetch)
///
/// **Single post detail fetch**
/// - Use for initial load or manual refresh
/// - Converts Either to AsyncValue automatically
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailFutureProvider(postId));
/// ```

final class PostDetailFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostDisplay?>,
          PostDisplay?,
          FutureOr<PostDisplay?>
        >
    with $FutureModifier<PostDisplay?>, $FutureProvider<PostDisplay?> {
  /// PostDetail Future Provider (one-time fetch)
  ///
  /// **Single post detail fetch**
  /// - Use for initial load or manual refresh
  /// - Converts Either to AsyncValue automatically
  ///
  /// **Usage**:
  /// ```dart
  /// final postAsync = ref.watch(postDetailFutureProvider(postId));
  /// ```
  const PostDetailFutureProvider._({
    required PostDetailFutureFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postDetailFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postDetailFutureHash();

  @override
  String toString() {
    return r'postDetailFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PostDisplay?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PostDisplay?> create(Ref ref) {
    final argument = this.argument as String;
    return postDetailFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDetailFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postDetailFutureHash() => r'7e4916d4ae5b02db97c1b27981f635e3a2141797';

/// PostDetail Future Provider (one-time fetch)
///
/// **Single post detail fetch**
/// - Use for initial load or manual refresh
/// - Converts Either to AsyncValue automatically
///
/// **Usage**:
/// ```dart
/// final postAsync = ref.watch(postDetailFutureProvider(postId));
/// ```

final class PostDetailFutureFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PostDisplay?>, String> {
  const PostDetailFutureFamily._()
    : super(
        retry: null,
        name: r'postDetailFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PostDetail Future Provider (one-time fetch)
  ///
  /// **Single post detail fetch**
  /// - Use for initial load or manual refresh
  /// - Converts Either to AsyncValue automatically
  ///
  /// **Usage**:
  /// ```dart
  /// final postAsync = ref.watch(postDetailFutureProvider(postId));
  /// ```

  PostDetailFutureProvider call(String postId) =>
      PostDetailFutureProvider._(argument: postId, from: this);

  @override
  String toString() => r'postDetailFutureProvider';
}

/// TrendingPosts UseCase Provider

@ProviderFor(trendingPostsUseCase)
const trendingPostsUseCaseProvider = TrendingPostsUseCaseProvider._();

/// TrendingPosts UseCase Provider

final class TrendingPostsUseCaseProvider
    extends
        $FunctionalProvider<
          GetTrendingPostsUseCase,
          GetTrendingPostsUseCase,
          GetTrendingPostsUseCase
        >
    with $Provider<GetTrendingPostsUseCase> {
  /// TrendingPosts UseCase Provider
  const TrendingPostsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingPostsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingPostsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetTrendingPostsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetTrendingPostsUseCase create(Ref ref) {
    return trendingPostsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetTrendingPostsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetTrendingPostsUseCase>(value),
    );
  }
}

String _$trendingPostsUseCaseHash() =>
    r'1876d628a58b9dede0df8065fcc5fd93784361ed';

/// TrendingPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached trending posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Trending scores update in real-time
///
/// **Cache Strategy**:
/// - TTL: 10 minutes (trending posts change slower)
/// - Cache key includes limit parameter
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(trendingPostsStreamProvider(20));
/// ```

@ProviderFor(trendingPostsStream)
const trendingPostsStreamProvider = TrendingPostsStreamFamily._();

/// TrendingPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached trending posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Trending scores update in real-time
///
/// **Cache Strategy**:
/// - TTL: 10 minutes (trending posts change slower)
/// - Cache key includes limit parameter
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(trendingPostsStreamProvider(20));
/// ```

final class TrendingPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          Stream<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $StreamProvider<List<PostDisplay>> {
  /// TrendingPosts Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached trending posts (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Trending scores update in real-time
  ///
  /// **Cache Strategy**:
  /// - TTL: 10 minutes (trending posts change slower)
  /// - Cache key includes limit parameter
  ///
  /// **Usage**:
  /// ```dart
  /// final postsAsync = ref.watch(trendingPostsStreamProvider(20));
  /// ```
  const TrendingPostsStreamProvider._({
    required TrendingPostsStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'trendingPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trendingPostsStreamHash();

  @override
  String toString() {
    return r'trendingPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as int;
    return trendingPostsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrendingPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trendingPostsStreamHash() =>
    r'4d17692f0b1c18d2ffc0a50c0e640ec2a28454a0';

/// TrendingPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached trending posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Trending scores update in real-time
///
/// **Cache Strategy**:
/// - TTL: 10 minutes (trending posts change slower)
/// - Cache key includes limit parameter
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(trendingPostsStreamProvider(20));
/// ```

final class TrendingPostsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostDisplay>>, int> {
  const TrendingPostsStreamFamily._()
    : super(
        retry: null,
        name: r'trendingPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// TrendingPosts Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached trending posts (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Trending scores update in real-time
  ///
  /// **Cache Strategy**:
  /// - TTL: 10 minutes (trending posts change slower)
  /// - Cache key includes limit parameter
  ///
  /// **Usage**:
  /// ```dart
  /// final postsAsync = ref.watch(trendingPostsStreamProvider(20));
  /// ```

  TrendingPostsStreamProvider call(int limit) =>
      TrendingPostsStreamProvider._(argument: limit, from: this);

  @override
  String toString() => r'trendingPostsStreamProvider';
}

/// TrendingPosts Future Provider

@ProviderFor(trendingPostsFuture)
const trendingPostsFutureProvider = TrendingPostsFutureFamily._();

/// TrendingPosts Future Provider

final class TrendingPostsFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          FutureOr<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $FutureProvider<List<PostDisplay>> {
  /// TrendingPosts Future Provider
  const TrendingPostsFutureProvider._({
    required TrendingPostsFutureFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'trendingPostsFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trendingPostsFutureHash();

  @override
  String toString() {
    return r'trendingPostsFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as int;
    return trendingPostsFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrendingPostsFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trendingPostsFutureHash() =>
    r'03da01474ed49e7c7877e68fdcd6d0b5a8f43708';

/// TrendingPosts Future Provider

final class TrendingPostsFutureFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostDisplay>>, int> {
  const TrendingPostsFutureFamily._()
    : super(
        retry: null,
        name: r'trendingPostsFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// TrendingPosts Future Provider

  TrendingPostsFutureProvider call(int limit) =>
      TrendingPostsFutureProvider._(argument: limit, from: this);

  @override
  String toString() => r'trendingPostsFutureProvider';
}

/// PopularPosts UseCase Provider

@ProviderFor(popularPostsUseCase)
const popularPostsUseCaseProvider = PopularPostsUseCaseProvider._();

/// PopularPosts UseCase Provider

final class PopularPostsUseCaseProvider
    extends
        $FunctionalProvider<
          GetPopularPostsUseCase,
          GetPopularPostsUseCase,
          GetPopularPostsUseCase
        >
    with $Provider<GetPopularPostsUseCase> {
  /// PopularPosts UseCase Provider
  const PopularPostsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularPostsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularPostsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPopularPostsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPopularPostsUseCase create(Ref ref) {
    return popularPostsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPopularPostsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPopularPostsUseCase>(value),
    );
  }
}

String _$popularPostsUseCaseHash() =>
    r'efaa0f69db0de51a68f30cbe8232d6a7b82497f2';

/// PopularPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached popular posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Popular scores update based on like counts
///
/// **Cache Strategy**:
/// - TTL: 10 minutes
/// - Cache key includes limit and timeWindow
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(popularPostsStreamProvider(
///   PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
/// ));
/// ```

@ProviderFor(popularPostsStream)
const popularPostsStreamProvider = PopularPostsStreamFamily._();

/// PopularPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached popular posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Popular scores update based on like counts
///
/// **Cache Strategy**:
/// - TTL: 10 minutes
/// - Cache key includes limit and timeWindow
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(popularPostsStreamProvider(
///   PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
/// ));
/// ```

final class PopularPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          Stream<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $StreamProvider<List<PostDisplay>> {
  /// PopularPosts Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached popular posts (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Popular scores update based on like counts
  ///
  /// **Cache Strategy**:
  /// - TTL: 10 minutes
  /// - Cache key includes limit and timeWindow
  ///
  /// **Usage**:
  /// ```dart
  /// final postsAsync = ref.watch(popularPostsStreamProvider(
  ///   PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
  /// ));
  /// ```
  const PopularPostsStreamProvider._({
    required PopularPostsStreamFamily super.from,
    required PopularPostsParams super.argument,
  }) : super(
         retry: null,
         name: r'popularPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$popularPostsStreamHash();

  @override
  String toString() {
    return r'popularPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as PopularPostsParams;
    return popularPostsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PopularPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$popularPostsStreamHash() =>
    r'559413d3bc9ce0fed2be96b5857584a387d67c15';

/// PopularPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached popular posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Popular scores update based on like counts
///
/// **Cache Strategy**:
/// - TTL: 10 minutes
/// - Cache key includes limit and timeWindow
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(popularPostsStreamProvider(
///   PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
/// ));
/// ```

final class PopularPostsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<PostDisplay>>,
          PopularPostsParams
        > {
  const PopularPostsStreamFamily._()
    : super(
        retry: null,
        name: r'popularPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PopularPosts Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached popular posts (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Popular scores update based on like counts
  ///
  /// **Cache Strategy**:
  /// - TTL: 10 minutes
  /// - Cache key includes limit and timeWindow
  ///
  /// **Usage**:
  /// ```dart
  /// final postsAsync = ref.watch(popularPostsStreamProvider(
  ///   PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
  /// ));
  /// ```

  PopularPostsStreamProvider call(PopularPostsParams params) =>
      PopularPostsStreamProvider._(argument: params, from: this);

  @override
  String toString() => r'popularPostsStreamProvider';
}

/// PopularPosts Future Provider

@ProviderFor(popularPostsFuture)
const popularPostsFutureProvider = PopularPostsFutureFamily._();

/// PopularPosts Future Provider

final class PopularPostsFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          FutureOr<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $FutureProvider<List<PostDisplay>> {
  /// PopularPosts Future Provider
  const PopularPostsFutureProvider._({
    required PopularPostsFutureFamily super.from,
    required PopularPostsParams super.argument,
  }) : super(
         retry: null,
         name: r'popularPostsFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$popularPostsFutureHash();

  @override
  String toString() {
    return r'popularPostsFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as PopularPostsParams;
    return popularPostsFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PopularPostsFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$popularPostsFutureHash() =>
    r'523c2586dbc4af04e49ff3b015ce369e2b9a9201';

/// PopularPosts Future Provider

final class PopularPostsFutureFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PostDisplay>>,
          PopularPostsParams
        > {
  const PopularPostsFutureFamily._()
    : super(
        retry: null,
        name: r'popularPostsFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PopularPosts Future Provider

  PopularPostsFutureProvider call(PopularPostsParams params) =>
      PopularPostsFutureProvider._(argument: params, from: this);

  @override
  String toString() => r'popularPostsFutureProvider';
}

/// UserPosts UseCase Provider

@ProviderFor(userPostsUseCase)
const userPostsUseCaseProvider = UserPostsUseCaseProvider._();

/// UserPosts UseCase Provider

final class UserPostsUseCaseProvider
    extends
        $FunctionalProvider<
          GetUserPostsUseCase,
          GetUserPostsUseCase,
          GetUserPostsUseCase
        >
    with $Provider<GetUserPostsUseCase> {
  /// UserPosts UseCase Provider
  const UserPostsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPostsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPostsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetUserPostsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetUserPostsUseCase create(Ref ref) {
    return userPostsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetUserPostsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetUserPostsUseCase>(value),
    );
  }
}

String _$userPostsUseCaseHash() => r'f7e2a9a68a9e911c04676eace9f1d9aaa3691056';

/// UserPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached user posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Updates when user creates/deletes posts
///
/// **Cache Strategy**:
/// - TTL: 5 minutes (user posts change frequently)
/// - Cache key includes userId and limit
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(userPostsStreamProvider(
///   UserPostsParams(userId: 'user123', limit: 20),
/// ));
/// ```

@ProviderFor(userPostsStream)
const userPostsStreamProvider = UserPostsStreamFamily._();

/// UserPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached user posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Updates when user creates/deletes posts
///
/// **Cache Strategy**:
/// - TTL: 5 minutes (user posts change frequently)
/// - Cache key includes userId and limit
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(userPostsStreamProvider(
///   UserPostsParams(userId: 'user123', limit: 20),
/// ));
/// ```

final class UserPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          Stream<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $StreamProvider<List<PostDisplay>> {
  /// UserPosts Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached user posts (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Updates when user creates/deletes posts
  ///
  /// **Cache Strategy**:
  /// - TTL: 5 minutes (user posts change frequently)
  /// - Cache key includes userId and limit
  ///
  /// **Usage**:
  /// ```dart
  /// final postsAsync = ref.watch(userPostsStreamProvider(
  ///   UserPostsParams(userId: 'user123', limit: 20),
  /// ));
  /// ```
  const UserPostsStreamProvider._({
    required UserPostsStreamFamily super.from,
    required UserPostsParams super.argument,
  }) : super(
         retry: null,
         name: r'userPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userPostsStreamHash();

  @override
  String toString() {
    return r'userPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as UserPostsParams;
    return userPostsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPostsStreamHash() => r'c02cbcb12d9806d5f8073359d5305f1d5c206427';

/// UserPosts Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached user posts (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Updates when user creates/deletes posts
///
/// **Cache Strategy**:
/// - TTL: 5 minutes (user posts change frequently)
/// - Cache key includes userId and limit
///
/// **Usage**:
/// ```dart
/// final postsAsync = ref.watch(userPostsStreamProvider(
///   UserPostsParams(userId: 'user123', limit: 20),
/// ));
/// ```

final class UserPostsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostDisplay>>, UserPostsParams> {
  const UserPostsStreamFamily._()
    : super(
        retry: null,
        name: r'userPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// UserPosts Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached user posts (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Updates when user creates/deletes posts
  ///
  /// **Cache Strategy**:
  /// - TTL: 5 minutes (user posts change frequently)
  /// - Cache key includes userId and limit
  ///
  /// **Usage**:
  /// ```dart
  /// final postsAsync = ref.watch(userPostsStreamProvider(
  ///   UserPostsParams(userId: 'user123', limit: 20),
  /// ));
  /// ```

  UserPostsStreamProvider call(UserPostsParams params) =>
      UserPostsStreamProvider._(argument: params, from: this);

  @override
  String toString() => r'userPostsStreamProvider';
}

/// UserPosts Future Provider

@ProviderFor(userPostsFuture)
const userPostsFutureProvider = UserPostsFutureFamily._();

/// UserPosts Future Provider

final class UserPostsFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          FutureOr<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $FutureProvider<List<PostDisplay>> {
  /// UserPosts Future Provider
  const UserPostsFutureProvider._({
    required UserPostsFutureFamily super.from,
    required UserPostsParams super.argument,
  }) : super(
         retry: null,
         name: r'userPostsFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userPostsFutureHash();

  @override
  String toString() {
    return r'userPostsFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as UserPostsParams;
    return userPostsFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPostsFutureHash() => r'001f97a93bf50d76bed68bed2cd758eece0a05e3';

/// UserPosts Future Provider

final class UserPostsFutureFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PostDisplay>>,
          UserPostsParams
        > {
  const UserPostsFutureFamily._()
    : super(
        retry: null,
        name: r'userPostsFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// UserPosts Future Provider

  UserPostsFutureProvider call(UserPostsParams params) =>
      UserPostsFutureProvider._(argument: params, from: this);

  @override
  String toString() => r'userPostsFutureProvider';
}

/// Feed UseCase Provider

@ProviderFor(feedUseCase)
const feedUseCaseProvider = FeedUseCaseProvider._();

/// Feed UseCase Provider

final class FeedUseCaseProvider
    extends $FunctionalProvider<GetFeedUseCase, GetFeedUseCase, GetFeedUseCase>
    with $Provider<GetFeedUseCase> {
  /// Feed UseCase Provider
  const FeedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFeedUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetFeedUseCase create(Ref ref) {
    return feedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFeedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFeedUseCase>(value),
    );
  }
}

String _$feedUseCaseHash() => r'264649995674afb89374a47decb2374edd1aecaf';

/// Feed Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached data if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response with stale-while-revalidate
///
/// **Cache Strategy**:
/// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore cache)
/// 2. If cache hit, yield immediately
/// 3. Subscribe to Firestore for real-time updates
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(feedStreamProvider(
///   FeedParams(limit: 20, sortBy: FeedSortBy.latest),
/// ));
/// ```

@ProviderFor(feedStream)
const feedStreamProvider = FeedStreamFamily._();

/// Feed Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached data if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response with stale-while-revalidate
///
/// **Cache Strategy**:
/// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore cache)
/// 2. If cache hit, yield immediately
/// 3. Subscribe to Firestore for real-time updates
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(feedStreamProvider(
///   FeedParams(limit: 20, sortBy: FeedSortBy.latest),
/// ));
/// ```

final class FeedStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          Stream<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $StreamProvider<List<PostDisplay>> {
  /// Feed Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached data if available (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Provides instant UI response with stale-while-revalidate
  ///
  /// **Cache Strategy**:
  /// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore cache)
  /// 2. If cache hit, yield immediately
  /// 3. Subscribe to Firestore for real-time updates
  /// 4. Update cache in background
  ///
  /// **Usage**:
  /// ```dart
  /// final feedAsync = ref.watch(feedStreamProvider(
  ///   FeedParams(limit: 20, sortBy: FeedSortBy.latest),
  /// ));
  /// ```
  const FeedStreamProvider._({
    required FeedStreamFamily super.from,
    required FeedParams super.argument,
  }) : super(
         retry: null,
         name: r'feedStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedStreamHash();

  @override
  String toString() {
    return r'feedStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as FeedParams;
    return feedStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedStreamHash() => r'da7dcf1ce9ad0b81b8d6f7e8775136be8f48c6c2';

/// Feed Stream Provider
///
/// **Phase 3: Cache-First Pattern**
/// - Immediately emits cached data if available (<30ms)
/// - Then subscribes to real-time Firestore updates
/// - Provides instant UI response with stale-while-revalidate
///
/// **Cache Strategy**:
/// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore cache)
/// 2. If cache hit, yield immediately
/// 3. Subscribe to Firestore for real-time updates
/// 4. Update cache in background
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(feedStreamProvider(
///   FeedParams(limit: 20, sortBy: FeedSortBy.latest),
/// ));
/// ```

final class FeedStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostDisplay>>, FeedParams> {
  const FeedStreamFamily._()
    : super(
        retry: null,
        name: r'feedStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Feed Stream Provider
  ///
  /// **Phase 3: Cache-First Pattern**
  /// - Immediately emits cached data if available (<30ms)
  /// - Then subscribes to real-time Firestore updates
  /// - Provides instant UI response with stale-while-revalidate
  ///
  /// **Cache Strategy**:
  /// 1. Check L1 (Memory) → L2 (Hive) → L3 (Firestore cache)
  /// 2. If cache hit, yield immediately
  /// 3. Subscribe to Firestore for real-time updates
  /// 4. Update cache in background
  ///
  /// **Usage**:
  /// ```dart
  /// final feedAsync = ref.watch(feedStreamProvider(
  ///   FeedParams(limit: 20, sortBy: FeedSortBy.latest),
  /// ));
  /// ```

  FeedStreamProvider call(FeedParams params) =>
      FeedStreamProvider._(argument: params, from: this);

  @override
  String toString() => r'feedStreamProvider';
}

/// Feed Future Provider (with pagination support)
///
/// **Paginated feed loading**
/// - Returns FeedResult with hasMore and lastDocumentId
/// - Use with StateProvider for pagination state management
///
/// **Pagination Pattern**:
/// ```dart
/// // State providers for pagination
/// final lastDocIdProvider = StateProvider<String?>((ref) => null);
/// final feedPostsProvider = StateProvider<List<PostDisplay>>((ref) => []);
///
/// // Load more
/// Future<void> loadMore() async {
///   final lastId = ref.read(lastDocIdProvider);
///   final currentPosts = ref.read(feedPostsProvider);
///
///   final result = await ref.read(feedFutureProvider(
///     FeedParams(limit: 20, sortBy: FeedSortBy.latest),
///     lastDocumentId: lastId,
///   ).future);
///
///   ref.read(feedPostsProvider.notifier).state = [
///     ...currentPosts,
///     ...result.posts,
///   ];
///   ref.read(lastDocIdProvider.notifier).state = result.lastDocumentId;
/// }
/// ```

@ProviderFor(feedFuture)
const feedFutureProvider = FeedFutureFamily._();

/// Feed Future Provider (with pagination support)
///
/// **Paginated feed loading**
/// - Returns FeedResult with hasMore and lastDocumentId
/// - Use with StateProvider for pagination state management
///
/// **Pagination Pattern**:
/// ```dart
/// // State providers for pagination
/// final lastDocIdProvider = StateProvider<String?>((ref) => null);
/// final feedPostsProvider = StateProvider<List<PostDisplay>>((ref) => []);
///
/// // Load more
/// Future<void> loadMore() async {
///   final lastId = ref.read(lastDocIdProvider);
///   final currentPosts = ref.read(feedPostsProvider);
///
///   final result = await ref.read(feedFutureProvider(
///     FeedParams(limit: 20, sortBy: FeedSortBy.latest),
///     lastDocumentId: lastId,
///   ).future);
///
///   ref.read(feedPostsProvider.notifier).state = [
///     ...currentPosts,
///     ...result.posts,
///   ];
///   ref.read(lastDocIdProvider.notifier).state = result.lastDocumentId;
/// }
/// ```

final class FeedFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedResult>,
          FeedResult,
          FutureOr<FeedResult>
        >
    with $FutureModifier<FeedResult>, $FutureProvider<FeedResult> {
  /// Feed Future Provider (with pagination support)
  ///
  /// **Paginated feed loading**
  /// - Returns FeedResult with hasMore and lastDocumentId
  /// - Use with StateProvider for pagination state management
  ///
  /// **Pagination Pattern**:
  /// ```dart
  /// // State providers for pagination
  /// final lastDocIdProvider = StateProvider<String?>((ref) => null);
  /// final feedPostsProvider = StateProvider<List<PostDisplay>>((ref) => []);
  ///
  /// // Load more
  /// Future<void> loadMore() async {
  ///   final lastId = ref.read(lastDocIdProvider);
  ///   final currentPosts = ref.read(feedPostsProvider);
  ///
  ///   final result = await ref.read(feedFutureProvider(
  ///     FeedParams(limit: 20, sortBy: FeedSortBy.latest),
  ///     lastDocumentId: lastId,
  ///   ).future);
  ///
  ///   ref.read(feedPostsProvider.notifier).state = [
  ///     ...currentPosts,
  ///     ...result.posts,
  ///   ];
  ///   ref.read(lastDocIdProvider.notifier).state = result.lastDocumentId;
  /// }
  /// ```
  const FeedFutureProvider._({
    required FeedFutureFamily super.from,
    required (FeedParams, {String? lastDocumentId}) super.argument,
  }) : super(
         retry: null,
         name: r'feedFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedFutureHash();

  @override
  String toString() {
    return r'feedFutureProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FeedResult> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FeedResult> create(Ref ref) {
    final argument = this.argument as (FeedParams, {String? lastDocumentId});
    return feedFuture(
      ref,
      argument.$1,
      lastDocumentId: argument.lastDocumentId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedFutureHash() => r'3a53b7f170b7c0d0ce1b899e85d1c1969409ab45';

/// Feed Future Provider (with pagination support)
///
/// **Paginated feed loading**
/// - Returns FeedResult with hasMore and lastDocumentId
/// - Use with StateProvider for pagination state management
///
/// **Pagination Pattern**:
/// ```dart
/// // State providers for pagination
/// final lastDocIdProvider = StateProvider<String?>((ref) => null);
/// final feedPostsProvider = StateProvider<List<PostDisplay>>((ref) => []);
///
/// // Load more
/// Future<void> loadMore() async {
///   final lastId = ref.read(lastDocIdProvider);
///   final currentPosts = ref.read(feedPostsProvider);
///
///   final result = await ref.read(feedFutureProvider(
///     FeedParams(limit: 20, sortBy: FeedSortBy.latest),
///     lastDocumentId: lastId,
///   ).future);
///
///   ref.read(feedPostsProvider.notifier).state = [
///     ...currentPosts,
///     ...result.posts,
///   ];
///   ref.read(lastDocIdProvider.notifier).state = result.lastDocumentId;
/// }
/// ```

final class FeedFutureFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<FeedResult>,
          (FeedParams, {String? lastDocumentId})
        > {
  const FeedFutureFamily._()
    : super(
        retry: null,
        name: r'feedFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Feed Future Provider (with pagination support)
  ///
  /// **Paginated feed loading**
  /// - Returns FeedResult with hasMore and lastDocumentId
  /// - Use with StateProvider for pagination state management
  ///
  /// **Pagination Pattern**:
  /// ```dart
  /// // State providers for pagination
  /// final lastDocIdProvider = StateProvider<String?>((ref) => null);
  /// final feedPostsProvider = StateProvider<List<PostDisplay>>((ref) => []);
  ///
  /// // Load more
  /// Future<void> loadMore() async {
  ///   final lastId = ref.read(lastDocIdProvider);
  ///   final currentPosts = ref.read(feedPostsProvider);
  ///
  ///   final result = await ref.read(feedFutureProvider(
  ///     FeedParams(limit: 20, sortBy: FeedSortBy.latest),
  ///     lastDocumentId: lastId,
  ///   ).future);
  ///
  ///   ref.read(feedPostsProvider.notifier).state = [
  ///     ...currentPosts,
  ///     ...result.posts,
  ///   ];
  ///   ref.read(lastDocIdProvider.notifier).state = result.lastDocumentId;
  /// }
  /// ```

  FeedFutureProvider call(FeedParams params, {String? lastDocumentId}) =>
      FeedFutureProvider._(
        argument: (params, lastDocumentId: lastDocumentId),
        from: this,
      );

  @override
  String toString() => r'feedFutureProvider';
}

/// Feed Sort Provider
///
/// **Current sort order**
/// - Persists sort selection
/// - Triggers feed reload on change

@ProviderFor(FeedSort)
const feedSortProvider = FeedSortProvider._();

/// Feed Sort Provider
///
/// **Current sort order**
/// - Persists sort selection
/// - Triggers feed reload on change
final class FeedSortProvider extends $NotifierProvider<FeedSort, FeedSortBy> {
  /// Feed Sort Provider
  ///
  /// **Current sort order**
  /// - Persists sort selection
  /// - Triggers feed reload on change
  const FeedSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedSortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedSortHash();

  @$internal
  @override
  FeedSort create() => FeedSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedSortBy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedSortBy>(value),
    );
  }
}

String _$feedSortHash() => r'374681e669ff56f2cda4adf8c6b700e8b9146317';

/// Feed Sort Provider
///
/// **Current sort order**
/// - Persists sort selection
/// - Triggers feed reload on change

abstract class _$FeedSort extends $Notifier<FeedSortBy> {
  FeedSortBy build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedSortBy, FeedSortBy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedSortBy, FeedSortBy>,
              FeedSortBy,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Feed Filter Provider
///
/// **Current filter settings**
/// - Persists filter selection
/// - Triggers feed reload on change

@ProviderFor(FeedFilterNotifier)
const feedFilterProvider = FeedFilterNotifierProvider._();

/// Feed Filter Provider
///
/// **Current filter settings**
/// - Persists filter selection
/// - Triggers feed reload on change
final class FeedFilterNotifierProvider
    extends $NotifierProvider<FeedFilterNotifier, FeedFilterModel> {
  /// Feed Filter Provider
  ///
  /// **Current filter settings**
  /// - Persists filter selection
  /// - Triggers feed reload on change
  const FeedFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedFilterNotifierHash();

  @$internal
  @override
  FeedFilterNotifier create() => FeedFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedFilterModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedFilterModel>(value),
    );
  }
}

String _$feedFilterNotifierHash() =>
    r'769c7a910370a02918dd8cbf6f430ce8aaf49b75';

/// Feed Filter Provider
///
/// **Current filter settings**
/// - Persists filter selection
/// - Triggers feed reload on change

abstract class _$FeedFilterNotifier extends $Notifier<FeedFilterModel> {
  FeedFilterModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedFilterModel, FeedFilterModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedFilterModel, FeedFilterModel>,
              FeedFilterModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Feed Pagination State Provider
///
/// **Pagination state management**
/// - Tracks current page, lastDocumentId, hasMore
/// - Use with feedFutureProvider for pagination

@ProviderFor(FeedPagination)
const feedPaginationProvider = FeedPaginationProvider._();

/// Feed Pagination State Provider
///
/// **Pagination state management**
/// - Tracks current page, lastDocumentId, hasMore
/// - Use with feedFutureProvider for pagination
final class FeedPaginationProvider
    extends $NotifierProvider<FeedPagination, FeedPaginationState> {
  /// Feed Pagination State Provider
  ///
  /// **Pagination state management**
  /// - Tracks current page, lastDocumentId, hasMore
  /// - Use with feedFutureProvider for pagination
  const FeedPaginationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedPaginationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedPaginationHash();

  @$internal
  @override
  FeedPagination create() => FeedPagination();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedPaginationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedPaginationState>(value),
    );
  }
}

String _$feedPaginationHash() => r'd05363c502e13e220131f091b9327cc736c5dbaa';

/// Feed Pagination State Provider
///
/// **Pagination state management**
/// - Tracks current page, lastDocumentId, hasMore
/// - Use with feedFutureProvider for pagination

abstract class _$FeedPagination extends $Notifier<FeedPaginationState> {
  FeedPaginationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedPaginationState, FeedPaginationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedPaginationState, FeedPaginationState>,
              FeedPaginationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Combined Feed Provider
///
/// **Reactive feed with sort + filter**
/// - Automatically reloads when sort or filter changes
/// - Combines multiple providers reactively
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(combinedFeedProvider);
/// // Automatically updates when sort/filter changes
/// ```

@ProviderFor(combinedFeed)
const combinedFeedProvider = CombinedFeedProvider._();

/// Combined Feed Provider
///
/// **Reactive feed with sort + filter**
/// - Automatically reloads when sort or filter changes
/// - Combines multiple providers reactively
///
/// **Usage**:
/// ```dart
/// final feedAsync = ref.watch(combinedFeedProvider);
/// // Automatically updates when sort/filter changes
/// ```

final class CombinedFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          Stream<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $StreamProvider<List<PostDisplay>> {
  /// Combined Feed Provider
  ///
  /// **Reactive feed with sort + filter**
  /// - Automatically reloads when sort or filter changes
  /// - Combines multiple providers reactively
  ///
  /// **Usage**:
  /// ```dart
  /// final feedAsync = ref.watch(combinedFeedProvider);
  /// // Automatically updates when sort/filter changes
  /// ```
  const CombinedFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'combinedFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$combinedFeedHash();

  @$internal
  @override
  $StreamProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostDisplay>> create(Ref ref) {
    return combinedFeed(ref);
  }
}

String _$combinedFeedHash() => r'7f8e69e3215ebd358a1131407c45217408ce068f';
