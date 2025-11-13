# Voting Feature - 통합 문서

> **최종 업데이트**: 2025-01-30
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0
> **캐싱**: UnifiedCacheService 3-Layer (Memory → Hive → Firestore)
> **상태 관리**: Riverpod 2.x

## 📋 목차

- [전체 디렉토리 구조](#-전체-디렉토리-구조)
- [아키텍처 개요](#-아키텍처-개요)
- [BOUNDARIES - Clean Architecture 3-Layer 경계](#️-boundaries---clean-architecture-3-layer-경계)
- [빠른 참조 가이드](#-빠른-참조-가이드)
- [레이어별 README 안내](#-레이어별-readme-안내)
- [주요 파일 위치](#-주요-파일-위치)

---

## 🗂 전체 디렉토리 구조

```
lib/features/voting/
├── 📂 data/                              # Data Layer (Firebase-Centric v2.0)
│   ├── 📂 repositories/                  # Repository 구현체
│   │   ├── voting_dialog_repository_impl.dart
│   │   └── voting_chat_repository_impl.dart
│   ├── 📂 datasources/
│   │   └── 📂 local/
│   │       ├── 📂 services/              # 독립 서비스
│   │       │   └── pending_operations_service.dart  # 오프라인 큐 관리
│   │       └── 📂 utils/
│   │           └── cache_keys.dart       # 캐시 키 상수
│   ├── 📂 extensions/                    # Firestore 에러 변환 (1개)
│   │   └── firestore_error_extensions.dart  # FirebaseException → VotingFailure
│   │
│   │   # ⚠️ NOTE: Entity 변환 Extension 5개는 Domain Layer로 이동
│   │   # - vote_extensions.dart → domain/entities/dialog/
│   │   # - vote_state_extensions.dart → domain/entities/chat/
│   │   # - post_voting_extensions.dart → domain/entities/chat/
│   │   # - vote_expansion_request_extensions.dart → domain/entities/dialog/
│   │   # - weight_extensions.dart → domain/entities/dialog/
│   ├── 📂 adapters/                      # Legacy 호환성 (2개)
│   │   ├── votecounts_adapter.dart
│   │   └── box_calculator_adapter.dart
│   ├── 📂 services/
│   │   └── vote_timer_service.dart       # 투표 타이머 구현
│   └── 📄 README.md                      # Data Layer 상세 문서 (2089줄)
│
├── 📂 domain/                             # Domain Layer (Clean Architecture v4.0)
│   ├── 📂 constants/
│   │   └── voting_constants.dart         # 전역 상수 (141줄)
│   ├── 📂 entities/
│   │   ├── 📂 chat/                      # 채팅 투표 카드용 (6개)
│   │   │   ├── post_voting.dart
│   │   │   ├── post_voting.freezed.dart
│   │   │   ├── post_voting.g.dart
│   │   │   ├── vote_state.dart
│   │   │   ├── vote_state.freezed.dart
│   │   │   └── vote_state.g.dart
│   │   └── 📂 dialog/                    # 투표 다이얼로그용 (21개)
│   │       ├── vote.dart
│   │       ├── vote.freezed.dart
│   │       ├── vote.g.dart
│   │       ├── vote_options.dart
│   │       ├── vote_options.freezed.dart
│   │       ├── vote_options.g.dart
│   │       ├── vote_counts_model.dart
│   │       ├── vote_counts_model.freezed.dart
│   │       ├── vote_counts_model.g.dart
│   │       ├── vote_cache_state.dart
│   │       ├── vote_cache_state.freezed.dart
│   │       ├── vote_cache_state.g.dart
│   │       ├── vote_expansion_request.dart
│   │       ├── vote_expansion_request.freezed.dart
│   │       ├── vote_expansion_request.g.dart
│   │       ├── versus_box_size_data.dart
│   │       ├── versus_box_size_data.freezed.dart
│   │       ├── versus_box_size_data.g.dart
│   │       ├── weight.dart
│   │       ├── weight.freezed.dart
│   │       └── weight.g.dart
│   ├── 📂 failures/
│   │   └── voting_failure.dart           # 18개 실패 타입 정의 (129줄)
│   ├── 📂 repositories/                  # Repository 인터페이스
│   │   ├── i_voting_dialog_repository.dart  # 25+ 메서드 (242줄)
│   │   └── i_voting_chat_repository.dart
│   ├── 📂 services/                      # 서비스 인터페이스
│   │   ├── i_vote_timer_service.dart
│   │   └── i_box_calculator_service.dart
│   ├── 📂 usecases/                      # UseCase (비즈니스 로직)
│   │   ├── submit_vote_use_case.dart     # 투표 제출 (60줄)
│   │   └── watch_vote_state_use_case.dart
│   └── 📄 README.md                      # Domain Layer 상세 문서 (1775줄)
│
├── 📂 presentation/                       # Presentation Layer (Clean Architecture v4.0)
│   ├── 📂 providers/                     # Riverpod 상태 관리 (2개)
│   │   ├── vote_providers.dart           # 투표 액션 Provider (210줄)
│   │   └── vote_state_providers.dart     # 상태 StreamProvider (140줄)
│   ├── 📂 chat_vote_card/               # 채팅 투표 카드 (12개)
│   │   ├── 📂 common/
│   │   │   └── simple_avatar.dart
│   │   └── 📂 vote_card/
│   │       ├── vote_card_widget.dart     # 메인 위젯 (279줄)
│   │       ├── base_vote_message.dart    # 기본 메시지 믹스인
│   │       ├── vote_timer_widget.dart
│   │       ├── vote_status_badge.dart
│   │       ├── vote_results_widget.dart
│   │       ├── vote_options_widget.dart
│   │       ├── 📂 components/            # 하위 컴포넌트 (4개)
│   │       │   ├── vote_card_profile_header.dart  # 프로필 헤더 (183줄)
│   │       │   ├── vote_card_header.dart          # 상태 헤더 (57줄)
│   │       │   ├── vote_card_body.dart            # 본문 (129줄)
│   │       │   └── vote_card_footer.dart          # 액션 버튼 (76줄)
│   │       ├── 📂 models/
│   │       │   └── vote_card_props.dart
│   │       └── 📂 utils/
│   │           └── vote_card_helpers.dart
│   ├── 📂 dialogs/                      # 투표 다이얼로그 (25개)
│   │   ├── voting_dialog.dart           # 메인 다이얼로그 (410줄)
│   │   ├── voting_dialog_constraints.dart
│   │   ├── voting_box.dart              # A/B 박스 위젯 (463줄)
│   │   ├── voting_image_viewer.dart     # 이미지 뷰어 (394줄)
│   │   ├── vote_ui_manager.dart
│   │   ├── 📂 voting_dialog/
│   │   │   ├── 📂 components/           # 다이얼로그 컴포넌트 (5개)
│   │   │   │   ├── voting_dialog_header.dart
│   │   │   │   ├── voting_dialog_timer.dart
│   │   │   │   ├── voting_dialog_content.dart
│   │   │   │   └── voting_dialog_actions.dart
│   │   │   ├── 📂 models/
│   │   │   │   └── voting_dialog_state.dart
│   │   │   ├── 📂 utils/
│   │   │   │   └── voting_dialog_helpers.dart
│   │   │   └── 📂 animations/
│   │   │       └── voting_dialog_animations.dart
│   │   ├── 📂 voting_box/
│   │   │   ├── 📂 components/           # 박스 컴포넌트 (4개)
│   │   │   │   ├── voting_box_header.dart
│   │   │   │   ├── voting_box_content.dart
│   │   │   │   ├── voting_box_overlay.dart
│   │   │   │   └── voting_box_animations.dart
│   │   │   ├── 📂 models/
│   │   │   │   └── voting_box_state.dart
│   │   │   └── 📂 utils/
│   │   │       └── voting_box_helpers.dart
│   │   └── 📂 image_viewer/
│   │       ├── 📂 components/           # 뷰어 컴포넌트 (5개)
│   │       │   ├── image_viewer_app_bar.dart
│   │       │   ├── image_viewer_controls.dart
│   │       │   ├── image_viewer_page_view.dart
│   │       │   ├── image_viewer_indicators.dart
│   │       │   └── image_viewer_text_sections.dart
│   │       └── 📂 utils/
│   │           └── image_viewer_helpers.dart
│   └── 📄 README.md                     # Presentation Layer 상세 문서 (~2000줄)
│
├── 📂 di/
│   └── voting_di_module.dart            # Dependency Injection 모듈
│
└── 📄 README.md                         # 👈 이 문서 (통합 가이드)
```

**총 파일 수**: 약 87개 (생성된 Freezed 파일 포함)
- Data Layer: 8개 (11개 파일 삭제: 7개 레거시 캐시 + 4개 Extension 이동)
- Domain Layer: 39개 (21개 주요 + 18개 생성) - Extension 5개 Data에서 이동
- Presentation Layer: 39개
- DI: 1개
- 문서: 4개

**아키텍처 변화**: Extension 파일 5개가 Data → Domain으로 이동하여
Entity 중심 설계 완성 (Firebase-Centric v2.0 진화)

---

## 🏗 아키텍처 개요

### 3-Layer Clean Architecture 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  • Riverpod 2.x 상태 관리                                     │
│  • StreamProvider.family (PostID별 독립 상태)                │
│  • Component-Driven Architecture (SRP)                       │
│  • 39개 파일 (~4,500줄)                                       │
└──────────────────┬──────────────────────────────────────────┘
                   │ Provider 의존성 (ref.watch)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • Pure Dart (프레임워크 독립)                                 │
│  • Freezed 불변 엔티티                                         │
│  • Either<Failure, Success> 패턴                             │
│  • Repository 인터페이스 (25+ 메서드)                          │
│  • UseCase 패턴 (단일 책임)                                    │
│  • 35개 파일 (1,775줄)                                         │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository 인터페이스 의존성
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • Firebase-Centric Architecture v2.0                        │
│  • Direct Firebase SDK 사용                                   │
│  • Extension Pattern (Mapper 대체)                           │
│  • Sharded Counter (256 shards)                             │
│  • Idempotency Service (UUID 기반)                           │
│  • UnifiedCacheService (3-Layer 캐싱)                        │
│    - L1 Memory: <1ms (SimpleMemoryCache)                    │
│    - L2 Hive: 10-30ms (영구 저장)                            │
│    - L3 Firestore: 50-500ms (오프라인 지원)                  │
│  • 12개 파일 (~1,400줄)                                       │
└─────────────────────────────────────────────────────────────┘
                   │
                   ▼
              Firebase Services
        (Firestore, Functions, Auth)
```

### 핵심 디자인 패턴

| 패턴 | 레이어 | 목적 | 예시 파일 |
|------|--------|------|-----------|
| **Extension Pattern** | Data | Firestore 직렬화 (Mapper 대체) | `vote_extensions.dart` |
| **Repository Pattern** | Domain/Data | 데이터 소스 추상화 | `i_voting_dialog_repository.dart` |
| **UseCase Pattern** | Domain | 비즈니스 로직 캡슐화 | `submit_vote_use_case.dart` |
| **Freezed Pattern** | Domain | 불변 엔티티 + 코드 생성 | `vote.dart`, `*.freezed.dart` |
| **Either Pattern** | Domain | 타입 안전 에러 처리 | `Either<VotingFailure, Vote>` |
| **StreamProvider.family** | Presentation | PostID별 독립 상태 관리 | `vote_state_providers.dart` |
| **Component-Driven** | Presentation | UI 컴포넌트 분리 (SRP) | `vote_card/components/` |
| **Sharded Counter** | Data | 분산 카운팅 (256 shards) | `ShardUtils` (공유) |
| **Idempotency** | Data | 중복 방지 (UUID 기반) | `IdempotencyService` (공유) |

---

## 🏛️ BOUNDARIES - Clean Architecture 3-Layer 경계

Voting Feature는 **Clean Architecture v4.0**의 3-Layer 구조를 따르며, 각 Layer 간 의존성 방향을 엄격히 준수합니다.

### 3-Layer 의존성 규칙

```
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                         │
│  • 의존: Domain Layer (UseCase, Entity, Repository          │
│          Interface)                                          │
│  • 금지: Data Layer, 다른 Feature Presentation               │
│  • 패턴: Riverpod Provider, ConsumerWidget, AsyncValue      │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 의존
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • 의존: 없음 (Pure Dart)                                    │
│  • 금지: Presentation, Data, Flutter SDK, Firebase           │
│  • 패턴: UseCase, Entity (Freezed), Repository Interface    │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 구현
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • 의존: Domain Layer (Entity, Repository Interface)         │
│  • 금지: Presentation Layer                                   │
│  • 패턴: Repository 구현, Extension (fromFirestore,          │
│          toFirestore), Firebase SDK 직접 사용                │
└─────────────────────────────────────────────────────────────┘
```

### 실전 예시

#### 1. ✅ Presentation → Domain (올바른 사용)

```dart
// presentation/providers/vote_state_providers.dart
@riverpod
Stream<Vote?> voteState(VoteStateRef ref, String postId) {
  final useCase = getIt<GetVoteStateUseCase>();

  return useCase.execute(postId: postId).map(
    (either) => either.getOrElse((l) => null),
  );
}

@riverpod
FutureOr<void> submitVote(
  SubmitVoteRef ref,
  String postId,
  VoteOption option,
) async {
  final useCase = getIt<SubmitVoteUseCase>();
  final currentUserId = ref.watch(currentUserIdProvider);

  final result = await useCase.execute(
    postId: postId,
    userId: currentUserId,
    voteOption: option,
  );

  return result.fold(
    (failure) => throw Exception(failure.getUserMessage()),
    (_) => null,
  );
}
```

#### 2. ✅ Domain → 독립성 (올바른 사용)

```dart
// domain/usecases/get_vote_state_usecase.dart
class GetVoteStateUseCase {
  final IVotingRepository _repository;

  GetVoteStateUseCase(this._repository);

  Stream<Either<VotingFailure, Vote?>> execute({
    required String postId,
  }) {
    return _repository.watchVoteState(postId);
  }
}

// domain/usecases/submit_vote_usecase.dart
class SubmitVoteUseCase {
  final IVotingRepository _repository;

  SubmitVoteUseCase(this._repository);

  Future<Either<VotingFailure, void>> execute({
    required String postId,
    required String userId,
    required VoteOption voteOption,
  }) {
    return _repository.submitVote(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
    );
  }
}

// domain/entities/vote.dart (Freezed)
@freezed
class Vote with _$Vote {
  const factory Vote({
    required String postId,
    required int optionACount,
    required int optionBCount,
    required List<String> voters,
    required DateTime? endTime,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) =>
      _$VoteFromJson(json);
}
```

#### 3. ✅ Data → Domain (올바른 사용)

```dart
// data/repositories/voting_repository_impl.dart
class VotingRepositoryImpl implements IVotingRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService;

  @override
  Stream<Either<VotingFailure, Vote?>> watchVoteState(String postId) {
    try {
      // ✅ Data Layer는 Firestore Stream 직접 사용 허용
      return _firestore
          .collection('votes')
          .doc(postId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return right<VotingFailure, Vote?>(null);
        }

        final vote = Vote.fromFirestore(snapshot);
        return right<VotingFailure, Vote?>(vote);
      });
    } catch (e) {
      return Stream.value(left(VotingFailure.serverError(e.toString())));
    }
  }

  @override
  Future<Either<VotingFailure, void>> submitVote({
    required String postId,
    required String userId,
    required VoteOption voteOption,
  }) async {
    try {
      // ✅ Data Layer는 Firestore Transaction 직접 사용 허용
      await _firestore.runTransaction((transaction) async {
        final voteRef = _firestore.collection('votes').doc(postId);
        final voteDoc = await transaction.get(voteRef);

        if (!voteDoc.exists) {
          throw VotingFailure.notFound();
        }

        final vote = Vote.fromFirestore(voteDoc);

        // 이미 투표했는지 확인
        if (vote.voters.contains(userId)) {
          throw VotingFailure.alreadyVoted();
        }

        // 투표 집계 업데이트
        final updatedVote = vote.copyWith(
          optionACount: voteOption == VoteOption.optionA
              ? vote.optionACount + 1
              : vote.optionACount,
          optionBCount: voteOption == VoteOption.optionB
              ? vote.optionBCount + 1
              : vote.optionBCount,
          voters: [...vote.voters, userId],
        );

        transaction.update(voteRef, updatedVote.toFirestore());
      });

      return right(null);
    } catch (e) {
      return left(VotingFailure.serverError(e.toString()));
    }
  }
}
```

#### 4. ❌ 잘못된 사용 패턴

```dart
// ❌ Presentation Layer에서 Firestore 직접 접근
@riverpod
Stream<Vote?> voteState(VoteStateRef ref, String postId) {
  return FirebaseFirestore.instance
      .collection('votes')
      .doc(postId)
      .snapshots()
      .map((snapshot) => Vote.fromFirestore(snapshot));
}

// ❌ Domain Layer에서 Firebase 의존성
class SubmitVoteUseCase {
  Future<void> execute(String postId, String userId) async {
    await FirebaseFirestore.instance
        .collection('votes')
        .doc(postId)
        .update({'voters': FieldValue.arrayUnion([userId])});
  }
}
```

### Boundary 검증

#### 자동 검증 (Lint)

```bash
# Presentation → Data 위반 검사
grep -r "import.*voting.*data" lib/features/voting/presentation/

# Domain → Firebase 의존성 검사
grep -r "import.*firebase" lib/features/voting/domain/

# 기대 결과: 발견되지 않아야 함
```

#### 수동 검증 체크리스트

- [ ] Presentation Layer는 UseCase만 호출하는가?
- [ ] Domain Layer는 Pure Dart만 사용하는가? (Firebase/Flutter SDK 없음)
- [ ] Data Layer는 Repository Interface를 구현하는가?
- [ ] GetIt으로 UseCase/Repository를 DI하는가?
- [ ] Either 패턴으로 에러를 반환하는가?
- [ ] Firestore Transaction으로 원자성을 보장하는가?

### 참고 문서

- **전체 프로젝트 Boundaries**: `/CLAUDE.md` - "## 🏛 BOUNDARIES" 섹션
- **App Layer Boundaries**: `/lib/app/README.md` - "### 🏛️ BOUNDARIES" 섹션
- **Voting Domain Layer**: `domain/README.md` - UseCase, Entity, Failure
- **Voting Data Layer**: `data/README.md` - Repository 구현, Extension
- **Voting Presentation Layer**: `presentation/README.md` - Provider, Widget

---

## 🎯 빠른 참조 가이드

### 찾고자 하는 것 → 참조할 README 섹션

| 무엇을 찾을 때 | 어느 README | 어느 섹션 | 파일 위치 |
|---------------|-------------|-----------|-----------|
| **투표 제출 로직** | `domain/README.md` | UseCase 섹션 | `domain/usecases/submit_vote_use_case.dart` |
| **투표 상태 실시간 추적** | `domain/README.md` | UseCase 섹션 | `domain/usecases/watch_vote_state_use_case.dart` |
| **Firestore 데이터 변환** | `data/README.md` | Extension Pattern 섹션 | `data/extensions/vote_extensions.dart` |
| **Firebase 저장 로직** | `data/README.md` | Repository 구현 섹션 | `data/repositories/voting_dialog_repository_impl.dart` |
| **3-Layer 캐싱** | `data/README.md` | UnifiedCacheService 섹션 | `/lib/services/cache/unified_cache_service.dart` |
| **투표 타이머 구현** | `data/README.md` | 서버 동기화 섹션 | `data/services/vote_timer_service.dart` |
| **에러 타입 정의** | `domain/README.md` | Failure 섹션 | `domain/failures/voting_failure.dart` |
| **엔티티 구조** | `domain/README.md` | Entity 섹션 | `domain/entities/dialog/vote.dart` |
| **UI 컴포넌트** | `presentation/README.md` | Component 섹션 | `presentation/chat_vote_card/vote_card/` |
| **Riverpod Provider** | `presentation/README.md` | Provider 섹션 | `presentation/providers/vote_state_providers.dart` |
| **투표 다이얼로그** | `presentation/README.md` | Dialog 섹션 | `presentation/dialogs/voting_dialog.dart` |
| **DI 설정** | `di/voting_di_module.dart` | - | `di/voting_di_module.dart` |

---

## 🧭 Router 통합 (Navigation)

### Voting Feature의 특별한 Navigation 전략

Voting Feature는 **전용 Routes를 가지지 않습니다**. 다른 Feature들과 달리, Voting은 2가지 UI 패턴으로 다른 Feature들에 임베디드되어 동작합니다:

1. **투표 다이얼로그** (`VotingDialog`): 오버레이 방식으로 표시
2. **채팅 투표 카드** (`VoteCardWidget`): Chat Feature 메시지에 임베디드

### 1. 투표 다이얼로그 (VotingDialog)

**사용 위치**: Post Feature에서 투표 버튼 클릭 시

**표시 방식**: `showDialog()` (Flutter 기본 다이얼로그)

**파일**: `lib/features/voting/presentation/dialogs/voting_dialog.dart` (410줄)

**구조**:
```dart
// Post Feature에서 호출
void _showVotingDialog(BuildContext context, Vote vote) {
  showDialog(
    context: context,
    barrierDismissible: false,  // 뒤로가기 방지 (투표 진행 중)
    builder: (context) => VotingDialog(
      vote: vote,
      onVoteSubmitted: (option) {
        // 투표 제출 처리
      },
    ),
  );
}
```

**특징**:
- **오버레이 UI**: 전체 화면을 덮는 다이얼로그
- **No Route Required**: GoRouter 라우트 불필요
- **Stateful Widget**: 내부 상태 관리 (VotingDialogState)
- **25개 컴포넌트**: Header, Timer, Content, Actions 등 분리

### 2. 채팅 투표 카드 (VoteCardWidget)

**사용 위치**: Chat Feature 메시지 목록

**표시 방식**: `flutter_chat_ui` 커스텀 메시지 타입

**파일**: `lib/features/voting/presentation/chat_vote_card/vote_card/vote_card_widget.dart` (279줄)

**구조**:
```dart
// Chat Feature에서 메시지 렌더링 시
Widget _buildChatMessage(types.Message message) {
  if (message is VoteMessage) {
    return VoteCardWidget(
      postVoting: message.postVoting,  // PostVoting 엔티티
      onVotePressed: (option) {
        // 투표 제출 → VotingDialog 표시
      },
    );
  }
  return TextMessageWidget(message: message);
}
```

**특징**:
- **임베디드 위젯**: Chat 메시지 스트림의 일부
- **No Route Required**: 독립 페이지 아님
- **Riverpod StreamProvider**: 실시간 투표 상태 동기화
- **12개 컴포넌트**: Profile Header, Body, Footer 등 분리

### 왜 Routes가 없나요?

**설계 의도**:
1. **Context-Aware**: 투표는 항상 특정 Post나 Chat 컨텍스트 안에서 발생
2. **UX 최적화**: 다이얼로그/임베디드 위젯이 더 자연스러운 투표 경험 제공
3. **State Management**: 부모 Feature의 상태와 긴밀하게 연결
4. **Code Reusability**: 다이얼로그는 Post/Chat 모두에서 재사용 가능

### Post Feature와의 관계

**Post Feature가 Voting Dialog를 호출하는 방법**:

```dart
// lib/features/post/presentation/screens/detail/post_detail_page.dart
ElevatedButton(
  onPressed: () {
    // 1. Vote 엔티티 준비 (Post Feature가 관리)
    final vote = Vote.fromPost(postData);

    // 2. VotingDialog 표시 (Voting Feature 컴포넌트)
    showDialog(
      context: context,
      builder: (context) => VotingDialog(
        vote: vote,
        onVoteSubmitted: (option) async {
          // 3. 투표 제출 (Voting Feature Provider 사용)
          final provider = ref.read(voteProvidersProvider);
          await provider.submitVote(
            voteId: vote.voteId,
            option: option,
          );

          // 4. Post 상태 갱신 (Post Feature가 관리)
          ref.invalidate(postDetailProvider(postId));
        },
      ),
    );
  },
  child: Text('투표하기'),
)
```

### Chat Feature와의 관계

**Chat Feature가 Vote Card를 표시하는 방법**:

```dart
// lib/features/chat/presentation/screens/chat_detail_widget_clean.dart
Chat(
  messages: messages,
  customMessageBuilder: (types.Message message, {required int messageWidth}) {
    if (message.metadata?['type'] == 'vote') {
      // 1. PostVoting 엔티티 파싱 (Chat Feature가 관리)
      final postVoting = PostVoting.fromJson(message.metadata!['data']);

      // 2. VoteCardWidget 표시 (Voting Feature 컴포넌트)
      return VoteCardWidget(
        postVoting: postVoting,
        onVotePressed: (option) {
          // 3. VotingDialog 표시
          showDialog(
            context: context,
            builder: (context) => VotingDialog(
              vote: Vote.fromPostVoting(postVoting),
              onVoteSubmitted: (option) async {
                // 4. 투표 제출 (Voting Feature Provider)
                final provider = ref.read(voteProvidersProvider);
                await provider.submitVote(
                  voteId: postVoting.voteId,
                  option: option,
                );
              },
            ),
          );
        },
      );
    }
    return null;  // 다른 메시지 타입은 기본 렌더링
  },
)
```

### Provider 사용법

Voting Feature는 독립적인 Routes는 없지만, **Riverpod Provider는 제공**합니다:

**1. 투표 제출 Provider** (`vote_providers.dart`):
```dart
@riverpod
class VoteProviders extends _$VoteProviders {
  Future<void> submitVote({
    required String voteId,
    required VoteOption option,
  }) async {
    final useCase = GetIt.instance<SubmitVoteUseCase>();
    final result = await useCase(voteId: voteId, option: option);

    result.fold(
      (failure) => throw Exception(failure.getUserMessage()),
      (_) => print('투표 성공'),
    );
  }
}
```

**2. 투표 상태 StreamProvider** (`vote_state_providers.dart`):
```dart
@riverpod
Stream<VoteState> voteState(VoteStateRef ref, String postId) {
  final useCase = GetIt.instance<WatchVoteStateUseCase>();
  return useCase(postId).asyncMap(
    (either) => either.fold(
      (failure) => throw Exception(failure.getUserMessage()),
      (state) => state,
    ),
  );
}
```

### DI (Dependency Injection)

**파일**: `lib/features/voting/di/voting_di_module.dart`

**등록 방식** (GetIt):
```dart
void setupVotingDI(GetIt getIt) {
  // Repository 등록
  getIt.registerSingleton<IVotingDialogRepository>(
    VotingDialogRepositoryImpl(),
  );
  getIt.registerSingleton<IVotingChatRepository>(
    VotingChatRepositoryImpl(),
  );

  // UseCase 등록
  getIt.registerFactory(() => SubmitVoteUseCase(getIt()));
  getIt.registerFactory(() => WatchVoteStateUseCase(getIt()));
}
```

**main.dart 호출**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Voting DI 등록
  setupVotingDI(getIt);

  runApp(ProviderScope(child: MyApp()));
}
```

### nav.dart 통합

**Voting Feature는 nav.dart에 통합되지 않습니다**:
- `lib/app/router/navigation/nav.dart`에 `VotingRoutes.routes(ref)` 호출 없음
- 이유: 독립 페이지가 아닌 임베디드 UI 컴포넌트

### 참조 문서

- [voting/README.md](../README.md) - Voting Feature 전체 가이드 (528줄)
- [voting/data/README.md](./data/README.md) - Data Layer 상세 (2089줄)
- [voting/domain/README.md](./domain/README.md) - Domain Layer 상세 (1775줄)
- [voting/presentation/README.md](./presentation/README.md) - Presentation Layer 상세 (~2000줄)
- [/lib/app/router/README.md](/lib/app/router/README.md) - Router 시스템 개요

### 요약

| Feature | Routes | UI Pattern | 호출 방식 | 상태 관리 |
|---------|--------|-----------|----------|----------|
| **Voting** | ❌ 없음 | Dialog + 임베디드 위젯 | showDialog() + 커스텀 메시지 | Riverpod StreamProvider |
| **Auth** | ✅ 6개 | 독립 페이지 | context.goNamed() | Riverpod Provider |
| **Chat** | ✅ 2개 | 독립 페이지 | context.goNamed() | Riverpod StreamProvider |
| **Post** | ✅ 3개 | 독립 페이지 | context.goNamed() | Riverpod StreamProvider |

**Voting Feature의 Navigation 철학**:
> "투표는 콘텐츠의 일부이지, 독립된 목적지가 아닙니다."
> 따라서 Routes 대신 임베디드 UI 패턴을 사용하여 더 자연스러운 사용자 경험을 제공합니다.

---

## 📚 레이어별 README 안내

### 1. Data Layer README (`data/README.md` - 2089줄)

**📌 핵심 내용**:
- Firebase-Centric Architecture v1.0 설명
- Extension Pattern 사용법 (Mapper 대체)
- Sharded Counter 구현 (256 shards)
- Idempotency Service 사용법
- 3-Layer 캐싱 전략 (TTL 관리)
- 서버 시간 동기화 (VoteTimerService)

**📖 주요 섹션**:
1. **아키텍처 개요**: Firebase-Centric v2.0 vs Clean Architecture
2. **Extension Pattern**: Firestore 직렬화 예시
3. **Repository 구현**: 25+ 메서드 상세 설명
4. **UnifiedCacheService**: 3-Layer 캐싱 통합 (Memory → Hive → Firestore)
5. **Adapter Pattern**: Legacy 호환성 (VoteCounts, BoxCalculator)
6. **서버 동기화**: VoteTimerService 타임스탬프 처리

**💡 언제 참조?**
- Firebase Firestore 연동 방법을 알고 싶을 때
- Extension Pattern 사용법을 배우고 싶을 때
- 캐싱 전략을 이해하고 싶을 때
- Sharded Counter 구현을 확인하고 싶을 때

**🔗 바로가기**: [data/README.md](./data/README.md)

---

### 2. Domain Layer README (`domain/README.md` - 1775줄)

**📌 핵심 내용**:
- Clean Architecture v4.0 원칙
- Freezed 불변 엔티티 패턴
- Either<Failure, Success> 에러 처리
- Repository 인터페이스 설계
- UseCase 패턴 (단일 책임)
- 18개 Failure 타입 정의

**📖 주요 섹션**:
1. **Entity**: 9개 핵심 엔티티 (Vote, VoteState, PostVoting 등)
2. **Repository Interface**: 25+ 메서드 계약 정의
3. **UseCase**: SubmitVoteUseCase, WatchVoteStateUseCase
4. **Failure**: 18개 실패 타입 (InvalidData, AlreadyVoted, NetworkError 등)
5. **Services Interface**: IVoteTimerService, IBoxCalculatorService
6. **Constants**: VotingConstants (상수 정의)

**💡 언제 참조?**
- 비즈니스 로직을 이해하고 싶을 때
- 엔티티 구조를 확인하고 싶을 때
- 에러 처리 방법을 알고 싶을 때
- Repository 계약을 확인하고 싶을 때

**🔗 바로가기**: [domain/README.md](./domain/README.md)

---

### 3. Presentation Layer README (`presentation/README.md` - ~2000줄)

**📌 핵심 내용**:
- Riverpod 2.x 상태 관리
- StreamProvider.family 패턴
- Component-Driven Architecture
- keepAlive() 캐싱 전략
- AsyncValue.when() 패턴
- 39개 UI 컴포넌트 문서

**📖 주요 섹션**:
1. **Provider**: vote_providers.dart, vote_state_providers.dart
2. **Chat Vote Card**: 12개 파일 (VoteCardWidget + components)
3. **Dialogs**: VotingDialog, VotingBox, VotingImageViewer
4. **Component 분리**: Profile Header, Body, Footer 등
5. **State Management**: PostID별 독립 상태 관리
6. **UI 패턴**: AsyncValue 처리, 에러 표시, 로딩 상태

**💡 언제 참조?**
- UI 컴포넌트를 수정하고 싶을 때
- Riverpod Provider 사용법을 알고 싶을 때
- 투표 다이얼로그를 커스터마이즈하고 싶을 때
- 채팅 투표 카드를 수정하고 싶을 때

**🔗 바로가기**: [presentation/README.md](./presentation/README.md)

---

## 📍 주요 파일 위치

### 투표 제출 플로우 추적

```
사용자 클릭 → Presentation → Domain → Data → Firebase
                    ↓           ↓        ↓
           vote_providers   UseCase  Repository
```

1. **UI 이벤트**: `presentation/dialogs/voting_dialog.dart:410`
2. **Provider 호출**: `presentation/providers/vote_providers.dart:210`
3. **UseCase 실행**: `domain/usecases/submit_vote_use_case.dart:60`
4. **Repository 호출**: `domain/repositories/i_voting_dialog_repository.dart:242`
5. **Data 구현**: `data/repositories/voting_dialog_repository_impl.dart`
6. **Extension 변환**: `data/extensions/vote_extensions.dart`
7. **Firebase 저장**: Firestore Transaction + Sharded Counter

### 투표 상태 실시간 추적 플로우

```
Firestore Stream → Data → Domain → Presentation → UI 업데이트
                     ↓       ↓         ↓
                Extension  UseCase  StreamProvider
```

1. **StreamProvider 구독**: `presentation/providers/vote_state_providers.dart:140`
2. **UseCase 실행**: `domain/usecases/watch_vote_state_use_case.dart`
3. **Repository 호출**: `domain/repositories/i_voting_chat_repository.dart`
4. **Data 구현**: `data/repositories/voting_chat_repository_impl.dart`
5. **Extension 변환**: `data/extensions/vote_state_extensions.dart`
6. **Firestore 감시**: `posts/{postId}` 문서 실시간 스냅샷
7. **UI 업데이트**: `presentation/chat_vote_card/vote_card/vote_card_widget.dart:279`

---

## 🔧 DI (Dependency Injection)

**파일**: `di/voting_di_module.dart`

**등록되는 의존성**:
- Repository 구현체 (VotingDialogRepositoryImpl, VotingChatRepositoryImpl)
- UseCase (SubmitVoteUseCase, WatchVoteStateUseCase)
- 공유 서비스 (VoteTimerService, ShardUtils, IdempotencyService)
- UnifiedCacheService (전역 싱글톤, GetIt 등록 불필요)

**Provider에서 사용**:
```dart
// presentation/providers/vote_providers.dart
final useCase = GetIt.instance<SubmitVoteUseCase>();
```

---

## 📊 통계

| 구분 | 파일 수 | 총 라인 수 | 주요 패턴 | 변경사항 |
|------|---------|-----------|-----------|---------|
| **Data** | 8 | ~2,300 | Extension (1개), Sharded Counter, UnifiedCache | ⬇️ 4개 감소 (Extension 이동) |
| **Domain** | 39 | ~2,132 | Freezed, Either, UseCase, Extension (5개) | ⬆️ 4개 증가 (Extension 수용) |
| **Presentation** | 39 | ~6,850 | Riverpod, StreamProvider, Component-Driven | 📈 +52% 증가 |
| **DI** | 1 | ~100 | GetIt 등록 (DataSource 제거) | - |
| **문서** | 4 | ~6,500 | 통합 가이드 + 레이어별 상세 문서 | - |
| **총합** | **87** | **~17,882** | Clean Architecture v4.0 + Firebase-Centric v2.0 | 🔄 Extension Pattern 진화 |

---

## 🚀 시작하기

### 1. 새로운 투표 기능 추가 시

1. **Domain Entity 정의**: `domain/entities/dialog/` 또는 `chat/`
2. **Repository 인터페이스**: `domain/repositories/i_voting_*_repository.dart`
3. **UseCase 생성**: `domain/usecases/`
4. **Repository 구현**: `data/repositories/*_repository_impl.dart`
5. **Extension 작성**: `data/extensions/*_extensions.dart`
6. **Provider 생성**: `presentation/providers/`
7. **UI 컴포넌트**: `presentation/chat_vote_card/` 또는 `dialogs/`
8. **DI 등록**: `di/voting_di_module.dart`

### 2. 버그 수정 시

1. **증상 파악**: 어느 레이어에서 발생? (UI/비즈니스/데이터)
2. **해당 레이어 README 참조**: 섹션별 상세 설명 확인
3. **파일 위치 찾기**: 위 "주요 파일 위치" 섹션 참조
4. **플로우 추적**: 투표 제출/상태 추적 플로우 확인
5. **에러 타입 확인**: `domain/failures/voting_failure.dart`

### 3. 성능 최적화 시

1. **캐시 전략**: `data/README.md` > 캐시 서비스 섹션
2. **Provider 최적화**: `presentation/README.md` > keepAlive 패턴
3. **Sharded Counter**: `data/README.md` > Sharded Counter 섹션
4. **Extension 효율성**: `data/README.md` > Extension Pattern 섹션

---

## 🔍 자주 찾는 질문

<details>
<summary><strong>Q1. 투표 중복 방지는 어디서 처리하나요?</strong></summary>

**A**: 3곳에서 처리됩니다.
1. **UI 레벨**: `presentation/providers/vote_providers.dart` (isVoting 플래그)
2. **비즈니스 레벨**: `domain/usecases/submit_vote_use_case.dart` (checkUserVote)
3. **데이터 레벨**: `data/repositories/voting_dialog_repository_impl.dart` (IdempotencyService)

📖 상세: `data/README.md` > Idempotency 섹션
</details>

<details>
<summary><strong>Q2. 투표 타이머는 어떻게 동기화하나요?</strong></summary>

**A**: `data/services/vote_timer_service.dart`에서 Firestore 서버 시간과 동기화합니다.
- `time_sync` 컬렉션 사용
- 네트워크 지연 보정 알고리즘
- 5분 캐싱으로 과도한 요청 방지

📖 상세: `data/README.md` > 서버 동기화 섹션
</details>

<details>
<summary><strong>Q3. Extension Pattern과 Mapper Pattern의 차이는?</strong></summary>

**A**:
- **Extension Pattern** (현재 사용): Dart Extension으로 Firestore 변환 로직 추가, 간결하고 타입 안전
- **Mapper Pattern** (기존 방식): 별도의 Mapper 클래스 + DTO 클래스, 보일러플레이트 많음

📖 상세: `data/README.md` > Extension Pattern 섹션
</details>

<details>
<summary><strong>Q4. Riverpod Provider가 PostID별로 독립적인 이유는?</strong></summary>

**A**: `StreamProvider.family` 패턴 사용으로 각 PostID별 독립 상태 관리.
- 메모리 효율성 (사용되지 않는 Provider 자동 dispose)
- 상태 격리 (A 게시물 투표가 B 게시물에 영향 X)
- 캐싱 전략 (`keepAlive()`)

📖 상세: `presentation/README.md` > StreamProvider.family 섹션
</details>

<details>
<summary><strong>Q5. Sharded Counter는 왜 256개 샤드를 사용하나요?</strong></summary>

**A**:
- Firestore 문서당 최대 쓰기 속도: 1회/초
- 256개 샤드: 256회/초 처리 가능
- 10분 투표 타이머에서 최대 153,600명 동시 처리 가능

📖 상세: `data/README.md` > Sharded Counter 섹션 + `/lib/core/utils/shard_utils.dart`
</details>

---

## 📝 기여 가이드

### 코드 수정 시

1. **레이어 규칙 준수**:
   - Presentation → Domain → Data 방향으로만 의존
   - Domain은 프레임워크 독립 (Pure Dart)
   - Data는 Firebase SDK 직접 사용

2. **패턴 일관성**:
   - Entity는 Freezed 사용
   - Repository는 Either 패턴
   - Extension으로 Firestore 변환
   - Provider는 Riverpod 2.x

3. **문서 업데이트**:
   - 파일 추가 시: 해당 레이어 README 업데이트
   - 아키텍처 변경 시: 이 통합 README 업데이트
   - 주요 변경사항: CHANGELOG 기록

---

## 📞 문의 및 지원

- **버그 리포트**: GitHub Issues
- **아키텍처 질문**: 각 레이어 README의 "자주 찾는 질문" 섹션 참조
- **기능 제안**: Feature Request 템플릿 사용

---

**마지막 업데이트**: 2025-01-30
**버전**: v2.1.0 (3-Layer 캐싱 마이그레이션 완료)
**작성자**: Voting Feature Team
