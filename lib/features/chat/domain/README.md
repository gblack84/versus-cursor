# Chat Feature - Domain Layer Documentation

> 버전: 2.0.0 | 최종 업데이트: 2025-01-20 | Clean Architecture v4.0

## 📋 Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [Directory Structure](#directory-structure)
- [Architecture & Responsibilities](#architecture--responsibilities)
- [Entities](#entities)
- [Repositories](#repositories)
- [Ports](#ports)
- [Use Cases](#use-cases)
- [Constants & Enums](#constants--enums)
- [Business Logic Patterns](#business-logic-patterns)
- [Design Principles](#design-principles)
- [Testing Strategy](#testing-strategy)
- [Related Documentation](#related-documentation)

---

## Overview

**Chat Feature Domain Layer**는 Clean Architecture v4.0의 핵심 비즈니스 로직 레이어로, 외부 의존성 없이 순수 Dart 타입만 사용하여 채팅 시스템의 규칙과 정책을 정의합니다.

### Design Principles

```yaml
Architecture: "Clean Architecture v4.0 - Pure Domain Layer"
Independence: "No External Dependencies (Firebase, Flutter, etc.)"
Dependency_Rule: "Inward Only - Data → Domain, Domain ↛ Data"
Entity_Types: "Pure Dart + Freezed (Immutable)"
Business_Logic: "Rich Domain Models with Behavior"
```

### Key Characteristics

- **Framework Independence**: Flutter/Firebase 의존성 완전 제거
- **Testability**: 순수 Dart로 빠른 단위 테스트
- **Business Logic Focus**: 도메인 규칙과 정책에만 집중
- **Immutability**: Freezed로 불변 엔티티 보장
- **Port & Adapter**: 외부 서비스를 인터페이스로 추상화

---

## Core Features

### 1. Pure Domain Entities
- **Chat Entity**: 채팅방 데이터 + 비즈니스 로직 (11개 메서드)
- **Message Entity**: 메시지 데이터 + 비즈니스 로직 (40+ 메서드)
- **Freezed**: 불변성, copyWith, pattern matching
- **JSON Serialization**: toJson/fromJson 지원

### 2. Repository Interfaces
- **IChatRepository**: 데이터 접근 추상화 (15개 메서드)
- **Dependency Inversion**: Data Layer가 구현, Domain은 인터페이스만 의존
- **Pure Dart Types**: Firestore 타입 완전 제거

### 3. Use Cases
- **Single Responsibility**: 각 UseCase는 하나의 비즈니스 작업만 수행
- **Result Type**: 성공/실패를 명확히 표현 (`Result<T>`)
- **Input Validation**: 비즈니스 규칙 검증
- **6개 Use Cases**: Chat CRUD, Message CRUD, AI Query

### 4. Ports (External Services)
- **IAIService**: AI 서비스 추상화 (Gemini AI)
- **Port & Adapter Pattern**: Domain은 인터페이스만, Data Layer가 구현

---

## Directory Structure

```
lib/features/chat/domain/
├── constants/                         # 도메인 상수
│   └── chat_constants.dart               # 채팅 시스템 상수 (126 lines)
│
├── entities/                          # 순수 도메인 엔티티
│   ├── chat.dart                         # Chat 엔티티 (135 lines)
│   ├── chat.freezed.dart                 # Freezed 생성 코드
│   ├── chat.g.dart                       # JSON 직렬화 코드
│   ├── message.dart                      # Message 엔티티 (335 lines)
│   ├── message.freezed.dart              # Freezed 생성 코드
│   └── message.g.dart                    # JSON 직렬화 코드
│
├── enums/                             # 도메인 열거형
│   └── message_delivery_status.dart      # 메시지 전달 상태 (17 lines)
│
├── ports/                             # 외부 서비스 인터페이스
│   └── i_ai_service.dart                 # AI 서비스 포트 (54 lines)
│
├── repositories/                      # Repository 인터페이스
│   └── i_chat_repository.dart            # Chat Repository 포트 (87 lines)
│
└── usecases/                          # 비즈니스 유스케이스
    ├── get_chat_list_usecase.dart        # 채팅 목록 조회 (76 lines)
    ├── get_chat_messages_usecase.dart    # 메시지 조회 (78 lines)
    ├── load_more_messages_usecase.dart   # 페이지네이션 (91 lines)
    ├── search_messages_usecase.dart      # 메시지 검색 (94 lines)
    ├── send_ai_query_usecase.dart        # AI 쿼리 (82 lines)
    ├── send_message_usecase.dart         # 메시지 전송 (103 lines)
    └── README.md                         # UseCase 문서

Total: 7 directories, 17 files
```

---

## Architecture & Responsibilities

### Layer Responsibilities

| Component | Responsibility | Dependencies |
|-----------|---------------|--------------|
| **Entities** | 비즈니스 데이터 + 로직, 불변 객체 | None (Pure Dart) |
| **Repositories** | 데이터 접근 추상화 인터페이스 | Entities only |
| **Ports** | 외부 서비스 추상화 인터페이스 | None |
| **Use Cases** | 비즈니스 유스케이스 실행, 검증 | Entities, Repositories, Ports |
| **Constants** | 도메인 규칙, 비즈니스 설정 | None |
| **Enums** | 도메인 상태, 타입 정의 | None |

### Dependency Graph

```
┌────────────────────────────────────────┐
│         Presentation Layer             │
│    (Providers, Widgets, Pages)         │
└──────────────┬─────────────────────────┘
               │ uses
               ↓
┌────────────────────────────────────────┐
│          Domain Layer                  │
│  ┌──────────────────────────────────┐  │
│  │         Use Cases                │  │
│  │  (Business Logic Orchestration)  │  │
│  └──────┬─────────────────┬──────────┘  │
│         │ uses            │ uses        │
│         ↓                 ↓             │
│  ┌─────────────┐   ┌─────────────────┐ │
│  │  Entities   │   │ Repositories    │ │
│  │  (Data +    │   │ (Interfaces)    │ │
│  │   Logic)    │   │                 │ │
│  └─────────────┘   └─────────────────┘ │
│                    ┌─────────────────┐ │
│                    │     Ports       │ │
│                    │  (IAIService)   │ │
│                    └─────────────────┘ │
└────────────────────────────────────────┘
               ↑
               │ implements
               │
┌──────────────┴─────────────────────────┐
│          Data Layer                    │
│  (Repositories, DataSources, DTOs)     │
└────────────────────────────────────────┘
```

★ **Insight ─────────────────────────────────────**
Domain Layer는 **의존성의 방향을 역전**시킵니다. Data Layer가 Domain의 인터페이스를 구현하므로, Domain은 외부 세계를 알 필요가 없습니다. 이를 통해 비즈니스 로직은 프레임워크와 완전히 독립적으로 유지됩니다.
─────────────────────────────────────────────────

---

## Entities

### 📁 `chat.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/entities/chat.dart`

#### Purpose
- **순수 도메인 엔티티**: 채팅방 데이터와 비즈니스 로직
- **불변 객체**: Freezed로 불변성 보장
- **비즈니스 메서드**: 11개의 도메인 로직 메서드

#### Entity Structure

```dart
@freezed
sealed class Chat with _$Chat {
  const Chat._();

  const factory Chat({
    required String id,
    required String chatId,
    required String chatType, // '1:1', 'group'
    required List<String> participantIds,
    required String chatName,
    required String lastMessageContent,
    DateTime? lastMessageAt,
    required bool isRead,
    DateTime? createdAt,
    required Map<String, DateTime> lastReadTimestamps,

    // TODO: Profile Feature로 이동 예정 (Phase 4)
    @Default('') String email,
    @Default('') String displayName,
    @Default('') String photoUrl,
    @Default('') String uid,
    DateTime? createdTime,
    @Default('') String phoneNumber,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
```

#### Business Logic Methods

**1. Participant Management**

```dart
/// 특정 사용자가 채팅방 참여자인지 확인
bool hasParticipant(String userId) {
  return participantIds.contains(userId);
}

/// 상대방 ID 조회 (1:1 채팅방 전용)
String? getOtherUserId(String currentUserId) {
  if (!isDirectChat || participantCount != 2) return null;
  return participantIds.firstWhere(
    (id) => id != currentUserId,
    orElse: () => '',
  );
}
```

**2. Read Status Management**

```dart
/// 특정 사용자의 마지막 읽은 시간 조회
DateTime? getLastReadFor(String userId) {
  return lastReadTimestamps[userId];
}

/// 채팅방에 읽지 않은 메시지가 있는지 확인
bool hasUnreadMessages(String userId) {
  final lastRead = getLastReadFor(userId);
  if (lastRead == null || lastMessageAt == null) return true;
  return lastMessageAt!.isAfter(lastRead);
}
```

**3. Chat Type Helpers**

```dart
/// 1:1 채팅방 여부
bool get isDirectChat => chatType == '1:1' || chatType == 'direct';

/// 그룹 채팅방 여부
bool get isGroupChat => chatType == 'group';

/// 채팅방 참여자 수
int get participantCount => participantIds.length;

/// 채팅방이 활성화 상태인지 (메시지가 1개 이상)
bool get isActive => lastMessageContent.isNotEmpty;
```

**4. Display Helpers**

```dart
/// 채팅방 표시 이름 (그룹: chatName, 1:1: 상대방 이름)
String getDisplayName(String currentUserId) {
  if (isGroupChat) return chatName;
  // 1:1 채팅: displayName 사용 (TODO: Profile feature 통합 후 개선)
  return displayName.isNotEmpty ? displayName : '알 수 없음';
}
```

★ **Insight ─────────────────────────────────────**
Chat 엔티티는 **Rich Domain Model** 패턴을 따릅니다. 데이터만 담는 빈약한 모델이 아니라, 채팅방 관련 비즈니스 로직을 직접 포함합니다. 이를 통해 로직이 여러 곳에 흩어지지 않고 엔티티에 캡슐화됩니다.
─────────────────────────────────────────────────

---

### 📁 `message.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/entities/message.dart`

#### Purpose
- **메시지 도메인 엔티티**: 메시지 데이터 + 40+ 비즈니스 메서드
- **다양한 메시지 타입**: text, image, video, vote_request
- **투표 시스템 통합**: 투표 카드 메시지 전용 필드 및 로직

#### Entity Structure

```dart
@freezed
sealed class Message with _$Message {
  const Message._();

  const factory Message({
    // ========== Basic Message Fields ==========
    required String id,
    required String parentPath,
    required String messageId,
    required String senderId,
    required String content,
    @Default('') String attachmentUrl,
    @Default('') String attachmentType,
    DateTime? timeStamp,
    required bool isRead,
    @Default('text') String messageType, // text, image, video, vote_request

    // ========== Media Fields ==========
    @Default('text') String mediaType,
    @Default('') String imageUrl,
    @Default('') String videoUrl,
    @Default('') String thumbnailUrl,
    @Default(0) int mediaSize,
    double? mediaWidth,
    double? mediaHeight,

    // ========== Message Lifecycle ==========
    DateTime? deliveredAt,
    DateTime? seenAt,

    // ========== Vote Card Fields ==========
    @Default('') String receiverId,
    @Default('') String votePostId,
    @Default('') String voteTitle,
    @Default('') String voteDescription,
    @Default('') String voteOptionAText,
    @Default('') String voteOptionBText,
    @Default('') String voteOptionAImage, // legacy
    @Default('') String voteOptionBImage, // legacy
    @Default([]) List<String> voteOptionAImages,
    @Default([]) List<String> voteOptionBImages,
    @Default('pending') String voteStatus, // pending, completed, expired
    @Default('') String cardStatus,
    DateTime? voteEndTime,
    @Default({}) Map<String, dynamic> voteResults,
    @Default({}) Map<String, dynamic> userVotes,
    double? voteAspectRatioA,
    double? voteAspectRatioB,
    @Default(0) int voteResultsA,
    @Default(0) int voteResultsB,
    @Default(0.0) double votePercentA,
    @Default(0.0) double votePercentB,

    // ========== Metadata ==========
    @Default({}) Map<String, dynamic> metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
```

#### Business Logic Categories

**1. Message Type Checks (5 methods)**

```dart
bool get isTextMessage => messageType == 'text';
bool get isImageMessage => messageType == 'image' || mediaType == 'image';
bool get isVideoMessage => messageType == 'video' || mediaType == 'video';
bool get isVoteRequest => messageType == 'vote_request';
bool get hasMedia => isImageMessage || isVideoMessage;
```

**2. Message Lifecycle (4 methods)**

```dart
bool get isDelivered => deliveredAt != null;
bool get isSeen => seenAt != null;

String get deliveryStatus {
  if (isSeen) return 'seen';
  if (isDelivered) return 'delivered';
  return 'sent';
}
```

**3. Vote Logic (11 methods)**

```dart
// Vote Status
bool get isVotePending => voteStatus == 'pending';
bool get isVoteCompleted => voteStatus == 'completed';
bool get isVoteExpired => voteStatus == 'expired';
bool get isVoteEnded => isVoteCompleted || isVoteExpired;

// Vote Timing
int? get voteRemainingSeconds {
  if (voteEndTime == null) return null;
  final now = DateTime.now();
  if (now.isAfter(voteEndTime!)) return 0;
  return voteEndTime!.difference(now).inSeconds;
}

// Vote Statistics
int get voteParticipantCount => userVotes.length;
int get totalVoteCount => voteResultsA + voteResultsB;

String? get voteWinner {
  if (!isVoteCompleted || totalVoteCount == 0) return null;
  if (voteResultsA > voteResultsB) return 'A';
  if (voteResultsB > voteResultsA) return 'B';
  return 'tie';
}
```

**4. User Vote Helpers (7 methods)**

```dart
Map<String, dynamic>? getUserVote(String userId) {
  return userVotes[userId] as Map<String, dynamic>?;
}

bool hasUserVoted(String userId) {
  return userVotes.containsKey(userId);
}

String? getUserVoteChoice(String userId) {
  final vote = getUserVote(userId);
  return vote?['option'] as String?;
}

DateTime? getUserVoteTime(String userId) {
  final vote = getUserVote(userId);
  final timestamp = vote?['votedAt'];

  if (timestamp is DateTime) return timestamp;
  if (timestamp is int) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  return null;
}

bool hasUserVotedA(String userId) {
  return getUserVoteChoice(userId) == 'A';
}

bool hasUserVotedB(String userId) {
  return getUserVoteChoice(userId) == 'B';
}
```

**5. Media Helpers (6 methods)**

```dart
double? get mediaAspectRatio {
  if (mediaWidth == null || mediaHeight == null || mediaHeight == 0) {
    return null;
  }
  return mediaWidth! / mediaHeight!;
}

bool get isMediaLandscape {
  final ratio = mediaAspectRatio;
  return ratio != null && ratio > 1.0;
}

bool get isMediaPortrait {
  final ratio = mediaAspectRatio;
  return ratio != null && ratio < 1.0;
}

double get mediaSizeInMB {
  return mediaSize / (1024 * 1024);
}
```

**6. Content Helpers (6 methods)**

```dart
bool get hasContent => content.isNotEmpty;
bool get hasAttachment => attachmentUrl.isNotEmpty;

String get contentPreview {
  if (isVoteRequest) return '📊 투표 요청: $voteTitle';
  if (isImageMessage) return '📷 이미지';
  if (isVideoMessage) return '🎥 비디오';
  if (content.isEmpty) return '(내용 없음)';
  return content.length > 100 ? '${content.substring(0, 100)}...' : content;
}

bool get hasVoteOptionAImages =>
    voteOptionAImages.isNotEmpty || voteOptionAImage.isNotEmpty;

bool get hasVoteOptionBImages =>
    voteOptionBImages.isNotEmpty || voteOptionBImage.isNotEmpty;

bool get hasVoteImages => hasVoteOptionAImages || hasVoteOptionBImages;
```

**7. Parent Chat Helper**

```dart
String get parentChatId {
  // parentPath 형식: "chats/chatId"
  final parts = parentPath.split('/');
  return parts.length >= 2 ? parts[1] : '';
}
```

★ **Insight ─────────────────────────────────────**
Message 엔티티는 **40+ 비즈니스 메서드**를 포함하여, Presentation Layer가 메시지 관련 모든 로직을 엔티티에 위임할 수 있습니다. 이는 로직 중복을 방지하고, 단일 진실의 원천(Single Source of Truth)을 유지합니다.
─────────────────────────────────────────────────

---

## Repositories

### 📁 `i_chat_repository.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/repositories/i_chat_repository.dart`

#### Purpose
- **데이터 접근 추상화**: Firebase 의존성 완전 제거
- **Dependency Inversion**: Data Layer가 이 인터페이스 구현
- **순수 Dart 타입**: Domain Entity만 사용

#### Interface Definition

```dart
abstract class IChatRepository {
  // ========== Chat Queries ==========

  /// 현재 사용자의 채팅 목록 실시간 스트림
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  /// 채팅방 개수 조회
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  });

  /// 단일 채팅방 조회
  Future<Chat?> getChat(String chatId);

  // ========== Message Queries ==========

  /// 특정 채팅방의 메시지 실시간 스트림
  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  /// 특정 메시지 이전의 메시지 로드 (페이지네이션)
  ///
  /// **Clean Architecture v4.0**:
  /// - UseCase는 messageId만 전달
  /// - Repository에서 Firestore DocumentSnapshot 처리
  /// - Pure Domain Entity 반환
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

  // ========== CRUD Operations ==========

  /// 새 채팅방 생성
  Future<void> createChat(Chat chat);

  /// 채팅방 정보 업데이트
  Future<void> updateChat(Chat chat);

  /// 채팅방 삭제
  Future<void> deleteChat(String chatId);

  /// 새 메시지 전송
  Future<void> sendMessage(String chatId, Message message);

  /// 메시지 삭제
  Future<void> deleteMessage(String chatId, String messageId);

  // ========== Media Upload ==========

  /// 채팅 미디어(이미지/비디오) 업로드
  ///
  /// **Implementation**:
  /// - Data Layer에서 ChatMediaUploadService 사용
  /// - 이미지: 자동 압축 (2MB 이하)
  /// - 비디오: 썸네일 자동 생성
  Future<String> uploadMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType, // 'image' or 'video'
  });
}
```

#### Method Categories

| Category | Methods | Purpose |
|----------|---------|---------|
| **Chat Queries** | queryChats, queryChatsCount, getChat | 채팅방 목록 및 정보 조회 |
| **Message Queries** | queryMessagesByChatId, queryMessagesBeforeMessageId, queryMessagesCount | 메시지 조회 및 페이지네이션 |
| **CRUD** | createChat, updateChat, deleteChat, sendMessage, deleteMessage | 채팅/메시지 생성/수정/삭제 |
| **Media** | uploadMedia | 이미지/비디오 업로드 |

---

## Ports

### 📁 `i_ai_service.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/ports/i_ai_service.dart`

#### Purpose
- **AI 서비스 추상화**: Gemini AI 의존성 제거
- **Port & Adapter Pattern**: Domain은 Port만, Data는 Adapter 구현
- **AI 제공자 교체 가능**: Gemini → OpenAI 등 쉽게 교체

#### Port Definition

```dart
abstract class IAIService {
  /// AI에게 질문을 전송하고 스트리밍 응답 받기
  ///
  /// **Returns**:
  /// - `Stream<String>`: AI 응답의 실시간 스트림 (청크 단위)
  ///
  /// **예외**:
  /// - 네트워크 오류, API 키 오류, 응답 생성 실패 등
  Stream<String> sendQuery(String query);

  /// 현재 AI 응답 생성 중인지 여부
  bool get isStreaming;

  /// 현재 진행 중인 AI 응답 취소
  ///
  /// **사용 시나리오**:
  /// - 사용자가 Stop 버튼 클릭
  /// - 새로운 쿼리 전송으로 이전 쿼리 중단 필요
  Future<void> cancelCurrentQuery();

  /// AI 서비스 초기화
  ///
  /// **Parameters**:
  /// - [apiKey]: AI API 키 (예: Gemini API Key)
  ///
  /// **호출 시점**: 앱 시작 시 또는 AI 채팅 페이지 진입 시
  void initialize(String apiKey);
}
```

★ **Insight ─────────────────────────────────────**
Port & Adapter 패턴은 **외부 서비스를 완전히 추상화**합니다. Domain은 IAIService 인터페이스만 알고, Data Layer의 GeminiAIService는 이를 구현합니다. 이를 통해 AI 제공자를 교체해도 Domain 코드는 변경되지 않습니다.
─────────────────────────────────────────────────

---

## Use Cases

### Overview

Use Case는 **단일 비즈니스 작업**을 수행하는 순수 비즈니스 로직입니다. 각 UseCase는:

- **Single Responsibility**: 하나의 작업만 수행
- **Input Validation**: 비즈니스 규칙 검증
- **Repository Orchestration**: 여러 Repository 메서드 조율
- **Result Type**: 성공/실패를 명확히 표현

### 📁 `send_message_usecase.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/usecases/send_message_usecase.dart`

#### Purpose
- **새 메시지 전송**: 텍스트/이미지/비디오 메시지 전송
- **미디어 업로드**: 파일이 있으면 먼저 업로드 후 URL 추가
- **입력 검증**: chatId, content/mediaFile 필수 검증

#### Class Structure

```dart
class SendMessageUseCase {
  final IChatRepository _chatRepository;

  SendMessageUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  Future<Result<void>> execute({
    required String chatId,
    required Message message,
    File? mediaFile,
  }) async {
    try {
      // 1. 입력 검증
      if (chatId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'Chat ID가 필요합니다.'),
        );
      }

      if (message.content.isEmpty && mediaFile == null) {
        return ResultFailure(
          ValidationFailure(message: '메시지 내용 또는 미디어 파일이 필요합니다.'),
        );
      }

      Message finalMessage = message;

      // 2. 미디어 파일이 있으면 먼저 업로드
      if (mediaFile != null) {
        try {
          final mediaUrl = await _chatRepository.uploadMedia(
            chatId: chatId,
            messageId: message.id,
            file: mediaFile,
            mediaType: message.mediaType,
          );

          // 업로드된 URL을 Message에 추가
          if (message.mediaType == 'image') {
            finalMessage = message.copyWith(imageUrl: mediaUrl);
          } else if (message.mediaType == 'video') {
            finalMessage = message.copyWith(videoUrl: mediaUrl);
          }
        } catch (e) {
          return ResultFailure(
            ServerFailure(message: '미디어 업로드 실패: ${e.toString()}'),
          );
        }
      }

      // 3. 메시지 전송
      await _chatRepository.sendMessage(chatId, finalMessage);

      return const Success(null);
    } catch (e) {
      return ResultFailure(
        ServerFailure(message: '메시지 전송 실패: ${e.toString()}'),
      );
    }
  }
}
```

---

### 📁 `get_chat_list_usecase.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/usecases/get_chat_list_usecase.dart`

#### Purpose
- **채팅 목록 조회**: 현재 사용자의 채팅 실시간 스트림
- **정렬**: lastMessageAt 기준 내림차순
- **페이지네이션**: limit 지원

#### Class Structure

```dart
class GetChatListUseCase {
  final IChatRepository _chatRepository;

  GetChatListUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  Stream<Result<List<Chat>>> execute({
    required String userId,
    int limit = 50,
  }) {
    try {
      // 입력 검증
      if (userId.isEmpty) {
        return Stream.value(
          ResultFailure(
            ValidationFailure(message: 'User ID는 비어있을 수 없습니다.'),
          ),
        );
      }

      // Repository 호출 (Firestore 타입 제거)
      final chatsStream = _chatRepository.queryChats(
        userId: userId,
        limit: limit,
        orderBy: 'lastMessageAt',
        descending: true,
      );

      // Stream<List<Chat>>을 Result로 감싸서 반환
      return chatsStream.map((chats) => Success(chats));
    } catch (e) {
      return Stream.value(
        ResultFailure(
          ServerFailure(message: '채팅 목록 로드 실패: ${e.toString()}'),
        ),
      );
    }
  }
}
```

---

### 📁 `get_chat_messages_usecase.dart`

**Purpose**: 특정 채팅방의 메시지 실시간 스트림 조회

### 📁 `load_more_messages_usecase.dart`

**Purpose**: 메시지 페이지네이션 (특정 메시지 이전 메시지 로드)

### 📁 `search_messages_usecase.dart`

**Purpose**: 채팅방 내 메시지 검색

### 📁 `send_ai_query_usecase.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/usecases/send_ai_query_usecase.dart`

#### Purpose
- **AI 쿼리 전송**: Gemini AI에 질문 전송
- **스트리밍 응답**: 실시간 AI 응답 스트림 반환
- **입력 검증**: query 비어있는지 확인

#### Class Structure

```dart
class SendAIQueryUseCase {
  final IAIService _aiService;

  SendAIQueryUseCase({required IAIService aiService})
      : _aiService = aiService;

  Future<Result<Stream<String>>> execute({
    required String query,
  }) async {
    try {
      // 입력 검증
      if (query.trim().isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'AI에게 물어볼 내용을 입력해주세요.'),
        );
      }

      // AI Service 호출
      final stream = _aiService.sendQuery(query.trim());

      return Success(stream);
    } catch (e) {
      return ResultFailure(
        ServerFailure(message: 'AI 쿼리 전송 실패: ${e.toString()}'),
      );
    }
  }

  /// 현재 진행 중인 AI 응답 취소
  Future<void> cancelCurrentQuery() async {
    await _aiService.cancelCurrentQuery();
  }

  /// AI 스트리밍 진행 상태 확인
  bool get isStreaming => _aiService.isStreaming;
}
```

---

## Constants & Enums

### 📁 `chat_constants.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/constants/chat_constants.dart`

#### Purpose
- **도메인 규칙**: 채팅 시스템의 비즈니스 설정
- **UI 설정**: 페이지네이션, 애니메이션 설정
- **메시지 타입**: 메시지 타입 상수 정의

#### Key Constants

```dart
class ChatConstants {
  ChatConstants._();

  // ========== 메시지 로딩 관련 ==========

  /// 초기 메시지 로드 개수
  static const int initialMessageLoadCount = 30;

  /// 추가 메시지 로드 개수 (페이지네이션)
  static const int paginationMessageCount = 20;

  /// 스크롤 임계값 - 추가 메시지 로드 (픽셀)
  static const double loadMoreThreshold = 100;

  /// 스크롤 임계값 - FAB 표시/숨김 (픽셀)
  static const double fabShowThreshold = 500;

  // ========== 애니메이션 관련 ==========

  /// FAB 스케일 애니메이션 시간
  static const Duration fabScaleAnimationDuration = Duration(milliseconds: 300);

  // ========== 캐시 관련 ==========

  /// 사용자 캐시 유지 개수
  static const int userCacheKeepCount = 100;

  /// 사용자 로딩 타임아웃 반복 횟수 (100ms x 50 = 5초)
  static const int userLoadingTimeoutIterations = 50;

  /// 사용자 로딩 체크 간격
  static const Duration userLoadingCheckInterval = Duration(milliseconds: 100);

  // ========== 메시지 타입 ==========

  /// 텍스트 메시지 타입
  static const String messageTypeText = 'text';

  /// 이미지 메시지 타입
  static const String messageTypeImage = 'image';

  /// 투표 요청 메시지 타입
  static const String messageTypeVoteRequest = 'voteRequest';

  /// 투표 생성 메시지 타입
  static const String messageTypeVoteCreated = 'voteCreated';

  /// 시스템 메시지 타입
  static const String messageTypeSystem = 'system';

  // ========== UI 텍스트 ==========

  /// 투표 완료 알림 텍스트
  static const String voteCompletedText = '피클! 피클! 피클!';
}
```

---

### 📁 `message_delivery_status.dart`

**Location**: `/Users/g_black/versus-cursor/lib/features/chat/domain/enums/message_delivery_status.dart`

#### Purpose
- **메시지 전달 상태**: 메시지 생명주기 표현
- **UI 표시**: 읽음 표시, 체크 마크 등

#### Enum Definition

```dart
enum MessageDeliveryStatus {
  /// Message has been sent from the client
  sent,

  /// Message has been delivered to the server
  delivered,

  /// Message has been seen by the recipient
  seen,

  /// Status cannot be determined
  unknown,
}
```

---

## Business Logic Patterns

### 1. Rich Domain Model Pattern

**개념**: 엔티티가 데이터뿐 아니라 비즈니스 로직도 포함

**예시**: Message 엔티티의 40+ 메서드

```dart
// ❌ 빈약한 도메인 모델 (Anemic Domain Model)
class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  // 데이터만 있고 로직 없음
}

// 비즈니스 로직이 Service에 흩어짐
class MessageService {
  bool isReadMessage(Message msg) => msg.deliveredAt != null;
  String getDeliveryStatus(Message msg) { ... }
  int getRemainingSeconds(Message msg) { ... }
}

// ✅ 풍부한 도메인 모델 (Rich Domain Model)
class Message {
  final String id;
  final String content;
  final DateTime timestamp;

  // 비즈니스 로직이 엔티티에 캡슐화
  bool get isDelivered => deliveredAt != null;
  bool get isSeen => seenAt != null;
  String get deliveryStatus { ... }
  int? get voteRemainingSeconds { ... }
}
```

**장점**:
- 로직 중복 방지
- 단일 진실의 원천 (Single Source of Truth)
- 테스트 용이성

---

### 2. Value Object Pattern

**개념**: 불변 객체로 도메인 개념 표현

**예시**: Chat, Message는 Freezed로 불변 보장

```dart
@freezed
sealed class Chat with _$Chat {
  const factory Chat({
    required String id,
    required List<String> participantIds,
    // ...
  }) = _Chat;
}

// 사용
final chat = Chat(id: '1', participantIds: ['user1']);

// ❌ 직접 수정 불가 (컴파일 에러)
// chat.participantIds.add('user2');

// ✅ copyWith로 새 객체 생성
final updatedChat = chat.copyWith(
  participantIds: [...chat.participantIds, 'user2'],
);
```

---

### 3. Repository Pattern

**개념**: 데이터 접근을 추상화하여 비즈니스 로직과 분리

**예시**: IChatRepository 인터페이스

```dart
// Domain Layer: 인터페이스만 정의
abstract class IChatRepository {
  Stream<List<Chat>> queryChats({required String userId});
  Future<void> sendMessage(String chatId, Message message);
}

// Data Layer: 구현체
class ChatRepositoryImpl implements IChatRepository {
  final FirebaseFirestore _firestore;

  @override
  Stream<List<Chat>> queryChats({required String userId}) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => ...);
  }
}
```

---

### 4. Dependency Inversion Principle

**개념**: 고수준 모듈이 저수준 모듈에 의존하지 않고, 둘 다 추상화에 의존

```
❌ 의존성 방향 잘못됨:
Domain (UseCase) → Data (Repository 구현체) → Firebase

✅ 의존성 역전:
Domain (UseCase) ← Domain (IChatRepository 인터페이스)
                       ↑
                    Data (ChatRepositoryImpl)
                       ↓
                    Firebase
```

---

### 5. Port & Adapter Pattern (Hexagonal Architecture)

**개념**: 외부 시스템을 Port(인터페이스)로 추상화, Adapter가 구현

```dart
// Domain Layer: Port
abstract class IAIService {
  Stream<String> sendQuery(String query);
}

// Data Layer: Adapter
class GeminiAIService implements IAIService {
  final GenerativeModel _model;

  @override
  Stream<String> sendQuery(String query) {
    return _model.generateContentStream([...]);
  }
}
```

---

## Design Principles

### SOLID Principles

**1. Single Responsibility Principle (SRP)**
- 각 UseCase는 하나의 비즈니스 작업만 수행
- 각 Entity는 하나의 도메인 개념만 표현

**2. Open/Closed Principle (OCP)**
- 새로운 메시지 타입 추가 시 Entity 확장 가능
- 새로운 AI 제공자 추가 시 IAIService 구현만 추가

**3. Liskov Substitution Principle (LSP)**
- IChatRepository 구현체는 언제든 교체 가능
- IAIService 구현체는 언제든 교체 가능

**4. Interface Segregation Principle (ISP)**
- IChatRepository는 필요한 메서드만 정의
- IAIService는 AI 관련 메서드만 정의

**5. Dependency Inversion Principle (DIP)**
- Domain은 인터페이스에만 의존
- Data Layer가 Domain 인터페이스 구현

---

### Clean Architecture Principles

**1. Independence of Frameworks**
- Domain은 Flutter, Firebase 의존성 없음
- 프레임워크 교체 가능

**2. Testability**
- 순수 Dart 코드로 빠른 단위 테스트
- Mock 주입으로 독립적 테스트

**3. Independence of UI**
- Domain 로직은 UI와 완전히 분리
- CLI, Web, Mobile 모두 동일한 Domain 사용 가능

**4. Independence of Database**
- Firestore → MongoDB 교체 가능
- Repository 구현만 변경, Domain 불변

**5. Independence of External Services**
- Gemini AI → OpenAI 교체 가능
- Adapter 구현만 변경, Domain 불변

---

## Testing Strategy

### Test Pyramid

```
        ┌─────────────┐
        │ E2E Tests   │ 5%   (Presentation → Domain → Data)
        ├─────────────┤
        │Integration  │ 15%  (UseCase + Repository Mock)
        ├─────────────┤
        │ Unit Tests  │ 80%  (Entity, UseCase, Business Logic)
        └─────────────┘
```

### Unit Tests (80% coverage target)

**Entity Tests**

```dart
void main() {
  group('Chat Entity', () {
    test('hasParticipant should return true for existing user', () {
      // Arrange
      final chat = Chat(
        id: '1',
        chatId: 'chat1',
        chatType: '1:1',
        participantIds: ['user1', 'user2'],
        chatName: 'Test Chat',
        lastMessageContent: 'Hello',
        isRead: false,
        lastReadTimestamps: {},
      );

      // Act
      final result = chat.hasParticipant('user1');

      // Assert
      expect(result, true);
    });

    test('hasUnreadMessages should return true when lastMessage is after lastRead', () {
      // Arrange
      final lastRead = DateTime.now().subtract(Duration(hours: 1));
      final lastMessage = DateTime.now();

      final chat = Chat(
        id: '1',
        chatId: 'chat1',
        chatType: '1:1',
        participantIds: ['user1'],
        chatName: 'Test',
        lastMessageContent: 'New message',
        lastMessageAt: lastMessage,
        isRead: false,
        lastReadTimestamps: {'user1': lastRead},
      );

      // Act
      final result = chat.hasUnreadMessages('user1');

      // Assert
      expect(result, true);
    });

    test('getOtherUserId should return other user in 1:1 chat', () {
      // Arrange
      final chat = Chat(
        id: '1',
        chatId: 'chat1',
        chatType: '1:1',
        participantIds: ['user1', 'user2'],
        chatName: 'Test',
        lastMessageContent: '',
        isRead: false,
        lastReadTimestamps: {},
      );

      // Act
      final result = chat.getOtherUserId('user1');

      // Assert
      expect(result, 'user2');
    });
  });

  group('Message Entity', () {
    test('deliveryStatus should return correct status', () {
      // Arrange
      final sentMessage = Message(
        id: '1',
        parentPath: 'chats/chat1',
        messageId: 'msg1',
        senderId: 'user1',
        content: 'Hello',
        isRead: false,
      );

      final deliveredMessage = sentMessage.copyWith(
        deliveredAt: DateTime.now(),
      );

      final seenMessage = deliveredMessage.copyWith(
        seenAt: DateTime.now(),
      );

      // Act & Assert
      expect(sentMessage.deliveryStatus, 'sent');
      expect(deliveredMessage.deliveryStatus, 'delivered');
      expect(seenMessage.deliveryStatus, 'seen');
    });

    test('voteWinner should return correct winner', () {
      // Arrange
      final message = Message(
        id: '1',
        parentPath: 'chats/chat1',
        messageId: 'msg1',
        senderId: 'user1',
        content: 'Vote',
        isRead: false,
        messageType: 'vote_request',
        voteStatus: 'completed',
        voteResultsA: 10,
        voteResultsB: 5,
      );

      // Act
      final winner = message.voteWinner;

      // Assert
      expect(winner, 'A');
    });

    test('hasUserVoted should return true for voted user', () {
      // Arrange
      final message = Message(
        id: '1',
        parentPath: 'chats/chat1',
        messageId: 'msg1',
        senderId: 'user1',
        content: 'Vote',
        isRead: false,
        userVotes: {
          'user2': {'option': 'A', 'votedAt': DateTime.now().millisecondsSinceEpoch},
        },
      );

      // Act
      final result = message.hasUserVoted('user2');

      // Assert
      expect(result, true);
    });
  });
}
```

**UseCase Tests**

```dart
void main() {
  late SendMessageUseCase useCase;
  late MockIChatRepository mockRepository;

  setUp(() {
    mockRepository = MockIChatRepository();
    useCase = SendMessageUseCase(chatRepository: mockRepository);
  });

  group('SendMessageUseCase', () {
    test('should return Success when message is sent', () async {
      // Arrange
      final message = Message(
        id: 'msg1',
        parentPath: 'chats/chat1',
        messageId: 'msg1',
        senderId: 'user1',
        content: 'Hello',
        isRead: false,
      );

      when(mockRepository.sendMessage('chat1', message))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.execute(
        chatId: 'chat1',
        message: message,
      );

      // Assert
      expect(result, isA<Success>());
      verify(mockRepository.sendMessage('chat1', message)).called(1);
    });

    test('should return ValidationFailure when chatId is empty', () async {
      // Arrange
      final message = Message(
        id: 'msg1',
        parentPath: 'chats/chat1',
        messageId: 'msg1',
        senderId: 'user1',
        content: 'Hello',
        isRead: false,
      );

      // Act
      final result = await useCase.execute(
        chatId: '',
        message: message,
      );

      // Assert
      expect(result, isA<ResultFailure>());
      expect((result as ResultFailure).failure, isA<ValidationFailure>());
      verifyNever(mockRepository.sendMessage(any, any));
    });

    test('should upload media before sending message', () async {
      // Arrange
      final message = Message(
        id: 'msg1',
        parentPath: 'chats/chat1',
        messageId: 'msg1',
        senderId: 'user1',
        content: '',
        isRead: false,
        mediaType: 'image',
      );

      final mediaFile = File('test.jpg');
      const uploadedUrl = 'https://storage.example.com/test.jpg';

      when(mockRepository.uploadMedia(
        chatId: 'chat1',
        messageId: 'msg1',
        file: mediaFile,
        mediaType: 'image',
      )).thenAnswer((_) async => uploadedUrl);

      when(mockRepository.sendMessage('chat1', any))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.execute(
        chatId: 'chat1',
        message: message,
        mediaFile: mediaFile,
      );

      // Assert
      expect(result, isA<Success>());
      verify(mockRepository.uploadMedia(
        chatId: 'chat1',
        messageId: 'msg1',
        file: mediaFile,
        mediaType: 'image',
      )).called(1);

      final captured = verify(mockRepository.sendMessage('chat1', captureAny))
          .captured.single as Message;
      expect(captured.imageUrl, uploadedUrl);
    });
  });
}
```

### Integration Tests (15% coverage target)

**UseCase + Repository Integration**

```dart
void main() {
  late GetChatListUseCase useCase;
  late MockIChatRepository mockRepository;

  setUp(() {
    mockRepository = MockIChatRepository();
    useCase = GetChatListUseCase(chatRepository: mockRepository);
  });

  test('should stream chats in real-time', () async {
    // Arrange
    final chat1 = Chat(
      id: '1',
      chatId: 'chat1',
      chatType: '1:1',
      participantIds: ['user1', 'user2'],
      chatName: 'Chat 1',
      lastMessageContent: 'Hello',
      isRead: false,
      lastReadTimestamps: {},
    );

    final chat2 = Chat(
      id: '2',
      chatId: 'chat2',
      chatType: '1:1',
      participantIds: ['user1', 'user3'],
      chatName: 'Chat 2',
      lastMessageContent: 'Hi',
      isRead: true,
      lastReadTimestamps: {},
    );

    when(mockRepository.queryChats(
      userId: 'user1',
      limit: 50,
      orderBy: 'lastMessageAt',
      descending: true,
    )).thenAnswer((_) => Stream.value([chat1, chat2]));

    // Act
    final stream = useCase.execute(userId: 'user1', limit: 50);

    // Assert
    await expectLater(
      stream,
      emits(isA<Success<List<Chat>>>()),
    );

    final result = await stream.first;
    expect(result, isA<Success<List<Chat>>>());
    final chats = (result as Success<List<Chat>>).data;
    expect(chats.length, 2);
    expect(chats[0].id, '1');
    expect(chats[1].id, '2');
  });
}
```

---

## Related Documentation

### Feature Documentation
- [Chat Data Layer](/lib/features/chat/data/README.md) - Data layer implementation
- [Chat Presentation Layer](/lib/features/chat/presentation/README.md) - UI widgets, providers
- [Voting Feature](/lib/features/voting/domain/README.md) - Vote request message integration

### Architecture Guides
- [Clean Architecture v4.0](/docs/architecture/clean-architecture.md)
- [Repository Pattern](/docs/patterns/repository-pattern.md)
- [Port & Adapter Pattern](/docs/patterns/port-adapter-pattern.md)
- [Rich Domain Model](/docs/patterns/rich-domain-model.md)

### Testing Resources
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Freezed Documentation](https://pub.dev/packages/freezed)

---

## Changelog

### v2.0.0 (2025-01-20)
- ✅ Clean Architecture v4.0 완전 마이그레이션
- ✅ Firestore 의존성 완전 제거 (Pure Dart)
- ✅ Chat Entity 11개 비즈니스 메서드 추가
- ✅ Message Entity 40+ 비즈니스 메서드 추가
- ✅ IChatRepository 인터페이스 정의 (15개 메서드)
- ✅ IAIService Port 추가 (Gemini AI 추상화)
- ✅ 6개 Use Cases 구현 (Result 타입 사용)
- ✅ Freezed로 불변 엔티티 보장
- ✅ JSON 직렬화 지원 (toJson/fromJson)

### v1.0.0 (2024-12-01)
- 🎉 Initial release with basic chat functionality

---

> 💡 **Tip**: 이 문서는 Chat Feature Domain Layer의 **완전한 참조 가이드**입니다. 새로운 비즈니스 로직 추가 시 동일한 패턴을 따라 확장하십시오.

**Last Updated**: 2025-01-20 | **Maintainer**: Backend Team
