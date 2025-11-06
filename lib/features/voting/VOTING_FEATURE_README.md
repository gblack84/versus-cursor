# Voting Feature - Riverpod 3.x Migration ✅

> **마이그레이션 완료일**: 2025-11-06
> **상태 관리**: Riverpod 3.x (Code Generation)
> **아키텍처**: Clean Architecture v4.0

---

## 📋 목차

- [Feature 개요](#-feature-개요)
- [Riverpod 3.x 마이그레이션](#-riverpod-3x-마이그레이션)
- [Provider 구조](#-provider-구조)
- [사용 패턴](#-사용-패턴)
- [파일 구조](#-파일-구조)
- [마이그레이션 문서](#-마이그레이션-문서)

---

## 🎯 Feature 개요

Voting Feature는 사용자의 투표 참여 및 제출을 관리합니다.

### 핵심 기능

- **투표 옵션 선택**: A vs B 옵션 선택
- **투표 제출 및 검증**: SubmitVoteUseCase를 통한 도메인 레이어 연결
- **실시간 투표 상태 관리**: postId별 독립적인 UI 상태 관리
- **에러 처리 및 재시도**: Either 패턴을 통한 안전한 에러 처리
- **애니메이션 상태**: 투표 UI 애니메이션 제어

---

## ✅ Riverpod 3.x 마이그레이션

### Before (Riverpod 2.x)

```dart
// ❌ Legacy: StateProvider + Controller 패턴
final voteSubmissionStateProvider = StateProvider<VoteSubmissionState>((ref) => ...);
final voteSubmissionControllerProvider = Provider<VoteSubmissionController>((ref) => ...);

// ❌ Legacy: StateProvider.family + Controller 패턴
final voteUIStateProvider = StateProvider.family<VoteUIState, String>((ref, postId) => ...);
final voteUIStateControllerProvider = Provider.family<VoteUIStateController, String>((ref, postId) => ...);
```

### After (Riverpod 3.x)

```dart
// ✅ New: @riverpod Notifier 패턴
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();

  Future<VoteSubmissionState> submitVote({...}) async { ... }
}

// ✅ New: @riverpod NotifierFamily 패턴
@riverpod
class VoteUIStateNotifier extends _$VoteUIStateNotifier {
  @override
  VoteUIState build(String postId) => const VoteUIState();

  void markAsVoted(String option) { ... }
}
```

### 주요 변경 사항

| 항목 | Before (2.x) | After (3.x) |
|------|--------------|-------------|
| **Provider 정의** | `StateProvider`, `Provider.family` | `@riverpod` 어노테이션 |
| **Controller** | 별도 Controller 클래스 | Notifier 클래스에 통합 |
| **State 클래스** | Plain Dart class | Freezed 불변 클래스 |
| **Code Generation** | Manual | `build_runner` 자동 생성 |
| **파일 수** | 1개 (vote_providers.dart) | 3개 (분리) |
| **생성 파일** | 없음 | 5개 (.g.dart, .freezed.dart) |

---

## 🏗 Provider 구조

### 1. VoteSubmission Notifier

**파일**: `vote_submission_notifier.dart`

**역할**: 투표 제출 상태 관리

**State** (Freezed):
```dart
@freezed
class VoteSubmissionState with _$VoteSubmissionState {
  const factory VoteSubmissionState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(false) bool isSuccess,
  }) = _VoteSubmissionState;
}
```

**메서드**:
- `Future<VoteSubmissionState> submitVote({required String postId, required String userId, required String choice, ...})`: 투표 제출
- `void reset()`: 상태 초기화

**사용 예시**:
```dart
// Widget에서 사용
class VoteButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voteSubmissionProvider);

    return ElevatedButton(
      onPressed: state.isLoading ? null : () async {
        final result = await ref
          .read(voteSubmissionProvider.notifier)
          .submitVote(
            postId: 'post123',
            userId: 'user456',
            choice: 'A',
          );

        if (result.error != null) {
          // 에러 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error!)),
          );
        }
      },
      child: state.isLoading
        ? CircularProgressIndicator()
        : Text('투표하기'),
    );
  }
}
```

---

### 2. VoteUIStateNotifier (Family)

**파일**: `vote_ui_state_notifier.dart`

**역할**: 투표 UI 상태 관리 (postId별 독립)

**State** (Freezed):
```dart
@freezed
class VoteUIState with _$VoteUIState {
  const factory VoteUIState({
    @Default(false) bool hasVoted,
    @Default(null) String? selectedOption,
    @Default(null) DateTime? voteTimestamp,
    @Default(false) bool isAnimating,
  }) = _VoteUIState;
}
```

**메서드**:
- `void markAsVoted(String option)`: 투표 완료 처리
- `void startAnimation()`: 애니메이션 시작
- `void stopAnimation()`: 애니메이션 종료
- `void reset()`: 상태 초기화

**사용 예시**:
```dart
// Widget에서 사용 (postId별 독립 상태)
class VoteCard extends ConsumerWidget {
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // postId별로 독립적인 상태 관리
    final uiState = ref.watch(voteUIStateNotifierProvider(postId));

    return Column(
      children: [
        if (uiState.hasVoted)
          Text('선택: ${uiState.selectedOption}'),

        ElevatedButton(
          onPressed: () {
            // 투표 완료 처리
            ref
              .read(voteUIStateNotifierProvider(postId).notifier)
              .markAsVoted('A');
          },
          child: Text('A에 투표'),
        ),
      ],
    );
  }
}
```

---

### 3. UseCase Providers

**파일**: `usecase_providers.dart`

**역할**: GetIt UseCase를 Riverpod Provider로 래핑

```dart
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}
```

**사용 예시**:
```dart
// Provider에서 사용
final useCase = ref.read(submitVoteUseCaseProvider);
final result = await useCase(
  postId: postId,
  userId: userId,
  voteOption: 'A',
);
```

---

## 💡 사용 패턴

### Widget에서 Provider 사용

#### 1. ref.watch() - 상태 구독

```dart
class VoteStatus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 변경 시 자동 리빌드
    final state = ref.watch(voteSubmissionProvider);

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.error != null) {
      return Text('Error: ${state.error}');
    }

    if (state.isSuccess) {
      return Text('투표 완료!');
    }

    return Text('투표 대기 중');
  }
}
```

#### 2. ref.read() - 이벤트 처리

```dart
class VoteSubmitButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // 이벤트 발생 시 한 번만 실행
        await ref
          .read(voteSubmissionProvider.notifier)
          .submitVote(
            postId: 'post123',
            userId: 'user456',
            choice: 'A',
          );
      },
      child: Text('투표하기'),
    );
  }
}
```

#### 3. ref.listen() - 부수 효과 처리

```dart
class VotePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<VotePage> createState() => _VotePageState();
}

class _VotePageState extends ConsumerState<VotePage> {
  @override
  Widget build(BuildContext context) {
    // 상태 변경 시 부수 효과 실행 (SnackBar, Navigation 등)
    ref.listen<VoteSubmissionState>(
      voteSubmissionProvider,
      (previous, next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (next.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('투표 완료!')),
          );

          // 성공 시 페이지 이동
          Navigator.of(context).pop();
        }
      },
    );

    return Scaffold(...);
  }
}
```

---

## 📁 파일 구조

```
lib/features/voting/
├── presentation/
│   └── providers/
│       ├── vote_submission_notifier.dart          # VoteSubmission Notifier
│       ├── vote_submission_notifier.freezed.dart  # Freezed 생성 파일
│       ├── vote_submission_notifier.g.dart        # Riverpod 생성 파일
│       │
│       ├── vote_ui_state_notifier.dart            # VoteUIStateNotifier (Family)
│       ├── vote_ui_state_notifier.freezed.dart    # Freezed 생성 파일
│       ├── vote_ui_state_notifier.g.dart          # Riverpod 생성 파일
│       │
│       ├── usecase_providers.dart                 # UseCase 래핑
│       └── usecase_providers.g.dart               # Riverpod 생성 파일
│
├── RIVERPOD_3X_MIGRATION_PHASE_1_2.md            # 마이그레이션 가이드 (준비 + Provider)
├── RIVERPOD_3X_MIGRATION_PHASE_3_7.md            # 마이그레이션 가이드 (실행 + 검증)
└── VOTING_FEATURE_README.md                      # 이 파일
```

### 생성된 파일

**Riverpod Generator** (`.g.dart`):
- `vote_submission_notifier.g.dart` - VoteSubmissionProvider 생성
- `vote_ui_state_notifier.g.dart` - VoteUIStateNotifierProvider 생성
- `usecase_providers.g.dart` - submitVoteUseCaseProvider 생성

**Freezed** (`.freezed.dart`):
- `vote_submission_notifier.freezed.dart` - VoteSubmissionState 클래스 생성
- `vote_ui_state_notifier.freezed.dart` - VoteUIState 클래스 생성

---

## 📚 마이그레이션 문서

### Phase 1-2: 준비 및 Provider Migration

**파일**: `RIVERPOD_3X_MIGRATION_PHASE_1_2.md` (1,915 lines)

**내용**:
- Phase 1.1: Dependencies 확인
- Phase 1.2: 파일 구조 설계
- Phase 1.3: 백업 전략
- Phase 2.1: StateProvider → Notifier (VoteSubmission)
- Phase 2.2: Provider (UseCase) → @riverpod getter
- Phase 2.3: Provider.family (Controller) → NotifierFamily
- Phase 2.4: Code Generation

### Phase 3-7: 실행 및 검증

**파일**: `RIVERPOD_3X_MIGRATION_PHASE_3_7.md` (3,041 lines)

**내용**:
- Phase 3: Widget Integration (base_vote_message.dart 업데이트)
- Phase 4: Code Generation (Final)
- Phase 5: Testing & Verification
- Phase 6: Legacy Code Cleanup (9단계 상세 가이드)
  - 6.1: 파일 관리
  - 6.2: Import 정리
  - 6.3: 주석 업데이트
  - 6.4: DI Module 정리
  - 6.5: Widget 파일 레거시 코드 정리
  - 6.6: Test 파일 레거시 처리
  - 6.7: 레거시 DI 바인딩 완전 제거 검증
  - 6.8: Git Commit
  - 6.9: Phase 6 최종 완료 체크리스트
- Phase 7: Documentation

---

## 🔄 마이그레이션 히스토리

### 2025-11-06: Riverpod 2.x → 3.x 완료

**변경 사항**:
- ✅ StateProvider → @riverpod Notifier (1개)
- ✅ StateProvider.family → @riverpod NotifierFamily (1개)
- ✅ Provider (Controller) → Notifier 클래스로 통합 (2개)
- ✅ Provider (UseCase) → @riverpod getter (1개)
- ✅ Freezed 불변 클래스 (2개)
- ✅ 코드 생성: .g.dart 파일 3개, .freezed.dart 파일 2개 추가
- ❌ vote_providers.dart 삭제 (레거시 코드 제거)

**코드 감소**:
- Provider 정의: 4 → 3 (25% 감소)
- Controller 클래스: 2 → 0 (Notifier로 통합)
- 파일 수: 1 → 3 (분리로 유지보수성 향상)
- 총 코드 라인: 219 lines → ~320 lines (문서 포함 시 대폭 증가)

**Benefits**:
- 🎯 **Type-safe Provider access**: 컴파일 타임에 에러 검출
- 🔄 **Automatic code generation**: 수동 코딩 오류 방지
- 📦 **Cleaner codebase**: Controller 제거로 단순화
- 🛡️ **Freezed immutability**: 불변 상태로 버그 방지
- 🚀 **Better performance**: AutoDispose로 메모리 최적화

---

## 🧪 테스트

### Provider 단위 테스트

**파일**: `test/features/voting/presentation/providers/vote_submission_notifier_test.dart`

**테스트 케이스**:
1. 초기 상태 검증
2. `submitVote()` 동작 검증
3. `reset()` 동작 검증
4. 에러 처리 검증

**예시**:
```dart
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('초기 상태는 비어있음', () {
    final state = container.read(voteSubmissionProvider);

    expect(state.isLoading, false);
    expect(state.error, null);
    expect(state.isSuccess, false);
  });

  test('submitVote 성공 시 isSuccess = true', () async {
    final notifier = container.read(voteSubmissionProvider.notifier);

    final result = await notifier.submitVote(
      postId: 'test',
      userId: 'user123',
      choice: 'A',
    );

    expect(result.isSuccess, true);
    expect(result.error, null);
  });
}
```

---

## 📖 참조 문서

- **Riverpod 공식 문서**: https://riverpod.dev/
- **Creation Feature**: `lib/features/creation/README.md` - Riverpod 3.x 참조 구현
- **Post Feature**: `lib/features/post/README.md` - Riverpod 2.x 참조 구현
- **Freezed 공식 문서**: https://pub.dev/packages/freezed

---

**마이그레이션 완료**: 2025-11-06
**소요 시간**: 총 2시간 (Phase 1-7)
**다음 단계**: Auth, Profile, Chat Feature 마이그레이션

🤖 Generated with [Claude Code](https://claude.com/claude-code)
