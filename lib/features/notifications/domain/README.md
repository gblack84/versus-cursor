# 🎯 Notifications Domain Layer

> **Version**: 2.0.0  
> **Last Updated**: 2025-09-12  
> **Architecture**: Clean Architecture Domain Layer  
> **Status**: ✅ Production Ready | Zero External Dependencies

## 📋 목차

1. [개요](#개요)
2. [아키텍처 원칙](#아키텍처-원칙)
3. [디렉토리 구조](#디렉토리-구조)
4. [핵심 컴포넌트](#핵심-컴포넌트)
5. [비즈니스 규칙](#비즈니스-규칙)
6. [Use Cases 목록](#use-cases-목록)
7. [의존성 규칙](#의존성-규칙)
8. [사용 가이드](#사용-가이드)
9. [확장 가이드](#확장-가이드)
10. [테스트 전략](#테스트-전략)

---

## 개요

Notifications Domain Layer는 알림 시스템의 핵심 비즈니스 로직을 담당하는 레이어입니다. Clean Architecture의 중심부로서, 외부 프레임워크나 라이브러리에 대한 의존성이 전혀 없는 순수한 Dart 코드로 구성됩니다.

### 🎯 핵심 책임
- **비즈니스 규칙 정의**: 알림 처리, 우선순위, 필터링 로직
- **도메인 모델 관리**: Notification, VoteNotification 등 핵심 엔티티
- **Use Case 구현**: 비즈니스 시나리오별 실행 로직
- **인터페이스 정의**: Repository, Service 등의 계약 정의

### 🏆 설계 원칙
- **독립성**: 외부 의존성 없음 (Flutter, Firebase 등)
- **테스트 가능성**: 100% 단위 테스트 가능
- **재사용성**: 플랫폼 독립적 비즈니스 로직
- **명확성**: 비즈니스 용어와 일치하는 네이밍

---

## 아키텍처 원칙

### Clean Architecture 준수
```
┌─────────────────────────────────────┐
│         Presentation Layer          │
├─────────────────────────────────────┤
│           Domain Layer              │ ← 현재 레이어
│   (비즈니스 로직, 엔티티, 규칙)      │
├─────────────────────────────────────┤
│            Data Layer               │
└─────────────────────────────────────┘
```

### 의존성 방향
- **Presentation** → Domain (허용)
- **Data** → Domain (허용)
- **Domain** → 외부 (❌ 금지)
- **Domain** → 순수 Dart (✅ 허용)

---

## 디렉토리 구조

```
lib/features/notifications/domain/
│
├── 📁 handlers/                    # 핸들러 인터페이스
│   └── i_notification_handler.dart    # UI 표시 핸들러 계약
│
├── 📁 models/                      # 도메인 엔티티
│   ├── notification.dart              # 기본 알림 모델
│   ├── notification_display_data.dart # 표시용 데이터 모델
│   ├── social_notification.dart       # 소셜 알림 모델
│   ├── system_notification.dart       # 시스템 알림 모델
│   └── vote_notification.dart         # 투표 알림 모델
│
├── 📁 repositories/                # Repository 인터페이스
│   └── i_notification_repository.dart # 데이터 접근 계약
│
├── 📁 services/                    # 도메인 서비스
│   └── i_notification_service.dart    # 알림 서비스 계약
│
├── 📁 usecases/                    # 비즈니스 Use Cases
│   ├── 📁 base/                   # Use Case 추상 클래스
│   │   ├── use_case.dart             # 기본 Use Case
│   │   ├── no_param_use_case.dart    # 파라미터 없는 Use Case
│   │   └── stream_use_case.dart      # Stream Use Case
│   │
│   ├── clear_queue_use_case.dart              # 큐 초기화
│   ├── get_current_user_use_case.dart         # 현재 사용자 조회
│   ├── get_post_data_use_case.dart            # 포스트 데이터 조회
│   ├── get_processed_count_use_case.dart      # 처리된 알림 수
│   ├── get_queue_status_use_case.dart         # 큐 상태 조회
│   ├── get_unread_notification_count.dart     # 읽지 않은 알림 수
│   ├── get_user_notifications_use_case.dart   # 사용자 알림 목록
│   ├── initialize_notifications_use_case.dart # 알림 초기화
│   ├── mark_as_read_use_case.dart            # 읽음 처리
│   ├── process_vote_notification_use_case.dart # 투표 알림 처리
│   ├── send_notification_use_case.dart        # 알림 전송
│   ├── start_notification_listening_use_case.dart # 리스닝 시작
│   ├── stop_notification_listening_use_case.dart  # 리스닝 중지
│   └── watch_unread_count_use_case.dart      # 읽지 않은 수 감시
│
└── 📁 value_objects/               # 값 객체
    ├── notification_filter.dart       # 필터링 조건
    └── vote_options.dart              # 투표 옵션
```

---

## 핵심 컴포넌트

### 1. Domain Models (엔티티)

#### Notification (기본 알림)
```dart
abstract class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  
  // 비즈니스 메서드
  bool isExpired();
  int getPriority();
  bool shouldShowInUI();
}
```

#### VoteNotification (투표 알림)
```dart
class VoteNotification extends Notification {
  final String postId;
  final String senderId;
  final VoteOptions options;
  final DateTime voteDeadline;
  
  // 투표 관련 비즈니스 로직
  bool isVotingOpen();
  Duration getRemainingTime();
  bool canUserVote(String userId);
}
```

#### NotificationDisplayData (표시 데이터)
```dart
class NotificationDisplayData {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Map<String, dynamic> actionData;
  final NotificationPriority priority;
  
  // UI 표시 관련 로직
  Color getBackgroundColor();
  IconData getIcon();
  String getFormattedTime();
}
```

### 2. Repository Interface

```dart
abstract class INotificationRepository {
  // 기본 CRUD
  Future<void> createNotification(Notification notification);
  Future<Notification?> getNotification(String id);
  Future<List<Notification>> getNotifications(String userId);
  Future<void> updateNotification(String id, Map<String, dynamic> data);
  Future<void> deleteNotification(String id);
  
  // 비즈니스 연산
  Future<List<Notification>> getUnreadNotifications(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  
  // 실시간 기능
  Stream<List<Notification>> watchNotifications(String userId);
  Stream<int> watchUnreadCount(String userId);
  
  // 필터링 및 검색
  Future<List<Notification>> searchNotifications(
    String userId,
    NotificationFilter filter,
  );
}
```

### 3. Service Interface

```dart
abstract class INotificationService {
  // 알림 처리
  Future<void> processNotification(Notification notification);
  Future<void> sendNotification(NotificationRequest request);
  
  // 투표 관련
  Future<void> createVoteRequestChatMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required IContentModel post,
  });
  
  // 큐 관리
  void enqueueNotification(Notification notification);
  Future<void> processQueue();
  void clearQueue();
  
  // 리스닝
  Stream<Notification> listenToNotifications(String userId);
  void stopListening();
}
```

### 4. Handler Interface

```dart
abstract class INotificationHandler {
  // UI 표시
  Future<void> showNotification(NotificationDisplayData data);
  Future<void> hideNotification();
  
  // 사용자 액션
  Future<void> handleNotificationTap(String notificationId);
  Future<void> handleQuickAction(String action, Map<String, dynamic> data);
  
  // 상태 관리
  bool isShowingNotification();
  NotificationDisplayData? getCurrentNotification();
}
```

---

## 비즈니스 규칙

### 알림 우선순위
```dart
enum NotificationPriority {
  critical,  // 즉시 표시, 사용자 방해 허용
  high,      // 빠른 표시, 큐 앞쪽 배치
  normal,    // 일반 표시, 순서대로 처리
  low,       // 지연 가능, 유휴 시간에 표시
}
```

### 알림 만료 규칙
- **투표 알림**: 투표 마감 시간까지
- **시스템 알림**: 30일
- **소셜 알림**: 7일
- **일반 알림**: 14일

### 표시 조건
```dart
bool shouldShowNotification(Notification notification) {
  return !notification.isExpired() &&
         !notification.isRead &&
         notification.userId == currentUserId &&
         !isUserInDoNotDisturbMode();
}
```

### 큐 처리 규칙
1. Critical 우선순위 먼저 처리
2. 같은 우선순위면 시간순
3. 최대 큐 크기: 100개
4. 처리 간격: 최소 2초

---

## Use Cases 목록

### 조회 Use Cases
| Use Case | 설명 | 파라미터 | 반환값 |
|----------|------|----------|--------|
| GetUserNotificationsUseCase | 사용자 알림 목록 조회 | userId, filter | List<Notification> |
| GetUnreadNotificationCountUseCase | 읽지 않은 알림 수 | userId | int |
| GetQueueStatusUseCase | 큐 상태 조회 | - | QueueStatus |
| GetProcessedCountUseCase | 처리된 알림 수 | - | int |
| GetCurrentUserUseCase | 현재 사용자 정보 | - | User |
| GetPostDataUseCase | 포스트 데이터 조회 | postId | PostData |

### 실행 Use Cases
| Use Case | 설명 | 파라미터 | 반환값 |
|----------|------|----------|--------|
| SendNotificationUseCase | 알림 전송 | NotificationRequest | void |
| ProcessVoteNotificationUseCase | 투표 알림 처리 | VoteNotification | void |
| MarkAsReadUseCase | 읽음 처리 | notificationId | void |
| ClearQueueUseCase | 큐 초기화 | - | void |
| InitializeNotificationsUseCase | 알림 시스템 초기화 | userId | void |

### Stream Use Cases
| Use Case | 설명 | 파라미터 | 반환값 |
|----------|------|----------|--------|
| StartNotificationListeningUseCase | 실시간 리스닝 시작 | userId | Stream<Notification> |
| WatchUnreadCountUseCase | 읽지 않은 수 감시 | userId | Stream<int> |
| StopNotificationListeningUseCase | 리스닝 중지 | - | void |

---

## 의존성 규칙

### ✅ 허용된 의존성
```dart
// 순수 Dart 패키지
import 'dart:async';
import 'dart:collection';
import 'dart:math';

// 도메인 레이어 내부
import 'models/notification.dart';
import 'repositories/i_notification_repository.dart';
import 'usecases/base/use_case.dart';

// Core 도메인 (shared)
import '/core/domain/models/result.dart';
import '/core/domain/errors/failure.dart';
```

### ❌ 금지된 의존성
```dart
// 외부 프레임워크
import 'package:flutter/material.dart';  // 금지!
import 'package:firebase_core/firebase_core.dart';  // 금지!

// 다른 레이어
import '../data/...';  // 금지!
import '../presentation/...';  // 금지!

// 다른 피처
import '/features/posts/...';  // 금지!
import '/features/voting/...';  // 금지!
```

---

## 사용 가이드

### 1. Use Case 실행
```dart
// Use Case 인스턴스 생성 (DI 사용)
final getNotifications = getIt<GetUserNotificationsUseCase>();

// 실행
final result = await getNotifications.execute(
  GetNotificationsParams(
    userId: 'user123',
    filter: NotificationFilter.unreadOnly(),
  ),
);

// 결과 처리
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (notifications) => print('Got ${notifications.length} notifications'),
);
```

### 2. Stream Use Case 사용
```dart
// Stream Use Case 실행
final watchUnread = getIt<WatchUnreadCountUseCase>();

// 구독
final subscription = watchUnread.execute('user123').listen(
  (count) => print('Unread count: $count'),
  onError: (error) => print('Error: $error'),
);

// 정리
await subscription.cancel();
```

### 3. 비즈니스 로직 활용
```dart
// 도메인 모델의 비즈니스 메서드 사용
final notification = VoteNotification(...);

if (notification.isVotingOpen()) {
  final remaining = notification.getRemainingTime();
  print('${remaining.inMinutes} minutes left to vote');
}

// 우선순위 기반 정렬
notifications.sort((a, b) => b.getPriority().compareTo(a.getPriority()));
```

---

## 확장 가이드

### 🎯 새로운 알림 타입 추가

#### 1. 도메인 모델 정의
```dart
// models/event_notification.dart
class EventNotification extends Notification {
  final String eventId;
  final DateTime eventDate;
  final String location;
  final List<String> attendees;
  
  EventNotification({
    required super.id,
    required super.userId,
    required this.eventId,
    required this.eventDate,
    required this.location,
    this.attendees = const [],
  });
  
  // 비즈니스 로직
  bool isEventPassed() => DateTime.now().isAfter(eventDate);
  bool isUserAttending(String userId) => attendees.contains(userId);
  Duration getTimeUntilEvent() => eventDate.difference(DateTime.now());
}
```

#### 2. Use Case 구현
```dart
// usecases/process_event_notification_use_case.dart
class ProcessEventNotificationUseCase extends UseCase<void, EventNotification> {
  final INotificationRepository repository;
  final INotificationService service;
  
  ProcessEventNotificationUseCase(this.repository, this.service);
  
  @override
  Future<Result<void>> execute(EventNotification params) async {
    try {
      // 비즈니스 규칙 검증
      if (params.isEventPassed()) {
        return Result.failure(
          BusinessFailure('Cannot process notification for past event'),
        );
      }
      
      // 처리 로직
      await repository.createNotification(params);
      await service.processNotification(params);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure(e.toString()));
    }
  }
}
```

#### 3. Repository 메서드 추가
```dart
// Repository 인터페이스에 추가
abstract class INotificationRepository {
  // 기존 메서드들...
  
  // Event 관련 메서드
  Future<List<EventNotification>> getUpcomingEvents(String userId);
  Future<void> updateAttendance(String eventId, List<String> attendees);
}
```

### 🔧 새로운 비즈니스 규칙 추가

```dart
// value_objects/notification_rules.dart
class NotificationRules {
  static const int maxNotificationsPerDay = 50;
  static const Duration minIntervalBetweenNotifications = Duration(seconds: 5);
  static const int maxRetryAttempts = 3;
  
  static bool canSendNotification(User user, DateTime lastSent) {
    final now = DateTime.now();
    final timeSinceLastSent = now.difference(lastSent);
    
    return timeSinceLastSent >= minIntervalBetweenNotifications &&
           user.dailyNotificationCount < maxNotificationsPerDay &&
           !user.isInQuietHours(now);
  }
}
```

---

## 테스트 전략

### 단위 테스트
```dart
// test/domain/models/notification_test.dart
void main() {
  group('VoteNotification', () {
    test('should calculate remaining time correctly', () {
      final deadline = DateTime.now().add(Duration(hours: 2));
      final notification = VoteNotification(
        voteDeadline: deadline,
        // ... other fields
      );
      
      final remaining = notification.getRemainingTime();
      
      expect(remaining.inMinutes, closeTo(120, 1));
    });
    
    test('should identify expired notifications', () {
      final pastDeadline = DateTime.now().subtract(Duration(hours: 1));
      final notification = VoteNotification(
        voteDeadline: pastDeadline,
        // ... other fields
      );
      
      expect(notification.isVotingOpen(), isFalse);
      expect(notification.isExpired(), isTrue);
    });
  });
}
```

### Use Case 테스트
```dart
// test/domain/usecases/send_notification_use_case_test.dart
void main() {
  late SendNotificationUseCase useCase;
  late MockNotificationRepository mockRepository;
  late MockNotificationService mockService;
  
  setUp(() {
    mockRepository = MockNotificationRepository();
    mockService = MockNotificationService();
    useCase = SendNotificationUseCase(mockRepository, mockService);
  });
  
  test('should send notification successfully', () async {
    // Arrange
    final request = NotificationRequest(
      userId: 'user123',
      title: 'Test',
      message: 'Test message',
    );
    
    when(() => mockService.sendNotification(any()))
        .thenAnswer((_) async => {});
    
    // Act
    final result = await useCase.execute(request);
    
    // Assert
    expect(result.isSuccess, isTrue);
    verify(() => mockService.sendNotification(request)).called(1);
  });
}
```

### 비즈니스 규칙 테스트
```dart
// test/domain/value_objects/notification_rules_test.dart
void main() {
  group('NotificationRules', () {
    test('should prevent sending when daily limit exceeded', () {
      final user = User(
        id: 'user123',
        dailyNotificationCount: 50,
      );
      final lastSent = DateTime.now().subtract(Duration(minutes: 1));
      
      final canSend = NotificationRules.canSendNotification(user, lastSent);
      
      expect(canSend, isFalse);
    });
  });
}
```

---

## 🚀 Best Practices

### DO's ✅
- 비즈니스 로직을 도메인 모델에 캡슐화
- Use Case는 단일 책임 원칙 준수
- 도메인 용어를 코드에 반영
- 불변 객체(Immutable) 사용
- 순수 함수 작성

### DON'ts ❌
- UI 로직을 도메인에 포함시키지 마세요
- 외부 라이브러리 의존성 추가 금지
- 데이터 소스 직접 접근 금지
- 플랫폼 특정 코드 작성 금지
- 도메인 모델에 JSON 시리얼라이제이션 추가 금지

---

## 📞 연락처 및 지원

- **Feature Owner**: Notifications Team
- **Domain Expert**: Business Analysis Team
- **아키텍처 질문**: Architecture Team
- **문서 업데이트**: PR을 통해 제출

---

## 📚 관련 문서

- [Data Layer README](../data/README.md)
- [Presentation Layer README](../presentation/README.md)
- [Clean Architecture Guide](../../../../docs/ARCHITECTURE.md)
- [Use Case Patterns](../../../../docs/patterns/USE_CASE_PATTERNS.md)

---

*이 문서는 Clean Architecture 마이그레이션 완료 후 작성되었습니다.*
*Last reviewed: 2025-09-12*