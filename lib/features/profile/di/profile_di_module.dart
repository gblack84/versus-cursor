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
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== App Layer - Contracts =====
import '/app/contracts/user_contract.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_profile_storage_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/repositories/i_characters_repository.dart';
import '../domain/repositories/i_interests_repository.dart';
import '../domain/repositories/i_profile_repository.dart';

// ===== Data Layer - DataSource Interfaces (Ports) =====
import '../data/datasources/interfaces/i_profile_datasource.dart';

// ===== Data Layer - DataSource Implementations (Adapters) =====
import '../data/datasources/profile_storage_datasource.dart';
import '../data/datasources/profile_storage_datasource_impl.dart';
import '../data/datasources/implementations/firebase_profile_datasource.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/characters_repository_impl.dart';
import '../data/repositories/interests_repository_impl.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/repositories/profile_storage_repository_impl.dart';

// ===== Domain Layer - UseCases (13 total) =====
// Profile UseCases (8)
import '../domain/usecases/profile/get_user_profile_usecase.dart';
import '../domain/usecases/profile/get_current_user_profile_usecase.dart';
import '../domain/usecases/profile/update_user_profile_usecase.dart';
import '../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../domain/usecases/profile/delete_user_profile_usecase.dart';
import '../domain/usecases/profile/watch_user_profile_usecase.dart';
import '../domain/usecases/profile/get_profile_completion_usecase.dart';
import '../domain/usecases/profile/get_profile_info_usecase.dart';

// Settings UseCases (2)
import '../domain/usecases/settings/get_user_settings_usecase.dart';
import '../domain/usecases/settings/update_user_settings_usecase.dart';

// Characters UseCases (1)
import '../domain/usecases/characters/get_available_characters_usecase.dart';

// Interests UseCases (2)
import '../domain/usecases/interests/get_user_interests_usecase.dart';
import '../domain/usecases/interests/update_user_interests_usecase.dart';

// ===== Presentation Layer - Providers =====
import '../presentation/providers/profile_provider.dart';
import '../presentation/providers/characters_provider.dart';
import '../presentation/providers/interests_provider.dart';
import '../presentation/providers/settings_provider.dart';

/// Register all Profile feature dependencies
/// Call this function from main setupDependencyInjection()
///
/// IMPORTANT: Must be called BEFORE registerAuthModule()
/// Auth Feature depends on UserContract from Profile Feature
void registerProfileModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== UserContract Registration =====
  _registerContract(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

/// Register Remote and Local DataSources
void _registerDataSources(GetIt getIt) {
  // Storage DataSource (Firebase Storage)
  getIt.registerLazySingleton<IProfileStorageDataSource>(
    () => ProfileStorageDataSourceImpl(),
  );

  // Profile DataSource (Firebase Firestore)
  getIt.registerLazySingleton<IProfileDataSource>(
    () => FirebaseProfileDataSource(
      firestore: FirebaseFirestore.instance,
    ),
  );
}

/// Register Repository implementations
void _registerRepositories(GetIt getIt) {
  // Storage Repository (Firebase Storage)
  getIt.registerLazySingleton<IProfileStorageRepository>(
    () => ProfileStorageRepositoryImpl(
      dataSource: getIt<IProfileStorageDataSource>(),
    ),
  );

  // User Repository (Singleton pattern)
  // Note: UserRepositoryImpl.initialize() must be called first
  // This happens automatically when the singleton instance is accessed
  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl.instance,
  );

  // Characters Repository
  getIt.registerLazySingleton<ICharactersRepository>(
    () => CharactersRepositoryImpl(),
  );

  // Interests Repository
  getIt.registerLazySingleton<IInterestsRepository>(
    () => InterestsRepositoryImpl(
      dataSource: getIt<IProfileDataSource>(),
    ),
  );

  // Profile Repository
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(
      dataSource: getIt<IProfileDataSource>(),
    ),
  );
}

/// Register UserContract
/// UserRepositoryImpl implements both IUserRepository and UserContract (Dual Interface)
void _registerContract(GetIt getIt) {
  getIt.registerLazySingleton<UserContract>(
    () => UserRepositoryImpl.instance,
  );
}

/// Register all UseCases (13 total)
void _registerUseCases(GetIt getIt) {
  // ===== Profile UseCases (8) =====

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
}

/// Register Presentation Layer Providers
void _registerProviders(GetIt getIt) {
  // ProfileProvider - manages user profile state
  getIt.registerFactory(
    () => ProfileProvider(
      getProfileUseCase: getIt<GetUserProfileUseCase>(),
      getCurrentProfileUseCase: getIt<GetCurrentUserProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateUserProfileUseCase>(),
      uploadImageUseCase: getIt<UploadProfileImageUseCase>(),
      getProfileCompletionUseCase: getIt<GetProfileCompletionUseCase>(),
      getProfileInfoUseCase: getIt<GetProfileInfoUseCase>(),
      watchProfileUseCase: getIt<WatchUserProfileUseCase>(),
    ),
  );

  // CharactersProvider - manages character avatars
  getIt.registerFactory(
    () => CharactersProvider(
      getAvailableCharactersUseCase: getIt<GetAvailableCharactersUseCase>(),
    ),
  );

  // InterestsProvider - manages user interests
  getIt.registerFactory(
    () => InterestsProvider(
      getUserInterestsUseCase: getIt<GetUserInterestsUseCase>(),
      updateUserInterestsUseCase: getIt<UpdateUserInterestsUseCase>(),
    ),
  );

  // SettingsProvider - manages user settings
  getIt.registerFactory(
    () => SettingsProvider(
      getSettingsUseCase: getIt<GetUserSettingsUseCase>(),
      updateSettingsUseCase: getIt<UpdateUserSettingsUseCase>(),
      deleteProfileUseCase: getIt<DeleteUserProfileUseCase>(),
    ),
  );
}
