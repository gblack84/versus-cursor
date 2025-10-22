/// Post Feature Dependency Injection Module
///
/// This module configures dependency injection for the Post feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote)
/// - Repositories
/// - UseCases
/// - Providers
/// - Voting Integration

import 'package:get_it/get_it.dart';

// ===== Data Layer - DataSource Interfaces =====
import '../data/datasources/interfaces/i_post_display_datasource.dart';

// ===== Data Layer - DataSource Implementations =====
import '../data/datasources/firebase_post_display_datasource.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_post_display_repository_v2.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/post_display_repository_v2_impl.dart';

// ===== Domain Layer - UseCases (5 total) =====
import '../domain/usecases/get_feed_usecase.dart';
import '../domain/usecases/get_trending_posts_usecase.dart';
import '../domain/usecases/get_popular_posts_usecase.dart';
import '../domain/usecases/get_user_posts_usecase.dart';
import '../domain/usecases/get_post_detail_usecase.dart';

// ===== Presentation Layer - Providers (5 total) =====
import '../presentation/providers/feed_provider.dart';
import '../presentation/providers/post_detail_provider.dart';
import '../presentation/providers/trending_posts_provider.dart';
import '../presentation/providers/popular_posts_provider.dart';
import '../presentation/providers/user_posts_provider.dart';

// ===== Voting Integration =====
// Post Feature owns VoteTimerService, but Voting Feature uses it via adapter
import '/features/voting/domain/services/vote_timer_service.dart';
import '/features/voting/domain/services/i_vote_timer_service.dart';
import '/features/voting/data/adapters/vote_timer_adapter.dart';

/// Register all Post feature dependencies
/// Call this function from main setupDependencyInjection()
void registerPostModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);

  // ===== Voting Integration Registration =====
  _registerVotingIntegration(getIt);
}

/// Register Remote DataSource
void _registerDataSources(GetIt getIt) {
  // Post Display DataSource (Firebase Firestore)
  getIt.registerLazySingleton<IPostDisplayDataSource>(
    () => FirebasePostDisplayDataSource(),
  );
}

/// Register Repository implementation
void _registerRepositories(GetIt getIt) {
  // Post Display Repository V2
  getIt.registerLazySingleton<IPostDisplayRepositoryV2>(
    () => PostDisplayRepositoryV2Impl(
      dataSource: getIt<IPostDisplayDataSource>(),
    ),
  );
}

/// Register all UseCases (5 total)
void _registerUseCases(GetIt getIt) {
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

  // 5. Get Post Detail UseCase
  getIt.registerLazySingleton<GetPostDetailUseCase>(
    () => GetPostDetailUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );
}

/// Register Presentation Layer Providers (5 total)
/// All providers use Factory pattern for per-screen instances
void _registerProviders(GetIt getIt) {
  // Feed Provider (Factory - 매번 새 인스턴스)
  getIt.registerFactory<FeedProvider>(
    () => FeedProvider(
      getFeedUseCase: getIt<GetFeedUseCase>(),
    ),
  );

  // Post Detail Provider (Factory - 매번 새 인스턴스)
  getIt.registerFactory<PostDetailProvider>(
    () => PostDetailProvider(
      getPostDetailUseCase: getIt<GetPostDetailUseCase>(),
    ),
  );

  // Trending Posts Provider (Factory - 매번 새 인스턴스)
  getIt.registerFactory<TrendingPostsProvider>(
    () => TrendingPostsProvider(
      getTrendingPostsUseCase: getIt<GetTrendingPostsUseCase>(),
    ),
  );

  // Popular Posts Provider (Factory - 매번 새 인스턴스)
  getIt.registerFactory<PopularPostsProvider>(
    () => PopularPostsProvider(
      getPopularPostsUseCase: getIt<GetPopularPostsUseCase>(),
    ),
  );

  // User Posts Provider (Factory - 매번 새 인스턴스)
  getIt.registerFactory<UserPostsProvider>(
    () => UserPostsProvider(
      getUserPostsUseCase: getIt<GetUserPostsUseCase>(),
    ),
  );
}

/// Register Voting Integration
///
/// Post Feature owns VoteTimerService (timer is a Post concept),
/// but Voting Feature uses it via IVoteTimerService adapter.
/// This implements cross-feature communication with loose coupling.
void _registerVotingIntegration(GetIt getIt) {
  // VoteTimerService (owned by Post Feature)
  getIt.registerLazySingleton<VoteTimerService>(
    () => VoteTimerService(),
  );

  // IVoteTimerService Adapter (used by Voting Feature)
  // This adapter bridges Post and Voting features without direct dependency
  getIt.registerLazySingleton<IVoteTimerService>(
    () => VoteTimerAdapter(
      getIt<VoteTimerService>(),
    ),
  );
}
