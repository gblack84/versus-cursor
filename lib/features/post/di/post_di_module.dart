/// Post Feature Dependency Injection Module
///
/// **Phase 3: Cache Integration**
/// **Phase 4: Idempotency Integration**
///
/// This module configures dependency injection for the Post feature
/// following Clean Architecture principles with Firebase-Centric v2.0:
/// - Services (Cache, Idempotency)
/// - Repositories (Direct Firestore + Cache + Idempotency)
/// - UseCases (Including CRUD operations)
/// - Providers (Auto-generated Riverpod)

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== Services Layer =====
import '/services/cache/unified_cache_service.dart';
import '/services/idempotency/idempotency_service.dart';
import '../data/services/post_cache_service.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_post_display_repository_v2.dart';
import '../domain/repositories/i_post_metrics_repository.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/post_repository_impl.dart';
import '../data/repositories/post_metrics_repository_impl.dart';

// ===== Domain Layer - UseCases (9 total) =====
// Query UseCases
import '../domain/usecases/get_feed_usecase.dart';
import '../domain/usecases/get_trending_posts_usecase.dart';
import '../domain/usecases/get_popular_posts_usecase.dart';
import '../domain/usecases/get_user_posts_usecase.dart';
import '../domain/usecases/get_post_detail_usecase.dart';
// CRUD UseCases (Phase 4: Idempotency)
import '../domain/usecases/create_post_usecase.dart';
import '../domain/usecases/update_post_usecase.dart';
import '../domain/usecases/delete_post_usecase.dart';
import '../domain/usecases/increment_view_count_usecase.dart';

// ===== Presentation Layer - Providers =====
// Note: Riverpod 2.x providers are auto-generated and don't need GetIt registration
// import '../presentation/providers/post_providers.dart';

/// Register all Post feature dependencies
///
/// **Phase 3: Cache Integration**
/// Call this function from main setupDependencyInjection()
void registerPostModule(GetIt getIt) {
  // ===== Services Registration =====
  _registerServices(getIt);

  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  // Note: Riverpod 2.x providers are auto-generated and don't need GetIt registration
  // Providers are accessed via ref.watch() in widgets
}

/// Register Services
///
/// **Phase 3: Cache Integration**
/// - PostCacheService uses UnifiedCacheService
/// - 3-Layer caching (Memory → Hive → Firestore)
///
/// **Phase 4: Idempotency Integration**
/// - IdempotencyService for duplicate operation prevention
void _registerServices(GetIt getIt) {
  // Idempotency Service (Phase 4)
  if (!getIt.isRegistered<IdempotencyService>()) {
    getIt.registerLazySingleton<IdempotencyService>(
      () => IdempotencyService(firestore: FirebaseFirestore.instance),
    );
  }

  // Post Cache Service
  getIt.registerLazySingleton<PostCacheService>(
    () => PostCacheService(
      cache: UnifiedCacheService.instance,
    ),
  );
}

/// Register Repository implementation
///
/// **Phase 3: Cache Integration**
/// - Direct Firestore SDK usage (no DataSource layer)
/// - Integrated with PostCacheService
///
/// **Phase 4: Idempotency Integration**
/// - IdempotencyService injection for CRUD operations
///
/// **Phase 6: Metrics Repository Migration** (2025-11-06)
/// - IPostMetricsRepository moved from Creation Feature
/// - Sharded counter support for metrics
void _registerRepositories(GetIt getIt) {
  // 1. Post Repository (Firebase-Centric v2.0 + Cache + Idempotency)
  getIt.registerLazySingleton<IPostDisplayRepositoryV2>(
    () => PostRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      cacheService: getIt<PostCacheService>(),
      idempotencyService: getIt<IdempotencyService>(),
    ),
  );

  // 2. Post Metrics Repository (Sharded counters + Idempotency)
  getIt.registerLazySingleton<IPostMetricsRepository>(
    () => PostMetricsRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      idempotencyService: getIt<IdempotencyService>(),
      // ShardUtils는 자동 생성 (기본값 사용)
    ),
  );
}

/// Register all UseCases (9 total)
///
/// **Phase 4: Added CRUD UseCases**
/// - CreatePostUseCase
/// - UpdatePostUseCase
/// - DeletePostUseCase
/// - IncrementViewCountUseCase
void _registerUseCases(GetIt getIt) {
  // ===== Query UseCases (5) =====

  // 1. Get Feed UseCase
  getIt.registerLazySingleton<GetFeedUseCase>(
    () => GetFeedUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 2. Get Trending Posts UseCase
  getIt.registerLazySingleton<GetTrendingPostsUseCase>(
    () => GetTrendingPostsUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 3. Get Popular Posts UseCase
  getIt.registerLazySingleton<GetPopularPostsUseCase>(
    () => GetPopularPostsUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 4. Get User Posts UseCase
  getIt.registerLazySingleton<GetUserPostsUseCase>(
    () => GetUserPostsUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 5. Get Post Detail UseCase (Phase 4: Updated with IncrementViewCountUseCase)
  getIt.registerLazySingleton<GetPostDetailUseCase>(
    () => GetPostDetailUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
      incrementViewCountUseCase: getIt<IncrementViewCountUseCase>(),
    ),
  );

  // ===== CRUD UseCases (4) - Phase 4: Idempotency =====

  // 6. Create Post UseCase
  getIt.registerLazySingleton<CreatePostUseCase>(
    () => CreatePostUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 7. Update Post UseCase
  getIt.registerLazySingleton<UpdatePostUseCase>(
    () => UpdatePostUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 8. Delete Post UseCase
  getIt.registerLazySingleton<DeletePostUseCase>(
    () => DeletePostUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // 9. Increment View Count UseCase
  getIt.registerLazySingleton<IncrementViewCountUseCase>(
    () => IncrementViewCountUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );
}

/// Register Presentation Layer Providers
///
/// **Phase 2: Riverpod Migration**
/// - Riverpod 2.x providers are auto-generated and don't need GetIt registration
/// - Providers are accessed via ref.watch() or ref.read() in widgets
/// - Provider instances are managed by Riverpod's dependency injection system
///
/// **Old ChangeNotifier Providers** (REMOVED):
/// - FeedProvider
/// - PostDetailProvider
/// - TrendingPostsProvider
/// - PopularPostsProvider
/// - UserPostsProvider
///
/// **New Riverpod Providers** (in post_providers.dart):
/// - @riverpod providers are automatically registered
/// - Use ref.watch(postDetailStreamProvider(postId)) in widgets
/// - No manual registration required
