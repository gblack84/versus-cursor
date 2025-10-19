# Notifications Feature - Domain Layer

> **Version:** 2.0.0
> **Last Updated:** 2025-01-20
> **Architecture:** Clean Architecture v4.0 (Feature-First + Layered)

## 📋 개요

Notifications Feature의 Domain Layer는 **Clean Architecture의 핵심 비즈니스 로직**을 담당하며, 프레임워크와 완전히 독립적인 순수 Dart 코드로 구성됩니다.

### 핵심 원칙

```yaml
프레임워크 독립성: Firebase, Flutter 의존성 완전 제거
비즈니스 규칙 중심: 알림의 본질적 동작과 규칙만 정의
테스트 가능성: 모든 로직이 단위 테스트 가능
재사용성: 다른 플랫폼/프레임워크에서도 재사용 가능
```

### 핵심 기능

1. **도메인 모델 정의**
   - `Notification` 추상 클래스 (베이스 엔티티)
   - `SystemNotification` (시스템 알림)
   - `SocialNotification` (소셜 상호작용 알림)
   - VoteNotification은 Voting Feature에서 관리

2. **비즈니스 로직 캡슐화**
   - 알림 만료 검증 (`isExpired`)
   - 알림 읽음 처리 권한 검증
   - 자동 삭제 규칙 (30일 경과)
   - 그룹 알림 병합 로직

3. **UseCase 패턴**
   - 단일 책임 원칙에 따른 비즈니스 작업 분리
   - `Result<T>` 타입으로 안전한 에러 처리
   - 스트림 기반 실시간 알림 감시

4. **Value Objects**
   - `NotificationFilter` - 필터링 조건 캡슐화
   - 불변성(Immutable) 보장
   - 유효성 검증 내장

### 계층 분리 원칙

```
Domain Layer (이 레이어)
  ↓ 의존 (Interface)
Data Layer (구현체)
  ↓ 의존
Infrastructure (Firebase, SharedPrefs 등)
```

**중요:** Domain은 상위 계층에만 의존하며, 하위 계층(Data, Presentation)은 Domain에 의존합니다.

---

## 🗂️ 디렉토리 구조

```
lib/features/notifications/domain/
├── models/                           # 도메인 엔티티
│   ├── notification.dart             # 추상 베이스 엔티티
│   ├── system_notification.dart      # 시스템 알림 엔티티
│   └── social_notification.dart      # 소셜 알림 엔티티
│
├── repositories/                     # Repository 인터페이스
│   └── i_notification_repository.dart  # CRUD 및 쿼리 계약
│
├── usecases/                         # 비즈니스 유스케이스
│   ├── base/                         # 베이스 추상 클래스
│   │   ├── use_case.dart             # UseCase<Input, Output>
│   │   ├── stream_use_case.dart      # StreamUseCase<Input, Output>
│   │   └── no_param_use_case.dart    # NoParamUseCase<Output>
│   │
│   ├── watch_user_notifications_use_case.dart   # 실시간 알림 감시
│   ├── get_user_notifications_use_case.dart     # 알림 목록 조회
│   ├── watch_unread_count_use_case.dart         # 읽지 않은 개수 감시
│   ├── mark_as_read_use_case.dart               # 읽음 처리
│   └── send_notification_use_case.dart          # 알림 발송
│
├── value_objects/                    # Value Objects
│   └── notification_filter.dart      # 필터링 조건
│
└── services/                         # Domain Service 인터페이스
    └── i_notification_service.dart   # 알림 서비스 계약
```

---

## 🎯 Domain Models

### Notification (Abstract Base Class)

**위치:** `models/notification.dart`

**역할:** 모든 알림 타입의 공통 속성 및 비즈니스 로직 정의

**핵심 필드:**

```dart
abstract class Notification {
  final String id;              // 고유 식별자
  final String userId;          // 수신자 ID
  final String type;            // 알림 타입 ('systemAlert', 'social', 'votingRequest')
  final String title;           // 제목
  final String content;         // 내용
  final DateTime createdAt;     // 생성 시간
  final DateTime? readAt;       // 읽은 시간 (null이면 읽지 않음)
  final bool isRead;            // 읽음 여부
  final DateTime? expiryTime;   // 만료 시간 (null이면 만료 없음)
  final Map<String, dynamic> metadata;  // 추가 메타데이터
}
```

**비즈니스 로직 메서드:**

```dart
// 만료 여부 검증
bool get isExpired {
  if (expiryTime == null) return false;
  return DateTime.now().isAfter(expiryTime!);
}

// 읽을 수 있는지 확인
bool get canBeRead => !isRead && !isExpired;

// 30일 경과 시 자동 삭제 대상
bool get shouldAutoDelete {
  final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
  return daysSinceCreation > 30;
}

// 알림의 나이
Duration get age => DateTime.now().difference(createdAt);

// 최근 알림인지 (24시간 이내)
bool get isRecent => age.inHours < 24;

// 오래된 알림인지 (7일 이상)
bool get isOld => age.inDays >= 7;

// 우선순위 계산 (기본 구현)
int get priority {
  if (!isRead) return 1;  // 읽지 않은 알림
  return 0;               // 읽은 알림
}

// 읽음으로 표시 (각 구체 클래스에서 구현)
Notification markAsRead();
```

**열거형:**

```dart
// 알림 우선순위
enum NotificationPriority {
  low(1),
  medium(2),
  high(3),
  urgent(4);
}

// 알림 상태
enum NotificationStatus {
  pending,     // 대기 중
  sent,        // 발송됨
  delivered,   // 전달됨
  read,        // 읽음
  failed,      // 실패
  expired,     // 만료됨
}
```

### SystemNotification

**위치:** `models/system_notification.dart`

**역할:** 시스템 공지, 점검, 업데이트 등 시스템 관련 알림

**추가 필드:**

```dart
class SystemNotification extends Notification {
  final SystemAlertType alertType;   // 알림 유형
  final String? actionUrl;            // 액션 버튼 URL
  final String? actionLabel;          // 액션 버튼 레이블
  final Map<String, String>? actionButtons;  // 여러 액션 버튼
  final String? iconUrl;              // 아이콘 URL
  final bool isDismissible;           // 해제 가능 여부
}
```

**비즈니스 로직:**

```dart
// 액션이 필요한 알림인지
bool get requiresAction {
  return actionUrl != null || (actionButtons?.isNotEmpty ?? false);
}

// 중요도 레벨 (1-5)
int get importanceLevel {
  switch (alertType) {
    case SystemAlertType.critical:     return 5;
    case SystemAlertType.security:     return 4;
    case SystemAlertType.maintenance:  return 3;
    case SystemAlertType.update:       return 2;
    case SystemAlertType.info:         return 1;
  }
}

// 자동 해제 가능한지
bool get canAutoDismiss {
  return isDismissible && alertType != SystemAlertType.critical;
}

@override
SystemNotification markAsRead() {
  return SystemNotification(
    // ... 모든 필드 복사 with isRead: true, readAt: DateTime.now()
  );
}
```

**SystemAlertType 열거형:**

```dart
enum SystemAlertType {
  critical,      // 중요 시스템 알림
  security,      // 보안 관련
  maintenance,   // 점검 알림
  update,        // 업데이트 알림
  info,          // 일반 정보
}
```

**사용 예시:**

```dart
final systemAlert = SystemNotification(
  id: 'sys_001',
  userId: 'user123',
  createdAt: DateTime.now(),
  isRead: false,
  title: '서버 점검 안내',
  content: '2025-01-21 02:00-04:00 정기 점검이 예정되어 있습니다.',
  alertType: SystemAlertType.maintenance,
  actionUrl: 'https://status.example.com',
  actionLabel: '자세히 보기',
  isDismissible: true,
);

// 비즈니스 로직 활용
if (systemAlert.requiresAction) {
  print('중요도: ${systemAlert.importanceLevel}');
  print('자동 해제 가능: ${systemAlert.canAutoDismiss}');
}
```

### SocialNotification

**위치:** `models/social_notification.dart`

**역할:** 좋아요, 댓글, 친구 요청 등 사용자 간 상호작용 알림

**추가 필드:**

```dart
class SocialNotification extends Notification {
  final SocialActionType actionType;  // 액션 타입
  final String fromUserId;            // 액션 수행자 ID
  final String fromUserName;          // 액션 수행자 이름
  final String? fromUserProfileUrl;   // 프로필 이미지
  final String? relatedPostId;        // 관련 포스트 ID
  final String? relatedCommentId;     // 관련 댓글 ID
  final String? relatedContent;       // 관련 콘텐츠
  final int? interactionCount;        // 상호작용 수 (그룹 알림용)
}
```

**비즈니스 로직:**

```dart
// 상호작용이 있는 알림인지
bool get hasInteraction {
  return relatedPostId != null || relatedCommentId != null;
}

// 프로필 이미지가 있는지
bool get hasProfileImage {
  return fromUserProfileUrl != null && fromUserProfileUrl!.isNotEmpty;
}

// 그룹 알림인지 (여러 사용자의 동일 액션)
bool get isGroupNotification {
  return (interactionCount ?? 0) > 1;
}

// 친구 관련 알림인지
bool get isFriendRelated {
  return actionType == SocialActionType.friendRequest ||
         actionType == SocialActionType.friendAccepted;
}

// 포스트 관련 알림인지
bool get isPostRelated {
  return relatedPostId != null;
}

// 액션 버튼 텍스트
String get actionButtonText {
  switch (actionType) {
    case SocialActionType.friendRequest: return '수락';
    case SocialActionType.comment:       return '답글';
    case SocialActionType.mention:       return '보기';
    default:                             return '확인';
  }
}

// 알림 설명 텍스트 생성
String get descriptionText {
  if (isGroupNotification) {
    return '$fromUserName님 외 ${interactionCount! - 1}명이 ${_getActionText()}';
  }
  return '$fromUserName님이 ${_getActionText()}';
}

// 그룹 알림에 추가 상호작용 병합
SocialNotification addInteraction() {
  return SocialNotification(
    // ... 모든 필드 복사 with interactionCount: (interactionCount ?? 1) + 1
  );
}

@override
SocialNotification markAsRead() {
  return SocialNotification(
    // ... 모든 필드 복사 with isRead: true, readAt: DateTime.now()
  );
}
```

**SocialActionType 열거형:**

```dart
enum SocialActionType {
  like,             // 좋아요
  comment,          // 댓글
  friendRequest,    // 친구 요청
  friendAccepted,   // 친구 수락
  follow,           // 팔로우
  mention,          // 언급
  share,            // 공유
}
```

**사용 예시:**

```dart
// 단일 알림
final socialNotif = SocialNotification(
  id: 'social_001',
  userId: 'user123',
  createdAt: DateTime.now(),
  isRead: false,
  title: '새 좋아요',
  content: 'Alice님이 회원님의 게시물을 좋아합니다.',
  actionType: SocialActionType.like,
  fromUserId: 'alice_id',
  fromUserName: 'Alice',
  fromUserProfileUrl: 'https://...',
  relatedPostId: 'post_456',
);

// 그룹 알림 (여러 사용자가 동일 포스트에 좋아요)
final groupNotif = socialNotif.addInteraction();  // interactionCount: 2
final moreGroupNotif = groupNotif.addInteraction();  // interactionCount: 3

print(moreGroupNotif.descriptionText);
// "Alice님 외 2명이 좋아요를 눌렀습니다"

print(moreGroupNotif.actionButtonText);  // "확인"
```

---

## 📡 Repository Interface

### INotificationRepository

**위치:** `repositories/i_notification_repository.dart`

**역할:** Data Layer가 구현해야 할 계약 정의 (Dependency Inversion Principle)

**메서드 카테고리:**

#### 1. 조회 Operations

```dart
// 단일 알림 조회
Future<Notification?> getNotification(String notificationId);

// 사용자의 알림 목록 조회
Future<List<Notification>> getUserNotifications({
  required String userId,
  NotificationFilter? filter,
});

// 실시간 알림 스트림 감시
Stream<List<Notification>> watchUserNotifications({
  required String userId,
  NotificationFilter? filter,
});

// 읽지 않은 알림 개수 조회
Future<int> getUnreadCount(String userId);

// 읽지 않은 알림 개수 실시간 스트림
Stream<int> watchUnreadCount(String userId);

// 특정 타입의 알림만 조회
Future<List<T>> getNotificationsByType<T extends Notification>({
  required String userId,
  required String type,
  int? limit,
});
```

#### 2. 생성/수정 Operations

```dart
// 새 알림 생성
Future<String> createNotification(Notification notification);

// 알림 업데이트
Future<void> updateNotification(
  String notificationId,
  Map<String, dynamic> updates,
);

// 읽음 처리
Future<void> markAsRead(String notificationId);

// 모든 알림 읽음 처리
Future<void> markAllAsRead(String userId);
```

#### 3. 삭제 Operations

```dart
// 단일 알림 삭제
Future<void> deleteNotification(String notificationId);

// 사용자의 모든 알림 삭제
Future<void> deleteAllNotifications(String userId);

// 특정 날짜 이전 알림 삭제
Future<void> deleteOldNotifications({
  required String userId,
  required DateTime before,
});

// 만료된 알림 자동 삭제
Future<void> deleteExpiredNotifications(String userId);
Future<void> cleanupExpiredNotifications(String userId);  // 호환성 메서드
```

#### 4. 특수 Operations

```dart
// 시스템 알림 브로드캐스트 (전체 또는 특정 사용자들)
Future<void> broadcastSystemNotification({
  required SystemNotification notification,
  List<String>? targetUserIds,  // null이면 전체 사용자
});

// 소셜 알림 그룹화 처리
Future<void> groupSocialNotifications({
  required String userId,
  required SocialActionType actionType,
  required String relatedPostId,
});
```

#### 5. 통계 및 분석

```dart
// 알림 통계 조회
Future<Map<String, dynamic>> getNotificationStats(String userId);

// 알림 활동 로그
Future<List<Map<String, dynamic>>> getNotificationActivityLog({
  required String userId,
  required DateTime from,
  required DateTime to,
});
```

#### 6. 시스템 초기화

```dart
// 알림 시스템 초기화
Future<void> initializeNotificationSystem({
  required String userId,
});

// 알림 리스너 시작
Future<Stream<Notification>> startListening({
  required String userId,
});

// 알림 리스너 중지
Future<void> stopListening({
  required String userId,
});
```

**계약 준수 규칙:**

```dart
// ✅ Domain은 인터페이스만 정의
// ✅ Data Layer가 구현체 제공
// ✅ Presentation은 UseCase를 통해 사용
// ❌ Domain이 직접 Firebase/SharedPrefs 접근 금지
```

---

## 🎯 UseCases

### UseCase 패턴 기본 구조

**위치:** `usecases/base/use_case.dart`

**개념:** 단일 비즈니스 작업을 캡슐화하는 클래스

```dart
abstract class UseCase<Input, Output> {
  Future<Result<Output>> call(Input input);
}

class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result.success(this.data);
  const Result.failure(this.error);

  // 유틸리티 메서드
  T getOrThrow();
  T getOrElse(T defaultValue);
  Result<R> map<R>(R Function(T data) mapper);
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  });
}
```

**StreamUseCase 패턴:**

```dart
abstract class StreamUseCase<Input, Output> {
  Stream<Output> call(Input input);
}
```

### WatchUserNotificationsUseCase

**위치:** `usecases/watch_user_notifications_use_case.dart`

**역할:** 사용자의 실시간 알림 스트림 제공

**구현:**

```dart
class WatchUserNotificationsUseCase
    implements StreamUseCase<String, List<Notification>> {
  final INotificationRepository _repository;

  WatchUserNotificationsUseCase(this._repository);

  @override
  Stream<List<Notification>> call(String userId) {
    // 비즈니스 규칙: 만료된 알림은 기본적으로 제외
    return _repository.watchUserNotifications(
      userId: userId,
      filter: const NotificationFilter(
        excludeExpired: true,
      ),
    );
  }
}
```

**사용 예시:**

```dart
final useCase = WatchUserNotificationsUseCase(repository);

// 실시간 알림 감시
useCase.call('user123').listen((notifications) {
  print('받은 알림: ${notifications.length}개');
  for (final notif in notifications) {
    print('- ${notif.title}: ${notif.content}');
  }
});
```

### GetUserNotificationsUseCase

**위치:** `usecases/get_user_notifications_use_case.dart`

**역할:** 알림 목록 1회성 조회 (페이지네이션 지원)

**구현:**

```dart
class GetUserNotificationsUseCase
    implements UseCase<GetNotificationsParams, List<Notification>> {
  final INotificationRepository _repository;

  GetUserNotificationsUseCase(this._repository);

  @override
  Future<Result<List<Notification>>> call(GetNotificationsParams params) async {
    try {
      // 비즈니스 규칙: 유효한 userId 검증
      if (params.userId.isEmpty) {
        return const Result.failure('User ID is required');
      }

      // 비즈니스 규칙: limit 범위 검증
      if (params.limit != null && params.limit! <= 0) {
        return const Result.failure('Limit must be positive');
      }

      // Repository 호출
      final notifications = await _repository.getUserNotifications(
        userId: params.userId,
        filter: params.filter,
      );

      return Result.success(notifications);
    } catch (e) {
      return Result.failure('Failed to get notifications: $e');
    }
  }
}

class GetNotificationsParams {
  final String userId;
  final NotificationFilter? filter;

  const GetNotificationsParams({
    required this.userId,
    this.filter,
  });
}
```

### MarkAsReadUseCase

**위치:** `usecases/mark_as_read_use_case.dart`

**역할:** 알림 읽음 처리 with 권한 검증

**비즈니스 규칙:**

1. ✅ userId와 notificationId는 필수
2. ✅ 알림이 존재해야 함
3. ✅ 본인의 알림만 읽음 처리 가능
4. ✅ 이미 읽은 알림은 Idempotent 처리 (재호출 시 성공 반환)

**구현:**

```dart
class MarkAsReadUseCase implements UseCase<MarkAsReadParams, void> {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  @override
  Future<Result<void>> call(MarkAsReadParams params) async {
    try {
      // 비즈니스 규칙 1: 파라미터 검증
      if (params.userId.isEmpty || params.notificationId.isEmpty) {
        return const Result.failure(
          'Invalid parameters: userId and notificationId are required',
        );
      }

      // 비즈니스 규칙 2: 알림 존재 확인
      final notification = await _repository.getNotification(
        params.notificationId,
      );

      if (notification == null) {
        return const Result.failure('Notification not found');
      }

      // 비즈니스 규칙 3: 권한 검증
      if (notification.userId != params.userId) {
        return const Result.failure(
          'Unauthorized: Cannot mark other user\'s notification as read',
        );
      }

      // 비즈니스 규칙 4: Idempotent 처리
      if (notification.isRead) {
        return const Result.success(null);  // 이미 읽음
      }

      // Repository 호출
      await _repository.markAsRead(params.notificationId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to mark as read: $e');
    }
  }
}

class MarkAsReadParams {
  final String notificationId;
  final String userId;

  const MarkAsReadParams({
    required this.notificationId,
    required this.userId,
  });
}
```

**사용 예시:**

```dart
final useCase = MarkAsReadUseCase(repository);

final result = await useCase.call(
  MarkAsReadParams(
    notificationId: 'notif_123',
    userId: 'user_456',
  ),
);

result.fold(
  onSuccess: (_) => print('읽음 처리 완료'),
  onFailure: (error) => print('에러: $error'),
);
```

### WatchUnreadCountUseCase

**위치:** `usecases/watch_unread_count_use_case.dart`

**역할:** 읽지 않은 알림 개수 실시간 추적 (뱃지 표시용)

**구현:**

```dart
class WatchUnreadCountUseCase implements StreamUseCase<String, int> {
  final INotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  @override
  Stream<int> call(String userId) {
    return _repository.watchUnreadCount(userId);
  }
}
```

**사용 예시:**

```dart
final useCase = WatchUnreadCountUseCase(repository);

// NotificationBadgeProvider에서 사용
useCase.call('user123').listen((count) {
  print('읽지 않은 알림: $count개');
  // UI 뱃지 업데이트
});
```

---

## 📦 Value Objects

### NotificationFilter

**위치:** `value_objects/notification_filter.dart`

**역할:** 알림 필터링 조건을 캡슐화하는 불변 객체

**필드:**

```dart
class NotificationFilter {
  final String? type;             // 타입 필터
  final bool? unreadOnly;         // 읽지 않은 것만
  final DateTime? after;          // 이후 생성
  final DateTime? before;         // 이전 생성
  final int? limit;               // 최대 개수
  final String? sortBy;           // 정렬 기준 (기본: 'createdAt')
  final bool? excludeExpired;     // 만료된 것 제외
  final String? userId;           // 사용자 ID
  final SortOrder? sortOrder;     // 정렬 순서 (기본: descending)
}
```

**팩토리 메서드:**

```dart
// 읽지 않은 + 활성 알림만
factory NotificationFilter.unreadActive() {
  return const NotificationFilter(
    unreadOnly: true,
    excludeExpired: true,
    sortOrder: SortOrder.descending,
  );
}

// 최근 N일 이내 알림
factory NotificationFilter.recent({int days = 30, int limit = 50}) {
  return NotificationFilter(
    after: DateTime.now().subtract(Duration(days: days)),
    sortOrder: SortOrder.descending,
    limit: limit,
  );
}

// 읽지 않은 알림만
factory NotificationFilter.unreadOnly() {
  return const NotificationFilter(unreadOnly: true);
}

// 특정 타입만
factory NotificationFilter.byType(String type) {
  return NotificationFilter(type: type);
}
```

**비즈니스 로직:**

```dart
// 필터가 적용되었는지 확인
bool get hasFilters {
  return type != null ||
         unreadOnly != null ||
         after != null ||
         before != null ||
         limit != null ||
         excludeExpired != null ||
         userId != null;
}

// 날짜 범위 유효성 검증
bool get isDateRangeValid {
  if (after == null || before == null) return true;
  return after!.isBefore(before!);
}

// 필터 복사 및 수정 (Immutable)
NotificationFilter copyWith({
  String? type,
  bool? unreadOnly,
  // ... 나머지 필드
});
```

**사용 예시:**

```dart
// 최근 7일, 읽지 않은 시스템 알림만
final filter = NotificationFilter.recent(days: 7).copyWith(
  type: 'systemAlert',
  unreadOnly: true,
);

// Repository에 전달
final notifications = await repository.getUserNotifications(
  userId: 'user123',
  filter: filter,
);
```

**SortOrder 열거형:**

```dart
enum SortOrder {
  ascending('asc'),
  descending('desc');
}
```

---

## 🔌 Domain Services

### INotificationService

**위치:** `services/i_notification_service.dart`

**역할:** Domain에서 정의하는 알림 서비스 계약 (Data Layer에서 구현)

**메서드:**

```dart
abstract class INotificationService {
  /// 알림 스트림 (NotificationQueueService를 통해 실시간 전달)
  Stream<List<Notification>> get notificationsStream;

  /// 알림 리스닝 시작
  void startListening(String userId, {String? type});

  /// 알림 리스닝 중지
  void stopListening();

  /// 읽지 않은 알림 수 실시간 스트림
  Stream<int> getUnreadNotificationCount(String userId);

  /// 알림 읽음 처리
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

  /// 리소스 정리
  void dispose();
}
```

**사용 시나리오:**

```dart
// NotificationService (Data Layer 구현체)를 통해
// NotificationQueueService와 Repository를 연결

final notificationService = getIt<INotificationService>();

// 리스닝 시작
notificationService.startListening('user123', type: null);

// 실시간 알림 스트림 구독
notificationService.notificationsStream.listen((notifications) {
  // UI로 알림 표시
});

// 리스닝 중지
notificationService.stopListening();
```

**통합 구조:**

```
[INotificationService (Domain)]
        ↓ 구현
[NotificationService (Data/Adapters)]
        ↓ 사용
[NotificationQueueService (/services)]
        ↓ 스트림 제공
[Presentation Layer]
```

---

## 📊 비즈니스 규칙 정리

### 알림 생명주기 규칙

```yaml
생성:
  - 모든 알림은 isRead: false로 시작
  - createdAt은 자동 설정 (서버 시간)
  - expiryTime은 선택적 (null이면 만료 없음)

읽음 처리:
  - 본인의 알림만 읽음 처리 가능 (권한 검증)
  - 이미 읽은 알림 재호출 시 Idempotent 처리
  - readAt 자동 설정

만료 처리:
  - expiryTime이 현재 시간보다 이전이면 만료
  - 만료된 알림은 canBeRead: false
  - 만료된 알림은 기본 필터에서 제외

자동 삭제:
  - 생성 후 30일 경과 시 shouldAutoDelete: true
  - 백그라운드 작업으로 주기적 정리
```

### 소셜 알림 그룹화 규칙

```yaml
그룹화 조건:
  - 동일 사용자, 동일 액션 타입, 동일 포스트
  - 24시간 이내 발생한 알림

그룹화 동작:
  - interactionCount 증가
  - 기존 알림 업데이트 (새 알림 생성 안 함)
  - fromUserName은 최초 사용자 유지

그룹 해제:
  - 24시간 경과 시 새 알림으로 생성
```

### 시스템 알림 브로드캐스트 규칙

```yaml
전체 발송:
  - targetUserIds: null → 모든 활성 사용자
  - 비활성 사용자(30일 이상) 제외

선택 발송:
  - targetUserIds: ['user1', 'user2'] → 특정 사용자만
  - 유효하지 않은 userId는 스킵

우선순위:
  - critical: 즉시 푸시 + 앱 내
  - security: 즉시 푸시 + 앱 내
  - maintenance: 앱 내만
  - update: 앱 내만
  - info: 앱 내만
```

### 읽지 않은 알림 카운트 규칙

```yaml
포함 조건:
  - isRead: false
  - !isExpired
  - expiryTime == null || expiryTime > now

제외 조건:
  - isRead: true
  - isExpired: true

업데이트 타이밍:
  - 새 알림 생성 시 +1
  - 알림 읽음 처리 시 -1
  - 알림 만료 시 -1
  - 알림 삭제 시 -1
```

---

## 🧪 테스트 전략

### 도메인 모델 테스트

```dart
group('Notification Domain Model', () {
  test('isExpired는 expiryTime 이후면 true를 반환한다', () {
    final notification = SystemNotification(
      id: 'test',
      userId: 'user1',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
      title: 'Test',
      content: 'Test',
      alertType: SystemAlertType.info,
      expiryTime: DateTime.now().subtract(Duration(hours: 1)),
    );

    expect(notification.isExpired, true);
  });

  test('canBeRead는 읽지 않고 만료되지 않은 경우에만 true', () {
    final notification = SystemNotification(
      id: 'test',
      userId: 'user1',
      createdAt: DateTime.now(),
      isRead: false,
      title: 'Test',
      content: 'Test',
      alertType: SystemAlertType.info,
      expiryTime: DateTime.now().add(Duration(hours: 1)),
    );

    expect(notification.canBeRead, true);
  });

  test('shouldAutoDelete는 30일 경과 시 true', () {
    final notification = SystemNotification(
      id: 'test',
      userId: 'user1',
      createdAt: DateTime.now().subtract(Duration(days: 31)),
      isRead: false,
      title: 'Test',
      content: 'Test',
      alertType: SystemAlertType.info,
    );

    expect(notification.shouldAutoDelete, true);
  });
});
```

### UseCase 테스트

```dart
group('MarkAsReadUseCase', () {
  late MockNotificationRepository mockRepository;
  late MarkAsReadUseCase useCase;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = MarkAsReadUseCase(mockRepository);
  });

  test('본인 알림은 읽음 처리 성공', () async {
    // Arrange
    final notification = SystemNotification(
      id: 'notif1',
      userId: 'user1',
      createdAt: DateTime.now(),
      isRead: false,
      title: 'Test',
      content: 'Test',
      alertType: SystemAlertType.info,
    );

    when(() => mockRepository.getNotification('notif1'))
      .thenAnswer((_) async => notification);
    when(() => mockRepository.markAsRead('notif1'))
      .thenAnswer((_) async => {});

    // Act
    final result = await useCase.call(MarkAsReadParams(
      notificationId: 'notif1',
      userId: 'user1',
    ));

    // Assert
    expect(result.isSuccess, true);
    verify(() => mockRepository.markAsRead('notif1')).called(1);
  });

  test('다른 사용자 알림은 권한 에러', () async {
    // Arrange
    final notification = SystemNotification(
      id: 'notif1',
      userId: 'user1',
      createdAt: DateTime.now(),
      isRead: false,
      title: 'Test',
      content: 'Test',
      alertType: SystemAlertType.info,
    );

    when(() => mockRepository.getNotification('notif1'))
      .thenAnswer((_) async => notification);

    // Act
    final result = await useCase.call(MarkAsReadParams(
      notificationId: 'notif1',
      userId: 'user2',  // 다른 사용자
    ));

    // Assert
    expect(result.isFailure, true);
    expect(result.error, contains('Unauthorized'));
    verifyNever(() => mockRepository.markAsRead(any()));
  });

  test('이미 읽은 알림은 Idempotent 처리', () async {
    // Arrange
    final notification = SystemNotification(
      id: 'notif1',
      userId: 'user1',
      createdAt: DateTime.now(),
      isRead: true,  // 이미 읽음
      readAt: DateTime.now(),
      title: 'Test',
      content: 'Test',
      alertType: SystemAlertType.info,
    );

    when(() => mockRepository.getNotification('notif1'))
      .thenAnswer((_) async => notification);

    // Act
    final result = await useCase.call(MarkAsReadParams(
      notificationId: 'notif1',
      userId: 'user1',
    ));

    // Assert
    expect(result.isSuccess, true);
    verifyNever(() => mockRepository.markAsRead(any()));  // 호출 안 함
  });
});
```

### Value Object 테스트

```dart
group('NotificationFilter', () {
  test('hasFilters는 필터 적용 시 true', () {
    final filter = NotificationFilter(unreadOnly: true);
    expect(filter.hasFilters, true);
  });

  test('isDateRangeValid는 올바른 범위일 때 true', () {
    final filter = NotificationFilter(
      after: DateTime(2025, 1, 1),
      before: DateTime(2025, 1, 31),
    );
    expect(filter.isDateRangeValid, true);
  });

  test('isDateRangeValid는 잘못된 범위일 때 false', () {
    final filter = NotificationFilter(
      after: DateTime(2025, 1, 31),
      before: DateTime(2025, 1, 1),
    );
    expect(filter.isDateRangeValid, false);
  });

  test('copyWith는 불변성을 유지하며 복사한다', () {
    final original = NotificationFilter.unreadActive();
    final modified = original.copyWith(limit: 10);

    expect(original.limit, null);
    expect(modified.limit, 10);
    expect(modified.unreadOnly, true);  // 기존 값 유지
  });
});
```

---

## 🔗 관련 문서

### Feature 내부 문서
- [Data Layer](../data/README.md) - Repository 구현 및 DataSource
- [Presentation Layer](../presentation/README.md) - UI 컴포넌트
- [Feature Root](../README.md) - Notifications Feature 전체 개요

### 다른 Feature와의 통합
- [Voting Feature](../../voting/domain/README.md) - VoteNotification 타입 처리
- [App Layer Contracts](../../../../app/contracts/README.md) - NotificationContract 인터페이스

### 프로젝트 전체 문서
- [Clean Architecture Guide](../../../../docs/architecture/clean-architecture.md)
- [Domain Layer Best Practices](../../../../docs/architecture/domain-layer.md)
- [UseCase Pattern Guide](../../../../docs/patterns/use-case-pattern.md)

---

## 📝 변경 이력

### v2.0.0 (2025-01-20)
- ✅ Domain Layer README.md 신규 작성
- ✅ 모든 비즈니스 로직 문서화
- ✅ UseCase 패턴 상세 설명
- ✅ Value Object 활용 가이드
- ✅ 테스트 전략 및 예시 추가

### v1.3.0 (2025-01-18)
- INotificationService 인터페이스 추가
- NotificationQueueService 통합 준비
- Domain Service 개념 도입

### v1.2.0 (2025-01-15)
- NotificationFilter Value Object 추가
- 비즈니스 규칙 강화 (권한 검증, Idempotent 처리)
- Result<T> 타입 도입으로 안전한 에러 처리

### v1.1.0 (2025-01-10)
- SystemNotification, SocialNotification 구체 클래스 추가
- 비즈니스 로직 메서드 추가 (isExpired, canBeRead 등)
- UseCase 패턴 적용

### v1.0.0 (2025-01-05)
- 초기 Domain Layer 구현
- Notification 추상 클래스 정의
- INotificationRepository 인터페이스 정의

---

## 👥 기여자

- Feature Owner: Backend Team
- Architecture Lead: Clean Architecture Team
- Domain Expert: Business Logic Team

**마지막 업데이트:** 2025-01-20
**문서 버전:** 2.0.0
