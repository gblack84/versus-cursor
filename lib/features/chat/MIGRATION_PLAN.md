# 💬 Chat Feature - Firebase 격리 마이그레이션 계획서

> **작성일**: 2025-01-20
> **브랜치**: `refactor/chat-firebase-isolation`
> **예상 소요**: 25-36시간
> **아키텍처**: Clean Architecture v4.0 (Feature-First + Layered)

---

## 📋 목차

1. [현황 분석](#-현황-분석)
2. [마이그레이션 목표](#-마이그레이션-목표)
3. [Phase별 상세 계획](#-phase별-상세-계획)
4. [리스크 관리](#-리스크-관리)
5. [검증 체크리스트](#-검증-체크리스트)
6. [참고 자료](#-참고-자료)

---

## 📊 현황 분석

### 전체 파일 통계
```
총 39개 파일:
├── README: 10개 (기능 문서)
├── Domain: 6개 (5 models + 1 repository interface)
├── Data: 12개 (9 adapters + 1 repository impl + exports + backup)
└── Presentation: 9개 (screens + controllers)
```

### Clean Architecture 준수율
- **Profile Feature**: 100% (완전 준수)
- **Chat Feature**: 28% (부분 준수)

**주요 이슈**:
1. ❌ MessagesModel이 `FirestoreRecord` 상속 (674줄, 60+ 필드)
2. ❌ DTO Layer 없음 (Firebase 타입 직접 노출)
3. ❌ DataSource Pattern 없음
4. ❌ UseCase Layer 없음 (비즈니스 로직 분산)
5. ❌ Provider Pattern 없음 (flutter_chat_core 직접 사용)

### 디렉토리 구조 현황
```
lib/features/chat/
├── domain/
│   ├── models/                    # ❌ FirestoreRecord 의존성
│   │   ├── chat_history_model.dart         (140줄)
│   │   ├── chats_model.dart                (297줄)
│   │   ├── group_chats_model.dart          (215줄)
│   │   ├── group_messages_model.dart       (280줄)
│   │   └── messages_model.dart             (674줄) ⚠️ 최우선
│   ├── repositories/              # ✅ 인터페이스 잘 정의됨
│   │   └── i_chat_repository.dart          (90줄)
│   ├── constants/                 # ✅ 유지
│   │   └── constants.dart
│   └── usecases/                  # ❌ 비어있음 (README만)
│
├── data/
│   ├── adapters/                  # 🔄 services로 이동 필요
│   │   ├── chat_animation_service.dart     (62줄)
│   │   ├── chat_initialization_service.dart (372줄)
│   │   ├── chat_media_upload_service.dart  (216줄)
│   │   ├── chat_message_lifecycle_service.dart (137줄)
│   │   ├── chat_message_service.dart       (383줄)
│   │   ├── chat_scroll_service.dart        (145줄)
│   │   ├── chat_vote_card_handler.dart     (161줄)
│   │   ├── message_mapper.dart             (259줄)
│   │   └── message_to_ui_converter.dart    (236줄)
│   ├── repositories/              # ❌ Firebase 직접 호출
│   │   └── chat_repository_impl.dart       (276줄)
│   ├── datasources/               # ❌ 비어있음 (README만)
│   └── exports/                   # ✅ 유지
│
└── presentation/
    ├── screens/                   # ✅ 구조 양호
    │   ├── chat_detail/
    │   │   └── chat_detail_controller_v2.dart (71줄)
    │   ├── chat_detail_v2/
    │   │   └── chat_detail_widget_v2.dart     (631줄)
    │   └── ai_chat_v2/
    │       └── ai_chat_page_v2.dart           (651줄)
    ├── providers/                 # ❌ 비어있음 (README만)
    └── widgets/                   # ❌ 비어있음 (README만)
```

---

## 🎯 마이그레이션 목표

### 최종 목표 아키텍처
```
lib/features/chat/
├── domain/                        # 순수 Dart, Firebase 독립
│   ├── models/                   # Domain Models (immutable)
│   ├── repositories/             # Repository Interfaces
│   └── usecases/                 # Business Logic
│
├── data/                          # Firebase 의존성 격리
│   ├── dto/                      # Firebase 타입 → DTO
│   ├── mappers/                  # DTO ↔ Domain 변환
│   ├── datasources/              # Remote/Local 분리
│   └── repositories/             # Repository 구현체
│
└── presentation/                  # UI & State Management
    ├── screens/                  # 화면 위젯
    ├── widgets/                  # 재사용 컴포넌트
    └── providers/                # ChangeNotifier 상태 관리
```

### 핵심 원칙
1. **Domain은 Firebase를 모른다** (`DocumentReference`, `Timestamp` 금지)
2. **Either Pattern 사용** (dartz 패키지, Left = Failure, Right = Success)
3. **DataSource 추상화** (Remote/Local 분리, 테스트 가능)
4. **UseCase 단일 책임** (하나의 비즈니스 로직 = 하나의 UseCase)
5. **Provider 상태 관리** (flutter_chat_core는 Adapter로 격리)

---

## 📅 Phase별 상세 계획

### Phase 1: MessagesModel Firebase 격리 (8-12시간) ⚠️ 최우선

**목표**: 674줄, 60+ 필드를 가진 MessagesModel을 Domain Model과 DTO로 분리

#### Step 1.1: DTO 생성 (3-4시간)
```dart
// 📁 lib/features/chat/data/models/message_dto.dart
class MessageDTO {
  // Core Message Fields (10개)
  final String? messageId;
  final String? senderId;
  final String? content;
  final Timestamp? timeStamp;           // Firebase 타입
  final String? messageType;
  final List<String>? readBy;
  final Timestamp? deliveredAt;         // Firebase 타입
  final Timestamp? seenAt;              // Firebase 타입
  final DocumentReference? reference;   // Firebase 타입
  final String? replyToMessageId;

  // Media Fields (10개)
  final String? imageUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? mediaSize;
  final int? mediaWidth;
  final int? mediaHeight;
  final String? fileType;
  final String? fileName;
  final double? videoDuration;
  final String? audioUrl;

  // Vote Fields (20+개)
  final String? votePostId;
  final String? voteTitle;
  final String? voteDescription;
  final String? voteOptionAText;
  final String? voteOptionBText;
  final List<String>? voteOptionAImages;
  final List<String>? voteOptionBImages;
  final Timestamp? voteStartTime;       // Firebase 타입
  final Timestamp? voteEndTime;         // Firebase 타입
  final String? voteStatus;
  final int? votesA;
  final int? votesB;
  final Map<String, dynamic>? voteResults;
  final List<String>? userVotes;
  final String? receiverId;
  final String? cardStatus;
  final double? optionAImageAspectRatio;
  final double? optionBImageAspectRatio;
  final String? layoutType;

  // Metadata Fields (5+개)
  final Map<String, dynamic>? metadata;
  final bool? isDeleted;
  final Timestamp? deletedAt;           // Firebase 타입
  final String? deletedBy;
  final int? editCount;

  // Deprecated Fields (3개) - 하위 호환성
  @Deprecated('Use userVotes instead')
  final bool? userVoted;
  @Deprecated('Use userVotes instead')
  final String? voteChoice;
  @Deprecated('Use userVotes instead')
  final Timestamp? voteParticipatedAt;  // Firebase 타입

  const MessageDTO({
    this.messageId,
    this.senderId,
    this.content,
    // ... 모든 필드
  });

  // Firestore 변환 메서드
  factory MessageDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageDTO(
      messageId: data['messageId'] as String?,
      senderId: data['senderId'] as String?,
      timeStamp: data['timeStamp'] as Timestamp?,
      // ... 60+ 필드 매핑
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'timeStamp': timeStamp,
      // ... 60+ 필드 매핑
    };
  }
}
```

#### Step 1.2: Domain Model 생성 (2-3시간)
```dart
// 📁 lib/features/chat/domain/models/message.dart
class Message {
  // Core Message Fields (순수 Dart 타입)
  final String messageId;
  final String senderId;
  final String content;
  final DateTime timeStamp;             // Dart 타입
  final String messageType;
  final List<String> readBy;
  final DateTime? deliveredAt;          // Dart 타입
  final DateTime? seenAt;               // Dart 타입
  final String? replyToMessageId;

  // Media Fields
  final String? imageUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? mediaSize;
  final int? mediaWidth;
  final int? mediaHeight;
  final String? fileType;
  final String? fileName;
  final double? videoDuration;
  final String? audioUrl;

  // Vote Fields
  final String? votePostId;
  final String? voteTitle;
  final String? voteDescription;
  final String? voteOptionAText;
  final String? voteOptionBText;
  final List<String>? voteOptionAImages;
  final List<String>? voteOptionBImages;
  final DateTime? voteStartTime;        // Dart 타입
  final DateTime? voteEndTime;          // Dart 타입
  final String? voteStatus;
  final int? votesA;
  final int? votesB;
  final Map<String, dynamic>? voteResults;
  final List<String>? userVotes;
  final String? receiverId;
  final String? cardStatus;
  final double? optionAImageAspectRatio;
  final double? optionBImageAspectRatio;
  final String? layoutType;

  // Metadata Fields
  final Map<String, dynamic>? metadata;
  final bool isDeleted;
  final DateTime? deletedAt;            // Dart 타입
  final String? deletedBy;
  final int editCount;

  const Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.timeStamp,
    this.messageType = 'text',
    this.readBy = const [],
    // ... 모든 필드
    this.isDeleted = false,
    this.editCount = 0,
  });

  // copyWith 메서드 (Immutability)
  Message copyWith({
    String? content,
    DateTime? seenAt,
    List<String>? readBy,
    // ... 필요한 필드들
  }) {
    return Message(
      messageId: messageId,
      senderId: senderId,
      content: content ?? this.content,
      timeStamp: timeStamp,
      // ... 모든 필드
    );
  }
}
```

#### Step 1.3: Mapper 생성 (2-3시간)
```dart
// 📁 lib/features/chat/data/mappers/message_mapper.dart
class MessageMapper {
  /// DTO → Domain 변환
  static Message toDomain(MessageDTO dto) {
    return Message(
      messageId: dto.messageId ?? '',
      senderId: dto.senderId ?? '',
      content: dto.content ?? '',
      timeStamp: dto.timeStamp?.toDate() ?? DateTime.now(),
      messageType: dto.messageType ?? 'text',
      readBy: dto.readBy ?? [],
      deliveredAt: dto.deliveredAt?.toDate(),
      seenAt: dto.seenAt?.toDate(),
      replyToMessageId: dto.replyToMessageId,

      // Media Fields
      imageUrl: dto.imageUrl,
      videoUrl: dto.videoUrl,
      thumbnailUrl: dto.thumbnailUrl,
      mediaSize: dto.mediaSize,
      mediaWidth: dto.mediaWidth,
      mediaHeight: dto.mediaHeight,
      fileType: dto.fileType,
      fileName: dto.fileName,
      videoDuration: dto.videoDuration,
      audioUrl: dto.audioUrl,

      // Vote Fields
      votePostId: dto.votePostId,
      voteTitle: dto.voteTitle,
      voteDescription: dto.voteDescription,
      voteOptionAText: dto.voteOptionAText,
      voteOptionBText: dto.voteOptionBText,
      voteOptionAImages: dto.voteOptionAImages,
      voteOptionBImages: dto.voteOptionBImages,
      voteStartTime: dto.voteStartTime?.toDate(),
      voteEndTime: dto.voteEndTime?.toDate(),
      voteStatus: dto.voteStatus,
      votesA: dto.votesA,
      votesB: dto.votesB,
      voteResults: dto.voteResults,
      userVotes: dto.userVotes,
      receiverId: dto.receiverId,
      cardStatus: dto.cardStatus,
      optionAImageAspectRatio: dto.optionAImageAspectRatio,
      optionBImageAspectRatio: dto.optionBImageAspectRatio,
      layoutType: dto.layoutType,

      // Metadata Fields
      metadata: dto.metadata,
      isDeleted: dto.isDeleted ?? false,
      deletedAt: dto.deletedAt?.toDate(),
      deletedBy: dto.deletedBy,
      editCount: dto.editCount ?? 0,
    );
  }

  /// Domain → DTO 변환
  static MessageDTO toDTO(Message domain) {
    return MessageDTO(
      messageId: domain.messageId,
      senderId: domain.senderId,
      content: domain.content,
      timeStamp: Timestamp.fromDate(domain.timeStamp),
      messageType: domain.messageType,
      readBy: domain.readBy,
      deliveredAt: domain.deliveredAt != null
          ? Timestamp.fromDate(domain.deliveredAt!)
          : null,
      seenAt: domain.seenAt != null
          ? Timestamp.fromDate(domain.seenAt!)
          : null,
      replyToMessageId: domain.replyToMessageId,

      // Media Fields
      imageUrl: domain.imageUrl,
      videoUrl: domain.videoUrl,
      thumbnailUrl: domain.thumbnailUrl,
      mediaSize: domain.mediaSize,
      mediaWidth: domain.mediaWidth,
      mediaHeight: domain.mediaHeight,
      fileType: domain.fileType,
      fileName: domain.fileName,
      videoDuration: domain.videoDuration,
      audioUrl: domain.audioUrl,

      // Vote Fields
      votePostId: domain.votePostId,
      voteTitle: domain.voteTitle,
      voteDescription: domain.voteDescription,
      voteOptionAText: domain.voteOptionAText,
      voteOptionBText: domain.voteOptionBText,
      voteOptionAImages: domain.voteOptionAImages,
      voteOptionBImages: domain.voteOptionBImages,
      voteStartTime: domain.voteStartTime != null
          ? Timestamp.fromDate(domain.voteStartTime!)
          : null,
      voteEndTime: domain.voteEndTime != null
          ? Timestamp.fromDate(domain.voteEndTime!)
          : null,
      voteStatus: domain.voteStatus,
      votesA: domain.votesA,
      votesB: domain.votesB,
      voteResults: domain.voteResults,
      userVotes: domain.userVotes,
      receiverId: domain.receiverId,
      cardStatus: domain.cardStatus,
      optionAImageAspectRatio: domain.optionAImageAspectRatio,
      optionBImageAspectRatio: domain.optionBImageAspectRatio,
      layoutType: domain.layoutType,

      // Metadata Fields
      metadata: domain.metadata,
      isDeleted: domain.isDeleted,
      deletedAt: domain.deletedAt != null
          ? Timestamp.fromDate(domain.deletedAt!)
          : null,
      deletedBy: domain.deletedBy,
      editCount: domain.editCount,
    );
  }

  /// DTO List → Domain List 변환 (벌크 처리)
  static List<Message> toDomainList(List<MessageDTO> dtoList) {
    return dtoList.map((dto) => toDomain(dto)).toList();
  }

  /// Domain List → DTO List 변환 (벌크 처리)
  static List<MessageDTO> toDTOList(List<Message> domainList) {
    return domainList.map((domain) => toDTO(domain)).toList();
  }
}
```

#### Step 1.4: 기존 MessagesModel 삭제 준비 (1시간)
```bash
# 1. 의존성 검색
grep -r "MessagesModel" lib/features/chat --include="*.dart"

# 2. 사용처 확인 (예상)
# - chat_repository_impl.dart
# - chat_initialization_service.dart
# - chat_message_service.dart
# - message_to_ui_converter.dart
# - chat_detail_widget_v2.dart
# - ai_chat_page_v2.dart

# 3. 점진적 교체 계획 수립
```

**완료 기준**:
- [x] MessageDTO 클래스 생성 (60+ 필드 모두 매핑)
- [x] Domain Message 클래스 생성 (순수 Dart 타입)
- [x] MessageMapper 양방향 변환 구현
- [x] 기존 MessagesModel 사용처 파악 완료

---

### Phase 2: 나머지 4개 Model Firebase 격리 (4-6시간)

**목표**: ChatsModel, GroupChatsModel, GroupMessagesModel, ChatHistoryModel을 Domain/DTO로 분리

#### 우선순위
1. **ChatsModel** (297줄) - 채팅방 메타데이터, 가장 많이 사용됨
2. **GroupChatsModel** (215줄) - 그룹 채팅방
3. **GroupMessagesModel** (280줄) - 그룹 메시지
4. **ChatHistoryModel** (140줄) - 채팅 히스토리 (필요시)

#### ChatsModel 변환 예시
```dart
// DTO (Firebase 타입)
class ChatDTO {
  final String? chatId;
  final List<String>? participantIds;
  final Timestamp? createdAt;               // Firebase 타입
  final Timestamp? lastMessageAt;           // Firebase 타입
  final DocumentReference? reference;       // Firebase 타입
  final String? lastMessage;
  final String? lastSenderId;
  final int? unreadCount;
  final bool? isGroupChat;
  final String? groupName;
  final String? groupPhotoUrl;
  // ... 기타 필드
}

// Domain Model (순수 Dart 타입)
class Chat {
  final String chatId;
  final List<String> participantIds;
  final DateTime createdAt;                 // Dart 타입
  final DateTime? lastMessageAt;            // Dart 타입
  final String? lastMessage;
  final String? lastSenderId;
  final int unreadCount;
  final bool isGroupChat;
  final String? groupName;
  final String? groupPhotoUrl;
  // ... 기타 필드
}

// Mapper
class ChatMapper {
  static Chat toDomain(ChatDTO dto) { ... }
  static ChatDTO toDTO(Chat domain) { ... }
}
```

**완료 기준**:
- [x] 4개 모델 모두 DTO/Domain/Mapper 생성
- [x] Profile Feature 패턴 일관성 유지
- [x] 하위 호환성 고려 (@Deprecated 어노테이션)

---

### Phase 3: DataSource Layer 생성 (3-5시간)

**목표**: Firebase 직접 호출을 DataSource로 추상화

#### Step 3.1: Interface 정의
```dart
// 📁 lib/features/chat/data/datasources/chat_remote_datasource.dart
abstract class ChatRemoteDataSource {
  /// 채팅방 조회
  Future<ChatDTO?> getChat(String chatId);

  /// 채팅방 목록 스트림
  Stream<List<ChatDTO>> watchChats({
    required List<String> participantIds,
    int? limit,
  });

  /// 채팅방 생성
  Future<void> createChat(ChatDTO chat);

  /// 채팅방 업데이트
  Future<void> updateChat(ChatDTO chat);

  /// 채팅방 삭제
  Future<void> deleteChat(String chatId);

  /// 메시지 조회 (특정 채팅방)
  Future<List<MessageDTO>> getMessages({
    required String chatId,
    int? limit,
    DateTime? before,
  });

  /// 메시지 스트림 (실시간)
  Stream<List<MessageDTO>> watchMessages({
    required String chatId,
    int? limit,
  });

  /// 메시지 전송
  Future<void> sendMessage({
    required String chatId,
    required MessageDTO message,
  });

  /// 메시지 업데이트
  Future<void> updateMessage({
    required String chatId,
    required MessageDTO message,
  });

  /// 메시지 삭제
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  });

  /// 메시지 읽음 처리
  Future<void> markAsRead({
    required String chatId,
    required String messageId,
    required String userId,
  });

  /// 그룹 채팅 관련
  Future<void> createGroupChat(GroupChatDTO group);
  Future<void> addGroupMember(String groupId, String userId);
  Future<void> removeGroupMember(String groupId, String userId);
  Stream<List<GroupMessageDTO>> watchGroupMessages(String groupId);
}
```

#### Step 3.2: Implementation
```dart
// 📁 lib/features/chat/data/datasources/chat_remote_datasource_impl.dart
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ChatDTO?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();

      if (!doc.exists) return null;

      return ChatDTO.fromFirestore(doc);
    } catch (e) {
      throw DataSourceException(
        message: 'Failed to get chat',
        cause: e,
      );
    }
  }

  @override
  Stream<List<ChatDTO>> watchChats({
    required List<String> participantIds,
    int? limit,
  }) {
    try {
      Query query = _firestore
          .collection('chats')
          .where('participantIds', arrayContainsAny: participantIds)
          .orderBy('lastMessageAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatDTO.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw DataSourceException(
        message: 'Failed to watch chats',
        cause: e,
      );
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required MessageDTO message,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. 메시지 추가
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      batch.set(messageRef, message.toFirestore());

      // 2. 채팅방 lastMessage 업데이트
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': message.content,
        'lastSenderId': message.senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw DataSourceException(
        message: 'Failed to send message',
        cause: e,
      );
    }
  }

  // ... 나머지 메서드 구현
}
```

#### Step 3.3: Cache DataSource (선택적)
```dart
// 📁 lib/features/chat/data/datasources/chat_local_datasource.dart
abstract class ChatLocalDataSource {
  Future<List<ChatDTO>> getCachedChats();
  Future<void> cacheChats(List<ChatDTO> chats);
  Future<List<MessageDTO>> getCachedMessages(String chatId);
  Future<void> cacheMessages(String chatId, List<MessageDTO> messages);
  Future<void> clearCache();
}

// Hive 구현체
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box<Map<String, dynamic>> _chatBox;
  final Box<Map<String, dynamic>> _messageBox;

  // UnifiedCacheService와 통합
  final UnifiedCacheService _cacheService;

  // ... 구현
}
```

**완료 기준**:
- [x] ChatRemoteDataSource 인터페이스 정의
- [x] Firebase 구현체 완성
- [x] 에러 처리 및 로깅 추가
- [x] UnifiedCacheService와 통합 (선택적)

---

### Phase 4: Repository Layer 리팩토링 (3-4시간)

**목표**: ChatRepositoryImpl을 DataSource 기반으로 재작성

#### 현재 문제점
```dart
// ❌ 현재: Firebase 직접 호출
class ChatRepositoryImpl implements IChatRepository {
  @override
  Future<ChatsModel?> getChat(String chatId) async {
    final doc = await FirebaseFirestore.instance  // 직접 호출
        .collection('chats')
        .doc(chatId)
        .get();
    return doc.exists ? ChatsModel.fromSnapshot(doc) : null;
  }
}
```

#### 리팩토링 후
```dart
// ✅ 리팩토링 후: DataSource + Mapper 사용
class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource? _localDataSource; // 선택적
  final ChatMapper _chatMapper;
  final MessageMapper _messageMapper;

  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    ChatLocalDataSource? localDataSource,
    ChatMapper? chatMapper,
    MessageMapper? messageMapper,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _chatMapper = chatMapper ?? ChatMapper(),
        _messageMapper = messageMapper ?? MessageMapper();

  @override
  Future<Either<Failure, Chat?>> getChat(String chatId) async {
    try {
      // 1. DataSource에서 DTO 가져오기
      final chatDTO = await _remoteDataSource.getChat(chatId);

      if (chatDTO == null) {
        return const Right(null);
      }

      // 2. DTO → Domain 변환
      final chat = _chatMapper.toDomain(chatDTO);

      return Right(chat);
    } on DataSourceException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Chat>>> watchChats({
    required List<String> participantIds,
    int? limit,
  }) {
    try {
      return _remoteDataSource
          .watchChats(participantIds: participantIds, limit: limit)
          .map((dtoList) {
        // DTO List → Domain List 변환
        final chats = dtoList.map(_chatMapper.toDomain).toList();
        return Right<Failure, List<Chat>>(chats);
      }).handleError((error) {
        if (error is DataSourceException) {
          return Left<Failure, List<Chat>>(
            ServerFailure(message: error.message),
          );
        }
        return Left<Failure, List<Chat>>(
          UnknownFailure(message: error.toString()),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(UnknownFailure(message: e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required Message message,
  }) async {
    try {
      // 1. Domain → DTO 변환
      final messageDTO = _messageMapper.toDTO(message);

      // 2. DataSource로 전송
      await _remoteDataSource.sendMessage(
        chatId: chatId,
        message: messageDTO,
      );

      return const Right(null);
    } on DataSourceException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ... 나머지 메서드 구현
}
```

#### Repository Interface 업데이트
```dart
// 📁 lib/features/chat/domain/repositories/i_chat_repository.dart
abstract class IChatRepository {
  // Either Pattern으로 변경
  Future<Either<Failure, Chat?>> getChat(String chatId);

  Stream<Either<Failure, List<Chat>>> watchChats({
    required List<String> participantIds,
    int? limit,
  });

  Future<Either<Failure, void>> createChat(Chat chat);
  Future<Either<Failure, void>> updateChat(Chat chat);
  Future<Either<Failure, void>> deleteChat(String chatId);

  // Message 관련
  Future<Either<Failure, List<Message>>> getMessages({
    required String chatId,
    int? limit,
    DateTime? before,
  });

  Stream<Either<Failure, List<Message>>> watchMessages({
    required String chatId,
    int? limit,
  });

  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required Message message,
  });

  Future<Either<Failure, void>> updateMessage({
    required String chatId,
    required Message message,
  });

  Future<Either<Failure, void>> deleteMessage({
    required String chatId,
    required String messageId,
  });

  Future<Either<Failure, void>> markAsRead({
    required String chatId,
    required String messageId,
    required String userId,
  });
}
```

**완료 기준**:
- [x] IChatRepository Either Pattern 적용
- [x] ChatRepositoryImpl DataSource 기반 재작성
- [x] Singleton 패턴 제거
- [x] DI (Dependency Injection) 준비 완료

---

### Phase 5: UseCase Layer 생성 (4-6시간)

**목표**: 비즈니스 로직을 UseCase로 추출

#### 필수 UseCases
```dart
// 📁 lib/features/chat/domain/usecases/chat/

// 1. GetChatUseCase - 채팅방 조회
class GetChatUseCase {
  final IChatRepository _repository;

  GetChatUseCase(this._repository);

  Future<Either<Failure, Chat?>> execute({
    required String chatId,
  }) async {
    return await _repository.getChat(chatId);
  }
}

// 2. WatchChatsUseCase - 채팅방 목록 실시간 감시
class WatchChatsUseCase {
  final IChatRepository _repository;

  WatchChatsUseCase(this._repository);

  Stream<Either<Failure, List<Chat>>> execute({
    required List<String> participantIds,
    int? limit,
  }) {
    return _repository.watchChats(
      participantIds: participantIds,
      limit: limit,
    );
  }
}

// 3. CreateChatUseCase - 채팅방 생성
class CreateChatUseCase {
  final IChatRepository _repository;

  CreateChatUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required Chat chat,
  }) async {
    // 비즈니스 로직: 중복 채팅방 체크
    final existingChat = await _repository.getChat(chat.chatId);

    return existingChat.fold(
      (failure) => Left(failure),
      (existing) {
        if (existing != null) {
          return Left(ValidationFailure(
            message: 'Chat already exists',
          ));
        }
        return _repository.createChat(chat);
      },
    );
  }
}

// 4. SendMessageUseCase - 메시지 전송
class SendMessageUseCase {
  final IChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String chatId,
    required Message message,
  }) async {
    // 비즈니스 로직: 메시지 유효성 검증
    if (message.content.trim().isEmpty &&
        message.imageUrl == null &&
        message.videoUrl == null) {
      return Left(ValidationFailure(
        message: 'Message content cannot be empty',
      ));
    }

    // 비즈니스 로직: 메시지 길이 제한 (예: 5000자)
    if (message.content.length > 5000) {
      return Left(ValidationFailure(
        message: 'Message too long (max 5000 characters)',
      ));
    }

    return await _repository.sendMessage(
      chatId: chatId,
      message: message,
    );
  }
}

// 5. GetMessagesUseCase - 메시지 목록 조회
class GetMessagesUseCase {
  final IChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<Either<Failure, List<Message>>> execute({
    required String chatId,
    int? limit = 30,
    DateTime? before,
  }) async {
    return await _repository.getMessages(
      chatId: chatId,
      limit: limit,
      before: before,
    );
  }
}

// 6. WatchMessagesUseCase - 메시지 실시간 감시
class WatchMessagesUseCase {
  final IChatRepository _repository;

  WatchMessagesUseCase(this._repository);

  Stream<Either<Failure, List<Message>>> execute({
    required String chatId,
    int? limit = 50,
  }) {
    return _repository.watchMessages(
      chatId: chatId,
      limit: limit,
    );
  }
}

// 7. MarkAsReadUseCase - 메시지 읽음 처리
class MarkAsReadUseCase {
  final IChatRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    return await _repository.markAsRead(
      chatId: chatId,
      messageId: messageId,
      userId: userId,
    );
  }
}

// 8. DeleteMessageUseCase - 메시지 삭제
class DeleteMessageUseCase {
  final IChatRepository _repository;

  DeleteMessageUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    // 비즈니스 로직: 권한 체크 (메시지 작성자만 삭제 가능)
    final messagesResult = await _repository.getMessages(
      chatId: chatId,
      limit: 1,
    );

    return messagesResult.fold(
      (failure) => Left(failure),
      (messages) {
        final message = messages.firstWhere(
          (m) => m.messageId == messageId,
          orElse: () => throw Exception('Message not found'),
        );

        if (message.senderId != userId) {
          return Left(PermissionFailure(
            message: 'You can only delete your own messages',
          ));
        }

        return _repository.deleteMessage(
          chatId: chatId,
          messageId: messageId,
        );
      },
    );
  }
}
```

#### 고급 UseCases (선택적)
```dart
// 9. SearchMessagesUseCase - 메시지 검색
class SearchMessagesUseCase {
  final IChatRepository _repository;

  SearchMessagesUseCase(this._repository);

  Future<Either<Failure, List<Message>>> execute({
    required String chatId,
    required String query,
  }) async {
    // 비즈니스 로직: 검색어 유효성 검증
    if (query.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Search query cannot be empty',
      ));
    }

    final messagesResult = await _repository.getMessages(
      chatId: chatId,
      limit: null, // 전체 메시지
    );

    return messagesResult.fold(
      (failure) => Left(failure),
      (messages) {
        // 비즈니스 로직: 로컬 검색 (대소문자 무시)
        final filtered = messages.where((message) {
          return message.content
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();

        return Right(filtered);
      },
    );
  }
}

// 10. GetUnreadCountUseCase - 읽지 않은 메시지 수 조회
class GetUnreadCountUseCase {
  final IChatRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<Either<Failure, int>> execute({
    required String chatId,
    required String userId,
  }) async {
    final messagesResult = await _repository.getMessages(
      chatId: chatId,
      limit: null,
    );

    return messagesResult.fold(
      (failure) => Left(failure),
      (messages) {
        // 비즈니스 로직: 읽지 않은 메시지 개수 계산
        final unreadCount = messages.where((message) {
          return message.senderId != userId &&
                 !message.readBy.contains(userId);
        }).length;

        return Right(unreadCount);
      },
    );
  }
}
```

**완료 기준**:
- [x] 10개 핵심 UseCases 생성
- [x] 비즈니스 로직 검증 (유효성, 권한, 중복 체크)
- [x] Either Pattern 일관성 유지
- [x] 단위 테스트 작성 (선택적)

---

### Phase 6: Presentation Layer 리팩토링 (6-8시간)

**목표**: flutter_chat_core를 격리하고 Provider 패턴 적용

#### Step 6.1: ChatProvider 생성
```dart
// 📁 lib/features/chat/presentation/providers/chat_provider.dart
class ChatProvider extends ChangeNotifier {
  final GetChatUseCase _getChatUseCase;
  final WatchChatsUseCase _watchChatsUseCase;
  final CreateChatUseCase _createChatUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final WatchMessagesUseCase _watchMessagesUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;

  // State
  Chat? _currentChat;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Either<Failure, List<Message>>>? _messageSubscription;

  // Getters
  Chat? get currentChat => _currentChat;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatProvider({
    required GetChatUseCase getChatUseCase,
    required WatchChatsUseCase watchChatsUseCase,
    required CreateChatUseCase createChatUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required WatchMessagesUseCase watchMessagesUseCase,
    required MarkAsReadUseCase markAsReadUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
  })  : _getChatUseCase = getChatUseCase,
        _watchChatsUseCase = watchChatsUseCase,
        _createChatUseCase = createChatUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _watchMessagesUseCase = watchMessagesUseCase,
        _markAsReadUseCase = markAsReadUseCase,
        _deleteMessageUseCase = deleteMessageUseCase;

  /// 채팅방 로드
  Future<void> loadChat(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getChatUseCase.execute(chatId: chatId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _currentChat = null;
      },
      (chat) {
        _currentChat = chat;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 메시지 실시간 감시 시작
  void startWatchingMessages(String chatId) {
    _messageSubscription?.cancel();

    _messageSubscription = _watchMessagesUseCase
        .execute(chatId: chatId)
        .listen((result) {
      result.fold(
        (failure) {
          _errorMessage = failure.getUserMessage();
          notifyListeners();
        },
        (messages) {
          _messages = messages;
          _errorMessage = null;
          notifyListeners();
        },
      );
    });
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required String chatId,
    required Message message,
  }) async {
    final result = await _sendMessageUseCase.execute(
      chatId: chatId,
      message: message,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        notifyListeners();
      },
      (_) {
        // 성공 - 메시지는 스트림으로 자동 업데이트됨
        _errorMessage = null;
      },
    );
  }

  /// 메시지 읽음 처리
  Future<void> markAsRead({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    final result = await _markAsReadUseCase.execute(
      chatId: chatId,
      messageId: messageId,
      userId: userId,
    );

    result.fold(
      (failure) {
        // 읽음 처리 실패는 무시 (UX에 영향 없음)
        debugPrint('Failed to mark as read: ${failure.getUserMessage()}');
      },
      (_) {
        // 성공 - 메시지는 스트림으로 자동 업데이트됨
      },
    );
  }

  /// 메시지 삭제
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    final result = await _deleteMessageUseCase.execute(
      chatId: chatId,
      messageId: messageId,
      userId: userId,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        notifyListeners();
      },
      (_) {
        // 성공 - 메시지는 스트림으로 자동 업데이트됨
        _errorMessage = null;
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
```

#### Step 6.2: flutter_chat_core Adapter 생성
```dart
// 📁 lib/features/chat/presentation/adapters/chat_ui_adapter.dart
/// flutter_chat_core와 Domain Message 간 변환 Adapter
class ChatUIAdapter {
  /// Domain Message → flutter_chat_core Message 변환
  static core.Message toCoreMessage(Message domainMessage) {
    // 메시지 타입 판단
    if (domainMessage.imageUrl != null) {
      return core.ImageMessage(
        id: domainMessage.messageId,
        author: core.User(id: domainMessage.senderId),
        createdAt: domainMessage.timeStamp.millisecondsSinceEpoch,
        uri: domainMessage.imageUrl!,
        size: domainMessage.mediaSize ?? 0,
        width: domainMessage.mediaWidth?.toDouble(),
        height: domainMessage.mediaHeight?.toDouble(),
      );
    } else if (domainMessage.videoUrl != null) {
      return core.VideoMessage(
        id: domainMessage.messageId,
        author: core.User(id: domainMessage.senderId),
        createdAt: domainMessage.timeStamp.millisecondsSinceEpoch,
        uri: domainMessage.videoUrl!,
        size: domainMessage.mediaSize ?? 0,
        width: domainMessage.mediaWidth?.toDouble(),
        height: domainMessage.mediaHeight?.toDouble(),
      );
    } else if (domainMessage.votePostId != null) {
      // 투표 메시지 → CustomMessage
      return core.CustomMessage(
        id: domainMessage.messageId,
        author: core.User(id: domainMessage.senderId),
        createdAt: domainMessage.timeStamp.millisecondsSinceEpoch,
        metadata: {
          'type': 'vote',
          'votePostId': domainMessage.votePostId,
          'voteTitle': domainMessage.voteTitle,
          'voteDescription': domainMessage.voteDescription,
          'voteOptionAText': domainMessage.voteOptionAText,
          'voteOptionBText': domainMessage.voteOptionBText,
          'voteOptionAImages': domainMessage.voteOptionAImages,
          'voteOptionBImages': domainMessage.voteOptionBImages,
          'voteStartTime': domainMessage.voteStartTime?.toIso8601String(),
          'voteEndTime': domainMessage.voteEndTime?.toIso8601String(),
          'voteStatus': domainMessage.voteStatus,
          'votesA': domainMessage.votesA,
          'votesB': domainMessage.votesB,
          'cardStatus': domainMessage.cardStatus,
        },
      );
    } else {
      // 텍스트 메시지
      return core.TextMessage(
        id: domainMessage.messageId,
        author: core.User(id: domainMessage.senderId),
        createdAt: domainMessage.timeStamp.millisecondsSinceEpoch,
        text: domainMessage.content,
      );
    }
  }

  /// flutter_chat_core Message → Domain Message 변환
  static Message toDomainMessage(core.Message coreMessage) {
    // 공통 필드
    final baseData = {
      'messageId': coreMessage.id,
      'senderId': coreMessage.author.id,
      'timeStamp': DateTime.fromMillisecondsSinceEpoch(
        coreMessage.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      ),
    };

    // 타입별 처리
    if (coreMessage is core.TextMessage) {
      return Message(
        ...baseData,
        content: coreMessage.text,
        messageType: 'text',
      );
    } else if (coreMessage is core.ImageMessage) {
      return Message(
        ...baseData,
        content: '',
        messageType: 'image',
        imageUrl: coreMessage.uri,
        mediaSize: coreMessage.size,
        mediaWidth: coreMessage.width?.toInt(),
        mediaHeight: coreMessage.height?.toInt(),
      );
    } else if (coreMessage is core.VideoMessage) {
      return Message(
        ...baseData,
        content: '',
        messageType: 'video',
        videoUrl: coreMessage.uri,
        mediaSize: coreMessage.size,
        mediaWidth: coreMessage.width?.toInt(),
        mediaHeight: coreMessage.height?.toInt(),
      );
    } else if (coreMessage is core.CustomMessage) {
      // 투표 메시지 처리
      if (coreMessage.metadata?['type'] == 'vote') {
        return Message(
          ...baseData,
          content: '',
          messageType: 'vote',
          votePostId: coreMessage.metadata?['votePostId'],
          voteTitle: coreMessage.metadata?['voteTitle'],
          voteDescription: coreMessage.metadata?['voteDescription'],
          voteOptionAText: coreMessage.metadata?['voteOptionAText'],
          voteOptionBText: coreMessage.metadata?['voteOptionBText'],
          voteOptionAImages: List<String>.from(
            coreMessage.metadata?['voteOptionAImages'] ?? [],
          ),
          voteOptionBImages: List<String>.from(
            coreMessage.metadata?['voteOptionBImages'] ?? [],
          ),
          voteStartTime: coreMessage.metadata?['voteStartTime'] != null
              ? DateTime.parse(coreMessage.metadata!['voteStartTime'])
              : null,
          voteEndTime: coreMessage.metadata?['voteEndTime'] != null
              ? DateTime.parse(coreMessage.metadata!['voteEndTime'])
              : null,
          voteStatus: coreMessage.metadata?['voteStatus'],
          votesA: coreMessage.metadata?['votesA'],
          votesB: coreMessage.metadata?['votesB'],
          cardStatus: coreMessage.metadata?['cardStatus'],
        );
      }
    }

    // Fallback
    return Message(
      ...baseData,
      content: '',
      messageType: 'unknown',
    );
  }

  /// Domain Message List → flutter_chat_core Message List 변환
  static List<core.Message> toCoreMessageList(List<Message> domainMessages) {
    return domainMessages.map((m) => toCoreMessage(m)).toList();
  }

  /// flutter_chat_core Message List → Domain Message List 변환
  static List<Message> toDomainMessageList(List<core.Message> coreMessages) {
    return coreMessages.map((m) => toDomainMessage(m)).toList();
  }
}
```

#### Step 6.3: ChatDetailWidgetV2 리팩토링
```dart
// 📁 lib/features/chat/presentation/screens/chat_detail_v2/chat_detail_widget_v2.dart
class ChatDetailWidgetV2 extends StatefulWidget {
  final String chatId;

  const ChatDetailWidgetV2({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatDetailWidgetV2> createState() => _ChatDetailWidgetV2State();
}

class _ChatDetailWidgetV2State extends State<ChatDetailWidgetV2> {
  late ChatProvider _chatProvider;
  late ChatDetailControllerV2 _controller;

  @override
  void initState() {
    super.initState();

    // Provider 초기화
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _controller = ChatDetailControllerV2();

    // 채팅방 로드 및 메시지 감시 시작
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _chatProvider.loadChat(widget.chatId);
    _chatProvider.startWatchingMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            final chat = provider.currentChat;
            return Text(chat?.groupName ?? 'Chat');
          },
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text('Error: ${provider.errorMessage}'),
            );
          }

          // Domain Messages → flutter_chat_core Messages 변환
          final coreMessages = ChatUIAdapter.toCoreMessageList(
            provider.messages,
          );

          // Controller에 메시지 로드
          _controller.loadInitialMessages(coreMessages);

          return core.Chat(
            messages: coreMessages,
            onSendPressed: _handleSendPressed,
            onMessageTap: _handleMessageTap,
            // ... 기타 설정
          );
        },
      ),
    );
  }

  void _handleSendPressed(core.PartialText message) async {
    // 현재 사용자 ID 가져오기
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Domain Message 생성
    final domainMessage = Message(
      messageId: const Uuid().v4(),
      senderId: currentUserId,
      content: message.text,
      timeStamp: DateTime.now(),
      messageType: 'text',
      readBy: [],
    );

    // Provider를 통해 전송
    await _chatProvider.sendMessage(
      chatId: widget.chatId,
      message: domainMessage,
    );
  }

  void _handleMessageTap(core.Message message) {
    // 메시지 읽음 처리
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    _chatProvider.markAsRead(
      chatId: widget.chatId,
      messageId: message.id,
      userId: currentUserId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**완료 기준**:
- [x] ChatProvider 생성 (8개 UseCases 통합)
- [x] ChatUIAdapter 생성 (flutter_chat_core 격리)
- [x] ChatDetailWidgetV2 리팩토링 (Provider 패턴)
- [x] AIChatPageV2 리팩토링 (동일 패턴)
- [x] flutter_chat_core 의존성 격리 완료

---

## 🚨 리스크 관리

### 1. MessagesModel 복잡도 (High Risk)
**문제**: 674줄, 60+ 필드로 인한 높은 마이그레이션 복잡도

**완화 전략**:
- ✅ 필드를 카테고리별로 그룹화 (Core, Media, Vote, Metadata)
- ✅ 점진적 마이그레이션 (Core → Media → Vote → Metadata)
- ✅ 하위 호환성 유지 (@Deprecated 어노테이션)
- ✅ 충분한 테스트 시간 확보 (Phase 1에 8-12시간 할당)

### 2. flutter_chat_core 의존성 (Medium Risk)
**문제**: 외부 패키지와의 타입 충돌 가능성

**완화 전략**:
- ✅ Adapter Pattern으로 격리
- ✅ Domain Message와 core.Message 분리 유지
- ✅ 변환 로직 중앙화 (ChatUIAdapter)
- ✅ 테스트 케이스 작성 (변환 정확성 검증)

### 3. 캐싱 시스템 통합 (Medium Risk)
**문제**: UnifiedCacheService와의 통합 복잡도

**완화 전략**:
- ✅ Phase 3에서 선택적으로 구현
- ✅ ChatLocalDataSource 인터페이스로 추상화
- ✅ Profile Feature 패턴 재사용
- ✅ 캐시 없이도 작동하도록 설계

### 4. 빌드 에러 누적 (Medium Risk)
**문제**: 마이그레이션 중 앱 빌드 실패 가능성

**완화 전략**:
- ✅ Phase별 점진적 마이그레이션
- ✅ Backward compatibility 유지
- ✅ 각 Phase 완료 후 빌드 검증
- ✅ Git 커밋으로 안전한 롤백 지점 확보

### 5. adapter 디렉토리 혼란 (Low Risk)
**문제**: 9개 파일이 data/adapters에 있지만 실제로는 services

**완화 전략**:
- ✅ Phase 7에서 디렉토리 재구성
- ✅ 파일 이동 전 의존성 분석
- ✅ Import 경로 일괄 업데이트

---

## ✅ 검증 체크리스트

### Phase 1 완료 기준
- [ ] MessageDTO 클래스 생성 (60+ 필드)
- [ ] Domain Message 클래스 생성 (순수 Dart)
- [ ] MessageMapper 양방향 변환 구현
- [ ] 단위 테스트 작성 (Mapper 정확성)
- [ ] 기존 MessagesModel 사용처 파악 완료
- [ ] 빌드 에러 없음

### Phase 2 완료 기준
- [ ] 4개 모델 DTO/Domain/Mapper 생성
- [ ] Profile Feature 패턴 일관성 유지
- [ ] 하위 호환성 검증
- [ ] 빌드 에러 없음

### Phase 3 완료 기준
- [ ] ChatRemoteDataSource 인터페이스 정의
- [ ] Firebase 구현체 완성
- [ ] ChatLocalDataSource 구현 (선택적)
- [ ] 에러 처리 및 로깅 추가
- [ ] UnifiedCacheService 통합 (선택적)
- [ ] 빌드 에러 없음

### Phase 4 완료 기준
- [ ] IChatRepository Either Pattern 적용
- [ ] ChatRepositoryImpl DataSource 기반 재작성
- [ ] Singleton 패턴 제거
- [ ] DI 준비 완료
- [ ] 빌드 에러 없음

### Phase 5 완료 기준
- [ ] 10개 핵심 UseCases 생성
- [ ] 비즈니스 로직 검증 추가
- [ ] Either Pattern 일관성 유지
- [ ] 단위 테스트 작성 (선택적)
- [ ] 빌드 에러 없음

### Phase 6 완료 기준
- [ ] ChatProvider 생성 (ChangeNotifier)
- [ ] ChatUIAdapter 생성 (flutter_chat_core 격리)
- [ ] ChatDetailWidgetV2 리팩토링 완료
- [ ] AIChatPageV2 리팩토링 완료
- [ ] 기능 테스트 통과 (메시지 송수신, 실시간 업데이트)
- [ ] 빌드 에러 없음

### Phase 7 완료 기준 (선택적)
- [ ] adapters → services 디렉토리 이동
- [ ] Import 경로 업데이트 완료
- [ ] 백업 파일 삭제
- [ ] 빈 README 정리
- [ ] 디렉토리 구조 문서 업데이트
- [ ] 빌드 에러 없음

### 최종 검증
- [ ] 앱 빌드 성공 (iOS, Android)
- [ ] 채팅 기능 완전 작동
  - [ ] 채팅방 목록 표시
  - [ ] 메시지 전송
  - [ ] 메시지 수신 (실시간)
  - [ ] 메시지 삭제
  - [ ] 읽음 처리
  - [ ] 투표 카드 표시
  - [ ] 이미지/비디오 메시지
- [ ] 캐싱 시스템 작동 (선택적)
- [ ] Profile Feature와 패턴 일관성 유지
- [ ] Clean Architecture 100% 준수
- [ ] Git 커밋 완료
- [ ] README.md 업데이트

---

## 📚 참고 자료

### 내부 문서
- `/lib/features/profile/MIGRATION_PLAN.md` - Profile Feature 마이그레이션 사례
- `/lib/features/profile/README.md` - Clean Architecture v4.0 패턴
- `/lib/features/chat/README.md` - Chat Feature 현황
- `/CLAUDE.md` - 프로젝트 전체 구조

### 외부 참조
- [dartz 패키지](https://pub.dev/packages/dartz) - Either Pattern
- [flutter_chat_ui](https://pub.dev/packages/flutter_chat_ui) - Chat UI 패키지
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)

### Profile Feature 패턴 예시
```dart
// Profile Feature의 UserProfile 구조 (참고용)
Domain Model:
  - lib/features/profile/domain/models/user_profile.dart (순수 Dart)

DTO:
  - lib/features/profile/data/dto/user_profile_dto.dart (Firebase 타입)

Mapper:
  - lib/features/profile/data/mappers/user_profile_mapper.dart

DataSource:
  - lib/features/profile/data/datasources/profile_remote_datasource.dart
  - lib/features/profile/data/datasources/profile_remote_datasource_impl.dart

Repository:
  - lib/features/profile/domain/repositories/i_user_repository.dart (인터페이스)
  - lib/features/profile/data/repositories/user_repository_impl.dart (구현체)

UseCases:
  - lib/features/profile/domain/usecases/profile/get_user_profile_usecase.dart
  - lib/features/profile/domain/usecases/profile/update_user_profile_usecase.dart

Provider:
  - lib/features/profile/presentation/providers/profile_provider.dart
```

---

## 📈 진행 상황 추적

| Phase | 설명 | 예상 시간 | 실제 시간 | 상태 |
|-------|------|-----------|-----------|------|
| Phase 1 | MessagesModel Firebase 격리 | 8-12h | - | ⏳ Pending |
| Phase 2 | 나머지 4개 Model 격리 | 4-6h | - | ⏳ Pending |
| Phase 3 | DataSource Layer 생성 | 3-5h | - | ⏳ Pending |
| Phase 4 | Repository Layer 리팩토링 | 3-4h | - | ⏳ Pending |
| Phase 5 | UseCase Layer 생성 | 4-6h | - | ⏳ Pending |
| Phase 6 | Presentation Layer 리팩토링 | 6-8h | - | ⏳ Pending |
| Phase 7 | 디렉토리 정리 (선택적) | 2h | - | ⏳ Pending |
| **총합** | | **30-43h** | **0h** | **0%** |

**범례**:
- ⏳ Pending - 시작 전
- 🔄 In Progress - 진행 중
- ✅ Complete - 완료
- ⚠️ Blocked - 블로킹 이슈

---

## 🎯 다음 액션 아이템

### 즉시 시작 가능:
1. **Phase 1.1 시작**: MessageDTO 클래스 생성 (3-4시간)
   - 파일 생성: `/lib/features/chat/data/models/message_dto.dart`
   - 60+ 필드 정의 및 Firestore 변환 메서드 구현

2. **백업 파일 정리** (선택적, 5분):
   ```bash
   rm lib/features/chat/data/adapters/message_to_ui_converter_backup.dart
   ```

3. **빈 README 삭제** (선택적, 5분):
   ```bash
   rm lib/features/chat/domain/usecases/README.md
   rm lib/features/chat/data/datasources/README.md
   rm lib/features/chat/presentation/providers/README.md
   rm lib/features/chat/presentation/widgets/README.md
   ```

---

**마이그레이션 시작 준비 완료!** 🚀
