# Phase 3: Riverpod 2.x 마이그레이션

> **소요 시간**: 2일
> **난이도**: ⭐⭐⭐⭐☆ (높음)
> **영향 범위**: Presentation Layer (4개 Provider + UI 5개 화면)
> **UI 영향**: ✅ **있음** (5개 화면 모두 변경 필요)

---

## 📋 목차

1. [개요](#1-개요)
2. [현재 상태 분석](#2-현재-상태-분석)
3. [마이그레이션 목표](#3-마이그레이션-목표)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [백엔드-UI 연결 완전 가이드](#6-백엔드-ui-연결-완전-가이드)
7. [5개 UI 화면 변경 가이드](#7-5개-ui-화면-변경-가이드)
8. [테스트 전략](#8-테스트-전략)
9. [롤백 계획](#9-롤백-계획)

---

## 1. 개요

### 1.1 Phase 3의 목적

Auth Feature와 Voting Feature의 실시간 상태 관리 패턴을 Profile Feature에 적용합니다:
- ✅ **Riverpod 2.x**: ChangeNotifier → StreamProvider.family
- ✅ **keepAlive()**: 수동 캐싱 → Provider 자동 관리
- ✅ **자동 dispose**: 수동 notifyListeners() → Stream 자동 감지
- ✅ **UI 자동 업데이트**: setState() → ref.watch() 자동 리렌더링

### 1.2 변경 대상

| Layer | 파일 | 라인 | 변경 내용 |
|-------|------|------|----------|
| **Presentation - Provider** | `profile_provider.dart` | 380줄 | **유지** (하위 호환성) |
| **Presentation - Provider** | `characters_provider.dart` | 156줄 | **유지** (하위 호환성) |
| **Presentation - Provider** | `settings_provider.dart` | 198줄 | **유지** (하위 호환성) |
| **Presentation - Provider** | `interests_provider.dart` | 145줄 | **유지** (하위 호환성) |
| **Presentation - Provider** | `profile_providers.dart` | 0줄 → 450줄 | **신규 생성** |
| **Presentation - UI** | `settings_screen.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `user_posts_list_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `profile_edit_screen.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `select_your_interests_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `user_info_display_screen.dart` | 변경 | Consumer 패턴 |

**총 변경**: 1개 신규 생성 + 5개 UI 화면 수정

### 1.3 왜 Riverpod를 사용하는가?

**ChangeNotifier + GetIt의 한계**:
```dart
// ❌ 현재 패턴
class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();  // 수동 호출

    final result = await _getProfileUseCase.execute(userId: userId);

    if (result is Success<UserProfile>) {
      _profile = result.data;
      _errorMessage = null;
    } else if (result is ResultFailure<UserProfile>) {
      _errorMessage = result.failure.message;
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();  // 수동 호출
  }

  @override
  void dispose() {
    // dispose 필요
    super.dispose();
  }
}

// UI에서 사용
late final ProfileProvider _profileProvider = GetIt.instance<ProfileProvider>();

@override
void initState() {
  super.initState();
  _profileProvider.loadProfile(userId);  // 수동 호출
}

// 문제점:
// 1. notifyListeners() 수동 호출
// 2. 초기화 타이밍 복잡
// 3. dispose 누락 시 메모리 누수
// 4. 상태 업데이트 누락 가능성
```

**Riverpod의 장점**:
```dart
// ✅ Riverpod 패턴
final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile, ProfileStreamParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: null 또는 캐시된 값 먼저 emit
    yield null;

    // 2. Firestore 실시간 Stream
    await for (final profile in _firestoreProfileStream(params.userId)) {
      yield profile;
    }

    // 3. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

// UI에서 사용
class ProfileEditScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStreamProvider(
      ProfileStreamParams(userId: userId),
    ));

    return profileState.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(e),
      data: (profile) => _buildEditForm(profile),
    );
  }
}

// 장점:
// 1. Stream 자동 관리 (autoDispose)
// 2. 메모리 누수 방지 (자동 dispose)
// 3. UI 자동 업데이트 (Stream 감지)
// 4. 초기화 불필요 (Provider 자동 생성)
// 5. Auth/Voting Feature와 100% 동일한 패턴
```

**Auth Feature 참조 패턴**:
```dart
// lib/features/auth/presentation/providers/auth_providers.dart
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    yield null;  // 기본값

    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      yield user?.toAuthUser();  // 실시간 업데이트
    }

    ref.keepAlive();  // 중복 리스너 방지
  },
);
```

---

## 2. 현재 상태 분석

### 2.1 ChangeNotifier 패턴 구조

**파일**: `lib/features/profile/presentation/providers/profile_provider.dart` (380줄)

<details>
<summary>현재 전체 구조 보기 (클릭)</summary>

```dart
// ❌ Before: ChangeNotifier + GetIt
import 'package:flutter/material.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
// ... 6개 UseCase imports

class ProfileProvider extends ChangeNotifier {
  // ========== Dependencies (8 UseCases) ==========
  final GetUserProfileUseCase _getProfileUseCase;
  final GetCurrentUserProfileUseCase _getCurrentProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadImageUseCase;
  final DeleteProfileUseCase _deleteProfileUseCase;
  final WatchUserProfileUseCase _watchProfileUseCase;
  final GetProfileCompletionUseCase _getCompletionUseCase;
  final GetProfileInfoUseCase _getInfoUseCase;

  ProfileProvider({
    required GetUserProfileUseCase getProfileUseCase,
    required GetCurrentUserProfileUseCase getCurrentProfileUseCase,
    required UpdateUserProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadImageUseCase,
    required DeleteProfileUseCase deleteProfileUseCase,
    required WatchUserProfileUseCase watchProfileUseCase,
    required GetProfileCompletionUseCase getCompletionUseCase,
    required GetProfileInfoUseCase getInfoUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _getCurrentProfileUseCase = getCurrentProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadImageUseCase = uploadImageUseCase,
        _deleteProfileUseCase = deleteProfileUseCase,
        _watchProfileUseCase = watchProfileUseCase,
        _getCompletionUseCase = getCompletionUseCase,
        _getInfoUseCase = getInfoUseCase;

  // ========== State ==========
  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  double? _profileCompletion;

  // ========== Getters ==========
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get profileCompletion => _profileCompletion;

  // ========== Public Methods ==========

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    if (result is Success<UserProfile>) {
      _profile = result.data;
      _errorMessage = null;
    } else if (result is ResultFailure<UserProfile>) {
      _errorMessage = result.failure.message;
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(
      userId: userId,
      updatedProfile: updatedProfile,
    );

    if (result is Success<void>) {
      _profile = updatedProfile;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result is ResultFailure<void>) {
      _errorMessage = result.failure.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<void> uploadProfileImage(String userId, File imageFile) async {
    _isLoading = true;
    notifyListeners();

    final result = await _uploadImageUseCase.execute(
      userId: userId,
      imageFile: imageFile,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (imageUrl) {
        // Update profile with new image URL
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ... 5개 메서드 더

  // ========== Private Helpers ==========
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

</details>

### 2.2 현재 UI 사용 패턴

**파일**: `lib/features/profile/presentation/screens/profile_edit/profile_edit_screen.dart`

```dart
// ❌ Before: GetIt + ChangeNotifier
class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final ProfileProvider _profileProvider = GetIt.instance<ProfileProvider>();

  @override
  void initState() {
    super.initState();
    _profileProvider.loadProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _profileProvider.isLoading
          ? CircularProgressIndicator()
          : _buildEditForm(),
    );
  }

  Future<void> _handleSave() async {
    if (_profileProvider.isLoading) return;

    final success = await _profileProvider.updateProfile(
      userId: widget.userId,
      updatedProfile: updatedProfile,
    );

    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileProvider.errorMessage ?? 'Update failed')),
      );
    }
  }
}
```

### 2.3 문제점 요약

| 문제 | 설명 | 영향 |
|------|------|------|
| **notifyListeners 수동** | 모든 상태 변경 시 수동 호출 | 휴먼 에러 가능성 |
| **초기화 체크** | initState에서 수동 로딩 | UI에서 매번 호출 |
| **dispose 누락 위험** | 수동 dispose 관리 | 메모리 누수 가능성 |
| **4개 Provider 중복** | 유사한 패턴 4번 반복 | 유지보수 복잡 |
| **실시간 동기화 부족** | Firestore Stream 미사용 | 데이터 불일치 |

---

## 3. 마이그레이션 목표

### 3.1 Riverpod Provider 구조

**신규 파일**: `lib/features/profile/presentation/providers/profile_providers.dart` (450줄)

```dart
// ✅ After: Riverpod Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '/app/di.dart';  // GetIt은 UseCase에만 사용
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/entities/profile_info.dart';
import '/features/profile/domain/entities/user_settings.dart';
import '/features/profile/domain/entities/character.dart';
import '/features/profile/domain/entities/interest.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
// ... 12개 UseCase imports

// ========== UseCase Providers (GetIt 래핑) ==========
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return getIt<GetUserProfileUseCase>();
});

final getCurrentUserProfileUseCaseProvider = Provider<GetCurrentUserProfileUseCase>((ref) {
  return getIt<GetCurrentUserProfileUseCase>();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return getIt<UpdateUserProfileUseCase>();
});

// ... 10개 더

// ========== Profile Stream Provider ==========
/// Auth/Voting Feature 패턴 100% 적용
///
/// **실시간 프로필 동기화**:
/// - ✅ Firestore Stream 직접 사용
/// - ✅ 자동 dispose (autoDispose)
/// - ✅ 캐싱 (keepAlive)
/// - ✅ Family로 userId별 독립 관리
final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: null 먼저 emit
    yield null;

    // 2. Firestore 실시간 Stream
    final watchUseCase = ref.read(watchUserProfileUseCaseProvider);
    await for (final profile in watchUseCase.execute(userId: params.userId)) {
      yield profile;
    }

    // 3. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

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

// ========== Settings Stream Provider ==========
final settingsStreamProvider =
    StreamProvider.autoDispose.family<UserSettings?, SettingsStreamParams>(
  (ref, params) async* {
    yield null;

    // Firestore settings 컬렉션 감시
    final watchUseCase = ref.read(watchUserSettingsUseCaseProvider);
    await for (final settings in watchUseCase.execute(userId: params.userId)) {
      yield settings;
    }

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

// ========== Characters Provider ==========
final charactersProvider = FutureProvider<List<Character>>((ref) async {
  final useCase = ref.read(getAvailableCharactersUseCaseProvider);
  final result = await useCase.execute();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (characters) => characters,
  );
});

// ========== Interests Provider ==========
final interestsProvider = FutureProvider<List<Interest>>((ref) async {
  final useCase = ref.read(getInterestsUseCaseProvider);
  final result = await useCase.execute();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (interests) => interests,
  );
});

// ========== Loading & Error State ==========
final profileLoadingProvider = StateProvider<bool>((ref) => false);
final profileErrorProvider = StateProvider<String?>((ref) => null);

final settingsLoadingProvider = StateProvider<bool>((ref) => false);
final settingsErrorProvider = StateProvider<String?>((ref) => null);
```

### 3.2 목표 UI 패턴

```dart
// ✅ After: ConsumerStatefulWidget + ref.watch
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({required this.userId, Key? key}) : super(key: key);

  final String userId;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  // GetIt 제거, initState 불필요

  @override
  Widget build(BuildContext context) {
    // 1. Profile 상태 감시 (실시간 동기화)
    final profileState = ref.watch(profileStreamProvider(
      ProfileStreamParams(userId: widget.userId),
    ));

    // 2. 로딩 상태 감시
    final isLoading = ref.watch(profileLoadingProvider);

    // 3. 에러 메시지 감시
    final errorMessage = ref.watch(profileErrorProvider);

    return Scaffold(
      body: profileState.when(
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(e),
        data: (profile) => profile == null
            ? Text('프로필을 찾을 수 없습니다')
            : _buildEditForm(profile, isLoading, errorMessage),
      ),
    );
  }

  Future<void> _handleSave(UserProfile updatedProfile) async {
    // 1. 로딩 시작
    ref.read(profileLoadingProvider.notifier).state = true;

    // 2. UseCase 실행
    final updateUseCase = ref.read(updateUserProfileUseCaseProvider);

    final result = await updateUseCase.execute(
      userId: widget.userId,
      updatedProfile: updatedProfile,
    );

    // 3. 결과 처리
    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ref.read(profileLoadingProvider.notifier).state = false;
        context.pop();
      },
    );
  }
}
```

### 3.3 변경 요약

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **Widget Type** | `StatefulWidget` | `ConsumerStatefulWidget` | Riverpod |
| **Provider 주입** | `GetIt.instance<ProfileProvider>()` | `ref.watch(provider)` | Riverpod |
| **초기화** | `loadProfile(userId)` | 불필요 | 자동 |
| **상태 감시** | `_profileProvider.profile` | `ref.watch(profileStreamProvider)` | Stream |
| **상태 업데이트** | `notifyListeners()` | Stream 자동 감지 | 자동 |
| **실시간 동기화** | 없음 | Firestore Stream | 추가 |
| **코드 라인** | 380줄 | 450줄 (4개 Provider 통합) | 통합 |

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: 의존성 추가** (Auth Phase 3에서 이미 추가됨)

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.1
```

```bash
flutter pub get
```

**Step 2: 백업 생성**

```bash
# Presentation Layer 백업
cp -r lib/features/profile/presentation lib/features/profile/presentation.backup

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(profile): Backup before Riverpod migration"
```

### 4.2 Riverpod Provider 생성

**Step 3: profile_providers.dart 신규 생성**

**파일**: `lib/features/profile/presentation/providers/profile_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '/app/di.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/domain/entities/profile_info.dart';
import '/features/profile/domain/entities/user_settings.dart';
import '/features/profile/domain/entities/character.dart';
import '/features/profile/domain/entities/interest.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import '/features/profile/domain/usecases/profile/delete_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/watch_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/get_profile_completion_usecase.dart';
import '/features/profile/domain/usecases/profile/get_profile_info_usecase.dart';
import '/features/profile/domain/usecases/settings/get_user_settings_usecase.dart';
import '/features/profile/domain/usecases/settings/update_user_settings_usecase.dart';
import '/features/profile/domain/usecases/characters/get_available_characters_usecase.dart';
import '/features/profile/domain/usecases/interests/get_interests_usecase.dart';
import '/features/profile/domain/usecases/interests/update_interests_usecase.dart';

// ========== UseCase Providers ==========
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

final deleteProfileUseCaseProvider = Provider<DeleteProfileUseCase>((ref) {
  return getIt<DeleteProfileUseCase>();
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

final getInterestsUseCaseProvider = Provider<GetInterestsUseCase>((ref) {
  return getIt<GetInterestsUseCase>();
});

final updateInterestsUseCaseProvider = Provider<UpdateInterestsUseCase>((ref) {
  return getIt<UpdateInterestsUseCase>();
});

// ========== Profile Stream Provider ==========
final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    yield null;

    // Firestore 실시간 Stream
    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(params.userId)
        .snapshots();

    await for (final doc in docStream) {
      if (doc.exists) {
        yield UserProfile.fromFirestore(doc);
      } else {
        yield null;
      }
    }

    ref.keepAlive();
  },
);

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

// ========== Settings Stream Provider ==========
final settingsStreamProvider =
    StreamProvider.autoDispose.family<UserSettings?, SettingsStreamParams>(
  (ref, params) async* {
    yield null;

    // Firestore settings 컬렉션 감시
    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(params.userId)
        .collection('settings')
        .doc('user_settings')
        .snapshots();

    await for (final doc in docStream) {
      if (doc.exists) {
        yield UserSettings.fromFirestore(doc);
      } else {
        yield null;
      }
    }

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

// ========== Characters Provider ==========
final charactersProvider = FutureProvider<List<Character>>((ref) async {
  final useCase = ref.read(getAvailableCharactersUseCaseProvider);
  final result = await useCase.execute();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (characters) => characters,
  );
});

// ========== Interests Provider ==========
final interestsProvider = FutureProvider<List<Interest>>((ref) async {
  final useCase = ref.read(getInterestsUseCaseProvider);
  final result = await useCase.execute();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (interests) => interests,
  );
});

// ========== Loading & Error State ==========
final profileLoadingProvider = StateProvider<bool>((ref) => false);
final profileErrorProvider = StateProvider<String?>((ref) => null);

final settingsLoadingProvider = StateProvider<bool>((ref) => false);
final settingsErrorProvider = StateProvider<String?>((ref) => null);
```

**Step 4: main.dart에 ProviderScope 추가** (Auth Phase 3에서 이미 추가됨)

```dart
// lib/main.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // GetIt 초기화 (UseCase 등록)
  setupGetIt();

  runApp(
    ProviderScope(  // ← Riverpod 추가됨
      child: MyApp(),
    ),
  );
}
```

### 4.3 UI 화면 변경 (5개 파일)

**패턴 1: StatefulWidget → ConsumerStatefulWidget**

```dart
// Before
class ProfileEditScreen extends StatefulWidget {
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final ProfileProvider _profileProvider = GetIt.instance<ProfileProvider>();
  // ...
}

// After
class ProfileEditScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  // GetIt 제거
  // ...
}
```

**패턴 2: build 메서드 변경**

```dart
// Before
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _profileProvider.isLoading
        ? CircularProgressIndicator()
        : _buildForm(),
  );
}

// After
@override
Widget build(BuildContext context) {
  final profileState = ref.watch(profileStreamProvider(
    ProfileStreamParams(userId: widget.userId),
  ));
  final isLoading = ref.watch(profileLoadingProvider);

  return Scaffold(
    body: profileState.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(e),
      data: (profile) => profile == null
          ? Text('프로필을 찾을 수 없습니다')
          : isLoading
              ? CircularProgressIndicator()
              : _buildForm(profile),
    ),
  );
}
```

**패턴 3: 액션 메서드 변경**

```dart
// Before
Future<void> _handleSave() async {
  final success = await _profileProvider.updateProfile(
    userId: userId,
    updatedProfile: updatedProfile,
  );

  if (success) {
    context.pop();
  } else {
    showError(_profileProvider.errorMessage);
  }
}

// After
Future<void> _handleSave() async {
  ref.read(profileLoadingProvider.notifier).state = true;

  final updateUseCase = ref.read(updateUserProfileUseCaseProvider);

  final result = await updateUseCase.execute(
    userId: userId,
    updatedProfile: updatedProfile,
  );

  result.fold(
    (failure) {
      ref.read(profileErrorProvider.notifier).state = failure.message;
      ref.read(profileLoadingProvider.notifier).state = false;
      showError(failure.message);
    },
    (_) {
      ref.read(profileLoadingProvider.notifier).state = false;
      context.pop();
    },
  );
}
```

### 4.4 컴파일 확인

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 에러:
# - StatefulWidget → ConsumerStatefulWidget 변경 필요
# - GetIt.instance → ref.watch 변경 필요
```

### 4.5 기존 Provider 유지 (하위 호환성)

**Step 5: 기존 4개 Provider 유지**

```dart
// lib/features/profile/presentation/providers/profile_provider.dart

// ⚠️ DEPRECATED: Riverpod로 마이그레이션 중
// 하위 호환성을 위해 일시적으로 유지
// 모든 UI 화면이 Riverpod로 전환되면 삭제 예정

@Deprecated('Use profile_providers.dart with Riverpod instead')
class ProfileProvider extends ChangeNotifier {
  // ... 기존 코드 유지
}

@Deprecated('Use profile_providers.dart with Riverpod instead')
class CharactersProvider extends ChangeNotifier {
  // ... 기존 코드 유지
}

@Deprecated('Use profile_providers.dart with Riverpod instead')
class SettingsProvider extends ChangeNotifier {
  // ... 기존 코드 유지
}

@Deprecated('Use profile_providers.dart with Riverpod instead')
class InterestsProvider extends ChangeNotifier {
  // ... 기존 코드 유지
}
```

---

## 5. Before/After 전체 코드

### 5.1 Provider 비교

<details>
<summary>Before: profile_provider.dart (380줄) - 일부</summary>

```dart
class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    if (result is Success<UserProfile>) {
      _profile = result.data;
      _errorMessage = null;
    } else if (result is ResultFailure<UserProfile>) {
      _errorMessage = result.failure.message;
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String userId,
    required UserProfile updatedProfile,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(
      userId: userId,
      updatedProfile: updatedProfile,
    );

    if (result is Success<void>) {
      _profile = updatedProfile;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result is ResultFailure<void>) {
      _errorMessage = result.failure.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return false;
  }
}
```

</details>

<details>
<summary>After: profile_providers.dart (450줄) - 핵심 부분</summary>

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '/app/di.dart';
import '/features/profile/domain/entities/user_profile.dart';
// ... imports

// ========== UseCase Providers ==========
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return getIt<GetUserProfileUseCase>();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return getIt<UpdateUserProfileUseCase>();
});

// ... 11개 더

// ========== Profile Stream Provider ==========
final profileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile?, ProfileStreamParams>(
  (ref, params) async* {
    yield null;

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(params.userId)
        .snapshots();

    await for (final doc in docStream) {
      if (doc.exists) {
        yield UserProfile.fromFirestore(doc);
      } else {
        yield null;
      }
    }

    ref.keepAlive();
  },
);

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

// ========== Loading & Error State ==========
final profileLoadingProvider = StateProvider<bool>((ref) => false);
final profileErrorProvider = StateProvider<String?>((ref) => null);
```

</details>

### 5.2 UI 비교: ProfileEditScreen

<details>
<summary>Before: GetIt + ChangeNotifier (일부)</summary>

```dart
class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final ProfileProvider _profileProvider = GetIt.instance<ProfileProvider>();

  @override
  void initState() {
    super.initState();
    _profileProvider.loadProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _profileProvider.isLoading
          ? CircularProgressIndicator()
          : _buildEditForm(),
    );
  }

  Future<void> _handleSave() async {
    if (_profileProvider.isLoading) return;

    final success = await _profileProvider.updateProfile(
      userId: widget.userId,
      updatedProfile: updatedProfile,
    );

    if (success) {
      context.pop();
    } else {
      showError(_profileProvider.errorMessage);
    }
  }
}
```

</details>

<details>
<summary>After: Riverpod (일부)</summary>

```dart
class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  // initState 불필요

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStreamProvider(
      ProfileStreamParams(userId: widget.userId),
    ));
    final isLoading = ref.watch(profileLoadingProvider);
    final errorMessage = ref.watch(profileErrorProvider);

    return Scaffold(
      body: profileState.when(
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(e),
        data: (profile) => profile == null
            ? Text('프로필을 찾을 수 없습니다')
            : isLoading
                ? CircularProgressIndicator()
                : _buildEditForm(profile, errorMessage),
      ),
    );
  }

  Future<void> _handleSave(UserProfile updatedProfile) async {
    ref.read(profileLoadingProvider.notifier).state = true;

    final updateUseCase = ref.read(updateUserProfileUseCaseProvider);

    final result = await updateUseCase.execute(
      userId: widget.userId,
      updatedProfile: updatedProfile,
    );

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;
        showError(failure.message);
      },
      (_) {
        ref.read(profileLoadingProvider.notifier).state = false;
        context.pop();
      },
    );
  }
}
```

</details>

---

## 6. 백엔드-UI 연결 완전 가이드

### 6.1 프로필 편집 플로우 (End-to-End)

```
[UI Layer] profile_edit_screen.dart
    ↓ 사용자가 저장 버튼 클릭
    ↓ _handleSave(updatedProfile) 호출
    │
    ├─ ref.read(profileLoadingProvider.notifier).state = true
    │  → 로딩 UI 표시
    │
    └─ ref.read(updateUserProfileUseCaseProvider)
       → UseCase 가져오기 (GetIt)

[Domain Layer] update_user_profile_usecase.dart
    ↓ execute(userId, updatedProfile) 호출
    ↓ 프로필 유효성 검증
    ↓
    ├─ 실패: return left(ProfileFailure.validation('userName'))
    │
    └─ 성공: _repository.updateUserProfile()

[Data Layer] user_repository_impl.dart
    ↓ updateUserProfile(userId, profile) 호출
    ↓ Firestore 업데이트

[Firebase Backend] Cloud Firestore
    ↓ POST /users/{userId}
    ↓ 문서 업데이트
    │
    ├─ 실패: throw FirebaseException
    │  ↓ _mapFirebaseException()
    │  ↓ return left(ProfileFailure.firestoreWrite())
    │
    └─ 성공: return right(unit)

[Data Layer → Domain Layer]
    ↓ Either<ProfileFailure, Unit> 반환

[Domain Layer → UI Layer]
    ↓ result.fold()
    │
    ├─ Left(failure):
    │  ↓ ref.read(profileErrorProvider.notifier).state = failure.message
    │  ↓ ref.read(profileLoadingProvider.notifier).state = false
    │  └─ SnackBar 에러 표시
    │
    └─ Right(_):
       ↓ ref.read(profileLoadingProvider.notifier).state = false
       ↓ context.pop()

[Riverpod Stream] profileStreamProvider
    ↓ Firestore.snapshots() 감지
    ↓ yield UserProfile.fromFirestore(doc)
    └─ UI 자동 리렌더링 (ref.watch 중인 모든 위젯)
```

### 6.2 실시간 프로필 동기화 플로우

```
[Firebase Backend] Cloud Firestore
    ↓ 다른 기기/세션에서 프로필 업데이트
    ↓ users/{userId} 문서 변경
    ↓ snapshots() Stream emit

[Riverpod Stream] profileStreamProvider
    ↓ await for (doc in snapshots())
    ↓ yield UserProfile.fromFirestore(doc)

[UI Layer] 모든 ref.watch(profileStreamProvider) 위젯
    ↓ profileState.when() 자동 호출
    │
    ├─ loading: CircularProgressIndicator()
    ├─ error: ErrorWidget(e)
    └─ data: _buildContent(profile)
       → 최신 프로필 데이터로 UI 자동 업데이트
```

---

## 7. 5개 UI 화면 변경 가이드

### 7.1 화면 1: profile_edit_screen.dart

**변경 사항**:
- StatefulWidget → ConsumerStatefulWidget
- GetIt 제거, ref.watch 사용
- initState 제거
- profileState.when() 패턴 적용

<details>
<summary>전체 Before/After 코드</summary>

```dart
// Before
class ProfileEditScreen extends StatefulWidget {
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final ProfileProvider _profileProvider = GetIt.instance<ProfileProvider>();

  @override
  void initState() {
    super.initState();
    _profileProvider.loadProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _profileProvider.isLoading
          ? CircularProgressIndicator()
          : _buildEditForm(),
    );
  }

  Future<void> _handleSave() async {
    final success = await _profileProvider.updateProfile(...);
    if (success) {
      context.pop();
    } else {
      showError(_profileProvider.errorMessage);
    }
  }
}

// After
class ProfileEditScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStreamProvider(
      ProfileStreamParams(userId: widget.userId),
    ));
    final isLoading = ref.watch(profileLoadingProvider);

    return Scaffold(
      body: profileState.when(
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(e),
        data: (profile) => profile == null
            ? Text('프로필을 찾을 수 없습니다')
            : isLoading
                ? CircularProgressIndicator()
                : _buildEditForm(profile),
      ),
    );
  }

  Future<void> _handleSave() async {
    ref.read(profileLoadingProvider.notifier).state = true;

    final updateUseCase = ref.read(updateUserProfileUseCaseProvider);
    final result = await updateUseCase.execute(...);

    result.fold(
      (failure) {
        ref.read(profileErrorProvider.notifier).state = failure.message;
        ref.read(profileLoadingProvider.notifier).state = false;
        showError(failure.message);
      },
      (_) {
        ref.read(profileLoadingProvider.notifier).state = false;
        context.pop();
      },
    );
  }
}
```

</details>

### 7.2 화면 2-5: 동일한 패턴 적용

| 화면 | UseCase/Provider | 특이사항 |
|------|-----------------|----------|
| `settings_screen.dart` | settingsStreamProvider | Settings 관리 |
| `user_posts_list_widget.dart` | profileStreamProvider | 사용자 포스트 목록 |
| `select_your_interests_widget.dart` | interestsProvider | Interests 선택 |
| `user_info_display_screen.dart` | profileStreamProvider | 프로필 표시 |

---

## 8. 테스트 전략

### 8.1 Provider Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('profileStreamProvider', () {
    test('초기값으로 null emit', () async {
      final container = ProviderContainer();

      final provider = container.read(
        profileStreamProvider(const ProfileStreamParams(userId: 'test-uid')),
      );

      expect(
        provider,
        const AsyncValue<UserProfile?>.loading(),
      );
    });

    test('Firestore Stream 변경 시 자동 업데이트', () async {
      // Given
      final mockFirestore = MockFirebaseFirestore();
      final profileStream = Stream.value(MockDocumentSnapshot());

      when(() => mockFirestore.collection('users')
          .doc('test-uid')
          .snapshots()).thenAnswer((_) => profileStream);

      // When
      final container = ProviderContainer();
      final provider = container.read(
        profileStreamProvider(const ProfileStreamParams(userId: 'test-uid')),
      );

      // Then
      await expectLater(
        provider.stream,
        emitsInOrder([
          null,  // 초기값
          isA<UserProfile>(),  // Firestore Stream 값
        ]),
      );
    });
  });
}
```

### 8.2 Widget Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('프로필 편집 화면이 profileState에 따라 렌더링', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileStreamProvider.overrideWith(
            (ref, params) => Stream.value(mockProfile),
          ),
        ],
        child: MaterialApp(home: ProfileEditScreen(userId: 'test-uid')),
      ),
    );

    // 편집 폼이 표시되는지 확인
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('저장'), findsOneWidget);
  });

  testWidgets('로딩 중일 때 CircularProgressIndicator 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileLoadingProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(home: ProfileEditScreen(userId: 'test-uid')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## 9. 롤백 계획

### 9.1 Git 롤백

```bash
# 변경사항 확인
git status
git diff lib/features/profile/presentation/

# Presentation Layer 전체 롤백
git checkout HEAD -- lib/features/profile/presentation/

# 신규 파일 삭제
rm lib/features/profile/presentation/providers/profile_providers.dart
```

### 9.2 수동 롤백

```bash
# 백업 복원
cp -r lib/features/profile/presentation.backup lib/features/profile/presentation

# 신규 파일 삭제
rm lib/features/profile/presentation/providers/profile_providers.dart

# 컴파일 확인
flutter analyze
```

### 9.3 롤백 검증

```bash
# GetIt 패턴 확인
grep -r "GetIt.instance<ProfileProvider>" lib/features/profile/presentation/screens/
# → 5개 파일 발견되어야 함

# Riverpod 패턴 확인 (없어야 함)
grep -r "ConsumerStatefulWidget" lib/features/profile/presentation/screens/
# → 결과 없어야 함

# 앱 실행 확인
flutter run
```

---

## 📊 Phase 3 완료 체크리스트

### Provider Layer
- [ ] `profile_providers.dart` 신규 생성 (450줄)
- [ ] UseCase Provider 13개 생성
- [ ] profileStreamProvider 생성
- [ ] settingsStreamProvider 생성
- [ ] charactersProvider 생성
- [ ] interestsProvider 생성
- [ ] Loading/Error State Provider 4개 생성

### UI Layer (5개 화면)
- [ ] `profile_edit_screen.dart` Riverpod 적용
- [ ] `settings_screen.dart` Riverpod 적용
- [ ] `user_posts_list_widget.dart` Riverpod 적용
- [ ] `select_your_interests_widget.dart` Riverpod 적용
- [ ] `user_info_display_screen.dart` Riverpod 적용

### 공통
- [ ] `pubspec.yaml`에 flutter_riverpod 의존성 추가 (Auth Phase 3에서 이미 추가됨)
- [ ] `main.dart`에 ProviderScope 추가 (Auth Phase 3에서 이미 추가됨)
- [ ] Git 커밋 (롤백 포인트)
- [ ] `flutter analyze` 통과 확인
- [ ] Widget 테스트 5개 통과 확인
- [ ] 5개 화면 모두 정상 작동 확인

### Legacy 코드 유지 (하위 호환성)
- [ ] 4개 Provider @Deprecated 어노테이션 추가
- [ ] 주석으로 마이그레이션 완료 시 삭제 예정 명시

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | Widget 테스트 5개 이상 통과 |
| **GetIt 제거** | UI에서 `GetIt.instance<ProfileProvider>` 0개 |
| **Riverpod 적용** | 5개 화면 모두 ConsumerStatefulWidget |
| **UI 동작** | 프로필 편집/설정/관심사 정상 작동 |
| **실시간 동기화** | Firestore snapshots Stream 자동 감지 |

---

## 🎯 다음 단계

Phase 3 완료 후 **Phase 4: Firebase Optimization**으로 진행합니다.

- **대상**: DataSource 제거, Adapter/Mapper 제거, Extension 패턴 적용
- **작업**: Firebase SDK 직접 사용, DTO 제거
- **소요 시간**: 2일

문서: `PHASE_4_FIREBASE_OPTIMIZATION.md`
