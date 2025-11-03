# Chat Domain Layer - Clean Architecture v4.0

> **Last Updated**: 2025-11-01
> **Architecture**: Clean Architecture v4.0 - Domain Layer
> **Pattern**: Repository Pattern + UseCase Pattern + Extension Pattern + Port-Adapter Pattern
> **Dependencies**: Pure Dart (No Flutter/Firebase)

## Overview

**Chat Domain Layer**는 채팅 Feature의 핵심 비즈니스 로직과 규칙을 정의하는 순수 Dart 레이어입니다. Clean Architecture v4.0의 가장 안쪽 원으로, 외부 의존성이 전혀 없으며 프레임워크에 독립적입니다.

### Core Principles

1. **Framework Independence**: Flutter, Firebase 등 외부 프레임워크 의존성 제거
2. **Testability**: 모든 비즈니스 로직은 단위 테스트 가능
3. **Immutability**: Freezed를 통한 불변 엔티티 설계
4. **Type Safety**: Either 패턴으로 타입 안전한 에러 처리
5. **Single Responsibility**: UseCase 패턴으로 단일 책임 원칙 준수
6. **Dependency Inversion**: Repository 인터페이스로 의존성 역전
7. **Extension Pattern**: Entity ↔ Firestore 변환을 Extension 메서드로 구현
8. **Port-Adapter Pattern**: AI 서비스를 Port 인터페이스로 추상화

### Domain Layer vs Data Layer

| Aspect | Domain Layer | Data Layer |
|--------|-------------|------------|
| **Purpose** | 비즈니스 개념 정의 | 구체적 구현 |
| **Dependencies** | Pure Dart only | Firebase, Hive, etc |
| **Entities** | Domain models | Extensions, Adapters |
| **Repositories** | Interfaces (abstract) | Implementations |
| **Focus** | What & Why | How |
| **Testing** | Unit tests (fast) | Integration tests (slow) |
| **Architecture** | Clean Architecture v4.0 | Firebase-Centric v2.0 |

---

## Directory Structure (20 files)

```
domain/
├── constants/
│   └── chat_constants.dart               # 48 lines - Feature-specific constants
│
├── entities/                              # Domain entities (2 main + 2 extensions)
│   ├── chat.dart                          # 147 lines - Chat room entity
│   ├── chat.freezed.dart                  # Generated
│   ├── chat.g.dart                        # Generated
│   ├── chat_extensions.dart               # 159 lines - Firestore ↔ Chat conversion
│   ├── message.dart                       # 313 lines - Message entity
│   ├── message.freezed.dart               # Generated
│   ├── message.g.dart                     # Generated
│   └── message_extensions.dart            # 277 lines - Firestore ↔ Message conversion
│
├── enums/
│   └── message_delivery_status.dart       # 31 lines - Message delivery states
│
├── failures/
│   └── chat_failure.dart                  # 175 lines - 17 error types
│
├── ports/                                 # Port-Adapter Pattern
│   └── i_ai_service.dart                  # 44 lines - AI service interface
│
├── repositories/
│   └── i_chat_repository.dart             # 390 lines - Repository interface (20+ methods)
│
└── usecases/                              # Business logic (10 usecases)
    ├── get_chat_list_usecase.dart         # 36 lines - Fetch chat list
    ├── get_chat_messages_usecase.dart     # 36 lines - Fetch messages
    ├── load_more_messages_usecase.dart    # 39 lines - Pagination
    ├── send_message_usecase.dart          # 50 lines - Send message
    ├── send_ai_query_usecase.dart         # 53 lines - AI chat
    ├── search_messages_usecase.dart       # 37 lines - Search
    ├── get_recommended_friends_usecase.dart # 37 lines - Friend recommendations
    ├── search_friends_usecase.dart        # 39 lines - Friend search
    ├── send_friend_request_usecase.dart   # 37 lines - Friend request
    └── toggle_follow_usecase.dart         # 38 lines - Follow/Unfollow
```

**Total**: 20 main files + 6 generated files = **26 files**, **3,386 lines**

---

## entities/ - Domain Entities Deep Dive

Domain entities는 비즈니스 개념을 표현하는 불변 객체입니다. Freezed 패키지를 사용하여 불변성, JSON 직렬화, copyWith, equality를 자동 생성합니다.

### 1. Chat Entity (chat.dart)

**Purpose**: 채팅방을 나타내는 핵심 엔티티

```dart
@freezed
sealed class Chat with _$Chat {
  const Chat._();

  const factory Chat({
    /// 채팅방 고유 ID
    required String id,

    /// 채팅방 식별자
    required String chatId,

    /// 채팅방 타입 (1:1, group 등)
    required String chatType,

    /// 참여자 ID 목록
    required List<String> participantIds,

    /// 채팅방 이름
    required String chatName,

    /// 마지막 메시지 내용
    required String lastMessageContent,

    /// 마지막 메시지 시간
    DateTime? lastMessageAt,

    /// 읽음 여부
    required bool isRead,

    /// 생성 시간
    DateTime? createdAt,

    /// 사용자별 마지막 읽은 시간
    required Map<String, DateTime> lastReadTimestamps,

    // 사용자 정보 (TODO: Profile Feature로 이동 예정)
    @Default('') String email,
    @Default('') String displayName,
    @Default('') String photoUrl,
    @Default('') String uid,
    DateTime? createdTime,
    @Default('') String phoneNumber,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  // ========== Business Logic Methods ==========

  /// 특정 사용자의 마지막 읽은 시간 조회
  DateTime? getLastReadFor(String userId) {
    return lastReadTimestamps[userId];
  }

  /// 특정 사용자가 채팅방 참여자인지 확인
  bool hasParticipant(String userId) {
    return participantIds.contains(userId);
  }

  /// 채팅방에 읽지 않은 메시지가 있는지 확인
  bool hasUnreadMessages(String userId) {
    final lastRead = getLastReadFor(userId);
    if (lastRead == null || lastMessageAt == null) return true;
    return lastMessageAt!.isAfter(lastRead);
  }

  /// 1:1 채팅방 여부
  bool get isDirectChat => chatType == 'direct' || participantIds.length == 2;

  /// 그룹 채팅방 여부
  bool get isGroupChat => chatType == 'group' || participantIds.length > 2;

  /// 참여자 수
  int get participantCount => participantIds.length;

  /// 상대방 사용자 ID 조회 (1:1 채팅 전용)
  String? getOtherUserId(String currentUserId) {
    if (!isDirectChat) return null;
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
```

**Key Features**:
- ✅ Immutable (Freezed)
- ✅ Rich business logic (7+ getter methods)
- ✅ JSON serialization
- ✅ Type safety
- ✅ User tracking (lastReadTimestamps Map)

### 2. Message Entity (message.dart)

**Purpose**: 채팅 메시지를 나타내는 복합 엔티티

```dart
@freezed
sealed class Message with _$Message {
  const Message._();

  const factory Message({
    /// 메시지 고유 ID
    required String id,

    /// 메시지 작성자 ID
    required String authorId,

    /// 채팅방 ID
    required String chatId,

    /// 메시지 타입 (text, image, video, vote, system)
    required String messageType,

    /// 텍스트 내용
    @Default('') String text,

    /// 메시지 전송 시간
    required DateTime timestamp,

    /// 읽음 여부 (사용자별 추적)
    @Default({}) Map<String, bool> readBy,

    /// 전달 상태 (sending, sent, failed)
    @Default('sent') String deliveryStatus,

    /// 미디어 URL (이미지/비디오)
    @Default([]) List<String> mediaUrls,

    /// 미디어 썸네일 URL
    String? thumbnailUrl,

    /// 원본 메시지 ID (답장용)
    String? replyToMessageId,

    /// AI 생성 메시지 여부
    @Default(false) bool isAiGenerated,

    // ========== Vote Message 전용 필드 ==========
    /// 투표 카드 상태 (voting_request, voting, completed)
    String? cardStatus,

    /// 게시물 ID (투표용)
    String? postId,

    /// 받는 사람 ID (투표용)
    String? receiverId,

    /// A 옵션 텍스트
    String? voteOptionAText,

    /// A 옵션 이미지 URL 목록
    @Default([]) List<String> voteOptionAImages,

    /// B 옵션 텍스트
    String? voteOptionBText,

    /// B 옵션 이미지 URL 목록
    @Default([]) List<String> voteOptionBImages,

    /// A 옵션 종횡비
    double? optionAAspectRatio,

    /// B 옵션 종횡비
    double? optionBAspectRatio,

    /// 레이아웃 타입 (horizontal, vertical)
    String? layoutType,

    /// 투표 종료 시간
    DateTime? voteEndTime,

    /// 투표 A 득표 수
    @Default(0) int votesA,

    /// 투표 B 득표 수
    @Default(0) int votesB,

    // ========== System Message 전용 필드 ==========
    /// 시스템 메시지 타입 (friend_request, notification 등)
    String? systemMessageType,

    /// 시스템 메시지 데이터 (JSON)
    @Default({}) Map<String, dynamic> systemData,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
    _$MessageFromJson(json);

  // ========== Business Logic Methods ==========

  /// 텍스트 메시지 여부
  bool get isTextMessage => messageType == 'text';

  /// 이미지 메시지 여부
  bool get isImageMessage => messageType == 'image';

  /// 비디오 메시지 여부
  bool get isVideoMessage => messageType == 'video';

  /// 투표 메시지 여부
  bool get isVoteMessage => messageType == 'vote';

  /// 시스템 메시지 여부
  bool get isSystemMessage => messageType == 'system';

  /// AI 생성 메시지 여부
  bool get isAiMessage => isAiGenerated;

  /// 미디어가 있는지 여부
  bool get hasMedia => mediaUrls.isNotEmpty;

  /// 특정 사용자가 읽었는지 확인
  bool isReadBy(String userId) => readBy[userId] ?? false;

  /// 전송 중 여부
  bool get isSending => deliveryStatus == 'sending';

  /// 전송 완료 여부
  bool get isSent => deliveryStatus == 'sent';

  /// 전송 실패 여부
  bool get isFailed => deliveryStatus == 'failed';

  /// 답장 메시지 여부
  bool get isReply => replyToMessageId != null;

  /// 투표 진행중 여부
  bool get isVotingActive =>
    cardStatus == 'voting' && voteEndTime != null && DateTime.now().isBefore(voteEndTime!);

  /// 투표 완료 여부
  bool get isVotingCompleted => cardStatus == 'completed';

  /// 총 투표 수
  int get totalVotes => votesA + votesB;
}
```

**Complex Features**:
- ✅ 5 message types (text, image, video, vote, system)
- ✅ Vote card support (A/B options, images, aspect ratios)
- ✅ Delivery status tracking (sending, sent, failed)
- ✅ Read receipts (Map<String, bool>)
- ✅ AI integration (isAiGenerated)
- ✅ Media support (URLs, thumbnails)
- ✅ Reply functionality (replyToMessageId)
- ✅ Rich business logic (15+ getter methods)

### 3. Extension Pattern (chat_extensions.dart, message_extensions.dart)

**Purpose**: Firestore ↔ Entity 변환을 Extension 메서드로 구현

Chat Feature의 **고유한 특징**: Extension 파일이 `domain/entities/` 에 위치 (Voting은 `data/extensions/`)

#### chat_extensions.dart (159 lines)

```dart
/// Extension for Chat Entity ↔ Firestore conversion
///
/// **Firebase-Centric v2.0 Architecture**:
/// - DTO/Mapper 레이어 제거
/// - Extension Pattern으로 직접 변환
/// - domain/entities/ 위치 (Data Layer 아님)
extension ChatFirestoreExtension on Chat {
  /// Chat Entity → Firestore Map
  ///
  /// **Usage**: data layer에서 Firestore 저장 시 사용
  /// ```dart
  /// final chatData = chat.toFirestore();
  /// await _firestore.collection('chats').doc(chatId).set(chatData);
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'chatId': chatId,
      'chatType': chatType,
      'participantIds': participantIds,
      'chatName': chatName,
      'lastMessageContent': lastMessageContent,
      'lastMessageAt': lastMessageAt != null
        ? Timestamp.fromDate(lastMessageAt!)
        : null,
      'isRead': isRead,
      'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : null,
      'lastReadTimestamps': lastReadTimestamps.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      // User fields (TODO: Profile Feature로 이동)
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'uid': uid,
      'createdTime': createdTime != null
        ? Timestamp.fromDate(createdTime!)
        : null,
      'phoneNumber': phoneNumber,
    };
  }
}

/// Extension for Firestore DocumentSnapshot → Chat Entity
extension ChatDocumentSnapshotExtension on DocumentSnapshot {
  /// Firestore DocumentSnapshot → Chat Entity
  ///
  /// **Usage**: data layer에서 Firestore 조회 시 사용
  /// ```dart
  /// final doc = await _firestore.collection('chats').doc(chatId).get();
  /// final chat = doc.toChat();
  /// ```
  Chat toChat() {
    final data = this.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Chat document not found: $id');
    }

    return Chat(
      id: id,
      chatId: data['chatId'] as String? ?? '',
      chatType: data['chatType'] as String? ?? 'direct',
      participantIds: (data['participantIds'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      chatName: data['chatName'] as String? ?? '',
      lastMessageContent: data['lastMessageContent'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastReadTimestamps: _parseLastReadTimestamps(data),
      // User fields
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      createdTime: (data['createdTime'] as Timestamp?)?.toDate(),
      phoneNumber: data['phoneNumber'] as String? ?? '',
    );
  }

  static Map<String, DateTime> _parseLastReadTimestamps(Map<String, dynamic> data) {
    final timestamps = data['lastReadTimestamps'] as Map<String, dynamic>?;
    if (timestamps == null) return {};

    return timestamps.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate());
      } else if (value is int) {
        return MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value));
      } else {
        return MapEntry(key, DateTime.now());
      }
    });
  }
}
```

**Key Features**:
- ✅ Bidirectional conversion (Entity ↔ Firestore)
- ✅ Timestamp handling (DateTime ↔ Firestore Timestamp)
- ✅ Null safety
- ✅ Type conversion (List, Map)
- ✅ Error handling

#### message_extensions.dart (277 lines)

```dart
/// Extension for Message Entity ↔ Firestore conversion
extension MessageFirestoreExtension on Message {
  /// Message Entity → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'authorId': authorId,
      'chatId': chatId,
      'messageType': messageType,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'deliveryStatus': deliveryStatus,
      'mediaUrls': mediaUrls,
      'thumbnailUrl': thumbnailUrl,
      'replyToMessageId': replyToMessageId,
      'isAiGenerated': isAiGenerated,
      // Vote fields
      'cardStatus': cardStatus,
      'postId': postId,
      'receiverId': receiverId,
      'voteOptionAText': voteOptionAText,
      'voteOptionAImages': voteOptionAImages,
      'voteOptionBText': voteOptionBText,
      'voteOptionBImages': voteOptionBImages,
      'optionAAspectRatio': optionAAspectRatio,
      'optionBAspectRatio': optionBAspectRatio,
      'layoutType': layoutType,
      'voteEndTime': voteEndTime != null
        ? Timestamp.fromDate(voteEndTime!)
        : null,
      'votesA': votesA,
      'votesB': votesB,
      // System message fields
      'systemMessageType': systemMessageType,
      'systemData': systemData,
    };
  }
}

extension MessageDocumentSnapshotExtension on DocumentSnapshot {
  /// Firestore DocumentSnapshot → Message Entity
  Message toMessage() {
    final data = this.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Message document not found: $id');
    }

    return Message(
      id: id,
      authorId: data['authorId'] as String? ?? '',
      chatId: data['chatId'] as String? ?? '',
      messageType: data['messageType'] as String? ?? 'text',
      text: data['text'] as String? ?? '',
      timestamp: _parseTimestamp(data['timestamp']),
      readBy: _parseReadBy(data['readBy']),
      deliveryStatus: data['deliveryStatus'] as String? ?? 'sent',
      mediaUrls: _parseList(data['mediaUrls']),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      replyToMessageId: data['replyToMessageId'] as String?,
      isAiGenerated: data['isAiGenerated'] as bool? ?? false,
      // Vote fields
      cardStatus: data['cardStatus'] as String?,
      postId: data['postId'] as String?,
      receiverId: data['receiverId'] as String?,
      voteOptionAText: data['voteOptionAText'] as String?,
      voteOptionAImages: _parseList(data['voteOptionAImages']),
      voteOptionBText: data['voteOptionBText'] as String?,
      voteOptionBImages: _parseList(data['voteOptionBImages']),
      optionAAspectRatio: _parseDouble(data['optionAAspectRatio']),
      optionBAspectRatio: _parseDouble(data['optionBAspectRatio']),
      layoutType: data['layoutType'] as String?,
      voteEndTime: _parseTimestamp(data['voteEndTime']),
      votesA: data['votesA'] as int? ?? 0,
      votesB: data['votesB'] as int? ?? 0,
      // System message fields
      systemMessageType: data['systemMessageType'] as String?,
      systemData: data['systemData'] as Map<String, dynamic>? ?? {},
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static Map<String, bool> _parseReadBy(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, bool>.from(
        value.map((key, val) => MapEntry(key.toString(), val as bool? ?? false)),
      );
    }
    return {};
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
```

**Complex Parsing**:
- ✅ Timestamp parsing (multiple formats: Timestamp, int, String)
- ✅ Map parsing (readBy)
- ✅ List parsing (mediaUrls, voteOptionImages)
- ✅ Double parsing (aspect ratios)
- ✅ Null safety with fallbacks

---

## failures/ - Domain Errors

ChatFailure는 채팅 시스템의 모든 에러 케이스를 표현하는 Sealed Class입니다.

### 17 Failure Types

#### 4 Message Errors

```dart
/// 메시지 전송 실패
class MessageSendFailed extends ChatFailure {
  const MessageSendFailed() : super();
}

/// 메시지 로드 실패
class MessageLoadFailed extends ChatFailure {
  const MessageLoadFailed() : super();
}

/// 메시지 삭제 실패
class MessageDeleteFailed extends ChatFailure {
  const MessageDeleteFailed() : super();
}

/// 유효하지 않은 메시지 내용
class InvalidMessageContent extends ChatFailure {
  const InvalidMessageContent() : super();
}
```

#### 3 Chat Room Errors

```dart
/// 채팅방을 찾을 수 없음
class ChatNotFound extends ChatFailure {
  const ChatNotFound() : super();
}

/// 채팅방 생성 실패
class ChatCreationFailed extends ChatFailure {
  const ChatCreationFailed() : super();
}

/// 채팅방 목록 로드 실패
class ChatLoadFailed extends ChatFailure {
  const ChatLoadFailed() : super();
}
```

#### 2 Participant Errors

```dart
/// 참여자를 찾을 수 없음
class ParticipantNotFound extends ChatFailure {
  const ParticipantNotFound() : super();
}

/// 참여자 정보 로드 실패
class ParticipantLoadFailed extends ChatFailure {
  const ParticipantLoadFailed() : super();
}
```

#### 3 AI Errors

```dart
/// AI 쿼리 실패
class AIQueryFailed extends ChatFailure {
  const AIQueryFailed() : super();
}

/// AI 스트리밍 오류
class AIStreamingError extends ChatFailure {
  const AIStreamingError() : super();
}

/// AI 서비스 초기화 안 됨
class AINotInitialized extends ChatFailure {
  const AINotInitialized() : super();
}
```

#### 1 Search Error

```dart
/// 검색 실패
class SearchFailed extends ChatFailure {
  const SearchFailed() : super();
}
```

#### 3 Friend System Errors

```dart
/// 친구 요청 실패
class FriendRequestFailed extends ChatFailure {
  const FriendRequestFailed() : super();
}

/// 친구 목록 로드 실패
class FriendLoadFailed extends ChatFailure {
  const FriendLoadFailed() : super();
}

/// 팔로우 토글 실패
class FollowToggleFailed extends ChatFailure {
  const FollowToggleFailed() : super();
}
```

#### 3 Network & Permission Errors

```dart
/// 네트워크 오류
class NetworkError extends ChatFailure {
  const NetworkError() : super();
}

/// 권한 없음
class PermissionDenied extends ChatFailure {
  const PermissionDenied() : super();
}

/// 서버 오류
class ServerError extends ChatFailure {
  const ServerError() : super();
}
```

#### 1 Generic Error

```dart
/// 예기치 않은 오류
class Unexpected extends ChatFailure {
  final String? errorMessage;
  const Unexpected([this.errorMessage]) : super();
}
```

### Pattern Matching with Switch Expression

```dart
// Modern Dart 3 switch expression
final message = switch (failure) {
  // Message errors
  MessageSendFailed() => '메시지 전송에 실패했습니다',
  MessageLoadFailed() => '메시지를 불러오는데 실패했습니다',
  MessageDeleteFailed() => '메시지 삭제에 실패했습니다',
  InvalidMessageContent() => '유효하지 않은 메시지 내용입니다',

  // Chat room errors
  ChatNotFound() => '채팅방을 찾을 수 없습니다',
  ChatCreationFailed() => '채팅방 생성에 실패했습니다',
  ChatLoadFailed() => '채팅방 목록을 불러오는데 실패했습니다',

  // Participant errors
  ParticipantNotFound() => '참여자를 찾을 수 없습니다',
  ParticipantLoadFailed() => '참여자 정보를 불러오는데 실패했습니다',

  // AI errors
  AIQueryFailed() => 'AI 질문에 실패했습니다',
  AIStreamingError() => 'AI 응답 생성 중 오류가 발생했습니다',
  AINotInitialized() => 'AI 서비스가 초기화되지 않았습니다',

  // Search error
  SearchFailed() => '검색에 실패했습니다',

  // Friend system errors
  FriendRequestFailed() => '친구 요청에 실패했습니다',
  FriendLoadFailed() => '친구 목록을 불러오는데 실패했습니다',
  FollowToggleFailed() => '팔로우 처리에 실패했습니다',

  // Network & Permission errors
  NetworkError() => '네트워크 연결 오류가 발생했습니다',
  PermissionDenied() => '권한이 없습니다',
  ServerError() => '서버 오류가 발생했습니다',

  // Generic error
  Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
};

showSnackBar(message);
```

### Failure Hierarchy

```
ChatFailure (Sealed)
├── Message Errors (4)
│   ├── MessageSendFailed
│   ├── MessageLoadFailed
│   ├── MessageDeleteFailed
│   └── InvalidMessageContent
│
├── Chat Room Errors (3)
│   ├── ChatNotFound
│   ├── ChatCreationFailed
│   └── ChatLoadFailed
│
├── Participant Errors (2)
│   ├── ParticipantNotFound
│   └── ParticipantLoadFailed
│
├── AI Errors (3)
│   ├── AIQueryFailed
│   ├── AIStreamingError
│   └── AINotInitialized
│
├── Search Error (1)
│   └── SearchFailed
│
├── Friend System Errors (3)
│   ├── FriendRequestFailed
│   ├── FriendLoadFailed
│   └── FollowToggleFailed
│
├── Network & Permission Errors (3)
│   ├── NetworkError
│   ├── PermissionDenied
│   └── ServerError
│
└── Generic Error (1)
    └── Unexpected (with optional message)
```

---

## repositories/ - Repository Interface

Repository는 데이터 접근 추상화를 제공하는 인터페이스입니다. Domain Layer는 "무엇을" 정의하고, Data Layer는 "어떻게"를 구현합니다.

### IChatRepository Deep Dive (390 lines, 20+ methods)

**4 Method Categories**:

#### 1. Query Operations (4 methods)

```dart
abstract class IChatRepository {
  /// 채팅 목록 실시간 스트림
  ///
  /// **Parameters**:
  /// - [userId]: 현재 사용자 ID (participantIds 필터링)
  /// - [limit]: 한 번에 로드할 채팅 개수 (기본값: 50)
  /// - [orderBy]: 정렬 기준 필드 (기본값: 'lastMessageAt')
  /// - [descending]: 내림차순 정렬 여부 (기본값: true)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Chat>>>`:
  ///   - Left: ChatLoadFailed (네트워크/캐시 에러)
  ///   - Right: List<Chat> (성공)
  ///
  /// **Phase 3 Integration**: 3-Layer Cache-First 패턴
  /// - L1 Memory → L2 Hive → L3 Firestore
  /// - 캐시 히트 시 즉시 emit (<10ms)
  /// - Firestore 스트림으로 실시간 업데이트
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  /// 채팅 개수 조회
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  });

  /// 메시지 실시간 스트림
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [limit]: 한 번에 로드할 메시지 개수 (기본값: 30)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Message>>>`:
  ///   - Left: MessageLoadFailed
  ///   - Right: List<Message>
  ///
  /// **Phase 3 Integration**: 3-Layer Cache-First 패턴
  Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  /// 페이지네이션: 특정 메시지 이전 메시지 로드
  ///
  /// **Use Case**: 무한 스크롤
  Future<List<Message>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  });

  /// 메시지 개수 조회
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  });
}
```

**Performance Optimization**:
- 3-Layer caching: <10ms (Memory) → 10-30ms (Hive) → 50-100ms (Firestore)
- Cache-First: Immediate response from cache, background sync
- Stream-based: Real-time updates

#### 2. CRUD Operations (8 methods)

```dart
abstract class IChatRepository {
  /// 채팅 조회
  ///
  /// **Returns**: Either<ChatFailure, Chat>
  /// - Left: ChatNotFound
  /// - Right: Chat entity
  Future<Either<ChatFailure, Chat>> getChat(String chatId);

  /// 채팅 생성 (중복 방지)
  ///
  /// **Parameters**:
  /// - [chat]: 생성할 채팅 엔티티
  /// - [eventId]: UUID v4 (중복 방지용)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  /// - IdempotencyService로 중복 생성 방지
  /// - Transaction으로 원자성 보장
  Future<Either<ChatFailure, Unit>> createChat({
    required Chat chat,
    required String eventId,
  });

  /// 채팅 업데이트 (중복 방지)
  Future<Either<ChatFailure, Unit>> updateChat({
    required Chat chat,
    required String eventId,
  });

  /// 채팅 삭제 (서브컬렉션 포함, 중복 방지)
  ///
  /// **Phase 4 - Complete Cleanup**:
  /// - messages 서브컬렉션 삭제
  /// - participants 서브컬렉션 삭제
  /// - chat 문서 삭제
  /// - Transaction으로 원자성 보장
  Future<Either<ChatFailure, Unit>> deleteChat({
    required String chatId,
    required String eventId,
  });

  /// 메시지 전송 (중복 방지)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [message]: 전송할 메시지 엔티티
  /// - [eventId]: UUID v4 (중복 전송 방지용)
  ///
  /// **Phase 4 - IdempotencyService Integration**:
  /// - 동일 eventId 재시도: 작업 스킵 (네트워크 재시도)
  /// - 다른 eventId 중복: IdempotencyViolation 발생
  /// - Transaction으로 메시지 + lastMessageAt 원자적 업데이트
  Future<Either<ChatFailure, Unit>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId,
  });

  /// 메시지 삭제 (중복 방지)
  Future<Either<ChatFailure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
    required String eventId,
  });

  /// 메시지 업데이트 (읽음 처리)
  Future<Either<ChatFailure, Unit>> updateMessage({
    required Message message,
    required String eventId,
  });

  /// 마지막 읽은 시간 업데이트
  Future<Either<ChatFailure, Unit>> updateLastRead({
    required String chatId,
    required String userId,
    required DateTime timestamp,
  });
}
```

**Atomic Guarantees**:
- Firestore Transaction 사용
- Subcollection cleanup (deleteChat)
- Idempotency 보장 (eventId)

#### 3. Media Operations (1 method)

```dart
abstract class IChatRepository {
  /// 채팅 미디어(이미지/비디오) 업로드
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [messageId]: 메시지 ID
  /// - [file]: 업로드할 파일
  /// - [mediaType]: 'image' or 'video'
  ///
  /// **Returns**: Firebase Storage 다운로드 URL
  ///
  /// **Implementation**:
  /// - Data Layer에서 ChatMediaUploadService 사용
  /// - 이미지: 자동 압축 (2MB 이하)
  /// - 비디오: 썸네일 자동 생성
  Future<Either<ChatFailure, String>> uploadChatMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType,
  });
}
```

#### 4. AI & Friend Operations (7 methods)

```dart
abstract class IChatRepository {
  /// AI 쿼리 전송 (Gemini AI 통합)
  ///
  /// **Returns**: Stream<Either<ChatFailure, String>>
  /// - AI 응답을 스트리밍으로 받아 실시간 표시
  Stream<Either<ChatFailure, String>> sendAIQuery({
    required String userId,
    required String query,
    List<Message>? conversationHistory,
  });

  /// 사용자 게시물 히스토리 조회 (AI 컨텍스트용)
  ///
  /// **Use Case**: AI가 사용자 게시 이력 분석
  Future<Either<ChatFailure, String>> getUserPostingHistory({
    required String userId,
    int limit = 10,
  });

  /// 친구 요청 전송
  Future<Either<ChatFailure, Unit>> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  });

  /// 친구 검색
  Future<Either<ChatFailure, List<Map<String, dynamic>>>> searchFriends({
    required String query,
    int limit = 20,
  });

  /// 추천 친구 조회
  Future<Either<ChatFailure, List<Map<String, dynamic>>>> getRecommendedFriends({
    required String userId,
    int limit = 10,
  });

  /// 팔로우/언팔로우 토글
  Future<Either<ChatFailure, bool>> toggleFollow({
    required String currentUserId,
    required String targetUserId,
  });

  /// 메시지 검색
  Future<Either<ChatFailure, List<Message>>> searchMessages({
    required String chatId,
    required String query,
    int limit = 50,
  });
}
```

---

## ports/ - Port-Adapter Pattern

Port-Adapter Pattern은 외부 서비스를 추상화하는 디자인 패턴입니다. Domain Layer는 Port (인터페이스)만 정의하고, Data Layer에서 Adapter (구현체)를 제공합니다.

### IAIService (Port Interface)

```dart
/// AI Service Port Interface
///
/// **Port-Adapter Pattern**:
/// - Port (Interface): Domain Layer에 정의
/// - Adapter (Implementation): Data Layer에 구현
///
/// **Hexagonal Architecture**:
/// - Domain Layer는 IAIService에 의존
/// - Data Layer는 GeminiAIService (Adapter)를 제공
/// - 외부 AI 서비스 교체 가능 (Gemini → GPT → Claude)
abstract class IAIService {
  /// AI 쿼리 전송
  ///
  /// **Parameters**:
  /// - [userId]: 사용자 ID
  /// - [query]: AI에게 전달할 질문
  /// - [conversationHistory]: 대화 컨텍스트 (선택적)
  ///
  /// **Returns**: Stream<Either<ChatFailure, String>>
  /// - AI 응답을 스트리밍으로 반환
  /// - Real-time 표시 가능
  Stream<Either<ChatFailure, String>> sendAIQuery({
    required String userId,
    required String query,
    List<Message>? conversationHistory,
  });

  /// 사용자 게시물 히스토리 분석
  ///
  /// **Use Case**: AI가 사용자의 과거 게시물 분석
  Future<Either<ChatFailure, String>> getUserPostingHistory({
    required String userId,
    int limit = 10,
  });
}
```

### Adapter Implementation (Data Layer)

```dart
// data/adapters/gemini_ai_service.dart

/// Gemini AI Service Adapter
///
/// **Adapter Pattern**: IAIService Port 구현
class GeminiAIService implements IAIService {
  final FirebaseFunctions _functions;

  GeminiAIService({required FirebaseFunctions functions})
    : _functions = functions;

  @override
  Stream<Either<ChatFailure, String>> sendAIQuery({
    required String userId,
    required String query,
    List<Message>? conversationHistory,
  }) async* {
    try {
      // Firebase Functions 호출 (Genkit 통합)
      final callable = _functions.httpsCallable('aiQueryWithGenkit');

      final response = await callable.call({
        'userId': userId,
        'query': query,
        'conversationHistory': conversationHistory
          ?.map((msg) => msg.toJson())
          .toList(),
      });

      // AI 응답 스트리밍
      yield* _streamAIResponse(response.data);
    } catch (e) {
      yield left(AIQueryFailed());
    }
  }

  @override
  Future<Either<ChatFailure, String>> getUserPostingHistory({
    required String userId,
    int limit = 10,
  }) async {
    // Firebase Functions 호출
    final callable = _functions.httpsCallable('getUserPostingHistory');

    final response = await callable.call({
      'userId': userId,
      'limit': limit,
    });

    return right(response.data as String);
  }
}
```

**Port-Adapter Benefits**:
- ✅ **Testability**: Mock IAIService for unit tests
- ✅ **Flexibility**: Easy to switch AI providers (Gemini → GPT)
- ✅ **Dependency Inversion**: Domain doesn't depend on Gemini
- ✅ **Clean Separation**: Business logic ↔ External service

---

## usecases/ - Business Logic Encapsulation

UseCase는 단일 비즈니스 작업을 캡슐화합니다. Clean Architecture의 "Use Case Layer"를 구현하며, 이전의 거대한 Service 클래스를 대체합니다.

### UseCase Pattern Benefits

1. **Single Responsibility**: 하나의 UseCase는 하나의 작업만 수행
2. **Testability**: Repository를 모킹하여 단위 테스트 용이
3. **Reusability**: 여러 UI에서 동일한 UseCase 재사용
4. **Maintainability**: 비즈니스 로직 변경 시 한 곳만 수정
5. **Dependency Inversion**: UseCase는 Repository 인터페이스에 의존

### 10 UseCases Overview

#### 1. Chat Operations (2 usecases)

**GetChatListUseCase** (36 lines)

```dart
/// 채팅 목록 조회 UseCase
///
/// **Responsibility**: 사용자의 채팅 목록 조회
///
/// **Business Rules**:
/// 1. userId로 참여 중인 채팅방 조회
/// 2. 최근 메시지 순 정렬
/// 3. 캐시 우선 조회 (3-Layer Cache)
class GetChatListUseCase {
  final IChatRepository _repository;

  GetChatListUseCase(this._repository);

  /// 채팅 목록 스트림
  ///
  /// **Returns**: Stream<Either<ChatFailure, List<Chat>>>
  Stream<Either<ChatFailure, List<Chat>>> call({
    required String userId,
    int limit = 50,
  }) {
    return _repository.queryChats(
      userId: userId,
      limit: limit,
      orderBy: 'lastMessageAt',
      descending: true,
    );
  }
}
```

**Usage in Presentation Layer**:

```dart
class ChatListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getChatList = ref.read(getChatListUseCaseProvider);

    return StreamBuilder<Either<ChatFailure, List<Chat>>>(
      stream: getChatList(userId: currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();

        return snapshot.data!.fold(
          (failure) => ErrorWidget(failure.message),
          (chats) => ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) => ChatTile(chats[index]),
          ),
        );
      },
    );
  }
}
```

**GetChatMessagesUseCase** (36 lines)

```dart
/// 채팅 메시지 조회 UseCase
///
/// **Responsibility**: 특정 채팅방의 메시지 목록 조회
class GetChatMessagesUseCase {
  final IChatRepository _repository;

  GetChatMessagesUseCase(this._repository);

  /// 메시지 스트림
  ///
  /// **Returns**: Stream<Either<ChatFailure, List<Message>>>
  Stream<Either<ChatFailure, List<Message>>> call({
    required String chatId,
    int limit = 30,
  }) {
    return _repository.queryMessagesByChatId(
      chatId: chatId,
      limit: limit,
      orderBy: 'timestamp',
      descending: true,
    );
  }
}
```

#### 2. Message Operations (3 usecases)

**SendMessageUseCase** (50 lines)

```dart
/// 메시지 전송 UseCase
///
/// **Responsibility**: 채팅 메시지 전송
///
/// **Business Rules**:
/// 1. 메시지 내용 유효성 검증
/// 2. UUID 생성 (eventId)
/// 3. 메시지 전송
/// 4. 에러 처리
class SendMessageUseCase {
  final IChatRepository _repository;

  SendMessageUseCase(this._repository);

  /// 메시지 전송
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [message]: 전송할 메시지 엔티티
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  Future<Either<ChatFailure, Unit>> call({
    required String chatId,
    required Message message,
  }) async {
    // 1. Validation
    if (message.text.isEmpty && message.mediaUrls.isEmpty) {
      return left(InvalidMessageContent());
    }

    // 2. Generate eventId (UUID v4)
    final eventId = Uuid().v4();

    // 3. Send message
    return _repository.sendMessage(
      chatId: chatId,
      message: message,
      eventId: eventId,
    );
  }
}
```

**LoadMoreMessagesUseCase** (39 lines)

```dart
/// 메시지 페이지네이션 UseCase
///
/// **Responsibility**: 무한 스크롤을 위한 이전 메시지 로드
class LoadMoreMessagesUseCase {
  final IChatRepository _repository;

  LoadMoreMessagesUseCase(this._repository);

  /// 이전 메시지 로드
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [lastMessageId]: 마지막으로 로드한 메시지 ID
  /// - [limit]: 로드할 메시지 개수 (기본값: 30)
  ///
  /// **Returns**: Future<List<Message>>
  Future<List<Message>> call({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  }) async {
    return _repository.queryMessagesBeforeMessageId(
      chatId: chatId,
      lastMessageId: lastMessageId,
      limit: limit,
    );
  }
}
```

**SearchMessagesUseCase** (37 lines)

```dart
/// 메시지 검색 UseCase
///
/// **Responsibility**: 채팅방 내 메시지 검색
class SearchMessagesUseCase {
  final IChatRepository _repository;

  SearchMessagesUseCase(this._repository);

  /// 메시지 검색
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [query]: 검색 키워드
  /// - [limit]: 검색 결과 개수 (기본값: 50)
  ///
  /// **Returns**: Either<ChatFailure, List<Message>>
  Future<Either<ChatFailure, List<Message>>> call({
    required String chatId,
    required String query,
    int limit = 50,
  }) async {
    // Validation
    if (query.trim().isEmpty) {
      return right([]);
    }

    return _repository.searchMessages(
      chatId: chatId,
      query: query,
      limit: limit,
    );
  }
}
```

#### 3. AI Operations (1 usecase)

**SendAIQueryUseCase** (53 lines)

```dart
/// AI 쿼리 전송 UseCase
///
/// **Responsibility**: Gemini AI와 대화
///
/// **Business Rules**:
/// 1. AI 서비스 초기화 확인
/// 2. 쿼리 유효성 검증
/// 3. AI 응답 스트리밍
class SendAIQueryUseCase {
  final IChatRepository _repository;

  SendAIQueryUseCase(this._repository);

  /// AI 쿼리 전송
  ///
  /// **Parameters**:
  /// - [userId]: 사용자 ID
  /// - [query]: AI에게 전달할 질문
  /// - [conversationHistory]: 대화 컨텍스트 (선택적)
  ///
  /// **Returns**: Stream<Either<ChatFailure, String>>
  Stream<Either<ChatFailure, String>> call({
    required String userId,
    required String query,
    List<Message>? conversationHistory,
  }) async* {
    // 1. Validation
    if (query.trim().isEmpty) {
      yield left(InvalidMessageContent());
      return;
    }

    // 2. Send AI query (streaming)
    yield* _repository.sendAIQuery(
      userId: userId,
      query: query,
      conversationHistory: conversationHistory,
    );
  }
}
```

**Usage with StreamBuilder**:

```dart
class AIChatWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendAIQuery = ref.read(sendAIQueryUseCaseProvider);

    return StreamBuilder<Either<ChatFailure, String>>(
      stream: sendAIQuery(
        userId: currentUserId,
        query: userQuery,
        conversationHistory: chatHistory,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();

        return snapshot.data!.fold(
          (failure) => ErrorWidget(failure.message),
          (aiResponse) => Text(aiResponse), // Real-time AI response
        );
      },
    );
  }
}
```

#### 4. Friend Operations (4 usecases)

**SendFriendRequestUseCase** (37 lines)

```dart
/// 친구 요청 UseCase
///
/// **Responsibility**: 친구 요청 전송
class SendFriendRequestUseCase {
  final IChatRepository _repository;

  SendFriendRequestUseCase(this._repository);

  /// 친구 요청 전송
  ///
  /// **Parameters**:
  /// - [fromUserId]: 요청하는 사용자 ID
  /// - [toUserId]: 대상 사용자 ID
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  Future<Either<ChatFailure, Unit>> call({
    required String fromUserId,
    required String toUserId,
  }) async {
    // Validation: 자기 자신에게 요청 불가
    if (fromUserId == toUserId) {
      return left(InvalidMessageContent());
    }

    return _repository.sendFriendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );
  }
}
```

**ToggleFollowUseCase** (38 lines)

```dart
/// 팔로우/언팔로우 UseCase
///
/// **Responsibility**: 사용자 팔로우 상태 토글
class ToggleFollowUseCase {
  final IChatRepository _repository;

  ToggleFollowUseCase(this._repository);

  /// 팔로우/언팔로우
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID
  /// - [targetUserId]: 대상 사용자 ID
  ///
  /// **Returns**: Either<ChatFailure, bool>
  /// - Right(true): 팔로우 완료
  /// - Right(false): 언팔로우 완료
  Future<Either<ChatFailure, bool>> call({
    required String currentUserId,
    required String targetUserId,
  }) async {
    return _repository.toggleFollow(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );
  }
}
```

**SearchFriendsUseCase** (39 lines)

```dart
/// 친구 검색 UseCase
///
/// **Responsibility**: 친구 검색
class SearchFriendsUseCase {
  final IChatRepository _repository;

  SearchFriendsUseCase(this._repository);

  /// 친구 검색
  ///
  /// **Parameters**:
  /// - [query]: 검색 키워드
  /// - [limit]: 검색 결과 개수 (기본값: 20)
  ///
  /// **Returns**: Either<ChatFailure, List<Map<String, dynamic>>>
  Future<Either<ChatFailure, List<Map<String, dynamic>>>> call({
    required String query,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      return right([]);
    }

    return _repository.searchFriends(
      query: query,
      limit: limit,
    );
  }
}
```

**GetRecommendedFriendsUseCase** (37 lines)

```dart
/// 추천 친구 조회 UseCase
///
/// **Responsibility**: AI 기반 친구 추천
class GetRecommendedFriendsUseCase {
  final IChatRepository _repository;

  GetRecommendedFriendsUseCase(this._repository);

  /// 추천 친구 조회
  ///
  /// **Parameters**:
  /// - [userId]: 사용자 ID
  /// - [limit]: 추천 친구 개수 (기본값: 10)
  ///
  /// **Returns**: Either<ChatFailure, List<Map<String, dynamic>>>
  Future<Either<ChatFailure, List<Map<String, dynamic>>>> call({
    required String userId,
    int limit = 10,
  }) async {
    return _repository.getRecommendedFriends(
      userId: userId,
      limit: limit,
    );
  }
}
```

---

## constants/ - Domain Constants

`chat_constants.dart`는 채팅 Feature의 모든 상수를 중앙 집중식으로 관리합니다.

### 3 Categories of Constants

#### 1. Message Types (5 constants)

```dart
class ChatConstants {
  /// 텍스트 메시지 타입
  static const String messageTypeText = 'text';

  /// 이미지 메시지 타입
  static const String messageTypeImage = 'image';

  /// 비디오 메시지 타입
  static const String messageTypeVideo = 'video';

  /// 투표 메시지 타입
  static const String messageTypeVote = 'vote';

  /// 시스템 메시지 타입
  static const String messageTypeSystem = 'system';
}
```

#### 2. Delivery Status (3 constants)

```dart
class ChatConstants {
  /// 전송 중
  static const String deliveryStatusSending = 'sending';

  /// 전송 완료
  static const String deliveryStatusSent = 'sent';

  /// 전송 실패
  static const String deliveryStatusFailed = 'failed';
}
```

#### 3. Vote Card Status (3 constants)

```dart
class ChatConstants {
  /// 투표 요청 상태
  static const String voteCardStatusRequest = 'voting_request';

  /// 투표 진행중 상태
  static const String voteCardStatusVoting = 'voting';

  /// 투표 완료 상태
  static const String voteCardStatusCompleted = 'completed';
}
```

### Usage Example

```dart
import 'package:versus_cursor/features/chat/domain/constants/chat_constants.dart';

// Message type check
if (message.messageType == ChatConstants.messageTypeVote) {
  // Handle vote message
}

// Delivery status
if (message.deliveryStatus == ChatConstants.deliveryStatusSending) {
  showLoadingIndicator();
}

// Vote card status
if (message.cardStatus == ChatConstants.voteCardStatusCompleted) {
  showVoteResults();
}
```

---

## enums/ - Domain Enums

### MessageDeliveryStatus Enum

```dart
/// 메시지 전달 상태
///
/// **Use Case**: 메시지 전송 상태 추적
enum MessageDeliveryStatus {
  /// 전송 중
  sending,

  /// 전송 완료
  sent,

  /// 전송 실패
  failed,
}

extension MessageDeliveryStatusExtension on MessageDeliveryStatus {
  /// Enum → String
  String toValue() {
    return switch (this) {
      MessageDeliveryStatus.sending => 'sending',
      MessageDeliveryStatus.sent => 'sent',
      MessageDeliveryStatus.failed => 'failed',
    };
  }

  /// String → Enum
  static MessageDeliveryStatus fromValue(String value) {
    return switch (value) {
      'sending' => MessageDeliveryStatus.sending,
      'sent' => MessageDeliveryStatus.sent,
      'failed' => MessageDeliveryStatus.failed,
      _ => MessageDeliveryStatus.sent,
    };
  }
}
```

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
- Ports (어떤 외부 서비스가 필요한가?)

### 2. Entities Are Pure Dart

**Rule**: 엔티티는 프레임워크 독립적이어야 합니다.

```dart
// ❌ BAD: Flutter 의존성
import 'package:flutter/material.dart';

class Chat {
  final Color color; // Flutter Widget!
}

// ✅ GOOD: Pure Dart
class Chat {
  final String id;
  final String chatName;
  final List<String> participantIds;
}
```

### 3. Repository Pattern

**Rule**: Repository는 인터페이스로 정의하고, Data Layer가 구현합니다.

```dart
// Domain Layer (interface)
abstract class IChatRepository {
  Future<Either<ChatFailure, Unit>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId,
  });
}

// Data Layer (implementation)
class ChatRepositoryImpl implements IChatRepository {
  final FirebaseFirestore _firestore;
  final IdempotencyService _idempotencyService;

  @override
  Future<Either<ChatFailure, Unit>> sendMessage(...) async {
    // Firestore 구현
  }
}
```

### 4. UseCase Single Responsibility

**Rule**: 하나의 UseCase는 하나의 비즈니스 작업만 수행합니다.

```dart
// ❌ BAD: God UseCase
class ChatUseCase {
  Future<void> sendMessage() {}
  Future<void> deleteMessage() {}
  Future<void> searchMessages() {}
  Future<void> sendAIQuery() {}
  // ... 50+ methods
}

// ✅ GOOD: Single Responsibility
class SendMessageUseCase {
  Future<Either<ChatFailure, Unit>> call(...) {}
}

class DeleteMessageUseCase {
  Future<Either<ChatFailure, Unit>> call(...) {}
}

class SearchMessagesUseCase {
  Future<Either<ChatFailure, List<Message>>> call(...) {}
}

class SendAIQueryUseCase {
  Stream<Either<ChatFailure, String>> call(...) {}
}
```

### 5. Either Pattern for Error Handling

**Rule**: 모든 실패 가능한 작업은 `Either<Failure, Success>` 타입을 반환합니다.

```dart
// ❌ BAD: Exception throwing
Future<Message> sendMessage() async {
  if (error) throw Exception('Error!');
  return message;
}

// ✅ GOOD: Either pattern
Future<Either<ChatFailure, Unit>> sendMessage() async {
  if (error) return left(MessageSendFailed());
  return right(unit);
}

// Usage with fold
final result = await sendMessage();
result.fold(
  (failure) => handleError(failure),
  (_) => handleSuccess(),
);
```

### 6. Immutability with Freezed

**Rule**: 모든 엔티티는 불변 객체여야 합니다.

```dart
// ❌ BAD: Mutable entity
class Chat {
  String chatName;
  List<String> participantIds;

  void updateName(String newName) {
    chatName = newName; // Mutation!
  }
}

// ✅ GOOD: Immutable entity
@freezed
sealed class Chat with _$Chat {
  const factory Chat({
    required String chatName,
    required List<String> participantIds,
  }) = _Chat;

  // Use copyWith for updates
  // chat.copyWith(chatName: 'New Name')
}
```

### 7. Extension Pattern for Conversion

**Rule**: Firestore ↔ Entity 변환은 Extension 메서드로 구현합니다.

```dart
// Chat Feature의 고유한 접근: domain/entities/ 위치

// chat_extensions.dart (domain/entities/)
extension ChatFirestoreExtension on Chat {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'chatName': chatName,
      'lastMessageAt': lastMessageAt != null
        ? Timestamp.fromDate(lastMessageAt!)
        : null,
    };
  }
}

extension ChatDocumentSnapshotExtension on DocumentSnapshot {
  Chat toChat() {
    final data = this.data() as Map<String, dynamic>?;
    return Chat(
      id: id,
      chatName: data?['chatName'] ?? '',
      lastMessageAt: (data?['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}
```

**Why Extension Pattern?**:
- ✅ No DTO/Mapper layer
- ✅ Direct conversion
- ✅ Less code (Voting: -817 lines, Chat: similar)
- ✅ Type safety
- ✅ Single source of truth

### 8. Port-Adapter Pattern

**Rule**: 외부 서비스는 Port 인터페이스로 추상화하고, Data Layer에서 Adapter를 구현합니다.

```dart
// Domain Layer (Port)
abstract class IAIService {
  Stream<Either<ChatFailure, String>> sendAIQuery({
    required String userId,
    required String query,
  });
}

// Data Layer (Adapter)
class GeminiAIService implements IAIService {
  final FirebaseFunctions _functions;

  @override
  Stream<Either<ChatFailure, String>> sendAIQuery(...) async* {
    // Gemini AI 구현
  }
}
```

**Benefits**:
- ✅ Easy to swap AI providers (Gemini → GPT)
- ✅ Testability (Mock IAIService)
- ✅ Dependency Inversion
- ✅ Clean separation

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

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
sealed class Chat with _$Chat {
  const Chat._(); // Private constructor for custom methods

  const factory Chat({
    required String id,
    required String chatName,
    required List<String> participantIds,
    DateTime? lastMessageAt,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  // Custom business logic
  bool hasParticipant(String userId) => participantIds.contains(userId);
  int get participantCount => participantIds.length;
}
```

**Generated Files**:
- `chat.freezed.dart`: copyWith, ==, hashCode, toString
- `chat.g.dart`: fromJson, toJson

### Custom JSON Converters

```dart
@freezed
sealed class Message with _$Message {
  const factory Message({
    required String id,

    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime timestamp,

    @Default({}) Map<String, bool> readBy,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
    _$MessageFromJson(json);
}

// Custom converters
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}
```

---

## Dependency Diagram

```
┌──────────────────────────────────────────────┐
│         Presentation Layer (UI)              │
│  - ChatListWidget                            │
│  - ChatDetailWidget                          │
│  - VoteCardMessage                           │
└───────────────────┬──────────────────────────┘
                    │ depends on
                    ↓
┌──────────────────────────────────────────────┐
│           Domain Layer (YOU ARE HERE)        │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ entities/                            │   │
│  │  - Chat, Message (Freezed)           │   │
│  │  - chat_extensions.dart (159 lines)  │   │
│  │  - message_extensions.dart (277 lines)│  │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ repositories/ (Interface)            │   │
│  │  - IChatRepository (20+ methods)     │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ ports/ (Port-Adapter Pattern)        │   │
│  │  - IAIService (Port)                 │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ usecases/                            │   │
│  │  - SendMessageUseCase                │   │
│  │  - GetChatListUseCase                │   │
│  │  - SendAIQueryUseCase                │   │
│  │  - SearchMessagesUseCase             │   │
│  │  - Friend UseCases (4개)             │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ failures/                            │   │
│  │  - ChatFailure (17 types)            │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ constants/                           │   │
│  │  - ChatConstants (11 constants)      │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ enums/                               │   │
│  │  - MessageDeliveryStatus             │   │
│  └──────────────────────────────────────┘   │
└───────────────────┬──────────────────────────┘
                    │ implemented by
                    ↓
┌──────────────────────────────────────────────┐
│             Data Layer (Implementation)      │
│  - ChatRepositoryImpl (709 lines)            │
│  - GeminiAIService (Adapter, 128 lines)      │
│  - FlutterChatUserAdapter (246 lines)        │
│  - ChatMediaUploadService (187 lines)        │
│  - ChatMessageLifecycleService (233 lines)   │
│  - Firebase, Firestore, UnifiedCacheService  │
└──────────────────────────────────────────────┘
```

**Dependency Flow**:
1. Presentation → Domain (UseCases, Entities)
2. Domain → Data (Repository implementations, Adapters)
3. Data → External (Firebase, Hive, Gemini AI)

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
sealed class Chat with _$Chat {
  const Chat._();

  const factory Chat({
    required String id,
    required List<String> participantIds,
  }) = _Chat;

  bool hasParticipant(String userId) => participantIds.contains(userId);
}

// ❌ BAD
class Chat {
  String id;
  List<String> participantIds;
  Color backgroundColor; // Flutter dependency!

  Chat(this.id, this.participantIds, this.backgroundColor);

  void addParticipant(String userId) {
    participantIds.add(userId); // Mutable!
  }
}
```

### 2. Repository Interface Design

**DO**:
- ✅ 메서드명은 동사로 시작 (sendMessage, getChat, queryMessages)
- ✅ 모든 실패 가능한 메서드는 `Either<Failure, T>` 반환
- ✅ 실시간 데이터는 `Stream<Either<Failure, T>>` 반환
- ✅ Async 작업은 `Future` 반환
- ✅ eventId 파라미터 추가 (Idempotency)

**DON'T**:
- ❌ void 반환 (에러 처리 불가)
- ❌ Exception throw (Either 패턴 사용)
- ❌ 구현 세부사항 노출 (Firestore, Firebase 타입)
- ❌ 너무 많은 메서드 (20+ = 분리 고려)

**Example**:

```dart
// ✅ GOOD
abstract class IChatRepository {
  Future<Either<ChatFailure, Unit>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId, // Idempotency
  });

  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
  });
}

// ❌ BAD
abstract class IChatRepository {
  Future<void> sendMessage(String chatId, Message message); // void!
  List<Chat> getChats(String userId); // Sync!

  // Firestore 노출
  Future<DocumentSnapshot> getChatDocument(String chatId);
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
class SendMessageUseCase {
  final IChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<ChatFailure, Unit>> call({
    required String chatId,
    required Message message,
  }) async {
    // Validation
    if (message.text.isEmpty && message.mediaUrls.isEmpty) {
      return left(InvalidMessageContent());
    }

    // Business logic
    final eventId = Uuid().v4();
    return _repository.sendMessage(
      chatId: chatId,
      message: message,
      eventId: eventId,
    );
  }
}

// ❌ BAD
class ChatUseCase {
  Future<void> sendMessage(...) {}
  Future<void> deleteMessage(...) {}
  Future<void> searchMessages(...) {}
  // ... 50+ methods (God Object!)
}
```

### 4. Extension Pattern

**DO**:
- ✅ Extension 파일 위치: `domain/entities/` (Chat Feature 고유)
- ✅ Bidirectional conversion (Entity ↔ Firestore)
- ✅ Null safety with fallbacks
- ✅ Timestamp handling (DateTime ↔ Firestore Timestamp)

**DON'T**:
- ❌ Extension에 비즈니스 로직 포함
- ❌ Extension에 복잡한 변환 로직
- ❌ Extension에 외부 서비스 호출

**Example**:

```dart
// ✅ GOOD
extension ChatFirestoreExtension on Chat {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'chatName': chatName,
      'lastMessageAt': lastMessageAt != null
        ? Timestamp.fromDate(lastMessageAt!)
        : null,
    };
  }
}

extension ChatDocumentSnapshotExtension on DocumentSnapshot {
  Chat toChat() {
    final data = this.data() as Map<String, dynamic>?;
    return Chat(
      id: id,
      chatName: data?['chatName'] ?? '',
      lastMessageAt: (data?['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ❌ BAD
extension ChatFirestoreExtension on Chat {
  Future<void> saveToFirestore() async {
    // ❌ Extension에 외부 서비스 호출
    await FirebaseFirestore.instance.collection('chats').doc(id).set(...);
  }

  bool hasUnreadMessages() {
    // ❌ Extension에 비즈니스 로직
    return lastMessageAt != null && ...;
  }
}
```

### 5. Port-Adapter Pattern

**DO**:
- ✅ Port (Interface) in Domain Layer
- ✅ Adapter (Implementation) in Data Layer
- ✅ Easy to swap implementations
- ✅ Testability (Mock Port)

**DON'T**:
- ❌ Port에 구현 세부사항 노출
- ❌ Adapter를 Domain Layer에 두기
- ❌ Port 없이 직접 외부 서비스 호출

**Example**:

```dart
// ✅ GOOD

// Domain Layer (Port)
abstract class IAIService {
  Stream<Either<ChatFailure, String>> sendAIQuery({
    required String userId,
    required String query,
  });
}

// Data Layer (Adapter)
class GeminiAIService implements IAIService {
  final FirebaseFunctions _functions;

  @override
  Stream<Either<ChatFailure, String>> sendAIQuery(...) async* {
    // Gemini AI 구현
  }
}

// ❌ BAD

// Domain Layer에 직접 Gemini 호출
class SendAIQueryUseCase {
  Future<String> call(String query) async {
    final gemini = GeminiAI(); // ❌ Direct dependency
    return await gemini.query(query);
  }
}
```

---

## Summary

**Chat Domain Layer**는 채팅 Feature의 핵심 비즈니스 로직을 정의하는 순수 Dart 레이어입니다.

**Key Highlights**:

1. **20 files**: 20 main files + 6 generated files = **26 files**, **3,386 lines**
2. **2 Entities**: Chat (147 lines), Message (313 lines)
3. **Extension Pattern**: chat_extensions (159 lines), message_extensions (277 lines)
4. **1 Repository Interface**: IChatRepository (390 lines, 20+ methods)
5. **1 Port Interface**: IAIService (44 lines)
6. **10 UseCases**: SendMessage, GetChatList, SendAIQuery, SearchMessages, Friend operations (4개)
7. **17 Failure Types**: Comprehensive error handling
8. **Freezed Pattern**: 100% immutable entities
9. **Either Pattern**: Type-safe error handling
10. **Clean Architecture v4.0**: Framework independence
11. **Port-Adapter Pattern**: AI service abstraction

**Unique Features**:
- ✅ **Extension Pattern**: Entity Extensions in `domain/entities/` (not `data/extensions/`)
- ✅ **Port-Adapter Pattern**: IAIService (Port) ↔ GeminiAIService (Adapter)
- ✅ **3-Layer Caching**: UnifiedCacheService integration (Memory → Hive → Firestore)
- ✅ **Dual Interface Pattern**: IChatRepository + ChatContract
- ✅ **Friend System**: Friend request/follow UseCases
- ✅ **AI Integration**: Gemini AI chat with streaming responses
- ✅ **Vote Card Support**: Rich vote message entity with A/B options, images, aspect ratios
- ✅ **Idempotency**: eventId parameter for duplicate prevention

**Architecture Pattern**:
```
Presentation → Domain (interfaces, entities) ← Data (implementations, adapters)
```

**Next Steps**:
- Presentation Layer 구현 (UI 위젯, Providers)
- Data Layer 검토 ([Data Layer README](/lib/features/chat/data/README.md) 참조)
- Unit Tests 작성 (UseCases, Entities)
- Integration Tests (Repository 통합)

**Related Documentation**:
- [Data Layer README](/lib/features/chat/data/README.md)
- [Voting Domain README](/lib/features/voting/domain/README.md)
- [Clean Architecture v4.0 Guide](/docs/guides/CLEAN_ARCHITECTURE.md)
- [Freezed Usage Guide](/docs/guides/FREEZED_GUIDE.md)
