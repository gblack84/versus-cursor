# Chat Feature - Riverpod 3.x Migration Guide (Phase 1-2)

> **마이그레이션 가이드**: Riverpod 2.x → 3.x
> **대상 Feature**: Chat Feature
> **참조 구현**: Post Feature (완료됨, Riverpod 3.x), Creation Feature (완료됨, Riverpod 3.x)
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

Chat Feature를 **Riverpod 2.x (Manual Providers)** 에서 **Riverpod 3.x (Code Generation)**으로 마이그레이션하여:

1. **타입 안정성 향상**: 컴파일 타임 에러 검출
2. **코드 감소**: 보일러플레이트 49% 감소 (294줄 → 150줄)
3. **유지보수성 향상**: 일관된 패턴, 자동 생성 코드
4. **DevTools 지원**: 향상된 Riverpod DevTools 기능
5. **프로젝트 일관성**: Post/Creation Feature와 통일된 Riverpod 3.x 패턴

### 문서 범위

이 문서는 **Phase 1-2**를 다룹니다:
- **Phase 1**: 준비 작업 (의존성, 파일 구조, 백업)
- **Phase 2**: Provider 마이그레이션 (UseCase, StreamProvider, Computed Provider)

**Phase 3-7**는 별도 문서 참조:
→ `RIVERPOD_3X_MIGRATION_PHASE_3_7.md`

### 참조 구현

#### Post Feature (Riverpod 3.x 완료)

**참조 파일**:
- `lib/features/post/presentation/providers/post_providers.dart` (~667 lines)
  - `@riverpod` 함수형 Provider 패턴
  - StreamProvider.autoDispose.family → @riverpod Stream<T>
  - 3-Layer 캐싱 통합

**마이그레이션 결과** (Post Feature):
- Before: Manual providers, 보일러플레이트 많음
- After: @riverpod annotation, 코드 생성
- 감소: ~40% 코드 감소

#### Creation Feature (Riverpod 3.x 완료)

**참조 파일**:
- `lib/features/creation/presentation/providers/create_post_notifier.dart` (807 lines)
  - `@riverpod` class Notifier 패턴
  - Timer 기반 debounce 로직
  - UUID 기반 idempotency
- `lib/features/creation/presentation/providers/usecase_providers.dart` (52 lines)
  - GetIt 통합 패턴
  - `@riverpod` getter function

---

## Phase 1: Preparation

### 1.1 의존성 확인

#### pubspec.yaml 검증

**필수 패키지** (현재 프로젝트에 이미 포함됨):

```yaml
dependencies:
  riverpod: ^3.0.3
  flutter_riverpod: ^3.0.3
  riverpod_annotation: ^3.0.0

dev_dependencies:
  build_runner: ^2.4.12
  riverpod_generator: ^3.0.0
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
| flutter_riverpod | 3.0.3 | ≥3.0.0 | ✅ |
| riverpod_annotation | 3.0.0 | ≥3.0.0 | ✅ |
| build_runner | 2.4.12 | ≥2.0.0 | ✅ |
| riverpod_generator | 3.0.0 | ≥3.0.0 | ✅ |

**결론**: ✅ 모든 의존성이 Riverpod 3.x 마이그레이션을 지원합니다.

---

### 1.2 파일 구조 설계

#### 현재 구조 (Riverpod 2.x)

```
lib/features/chat/presentation/providers/
├── chat_providers.dart           # 294 lines, 10 UseCases + 4 StreamProviders + 2 Computed
└── chat_params.dart              # Freezed parameter classes
    └── chat_params.freezed.dart
```

**chat_providers.dart** 구성 (294 lines):
- **Line 1-20**: Import 문 (20 lines)
- **Line 22-63**: UseCase Providers (10개, 42 lines)
  - `getChatListUseCaseProvider` (3 lines)
  - `getChatMessagesUseCaseProvider` (3 lines)
  - `loadMoreMessagesUseCaseProvider` (3 lines)
  - `sendMessageUseCaseProvider` (3 lines)
  - `searchMessagesUseCaseProvider` (3 lines)
  - `sendAIQueryUseCaseProvider` (3 lines)
  - `chatMessageLifecycleServiceProvider` (3 lines)
  - `aiServiceProvider` (3 lines)
  - `getRecommendedFriendsUseCaseProvider` (3 lines)
  - `searchFriendsUseCaseProvider` (3 lines)
  - `sendFriendRequestUseCaseProvider` (3 lines)
  - `toggleFollowUseCaseProvider` (3 lines)
- **Line 66-110**: chatListStreamProvider (45 lines)
- **Line 112-141**: chatMessagesStreamProvider (30 lines)
- **Line 143-162**: unreadChatCountProvider (20 lines)
- **Line 164-191**: aiChatProvider (28 lines)
- **Line 196-259**: recommendedFriendsStreamProvider (64 lines)
- **Line 261-293**: searchFriendsStreamProvider (33 lines)

#### 목표 구조 (Riverpod 3.x)

```
lib/features/chat/presentation/providers/
├── chat_providers.dart              # Riverpod 3.x providers (~150 lines)
├── chat_providers.g.dart            # 🆕 Generated file
├── chat_params.dart                 # Freezed parameter classes (유지)
└── chat_params.freezed.dart         # (유지)
```

**파일 설명**:

1. **chat_providers.dart** (Riverpod 3.x)
   - `@riverpod` annotations
   - Part directive: `part 'chat_providers.g.dart';`
   - 10개 UseCase → 간결한 @riverpod 함수
   - 4개 StreamProvider → @riverpod Stream<T> 함수
   - 2개 Computed Provider → @riverpod 계산 함수

2. **chat_providers.g.dart** (자동 생성)
   - build_runner로 생성
   - Provider 코드 자동 생성
   - 수정하지 말 것!

3. **chat_params.dart** (유지)
   - Freezed 파라미터 클래스 유지
   - `ChatListParams`, `ChatMessagesParams`, `RecommendedFriendsParams`, `SearchFriendsParams`

#### 파일 분리 전략

**Option 1: 점진적 마이그레이션** (추천)
- 기존 `chat_providers.dart` 백업
- 동일 파일에서 Riverpod 3.x로 변환
- 테스트 후 백업 파일 삭제

**Option 2: 새 파일 생성**
- `chat_providers_v3.dart` 생성
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
git checkout -b feature/chat-riverpod-3x-migration

# 현재 상태 커밋
git add .
git commit -m "chore(chat): Backup before Riverpod 3.x migration

- Current: Riverpod 2.x manual providers (294 lines)
- Target: Riverpod 3.x @riverpod annotation (~150 lines)
- Expected reduction: 49%"
```

#### 파일 백업 (Optional)

**수동 백업**:
```bash
# chat/presentation/providers/ 전체 백업
cp -r lib/features/chat/presentation/providers \
      lib/features/chat/presentation/providers.backup

# 백업 확인
ls -la lib/features/chat/presentation/providers.backup/
```

**백업 파일**:
- `providers.backup/chat_providers.dart` (원본, 294 lines)
- `providers.backup/chat_params.dart` (원본, Freezed)

#### 롤백 전략

**Git 롤백**:
```bash
# 마이그레이션 중 문제 발생 시
git checkout lib/features/chat/presentation/providers/

# 또는 branch 전체 롤백
git reset --hard HEAD
```

**수동 롤백**:
```bash
# 백업 파일 복원
cp -r lib/features/chat/presentation/providers.backup/* \
      lib/features/chat/presentation/providers/
```

---

### 1.4 사전 확인 체크리스트

마이그레이션 시작 전에 다음을 확인하세요:

- [ ] **pubspec.yaml 최신화 완료**
  - `flutter pub get` 실행 완료
  - 모든 패키지 버전 호환성 확인

- [ ] **기존 코드 컴파일 확인**
  ```bash
  flutter analyze lib/features/chat/
  # 예상: "No issues found!"
  ```

- [ ] **Git branch 생성 완료**
  ```bash
  git branch
  # 예상: * feature/chat-riverpod-3x-migration
  ```

- [ ] **백업 완료**
  - Git commit 완료
  - (Optional) 수동 백업 폴더 생성

- [ ] **Post/Creation Feature 참조 파일 확인**
  - `lib/features/post/presentation/providers/post_providers.dart` 존재 확인
  - `lib/features/creation/presentation/providers/create_post_notifier.dart` 존재 확인

**확인 완료 후 Phase 2로 진행하세요!**

---

## Phase 2: Provider Migration

### 2.1 UseCase Provider 마이그레이션 (10개)

#### 개념 설명

**Riverpod 2.x (Manual)**:
```dart
// GetIt UseCase를 Provider로 래핑
final getChatListUseCaseProvider = Provider<GetChatListUseCase>((ref) {
  return getIt<GetChatListUseCase>();
});
```

**Riverpod 3.x (Code Generation)**:
```dart
@riverpod
GetChatListUseCase getChatListUseCase(Ref ref) {
  return getIt<GetChatListUseCase>();
}
```

**차이점**:
- 2.x: `Provider<T>` 타입 명시 필요, 3줄
- 3.x: 반환 타입에서 자동 추론, 1줄 (67% 감소)
- 3.x: 더 간결한 문법

---

#### 예제 1-10: 모든 UseCase Provider 변환

**Before (Riverpod 2.x)** - `chat_providers.dart:26-63` (42 lines)

```dart
// ========================================
// UseCase Providers (GetIt Wrapping)
// ========================================

/// GetIt에 등록된 GetChatListUseCase를 Riverpod Provider로 제공
final getChatListUseCaseProvider = Provider<GetChatListUseCase>((ref) {
  return getIt<GetChatListUseCase>();
});

/// GetIt에 등록된 GetChatMessagesUseCase를 Riverpod Provider로 제공
final getChatMessagesUseCaseProvider = Provider<GetChatMessagesUseCase>((ref) {
  return getIt<GetChatMessagesUseCase>();
});

/// GetIt에 등록된 LoadMoreMessagesUseCase를 Riverpod Provider로 제공
final loadMoreMessagesUseCaseProvider = Provider<LoadMoreMessagesUseCase>((ref) {
  return getIt<LoadMoreMessagesUseCase>();
});

/// GetIt에 등록된 SendMessageUseCase를 Riverpod Provider로 제공
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return getIt<SendMessageUseCase>();
});

/// GetIt에 등록된 SearchMessagesUseCase를 Riverpod Provider로 제공
final searchMessagesUseCaseProvider = Provider<SearchMessagesUseCase>((ref) {
  return getIt<SearchMessagesUseCase>();
});

/// GetIt에 등록된 SendAIQueryUseCase를 Riverpod Provider로 제공
final sendAIQueryUseCaseProvider = Provider<SendAIQueryUseCase>((ref) {
  return getIt<SendAIQueryUseCase>();
});

/// GetIt에 등록된 ChatMessageLifecycleService를 Riverpod Provider로 제공
final chatMessageLifecycleServiceProvider = Provider<ChatMessageLifecycleService>((ref) {
  return getIt<ChatMessageLifecycleService>();
});

/// GetIt에 등록된 IAIService를 Riverpod Provider로 제공
final aiServiceProvider = Provider<IAIService>((ref) {
  return getIt<IAIService>();
});

/// GetIt에 등록된 GetRecommendedFriendsUseCase를 Riverpod Provider로 제공
final getRecommendedFriendsUseCaseProvider = Provider<GetRecommendedFriendsUseCase>((ref) {
  return getIt<GetRecommendedFriendsUseCase>();
});

/// GetIt에 등록된 SearchFriendsUseCase를 Riverpod Provider로 제공
final searchFriendsUseCaseProvider = Provider<SearchFriendsUseCase>((ref) {
  return getIt<SearchFriendsUseCase>();
});

/// GetIt에 등록된 SendFriendRequestUseCase를 Riverpod Provider로 제공
final sendFriendRequestUseCaseProvider = Provider<SendFriendRequestUseCase>((ref) {
  return getIt<SendFriendRequestUseCase>();
});

/// GetIt에 등록된 ToggleFollowUseCase를 Riverpod Provider로 제공
final toggleFollowUseCaseProvider = Provider<ToggleFollowUseCase>((ref) {
  return getIt<ToggleFollowUseCase>();
});
```

**After (Riverpod 3.x)** - ~14 lines (67% 감소)

```dart
// ========================================
// UseCase Providers (GetIt Wrapping)
// ========================================

/// GetChatList UseCase
@riverpod
GetChatListUseCase getChatListUseCase(Ref ref) => getIt<GetChatListUseCase>();

/// GetChatMessages UseCase
@riverpod
GetChatMessagesUseCase getChatMessagesUseCase(Ref ref) => getIt<GetChatMessagesUseCase>();

/// LoadMoreMessages UseCase
@riverpod
LoadMoreMessagesUseCase loadMoreMessagesUseCase(Ref ref) => getIt<LoadMoreMessagesUseCase>();

/// SendMessage UseCase
@riverpod
SendMessageUseCase sendMessageUseCase(Ref ref) => getIt<SendMessageUseCase>();

/// SearchMessages UseCase
@riverpod
SearchMessagesUseCase searchMessagesUseCase(Ref ref) => getIt<SearchMessagesUseCase>();

/// SendAIQuery UseCase
@riverpod
SendAIQueryUseCase sendAIQueryUseCase(Ref ref) => getIt<SendAIQueryUseCase>();

/// ChatMessageLifecycle Service
@riverpod
ChatMessageLifecycleService chatMessageLifecycleService(Ref ref) => getIt<ChatMessageLifecycleService>();

/// AI Service
@riverpod
IAIService aiService(Ref ref) => getIt<IAIService>();

/// GetRecommendedFriends UseCase
@riverpod
GetRecommendedFriendsUseCase getRecommendedFriendsUseCase(Ref ref) => getIt<GetRecommendedFriendsUseCase>();

/// SearchFriends UseCase
@riverpod
SearchFriendsUseCase searchFriendsUseCase(Ref ref) => getIt<SearchFriendsUseCase>();

/// SendFriendRequest UseCase
@riverpod
SendFriendRequestUseCase sendFriendRequestUseCase(Ref ref) => getIt<SendFriendRequestUseCase>();

/// ToggleFollow UseCase
@riverpod
ToggleFollowUseCase toggleFollowUseCase(Ref ref) => getIt<ToggleFollowUseCase>();
```

**변경 사항**:
1. `Provider<T>` → `@riverpod T useCaseName(Ref ref)`
2. 3줄 → 1줄 (주석 제외)
3. 코드 감소: 42 lines → 14 lines (67% 감소)
4. 사용법 변경 없음:
   ```dart
   // Before & After (동일)
   final useCase = ref.read(getChatListUseCaseProvider);
   ```

---

#### Post Feature 참조

**파일**: `lib/features/post/presentation/providers/post_providers.dart:49-52`

```dart
/// PostDetail UseCase Provider
@riverpod
GetPostDetailUseCase postDetailUseCase(Ref ref) {
  return getIt<GetPostDetailUseCase>();
}
```

**핵심 패턴**:
- GetIt 통합: `getIt<T>()` 호출
- 반환 타입 자동 추론
- Provider 이름: `postDetailUseCaseProvider` (자동 생성)

---

### 2.2 StreamProvider 마이그레이션 (4개)

#### 개념 설명

**Riverpod 2.x (Manual)**:
```dart
// StreamProvider.autoDispose.family 수동 정의
final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    // Stream 로직
  },
);
```

**Riverpod 3.x (Code Generation)**:
```dart
// @riverpod Stream<T> 함수로 자동 변환
@riverpod
Stream<List<Chat>> chatListStream(
  Ref ref,
  ChatListParams params,
) async* {
  // Stream 로직 (동일)
}
```

**차이점**:
- 2.x: `StreamProvider.autoDispose.family<T, P>()` 명시
- 3.x: `@riverpod` + 함수 파라미터로 family 자동 생성
- 3.x: autoDispose는 기본값

---

#### 예제 1: chatListStream 변환

**Before (Riverpod 2.x)** - `chat_providers.dart:86-109` (24 lines)

```dart
/// 채팅 목록 실시간 스트림 Provider
///
/// **Riverpod StreamProvider.autoDispose.family 패턴 적용**:
/// - StreamProvider.autoDispose.family
/// - 즉시 emit으로 로딩 개선
/// - keepAlive()로 중복 리스너 방지
final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    final getChatListUseCase = ref.watch(getChatListUseCaseProvider);

    await for (final either in getChatListUseCase.execute(
      userId: params.userId,
      limit: params.limit,
    )) {
      yield* either.fold(
        (failure) => Stream<List<Chat>>.error(failure),
        (chats) async* {
          yield chats;
        },
      );
    }

    ref.keepAlive();
  },
);
```

**After (Riverpod 3.x)** - ~20 lines (유사, 더 간결한 구문)

```dart
/// 채팅 목록 실시간 스트림 Provider
///
/// **Riverpod 3.x StreamProvider 패턴**:
/// - @riverpod annotation으로 자동 family
/// - autoDispose 기본값 (keepAlive 필요 시 추가)
/// - 3-Layer 캐싱 통합
@riverpod
Stream<List<Chat>> chatListStream(
  Ref ref,
  ChatListParams params,
) async* {
  final getChatListUseCase = ref.watch(getChatListUseCaseProvider);

  await for (final either in getChatListUseCase.execute(
    userId: params.userId,
    limit: params.limit,
  )) {
    yield* either.fold(
      (failure) => Stream<List<Chat>>.error(failure),
      (chats) async* {
        yield chats;
      },
    );
  }

  // keepAlive는 필요 시 추가
  // ref.keepAlive();
}
```

**변경 사항**:
1. `StreamProvider.autoDispose.family<List<Chat>, ChatListParams>` 제거
2. `@riverpod` + 함수 정의
3. 파라미터가 자동 family
4. Provider 이름: `chatListStreamProvider` (자동 생성, 동일)
5. 사용법 변경 없음:
   ```dart
   // Before & After (동일)
   final asyncChats = ref.watch(chatListStreamProvider(
     ChatListParams(userId: currentUserUid, limit: 50),
   ));
   ```

---

#### 예제 2: chatMessagesStream 변환

**Before (Riverpod 2.x)** - `chat_providers.dart:118-140` (23 lines)

```dart
/// 채팅 메시지 실시간 스트림 Provider
final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<Message>, ChatMessagesParams>(
  (ref, params) async* {
    final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);

    await for (final either in getChatMessagesUseCase.execute(
      chatId: params.chatId,
      limit: params.limit,
    )) {
      yield* either.fold(
        (failure) => Stream<List<Message>>.error(failure),
        (messages) async* {
          yield messages;
        },
      );
    }

    ref.keepAlive();
  },
);
```

**After (Riverpod 3.x)**

```dart
/// 채팅 메시지 실시간 스트림 Provider
@riverpod
Stream<List<Message>> chatMessagesStream(
  Ref ref,
  ChatMessagesParams params,
) async* {
  final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);

  await for (final either in getChatMessagesUseCase.execute(
    chatId: params.chatId,
    limit: params.limit,
  )) {
    yield* either.fold(
      (failure) => Stream<List<Message>>.error(failure),
      (messages) async* {
        yield messages;
      },
    );
  }
}
```

---

#### 예제 3-4: Friends Stream Provider 변환

**Before (Riverpod 2.x)** - 2개 StreamProvider (총 97 lines)

```dart
// recommendedFriendsStreamProvider (64 lines)
final recommendedFriendsStreamProvider =
    StreamProvider.autoDispose.family<List<UserProfile>, RecommendedFriendsParams>(
  (ref, params) async* {
    // ... 로직
  },
);

// searchFriendsStreamProvider (33 lines)
final searchFriendsStreamProvider =
    StreamProvider.autoDispose.family<List<UserProfile>, SearchFriendsParams>(
  (ref, params) async* {
    // ... 로직
  },
);
```

**After (Riverpod 3.x)**

```dart
/// 추천 친구 목록 실시간 스트림
@riverpod
Stream<List<UserProfile>> recommendedFriendsStream(
  Ref ref,
  RecommendedFriendsParams params,
) async* {
  final useCase = ref.watch(getRecommendedFriendsUseCaseProvider);

  await for (final either in useCase.execute(
    currentUserId: params.currentUserId,
    limit: params.limit,
  )) {
    yield* either.fold(
      (failure) => Stream<List<UserProfile>>.error(failure),
      (friends) async* {
        yield friends;
      },
    );
  }
}

/// 친구 검색 실시간 스트림
@riverpod
Stream<List<UserProfile>> searchFriendsStream(
  Ref ref,
  SearchFriendsParams params,
) async* {
  final useCase = ref.watch(searchFriendsUseCaseProvider);

  await for (final either in useCase.execute(
    currentUserId: params.currentUserId,
    query: params.query,
  )) {
    yield* either.fold(
      (failure) => Stream<List<UserProfile>>.error(failure),
      (results) async* {
        yield results;
      },
    );
  }
}
```

---

#### Post Feature 참조

**파일**: `lib/features/post/presentation/providers/post_providers.dart:76-100`

```dart
@riverpod
Stream<PostDisplay?> postDetailStream(
  Ref ref,
  String postId,
) async* {
  final cacheService = ref.watch(postCacheServiceProvider);
  final useCase = ref.watch(postDetailUseCaseProvider);

  // Phase 3: Emit cached post immediately
  final cachedPost = await cacheService.getPost(postId);
  if (cachedPost != null) {
    yield cachedPost; // <30ms response
  }

  // Subscribe to real-time Firestore updates
  yield* useCase.getPostStream(postId: postId).handleError((error) {
    if (error is! PostFailure) {
      throw PostFailure.unexpected(
        message: 'Unexpected error in post detail stream',
        error: error,
      );
    }
    throw error;
  });
}
```

**핵심 패턴**:
- `@riverpod` Stream<T> 함수
- 파라미터가 자동 family
- Cache-first 패턴 통합

---

### 2.3 Computed Provider 마이그레이션 (2개)

#### 개념 설명

**Riverpod 2.x (Manual)**:
```dart
// Provider.autoDispose.family로 계산 Provider
final unreadChatCountProvider = Provider.autoDispose.family<int, String>(
  (ref, userId) {
    final asyncChats = ref.watch(chatListStreamProvider(...));
    return asyncChats.when(
      data: (chats) => chats.where((chat) => !chat.isRead).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  },
);
```

**Riverpod 3.x (Code Generation)**:
```dart
// @riverpod 계산 함수로 자동 변환
@riverpod
int unreadChatCount(Ref ref, String userId) {
  final asyncChats = ref.watch(chatListStreamProvider(...));
  return asyncChats.when(
    data: (chats) => chats.where((chat) => !chat.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
```

---

#### 예제 1: unreadChatCount 변환

**Before (Riverpod 2.x)** - `chat_providers.dart:149-162` (14 lines)

```dart
/// 읽지 않은 채팅 개수 Provider
///
/// **Computed Provider 패턴**:
/// - chatListStreamProvider를 watch하여 자동 업데이트
/// - 읽지 않은 채팅만 필터링
final unreadChatCountProvider = Provider.autoDispose.family<int, String>(
  (ref, userId) {
    final asyncChats = ref.watch(chatListStreamProvider(
      ChatListParams(userId: userId, limit: 50),
    ));

    return asyncChats.when(
      data: (chats) => chats.where((chat) => !chat.isRead).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  },
);
```

**After (Riverpod 3.x)**

```dart
/// 읽지 않은 채팅 개수 Provider
///
/// **Riverpod 3.x Computed Provider 패턴**:
/// - chatListStreamProvider를 watch하여 자동 업데이트
/// - 읽지 않은 채팅만 필터링
@riverpod
int unreadChatCount(Ref ref, String userId) {
  final asyncChats = ref.watch(chatListStreamProvider(
    ChatListParams(userId: userId, limit: 50),
  ));

  return asyncChats.when(
    data: (chats) => chats.where((chat) => !chat.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
```

**변경 사항**:
1. `Provider.autoDispose.family<int, String>` 제거
2. `@riverpod` + 반환 타입 `int`
3. Provider 이름: `unreadChatCountProvider` (자동 생성, 동일)

---

#### 예제 2: aiChat 변환

**Before (Riverpod 2.x)** - `chat_providers.dart:169-191` (23 lines)

```dart
/// AI 채팅방 찾기 Provider
///
/// **Computed Provider 패턴**:
/// - AI 채팅방만 필터링
/// - 없으면 null 반환
final aiChatProvider = Provider.autoDispose.family<Chat?, String>(
  (ref, userId) {
    final asyncChats = ref.watch(chatListStreamProvider(
      ChatListParams(userId: userId, limit: 50),
    ));

    return asyncChats.when(
      data: (chats) {
        try {
          return chats.firstWhere(
            (chat) =>
                chat.participantIds.contains(AppConstants.aiUserId) ||
                chat.chatType == 'aiChat',
          );
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  },
);
```

**After (Riverpod 3.x)**

```dart
/// AI 채팅방 찾기 Provider
///
/// **Riverpod 3.x Computed Provider 패턴**:
/// - AI 채팅방만 필터링
/// - 없으면 null 반환
@riverpod
Chat? aiChat(Ref ref, String userId) {
  final asyncChats = ref.watch(chatListStreamProvider(
    ChatListParams(userId: userId, limit: 50),
  ));

  return asyncChats.when(
    data: (chats) {
      try {
        return chats.firstWhere(
          (chat) =>
              chat.participantIds.contains(AppConstants.aiUserId) ||
              chat.chatType == 'aiChat',
        );
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
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

[INFO] Running build...
[INFO] 1.2s elapsed, 0/3 actions completed.
[INFO] 2.5s elapsed, 1/3 actions completed.
[INFO] Running build completed, took 2.6s

[INFO] Succeeded after 2.6s with 1 outputs (3 actions)
```

**생성된 파일**: `lib/features/chat/presentation/providers/chat_providers.g.dart`

---

#### Import 문 수정

**chat_providers.dart** 최종 Import:

```dart
// ===== chat_providers.dart =====
import 'package:riverpod_annotation/riverpod_annotation.dart';  // ✅ 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/app/di.dart';
import '/features/chat/domain/entities/chat.dart';
import '/features/chat/domain/entities/message.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/chat/domain/usecases/get_chat_list_usecase.dart';
import '/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '/features/chat/domain/usecases/load_more_messages_usecase.dart';
import '/features/chat/domain/usecases/send_message_usecase.dart';
import '/features/chat/domain/usecases/search_messages_usecase.dart';
import '/features/chat/domain/usecases/send_ai_query_usecase.dart';
import '/features/chat/domain/usecases/get_recommended_friends_usecase.dart';
import '/features/chat/domain/usecases/search_friends_usecase.dart';
import '/features/chat/domain/usecases/send_friend_request_usecase.dart';
import '/features/chat/domain/usecases/toggle_follow_usecase.dart';
import '/features/chat/data/services/chat_message_lifecycle_service.dart';
import '/features/chat/domain/ports/i_ai_service.dart';
import '/core/constants/app_constants.dart';
import 'chat_params.dart';

part 'chat_providers.g.dart'; // ✅ Part directive

// ... Provider 정의들
```

---

#### flutter analyze 실행

**명령어**:
```bash
flutter analyze lib/features/chat/
```

**예상 출력 (성공)**:
```
Analyzing chat...
No issues found! (ran in 1.2s)
```

---

## Appendix A: Provider 변환 매트릭스

### 현재 Chat Feature Provider 목록

**chat_providers.dart** (294 lines):

| Provider 이름 | 타입 | 라인 | 설명 |
|--------------|------|------|------|
| `getChatListUseCaseProvider` | Provider | L26-28 | GetChatList UseCase |
| `getChatMessagesUseCaseProvider` | Provider | L31-33 | GetChatMessages UseCase |
| `loadMoreMessagesUseCaseProvider` | Provider | L36-38 | LoadMoreMessages UseCase |
| `sendMessageUseCaseProvider` | Provider | L41-43 | SendMessage UseCase |
| `searchMessagesUseCaseProvider` | Provider | L46-48 | SearchMessages UseCase |
| `sendAIQueryUseCaseProvider` | Provider | L51-53 | SendAIQuery UseCase |
| `chatMessageLifecycleServiceProvider` | Provider | L56-58 | ChatMessageLifecycle Service |
| `aiServiceProvider` | Provider | L61-63 | AI Service |
| `getRecommendedFriendsUseCaseProvider` | Provider | L198-200 | GetRecommendedFriends UseCase |
| `searchFriendsUseCaseProvider` | Provider | L203-205 | SearchFriends UseCase |
| `sendFriendRequestUseCaseProvider` | Provider | L208-210 | SendFriendRequest UseCase |
| `toggleFollowUseCaseProvider` | Provider | L213-215 | ToggleFollow UseCase |
| `chatListStreamProvider` | StreamProvider.family | L86-109 | 채팅 목록 스트림 |
| `chatMessagesStreamProvider` | StreamProvider.family | L118-140 | 채팅 메시지 스트림 |
| `recommendedFriendsStreamProvider` | StreamProvider.family | L240-259 | 추천 친구 스트림 |
| `searchFriendsStreamProvider` | StreamProvider.family | L273-293 | 친구 검색 스트림 |
| `unreadChatCountProvider` | Provider.family | L149-162 | 읽지 않은 채팅 개수 |
| `aiChatProvider` | Provider.family | L169-191 | AI 채팅방 찾기 |

**총 Provider 수**: 18개 (10 UseCases + 4 Streams + 2 Computed + 2 Services)

---

### 변환 후 Provider 목록 (Riverpod 3.x)

**chat_providers.dart** (예상 ~150 lines):

| Provider 이름 | 타입 | 함수명 | 설명 |
|--------------|------|--------|------|
| `getChatListUseCaseProvider` | @riverpod | getChatListUseCase | UseCase Provider (자동 생성) |
| ... (10개 UseCase) | @riverpod | ... | UseCase Providers (자동 생성) |
| `chatListStreamProvider` | @riverpod Stream | chatListStream | 채팅 목록 스트림 (자동 family) |
| `chatMessagesStreamProvider` | @riverpod Stream | chatMessagesStream | 채팅 메시지 스트림 (자동 family) |
| `recommendedFriendsStreamProvider` | @riverpod Stream | recommendedFriendsStream | 추천 친구 스트림 (자동 family) |
| `searchFriendsStreamProvider` | @riverpod Stream | searchFriendsStream | 친구 검색 스트림 (자동 family) |
| `unreadChatCountProvider` | @riverpod int | unreadChatCount | 읽지 않은 채팅 개수 (자동 family) |
| `aiChatProvider` | @riverpod Chat? | aiChat | AI 채팅방 찾기 (자동 family) |

**총 Provider 수**: 18개 (동일, 자동 생성)

---

### 코드 감소 통계

| 항목 | Before (2.x) | After (3.x) | 감소율 |
|------|--------------|-------------|--------|
| **총 라인 수** | 294 lines | ~150 lines | **49%** |
| **UseCase Provider** | 42 lines (10개 x 3줄) | 14 lines (10개 x 1줄) | **67%** |
| **StreamProvider** | ~120 lines | ~100 lines | **17%** |
| **Computed Provider** | ~37 lines | ~30 lines | **19%** |
| **Import 문** | 20 lines | 22 lines (+2, part 추가) | - |
| **수동 코드** | 294 lines | ~150 lines | **49%** |
| **자동 생성 코드** | 0 lines | .g.dart 파일 | - |

**예상 결과**:
- 수동 작성 코드: 294 lines → ~150 lines (49% 감소)
- 보일러플레이트: UseCase 42 lines → 14 lines (67% 감소)
- 유지보수성: Manual Provider → @riverpod annotation
- 타입 안정성: 수동 타입 → 자동 타입 추론

---

### 변환 체크리스트

#### Phase 2 완료 확인

- [ ] **chat_providers.dart 변환 완료**
  - [ ] Import 문 수정 (riverpod_annotation 추가)
  - [ ] Part directive 추가 (`part 'chat_providers.g.dart';`)
  - [ ] 10개 UseCase Provider → @riverpod 함수로 변환
  - [ ] 4개 StreamProvider → @riverpod Stream<T> 함수로 변환
  - [ ] 2개 Computed Provider → @riverpod 계산 함수로 변환
  - [ ] 모든 Provider 정의 제거 (final ... = Provider...)

- [ ] **코드 생성 완료**
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
  - [ ] `chat_providers.g.dart` 생성 확인
  - [ ] 생성 파일 오류 없음

- [ ] **컴파일 확인**
  - [ ] `flutter analyze lib/features/chat/` 실행
  - [ ] 에러 없음 확인
  - [ ] Warning 확인 및 해결

- [ ] **문서 업데이트** (Phase 7에서 상세 수행)
  - [ ] 주석 추가 (마이그레이션 내역)
  - [ ] README.md 업데이트 예정 표시

---

## 다음 단계: Phase 3-7

Phase 1-2를 완료했다면, 다음 단계로 진행하세요:

**Phase 3: Widget Integration**
- ConsumerWidget 업데이트
- ref.watch() / ref.read() 패턴 적용
- flutter_chat_ui 통합 확인

**Phase 4: Code Generation**
- build_runner 최종 실행
- .g.dart 파일 검증
- Import 문 정리

**Phase 5: Testing & Verification**
- Unit 테스트 작성
- 3-Layer 캐싱 동작 확인
- flutter_chat_ui 통합 테스트

**Phase 6: Legacy Code Cleanup**
- 주석 처리된 코드 제거
- 불필요한 import 정리

**Phase 7: Documentation**
- README.md 업데이트 (Riverpod 2.x → 3.x)
- Provider 문서화
- 마이그레이션 로그 작성

---

**다음 문서**: `RIVERPOD_3X_MIGRATION_PHASE_3_7.md`

---

**작성**: 2025-11-06
**참조 구현**: Post Feature (Riverpod 3.x), Creation Feature (Riverpod 3.x)
**예상 작업 시간**: Phase 1 (15분) + Phase 2 (1-1.5시간) = **1.25-1.75시간**
