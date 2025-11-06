# Profile Feature - Riverpod 3.x Migration (Phase 1-2)

> **작성일**: 2025-11-06
> **기준 코드**: lib/features/profile/presentation/providers/profile_providers.dart (560줄)
> **참조 문서**: Voting Feature Riverpod 3.x Migration, Creation Feature (완료)
> **목표**: Riverpod 2.x → 3.x 마이그레이션 (Provider 변환)

---

## 📋 목차

- [Phase 1: Migration Preparation](#phase-1-migration-preparation)
  - [1.1 Current State Analysis](#11-current-state-analysis)
  - [1.2 File Structure Design](#12-file-structure-design)
  - [1.3 Dependency Verification](#13-dependency-verification)
  - [1.4 Backup Strategy](#14-backup-strategy)
  - [1.5 Pre-migration Checklist](#15-pre-migration-checklist)
- [Phase 2: Provider Transformation](#phase-2-provider-transformation)
  - [2.1 StateProvider → @riverpod class Notifier](#21-stateprovider--riverpod-class-notifier)
  - [2.2 Provider<UseCase> → @riverpod function](#22-providerusecase--riverpod-function)
  - [2.3 StreamProvider → @riverpod Stream](#23-streamprovider--riverpod-stream)
  - [2.4 ProfileActions → Notifier Methods](#24-profileactions--notifier-methods)
  - [2.5 Code Generation & Validation](#25-code-generation--validation)
  - [2.6 Provider Transformation Matrix](#26-provider-transformation-matrix)
- [Appendix A: File Organization Strategy](#appendix-a-file-organization-strategy)
- [Appendix B: Migration Checklist](#appendix-b-migration-checklist)

---

## Phase 1: Migration Preparation

### 1.1 Current State Analysis

#### Provider 현황표

| Provider Type | Count | File | Status |
|---------------|-------|------|--------|
| `Provider<UseCase>` | 13 | profile_providers.dart | ❌ 마이그레이션 필요 |
| `StateProvider<bool>` | 3 | profile_providers.dart | ❌ 마이그레이션 필요 |
| `StateProvider<String?>` | 2 | profile_providers.dart | ❌ 마이그레이션 필요 |
| `StateProvider<double>` | 1 | profile_providers.dart | ❌ 마이그레이션 필요 |
| `StreamProvider.autoDispose.family` | 2 | profile_providers.dart | ❌ 마이그레이션 필요 |
| `@riverpod Stream` | 2 | profile_post_providers.dart | ✅ 이미 3.x |
| `@riverpod Future` | 1 | profile_post_providers.dart | ✅ 이미 3.x |
| `ProfileActions` static methods | ~6 | profile_providers.dart | ❌ 마이그레이션 필요 |
| **Total** | **30** | 2 files | **23 마이그레이션 필요** |

#### 현재 문제점

1. **Legacy Import 존재**:
   ```dart
   import 'package:flutter_riverpod/legacy.dart'; // ❌ 제거 필요
   ```

2. **Manual Provider 정의** (Riverpod 2.x 스타일):
   ```dart
   final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
     return getIt<GetUserProfileUseCase>();
   }); // ❌ Should be @riverpod function
   ```

3. **StateProvider 남용** (6개 분산):
   ```dart
   final profileLoadingProvider = StateProvider<bool>((ref) => false);
   final profileErrorProvider = StateProvider<String?>((ref) => null);
   final settingsLoadingProvider = StateProvider<bool>((ref) => false);
   final settingsErrorProvider = StateProvider<String?>((ref) => null);
   final imageUploadLoadingProvider = StateProvider<bool>((ref) => false);
   final imageUploadProgressProvider = StateProvider<double>((ref) => 0.0);
   ```

4. **StreamProvider 수동 구현**:
   ```dart
   final profileStreamProvider =
       StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
     (ref, params) async* {
       yield null; // Manual null handling
       // Manual Either folding logic
       await for (final either in profileStream) {
         either.fold(...);
         yield either.fold(...);
       }
       ref.keepAlive(); // Manual keepAlive
     },
   ); // ❌ Should use @riverpod annotation
   ```

5. **Non-Riverpod Action Pattern**:
   ```dart
   class ProfileActions {  // ❌ Not Riverpod pattern
     static Future<void> updateProfile({
       required WidgetRef ref,
       required String userId,
       required Map<String, dynamic> updates,
     }) async {
       ref.read(profileLoadingProvider.notifier).state = true;
       // ...
     }
   }
   ```

#### 긍정적 요소

1. **profile_post_providers.dart** - 이미 Riverpod 3.x 완료 ✅:
   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';

   part 'profile_post_providers.g.dart';

   @riverpod
   Stream<List<PostDisplay>> profileUserPostsStream(
     Ref ref,
     String userId, {
     int limit = 5,
   }) async* {
     // Clean 3.x implementation
   }
   ```

2. **Widget Already Modern** - ProfilePageWidget uses ConsumerStatefulWidget ✅

3. **Creation Feature Reference** - 동일 패턴으로 2025-11-06 완료 ✅

---

### 1.2 File Structure Design

#### Current Structure (Before Migration)

```
lib/features/profile/presentation/providers/
├── profile_providers.dart (560줄)
│   ├── 13 Provider<UseCase> (manual)
│   ├── 6 StateProvider (manual)
│   ├── 2 StreamProvider.family (manual)
│   ├── ProfileActions class (static methods)
│   └── Helper classes (ProfileStreamParams, etc.)
│
└── profile_post_providers.dart (68줄) ✅ Already 3.x
    ├── @riverpod Stream (profileUserPostsStream)
    ├── @riverpod Future (profileUserPostsCount)
    └── profile_post_providers.g.dart (generated)
```

#### Target Structure (After Migration)

```
lib/features/profile/presentation/providers/
├── profile_notifiers.dart (NEW: ~200줄)
│   ├── part 'profile_notifiers.freezed.dart';
│   ├── part 'profile_notifiers.g.dart';
│   │
│   ├── ProfileUIState (Freezed)
│   ├── SettingsUIState (Freezed)
│   ├── ImageUploadState (Freezed)
│   │
│   ├── @riverpod class ProfileUI extends _$ProfileUI
│   ├── @riverpod class SettingsUI extends _$SettingsUI
│   ├── @riverpod class ImageUpload extends _$ImageUpload
│   ├── @riverpod class ProfileNotifier extends _$ProfileNotifier
│   │
│   ├── @riverpod Stream<UserProfile?> profileStream(...)
│   └── @riverpod Stream<UserSettings?> settingsStream(...)
│
├── profile_notifiers.freezed.dart (GENERATED)
├── profile_notifiers.g.dart (GENERATED)
│
├── usecase_providers.dart (NEW: ~100줄)
│   ├── part 'usecase_providers.g.dart';
│   │
│   ├── @riverpod GetUserProfileUseCase getUserProfileUseCase(Ref ref)
│   ├── @riverpod UpdateUserProfileUseCase updateUserProfileUseCase(Ref ref)
│   └── ... (11 more UseCase providers)
│
├── usecase_providers.g.dart (GENERATED)
│
├── profile_post_providers.dart (KEEP AS-IS) ✅
├── profile_post_providers.g.dart (KEEP AS-IS) ✅
│
└── profile_providers.dart (DEPRECATED - 마이그레이션 후 제거 가능)
```

#### 파일 분리 전략

**왜 2개 파일로 분리?**

1. **관심사 분리 (Separation of Concerns)**:
   - `profile_notifiers.dart` - 상태 관리 (State Management)
   - `usecase_providers.dart` - 의존성 주입 (Dependency Injection)

2. **유지보수성 (Maintainability)**:
   - 각 파일이 단일 책임을 가짐
   - 특정 Provider 찾기 쉬움

3. **컴파일 시간 (Build Time)**:
   - 작은 .g.dart 파일들로 분리
   - 변경 시 일부만 재생성

4. **패턴 일관성 (Pattern Consistency)**:
   - Creation Feature와 동일한 구조
   - Voting Feature 문서와 일치

---

### 1.3 Dependency Verification

#### pubspec.yaml 확인

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0  # ✅ 2.4.0+ 필요
  riverpod_annotation: ^2.3.0  # ✅ 3.x 지원
  freezed_annotation: ^2.4.1  # ✅ State classes

dev_dependencies:
  build_runner: ^2.4.0  # ✅ Code generation
  riverpod_generator: ^2.3.0  # ✅ @riverpod 지원
  freezed: ^2.4.5  # ✅ Freezed generation
  riverpod_lint: ^2.3.0  # ✅ Linting (optional but recommended)
```

#### 버전 확인 명령어

```bash
# pubspec.yaml 버전 확인
cat pubspec.yaml | grep -A 2 "riverpod"

# 설치된 버전 확인
flutter pub deps | grep riverpod
```

#### 최소 요구사항

| Package | Minimum Version | Current | Status |
|---------|-----------------|---------|--------|
| flutter_riverpod | 2.4.0 | 2.4.0+ | ✅ |
| riverpod_annotation | 2.3.0 | 2.3.0+ | ✅ |
| riverpod_generator | 2.3.0 | 2.3.0+ | ✅ |
| build_runner | 2.4.0 | 2.4.0+ | ✅ |
| freezed | 2.4.0 | 2.4.5+ | ✅ |

---

### 1.4 Backup Strategy

#### Git Branch 생성

```bash
# 현재 브랜치 확인
git branch

# 새 브랜치 생성 및 체크아웃
git checkout -b feature/profile-riverpod-3x

# 현재 상태 커밋
git add lib/features/profile/presentation/providers/profile_providers.dart
git commit -m "Pre-migration: Profile Feature Riverpod 2.x state"

# 백업 브랜치 생성 (선택사항)
git checkout -b backup/profile-riverpod-2x
git checkout feature/profile-riverpod-3x
```

#### 파일 백업 (선택사항)

```bash
# 수동 백업 (선택사항)
cp lib/features/profile/presentation/providers/profile_providers.dart \
   lib/features/profile/presentation/providers/profile_providers.dart.backup

# 백업 확인
ls -la lib/features/profile/presentation/providers/*.backup
```

#### Rollback 계획

만약 마이그레이션 중 문제가 발생하면:

```bash
# Option 1: Git revert
git checkout backup/profile-riverpod-2x
git checkout -b feature/profile-riverpod-3x-retry

# Option 2: 파일 복원
mv lib/features/profile/presentation/providers/profile_providers.dart.backup \
   lib/features/profile/presentation/providers/profile_providers.dart

# Option 3: Git reset (주의: uncommitted changes 손실)
git reset --hard HEAD
```

---

### 1.5 Pre-migration Checklist

마이그레이션 시작 전 다음 항목들을 확인하세요:

- [ ] **의존성 확인 완료** - pubspec.yaml에 필요한 패키지 모두 존재
- [ ] **Git 백업 완료** - feature/profile-riverpod-3x 브랜치 생성
- [ ] **현재 상태 커밋** - "Pre-migration" 커밋 완료
- [ ] **profile_post_providers.dart 분석** - 3.x 패턴 숙지
- [ ] **Creation Feature 참조** - 동일 패턴 확인 (lib/features/creation/)
- [ ] **Voting Feature 문서 읽음** - 변환 패턴 이해
- [ ] **테스트 실행 가능** - `flutter test` 정상 동작 확인
- [ ] **앱 실행 가능** - `flutter run` 정상 동작 확인
- [ ] **build_runner 동작 확인** - `dart run build_runner --help` 실행 성공

---

## Phase 2: Provider Transformation

### 2.1 StateProvider → @riverpod class Notifier

Profile Feature는 **6개의 StateProvider**를 사용 중입니다. 이를 **3개의 Freezed State + Notifier**로 통합합니다.

#### Transformation 1: Profile UI State 통합

**Before** (profile_providers.dart:30-35):

```dart
// ❌ Legacy: 2개의 분산된 StateProvider
final profileLoadingProvider = StateProvider<bool>((ref) => false);
final profileErrorProvider = StateProvider<String?>((ref) => null);

// Widget에서 사용:
ref.read(profileLoadingProvider.notifier).state = true;
ref.read(profileErrorProvider.notifier).state = 'Error message';
```

**After** (profile_notifiers.dart):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_notifiers.freezed.dart';
part 'profile_notifiers.g.dart';

// ✅ Step 1: Freezed State 정의
@freezed
class ProfileUIState with _$ProfileUIState {
  const factory ProfileUIState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
  }) = _ProfileUIState;
}

// ✅ Step 2: Notifier 정의
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
```

**Widget Usage (변경사항)**:

```dart
// ❌ Before: 2개의 Provider를 개별적으로 watch
final isLoading = ref.watch(profileLoadingProvider);
final error = ref.watch(profileErrorProvider);

// ✅ After: 단일 Notifier, 선택적으로 watch 가능
// Option 1: 전체 state
final uiState = ref.watch(profileUIProvider);
if (uiState.isLoading) { /* ... */ }
if (uiState.error != null) { /* ... */ }

// Option 2: 선택적 watching (성능 최적화)
final isLoading = ref.watch(profileUIProvider.select((s) => s.isLoading));
final error = ref.watch(profileUIProvider.select((s) => s.error));

// ❌ Before: State 업데이트 (2줄)
ref.read(profileLoadingProvider.notifier).state = true;
ref.read(profileErrorProvider.notifier).state = null;

// ✅ After: State 업데이트 (1줄)
ref.read(profileUIProvider.notifier).setLoading(true);
ref.read(profileUIProvider.notifier).clearError();
```

**왜 통합?**

- **응집도 향상**: 관련된 상태를 하나의 클래스로 관리
- **타입 안전성**: Freezed의 copyWith로 불변성 보장
- **코드 감소**: 2개 Provider → 1개 Notifier
- **가독성 향상**: `uiState.isLoading`이 `ref.watch(profileLoadingProvider)`보다 명확

---

#### Transformation 2: Settings UI State 통합

**Before** (profile_providers.dart:40-45):

```dart
final settingsLoadingProvider = StateProvider<bool>((ref) => false);
final settingsErrorProvider = StateProvider<String?>((ref) => null);
```

**After** (profile_notifiers.dart):

```dart
@freezed
class SettingsUIState with _$SettingsUIState {
  const factory SettingsUIState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
  }) = _SettingsUIState;
}

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
}
```

**Widget Usage**:

```dart
// ✅ Settings Screen에서 사용
final settingsState = ref.watch(settingsUIProvider);

if (settingsState.isLoading) {
  return const CircularProgressIndicator();
}

if (settingsState.error != null) {
  return ErrorWidget(message: settingsState.error!);
}
```

---

#### Transformation 3: Image Upload State

**Before** (profile_providers.dart:50-55):

```dart
final imageUploadLoadingProvider = StateProvider<bool>((ref) => false);
final imageUploadProgressProvider = StateProvider<double>((ref) => 0.0);

// Usage:
ref.read(imageUploadLoadingProvider.notifier).state = true;
ref.read(imageUploadProgressProvider.notifier).state = 0.5; // 50%
```

**After** (profile_notifiers.dart):

```dart
@freezed
class ImageUploadState with _$ImageUploadState {
  const factory ImageUploadState({
    @Default(false) bool isUploading,
    @Default(0.0) double progress, // 0.0 to 1.0
    @Default(null) String? error,
    @Default(null) String? uploadedUrl, // 업로드 완료 시 URL
  }) = _ImageUploadState;
}

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
```

**Widget Usage**:

```dart
// ✅ Image Upload Progress UI
final uploadState = ref.watch(imageUploadProvider);

if (uploadState.isUploading) {
  return Column(
    children: [
      CircularProgressIndicator(value: uploadState.progress),
      Text('${(uploadState.progress * 100).toStringAsFixed(0)}%'),
    ],
  );
}

if (uploadState.error != null) {
  return Text('Upload failed: ${uploadState.error}');
}

if (uploadState.uploadedUrl != null) {
  return Image.network(uploadState.uploadedUrl!);
}
```

---

### 2.2 Provider<UseCase> → @riverpod function

Profile Feature는 **13개의 UseCase Provider**를 가지고 있습니다. 모두 `@riverpod` getter 함수로 변환합니다.

**Before** (profile_providers.dart:60-130):

```dart
// ❌ Legacy: Manual Provider definition
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return getIt<GetUserProfileUseCase>();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return getIt<UpdateUserProfileUseCase>();
});

final watchUserProfileUseCaseProvider = Provider<WatchUserProfileUseCase>((ref) {
  return getIt<WatchUserProfileUseCase>();
});

final uploadProfileImageUseCaseProvider = Provider<UploadProfileImageUseCase>((ref) {
  return getIt<UploadProfileImageUseCase>();
});

final deleteProfileImageUseCaseProvider = Provider<DeleteProfileImageUseCase>((ref) {
  return getIt<DeleteProfileImageUseCase>();
});

final getFollowersUseCaseProvider = Provider<GetFollowersUseCase>((ref) {
  return getIt<GetFollowersUseCase>();
});

final getFollowingUseCaseProvider = Provider<GetFollowingUseCase>((ref) {
  return getIt<GetFollowingUseCase>();
});

final followUserUseCaseProvider = Provider<FollowUserUseCase>((ref) {
  return getIt<FollowUserUseCase>();
});

final unfollowUserUseCaseProvider = Provider<UnfollowUserUseCase>((ref) {
  return getIt<UnfollowUserUseCase>();
});

final checkFollowStatusUseCaseProvider = Provider<CheckFollowStatusUseCase>((ref) {
  return getIt<CheckFollowStatusUseCase>();
});

final updateUserSettingsUseCaseProvider = Provider<UpdateUserSettingsUseCase>((ref) {
  return getIt<UpdateUserSettingsUseCase>();
});

final getUserSettingsUseCaseProvider = Provider<GetUserSettingsUseCase>((ref) {
  return getIt<GetUserSettingsUseCase>();
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return getIt<DeleteAccountUseCase>();
});
```

**After** (usecase_providers.dart):

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/watch_user_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../../domain/usecases/delete_profile_image_usecase.dart';
import '../../domain/usecases/get_followers_usecase.dart';
import '../../domain/usecases/get_following_usecase.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
import '../../domain/usecases/check_follow_status_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../di/profile_di_module.dart'; // getIt

part 'usecase_providers.g.dart';

// ✅ New: @riverpod getter functions (13개)

@riverpod
GetUserProfileUseCase getUserProfileUseCase(GetUserProfileUseCaseRef ref) {
  return getIt<GetUserProfileUseCase>();
}

@riverpod
UpdateUserProfileUseCase updateUserProfileUseCase(UpdateUserProfileUseCaseRef ref) {
  return getIt<UpdateUserProfileUseCase>();
}

@riverpod
WatchUserProfileUseCase watchUserProfileUseCase(WatchUserProfileUseCaseRef ref) {
  return getIt<WatchUserProfileUseCase>();
}

@riverpod
UploadProfileImageUseCase uploadProfileImageUseCase(UploadProfileImageUseCaseRef ref) {
  return getIt<UploadProfileImageUseCase>();
}

@riverpod
DeleteProfileImageUseCase deleteProfileImageUseCase(DeleteProfileImageUseCaseRef ref) {
  return getIt<DeleteProfileImageUseCase>();
}

@riverpod
GetFollowersUseCase getFollowersUseCase(GetFollowersUseCaseRef ref) {
  return getIt<GetFollowersUseCase>();
}

@riverpod
GetFollowingUseCase getFollowingUseCase(GetFollowingUseCaseRef ref) {
  return getIt<GetFollowingUseCase>();
}

@riverpod
FollowUserUseCase followUserUseCase(FollowUserUseCaseRef ref) {
  return getIt<FollowUserUseCase>();
}

@riverpod
UnfollowUserUseCase unfollowUserUseCase(UnfollowUserUseCaseRef ref) {
  return getIt<UnfollowUserUseCase>();
}

@riverpod
CheckFollowStatusUseCase checkFollowStatusUseCase(CheckFollowStatusUseCaseRef ref) {
  return getIt<CheckFollowStatusUseCase>();
}

@riverpod
UpdateUserSettingsUseCase updateUserSettingsUseCase(UpdateUserSettingsUseCaseRef ref) {
  return getIt<UpdateUserSettingsUseCase>();
}

@riverpod
GetUserSettingsUseCase getUserSettingsUseCase(GetUserSettingsUseCaseRef ref) {
  return getIt<GetUserSettingsUseCase>();
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(DeleteAccountUseCaseRef ref) {
  return getIt<DeleteAccountUseCase>();
}
```

**주요 변경사항**:

1. **Provider 정의 제거**: `final ... = Provider<T>((ref) => ...)`
2. **@riverpod 사용**: `@riverpod T functionName(Ref ref) => ...`
3. **Ref 타입 자동 생성**: `GetUserProfileUseCaseRef` 등 (build_runner가 생성)
4. **Import 정리**: 모든 UseCase import 명시적으로 추가

**Widget Usage (변경사항)**:

```dart
// ❌ Before
final useCase = ref.read(getUserProfileUseCaseProvider);

// ✅ After (동일한 방식으로 사용 가능)
final useCase = ref.read(getUserProfileUseCaseProvider);
```

**왜 변환?**

- **코드 생성**: build_runner가 boilerplate 자동 생성
- **타입 안전성**: Ref 타입이 명시적으로 생성됨
- **일관성**: 모든 Provider가 `@riverpod` 패턴 사용
- **간결함**: `Provider<T>((ref) => ...)` → `@riverpod T function(Ref ref)`

---

### 2.3 StreamProvider → @riverpod Stream

Profile Feature는 **2개의 StreamProvider**를 사용 중입니다.

#### Transformation: profileStreamProvider

**Before** (profile_providers.dart:150-180):

```dart
// ❌ Legacy: Manual StreamProvider with family
@immutable
class ProfileStreamParams {
  final String userId;
  final bool keepAlive;

  const ProfileStreamParams({
    required this.userId,
    this.keepAlive = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileStreamParams &&
          userId == other.userId &&
          keepAlive == other.keepAlive;

  @override
  int get hashCode => Object.hash(userId, keepAlive);
}

final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    yield null; // Initial null state

    final watchUseCase = ref.read(watchUserProfileUseCaseProvider);
    final stream = watchUseCase.execute(userId: params.userId);

    await for (final either in stream) {
      either.fold(
        (failure) {
          ref.read(profileErrorProvider.notifier).state = failure.message;
        },
        (_) {
          ref.read(profileErrorProvider.notifier).state = null;
        },
      );
      yield either.fold((failure) => null, (profile) => profile);
    }

    if (params.keepAlive) {
      ref.keepAlive();
    }
  },
);
```

**After** (profile_notifiers.dart):

```dart
// ✅ New: @riverpod Stream function with named parameters
@riverpod
Stream<UserProfile?> profileStream(
  ProfileStreamRef ref,
  String userId, {
  bool keepAlive = false,
}) async* {
  // keepAlive 처리
  if (keepAlive) {
    ref.keepAlive();
  }

  final watchUseCase = ref.read(watchUserProfileUseCaseProvider);
  final stream = watchUseCase.execute(userId: userId);

  await for (final either in stream) {
    yield either.fold(
      (failure) {
        // 에러를 ProfileUI Notifier에 전달
        ref.read(profileUIProvider.notifier).setError(failure.message);
        return null;
      },
      (profile) {
        // 에러 클리어
        ref.read(profileUIProvider.notifier).clearError();
        return profile;
      },
    );
  }
}
```

**Widget Usage (변경사항)**:

```dart
// ❌ Before: ProfileStreamParams 객체 생성 필요
final profileAsync = ref.watch(profileStreamProvider(
  ProfileStreamParams(
    userId: userId,
    keepAlive: true,
  ),
));

// ✅ After: Named parameters로 간결하게
final profileAsync = ref.watch(profileStreamProvider(
  userId,
  keepAlive: true,
));

// AsyncValue handling (동일)
profileAsync.when(
  data: (profile) {
    if (profile == null) return Text('Profile not found');
    return ProfileWidget(profile: profile);
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

**제거된 코드**:
- `ProfileStreamParams` 클래스 (더 이상 필요 없음)
- `yield null` (초기 상태는 AsyncValue.loading()으로 자동 처리)
- Manual `either.fold()` for error handling (Notifier에서 처리)

---

#### Transformation: settingsStreamProvider

**Before** (profile_providers.dart:200-230):

```dart
final settingsStreamProvider =
    StreamProvider.autoDispose.family<UserSettings?, String>(
  (ref, userId) async* {
    yield null;

    final watchUseCase = ref.read(watchUserSettingsUseCaseProvider);
    final stream = watchUseCase.execute(userId: userId);

    await for (final either in stream) {
      either.fold(
        (failure) {
          ref.read(settingsErrorProvider.notifier).state = failure.message;
        },
        (_) {
          ref.read(settingsErrorProvider.notifier).state = null;
        },
      );
      yield either.fold((failure) => null, (settings) => settings);
    }
  },
);
```

**After** (profile_notifiers.dart):

```dart
@riverpod
Stream<UserSettings?> settingsStream(
  SettingsStreamRef ref,
  String userId,
) async* {
  final watchUseCase = ref.read(watchUserSettingsUseCaseProvider);
  final stream = watchUseCase.execute(userId: userId);

  await for (final either in stream) {
    yield either.fold(
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
}
```

**Widget Usage**:

```dart
// ✅ Settings Screen
final settingsAsync = ref.watch(settingsStreamProvider(userId));

settingsAsync.when(
  data: (settings) {
    if (settings == null) return Text('Settings not found');
    return SettingsForm(settings: settings);
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

---

### 2.4 ProfileActions → Notifier Methods

**ProfileActions**는 static 메서드로 구성된 헬퍼 클래스입니다. 이를 **ProfileNotifier**의 메서드로 변환합니다.

**Before** (profile_providers.dart:250-400):

```dart
// ❌ Legacy: Non-Riverpod pattern
class ProfileActions {
  /// Update user profile
  static Future<void> updateProfile({
    required WidgetRef ref,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    ref.read(profileLoadingProvider.notifier).state = true;
    ref.read(profileErrorProvider.notifier).state = null;

    final useCase = ref.read(updateUserProfileUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      updates: updates,
    );

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
      },
      (_) {
        ref.read(profileErrorProvider.notifier).state = null;
      },
    );

    ref.read(profileLoadingProvider.notifier).state = false;
  }

  /// Upload profile image
  static Future<void> uploadProfileImage({
    required WidgetRef ref,
    required String userId,
    required String imagePath,
  }) async {
    ref.read(imageUploadLoadingProvider.notifier).state = true;
    ref.read(imageUploadProgressProvider.notifier).state = 0.0;

    final useCase = ref.read(uploadProfileImageUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      imagePath: imagePath,
      onProgress: (progress) {
        ref.read(imageUploadProgressProvider.notifier).state = progress;
      },
    );

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
      },
      (url) {
        // Success - image uploaded
      },
    );

    ref.read(imageUploadLoadingProvider.notifier).state = false;
  }

  /// Follow user
  static Future<void> followUser({
    required WidgetRef ref,
    required String currentUserId,
    required String targetUserId,
  }) async {
    final useCase = ref.read(followUserUseCaseProvider);
    final result = await useCase.execute(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
      },
      (_) {
        // Success
      },
    );
  }

  /// Unfollow user
  static Future<void> unfollowUser({
    required WidgetRef ref,
    required String currentUserId,
    required String targetUserId,
  }) async {
    final useCase = ref.read(unfollowUserUseCaseProvider);
    final result = await useCase.execute(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
      },
      (_) {
        // Success
      },
    );
  }

  /// Delete account
  static Future<void> deleteAccount({
    required WidgetRef ref,
    required String userId,
  }) async {
    ref.read(profileLoadingProvider.notifier).state = true;

    final useCase = ref.read(deleteAccountUseCaseProvider);
    final result = await useCase.execute(userId: userId);

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;
      },
      (_) {
        // Success - navigate to auth screen
      },
    );
  }

  /// Update settings
  static Future<void> updateSettings({
    required WidgetRef ref,
    required String userId,
    required UserSettings settings,
  }) async {
    ref.read(settingsLoadingProvider.notifier).state = true;
    ref.read(settingsErrorProvider.notifier).state = null;

    final useCase = ref.read(updateUserSettingsUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      settings: settings,
    );

    result.fold(
      (failure) {
        ref.read(settingsErrorProvider.notifier).state = failure.message;
      },
      (_) {
        ref.read(settingsErrorProvider.notifier).state = null;
      },
    );

    ref.read(settingsLoadingProvider.notifier).state = false;
  }
}
```

**After** (profile_notifiers.dart):

```dart
// ✅ New: @riverpod class Notifier with methods
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  void build() {
    // No initial state needed - this is just an action notifier
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    ref.read(profileUIProvider.notifier).setLoading(true);
    ref.read(profileUIProvider.notifier).clearError();

    final useCase = ref.read(updateUserProfileUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      updates: updates,
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

  /// Upload profile image with progress tracking
  Future<void> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    ref.read(imageUploadProvider.notifier).setUploading(true);
    ref.read(imageUploadProvider.notifier).setProgress(0.0);
    ref.read(imageUploadProvider.notifier).setError(null);

    final useCase = ref.read(uploadProfileImageUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      imagePath: imagePath,
      onProgress: (progress) {
        ref.read(imageUploadProvider.notifier).setProgress(progress);
      },
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

  /// Follow a user
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final useCase = ref.read(followUserUseCaseProvider);
    final result = await useCase.execute(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );

    result.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
      },
      (_) {
        // Success - profile stream will auto-update
        ref.read(profileUIProvider.notifier).clearError();
      },
    );
  }

  /// Unfollow a user
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final useCase = ref.read(unfollowUserUseCaseProvider);
    final result = await useCase.execute(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );

    result.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
      },
      (_) {
        // Success - profile stream will auto-update
        ref.read(profileUIProvider.notifier).clearError();
      },
    );
  }

  /// Delete user account (requires re-authentication)
  Future<void> deleteAccount({
    required String userId,
  }) async {
    ref.read(profileUIProvider.notifier).setLoading(true);
    ref.read(profileUIProvider.notifier).clearError();

    final useCase = ref.read(deleteAccountUseCaseProvider);
    final result = await useCase.execute(userId: userId);

    result.fold(
      (failure) {
        ref.read(profileUIProvider.notifier).setError(failure.message);
        ref.read(profileUIProvider.notifier).setLoading(false);
      },
      (_) {
        // Success - don't clear loading, app will navigate to auth
      },
    );
  }

  /// Update user settings
  Future<void> updateSettings({
    required String userId,
    required UserSettings settings,
  }) async {
    ref.read(settingsUIProvider.notifier).setLoading(true);
    ref.read(settingsUIProvider.notifier).clearError();

    final useCase = ref.read(updateUserSettingsUseCaseProvider);
    final result = await useCase.execute(
      userId: userId,
      settings: settings,
    );

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
}
```

**Widget Usage (변경사항)**:

```dart
// ❌ Before: Static method with WidgetRef parameter
await ProfileActions.updateProfile(
  ref: ref,
  userId: userId,
  updates: {'displayName': 'New Name'},
);

// ✅ After: Notifier instance method
await ref.read(profileNotifierProvider.notifier).updateProfile(
  userId: userId,
  updates: {'displayName': 'New Name'},
);

// ❌ Before: Image upload
await ProfileActions.uploadProfileImage(
  ref: ref,
  userId: userId,
  imagePath: imagePath,
);

// ✅ After: Notifier method
await ref.read(profileNotifierProvider.notifier).uploadProfileImage(
  userId: userId,
  imagePath: imagePath,
);

// ❌ Before: Follow/Unfollow
await ProfileActions.followUser(
  ref: ref,
  currentUserId: currentUserId,
  targetUserId: targetUserId,
);

// ✅ After: Notifier method
await ref.read(profileNotifierProvider.notifier).followUser(
  currentUserId: currentUserId,
  targetUserId: targetUserId,
);
```

**주요 변경사항**:

1. **WidgetRef 파라미터 제거**: `ref`는 Notifier 내부에서 사용 가능
2. **State 업데이트 간소화**: 다른 Notifier의 메서드 호출
3. **타입 안전성**: build_runner가 `ProfileNotifierProvider` 생성
4. **캡슐화**: Action 로직이 Notifier 내부에 캡슐화됨

---

### 2.5 Code Generation & Validation

모든 Provider 변환이 완료되면 코드를 생성하고 검증합니다.

#### Step 1: Part Directives 추가 확인

**profile_notifiers.dart** 상단:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ... other imports

part 'profile_notifiers.freezed.dart'; // ✅ Freezed 생성
part 'profile_notifiers.g.dart';       // ✅ Riverpod 생성
```

**usecase_providers.dart** 상단:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ... other imports

part 'usecase_providers.g.dart'; // ✅ Riverpod 생성
```

#### Step 2: Build Runner 실행

```bash
# 이전 빌드 정리
flutter clean
flutter pub get

# 코드 생성 (충돌하는 출력 삭제)
dart run build_runner build --delete-conflicting-outputs

# Watch 모드 (개발 중 자동 재생성)
dart run build_runner watch --delete-conflicting-outputs
```

**예상 출력**:

```
[INFO] Generating build script completed, took 412ms
[INFO] Reading cached asset graph completed, took 89ms
[INFO] Checking for updates since last build completed, took 657ms
[INFO] Running build completed, took 5.2s
[INFO] Caching finalized dependency graph completed, took 54ms
[INFO] Succeeded after 5.3s with 18 outputs (24 actions)
```

#### Step 3: Generated Files 확인

```bash
# 생성된 파일 확인
ls -la lib/features/profile/presentation/providers/

# 예상 출력:
# profile_notifiers.dart
# profile_notifiers.freezed.dart  ✅ NEW
# profile_notifiers.g.dart        ✅ NEW
# usecase_providers.dart
# usecase_providers.g.dart        ✅ NEW
# profile_post_providers.dart     (기존)
# profile_post_providers.g.dart   (기존)
```

#### Step 4: Import 검증

**profile_providers.dart에서 legacy import 제거**:

```dart
// ❌ Remove this line
import 'package:flutter_riverpod/legacy.dart';

// ✅ Keep only these
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
```

#### Step 5: Static Analysis

```bash
# 코드 분석 (에러 확인)
flutter analyze lib/features/profile/

# 예상: No issues found!
```

**일반적인 빌드 에러와 해결방법**:

| Error | Cause | Solution |
|-------|-------|----------|
| `Missing part directive` | `part '*.g.dart'` 없음 | 파일 상단에 part 추가 |
| `Conflicting outputs` | 이전 .g.dart 파일 충돌 | `--delete-conflicting-outputs` 사용 |
| `@riverpod not found` | riverpod_annotation import 없음 | import 추가 |
| `_$ClassName not found` | build_runner 미실행 | `dart run build_runner build` 실행 |
| `Freezed error` | @freezed 누락 | Freezed annotation 추가 |

---

### 2.6 Provider Transformation Matrix

전체 변환 작업의 요약표입니다.

| # | Current (2.x) | Type | Count | Target (3.x) | File | Status |
|---|---------------|------|-------|--------------|------|--------|
| 1 | `profileLoadingProvider` | StateProvider<bool> | 1 | `ProfileUIState.isLoading` | profile_notifiers.dart | ✅ |
| 2 | `profileErrorProvider` | StateProvider<String?> | 1 | `ProfileUIState.error` | profile_notifiers.dart | ✅ |
| 3 | `settingsLoadingProvider` | StateProvider<bool> | 1 | `SettingsUIState.isLoading` | profile_notifiers.dart | ✅ |
| 4 | `settingsErrorProvider` | StateProvider<String?> | 1 | `SettingsUIState.error` | profile_notifiers.dart | ✅ |
| 5 | `imageUploadLoadingProvider` | StateProvider<bool> | 1 | `ImageUploadState.isUploading` | profile_notifiers.dart | ✅ |
| 6 | `imageUploadProgressProvider` | StateProvider<double> | 1 | `ImageUploadState.progress` | profile_notifiers.dart | ✅ |
| 7-19 | UseCase Providers | Provider<UseCase> | 13 | `@riverpod UseCase getter()` | usecase_providers.dart | ✅ |
| 20 | `profileStreamProvider` | StreamProvider.family | 1 | `@riverpod Stream profileStream()` | profile_notifiers.dart | ✅ |
| 21 | `settingsStreamProvider` | StreamProvider.family | 1 | `@riverpod Stream settingsStream()` | profile_notifiers.dart | ✅ |
| 22 | `ProfileActions.updateProfile()` | Static method | 1 | `ProfileNotifier.updateProfile()` | profile_notifiers.dart | ✅ |
| 23 | `ProfileActions.uploadProfileImage()` | Static method | 1 | `ProfileNotifier.uploadProfileImage()` | profile_notifiers.dart | ✅ |
| 24 | `ProfileActions.followUser()` | Static method | 1 | `ProfileNotifier.followUser()` | profile_notifiers.dart | ✅ |
| 25 | `ProfileActions.unfollowUser()` | Static method | 1 | `ProfileNotifier.unfollowUser()` | profile_notifiers.dart | ✅ |
| 26 | `ProfileActions.deleteAccount()` | Static method | 1 | `ProfileNotifier.deleteAccount()` | profile_notifiers.dart | ✅ |
| 27 | `ProfileActions.updateSettings()` | Static method | 1 | `ProfileNotifier.updateSettings()` | profile_notifiers.dart | ✅ |
| **Total** | — | — | **27** | **~20 providers** | **2 files** | — |

**코드 감소 효과**:

- **Before**: profile_providers.dart (560줄, 수동 정의)
- **After**:
  - profile_notifiers.dart (~200줄, 선언적)
  - usecase_providers.dart (~100줄, 선언적)
  - Generated files (~400줄, 자동 생성)
- **Net Result**: ~30% 코드 감소 (수동 작성 기준)

---

## Appendix A: File Organization Strategy

### 최종 파일 구조

```
lib/features/profile/presentation/providers/
├── profile_notifiers.dart (NEW: ~200줄)
│   ├── Imports (riverpod_annotation, freezed_annotation)
│   ├── Part directives (*.freezed.dart, *.g.dart)
│   │
│   ├── [Freezed States]
│   │   ├── ProfileUIState (isLoading, error)
│   │   ├── SettingsUIState (isLoading, error)
│   │   └── ImageUploadState (isUploading, progress, error, uploadedUrl)
│   │
│   ├── [State Notifiers]
│   │   ├── @riverpod class ProfileUI extends _$ProfileUI
│   │   ├── @riverpod class SettingsUI extends _$SettingsUI
│   │   └── @riverpod class ImageUpload extends _$ImageUpload
│   │
│   ├── [Action Notifier]
│   │   └── @riverpod class ProfileNotifier extends _$ProfileNotifier
│   │       ├── updateProfile()
│   │       ├── uploadProfileImage()
│   │       ├── followUser()
│   │       ├── unfollowUser()
│   │       ├── deleteAccount()
│   │       └── updateSettings()
│   │
│   └── [Stream Providers]
│       ├── @riverpod Stream<UserProfile?> profileStream(...)
│       └── @riverpod Stream<UserSettings?> settingsStream(...)
│
├── profile_notifiers.freezed.dart (GENERATED: ~300줄)
├── profile_notifiers.g.dart (GENERATED: ~100줄)
│
├── usecase_providers.dart (NEW: ~100줄)
│   ├── Import (riverpod_annotation)
│   ├── Part directive (*.g.dart)
│   │
│   └── [UseCase Providers] (13개)
│       ├── @riverpod GetUserProfileUseCase getUserProfileUseCase(Ref)
│       ├── @riverpod UpdateUserProfileUseCase updateUserProfileUseCase(Ref)
│       ├── @riverpod WatchUserProfileUseCase watchUserProfileUseCase(Ref)
│       ├── @riverpod UploadProfileImageUseCase uploadProfileImageUseCase(Ref)
│       ├── @riverpod DeleteProfileImageUseCase deleteProfileImageUseCase(Ref)
│       ├── @riverpod GetFollowersUseCase getFollowersUseCase(Ref)
│       ├── @riverpod GetFollowingUseCase getFollowingUseCase(Ref)
│       ├── @riverpod FollowUserUseCase followUserUseCase(Ref)
│       ├── @riverpod UnfollowUserUseCase unfollowUserUseCase(Ref)
│       ├── @riverpod CheckFollowStatusUseCase checkFollowStatusUseCase(Ref)
│       ├── @riverpod UpdateUserSettingsUseCase updateUserSettingsUseCase(Ref)
│       ├── @riverpod GetUserSettingsUseCase getUserSettingsUseCase(Ref)
│       └── @riverpod DeleteAccountUseCase deleteAccountUseCase(Ref)
│
├── usecase_providers.g.dart (GENERATED: ~100줄)
│
├── profile_post_providers.dart (EXISTING: 68줄) ✅ Keep as-is
├── profile_post_providers.g.dart (EXISTING) ✅ Keep as-is
│
└── profile_providers.dart (DEPRECATED: 560줄)
    └── To be removed after migration complete
```

### Import Strategy (Widget에서)

**Before**:

```dart
import '../providers/profile_providers.dart'; // All providers
```

**After**:

```dart
// Option 1: 필요한 파일만 import
import '../providers/profile_notifiers.dart'; // State + Actions + Streams
import '../providers/usecase_providers.dart'; // UseCases (필요시)

// Option 2: Barrel export 사용 (선택사항)
// providers/providers.dart 생성:
// export 'profile_notifiers.dart';
// export 'usecase_providers.dart';
// export 'profile_post_providers.dart';

import '../providers/providers.dart'; // All
```

---

## Appendix B: Migration Checklist

### Phase 1: Preparation

- [ ] **의존성 확인 완료**
  - [ ] pubspec.yaml에 riverpod_annotation, riverpod_generator 존재
  - [ ] 버전 확인: flutter_riverpod ^2.4.0, riverpod_annotation ^2.3.0
- [ ] **Git 백업 완료**
  - [ ] `feature/profile-riverpod-3x` 브랜치 생성
  - [ ] Pre-migration 커밋 완료
  - [ ] (선택) backup/profile-riverpod-2x 브랜치 생성
- [ ] **파일 구조 설계**
  - [ ] profile_notifiers.dart 구조 이해
  - [ ] usecase_providers.dart 구조 이해
- [ ] **참조 자료 확인**
  - [ ] profile_post_providers.dart 분석 (3.x 템플릿)
  - [ ] Creation Feature 참조 (동일 패턴)
  - [ ] Voting Feature 문서 읽음
- [ ] **현재 상태 테스트**
  - [ ] `flutter test` 정상 동작
  - [ ] `flutter run` 정상 동작
  - [ ] `flutter analyze` 에러 없음

### Phase 2: Provider Transformation

- [ ] **2.1 StateProvider → Notifier (6개 → 3개)**
  - [ ] ProfileUIState (Freezed) 정의
  - [ ] ProfileUI Notifier 정의
  - [ ] SettingsUIState (Freezed) 정의
  - [ ] SettingsUI Notifier 정의
  - [ ] ImageUploadState (Freezed) 정의
  - [ ] ImageUpload Notifier 정의
- [ ] **2.2 Provider<UseCase> → @riverpod function (13개)**
  - [ ] usecase_providers.dart 파일 생성
  - [ ] Part directive 추가
  - [ ] 13개 UseCase Provider 변환 완료
- [ ] **2.3 StreamProvider → @riverpod Stream (2개)**
  - [ ] profileStream 변환 완료
  - [ ] settingsStream 변환 완료
  - [ ] ProfileStreamParams 클래스 제거
- [ ] **2.4 ProfileActions → Notifier Methods (6개)**
  - [ ] ProfileNotifier 클래스 정의
  - [ ] updateProfile() 메서드 구현
  - [ ] uploadProfileImage() 메서드 구현
  - [ ] followUser() 메서드 구현
  - [ ] unfollowUser() 메서드 구현
  - [ ] deleteAccount() 메서드 구현
  - [ ] updateSettings() 메서드 구현
- [ ] **2.5 Code Generation**
  - [ ] Part directives 추가 확인
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
  - [ ] Generated files 확인 (*.g.dart, *.freezed.dart)
  - [ ] legacy.dart import 제거
  - [ ] `flutter analyze` 에러 없음

### 다음 단계

- [ ] **Phase 3-7로 진행**
  - [ ] Widget Integration (Phase 3)
  - [ ] Code Generation (Phase 4)
  - [ ] Testing & Verification (Phase 5)
  - [ ] Legacy Code Cleanup (Phase 6)
  - [ ] Documentation (Phase 7)

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-11-06
**작성자**: Claude Code
**다음 문서**: [RIVERPOD_3X_MIGRATION_PHASE_3_7.md](./RIVERPOD_3X_MIGRATION_PHASE_3_7.md)
