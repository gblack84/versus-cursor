# Chat Feature - 통합 문서

> **최종 업데이트**: 2025-11-07
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0
> **캐싱**: UnifiedCacheService 3-Layer (Memory → Hive → Firestore)
> **상태 관리**: Riverpod 3.x with @riverpod code generation
> **UI 라이브러리**: flutter_chat_ui v2

## 📋 목차

- [전체 디렉토리 구조](#-전체-디렉토리-구조)
- [아키텍처 개요](#-아키텍처-개요)
- [핵심 기능](#-핵심-기능)
- [BOUNDARIES - Clean Architecture 3-Layer 경계](#️-boundaries---clean-architecture-3-layer-경계)
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
│   ├── 📂 providers/                     # Riverpod 3.x 상태 관리 (3개)
│   │   ├── chat_providers.dart           # 18개 Provider 정의 (312줄)
│   │   ├── chat_providers.g.dart         # Auto-generated (42.7 KB)
│   │   └── chat_params.dart              # Freezed 파라미터 클래스 (150줄)
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
│  • Riverpod 3.x with @riverpod code generation               │
│  • 18개 Providers (10 UseCase + 4 Stream + 2 Computed + 2 Service) │
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
| **@riverpod Stream** | Presentation | @riverpod 어노테이션 기반 스트림 Provider | `chatMessagesStream()` → `chatMessagesStreamProvider()` |
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

## 🏛️ BOUNDARIES - Clean Architecture 3-Layer 경계

Chat Feature는 **Clean Architecture v4.0**의 3-Layer 구조를 따르며, 각 Layer 간 의존성 방향을 엄격히 준수합니다.

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
│  • 패턴: UseCase, Entity (Freezed), Repository Interface     │
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
// presentation/providers/chat_providers.dart
@riverpod
Stream<List<Chat>> chatList(ChatListRef ref, String userId) {
  final useCase = getIt<GetChatListUseCase>();  // GetIt DI

  return useCase.execute(userId: userId).map(
    (either) => either.getOrElse((l) => []),
  );
}

@riverpod
FutureOr<void> sendMessage(
  SendMessageRef ref,
  String chatId,
  String content,
) async {
  final useCase = getIt<SendMessageUseCase>();
  final currentUserId = ref.watch(currentUserIdProvider);

  final result = await useCase.execute(
    chatId: chatId,
    senderId: currentUserId,
    content: content,
  );

  return result.fold(
    (failure) => throw Exception(failure.getUserMessage()),
    (_) => null,
  );
}
```

#### 2. ✅ Domain → 독립성 (올바른 사용)

```dart
// domain/usecases/send_message_usecase.dart
class SendMessageUseCase {
  final IChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<ChatFailure, void>> execute({
    required String chatId,
    required String senderId,
    required String content,
  }) {
    return _repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      content: content,
    );
  }
}

// domain/usecases/get_chat_list_usecase.dart
class GetChatListUseCase {
  final IChatRepository _repository;

  GetChatListUseCase(this._repository);

  Stream<Either<ChatFailure, List<Chat>>> execute({
    required String userId,
  }) {
    return _repository.watchChatList(userId);
  }
}
```

#### 3. ✅ Data → Domain (올바른 사용)

```dart
// data/repositories/chat_repository_impl.dart
class ChatRepositoryImpl implements IChatRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService;

  @override
  Future<Either<ChatFailure, void>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    try {
      // ✅ Data Layer는 Firestore 직접 접근 허용
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return right(null);
    } catch (e) {
      return left(ChatFailure.serverError(e.toString()));
    }
  }

  @override
  Stream<Either<ChatFailure, List<Chat>>> watchChatList(String userId) {
    try {
      // ✅ Data Layer는 Firestore Stream 직접 사용 허용
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        final chats = snapshot.docs
            .map((doc) => Chat.fromFirestore(doc))
            .toList();
        return right<ChatFailure, List<Chat>>(chats);
      });
    } catch (e) {
      return Stream.value(left(ChatFailure.serverError(e.toString())));
    }
  }
}
```

#### 4. ❌ 잘못된 사용 패턴

```dart
// ❌ Presentation Layer에서 Firestore 직접 접근
@riverpod
Stream<List<Chat>> chatList(ChatListRef ref, String userId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Chat.fromFirestore(doc))
          .toList());
}

// ❌ Domain Layer에서 Firebase 의존성
class SendMessageUseCase {
  Future<void> execute(String chatId, String content) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({'content': content});
  }
}
```

### Boundary 검증

#### 자동 검증 (Lint)

```bash
# Presentation → Data 위반 검사
grep -r "import.*chat.*data" lib/features/chat/presentation/

# Domain → Firebase 의존성 검사
grep -r "import.*firebase" lib/features/chat/domain/

# 기대 결과: 발견되지 않아야 함
```

#### 수동 검증 체크리스트

- [ ] Presentation Layer는 UseCase만 호출하는가?
- [ ] Domain Layer는 Pure Dart만 사용하는가? (Firebase/Flutter SDK 없음)
- [ ] Data Layer는 Repository Interface를 구현하는가?
- [ ] GetIt으로 UseCase/Repository를 DI하는가?
- [ ] Either 패턴으로 에러를 반환하는가?

### 참고 문서

- **전체 프로젝트 Boundaries**: `/CLAUDE.md` - "## 🏛 BOUNDARIES" 섹션
- **App Layer Boundaries**: `/lib/app/README.md` - "### 🏛️ BOUNDARIES" 섹션
- **Chat Domain Layer**: `domain/README.md` - UseCase, Entity, Failure
- **Chat Data Layer**: `data/README.md` - Repository 구현, Extension
- **Chat Presentation Layer**: `presentation/README.md` - Provider, Widget

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

## 🗺 Router Integration

Chat Feature는 GoRouter 기반 라우팅을 사용하며, **Domain Entity를 extra 파라미터로 전달**하는 패턴을 사용합니다.

### 라우트 구성

**파일 위치**: `lib/features/chat/presentation/routes/chat_routes.dart` (77줄)

Chat Feature는 **2개의 라우트**를 제공합니다:

| # | 라우트 이름 | 경로 | requireAuth | 파라미터 | 목적 |
|---|------------|------|-------------|---------|------|
| 1 | `ChatDetailWidgetClean.routeName` | `/chat/:chatId` | ✅ true (PRIVATE) | `chatId` (String, PathParameter)<br>`chatDocument` (Chat entity, extra) | 1:1 채팅방 (flutter_chat_ui v2) |
| 2 | `AIChatWidget.routeName` | `/aiChat` | ✅ true (PRIVATE) | `aiChatId` (String, QueryParameter, 선택) | AI 채팅 (Gemini AI) |

**총 라우트**: 2개 (모두 PRIVATE - 로그인 필수)

### Domain Entity as Extra Parameter

Chat Feature의 가장 큰 특징은 **Domain Entity를 GoRouter의 extra 파라미터로 전달**한다는 점입니다.

#### 왜 extra 파라미터를 사용하나?

```dart
// ❌ 방법 1: chatId만 전달 → Firestore 재조회 (300-500ms)
context.goNamed(
  ChatRoutes.chatDetail,
  pathParameters: {'chatId': chatId},
);
// ChatDetailWidget 내부에서 firestore.collection('chats').doc(chatId).get()
// → 불필요한 네트워크 요청, 로딩 시간 증가

// ✅ 방법 2: Chat entity를 extra로 전달 → 즉시 렌더링 (<10ms)
context.goNamed(
  ChatRoutes.chatDetail,
  pathParameters: {'chatId': chatId},
  extra: {
    'chatDocument': chatEntity,  // 이미 가지고 있는 Chat 객체
  },
);
// ChatDetailWidget가 즉시 chatEntity를 사용
// → 네트워크 요청 없음, 로딩 시간 0
```

**장점**:
1. **성능 향상**: Firestore 재조회 불필요 (300-500ms → <10ms)
2. **오프라인 지원**: 네트워크 없이도 이미 로드된 데이터 사용
3. **타입 안전**: Domain Entity 사용으로 타입 체크
4. **UX 개선**: 로딩 화면 없이 즉시 채팅방 진입

#### Extra Parameter 구현

```dart
// lib/features/chat/presentation/routes/chat_routes.dart

AppRoute(
  name: ChatDetailWidgetClean.routeName,
  path: ChatDetailWidgetClean.routePath, // '/chat/:chatId'
  requireAuth: true,  // 채팅은 로그인 필수
  builder: (context, params) => ChatDetailWidgetClean(
    // chatId는 PathParameter에서 가져오기
    chatId: params.getParam('chatId', ParamType.String),

    // chatDocument는 extra에서 가져오기 (선택적)
    chatDocument: params.state.extra != null
        ? (params.state.extra as Map<String, dynamic>)['chatDocument']
            as chat_entities.Chat?
        : null,
  ),
).toRoute(ref),
```

**핵심 포인트**:
- `chatId`는 **필수** (PathParameter - URL에 포함)
- `chatDocument`는 **선택적** (extra parameter - 있으면 사용, 없으면 Firestore 조회)

### PRIVATE Routes (2개) - requireAuth: true

Chat Feature의 **모든 라우트는 PRIVATE**입니다.

```dart
// ✅ PRIVATE - 로그인 필수
AppRoute(
  name: ChatDetailWidgetClean.routeName,
  path: ChatDetailWidgetClean.routePath,
  requireAuth: true,  // AuthGuard 자동 적용
  builder: (context, params) => ChatDetailWidgetClean(...),
).toRoute(ref),
```

**PRIVATE 라우트**:
1. **ChatDetail** (`/chat/:chatId`) - 1:1 채팅방 (다른 사용자와 대화)
2. **AIChat** (`/aiChat`) - AI 채팅 (Gemini AI와 대화)

**왜 모두 PRIVATE?**
| Route | 이유 |
|-------|------|
| **ChatDetail** | 개인 메시지 보호 (로그인한 사용자만 접근) |
| **AIChat** | AI 채팅 기록 보호 (본인만 조회) |

**근거**:
- **개인정보 보호**: 메시지는 민감한 개인 정보
- **보안**: 인증된 사용자만 채팅 가능
- **무단 접근 방지**: 다른 사용자의 채팅방 접근 차단

### flutter_chat_ui v2 Integration

Chat Feature는 **flutter_chat_ui v2**를 사용하여 채팅 UI를 구현합니다.

#### Adapter Pattern

```dart
// lib/features/chat/presentation/adapters/flutter_chat_adapter.dart

class FlutterChatAdapter {
  /// Domain Entity → flutter_chat_ui types.User
  static types.User toChatUser(chat_entities.User domainUser) {
    return types.User(
      id: domainUser.uid,
      firstName: domainUser.displayName.split(' ').first,
      lastName: domainUser.displayName.split(' ').skip(1).join(' '),
      imageUrl: domainUser.photoUrl,
    );
  }

  /// Domain Entity → flutter_chat_ui types.Message
  static types.Message toChatMessage(chat_entities.Message domainMessage) {
    return types.TextMessage(
      id: domainMessage.id,
      author: toChatUser(domainMessage.sender),
      text: domainMessage.content,
      createdAt: domainMessage.timestamp.millisecondsSinceEpoch,
      status: _mapStatus(domainMessage.status),
    );
  }
}
```

**Adapter 역할**:
- **Domain → UI**: Chat Feature의 Domain Entity를 flutter_chat_ui 타입으로 변환
- **타입 안전**: Domain 레이어는 flutter_chat_ui에 의존하지 않음
- **테스트 용이**: Adapter만 Mock 처리 가능

#### ChatDetailWidget 구조

```dart
// lib/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart

class ChatDetailWidgetClean extends ConsumerStatefulWidget {
  final String? chatId;
  final chat_entities.Chat? chatDocument;  // Extra parameter로 전달받은 Chat entity

  @override
  ConsumerState<ChatDetailWidgetClean> createState() => _State();
}

class _State extends ConsumerState<ChatDetailWidgetClean> {
  @override
  Widget build(BuildContext context) {
    // extra로 전달받은 chatDocument가 있으면 즉시 사용
    if (widget.chatDocument != null) {
      return _buildChatUI(widget.chatDocument!);
    }

    // 없으면 chatId로 Firestore 조회
    final chatAsync = ref.watch(chatProvider(widget.chatId!));
    return chatAsync.when(
      data: (chat) => _buildChatUI(chat),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(error: e),
    );
  }

  Widget _buildChatUI(chat_entities.Chat chat) {
    final messagesAsync = ref.watch(chatMessagesProvider(chat.chatId));

    return Chat(
      messages: messagesAsync.when(
        data: (messages) => messages.map(
          (msg) => FlutterChatAdapter.toChatMessage(msg),
        ).toList(),
        loading: () => [],
        error: (e, s) => [],
      ),
      user: FlutterChatAdapter.toChatUser(currentUser),
      onSendPressed: (message) => _handleSendMessage(message),
    );
  }
}
```

### 사용 예시

#### 1. ChatDetail 네비게이션 (extra 파라미터 포함)

```dart
// 방법 1: Chat entity를 extra로 전달 (권장 - 빠름)
context.goNamed(
  ChatRoutes.chatDetail,
  pathParameters: {
    'chatId': chat.chatId,
  },
  extra: {
    'chatDocument': chat,  // 이미 가지고 있는 Chat entity
  },
);

// 방법 2: chatId만 전달 (Firestore 재조회)
context.goNamed(
  ChatRoutes.chatDetail,
  pathParameters: {
    'chatId': chatId,
  },
);
// ChatDetailWidget 내부에서 Firestore 조회
```

#### 2. AIChat 네비게이션

```dart
// 새 AI 채팅 시작
context.goNamed(ChatRoutes.aiChat);

// 기존 AI 채팅 이어서 하기
context.goNamed(
  ChatRoutes.aiChat,
  queryParameters: {
    'aiChatId': existingAiChatId,
  },
);
```

#### 3. 채팅방 목록에서 네비게이션

```dart
// ChatList Widget에서 채팅방 클릭 시
ListView.builder(
  itemCount: chats.length,
  itemBuilder: (context, index) {
    final chat = chats[index];

    return ListTile(
      title: Text(chat.otherUserName),
      subtitle: Text(chat.lastMessage),
      onTap: () {
        // Chat entity를 extra로 전달 (즉시 렌더링)
        context.goNamed(
          ChatRoutes.chatDetail,
          pathParameters: {'chatId': chat.chatId},
          extra: {'chatDocument': chat},  // 이미 로드된 데이터 전달
        );
      },
    );
  },
);
```

#### 4. Push 네비게이션 (스택에 추가)

```dart
// 채팅방을 스택에 추가 (뒤로가기로 목록으로 복귀)
context.pushNamed(
  ChatRoutes.chatDetail,
  pathParameters: {'chatId': chatId},
  extra: {'chatDocument': chat},
);
```

#### 5. 딥링크 처리

```dart
// 외부 링크로 채팅방 접근
// versus://chat/abc123def456

// GoRouter가 자동으로 라우팅:
// 1. /chat/abc123def456 경로 파싱
// 2. ChatDetailWidgetClean.routePath 매칭 ('/chat/:chatId')
// 3. chatId 파라미터 추출 (abc123def456)
// 4. extra가 없으므로 Firestore에서 Chat 조회
// 5. ChatDetailWidgetClean 렌더링
```

### nav.dart 통합

Chat Feature의 2개 라우트는 `lib/app/router/navigation/nav.dart`에 통합되어 있습니다.

```dart
// /lib/app/router/navigation/nav.dart (line 139)
routes: [
  ...AuthRoutes.routes(ref),        // 6개
  ...ProfileRoutes.routes(ref),     // 6개
  ...ChatRoutes.routes(ref),        // 2개 (ChatDetail, AIChat)
  // ... 다른 Feature Routes
],
```

**병합 순서**:
1. AuthRoutes (6개)
2. ProfileRoutes (6개)
3. **ChatRoutes (2개)** - 1:1 채팅 + AI 채팅
4. VotingRoutes (0개 - 다이얼로그)
5. CreationRoutes (2개)
6. NotificationRoutes (4개)
7. PostRoutes (3개)
8. SearchRoutes (0개 - Phase 4-5 대기)

### Type-Safe Navigation 상수

Chat Feature는 타입 안전 네비게이션을 위한 static getter를 제공합니다:

```dart
// lib/features/chat/presentation/routes/chat_routes.dart

class ChatRoutes {
  /// Route names for type-safe navigation
  static String get chatDetail => ChatDetailWidgetClean.routeName;
  static String get aiChat => AIChatWidget.routeName;

  /// Route paths for reference
  static String get chatDetailPath => ChatDetailWidgetClean.routePath;
  static String get aiChatPath => AIChatWidget.routePath;
}
```

**사용법**:
```dart
// ✅ 타입 안전 (컴파일 타임 체크)
context.goNamed(ChatRoutes.chatDetail, pathParameters: {'chatId': id});

// ❌ 하드코딩 (오타 위험)
context.goNamed('chatDetail', pathParameters: {'chatId': id});
```

### Performance: extra vs Firestore 재조회

| 방법 | 네트워크 | 응답 시간 | 오프라인 | 권장 |
|------|---------|----------|---------|------|
| **extra 파라미터** | ❌ 불필요 | <10ms | ✅ 지원 | ✅ 권장 |
| **Firestore 재조회** | ✅ 필요 | 300-500ms | ❌ 실패 | ⚠️ 비권장 |

**Best Practice**:
```dart
// ✅ 채팅방 목록에서 이동 시 - extra 사용
// (이미 Chat entity를 가지고 있음)
context.goNamed(
  ChatRoutes.chatDetail,
  pathParameters: {'chatId': chat.chatId},
  extra: {'chatDocument': chat},
);

// ✅ 딥링크/알림으로 접근 시 - chatId만 사용
// (Chat entity가 없으므로 Firestore 조회 필요)
context.goNamed(
  ChatRoutes.chatDetail,
  pathParameters: {'chatId': chatId},
);
```

### 참조 문서

- [chat_routes.dart 소스 코드](./presentation/routes/chat_routes.dart) (77줄)
- [flutter_chat_ui v2 공식 문서](https://pub.dev/packages/flutter_chat_ui)
- [FlutterChatAdapter 구현](./presentation/adapters/flutter_chat_adapter.dart) - Domain ↔ UI 변환
- [GoRouter 공식 문서 - Extra parameter](https://pub.dev/packages/go_router#extra-parameter)
- [AppRoute 패턴](/lib/app/router/README.md)
- [Navigation 상세 가이드](/lib/app/router/navigation/README.md)

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
- Riverpod 3.x with @riverpod code generation
- 18개 Providers (10 UseCase + 4 Stream + 2 Computed + 2 Service)
- flutter_chat_ui v2 통합 (Adapter Pattern)
- ConsumerWidget/ConsumerStatefulWidget
- AsyncValue.when() 자동 상태 처리
- ChatAnimatedListReversed (스크롤 점프 방지)
- Clean Architecture v4.0 마이그레이션 (38% 평균 코드 감소)

**📖 주요 섹션**:
1. **Providers**: 18개 Riverpod 3.x Provider 정의 (chat_providers.dart + .g.dart)
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
- Riverpod 3.x 완전 도입 (18개 @riverpod Providers)
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
   - Provider는 Riverpod 3.x (@riverpod 어노테이션)

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
3. **Riverpod 3.x**: `presentation/README.md` 읽기 (Riverpod 3.x Migration 섹션 포함)
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
- [Presentation Layer README](./presentation/README.md) - Riverpod 3.x + flutter_chat_ui 통합
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
- [Riverpod 3.x](https://riverpod.dev/) - 상태 관리 with @riverpod code generation
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
