# Notifications Domain Layer - Clean Architecture v4.0

> **Last Updated**: 2025-11-01
> **Architecture**: Clean Architecture v4.0 - Domain Layer
> **Pattern**: Repository Pattern + UseCase Pattern + Extension Pattern + Value Object Pattern
> **Dependencies**: Pure Dart (No Flutter/Firebase)

## Overview

**Notifications Domain Layer**는 알림 Feature의 핵심 비즈니스 로직과 규칙을 정의하는 순수 Dart 레이어입니다. Clean Architecture v4.0의 가장 안쪽 원으로, 외부 의존성이 전혀 없으며 프레임워크에 독립적입니다.

### Core Principles

1. **Framework Independence**: Flutter, Firebase 등 외부 프레임워크 의존성 제거
2. **Testability**: 모든 비즈니스 로직은 단위 테스트 가능
3. **Immutability**: Freezed를 통한 불변 엔티티 설계
4. **Type Safety**: Either 패턴으로 타입 안전한 에러 처리
5. **Single Responsibility**: UseCase 패턴으로 단일 책임 원칙 준수
6. **Dependency Inversion**: Repository 인터페이스로 의존성 역전
7. **Extension Pattern**: Entity ↔ Firestore 변환을 Extension 메서드로 구현
8. **Value Object Pattern**: NotificationFilter로 복잡한 쿼리 로직 캡슐화

### Domain Layer vs Data Layer

| Aspect | Domain Layer | Data Layer |
|--------|-------------|------------|
| **Purpose** | 비즈니스 개념 정의 | 구체적 구현 |
| **Dependencies** | Pure Dart only | Firebase, UnifiedCacheService |
| **Entities** | Domain models (Freezed) | Extensions, Services |
| **Repositories** | Interfaces (abstract) | Implementations |
| **Focus** | What & Why | How |
| **Testing** | Unit tests (fast) | Integration tests (slow) |
| **Architecture** | Clean Architecture v4.0 | Firebase-Centric v2.0 |

---

## Directory Structure (19 files)

```
domain/
├── entities/                                    # Domain entities (1 main + 4 extensions)
│   ├── notification.dart                        # 246 lines - Freezed Sealed Union (3 types)
│   ├── notification.freezed.dart                # Generated
│   ├── notification.g.dart                      # Generated
│   ├── notification_extensions.dart             # 169 lines - 기본 10 필드 변환
│   ├── social_notification_extensions.dart      # 142 lines - Social +8 필드 변환
│   ├── system_notification_extensions.dart      # 161 lines - System +6 필드 변환
│   └── voting_notification_extensions.dart      # 233 lines - Voting +20 필드 변환
│
├── failures/
│   └── notification_failure.dart                # 138 lines - 15 error types
│
├── repositories/
│   └── i_notification_repository.dart           # 166 lines - Repository interface (25+ methods)
│
├── services/
│   └── i_notification_service.dart              # 47 lines - Service interface (8 methods)
│
├── value_objects/
│   └── notification_filter.dart                 # 130 lines - Filter + 4 factories + SortOrder enum
│
└── usecases/                                    # Business logic (5 usecases + 3 base classes)
    ├── base/
    │   ├── use_case.dart                        # 17 lines - Base UseCase abstraction
    │   ├── stream_use_case.dart                 # 6 lines - Stream UseCase abstraction
    │   └── no_param_use_case.dart               # 13 lines - No-param UseCase abstraction
    ├── send_notification_usecase.dart           # 97 lines - Send notification
    ├── get_user_notifications_usecase.dart      # 97 lines - Fetch notifications
    ├── mark_as_read_usecase.dart                # 69 lines - Mark as read
    ├── watch_user_notifications_usecase.dart    # 46 lines - Real-time stream
    └── watch_unread_count_usecase.dart          # 26 lines - Unread count stream
```

**Total**: 19 main files + 2 generated files = **21 files**, **2,651 lines**

---

## entities/ - Domain Entities Deep Dive

Domain entities는 비즈니스 개념을 표현하는 불변 객체입니다. Notifications Feature는 **Freezed Sealed Union** 패턴을 사용하여 3가지 알림 타입을 단일 엔티티로 표현합니다.

### 1. Notification Entity (notification.dart) - Freezed Sealed Union

**Purpose**: 3가지 알림 타입을 타입 안전하게 표현하는 핵심 엔티티

```dart
@freezed
sealed class Notification with _$Notification {
  const Notification._();  // Private constructor for custom getters

  // ===== Social Notification (18 fields total) =====
  const factory Notification.social({
    // 기본 필드 (10개)
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? readAt,
    required bool isRead,
    DateTime? expiryTime,
    @Default({}) Map<String, dynamic> metadata,

    // Social 전용 필드 (8개)
    required SocialActionType actionType,       // like, comment, follow 등
    required String fromUserId,
    required String fromUserName,
    String? fromUserProfileUrl,
    String? relatedPostId,
    String? relatedCommentId,
    String? relatedContent,
    int? interactionCount,
  }) = SocialNotification;

  // ===== System Notification (16 fields total) =====
  const factory Notification.system({
    // 기본 필드 (10개)
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? readAt,
    required bool isRead,
    DateTime? expiryTime,
    @Default({}) Map<String, dynamic> metadata,

    // System 전용 필드 (6개)
    required SystemAlertType alertType,         // critical, security, maintenance 등
    String? actionUrl,
    String? actionLabel,
    Map<String, String>? actionButtons,
    String? iconUrl,
    @Default(true) bool isDismissible,
  }) = SystemNotification;

  // ===== Voting Notification (30 fields total) =====
  const factory Notification.voting({
    // 기본 필드 (10개)
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? readAt,
    required bool isRead,
    DateTime? expiryTime,
    @Default({}) Map<String, dynamic> metadata,

    // Voting 전용 필드 (20개)
    required String postId,
    required String postTitle,
    required String postContent,
    String? postDescription,
    required DateTime voteStartTime,
    required DateTime voteEndTime,
    String? targetAudience,
    int? currentVotesA,
    int? currentVotesB,
    @Default(false) bool hasVoted,
    String? userVoteChoice,
    String? senderId,
    String? senderName,
    String? body,
    @JsonKey(fromJson: NotificationPriority.fromJson)
    @Default(NotificationPriority.medium)
    NotificationPriority notificationPriority,
    @Default([]) List<String> imageUrlsA,
    @Default([]) List<String> imageUrlsB,
    double? aspectRatioA,
    double? aspectRatioB,
    String? layoutType,
  }) = VotingNotification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  // ========== 공통 비즈니스 로직 (모든 타입에 적용) ==========

  /// 알림이 만료되었는지 확인
  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  /// 알림을 읽을 수 있는지 확인
  bool get canBeRead => !isRead && !isExpired;

  /// 알림이 자동 삭제되어야 하는지 확인 (30일 이상)
  bool get shouldAutoDelete {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation > 30;
  }

  /// 알림의 나이 (생성 후 경과 시간)
  Duration get age => DateTime.now().difference(createdAt);

  /// 알림이 최근 것인지 확인 (24시간 이내)
  bool get isRecent => age.inHours < 24;

  /// 알림이 오래된 것인지 확인 (7일 이상)
  bool get isOld => age.inDays >= 7;

  /// 알림의 우선순위 계산 (타입별로 다름)
  int get priority {
    return when(
      social: (...) => isRead ? 0 : 1,
      system: (...) {
        if (!isRead) {
          switch (alertType) {
            case SystemAlertType.critical: return 5;
            case SystemAlertType.security: return 4;
            case SystemAlertType.maintenance: return 3;
            case SystemAlertType.update: return 2;
            case SystemAlertType.info: return 1;
          }
        }
        return 0;
      },
      voting: (...) {
        // 투표 요청이면서 읽지 않은 경우 가장 높은 우선순위
        if (!isRead && (expiryTime == null || !DateTime.now().isAfter(expiryTime))) {
          return 3;
        }
        return 0;
      },
    );
  }
}
```

**Key Features**:
- ✅ **Sealed Union**: 3가지 타입을 타입 안전하게 표현
- ✅ **Exhaustive Pattern Matching**: when() 메서드로 모든 케이스 처리
- ✅ **Type-Specific Fields**: 각 타입마다 고유한 필드 (8, 6, 20개)
- ✅ **Rich Business Logic**: 7+ getter methods (isExpired, canBeRead, priority 등)
- ✅ **Immutability**: Freezed로 불변성 보장
- ✅ **JSON Serialization**: fromJson/toJson 자동 생성

### 2. Enums for Type Safety

#### SocialActionType (7 values)

```dart
enum SocialActionType {
  like('like'),
  comment('comment'),
  friendRequest('friend_request'),
  friendAccepted('friend_accepted'),
  follow('follow'),
  mention('mention'),
  share('share');

  final String value;
  const SocialActionType(this.value);

  static SocialActionType fromString(String value) {
    return SocialActionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SocialActionType.like,
    );
  }
}
```

#### SystemAlertType (5 values)

```dart
enum SystemAlertType {
  critical('critical'),     // 중요 시스템 알림
  security('security'),     // 보안 관련 알림
  maintenance('maintenance'), // 점검 알림
  update('update'),         // 업데이트 알림
  info('info');            // 일반 정보

  final String value;
  const SystemAlertType(this.value);

  static SystemAlertType fromString(String value) {
    return SystemAlertType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SystemAlertType.info,
    );
  }
}
```

#### NotificationStatus (6 values)

```dart
enum NotificationStatus {
  pending('pending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed'),
  expired('expired');

  final String value;
  const NotificationStatus(this.value);

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NotificationStatus.pending,
    );
  }
}
```

### 3. Extension Pattern (Type-Specific) - 4 Files, 705 Lines Total

Notifications Feature의 **고유한 특징**: 각 알림 타입마다 별도의 Extension 파일을 사용하여 Firestore 변환을 구현합니다.

#### notification_extensions.dart (169 lines) - 기본 10 필드

**Purpose**: 모든 알림 타입에 공통인 기본 10 필드 변환

```dart
/// Notification Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - DataSource/DTO/Mapper 제거로 코드 간소화
extension NotificationFirestore on Notification {
  /// Notification Entity → Firestore Map
  ///
  /// **기본 필드 (10개)**:
  /// - id, userId, type, title, content (5개)
  /// - createdAt, readAt, isRead, expiryTime, metadata (5개)
  static Notification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final type = data['type'] as String? ?? '';

    // 타입별 Extension 호출
    switch (type) {
      case 'social':
        return SocialNotificationFirestore.fromFirestore(doc);
      case 'system':
        return SystemNotificationFirestore.fromFirestore(doc);
      case 'voting':
        return VotingNotificationFirestore.fromFirestore(doc);
      default:
        throw Exception('Unknown notification type: $type');
    }
  }

  /// Entity → Firestore Map (타입별로 다르게 구현)
  Map<String, dynamic> toFirestore() {
    return when(
      social: (notification) => (notification as SocialNotification).toFirestore(),
      system: (notification) => (notification as SystemNotification).toFirestore(),
      voting: (notification) => (notification as VotingNotification).toFirestore(),
    );
  }
}

// ===== Helper Functions =====

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
```

**Key Features**:
- ✅ Type dispatch: switch로 타입별 Extension 호출
- ✅ Helper functions: _parseDateTime, _parseStringList, _parseDouble
- ✅ Null safety: fallback values 제공
- ✅ Type conversion: Timestamp ↔ DateTime

#### social_notification_extensions.dart (142 lines) - +8 필드

**Purpose**: Social 알림 전용 필드 변환 (총 18 필드 = 기본 10 + Social 8)

```dart
extension SocialNotificationFirestore on SocialNotification {
  /// Firestore DocumentSnapshot → SocialNotification Entity
  ///
  /// **처리 필드 (18개)**:
  /// - 기본: id, userId, type, title, content, createdAt, readAt, isRead, expiryTime, metadata (10개)
  /// - Social: actionType, fromUserId, fromUserName, fromUserProfileUrl,
  ///          relatedPostId, relatedCommentId, relatedContent, interactionCount (8개)
  static SocialNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SocialNotification(
      // ===== 기본 필드 (10개) =====
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'social',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
      isRead: data['isRead'] as bool? ?? false,
      expiryTime: _parseDateTime(data['expiryTime']),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},

      // ===== Social 전용 필드 (8개) =====
      actionType: _parseActionType(data['actionType']),
      fromUserId: data['fromUserId'] as String? ?? '',
      fromUserName: data['fromUserName'] as String? ?? '',
      fromUserProfileUrl: data['fromUserProfileUrl'] as String?,
      relatedPostId: data['relatedPostId'] as String?,
      relatedCommentId: data['relatedCommentId'] as String?,
      relatedContent: data['relatedContent'] as String?,
      interactionCount: data['interactionCount'] as int?,
    );
  }

  /// SocialNotification Entity → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      // Type 필드 (Sealed Union 구분)
      'type': 'social',

      // ===== 기본 필드 =====
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isRead': isRead,
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      if (metadata.isNotEmpty) 'metadata': metadata,

      // ===== Social 전용 필드 =====
      'actionType': actionType.value,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      if (fromUserProfileUrl != null) 'fromUserProfileUrl': fromUserProfileUrl,
      if (relatedPostId != null) 'relatedPostId': relatedPostId,
      if (relatedCommentId != null) 'relatedCommentId': relatedCommentId,
      if (relatedContent != null) 'relatedContent': relatedContent,
      if (interactionCount != null) 'interactionCount': interactionCount,
    };
  }

  static SocialActionType _parseActionType(dynamic value) {
    if (value == null) return SocialActionType.like;
    if (value is String) return SocialActionType.fromString(value);
    return SocialActionType.like;
  }
}
```

#### system_notification_extensions.dart (161 lines) - +6 필드

**Purpose**: System 알림 전용 필드 변환 (총 16 필드 = 기본 10 + System 6)

```dart
extension SystemNotificationFirestore on SystemNotification {
  /// Firestore DocumentSnapshot → SystemNotification Entity
  ///
  /// **처리 필드 (16개)**:
  /// - 기본: 10개
  /// - System: alertType, actionUrl, actionLabel, actionButtons, iconUrl, isDismissible (6개)
  static SystemNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SystemNotification(
      // ===== 기본 필드 (10개) =====
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
      isRead: data['isRead'] as bool? ?? false,
      expiryTime: _parseDateTime(data['expiryTime']),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},

      // ===== System 전용 필드 (6개) =====
      alertType: _parseAlertType(data['alertType']),
      actionUrl: data['actionUrl'] as String?,
      actionLabel: data['actionLabel'] as String?,
      actionButtons: _parseActionButtons(data['actionButtons']),
      iconUrl: data['iconUrl'] as String?,
      isDismissible: data['isDismissible'] as bool? ?? true,
    );
  }

  /// SystemNotification Entity → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'type': 'system',

      // ===== 기본 필드 =====
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isRead': isRead,
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      if (metadata.isNotEmpty) 'metadata': metadata,

      // ===== System 전용 필드 =====
      'alertType': alertType.value,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (actionLabel != null) 'actionLabel': actionLabel,
      if (actionButtons != null && actionButtons!.isNotEmpty)
        'actionButtons': actionButtons,
      if (iconUrl != null) 'iconUrl': iconUrl,
      'isDismissible': isDismissible,
    };
  }

  static SystemAlertType _parseAlertType(dynamic value) {
    if (value == null) return SystemAlertType.info;
    if (value is String) return SystemAlertType.fromString(value);
    return SystemAlertType.info;
  }

  static Map<String, String>? _parseActionButtons(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return Map<String, String>.from(value);
    }
    return null;
  }
}
```

#### voting_notification_extensions.dart (233 lines) - +20 필드

**Purpose**: Voting 알림 전용 필드 변환 (총 30 필드 = 기본 10 + Voting 20) - **가장 복잡**

```dart
extension VotingNotificationFirestore on VotingNotification {
  /// Firestore DocumentSnapshot → VotingNotification Entity
  ///
  /// **처리 필드 (30개)**:
  /// - 기본: 10개
  /// - Voting: postId, postTitle, postContent, postDescription, voteStartTime, voteEndTime,
  ///          targetAudience, currentVotesA, currentVotesB, hasVoted, userVoteChoice,
  ///          senderId, senderName, body, notificationPriority, imageUrlsA, imageUrlsB,
  ///          aspectRatioA, aspectRatioB, layoutType (20개)
  static VotingNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return VotingNotification(
      // ===== 기본 필드 (10개) =====
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'voting',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
      isRead: data['isRead'] as bool? ?? false,
      expiryTime: _parseDateTime(data['expiryTime']),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},

      // ===== Voting 전용 필드 (20개) =====
      // Post 정보 (4개)
      postId: data['postId'] as String? ?? '',
      postTitle: data['postTitle'] as String? ?? '',
      postContent: data['postContent'] as String? ?? '',
      postDescription: data['postDescription'] as String?,

      // 투표 시간 (2개)
      voteStartTime: _parseDateTime(data['voteStartTime']) ?? DateTime.now(),
      voteEndTime: _parseDateTime(data['voteEndTime']) ?? DateTime.now(),

      // 타겟팅 & 통계 (4개)
      targetAudience: data['targetAudience'] as String?,
      currentVotesA: data['currentVotesA'] as int?,
      currentVotesB: data['currentVotesB'] as int?,
      hasVoted: data['hasVoted'] as bool? ?? false,

      // 사용자 투표 선택 (1개)
      userVoteChoice: data['userVoteChoice'] as String?,

      // 발신자 정보 (3개)
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      body: data['body'] as String?,

      // 우선순위 (1개)
      notificationPriority: _parsePriority(data['notificationPriority']),

      // 이미지 URL 리스트 (2개)
      imageUrlsA: _parseStringList(data['imageUrlsA']),
      imageUrlsB: _parseStringList(data['imageUrlsB']),

      // Aspect Ratio & Layout (3개)
      aspectRatioA: _parseDouble(data['aspectRatioA']),
      aspectRatioB: _parseDouble(data['aspectRatioB']),
      layoutType: data['layoutType'] as String?,
    );
  }

  /// VotingNotification Entity → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'type': 'voting',

      // ===== 기본 필드 =====
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isRead': isRead,
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      if (metadata.isNotEmpty) 'metadata': metadata,

      // ===== Voting 전용 필드 =====
      'postId': postId,
      'postTitle': postTitle,
      'postContent': postContent,
      if (postDescription != null) 'postDescription': postDescription,
      'voteStartTime': Timestamp.fromDate(voteStartTime),
      'voteEndTime': Timestamp.fromDate(voteEndTime),
      if (targetAudience != null) 'targetAudience': targetAudience,
      if (currentVotesA != null) 'currentVotesA': currentVotesA,
      if (currentVotesB != null) 'currentVotesB': currentVotesB,
      'hasVoted': hasVoted,
      if (userVoteChoice != null) 'userVoteChoice': userVoteChoice,
      if (senderId != null) 'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      if (body != null) 'body': body,
      'notificationPriority': notificationPriority.toJson(),
      if (imageUrlsA.isNotEmpty) 'imageUrlsA': imageUrlsA,
      if (imageUrlsB.isNotEmpty) 'imageUrlsB': imageUrlsB,
      if (aspectRatioA != null) 'aspectRatioA': aspectRatioA,
      if (aspectRatioB != null) 'aspectRatioB': aspectRatioB,
      if (layoutType != null) 'layoutType': layoutType,
    };
  }

  static NotificationPriority _parsePriority(dynamic value) {
    if (value == null) return NotificationPriority.medium;
    if (value is int) return NotificationPriority.fromJson(value);
    return NotificationPriority.medium;
  }
}
```

**Extension Pattern Summary**:

| Extension File | Field Count | Lines | Purpose |
|---------------|-------------|-------|---------|
| notification_extensions.dart | 10 | 169 | 기본 필드 + Type dispatch |
| social_notification_extensions.dart | 18 (10+8) | 142 | Social 알림 변환 |
| system_notification_extensions.dart | 16 (10+6) | 161 | System 알림 변환 |
| voting_notification_extensions.dart | 30 (10+20) | 233 | Voting 알림 변환 (가장 복잡) |
| **Total** | **74 fields** | **705 lines** | **Type-Specific Pattern** |

**Why Type-Specific Extensions?**:
- ✅ **Separation of Concerns**: 각 타입의 변환 로직 분리
- ✅ **Maintainability**: 타입별로 독립적인 수정 가능
- ✅ **Type Safety**: 타입별로 다른 필드 처리
- ✅ **Scalability**: 새로운 알림 타입 추가 용이

---

## failures/ - Domain Errors

NotificationFailure는 알림 시스템의 모든 에러 케이스를 표현하는 Sealed Class입니다.

### 15 Failure Types

#### 6 Notification CRUD Errors

```dart
/// 알림을 찾을 수 없음
class NotificationNotFound extends NotificationFailure {
  const NotificationNotFound() : super();
}

/// 알림 로드 실패
class NotificationLoadFailed extends NotificationFailure {
  const NotificationLoadFailed() : super();
}

/// 알림 전송 실패
class NotificationSendFailed extends NotificationFailure {
  const NotificationSendFailed() : super();
}

/// 알림 생성 실패
class NotificationCreateFailed extends NotificationFailure {
  const NotificationCreateFailed() : super();
}

/// 알림 업데이트 실패
class NotificationUpdateFailed extends NotificationFailure {
  const NotificationUpdateFailed() : super();
}

/// 알림 삭제 실패
class NotificationDeleteFailed extends NotificationFailure {
  const NotificationDeleteFailed() : super();
}
```

#### 2 Validation Errors

```dart
/// 유효하지 않은 알림 데이터
class InvalidNotificationData extends NotificationFailure {
  const InvalidNotificationData() : super();
}

/// 만료된 알림
class NotificationExpired extends NotificationFailure {
  const NotificationExpired() : super();
}
```

#### 4 Special Operations Errors

```dart
/// 알림 브로드캐스트 실패
class BroadcastFailed extends NotificationFailure {
  const BroadcastFailed() : super();
}

/// 알림 그룹화 실패
class GroupingFailed extends NotificationFailure {
  const GroupingFailed() : super();
}

/// 알림 스트리밍 실패
class StreamingFailed extends NotificationFailure {
  const StreamingFailed() : super();
}

/// 알림 시스템 초기화 실패
class InitializationFailed extends NotificationFailure {
  const InitializationFailed() : super();
}
```

#### 3 Network & Permission Errors

```dart
/// 네트워크 오류
class NetworkError extends NotificationFailure {
  const NetworkError() : super();
}

/// 권한 없음
class PermissionDenied extends NotificationFailure {
  const PermissionDenied() : super();
}

/// 서버 오류
class ServerError extends NotificationFailure {
  const ServerError() : super();
}
```

#### 1 Generic Error

```dart
/// 예기치 않은 오류
class Unexpected extends NotificationFailure {
  final String? errorMessage;
  const Unexpected([this.errorMessage]) : super();
}
```

### Pattern Matching with Switch Expression

```dart
// Modern Dart 3 switch expression
final message = switch (failure) {
  // CRUD errors
  NotificationNotFound() => '알림을 찾을 수 없습니다',
  NotificationLoadFailed() => '알림을 불러오는데 실패했습니다',
  NotificationSendFailed() => '알림 전송에 실패했습니다',
  NotificationCreateFailed() => '알림 생성에 실패했습니다',
  NotificationUpdateFailed() => '알림 업데이트에 실패했습니다',
  NotificationDeleteFailed() => '알림 삭제에 실패했습니다',

  // Validation errors
  InvalidNotificationData() => '유효하지 않은 알림 데이터입니다',
  NotificationExpired() => '만료된 알림입니다',

  // Special operations
  BroadcastFailed() => '알림 브로드캐스트에 실패했습니다',
  GroupingFailed() => '알림 그룹화에 실패했습니다',
  StreamingFailed() => '알림 스트리밍에 실패했습니다',
  InitializationFailed() => '알림 시스템 초기화에 실패했습니다',

  // Network & Permission
  NetworkError() => '네트워크 연결을 확인해주세요',
  PermissionDenied() => '알림 권한이 없습니다',
  ServerError() => '서버 오류가 발생했습니다',

  // Generic
  Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
};

showSnackBar(message);
```

### Failure Hierarchy

```
NotificationFailure (Sealed)
├── CRUD Errors (6)
│   ├── NotificationNotFound
│   ├── NotificationLoadFailed
│   ├── NotificationSendFailed
│   ├── NotificationCreateFailed
│   ├── NotificationUpdateFailed
│   └── NotificationDeleteFailed
│
├── Validation Errors (2)
│   ├── InvalidNotificationData
│   └── NotificationExpired
│
├── Special Operations (4)
│   ├── BroadcastFailed
│   ├── GroupingFailed
│   ├── StreamingFailed
│   └── InitializationFailed
│
├── Network & Permission (3)
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

### INotificationRepository Deep Dive (166 lines, 25+ methods)

**4 Method Categories**:

#### 1. CRUD Operations (10 methods)

```dart
abstract class INotificationRepository {
  /// 사용자의 알림 목록 조회
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  );

  /// 알림 전송
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId,
  );

  /// 단일 알림 조회
  Future<Either<NotificationFailure, Notification>> getNotification(String id);

  /// 알림 읽음 처리
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String eventId,
  );

  /// 알림 삭제
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String eventId,
  );

  /// 모든 알림을 읽음으로 표시
  Future<Either<NotificationFailure, Unit>> markAllAsRead(
    String userId,
    String eventId,
  );

  /// 사용자의 모든 알림 삭제
  Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
    String userId,
    String eventId,
  );

  /// 오래된 알림 삭제
  Future<Either<NotificationFailure, Unit>> deleteOldNotifications({
    required String userId,
    required DateTime before,
  });

  /// 만료된 알림 자동 삭제
  Future<Either<NotificationFailure, Unit>> deleteExpiredNotifications(
    String userId,
  );

  /// 만료된 알림 정리 (동일한 기능, 호환성 유지)
  Future<Either<NotificationFailure, Unit>> cleanupExpiredNotifications(
    String userId,
  );
}
```

#### 2. Query Operations (7 methods)

```dart
abstract class INotificationRepository {
  /// 읽지 않은 알림 개수 조회
  Future<Either<NotificationFailure, int>> getUnreadCount(String userId);

  /// 특정 타입의 알림 조회
  Future<Either<NotificationFailure, List<T>>> getNotificationsByType<
      T extends Notification>({
    required String userId,
    required String type,
    int? limit,
  });

  /// 새 알림 생성
  ///
  /// [eventId]: 멱등성 보장을 위한 고유 ID (UUID v4 권장)
  Future<Either<NotificationFailure, String>> createNotification(
    Notification notification,
    String eventId,
  );

  /// 알림 업데이트 (읽음 처리 등)
  Future<Either<NotificationFailure, Unit>> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  );

  /// 알림 통계 조회
  Future<Either<NotificationFailure, Map<String, dynamic>>>
      getNotificationStats(String userId);

  /// 알림 활동 로그
  Future<Either<NotificationFailure, List<Map<String, dynamic>>>>
      getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  });

  /// 알림 시스템 초기화
  Future<Either<NotificationFailure, Unit>> initializeNotificationSystem({
    required String userId,
  });
}
```

#### 3. Special Operations (2 methods)

```dart
abstract class INotificationRepository {
  /// 시스템 알림 브로드캐스트
  Future<Either<NotificationFailure, Unit>> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  });

  /// 소셜 알림 그룹화 처리
  Future<Either<NotificationFailure, Unit>> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  });
}
```

#### 4. Stream Operations (5 methods)

```dart
abstract class INotificationRepository {
  /// 읽지 않은 알림 개수 실시간 감시
  Stream<int> watchUnreadCount(String userId);

  /// 사용자 알림 실시간 감시
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  /// 읽지 않은 알림 개수 실시간 스트림
  Stream<int> getUnreadNotificationCount(String userId);

  /// 알림 리스너 시작
  Future<Stream<Notification>> startListening({
    required String userId,
  });

  /// 알림 리스너 중지
  Future<Either<NotificationFailure, Unit>> stopListening({
    required String userId,
  });
}
```

**Repository Features**:
- ✅ **25+ Methods**: CRUD (10) + Query (7) + Special (2) + Stream (5) + Misc (1)
- ✅ **Either Pattern**: 모든 실패 가능한 작업은 `Either<NotificationFailure, T>` 반환
- ✅ **Idempotency**: eventId 파라미터로 중복 작업 방지
- ✅ **Stream Support**: Real-time notification updates
- ✅ **Type Safety**: Generic type parameter for `getNotificationsByType<T>`
- ✅ **Comprehensive**: CRUD, Query, Special operations 모두 지원

---

## services/ - Service Interface

### INotificationService (47 lines, 8 methods)

**Purpose**: Repository wrapper로 실시간 알림 스트리밍 제공

```dart
/// 알림 서비스 인터페이스
///
/// Domain 레이어에서 정의하는 알림 서비스 계약
/// Data 레이어에서 구현됨
abstract class INotificationService {
  /// 알림 스트림
  Stream<List<Notification>> get notificationsStream;

  /// 알림 리스닝 시작
  ///
  /// [userId] - 사용자 ID
  /// [type] - 알림 타입 필터 (null이면 모든 타입)
  void startListening(String userId, {String? type});

  /// 알림 리스닝 중지
  void stopListening();

  /// 사용자의 읽지 않은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount(String userId);

  /// 알림을 읽음으로 표시
  Future<void> markAsRead(String notificationId);

  /// 알림 다시 표시 (답변 거부 시)
  Future<void> reshowNotification(String notificationId);

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId);

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId);

  /// 만료된 알림 정리
  Future<void> cleanupExpiredNotifications(String userId);

  /// 알림 큐 비우기
  void clearQueue();

  /// 서비스 리소스 정리
  void dispose();
}
```

**Service vs Repository**:

| Aspect | INotificationService | INotificationRepository |
|--------|---------------------|------------------------|
| **Purpose** | Broadcast stream wrapper | Data access abstraction |
| **Return Type** | void, Future<void> | Either<Failure, T> |
| **Error Handling** | Stream.error() | Either Pattern |
| **Use Case** | Real-time UI updates | Business logic |
| **Layer** | Domain (interface) | Domain (interface) |
| **Implementation** | NotificationService (Data) | NotificationRepositoryImpl (Data) |

**Why Service Interface?**:
- ✅ **Broadcast Pattern**: Single stream, multiple listeners
- ✅ **Type Filtering**: Filter by notification type
- ✅ **Lifecycle Management**: startListening/stopListening
- ✅ **Simplified API**: No Either pattern for UI layer
- ✅ **Real-time Updates**: Stream-based reactive updates

---

## value_objects/ - Value Objects

### NotificationFilter (130 lines)

**Purpose**: 복잡한 알림 쿼리 조건을 캡슐화하는 Value Object

```dart
/// 알림 필터 Value Object
/// Clean Architecture - 도메인 값 객체
class NotificationFilter {
  final String? type;
  final bool? unreadOnly;
  final DateTime? after;
  final DateTime? before;
  final int? limit;
  final String? sortBy;
  final bool? excludeExpired;
  final String? userId;
  final SortOrder? sortOrder;

  const NotificationFilter({
    this.type,
    this.unreadOnly,
    this.after,
    this.before,
    this.limit,
    this.sortBy = 'createdAt',
    this.excludeExpired = true,
    this.userId,
    this.sortOrder = SortOrder.descending,
  });

  /// 필터가 적용되었는지 확인
  bool get hasFilters {
    return type != null ||
        unreadOnly != null ||
        after != null ||
        before != null ||
        limit != null ||
        excludeExpired != null ||
        userId != null;
  }

  /// 날짜 범위가 유효한지 확인
  bool get isDateRangeValid {
    if (after == null || before == null) return true;
    return after!.isBefore(before!);
  }

  /// 기본 필터 생성 (읽지 않은, 만료되지 않은 알림)
  factory NotificationFilter.unreadActive() {
    return const NotificationFilter(
      unreadOnly: true,
      excludeExpired: true,
      sortOrder: SortOrder.descending,
    );
  }

  /// 최근 알림 필터 (30일 이내)
  factory NotificationFilter.recent({int days = 30, int limit = 50}) {
    return NotificationFilter(
      after: DateTime.now().subtract(Duration(days: days)),
      sortOrder: SortOrder.descending,
      limit: limit,
    );
  }

  /// 읽지 않은 알림만 필터
  factory NotificationFilter.unreadOnly() {
    return const NotificationFilter(
      unreadOnly: true,
    );
  }

  /// 타입별 필터
  factory NotificationFilter.byType(String type) {
    return NotificationFilter(
      type: type,
    );
  }

  /// 필터 복사 및 수정
  NotificationFilter copyWith({
    String? type,
    bool? unreadOnly,
    DateTime? after,
    DateTime? before,
    int? limit,
    String? sortBy,
    bool? excludeExpired,
    String? userId,
    SortOrder? sortOrder,
  }) {
    return NotificationFilter(
      type: type ?? this.type,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      after: after ?? this.after,
      before: before ?? this.before,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      excludeExpired: excludeExpired ?? this.excludeExpired,
      userId: userId ?? this.userId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    final filters = <String>[];
    if (type != null) filters.add('type=$type');
    if (unreadOnly == true) filters.add('unreadOnly');
    if (after != null) filters.add('after=$after');
    if (before != null) filters.add('before=$before');
    if (limit != null) filters.add('limit=$limit');
    if (excludeExpired == true) filters.add('excludeExpired');
    if (userId != null) filters.add('userId=$userId');
    if (sortOrder != null) filters.add('sort=${sortOrder?.name}');

    return 'NotificationFilter(${filters.join(', ')})';
  }
}

/// 정렬 순서 열거형
enum SortOrder {
  ascending('asc'),
  descending('desc');

  final String value;
  const SortOrder(this.value);

  static SortOrder fromString(String value) {
    return SortOrder.values.firstWhere(
      (order) => order.value == value,
      orElse: () => SortOrder.descending,
    );
  }
}
```

**Value Object Features**:
- ✅ **8 Filter Conditions**: type, unreadOnly, after, before, limit, sortBy, excludeExpired, userId
- ✅ **4 Factory Methods**: unreadActive(), recent(), unreadOnly(), byType()
- ✅ **Validation**: hasFilters, isDateRangeValid
- ✅ **Immutability**: const constructor
- ✅ **copyWith**: For modifications
- ✅ **toString**: Debugging support

**Usage Example**:

```dart
// Factory methods
final filter1 = NotificationFilter.unreadActive();
final filter2 = NotificationFilter.recent(days: 7, limit: 20);
final filter3 = NotificationFilter.byType('voting');

// Custom filter
final filter4 = NotificationFilter(
  unreadOnly: true,
  after: DateTime.now().subtract(Duration(days: 30)),
  before: DateTime.now(),
  limit: 50,
  sortOrder: SortOrder.descending,
);

// copyWith
final filter5 = filter4.copyWith(limit: 100);

// Validation
if (filter4.hasFilters && filter4.isDateRangeValid) {
  // Apply filter
}
```

---

## usecases/ - Business Logic Encapsulation

UseCase는 단일 비즈니스 작업을 캡슐화합니다. Notifications Feature는 **Base UseCase Pattern**을 사용하여 일관된 인터페이스를 제공합니다.

### Base UseCase Abstraction (3 files, 36 lines)

#### 1. UseCase<Input, Output> (17 lines)

**Purpose**: Future를 반환하는 모든 UseCase의 추상 클래스

```dart
/// Base UseCase abstraction for all use cases
/// Clean Architecture - Domain UseCase Pattern
abstract class UseCase<Input, Output> {
  /// Execute the use case with given input
  ///
  /// Returns [Result<Output>] which is either:
  /// - Success<Output> - successful operation with data
  /// - ResultFailure<Failure> - failed operation with typed Failure
  Future<Result<Output>> call(Input input);
}
```

#### 2. StreamUseCase<Input, Output> (6 lines)

**Purpose**: Stream을 반환하는 UseCase의 추상 클래스

```dart
/// Base Stream UseCase abstraction
abstract class StreamUseCase<Input, Output> {
  /// Execute the use case with given input
  Stream<Output> call(Input input);
}
```

#### 3. NoParamUseCase<Output> (13 lines)

**Purpose**: 파라미터가 없는 UseCase의 추상 클래스

```dart
/// Base UseCase abstraction for use cases without parameters
abstract class NoParamUseCase<Output> {
  /// Execute the use case without parameters
  Future<Result<Output>> call();
}
```

**Base UseCase Benefits**:
- ✅ **Consistency**: 모든 UseCase가 동일한 인터페이스 따름
- ✅ **Type Safety**: Generic type parameters
- ✅ **Flexibility**: Future/Stream/NoParam variants
- ✅ **Testability**: Easy to mock

### 5 UseCases Overview

#### 1. SendNotificationUseCase (97 lines)

**Purpose**: 알림 전송 비즈니스 로직

```dart
class SendNotificationUseCase {
  final INotificationRepository _repository;

  SendNotificationUseCase(this._repository);

  Future<Either<NotificationFailure, List<String>>> call(
      SendNotificationParams params) async {
    // 비즈니스 규칙: 타겟 사용자 검증
    if (params.targetUserIds.isEmpty) {
      return left(const InvalidNotificationData());
    }

    // 비즈니스 규칙: 최대 타겟 사용자 수 제한
    const maxTargets = 100;
    if (params.targetUserIds.length > maxTargets) {
      return left(const InvalidNotificationData());
    }

    // 일반 알림 처리 - 각 사용자별로 생성
    final createdIds = <String>[];

    for (final userId in params.targetUserIds) {
      final userNotification = _createUserNotification(
        params.notification,
        userId,
      );

      // Repository 호출 - Either 반환 (eventId 생성)
      final result = await _repository.createNotification(
        userNotification,
        const Uuid().v4(),
      );

      // fold()로 Either 처리
      final idOrError = result.fold(
        (failure) => left<NotificationFailure, String>(failure),
        (id) => right<NotificationFailure, String>(id),
      );

      // 에러 발생 시 즉시 반환
      if (idOrError.isLeft()) {
        return idOrError.fold(
          (failure) => left(failure),
          (_) => left(const NotificationSendFailed()),
        );
      }

      // ID 수집
      idOrError.fold(
        (_) {},
        (id) => createdIds.add(id),
      );
    }

    return right(createdIds);
  }

  Notification _createUserNotification(
      Notification baseNotification, String userId) {
    return baseNotification;
  }
}

/// Parameters for SendNotificationUseCase
class SendNotificationParams {
  final Notification notification;
  final List<String> targetUserIds;
  final String? targetAudience;

  const SendNotificationParams({
    required this.notification,
    required this.targetUserIds,
    this.targetAudience,
  });
}
```

**Business Rules**:
- ✅ Target user validation (not empty)
- ✅ Maximum 100 targets
- ✅ UUID generation for idempotency
- ✅ All-or-nothing semantics (fail on first error)

#### 2. GetUserNotificationsUseCase (97 lines)

**Purpose**: 사용자 알림 조회 및 필터링 비즈니스 로직

```dart
class GetUserNotificationsUseCase {
  final INotificationRepository _repository;

  GetUserNotificationsUseCase(this._repository);

  Future<Either<NotificationFailure, List<Notification>>> call(
      GetUserNotificationsParams params) async {
    // Repository 호출 (Either 반환)
    final result = await _repository.getUserNotifications(params.userId);

    // fold()로 Either 처리하며 비즈니스 로직 적용
    return result.fold(
      (failure) => left(failure),
      (notifications) {
        var filtered = notifications;
        final filter = params.filter ?? NotificationFilter.unreadActive();

        // 비즈니스 로직 1: 필터 적용
        if (filter.unreadOnly == true) {
          filtered = filtered.where((n) => !n.isRead).toList();
        }

        if (filter.type != null) {
          filtered = filtered.where((n) => n.type == filter.type).toList();
        }

        // 비즈니스 로직 2: 만료된 알림 자동 필터링
        if (params.excludeExpired || filter.excludeExpired == true) {
          filtered = filtered.where((n) => !n.isExpired).toList();
        }

        // 날짜 범위 필터링
        if (filter.after != null) {
          filtered = filtered.where((n) => n.createdAt.isAfter(filter.after!)).toList();
        }
        if (filter.before != null) {
          filtered = filtered.where((n) => n.createdAt.isBefore(filter.before!)).toList();
        }

        // 비즈니스 로직 3: 우선순위 정렬
        if (params.sortByPriority) {
          filtered.sort((a, b) => b.priority.compareTo(a.priority));
        } else if (filter.sortBy != null) {
          if (filter.sortOrder == SortOrder.descending) {
            filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else {
            filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          }
        }

        // 비즈니스 로직 4: 최대 개수 제한
        final limit = params.limit ?? filter.limit;
        if (limit != null && filtered.length > limit) {
          filtered = filtered.take(limit).toList();
        }

        return right(filtered);
      },
    );
  }
}

/// Parameters for GetUserNotificationsUseCase
class GetUserNotificationsParams {
  final String userId;
  final NotificationFilter? filter;
  final bool excludeExpired;
  final bool sortByPriority;
  final int? limit;

  const GetUserNotificationsParams({
    required this.userId,
    this.filter,
    this.excludeExpired = true,
    this.sortByPriority = true,
    this.limit,
  });
}
```

**Business Rules**:
- ✅ Filter application (unread, type, date range)
- ✅ Auto-exclude expired notifications
- ✅ Priority-based sorting
- ✅ Limit enforcement

#### 3. MarkAsReadUseCase (69 lines)

**Purpose**: 알림 읽음 처리 비즈니스 로직

```dart
class MarkAsReadUseCase {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    // 비즈니스 규칙: 권한 검증
    if (params.userId.isEmpty || params.notificationId.isEmpty) {
      return left(const InvalidNotificationData());
    }

    // 비즈니스 로직: 알림 조회하여 소유자 확인
    final notificationResult =
        await _repository.getNotification(params.notificationId);

    return notificationResult.fold(
      (failure) => left(failure),
      (notification) async {
        // 비즈니스 규칙: 본인 알림만 읽음 처리 가능
        if (notification.userId != params.userId) {
          return left(const PermissionDenied());
        }

        // 비즈니스 규칙: 이미 읽은 알림은 스킵 (Idempotent)
        if (notification.isRead) {
          return right(unit);
        }

        // Repository 호출 - Either 반환 (eventId 생성)
        final markResult = await _repository.markAsRead(
          params.notificationId,
          const Uuid().v4(),
        );

        return markResult;
      },
    );
  }
}

/// Parameters for MarkAsReadUseCase
class MarkAsReadParams {
  final String notificationId;
  final String userId;

  const MarkAsReadParams({
    required this.notificationId,
    required this.userId,
  });
}
```

**Business Rules**:
- ✅ Ownership validation (본인 알림만 처리)
- ✅ Idempotent (이미 읽은 경우 스킵)
- ✅ UUID generation for eventId

#### 4. WatchUserNotificationsUseCase (46 lines)

**Purpose**: 실시간 알림 스트림 UseCase

```dart
class WatchUserNotificationsUseCase {
  final INotificationRepository _repository;

  WatchUserNotificationsUseCase(this._repository);

  Stream<List<Notification>> call(WatchUserNotificationsParams params) {
    return _repository.watchUserNotifications(
      userId: params.userId,
      filter: params.filter,
    );
  }
}

/// Parameters for WatchUserNotificationsUseCase
class WatchUserNotificationsParams {
  final String userId;
  final NotificationFilter? filter;

  const WatchUserNotificationsParams({
    required this.userId,
    this.filter,
  });
}
```

#### 5. WatchUnreadCountUseCase (26 lines)

**Purpose**: 읽지 않은 알림 개수 실시간 스트림 UseCase

```dart
class WatchUnreadCountUseCase {
  final INotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  Stream<int> call(String userId) {
    return _repository.watchUnreadCount(userId);
  }
}
```

**Usage in Presentation Layer**:

```dart
class NotificationBadgeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchUnreadCount = ref.read(watchUnreadCountUseCaseProvider);

    return StreamBuilder<int>(
      stream: watchUnreadCount(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final unreadCount = snapshot.data!;
        if (unreadCount == 0) return SizedBox.shrink();

        return Badge(
          label: Text('$unreadCount'),
          child: Icon(Icons.notifications),
        );
      },
    );
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
- Service Interfaces (어떤 외부 서비스가 필요한가?)
- UseCases (어떤 비즈니스 로직이 있는가?)
- Failures (어떤 에러가 발생할 수 있는가?)
- Value Objects (어떤 값 객체가 필요한가?)

### 2. Entities Are Pure Dart

**Rule**: 엔티티는 프레임워크 독립적이어야 합니다.

```dart
// ❌ BAD: Flutter 의존성
import 'package:flutter/material.dart';

class Notification {
  final Color color; // Flutter Widget!
}

// ✅ GOOD: Pure Dart
class Notification {
  final String id;
  final String title;
  final DateTime createdAt;
}
```

### 3. Repository Pattern

**Rule**: Repository는 인터페이스로 정의하고, Data Layer가 구현합니다.

```dart
// Domain Layer (interface)
abstract class INotificationRepository {
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId,
  );
}

// Data Layer (implementation)
class NotificationRepositoryImpl implements INotificationRepository {
  final FirebaseFirestore _firestore;
  final IdempotencyService _idempotencyService;

  @override
  Future<Either<NotificationFailure, Unit>> sendNotification(...) async {
    // Firestore 구현
  }
}
```

### 4. UseCase Single Responsibility

**Rule**: 하나의 UseCase는 하나의 비즈니스 작업만 수행합니다.

```dart
// ❌ BAD: God UseCase
class NotificationUseCase {
  Future<void> sendNotification() {}
  Future<void> markAsRead() {}
  Future<void> deleteNotification() {}
  // ... 50+ methods
}

// ✅ GOOD: Single Responsibility
class SendNotificationUseCase {
  Future<Either<NotificationFailure, List<String>>> call(...) {}
}

class MarkAsReadUseCase {
  Future<Either<NotificationFailure, Unit>> call(...) {}
}

class DeleteNotificationUseCase {
  Future<Either<NotificationFailure, Unit>> call(...) {}
}
```

### 5. Either Pattern for Error Handling

**Rule**: 모든 실패 가능한 작업은 `Either<Failure, Success>` 타입을 반환합니다.

```dart
// ❌ BAD: Exception throwing
Future<Notification> getNotification(String id) async {
  if (error) throw Exception('Error!');
  return notification;
}

// ✅ GOOD: Either pattern
Future<Either<NotificationFailure, Notification>> getNotification(String id) async {
  if (error) return left(NotificationNotFound());
  return right(notification);
}

// Usage with fold
final result = await getNotification('123');
result.fold(
  (failure) => handleError(failure),
  (notification) => handleSuccess(notification),
);
```

### 6. Immutability with Freezed

**Rule**: 모든 엔티티는 불변 객체여야 합니다.

```dart
// ❌ BAD: Mutable entity
class Notification {
  String title;
  bool isRead;

  void markAsRead() {
    isRead = true; // Mutation!
  }
}

// ✅ GOOD: Immutable entity
@freezed
sealed class Notification with _$Notification {
  const factory Notification.social({
    required String title,
    required bool isRead,
  }) = SocialNotification;

  // Use copyWith for updates
  // notification.copyWith(isRead: true)
}
```

### 7. Extension Pattern for Conversion

**Rule**: Firestore ↔ Entity 변환은 Extension 메서드로 구현합니다.

```dart
// Notifications Feature의 고유한 접근: Type-Specific Extensions

// social_notification_extensions.dart
extension SocialNotificationFirestore on SocialNotification {
  static SocialNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SocialNotification(
      id: doc.id,
      // ... 18 fields
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': 'social',
      'id': id,
      // ... 18 fields
    };
  }
}
```

**Why Extension Pattern?**:
- ✅ No DTO/Mapper layer
- ✅ Direct conversion
- ✅ Less code (817 lines deleted in Voting Feature)
- ✅ Type safety
- ✅ Type-specific logic (4 separate extension files)

### 8. Value Object Pattern

**Rule**: 복잡한 값 조합은 Value Object로 캡슐화합니다.

```dart
// ❌ BAD: Primitive Obsession
Future<List<Notification>> getUserNotifications(
  String userId,
  String? type,
  bool? unreadOnly,
  DateTime? after,
  DateTime? before,
  int? limit,
  String? sortBy,
  bool? excludeExpired,
) {
  // 8개의 파라미터!
}

// ✅ GOOD: Value Object
class NotificationFilter {
  final String? type;
  final bool? unreadOnly;
  final DateTime? after;
  final DateTime? before;
  final int? limit;
  final String? sortBy;
  final bool? excludeExpired;
  final SortOrder? sortOrder;

  const NotificationFilter({...});
}

Future<List<Notification>> getUserNotifications(
  String userId,
  NotificationFilter? filter,
) {
  // 2개의 파라미터!
}
```

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

### Freezed Sealed Union

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
sealed class Notification with _$Notification {
  const Notification._(); // Private constructor for custom methods

  const factory Notification.social({
    required String id,
    required String title,
    required SocialActionType actionType,
  }) = SocialNotification;

  const factory Notification.system({
    required String id,
    required String title,
    required SystemAlertType alertType,
  }) = SystemNotification;

  const factory Notification.voting({
    required String id,
    required String title,
    required String postId,
  }) = VotingNotification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  // Custom business logic
  bool get canBeRead => !isRead && !isExpired;
}
```

**Generated Files**:
- `notification.freezed.dart`: copyWith, ==, hashCode, toString, when, map
- `notification.g.dart`: fromJson, toJson

### Pattern Matching with `when()`

```dart
final notification = Notification.social(...);

// Exhaustive pattern matching
final message = notification.when(
  social: (id, title, actionType) => 'Social: $title',
  system: (id, title, alertType) => 'System: $title',
  voting: (id, title, postId) => 'Voting: $title',
);
```

---

## Dependency Diagram

```
┌──────────────────────────────────────────────┐
│         Presentation Layer (UI)              │
│  - NotificationListWidget                    │
│  - NotificationBadge                         │
│  - VotingNotificationDialog                  │
└───────────────────┬──────────────────────────┘
                    │ depends on
                    ↓
┌──────────────────────────────────────────────┐
│           Domain Layer (YOU ARE HERE)        │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ entities/                            │   │
│  │  - Notification (Freezed Sealed Union)│  │
│  │    • SocialNotification (18 fields)  │   │
│  │    • SystemNotification (16 fields)  │   │
│  │    • VotingNotification (30 fields)  │   │
│  │  - Extensions (4 files, 705 lines)   │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ repositories/ (Interface)            │   │
│  │  - INotificationRepository (25+ methods)│ │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ services/ (Interface)                │   │
│  │  - INotificationService (8 methods)  │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ value_objects/                       │   │
│  │  - NotificationFilter                │   │
│  │    • 8 filter conditions             │   │
│  │    • 4 factory methods               │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ usecases/                            │   │
│  │  - Base (3 abstract classes)         │   │
│  │  - SendNotificationUseCase           │   │
│  │  - GetUserNotificationsUseCase       │   │
│  │  - MarkAsReadUseCase                 │   │
│  │  - WatchUserNotificationsUseCase     │   │
│  │  - WatchUnreadCountUseCase           │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ failures/                            │   │
│  │  - NotificationFailure (15 types)    │   │
│  └──────────────────────────────────────┘   │
└───────────────────┬──────────────────────────┘
                    │ implemented by
                    ↓
┌──────────────────────────────────────────────┐
│             Data Layer (Implementation)      │
│  - NotificationRepositoryImpl (1,154 lines)  │
│  - NotificationService (281 lines)           │
│  - UnifiedCacheService Integration           │
│  - IdempotencyService Integration            │
│  - Firebase, Firestore                       │
└──────────────────────────────────────────────┘
```

**Dependency Flow**:
1. Presentation → Domain (UseCases, Entities, Value Objects)
2. Domain → Data (Repository implementations, Services)
3. Data → External (Firebase, UnifiedCacheService)

**Key Rule**: Domain은 Data를 알지 못합니다 (Dependency Inversion)

---

## Best Practices

### 1. Entity Design

**DO**:
- ✅ Pure Dart 타입만 사용 (String, int, DateTime, List, Map, Enum)
- ✅ Freezed Sealed Union으로 타입 안전성 보장
- ✅ Business logic을 getter/method로 구현
- ✅ JSON 직렬화 지원 (fromJson, toJson)
- ✅ copyWith로 업데이트
- ✅ Private constructor: `const Notification._();`
- ✅ Exhaustive pattern matching with `when()`

**DON'T**:
- ❌ Flutter Widget 타입 사용 (Color, IconData, etc)
- ❌ Firebase 타입 직접 사용 (DocumentReference, Timestamp)
- ❌ Mutable 필드 (var, setter)
- ❌ 비즈니스 로직을 Presentation Layer에 두기

**Example**:

```dart
// ✅ GOOD
@freezed
sealed class Notification with _$Notification {
  const Notification._();

  const factory Notification.social({
    required String id,
    required SocialActionType actionType,
  }) = SocialNotification;

  bool get canBeRead => !isRead && !isExpired;
}

// ❌ BAD
class Notification {
  String id;
  Color backgroundColor; // Flutter dependency!

  Notification(this.id, this.backgroundColor);

  void markAsRead() {
    isRead = true; // Mutable!
  }
}
```

### 2. Repository Interface Design

**DO**:
- ✅ 메서드명은 동사로 시작 (sendNotification, getNotification, markAsRead)
- ✅ 모든 실패 가능한 메서드는 `Either<Failure, T>` 반환
- ✅ 실시간 데이터는 `Stream<T>` 반환 (Either 미사용)
- ✅ Async 작업은 `Future` 반환
- ✅ eventId 파라미터 추가 (Idempotency)

**DON'T**:
- ❌ void 반환 (에러 처리 불가)
- ❌ Exception throw (Either 패턴 사용)
- ❌ 구현 세부사항 노출 (Firestore, Firebase 타입)
- ❌ 너무 많은 메서드 (25+ = 분리 고려)

**Example**:

```dart
// ✅ GOOD
abstract class INotificationRepository {
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId, // Idempotency
  );

  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });
}

// ❌ BAD
abstract class INotificationRepository {
  Future<void> sendNotification(Notification notification); // void!
  List<Notification> getNotifications(String userId); // Sync!

  // Firestore 노출
  Future<DocumentSnapshot> getNotificationDocument(String id);
}
```

### 3. UseCase Design

**DO**:
- ✅ Single Responsibility (하나의 UseCase = 하나의 작업)
- ✅ `call()` 메서드로 실행
- ✅ Repository를 생성자 주입
- ✅ Input validation 수행
- ✅ Either 패턴 반환
- ✅ Base UseCase 상속 고려

**DON'T**:
- ❌ 여러 작업을 하나의 UseCase에 넣기
- ❌ UI 로직 포함 (showDialog, navigation)
- ❌ 직접 Firebase 호출

**Example**:

```dart
// ✅ GOOD
class MarkAsReadUseCase {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    // Validation
    if (params.userId.isEmpty || params.notificationId.isEmpty) {
      return left(const InvalidNotificationData());
    }

    // Ownership check
    final notificationResult =
        await _repository.getNotification(params.notificationId);

    return notificationResult.fold(
      (failure) => left(failure),
      (notification) async {
        if (notification.userId != params.userId) {
          return left(const PermissionDenied());
        }

        // Idempotent
        if (notification.isRead) {
          return right(unit);
        }

        return _repository.markAsRead(
          params.notificationId,
          const Uuid().v4(),
        );
      },
    );
  }
}

// ❌ BAD
class NotificationUseCase {
  Future<void> markAsRead(...) {}
  Future<void> sendNotification(...) {}
  Future<void> deleteNotification(...) {}
  // ... 50+ methods (God Object!)
}
```

### 4. Extension Pattern (Type-Specific)

**DO**:
- ✅ 타입별로 별도 Extension 파일 생성
- ✅ Bidirectional conversion (Entity ↔ Firestore)
- ✅ Null safety with fallbacks
- ✅ Timestamp handling (DateTime ↔ Firestore Timestamp)
- ✅ Helper functions for parsing (_parseDateTime, _parseDouble)

**DON'T**:
- ❌ Extension에 비즈니스 로직 포함
- ❌ Extension에 복잡한 변환 로직
- ❌ Extension에 외부 서비스 호출

**Example**:

```dart
// ✅ GOOD - Type-Specific Extension
extension SocialNotificationFirestore on SocialNotification {
  static SocialNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SocialNotification(
      id: doc.id,
      actionType: _parseActionType(data['actionType']),
      // ... 18 fields
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': 'social',
      'actionType': actionType.value,
      // ... 18 fields
    };
  }

  static SocialActionType _parseActionType(dynamic value) {
    if (value == null) return SocialActionType.like;
    if (value is String) return SocialActionType.fromString(value);
    return SocialActionType.like;
  }
}

// ❌ BAD
extension NotificationFirestore on Notification {
  Future<void> saveToFirestore() async {
    // ❌ Extension에 외부 서비스 호출
    await FirebaseFirestore.instance.collection('notifications').doc(id).set(...);
  }

  bool isImportant() {
    // ❌ Extension에 비즈니스 로직
    return priority > 3;
  }
}
```

### 5. Value Object Pattern

**DO**:
- ✅ Immutable (const constructor)
- ✅ Factory methods for common cases
- ✅ Validation logic (hasFilters, isDateRangeValid)
- ✅ copyWith for modifications
- ✅ toString for debugging

**DON'T**:
- ❌ Mutable fields
- ❌ Complex business logic
- ❌ External dependencies

**Example**:

```dart
// ✅ GOOD
class NotificationFilter {
  final String? type;
  final bool? unreadOnly;
  final DateTime? after;

  const NotificationFilter({
    this.type,
    this.unreadOnly,
    this.after,
  });

  factory NotificationFilter.unreadActive() {
    return const NotificationFilter(
      unreadOnly: true,
      excludeExpired: true,
    );
  }

  bool get hasFilters => type != null || unreadOnly != null;

  NotificationFilter copyWith({String? type}) {
    return NotificationFilter(
      type: type ?? this.type,
      unreadOnly: unreadOnly,
      after: after,
    );
  }
}

// ❌ BAD
class NotificationFilter {
  String? type;
  bool? unreadOnly;

  void setType(String type) {
    this.type = type; // Mutable!
  }

  Future<List<Notification>> apply() async {
    // ❌ Business logic + external call
    return await FirebaseFirestore.instance.collection('notifications').get();
  }
}
```

---

## Summary

**Notifications Domain Layer**는 알림 Feature의 핵심 비즈니스 로직을 정의하는 순수 Dart 레이어입니다.

**Key Highlights**:

1. **19 files**: 19 main files + 2 generated files = **21 files**, **2,651 lines**
2. **1 Entity**: Notification (Freezed Sealed Union) - 3가지 타입 (Social, System, Voting)
3. **Type-Specific Extensions**: 4 파일 (705 lines) - 각 타입마다 고유한 필드 수
4. **1 Repository Interface**: INotificationRepository (166 lines, 25+ methods)
5. **1 Service Interface**: INotificationService (47 lines, 8 methods)
6. **1 Value Object**: NotificationFilter (130 lines, 8 conditions, 4 factories)
7. **5 UseCases**: Send, Get, MarkAsRead, Watch, WatchUnreadCount
8. **3 Base UseCase Classes**: UseCase, StreamUseCase, NoParamUseCase
9. **15 Failure Types**: Comprehensive error handling
10. **Freezed Pattern**: 100% immutable entities with Sealed Union
11. **Either Pattern**: Type-safe error handling
12. **Clean Architecture v4.0**: Framework independence

**Unique Features**:
- ✅ **Freezed Sealed Union**: 3가지 알림 타입을 단일 엔티티로 표현
- ✅ **Type-Specific Extensions**: 4개 파일로 타입별 변환 분리 (142-233줄)
- ✅ **Field Distribution**: Social 18, System 16, Voting 30 필드
- ✅ **Value Object Pattern**: NotificationFilter로 쿼리 로직 캡슐화
- ✅ **Base UseCase Pattern**: 3가지 추상 클래스로 일관성 확보
- ✅ **Business Logic in Entity**: 7+ getter methods (isExpired, canBeRead, priority)
- ✅ **INotificationService**: Repository wrapper for broadcast stream
- ✅ **Idempotency**: eventId parameter in all write operations

**Architecture Pattern**:
```
Presentation → Domain (interfaces, entities, value objects) ← Data (implementations, services)
```

**Comparison with Other Features**:

| Aspect | Notifications | Chat | Voting |
|--------|--------------|------|--------|
| **Entity Pattern** | Sealed Union (3 types) | 2 separate entities | 6 entities |
| **Extension Files** | 4 (type-specific) | 2 | 6 |
| **Total Extension Lines** | 705 | 436 | ~700 |
| **Repository Methods** | 25+ | 20+ | 15+ |
| **UseCases** | 5 + 3 base classes | 10 | 5 |
| **Value Objects** | NotificationFilter | None | VoteFilter |
| **Service Interface** | Yes (8 methods) | None | Yes (4 methods) |

**Next Steps**:
- Presentation Layer 구현 (UI 위젯, Providers)
- Data Layer 검토 ([Data Layer README](/lib/features/notifications/data/README.md) 참조)
- Unit Tests 작성 (UseCases, Entities)
- Integration Tests (Repository 통합)

**Related Documentation**:
- [Data Layer README](/lib/features/notifications/data/README.md)
- [Chat Domain README](/lib/features/chat/domain/README.md)
- [Voting Domain README](/lib/features/voting/domain/README.md)
- [Clean Architecture v4.0 Guide](/docs/guides/CLEAN_ARCHITECTURE.md)
- [Freezed Usage Guide](/docs/guides/FREEZED_GUIDE.md)
