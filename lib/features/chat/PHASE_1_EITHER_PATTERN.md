# Chat Feature - Phase 1: Either Pattern Migration

> **마이그레이션 가이드**: Result<T> → Either<L,R> 패턴 전환
> **난이도**: ⭐⭐⭐☆☆ (중간)
> **예상 소요 시간**: 1일 (8시간)
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

Chat Feature의 Result<T> 패턴을 `fpdart`의 Either<L,R> 패턴으로 전환하여 함수형 프로그래밍의 장점을 활용하고, Auth Feature와의 일관성을 확보합니다.

### 영향 범위

| 레이어 | 파일 수 | 변경 줄 수 | 주요 변경 사항 |
|--------|---------|-----------|---------------|
| **Presentation** | 3개 | ~150줄 | Provider에서 fold() 패턴 적용 |
| **Domain (UseCases)** | 8개 | ~180줄 | Result<T> → Either<L,R> 변환 |
| **Domain (Repository)** | 1개 | ~80줄 | 인터페이스 시그니처 변경 |
| **Data** | 1개 | ~100줄 | 구현체 반환 타입 변경 |
| **합계** | **13개** | **~510줄** | - |

### 주요 이점

1. **타입 안전성 향상**: Either는 Left/Right로 명확히 구분
2. **함수 합성**: `fold()`, `map()`, `flatMap()` 체이닝
3. **일관성**: Auth Feature와 동일한 패턴 사용
4. **에러 처리 강제**: 컴파일러가 에러 처리를 강제함

---

## 🔍 현재 상태 분석

### 1. Presentation Layer (Provider)

**파일**: `presentation/providers/chat_list_provider.dart:82-104`

```dart
// ❌ 현재: Result<T> 패턴
_chatsSubscription = _getChatListUseCase
    .execute(
      userId: userId,
      limit: 50,
    )
    .listen(
  (result) {
    result.fold(
      (failure) {
        _setError(failure.message);
        _setState(ChatListLoadingState.error);
      },
      (chats) {
        _chats = chats;
        _setState(ChatListLoadingState.success);
      },
    );
  },
  onError: (error) {
    _setError('실시간 업데이트 오류: $error');
    _setState(ChatListLoadingState.error);
  },
);
```

**문제점**:
- `Result<T>` 타입이 fpdart의 Either와 혼용됨
- fold() 메서드가 Result와 Either에서 다름
- Auth Feature와 패턴 불일치

### 2. Domain Layer (UseCase)

**파일**: `domain/usecases/get_chat_list_usecase.dart`

```dart
// ❌ 현재: Result<List<Chat>> 반환
class GetChatListUseCase {
  final IChatRepository _repository;

  GetChatListUseCase({required IChatRepository repository})
      : _repository = repository;

  Stream<Result<List<Chat>>> execute({
    required String userId,
    int limit = 50,
  }) async* {
    try {
      await for (final chats in _repository.queryChats(
        userId: userId,
        limit: limit,
      )) {
        yield Success(chats);  // ❌ Result Success
      }
    } catch (e, stackTrace) {
      yield ResultFailure(  // ❌ Result Failure
        ChatFailure.unexpected(
          message: 'Failed to load chat list: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
```

**문제점**:
- Success/ResultFailure는 커스텀 Result 타입
- fpdart의 right/left와 혼용 불가
- 에러 처리 불일치

### 3. Domain Layer (Repository Interface)

**파일**: `domain/repositories/i_chat_repository.dart`

```dart
// ❌ 현재: Result가 아닌 순수 도메인 엔티티 반환
abstract class IChatRepository {
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  Future<Chat?> getChat(String chatId);

  Future<void> createChat(Chat chat);

  Future<void> deleteChat(String chatId);
}
```

**문제점**:
- 에러를 throw로만 전달 (명시적 에러 타입 없음)
- Repository 레이어에서 에러 핸들링이 UseCase로 위임됨
- Auth Repository는 Either를 사용하는데 Chat은 예외 던지기만 사용

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. UseCase 계층

```dart
// ❌ Before: Result<T> 패턴
Stream<Result<List<Chat>>> execute({...}) async* {
  try {
    await for (final chats in _repository.queryChats(...)) {
      yield Success(chats);
    }
  } catch (e, stackTrace) {
    yield ResultFailure(ChatFailure.unexpected(...));
  }
}

// ✅ After: Either<L,R> 패턴
Stream<Either<ChatFailure, List<Chat>>> execute({...}) async* {
  try {
    await for (final chats in _repository.queryChats(...)) {
      yield right(chats);  // 성공 시 right
    }
  } catch (e, stackTrace) {
    yield left(  // 실패 시 left
      ChatFailure.unexpected(
        message: 'Failed to load chat list: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ),
    );
  }
}
```

#### 2. Provider 계층

```dart
// ❌ Before: Result<T>.fold()
result.fold(
  (failure) => _handleError(failure),
  (chats) => _handleSuccess(chats),
);

// ✅ After: Either<L,R>.fold()
either.fold(
  (failure) => _handleError(failure),  // Left (에러)
  (chats) => _handleSuccess(chats),    // Right (성공)
);
```

#### 3. Repository 인터페이스 (선택적 변경)

```dart
// ❌ Before: 예외 던지기
abstract class IChatRepository {
  Stream<List<Chat>> queryChats({...});  // throw Exception
}

// ✅ After: Either 반환 (Phase 4에서 적용)
abstract class IChatRepository {
  Stream<Either<ChatFailure, List<Chat>>> queryChats({...});
}
```

> **참고**: Phase 1에서는 UseCase와 Provider만 변경하고, Repository 인터페이스는 Phase 4 (Idempotency)에서 함께 변경합니다.

---

## 📝 단계별 마이그레이션 가이드

### Step 1: fpdart 의존성 확인

**pubspec.yaml**에 fpdart가 이미 추가되어 있는지 확인:

```yaml
dependencies:
  fpdart: ^1.1.0
```

> **참고**: Auth Feature에서 이미 추가했다면 생략 가능

### Step 2: ChatFailure 분석

**파일**: `domain/failures/chat_failure.dart`

ChatFailure가 이미 Freezed로 정의되어 있는지 확인:

```dart
@freezed
sealed class ChatFailure with _$ChatFailure implements Failure {
  const factory ChatFailure.unexpected({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ChatUnexpected;

  const factory ChatFailure.notFound({
    required String chatId,
  }) = ChatNotFound;

  const factory ChatFailure.permissionDenied({
    required String message,
  }) = ChatPermissionDenied;

  const factory ChatFailure.network({
    required String message,
  }) = ChatNetworkFailure;
}
```

✅ **이미 Freezed로 정의되어 있으므로 변경 불필요**

### Step 3: GetChatListUseCase 마이그레이션

**파일**: `domain/usecases/get_chat_list_usecase.dart`

#### Before (149줄 기준, 38-45줄 변경 필요):

```dart
import '/core/types/result.dart';  // ❌ 제거
import '../repositories/i_chat_repository.dart';
import '../entities/chat.dart';
import '../failures/chat_failure.dart';

class GetChatListUseCase {
  final IChatRepository _repository;

  GetChatListUseCase({required IChatRepository repository})
      : _repository = repository;

  /// 사용자의 채팅 목록을 실시간으로 조회합니다.
  ///
  /// **Stream 방식**:
  /// - Firestore의 실시간 업데이트를 반영
  /// - 새 메시지가 도착하면 자동으로 emit
  ///
  /// **에러 처리**:
  /// - Firestore 에러: ChatFailure.unexpected
  /// - 네트워크 에러: ChatFailure.network
  Stream<Result<List<Chat>>> execute({  // ❌ Result<T>
    required String userId,
    int limit = 50,
  }) async* {
    try {
      await for (final chats in _repository.queryChats(
        userId: userId,
        limit: limit,
        orderBy: 'lastMessageAt',
        descending: true,
      )) {
        yield Success(chats);  // ❌ Success
      }
    } catch (e, stackTrace) {
      yield ResultFailure(  // ❌ ResultFailure
        ChatFailure.unexpected(
          message: 'Failed to load chat list: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
```

#### After (동일 줄 수, import만 변경):

```dart
import 'package:fpdart/fpdart.dart';  // ✅ Either 추가
import '../repositories/i_chat_repository.dart';
import '../entities/chat.dart';
import '../failures/chat_failure.dart';

class GetChatListUseCase {
  final IChatRepository _repository;

  GetChatListUseCase({required IChatRepository repository})
      : _repository = repository;

  /// 사용자의 채팅 목록을 실시간으로 조회합니다.
  ///
  /// **Stream 방식**:
  /// - Firestore의 실시간 업데이트를 반영
  /// - 새 메시지가 도착하면 자동으로 emit
  ///
  /// **에러 처리**:
  /// - Left: ChatFailure (Firestore/네트워크 에러)
  /// - Right: List<Chat> (성공)
  Stream<Either<ChatFailure, List<Chat>>> execute({  // ✅ Either<L,R>
    required String userId,
    int limit = 50,
  }) async* {
    try {
      await for (final chats in _repository.queryChats(
        userId: userId,
        limit: limit,
        orderBy: 'lastMessageAt',
        descending: true,
      )) {
        yield right(chats);  // ✅ right (성공)
      }
    } catch (e, stackTrace) {
      yield left(  // ✅ left (실패)
        ChatFailure.unexpected(
          message: 'Failed to load chat list: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
```

**변경 사항**:
1. `import '/core/types/result.dart'` 제거
2. `import 'package:fpdart/fpdart.dart'` 추가
3. `Stream<Result<...>>` → `Stream<Either<ChatFailure, ...>>`
4. `Success(...)` → `right(...)`
5. `ResultFailure(...)` → `left(...)`

### Step 4: 나머지 UseCases 마이그레이션

동일한 패턴으로 다음 UseCase들을 마이그레이션:

1. ✅ **get_chat_messages_usecase.dart**
   ```dart
   // Before
   Stream<Result<List<Message>>> execute({...})

   // After
   Stream<Either<ChatFailure, List<Message>>> execute({...})
   ```

2. ✅ **send_message_usecase.dart**
   ```dart
   // Before
   Future<Result<void>> execute({...})

   // After
   Future<Either<ChatFailure, Unit>> execute({...})
   ```
   > **참고**: void → Unit 변경 (fpdart 표준)

3. ✅ **load_more_messages_usecase.dart**
   ```dart
   // Before
   Future<Result<List<Message>>> execute({...})

   // After
   Future<Either<ChatFailure, List<Message>>> execute({...})
   ```

4. ✅ **search_messages_usecase.dart**
5. ✅ **send_ai_query_usecase.dart**
6. ✅ **get_recommended_friends_usecase.dart**
7. ✅ **search_friends_usecase.dart**
8. ✅ **send_friend_request_usecase.dart**

**일괄 변경 명령어** (VS Code):
```
검색: Stream<Result<
교체: Stream<Either<ChatFailure,

검색: Future<Result<
교체: Future<Either<ChatFailure,

검색: yield Success\(
교체: yield right(

검색: yield ResultFailure\(
교체: yield left(

검색: return Success\(
교체: return right(

검색: return ResultFailure\(
교체: return left(
```

### Step 5: ChatListProvider 마이그레이션

**파일**: `presentation/providers/chat_list_provider.dart:82-104`

#### Before:

```dart
import '/core/types/result.dart';  // ❌ 제거 예정

class ChatListProvider extends ChangeNotifier {
  // ...

  Future<void> initializeChatList(String userId) async {
    if (_userId == userId) return;

    _userId = userId;
    _setState(ChatListLoadingState.loading);

    try {
      _chatsSubscription = _getChatListUseCase
          .execute(
        userId: userId,
        limit: 50,
      )
          .listen(
        (result) {  // ❌ Result<List<Chat>>
          result.fold(
            (failure) {
              _setError(failure.message);
              _setState(ChatListLoadingState.error);
            },
            (chats) {
              _chats = chats;
              _setState(ChatListLoadingState.success);
            },
          );
        },
        onError: (error) {
          _setError('실시간 업데이트 오류: $error');
          _setState(ChatListLoadingState.error);
        },
      );
    } catch (e) {
      _setError('채팅 목록 초기화 실패: ${e.toString()}');
      _setState(ChatListLoadingState.error);
    }
  }
}
```

#### After:

```dart
import 'package:fpdart/fpdart.dart';  // ✅ Either 추가

class ChatListProvider extends ChangeNotifier {
  // ...

  Future<void> initializeChatList(String userId) async {
    if (_userId == userId) return;

    _userId = userId;
    _setState(ChatListLoadingState.loading);

    try {
      _chatsSubscription = _getChatListUseCase
          .execute(
        userId: userId,
        limit: 50,
      )
          .listen(
        (either) {  // ✅ Either<ChatFailure, List<Chat>>
          either.fold(
            (failure) {  // Left: 에러
              _setError(failure.message);
              _setState(ChatListLoadingState.error);
            },
            (chats) {  // Right: 성공
              _chats = chats;
              _setState(ChatListLoadingState.success);
            },
          );
        },
        onError: (error) {
          _setError('실시간 업데이트 오류: $error');
          _setState(ChatListLoadingState.error);
        },
      );
    } catch (e) {
      _setError('채팅 목록 초기화 실패: ${e.toString()}');
      _setState(ChatListLoadingState.error);
    }
  }
}
```

**변경 사항**:
1. `import '/core/types/result.dart'` 제거
2. `import 'package:fpdart/fpdart.dart'` 추가
3. `(result)` → `(either)` 변수명 변경 (명확성)
4. fold() 로직은 동일 (Result와 Either 모두 fold 지원)

### Step 6: 나머지 Providers 마이그레이션

동일한 패턴으로 다음 Provider들을 마이그레이션:

1. ✅ **chat_detail_provider.dart**
   - `_messagesSubscription` 리스너 업데이트
   - `sendMessage()` 메서드 Either 처리

2. ✅ **ai_chat_provider.dart**
   - `sendAIQuery()` 메서드 Either 처리
   - AI 응답 스트림 Either 처리

### Step 7: 컴파일 및 테스트

```bash
# 1. 컴파일 에러 확인
flutter analyze lib/features/chat

# 2. 타입 에러 수정
# - Result<T> 누락 부분 찾기
# - Either<L,R> 변환 누락 확인

# 3. 수동 테스트
# - 채팅 목록 로드
# - 메시지 전송
# - AI 채팅 테스트
```

---

## 🧪 테스트 전략

### 1. 단위 테스트 (Unit Tests)

**파일**: `test/unit/usecases/get_chat_list_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetChatListUseCase - Either Pattern', () {
    late GetChatListUseCase usecase;
    late MockChatRepository mockRepository;

    setUp(() {
      mockRepository = MockChatRepository();
      usecase = GetChatListUseCase(repository: mockRepository);
    });

    test('성공 시 Right<List<Chat>> 반환', () async {
      // Arrange
      final mockChats = [
        Chat(id: '1', participantIds: ['user1', 'user2']),
        Chat(id: '2', participantIds: ['user1', 'user3']),
      ];
      when(mockRepository.queryChats(
        userId: 'user1',
        limit: 50,
      )).thenAnswer((_) => Stream.value(mockChats));

      // Act
      final stream = usecase.execute(userId: 'user1');

      // Assert
      await expectLater(
        stream,
        emits(
          isA<Right<ChatFailure, List<Chat>>>().having(
            (either) => either.getOrElse(() => []),
            'chats',
            mockChats,
          ),
        ),
      );
    });

    test('실패 시 Left<ChatFailure> 반환', () async {
      // Arrange
      when(mockRepository.queryChats(
        userId: 'user1',
        limit: 50,
      )).thenThrow(Exception('Network error'));

      // Act
      final stream = usecase.execute(userId: 'user1');

      // Assert
      await expectLater(
        stream,
        emits(
          isA<Left<ChatFailure, List<Chat>>>().having(
            (either) => either.swap().getOrElse(() => ChatFailure.unexpected(message: '')),
            'failure',
            isA<ChatFailure>(),
          ),
        ),
      );
    });

    test('fold()로 Left/Right 분기 처리', () async {
      // Arrange
      final mockChats = [Chat(id: '1', participantIds: ['user1'])];
      when(mockRepository.queryChats(userId: 'user1'))
          .thenAnswer((_) => Stream.value(mockChats));

      // Act
      final stream = usecase.execute(userId: 'user1');
      String result = '';

      await for (final either in stream) {
        either.fold(
          (failure) => result = 'error: ${failure.message}',
          (chats) => result = 'success: ${chats.length} chats',
        );
      }

      // Assert
      expect(result, 'success: 1 chats');
    });
  });
}
```

### 2. Provider 테스트

**파일**: `test/unit/providers/chat_list_provider_test.dart`

```dart
void main() {
  group('ChatListProvider - Either Pattern', () {
    late ChatListProvider provider;
    late MockGetChatListUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockGetChatListUseCase();
      provider = ChatListProvider(getChatListUseCase: mockUseCase);
    });

    test('성공 시 chats 리스트 업데이트', () async {
      // Arrange
      final mockChats = [Chat(id: '1', participantIds: ['user1'])];
      when(mockUseCase.execute(userId: 'user1'))
          .thenAnswer((_) => Stream.value(right(mockChats)));

      // Act
      await provider.initializeChatList('user1');
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(provider.state, ChatListLoadingState.success);
      expect(provider.chats, mockChats);
      expect(provider.errorMessage, isNull);
    });

    test('실패 시 에러 메시지 설정', () async {
      // Arrange
      final failure = ChatFailure.network(message: 'No internet');
      when(mockUseCase.execute(userId: 'user1'))
          .thenAnswer((_) => Stream.value(left(failure)));

      // Act
      await provider.initializeChatList('user1');
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(provider.state, ChatListLoadingState.error);
      expect(provider.errorMessage, 'No internet');
      expect(provider.chats, isEmpty);
    });
  });
}
```

### 3. 통합 테스트 (Integration Tests)

```dart
void main() {
  testWidgets('채팅 목록 로드 E2E 테스트', (tester) async {
    // 1. 앱 시작
    await tester.pumpWidget(MyApp());

    // 2. 로그인
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    // 3. 채팅 탭 이동
    await tester.tap(find.byIcon(Icons.chat));
    await tester.pumpAndSettle();

    // 4. 채팅 목록 확인
    expect(find.byType(ChatListItem), findsWidgets);

    // 5. 에러 없음 확인
    expect(find.text('실시간 업데이트 오류'), findsNothing);
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **Either 패턴 이해 부족**으로 인한 개발 지연
2. **기존 코드와의 호환성 문제** 발생
3. **테스트 실패율 증가**

### 롤백 절차

#### Step 1: Git Revert

```bash
# 마이그레이션 커밋 확인
git log --oneline --grep="Either Pattern"

# 해당 커밋 revert
git revert <commit-hash>
```

#### Step 2: 의존성 확인

```yaml
# pubspec.yaml에서 fpdart 제거 여부 확인
dependencies:
  fpdart: ^1.1.0  # Auth Feature에서 사용 중이면 유지
```

#### Step 3: 임포트 복구

```dart
// Before (롤백 후)
import '/core/types/result.dart';

// After (마이그레이션 시)
import 'package:fpdart/fpdart.dart';
```

#### Step 4: 타입 복구

```bash
# 일괄 검색/교체 (역순)
검색: Stream<Either<ChatFailure,
교체: Stream<Result<

검색: yield right\(
교체: yield Success(

검색: yield left\(
교체: yield ResultFailure(
```

### 롤백 검증

```bash
# 1. 컴파일 에러 확인
flutter analyze

# 2. 테스트 실행
flutter test

# 3. 앱 실행 확인
flutter run
```

---

## ✅ 완료 체크리스트

### Phase 1 완료 기준

- [ ] **의존성 확인**
  - [ ] pubspec.yaml에 fpdart 추가됨
  - [ ] flutter pub get 실행 완료

- [ ] **Domain Layer (UseCases)**
  - [ ] GetChatListUseCase: Result → Either 변환
  - [ ] GetChatMessagesUseCase: Result → Either 변환
  - [ ] SendMessageUseCase: Result → Either 변환
  - [ ] LoadMoreMessagesUseCase: Result → Either 변환
  - [ ] SearchMessagesUseCase: Result → Either 변환
  - [ ] SendAIQueryUseCase: Result → Either 변환
  - [ ] GetRecommendedFriendsUseCase: Result → Either 변환
  - [ ] SendFriendRequestUseCase: Result → Either 변환

- [ ] **Presentation Layer (Providers)**
  - [ ] ChatListProvider: Either fold() 적용
  - [ ] ChatDetailProvider: Either fold() 적용
  - [ ] AIChatProvider: Either fold() 적용

- [ ] **테스트**
  - [ ] 단위 테스트: GetChatListUseCase (Right/Left 분기)
  - [ ] 단위 테스트: ChatListProvider (성공/실패 시나리오)
  - [ ] 통합 테스트: 채팅 목록 로드 E2E

- [ ] **컴파일 & 분석**
  - [ ] `flutter analyze lib/features/chat` 에러 없음
  - [ ] `flutter test` 모든 테스트 통과
  - [ ] 수동 테스트: 채팅 목록 로드 정상 작동

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] README.md에 Either 패턴 설명 추가
  - [ ] Phase 2 준비 (Riverpod Migration)

---

## 📊 마이그레이션 영향 분석

### 코드 변경량

| 파일 | Before (줄) | After (줄) | 변경률 |
|------|------------|-----------|--------|
| get_chat_list_usecase.dart | 58 | 58 | 0% (import만 변경) |
| chat_list_provider.dart | 149 | 149 | 0% (import만 변경) |
| send_message_usecase.dart | 45 | 46 | +2% (void → Unit) |
| **합계** | **~520줄** | **~525줄** | **+1%** |

### 성능 영향

- **컴파일 시간**: 변화 없음 (Either는 pure Dart)
- **런타임 성능**: 변화 없음 (fold()는 단순 패턴 매칭)
- **메모리 사용**: 변화 없음

### 개발자 경험

| 항목 | Before (Result) | After (Either) |
|------|-----------------|----------------|
| **타입 안전성** | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ |
| **에러 처리 강제** | ⭐⭐☆☆☆ | ⭐⭐⭐⭐⭐ |
| **함수 합성** | ⭐⭐☆☆☆ | ⭐⭐⭐⭐⭐ |
| **학습 곡선** | ⭐⭐⭐⭐☆ | ⭐⭐⭐☆☆ |
| **Auth 일관성** | ❌ | ✅ |

---

## 🎓 추가 학습 자료

### Either 패턴 심화

```dart
// 1. map(): Right 값만 변환
final either = right<ChatFailure, List<Chat>>([chat1, chat2]);
final mapped = either.map((chats) => chats.length);  // Right(2)

// 2. flatMap(): Either를 반환하는 함수 체이닝
final result = either.flatMap((chats) {
  if (chats.isEmpty) {
    return left(ChatFailure.notFound(chatId: 'empty'));
  }
  return right(chats.first);
});

// 3. getOrElse(): 기본값 제공
final chats = either.getOrElse(() => []);

// 4. swap(): Left ↔ Right 교환
final swapped = either.swap();  // Left → Right, Right → Left
```

### Auth Feature 참조

- **Auth PHASE_2_EITHER_PATTERN.md**: Either 패턴 상세 가이드
- **Voting Feature**: keepAlive() 활용 예시
- **Profile Feature**: Entity → DTO 변환 패턴

---

## 📌 다음 단계: Phase 2

Phase 1 완료 후, **Phase 2: Riverpod 2.x Migration**으로 진행:

```
ChangeNotifier → StreamProvider.autoDispose.family
```

**예상 효과**:
- 코드 46% 감소 (149줄 → 80줄)
- 자동 dispose (메모리 누수 방지)
- keepAlive()로 중복 리스너 방지

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
