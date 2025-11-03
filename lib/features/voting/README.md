# Voting Feature - 통합 문서

> **최종 업데이트**: 2025-01-30
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0
> **캐싱**: UnifiedCacheService 3-Layer (Memory → Hive → Firestore)
> **상태 관리**: Riverpod 2.x

## 📋 목차

- [전체 디렉토리 구조](#-전체-디렉토리-구조)
- [아키텍처 개요](#-아키텍처-개요)
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
