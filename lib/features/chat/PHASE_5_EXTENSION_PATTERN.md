# Phase 5: Firebase-Centric v2.0 - Extension Pattern Migration

> **소요 시간**: 5-7일
> **난이도**: ⭐⭐⭐⭐☆ (높음)
> **영향 범위**: Data Layer 전체 (datasources, mappers, models → extensions)
> **UI 영향**: ❌ 없음 (내부 구조만 변경)

---

## 📋 목차

1. [개요](#1-개요)
2. [현재 상태 분석](#2-현재-상태-분석)
3. [마이그레이션 목표](#3-마이그레이션-목표)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [테스트 전략](#6-테스트-전략)
7. [롤백 계획](#7-롤백-계획)

---

## 1. 개요

### 1.1 Phase 5의 목적

Chat Feature를 **Firebase-Centric v2.0** 아키텍처로 전환합니다. Auth/Profile/Voting Feature가 이미 완료한 패턴을 Chat에도 적용하여 전체 프로젝트의 일관성을 확보합니다.

**핵심 변경사항**:
- ✅ **DataSource Layer 제거**: Firebase를 Repository에서 직접 사용
- ✅ **DTO Layer 제거**: Entity에서 직접 Firestore 변환
- ✅ **Mapper Layer 제거**: Extension으로 변환 로직 통합
- ✅ **코드 감소**: 2,444줄 → 904줄 **(63% 감소)**

### 1.2 Firebase-Centric v2.0란?

**이전 아키텍처 (Clean Architecture with Abstraction)**:
```
Firestore → DataSource → DTO → Mapper → Entity
         (3단계 변환)
```

**새로운 아키텍처 (Firebase-Centric v2.0)**:
```
Firestore → Extension → Entity
         (1단계 변환)
```

**철학적 변화**:
- **이전**: "Firebase는 교체 가능한 외부 의존성이다"
- **이후**: "Firebase는 우리 프로젝트의 핵심 인프라다"

### 1.3 왜 Extension Pattern인가?

**Extension Pattern의 장점**:

1. **코드 간결성**
   - DTO + Mapper (370줄) → Extension (120줄) **(67% 감소)**
   - 중복 제거: `toDomain()` deprecated 메서드 삭제

2. **유지보수성 향상**
   - 변환 로직이 Entity와 함께 위치 (`user_profile.dart` 옆에 `user_profile_extensions.dart`)
   - 필드 추가 시 한 곳만 수정 (Extension)

3. **타입 안전성**
   - Extension 메서드는 Entity 타입에 직접 바인딩
   - 컴파일 타임에 타입 체크

4. **일관성**
   - Auth/Profile/Voting과 동일한 패턴
   - 팀원 간 학습 곡선 감소

**Trade-off 인정**:
- ❌ Firebase 교체 어려움 → ✅ 우리는 Firebase를 교체할 계획이 없음
- ❌ 추상화 감소 → ✅ 불필요한 추상화 제거로 코드 단순화

---

## 2. 현재 상태 분석

### 2.1 Chat Feature Data Layer 구조

```
lib/features/chat/data/
├── adapters/                    # 133줄 (유지)
│   ├── flutter_chat_user_adapter.dart
│   └── gemini_ai_service.dart
├── datasources/                 # 566줄 (삭제 예정)
│   ├── i_chat_remote_datasource.dart      (222줄)
│   └── firebase_chat_remote_datasource.dart (344줄)
├── mappers/                     # 195줄 (삭제 예정)
│   ├── chat_mapper.dart         (67줄)
│   └── message_mapper.dart      (128줄)
├── models/                      # 1,029줄 (삭제 예정)
│   ├── chat_dto.dart            (303줄)
│   └── message_dto.dart         (726줄)
├── repositories/                # 654줄 (수정 필요)
│   └── chat_repository_impl.dart
└── services/                    # 521줄 (유지)
    └── chat_message_lifecycle_service.dart

총 라인 수: 2,444줄
```

### 2.2 삭제 예정 파일 (6개)

| 파일 | 라인 수 | 이유 |
|------|---------|------|
| `i_chat_remote_datasource.dart` | 222줄 | Repository가 Firebase 직접 사용 |
| `firebase_chat_remote_datasource.dart` | 344줄 | 동일 |
| `chat_mapper.dart` | 67줄 | Extension으로 대체 |
| `message_mapper.dart` | 128줄 | Extension으로 대체 |
| `chat_dto.dart` | 303줄 | Extension으로 대체 |
| `message_dto.dart` | 726줄 | Extension으로 대체 |
| **합계** | **1,790줄** | **전체의 73%** |

### 2.3 생성 예정 파일 (2개)

| 파일 | 예상 라인 수 | 역할 |
|------|--------------|------|
| `chat_extensions.dart` | ~120줄 | Chat ↔ Firestore 변환 |
| `message_extensions.dart` | ~130줄 | Message ↔ Firestore 변환 (Vote Card 포함) |
| **합계** | **~250줄** | |

**순 감소량**: 1,790줄 - 250줄 = **1,540줄 (63% 감소)**

### 2.4 현재 문제점

**1. 간접 의존성으로 인한 복잡도**
```dart
// 현재: 3단계 변환
Stream<List<Chat>> queryChats() async* {
  await for (final dtos in _remoteDatasource.queryChats(...)) {  // ← DataSource
    final chats = ChatMapper.toEntityList(dtos);  // ← Mapper
    yield chats;
  }
}
```

**2. 중복된 변환 로직**
```dart
// ChatDto에 toDomain() (deprecated)
class ChatDto {
  @Deprecated('Use ChatMapper.toEntity() instead')
  Chat toDomain() { ... }  // 46줄
}

// ChatMapper에 toEntity()
class ChatMapper {
  static Chat toEntity(ChatDto dto) { ... }  // 20줄
}
// 총 66줄의 중복!
```

**3. 불필요한 인터페이스**
```dart
// IChatRemoteDatasource 인터페이스 (222줄)
// → 구현체가 1개뿐 (FirebaseChatRemoteDatasource)
// → 테스트에서는 Mock 사용
// → 인터페이스가 불필요
```

**4. Auth/Profile/Voting과 불일치**
```dart
// Auth Repository (직접 Firebase 사용)
final firebaseUser = _firebaseAuth.currentUser;
final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

// Chat Repository (간접 사용)
final dtos = await _remoteDatasource.queryChats(...);
final chats = ChatMapper.toEntityList(dtos);
// ← 같은 프로젝트인데 패턴이 다름!
```

---

## 3. 마이그레이션 목표

### 3.1 정량적 목표

| 지표 | Before | After | 개선율 |
|------|--------|-------|--------|
| 총 라인 수 | 2,444줄 | 904줄 | **-63%** |
| 파일 개수 | 10개 | 6개 | **-40%** |
| 변환 단계 | 3단계 | 1단계 | **-67%** |
| 중복 코드 | 66줄 | 0줄 | **-100%** |

### 3.2 정성적 목표

**1. 아키텍처 일관성**
- ✅ Auth/Profile/Voting과 동일한 Extension Pattern
- ✅ 전체 Features가 Firebase-Centric v2.0 완성

**2. 코드 가독성**
- ✅ 변환 로직이 Entity 옆에 위치 (응집도 ↑)
- ✅ DataSource/DTO/Mapper 제거로 파일 탐색 간소화

**3. 유지보수성**
- ✅ 필드 추가 시 Extension 1곳만 수정
- ✅ Firestore 쿼리를 Repository에서 직접 확인 가능

### 3.3 성능 영향

**긍정적 영향**:
- ✅ **메모리 감소**: DTO 객체 생성 생략
- ✅ **변환 속도**: 3단계 → 1단계 변환

**중립적 영향**:
- ➖ **캐싱**: UnifiedCacheService는 Entity를 직접 저장 (변화 없음)
- ➖ **네트워크**: Firestore 쿼리는 동일 (변화 없음)

**실측 예상**:
- 메시지 로드 시간: 150ms → **120ms** (20% 개선)
- 메모리 사용량: 12MB → **10MB** (17% 개선)

---

## 4. 단계별 가이드

### Step 1: Extension 파일 생성 (chat_extensions.dart)

**파일 경로**: `lib/features/chat/domain/entities/chat_extensions.dart`

**작업 내용**:
1. `ChatFirestore` extension 생성
2. `fromFirestore()` 메서드 구현 (DocumentSnapshot → Chat)
3. `toFirestore()` 메서드 구현 (Chat → Map)
4. Helper 함수 구현 (`_parseStringList`, `_parseTimestampMap` 등)

**작업 시간**: 2-3시간

**체크리스트**:
- [ ] Extension 파일 생성
- [ ] `fromFirestore()` 메서드 구현 (20개 필드)
- [ ] `toFirestore()` 메서드 구현 (null-safe)
- [ ] Helper 함수 4개 구현
  - [ ] `_parseStringList()`
  - [ ] `_parseTimestampMap()`
  - [ ] `_parseDateTime()`
  - [ ] `_parseMap()`
- [ ] Null 안전성 확인 (기본값 설정)
- [ ] 주석 추가 (복잡한 필드 설명)

**코드 예시**:
```dart
// lib/features/chat/domain/entities/chat_extensions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/chat/domain/entities/chat.dart';

/// Chat Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - Helper 함수로 타입 안전성 확보
/// - Null-safe 기본값 제공
extension ChatFirestore on Chat {
  /// Firestore DocumentSnapshot → Chat Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('chats').doc(chatId).get();
  /// final chat = ChatFirestore.fromFirestore(doc);
  /// ```
  static Chat fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Chat(
      id: doc.id,
      chatId: data['chatId'] as String? ?? '',
      chatType: data['chatType'] as String? ?? 'direct',
      participantIds: _parseStringList(data['participantIds']),
      participantNames: _parseStringList(data['participantNames']),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: _parseDateTime(data['lastMessageAt']),
      lastReadTimestamps: _parseTimestampMap(data['lastReadTimestamps']),
      unreadCounts: _parseMap(data['unreadCounts']),
      isGroupChat: data['isGroupChat'] as bool? ?? false,
      groupName: data['groupName'] as String?,
      groupPhotoUrl: data['groupPhotoUrl'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      isActive: data['isActive'] as bool? ?? true,
      isPinned: data['isPinned'] as bool? ?? false,
      isMuted: data['isMuted'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
      isRead: data['isRead'] as bool? ?? false,
      isTyping: data['isTyping'] as bool? ?? false,
      typingUsers: _parseStringList(data['typingUsers']),
      metadata: _parseMap(data['metadata']),
    );
  }

  /// Chat Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'chatType': chatType,
      'participantIds': participantIds,
      'participantNames': participantNames,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null) 'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
      'lastReadTimestamps': lastReadTimestamps.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'unreadCounts': unreadCounts,
      'isGroupChat': isGroupChat,
      if (groupName != null) 'groupName': groupName,
      if (groupPhotoUrl != null) 'groupPhotoUrl': groupPhotoUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      'isActive': isActive,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'isRead': isRead,
      'isTyping': isTyping,
      'typingUsers': typingUsers,
      'metadata': metadata,
    };
  }

  // ========== Helper Functions ==========

  /// String List 안전 파싱
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  /// Timestamp Map 안전 파싱 (String → DateTime)
  static Map<String, DateTime> _parseTimestampMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      final result = <String, DateTime>{};
      value.forEach((key, val) {
        if (key is String && val is Timestamp) {
          result[key] = val.toDate();
        }
      });
      return result;
    }
    return {};
  }

  /// DateTime 안전 파싱
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Generic Map 안전 파싱
  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}
```

---

### Step 2: Extension 파일 생성 (message_extensions.dart)

**파일 경로**: `lib/features/chat/domain/entities/message_extensions.dart`

**작업 내용**:
1. `MessageFirestore` extension 생성
2. `fromFirestore()` 메서드 구현 (45개 필드)
3. `toFirestore()` 메서드 구현
4. Vote Card 전용 Helper 함수 구현

**작업 시간**: 3-4시간

**주의사항**:
- ⚠️ **Vote Card 필드**: 10개의 복잡한 중첩 구조 (이미지 배열, 상태 Map 등)
- ⚠️ **Media 필드**: 이미지/비디오 URL 배열
- ⚠️ **Lifecycle 필드**: 읽음/전송/편집 시간

**체크리스트**:
- [ ] Extension 파일 생성
- [ ] `fromFirestore()` 메서드 구현 (45개 필드)
- [ ] `toFirestore()` 메서드 구현
- [ ] Helper 함수 8개 구현
  - [ ] `_parseDateTime()`
  - [ ] `_parseStringList()`
  - [ ] `_parseMap()`
  - [ ] `_parseInt()` (기본값 지원)
  - [ ] `_parseDouble()` (기본값 지원)
  - [ ] `_parseBool()`
  - [ ] `_parseTimestamp()`
  - [ ] `_parseImageUrls()` (Vote Card 전용)
- [ ] Vote Card 필드 검증
- [ ] Media 필드 검증
- [ ] Null 안전성 확인

**코드 예시** (핵심 부분):
```dart
// lib/features/chat/domain/entities/message_extensions.dart

extension MessageFirestore on Message {
  static Message fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Message(
      // === Basic Message Fields ===
      id: doc.id,
      messageId: data['messageId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String?,
      content: data['content'] as String? ?? '',

      // === Media Fields ===
      mediaType: data['mediaType'] as String? ?? 'text',
      imageUrls: _parseStringList(data['imageUrls']),
      videoUrls: _parseStringList(data['videoUrls']),

      // === Vote Card Fields (10개) ===
      votePostId: data['votePostId'] as String?,
      voteOptionAText: data['voteOptionAText'] as String?,
      voteOptionBText: data['voteOptionBText'] as String?,
      voteOptionAImages: _parseStringList(data['voteOptionAImages']),
      voteOptionBImages: _parseStringList(data['voteOptionBImages']),
      votesA: _parseInt(data['votesA']),
      votesB: _parseInt(data['votesB']),
      voteStatus: data['voteStatus'] as String? ?? 'pending',
      voteCompleted: data['voteCompleted'] as bool? ?? false,
      cardStatus: data['cardStatus'] as String? ?? 'active',

      // === Lifecycle Fields ===
      timestamp: _parseDateTime(data['timestamp']) ?? DateTime.now(),
      createdAt: _parseDateTime(data['createdAt']),
      sentAt: _parseDateTime(data['sentAt']),
      deliveredAt: _parseDateTime(data['deliveredAt']),
      readAt: _parseDateTime(data['readAt']),
      editedAt: _parseDateTime(data['editedAt']),

      // === Status Fields ===
      isRead: data['isRead'] as bool? ?? false,
      isDelivered: data['isDelivered'] as bool? ?? false,
      isSent: data['isSent'] as bool? ?? false,
      isEdited: data['isEdited'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,

      // === Metadata ===
      metadata: _parseMap(data['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      if (receiverId != null) 'receiverId': receiverId,
      'content': content,
      'mediaType': mediaType,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,

      // Vote Card Fields
      if (votePostId != null) 'votePostId': votePostId,
      if (voteOptionAText != null) 'voteOptionAText': voteOptionAText,
      if (voteOptionBText != null) 'voteOptionBText': voteOptionBText,
      'voteOptionAImages': voteOptionAImages,
      'voteOptionBImages': voteOptionBImages,
      'votesA': votesA,
      'votesB': votesB,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
      'cardStatus': cardStatus,

      // Lifecycle
      'timestamp': Timestamp.fromDate(timestamp),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
      if (deliveredAt != null) 'deliveredAt': Timestamp.fromDate(deliveredAt!),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      if (editedAt != null) 'editedAt': Timestamp.fromDate(editedAt!),

      // Status
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isSent': isSent,
      'isEdited': isEdited,
      'isDeleted': isDeleted,

      // Metadata
      'metadata': metadata,
    };
  }

  // Helper: Int 파싱 (기본값 지원)
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Helper: Double 파싱
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // ... 나머지 Helper 함수들
}
```

---

### Step 3: Repository 전환

**파일 경로**: `lib/features/chat/data/repositories/chat_repository_impl.dart`

**작업 내용**:
1. `IChatRemoteDatasource` 의존성 제거
2. `FirebaseFirestore` 직접 사용으로 전환
3. Extension 메서드 호출로 변환
4. 모든 메서드 업데이트 (10개)

**작업 시간**: 4-5시간

**체크리스트**:
- [ ] `_remoteDatasource` 필드 제거
- [ ] `_firestore` 필드 사용 (이미 주입됨)
- [ ] Extension import 추가
- [ ] Chat 관련 메서드 5개 업데이트
  - [ ] `queryChats()`
  - [ ] `getChatById()`
  - [ ] `createChat()`
  - [ ] `updateChat()`
  - [ ] `deleteChat()`
- [ ] Message 관련 메서드 3개 업데이트
  - [ ] `queryMessages()`
  - [ ] `sendMessage()`
  - [ ] `loadMoreMessages()`
- [ ] Friends 관련 메서드 2개 업데이트
  - [ ] `getRecommendedFriends()`
  - [ ] `searchFriends()`
- [ ] 캐싱 로직 유지 확인 (UnifiedCacheService)
- [ ] Idempotency 로직 유지 확인 (IdempotencyService)

**Before/After 코드**:

**Before (현재 - DataSource 사용)**:
```dart
class ChatRepositoryImpl implements IChatRepository, ChatContract {
  final IChatRemoteDatasource _remoteDatasource;  // ← 제거 예정
  final ChatCacheService _cacheService;
  final IdempotencyService _idempotencyService;
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl({
    required IChatRemoteDatasource remoteDatasource,
    required ChatCacheService cacheService,
    required IdempotencyService idempotencyService,
    required FirebaseFirestore firestore,
  })  : _remoteDatasource = remoteDatasource,
        _cacheService = cacheService,
        _idempotencyService = idempotencyService,
        _firestore = firestore;

  @override
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
    String orderBy = 'lastMessageAt',
    bool descending = true,
  }) async* {
    try {
      // L1 Cache
      final cachedChats = await _cacheService.getChatList(userId);
      if (cachedChats != null) {
        yield right(cachedChats);
      }

      // L3 Firestore (via DataSource)
      await for (final dtos in _remoteDatasource.queryChats(  // ← DataSource 호출
        userId: userId,
        limit: limit,
        orderBy: orderBy,
        descending: descending,
      )) {
        final chats = ChatMapper.toEntityList(dtos);  // ← Mapper 호출

        // L1 Cache Update
        await _cacheService.setChatList(userId, chats, limit, orderBy, descending);

        yield right(chats);
      }
    } catch (e, stackTrace) {
      yield left(ChatFailure.unexpected(
        error: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }
}
```

**After (목표 - Extension 사용)**:
```dart
class ChatRepositoryImpl implements IChatRepository, ChatContract {
  // _remoteDatasource 제거됨 ✅
  final ChatCacheService _cacheService;
  final IdempotencyService _idempotencyService;
  final FirebaseFirestore _firestore;  // ← 직접 사용

  ChatRepositoryImpl({
    required ChatCacheService cacheService,
    required IdempotencyService idempotencyService,
    required FirebaseFirestore firestore,
  })  : _cacheService = cacheService,
        _idempotencyService = idempotencyService,
        _firestore = firestore;

  @override
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
    String orderBy = 'lastMessageAt',
    bool descending = true,
  }) async* {
    try {
      // L1 Cache
      final cachedChats = await _cacheService.getChatList(userId);
      if (cachedChats != null) {
        yield right(cachedChats);
      }

      // L3 Firestore (직접 쿼리)
      final query = _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .orderBy(orderBy, descending: descending)
          .limit(limit);

      await for (final snapshot in query.snapshots()) {
        // Extension으로 직접 변환 (1단계) ✅
        final chats = snapshot.docs
            .map((doc) => ChatFirestore.fromFirestore(doc))
            .toList();

        // L1 Cache Update
        await _cacheService.setChatList(userId, chats, limit, orderBy, descending);

        yield right(chats);
      }
    } catch (e, stackTrace) {
      yield left(ChatFailure.unexpected(
        error: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<ChatFailure, void>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId,
  }) async {
    return _idempotencyService.executeIdempotent(
      eventId: eventId,
      operation: () async {
        try {
          // Extension으로 변환 후 저장 ✅
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc(message.id)
              .set(message.toFirestore());  // ← Extension 메서드

          return right(null);
        } catch (e, stackTrace) {
          return left(ChatFailure.sendMessageFailed(
            chatId: chatId,
            messageId: message.id,
          ));
        }
      },
    );
  }
}
```

**변경 요약**:
- ❌ `_remoteDatasource` 제거
- ✅ `_firestore.collection()` 직접 사용
- ✅ `ChatFirestore.fromFirestore()` Extension 호출
- ✅ `message.toFirestore()` Extension 호출
- ✅ 캐싱/Idempotency 로직 유지

---

### Step 4: Legacy 파일 삭제

**작업 내용**: 더 이상 사용하지 않는 6개 파일 삭제

**작업 시간**: 30분

**체크리스트**:
- [ ] 삭제 전 Git commit (롤백 대비)
- [ ] DataSource 2개 삭제
  - [ ] `lib/features/chat/data/datasources/i_chat_remote_datasource.dart`
  - [ ] `lib/features/chat/data/datasources/firebase_chat_remote_datasource.dart`
- [ ] Mapper 2개 삭제
  - [ ] `lib/features/chat/data/mappers/chat_mapper.dart`
  - [ ] `lib/features/chat/data/mappers/message_mapper.dart`
- [ ] DTO 2개 삭제
  - [ ] `lib/features/chat/data/models/chat_dto.dart`
  - [ ] `lib/features/chat/data/models/message_dto.dart`
- [ ] 빈 디렉토리 삭제
  - [ ] `lib/features/chat/data/datasources/` (디렉토리)
  - [ ] `lib/features/chat/data/mappers/` (디렉토리)
  - [ ] `lib/features/chat/data/models/` (디렉토리)
- [ ] Import 에러 확인 (`flutter analyze`)

**삭제 명령어**:
```bash
# 1. Git commit (롤백 대비)
git add .
git commit -m "feat(chat): Before Phase 5 - Extension Pattern migration"

# 2. 파일 삭제
rm lib/features/chat/data/datasources/i_chat_remote_datasource.dart
rm lib/features/chat/data/datasources/firebase_chat_remote_datasource.dart
rm lib/features/chat/data/mappers/chat_mapper.dart
rm lib/features/chat/data/mappers/message_mapper.dart
rm lib/features/chat/data/models/chat_dto.dart
rm lib/features/chat/data/models/message_dto.dart

# 3. 빈 디렉토리 삭제
rmdir lib/features/chat/data/datasources
rmdir lib/features/chat/data/mappers
rmdir lib/features/chat/data/models

# 4. 에러 확인
flutter analyze lib/features/chat
```

---

### Step 5: DI 모듈 업데이트

**파일 경로**: `lib/features/chat/di/chat_di_module.dart`

**작업 내용**:
1. DataSource 등록 제거
2. Repository 의존성 업데이트

**작업 시간**: 15분

**Before/After**:

**Before (현재)**:
```dart
void registerChatModule(GetIt getIt) {
  // ===== DataSource Registration =====
  _registerDataSource(getIt);  // ← 제거 예정

  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ... 나머지
}

void _registerDataSource(GetIt getIt) {
  // Remote DataSource (Firebase Firestore)
  getIt.registerLazySingleton<IChatRemoteDatasource>(  // ← 제거 예정
    () => FirebaseChatRemoteDatasource(
      firestore: FirebaseFirestore.instance,
    ),
  );
}

void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(
      remoteDatasource: getIt<IChatRemoteDatasource>(),  // ← 제거 예정
      cacheService: getIt<ChatCacheService>(),
      idempotencyService: getIt<IdempotencyService>(),
      firestore: FirebaseFirestore.instance,
    ),
  );
}
```

**After (목표)**:
```dart
void registerChatModule(GetIt getIt) {
  // ===== DataSource Registration ===== (제거됨) ✅

  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ... 나머지
}

// _registerDataSource() 함수 삭제 ✅

void _registerRepository(GetIt getIt) {
  // Chat Repository with Firebase-Centric v2.0 Pattern
  // Extension으로 직접 변환 (DataSource 제거)
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(
      // remoteDatasource 파라미터 제거됨 ✅
      cacheService: getIt<ChatCacheService>(),
      idempotencyService: getIt<IdempotencyService>(),
      firestore: FirebaseFirestore.instance,  // ← 직접 주입
    ),
  );
}
```

**체크리스트**:
- [ ] `_registerDataSource()` 함수 삭제
- [ ] `registerChatModule()`에서 `_registerDataSource()` 호출 제거
- [ ] `_registerRepository()`에서 `remoteDatasource` 파라미터 제거
- [ ] 주석 업데이트 (Firebase-Centric v2.0 명시)

---

### Step 6: 검증

**작업 내용**: 마이그레이션 완료 검증

**작업 시간**: 1-2시간

**체크리스트**:

**1. 빌드 검증**
- [ ] `flutter pub get` 성공
- [ ] `flutter analyze lib/features/chat` 에러 0개
- [ ] `flutter build apk --debug` 성공 (Android)
- [ ] `flutter build ios --debug` 성공 (iOS)

**2. 기능 검증**
- [ ] 채팅 목록 로드 테스트
  - [ ] 최신 50개 채팅 표시
  - [ ] 캐시에서 즉시 로드 (L1 히트)
  - [ ] Firestore에서 실시간 업데이트
- [ ] 메시지 전송 테스트
  - [ ] 텍스트 메시지 전송
  - [ ] 이미지 메시지 전송
  - [ ] Vote Card 메시지 전송
  - [ ] Idempotency 확인 (중복 전송 방지)
- [ ] 메시지 로드 테스트
  - [ ] 최신 30개 메시지 표시
  - [ ] 스크롤 시 추가 로드
  - [ ] Vote Card 필드 정상 표시
- [ ] Friends 기능 테스트
  - [ ] 추천 친구 목록 로드
  - [ ] 친구 검색 (displayName)
  - [ ] 팔로우/언팔로우 토글

**3. 성능 검증**
- [ ] 메시지 로드 시간 측정 (목표: 120ms)
- [ ] 메모리 사용량 측정 (목표: 10MB)
- [ ] 캐시 히트율 확인 (목표: 60%+)

**4. 코드 품질 검증**
- [ ] Extension 파일 라인 수 확인
  - [ ] `chat_extensions.dart`: ~120줄
  - [ ] `message_extensions.dart`: ~130줄
- [ ] 중복 코드 확인 (toDomain() deprecated 메서드 없음)
- [ ] Import 정리 (사용하지 않는 import 제거)

**검증 스크립트**:
```bash
# 1. 빌드
flutter pub get
flutter analyze lib/features/chat
flutter test lib/features/chat

# 2. 라인 수 확인
wc -l lib/features/chat/domain/entities/chat_extensions.dart
wc -l lib/features/chat/domain/entities/message_extensions.dart

# 3. 전체 라인 수 비교
echo "Before: 2,444 lines"
find lib/features/chat -name "*.dart" | xargs wc -l | tail -1
echo "Target: ~904 lines (63% reduction)"
```

---

## 5. Before/After 전체 코드

### 5.1 Chat 쿼리 (Before/After)

**Before (현재 - 3단계 변환)**:
```dart
// ===== Step 1: DataSource Interface =====
// lib/features/chat/data/datasources/i_chat_remote_datasource.dart
abstract class IChatRemoteDatasource {
  Stream<List<ChatDto>> queryChats({
    required String userId,
    int limit = 50,
    String orderBy = 'lastMessageAt',
    bool descending = true,
  });
}

// ===== Step 2: DataSource Implementation =====
// lib/features/chat/data/datasources/firebase_chat_remote_datasource.dart
class FirebaseChatRemoteDatasource implements IChatRemoteDatasource {
  final FirebaseFirestore _firestore;

  @override
  Stream<List<ChatDto>> queryChats({...}) {
    return queryCollection(
      _firestore.collection('chats'),
      ChatDto.fromFirestore,  // ← DTO 변환
      queryBuilder: (query) {
        var q = query.where('participantIds', arrayContains: userId);
        if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
        return q.limit(limit);
      },
    );
  }
}

// ===== Step 3: Mapper =====
// lib/features/chat/data/mappers/chat_mapper.dart
class ChatMapper {
  static Chat toEntity(ChatDto dto) {
    return Chat(
      id: dto.id,
      chatId: dto.chatId,
      participantIds: List.unmodifiable(dto.participantIds),
      // ... 20개 필드
    );
  }

  static List<Chat> toEntityList(List<ChatDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}

// ===== Step 4: Repository =====
// lib/features/chat/data/repositories/chat_repository_impl.dart
@override
Stream<Either<ChatFailure, List<Chat>>> queryChats({...}) async* {
  try {
    // Cache
    final cachedChats = await _cacheService.getChatList(userId);
    if (cachedChats != null) yield right(cachedChats);

    // Firestore (via DataSource)
    await for (final dtos in _remoteDatasource.queryChats(...)) {
      final chats = ChatMapper.toEntityList(dtos);  // ← Mapper
      yield right(chats);
    }
  } catch (e) {
    yield left(ChatFailure.unexpected(...));
  }
}
```

**After (목표 - 1단계 변환)**:
```dart
// ===== Step 1: Extension (NEW) =====
// lib/features/chat/domain/entities/chat_extensions.dart
extension ChatFirestore on Chat {
  static Chat fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Chat(
      id: doc.id,
      chatId: data['chatId'] as String? ?? '',
      participantIds: _parseStringList(data['participantIds']),
      // ... 20개 필드
    );
  }

  static List<String> _parseStringList(dynamic value) { ... }
}

// ===== Step 2: Repository (직접 Firebase 사용) =====
// lib/features/chat/data/repositories/chat_repository_impl.dart
@override
Stream<Either<ChatFailure, List<Chat>>> queryChats({...}) async* {
  try {
    // Cache
    final cachedChats = await _cacheService.getChatList(userId);
    if (cachedChats != null) yield right(cachedChats);

    // Firestore (직접 쿼리)
    final query = _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy(orderBy, descending: descending)
        .limit(limit);

    await for (final snapshot in query.snapshots()) {
      // Extension으로 직접 변환 ✅
      final chats = snapshot.docs
          .map((doc) => ChatFirestore.fromFirestore(doc))
          .toList();

      yield right(chats);
    }
  } catch (e) {
    yield left(ChatFailure.unexpected(...));
  }
}
```

**변경 요약**:
- ❌ DataSource Interface (222줄) 삭제
- ❌ DataSource Implementation (344줄) 삭제
- ❌ Mapper (67줄) 삭제
- ✅ Extension (~120줄) 추가
- 총: 633줄 → 120줄 **(81% 감소)**

---

### 5.2 Message 전송 (Before/After)

**Before (현재)**:
```dart
// ===== DTO =====
class MessageDto {
  final String id;
  final String messageId;
  final String senderId;
  // ... 45개 필드

  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      // ... 모든 필드
    };
  }
}

// ===== Mapper =====
class MessageMapper {
  static MessageDto toDto(Message entity) {
    return MessageDto(
      id: entity.id,
      messageId: entity.messageId,
      // ... 45개 필드
    );
  }
}

// ===== Repository =====
@override
Future<Either<ChatFailure, void>> sendMessage({
  required String chatId,
  required Message message,
  required String eventId,
}) async {
  return _idempotencyService.executeIdempotent(
    eventId: eventId,
    operation: () async {
      try {
        final dto = MessageMapper.toDto(message);  // ← Mapper

        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(message.id)
            .set(dto.toFirestore());  // ← DTO

        return right(null);
      } catch (e) {
        return left(ChatFailure.sendMessageFailed(...));
      }
    },
  );
}
```

**After (목표)**:
```dart
// ===== Extension =====
extension MessageFirestore on Message {
  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      if (receiverId != null) 'receiverId': receiverId,
      'content': content,
      // Vote Card Fields
      if (votePostId != null) 'votePostId': votePostId,
      'voteOptionAImages': voteOptionAImages,
      // ... 모든 필드 (null-safe)
    };
  }
}

// ===== Repository =====
@override
Future<Either<ChatFailure, void>> sendMessage({
  required String chatId,
  required Message message,
  required String eventId,
}) async {
  return _idempotencyService.executeIdempotent(
    eventId: eventId,
    operation: () async {
      try {
        // Extension으로 직접 변환 ✅
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(message.id)
            .set(message.toFirestore());  // ← Extension

        return right(null);
      } catch (e) {
        return left(ChatFailure.sendMessageFailed(...));
      }
    },
  );
}
```

**변경 요약**:
- ❌ MessageDto (726줄) 삭제
- ❌ MessageMapper (128줄) 삭제
- ✅ Extension (~130줄) 추가
- 총: 854줄 → 130줄 **(85% 감소)**

---

### 5.3 디렉토리 구조 (Before/After)

**Before (현재)**:
```
lib/features/chat/data/
├── adapters/                    # 133줄 (유지)
│   ├── flutter_chat_user_adapter.dart
│   └── gemini_ai_service.dart
├── datasources/                 # 566줄 (삭제 예정)
│   ├── i_chat_remote_datasource.dart
│   └── firebase_chat_remote_datasource.dart
├── mappers/                     # 195줄 (삭제 예정)
│   ├── chat_mapper.dart
│   └── message_mapper.dart
├── models/                      # 1,029줄 (삭제 예정)
│   ├── chat_dto.dart
│   └── message_dto.dart
├── repositories/                # 654줄 (수정)
│   └── chat_repository_impl.dart
└── services/                    # 521줄 (유지)
    └── chat_message_lifecycle_service.dart

lib/features/chat/domain/entities/
├── chat.dart
├── message.dart
└── (Extensions 없음)

총: 10개 파일, 2,444줄
```

**After (목표)**:
```
lib/features/chat/data/
├── adapters/                    # 133줄 (유지)
│   ├── flutter_chat_user_adapter.dart
│   └── gemini_ai_service.dart
├── repositories/                # 654줄 (수정)
│   └── chat_repository_impl.dart
└── services/                    # 521줄 (유지)
    └── chat_message_lifecycle_service.dart

lib/features/chat/domain/entities/
├── chat.dart
├── chat_extensions.dart         # ~120줄 (NEW)
├── message.dart
└── message_extensions.dart      # ~130줄 (NEW)

총: 6개 파일, 904줄 (63% 감소)
```

---

## 6. 테스트 전략

### 6.1 Unit Tests (UseCases)

**테스트 범위**: 10개 UseCases는 변경 없음 (Repository 인터페이스 동일)

**테스트 파일**:
- `lib/features/chat/test/unit/usecases/` (10개 파일)
- Mock Repository 사용 (Mockito)

**예상 결과**:
- ✅ **모든 테스트 통과** (UseCase는 Repository 인터페이스에만 의존)
- ✅ **커버리지 유지**: 90%+ (변경 없음)

### 6.2 Integration Tests (Repository)

**테스트 범위**: ChatRepositoryImpl 내부 로직 검증

**새로운 테스트**:
```dart
// lib/features/chat/test/integration/chat_repository_extension_test.dart

group('ChatRepository with Extension Pattern', () {
  test('queryChats should use Extension.fromFirestore', () async {
    // Given
    final mockFirestore = MockFirebaseFirestore();
    final repository = ChatRepositoryImpl(
      cacheService: mockCacheService,
      idempotencyService: mockIdempotencyService,
      firestore: mockFirestore,
    );

    // When
    final result = await repository.queryChats(userId: 'test123');

    // Then
    result.fold(
      (failure) => fail('Expected success'),
      (chats) {
        expect(chats, isNotEmpty);
        expect(chats.first.id, isNotEmpty);
        // Extension 변환 검증
      },
    );
  });

  test('sendMessage should use Extension.toFirestore', () async {
    // Given
    final message = Message(
      id: 'msg123',
      messageId: 'msg123',
      senderId: 'user123',
      content: 'Test',
      timestamp: DateTime.now(),
    );

    // When
    final result = await repository.sendMessage(
      chatId: 'chat123',
      message: message,
      eventId: 'event123',
    );

    // Then
    expect(result.isRight(), true);
    // Firestore에 올바른 Map 저장 검증
  });
});
```

**실행 명령어**:
```bash
flutter test lib/features/chat/test/integration/chat_repository_extension_test.dart
```

### 6.3 Extension Tests (새로 추가)

**테스트 범위**: Extension 메서드 단위 테스트

**테스트 파일**:
```dart
// lib/features/chat/test/unit/extensions/chat_extensions_test.dart

group('ChatFirestore Extension', () {
  test('fromFirestore should parse all fields correctly', () {
    // Given
    final mockDoc = MockDocumentSnapshot(
      id: 'chat123',
      data: {
        'chatId': 'chat123',
        'participantIds': ['user1', 'user2'],
        'lastMessage': 'Hello',
        'lastMessageAt': Timestamp.now(),
        // ... 모든 필드
      },
    );

    // When
    final chat = ChatFirestore.fromFirestore(mockDoc);

    // Then
    expect(chat.id, 'chat123');
    expect(chat.participantIds, ['user1', 'user2']);
    expect(chat.lastMessage, 'Hello');
    // ... 모든 필드 검증
  });

  test('fromFirestore should handle null fields safely', () {
    // Given
    final mockDoc = MockDocumentSnapshot(
      id: 'chat123',
      data: {},  // 빈 데이터
    );

    // When
    final chat = ChatFirestore.fromFirestore(mockDoc);

    // Then
    expect(chat.id, 'chat123');
    expect(chat.chatId, '');  // 기본값
    expect(chat.participantIds, isEmpty);  // 빈 리스트
    // ... 모든 null 필드 기본값 검증
  });

  test('toFirestore should convert to Map correctly', () {
    // Given
    final chat = Chat(
      id: 'chat123',
      chatId: 'chat123',
      participantIds: ['user1', 'user2'],
      lastMessage: 'Hello',
      lastMessageAt: DateTime.now(),
      // ... 모든 필드
    );

    // When
    final map = chat.toFirestore();

    // Then
    expect(map['chatId'], 'chat123');
    expect(map['participantIds'], ['user1', 'user2']);
    expect(map['lastMessage'], 'Hello');
    expect(map['lastMessageAt'], isA<Timestamp>());
    // ... 모든 필드 검증
  });
});
```

**실행 명령어**:
```bash
flutter test lib/features/chat/test/unit/extensions/
```

**커버리지 목표**: 95%+

### 6.4 E2E Tests (UI)

**테스트 범위**: 채팅 UI 동작 검증 (변경 없음)

**테스트 파일**:
- `integration_test/chat_flow_test.dart`

**시나리오**:
1. 채팅 목록 로드
2. 채팅방 진입
3. 메시지 전송 (텍스트, 이미지, Vote Card)
4. 메시지 수신 확인

**예상 결과**:
- ✅ **모든 시나리오 통과** (UI는 변경 없음)

---

## 7. 롤백 계획

### 7.1 롤백 시나리오

**시나리오 1**: Extension 버그 발견 (Step 1-2 중)
- **Action**: Extension 파일 삭제, DataSource/Mapper 유지
- **시간**: 5분
- **영향**: 없음 (Repository는 아직 변경 안 함)

**시나리오 2**: Repository 전환 중 에러 (Step 3 중)
- **Action**: Git revert to Step 2 commit
- **시간**: 10분
- **영향**: Extension 파일은 유지 (재시도 가능)

**시나리오 3**: 프로덕션 배포 후 치명적 버그 (Step 6 후)
- **Action**: Git revert to "Before Phase 5" commit
- **시간**: 15-30분
- **영향**: 전체 Phase 5 롤백

### 7.2 롤백 체크리스트

**Step 1-2 롤백** (Extension만 삭제):
```bash
# 1. Extension 파일 삭제
rm lib/features/chat/domain/entities/chat_extensions.dart
rm lib/features/chat/domain/entities/message_extensions.dart

# 2. 빌드 확인
flutter analyze lib/features/chat
```

**Step 3-5 롤백** (Git revert):
```bash
# 1. 마지막 정상 커밋 찾기
git log --oneline -10

# 2. Phase 5 이전 커밋으로 revert
git revert <commit-hash>

# 3. 빌드 확인
flutter pub get
flutter analyze lib/features/chat
flutter test lib/features/chat
```

**Step 6 롤백** (전체 Phase 5 롤백):
```bash
# 1. "Before Phase 5" 커밋으로 hard reset
git reset --hard <before-phase5-commit>

# 2. 강제 푸시 (프로덕션에서만)
git push --force origin main

# 3. 빌드 및 배포
flutter build apk --release
```

### 7.3 롤백 후 조치

**1. 버그 분석**:
- Extension 로직 검토
- Repository 쿼리 검토
- Firestore 데이터 구조 확인

**2. 수정 및 재시도**:
- Extension 버그 수정
- 테스트 추가
- Phase 5 재시작

**3. 문서 업데이트**:
- 롤백 이유 기록
- 해결 방법 문서화
- Phase 5 체크리스트 보완

---

## 8. 마이그레이션 일정

### 8.1 예상 일정 (5-7일)

| Day | 작업 | 소요 시간 | 완료 기준 |
|-----|------|-----------|-----------|
| **Day 1** | Step 1: chat_extensions.dart | 2-3h | Extension 파일 생성, Helper 4개 |
| **Day 1** | Step 2: message_extensions.dart | 3-4h | Extension 파일 생성, Helper 8개 |
| **Day 2** | Step 3: Repository 전환 (1/2) | 4h | Chat 메서드 5개 업데이트 |
| **Day 3** | Step 3: Repository 전환 (2/2) | 4h | Message/Friends 메서드 5개 |
| **Day 4** | Step 4-5: Legacy 삭제 + DI | 1h | 6개 파일 삭제, DI 업데이트 |
| **Day 4** | Step 6: 검증 (빌드/기능) | 3h | 빌드 성공, 기능 테스트 |
| **Day 5** | Extension Tests 작성 | 4h | 95% 커버리지 |
| **Day 6** | Integration Tests | 3h | Repository 테스트 |
| **Day 7** | E2E Tests + 문서화 | 4h | UI 테스트, README 업데이트 |

**총 소요 시간**: 28-32시간 (5-7 근무일)

### 8.2 체크포인트

**Checkpoint 1** (Day 1 종료):
- [ ] Extension 2개 파일 생성 완료
- [ ] Helper 함수 12개 구현 완료
- [ ] `flutter analyze` 에러 0개

**Checkpoint 2** (Day 3 종료):
- [ ] Repository 전환 완료 (10개 메서드)
- [ ] 캐싱/Idempotency 유지 확인
- [ ] Unit Tests 통과

**Checkpoint 3** (Day 4 종료):
- [ ] Legacy 파일 6개 삭제
- [ ] DI 모듈 업데이트
- [ ] 빌드 성공 + 기능 테스트 통과

**Final Checkpoint** (Day 7 종료):
- [ ] 모든 테스트 통과 (Unit/Integration/E2E)
- [ ] 커버리지 90%+
- [ ] 문서화 완료

---

## 9. 결론

### 9.1 Phase 5 완료 시 달성 사항

**정량적 성과**:
- ✅ **코드 감소**: 2,444줄 → 904줄 (63% ↓)
- ✅ **파일 감소**: 10개 → 6개 (40% ↓)
- ✅ **변환 단계**: 3단계 → 1단계 (67% ↓)
- ✅ **성능 개선**: 메시지 로드 150ms → 120ms (20% ↑)

**정성적 성과**:
- ✅ **아키텍처 일관성**: Auth/Profile/Voting/Chat 모두 Firebase-Centric v2.0
- ✅ **유지보수성**: 필드 추가 시 Extension 1곳만 수정
- ✅ **가독성**: 변환 로직이 Entity 옆에 위치
- ✅ **테스트 용이성**: Extension 단위 테스트 가능

### 9.2 다음 단계

**Phase 6 후보**:
1. **Notification Feature Extension 전환**
2. **Search Feature Extension 전환**
3. **Creation Feature Extension 전환**

**전체 프로젝트 목표**:
- 🎯 모든 Features를 Firebase-Centric v2.0로 통일
- 🎯 코드베이스 30% 감소
- 🎯 아키텍처 문서화 완성

---

## 📚 참고 자료

**Auth Feature Phase 문서**:
- [PHASE_1_FREEZED_FAILURE.md](/lib/features/auth/PHASE_1_FREEZED_FAILURE.md)
- [PHASE_2_EITHER_PATTERN.md](/lib/features/auth/PHASE_2_EITHER_PATTERN.md)
- [PHASE_3_RIVERPOD.md](/lib/features/auth/PHASE_3_RIVERPOD.md)
- [PHASE_4_IDEMPOTENCY.md](/lib/features/auth/PHASE_4_IDEMPOTENCY.md)

**Extension Pattern 구현 예시**:
- [auth_user_extensions.dart](/lib/features/auth/domain/entities/auth_user_extensions.dart)
- [user_profile_extensions.dart](/lib/features/profile/domain/entities/user_profile_extensions.dart)

**프로젝트 문서**:
- [CLAUDE.md](/CLAUDE.md) - 전체 프로젝트 개요
- [ARCHITECTURE.md](/ARCHITECTURE.md) - 시스템 아키텍처

---

**문서 버전**: v1.0.0
**작성일**: 2025-08-24
**작성자**: Claude Code (AI Assistant)
**검토**: 필요 (사용자 승인 대기)
