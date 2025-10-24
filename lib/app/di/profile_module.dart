/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정
///
/// 이 파일은 레거시 DI 시스템의 일부입니다.
/// 신규 시스템은 /features/profile/di/profile_di_module.dart를 사용합니다.
///
/// 삭제 조건:
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
///
/// 관련 이슈: Firebase 최적화 마이그레이션

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'feature_modules.dart';
import '../contracts/auth_contract.dart';
import '../contracts/user_contract.dart';

// ===== Repositories =====
import '../../features/profile/domain/repositories/i_user_repository.dart';
import '../../features/profile/data/repositories/user_repository_impl.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/i_characters_repository.dart';
import '../../features/profile/data/repositories/characters_repository_impl.dart';
import '../../features/profile/domain/repositories/i_settings_repository.dart';
import '../../features/profile/data/repositories/settings_repository_impl.dart';
import '../../features/profile/domain/repositories/i_interests_repository.dart';
import '../../features/profile/data/repositories/interests_repository_impl.dart';

// ===== DataSources =====
import '../../features/profile/data/datasources/interfaces/i_profile_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_profile_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_settings_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_settings_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_storage_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_storage_datasource.dart';
import '../../features/profile/data/datasources/profile_storage_datasource_impl.dart';

// ===== Domain Repositories (for Architecture fix) =====
import '../../features/profile/domain/repositories/i_profile_storage_repository.dart';

// ===== Profile UseCases =====
import '../../features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../features/profile/domain/usecases/profile/get_profile_completion_usecase.dart';
import '../../features/profile/domain/usecases/profile/get_profile_info_usecase.dart';
import '../../features/profile/domain/usecases/profile/delete_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/watch_user_profile_usecase.dart';
// Phase 6: 미사용 UseCase 삭제 (2025-01-21)
// - block_user_usecase.dart
// - report_user_usecase.dart
// - get_suggested_profiles_usecase.dart

// ===== Characters UseCases =====
import '../../features/profile/domain/usecases/characters/get_available_characters_usecase.dart';

// ===== Settings UseCases =====
import '../../features/profile/domain/usecases/settings/get_user_settings_usecase.dart';
import '../../features/profile/domain/usecases/settings/update_user_settings_usecase.dart';

// ===== Interests UseCases =====
import '../../features/profile/domain/usecases/interests/get_user_interests_usecase.dart';
import '../../features/profile/domain/usecases/interests/update_user_interests_usecase.dart';

// ===== Providers =====
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/providers/characters_provider.dart';
import '../../features/profile/presentation/providers/settings_provider.dart';
import '../../features/profile/presentation/providers/interests_provider.dart';
import '../../features/profile/presentation/providers/profile_edit_provider.dart';

/// Profile Feature DI Module (Clean Architecture v4.0)
///
/// Manages dependency injection for profile-related services
/// following Clean Architecture principles
///
/// **등록 순서**:
/// 1. DataSources (인터페이스 → 구현체)
/// 2. Repositories (인터페이스 → 구현체)
/// 3. UseCases (Factory 등록)
/// 4. Providers (Singleton 등록)
class ProfileModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Profile';

  @override
  void register(GetIt sl) {
    // ===== 1. DataSources 등록 =====

    if (!sl.isRegistered<IProfileDataSource>()) {
      sl.registerLazySingleton<IProfileDataSource>(
        () => FirebaseProfileDataSource(
          firestore: FirebaseFirestore.instance,
        ),
      );
    }

    if (!sl.isRegistered<ISettingsDataSource>()) {
      sl.registerLazySingleton<ISettingsDataSource>(
        () => FirebaseSettingsDataSource(
          firestore: FirebaseFirestore.instance,
        ),
      );
    }

    if (!sl.isRegistered<IStorageDataSource>()) {
      sl.registerLazySingleton<IStorageDataSource>(
        () => FirebaseStorageDataSource(
          storage: FirebaseStorage.instance,
        ),
      );
    }

    // Profile Storage DataSource (Architecture Fix: implements Domain Repository)
    if (!sl.isRegistered<IProfileStorageRepository>()) {
      sl.registerLazySingleton<IProfileStorageRepository>(
        () => ProfileStorageDataSourceImpl(),
      );
    }

    // ===== 2. Repositories 등록 =====

    if (!sl.isRegistered<IUserRepository>()) {
      // Phase 2: AuthContract 주입
      // AuthModule이 ProfileModule보다 먼저 등록되어 있어야 함
      final authContract = sl<AuthContract>();
      UserRepositoryImpl.initialize(authContract);

      sl.registerLazySingleton<IUserRepository>(
        () => UserRepositoryImpl.instance,
      );
    }

    // Phase 5: UserContract 등록 (Auth Feature가 Profile 작업을 요청할 때 사용)
    // Same instance as IUserRepository, different interface
    if (!sl.isRegistered<UserContract>()) {
      sl.registerLazySingleton<UserContract>(
        () => UserRepositoryImpl.instance,
      );
    }

    if (!sl.isRegistered<IProfileRepository>()) {
      sl.registerLazySingleton<IProfileRepository>(
        () => ProfileRepositoryImpl(
          dataSource: sl<IProfileDataSource>(),
        ),
      );
    }

    if (!sl.isRegistered<ICharactersRepository>()) {
      sl.registerLazySingleton<ICharactersRepository>(
        () => CharactersRepositoryImpl(
          firestore: FirebaseFirestore.instance,
        ),
      );
    }

    if (!sl.isRegistered<ISettingsRepository>()) {
      sl.registerLazySingleton<ISettingsRepository>(
        () => SettingsRepositoryImpl(
          dataSource: sl<ISettingsDataSource>(),
        ),
      );
    }

    if (!sl.isRegistered<IInterestsRepository>()) {
      sl.registerLazySingleton<IInterestsRepository>(
        () => InterestsRepositoryImpl(
          dataSource: sl<IProfileDataSource>(),
        ),
      );
    }

    // ===== 3. Profile UseCases 등록 =====

    if (!sl.isRegistered<GetUserProfileUseCase>()) {
      sl.registerFactory(
        () => GetUserProfileUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    // Phase 2: 현재 사용자 프로필 조회 UseCase
    if (!sl.isRegistered<GetCurrentUserProfileUseCase>()) {
      sl.registerFactory(
        () => GetCurrentUserProfileUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<UpdateUserProfileUseCase>()) {
      sl.registerFactory(
        () => UpdateUserProfileUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<UploadProfileImageUseCase>()) {
      sl.registerFactory(
        () => UploadProfileImageUseCase(
          storageRepository: sl<IProfileStorageRepository>(),
        ),
      );
    }

    // Phase 6: 프로필 완성도 조회 UseCase (2025-01-21)
    if (!sl.isRegistered<GetProfileCompletionUseCase>()) {
      sl.registerFactory(
        () => GetProfileCompletionUseCase(
          repository: sl<IProfileRepository>(),
        ),
      );
    }

    // Phase 6 복원: 계정 삭제 UseCase (2025-01-21)
    if (!sl.isRegistered<DeleteUserProfileUseCase>()) {
      sl.registerFactory(
        () => DeleteUserProfileUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    // 🆕 Real-time Sync: 사용자 프로필 실시간 감시 UseCase (2025-01-20)
    if (!sl.isRegistered<WatchUserProfileUseCase>()) {
      sl.registerFactory(
        () => WatchUserProfileUseCase(
          sl<IUserRepository>(),
        ),
      );
    }

    // Phase 6: 미사용 UseCase 등록 제거 (2025-01-21)
    // - BlockUserUseCase → Social Feature 구현 시 재생성
    // - ReportUserUseCase → Social Feature 구현 시 재생성
    // - GetSuggestedProfilesUseCase → Search Feature 구현 시 재생성

    // ===== 4. Characters UseCases 등록 =====

    if (!sl.isRegistered<GetAvailableCharactersUseCase>()) {
      sl.registerFactory(
        () => GetAvailableCharactersUseCase(
          repository: sl<ICharactersRepository>(),
        ),
      );
    }

    // ===== 5. Settings UseCases 등록 =====

    if (!sl.isRegistered<GetUserSettingsUseCase>()) {
      sl.registerFactory(
        () => GetUserSettingsUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<UpdateUserSettingsUseCase>()) {
      sl.registerFactory(
        () => UpdateUserSettingsUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    // ===== 6. Interests UseCases 등록 =====

    if (!sl.isRegistered<GetUserInterestsUseCase>()) {
      sl.registerFactory(
        () => GetUserInterestsUseCase(
          repository: sl<IInterestsRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<UpdateUserInterestsUseCase>()) {
      sl.registerFactory(
        () => UpdateUserInterestsUseCase(
          repository: sl<IInterestsRepository>(),
        ),
      );
    }

    // ===== 7. Providers 등록 (Singleton) =====

    if (!sl.isRegistered<ProfileProvider>()) {
      sl.registerLazySingleton<ProfileProvider>(
        () => ProfileProvider(
          getProfileUseCase: sl<GetUserProfileUseCase>(),
          getCurrentProfileUseCase: sl<GetCurrentUserProfileUseCase>(),  // Phase 2
          updateProfileUseCase: sl<UpdateUserProfileUseCase>(),
          uploadImageUseCase: sl<UploadProfileImageUseCase>(),
          getProfileCompletionUseCase: sl<GetProfileCompletionUseCase>(),  // Phase 6
          getProfileInfoUseCase: sl<GetProfileInfoUseCase>(),  // Phase 6.1
          watchProfileUseCase: sl<WatchUserProfileUseCase>(),  // 🆕 Real-time Sync (2025-01-20)
        ),
      );
    }

    if (!sl.isRegistered<CharactersProvider>()) {
      sl.registerLazySingleton<CharactersProvider>(
        () => CharactersProvider(
          getAvailableCharactersUseCase: sl<GetAvailableCharactersUseCase>(),
        ),
      );
    }

    if (!sl.isRegistered<SettingsProvider>()) {
      sl.registerLazySingleton<SettingsProvider>(
        () => SettingsProvider(
          getSettingsUseCase: sl<GetUserSettingsUseCase>(),
          updateSettingsUseCase: sl<UpdateUserSettingsUseCase>(),
          deleteProfileUseCase: sl<DeleteUserProfileUseCase>(),  // Phase 6 복원
        ),
      );
    }

    // FriendsProvider removed - Friends feature not yet implemented

    if (!sl.isRegistered<InterestsProvider>()) {
      sl.registerLazySingleton<InterestsProvider>(
        () => InterestsProvider(
          getUserInterestsUseCase: sl<GetUserInterestsUseCase>(),
          updateUserInterestsUseCase: sl<UpdateUserInterestsUseCase>(),
        ),
      );
    }

    if (!sl.isRegistered<ProfileEditProvider>()) {
      sl.registerLazySingleton<ProfileEditProvider>(
        () => ProfileEditProvider(
          updateProfileUseCase: sl<UpdateUserProfileUseCase>(),
          getUserProfileUseCase: sl<GetUserProfileUseCase>(),
          uploadImageUseCase: sl<UploadProfileImageUseCase>(),
        ),
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IUserRepository>()) {
      sl.unregister<IUserRepository>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
