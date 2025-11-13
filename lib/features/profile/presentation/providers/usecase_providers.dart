import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_current_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_language_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/usecases/profile/delete_user_profile_usecase.dart';
import '../../domain/usecases/profile/watch_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_profile_completion_usecase.dart';
import '../../domain/usecases/profile/get_profile_info_usecase.dart';
import '../../domain/usecases/activity/update_last_active_usecase.dart';
import '../../domain/usecases/settings/get_user_settings_usecase.dart';
import '../../domain/usecases/settings/update_user_settings_usecase.dart';
import '../../domain/usecases/characters/get_available_characters_usecase.dart';
import '../../domain/usecases/interests/get_user_interests_usecase.dart';
import '../../domain/usecases/interests/update_user_interests_usecase.dart';
import '../../domain/usecases/storage/select_media_usecase.dart';
import '../../domain/usecases/storage/validate_media_usecase.dart';
import '../../domain/entities/user_profile_business.dart'; // Phase C-1: Extension 메서드

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
UpdateLanguageUseCase updateLanguageUseCase(Ref ref) {
  return getIt<UpdateLanguageUseCase>();
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
UpdateLastActiveUseCase updateLastActiveUseCase(Ref ref) {
  return getIt<UpdateLastActiveUseCase>();
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

@riverpod
SelectMediaUseCase selectMediaUseCase(Ref ref) {
  return getIt<SelectMediaUseCase>();
}

@riverpod
ValidateMediaUseCase validateMediaUseCase(Ref ref) {
  return getIt<ValidateMediaUseCase>();
}

// ========================================
// Data Providers (Phase C-1)
// ========================================
//
// UseCase를 실행하고 결과를 가공하는 Provider들
// Extension 메서드를 활용한 비즈니스 로직 노출

/// 사용자 역할 조회 Provider
///
/// **Phase C-1**: App Layer 아키텍처 정리
/// - AuthGuard의 Firestore 직접 접근 제거
/// - Extension 메서드 활용 (user_profile_business.dart)
///
/// **Usage**:
/// ```dart
/// final roleAsync = ref.watch(userRoleProvider(userId));
///
/// roleAsync.when(
///   data: (role) => Text('Role: $role'),  // 'user', 'admin', 'tester'
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
///
/// **특징**:
/// - GetUserProfileUseCase 사용
/// - UserRoleExtension.getRole() 호출
/// - 기본값: 'user' (에러 시에도)
@riverpod
Future<String> userRole(Ref ref, String userId) async {
  final useCase = ref.watch(getUserProfileUseCaseProvider);
  final result = await useCase.execute(userId: userId);

  return result.fold(
    (failure) => 'user', // 에러 시 기본값
    (profile) => profile.getRole(), // Extension 메서드 사용
  );
}

/// 관리자 여부 확인 Provider
///
/// **Usage**:
/// ```dart
/// final isAdminAsync = ref.watch(isAdminUserProvider(userId));
///
/// if (isAdminAsync.value == true) {
///   // 관리자 전용 UI 표시
/// }
/// ```
@riverpod
Future<bool> isAdminUser(Ref ref, String userId) async {
  final useCase = ref.watch(getUserProfileUseCaseProvider);
  final result = await useCase.execute(userId: userId);

  return result.fold(
    (failure) => false,
    (profile) => profile.isAdmin(), // Extension 메서드 사용
  );
}

/// 현재 사용자 역할 조회 Provider (편의용)
///
/// **Usage**:
/// ```dart
/// final currentRoleAsync = ref.watch(currentUserRoleProvider);
///
/// currentRoleAsync.when(
///   data: (role) => print('My role: $role'),
///   loading: () => null,
///   error: (error, stack) => null,
/// );
/// ```
@riverpod
Future<String> currentUserRole(Ref ref) async {
  final useCase = ref.watch(getCurrentUserProfileUseCaseProvider);
  final result = await useCase.execute();

  return result.fold(
    (failure) => 'user',
    (profile) => profile.getRole(),
  );
}
