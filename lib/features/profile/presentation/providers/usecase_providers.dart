import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_current_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/usecases/profile/delete_user_profile_usecase.dart';
import '../../domain/usecases/profile/watch_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_profile_completion_usecase.dart';
import '../../domain/usecases/profile/get_profile_info_usecase.dart';
import '../../domain/usecases/settings/get_user_settings_usecase.dart';
import '../../domain/usecases/settings/update_user_settings_usecase.dart';
import '../../domain/usecases/characters/get_available_characters_usecase.dart';
import '../../domain/usecases/interests/get_user_interests_usecase.dart';
import '../../domain/usecases/interests/update_user_interests_usecase.dart';

part 'usecase_providers.g.dart';

// ========================================
// UseCase Providers (GetIt Wrappers)
// ========================================
//
// Converted from manual Provider<UseCase> to @riverpod functions
// Migration: Riverpod 2.x → 3.x (Code Generation)

@riverpod
GetUserProfileUseCase getUserProfileUseCase(Ref ref) {
  return getIt<GetUserProfileUseCase>();
}

@riverpod
GetCurrentUserProfileUseCase getCurrentUserProfileUseCase(Ref ref) {
  return getIt<GetCurrentUserProfileUseCase>();
}

@riverpod
UpdateUserProfileUseCase updateUserProfileUseCase(Ref ref) {
  return getIt<UpdateUserProfileUseCase>();
}

@riverpod
UploadProfileImageUseCase uploadProfileImageUseCase(Ref ref) {
  return getIt<UploadProfileImageUseCase>();
}

@riverpod
DeleteUserProfileUseCase deleteUserProfileUseCase(Ref ref) {
  return getIt<DeleteUserProfileUseCase>();
}

@riverpod
WatchUserProfileUseCase watchUserProfileUseCase(Ref ref) {
  return getIt<WatchUserProfileUseCase>();
}

@riverpod
GetProfileCompletionUseCase getProfileCompletionUseCase(Ref ref) {
  return getIt<GetProfileCompletionUseCase>();
}

@riverpod
GetProfileInfoUseCase getProfileInfoUseCase(Ref ref) {
  return getIt<GetProfileInfoUseCase>();
}

@riverpod
GetUserSettingsUseCase getUserSettingsUseCase(Ref ref) {
  return getIt<GetUserSettingsUseCase>();
}

@riverpod
UpdateUserSettingsUseCase updateUserSettingsUseCase(Ref ref) {
  return getIt<UpdateUserSettingsUseCase>();
}

@riverpod
GetAvailableCharactersUseCase getAvailableCharactersUseCase(Ref ref) {
  return getIt<GetAvailableCharactersUseCase>();
}

@riverpod
GetUserInterestsUseCase getUserInterestsUseCase(Ref ref) {
  return getIt<GetUserInterestsUseCase>();
}

@riverpod
UpdateUserInterestsUseCase updateUserInterestsUseCase(Ref ref) {
  return getIt<UpdateUserInterestsUseCase>();
}
