# Chat Feature - Phase 1: Either Pattern 완전 적용 계획서

> **목표**: Repository 레이어에 Either 패턴 적용으로 PHASE 1을 100% 완료
> **현재 진행률**: 75% → 100% (나머지 25% 완료)
> **예상 소요 시간**: 2-3시간
> **작성일**: 2025-01-31

---

## 📊 현재 상태 분석

### ✅ 이미 적용된 부분 (75%)

#### 1. Presentation Layer (Provider) - 100% 완료
**파일**: `presentation/providers/chat_providers.dart:87-141`

```dart
// ✅ Either 패턴 완벽 적용
final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    final getChatListUseCase = ref.watch(getChatListUseCaseProvider);

    await for (final either in getChatListUseCase.execute(
      userId: params.userId,
      limit: params.limit,
    )) {
      // Either.fold()로 에러 처리
      yield* either.fold(
        (failure) => Stream<List<Chat>>.error(failure), // Left: 에러
        (chats) async* {
          yield chats; // Right: 성공
        },
      );
    }

    ref.keepAlive();
  },
);
```

**상태**: ✅ 완료 - 수정 불필요

#### 2. Domain Layer (UseCase) - 100% 완료 (하지만 개선 필요)
**파일**: `domain/usecases/get_chat_list_usecase.dart:45-72`

```dart
// ✅ Either 반환하지만 .map() 변환 사용 중
Stream<Either<ChatFailure, List<Chat>>> execute({
  required String userId,
  int limit = 50,
}) {
  try {
    if (userId.isEmpty) {
      return Stream.value(left(const ChatNotFound()));
    }

    // Repository에서 Stream<List<Chat>> 받음
    final chatsStream = _chatRepository.queryChats(
      userId: userId,
      limit: limit,
      orderBy: 'lastMessageAt',
      descending: true,
    );

    // .map()으로 Either 변환 (중간 단계)
    return chatsStream.map((chats) => right<ChatFailure, List<Chat>>(chats));
  } catch (e) {
    return Stream.value(left(const ChatLoadFailed()));
  }
}
```

**문제점**:
- Repository가 Either를 반환하지 않아 UseCase에서 `.map()` 변환 필요
- 불필요한 중간 변환 로직
- Repository의 에러가 UseCase의 catch로만 잡힘

### ❌ 미적용 부분 (25%)

#### 3. Repository Interface - 0% 적용
**파일**: `domain/repositories/i_chat_repository.dart:22-40`

```dart
// ❌ Either 없이 순수 도메인 엔티티 반환
abstract class IChatRepository {
  /// 채팅 목록 실시간 스트림
  Stream<List<Chat>> queryChats({  // ← Either 없음!
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  /// 채팅 메시지 실시간 스트림
  Stream<List<Message>> queryMessagesByChatId({  // ← Either 없음!
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  // CRUD 메서드는 Either 적용됨 ✅
  Future<Either<ChatFailure, Chat>> getChat(String chatId);
  Future<Either<ChatFailure, Unit>> createChat({...});
  Future<Either<ChatFailure, Unit>> sendMessage({...});
  // ...
}
```

**문제점**:
- Query 메서드만 Either 미적용 (2개 메서드)
- CRUD 메서드는 이미 Either 적용됨 (8개 메서드)
- 일관성 부족

#### 4. Repository Implementation - 0% 적용
**파일**: `data/repositories/chat_repository_impl.dart:84-110`

```dart
// ❌ Either 없이 직접 yield
@override
Stream<List<Chat>> queryChats({
  required String userId,
  int limit = 50,
  String? orderBy,
  bool descending = true,
}) async* {
  // 1. Cache-First 패턴
  final cachedChats = await _cacheService.getChatList(userId);
  if (cachedChats != null && cachedChats.isNotEmpty) {
    yield cachedChats; // ❌ 직접 yield
  }

  // 2. Firestore Stream
  await for (final dtos in _remoteDatasource.queryChats(
    userId: userId,
    limit: limit,
    orderBy: orderBy,
    descending: descending,
  )) {
    final chats = ChatMapper.toEntityList(dtos);

    // 3. Write-Through Cache
    await _cacheService.setChatList(userId, chats);

    yield chats; // ❌ 직접 yield
  }
}
```

**문제점**:
- `yield chats` 대신 `yield right(chats)` 사용해야 함
- 에러 처리 누락 (try-catch로 left(failure) 반환해야)
- Cache 에러와 Firestore 에러 구분 안됨

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### Repository Interface

```dart
// ❌ Before
Stream<List<Chat>> queryChats({...});
Stream<List<Message>> queryMessagesByChatId({...});

// ✅ After
Stream<Either<ChatFailure, List<Chat>>> queryChats({...});
Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({...});
```

#### Repository Implementation

```dart
// ❌ Before
Stream<List<Chat>> queryChats({...}) async* {
  final cachedChats = await _cacheService.getChatList(userId);
  if (cachedChats != null && cachedChats.isNotEmpty) {
    yield cachedChats; // 직접 yield
  }

  await for (final dtos in _remoteDatasource.queryChats(...)) {
    final chats = ChatMapper.toEntityList(dtos);
    yield chats; // 직접 yield
  }
}

// ✅ After
Stream<Either<ChatFailure, List<Chat>>> queryChats({...}) async* {
  try {
    // 1. Cache 로드 (Either 래핑)
    final cachedChats = await _cacheService.getChatList(userId);
    if (cachedChats != null && cachedChats.isNotEmpty) {
      yield right(cachedChats); // ✅ Either 래핑
    }

    // 2. Firestore Stream (Either 래핑)
    await for (final dtos in _remoteDatasource.queryChats(...)) {
      final chats = ChatMapper.toEntityList(dtos);
      await _cacheService.setChatList(userId, chats);
      yield right(chats); // ✅ Either 래핑
    }
  } catch (e, stackTrace) {
    // 3. 에러 처리
    yield left(ChatFailure.unexpected(
      error: e.toString(),
      stackTrace: stackTrace,
    ));
  }
}
```

#### UseCase (단순화)

```dart
// ❌ Before (불필요한 .map() 변환)
Stream<Either<ChatFailure, List<Chat>>> execute({...}) {
  try {
    final chatsStream = _chatRepository.queryChats(...);

    // .map()으로 Either 변환
    return chatsStream.map((chats) => right<ChatFailure, List<Chat>>(chats));
  } catch (e) {
    return Stream.value(left(const ChatLoadFailed()));
  }
}

// ✅ After (패스스루)
Stream<Either<ChatFailure, List<Chat>>> execute({...}) async* {
  // 입력 검증만 수행
  if (userId.isEmpty) {
    yield left(const ChatNotFound());
    return;
  }

  // Repository에서 이미 Either를 반환하므로 그대로 전달
  await for (final either in _chatRepository.queryChats(...)) {
    yield either; // ✅ 그대로 전달
  }
}
```

---

## 📝 단계별 구현 계획

### Step 1: Repository Interface 수정 (5분)

**파일**: `lib/features/chat/domain/repositories/i_chat_repository.dart`

**작업**:
1. `queryChats()` 시그니처 변경
2. `queryMessagesByChatId()` 시그니처 변경

**Before**:
```dart
abstract class IChatRepository {
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });
}
```

**After**:
```dart
abstract class IChatRepository {
  /// 채팅 목록 실시간 스트림 (PHASE 1: Either Pattern)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Chat>>>`:
  ///   - Left: ChatFailure (캐시/네트워크 에러)
  ///   - Right: List<Chat> (성공)
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  /// 채팅 메시지 실시간 스트림 (PHASE 1: Either Pattern)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Message>>>`:
  ///   - Left: ChatFailure (캐시/네트워크 에러)
  ///   - Right: List<Message> (성공)
  Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });
}
```

**검증**:
```bash
flutter analyze lib/features/chat/domain/repositories/i_chat_repository.dart
```

---

### Step 2: Repository Implementation 수정 (30분)

**파일**: `lib/features/chat/data/repositories/chat_repository_impl.dart`

#### 2.1. queryChats() 메서드 수정

**Before** (line 84-110):
```dart
@override
Stream<List<Chat>> queryChats({
  required String userId,
  int limit = 50,
  String? orderBy,
  bool descending = true,
}) async* {
  final cachedChats = await _cacheService.getChatList(userId);
  if (cachedChats != null && cachedChats.isNotEmpty) {
    yield cachedChats;
  }

  await for (final dtos in _remoteDatasource.queryChats(
    userId: userId,
    limit: limit,
    orderBy: orderBy,
    descending: descending,
  )) {
    final chats = ChatMapper.toEntityList(dtos);
    await _cacheService.setChatList(userId, chats);
    yield chats;
  }
}
```

**After**:
```dart
@override
Stream<Either<ChatFailure, List<Chat>>> queryChats({
  required String userId,
  int limit = 50,
  String? orderBy,
  bool descending = true,
}) async* {
  try {
    // ✅ PHASE 3: L1/L2/L3 Cache-First 패턴 유지
    final cachedChats = await _cacheService.getChatList(userId);
    if (cachedChats != null && cachedChats.isNotEmpty) {
      yield right(cachedChats); // ✅ Either 래핑
    }

    // ✅ Firestore 실시간 스트림
    await for (final dtos in _remoteDatasource.queryChats(
      userId: userId,
      limit: limit,
      orderBy: orderBy ?? 'lastMessageAt',
      descending: descending,
    )) {
      final chats = ChatMapper.toEntityList(dtos);

      // ✅ PHASE 3: Write-Through Cache 유지
      await _cacheService.setChatList(userId, chats);

      yield right(chats); // ✅ Either 래핑
    }
  } on FirebaseException catch (e, stackTrace) {
    // Firebase 에러 처리
    yield left(ChatFailure.unexpected(
      error: 'Firestore error: ${e.code} - ${e.message}',
      stackTrace: stackTrace,
    ));
  } on Exception catch (e, stackTrace) {
    // 일반 에러 처리 (Cache 에러 포함)
    yield left(ChatFailure.unexpected(
      error: e.toString(),
      stackTrace: stackTrace,
    ));
  }
}
```

#### 2.2. queryMessagesByChatId() 메서드 수정

**Before**:
```dart
@override
Stream<List<Message>> queryMessagesByChatId({
  required String chatId,
  int limit = 30,
  String? orderBy,
  bool descending = true,
}) async* {
  final cachedMessages = await _cacheService.getMessages(chatId);
  if (cachedMessages != null && cachedMessages.isNotEmpty) {
    yield cachedMessages;
  }

  await for (final dtos in _remoteDatasource.queryMessagesByChatId(
    chatId: chatId,
    limit: limit,
    orderBy: orderBy,
    descending: descending,
  )) {
    final messages = MessageMapper.toEntityList(dtos);
    await _cacheService.setMessages(chatId, messages);
    yield messages;
  }
}
```

**After**:
```dart
@override
Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({
  required String chatId,
  int limit = 30,
  String? orderBy,
  bool descending = true,
}) async* {
  try {
    // ✅ PHASE 3: Cache-First 패턴 유지
    final cachedMessages = await _cacheService.getMessages(chatId);
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      yield right(cachedMessages); // ✅ Either 래핑
    }

    // ✅ Firestore 실시간 스트림
    await for (final dtos in _remoteDatasource.queryMessagesByChatId(
      chatId: chatId,
      limit: limit,
      orderBy: orderBy ?? 'timeStamp',
      descending: descending,
    )) {
      final messages = MessageMapper.toEntityList(dtos);

      // ✅ PHASE 3: Write-Through Cache 유지
      await _cacheService.setMessages(chatId, messages);

      yield right(messages); // ✅ Either 래핑
    }
  } on FirebaseException catch (e, stackTrace) {
    yield left(ChatFailure.unexpected(
      error: 'Firestore error: ${e.code} - ${e.message}',
      stackTrace: stackTrace,
    ));
  } on Exception catch (e, stackTrace) {
    yield left(ChatFailure.unexpected(
      error: e.toString(),
      stackTrace: stackTrace,
    ));
  }
}
```

**검증**:
```bash
flutter analyze lib/features/chat/data/repositories/chat_repository_impl.dart
```

---

### Step 3: UseCase 단순화 (20분)

#### 3.1. GetChatListUseCase 수정

**파일**: `lib/features/chat/domain/usecases/get_chat_list_usecase.dart`

**Before** (line 45-72):
```dart
Stream<Either<ChatFailure, List<Chat>>> execute({
  required String userId,
  int limit = 50,
}) {
  try {
    if (userId.isEmpty) {
      return Stream.value(left(const ChatNotFound()));
    }

    final chatsStream = _chatRepository.queryChats(
      userId: userId,
      limit: limit,
      orderBy: 'lastMessageAt',
      descending: true,
    );

    // .map()으로 Either 변환 (불필요)
    return chatsStream.map((chats) => right<ChatFailure, List<Chat>>(chats));
  } catch (e) {
    return Stream.value(left(const ChatLoadFailed()));
  }
}
```

**After**:
```dart
/// 실시간 채팅 목록 스트림 반환 (PHASE 1: Either Pattern 완료)
///
/// **Parameters**:
/// - [userId]: 현재 사용자 ID
/// - [limit]: 한 번에 로드할 채팅 개수 (기본값: 50)
///
/// **Returns**:
/// - `Stream<Either<ChatFailure, List<Chat>>>`: 채팅 목록의 실시간 스트림
///
/// **PHASE 1 완료**:
/// - Repository부터 Either 반환 (패스스루 패턴)
/// - 불필요한 .map() 변환 제거
/// - 입력 검증만 UseCase에서 수행
Stream<Either<ChatFailure, List<Chat>>> execute({
  required String userId,
  int limit = 50,
}) async* {
  // ✅ 입력 검증
  if (userId.isEmpty) {
    yield left(const ChatNotFound());
    return;
  }

  // ✅ Repository에서 이미 Either 반환하므로 그대로 전달
  await for (final either in _chatRepository.queryChats(
    userId: userId,
    limit: limit,
    orderBy: 'lastMessageAt',
    descending: true,
  )) {
    yield either; // 패스스루
  }
}
```

#### 3.2. GetChatMessagesUseCase 수정

**파일**: `lib/features/chat/domain/usecases/get_chat_messages_usecase.dart`

**Before** (line 47-74):
```dart
Stream<Either<ChatFailure, List<Message>>> execute({
  required String chatId,
  int limit = 30,
}) {
  try {
    if (chatId.isEmpty) {
      return Stream.value(left(const InvalidMessageContent()));
    }

    final messagesStream = _chatRepository.queryMessagesByChatId(
      chatId: chatId,
      limit: limit,
      orderBy: 'timeStamp',
      descending: false,
    );

    return messagesStream.map((messages) => right<ChatFailure, List<Message>>(messages));
  } catch (e) {
    return Stream.value(left(const MessageLoadFailed()));
  }
}
```

**After**:
```dart
/// 실시간 메시지 스트림 반환 (PHASE 1: Either Pattern 완료)
///
/// **Parameters**:
/// - [chatId]: 채팅방 ID
/// - [limit]: 한 번에 로드할 메시지 개수 (기본값: 30)
///
/// **Returns**:
/// - `Stream<Either<ChatFailure, List<Message>>>`: 메시지 목록의 실시간 스트림
///
/// **PHASE 1 완료**:
/// - Repository부터 Either 반환 (패스스루 패턴)
/// - 불필요한 .map() 변환 제거
Stream<Either<ChatFailure, List<Message>>> execute({
  required String chatId,
  int limit = 30,
}) async* {
  // ✅ 입력 검증
  if (chatId.isEmpty) {
    yield left(const InvalidMessageContent());
    return;
  }

  // ✅ Repository에서 이미 Either 반환하므로 그대로 전달
  await for (final either in _chatRepository.queryMessagesByChatId(
    chatId: chatId,
    limit: limit,
    orderBy: 'timeStamp',
    descending: false,
  )) {
    yield either; // 패스스루
  }
}
```

**검증**:
```bash
flutter analyze lib/features/chat/domain/usecases/
```

---

### Step 4: Provider 확인 (5분)

**파일**: `lib/features/chat/presentation/providers/chat_providers.dart`

**현재 상태**: ✅ 이미 완벽하게 작동 중

```dart
// line 87-110: chatListStreamProvider
final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    final getChatListUseCase = ref.watch(getChatListUseCaseProvider);

    await for (final either in getChatListUseCase.execute(
      userId: params.userId,
      limit: params.limit,
    )) {
      // ✅ Either.fold()로 에러 처리 (이미 완벽)
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

**작업**: 수정 불필요 (이미 완료됨)

---

## ✅ 검증 체크리스트

### 컴파일 타임 검증

```bash
# 1. Repository 인터페이스 검증
flutter analyze lib/features/chat/domain/repositories/i_chat_repository.dart

# 2. Repository 구현체 검증
flutter analyze lib/features/chat/data/repositories/chat_repository_impl.dart

# 3. UseCase 검증
flutter analyze lib/features/chat/domain/usecases/get_chat_list_usecase.dart
flutter analyze lib/features/chat/domain/usecases/get_chat_messages_usecase.dart

# 4. Provider 검증
flutter analyze lib/features/chat/presentation/providers/chat_providers.dart

# 5. 전체 Chat Feature 검증
flutter analyze lib/features/chat/
```

### 런타임 검증

#### 1. 캐시 히트 시나리오
```dart
// 예상 동작:
// 1. UnifiedCacheService에서 캐시 데이터 반환
// 2. Repository: yield right(cachedChats)
// 3. UseCase: yield either (패스스루)
// 4. Provider: either.fold() 성공 분기
// 5. UI: 즉시 채팅 목록 표시
```

**테스트**:
1. 앱 실행 → 채팅 목록 로드
2. 앱 종료 → 재시작
3. 캐시된 데이터 즉시 표시 확인
4. 로그 확인: "✅ Cache hit: L1/L2/L3"

#### 2. 네트워크 에러 시나리오
```dart
// 예상 동작:
// 1. Firestore 연결 실패
// 2. Repository: catch (FirebaseException) → yield left(ChatFailure)
// 3. UseCase: yield either (에러 그대로 전달)
// 4. Provider: either.fold() 에러 분기
// 5. UI: Stream<T>.error() 발생 → AsyncValue.error
```

**테스트**:
1. 기기 비행기 모드 활성화
2. 채팅 목록 새로고침
3. 에러 메시지 표시 확인
4. 로그 확인: "❌ Firebase error: unavailable"

#### 3. 정상 스트림 시나리오
```dart
// 예상 동작:
// 1. Firestore 실시간 스트림 구독
// 2. Repository: yield right(chats) (지속적)
// 3. UseCase: yield either (패스스루)
// 4. Provider: either.fold() 성공 분기 (지속적)
// 5. UI: 실시간 업데이트
```

**테스트**:
1. 채팅 목록 열기
2. 다른 기기에서 메시지 전송
3. 실시간 업데이트 확인
4. 로그 확인: "✅ Firestore stream update"

---

## 🔄 롤백 계획

### Git 커밋 전략

```bash
# 1. 현재 상태 백업
git checkout -b backup/before-phase1-completion
git commit -am "backup: PHASE 1 적용 전 상태"

# 2. 작업 브랜치 생성
git checkout -b feature/chat-phase1-completion
```

### 단계별 커밋

```bash
# Step 1: Repository Interface
git add lib/features/chat/domain/repositories/i_chat_repository.dart
git commit -m "refactor(chat): Apply Either pattern to Repository interface (PHASE 1)

- queryChats(): Stream<List<Chat>> → Stream<Either<ChatFailure, List<Chat>>>
- queryMessagesByChatId(): Stream<List<Message>> → Stream<Either<ChatFailure, List<Message>>>
- Add comprehensive docstrings"

# Step 2: Repository Implementation
git add lib/features/chat/data/repositories/chat_repository_impl.dart
git commit -m "refactor(chat): Apply Either pattern to Repository implementation (PHASE 1)

- Wrap all yields with right()
- Add try-catch for error handling with left()
- Maintain PHASE 3 cache-first pattern
- Add FirebaseException specific handling"

# Step 3: UseCase Simplification
git add lib/features/chat/domain/usecases/get_chat_list_usecase.dart
git add lib/features/chat/domain/usecases/get_chat_messages_usecase.dart
git commit -m "refactor(chat): Simplify UseCases with passthrough pattern (PHASE 1)

- Remove unnecessary .map() transformation
- Repository already returns Either
- Keep input validation only"

# Step 4: 최종 검증
flutter test lib/features/chat/test/
git commit -am "test(chat): Verify PHASE 1 completion

- All tests passing
- Either pattern 100% applied"
```

### 롤백 명령어

```bash
# 전체 롤백
git checkout backup/before-phase1-completion
git branch -D feature/chat-phase1-completion

# 특정 Step만 롤백
git revert <commit-hash>
```

---

## 📈 마이그레이션 진행률

### Before (75% 완료)

| 레이어 | 파일 | Either 적용 | 상태 |
|--------|------|------------|------|
| Presentation | chat_providers.dart | ✅ 100% | 완료 |
| Domain (UseCase) | get_chat_list_usecase.dart | ✅ 100% | 개선 필요 (.map() 제거) |
| Domain (UseCase) | get_chat_messages_usecase.dart | ✅ 100% | 개선 필요 (.map() 제거) |
| Domain (Repository) | i_chat_repository.dart | ❌ 0% | **작업 필요** |
| Data (Repository) | chat_repository_impl.dart | ❌ 0% | **작업 필요** |

**진행률**: 3/5 파일 완료 = 60%
**실제 Either 적용률**: 75% (UseCase가 Either 반환하지만 Repository는 미적용)

### After (100% 완료)

| 레이어 | 파일 | Either 적용 | 상태 |
|--------|------|------------|------|
| Presentation | chat_providers.dart | ✅ 100% | 완료 |
| Domain (UseCase) | get_chat_list_usecase.dart | ✅ 100% | 패스스루로 단순화 |
| Domain (UseCase) | get_chat_messages_usecase.dart | ✅ 100% | 패스스루로 단순화 |
| Domain (Repository) | i_chat_repository.dart | ✅ 100% | ✅ Either 적용 완료 |
| Data (Repository) | chat_repository_impl.dart | ✅ 100% | ✅ Either 적용 완료 |

**진행률**: 5/5 파일 완료 = 100%
**실제 Either 적용률**: 100% (Repository부터 Either 반환)

---

## 🎓 학습 포인트

### 1. Either 패턴의 계층별 적용

```
Presentation → Domain (UseCase) → Domain (Repository) → Data (Repository Impl)
     ↓              ↓                    ↓                       ↓
  fold()         yield either      Stream<Either<L,R>>    yield right/left
```

**핵심**: Repository부터 Either를 반환해야 UseCase가 단순 패스스루 역할 가능

### 2. Cache-First 패턴과 Either의 조화

```dart
// ✅ Cache도 Either로 래핑
final cachedChats = await _cacheService.getChatList(userId);
if (cachedChats != null && cachedChats.isNotEmpty) {
  yield right(cachedChats); // 캐시 히트도 성공
}

// ✅ Firestore 스트림도 Either로 래핑
await for (final dtos in _remoteDatasource.queryChats(...)) {
  final chats = ChatMapper.toEntityList(dtos);
  yield right(chats); // 네트워크 응답도 성공
}
```

### 3. 에러 처리의 세분화

```dart
try {
  // ...
} on FirebaseException catch (e, stackTrace) {
  // Firebase 에러 (네트워크, 권한 등)
  yield left(ChatFailure.unexpected(
    error: 'Firestore error: ${e.code}',
    stackTrace: stackTrace,
  ));
} on Exception catch (e, stackTrace) {
  // 기타 에러 (Cache, Mapper 등)
  yield left(ChatFailure.unexpected(
    error: e.toString(),
    stackTrace: stackTrace,
  ));
}
```

---

## 📌 요약

### 작업 범위
- **수정 파일**: 4개 (Interface 1 + Impl 1 + UseCase 2)
- **수정 줄 수**: 약 100줄
- **예상 시간**: 2-3시간

### 핵심 변경사항
1. ✅ Repository 인터페이스에 Either 적용
2. ✅ Repository 구현체에 try-catch + Either 적용
3. ✅ UseCase의 불필요한 .map() 제거

### 기대 효과
- 🎯 PHASE 1 완전 적용 (100%)
- 🧹 코드 단순화 (UseCase 패스스루)
- 🛡️ 에러 처리 개선 (타입 안전)
- 🔗 Auth Feature와 패턴 일관성 확보

---

**다음 단계**: PHASE 1 완료 후 → PHASE 5 Extension Pattern 적용
