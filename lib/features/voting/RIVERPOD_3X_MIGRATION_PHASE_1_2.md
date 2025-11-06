# Voting Feature - Riverpod 3.x Migration Guide (Phase 1-2)

> **마이그레이션 가이드**: Riverpod 2.x → 3.x
> **대상 Feature**: Voting Feature
> **참조 구현**: Creation Feature (완료됨, 2025-11-06)
> **작성일**: 2025-11-06
> **범위**: Phase 1 (Preparation) + Phase 2 (Provider Migration)

---

## 📋 목차

1. [개요](#개요)
2. [Phase 1: Preparation](#phase-1-preparation)
3. [Phase 2: Provider Migration](#phase-2-provider-migration)
4. [Appendix A: Provider 변환 매트릭스](#appendix-a-provider-변환-매트릭스)

---

## 개요

### 마이그레이션 목적

Voting Feature를 **Riverpod 2.x (Manual Providers)** 에서 **Riverpod 3.x (Code Generation)**으로 마이그레이션하여:

1. **타입 안정성 향상**: 컴파일 타임 에러 검출
2. **코드 감소**: 보일러플레이트 30-40% 감소
3. **유지보수성 향상**: 일관된 패턴, 자동 생성 코드
4. **DevTools 지원**: 향상된 Riverpod DevTools 기능
5. **일관성**: 전체 프로젝트의 통일된 Riverpod 3.x 패턴

### 문서 범위

이 문서는 **Phase 1-2**를 다룹니다:
- **Phase 1**: 준비 작업 (의존성, 파일 구조, 백업)
- **Phase 2**: Provider 마이그레이션 (StateProvider, Provider.family 등)

**Phase 3-7**는 별도 문서 참조:
→ `RIVERPOD_3X_MIGRATION_PHASE_3_7.md`

### 참조 구현: Creation Feature

Creation Feature는 2025-11-06에 Riverpod 3.x 마이그레이션을 완료했습니다.

**참조 파일**:
- `lib/features/creation/presentation/providers/create_post_notifier.dart` (807 lines)
  - `@riverpod` class Notifier 패턴
  - Timer 기반 debounce 로직
  - UUID 기반 idempotency
- `lib/features/creation/presentation/providers/usecase_providers.dart` (52 lines)
  - GetIt 통합 패턴
  - `@riverpod` getter function
- `lib/features/creation/README.md`
  - "상태 관리: Riverpod 3.x ✅ 완료 (2025-11-06)"
  - 5 Notifiers 마이그레이션 완료
  - 17 Widgets 검토 완료

**마이그레이션 결과** (Creation Feature):
- Before: Manual providers, ChangeNotifier 패턴
- After: @riverpod annotation, 코드 생성, Notifier 패턴
- 감소: ~30-40% 보일러플레이트 코드

---

## Phase 1: Preparation

### 1.1 의존성 확인

#### pubspec.yaml 검증

**필수 패키지** (현재 프로젝트에 이미 포함됨):

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
```

**확인 명령어**:
```bash
flutter pub get
```

**예상 출력**:
```
Running "flutter pub get" in versus-cursor...
Resolving dependencies...
Got dependencies!
```

#### 버전 호환성 확인

| 패키지 | 현재 버전 | 필요 버전 | 상태 |
|--------|----------|----------|------|
| flutter_riverpod | 2.6.1 | ≥2.0.0 | ✅ |
| riverpod_annotation | 2.6.1 | ≥2.0.0 | ✅ |
| build_runner | 2.4.13 | ≥2.0.0 | ✅ |
| riverpod_generator | 2.6.2 | ≥2.0.0 | ✅ |

**결론**: ✅ 모든 의존성이 Riverpod 3.x 마이그레이션을 지원합니다.

---

### 1.2 파일 구조 설계

#### 현재 구조 (Riverpod 2.x)

```
lib/features/voting/presentation/providers/
├── vote_providers.dart           # 133 lines, 2 controllers + 4 providers
└── vote_state_providers.dart     # (존재 여부 확인 필요)
```

**vote_providers.dart** 구성 (133 lines):
- **Line 1-46**: VoteSubmissionState 클래스 (45 lines)
- **Line 47-123**: VoteSubmissionController 클래스 (77 lines)
- **Line 125-132**: Provider 정의 (8 lines)
  - `voteSubmissionStateProvider` (StateProvider)
  - `voteSubmissionControllerProvider` (Provider)
- **Line 134-218**: VoteUIState + VoteUIStateController (85 lines)
  - `voteUIStateProvider` (StateProvider.family)
  - `voteUIStateControllerProvider` (Provider.family)

#### 목표 구조 (Riverpod 3.x)

```
lib/features/voting/presentation/providers/
├── vote_providers.dart              # Riverpod 3.x providers
├── vote_providers.g.dart            # 🆕 Generated file
├── states/
│   ├── vote_submission_state.dart   # 🆕 Freezed state (optional)
│   ├── vote_submission_state.freezed.dart
│   ├── vote_submission_state.g.dart
│   ├── vote_ui_state.dart           # 🆕 Freezed state (optional)
│   ├── vote_ui_state.freezed.dart
│   └── vote_ui_state.g.dart
└── usecase_providers.dart           # 🆕 GetIt wrapper providers
    └── usecase_providers.g.dart
```

**파일 설명**:

1. **vote_providers.dart** (Riverpod 3.x)
   - `@riverpod` annotations
   - Part directive: `part 'vote_providers.g.dart';`
   - Notifier 클래스 정의

2. **vote_providers.g.dart** (자동 생성)
   - build_runner로 생성
   - Provider 코드 자동 생성
   - 수정하지 말 것!

3. **states/** (Optional, 권장)
   - Freezed로 불변 상태 클래스 생성
   - copyWith(), ==, hashCode 자동 생성
   - JSON 직렬화 지원

4. **usecase_providers.dart**
   - GetIt UseCases를 Riverpod Provider로 노출
   - Creation Feature 참조: `creation/presentation/providers/usecase_providers.dart`

#### 파일 분리 전략

**Option 1: 점진적 마이그레이션** (추천)
- 기존 `vote_providers.dart` 백업
- 동일 파일에서 Riverpod 3.x로 변환
- 테스트 후 백업 파일 삭제

**Option 2: 새 파일 생성**
- `vote_providers_v3.dart` 생성
- 마이그레이션 완료 후 원본 파일 교체
- 더 안전하지만 import 경로 수정 필요

**선택**: Option 1 (점진적 마이그레이션) - 동일 파일명 유지

---

### 1.3 백업 전략

#### Git Branch 생성

```bash
# 현재 branch 확인
git branch

# 새 branch 생성 (마이그레이션 전용)
git checkout -b feature/voting-riverpod-3x-migration

# 현재 상태 커밋
git add .
git commit -m "chore(voting): Backup before Riverpod 3.x migration"
```

#### 파일 백업 (Optional)

**수동 백업**:
```bash
# voting/presentation/providers/ 전체 백업
cp -r lib/features/voting/presentation/providers \
      lib/features/voting/presentation/providers.backup

# 백업 확인
ls -la lib/features/voting/presentation/providers.backup/
```

**백업 파일**:
- `providers.backup/vote_providers.dart` (원본)
- `providers.backup/vote_state_providers.dart` (원본, 존재 시)

#### 롤백 전략

**Git 롤백**:
```bash
# 마이그레이션 중 문제 발생 시
git checkout lib/features/voting/presentation/providers/

# 또는 branch 전체 롤백
git reset --hard HEAD
```

**수동 롤백**:
```bash
# 백업 파일 복원
cp -r lib/features/voting/presentation/providers.backup/* \
      lib/features/voting/presentation/providers/
```

---

### 1.4 사전 확인 체크리스트

마이그레이션 시작 전에 다음을 확인하세요:

- [ ] **pubspec.yaml 최신화 완료**
  - `flutter pub get` 실행 완료
  - 모든 패키지 버전 호환성 확인

- [ ] **기존 코드 컴파일 확인**
  ```bash
  flutter analyze lib/features/voting/
  # 예상: "No issues found!"
  ```

- [ ] **Git branch 생성 완료**
  ```bash
  git branch
  # 예상: * feature/voting-riverpod-3x-migration
  ```

- [ ] **백업 완료**
  - Git commit 완료
  - (Optional) 수동 백업 폴더 생성

- [ ] **Creation Feature 참조 파일 확인**
  - `lib/features/creation/presentation/providers/create_post_notifier.dart` 존재 확인
  - `lib/features/creation/presentation/providers/usecase_providers.dart` 존재 확인

**확인 완료 후 Phase 2로 진행하세요!**

---

## Phase 2: Provider Migration

### 2.1 StateProvider → @riverpod class Notifier

#### 개념 설명

**Riverpod 2.x (Manual)**:
```dart
// StateProvider: 단순 상태 저장
final myStateProvider = StateProvider<MyState>((ref) {
  return MyState.initial();
});

// 사용
ref.read(myStateProvider.notifier).state = newState;
```

**Riverpod 3.x (Code Generation)**:
```dart
@riverpod
class MyState extends _$MyState {
  @override
  MyState build() => MyState.initial();

  // 메서드로 상태 변경
  void updateState(MyState newState) {
    state = newState;
  }
}

// 사용
ref.read(myStateProvider.notifier).updateState(newState);
```

**장점**:
- 타입 안정성: `state` 타입 자동 추론
- 메서드 캡슐화: 상태 변경 로직을 메서드로 추상화
- 코드 생성: `.g.dart` 파일 자동 생성

---

#### 예제 1: VoteSubmissionState 변환

**Before (Riverpod 2.x)** - `vote_providers.dart:125-127`
```dart
/// 투표 제출 상태 Provider
final voteSubmissionStateProvider =
    StateProvider<VoteSubmissionState>((ref) => const VoteSubmissionState());
```

**After (Riverpod 3.x)**
```dart
// ===== vote_providers.dart =====
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Remove: import 'package:flutter_riverpod/legacy.dart'; ❌

part 'vote_providers.g.dart'; // ✅ Part directive 추가

/// 투표 제출 상태 Notifier (Riverpod 3.x)
///
/// **마이그레이션**: voteSubmissionStateProvider (StateProvider) → VoteSubmissionNotifier
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() {
    return const VoteSubmissionState();
  }

  /// 로딩 시작
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 에러 설정
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// 성공 처리
  void setSuccess() {
    state = state.copyWith(isSuccess: true, isLoading: false);
  }

  /// 상태 초기화
  void reset() {
    state = const VoteSubmissionState();
  }
}
```

**변경 사항**:
1. `StateProvider<VoteSubmissionState>` → `@riverpod class VoteSubmission`
2. Provider 이름: `voteSubmissionStateProvider` → `voteSubmissionProvider` (자동 생성)
3. 메서드 추가: `setLoading()`, `setError()`, `setSuccess()`, `reset()`
4. 사용법 변경:
   ```dart
   // Before
   ref.read(voteSubmissionStateProvider.notifier).state =
       VoteSubmissionState(isLoading: true);

   // After
   ref.read(voteSubmissionProvider.notifier).setLoading(true);
   ```

---

#### 예제 2: VoteUIState 변환

**Before (Riverpod 2.x)** - `vote_providers.dart:209-212`
```dart
/// 투표 UI 상태 Provider (postId별 독립 관리)
final voteUIStateProvider =
    StateProvider.family<VoteUIState, String>((ref, postId) {
  return const VoteUIState();
});
```

**After (Riverpod 3.x)**
```dart
/// 투표 UI 상태 Notifier (postId별 독립 관리)
///
/// **마이그레이션**: voteUIStateProvider (StateProvider.family) → VoteUINotifier
@riverpod
class VoteUI extends _$VoteUI {
  @override
  VoteUIState build(String postId) {
    // postId 파라미터를 받아서 초기 상태 반환
    return const VoteUIState();
  }

  /// 투표 완료 처리
  void markAsVoted(String option) {
    state = state.copyWith(
      hasVoted: true,
      selectedOption: option,
      voteTimestamp: DateTime.now(),
    );
  }

  /// 애니메이션 시작
  void startAnimation() {
    state = state.copyWith(isAnimating: true);
  }

  /// 애니메이션 종료
  void stopAnimation() {
    state = state.copyWith(isAnimating: false);
  }

  /// 상태 초기화
  void reset() {
    state = const VoteUIState();
  }
}
```

**변경 사항**:
1. `StateProvider.family<VoteUIState, String>` → `@riverpod class VoteUI`
2. Family parameter: `(ref, postId)` → `build(String postId)`
3. Provider 이름: `voteUIStateProvider(postId)` → `voteUIProvider(postId)` (자동 생성)
4. 사용법 변경:
   ```dart
   // Before
   ref.read(voteUIStateProvider('post123').notifier).state =
       VoteUIState(hasVoted: true, selectedOption: 'A');

   // After
   ref.read(voteUIProvider('post123').notifier).markAsVoted('A');
   ```

---

#### Creation Feature 참조

**파일**: `lib/features/creation/presentation/providers/create_post_notifier.dart`

**Line 34-52**: `@riverpod class CreatePost` 기본 구조
```dart
@riverpod
class CreatePost extends _$CreatePost {
  Timer? _debounceTimer; // 비동기 작업용 필드
  final Uuid _uuid = const Uuid(); // 상수 필드

  @override
  CreatePostState build() {
    // Setup cleanup on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Load draft asynchronously
    _loadDraftAsync();

    // Return initial state immediately
    return const CreatePostState();
  }

  // ... 메서드들
}
```

**핵심 패턴**:
- `extends _$CreatePost`: 자동 생성된 base class
- `build()`: 초기 상태 반환
- `ref.onDispose()`: 리소스 정리
- 비동기 작업: `_loadDraftAsync()` 백그라운드 실행

---

#### 변환 단계 (Step-by-Step)

**Step 1: Import 문 수정**

```dart
// Before
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // ❌ 제거

// After
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'vote_providers.g.dart'; // ✅ 추가
```

**Step 2: StateProvider → @riverpod class**

```dart
// Before (vote_providers.dart:125-127)
final voteSubmissionStateProvider =
    StateProvider<VoteSubmissionState>((ref) => const VoteSubmissionState());

// After
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();

  // 메서드 추가...
}
```

**Step 3: 메서드 추가 (Controller 로직 이동)**

VoteSubmissionController의 로직을 Notifier 메서드로 이동:

```dart
// Before (Controller 메서드)
class VoteSubmissionController {
  void reset() {
    ref.read(voteSubmissionStateProvider.notifier).state =
        const VoteSubmissionState();
  }
}

// After (Notifier 메서드)
@riverpod
class VoteSubmission extends _$VoteSubmission {
  // ... build() ...

  void reset() {
    state = const VoteSubmissionState();
  }
}
```

**Step 4: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**예상 출력**:
```
[INFO] Generating build script...
[INFO] Generating build script completed, took 285ms

[INFO] Creating build script snapshot......
[INFO] Creating build script snapshot... completed, took 8.7s

[INFO] Building new asset graph...
[INFO] Building new asset graph completed, took 645ms

[INFO] Checking for unexpected pre-existing outputs....
[INFO] Checking for unexpected pre-existing outputs. completed, took 1ms

[INFO] Running build...
[INFO] 1.2s elapsed, 0/3 actions completed.
[INFO] 2.5s elapsed, 1/3 actions completed.
[INFO] Running build completed, took 2.6s

[INFO] Caching finalized dependency graph...
[INFO] Caching finalized dependency graph completed, took 38ms

[INFO] Succeeded after 2.6s with 1 outputs (3 actions)
```

**생성 파일**: `lib/features/voting/presentation/providers/vote_providers.g.dart`

---

#### 주의사항 및 Best Practices

**1. Provider 이름 규칙**

```dart
// Notifier 클래스명: VoteSubmission
@riverpod
class VoteSubmission extends _$VoteSubmission { ... }

// 자동 생성된 Provider 이름: voteSubmissionProvider
// 규칙: 클래스명의 camelCase + "Provider"
ref.read(voteSubmissionProvider);
```

**2. Family Provider 파라미터 타입**

```dart
// 단일 파라미터
@riverpod
class VoteUI extends _$VoteUI {
  @override
  VoteUIState build(String postId) { ... }
}

// 사용: voteUIProvider(postId)
ref.watch(voteUIProvider('post123'));

// 복잡한 파라미터는 Freezed 클래스 사용 권장
class VoteParams {
  final String postId;
  final String userId;

  const VoteParams({required this.postId, required this.userId});
}

@riverpod
class VoteComplex extends _$VoteComplex {
  @override
  VoteState build(VoteParams params) { ... }
}
```

**3. AutoDispose 기본 동작**

Riverpod 3.x의 `@riverpod`는 기본적으로 **autoDispose**입니다:

```dart
// Before (2.x)
final myProvider = StateProvider.autoDispose<MyState>((ref) { ... });

// After (3.x) - autoDispose는 기본값
@riverpod
class MyState extends _$MyState { ... }

// Keep alive가 필요한 경우
@Riverpod(keepAlive: true)
class MyPersistentState extends _$MyPersistentState { ... }
```

**4. State 불변성 유지**

```dart
// ❌ BAD: 직접 수정
void updateState() {
  state.isLoading = true; // Error: Cannot modify final field
}

// ✅ GOOD: copyWith() 사용
void updateState() {
  state = state.copyWith(isLoading: true);
}
```

**5. 복잡한 State는 Freezed 사용**

```dart
// vote_providers.dart에 있는 VoteSubmissionState를
// states/vote_submission_state.dart로 분리하고 Freezed 적용

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_submission_state.freezed.dart';
part 'vote_submission_state.g.dart';

@freezed
class VoteSubmissionState with _$VoteSubmissionState {
  const factory VoteSubmissionState({
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isSuccess,
  }) = _VoteSubmissionState;

  factory VoteSubmissionState.fromJson(Map<String, dynamic> json) =>
      _$VoteSubmissionStateFromJson(json);
}
```

**Freezed 사용 시 장점**:
- `copyWith()` 자동 생성
- `==` / `hashCode` 자동 생성
- JSON 직렬화 지원
- 불변성 강제

---

### 2.2 Provider (UseCase wrapping) → @riverpod getter

#### 개념 설명

**Riverpod 2.x (Manual)**:
```dart
// GetIt UseCase를 Provider로 래핑
final myUseCaseProvider = Provider<MyUseCase>((ref) {
  return GetIt.instance<MyUseCase>();
});
```

**Riverpod 3.x (Code Generation)**:
```dart
@riverpod
MyUseCase myUseCase(Ref ref) {
  return GetIt.instance<MyUseCase>();
}
```

**차이점**:
- 2.x: `Provider<T>` 타입 명시 필요
- 3.x: 반환 타입에서 자동 추론
- 3.x: 더 간결한 문법

---

#### 예제 1: SubmitVoteUseCase Provider

**Before (Riverpod 2.x)** - 현재 코드에는 없음, 추가 필요
```dart
// vote_providers.dart에 추가되어야 할 Provider
final submitVoteUseCaseProvider = Provider<SubmitVoteUseCase>((ref) {
  return getIt<SubmitVoteUseCase>();
});
```

**After (Riverpod 3.x)** - 새 파일: `usecase_providers.dart`
```dart
// lib/features/voting/presentation/providers/usecase_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/chat/submit_vote_use_case.dart';

part 'usecase_providers.g.dart';

/// Submit Vote UseCase Provider
///
/// **역할**: 투표 제출 비즈니스 로직
/// **의존성**: IVoteRepository (GetIt에 등록됨)
///
/// **사용처**: VoteSubmissionNotifier.submitVote()
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}
```

**변경 사항**:
1. Provider 타입 명시 제거: `Provider<SubmitVoteUseCase>` → 반환 타입 자동 추론
2. 파라미터: `(ref)` → `(Ref ref)` (타입 명시, Riverpod 3.x 규칙)
3. 파일 분리: `vote_providers.dart` → `usecase_providers.dart` (권장)

**사용법**:
```dart
// Before
final useCase = ref.read(submitVoteUseCaseProvider);

// After (동일)
final useCase = ref.read(submitVoteUseCaseProvider);
```

---

#### Creation Feature 참조

**파일**: `lib/features/creation/presentation/providers/usecase_providers.dart`

**Line 15-26**: CreatePostUseCase Provider
```dart
/// Create Post UseCase Provider
///
/// **역할**: 포스트 생성 비즈니스 로직
/// **의존성**:
/// - IPostCreationRepositoryV2
/// - IMediaRepository
///
/// **사용처**: CreatePostNotifier.createPost()
@riverpod
CreatePostUseCase createPostUseCase(Ref ref) {
  return getIt<CreatePostUseCase>();
}
```

**Line 28-37**: ModerateContentUseCase Provider
```dart
/// Moderate Content UseCase Provider
///
/// **역할**: AI 기반 콘텐츠 검열 (Perspective API + Gemini AI)
/// **의존성**: 없음 (직접 API 호출)
///
/// **사용처**: CreatePostNotifier.validateAndModerate()
@riverpod
ModerateContentUseCase moderateContentUseCase(Ref ref) {
  return getIt<ModerateContentUseCase>();
}
```

**Line 39-51**: ValidatePostUseCase Provider
```dart
/// Validate Post UseCase Provider
///
/// **역할**: 폼 필드 검증 (제목, 설명, 텍스트 등)
/// **의존성**: 없음 (로컬 검증 로직)
///
/// **사용처**:
/// - CreatePostNotifier.validateFormFields()
/// - CreatePostNotifier.validateTitle()
/// - CreatePostNotifier.validateDescription()
@riverpod
ValidatePostUseCase validatePostUseCase(Ref ref) {
  return getIt<ValidatePostUseCase>();
}
```

**핵심 패턴**:
- 파일 분리: `usecase_providers.dart` (UseCases만 모음)
- GetIt 통합: `getIt<T>()` 호출
- 문서화: 역할, 의존성, 사용처 명시

---

#### 변환 단계 (Step-by-Step)

**Step 1: usecase_providers.dart 파일 생성**

```dart
// lib/features/voting/presentation/providers/usecase_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/chat/submit_vote_use_case.dart';

part 'usecase_providers.g.dart';
```

**Step 2: GetIt UseCase Provider 추가**

```dart
/// Submit Vote UseCase Provider
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}
```

**Step 3: 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**생성 파일**: `lib/features/voting/presentation/providers/usecase_providers.g.dart`

**Step 4: vote_providers.dart에서 사용**

```dart
// vote_providers.dart
import 'usecase_providers.dart'; // ✅ 추가

@riverpod
class VoteSubmission extends _$VoteSubmission {
  // ...

  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
  }) async {
    // ✅ UseCase Provider 사용
    final useCase = ref.read(submitVoteUseCaseProvider);

    final result = await useCase(
      postId: postId,
      userId: userId,
      voteOption: choice,
    );

    // ... 결과 처리
  }
}
```

---

#### 주의사항 및 Best Practices

**1. 파일 분리 권장**

```dart
// ✅ GOOD: usecase_providers.dart 파일 분리
// lib/features/voting/presentation/providers/usecase_providers.dart
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) { ... }

@riverpod
GetVoteResultsUseCase getVoteResultsUseCase(Ref ref) { ... }

// ❌ BAD: vote_providers.dart에 모든 Provider 혼재
// 유지보수성 저하
```

**2. GetIt 통합 패턴**

```dart
// ✅ GOOD: GetIt 직접 사용
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}

// ❌ BAD: ref.read()로 다른 Provider 체이닝 (불필요한 복잡도)
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  final repository = ref.read(voteRepositoryProvider);
  return SubmitVoteUseCase(repository); // ❌ GetIt 우회
}
```

**3. 타입 명시 규칙**

```dart
// ✅ GOOD: 반환 타입 명시, Ref 타입 명시
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}

// ❌ BAD: 타입 생략 (컴파일러 추론 의존)
@riverpod
submitVoteUseCase(ref) { // ❌ 타입 생략
  return getIt();
}
```

**4. Provider 이름 규칙**

```dart
// UseCase 이름: SubmitVoteUseCase
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) { ... }

// 자동 생성된 Provider 이름: submitVoteUseCaseProvider
// 규칙: 함수명 + "Provider"
ref.read(submitVoteUseCaseProvider);
```

---

### 2.3 Provider.family (Controller) → @riverpod function with parameter

#### 개념 설명

**Riverpod 2.x (Manual)**:
```dart
// Controller를 Provider.family로 래핑
final myControllerProvider = Provider.family<MyController, String>((ref, id) {
  return MyController(ref, id);
});
```

**Riverpod 3.x (Code Generation)**:
```dart
// Controller 클래스를 직접 Provider로 변환
@riverpod
MyController myController(Ref ref, String id) {
  return MyController(ref, id);
}

// 또는 Notifier 패턴으로 변환 (권장)
@riverpod
class MyController extends _$MyController {
  @override
  MyState build(String id) { ... }

  void doSomething() { ... }
}
```

---

#### 예제 1: VoteUIStateController 변환

**Before (Riverpod 2.x)** - `vote_providers.dart:214-218`
```dart
/// 투표 UI 상태 Controller Provider
final voteUIStateControllerProvider =
    Provider.family<VoteUIStateController, String>((ref, postId) {
  return VoteUIStateController(ref, postId);
});
```

**Controller 클래스** - `vote_providers.dart:167-204`
```dart
/// 투표 UI 상태 Controller
class VoteUIStateController {
  final Ref ref;
  final String postId;

  VoteUIStateController(this.ref, this.postId);

  StateProvider<VoteUIState> get _provider => voteUIStateProvider(postId);

  /// 투표 완료 처리
  void markAsVoted(String option) {
    final currentState = ref.read(_provider);
    ref.read(_provider.notifier).state = currentState.copyWith(
      hasVoted: true,
      selectedOption: option,
      voteTimestamp: DateTime.now(),
    );
  }

  /// 애니메이션 시작
  void startAnimation() {
    final currentState = ref.read(_provider);
    ref.read(_provider.notifier).state =
        currentState.copyWith(isAnimating: true);
  }

  /// 애니메이션 종료
  void stopAnimation() {
    final currentState = ref.read(_provider);
    ref.read(_provider.notifier).state =
        currentState.copyWith(isAnimating: false);
  }

  /// 상태 초기화
  void reset() {
    ref.read(_provider.notifier).state = const VoteUIState();
  }
}
```

**After (Riverpod 3.x)** - Notifier 패턴으로 통합

```dart
/// 투표 UI 상태 Notifier (postId별 독립 관리)
///
/// **마이그레이션**:
/// - voteUIStateProvider (StateProvider.family) → VoteUINotifier
/// - voteUIStateControllerProvider (Provider.family) → 제거 (Notifier에 통합)
@riverpod
class VoteUI extends _$VoteUI {
  @override
  VoteUIState build(String postId) {
    // postId 파라미터를 받아서 초기 상태 반환
    return const VoteUIState();
  }

  /// 투표 완료 처리
  void markAsVoted(String option) {
    state = state.copyWith(
      hasVoted: true,
      selectedOption: option,
      voteTimestamp: DateTime.now(),
    );
  }

  /// 애니메이션 시작
  void startAnimation() {
    state = state.copyWith(isAnimating: true);
  }

  /// 애니메이션 종료
  void stopAnimation() {
    state = state.copyWith(isAnimating: false);
  }

  /// 상태 초기화
  void reset() {
    state = const VoteUIState();
  }
}
```

**변경 사항**:
1. Controller 클래스 제거: `VoteUIStateController` → Notifier 메서드로 통합
2. Provider 제거: `voteUIStateControllerProvider` → 불필요 (Notifier가 상태 + 로직 모두 관리)
3. 사용법 변경:
   ```dart
   // Before
   final controller = ref.read(voteUIStateControllerProvider('post123'));
   controller.markAsVoted('A');

   // After
   ref.read(voteUIProvider('post123').notifier).markAsVoted('A');
   ```

**결과**:
- 코드 감소: 38 lines (Controller 클래스) + 5 lines (Provider) = 43 lines 제거
- Notifier 패턴: 상태와 로직이 하나의 클래스에 통합

---

#### 예제 2: VoteSubmissionController 변환

**Before (Riverpod 2.x)** - `vote_providers.dart:129-132`
```dart
/// 투표 제출 Controller Provider
final voteSubmissionControllerProvider = Provider<VoteSubmissionController>(
  (ref) => VoteSubmissionController(ref),
);
```

**Controller 클래스** - `vote_providers.dart:47-123`
```dart
/// 투표 제출 Controller
class VoteSubmissionController {
  final Ref ref;

  VoteSubmissionController(this.ref);

  /// 투표 제출
  Future<VoteSubmissionState> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
  }) async {
    // 로딩 시작
    ref.read(voteSubmissionStateProvider.notifier).state =
        const VoteSubmissionState(isLoading: true);

    // SubmitVoteUseCase를 통한 투표 제출
    final useCase = getIt<SubmitVoteUseCase>();
    final result = await useCase(
      postId: postId,
      userId: userId,
      voteOption: choice,
    );

    // Either<Failure, T> 패턴으로 결과 처리
    return result.fold(
      // 실패 시
      (failure) {
        final errorState = VoteSubmissionState(
          error: _mapFailureToMessage(failure),
        );
        ref.read(voteSubmissionStateProvider.notifier).state = errorState;
        return errorState;
      },
      // 성공 시
      (postVoting) {
        final successState = const VoteSubmissionState(isSuccess: true);
        ref.read(voteSubmissionStateProvider.notifier).state = successState;
        return successState;
      },
    );
  }

  /// VotingFailure → 사용자 메시지 변환
  String _mapFailureToMessage(VotingFailure failure) {
    return failure.when(
      networkError: (_) => '네트워크 연결을 확인해주세요',
      timeout: (_) => '요청 시간이 초과되었습니다',
      // ... 15개 case
    );
  }

  /// 상태 초기화
  void reset() {
    ref.read(voteSubmissionStateProvider.notifier).state =
        const VoteSubmissionState();
  }
}
```

**After (Riverpod 3.x)** - Notifier 패턴으로 통합

```dart
/// 투표 제출 Notifier (Riverpod 3.x)
///
/// **마이그레이션**:
/// - voteSubmissionStateProvider (StateProvider) → VoteSubmissionNotifier
/// - voteSubmissionControllerProvider (Provider) → 제거 (Notifier에 통합)
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() {
    return const VoteSubmissionState();
  }

  /// 투표 제출
  Future<VoteSubmissionState> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
  }) async {
    // 로딩 시작
    state = const VoteSubmissionState(isLoading: true);

    // SubmitVoteUseCase를 통한 투표 제출
    final useCase = ref.read(submitVoteUseCaseProvider);
    final result = await useCase(
      postId: postId,
      userId: userId,
      voteOption: choice,
    );

    // Either<Failure, T> 패턴으로 결과 처리
    return result.fold(
      // 실패 시
      (failure) {
        final errorState = VoteSubmissionState(
          error: _mapFailureToMessage(failure),
        );
        state = errorState;
        return errorState;
      },
      // 성공 시
      (postVoting) {
        final successState = const VoteSubmissionState(isSuccess: true);
        state = successState;
        return successState;
      },
    );
  }

  /// VotingFailure → 사용자 메시지 변환
  String _mapFailureToMessage(VotingFailure failure) {
    return failure.when(
      networkError: (_) => '네트워크 연결을 확인해주세요',
      timeout: (_) => '요청 시간이 초과되었습니다',
      // ... 15개 case (동일)
    );
  }

  /// 상태 초기화
  void reset() {
    state = const VoteSubmissionState();
  }
}
```

**변경 사항**:
1. Controller 클래스 제거: `VoteSubmissionController` → Notifier 메서드로 통합
2. Provider 제거: `voteSubmissionControllerProvider` → 불필요
3. `ref` 사용:
   ```dart
   // Before
   getIt<SubmitVoteUseCase>(); // GetIt 직접 호출

   // After
   ref.read(submitVoteUseCaseProvider); // Riverpod Provider 사용
   ```
4. 상태 변경:
   ```dart
   // Before
   ref.read(voteSubmissionStateProvider.notifier).state = newState;

   // After
   state = newState; // Notifier 내부에서 직접 변경
   ```

**결과**:
- 코드 감소: 77 lines (Controller 클래스) + 4 lines (Provider) = 81 lines 제거
- 패턴 통일: 모든 투표 로직이 Notifier 패턴으로 일관성 확보

---

#### Creation Feature 참조

**파일**: `lib/features/creation/presentation/providers/create_post_notifier.dart`

**Line 34-52**: CreatePost Notifier 구조
```dart
@riverpod
class CreatePost extends _$CreatePost {
  Timer? _debounceTimer; // 인스턴스 필드 사용 가능
  final Uuid _uuid = const Uuid();

  @override
  CreatePostState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel(); // 리소스 정리
    });

    _loadDraftAsync(); // 비동기 초기화

    return const CreatePostState(); // 초기 상태 반환
  }

  // ... 메서드들 (20개 이상)
}
```

**Line 556-629**: createPost() 메서드
```dart
/// Create post with validation and moderation
Future<void> createPost(
  String userId, {
  Map<String, dynamic>? targetAudience,
}) async {
  if (!state.canSubmit) {
    _setError('양식을 올바르게 작성해주세요.');
    return;
  }

  // ... 복잡한 비즈니스 로직 (70 lines)

  final createUseCase = ref.read(createPostUseCaseProvider); // UseCase 사용
  final result = await createUseCase.execute(...);

  result.fold(
    (failure) {
      _setError(_getFailureMessage(failure));
    },
    (post) {
      state = state.copyWith(
        createdPost: post,
        loadingState: LoadingState.success,
      );
      _resetForm();
    },
  );
}
```

**핵심 패턴**:
- Controller 클래스 → Notifier 클래스로 완전 통합
- `ref.read()` 사용: UseCase Provider 접근
- Private 헬퍼 메서드: `_setError()`, `_resetForm()`, `_getFailureMessage()` 등
- Either 패턴: `result.fold()` 사용

---

#### 변환 단계 (Step-by-Step)

**Step 1: Controller 클래스 분석**

```dart
// Before - VoteSubmissionController 분석
class VoteSubmissionController {
  final Ref ref; // ✅ Notifier는 ref를 자동으로 가짐

  VoteSubmissionController(this.ref); // ❌ 생성자 불필요 (Notifier가 자동 관리)

  Future<VoteSubmissionState> submitVote(...) { // ✅ Notifier 메서드로 이동
    ref.read(voteSubmissionStateProvider.notifier).state = newState; // ❌ state = newState로 변경
  }

  String _mapFailureToMessage(...) { // ✅ Private 헬퍼 메서드 유지
  }

  void reset() { // ✅ Notifier 메서드로 이동
  }
}
```

**Step 2: Notifier 클래스로 변환**

```dart
// After - VoteSubmission Notifier
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() {
    return const VoteSubmissionState();
  }

  // submitVote() 메서드 복사 + 수정
  Future<VoteSubmissionState> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
  }) async {
    // ref.read(voteSubmissionStateProvider.notifier).state = ...
    // → state = ... 로 변경
    state = const VoteSubmissionState(isLoading: true);

    // getIt<SubmitVoteUseCase>()
    // → ref.read(submitVoteUseCaseProvider) 로 변경
    final useCase = ref.read(submitVoteUseCaseProvider);

    // ... 나머지 로직 동일
  }

  // _mapFailureToMessage() 복사 (동일)
  String _mapFailureToMessage(VotingFailure failure) {
    // ... 동일
  }

  // reset() 메서드 복사 + 수정
  void reset() {
    state = const VoteSubmissionState();
  }
}
```

**Step 3: Controller Provider 제거**

```dart
// Before (삭제 대상)
final voteSubmissionControllerProvider = Provider<VoteSubmissionController>(
  (ref) => VoteSubmissionController(ref),
);

// After (자동 생성됨, 명시 불필요)
// voteSubmissionProvider.notifier 사용
```

**Step 4: 사용처 업데이트 (Widget 코드)**

```dart
// Before (Widget에서 사용)
final controller = ref.read(voteSubmissionControllerProvider);
final state = await controller.submitVote(
  postId: postId,
  userId: userId,
  choice: 'A',
);

// After
final notifier = ref.read(voteSubmissionProvider.notifier);
final state = await notifier.submitVote(
  postId: postId,
  userId: userId,
  choice: 'A',
);

// 또는 더 간결하게
final state = await ref.read(voteSubmissionProvider.notifier).submitVote(
  postId: postId,
  userId: userId,
  choice: 'A',
);
```

---

#### 주의사항 및 Best Practices

**1. Controller → Notifier 통합의 장점**

```dart
// ✅ GOOD: 상태 + 로직 통합
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();

  void setLoading(bool isLoading) { state = state.copyWith(isLoading: isLoading); }
  void setError(String error) { state = state.copyWith(error: error); }
  Future<void> submitVote(...) { /* 비즈니스 로직 */ }
}

// ❌ BAD: 상태와 로직 분리 (Riverpod 2.x 패턴)
final voteStateProvider = StateProvider<VoteState>(...);
final voteControllerProvider = Provider<VoteController>(...);
// 2개의 Provider 관리 필요, 복잡도 증가
```

**2. ref 사용 패턴**

```dart
@riverpod
class VoteSubmission extends _$VoteSubmission {
  // ... build() ...

  Future<void> submitVote(...) async {
    // ✅ GOOD: ref.read() 사용 (다른 Provider 접근)
    final useCase = ref.read(submitVoteUseCaseProvider);

    // ✅ GOOD: ref.watch() 사용 (실시간 의존성)
    final currentUser = ref.watch(currentUserProvider);

    // ❌ BAD: getIt 직접 호출 (Riverpod 우회)
    final useCase = getIt<SubmitVoteUseCase>();
  }
}
```

**3. Private 메서드 활용**

```dart
@riverpod
class VoteSubmission extends _$VoteSubmission {
  // Public 메서드 (Widget에서 호출)
  Future<void> submitVote(...) async {
    _setLoading(true);

    final result = await _executeSubmit(...);

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (success) => _setSuccess(),
    );
  }

  // Private 헬퍼 메서드 (내부에서만 사용)
  void _setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void _setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void _setSuccess() {
    state = state.copyWith(isSuccess: true, isLoading: false);
  }

  String _mapFailureToMessage(VotingFailure failure) {
    // ... 에러 메시지 매핑
  }
}
```

**4. 비동기 작업 패턴**

```dart
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() {
    // ✅ GOOD: 초기화 시 비동기 작업
    _initializeAsync(); // 백그라운드 실행
    return const VoteSubmissionState(); // 즉시 반환
  }

  Future<void> _initializeAsync() async {
    // 비동기 초기화 로직
    final cachedData = await _loadFromCache();
    if (cachedData != null) {
      state = state.copyWith(cachedData: cachedData);
    }
  }

  Future<void> submitVote(...) async {
    // ✅ GOOD: 로딩 상태 즉시 설정
    state = const VoteSubmissionState(isLoading: true);

    try {
      final result = await _performAsyncOperation();
      state = state.copyWith(result: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

---

### 2.4 코드 생성 및 검증

#### build_runner 실행

**명령어**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**옵션 설명**:
- `build`: 코드 생성 실행
- `--delete-conflicting-outputs`: 기존 생성 파일 충돌 시 삭제 후 재생성

**watch 모드** (개발 중 자동 생성):
```bash
dart run build_runner watch --delete-conflicting-outputs
```

#### 예상 출력

**성공 케이스**:
```
[INFO] Generating build script...
[INFO] Generating build script completed, took 285ms

[INFO] Creating build script snapshot......
[INFO] Creating build script snapshot... completed, took 8.7s

[INFO] Building new asset graph...
[INFO] Building new asset graph completed, took 645ms

[INFO] Checking for unexpected pre-existing outputs....
[INFO] Checking for unexpected pre-existing outputs. completed, took 1ms

[INFO] Running build...
[INFO] 1.2s elapsed, 0/3 actions completed.
[INFO] 2.5s elapsed, 1/3 actions completed.
[INFO] Running build completed, took 2.6s

[INFO] Caching finalized dependency graph...
[INFO] Caching finalized dependency graph completed, took 38ms

[INFO] Succeeded after 2.6s with 2 outputs (6 actions)
```

**생성된 파일**:
1. `lib/features/voting/presentation/providers/vote_providers.g.dart`
2. `lib/features/voting/presentation/providers/usecase_providers.g.dart`

---

#### .g.dart 파일 검증

**vote_providers.g.dart** 예상 내용:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voteSubmissionHash() => r'...'; // 해시값

/// See also [VoteSubmission].
@ProviderFor(VoteSubmission)
final voteSubmissionProvider =
    AutoDisposeNotifierProvider<VoteSubmission, VoteSubmissionState>.internal(
  VoteSubmission.new,
  name: r'voteSubmissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voteSubmissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VoteSubmission = AutoDisposeNotifier<VoteSubmissionState>;

String _$voteUIHash() => r'...'; // 해시값

/// See also [VoteUI].
@ProviderFor(VoteUI)
final voteUIProvider =
    AutoDisposeNotifierProviderFamily<VoteUI, VoteUIState, String>.internal(
  VoteUI.new,
  name: r'voteUIProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$voteUIHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VoteUI = AutoDisposeNotifier<VoteUIState>;
typedef VoteUIRef = AutoDisposeNotifierProviderRef<VoteUIState>;
```

**검증 포인트**:
- ✅ `voteSubmissionProvider` 생성됨
- ✅ `voteUIProvider` 생성됨 (family)
- ✅ `AutoDisposeNotifier` 타입 사용 (기본값)
- ✅ Part directive 정상 작동

---

#### Import 문 수정

**vote_providers.dart** 최종 Import:

```dart
// ===== vote_providers.dart =====
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ❌ 제거: import 'package:flutter_riverpod/legacy.dart';

import '/app/di.dart';
import '/features/voting/domain/usecases/chat/submit_vote_use_case.dart';
import '/features/voting/domain/failures/voting_failure.dart';
import 'usecase_providers.dart'; // ✅ 추가

part 'vote_providers.g.dart'; // ✅ Part directive

// ... Notifier 클래스들
```

**usecase_providers.dart** Import:

```dart
// ===== usecase_providers.dart =====
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/chat/submit_vote_use_case.dart';

part 'usecase_providers.g.dart'; // ✅ Part directive

// ... UseCase Provider들
```

---

#### 컴파일 에러 수정

**일반적인 에러 1: Part directive 누락**

```
Error: Expected to find a part directive in vote_providers.dart
```

**해결**:
```dart
// vote_providers.dart 상단에 추가
part 'vote_providers.g.dart';
```

---

**일반적인 에러 2: legacy.dart import**

```
Error: 'StateProvider' is deprecated and shouldn't be used
```

**해결**:
```dart
// ❌ 제거
import 'package:flutter_riverpod/legacy.dart';
```

---

**일반적인 에러 3: Notifier 클래스명 충돌**

```
Error: '_$VoteSubmission' isn't defined for the class 'VoteSubmission'
```

**해결**:
```bash
# 코드 생성 재실행
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

#### flutter analyze 실행

**명령어**:
```bash
flutter analyze lib/features/voting/
```

**예상 출력 (성공)**:
```
Analyzing voting...
No issues found! (ran in 1.2s)
```

**에러 발견 시**:
```
Analyzing voting...
  error • The import of 'package:flutter_riverpod/legacy.dart' is unnecessary • lib/features/voting/presentation/providers/vote_providers.dart:13:8 • unnecessary_import
1 issue found. (ran in 1.5s)
```

**해결**: 불필요한 import 제거

---

## Appendix A: Provider 변환 매트릭스

### 현재 Voting Feature Provider 목록

**vote_providers.dart** (133 lines):

| Provider 이름 | 타입 | 라인 | 설명 |
|--------------|------|------|------|
| `voteSubmissionStateProvider` | StateProvider | L126-127 | 투표 제출 상태 |
| `voteSubmissionControllerProvider` | Provider | L130-132 | 투표 제출 Controller |
| `voteUIStateProvider` | StateProvider.family | L209-212 | 투표 UI 상태 (postId별) |
| `voteUIStateControllerProvider` | Provider.family | L215-218 | 투표 UI Controller (postId별) |

**총 Provider 수**: 4개

---

### 변환 후 Provider 목록 (Riverpod 3.x)

**vote_providers.dart** (예상):

| Provider 이름 | 타입 | Notifier 클래스 | 설명 |
|--------------|------|----------------|------|
| `voteSubmissionProvider` | AutoDisposeNotifier | VoteSubmission | 투표 제출 상태 + 로직 통합 |
| `voteUIProvider(postId)` | AutoDisposeNotifierFamily | VoteUI | 투표 UI 상태 + 로직 통합 (postId별) |

**usecase_providers.dart** (신규):

| Provider 이름 | 타입 | 반환 타입 | 설명 |
|--------------|------|----------|------|
| `submitVoteUseCaseProvider` | AutoDisposeProvider | SubmitVoteUseCase | GetIt UseCase 래핑 |

**총 Provider 수**: 3개 (감소: 4 → 3)

---

### 변환 규칙 요약

#### StateProvider → @riverpod class Notifier

| Before (2.x) | After (3.x) |
|-------------|------------|
| `StateProvider<T>` | `@riverpod class MyNotifier extends _$MyNotifier` |
| `(ref) => initialState` | `@override T build() => initialState` |
| `ref.read(provider.notifier).state = newState` | `state = newState` |
| Provider 이름: `myStateProvider` | Provider 이름: `myNotifierProvider` (자동 생성) |

---

#### StateProvider.family → @riverpod class Notifier with parameter

| Before (2.x) | After (3.x) |
|-------------|------------|
| `StateProvider.family<T, P>` | `@riverpod class MyNotifier extends _$MyNotifier` |
| `(ref, param) => initialState` | `@override T build(P param) => initialState` |
| `provider(param).notifier.state = newState` | `state = newState` |
| Provider 이름: `myStateProvider(param)` | Provider 이름: `myNotifierProvider(param)` (자동 생성) |

---

#### Provider (Controller) → @riverpod class Notifier

| Before (2.x) | After (3.x) |
|-------------|------------|
| `class MyController { ... }` | `@riverpod class MyNotifier extends _$MyNotifier { ... }` |
| `Provider<MyController>((ref) => MyController(ref))` | 제거 (Notifier가 대체) |
| `controller.method()` | `notifier.method()` |
| 상태 + 로직 분리 | 상태 + 로직 통합 |

---

#### Provider (UseCase) → @riverpod getter function

| Before (2.x) | After (3.x) |
|-------------|------------|
| `Provider<UseCase>((ref) => getIt<UseCase>())` | `@riverpod UseCase myUseCase(Ref ref) => getIt<UseCase>()` |
| Provider 타입 명시 필요 | 반환 타입에서 자동 추론 |
| 동일 파일 or 별도 파일 | usecase_providers.dart 파일 분리 권장 |

---

### 코드 감소 통계 (예상)

| 항목 | Before (2.x) | After (3.x) | 감소율 |
|------|--------------|-------------|--------|
| **Provider 파일 수** | 1개 | 2개 (vote_providers.dart, usecase_providers.dart) | - |
| **Provider 정의 라인** | 15 lines | 자동 생성 (.g.dart) | 100% |
| **Controller 클래스** | 115 lines (2 classes) | 0 lines (Notifier로 통합) | 100% |
| **Notifier 클래스** | 0 lines | ~80 lines (2 classes) | - |
| **총 라인 수** | 133 lines | ~100 lines (수동 작성) + 자동 생성 | ~25% 감소 |

**예상 결과**:
- 수동 작성 코드: 133 lines → ~100 lines (25% 감소)
- 보일러플레이트: 15 lines (Provider 정의) → 0 lines (자동 생성)
- 유지보수성: Controller + StateProvider 분리 → Notifier 통합

---

### 변환 체크리스트

#### Phase 2 완료 확인

- [ ] **vote_providers.dart 변환 완료**
  - [ ] Import 문 수정 (legacy.dart 제거, riverpod_annotation 추가)
  - [ ] Part directive 추가 (`part 'vote_providers.g.dart';`)
  - [ ] `VoteSubmission` Notifier 클래스 생성
  - [ ] `VoteUI` Notifier 클래스 생성
  - [ ] Controller 클래스 제거 (VoteSubmissionController, VoteUIStateController)
  - [ ] StateProvider 정의 제거 (voteSubmissionStateProvider, voteUIStateProvider)
  - [ ] Controller Provider 정의 제거 (voteSubmissionControllerProvider, voteUIStateControllerProvider)

- [ ] **usecase_providers.dart 생성 완료**
  - [ ] 파일 생성: `lib/features/voting/presentation/providers/usecase_providers.dart`
  - [ ] Import 문 추가
  - [ ] Part directive 추가 (`part 'usecase_providers.g.dart';`)
  - [ ] `submitVoteUseCaseProvider` 추가
  - [ ] (Optional) 추가 UseCase Provider 생성

- [ ] **코드 생성 완료**
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
  - [ ] `vote_providers.g.dart` 생성 확인
  - [ ] `usecase_providers.g.dart` 생성 확인
  - [ ] 생성 파일 오류 없음

- [ ] **컴파일 확인**
  - [ ] `flutter analyze lib/features/voting/` 실행
  - [ ] 에러 없음 확인
  - [ ] Warning 확인 및 해결

- [ ] **문서 업데이트** (Phase 7에서 상세 수행)
  - [ ] 주석 추가 (마이그레이션 내역)
  - [ ] README.md 업데이트 예정 표시

---

## 다음 단계: Phase 3-7

Phase 1-2를 완료했다면, 다음 단계로 진행하세요:

**Phase 3: Controller Class Migration**
- Controller 로직을 Notifier 메서드로 완전 이동
- Widget에서 Provider 사용법 업데이트
- GetIt → Riverpod Provider 전환 완료

**Phase 4: Widget Integration**
- ConsumerWidget 업데이트
- ref.watch() / ref.read() 패턴 변경
- 액션 디스패치 방식 변경

**Phase 5: Code Generation**
- build_runner 최종 실행
- .g.dart 파일 검증
- Import 문 정리

**Phase 6: Testing & Verification**
- Unit 테스트 작성
- Integration 테스트
- 수동 테스트

**Phase 7: Documentation**
- README.md 업데이트 (Riverpod 2.x → 3.x)
- Provider 문서화
- 마이그레이션 로그 작성

---

**다음 문서**: `RIVERPOD_3X_MIGRATION_PHASE_3_7.md`

---

**작성**: 2025-11-06
**참조 구현**: Creation Feature (Riverpod 3.x 완료, 2025-11-06)
**예상 작업 시간**: Phase 1 (15분) + Phase 2 (1-2시간) = **1.25-2.25시간**
