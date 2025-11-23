/// Profile Feature Dependency Injection Module
///
/// This module configures dependency injection for the Profile feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote/Local)
/// - Repositories
/// - UseCases
/// - Providers
/// - Contracts

import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ===== Core Services =====
import '/services/cache/unified_cache_service.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_profile_storage_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/repositories/i_characters_repository.dart';
import '../domain/repositories/i_interests_repository.dart';
import '../domain/repositories/i_profile_repository.dart';
import '../domain/repositories/i_profile_post_repository.dart';

// ===== Data Layer - DataSource Implementations (Adapters) =====
// Note: Profile DataSource removed in Phase 4 (Firebase-Centric v2.0)
// Only Storage DataSource remains for file upload functionality
import '../data/datasources/profile_storage_datasource.dart';
import '../data/datasources/profile_storage_datasource_impl.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/characters_repository_impl.dart';
import '../data/repositories/interests_repository_impl.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/repositories/profile_storage_repository_impl.dart';
import '../data/repositories/profile_post_repository_impl.dart';

// ===== Domain Layer - UseCases (16 total) =====
// Profile UseCases (9)
import '../domain/usecases/profile/get_user_profile_usecase.dart';
import '../domain/usecases/profile/get_current_user_profile_usecase.dart';
import '../domain/usecases/profile/update_user_profile_usecase.dart';
import '../domain/usecases/profile/update_language_usecase.dart';
import '../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../domain/usecases/profile/delete_user_profile_usecase.dart';
import '../domain/usecases/profile/watch_user_profile_usecase.dart';
import '../domain/usecases/profile/get_profile_completion_usecase.dart';
import '../domain/usecases/profile/get_profile_info_usecase.dart';

// Activity UseCases (1) - Added 2025-11-11
import '../domain/usecases/activity/update_last_active_usecase.dart';

// Storage UseCases (2) - Added 2025-11-10
import '../domain/usecases/storage/select_media_usecase.dart';
import '../domain/usecases/storage/validate_media_usecase.dart';

// Settings UseCases (2)
import '../domain/usecases/settings/get_user_settings_usecase.dart';
import '../domain/usecases/settings/update_user_settings_usecase.dart';

// Characters UseCases (1)
import '../domain/usecases/characters/get_available_characters_usecase.dart';

// Interests UseCases (2)
import '../domain/usecases/interests/get_user_interests_usecase.dart';
import '../domain/usecases/interests/update_user_interests_usecase.dart';

// ===== Presentation Layer - Providers =====
// Phase 3: Riverpod 마이그레이션 완료 - ChangeNotifier Providers 제거됨
// 모든 UI 컴포넌트가 Riverpod 2.x의 profile_providers.dart 사용

/// Register all Profile feature dependencies
/// Call this function from main setupDependencyInjection()
///
/// IMPORTANT: Must be called BEFORE registerAuthModule()
/// Auth Feature uses IUserRepository from Profile Feature
void registerProfileModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  // Phase 3: Riverpod 마이그레이션 완료 - ChangeNotifier Providers 제거됨
}

/// Register Remote and Local DataSources
void _registerDataSources(GetIt getIt) {
  // Storage DataSource (Firebase Storage)
  getIt.registerLazySingleton<IProfileStorageDataSource>(
    () => ProfileStorageDataSourceImpl(),
  );

  // Profile DataSource (Firebase Firestore) - REMOVED in Phase 4
  // Firebase-Centric v2.0: Repositories access FirebaseFirestore directly
}

/// Register Repository implementations
void _registerRepositories(GetIt getIt) {
  // Storage Repository (Firebase Storage)
  getIt.registerLazySingleton<IProfileStorageRepository>(
    () => ProfileStorageRepositoryImpl(
      dataSource: getIt<IProfileStorageDataSource>(),
    ),
  );

  // User Repository (Singleton pattern with explicit initialization)
  // IMPORTANT: Initialize BEFORE registering the singleton
  // Contract 패턴 폐기 (2025-11-09): FirebaseAuth 직접 사용
  final auth = FirebaseAuth.instance;
  final cacheService = getIt<UnifiedCacheService>();  // GetIt을 통한 안전한 접근

  UserRepositoryImpl.initialize(auth, cacheService);

  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl.instance,
  );

  // Characters Repository
  getIt.registerLazySingleton<ICharactersRepository>(
    () => CharactersRepositoryImpl(),
  );

  // Interests Repository (Firebase-Centric v2.0)
  getIt.registerLazySingleton<IInterestsRepository>(
    () => InterestsRepositoryImpl(),
  );

  // Profile Repository (Firebase-Centric v2.0)
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(),
  );

  // Profile Post Repository (Phase 6.5 - Feature 독립성 확보)
  getIt.registerLazySingleton<IProfilePostRepository>(
    () => ProfilePostRepositoryImpl(),
  );
}

/// Register all UseCases (16 total)
void _registerUseCases(GetIt getIt) {
  // ===== Profile UseCases (9) =====

  getIt.registerFactory(
    () => GetUserProfileUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => GetCurrentUserProfileUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => UpdateUserProfileUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => UpdateLanguageUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => UploadProfileImageUseCase(
      storageRepository: getIt<IProfileStorageRepository>(),
    ),
  );

  getIt.registerFactory(
    () => DeleteUserProfileUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => WatchUserProfileUseCase(
      getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => GetProfileCompletionUseCase(
      repository: getIt<IProfileRepository>(),
    ),
  );

  getIt.registerFactory(
    () => GetProfileInfoUseCase(
      repository: getIt<IProfileRepository>(),
    ),
  );

  // ===== Activity UseCases (1) =====

  getIt.registerFactory(
    () => UpdateLastActiveUseCase(
      getIt<IProfileRepository>(),
    ),
  );

  // ===== Settings UseCases (2) =====

  getIt.registerFactory(
    () => GetUserSettingsUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  getIt.registerFactory(
    () => UpdateUserSettingsUseCase(
      repository: getIt<IUserRepository>(),
    ),
  );

  // ===== Characters UseCases (1) =====

  getIt.registerFactory(
    () => GetAvailableCharactersUseCase(
      repository: getIt<ICharactersRepository>(),
    ),
  );

  // ===== Interests UseCases (2) =====

  getIt.registerFactory(
    () => GetUserInterestsUseCase(
      repository: getIt<IInterestsRepository>(),
    ),
  );

  getIt.registerFactory(
    () => UpdateUserInterestsUseCase(
      repository: getIt<IInterestsRepository>(),
    ),
  );

  // ===== Storage UseCases (2) - Added 2025-11-10 =====

  getIt.registerFactory(
    () => SelectMediaUseCase(
      storageRepository: getIt<IProfileStorageRepository>(),
    ),
  );

  getIt.registerFactory(
    () => ValidateMediaUseCase(
      storageRepository: getIt<IProfileStorageRepository>(),
    ),
  );
}

