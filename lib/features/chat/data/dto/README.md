# Chat Feature DTO Layer

**Version**: 1.0.0
**Date**: 2025-01-20
**Status**: Phase 1 - DTO Layer Complete ✅

## Overview

DTO (Data Transfer Object) 레이어는 Clean Architecture v4.0에서 **Firestore 의존성을 Data Layer로 격리**하는 핵심 컴포넌트입니다.

```
Firestore DocumentSnapshot → DTO → Domain Entity
```

## Purpose

### DTO가 해결하는 문제

**Before (Domain Model 직접 Firestore 의존)**:
```dart
// ❌ Domain Layer가 Infrastructure에 의존
class ChatsModel extends FirestoreRecord {
  final DocumentReference reference;  // Firestore 타입!

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('chats');  // 직접 Firestore 접근!
}
```

**After (DTO를 통한 격리)**:
```dart
// ✅ Domain Entity는 순수 Dart 타입만 사용
class Chat {
  final String id;           // DocumentReference → String
  final DateTime? createdAt; // Timestamp → DateTime
}

// ✅ DTO가 Firestore 변환 담당
class ChatDto {
  factory ChatDto.fromFirestore(DocumentSnapshot snapshot) {
    // Firestore 타입 변환 로직
  }
}
```

### Clean Architecture 원칙 준수

```
┌─────────────────────────────────────────────────┐
│          Presentation Layer (UI)                 │
│          ↓ Domain Entities                      │
├─────────────────────────────────────────────────┤
│          Domain Layer (Business Logic)           │
│          - Entities, UseCases, Repositories      │
│          ↓ Domain Entities                      │
├─────────────────────────────────────────────────┤
│          Data Layer (Infrastructure)             │
│          ┌──────────────────────────────────┐   │
│          │  DTO Layer (격리 경계)            │   │
│          │  - Firestore → DTO 변환           │   │
│          │  - DTO → Domain 변환              │   │
│          └──────────────────────────────────┘   │
│          ↓ Firestore Types                      │
├─────────────────────────────────────────────────┤
│          Infrastructure (Firebase)               │
└─────────────────────────────────────────────────┘
```

## DTO Classes

### ChatDto

**책임**: 1:1 채팅방 데이터 변환

**필드** (15개):
- `id`: 채팅방 문서 ID (DocumentReference.id → String)
- `chatId`, `chatType`, `participantIds`: 채팅방 식별자
- `lastMessageContent`, `lastMessageAt`: 최근 메시지 정보
- `isRead`, `createdAt`: 상태 정보
- `email`, `displayName`, `photoUrl`, `uid`, `createdTime`, `phoneNumber`: 사용자 정보 (TODO: Profile feature로 이동)
- `lastReadTimestamps`: 사용자별 읽은 시간

**주요 메서드**:
```dart
// Firestore → DTO
factory ChatDto.fromFirestore(DocumentSnapshot snapshot)

// DTO → Firestore
Map<String, dynamic> toFirestore()

// DTO → Domain (Phase 2에서 구현)
Chat toDomain()

// Helper
DateTime? getLastReadFor(String userId)
ChatDto copyWith({...})
```

### MessageDto

**책임**: 채팅 메시지 데이터 변환 (기본 메시지 + 미디어 + 투표 카드)

**필드 카테고리** (40+ 필드):

1. **Basic Message** (10개):
   - `id`, `parentPath`, `messageId`, `senderId`
   - `content`, `attachmentUrl/Type`, `timeStamp`
   - `isRead`, `messageType`

2. **Media** (8개):
   - `mediaType`, `imageUrl`, `videoUrl`, `thumbnailUrl`
   - `mediaSize`, `mediaWidth`, `mediaHeight`

3. **Lifecycle** (2개):
   - `deliveredAt`, `seenAt`

4. **Vote Card** (20+개):
   - `receiverId`, `votePostId`, `voteTitle`, `voteDescription`
   - `voteOptionA/BText`, `voteOptionA/BImage`
   - `voteOptionA/BImages` (멀티이미지)
   - `voteStatus`, `cardStatus`, `voteEndTime`
   - `voteResults`, `userVotes` (사용자별 투표 정보)
   - `voteAspectRatioA/B`, `voteResultsA/B`, `votePercentA/B`

5. **Metadata** (1개):
   - `metadata`

**주요 메서드**:
```dart
// Firestore → DTO
factory MessageDto.fromFirestore(DocumentSnapshot snapshot)

// DTO → Firestore
Map<String, dynamic> toFirestore()

// JSON 직렬화 (Hive 캐싱용)
Map<String, dynamic> toJson()
factory MessageDto.fromJson(Map<String, dynamic> json)

// DTO → Domain (Phase 2에서 구현)
Message toDomain()

// Helper (투표 관련)
Map<String, dynamic>? getUserVote(String userId)
bool checkUserVoted(String userId)
String? getUserVoteChoice(String userId)
DateTime? getUserVoteTime(String userId)

MessageDto copyWith({...})
```

## Type Conversions

### Firestore → Dart

| Firestore Type | DTO Type | 변환 로직 |
|----------------|----------|----------|
| `DocumentReference` | `String` | `snapshot.id` |
| `Timestamp` | `DateTime` | `timestamp.toDate()` |
| `List<dynamic>` | `List<String>` | `whereType<String>().toList()` |
| `Map<dynamic, dynamic>` | `Map<String, DateTime>` | 타입 캐스트 + Timestamp 변환 |

### 안전한 변환 헬퍼 함수

```dart
// DateTime 파싱 (int, Timestamp, String, DateTime 모두 처리)
DateTime? parseDateTime(dynamic value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

// List<String> 안전 변환
List<String> parseStringList(dynamic value) {
  if (value is List) return value.whereType<String>().toList();
  return [];
}

// Map<String, dynamic> 안전 변환
Map<String, dynamic> parseMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return {};
}
```

## Usage Examples

### ChatDto 사용 예시

```dart
// Repository에서 Firestore 읽기
Future<ChatDto> getChat(String chatId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .get();

  return ChatDto.fromFirestore(snapshot);
}

// Repository에서 Firestore 쓰기
Future<void> updateChat(ChatDto chatDto) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatDto.id)
      .update(chatDto.toFirestore());
}

// DTO → Domain 변환 (Phase 2에서 구현 예정)
Chat chat = chatDto.toDomain();
```

### MessageDto 사용 예시

```dart
// Repository에서 메시지 스트림 읽기
Stream<List<MessageDto>> getMessages(String chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MessageDto.fromFirestore(doc))
          .toList());
}

// Hive 캐싱에 저장
await box.put('messages_$chatId',
    messages.map((msg) => msg.toJson()).toList());

// Hive 캐시에서 복원
final cached = (box.get('messages_$chatId') as List)
    .map((json) => MessageDto.fromJson(json))
    .toList();

// 투표 정보 조회
if (messageDto.checkUserVoted(currentUserId)) {
  final choice = messageDto.getUserVoteChoice(currentUserId);
  print('User voted: $choice');
}
```

## Migration Status

### Phase 1: DTO Layer Creation ✅ (Current)

**작업 완료**:
- ✅ `ChatDto` 구현 완료
- ✅ `MessageDto` 구현 완료
- ✅ Firestore ↔ DTO 변환 로직 완료
- ✅ JSON 직렬화 (Hive 캐싱용)
- ✅ Helper 메서드 구현

**영향**:
- 새 파일 생성만
- 기존 코드 영향 없음 ✅

### Phase 2: Pure Domain Entities (Next)

**예정 작업**:
- [ ] `domain/entities/chat.dart` 생성 (Freezed)
- [ ] `domain/entities/message.dart` 생성 (Freezed)
- [ ] `ChatDto.toDomain()` 구현
- [ ] `MessageDto.toDomain()` 구현

**영향**:
- 새 파일 생성만
- 기존 코드 영향 없음

### Phase 3-7: Gradual Migration

Phase 3-7에서는 Repository, UseCase, Provider, Services, App Layer를 순차적으로 마이그레이션합니다.

자세한 마이그레이션 계획은 상위 디렉토리의 `MIGRATION_PLAN.md` 참조.

## Design Decisions

### 1. DTO는 왜 Mutable인가?

**질문**: Domain Entity는 Immutable (Freezed)인데, DTO는 왜 Mutable인가?

**답변**:
- DTO는 Infrastructure 레이어의 Data Transfer 목적
- Firestore 변환 과정에서 필드 설정 필요
- Domain Layer 이후부터만 Immutability 보장
- 성능: Mutable DTO는 변환 시 메모리 효율적

### 2. toJson/fromJson은 왜 MessageDto에만?

**질문**: ChatDto는 왜 JSON 직렬화가 없나?

**답변**:
- `UnifiedCacheService`가 현재 메시지만 캐싱
- 채팅방은 Firestore 오프라인 캐시로 충분
- 필요 시 Phase 6에서 추가 가능

### 3. Helper 메서드는 DTO에 있어야 하나?

**질문**: `getUserVote()` 같은 비즈니스 로직이 DTO에 있어야 하나?

**답변**:
- Helper 메서드는 데이터 접근 편의성 제공
- 비즈니스 로직은 Domain Layer (Phase 2 이후)
- 기존 코드 호환성 유지 (Migration 전략)

## Architecture Benefits

### Before DTO Layer

```dart
// Domain Layer가 Firestore에 의존
Stream<Result<List<MessagesModel>>> execute() {
  final stream = _repository.queryMessages();  // FirestoreRecord 반환

  return stream.map((messages) {
    // ❌ Presentation Layer에서 Firestore 타입 사용
    messages.map((msg) => TextMessage(
      id: msg.reference.id,  // DocumentReference 의존!
      ...
    ));
  });
}
```

**문제점**:
- Domain/Presentation Layer가 Firestore 타입 알아야 함
- Firestore 교체 불가능 (강한 결합)
- 테스트 시 Firestore 모킹 필수

### After DTO Layer

```dart
// Domain Layer가 순수 Dart 타입만 사용
Stream<Result<List<Message>>> execute() {
  final stream = _repository.queryMessages();  // Message 엔티티 반환

  return stream.map((messages) {
    // ✅ 순수 Dart 타입만 사용
    messages.map((msg) => TextMessage(
      id: msg.id,  // String!
      ...
    ));
  });
}

// Repository (Data Layer)에서 DTO 변환
Stream<List<Message>> queryMessages() {
  return _firestore
      .collection('chats/$chatId/messages')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MessageDto.fromFirestore(doc))
          .map((dto) => dto.toDomain())  // DTO → Domain 변환
          .toList());
}
```

**장점**:
- ✅ Domain/Presentation Layer가 Firestore 모름
- ✅ Firestore 교체 가능 (느슨한 결합)
- ✅ 테스트 시 Domain Entity만 모킹

## Testing

### DTO 변환 테스트

```dart
test('ChatDto.fromFirestore converts Firestore types correctly', () {
  // Given: Firestore DocumentSnapshot
  final snapshot = MockDocumentSnapshot(
    id: 'chat123',
    data: {
      'chatId': 'chat123',
      'participantIds': ['user1', 'user2'],
      'lastMessageAt': Timestamp.fromDate(DateTime(2025, 1, 20)),
    },
  );

  // When: DTO 변환
  final dto = ChatDto.fromFirestore(snapshot);

  // Then: 타입 변환 확인
  expect(dto.id, 'chat123');  // String
  expect(dto.participantIds, ['user1', 'user2']);  // List<String>
  expect(dto.lastMessageAt, DateTime(2025, 1, 20));  // DateTime
});
```

## Next Steps

1. **Phase 2 준비**: Domain Entity 설계 (Freezed)
2. **toDomain() 구현**: DTO → Domain 변환 로직
3. **Repository 마이그레이션**: Phase 3에서 Repository 반환 타입 변경

## References

- [Clean Architecture v4.0 Migration Plan](../MIGRATION_PLAN.md)
- [Chat Domain Entities](../../domain/entities/)
- [Chat Domain Enums](../../domain/enums/)
- [Repository Interface](../../domain/repositories/i_chat_repository.dart)

---

**Last Updated**: 2025-01-20
**Migration Phase**: 1 of 7
**Breaking Changes**: None (격리 레이어)
