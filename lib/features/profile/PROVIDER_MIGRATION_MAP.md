# Profile Feature: Provider Migration Map (Riverpod 2.x → 3.x)

## Overview

This document maps the old Riverpod 2.x providers (`profile_providers.dart`) to the new Riverpod 3.x providers with code generation (`profile_notifiers.dart` + `usecase_providers.dart`).

**Status**: Phase 3 - Widget Migration in Progress

**Affected Files**: 11 widgets importing `profile_providers.dart`

---

## UseCase Providers (13 providers)

All UseCase providers have been migrated to `usecase_providers.dart` with `@riverpod` annotation.

| Old Provider (Manual) | New Provider (Generated) | File | Status |
|----------------------|--------------------------|------|--------|
| `getUserProfileUseCaseProvider` | `getUserProfileUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `getCurrentUserProfileUseCaseProvider` | `getCurrentUserProfileUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `updateUserProfileUseCaseProvider` | `updateUserProfileUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `uploadProfileImageUseCaseProvider` | `uploadProfileImageUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `deleteUserProfileUseCaseProvider` | `deleteUserProfileUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `watchUserProfileUseCaseProvider` | `watchUserProfileUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `getProfileCompletionUseCaseProvider` | `getProfileCompletionUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `getProfileInfoUseCaseProvider` | `getProfileInfoUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `getUserSettingsUseCaseProvider` | `getUserSettingsUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `updateUserSettingsUseCaseProvider` | `updateUserSettingsUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `getAvailableCharactersUseCaseProvider` | `getAvailableCharactersUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `getUserInterestsUseCaseProvider` | `getUserInterestsUseCaseProvider` | usecase_providers.dart | ✅ Same name |
| `updateUserInterestsUseCaseProvider` | `updateUserInterestsUseCaseProvider` | usecase_providers.dart | ✅ Same name |

**Migration Note**: UseCase providers **keep the same name**, so no code changes needed in widgets.

---

## Stream Providers (2 providers)

Stream providers have been migrated with **signature changes** (Params class → direct parameters).

### profileStreamProvider

**Old (Riverpod 2.x)**:
```dart
final profileStreamProvider = StreamProvider.family.autoDispose<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    // ...
  },
);

// Usage
ref.watch(profileStreamProvider(ProfileStreamParams(userId: userId)))
```

**New (Riverpod 3.x)**:
```dart
@riverpod
Stream<UserProfile?> profileStream(
  Ref ref,
  String userId, {
  bool keepAlive = false,
}) async* {
  // ...
}

// Usage - SIGNATURE CHANGE!
ref.watch(profileStreamProvider(userId))  // Direct parameter, no Params class
```

**Migration Steps**:
1. Remove `ProfileStreamParams` import and class usage
2. Change `profileStreamProvider(ProfileStreamParams(userId: userId))` → `profileStreamProvider(userId)`

### settingsStreamProvider

**Old (Riverpod 2.x)**:
```dart
final settingsStreamProvider = StreamProvider.family.autoDispose<UserSettings?, SettingsStreamParams>(
  (ref, params) async* {
    // ...
  },
);

// Usage
ref.watch(settingsStreamProvider(SettingsStreamParams(userId: userId)))
```

**New (Riverpod 3.x)**:
```dart
@riverpod
Stream<UserSettings?> settingsStream(
  Ref ref,
  String userId,
) async* {
  // ...
}

// Usage - SIGNATURE CHANGE!
ref.watch(settingsStreamProvider(userId))  // Direct parameter
```

**Migration Steps**:
1. Remove `SettingsStreamParams` import and class usage
2. Change `settingsStreamProvider(SettingsStreamParams(userId: userId))` → `settingsStreamProvider(userId)`

---

## FutureProvider Providers (4 providers)

FutureProvider patterns have been replaced with direct UseCase calls or removed.

### charactersProvider

**Status**: ⚠️ **NOT MIGRATED YET** (needs decision)

**Old**:
```dart
final charactersProvider = FutureProvider<List<Character>>((ref) async {
  final useCase = ref.watch(getAvailableCharactersUseCaseProvider);
  final result = await useCase.execute();
  return result.getOrElse((l) => []);
});
```

**Options**:
1. Convert to `@riverpod` FutureProvider
2. Use UseCase directly in widgets with `ref.read()`
3. Keep old provider temporarily

### interestsProvider

**Status**: ⚠️ **NOT MIGRATED YET** (needs decision)

**Old**:
```dart
final interestsProvider = FutureProvider.family<List<Interest>, String>((ref, userId) async {
  final useCase = ref.watch(getUserInterestsUseCaseProvider);
  final result = await useCase.execute(userId: userId);
  return result.getOrElse((l) => []);
});
```

### profileCompletionProvider

**Status**: ⚠️ **NOT MIGRATED YET** (needs decision)

**Old**:
```dart
final profileCompletionProvider = FutureProvider.family<double, String>((ref, userId) async {
  final useCase = ref.watch(getProfileCompletionUseCaseProvider);
  final result = await useCase.execute(userId: userId);
  return result.getOrElse((l) => 0.0);
});
```

### profileInfoProvider

**Status**: ⚠️ **NOT MIGRATED YET** (needs decision)

**Old**:
```dart
final profileInfoProvider = FutureProvider.family<ProfileInfo, String>((ref, userId) async {
  final useCase = ref.watch(getProfileInfoUseCaseProvider);
  final result = await useCase.execute(userId: userId);
  return result.fold(
    (l) => const ProfileInfo(userId: '', displayName: '', photoUrl: null, completionPercentage: 0.0),
    (r) => r,
  );
});
```

---

## State Providers (6 providers → 3 Notifiers)

Old StateProviders have been consolidated into 3 Freezed State Notifiers with helper methods.

### Profile UI State (2 old → 1 new Notifier)

**Old (2 separate StateProviders)**:
```dart
final profileLoadingProvider = StateProvider<bool>((ref) => false);
final profileErrorProvider = StateProvider<String?>((ref) => null);

// Usage
ref.read(profileLoadingProvider.notifier).state = true;
ref.read(profileErrorProvider.notifier).state = 'Error message';
```

**New (Freezed State + Notifier)**:
```dart
@freezed
sealed class ProfileUIState with _$ProfileUIState {
  const factory ProfileUIState({
    @Default(false) bool isLoading,
    String? error,
  }) = _ProfileUIState;
}

@riverpod
class ProfileUI extends _$ProfileUI {
  @override
  ProfileUIState build() => const ProfileUIState();

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

// Usage
ref.read(profileUIProvider.notifier).setLoading(true);
ref.read(profileUIProvider.notifier).setError('Error message');
ref.watch(profileUIProvider).isLoading  // Watch state
```

**Migration Steps**:
1. Replace `profileLoadingProvider` → `profileUIProvider.select((s) => s.isLoading)`
2. Replace `profileErrorProvider` → `profileUIProvider.select((s) => s.error)`
3. Replace `.notifier.state = value` → `.notifier.setLoading(value)` or `.notifier.setError(value)`

### Settings UI State (2 old → 1 new Notifier)

**Old (2 separate StateProviders)**:
```dart
final settingsLoadingProvider = StateProvider<bool>((ref) => false);
final settingsErrorProvider = StateProvider<String?>((ref) => null);
```

**New (Freezed State + Notifier)**:
```dart
@freezed
sealed class SettingsUIState with _$SettingsUIState {
  const factory SettingsUIState({
    @Default(false) bool isLoading,
    String? error,
  }) = _SettingsUIState;
}

@riverpod
class SettingsUI extends _$SettingsUI {
  @override
  SettingsUIState build() => const SettingsUIState();

  void setLoading(bool isLoading) { /* ... */ }
  void setError(String? error) { /* ... */ }
  void clearError() { /* ... */ }
  void reset() { /* ... */ }
}

// Usage
ref.read(settingsUIProvider.notifier).setLoading(true);
ref.watch(settingsUIProvider).isLoading
```

**Migration Steps**: Same as ProfileUIState

### Image Upload State (2 old → 1 new Notifier)

**Old (3 separate StateProviders)**:
```dart
final imageUploadLoadingProvider = StateProvider<bool>((ref) => false);
final imageUploadProgressProvider = StateProvider<double>((ref) => 0.0);
// Error was handled by profileErrorProvider
```

**New (Freezed State + Notifier)**:
```dart
@freezed
sealed class ImageUploadState with _$ImageUploadState {
  const factory ImageUploadState({
    @Default(false) bool isUploading,
    @Default(0.0) double progress,
    String? error,
    String? uploadedUrl,
  }) = _ImageUploadState;
}

@riverpod
class ImageUpload extends _$ImageUpload {
  @override
  ImageUploadState build() => const ImageUploadState();

  void setUploading(bool isUploading) { /* ... */ }
  void setProgress(double progress) { /* ... */ }
  void setError(String? error) { /* ... */ }
  void setUploadedUrl(String url) { /* ... */ }
  void reset() { /* ... */ }
}

// Usage
ref.read(imageUploadProvider.notifier).setProgress(0.5);
ref.watch(imageUploadProvider).progress
```

**Migration Steps**:
1. Replace `imageUploadLoadingProvider` → `imageUploadProvider.select((s) => s.isUploading)`
2. Replace `imageUploadProgressProvider` → `imageUploadProvider.select((s) => s.progress)`
3. Use `.notifier.setProgress()`, `.notifier.setError()`, etc.

---

## Action Provider (1 provider)

The old `ProfileActions` class has been replaced with `ProfileNotifier` (action-only notifier).

**Old**:
```dart
class ProfileActions {
  ProfileActions(this.ref);
  final Ref ref;

  Future<void> updateProfile(UserProfile profile, {String? eventId}) async {
    // ...
  }

  Future<void> uploadProfileImage({required String userId, required File imageFile}) async {
    // ...
  }

  // ... other methods
}

final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});

// Usage
await ref.read(profileActionsProvider).updateProfile(profile);
```

**New**:
```dart
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  void build() {}  // No state, just actions

  Future<void> updateProfile({
    required UserProfile profile,
    String? eventId,
  }) async {
    // ...
  }

  Future<void> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    // ...
  }

  // ... other action methods
}

// Usage - SIGNATURE CHANGE!
await ref.read(profileNotifierProvider.notifier).updateProfile(profile: profile);
```

**Migration Steps**:
1. Replace `profileActionsProvider` → `profileNotifierProvider.notifier`
2. Update method signatures if parameters changed (check PHASE_3_7 docs)

---

## Import Changes

### Old Import

```dart
import '/features/profile/presentation/providers/profile_providers.dart';
```

### New Imports

```dart
// For UI State Notifiers (ProfileUI, SettingsUI, ImageUpload)
// and Action Notifier (ProfileNotifier)
// and Stream Providers (profileStream, settingsStream)
import '/features/profile/presentation/providers/profile_notifiers.dart';

// For UseCase Providers (all 13 UseCases)
import '/features/profile/presentation/providers/usecase_providers.dart';
```

**Note**: Most widgets will only need `profile_notifiers.dart` import. Only import `usecase_providers.dart` if you need direct UseCase access.

---

## Migration Checklist for Each Widget

- [ ] Update imports (remove `profile_providers.dart`, add new imports)
- [ ] Replace stream provider params: `ProfileStreamParams(userId: userId)` → `userId`
- [ ] Replace state providers with notifier selectors: `profileLoadingProvider` → `profileUIProvider.select((s) => s.isLoading)`
- [ ] Update action calls: `profileActionsProvider` → `profileNotifierProvider.notifier`
- [ ] Remove unused Params classes (`ProfileStreamParams`, `SettingsStreamParams`)
- [ ] Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- [ ] Test widget functionality

---

## Affected Widgets (11 files)

1. ✅ `profile_page_widget.dart` - **PRIORITY** (Main profile screen)
2. ⏳ `settings_screen.dart`
3. ⏳ `user_posts_list_screen.dart`
4. ⏳ `profile_edit_screen.dart`
5. ⏳ `user_info_input_widget.dart`
6. ⏳ `onboarding_flow_screen.dart`
7. ⏳ `character_detail_page_widget.dart`
8. ⏳ `language_selector_model.dart`
9. ⏳ `user_info_display_screen.dart`
10. ⏳ `profile_completion_card.dart`
11. ⏳ `interest_selection_widget.dart`

**Next Step**: Update `profile_page_widget.dart` first (highest priority).

---

## Notes

- **UseCase providers**: Same names, no changes needed ✅
- **Stream providers**: Signature changes (remove Params classes) ⚠️
- **State providers**: Consolidated into Notifiers with Freezed states ⚠️
- **Action provider**: Renamed and signature changes ⚠️
- **FutureProviders**: Migration strategy TBD ⚠️

---

**Created**: 2025-11-06
**Last Updated**: 2025-11-06
**Phase**: 3.1 - Provider Mapping Complete
