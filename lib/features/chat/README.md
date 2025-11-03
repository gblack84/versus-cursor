# Chat Feature - 통합 문서

> **최종 업데이트**: 2025-01-30
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0
> **캐싱**: UnifiedCacheService 3-Layer (Memory → Hive → Firestore)
> **상태 관리**: Riverpod 2.x
> **UI 라이브러리**: flutter_chat_ui v2

## 📋 목차

- [전체 디렉토리 구조](#-전체-디렉토리-구조)
- [아키텍처 개요](#-아키텍처-개요)
- [핵심 기능](#-핵심-기능)
- [빠른 참조 가이드](#-빠른-참조-가이드)
- [레이어별 README 안내](#-레이어별-readme-안내)
- [주요 파일 위치](#-주요-파일-위치)

---

## 🗂 전체 디렉토리 구조

```
lib/features/chat/
├── 📂 data/                              # Data Layer (Firebase-Centric v2.0)
│   ├── 📂 repositories/                  # Repository 구현체 (4개)
│   │   ├── chat_repository_impl.dart
│   │   ├── message_repository_impl.dart
│   │   ├── friend_repository_impl.dart
│   │   └── ai_repository_impl.dart
│   ├── 📂 services/                      # Port-Adapter 패턴 서비스
│   │   └── gemini_ai_service.dart        # IAIService 구현체
│   ├── 📂 extensions/                    # Firestore 변환 (2개)
│   │   ├── chat_extensions.dart
│   │   └── message_extensions.dart
│   └── 📄 README.md                      # Data Layer 상세 문서 (1,829줄)
│
├── 📂 domain/                             # Domain Layer (Clean Architecture v4.0)
│   ├── 📂 entities/                      # Freezed 불변 엔티티 (6개)
│   │   ├── chat.dart
│   │   ├── chat.freezed.dart
│   │   ├── chat.g.dart
│   │   ├── message.dart
│   │   ├── message.freezed.dart
│   │   └── message.g.dart
│   ├── 📂 repositories/                  # Repository 인터페이스 (4개)
│   │   ├── i_chat_repository.dart
│   │   ├── i_message_repository.dart
│   │   ├── i_friend_repository.dart
│   │   └── i_ai_repository.dart
│   ├── 📂 services/                      # 서비스 인터페이스 (1개)
│   │   └── i_ai_service.dart
│   ├── 📂 failures/                      # Failure 정의 (1개)
│   │   └── chat_failure.dart
│   ├── 📂 usecases/                      # UseCase 비즈니스 로직 (10개)
│   │   ├── get_chat_list_usecase.dart
│   │   ├── get_chat_messages_usecase.dart
│   │   ├── send_message_usecase.dart
│   │   ├── upload_media_usecase.dart
│   │   ├── delete_message_usecase.dart
│   │   ├── create_or_get_chat_usecase.dart
│   │   ├── get_recommended_friends_usecase.dart
│   │   ├── search_friends_usecase.dart
│   │   ├── submit_vote_usecase.dart
│   │   └── generate_ai_response_usecase.dart
│   └── 📄 README.md                      # Domain Layer 상세 문서 (1,618줄)
│
├── 📂 presentation/                       # Presentation Layer (Clean Architecture v4.0)
│   ├── 📂 providers/                     # Riverpod 2.x 상태 관리 (2개)
│   │   ├── chat_providers.dart           # 10개 Provider 정의 (293줄)
│   │   └── chat_params.dart              # Freezed 파라미터 클래스 (76줄)
│   ├── 📂 adapters/                      # flutter_chat_ui 어댑터 (1개)
│   │   └── flutter_chat_adapter.dart     # Message 변환 (338줄)
│   ├── 📂 screens/                       # 화면 위젯 (5개)
│   │   ├── 📂 chat_list/
│   │   │   └── chat_list_widget_clean.dart  # 채팅 목록 (305줄)
│   │   ├── 📂 chat_detail/
│   │   │   ├── chat_detail_widget_clean.dart     # 1:1 채팅방 (627줄)
│   │   │   └── 📂 components/
│   │   │       ├── chat_message_builder.dart     # CustomMessage 빌더 (339줄)
│   │   │       ├── chat_detail_app_bar.dart
│   │   │       └── chat_detail_loading_widgets.dart
│   │   ├── 📂 ai_chat/
│   │   │   └── ai_chat_page_clean.dart  # AI 채팅방 (667줄)
│   │   ├── 📂 friends_search/
│   │   │   └── friends_search_widget_clean.dart
│   │   └── 📂 create_chat/
│   │       └── create_chat_widget_clean.dart
│   ├── 📂 widgets/                       # 공통 위젯 (1개)
│   │   └── chat_tile.dart
│   ├── 📂 services/                      # Presentation 서비스 (1개)
│   │   └── chat_scroll_service.dart      # 스크롤 관리 (165줄)
│   └── 📄 README.md                      # Presentation Layer 상세 문서 (2,800+줄)
│
├── 📂 di/
│   └── chat_di_module.dart               # Dependency Injection 모듈
│
└── 📄 README.md                          # 👈 이 문서 (통합 가이드)
```

**총 파일 수**: 약 50개 (생성된 Freezed/JSON 파일 포함)
- Data Layer: 8개
- Domain Layer: 23개 (주요 8개 + Freezed/JSON 생성 15개)
- Presentation Layer: 17개 (5,162줄)
- DI: 1개
- 문서: 4개

---

## 🏗 아키텍처 개요

### 3-Layer Clean Architecture 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  • Riverpod 2.x 상태 관리                                     │
│  • StreamProvider.autoDispose.family 패턴                    │
│  • flutter_chat_ui v2 통합 (Adapter Pattern)                │
│  • ConsumerWidget/ConsumerStatefulWidget                     │
│  • AsyncValue.when() 자동 상태 처리                          │
│  • 17개 파일 (5,162줄)                                        │
│  • Clean 마이그레이션: 38% 평균 코드 감소                     │
└──────────────────┬──────────────────────────────────────────┘
                   │ Provider 의존성 (ref.watch)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • Pure Dart (프레임워크 독립)                                 │
│  • Freezed 불변 엔티티 (Chat, Message)                        │
│  • Either<Failure, Success> 패턴                             │
│  • Repository 인터페이스 (4개)                                 │
│  • UseCase 패턴 (10개 - 단일 책임)                             │
│  • Port-Adapter Pattern (IAIService)                         │
│  • 23개 파일 (1,618줄)                                         │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository 인터페이스 의존성
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • Firebase-Centric Architecture v2.0                        │
│  • Direct Firebase SDK 사용 (Firestore, Storage, Auth)       │
│  • Extension Pattern (DTO/Mapper 제거)                       │
│  • Port-Adapter Pattern (GeminiAIService implements IAIService) │
│  • UnifiedCacheService (3-Layer 캐싱)                        │
│    - L1 Memory: <10ms (SimpleMemoryCache, LRU)              │
│    - L2 Hive: 10-30ms (영구 로컬 저장)                       │
│    - L3 Firestore: 50-500ms (오프라인 지원)                  │
│  • 캐시 히트율: 60%+ 목표                                      │
│  • 응답 시간: 캐시 히트 <10ms vs 네트워크 300-500ms           │
│  • 8개 파일 (1,829줄)                                          │
└─────────────────────────────────────────────────────────────┘
                   │
                   ▼
              Firebase Services
        (Firestore, Storage, Auth, Gemini AI)
```

### 핵심 디자인 패턴

| 패턴 | 레이어 | 목적 | 예시 파일 |
|------|--------|------|-----------|
| **Extension Pattern** | Data | Firestore 직렬화 (DTO/Mapper 대체) | `chat_extensions.dart`, `message_extensions.dart` |
| **Repository Pattern** | Domain/Data | 데이터 소스 추상화 | `i_chat_repository.dart` → `chat_repository_impl.dart` |
| **UseCase Pattern** | Domain | 비즈니스 로직 캡슐화 | `send_message_usecase.dart` |
| **Freezed Pattern** | Domain | 불변 엔티티 + 코드 생성 | `chat.dart`, `message.dart` + `*.freezed.dart` |
| **Either Pattern** | Domain | 타입 안전 에러 처리 | `Either<ChatFailure, Chat>` |
| **Port-Adapter Pattern** | Domain/Data | 서비스 인터페이스 분리 | `IAIService` (Port) ↔ `GeminiAIService` (Adapter) |
| **StreamProvider.family** | Presentation | 파라미터화된 스트림 상태 | `chatMessagesStreamProvider(ChatMessagesParams)` |
| **Adapter Pattern** | Presentation | flutter_chat_ui 통합 | `FlutterChatAdapter` (Message → core.Message) |
| **ConsumerWidget** | Presentation | Riverpod 통합 위젯 | `ChatListWidgetClean`, `ChatDetailWidgetClean` |
| **AsyncValue.when()** | Presentation | 로딩/에러/데이터 자동 처리 | `asyncMessages.when(loading: ..., error: ..., data: ...)` |
| **3-Layer Caching** | Data | 성능 최적화 | `UnifiedCacheService` (Memory → Hive → Firestore) |
| **ChatAnimatedListReversed** | Presentation | 스크롤 점프 방지 | flutter_chat_ui v2 커스텀 구현 |

---

## 🎯 핵심 기능

### 1. 실시간 채팅 시스템
- **1:1 채팅**: Firestore 실시간 스트림으로 즉시 메시지 동기화
- **AI 채팅**: 2개 AI 채팅방 (ai_assistant: 투표 카드 릴레이, ai_helper: 일반 대화)
- **친구 검색**: 추천 친구 목록 + 검색 기능
- **채팅방 생성**: 자동 채팅방 생성 또는 기존 채팅방 조회

### 2. Vote Card 통합
- **CustomMessage Builder**: 투표 카드를 채팅 메시지로 표시
- **실시간 투표 상태**: StreamBuilder로 투표 진행/완료 상태 자동 업데이트
- **스마트 레이아웃**: AspectRatioAnalyzer + UnifiedBoxCalculator로 자동 레이아웃
- **멀티이미지 지원**: A/B 각각 최대 4개 이미지 표시

### 3. 미디어 메시지
- **이미지 업로드**: Firebase Storage 통합
- **이미지 뷰어**: 전체화면 이미지 보기
- **미디어 캐싱**: CachedNetworkImage + memCacheWidth 최적화

### 4. 3-Layer 캐싱 시스템
- **L1 Memory Cache**: SimpleMemoryCache (LRU, 100개 제한, 5분 TTL)
- **L2 Local DB**: Hive 영구 저장소
- **L3 Remote**: Firestore 오프라인 캐시
- **프리로딩**: 최근 10개 채팅, 채팅당 15개 메시지 자동 프리로드
- **성능**: 캐시 히트 시 <10ms (네트워크 대비 30-50배 빠름)

### 5. Clean Architecture v4.0 Migration
| 화면 | Before (v2) | After (Clean) | 감소율 |
|------|-------------|---------------|--------|
| ChatDetailWidget | 1,199줄 | 627줄 | **48%** |
| AIChatPage | 956줄 | 667줄 | **30%** |
| ChatListWidget | 332줄 | 305줄 | **8%** |
| **평균** | - | - | **38%** |

### 6. 검색 기능
- **AI 채팅방 검색**: 20자 제한, 하이라이트 표시
- **친구 검색**: 실시간 검색 결과
- **검색창 UI**: 카카오톡 스타일 하단 고정

### 7. UI/UX 최적화
- **스크롤 점프 방지**: ChatAnimatedListReversed 적용
- **키보드 애니메이션**: 부드러운 키보드 등장/사라짐
- **로딩 상태**: AsyncValue.when()으로 자동 로딩 처리
- **에러 처리**: Either 패턴으로 타입 안전 에러 처리

---

## 🎯 빠른 참조 가이드

### 찾고자 하는 것 → 참조할 README 섹션

| 무엇을 찾을 때 | 어느 README | 어느 섹션 | 파일 위치 |
|---------------|-------------|-----------|-----------|
| **메시지 전송 로직** | `domain/README.md` | UseCase 섹션 | `domain/usecases/send_message_usecase.dart` |
| **채팅 목록 실시간 추적** | `domain/README.md` | UseCase 섹션 | `domain/usecases/get_chat_list_usecase.dart` |
| **Firestore 데이터 변환** | `data/README.md` | Extension Pattern 섹션 | `data/extensions/chat_extensions.dart` |
| **Firebase 저장 로직** | `data/README.md` | Repository 구현 섹션 | `data/repositories/chat_repository_impl.dart` |
| **3-Layer 캐싱** | `data/README.md` | UnifiedCacheService 섹션 | `/lib/services/cache/unified_cache_service.dart` |
| **AI 서비스 통합** | `data/README.md` | Port-Adapter 섹션 | `data/services/gemini_ai_service.dart` |
| **에러 타입 정의** | `domain/README.md` | Failure 섹션 | `domain/failures/chat_failure.dart` |
| **엔티티 구조** | `domain/README.md` | Entity 섹션 | `domain/entities/chat.dart`, `message.dart` |
| **Riverpod Provider** | `presentation/README.md` | Provider 섹션 | `presentation/providers/chat_providers.dart` |
| **flutter_chat_ui 통합** | `presentation/README.md` | Adapter 섹션 | `presentation/adapters/flutter_chat_adapter.dart` |
| **Vote Card UI** | `presentation/README.md` | CustomMessage 섹션 | `presentation/screens/chat_detail/components/chat_message_builder.dart` |
| **채팅방 화면** | `presentation/README.md` | Screens 섹션 | `presentation/screens/chat_detail/chat_detail_widget_clean.dart` |
| **DI 설정** | `di/chat_di_module.dart` | - | `di/chat_di_module.dart` |

---

## 📚 레이어별 README 안내

### 1. Data Layer README (`data/README.md` - 1,829줄)

**📌 핵심 내용**:
- Firebase-Centric Architecture v2.0 설명
- Extension Pattern 사용법 (DTO/Mapper 제거)
- UnifiedCacheService 3-Layer 캐싱 전략
- Port-Adapter Pattern (IAIService ↔ GeminiAIService)
- Repository 구현체 4개 상세 설명
- Firestore 컬렉션 구조 (chats, messages)

**📖 주요 섹션**:
1. **아키텍처 개요**: Firebase-Centric v2.0 vs Clean Architecture
2. **Extension Pattern**: Chat/Message Entity ↔ Firestore 변환
3. **Repository 구현**: ChatRepositoryImpl, MessageRepositoryImpl, FriendRepositoryImpl, AIRepositoryImpl
4. **UnifiedCacheService**: 3-Layer 캐싱 (Memory → Hive → Firestore)
5. **Port-Adapter Pattern**: IAIService (Domain) ↔ GeminiAIService (Data)
6. **Performance**: 캐시 히트율, 응답 시간, 프리로딩 전략

**💡 언제 참조?**
- Firebase Firestore 연동 방법을 알고 싶을 때
- Extension Pattern 사용법을 배우고 싶을 때
- 캐싱 전략을 이해하고 싶을 때
- AI 서비스 통합 방법을 확인하고 싶을 때
- Firestore 컬렉션 구조를 파악하고 싶을 때

**🔗 바로가기**: [data/README.md](./data/README.md)

---

### 2. Domain Layer README (`domain/README.md` - 1,618줄)

**📌 핵심 내용**:
- Clean Architecture v4.0 원칙
- Freezed 불변 엔티티 패턴 (Chat, Message)
- Either<Failure, Success> 에러 처리
- Repository 인터페이스 설계 (4개)
- UseCase 패턴 (10개 - 단일 책임)
- ChatFailure 타입 정의

**📖 주요 섹션**:
1. **Entity**: Chat (채팅방), Message (메시지)
2. **Repository Interface**: IChatRepository, IMessageRepository, IFriendRepository, IAIRepository
3. **UseCase**: 10개 비즈니스 로직 (메시지 전송, 채팅 목록, 친구 검색 등)
4. **Failure**: ChatFailure (10개 실패 타입)
5. **Services Interface**: IAIService (Port)
6. **Architecture Diagram**: Mermaid 다이어그램

**💡 언제 참조?**
- 비즈니스 로직을 이해하고 싶을 때
- 엔티티 구조를 확인하고 싶을 때
- 에러 처리 방법을 알고 싶을 때
- Repository 계약을 확인하고 싶을 때
- UseCase 사용법을 배우고 싶을 때

**🔗 바로가기**: [domain/README.md](./domain/README.md)

---

### 3. Presentation Layer README (`presentation/README.md` - 2,800+줄)

**📌 핵심 내용**:
- Riverpod 2.x 상태 관리
- StreamProvider.autoDispose.family 패턴
- flutter_chat_ui v2 통합 (Adapter Pattern)
- ConsumerWidget/ConsumerStatefulWidget
- AsyncValue.when() 자동 상태 처리
- ChatAnimatedListReversed (스크롤 점프 방지)
- Clean Architecture v4.0 마이그레이션 (38% 평균 코드 감소)

**📖 주요 섹션**:
1. **Providers**: 10개 Riverpod Provider 정의
2. **Freezed Params**: ChatListParams, ChatMessagesParams, RecommendedFriendsParams, SearchFriendsParams
3. **Flutter Chat UI Adapter**: Message Entity → flutter_chat_ui 변환
4. **Screens**: 5개 화면 (Chat List, Chat Detail, AI Chat, Friends Search, Create Chat)
5. **Components**: CustomMessage Builder (Vote Card), AppBar, Loading Widgets
6. **Services**: ChatScrollService (스크롤 관리)
7. **UI/UX Features**: 검색, 애니메이션, ChatAnimatedListReversed
8. **Testing Strategy**: Provider, Widget, Adapter 테스트 예시

**💡 언제 참조?**
- UI 컴포넌트를 수정하고 싶을 때
- Riverpod Provider 사용법을 알고 싶을 때
- flutter_chat_ui 통합 방법을 배우고 싶을 때
- Vote Card 커스터마이징을 하고 싶을 때
- Clean 마이그레이션 결과를 확인하고 싶을 때

**🔗 바로가기**: [presentation/README.md](./presentation/README.md)

---

## 📍 주요 파일 위치

### 메시지 전송 플로우 추적

```
사용자 입력 → Presentation → Domain → Data → Firebase
                    ↓           ↓        ↓
              chat_providers  UseCase  Repository
```

1. **UI 이벤트**: `presentation/screens/chat_detail/chat_detail_widget_clean.dart`
2. **Provider 호출**: `presentation/providers/chat_providers.dart` (sendMessageUseCaseProvider)
3. **UseCase 실행**: `domain/usecases/send_message_usecase.dart`
4. **Repository 호출**: `domain/repositories/i_message_repository.dart`
5. **Data 구현**: `data/repositories/message_repository_impl.dart`
6. **Extension 변환**: `data/extensions/message_extensions.dart`
7. **Firebase 저장**: Firestore `chats/{chatId}/messages` 컬렉션

### 채팅 목록 실시간 스트림 플로우

```
Firestore Stream → Data → Domain → Presentation → UI 업데이트
                     ↓       ↓         ↓
                Extension  UseCase  StreamProvider
```

1. **StreamProvider 구독**: `presentation/providers/chat_providers.dart` (chatListStreamProvider)
2. **UseCase 실행**: `domain/usecases/get_chat_list_usecase.dart`
3. **Repository 호출**: `domain/repositories/i_chat_repository.dart`
4. **Data 구현**: `data/repositories/chat_repository_impl.dart`
5. **Extension 변환**: `data/extensions/chat_extensions.dart`
6. **Firestore 감시**: `chats` 컬렉션 실시간 스냅샷
7. **Cache 체크**: UnifiedCacheService (Memory → Hive → Firestore)
8. **UI 업데이트**: `presentation/screens/chat_list/chat_list_widget_clean.dart` (AsyncValue.when())

### Vote Card 렌더링 플로우

```
Message Entity → FlutterChatAdapter → CustomMessage → Vote Card Widget
         ↓                 ↓                ↓                ↓
   metadata 추출    core.CustomMessage   Builder 호출   VoteCardWidget
```

1. **Message 수신**: `domain/entities/message.dart` (isVoteRequest: true)
2. **Adapter 변환**: `presentation/adapters/flutter_chat_adapter.dart` (convertEntityToMessage)
3. **CustomMessage 생성**: metadata에 postId, aspectRatios 등 포함
4. **Builder 호출**: `presentation/screens/chat_detail/components/chat_message_builder.dart`
5. **Layout 계산**: AspectRatioAnalyzer.getOptimalLayout() + UnifiedBoxCalculator
6. **Vote Card 렌더링**: `/lib/components/chat/vote_card_message.dart` (VoteCardWidget)
7. **실시간 업데이트**: StreamBuilder<PostsModel> for vote state changes

---

## 🔧 DI (Dependency Injection)

**파일**: `di/chat_di_module.dart`

**등록되는 의존성**:
- Repository 구현체 (ChatRepositoryImpl, MessageRepositoryImpl, FriendRepositoryImpl, AIRepositoryImpl)
- UseCase (10개: GetChatListUseCase, SendMessageUseCase 등)
- 서비스 (GeminiAIService implements IAIService)
- 공유 서비스 (UnifiedCacheService는 전역 싱글톤, GetIt 등록 불필요)

**Provider에서 사용**:
```dart
// presentation/providers/chat_providers.dart
final getChatListUseCaseProvider = Provider<GetChatListUseCase>((ref) {
  return getIt<GetChatListUseCase>();
});

final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    final useCase = ref.watch(getChatListUseCaseProvider);
    await for (final either in useCase.execute(
      userId: params.userId,
      limit: params.limit,
    )) {
      yield* either.fold(
        (failure) => Stream<List<Chat>>.error(failure),
        (chats) async* { yield chats; },
      );
    }
    ref.keepAlive();
  },
);
```

---

## 📊 통계

| 구분 | 파일 수 | 총 라인 수 | 주요 패턴 |
|------|---------|-----------|-----------|
| **Data** | 8 | ~1,829 | Extension, Port-Adapter, UnifiedCache |
| **Domain** | 23 | ~1,618 | Freezed, Either, UseCase, Repository Interface |
| **Presentation** | 17 | ~5,162 | Riverpod, StreamProvider, flutter_chat_ui Adapter |
| **DI** | 1 | ~150 | GetIt 등록 |
| **문서** | 4 | ~12,000+ | 통합 가이드 + 레이어별 상세 문서 |
| **총합** | **53** | **~20,759** | Clean Architecture v4.0 + Firebase-Centric v2.0 |

**Clean Architecture v4.0 Migration 성과**:
- 평균 코드 감소: **38%**
- 최대 감소 (ChatDetailWidget): **48%** (1,199줄 → 627줄)
- Riverpod 2.x 완전 도입
- flutter_chat_ui v2 통합 완료
- 3-Layer 캐싱 시스템 통합

---

## 🚀 시작하기

### 1. 새로운 채팅 기능 추가 시

1. **Domain Entity 정의**: `domain/entities/` (필요시 새 엔티티 추가)
2. **Repository 인터페이스**: `domain/repositories/i_*_repository.dart`
3. **UseCase 생성**: `domain/usecases/*_usecase.dart`
4. **Repository 구현**: `data/repositories/*_repository_impl.dart`
5. **Extension 작성**: `data/extensions/*_extensions.dart` (Firestore 변환)
6. **Provider 생성**: `presentation/providers/chat_providers.dart`
7. **UI 컴포넌트**: `presentation/screens/` 또는 `components/`
8. **DI 등록**: `di/chat_di_module.dart`

### 2. 버그 수정 시

1. **증상 파악**: 어느 레이어에서 발생? (UI/비즈니스/데이터)
2. **해당 레이어 README 참조**: 섹션별 상세 설명 확인
3. **파일 위치 찾기**: 위 "주요 파일 위치" 섹션 참조
4. **플로우 추적**: 메시지 전송/채팅 목록 플로우 확인
5. **에러 타입 확인**: `domain/failures/chat_failure.dart`

### 3. 성능 최적화 시

1. **캐시 전략**: `data/README.md` > UnifiedCacheService 섹션
2. **Provider 최적화**: `presentation/README.md` > keepAlive 패턴
3. **Image Caching**: `presentation/README.md` > UnifiedImageCacheService 섹션
4. **Extension 효율성**: `data/README.md` > Extension Pattern 섹션
5. **Preloading**: `data/README.md` > PreloadStrategy 섹션

### 4. flutter_chat_ui 커스터마이징 시

1. **Adapter Pattern**: `presentation/README.md` > FlutterChatAdapter 섹션
2. **CustomMessage Builder**: `presentation/README.md` > CustomMessage 섹션
3. **Chat UI 설정**: `presentation/README.md` > flutter_chat_ui 섹션
4. **Theme 커스터마이징**: DefaultChatTheme 활용

---

## 🔍 자주 찾는 질문

<details>
<summary><strong>Q1. 메시지 중복 전송은 어떻게 방지하나요?</strong></summary>

**A**: 2곳에서 처리됩니다.
1. **UI 레벨**: `presentation/providers/chat_providers.dart` (isSending 플래그)
2. **데이터 레벨**: `data/repositories/message_repository_impl.dart` (Firestore 자동 ID 생성)

📖 상세: `data/README.md` > MessageRepository 섹션
</details>

<details>
<summary><strong>Q2. 3-Layer 캐싱은 어떻게 작동하나요?</strong></summary>

**A**: `UnifiedCacheService`가 세 가지 레이어를 관리합니다.
- **L1 Memory**: SimpleMemoryCache (LRU, 100개 제한, <10ms)
- **L2 Hive**: 로컬 DB (영구 저장, 10-30ms)
- **L3 Firestore**: 오프라인 캐시 (50-500ms)

**플로우**: Memory 확인 → 없으면 Hive → 없으면 Firestore → 상위 레이어에 저장

📖 상세: `data/README.md` > UnifiedCacheService 섹션
</details>

<details>
<summary><strong>Q3. flutter_chat_ui와 어떻게 통합되나요?</strong></summary>

**A**: **Adapter Pattern** 사용:
- **FlutterChatAdapter**: `Message` Entity → `core.Message` (flutter_chat_ui)
- 5가지 메시지 타입 지원: Text, Image, Custom (Vote Card), System
- CustomMessage Builder로 Vote Card 렌더링

**변환 플로우**: Firestore → Message Entity → FlutterChatAdapter → core.Message → Chat UI

📖 상세: `presentation/README.md` > FlutterChatAdapter 섹션
</details>

<details>
<summary><strong>Q4. Riverpod Provider가 family 패턴을 사용하는 이유는?</strong></summary>

**A**: `StreamProvider.autoDispose.family` 패턴으로 파라미터화된 스트림 관리.
- **파라미터 기반**: ChatId, UserId 등으로 독립적인 Provider 생성
- **자동 Dispose**: 사용되지 않으면 자동으로 리소스 해제
- **캐싱 전략**: `keepAlive()`로 선택적 캐싱
- **메모리 효율**: 필요한 채팅방만 활성화

📖 상세: `presentation/README.md` > StreamProvider.family 섹션
</details>

<details>
<summary><strong>Q5. AI 채팅방은 어떻게 구현되나요?</strong></summary>

**A**: **Port-Adapter Pattern** 사용:
- **IAIService** (Domain): 서비스 인터페이스 (Port)
- **GeminiAIService** (Data): Google Gemini AI 구현체 (Adapter)
- **2개 AI 채팅방**:
  - `ai_assistant_{userId}`: 투표 카드 릴레이 (발신자 → AI → 수신자)
  - `ai_helper_{userId}`: 일반 AI 대화

📖 상세: `data/README.md` > Port-Adapter Pattern 섹션, `domain/README.md` > IAIService 섹션
</details>

<details>
<summary><strong>Q6. 스크롤 점프 문제는 어떻게 해결했나요?</strong></summary>

**A**: **ChatAnimatedListReversed** 사용:
- flutter_chat_ui v2 기본값이 Regular List (스크롤 0.0 = 상단)
- ChatAnimatedListReversed 적용 (스크롤 0.0 = 하단)
- 채팅방 진입 시 즉시 최신 메시지 표시
- 키보드 애니메이션 개선

📖 상세: `presentation/README.md` > ChatAnimatedListReversed 섹션
</details>

<details>
<summary><strong>Q7. Vote Card는 어떻게 채팅에 표시되나요?</strong></summary>

**A**: **CustomMessage Builder** 사용:
1. **Message Entity**: `isVoteRequest: true` 플래그 + metadata
2. **FlutterChatAdapter**: Message → core.CustomMessage 변환
3. **ChatMessageBuilder**: CustomMessage → VoteCardWidget
4. **Layout 계산**: AspectRatioAnalyzer + UnifiedBoxCalculator
5. **실시간 업데이트**: StreamBuilder<PostsModel> for vote state

📖 상세: `presentation/README.md` > CustomMessage Builder 섹션
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
   - Provider는 Riverpod 2.x (StreamProvider.family)

3. **문서 업데이트**:
   - 파일 추가 시: 해당 레이어 README 업데이트
   - 아키텍처 변경 시: 이 통합 README 업데이트
   - 주요 변경사항: CHANGELOG 기록

4. **테스트 작성**:
   - UseCase: 비즈니스 로직 단위 테스트
   - Repository: Mock Firebase 통합 테스트
   - Provider: Riverpod 상태 관리 테스트
   - Widget: flutter_test 위젯 테스트

---

## 🎓 학습 가이드

### 초보자를 위한 학습 경로

1. **Clean Architecture 이해**: `domain/README.md` 읽기
2. **Firebase-Centric v2.0**: `data/README.md` 읽기
3. **Riverpod 2.x**: `presentation/README.md` 읽기
4. **flutter_chat_ui 통합**: `presentation/README.md` > Adapter 섹션
5. **실습**: 간단한 메시지 전송 기능 추가

### 고급 개발자를 위한 참조

1. **Extension Pattern**: `data/README.md` > Extension 섹션
2. **3-Layer Caching**: `data/README.md` > UnifiedCacheService 섹션
3. **Port-Adapter Pattern**: `data/README.md` > Port-Adapter 섹션
4. **StreamProvider.family**: `presentation/README.md` > Provider 섹션
5. **Clean Migration 결과**: `presentation/README.md` > 코드 감소 메트릭

---

## 📞 문의 및 지원

- **버그 리포트**: GitHub Issues
- **아키텍처 질문**: 각 레이어 README의 "자주 찾는 질문" 섹션 참조
- **기능 제안**: Feature Request 템플릿 사용
- **기술 문서**: `/docs` 디렉토리의 가이드 참조

---

## 🔗 관련 문서

### 내부 문서
- [Data Layer README](./data/README.md) - Firebase-Centric v2.0 아키텍처
- [Domain Layer README](./domain/README.md) - Clean Architecture v4.0 비즈니스 로직
- [Presentation Layer README](./presentation/README.md) - Riverpod 2.x + flutter_chat_ui 통합
- [Chat DI Module](./di/chat_di_module.dart) - Dependency Injection 설정

### 공유 서비스
- `/lib/services/cache/unified_cache_service.dart` - 3-Layer 캐싱 시스템
- `/lib/services/cache/simple_memory_cache.dart` - L1 메모리 캐시 (LRU)
- `/lib/services/cache/cache_statistics.dart` - 캐시 성능 모니터링
- `/lib/services/cache/preload_strategy.dart` - 프리로딩 전략
- `/lib/core/utils/shard_utils.dart` - Sharded Counter 유틸리티
- `/lib/core/utils/idempotency_service.dart` - 중복 방지 서비스

### 외부 라이브러리
- [flutter_chat_ui v2](https://pub.dev/packages/flutter_chat_ui) - 채팅 UI 라이브러리
- [Riverpod 2.x](https://riverpod.dev/) - 상태 관리
- [fpdart](https://pub.dev/packages/fpdart) - Functional Programming (Either)
- [freezed](https://pub.dev/packages/freezed) - 불변 엔티티 코드 생성
- [Hive](https://pub.dev/packages/hive) - 로컬 DB

### 아키텍처 참조
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - Robert C. Martin
- [Firebase-Centric Architecture](https://firebase.google.com/docs/firestore/best-practices) - Google Firebase

---

**마지막 업데이트**: 2025-01-30
**버전**: v2.1.0 (Clean Architecture v4.0 + 3-Layer 캐싱 완료)
**작성자**: Chat Feature Team
