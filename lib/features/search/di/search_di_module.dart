/// Search Feature Dependency Injection Module
///
/// This module configures dependency injection for the Search feature
/// following Clean Architecture principles with proper layering:
/// - Repositories
/// - UseCases (TODO: Implement when ready)
/// - Providers
///
/// **Current Status** (2025-01-20):
/// - Repository layer: Implemented with singleton pattern
/// - Provider layer: Basic skeleton implemented
/// - UseCases layer: Pending implementation (TODO)

import 'package:get_it/get_it.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_search_repository.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/search_repository_impl.dart';

// ===== Domain Layer - UseCases =====
// Rankings UseCases (migrated from Voting feature)
import '../domain/usecases/get_rankings_use_case.dart';
import '../domain/usecases/stream_rankings_use_case.dart';
import '../domain/usecases/update_rankings_use_case.dart';

// TODO: Uncomment and import when other UseCases are implemented
// import '../domain/usecases/search_posts_usecase.dart';
// import '../domain/usecases/search_users_usecase.dart';
// import '../domain/usecases/get_search_history_usecase.dart';
// import '../domain/usecases/save_search_history_usecase.dart';
// import '../domain/usecases/clear_search_history_usecase.dart';

// ===== Presentation Layer - Providers =====
import '../presentation/providers/search_provider.dart';

/// Register all Search feature dependencies
/// Call this function from main setupDependencyInjection()
void registerSearchModule(GetIt getIt) {
  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

/// Register Repository implementation
void _registerRepositories(GetIt getIt) {
  // Search Repository (Singleton pattern - uses existing instance)
  getIt.registerLazySingleton<ISearchRepository>(
    () => SearchRepositoryImpl.instance,
  );
}

/// Register all UseCases
void _registerUseCases(GetIt getIt) {
  // Rankings Operations (migrated from Voting feature)
  getIt.registerFactory<GetRankingsUseCase>(
    () => GetRankingsUseCase(getIt<ISearchRepository>()),
  );

  getIt.registerFactory<StreamRankingsUseCase>(
    () => StreamRankingsUseCase(getIt<ISearchRepository>()),
  );

  getIt.registerFactory<UpdateRankingsUseCase>(
    () => UpdateRankingsUseCase(getIt<ISearchRepository>()),
  );

  // TODO: Uncomment when other UseCases are implemented
  // // 1. Search Posts UseCase
  // getIt.registerLazySingleton<SearchPostsUseCase>(
  //   () => SearchPostsUseCase(
  //     searchRepository: getIt<ISearchRepository>(),
  //   ),
  // );
  //
  // // 2. Search Users UseCase
  // getIt.registerLazySingleton<SearchUsersUseCase>(
  //   () => SearchUsersUseCase(
  //     searchRepository: getIt<ISearchRepository>(),
  //   ),
  // );
  //
  // // 3. Get Search History UseCase
  // getIt.registerLazySingleton<GetSearchHistoryUseCase>(
  //   () => GetSearchHistoryUseCase(
  //     searchRepository: getIt<ISearchRepository>(),
  //   ),
  // );
  //
  // // 4. Save Search History UseCase
  // getIt.registerLazySingleton<SaveSearchHistoryUseCase>(
  //   () => SaveSearchHistoryUseCase(
  //     searchRepository: getIt<ISearchRepository>(),
  //   ),
  // );
  //
  // // 5. Clear Search History UseCase
  // getIt.registerLazySingleton<ClearSearchHistoryUseCase>(
  //   () => ClearSearchHistoryUseCase(
  //     searchRepository: getIt<ISearchRepository>(),
  //   ),
  // );
}

/// Register Presentation Layer Providers
/// Factory pattern for per-screen instances
void _registerProviders(GetIt getIt) {
  // Search Provider (Factory - 매번 새 인스턴스)
  // TODO: Update to inject UseCases when implemented
  getIt.registerFactory<SearchProvider>(
    () => SearchProvider(),
  );
}
