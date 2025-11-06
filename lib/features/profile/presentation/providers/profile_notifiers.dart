import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_settings.dart';
import 'usecase_providers.dart';

part 'profile_notifiers.freezed.dart';
part 'profile_notifiers.g.dart';

// ========================================
// Freezed State Classes
// ========================================

/// Profile UI State
@freezed
class ProfileUIState with _$ProfileUIState {
  const ProfileUIState._();

  const factory ProfileUIState({
    @Default(false) bool isLoading,
    String? error,
  }) = _ProfileUIState;
}

/// Settings UI State
@freezed
class SettingsUIState with _$SettingsUIState {
  const SettingsUIState._();

  const factory SettingsUIState({
    @Default(false) bool isLoading,
    String? error,
  }) = _SettingsUIState;
}

/// Image Upload State
@freezed
class ImageUploadState with _$ImageUploadState {
  const ImageUploadState._();

  const factory ImageUploadState({
    @Default(false) bool isUploading,
    @Default(0.0) double progress, // 0.0 to 1.0
    String? error,
    String? uploadedUrl,
  }) = _ImageUploadState;
}

// ========================================
// State Management Notifiers
// ========================================

/// Profile UI State Notifier
@riverpod
class ProfileUI extends _$ProfileUI {
  @override
  ProfileUIState build() {
    return const ProfileUIState();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ProfileUIState();
  }
}

/// Settings UI State Notifier
@riverpod
class SettingsUI extends _$SettingsUI {
  @override
  SettingsUIState build() {
    return const SettingsUIState();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const SettingsUIState();
  }
}

/// Image Upload State Notifier
@riverpod
class ImageUpload extends _$ImageUpload {
  @override
  ImageUploadState build() {
    return const ImageUploadState();
  }

  void setUploading(bool isUploading) {
    state = state.copyWith(isUploading: isUploading);
  }

  void setProgress(double progress) {
    // Clamp between 0.0 and 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);
    state = state.copyWith(progress: clampedProgress);
  }

  void setError(String? error) {
    state = state.copyWith(
      error: error,
      isUploading: false,
    );
  }

  void setUploadedUrl(String url) {
    state = state.copyWith(
      uploadedUrl: url,
      isUploading: false,
      progress: 1.0,
      error: null,
    );
  }

  void reset() {
    state = const ImageUploadState();
  }
}

// ========================================
// Action Notifier
// ========================================

/// Profile Actions Notifier
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  void build() {
    // No initial state needed - this is just an action notifier
  }

  /// Update user profile
  Future<void> updateProfile({
    required UserProfile profile,
    String? eventId,
  }) async {
    ref.read(profileUIProvider.notifier).setLoading(true);
    ref.read(profileUIProvider.notifier).clearError();

    final useCase = ref.read(updateUserProfileUseCaseProvider);
    final result = await useCase.execute(profile, eventId: eventId);

    result.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
      },
      (_) {
        ref.read(profileUIProvider.notifier).clearError();
      },
    );

    ref.read(profileUIProvider.notifier).setLoading(false);
  }

  /// Upload profile image with progress tracking
  Future<void> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    ref.read(imageUploadProvider.notifier).setUploading(true);
    ref.read(imageUploadProvider.notifier).setProgress(0.0);
    ref.read(imageUploadProvider.notifier).setError(null);

    final useCase = ref.read(uploadProfileImageUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      imageFile: imageFile,
    );

    result.fold(
      (failure) {
        ref.read(imageUploadProvider.notifier).setError(failure.message);
      },
      (url) {
        ref.read(imageUploadProvider.notifier).setUploadedUrl(url);
      },
    );
  }

  /// Delete user profile
  Future<void> deleteProfile({
    required String userId,
  }) async {
    ref.read(profileUIProvider.notifier).setLoading(true);
    ref.read(profileUIProvider.notifier).clearError();

    final useCase = ref.read(deleteUserProfileUseCaseProvider);
    final result = await useCase.execute(userId: userId);

    result.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
        ref.read(profileUIProvider.notifier).setLoading(false);
      },
      (_) {
        // Success - don't clear loading, app will navigate
      },
    );
  }

  /// Update user settings
  Future<void> updateSettings({
    required UserSettings settings,
    String? eventId,
  }) async {
    ref.read(settingsUIProvider.notifier).setLoading(true);
    ref.read(settingsUIProvider.notifier).clearError();

    final useCase = ref.read(updateUserSettingsUseCaseProvider);
    final result = await useCase.execute(settings, eventId: eventId);

    result.fold(
      (failure) {
        ref.read(settingsUIProvider.notifier).setError(failure.message);
      },
      (_) {
        ref.read(settingsUIProvider.notifier).clearError();
      },
    );

    ref.read(settingsUIProvider.notifier).setLoading(false);
  }

  /// Update user interests
  Future<void> updateInterests({
    required String userId,
    required List<String> expertise,
    required List<String> hobbies,
    String? eventId,
  }) async {
    ref.read(profileUIProvider.notifier).setLoading(true);
    ref.read(profileUIProvider.notifier).clearError();

    final useCase = ref.read(updateUserInterestsUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      expertise: expertise,
      hobbies: hobbies,
      eventId: eventId,
    );

    result.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
      },
      (_) {
        ref.read(profileUIProvider.notifier).clearError();
      },
    );

    ref.read(profileUIProvider.notifier).setLoading(false);
  }
}

// ========================================
// Stream Providers
// ========================================

/// Profile Stream Provider
@riverpod
Stream<UserProfile?> profileStream(
  Ref ref,
  String userId, {
  bool keepAlive = false,
}) async* {
  if (keepAlive) {
    ref.keepAlive();
  }

  final watchUseCase = ref.read(watchUserProfileUseCaseProvider);
  final stream = watchUseCase.execute(userId: userId);

  await for (final either in stream) {
    yield either.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
        return null;
      },
      (profile) {
        ref.read(profileUIProvider.notifier).clearError();
        return profile;
      },
    );
  }
}

/// Settings Stream Provider
@riverpod
Stream<UserSettings?> settingsStream(
  Ref ref,
  String userId,
) async* {
  final watchUseCase = ref.read(getUserSettingsUseCaseProvider);

  // Get user settings once (not a stream in current implementation)
  final result = await watchUseCase.execute(userId: userId);

  yield result.fold(
    (failure) {
      ref.read(settingsUIProvider.notifier).setError(failure.message);
      return null;
    },
    (settings) {
      ref.read(settingsUIProvider.notifier).clearError();
      return settings;
    },
  );
}
