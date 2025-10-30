import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '/app/di.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/features/profile/domain/models/profile_info.dart';
import '/features/profile/domain/models/user_settings.dart';
import '/features/profile/domain/models/character.dart';
import '/features/profile/domain/models/interest.dart';
import '/features/profile/domain/models/user_post_item.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import '/features/profile/domain/usecases/profile/delete_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/watch_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/get_profile_completion_usecase.dart';
import '/features/profile/domain/usecases/profile/get_profile_info_usecase.dart';
import '/features/profile/domain/usecases/settings/get_user_settings_usecase.dart';
import '/features/profile/domain/usecases/settings/update_user_settings_usecase.dart';
import '/features/profile/domain/usecases/characters/get_available_characters_usecase.dart';
import '/features/profile/domain/usecases/interests/get_user_interests_usecase.dart';
import '/features/profile/domain/usecases/interests/update_user_interests_usecase.dart';

/// Riverpod Providers for Profile Feature (Phase 3)
///
/// **Architecture Pattern**: Auth/Voting Feature와 100% 동일
/// - ✅ StreamProvider.autoDispose.family
/// - ✅ keepAlive() for caching
/// - ✅ Either<L, R> error handling
/// - ✅ GetIt for UseCase injection
///
/// **Migration**: ChangeNotifier → Riverpod 2.x
/// - Before: manual notifyListeners()
/// - After: automatic Stream updates

// ========================================
// UseCase Providers (GetIt Wrappers)
// ========================================

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return getIt<GetUserProfileUseCase>();
});

final getCurrentUserProfileUseCaseProvider = Provider<GetCurrentUserProfileUseCase>((ref) {
  return getIt<GetCurrentUserProfileUseCase>();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return getIt<UpdateUserProfileUseCase>();
});

final uploadProfileImageUseCaseProvider = Provider<UploadProfileImageUseCase>((ref) {
  return getIt<UploadProfileImageUseCase>();
});

final deleteUserProfileUseCaseProvider = Provider<DeleteUserProfileUseCase>((ref) {
  return getIt<DeleteUserProfileUseCase>();
});

final watchUserProfileUseCaseProvider = Provider<WatchUserProfileUseCase>((ref) {
  return getIt<WatchUserProfileUseCase>();
});

final getProfileCompletionUseCaseProvider = Provider<GetProfileCompletionUseCase>((ref) {
  return getIt<GetProfileCompletionUseCase>();
});

final getProfileInfoUseCaseProvider = Provider<GetProfileInfoUseCase>((ref) {
  return getIt<GetProfileInfoUseCase>();
});

final getUserSettingsUseCaseProvider = Provider<GetUserSettingsUseCase>((ref) {
  return getIt<GetUserSettingsUseCase>();
});

final updateUserSettingsUseCaseProvider = Provider<UpdateUserSettingsUseCase>((ref) {
  return getIt<UpdateUserSettingsUseCase>();
});

final getAvailableCharactersUseCaseProvider = Provider<GetAvailableCharactersUseCase>((ref) {
  return getIt<GetAvailableCharactersUseCase>();
});

final getUserInterestsUseCaseProvider = Provider<GetUserInterestsUseCase>((ref) {
  return getIt<GetUserInterestsUseCase>();
});

final updateUserInterestsUseCaseProvider = Provider<UpdateUserInterestsUseCase>((ref) {
  return getIt<UpdateUserInterestsUseCase>();
});

// ========================================
// Profile Stream Provider
// ========================================

/// 실시간 프로필 동기화 Provider
///
/// **Pattern**: Auth Feature의 authStateStreamProvider와 동일
///
/// **Features**:
/// - ✅ 자동 dispose (autoDispose)
/// - ✅ Family로 userId별 독립 관리
/// - ✅ keepAlive로 중복 리스너 방지
/// - ✅ Either → throw 변환으로 AsyncValue 통합
///
/// **Usage**:
/// ```dart
/// final profileState = ref.watch(profileStreamProvider(
///   ProfileStreamParams(userId: userId),
/// ));
///
/// profileState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
///   data: (profile) => ProfileView(profile),
/// );
/// ```
final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: null 먼저 emit
    yield null;

    // 2. WatchUserProfileUseCase의 Stream 구독
    final watchUseCase = ref.read(watchUserProfileUseCaseProvider);
    final profileStream = watchUseCase.execute(userId: params.userId);

    // 3. Either<ProfileFailure, UserProfile> → UserProfile 변환
    await for (final either in profileStream) {
      either.fold(
        // Left: ProfileFailure → throw로 AsyncValue.error 트리거
        (failure) => throw failure,
        // Right: UserProfile → yield로 AsyncValue.data 트리거
        (profile) => profile,
      );

      // fold 결과를 yield
      yield either.fold(
        (failure) => null,  // 에러 시 null (AsyncValue.error로 이미 처리됨)
        (profile) => profile,
      );
    }

    // 4. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

/// ProfileStreamProvider의 파라미터 클래스
///
/// **equals/hashCode**: Family Provider의 캐시 키로 사용
class ProfileStreamParams {
  final String userId;

  const ProfileStreamParams({required this.userId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileStreamParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

// ========================================
// Settings Stream Provider
// ========================================

/// 실시간 설정 동기화 Provider
///
/// **Pattern**: profileStreamProvider와 동일
final settingsStreamProvider =
    StreamProvider.autoDispose.family<UserSettings?, SettingsStreamParams>(
  (ref, params) async* {
    yield null;

    // GetUserSettingsUseCase는 Future 반환 (Stream 아님)
    // 실시간 업데이트가 필요하면 WatchUserSettingsUseCase 생성 필요
    final settingsUseCase = ref.read(getUserSettingsUseCaseProvider);
    final result = await settingsUseCase.execute(params.userId);

    yield result.fold(
      (failure) => throw failure,
      (settings) => settings,
    );

    ref.keepAlive();
  },
);

class SettingsStreamParams {
  final String userId;

  const SettingsStreamParams({required this.userId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsStreamParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

// ========================================
// Characters Provider
// ========================================

/// 사용 가능한 캐릭터 목록 Provider
///
/// **Pattern**: FutureProvider (1회성 로드)
final charactersProvider = FutureProvider<List<Character>>((ref) async {
  final useCase = ref.read(getAvailableCharactersUseCaseProvider);
  final result = await useCase.execute();

  return result.fold(
    (failure) => throw failure,
    (characters) => characters,
  );
});

// ========================================
// Interests Provider
// ========================================

/// 사용자 관심사 목록 Provider
///
/// **Pattern**: FutureProvider.family (userId별)
final interestsProvider = FutureProvider.family<List<Interest>, String>((ref, userId) async {
  final useCase = ref.read(getUserInterestsUseCaseProvider);
  final result = await useCase.execute(userId);

  return result.fold(
    (failure) => throw failure,
    (interests) => interests,
  );
});

// ========================================
// Profile Completion Provider
// ========================================

/// 프로필 완성도 Provider
///
/// **Pattern**: FutureProvider.family (userId별)
final profileCompletionProvider = FutureProvider.family<double, String>((ref, userId) async {
  final useCase = ref.read(getProfileCompletionUseCaseProvider);
  final result = await useCase.execute(userId);

  return result.fold(
    (failure) => throw failure,
    (completion) => completion,
  );
});

// ========================================
// Profile Info Provider
// ========================================

/// 프로필 정보 Provider
///
/// **Pattern**: FutureProvider.family (userId별)
final profileInfoProvider = FutureProvider.family<ProfileInfo, String>((ref, userId) async {
  final useCase = ref.read(getProfileInfoUseCaseProvider);
  final result = await useCase.execute(userId);

  return result.fold(
    (failure) => throw failure,
    (info) => info,
  );
});

// ========================================
// Loading & Error State Providers
// ========================================

/// 프로필 업데이트 로딩 상태
///
/// **Usage**: 저장 버튼 클릭 시 true로 설정
final profileLoadingProvider = StateProvider<bool>((ref) => false);

/// 프로필 에러 메시지
///
/// **Usage**: 에러 발생 시 메시지 설정, SnackBar 표시용
final profileErrorProvider = StateProvider<String?>((ref) => null);

/// 설정 업데이트 로딩 상태
final settingsLoadingProvider = StateProvider<bool>((ref) => false);

/// 설정 에러 메시지
final settingsErrorProvider = StateProvider<String?>((ref) => null);

/// 이미지 업로드 로딩 상태
final imageUploadLoadingProvider = StateProvider<bool>((ref) => false);

/// 이미지 업로드 진행률 (0.0 ~ 1.0)
final imageUploadProgressProvider = StateProvider<double>((ref) => 0.0);

// ========================================
// Action Methods (Helper Extensions)
// ========================================

/// Riverpod에서 액션 메서드를 호출하는 헬퍼
///
/// **Phase 1.4**: IdempotencyService 통합
/// - UUID v4 기반 eventId 자동 생성
/// - 중복 작업 방지를 위해 모든 write 작업에 eventId 전달
///
/// **Usage Example**:
/// ```dart
/// Future<void> _handleSave() async {
///   await ProfileActions.updateProfile(
///     ref: ref,
///     userId: userId,
///     updatedProfile: profile,
///     onSuccess: () => context.pop(),
///     onError: (message) => showSnackBar(message),
///   );
/// }
/// ```
class ProfileActions {
  /// UUID 생성기 (Phase 1.4: IdempotencyService 통합)
  static const _uuid = Uuid();
  /// 프로필 업데이트 (Phase 1.4: eventId 추가)
  static Future<void> updateProfile({
    required WidgetRef ref,
    required String userId,
    required UserProfile updatedProfile,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    // 1. 로딩 시작
    ref.read(profileLoadingProvider.notifier).state = true;
    ref.read(profileErrorProvider.notifier).state = null;

    // 2. eventId 생성 (UUID v4)
    final eventId = _uuid.v4();

    // 3. UseCase 실행 (eventId 전달)
    final updateUseCase = ref.read(updateUserProfileUseCaseProvider);
    final result = await updateUseCase.execute(updatedProfile, eventId: eventId);

    // 4. 결과 처리
    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;
        onError(failure.message);
      },
      (_) {
        ref.read(profileLoadingProvider.notifier).state = false;
        onSuccess();
      },
    );
  }

  /// 프로필 이미지 업로드
  static Future<void> uploadProfileImage({
    required WidgetRef ref,
    required String userId,
    required File imageFile,
    required void Function(String imageUrl) onSuccess,
    required void Function(String message) onError,
  }) async {
    // 1. 로딩 시작
    ref.read(imageUploadLoadingProvider.notifier).state = true;
    ref.read(profileErrorProvider.notifier).state = null;

    // 2. UseCase 실행
    final uploadUseCase = ref.read(uploadProfileImageUseCaseProvider);
    final result = await uploadUseCase.execute(
      userId: userId,
      imageFile: imageFile,
    );

    // 3. 결과 처리
    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(imageUploadLoadingProvider.notifier).state = false;
        onError(failure.message);
      },
      (imageUrl) {
        ref.read(imageUploadLoadingProvider.notifier).state = false;
        onSuccess(imageUrl);
      },
    );
  }

  /// 프로필 삭제 (Phase 1.4: eventId 추가)
  static Future<void> deleteProfile({
    required WidgetRef ref,
    required String userId,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    // 1. 로딩 시작
    ref.read(profileLoadingProvider.notifier).state = true;
    ref.read(profileErrorProvider.notifier).state = null;

    // 2. eventId 생성 (UUID v4)
    final eventId = _uuid.v4();

    // 3. UseCase 실행 (eventId 전달)
    final deleteUseCase = ref.read(deleteUserProfileUseCaseProvider);
    final result = await deleteUseCase.execute(userId: userId, eventId: eventId);

    // 4. 결과 처리
    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;
        onError(failure.message);
      },
      (_) {
        ref.read(profileLoadingProvider.notifier).state = false;
        onSuccess();
      },
    );
  }

  /// 설정 업데이트 (Phase 1.4: eventId 추가)
  static Future<void> updateSettings({
    required WidgetRef ref,
    required String userId,
    required Map<String, dynamic> settings,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    // 1. 로딩 시작
    ref.read(settingsLoadingProvider.notifier).state = true;
    ref.read(settingsErrorProvider.notifier).state = null;

    // 2. eventId 생성 (UUID v4)
    final eventId = _uuid.v4();

    // 3. UseCase 실행 (eventId 전달)
    final updateUseCase = ref.read(updateUserSettingsUseCaseProvider);
    final result = await updateUseCase.execute(userId, settings, eventId: eventId);

    // 4. 결과 처리
    result.fold(
      (failure) {
        ref.read(settingsErrorProvider.notifier).state = failure.message;
        ref.read(settingsLoadingProvider.notifier).state = false;
        onError(failure.message);
      },
      (_) {
        ref.read(settingsLoadingProvider.notifier).state = false;
        onSuccess();
      },
    );
  }

  /// 관심사 업데이트 (Phase 1.4: eventId 추가)
  static Future<void> updateInterests({
    required WidgetRef ref,
    required String userId,
    required List<String> expertise,
    required List<String> hobbies,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    // 1. 로딩 시작
    ref.read(profileLoadingProvider.notifier).state = true;
    ref.read(profileErrorProvider.notifier).state = null;

    // 2. eventId 생성 (UUID v4)
    final eventId = _uuid.v4();

    // 3. UseCase 실행 (eventId 전달)
    final updateUseCase = ref.read(updateUserInterestsUseCaseProvider);
    final result = await updateUseCase.execute(
      userId: userId,
      expertise: expertise,
      hobbies: hobbies,
      eventId: eventId,
    );

    // 4. 결과 처리
    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;
        onError(failure.message);
      },
      (_) {
        ref.read(profileLoadingProvider.notifier).state = false;
        onSuccess();
      },
    );
  }
}

// ========================================
// User Posts Provider (Firebase Direct Access)
// ========================================

/// 사용자 게시물 목록 Stream Provider
///
/// **Feature Isolation 원칙**:
/// - ✅ Firebase posts 컬렉션 직접 쿼리
/// - ✅ Post Feature에 의존하지 않음
/// - ✅ Profile Feature 전용 UserPostItem 모델 사용
///
/// **Pattern**: profileStreamProvider와 100% 동일
/// - ✅ StreamProvider.autoDispose.family
/// - ✅ Firebase Firestore 직접 접근
/// - ✅ keepAlive() for caching
/// - ✅ AsyncValue 자동 상태 관리
///
/// **Usage**:
/// ```dart
/// final postsState = ref.watch(userPostsStreamProvider(userId));
///
/// postsState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
///   data: (posts) => ListView.builder(...),
/// );
/// ```
final userPostsStreamProvider =
    StreamProvider.autoDispose.family<List<UserPostItem>, String>(
  (ref, userId) async* {
    // 1. 즉시 로딩: 빈 리스트 먼저 emit
    yield [];

    // 2. Firebase Firestore 직접 쿼리 (Feature 간 의존 없음)
    final stream = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    // 3. Firestore DocumentSnapshot → UserPostItem 변환
    await for (final snapshot in stream) {
      try {
        final posts = snapshot.docs
            .map((doc) => UserPostItem.fromFirestore(doc))
            .toList();
        yield posts;
      } catch (e) {
        // 파싱 에러 시 throw로 AsyncValue.error 트리거
        throw Exception('Failed to parse user posts: $e');
      }
    }

    // 4. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);
