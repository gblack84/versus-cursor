# Voting Feature - Riverpod 3.x Migration Guide (Phase 3-7)

**문서 버전**: 1.0.0
**작성일**: 2025-11-06
**대상 Feature**: Voting
**참조 Feature**: Creation (Riverpod 3.x 완료)
**이전 문서**: [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)

---

## 📋 목차

- [Phase 3: Widget Integration (위젯 통합)](#phase-3-widget-integration-위젯-통합)
- [Phase 4: Code Generation (코드 생성)](#phase-4-code-generation-코드-생성)
- [Phase 5: Testing & Verification (테스트 및 검증)](#phase-5-testing--verification-테스트-및-검증)
- [Phase 6: Legacy Code Cleanup (레거시 코드 정리)](#phase-6-legacy-code-cleanup-레거시-코드-정리)
- [Phase 7: Documentation (문서화)](#phase-7-documentation-문서화)
- [Appendix B: Creation Feature 참조](#appendix-b-creation-feature-참조)
- [Appendix C: Voting Feature 현재 구조](#appendix-c-voting-feature-현재-구조)
- [Appendix D: 전체 마이그레이션 체크리스트](#appendix-d-전체-마이그레이션-체크리스트)

---

## Phase 3: Widget Integration (위젯 통합)

**목표**: Riverpod 3.x Provider를 Widget에서 사용하도록 변경
**소요 시간**: 1.5-2.5시간
**난이도**: 중 (★★★☆☆)

### 3.1 ConsumerWidget 패턴 적용

#### 3.1.1 기존 Widget 분석

**현재 상태** (Voting Feature):
```dart
// lib/features/voting/presentation/screens/vote_page.dart (예상 구조)
class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('투표')),
      body: VoteForm(),
    );
  }
}
```

**Creation Feature 참조** (lib/features/creation/presentation/screens/create_post/create_post_screen.dart:20-40):
```dart
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  static String routeName = 'createPost';
  static String routePath = '/create-post';

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 초기화 로직
    Future.microtask(() {
      ref.read(createPostProvider.notifier).initializeDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPostProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context, state),
      body: _buildBody(context, state),
    );
  }
}
```

#### 3.1.2 Widget 변환 단계

**Step 1: StatefulWidget → ConsumerStatefulWidget**

```dart
// Before (Riverpod 2.x)
class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  // ...
}
```

**After (Riverpod 3.x)**:
```dart
class VotePage extends ConsumerStatefulWidget {
  const VotePage({super.key});

  static String routeName = 'vote';
  static String routePath = '/vote/:postId';

  @override
  ConsumerState<VotePage> createState() => _VotePageState();
}

class _VotePageState extends ConsumerState<VotePage> {
  @override
  void initState() {
    super.initState();

    // Riverpod 3.x: ref 사용 가능
    Future.microtask(() {
      ref.read(voteSubmissionProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch()로 상태 구독
    final submissionState = ref.watch(voteSubmissionProvider);
    final uiState = ref.watch(voteUIStateProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildVoteForm(submissionState, uiState),
    );
  }
}
```

**Step 2: StatelessWidget → ConsumerWidget**

```dart
// Before (Riverpod 2.x)
class VoteOptionCard extends StatelessWidget {
  final String option;

  const VoteOptionCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(option),
    );
  }
}
```

**After (Riverpod 3.x)**:
```dart
class VoteOptionCard extends ConsumerWidget {
  final String postId;
  final String optionId;

  const VoteOptionCard({
    super.key,
    required this.postId,
    required this.optionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch()로 실시간 상태 구독
    final submissionState = ref.watch(voteSubmissionProvider);
    final isSelected = submissionState.selectedOptionId == optionId;

    return Card(
      color: isSelected ? Colors.blue : Colors.white,
      child: InkWell(
        onTap: () {
          ref.read(voteSubmissionProvider.notifier).selectOption(optionId);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            optionId,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3.2 Provider 사용 패턴

#### 3.2.1 ref.watch() - 상태 구독

**용도**: Widget이 상태 변화를 추적하고 자동 리빌드

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // 상태 구독: 변경 시 자동 리빌드
  final submissionState = ref.watch(voteSubmissionProvider);

  return Text('Loading: ${submissionState.isLoading}');
}
```

**Creation Feature 참조** (lib/features/creation/presentation/screens/create_post/create_post_screen.dart:140-145):
```dart
final state = ref.watch(createPostProvider);

if (state.isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

#### 3.2.2 ref.read() - 일회성 읽기

**용도**: 이벤트 핸들러에서 Provider 읽기 (리빌드 발생 안 함)

```dart
void _handleSubmitVote() {
  final notifier = ref.read(voteSubmissionProvider.notifier);
  notifier.submitVote();
}
```

**Creation Feature 참조** (lib/features/creation/presentation/screens/create_post/create_post_screen.dart:275-280):
```dart
onPressed: () {
  ref.read(createPostProvider.notifier).saveAsDraft();
},
```

#### 3.2.3 ref.listen() - 부수 효과 처리

**용도**: 상태 변화를 감지하여 SnackBar, Dialog 표시

```dart
@override
void initState() {
  super.initState();

  // 에러 발생 시 SnackBar 표시
  ref.listen<VoteSubmissionState>(
    voteSubmissionProvider,
    (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }

      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표가 완료되었습니다')),
        );
        Navigator.of(context).pop();
      }
    },
  );
}
```

**Creation Feature 참조** (lib/features/creation/presentation/widgets/create_post/text_input_widget.dart:140-155):
```dart
ref.listen<CreatePostState>(
  createPostProvider,
  (previous, next) {
    if (next.validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.validationError!),
          backgroundColor: VersusColors.error,
        ),
      );
    }
  },
);
```

### 3.3 Widget 통합 구현 예시

#### 3.3.1 VotePage Widget (Full Example)

```dart
// lib/features/voting/presentation/screens/vote_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/voting/presentation/providers/vote_submission_notifier.dart';
import '/features/voting/presentation/providers/vote_ui_state_notifier.dart';
import '/core/design_system/design_system.dart';

class VotePage extends ConsumerStatefulWidget {
  final String postId;

  const VotePage({super.key, required this.postId});

  static String routeName = 'vote';
  static String routePath = '/vote/:postId';

  @override
  ConsumerState<VotePage> createState() => _VotePageState();
}

class _VotePageState extends ConsumerState<VotePage> {
  @override
  void initState() {
    super.initState();

    // 초기화: 상태 리셋
    Future.microtask(() {
      ref.read(voteSubmissionProvider.notifier).reset();
      ref.read(voteUIStateProvider(widget.postId).notifier).loadVoteOptions();
    });

    // 부수 효과 리스너: 에러/성공 처리
    ref.listen<VoteSubmissionState>(
      voteSubmissionProvider,
      (previous, next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: VersusColors.error,
            ),
          );
        }

        if (next.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('투표가 완료되었습니다!'),
              backgroundColor: VersusColors.success,
            ),
          );

          // 성공 시 이전 화면으로 이동
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 상태 구독
    final submissionState = ref.watch(voteSubmissionProvider);
    final uiState = ref.watch(voteUIStateProvider(widget.postId));

    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: VersusColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '투표하기',
          style: VersusTextStyles.headingSmall,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: _buildBody(submissionState, uiState),
      ),
    );
  }

  Widget _buildBody(VoteSubmissionState submissionState, VoteUIState uiState) {
    if (uiState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(VersusColors.primary),
        ),
      );
    }

    if (uiState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: VersusColors.error),
            SizedBox(height: 16),
            Text(
              uiState.error!,
              style: VersusTextStyles.bodyMedium.copyWith(
                color: VersusColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(voteUIStateProvider(widget.postId).notifier).loadVoteOptions();
              },
              style: ElevatedButton.styleFrom(backgroundColor: VersusColors.primary),
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(VersusSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 질문 제목
          Text(
            uiState.questionTitle ?? '투표 질문',
            style: VersusTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          VersusSpacing.gapXL,

          // 옵션 A
          _buildOptionCard(
            optionId: 'A',
            optionText: uiState.optionAText ?? 'Option A',
            isSelected: submissionState.selectedOptionId == 'A',
            onTap: () {
              ref.read(voteSubmissionProvider.notifier).selectOption('A');
            },
          ),
          VersusSpacing.gapLG,

          // VS 구분선
          Row(
            children: [
              Expanded(child: Divider(color: VersusColors.borderMedium)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: VersusSpacing.md),
                child: Text(
                  'VS',
                  style: VersusTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: VersusColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: VersusColors.borderMedium)),
            ],
          ),
          VersusSpacing.gapLG,

          // 옵션 B
          _buildOptionCard(
            optionId: 'B',
            optionText: uiState.optionBText ?? 'Option B',
            isSelected: submissionState.selectedOptionId == 'B',
            onTap: () {
              ref.read(voteSubmissionProvider.notifier).selectOption('B');
            },
          ),
          VersusSpacing.gapXL,

          // 투표 제출 버튼
          ElevatedButton(
            onPressed: submissionState.isLoading || submissionState.selectedOptionId == null
                ? null
                : () {
                    ref.read(voteSubmissionProvider.notifier).submitVote(
                      postId: widget.postId,
                      userId: 'currentUserId', // TODO: 실제 userId 가져오기
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: VersusColors.primary,
              padding: EdgeInsets.symmetric(vertical: VersusSpacing.md),
              disabledBackgroundColor: VersusColors.textTertiary,
            ),
            child: submissionState.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    '투표하기',
                    style: VersusTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String optionId,
    required String optionText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = optionId == 'A' ? VersusColors.primary : VersusColors.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: VersusRadius.card,
      child: Container(
        padding: EdgeInsets.all(VersusSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : VersusColors.backgroundSecondary,
          borderRadius: VersusRadius.card,
          border: Border.all(
            color: isSelected ? color : VersusColors.borderLight,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              optionId,
              style: VersusTextStyles.headingLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            VersusSpacing.gapSM,
            Text(
              optionText,
              style: VersusTextStyles.bodyLarge,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              VersusSpacing.gapMD,
              Icon(
                Icons.check_circle,
                color: color,
                size: 32,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 3.4 Post Feature Widget 통합 참조

#### 3.4.1 ConsumerWidget with AsyncValue.when()

**Post Feature 참조** (lib/features/post/presentation/screens/trending/trending_posts_page.dart:16-48):
```dart
class TrendingPostsPage extends ConsumerWidget {
  const TrendingPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(trendingPostsStreamProvider(20));

    return Scaffold(
      body: SafeArea(
        top: true,
        child: postsAsync.when(
          // Loading state
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(VersusColors.primary),
            ),
          ),

          // Error state
          error: (error, stack) {
            String errorMessage = '오류가 발생했습니다';

            if (error is PostFailure) {
              errorMessage = error.when(
                networkError: () => '네트워크 연결을 확인해주세요.',
                serverError: (message) => '서버 오류: ${message ?? "알 수 없는 오류"}',
                // ... other error cases
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: VersusColors.error),
                  SizedBox(height: 16),
                  Text(errorMessage),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(trendingPostsStreamProvider(20));
                    },
                    child: Text('다시 시도'),
                  ),
                ],
              ),
            );
          },

          // Data state
          data: (posts) {
            if (posts.isEmpty) {
              return Center(child: Text('트렌딩 게시물이 없습니다'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(trendingPostsStreamProvider(20));
              },
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildTrendingCard(context, post);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
```

#### 3.4.2 ConsumerStatefulWidget with initState()

**Post Feature 참조** (lib/features/post/presentation/screens/feed/home_page_widget.dart:24-60):
```dart
class HomePageWidget extends ConsumerStatefulWidget {
  const HomePageWidget({super.key});

  @override
  ConsumerState<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends ConsumerState<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 백그라운드에서 인기 게시물 프리로드
    Future.microtask(() async {
      try {
        await UnifiedCacheService.instance.preloadPopularPosts();
        debugPrint('[HomePage] Popular posts preloaded successfully');
      } catch (e) {
        debugPrint('[HomePage] Failed to preload popular posts: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch feed stream with default params
    final feedAsync = ref.watch(
      feedStreamProvider(
        const FeedParams(limit: 20, sortBy: FeedSortBy.latest),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      body: feedAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error),
        data: (posts) => _buildPostList(posts),
      ),
    );
  }
}
```

### 3.5 Phase 3 완료 체크리스트

- [ ] **VotePage Widget 변환**
  - [ ] `ConsumerStatefulWidget` 상속
  - [ ] `ref.watch()` 사용하여 상태 구독
  - [ ] `ref.listen()` 사용하여 부수 효과 처리
  - [ ] `initState()`에서 초기화 로직 추가

- [ ] **VoteOptionCard Widget 변환**
  - [ ] `ConsumerWidget` 상속
  - [ ] `ref.watch()` 사용하여 선택 상태 구독
  - [ ] `ref.read()` 사용하여 이벤트 핸들러 구현

- [ ] **에러 처리 개선**
  - [ ] `AsyncValue.when()` 패턴 적용 (해당 시)
  - [ ] `PostFailure` 스타일 에러 메시지 처리
  - [ ] `ref.invalidate()` 사용하여 재시도 구현

- [ ] **UI/UX 개선**
  - [ ] 로딩 인디케이터 추가
  - [ ] 에러 상태 UI 개선
  - [ ] 성공/실패 SnackBar 표시
  - [ ] 빈 상태 UI 추가 (해당 시)

---

## Phase 4: Code Generation (코드 생성)

**목표**: build_runner로 .g.dart 파일 생성 및 검증
**소요 시간**: 0.5-1시간
**난이도**: 하 (★☆☆☆☆)

### 4.1 Code Generation 실행

#### 4.1.1 기본 생성 명령어

```bash
# 1. 기존 생성 파일 삭제 후 재생성
dart run build_runner build --delete-conflicting-outputs

# 2. 생성 결과 확인
ls -la lib/features/voting/presentation/providers/

# 예상 출력:
# vote_submission_notifier.dart      (원본)
# vote_submission_notifier.g.dart    (생성됨) ✅
# vote_ui_state_notifier.dart        (원본)
# vote_ui_state_notifier.g.dart      (생성됨) ✅
# usecase_providers.dart              (원본)
# usecase_providers.g.dart            (생성됨) ✅
```

#### 4.1.2 Watch 모드 (개발 중 권장)

```bash
# Watch 모드로 실행: 파일 변경 시 자동 재생성
dart run build_runner watch --delete-conflicting-outputs
```

**Creation Feature 참조**: Creation Feature도 동일한 명령어 사용

### 4.2 생성된 파일 구조

#### 4.2.1 VoteSubmissionNotifier.g.dart 예상 구조

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_submission_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voteSubmissionHash() => r'5a9b8c7d6e4f3a2b1c0d9e8f7a6b5c4d';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
```

#### 4.2.2 생성 파일 검증

**검증 항목**:
1. `.g.dart` 파일이 생성되었는지 확인
2. `part of` 지시문이 올바른지 확인
3. Provider 이름이 예상과 일치하는지 확인
4. AutoDispose 타입이 올바른지 확인

```bash
# 생성된 Provider 확인
grep -r "final.*Provider" lib/features/voting/presentation/providers/*.g.dart

# 예상 출력:
# vote_submission_notifier.g.dart:final voteSubmissionProvider = ...
# vote_ui_state_notifier.g.dart:final voteUIStateProvider = ...
# usecase_providers.g.dart:final submitVoteUseCaseProvider = ...
```

### 4.3 빌드 에러 해결

#### 4.3.1 일반적인 빌드 에러

**Error 1: "part of" 지시문 누락**
```
Error: The part directive must come after all imports
```

**해결책**:
```dart
// ❌ 잘못된 순서
part 'vote_submission_notifier.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ 올바른 순서
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_submission_notifier.g.dart';
```

**Error 2: @riverpod 어노테이션 누락**
```
Error: No generator found for 'VoteSubmission'
```

**해결책**:
```dart
// ❌ 어노테이션 없음
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();
}

// ✅ @riverpod 어노테이션 추가
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();
}
```

**Error 3: build() 메서드 반환 타입 불일치**
```
Error: The return type 'void' isn't a 'VoteSubmissionState'
```

**해결책**:
```dart
// ❌ 반환 타입 명시 안 함
@override
build() => const VoteSubmissionState();

// ✅ 반환 타입 명시
@override
VoteSubmissionState build() => const VoteSubmissionState();
```

#### 4.3.2 캐시 문제 해결

```bash
# 1. 빌드 캐시 삭제
dart run build_runner clean

# 2. Flutter 캐시 삭제
flutter clean

# 3. 의존성 재설치
flutter pub get

# 4. 재생성
dart run build_runner build --delete-conflicting-outputs
```

### 4.4 Phase 4 완료 체크리스트

- [ ] **Code Generation 실행**
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 성공
  - [ ] `.g.dart` 파일 3개 생성됨

- [ ] **생성 파일 검증**
  - [ ] `vote_submission_notifier.g.dart` 존재
  - [ ] `vote_ui_state_notifier.g.dart` 존재
  - [ ] `usecase_providers.g.dart` 존재

- [ ] **빌드 에러 없음**
  - [ ] `flutter analyze` 통과
  - [ ] Import 에러 없음
  - [ ] Type 에러 없음

---

## Phase 5: Testing & Verification (테스트 및 검증)

**목표**: 마이그레이션 후 기능 및 성능 검증
**소요 시간**: 2-3시간
**난이도**: 상 (★★★★☆)

### 5.1 정적 분석 검증

#### 5.1.1 Flutter Analyze

```bash
# 전체 프로젝트 분석
flutter analyze

# Voting Feature만 분석
flutter analyze lib/features/voting

# 예상 출력 (정상):
Analyzing voting...

No issues found! (ran in 2.3s)
```

#### 5.1.2 주요 검증 항목

```bash
# 1. Import 검증
grep -r "import.*vote_providers.dart" lib/features/voting/

# 2. Provider 사용 검증
grep -r "voteSubmissionProvider" lib/features/voting/

# 3. .g.dart 파일 검증
ls -la lib/features/voting/presentation/providers/*.g.dart
```

### 5.2 기능 테스트

#### 5.2.1 수동 테스트 시나리오

**Scenario 1: 투표 옵션 선택**
```
1. VotePage 열기
2. 옵션 A 클릭
   → 예상: 옵션 A가 선택 상태로 변경됨 ✅
3. 옵션 B 클릭
   → 예상: 옵션 B가 선택 상태로 변경됨, A는 선택 해제 ✅
4. 투표하기 버튼 활성화 확인 ✅
```

**Scenario 2: 투표 제출**
```
1. VotePage 열기
2. 옵션 A 선택
3. 투표하기 버튼 클릭
   → 예상: 로딩 인디케이터 표시 ✅
   → 예상: 성공 SnackBar 표시 ✅
   → 예상: 이전 화면으로 이동 ✅
```

**Scenario 3: 에러 처리**
```
1. VotePage 열기
2. 네트워크 연결 끊기
3. 투표하기 버튼 클릭
   → 예상: 에러 SnackBar 표시 ✅
   → 예상: 투표 상태가 초기 상태로 복원 ✅
```

**Scenario 4: 상태 리셋**
```
1. VotePage 열기
2. 옵션 A 선택
3. 뒤로가기
4. VotePage 다시 열기
   → 예상: 선택 상태가 초기화됨 ✅
```

#### 5.2.2 자동 테스트 (Widget Test)

```dart
// test/features/voting/presentation/screens/vote_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_space/features/voting/presentation/screens/vote_page.dart';

void main() {
  group('VotePage Widget Tests', () {
    testWidgets('초기 상태: 옵션 선택 안 됨, 버튼 비활성화', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VotePage(postId: 'test_post_id'),
          ),
        ),
      );

      // 옵션이 선택되지 않았는지 확인
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // 투표하기 버튼이 비활성화되었는지 확인
      final submitButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(submitButton.enabled, isFalse);
    });

    testWidgets('옵션 A 선택 시 상태 변경', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VotePage(postId: 'test_post_id'),
          ),
        ),
      );

      // 옵션 A 카드 찾기
      final optionACard = find.text('A');
      expect(optionACard, findsOneWidget);

      // 옵션 A 클릭
      await tester.tap(optionACard);
      await tester.pump();

      // 체크 아이콘이 표시되는지 확인
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // 투표하기 버튼이 활성화되었는지 확인
      final submitButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(submitButton.enabled, isTrue);
    });

    testWidgets('옵션 전환 시 이전 선택 해제', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VotePage(postId: 'test_post_id'),
          ),
        ),
      );

      // 옵션 A 선택
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // 옵션 B 선택
      await tester.tap(find.text('B'));
      await tester.pump();

      // 여전히 체크 아이콘은 1개만 있어야 함
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
```

#### 5.2.3 Provider 단위 테스트

```dart
// test/features/voting/presentation/providers/vote_submission_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_space/features/voting/presentation/providers/vote_submission_notifier.dart';

void main() {
  group('VoteSubmission Notifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태: selectedOptionId가 null', () {
      final state = container.read(voteSubmissionProvider);

      expect(state.selectedOptionId, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.error, isNull);
    });

    test('selectOption 호출 시 selectedOptionId 변경', () {
      final notifier = container.read(voteSubmissionProvider.notifier);

      notifier.selectOption('A');
      final state = container.read(voteSubmissionProvider);

      expect(state.selectedOptionId, equals('A'));
    });

    test('reset 호출 시 상태 초기화', () {
      final notifier = container.read(voteSubmissionProvider.notifier);

      // 옵션 선택
      notifier.selectOption('A');
      expect(container.read(voteSubmissionProvider).selectedOptionId, equals('A'));

      // 리셋
      notifier.reset();
      final state = container.read(voteSubmissionProvider);

      expect(state.selectedOptionId, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('submitVote 호출 시 isLoading이 true로 변경', () async {
      final notifier = container.read(voteSubmissionProvider.notifier);

      // 옵션 선택
      notifier.selectOption('A');

      // 투표 제출 (비동기)
      final submitFuture = notifier.submitVote(
        postId: 'test_post_id',
        userId: 'test_user_id',
      );

      // 즉시 로딩 상태 확인
      expect(container.read(voteSubmissionProvider).isLoading, isTrue);

      // 완료 대기
      await submitFuture;
    });
  });
}
```

### 5.3 성능 검증

#### 5.3.1 성능 측정 포인트

**1. Provider 생성 시간 측정**

```dart
// lib/features/voting/presentation/providers/vote_submission_notifier.dart
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() {
    final startTime = DateTime.now();

    ref.onDispose(() {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('[VoteSubmission] Lifecycle duration: ${duration.inMilliseconds}ms');
    });

    return const VoteSubmissionState();
  }
}
```

**2. 상태 업데이트 시간 측정**

```dart
void selectOption(String optionId) {
  final startTime = DateTime.now();

  state = state.copyWith(selectedOptionId: optionId);

  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);
  debugPrint('[VoteSubmission] selectOption duration: ${duration.inMicroseconds}μs');
}
```

**3. Widget 리빌드 횟수 측정**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  debugPrint('[VotePage] Build called');

  final submissionState = ref.watch(voteSubmissionProvider);

  // ...
}
```

#### 5.3.2 성능 목표

- **Provider 생성 시간**: < 10ms
- **상태 업데이트 시간**: < 1ms
- **Widget 리빌드 최소화**: 필요한 경우만 리빌드

### 5.4 마이그레이션 전후 비교

#### 5.4.1 코드 메트릭 비교

| 항목 | Riverpod 2.x (Before) | Riverpod 3.x (After) | 변화 |
|------|------------------------|----------------------|------|
| **Provider 파일 수** | 1 (vote_providers.dart) | 3 (notifier + usecase) | +2 |
| **총 Provider 수** | 4 | 3 | -1 (25% 감소) |
| **코드 줄 수** | ~219 lines | ~300 lines | +80 lines |
| **.g.dart 파일** | 0 | 3 | +3 (코드 생성) |
| **Controller 클래스** | 2 | 0 | -2 (Notifier로 통합) |
| **수동 Provider 정의** | 4 | 0 | -4 (자동 생성) |

#### 5.4.2 기능 비교

| 기능 | Riverpod 2.x | Riverpod 3.x | 개선 사항 |
|------|--------------|--------------|-----------|
| **타입 안전성** | ⚠️ 부분적 | ✅ 완전 | 컴파일 타임 검증 |
| **AutoDispose** | ⚠️ 수동 설정 | ✅ 자동 | 메모리 누수 방지 |
| **코드 생성** | ❌ 없음 | ✅ 자동 | 보일러플레이트 감소 |
| **의존성 주입** | ⚠️ GetIt 직접 사용 | ✅ @riverpod 래핑 | 일관성 향상 |
| **디버깅** | ⚠️ 제한적 | ✅ DevTools 지원 | 개발 생산성 향상 |

### 5.5 Phase 5 완료 체크리스트

- [ ] **정적 분석 통과**
  - [ ] `flutter analyze` 에러 없음
  - [ ] Import 에러 없음
  - [ ] Type 에러 없음

- [ ] **기능 테스트 완료**
  - [ ] 투표 옵션 선택 기능 정상 작동
  - [ ] 투표 제출 기능 정상 작동
  - [ ] 에러 처리 정상 작동
  - [ ] 상태 리셋 정상 작동

- [ ] **자동 테스트 작성**
  - [ ] Widget Test 작성 (선택적)
  - [ ] Provider 단위 테스트 작성 (선택적)
  - [ ] 테스트 통과율 100%

- [ ] **성능 검증**
  - [ ] Provider 생성 시간 < 10ms
  - [ ] 상태 업데이트 시간 < 1ms
  - [ ] 불필요한 리빌드 없음

---

## Phase 6: Legacy Code Cleanup (레거시 코드 정리)

**목표**: Riverpod 2.x 코드 제거 및 정리
**소요 시간**: 0.5-1시간
**난이도**: 중 (★★★☆☆)

### 6.1 삭제 대상 파일

#### 6.1.1 삭제할 파일 목록

```bash
# 1. 기존 Provider 파일 삭제
rm lib/features/voting/presentation/providers/vote_providers.dart

# 2. 백업 파일 삭제 (생성했던 경우)
rm lib/features/voting/presentation/providers/vote_providers.dart.backup
```

#### 6.1.2 파일 삭제 전 확인

```bash
# 1. 해당 파일을 import하는 곳이 있는지 검색
grep -r "import.*vote_providers.dart" lib/

# 예상 출력: (아무것도 없어야 함)

# 2. Provider를 사용하는 곳이 있는지 검색
grep -r "voteSubmissionStateProvider" lib/
grep -r "voteSubmissionControllerProvider" lib/
grep -r "voteUIStateProvider" lib/
grep -r "voteUIStateControllerProvider" lib/

# 예상 출력: (아무것도 없어야 함)
```

### 6.2 코드 정리

#### 6.2.1 불필요한 Import 제거

**Before (Widget에서)**:
```dart
// lib/features/voting/presentation/screens/vote_page.dart
import '/features/voting/presentation/providers/vote_providers.dart'; // ❌ 삭제
import '/features/voting/presentation/providers/vote_submission_notifier.dart'; // ✅ 유지
import '/features/voting/presentation/providers/vote_ui_state_notifier.dart'; // ✅ 유지
```

**After**:
```dart
// lib/features/voting/presentation/screens/vote_page.dart
import '/features/voting/presentation/providers/vote_submission_notifier.dart';
import '/features/voting/presentation/providers/vote_ui_state_notifier.dart';
```

#### 6.2.2 주석 업데이트

**Before**:
```dart
/// Voting Feature - Riverpod 2.x
///
/// **상태 관리**: StateProvider + Provider.family
/// **Controller**: VoteSubmissionController, VoteUIStateController
```

**After**:
```dart
/// Voting Feature - Riverpod 3.x
///
/// **상태 관리**: @riverpod Notifier 패턴
/// **Code Generation**: .g.dart 파일 자동 생성
/// **AutoDispose**: 자동 메모리 관리
```

#### 6.2.3 TODO 주석 제거

```bash
# TODO 주석 검색
grep -r "TODO.*Riverpod 2.x" lib/features/voting/

# 발견된 TODO 주석 제거 또는 업데이트
```

### 6.3 DI Module 정리

#### 6.3.1 GetIt 바인딩 확인

```dart
// lib/features/voting/di/voting_di_module.dart (예상)

import 'package:get_it/get_it.dart';
import '/features/voting/domain/usecases/submit_vote_usecase.dart';
import '/features/voting/data/repositories/vote_repository_impl.dart';

void registerVotingDI(GetIt getIt) {
  // Repository 등록
  getIt.registerLazySingleton<IVoteRepository>(
    () => VoteRepositoryImpl(),
  );

  // UseCase 등록
  getIt.registerLazySingleton<SubmitVoteUseCase>(
    () => SubmitVoteUseCase(getIt()),
  );

  // ❌ 삭제: Controller 등록 (Riverpod 3.x에서 불필요)
  // getIt.registerFactory(() => VoteSubmissionController(getIt()));
  // getIt.registerFactory(() => VoteUIStateController(getIt()));
}
```

**After (Riverpod 3.x)**:
```dart
// lib/features/voting/di/voting_di_module.dart

import 'package:get_it/get_it.dart';
import '/features/voting/domain/usecases/submit_vote_usecase.dart';
import '/features/voting/data/repositories/vote_repository_impl.dart';

void registerVotingDI(GetIt getIt) {
  // Repository 등록
  getIt.registerLazySingleton<IVoteRepository>(
    () => VoteRepositoryImpl(),
  );

  // UseCase 등록
  getIt.registerLazySingleton<SubmitVoteUseCase>(
    () => SubmitVoteUseCase(getIt()),
  );

  // Notifier는 @riverpod Provider로 자동 관리됨
  // GetIt 등록 불필요 ✅
}
```

### 6.4 Git Commit (선택적)

#### 6.4.1 변경 사항 스테이징

```bash
# 1. 변경된 파일 확인
git status

# 예상 출력:
# modified:   lib/features/voting/presentation/providers/vote_submission_notifier.dart
# modified:   lib/features/voting/presentation/providers/vote_ui_state_notifier.dart
# modified:   lib/features/voting/presentation/screens/vote_page.dart
# deleted:    lib/features/voting/presentation/providers/vote_providers.dart
# new file:   lib/features/voting/presentation/providers/vote_submission_notifier.g.dart
# new file:   lib/features/voting/presentation/providers/vote_ui_state_notifier.g.dart
```

#### 6.4.2 커밋 메시지 작성

```bash
git add lib/features/voting/

git commit -m "feat(voting): Complete Riverpod 3.x migration

- Migrated VoteSubmissionController → VoteSubmission Notifier
- Migrated VoteUIStateController → VoteUIState Notifier
- Added @riverpod code generation with .g.dart files
- Removed legacy vote_providers.dart (Riverpod 2.x)
- Updated Widget integration (ConsumerWidget/ConsumerStatefulWidget)
- Improved error handling with AsyncValue.when() pattern

Breaking Changes:
- StateProvider → @riverpod Notifier
- Provider.family → @riverpod with parameters
- Manual providers → Auto-generated providers

Related: RIVERPOD_3X_MIGRATION_PHASE_1_2.md, RIVERPOD_3X_MIGRATION_PHASE_3_7.md"
```

### 6.5 Widget 파일 레거시 코드 정리

#### 6.5.1 Widget 파일 내 주석 처리된 레거시 코드 검색

**목적**: Widget 파일에 남아있는 주석 처리된 Riverpod 2.x 코드 완전 제거

```bash
# 1. 주석 처리된 StateProvider 사용 검색
grep -rn "// *final.*Provider" lib/features/voting/presentation/screens/
grep -rn "// *ref.read.*Provider" lib/features/voting/presentation/widgets/

# 2. 주석 처리된 Controller 사용 검색
grep -rn "// *Controller" lib/features/voting/presentation/

# 3. 주석 처리된 import 검색
grep -rn "// *import.*vote_providers" lib/features/voting/presentation/
```

#### 6.5.2 Widget 파일 레거시 코드 제거 예시

**Before (vote_page.dart)**:
```dart
// lib/features/voting/presentation/screens/vote_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '/features/voting/presentation/providers/vote_providers.dart'; // ❌ 주석 처리된 레거시 import
import '/features/voting/presentation/providers/vote_submission_notifier.dart';

class VotePage extends ConsumerStatefulWidget {
  // ...

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final submissionState = ref.watch(voteSubmissionStateProvider); // ❌ 레거시
    final submissionState = ref.watch(voteSubmissionProvider); // ✅ 새 Provider

    // final controller = ref.read(voteSubmissionControllerProvider); // ❌ 레거시
    // controller.selectOption('A');

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // ❌ 레거시 Controller 방식 (주석)
              // ref.read(voteSubmissionControllerProvider).submitVote();

              // ✅ Riverpod 3.x Notifier 방식
              ref.read(voteSubmissionProvider.notifier).submitVote(
                postId: 'test',
                userId: 'user123',
              );
            },
            child: Text('투표하기'),
          ),
        ],
      ),
    );
  }
}
```

**After (vote_page.dart)** - 주석 제거:
```dart
// lib/features/voting/presentation/screens/vote_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/voting/presentation/providers/vote_submission_notifier.dart';

class VotePage extends ConsumerStatefulWidget {
  // ...

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionState = ref.watch(voteSubmissionProvider);

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              ref.read(voteSubmissionProvider.notifier).submitVote(
                postId: 'test',
                userId: 'user123',
              );
            },
            child: Text('투표하기'),
          ),
        ],
      ),
    );
  }
}
```

#### 6.5.3 사용하지 않는 import 정리

```bash
# 1. 사용하지 않는 import 검색 (flutter analyze 권장)
flutter analyze lib/features/voting/

# 2. dart fix로 자동 정리 (선택적)
dart fix --dry-run lib/features/voting/
dart fix --apply lib/features/voting/

# 3. 수동 확인
grep -rn "^import" lib/features/voting/presentation/ | \
  grep -v "vote_submission_notifier" | \
  grep -v "vote_ui_state_notifier" | \
  grep -v "usecase_providers"
```

#### 6.5.4 Widget 파일 정리 체크리스트

- [ ] 주석 처리된 레거시 import 제거
- [ ] 주석 처리된 StateProvider 사용 코드 제거
- [ ] 주석 처리된 Controller 사용 코드 제거
- [ ] 사용하지 않는 import 제거
- [ ] `flutter analyze` 통과 확인

---

### 6.6 Test 파일 레거시 처리

#### 6.6.1 기존 테스트 파일 식별

**목적**: Riverpod 2.x 기반 테스트 파일 식별 및 처리 방침 결정

```bash
# 1. Voting Feature 테스트 파일 확인
find test/features/voting/ -name "*_test.dart" -type f

# 예상 출력 (있는 경우):
# test/features/voting/presentation/providers/vote_providers_test.dart
# test/features/voting/presentation/screens/vote_page_test.dart

# 2. 레거시 Provider 테스트 검색
grep -rn "voteSubmissionStateProvider" test/features/voting/
grep -rn "voteSubmissionControllerProvider" test/features/voting/
grep -rn "VoteSubmissionController" test/features/voting/
```

#### 6.6.2 테스트 파일 처리 판단 기준

| 조건 | 처리 방침 |
|------|----------|
| **Provider 테스트 파일** (예: `vote_providers_test.dart`) | ❌ 삭제 (새 Notifier 테스트로 대체) |
| **Widget 테스트 파일** (예: `vote_page_test.dart`) | ✅ 업데이트 (ref.watch 패턴 변경) |
| **UseCase 테스트 파일** | ✅ 유지 (변경 불필요) |
| **레거시 Provider 사용** | ❌ 제거 (새 Provider로 변경) |

#### 6.6.3 레거시 테스트 파일 삭제

```bash
# 1. 레거시 Provider 테스트 파일 삭제
rm test/features/voting/presentation/providers/vote_providers_test.dart

# 2. 백업 (선택적)
cp test/features/voting/presentation/providers/vote_providers_test.dart \
   test/features/voting/presentation/providers/vote_providers_test.dart.backup
```

#### 6.6.4 Widget 테스트 업데이트 예시

**Before (Riverpod 2.x 테스트)**:
```dart
// test/features/voting/presentation/screens/vote_page_test.dart
testWidgets('투표 옵션 선택 시 상태 변경', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // ❌ 레거시 Provider override
        voteSubmissionStateProvider.overrideWith(
          (ref) => const VoteSubmissionState(),
        ),
      ],
      child: MaterialApp(
        home: VotePage(postId: 'test'),
      ),
    ),
  );

  // ...
});
```

**After (Riverpod 3.x 테스트)**:
```dart
// test/features/voting/presentation/screens/vote_page_test.dart
testWidgets('투표 옵션 선택 시 상태 변경', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // ✅ Riverpod 3.x Notifier override
        voteSubmissionProvider.overrideWith(
          () => VoteSubmissionTestNotifier(),
        ),
      ],
      child: MaterialApp(
        home: VotePage(postId: 'test'),
      ),
    ),
  );

  // ...
});

// Test용 Notifier
class VoteSubmissionTestNotifier extends VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();
}
```

#### 6.6.5 새로운 테스트 파일 작성 참조

**Phase 5.2.3 Provider 단위 테스트** 참조:
- `test/features/voting/presentation/providers/vote_submission_notifier_test.dart`
- `test/features/voting/presentation/providers/vote_ui_state_notifier_test.dart`

**Phase 5.2.2 Widget 테스트** 참조:
- `test/features/voting/presentation/screens/vote_page_test.dart`

#### 6.6.6 테스트 파일 정리 체크리스트

- [ ] 레거시 Provider 테스트 파일 식별
- [ ] 레거시 테스트 파일 삭제 또는 백업
- [ ] Widget 테스트 파일 업데이트 (Provider override 변경)
- [ ] 새로운 Notifier 테스트 파일 작성 (Phase 5 참조)
- [ ] 모든 테스트 통과 확인 (`flutter test`)

---

### 6.7 레거시 DI 바인딩 완전 제거 검증

#### 6.7.1 모든 레거시 Provider 사용 검색 스크립트

**목적**: 코드베이스 전체에서 레거시 Provider 사용 여부 최종 검증

```bash
#!/bin/bash
# legacy_provider_check.sh - 레거시 Provider 사용 검색 스크립트

echo "=== Voting Feature 레거시 Provider 검색 ==="
echo ""

# 1. StateProvider 사용 검색
echo "[1] StateProvider 사용 검색:"
grep -rn "voteSubmissionStateProvider" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
grep -rn "voteUIStateProvider" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
echo ""

# 2. Controller Provider 사용 검색
echo "[2] Controller Provider 사용 검색:"
grep -rn "voteSubmissionControllerProvider" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
grep -rn "voteUIStateControllerProvider" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
echo ""

# 3. Controller 클래스 사용 검색
echo "[3] Controller 클래스 사용 검색:"
grep -rn "VoteSubmissionController" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
grep -rn "VoteUIStateController" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
echo ""

# 4. 레거시 import 검색
echo "[4] 레거시 import 검색:"
grep -rn "import.*vote_providers.dart" lib/features/voting/ test/features/voting/ || echo "✅ 없음"
echo ""

# 5. vote_providers.dart 파일 존재 여부
echo "[5] vote_providers.dart 파일 존재 여부:"
if [ -f "lib/features/voting/presentation/providers/vote_providers.dart" ]; then
  echo "❌ 파일이 아직 존재합니다!"
else
  echo "✅ 파일이 삭제되었습니다"
fi
echo ""

echo "=== 검색 완료 ==="
```

**실행 방법**:
```bash
# 1. 스크립트 파일 생성
cat > legacy_provider_check.sh << 'EOF'
# 위 스크립트 내용 붙여넣기
EOF

# 2. 실행 권한 부여
chmod +x legacy_provider_check.sh

# 3. 실행
./legacy_provider_check.sh
```

**예상 출력 (정상)**:
```
=== Voting Feature 레거시 Provider 검색 ===

[1] StateProvider 사용 검색:
✅ 없음
✅ 없음

[2] Controller Provider 사용 검색:
✅ 없음
✅ 없음

[3] Controller 클래스 사용 검색:
✅ 없음
✅ 없음

[4] 레거시 import 검색:
✅ 없음

[5] vote_providers.dart 파일 존재 여부:
✅ 파일이 삭제되었습니다

=== 검색 완료 ===
```

#### 6.7.2 GetIt 바인딩 중복 검증

**목적**: DI Module에서 중복 바인딩 또는 불필요한 바인딩 확인

```bash
# 1. GetIt 등록 검색
grep -rn "getIt.register" lib/features/voting/di/

# 2. Controller 등록이 남아있는지 확인
grep -rn "Controller" lib/features/voting/di/

# 3. 예상 출력 (정상):
# lib/features/voting/di/voting_di_module.dart:8:  getIt.registerLazySingleton<IVoteRepository>
# lib/features/voting/di/voting_di_module.dart:12:  getIt.registerLazySingleton<SubmitVoteUseCase>
# (Controller 관련 등록 없어야 함 ✅)
```

#### 6.7.3 DI Module 전체 검증 체크리스트

**검증 항목**:

```dart
// lib/features/voting/di/voting_di_module.dart

void registerVotingDI(GetIt getIt) {
  // ✅ Repository 등록 (필요)
  getIt.registerLazySingleton<IVoteRepository>(
    () => VoteRepositoryImpl(),
  );

  // ✅ UseCase 등록 (필요)
  getIt.registerLazySingleton<SubmitVoteUseCase>(
    () => SubmitVoteUseCase(getIt()),
  );

  // ❌ Controller 등록 (불필요 - 제거되어야 함)
  // getIt.registerFactory(() => VoteSubmissionController(getIt()));
  // getIt.registerFactory(() => VoteUIStateController(getIt()));

  // ❌ Notifier 등록 (불필요 - @riverpod가 자동 관리)
  // getIt.registerFactory(() => VoteSubmission());
  // getIt.registerFactory(() => VoteUIState());
}
```

**검증 체크리스트**:
- [ ] Repository 바인딩만 존재 (✅ 필요)
- [ ] UseCase 바인딩만 존재 (✅ 필요)
- [ ] Controller 바인딩 제거됨 (❌ 불필요)
- [ ] Notifier 바인딩 없음 (❌ 불필요)
- [ ] 중복 바인딩 없음

#### 6.7.4 자동화된 검증 스크립트 (고급)

```bash
#!/bin/bash
# di_validation.sh - DI Module 검증 스크립트

echo "=== DI Module 검증 ==="
echo ""

DI_FILE="lib/features/voting/di/voting_di_module.dart"

if [ ! -f "$DI_FILE" ]; then
  echo "❌ DI Module 파일을 찾을 수 없습니다: $DI_FILE"
  exit 1
fi

# 1. Controller 등록 확인
echo "[1] Controller 등록 확인:"
if grep -q "Controller" "$DI_FILE"; then
  echo "❌ Controller 등록이 발견되었습니다:"
  grep -n "Controller" "$DI_FILE"
else
  echo "✅ Controller 등록 없음"
fi
echo ""

# 2. Notifier 등록 확인
echo "[2] Notifier 등록 확인:"
if grep -q "Notifier" "$DI_FILE"; then
  echo "❌ Notifier 등록이 발견되었습니다:"
  grep -n "Notifier" "$DI_FILE"
else
  echo "✅ Notifier 등록 없음"
fi
echo ""

# 3. Repository 등록 확인
echo "[3] Repository 등록 확인:"
if grep -q "Repository" "$DI_FILE"; then
  echo "✅ Repository 등록 발견:"
  grep -n "Repository" "$DI_FILE"
else
  echo "⚠️ Repository 등록이 없습니다 (필요할 수 있음)"
fi
echo ""

# 4. UseCase 등록 확인
echo "[4] UseCase 등록 확인:"
if grep -q "UseCase" "$DI_FILE"; then
  echo "✅ UseCase 등록 발견:"
  grep -n "UseCase" "$DI_FILE"
else
  echo "⚠️ UseCase 등록이 없습니다 (필요할 수 있음)"
fi
echo ""

echo "=== 검증 완료 ==="
```

#### 6.7.5 DI 바인딩 검증 체크리스트

- [ ] 레거시 Provider 사용 검색 스크립트 실행
- [ ] 모든 레거시 Provider 사용 제거 확인
- [ ] GetIt 바인딩 중복 검증
- [ ] Controller 바인딩 제거 확인
- [ ] Notifier 바인딩 없음 확인
- [ ] DI Module 검증 스크립트 실행 (선택적)

---

### 6.8 Git Commit (선택적)

#### 6.8.1 변경 사항 스테이징

```bash
# 1. 변경된 파일 확인
git status

# 예상 출력:
# modified:   lib/features/voting/presentation/providers/vote_submission_notifier.dart
# modified:   lib/features/voting/presentation/providers/vote_ui_state_notifier.dart
# modified:   lib/features/voting/presentation/screens/vote_page.dart
# deleted:    lib/features/voting/presentation/providers/vote_providers.dart
# deleted:    test/features/voting/presentation/providers/vote_providers_test.dart
# new file:   lib/features/voting/presentation/providers/vote_submission_notifier.g.dart
# new file:   lib/features/voting/presentation/providers/vote_ui_state_notifier.g.dart
# new file:   test/features/voting/presentation/providers/vote_submission_notifier_test.dart
```

#### 6.8.2 커밋 메시지 작성

```bash
git add lib/features/voting/ test/features/voting/

git commit -m "feat(voting): Complete Riverpod 3.x migration with full cleanup

- Migrated VoteSubmissionController → VoteSubmission Notifier
- Migrated VoteUIStateController → VoteUIState Notifier
- Added @riverpod code generation with .g.dart files
- Removed legacy vote_providers.dart (Riverpod 2.x)
- Removed legacy test files (vote_providers_test.dart)
- Updated Widget integration (ConsumerWidget/ConsumerStatefulWidget)
- Cleaned up all commented legacy code in widgets
- Removed legacy DI bindings (Controller registrations)
- Improved error handling with AsyncValue.when() pattern

Breaking Changes:
- StateProvider → @riverpod Notifier
- Provider.family → @riverpod with parameters
- Manual providers → Auto-generated providers
- Controller pattern → Notifier pattern

Files Removed:
- lib/features/voting/presentation/providers/vote_providers.dart
- test/features/voting/presentation/providers/vote_providers_test.dart

Files Added:
- lib/features/voting/presentation/providers/vote_submission_notifier.dart
- lib/features/voting/presentation/providers/vote_submission_notifier.g.dart
- lib/features/voting/presentation/providers/vote_ui_state_notifier.dart
- lib/features/voting/presentation/providers/vote_ui_state_notifier.g.dart
- lib/features/voting/presentation/providers/usecase_providers.dart
- lib/features/voting/presentation/providers/usecase_providers.g.dart
- test/features/voting/presentation/providers/vote_submission_notifier_test.dart

Related: RIVERPOD_3X_MIGRATION_PHASE_1_2.md, RIVERPOD_3X_MIGRATION_PHASE_3_7.md"
```

---

### 6.9 Phase 6 최종 완료 체크리스트

#### 6.9.1 파일 관리

- [ ] **Provider 파일 삭제**
  - [ ] `vote_providers.dart` 삭제
  - [ ] 백업 파일 삭제 (생성했던 경우)

- [ ] **테스트 파일 처리**
  - [ ] 레거시 Provider 테스트 파일 삭제
  - [ ] Widget 테스트 파일 업데이트
  - [ ] 새로운 Notifier 테스트 파일 작성

#### 6.9.2 코드 정리

- [ ] **Import 정리**
  - [ ] 불필요한 import 제거
  - [ ] 모든 Widget에서 새로운 Provider import 사용
  - [ ] `flutter analyze` 통과

- [ ] **주석 업데이트**
  - [ ] Feature 주석 업데이트 (Riverpod 3.x 명시)
  - [ ] TODO 주석 제거 또는 업데이트
  - [ ] 주석 처리된 레거시 코드 제거

#### 6.9.3 Widget 레거시 코드 정리

- [ ] **Widget 파일 검증**
  - [ ] 주석 처리된 레거시 import 제거
  - [ ] 주석 처리된 StateProvider 사용 코드 제거
  - [ ] 주석 처리된 Controller 사용 코드 제거
  - [ ] 사용하지 않는 import 제거

#### 6.9.4 DI Module 정리

- [ ] **GetIt 바인딩 정리**
  - [ ] Controller 등록 코드 제거 (해당 시)
  - [ ] Notifier 등록 없음 확인
  - [ ] Repository/UseCase 바인딩만 유지
  - [ ] 중복 바인딩 제거

#### 6.9.5 레거시 검증

- [ ] **레거시 Provider 사용 검증**
  - [ ] 레거시 Provider 검색 스크립트 실행
  - [ ] 모든 레거시 Provider 사용 제거 확인
  - [ ] DI Module 검증 스크립트 실행 (선택적)
  - [ ] `flutter analyze` 통과
  - [ ] `flutter test` 통과

#### 6.9.6 Git Commit (선택적)

- [ ] **커밋 준비**
  - [ ] 변경 사항 스테이징
  - [ ] 명확한 커밋 메시지 작성
  - [ ] 커밋 완료

---

## Phase 7: Documentation (문서화)

**목표**: 마이그레이션 완료 문서 작성
**소요 시간**: 1-1.5시간
**난이도**: 중 (★★★☆☆)

### 7.1 Feature README 업데이트

#### 7.1.1 README.md 구조

```markdown
# Voting Feature - Riverpod 3.x

**상태 관리**: Riverpod 3.x with @riverpod code generation
**마이그레이션 완료일**: 2025-11-06
**마이그레이션 문서**: [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md), [RIVERPOD_3X_MIGRATION_PHASE_3_7.md](./RIVERPOD_3X_MIGRATION_PHASE_3_7.md)

---

## 📋 목차

- [개요](#개요)
- [아키텍처](#아키텍처)
- [Provider 구조](#provider-구조)
- [사용 예시](#사용-예시)
- [테스트](#테스트)
- [마이그레이션 히스토리](#마이그레이션-히스토리)

---

## 개요

Voting Feature는 사용자의 투표 참여 및 제출을 관리하는 Feature입니다.

**핵심 기능**:
- 투표 옵션 선택
- 투표 제출 및 검증
- 실시간 투표 상태 관리
- 에러 처리 및 재시도

---

## 아키텍처

### Clean Architecture 레이어

```
lib/features/voting/
├── domain/                      # Domain Layer (비즈니스 로직)
│   ├── entities/               # Freezed 불변 엔티티
│   ├── repositories/           # Repository 인터페이스
│   ├── usecases/               # UseCase 비즈니스 로직
│   └── failures/               # Failure 정의
├── data/                       # Data Layer (데이터 접근)
│   ├── repositories/           # Repository 구현체
│   └── extensions/             # Firestore Extension
├── presentation/               # Presentation Layer (UI)
│   ├── providers/              # Riverpod 3.x Providers
│   │   ├── vote_submission_notifier.dart
│   │   ├── vote_submission_notifier.g.dart      ✅
│   │   ├── vote_ui_state_notifier.dart
│   │   ├── vote_ui_state_notifier.g.dart         ✅
│   │   ├── usecase_providers.dart
│   │   └── usecase_providers.g.dart              ✅
│   ├── screens/                # 화면 위젯
│   └── widgets/                # 재사용 위젯
└── di/                         # Dependency Injection
    └── voting_di_module.dart
```

---

## Provider 구조

### 1. VoteSubmission Notifier

**파일**: `lib/features/voting/presentation/providers/vote_submission_notifier.dart`

```dart
@riverpod
class VoteSubmission extends _$VoteSubmission {
  @override
  VoteSubmissionState build() => const VoteSubmissionState();

  void selectOption(String optionId) {
    state = state.copyWith(selectedOptionId: optionId);
  }

  Future<void> submitVote({
    required String postId,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final useCase = ref.read(submitVoteUseCaseProvider);
    final result = await useCase(
      postId: postId,
      userId: userId,
      selectedOptionId: state.selectedOptionId!,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
      },
    );
  }

  void reset() {
    state = const VoteSubmissionState();
  }
}
```

**상태 클래스** (Freezed):
```dart
@freezed
class VoteSubmissionState with _$VoteSubmissionState {
  const factory VoteSubmissionState({
    @Default(null) String? selectedOptionId,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default(null) String? error,
  }) = _VoteSubmissionState;
}
```

### 2. VoteUIState Notifier

**파일**: `lib/features/voting/presentation/providers/vote_ui_state_notifier.dart`

```dart
@riverpod
class VoteUIState extends _$VoteUIState {
  @override
  VoteUIState build(String postId) {
    _loadVoteOptions(postId);
    return const VoteUIState();
  }

  Future<void> _loadVoteOptions(String postId) async {
    state = state.copyWith(isLoading: true, error: null);

    // Load vote options from repository
    // ...

    state = state.copyWith(
      isLoading: false,
      questionTitle: 'Loaded Question Title',
      optionAText: 'Option A Text',
      optionBText: 'Option B Text',
    );
  }

  void loadVoteOptions() {
    _loadVoteOptions(postId);
  }
}
```

### 3. UseCase Providers

**파일**: `lib/features/voting/presentation/providers/usecase_providers.dart`

```dart
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}
```

---

## 사용 예시

### Widget에서 Provider 사용

```dart
class VotePage extends ConsumerStatefulWidget {
  final String postId;
  const VotePage({super.key, required this.postId});

  @override
  ConsumerState<VotePage> createState() => _VotePageState();
}

class _VotePageState extends ConsumerState<VotePage> {
  @override
  void initState() {
    super.initState();

    // 초기화: 상태 리셋
    Future.microtask(() {
      ref.read(voteSubmissionProvider.notifier).reset();
      ref.read(voteUIStateProvider(widget.postId).notifier).loadVoteOptions();
    });

    // 부수 효과 리스너: 에러/성공 처리
    ref.listen<VoteSubmissionState>(
      voteSubmissionProvider,
      (previous, next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!)),
          );
        }

        if (next.isSuccess) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 상태 구독
    final submissionState = ref.watch(voteSubmissionProvider);
    final uiState = ref.watch(voteUIStateProvider(widget.postId));

    return Scaffold(
      body: Column(
        children: [
          // 옵션 A
          OptionCard(
            optionId: 'A',
            isSelected: submissionState.selectedOptionId == 'A',
            onTap: () {
              ref.read(voteSubmissionProvider.notifier).selectOption('A');
            },
          ),

          // 투표하기 버튼
          ElevatedButton(
            onPressed: submissionState.isLoading || submissionState.selectedOptionId == null
                ? null
                : () {
                    ref.read(voteSubmissionProvider.notifier).submitVote(
                      postId: widget.postId,
                      userId: 'currentUserId',
                    );
                  },
            child: Text('투표하기'),
          ),
        ],
      ),
    );
  }
}
```

---

## 테스트

### Provider 단위 테스트

```dart
void main() {
  group('VoteSubmission Notifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태: selectedOptionId가 null', () {
      final state = container.read(voteSubmissionProvider);
      expect(state.selectedOptionId, isNull);
    });

    test('selectOption 호출 시 selectedOptionId 변경', () {
      final notifier = container.read(voteSubmissionProvider.notifier);
      notifier.selectOption('A');

      final state = container.read(voteSubmissionProvider);
      expect(state.selectedOptionId, equals('A'));
    });
  });
}
```

---

## 마이그레이션 히스토리

### 2025-11-06: Riverpod 2.x → 3.x 마이그레이션 완료

**변경 사항**:
- StateProvider → @riverpod Notifier
- Provider.family → @riverpod with parameters
- Manual Controller → Notifier class with integrated logic
- 코드 생성: .g.dart 파일 3개 추가

**참조 문서**:
- [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)
- [RIVERPOD_3X_MIGRATION_PHASE_3_7.md](./RIVERPOD_3X_MIGRATION_PHASE_3_7.md)

**Before (Riverpod 2.x)**:
- 4개 Provider (StateProvider + Provider.family)
- 2개 Controller 클래스 (수동 관리)
- 219 lines of code

**After (Riverpod 3.x)**:
- 3개 Provider (25% 감소)
- 0개 Controller 클래스 (Notifier로 통합)
- 300 lines of code (자동 생성 포함)

---

## 참고 자료

- [Riverpod 3.x 공식 문서](https://riverpod.dev/)
- [Creation Feature README](../creation/README.md) - Riverpod 3.x 참조 구현
- [Voting Feature CLAUDE.md](./CLAUDE.md) - AI 컨텍스트 문서
```

### 7.2 CLAUDE.md 업데이트 (선택적)

```markdown
# Voting Feature - AI Context Document

**Feature**: Voting
**상태 관리**: Riverpod 3.x
**마이그레이션 완료일**: 2025-11-06

---

## 🔍 Feature 개요

Voting Feature는 사용자의 투표 참여 및 제출을 관리합니다.

**핵심 기능**:
- 투표 옵션 선택 (A vs B)
- 투표 제출 및 검증
- 실시간 투표 상태 관리
- 에러 처리 및 재시도

---

## 🏗 아키텍처

### Riverpod 3.x Provider 구조

```
presentation/providers/
├── vote_submission_notifier.dart      # 투표 제출 상태 관리
├── vote_submission_notifier.g.dart    # 자동 생성 (Riverpod)
├── vote_ui_state_notifier.dart        # UI 상태 관리
├── vote_ui_state_notifier.g.dart      # 자동 생성 (Riverpod)
├── usecase_providers.dart              # UseCase 래핑
└── usecase_providers.g.dart            # 자동 생성 (Riverpod)
```

### Provider 종류

1. **VoteSubmission Notifier**
   - 타입: `AutoDisposeNotifier<VoteSubmissionState>`
   - 역할: 투표 옵션 선택, 투표 제출, 상태 리셋
   - 파일: `vote_submission_notifier.dart`

2. **VoteUIState Notifier**
   - 타입: `AutoDisposeNotifierFamily<VoteUIState, String>`
   - 역할: 투표 질문 및 옵션 로딩
   - 파일: `vote_ui_state_notifier.dart`

3. **SubmitVoteUseCase Provider**
   - 타입: `@riverpod` getter function
   - 역할: GetIt UseCase 래핑
   - 파일: `usecase_providers.dart`

---

## 📝 주요 파일

### 1. vote_submission_notifier.dart

**위치**: `lib/features/voting/presentation/providers/vote_submission_notifier.dart`

**역할**: 투표 제출 상태 관리

**주요 메서드**:
- `selectOption(String optionId)`: 옵션 선택
- `submitVote({required String postId, required String userId})`: 투표 제출
- `reset()`: 상태 초기화

**상태 클래스** (Freezed):
```dart
@freezed
class VoteSubmissionState with _$VoteSubmissionState {
  const factory VoteSubmissionState({
    @Default(null) String? selectedOptionId,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default(null) String? error,
  }) = _VoteSubmissionState;
}
```

### 2. vote_ui_state_notifier.dart

**위치**: `lib/features/voting/presentation/providers/vote_ui_state_notifier.dart`

**역할**: 투표 UI 상태 관리 (질문, 옵션)

**주요 메서드**:
- `build(String postId)`: 초기화 및 데이터 로딩
- `loadVoteOptions()`: 투표 옵션 재로딩

**상태 클래스** (Freezed):
```dart
@freezed
class VoteUIState with _$VoteUIState {
  const factory VoteUIState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(null) String? questionTitle,
    @Default(null) String? optionAText,
    @Default(null) String? optionBText,
  }) = _VoteUIState;
}
```

---

## 💡 사용 패턴

### Widget에서 Provider 사용

```dart
// 상태 구독: ref.watch()
final submissionState = ref.watch(voteSubmissionProvider);
final uiState = ref.watch(voteUIStateProvider(postId));

// 이벤트 처리: ref.read()
ref.read(voteSubmissionProvider.notifier).selectOption('A');

// 부수 효과: ref.listen()
ref.listen<VoteSubmissionState>(
  voteSubmissionProvider,
  (previous, next) {
    if (next.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error!)),
      );
    }
  },
);
```

---

## 🧪 테스트

### Provider 단위 테스트

**파일**: `test/features/voting/presentation/providers/vote_submission_notifier_test.dart`

**테스트 케이스**:
1. 초기 상태 검증
2. `selectOption()` 동작 검증
3. `submitVote()` 동작 검증
4. `reset()` 동작 검증

---

## 📚 참조 문서

- [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)
- [RIVERPOD_3X_MIGRATION_PHASE_3_7.md](./RIVERPOD_3X_MIGRATION_PHASE_3_7.md)
- [Creation Feature](../creation/README.md) - Riverpod 3.x 참조 구현

---

## 🔄 마이그레이션 히스토리

### 2025-11-06: Riverpod 2.x → 3.x 완료

**변경 사항**:
- StateProvider → @riverpod Notifier (2개)
- Provider.family → @riverpod with parameters (1개)
- Provider (UseCase) → @riverpod getter (1개)
- 코드 생성: .g.dart 파일 3개 추가

**코드 감소**:
- Provider 수: 4 → 3 (25% 감소)
- Controller 클래스: 2 → 0 (Notifier로 통합)
```

### 7.3 Phase 7 완료 체크리스트

- [ ] **README.md 작성**
  - [ ] Feature 개요 작성
  - [ ] 아키텍처 다이어그램 추가
  - [ ] Provider 구조 설명
  - [ ] 사용 예시 코드 추가
  - [ ] 마이그레이션 히스토리 작성

- [ ] **CLAUDE.md 작성 (선택적)**
  - [ ] AI Context 정보 추가
  - [ ] 주요 파일 설명
  - [ ] 사용 패턴 예시
  - [ ] 참조 문서 링크

- [ ] **마이그레이션 문서 정리**
  - [ ] Phase 1-2 문서 최종 검토
  - [ ] Phase 3-7 문서 최종 검토
  - [ ] 체크리스트 완료 확인

---

## Appendix B: Creation Feature 참조

### B.1 Creation Feature Provider 구조

**Creation Feature**는 Riverpod 3.x 마이그레이션이 완료된 참조 구현입니다.

#### B.1.1 파일 구조

```
lib/features/creation/presentation/providers/
├── create_post_notifier.dart            # 메인 Notifier (807 lines)
├── create_post_notifier.g.dart          # 자동 생성
├── media/                               # 미디어 관련 Notifier
│   ├── media_coordinator_provider.dart
│   ├── media_coordinator_provider.g.dart
│   ├── media_selection_notifier.dart
│   ├── media_selection_notifier.g.dart
│   ├── media_upload_notifier.dart
│   ├── media_upload_notifier.g.dart
│   ├── media_validation_notifier.dart
│   └── media_validation_notifier.g.dart
├── target_audience_notifier.dart
├── target_audience_notifier.g.dart
├── usecase_providers.dart               # UseCase 래핑 (52 lines)
└── usecase_providers.g.dart
```

#### B.1.2 CreatePost Notifier 핵심 패턴

**파일**: `lib/features/creation/presentation/providers/create_post_notifier.dart`

**Line 34-52: Notifier 구조**
```dart
@riverpod
class CreatePost extends _$CreatePost {
  Timer? _debounceTimer;
  final Uuid _uuid = const Uuid();

  @override
  CreatePostState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    _loadDraftAsync();

    return const CreatePostState();
  }

  Future<void> _loadDraftAsync() async {
    // 비동기 초기화 로직
  }
}
```

**Line 140-145: 상태 업데이트 패턴**
```dart
void updateQuestionTitle(String title) {
  state = state.copyWith(questionTitle: title);
  _saveDraftDebounced();
}
```

**Line 275-280: ref.read() 패턴**
```dart
Future<void> saveAsDraft() async {
  final useCase = ref.read(saveDraftUseCaseProvider);
  final result = await useCase(state);

  result.fold(
    (failure) => state = state.copyWith(error: failure.message),
    (success) => state = state.copyWith(isSaved: true),
  );
}
```

#### B.1.3 UseCase Provider 패턴

**파일**: `lib/features/creation/presentation/providers/usecase_providers.dart`

**Line 23-26: GetIt 래핑**
```dart
@riverpod
CreatePostUseCase createPostUseCase(Ref ref) {
  return getIt<CreatePostUseCase>();
}
```

**Line 29-32: Multiple UseCases**
```dart
@riverpod
SaveDraftUseCase saveDraftUseCase(Ref ref) {
  return getIt<SaveDraftUseCase>();
}
```

#### B.1.4 Freezed 상태 클래스

```dart
@freezed
class CreatePostState with _$CreatePostState {
  const factory CreatePostState({
    @Default('') String questionTitle,
    @Default(null) String? optionAText,
    @Default(null) String? optionBText,
    @Default([]) List<String> optionAImages,
    @Default([]) List<String> optionBImages,
    @Default(false) bool isLoading,
    @Default(false) bool isSaved,
    @Default(null) String? error,
  }) = _CreatePostState;

  factory CreatePostState.fromJson(Map<String, dynamic> json) =>
      _$CreatePostStateFromJson(json);
}
```

### B.2 Widget 통합 참조

#### B.2.1 ConsumerStatefulWidget 패턴

**파일**: `lib/features/creation/presentation/screens/create_post/create_post_screen.dart`

**Line 20-40: Widget 구조**
```dart
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  static String routeName = 'createPost';
  static String routePath = '/create-post';

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 초기화
    Future.microtask(() {
      ref.read(createPostProvider.notifier).initializeDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPostProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context, state),
      body: _buildBody(context, state),
    );
  }
}
```

#### B.2.2 ref.listen() 패턴

**파일**: `lib/features/creation/presentation/widgets/create_post/text_input_widget.dart`

**Line 140-155: 부수 효과 처리**
```dart
ref.listen<CreatePostState>(
  createPostProvider,
  (previous, next) {
    if (next.validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.validationError!),
          backgroundColor: VersusColors.error,
        ),
      );
    }

    if (next.isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('임시 저장되었습니다')),
      );
    }
  },
);
```

---

## Appendix C: Voting Feature 현재 구조

### C.1 Riverpod 2.x 구조 (Migration 전)

#### C.1.1 파일 구조

```
lib/features/voting/presentation/providers/
└── vote_providers.dart    # 단일 파일에 모든 Provider 정의 (219 lines)
```

#### C.1.2 VoteSubmissionState 클래스

**Line 23-45**:
```dart
class VoteSubmissionState {
  final String? selectedOptionId;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const VoteSubmissionState({
    this.selectedOptionId,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  VoteSubmissionState copyWith({
    String? selectedOptionId,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return VoteSubmissionState(
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}
```

#### C.1.3 VoteSubmissionController 클래스

**Line 47-123**:
```dart
class VoteSubmissionController {
  final Ref ref;

  VoteSubmissionController(this.ref);

  void selectOption(String optionId) {
    final currentState = ref.read(voteSubmissionStateProvider);
    ref.read(voteSubmissionStateProvider.notifier).state =
        currentState.copyWith(selectedOptionId: optionId);
  }

  Future<void> submitVote({
    required String postId,
    required String userId,
  }) async {
    final currentState = ref.read(voteSubmissionStateProvider);

    if (currentState.selectedOptionId == null) {
      ref.read(voteSubmissionStateProvider.notifier).state =
          currentState.copyWith(error: '옵션을 선택해주세요');
      return;
    }

    ref.read(voteSubmissionStateProvider.notifier).state =
        currentState.copyWith(isLoading: true, error: null);

    // UseCase 호출
    final submitVoteUseCase = ref.read(submitVoteUseCaseProvider);
    final result = await submitVoteUseCase(
      postId: postId,
      userId: userId,
      selectedOptionId: currentState.selectedOptionId!,
    );

    result.fold(
      (failure) {
        ref.read(voteSubmissionStateProvider.notifier).state =
            currentState.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (success) {
        ref.read(voteSubmissionStateProvider.notifier).state =
            currentState.copyWith(
          isLoading: false,
          isSuccess: true,
        );
      },
    );
  }

  void reset() {
    ref.read(voteSubmissionStateProvider.notifier).state =
        const VoteSubmissionState();
  }
}
```

#### C.1.4 Manual Provider 정의

**Line 125-132**:
```dart
// StateProvider for VoteSubmissionState
final voteSubmissionStateProvider =
    StateProvider<VoteSubmissionState>((ref) => const VoteSubmissionState());

// Provider for VoteSubmissionController
final voteSubmissionControllerProvider = Provider<VoteSubmissionController>(
  (ref) => VoteSubmissionController(ref),
);
```

#### C.1.5 VoteUIState 및 Controller

**Line 139-165: VoteUIState**
```dart
class VoteUIState {
  final bool isLoading;
  final String? error;
  final String? questionTitle;
  final String? optionAText;
  final String? optionBText;

  const VoteUIState({
    this.isLoading = false,
    this.error,
    this.questionTitle,
    this.optionAText,
    this.optionBText,
  });

  VoteUIState copyWith({
    bool? isLoading,
    String? error,
    String? questionTitle,
    String? optionAText,
    String? optionBText,
  }) {
    return VoteUIState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      questionTitle: questionTitle ?? this.questionTitle,
      optionAText: optionAText ?? this.optionAText,
      optionBText: optionBText ?? this.optionBText,
    );
  }
}
```

**Line 167-204: VoteUIStateController**
```dart
class VoteUIStateController {
  final Ref ref;
  final String postId;

  VoteUIStateController(this.ref, this.postId);

  Future<void> loadVoteOptions() async {
    ref.read(voteUIStateProvider(postId).notifier).state =
        const VoteUIState(isLoading: true);

    // Load vote options from repository
    // ...

    ref.read(voteUIStateProvider(postId).notifier).state =
        const VoteUIState(
      isLoading: false,
      questionTitle: 'Loaded Question Title',
      optionAText: 'Option A Text',
      optionBText: 'Option B Text',
    );
  }
}
```

**Line 209-218: Manual Provider.family**
```dart
// StateProvider.family for VoteUIState
final voteUIStateProvider =
    StateProvider.family<VoteUIState, String>((ref, postId) {
  return const VoteUIState();
});

// Provider.family for VoteUIStateController
final voteUIStateControllerProvider =
    Provider.family<VoteUIStateController, String>((ref, postId) {
  return VoteUIStateController(ref, postId);
});
```

### C.2 Migration 계획 요약

| 항목 | Before (Riverpod 2.x) | After (Riverpod 3.x) |
|------|------------------------|----------------------|
| **파일 수** | 1 (vote_providers.dart) | 3 (notifier + usecase) |
| **Provider 수** | 4 | 3 (25% 감소) |
| **State 클래스** | Plain Dart class | Freezed class |
| **Controller** | 2 classes | 0 (Notifier 통합) |
| **코드 생성** | 없음 | .g.dart 3개 |
| **AutoDispose** | 수동 설정 | 자동 |

---

## Appendix D: 전체 마이그레이션 체크리스트

### Phase 1-2: 준비 및 Provider Migration

- [ ] **Phase 1.1: Dependencies 확인**
  - [ ] `pubspec.yaml` 검증
  - [ ] `riverpod_generator: ^3.0.0` 설치됨
  - [ ] `build_runner` 설치됨

- [ ] **Phase 1.2: 파일 구조 설계**
  - [ ] `vote_submission_notifier.dart` 생성 계획
  - [ ] `vote_ui_state_notifier.dart` 생성 계획
  - [ ] `usecase_providers.dart` 생성 계획

- [ ] **Phase 1.3: 백업 전략**
  - [ ] Git 브랜치 생성 (예: `feature/voting-riverpod-3x`)
  - [ ] `vote_providers.dart` 백업 (선택적)

- [ ] **Phase 2.1: StateProvider → Notifier**
  - [ ] `VoteSubmissionState` Freezed 변환
  - [ ] `VoteSubmission` Notifier 클래스 생성
  - [ ] `@riverpod` 어노테이션 추가
  - [ ] `build()` 메서드 구현

- [ ] **Phase 2.2: Provider (UseCase) → @riverpod getter**
  - [ ] `submitVoteUseCaseProvider` 생성
  - [ ] GetIt 래핑 구현

- [ ] **Phase 2.3: Provider.family (Controller) → Notifier**
  - [ ] `VoteUIState` Freezed 변환
  - [ ] `VoteUIState` Notifier 클래스 생성
  - [ ] `build(String postId)` 메서드 구현

- [ ] **Phase 2.4: Code Generation**
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
  - [ ] `.g.dart` 파일 3개 생성 확인
  - [ ] `flutter analyze` 통과

### Phase 3-7: 실행 및 검증

- [ ] **Phase 3: Widget Integration**
  - [ ] `VotePage` → `ConsumerStatefulWidget` 변환
  - [ ] `VoteOptionCard` → `ConsumerWidget` 변환
  - [ ] `ref.watch()` 패턴 적용
  - [ ] `ref.read()` 패턴 적용
  - [ ] `ref.listen()` 부수 효과 처리

- [ ] **Phase 4: Code Generation**
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
  - [ ] 빌드 에러 해결
  - [ ] `.g.dart` 파일 검증

- [ ] **Phase 5: Testing & Verification**
  - [ ] 정적 분석 통과 (`flutter analyze`)
  - [ ] 수동 테스트 시나리오 4개 완료
  - [ ] 자동 테스트 작성 (선택적)
  - [ ] 성능 검증

- [ ] **Phase 6: Legacy Code Cleanup**
  - [ ] **6.1 파일 관리**
    - [ ] `vote_providers.dart` 삭제
    - [ ] 테스트 파일 처리 (삭제 또는 업데이트)
  - [ ] **6.2 Import 정리**
    - [ ] 불필요한 import 제거
    - [ ] `dart fix --apply` 실행
  - [ ] **6.3 주석 업데이트**
    - [ ] Phase별 작업 주석 정리
    - [ ] TODO 주석 제거
  - [ ] **6.4 DI Module 정리**
    - [ ] Controller 등록 코드 제거
    - [ ] Notifier 등록 없음 확인
  - [ ] **6.5 Widget 파일 레거시 코드 정리**
    - [ ] 주석 처리된 레거시 import 제거
    - [ ] 주석 처리된 StateProvider 사용 코드 제거
    - [ ] 주석 처리된 Controller 사용 코드 제거
  - [ ] **6.6 Test 파일 레거시 처리**
    - [ ] 레거시 테스트 파일 식별 및 삭제
    - [ ] Widget 테스트에서 Provider override 업데이트
  - [ ] **6.7 레거시 DI 바인딩 완전 제거 검증**
    - [ ] `legacy_provider_check.sh` 스크립트 실행
    - [ ] `di_validation.sh` 스크립트 실행
    - [ ] GetIt 바인딩 검증 명령어 실행
  - [ ] **6.8 Git Commit**
    - [ ] 변경 사항 스테이징
    - [ ] 명확한 커밋 메시지 작성
  - [ ] **6.9 Phase 6 최종 완료 확인**
    - [ ] 파일 관리 체크리스트 완료 (6.9.1)
    - [ ] 코드 정리 체크리스트 완료 (6.9.2)
    - [ ] Widget 레거시 코드 정리 완료 (6.9.3)
    - [ ] DI Module 정리 완료 (6.9.4)
    - [ ] 레거시 검증 스크립트 통과 (6.9.5)
    - [ ] Git 커밋 완료 (6.9.6)

- [ ] **Phase 7: Documentation**
  - [ ] `README.md` 작성
  - [ ] `CLAUDE.md` 업데이트 (선택적)
  - [ ] 마이그레이션 문서 최종 검토

### 전체 완료 확인

- [ ] **기능 정상 작동**
  - [ ] 투표 옵션 선택 기능
  - [ ] 투표 제출 기능
  - [ ] 에러 처리
  - [ ] 상태 리셋

- [ ] **코드 품질**
  - [ ] `flutter analyze` 에러 없음
  - [ ] 불필요한 주석 제거
  - [ ] 일관된 코드 스타일

- [ ] **문서화**
  - [ ] README.md 완성
  - [ ] CLAUDE.md 완성 (선택적)
  - [ ] 마이그레이션 문서 완성

---

## 🎉 마이그레이션 완료!

**축하합니다!** Voting Feature의 Riverpod 3.x 마이그레이션이 완료되었습니다.

### 다음 단계

1. **다른 Feature 마이그레이션**: Auth, Profile, Chat Feature 순서로 진행
2. **성능 모니터링**: Riverpod DevTools로 Provider 상태 추적
3. **지속적 개선**: 새로운 Riverpod 3.x 패턴 적용 및 개선

### 참고 자료

- **Riverpod 공식 문서**: https://riverpod.dev/
- **Creation Feature**: `lib/features/creation/README.md` - Riverpod 3.x 참조 구현
- **Post Feature**: `lib/features/post/README.md` - Riverpod 2.x 참조 구현

---

**문서 작성**: 2025-11-06
**마이그레이션 소요 시간**: 총 6-9시간 (Phase 1-7)
**다음 문서**: Feature README.md, CLAUDE.md 작성
