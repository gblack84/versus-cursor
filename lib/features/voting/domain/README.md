# Voting Domain Layer - Clean Architecture v4.0

> **Last Updated**: 2025-01-28
> **Architecture**: Clean Architecture v4.0 - Domain Layer
> **Pattern**: Repository Pattern + UseCase Pattern + Freezed Immutability
> **Dependencies**: Pure Dart (No Flutter/Firebase)

## Overview

**Voting Domain Layer**는 투표 Feature의 핵심 비즈니스 로직과 규칙을 정의하는 순수 Dart 레이어입니다. Clean Architecture v4.0의 가장 안쪽 원으로, 외부 의존성이 전혀 없으며 프레임워크에 독립적입니다.

### Core Principles

1. **Framework Independence**: Flutter, Firebase 등 외부 프레임워크 의존성 제거
2. **Testability**: 모든 비즈니스 로직은 단위 테스트 가능
3. **Immutability**: Freezed를 통한 불변 엔티티 설계
4. **Type Safety**: Either 패턴으로 타입 안전한 에러 처리
5. **Single Responsibility**: UseCase 패턴으로 단일 책임 원칙 준수
6. **Dependency Inversion**: Repository 인터페이스로 의존성 역전

### Domain Layer vs Data Layer

| Aspect | Domain Layer | Data Layer |
|--------|-------------|------------|
| **Purpose** | 비즈니스 개념 정의 | 구체적 구현 |
| **Dependencies** | Pure Dart only | Firebase, Dio, etc |
| **Entities** | Domain models | DTOs, Mappers |
| **Repositories** | Interfaces (abstract) | Implementations |
| **Focus** | What & Why | How |
| **Testing** | Unit tests (fast) | Integration tests (slow) |

---

## Directory Structure (35 files)

```
domain/
├── constants/
│   └── voting_constants.dart              # 141 lines - Feature-specific constants
│
├── entities/
│   ├── chat/                              # Chat-based voting entities (6 files)
│   │   ├── post_voting.dart               # 220 lines - Main voting entity
│   │   ├── post_voting.freezed.dart       # Generated
│   │   ├── post_voting.g.dart             # Generated
│   │   ├── vote_state.dart                # 60 lines - Voting state machine
│   │   ├── vote_state.freezed.dart        # Generated
│   │   └── vote_state.g.dart              # Generated
│   │
│   └── dialog/                            # Dialog-based voting entities (21 files)
│       ├── vote.dart                      # 55 lines - Single vote entity
│       ├── vote.freezed.dart              # Generated
│       ├── vote.g.dart                    # Generated
│       ├── vote_cache_state.dart          # Cache state entity
│       ├── vote_cache_state.freezed.dart  # Generated
│       ├── vote_cache_state.g.dart        # Generated
│       ├── vote_counts_model.dart         # 20 lines - Vote counts
│       ├── vote_counts_model.freezed.dart # Generated
│       ├── vote_counts_model.g.dart       # Generated
│       ├── vote_expansion_request.dart    # Vote time extension
│       ├── vote_expansion_request.freezed.dart # Generated
│       ├── vote_expansion_request.g.dart  # Generated
│       ├── vote_options.dart              # Vote option enum
│       ├── vote_options.freezed.dart      # Generated
│       ├── vote_options.g.dart            # Generated
│       ├── versus_box_size_data.dart      # UI box sizing data
│       ├── versus_box_size_data.freezed.dart # Generated
│       ├── versus_box_size_data.g.dart    # Generated
│       ├── weight.dart                    # Vote weight entity
│       ├── weight.freezed.dart            # Generated
│       └── weight.g.dart                  # Generated
│
├── failures/
│   └── voting_failure.dart                # 129 lines - 18 error types
│
├── repositories/
│   ├── i_voting_chat_repository.dart      # Chat voting repository interface
│   └── i_voting_dialog_repository.dart    # 242 lines - Dialog voting repository (25+ methods)
│
├── services/
│   ├── i_box_calculator_service.dart      # Box size calculation service
│   └── i_vote_timer_service.dart          # Vote timer service
│
└── usecases/
    ├── submit_vote_use_case.dart          # 60 lines - Vote submission logic
    └── watch_vote_state_use_case.dart     # Real-time vote state monitoring
```

**Total**: 17 main files + 18 generated files = **35 files**

---

## entities/ - Domain Entities Deep Dive

Domain entities는 비즈니스 개념을 표현하는 불변 객체입니다. Freezed 패키지를 사용하여 불변성, JSON 직렬화, copyWith, equality를 자동 생성합니다.

### 1. Vote Entity (dialog/vote.dart)

**Purpose**: 개별 투표 행위를 나타내는 최소 단위

```dart
@freezed
sealed class Vote with _$Vote {
  const Vote._();

  /// 투표 엔티티
  ///
  /// - [postId]: 투표 대상 게시물 ID
  /// - [userId]: 투표한 사용자 ID
  /// - [choice]: 선택지 ('A' 또는 'B')
  /// - [timestamp]: 투표 시각 (nullable)
  const factory Vote({
    required String postId,
    required String userId,
    required String choice,
    DateTime? timestamp,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);

  // ========================================
  // Business Logic (Domain Layer)
  // ========================================

  /// 선택지 A 여부
  bool get isOptionA => choice == 'A';

  /// 선택지 B 여부
  bool get isOptionB => choice == 'B';

  /// 투표 유효성 검증
  bool get isValid =>
    postId.isNotEmpty &&
    userId.isNotEmpty &&
    (choice == 'A' || choice == 'B');
}
```

**Key Features**:
- ✅ Immutable (Freezed)
- ✅ Business logic (isOptionA, isOptionB, isValid)
- ✅ JSON serialization
- ✅ Type safety

### 2. VoteCounts Entity (dialog/vote_counts_model.dart)

**Purpose**: 투표 집계 결과를 표현하는 읽기 전용 엔티티

```dart
@freezed
sealed class VoteCounts with _$VoteCounts {
  const VoteCounts._();

  /// 투표 집계 모델
  ///
  /// - [votesA]: A 선택지 투표 수
  /// - [votesB]: B 선택지 투표 수
  /// - [totalVotes]: 총 투표 수
  const factory VoteCounts({
    required int votesA,
    required int votesB,
    required int totalVotes,
  }) = _VoteCounts;

  factory VoteCounts.fromJson(Map<String, dynamic> json) =>
    _$VoteCountsFromJson(json);

  // Business Logic
  double get percentA => totalVotes > 0 ? (votesA / totalVotes) * 100 : 0.0;
  double get percentB => totalVotes > 0 ? (votesB / totalVotes) * 100 : 0.0;
  bool get isTied => votesA == votesB;
  String get winner => votesA > votesB ? 'A' : (votesB > votesA ? 'B' : 'Tie');
}
```

**Use Cases**:
- 실시간 투표 결과 표시
- 투표 완료 후 결과 조회
- 통계 대시보드

### 3. PostVoting Entity (chat/post_voting.dart)

**Purpose**: 채팅 기반 투표 게시물의 전체 상태를 표현하는 복합 엔티티

```dart
/// 투표 상태
enum VoteStatus {
  pending,    // 대기중
  active,     // 진행중
  completed,  // 완료
  cancelled,  // 취소됨
  timeout,    // 시간초과
}

/// 투표 선택지
enum VoteOption { A, B }

/// 시간 연장 상태
enum ExpansionStatus {
  none,       // 연장 없음
  pending,    // 연장 요청 대기
  active,     // 연장 진행중
  completed,  // 연장 완료
}

@freezed
sealed class PostVoting with _$PostVoting {
  const PostVoting._();

  const factory PostVoting({
    required String postId,
    required String creatorId,

    // 투표 상태
    required VoteStatus status,

    // 타이머 정보
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteStartTime,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteEndTime,

    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    Duration? remainingTime,

    // 투표 결과
    @Default(0) int votesA,
    @Default(0) int votesB,
    @Default([]) List<String> votedUserIdsA,
    @Default([]) List<String> votedUserIdsB,

    // 시간 연장
    ExpansionStatus? expansionStatus,
    DateTime? expansionRequestedAt,

    // 완료 정보
    bool? voteCompleted,
    DateTime? voteCompletedAt,

    // 취소 정보
    DateTime? voteCancelledAt,
    String? voteCancelledReason,
  }) = _PostVoting;

  factory PostVoting.fromJson(Map<String, dynamic> json) =>
    _$PostVotingFromJson(json);

  // ========================================
  // Business Logic
  // ========================================

  /// 투표 진행중 여부
  bool get isActive => status == VoteStatus.active;

  /// 투표 완료 여부
  bool get isCompleted => status == VoteStatus.completed || voteCompleted == true;

  /// 총 투표 수
  int get totalVotes => votesA + votesB;

  /// 사용자가 투표했는지 확인
  bool hasUserVoted(String userId) =>
    votedUserIdsA.contains(userId) || votedUserIdsB.contains(userId);

  /// 사용자의 투표 선택지 조회
  VoteOption? getUserVoteOption(String userId) {
    if (votedUserIdsA.contains(userId)) return VoteOption.A;
    if (votedUserIdsB.contains(userId)) return VoteOption.B;
    return null;
  }

  /// 타이머 만료 여부
  bool get isTimerExpired {
    if (voteEndTime == null) return false;
    return DateTime.now().isAfter(voteEndTime!);
  }

  /// A 선택지 승리 여부
  bool get isOptionAWinning => votesA > votesB;

  /// B 선택지 승리 여부
  bool get isOptionBWinning => votesB > votesA;

  /// 동점 여부
  bool get isTied => votesA == votesB;
}

// ========================================
// Custom JSON Converters
// ========================================

DateTime? _dateTimeFromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}

dynamic _dateTimeToTimestamp(DateTime? dateTime) {
  return dateTime?.millisecondsSinceEpoch;
}

int _durationToJson(Duration duration) => duration.inMilliseconds;

Duration _durationFromJson(int? milliseconds) {
  return Duration(milliseconds: milliseconds ?? 0);
}
```

**Complex Features**:
- ✅ 3 enums (VoteStatus, VoteOption, ExpansionStatus)
- ✅ Custom JSON converters (DateTime, Duration)
- ✅ Rich business logic (10+ getter methods)
- ✅ User tracking (votedUserIds lists)
- ✅ Timer management (start/end/remaining)
- ✅ Extension requests
- ✅ Completion/Cancellation tracking

### 4. VoteState Entity (chat/vote_state.dart)

**Purpose**: 투표 UI 상태를 표현하는 상태 머신 엔티티

```dart
@freezed
sealed class VoteState with _$VoteState {
  const VoteState._();

  /// 투표 요청 대기 상태
  const factory VoteState.votingRequest({
    DateTime? voteEndTime,
  }) = VotingRequest;

  /// 투표 진행중 상태
  const factory VoteState.voting({
    required DateTime voteEndTime,
    Duration? remainingTime,
  }) = Voting;

  /// 투표 완료 상태
  const factory VoteState.completed({
    required int votesA,
    required int votesB,
    String? winnerId,
  }) = VotingCompleted;

  /// 투표 취소 상태
  const factory VoteState.cancelled({
    String? reason,
  }) = VotingCancelled;

  /// 투표 타임아웃 상태
  const factory VoteState.timeout() = VotingTimeout;

  // Business Logic
  bool get isVotingRequest => this is VotingRequest;
  bool get isVoting => this is Voting;
  bool get isCompleted => this is VotingCompleted;
  bool get isCancelled => this is VotingCancelled;
  bool get isTimeout => this is VotingTimeout;
}
```

**State Machine Pattern**:
```
VotingRequest → Voting → (Completed | Cancelled | Timeout)
                  ↓
              (can request extension)
```

### 5. VoteExpansionRequest Entity (dialog/vote_expansion_request.dart)

**Purpose**: 투표 시간 연장 요청을 표현하는 엔티티

**Use Case**: 사용자가 10분 타이머 추가 시간 요청 시 사용

### 6. VersusBoxSizeData Entity (dialog/versus_box_size_data.dart)

**Purpose**: A/B 박스의 UI 크기 데이터를 표현하는 엔티티

**Use Case**: 스마트 레이아웃 시스템에서 동적 박스 크기 계산

### 7. Weight Entity (dialog/weight.dart)

**Purpose**: 투표 가중치를 표현하는 엔티티

**Use Case**: 특정 사용자 그룹에 투표 가중치 부여

### 8. VoteCacheState Entity (dialog/vote_cache_state.dart)

**Purpose**: 투표 캐시 상태를 표현하는 엔티티

**Use Case**: 3-Layer 캐싱 시스템에서 캐시 메타데이터 관리

### 9. VoteOptions Entity (dialog/vote_options.dart)

**Purpose**: 투표 선택지 정보를 표현하는 엔티티

**Use Case**: A/B 선택지의 텍스트, 이미지, 메타데이터 관리

---

## repositories/ - Repository Interfaces

Repository는 데이터 접근 추상화를 제공하는 인터페이스입니다. Domain Layer는 "무엇을" 정의하고, Data Layer는 "어떻게"를 구현합니다.

### Interface Segregation Principle

투표 시스템은 2개의 분리된 Repository 인터페이스를 제공합니다:

1. **IVotingDialogRepository** (242 lines, 25+ methods)
   - Legacy UI (VotingNotificationDialog)
   - Dialog-based vote submission
   - Vote expansion requests
   - Vote counts queries
   - Weights management

2. **IVotingChatRepository**
   - Chat-based voting (AI Assistant)
   - Message-embedded vote cards
   - Real-time vote state streams
   - Post-based voting logic

### IVotingDialogRepository Deep Dive

**5 Method Categories**:

#### 1. Basic Vote Operations (3 methods)

```dart
abstract class IVotingDialogRepository {
  /// 투표 제출 (원자적 트랜잭션)
  ///
  /// **Idempotency**: 동일한 userId가 재투표 시 기존 투표 제거 후 새 투표 등록
  ///
  /// **Transaction Steps**:
  /// 1. posts/{postId}/votes/{userId} 문서 생성
  /// 2. posts/{postId}.votedUserIdsA or votedUserIdsB 배열 업데이트
  /// 3. counters/vote_{postId}/shards/shard_{N} 증가 (ShardUtils 사용)
  ///
  /// **Returns**:
  /// - Right(unit): 성공
  /// - Left(VotingFailure): 실패 (AlreadyVoted, VotingClosed, etc.)
  Future<Either<VotingFailure, Unit>> castVote({
    required String postId,
    required String userId,
    required VoteOption option, // A or B
  });

  /// 투표 제거
  ///
  /// **Transaction Steps**:
  /// 1. posts/{postId}/votes/{userId} 문서 삭제
  /// 2. posts/{postId}.votedUserIdsA or votedUserIdsB 배열에서 제거
  /// 3. counters 샤드 감소
  Future<Either<VotingFailure, Unit>> removeVote({
    required String postId,
    required String userId,
  });

  /// 사용자 투표 여부 확인
  ///
  /// **Returns**:
  /// - Right(VoteOption.A): A에 투표
  /// - Right(VoteOption.B): B에 투표
  /// - Right(null): 투표 안 함
  /// - Left(VotingFailure): 에러
  Future<Either<VotingFailure, VoteOption?>> checkUserVote({
    required String postId,
    required String userId,
  });
}
```

**Atomic Transaction 보장**:
- Firestore Transaction 사용
- 중복 투표 방지
- Idempotency 지원 (재투표 시 기존 투표 제거)

#### 2. Vote Counts Queries (4 methods)

```dart
abstract class IVotingDialogRepository {
  /// 투표 수 조회 (일회성)
  ///
  /// **Source**: posts/{postId} 문서의 집계된 필드 (votesA, votesB)
  /// **Performance**: O(1) 읽기 (Cloud Function 자동 집계)
  Future<Either<VotingFailure, VoteCounts>> getVoteCounts(String postId);

  /// 투표 수 실시간 스트림
  ///
  /// **Use Case**: 투표 진행중 실시간 카운트 업데이트
  /// **Stream**: posts/{postId} 문서 변경 감지
  Stream<Either<VotingFailure, VoteCounts>> streamVoteCounts(String postId);

  /// 투표 수 조회 (필터 옵션 포함)
  ///
  /// **Filters**:
  /// - VoteOption (A or B)
  /// - Date range
  /// - User group
  Future<Either<VotingFailure, List<VoteCounts>>> getVoteCountsOnce({
    required List<VoteCountsReference> voteCountsList,
    List<Query Function(Query query)>? queryBuilder,
    int? limit,
  });

  /// 투표 수 카운트 조회
  ///
  /// **Use Case**: 페이지네이션 전 총 개수 확인
  Future<Either<VotingFailure, int>> getVoteCountsCount({
    required List<VoteCountsReference> voteCountsList,
    List<Query Function(Query query)>? queryBuilder,
    int? limit,
  });
}
```

**Performance Optimization**:
- Cloud Function 자동 집계 (counters 샤드 → posts 필드)
- 256개 샤드로 쓰기 부하 분산
- O(1) 읽기 성능

#### 3. User Vote History (1 method)

```dart
abstract class IVotingDialogRepository {
  /// 사용자 투표 이력 조회
  ///
  /// **Limit**: 최근 100개
  /// **Source**: posts/{postId}/votes subcollection
  /// **Order**: createdAt DESC
  Future<Either<VotingFailure, List<Vote>>> getUserVoteHistory({
    required String userId,
    int limit = 100,
  });
}
```

#### 4. Vote Expansion Operations (7 methods)

```dart
abstract class IVotingDialogRepository {
  /// 투표 시간 연장 요청
  ///
  /// **Request Flow**:
  /// 1. User → posts/{postId}/voteExpansionRequests 생성
  /// 2. Admin notification 전송
  /// 3. Admin approval → voteEndTime 연장
  Future<Either<VotingFailure, Unit>> requestVoteExpansion({
    required String postId,
    required String userId,
    required Duration extensionDuration, // 예: Duration(minutes: 10)
    String? reason,
  });

  /// 연장 요청 승인 (Admin only)
  Future<Either<VotingFailure, Unit>> approveVoteExpansion({
    required String postId,
    required String requestId,
    required String adminId,
  });

  /// 연장 요청 거부 (Admin only)
  Future<Either<VotingFailure, Unit>> rejectVoteExpansion({
    required String postId,
    required String requestId,
    required String adminId,
    String? rejectionReason,
  });

  /// 연장 요청 실시간 스트림
  Stream<Either<VotingFailure, List<VoteExpansionRequest>>>
    streamVoteExpansionRequests(String postId);

  /// 연장 요청 조회 (일회성)
  Future<Either<VotingFailure, List<VoteExpansionRequest>>>
    getVoteExpansionRequestsOnce(String postId);

  /// 연장 요청 카운트
  Future<Either<VotingFailure, int>> getVoteExpansionRequestsCount(String postId);

  /// 특정 연장 요청 조회
  Future<Either<VotingFailure, VoteExpansionRequest>> getVoteExpansionRequest({
    required String postId,
    required String requestId,
  });
}
```

**Admin Workflow**:
```
User Request → Notification → Admin Review → Approve/Reject
                                                  ↓
                                            Timer Extended
```

#### 5. Weights Operations (6 methods)

```dart
abstract class IVotingDialogRepository {
  /// 가중치 실시간 스트림
  Stream<Either<VotingFailure, List<Weight>>> streamWeights({
    required List<WeightReference> weightsList,
  });

  /// 가중치 조회 (일회성)
  Future<Either<VotingFailure, List<Weight>>> getWeightsOnce({
    required List<WeightReference> weightsList,
    List<Query Function(Query query)>? queryBuilder,
    int? limit,
  });

  /// 가중치 카운트
  Future<Either<VotingFailure, int>> getWeightsCount({
    required List<WeightReference> weightsList,
    List<Query Function(Query query)>? queryBuilder,
    int? limit,
  });

  /// 사용자 가중치 조회
  Future<Either<VotingFailure, double>> getUserVoteWeight({
    required String userId,
  });

  /// 그룹 가중치 조회
  Future<Either<VotingFailure, Map<String, double>>> getGroupVoteWeights({
    required String groupId,
  });

  /// 가중치 적용 투표 수 계산
  Future<Either<VotingFailure, VoteCounts>> getWeightedVoteCounts({
    required String postId,
  });
}
```

**Use Cases**:
- VIP 사용자 투표 가중치 부여
- 그룹별 투표 영향력 조정
- 전문가 의견 가중치 반영

### IVotingChatRepository Overview

```dart
abstract class IVotingChatRepository {
  /// 채팅 메시지 투표 제출
  Future<Either<VotingFailure, Unit>> submitChatVote({
    required String chatId,
    required String messageId,
    required String userId,
    required VoteOption option,
  });

  /// 실시간 투표 상태 스트림
  Stream<Either<VotingFailure, VoteState>> watchVoteState({
    required String postId,
    required String userId,
  });

  /// 메시지 투표 결과 조회
  Future<Either<VotingFailure, PostVoting>> getMessageVoteResult({
    required String chatId,
    required String messageId,
  });
}
```

**Key Differences from Dialog Repository**:
- Message-centric (chatId + messageId)
- Simplified API (fewer methods)
- Real-time VoteState streams
- Integrated with chat system

---

## usecases/ - Business Logic Encapsulation

UseCase는 단일 비즈니스 작업을 캡슐화합니다. Clean Architecture의 "Use Case Layer"를 구현하며, 이전의 거대한 Coordinator 클래스를 대체합니다.

### UseCase Pattern Benefits

1. **Single Responsibility**: 하나의 UseCase는 하나의 작업만 수행
2. **Testability**: Repository를 모킹하여 단위 테스트 용이
3. **Reusability**: 여러 UI에서 동일한 UseCase 재사용
4. **Maintainability**: 비즈니스 로직 변경 시 한 곳만 수정
5. **Dependency Inversion**: UseCase는 Repository 인터페이스에 의존

### 1. SubmitVoteUseCase

**Purpose**: 투표 제출 비즈니스 로직 캡슐화

**Previous**: `VoteStateCoordinator.castVote()` (519 lines 삭제)
**Current**: `SubmitVoteUseCase` (60 lines)

```dart
/// 투표 제출 UseCase
///
/// **Responsibility**: 사용자 투표 제출 플로우 처리
///
/// **Business Rules**:
/// 1. 투표 진행중 상태 확인
/// 2. 중복 투표 방지
/// 3. 투표 제출
/// 4. 에러 처리
///
/// **Dependencies**:
/// - Repository: IVotingDialogRepository or IVotingChatRepository
///
/// **Returns**: Either<VotingFailure, PostVoting>
class SubmitVoteUseCase {
  final IVotingDialogRepository _repository;

  SubmitVoteUseCase(this._repository);

  /// 투표 제출
  ///
  /// **Parameters**:
  /// - [postId]: 게시물 ID
  /// - [userId]: 사용자 ID
  /// - [voteOption]: 'A' or 'B'
  ///
  /// **Returns**:
  /// - Right(PostVoting): 투표 성공 후 업데이트된 PostVoting
  /// - Left(VotingFailure.alreadyVoted): 이미 투표함
  /// - Left(VotingFailure.votingClosed): 투표 종료됨
  /// - Left(VotingFailure.unauthorized): 권한 없음
  Future<Either<VotingFailure, PostVoting>> call({
    required String postId,
    required String userId,
    required String voteOption,
  }) async {
    // 1. Input validation
    if (voteOption != 'A' && voteOption != 'B') {
      return left(const VotingFailure.invalidData());
    }

    // 2. Convert to domain model
    final option = voteOption == 'A' ? VoteOption.A : VoteOption.B;

    // 3. Check existing vote
    final existingVoteResult = await _repository.checkUserVote(
      postId: postId,
      userId: userId,
    );

    return existingVoteResult.fold(
      (failure) => left(failure),
      (existingOption) async {
        if (existingOption != null) {
          // Already voted
          return left(const VotingFailure.alreadyVoted());
        }

        // 4. Cast vote
        final castResult = await _repository.castVote(
          postId: postId,
          userId: userId,
          option: option,
        );

        return castResult.fold(
          (failure) => left(failure),
          (_) async {
            // 5. Fetch updated post voting data
            // (Implementation depends on repository method)
            return right(/* PostVoting */);
          },
        );
      },
    );
  }
}
```

**Usage in Presentation Layer**:

```dart
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitVote = ref.read(submitVoteUseCaseProvider);

    return ElevatedButton(
      onPressed: () async {
        final result = await submitVote(
          postId: widget.postId,
          userId: currentUserId,
          voteOption: 'A',
        );

        result.fold(
          (failure) => _showError(failure),
          (updatedPost) => _showSuccess(updatedPost),
        );
      },
      child: Text('Vote A'),
    );
  }
}
```

### 2. WatchVoteStateUseCase

**Purpose**: 실시간 투표 상태 모니터링

```dart
/// 투표 상태 감시 UseCase
///
/// **Responsibility**: 실시간 투표 상태 스트림 제공
///
/// **Business Rules**:
/// 1. postId에 대한 투표 상태 스트림 생성
/// 2. VoteState 변환 (PostVoting → VoteState)
/// 3. 에러 스트림 변환
///
/// **Dependencies**:
/// - Repository: IVotingChatRepository
///
/// **Returns**: Stream<Either<VotingFailure, VoteState>>
class WatchVoteStateUseCase {
  final IVotingChatRepository _repository;

  WatchVoteStateUseCase(this._repository);

  /// 투표 상태 감시
  ///
  /// **Parameters**:
  /// - [postId]: 게시물 ID
  /// - [userId]: 사용자 ID (선택적 필터링)
  ///
  /// **Returns**: Stream of VoteState
  Stream<Either<VotingFailure, VoteState>> call({
    required String postId,
    required String userId,
  }) {
    return _repository.watchVoteState(
      postId: postId,
      userId: userId,
    );
  }
}
```

**Usage with StreamBuilder**:

```dart
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchVoteState = ref.read(watchVoteStateUseCaseProvider);

    return StreamBuilder<Either<VotingFailure, VoteState>>(
      stream: watchVoteState(
        postId: widget.postId,
        userId: currentUserId,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();

        return snapshot.data!.fold(
          (failure) => ErrorWidget(failure),
          (voteState) => voteState.when(
            votingRequest: () => VoteRequestUI(),
            voting: (endTime, remaining) => VotingUI(endTime, remaining),
            completed: (votesA, votesB, winner) => ResultUI(votesA, votesB, winner),
            cancelled: (reason) => CancelledUI(reason),
            timeout: () => TimeoutUI(),
          ),
        );
      },
    );
  }
}
```

---

## failures/ - Domain Errors

VotingFailure는 투표 시스템의 모든 에러 케이스를 표현하는 Sealed Union Type입니다.

### 18 Failure Types

#### 9 Basic Failures

```dart
@freezed
sealed class VotingFailure with _$VotingFailure {
  /// 서버 에러 (500)
  const factory VotingFailure.serverError() = _ServerError;

  /// 네트워크 에러 (연결 실패)
  const factory VotingFailure.networkError() = _NetworkError;

  /// 리소스 없음 (404)
  const factory VotingFailure.notFound() = _NotFound;

  /// 권한 없음 (403)
  const factory VotingFailure.unauthorized() = _Unauthorized;

  /// 이미 투표함 (중복 투표)
  const factory VotingFailure.alreadyVoted() = _AlreadyVoted;

  /// 투표 종료됨
  const factory VotingFailure.votingClosed() = _VotingClosed;

  /// 잘못된 데이터 (유효성 검증 실패)
  const factory VotingFailure.invalidData() = _InvalidData;

  /// 캐시 에러 (Hive 읽기/쓰기 실패)
  const factory VotingFailure.cacheError() = _CacheError;

  /// 예상치 못한 에러
  const factory VotingFailure.unexpected() = _Unexpected;
}
```

#### 9 Firebase-Specific Failures

```dart
@freezed
sealed class VotingFailure with _$VotingFailure {
  /// Firestore 권한 거부
  const factory VotingFailure.permissionDenied() = _PermissionDenied;

  /// Firebase 인증 필요
  const factory VotingFailure.unauthenticated() = _Unauthenticated;

  /// 문서 이미 존재 (createOnly 제약 위반)
  const factory VotingFailure.alreadyExists() = _AlreadyExists;

  /// Firestore 타임아웃
  const factory VotingFailure.timeout() = _Timeout;

  /// 할당량 초과
  const factory VotingFailure.quotaExceeded() = _QuotaExceeded;

  /// 잘못된 인자
  const factory VotingFailure.invalidArgument() = _InvalidArgument;

  /// 전제 조건 실패 (트랜잭션 충돌)
  const factory VotingFailure.failedPrecondition() = _FailedPrecondition;

  /// 작업 취소됨
  const factory VotingFailure.cancelled() = _Cancelled;

  /// 트랜잭션 중단됨
  const factory VotingFailure.aborted() = _Aborted;
}
```

### Pattern Matching with `.when()`

```dart
result.fold(
  (failure) => failure.when(
    serverError: () => showSnackBar('서버 에러가 발생했습니다'),
    networkError: () => showSnackBar('네트워크 연결을 확인하세요'),
    notFound: () => showSnackBar('투표를 찾을 수 없습니다'),
    unauthorized: () => showSnackBar('권한이 없습니다'),
    alreadyVoted: () => showSnackBar('이미 투표하셨습니다'),
    votingClosed: () => showSnackBar('투표가 종료되었습니다'),
    invalidData: () => showSnackBar('잘못된 데이터입니다'),
    cacheError: () => showSnackBar('캐시 에러'),
    unexpected: () => showSnackBar('알 수 없는 에러'),

    // Firebase-specific
    permissionDenied: () => showSnackBar('권한이 거부되었습니다'),
    unauthenticated: () => navigateToLogin(),
    alreadyExists: () => showSnackBar('이미 존재합니다'),
    timeout: () => showSnackBar('시간 초과'),
    quotaExceeded: () => showSnackBar('할당량 초과'),
    invalidArgument: () => showSnackBar('잘못된 인자'),
    failedPrecondition: () => showSnackBar('트랜잭션 충돌'),
    cancelled: () => showSnackBar('작업 취소됨'),
    aborted: () => showSnackBar('트랜잭션 중단됨'),
  ),
  (success) => showSnackBar('투표 성공!'),
);
```

### Failure Hierarchy

```
VotingFailure (Sealed)
├── Basic Failures (9)
│   ├── ServerError (500)
│   ├── NetworkError (connectivity)
│   ├── NotFound (404)
│   ├── Unauthorized (403)
│   ├── AlreadyVoted (business rule)
│   ├── VotingClosed (business rule)
│   ├── InvalidData (validation)
│   ├── CacheError (local storage)
│   └── Unexpected (unknown)
│
└── Firebase Failures (9)
    ├── PermissionDenied (Firestore rules)
    ├── Unauthenticated (no auth token)
    ├── AlreadyExists (createOnly violation)
    ├── Timeout (network timeout)
    ├── QuotaExceeded (billing limit)
    ├── InvalidArgument (bad params)
    ├── FailedPrecondition (transaction conflict)
    ├── Cancelled (user cancelled)
    └── Aborted (transaction aborted)
```

---

## constants/ - Domain Constants

`voting_constants.dart`는 투표 Feature의 모든 상수를 중앙 집중식으로 관리합니다.

### 5 Categories of Constants

#### 1. Colors (2 constants)

```dart
class VotingConstants {
  /// A 선택지 색상 (빨강)
  static const Color voteColorA = Color(0xFFFF0000);

  /// B 선택지 색상 (청록)
  static const Color voteColorB = Color(0xFF00B4D8);
}
```

#### 2. UI Styles (5 constants)

```dart
class VotingConstants {
  /// 투표 카드 모서리 둥글기
  static const double cardBorderRadius = 12.0;

  /// A/B 박스 기본 높이
  static const double defaultBoxHeight = 200.0;

  /// 가로 레이아웃 박스 높이 비율
  static const double horizontalHeightRatio = 0.4;

  /// 세로 레이아웃 박스 너비 비율
  static const double verticalWidthRatio = 0.85;

  /// 박스 간격
  static const double boxSpacing = 8.0;
}
```

#### 3. Status Strings (3 constants)

```dart
class VotingConstants {
  /// 투표 요청 상태
  static const String cardStatusVotingRequest = 'voting_request';

  /// 투표 진행중 상태
  static const String cardStatusVoting = 'voting';

  /// 투표 완료 상태
  static const String cardStatusCompleted = 'completed';
}
```

#### 4. UI Text (1 constant)

```dart
class VotingConstants {
  /// 투표 완료 메시지
  static const String completionMessage = '피클! 피클! 피클!';
}
```

#### 5. Animations (1 constant)

```dart
class VotingConstants {
  /// 투표 카드 애니메이션 지연 시간 (밀리초)
  static const int animationResetDelay = 500;
}
```

### Usage Example

```dart
import 'package:versus_cursor/features/voting/domain/constants/voting_constants.dart';

Container(
  decoration: BoxDecoration(
    color: isOptionA
      ? VotingConstants.voteColorA
      : VotingConstants.voteColorB,
    borderRadius: BorderRadius.circular(VotingConstants.cardBorderRadius),
  ),
  height: VotingConstants.defaultBoxHeight,
  child: Text(VotingConstants.completionMessage),
);
```

---

## services/ - Domain Services

Domain Services는 여러 엔티티에 걸친 비즈니스 로직을 캡슐화하는 인터페이스입니다.

### 1. IBoxCalculatorService

**Purpose**: A/B 박스의 동적 크기를 계산하는 서비스

```dart
/// 박스 크기 계산 서비스 인터페이스
///
/// **Responsibility**: 스마트 레이아웃 시스템의 박스 크기 계산
///
/// **Inputs**:
/// - aspectRatioA/B: 이미지 비율 (width / height)
/// - containerWidth: 컨테이너 너비
/// - layoutType: 가로/세로 배치
///
/// **Outputs**: VersusBoxSizeData (widthA/B, heightA/B)
abstract class IBoxCalculatorService {
  /// 박스 크기 계산
  VersusBoxSizeData calculate({
    required double? aspectRatioA,
    required double? aspectRatioB,
    required double containerWidth,
    required LayoutType layoutType,
  });

  /// 평균 높이 계산 (가로 배치용)
  double calculateAverageHeight(double? aspectRatioA, double? aspectRatioB);

  /// 최적 레이아웃 결정
  LayoutType determineOptimalLayout(double? aspectRatioA, double? aspectRatioB);
}
```

**Implementation Location**: `/lib/services/ui/unified_box_calculator.dart`

### 2. IVoteTimerService

**Purpose**: 투표 타이머를 관리하는 서비스

```dart
/// 투표 타이머 서비스 인터페이스
///
/// **Responsibility**: 투표 타이머 생명주기 관리
///
/// **Features**:
/// - 싱글톤 Timer 인스턴스 (postId당 하나)
/// - 브로드캐스트 Stream (여러 위젯에서 구독)
/// - 자동 메모리 정리
/// - 서버 시간 동기화
abstract class IVoteTimerService {
  /// 타이머 시작
  void startTimer({
    required String postId,
    required DateTime voteEndTime,
  });

  /// 타이머 중지
  void stopTimer(String postId);

  /// 남은 시간 스트림 구독
  Stream<Duration?> getRemainingTimeStream(String postId);

  /// 현재 남은 시간 조회 (캐시)
  Duration? getCachedRemainingTime(String postId);

  /// 서버 시간 동기화
  Future<void> syncServerTime();

  /// 동기화된 현재 시간
  DateTime get synchronizedNow;

  /// 모든 타이머 정리
  void dispose();
}
```

**Implementation Location**: `/lib/services/vote_timer_service.dart`

**Key Features**:
- ✅ 싱글톤 패턴 (postId당 하나의 Timer)
- ✅ 메모리 누수 방지 (자동 정리)
- ✅ 서버 시간 동기화 (Firebase `time_sync` 컬렉션)
- ✅ 브로드캐스트 Stream (여러 위젯 동시 구독)

---

## Clean Architecture v4.0 Principles

### 1. Dependency Rule

**Rule**: 의존성은 항상 바깥쪽에서 안쪽으로만 향합니다.

```
Presentation Layer (UI)
        ↓
   Domain Layer (Business Logic)  ← You Are Here
        ↓
    Data Layer (Implementation)
```

**Domain Layer는**:
- ✅ Presentation Layer에 대해 알지 못함
- ✅ Data Layer에 대해 알지 못함
- ✅ Flutter/Firebase에 대해 알지 못함
- ✅ 순수 Dart 코드만 사용

**Domain Layer가 정의하는 것**:
- Entities (무엇을 표현하는가?)
- Repository Interfaces (어떤 기능이 필요한가?)
- UseCases (어떤 비즈니스 로직이 있는가?)
- Failures (어떤 에러가 발생할 수 있는가?)

### 2. Entities Are Pure Dart

**Rule**: 엔티티는 프레임워크 독립적이어야 합니다.

```dart
// ❌ BAD: Flutter 의존성
import 'package:flutter/material.dart';

class Vote {
  final Color color; // Flutter Widget!
}

// ✅ GOOD: Pure Dart
class Vote {
  final String postId;
  final String userId;
  final String choice;
}
```

### 3. Repository Pattern

**Rule**: Repository는 인터페이스로 정의하고, Data Layer가 구현합니다.

```dart
// Domain Layer (interface)
abstract class IVotingDialogRepository {
  Future<Either<VotingFailure, Unit>> castVote({
    required String postId,
    required String userId,
    required VoteOption option,
  });
}

// Data Layer (implementation)
class VotingDialogRepository implements IVotingDialogRepository {
  final FirebaseFirestore _firestore;
  final ShardUtils _shardUtils;

  @override
  Future<Either<VotingFailure, Unit>> castVote(...) async {
    // Firestore 구현
  }
}
```

### 4. UseCase Single Responsibility

**Rule**: 하나의 UseCase는 하나의 비즈니스 작업만 수행합니다.

```dart
// ❌ BAD: God UseCase
class VotingUseCase {
  Future<void> castVote() {}
  Future<void> removeVote() {}
  Future<void> requestExpansion() {}
  Future<void> approveExpansion() {}
  // ... 50+ methods
}

// ✅ GOOD: Single Responsibility
class SubmitVoteUseCase {
  Future<Either<VotingFailure, PostVoting>> call(...) {}
}

class RemoveVoteUseCase {
  Future<Either<VotingFailure, Unit>> call(...) {}
}

class RequestVoteExpansionUseCase {
  Future<Either<VotingFailure, Unit>> call(...) {}
}
```

### 5. Either Pattern for Error Handling

**Rule**: 모든 실패 가능한 작업은 `Either<Failure, Success>` 타입을 반환합니다.

```dart
// ❌ BAD: Exception throwing
Future<Vote> castVote() async {
  if (error) throw Exception('Error!');
  return vote;
}

// ✅ GOOD: Either pattern
Future<Either<VotingFailure, Vote>> castVote() async {
  if (error) return left(VotingFailure.serverError());
  return right(vote);
}

// Usage with fold
final result = await castVote();
result.fold(
  (failure) => handleError(failure),
  (vote) => handleSuccess(vote),
);
```

### 6. Immutability with Freezed

**Rule**: 모든 엔티티는 불변 객체여야 합니다.

```dart
// ❌ BAD: Mutable entity
class Vote {
  String postId;
  String userId;
  String choice;

  void updateChoice(String newChoice) {
    choice = newChoice; // Mutation!
  }
}

// ✅ GOOD: Immutable entity
@freezed
sealed class Vote with _$Vote {
  const factory Vote({
    required String postId,
    required String userId,
    required String choice,
  }) = _Vote;

  // Use copyWith for updates
  // vote.copyWith(choice: 'B')
}
```

### 7. Domain Services

**Rule**: 여러 엔티티에 걸친 비즈니스 로직은 Domain Service로 분리합니다.

```dart
// ❌ BAD: Business logic in entity
class Vote {
  bool canExpand() {
    // 복잡한 비즈니스 규칙
  }
}

// ✅ GOOD: Domain service
abstract class IVoteExpansionService {
  bool canRequestExpansion({
    required Vote vote,
    required User user,
    required DateTime now,
  });
}
```

---

## Freezed Usage Guide

### Installation

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1
```

### Code Generation

```bash
# 1회 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 파일 변경 감지 및 자동 재생성
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Basic Freezed Entity

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote.freezed.dart';
part 'vote.g.dart';

@freezed
sealed class Vote with _$Vote {
  const Vote._(); // Private constructor for custom methods

  const factory Vote({
    required String postId,
    required String userId,
    required String choice,
    DateTime? timestamp,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);

  // Custom business logic
  bool get isOptionA => choice == 'A';
  bool get isOptionB => choice == 'B';
}
```

**Generated Files**:
- `vote.freezed.dart`: copyWith, ==, hashCode, toString
- `vote.g.dart`: fromJson, toJson

### Union Types (State Machine)

```dart
@freezed
sealed class VoteState with _$VoteState {
  const factory VoteState.votingRequest({
    DateTime? voteEndTime,
  }) = VotingRequest;

  const factory VoteState.voting({
    required DateTime voteEndTime,
    Duration? remainingTime,
  }) = Voting;

  const factory VoteState.completed({
    required int votesA,
    required int votesB,
  }) = VotingCompleted;
}

// Pattern matching
voteState.when(
  votingRequest: (endTime) => Text('Request'),
  voting: (endTime, remaining) => Text('Voting: $remaining'),
  completed: (votesA, votesB) => Text('Completed: A=$votesA, B=$votesB'),
);
```

### Custom JSON Converters

```dart
@freezed
sealed class PostVoting with _$PostVoting {
  const factory PostVoting({
    required String postId,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteStartTime,

    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    Duration? remainingTime,
  }) = _PostVoting;

  factory PostVoting.fromJson(Map<String, dynamic> json) =>
    _$PostVotingFromJson(json);
}

DateTime? _dateTimeFromTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

dynamic _dateTimeToTimestamp(DateTime? dateTime) {
  return dateTime?.millisecondsSinceEpoch;
}

Duration _durationFromJson(int? milliseconds) {
  return Duration(milliseconds: milliseconds ?? 0);
}

int _durationToJson(Duration duration) {
  return duration.inMilliseconds;
}
```

---

## Dependency Diagram

```
┌──────────────────────────────────────────────┐
│         Presentation Layer (UI)              │
│  - VoteCardWidget                            │
│  - VotingNotificationDialog                  │
│  - ChatDetailWidget                          │
└───────────────────┬──────────────────────────┘
                    │ depends on
                    ↓
┌──────────────────────────────────────────────┐
│           Domain Layer (YOU ARE HERE)        │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ entities/                            │   │
│  │  - Vote, VoteCounts, PostVoting      │   │
│  │  - VoteState (Union Type)            │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ repositories/ (Interfaces)           │   │
│  │  - IVotingDialogRepository           │   │
│  │  - IVotingChatRepository             │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ usecases/                            │   │
│  │  - SubmitVoteUseCase                 │   │
│  │  - WatchVoteStateUseCase             │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ failures/                            │   │
│  │  - VotingFailure (18 types)          │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ services/ (Interfaces)               │   │
│  │  - IBoxCalculatorService             │   │
│  │  - IVoteTimerService                 │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ constants/                           │   │
│  │  - VotingConstants (UI, Colors, etc) │   │
│  └──────────────────────────────────────┘   │
└───────────────────┬──────────────────────────┘
                    │ implemented by
                    ↓
┌──────────────────────────────────────────────┐
│             Data Layer (Implementation)      │
│  - VotingDialogRepository                    │
│  - VotingChatRepository                      │
│  - VoteTimerService                          │
│  - UnifiedBoxCalculator                      │
│  - Firebase, Firestore, ShardUtils           │
└──────────────────────────────────────────────┘
```

**Dependency Flow**:
1. Presentation → Domain (UseCases, Entities)
2. Domain → Data (Repository implementations)
3. Data → External (Firebase, Dio, Hive)

**Key Rule**: Domain은 Data를 알지 못합니다 (Dependency Inversion)

---

## Best Practices

### 1. Entity Design

**DO**:
- ✅ Pure Dart 타입만 사용 (String, int, DateTime, List, Map)
- ✅ Freezed로 불변성 보장
- ✅ Business logic을 getter/method로 구현
- ✅ JSON 직렬화 지원 (fromJson, toJson)
- ✅ copyWith로 업데이트
- ✅ Private constructor: `const Entity._();`

**DON'T**:
- ❌ Flutter Widget 타입 사용 (Color, IconData, etc)
- ❌ Firebase 타입 직접 사용 (DocumentReference, Timestamp)
- ❌ Mutable 필드 (var, setter)
- ❌ 비즈니스 로직을 Presentation Layer에 두기

**Example**:

```dart
// ✅ GOOD
@freezed
sealed class Vote with _$Vote {
  const Vote._();

  const factory Vote({
    required String postId,
    required String userId,
    required String choice,
  }) = _Vote;

  bool get isValid => choice == 'A' || choice == 'B';
}

// ❌ BAD
class Vote {
  String postId;
  String userId;
  Color color; // Flutter dependency!

  Vote(this.postId, this.userId, this.color);

  void updateColor(Color newColor) {
    color = newColor; // Mutable!
  }
}
```

### 2. Repository Interface Design

**DO**:
- ✅ 메서드명은 동사로 시작 (castVote, removeVote, getVoteCounts)
- ✅ 모든 실패 가능한 메서드는 `Either<Failure, T>` 반환
- ✅ 실시간 데이터는 `Stream<Either<Failure, T>>` 반환
- ✅ Interface Segregation (Dialog vs Chat 분리)
- ✅ Async 작업은 `Future` 반환

**DON'T**:
- ❌ void 반환 (에러 처리 불가)
- ❌ Exception throw (Either 패턴 사용)
- ❌ 구현 세부사항 노출 (Firestore, Firebase 타입)
- ❌ 너무 많은 메서드 (25+ = 분리 고려)

**Example**:

```dart
// ✅ GOOD
abstract class IVotingDialogRepository {
  Future<Either<VotingFailure, Unit>> castVote({
    required String postId,
    required String userId,
    required VoteOption option,
  });

  Stream<Either<VotingFailure, VoteCounts>> streamVoteCounts(String postId);
}

// ❌ BAD
abstract class IVotingRepository {
  Future<void> castVote(String postId, String userId, String option); // void!
  VoteCounts getVoteCounts(String postId); // Sync!

  // Firestore 노출
  Future<DocumentSnapshot> getVoteDocument(String postId);
}
```

### 3. UseCase Design

**DO**:
- ✅ Single Responsibility (하나의 UseCase = 하나의 작업)
- ✅ `call()` 메서드로 실행
- ✅ Repository를 생성자 주입
- ✅ Input validation 수행
- ✅ Either 패턴 반환

**DON'T**:
- ❌ 여러 작업을 하나의 UseCase에 넣기
- ❌ UI 로직 포함 (showDialog, navigation)
- ❌ 직접 Firebase 호출

**Example**:

```dart
// ✅ GOOD
class SubmitVoteUseCase {
  final IVotingDialogRepository _repository;

  SubmitVoteUseCase(this._repository);

  Future<Either<VotingFailure, PostVoting>> call({
    required String postId,
    required String userId,
    required String voteOption,
  }) async {
    // Validation
    if (voteOption != 'A' && voteOption != 'B') {
      return left(const VotingFailure.invalidData());
    }

    // Business logic
    final option = voteOption == 'A' ? VoteOption.A : VoteOption.B;
    return _repository.castVote(
      postId: postId,
      userId: userId,
      option: option,
    );
  }
}

// ❌ BAD
class VotingUseCase {
  Future<void> submitVote(...) {}
  Future<void> removeVote(...) {}
  Future<void> getVoteCounts(...) {}
  // ... 50+ methods (God Object!)
}
```

### 4. Failure Handling

**DO**:
- ✅ 모든 실패 케이스를 Sealed Union으로 정의
- ✅ `.when()` 패턴 매칭 사용
- ✅ Firebase 에러를 Domain Failure로 변환 (Data Layer에서)
- ✅ 사용자 친화적 메시지 제공

**DON'T**:
- ❌ Exception throw
- ❌ Generic `Exception` 사용
- ❌ Firebase 에러를 그대로 노출

**Example**:

```dart
// ✅ GOOD
result.fold(
  (failure) => failure.when(
    serverError: () => showSnackBar('서버 에러'),
    networkError: () => showSnackBar('네트워크 확인'),
    alreadyVoted: () => showSnackBar('이미 투표함'),
    votingClosed: () => showSnackBar('투표 종료'),
    // ... 18 cases
  ),
  (success) => showSnackBar('투표 성공!'),
);

// ❌ BAD
try {
  await castVote();
} catch (e) {
  showSnackBar(e.toString()); // "FirebaseException: ..."
}
```

---

## Summary

**Voting Domain Layer**는 투표 Feature의 핵심 비즈니스 로직을 정의하는 순수 Dart 레이어입니다.

**Key Highlights**:

1. **35 files**: 17 main files + 18 generated files
2. **9 Entities**: Vote, VoteCounts, PostVoting, VoteState, etc.
3. **2 Repository Interfaces**: Dialog (25+ methods), Chat (simplified)
4. **2 UseCases**: SubmitVote, WatchVoteState
5. **18 Failure Types**: Comprehensive error handling
6. **2 Domain Services**: BoxCalculator, VoteTimer
7. **Freezed Pattern**: 100% immutable entities
8. **Either Pattern**: Type-safe error handling
9. **Clean Architecture v4.0**: Framework independence

**Architecture Pattern**:
```
Presentation → Domain (interfaces) ← Data (implementations)
```

**Next Steps**:
- Presentation Layer 구현 (UI 위젯, Providers)
- Data Layer 구현 (Firebase, Repository 구체 클래스)
- Unit Tests 작성 (UseCases, Entities)
- Integration Tests (Repository 통합)

**Related Documentation**:
- [Data Layer README](/lib/features/voting/data/README.md)
- [Clean Architecture v4.0 Guide](/docs/guides/CLEAN_ARCHITECTURE.md)
- [Freezed Usage Guide](/docs/guides/FREEZED_GUIDE.md)
