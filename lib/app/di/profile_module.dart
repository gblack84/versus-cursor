import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'feature_modules.dart';

// ===== Repositories =====
import '../../features/profile/domain/repositories/i_user_repository.dart';
import '../../features/profile/data/repositories/user_repository_impl.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/i_characters_repository.dart';
import '../../features/profile/data/repositories/characters_repository_impl.dart';
import '../../features/profile/domain/repositories/i_settings_repository.dart';
import '../../features/profile/data/repositories/settings_repository_impl.dart';
import '../../features/profile/domain/repositories/i_friends_repository.dart';
import '../../features/profile/data/repositories/friends_repository_impl.dart';
import '../../features/profile/domain/repositories/i_interests_repository.dart';
import '../../features/profile/data/repositories/interests_repository_impl.dart';

// ===== DataSources =====
import '../../features/profile/data/datasources/interfaces/i_profile_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_profile_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_settings_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_settings_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_friends_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_friends_datasource.dart';
import '../../features/profile/data/datasources/interfaces/i_storage_datasource.dart';
import '../../features/profile/data/datasources/implementations/firebase_storage_datasource.dart';

// ===== Profile UseCases =====
import '../../features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../features/profile/domain/usecases/profile/get_profile_info_usecase.dart';
import '../../features/profile/domain/usecases/profile/block_user_usecase.dart';
import '../../features/profile/domain/usecases/profile/report_user_usecase.dart';
import '../../features/profile/domain/usecases/profile/get_suggested_profiles_usecase.dart';

// ===== Characters UseCases =====
import '../../features/profile/domain/usecases/characters/get_user_character_usecase.dart';
import '../../features/profile/domain/usecases/characters/set_user_character_usecase.dart';
import '../../features/profile/domain/usecases/characters/get_available_characters_usecase.dart';

// ===== Settings UseCases =====
import '../../features/profile/domain/usecases/settings/get_user_settings_usecase.dart';
import '../../features/profile/domain/usecases/settings/update_user_settings_usecase.dart';
import '../../features/profile/domain/usecases/settings/get_notification_settings_usecase.dart';
import '../../features/profile/domain/usecases/settings/update_notification_settings_usecase.dart';

// ===== Friends UseCases =====
import '../../features/profile/domain/usecases/friends/get_friends_list_usecase.dart';
import '../../features/profile/domain/usecases/friends/add_friend_usecase.dart';
import '../../features/profile/domain/usecases/friends/remove_friend_usecase.dart';
import '../../features/profile/domain/usecases/friends/send_friend_request_usecase.dart';
import '../../features/profile/domain/usecases/friends/accept_friend_request_usecase.dart';
import '../../features/profile/domain/usecases/friends/reject_friend_request_usecase.dart';

// ===== Interests UseCases =====
import '../../features/profile/domain/usecases/interests/get_user_interests_usecase.dart';
import '../../features/profile/domain/usecases/interests/update_user_interests_usecase.dart';

// ===== Providers =====
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/providers/characters_provider.dart';
import '../../features/profile/presentation/providers/settings_provider.dart';
import '../../features/profile/presentation/providers/friends_provider.dart';
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

    if (!sl.isRegistered<IFriendsDataSource>()) {
      sl.registerLazySingleton<IFriendsDataSource>(
        () => FirebaseFriendsDataSource(
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

    // ===== 2. Repositories 등록 =====

    if (!sl.isRegistered<IUserRepository>()) {
      sl.registerLazySingleton<IUserRepository>(
        () => UserRepositoryImpl.instance,
      );
    }

    if (!sl.isRegistered<IProfileRepository>()) {
      sl.registerLazySingleton<IProfileRepository>(
        () => ProfileRepositoryImpl(
          dataSource: sl<IProfileDataSource>(),
          storageDataSource: sl<IStorageDataSource>(),
        ),
      );
    }

    if (!sl.isRegistered<ICharactersRepository>()) {
      sl.registerLazySingleton<ICharactersRepository>(
        () => CharactersRepositoryImpl(
          dataSource: sl<IProfileDataSource>(),
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

    if (!sl.isRegistered<IFriendsRepository>()) {
      sl.registerLazySingleton<IFriendsRepository>(
        () => FriendsRepositoryImpl(
          dataSource: sl<IFriendsDataSource>(),
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

    if (!sl.isRegistered<UpdateUserProfileUseCase>()) {
      sl.registerFactory(
        () => UpdateUserProfileUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<UploadProfileImageUseCase>()) {
      sl.registerFactory(
        () => UploadProfileImageUseCase(),
      );
    }

    if (!sl.isRegistered<GetProfileInfoUseCase>()) {
      sl.registerFactory(
        () => GetProfileInfoUseCase(
          repository: sl<IProfileRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<BlockUserUseCase>()) {
      sl.registerFactory(
        () => BlockUserUseCase(
          repository: sl<IProfileRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<ReportUserUseCase>()) {
      sl.registerFactory(
        () => ReportUserUseCase(
          repository: sl<IProfileRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<GetSuggestedProfilesUseCase>()) {
      sl.registerFactory(
        () => GetSuggestedProfilesUseCase(
          repository: sl<IProfileRepository>(),
        ),
      );
    }

    // ===== 4. Characters UseCases 등록 =====

    if (!sl.isRegistered<GetUserCharacterUseCase>()) {
      sl.registerFactory(
        () => GetUserCharacterUseCase(
          repository: sl<ICharactersRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<SetUserCharacterUseCase>()) {
      sl.registerFactory(
        () => SetUserCharacterUseCase(
          repository: sl<ICharactersRepository>(),
        ),
      );
    }

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

    if (!sl.isRegistered<GetNotificationSettingsUseCase>()) {
      sl.registerFactory(
        () => GetNotificationSettingsUseCase(
          repository: sl<ISettingsRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<UpdateNotificationSettingsUseCase>()) {
      sl.registerFactory(
        () => UpdateNotificationSettingsUseCase(
          repository: sl<ISettingsRepository>(),
        ),
      );
    }

    // ===== 6. Friends UseCases 등록 =====

    if (!sl.isRegistered<GetFriendsListUseCase>()) {
      sl.registerFactory(
        () => GetFriendsListUseCase(
          repository: sl<IUserRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<AddFriendUseCase>()) {
      sl.registerFactory(
        () => AddFriendUseCase(),
      );
    }

    if (!sl.isRegistered<RemoveFriendUseCase>()) {
      sl.registerFactory(
        () => RemoveFriendUseCase(),
      );
    }

    if (!sl.isRegistered<SendFriendRequestUseCase>()) {
      sl.registerFactory(
        () => SendFriendRequestUseCase(
          repository: sl<IFriendsRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<AcceptFriendRequestUseCase>()) {
      sl.registerFactory(
        () => AcceptFriendRequestUseCase(
          repository: sl<IFriendsRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<RejectFriendRequestUseCase>()) {
      sl.registerFactory(
        () => RejectFriendRequestUseCase(
          repository: sl<IFriendsRepository>(),
        ),
      );
    }

    // ===== 7. Interests UseCases 등록 =====

    if (!sl.isRegistered<GetUserInterestsUseCase>()) {
      sl.registerFactory(
        () => GetUserInterestsUseCase(
          repository: sl<IProfileRepository>(),
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

    // ===== 8. Providers 등록 (Singleton) =====

    if (!sl.isRegistered<ProfileProvider>()) {
      sl.registerLazySingleton<ProfileProvider>(
        () => ProfileProvider(
          getProfileUseCase: sl<GetUserProfileUseCase>(),
          updateProfileUseCase: sl<UpdateUserProfileUseCase>(),
          uploadImageUseCase: sl<UploadProfileImageUseCase>(),
        ),
      );
    }

    if (!sl.isRegistered<CharactersProvider>()) {
      sl.registerLazySingleton<CharactersProvider>(
        () => CharactersProvider(
          getUserCharacterUseCase: sl<GetUserCharacterUseCase>(),
          setUserCharacterUseCase: sl<SetUserCharacterUseCase>(),
          getAvailableCharactersUseCase: sl<GetAvailableCharactersUseCase>(),
        ),
      );
    }

    if (!sl.isRegistered<SettingsProvider>()) {
      sl.registerLazySingleton<SettingsProvider>(
        () => SettingsProvider(
          getSettingsUseCase: sl<GetUserSettingsUseCase>(),
          updateSettingsUseCase: sl<UpdateUserSettingsUseCase>(),
        ),
      );
    }

    if (!sl.isRegistered<FriendsProvider>()) {
      sl.registerLazySingleton<FriendsProvider>(
        () => FriendsProvider(
          getFriendsListUseCase: sl<GetFriendsListUseCase>(),
          addFriendUseCase: sl<AddFriendUseCase>(),
          removeFriendUseCase: sl<RemoveFriendUseCase>(),
          sendFriendRequestUseCase: sl<SendFriendRequestUseCase>(),
          acceptFriendRequestUseCase: sl<AcceptFriendRequestUseCase>(),
          rejectFriendRequestUseCase: sl<RejectFriendRequestUseCase>(),
        ),
      );
    }

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
