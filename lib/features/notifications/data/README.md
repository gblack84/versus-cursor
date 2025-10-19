# Notifications Feature - Data Layer

> **Version:** 2.0.0
> **Last Updated:** 2025-01-20
> **Architecture:** Clean Architecture v4.0 (Feature-First + Layered)

## 📋 개요

Notifications Feature의 Data Layer는 **Clean Architecture의 Data Layer 원칙**을 따르며, 알림 데이터의 영속성과 외부 데이터 소스 통합을 담당합니다.

### 핵심 기능

1. **범용 알림 시스템**
   - System Alert, Social Notification 타입 지원
   - VoteNotification은 Voting Feature에서 관리
   - 타입 기반 필터링 및 쿼리 시스템

2. **듀얼 데이터소스 전략**
   - **Remote (Firebase)**: 실시간 알림 스트림 및 영구 저장
   - **Local (SharedPrefs)**: 오프라인 캐싱 및 사용자 설정 저장

3. **계약 기반 통합**
   - `NotificationContract` 구현으로 다른 Feature와 통신
   - `NotificationQueueService` 통합으로 실시간 알림 표시

4. **성능 최적화**
   - 30분 캐시 만료 시간
   - 최대 100개 알림 캐싱
   - 스트림 재사용으로 중복 구독 방지

### 주요 설계 원칙

```yaml
단일 책임: 각 클래스는 하나의 데이터 관련 작업만 수행
의존성 역전: Repository가 인터페이스를 구현, Domain이 정의
데이터 격리: Firebase/SharedPrefs 세부사항이 Repository 외부로 노출되지 않음
타입 안전성: DTO 패턴으로 Data ↔ Domain 경계 명확화
```

---

## 🗂️ 디렉토리 구조

```
lib/features/notifications/data/
├── datasources/                      # 데이터 소스 계층
│   ├── i_local_notification_datasource.dart    # Local 인터페이스
│   ├── i_remote_notification_datasource.dart   # Remote 인터페이스
│   ├── local/
│   │   └── shared_prefs_notification_datasource.dart  # SharedPrefs 구현
│   └── remote/
│       └── firebase_notification_datasource.dart      # Firebase 구현
│
├── models/                           # DTO (Data Transfer Objects)
│   ├── notification_dto.dart         # 베이스 DTO
│   ├── social_notification_dto.dart  # Social 알림 DTO
│   ├── system_notification_dto.dart  # System 알림 DTO
│   └── dto_extensions.dart           # DTO 헬퍼 확장
│
├── mappers/                          # Domain ↔ DTO 변환
│   └── notification_mapper.dart      # 양방향 매핑 로직
│
├── repositories/                     # Repository 구현
│   └── notification_repository_impl.dart  # Repository + Contract 구현
│
└── adapters/                         # 서비스 어댑터
    └── notification_service.dart     # NotificationQueueService 통합
```

---

## 🔌 Repositories

### NotificationRepositoryImpl

**역할:** Domain의 `INotificationRepository`와 App의 `NotificationContract` 동시 구현

**위치:** `repositories/notification_repository_impl.dart`

**핵심 책임:**
- Domain Layer의 알림 요구사항 충족 (Repository 패턴)
- App Layer의 알림 통합 요구사항 충족 (Contract 패턴)
- Remote와 Local DataSource 조율
- 캐싱 전략 관리 (30분 만료, 100개 제한)

**주요 메서드:**

```dart
// INotificationRepository 구현
Stream<List<Notification>> watchUserNotifications({
  required String userId,
  String? type,              // 타입 필터: 'systemAlert', 'social'
  bool? unreadOnly,
  DateTime? after,
  DateTime? before,
  int? limit,
});

Future<List<Notification>> getUserNotifications({
  required String userId,
  String? type,
  bool? unreadOnly,
  DateTime? after,
  DateTime? before,
  int? limit,
});

Stream<int> watchUnreadCount({
  required String userId,
  String? type,
});

Future<void> markAsRead(String notificationId);
Future<void> markAllAsRead(String userId);

// NotificationContract 구현
Future<void> showNotification(Map<String, dynamic> notificationData);
Stream<Map<String, dynamic>> getNotificationStream(String userId);
Future<void> updateNotificationSettings(String userId, Map<String, bool> settings);
Future<Map<String, bool>> getNotificationSettings(String userId);
```

**데이터 플로우:**

```
[Firebase] ─┐
            ├─> [Repository] ─> [Mapper] ─> [Domain Models] ─> [UseCase]
[SharedPrefs]┘                    ↓
                            [DTO Models]
```

**캐싱 전략:**

```dart
// 1. Remote에서 데이터 가져오기
final remoteData = await _remoteDataSource.getNotifications(
  userId: userId,
  type: type,
  limit: limit,
);

// 2. Local에 캐싱 (30분 TTL, 100개 제한)
await _localDataSource.cacheNotifications(userId, remoteData);

// 3. DTO → Domain 변환
return remoteData.map((dto) =>
  NotificationMapper.toDomain(NotificationDto.fromJson(dto))
).toList();
```

**NotificationQueueService 통합:**

```dart
// NotificationService를 통해 실시간 알림 표시
void _initializeNotificationService() {
  _notificationService.startListening(userId, type: null);

  // NotificationService의 스트림을 Repository가 구독
  _notificationService.notificationsStream.listen((notifications) {
    // UI로 전달할 알림 필터링 및 변환
  });
}
```

**계약 패턴 구현 세부사항:**

```dart
class NotificationRepositoryImpl
    implements INotificationRepository, NotificationContract {

  final IRemoteNotificationDatasource _remoteDataSource;
  final ILocalNotificationDatasource _localDataSource;
  final NotificationService _notificationService;

  // NotificationContract 메서드 구현
  @override
  Future<void> showNotification(Map<String, dynamic> notificationData) async {
    // 1. DTO 생성
    final dto = NotificationDto.fromJson(notificationData);

    // 2. Domain 변환
    final notification = NotificationMapper.toDomain(dto);

    // 3. NotificationService를 통해 UI에 표시
    _notificationService.addNotification(notification);
  }

  @override
  Stream<Map<String, dynamic>> getNotificationStream(String userId) {
    // NotificationService의 스트림을 Contract 형태로 변환
    return _notificationService.notificationsStream
      .map((notifications) => _convertToContractFormat(notifications));
  }
}
```

---

## 📡 DataSources

### Remote DataSource (Firebase)

**인터페이스:** `i_remote_notification_datasource.dart`
**구현체:** `remote/firebase_notification_datasource.dart`

**책임:**
- Firestore `notifications` 컬렉션과의 모든 상호작용
- 실시간 스트림 관리 및 쿼리 최적화
- 배치 작업 처리

**핵심 메서드:**

```dart
// 실시간 알림 스트림
Stream<List<Map<String, dynamic>>> watchUserNotifications({
  required String userId,
  String? type,
  bool? unreadOnly,
  DateTime? after,
  DateTime? before,
  int? limit,
});

// 읽지 않은 알림 개수 추적
Stream<int> watchUnreadCount({
  required String userId,
  String? type,
});

// CRUD 작업
Future<String> createNotification(Map<String, dynamic> data);
Future<void> updateNotification(String id, Map<String, dynamic> updates);
Future<void> deleteNotification(String id);

// 배치 작업
Future<void> batchUpdate(List<BatchUpdateRequest> requests);
Future<void> markAllAsRead(String userId);

// P1 추가 메서드 (Phase 1 요구사항)
Future<void> deleteAllUserNotifications(String userId);
Future<void> deleteNotificationsBefore({
  required String userId,
  required DateTime before,
});
Future<void> deleteExpiredNotifications(String userId);
Future<Map<String, dynamic>> getNotificationStats(String userId);
Future<List<Map<String, dynamic>>> getNotificationActivityLog({
  required String userId,
  required DateTime from,
  required DateTime to,
});

// Contract 지원 메서드
Stream<Map<String, dynamic>> getRealTimeNotificationStream(String userId);
```

**Firestore 쿼리 예시:**

```dart
// 복합 쿼리 빌드
Query query = _firestore
  .collection('notifications')
  .where('userId', isEqualTo: userId);

if (type != null) {
  query = query.where('type', isEqualTo: type);
}
if (unreadOnly == true) {
  query = query.where('isRead', isEqualTo: false);
}

query = query
  .orderBy('createdAt', descending: true)
  .limit(limit ?? 20);

return query.snapshots();
```

**스트림 관리 최적화:**

```dart
// 스트림 재사용으로 중복 구독 방지
final Map<String, StreamController<List<Map<String, dynamic>>>> _streamControllers = {};
final Map<String, StreamSubscription> _subscriptions = {};

Stream<List<Map<String, dynamic>>> watchUserNotifications(...) {
  final streamKey = '$userId-$type-$unreadOnly-$limit';

  // 기존 스트림이 있으면 재사용
  if (_streamControllers.containsKey(streamKey)) {
    return _streamControllers[streamKey]!.stream;
  }

  // 새 스트림 생성
  final controller = StreamController<List<Map<String, dynamic>>>.broadcast(
    onCancel: () => _cleanupStream(streamKey),
  );

  // Firestore 스트림 구독
  final subscription = query.snapshots().listen(...);

  _streamControllers[streamKey] = controller;
  _subscriptions[streamKey] = subscription;

  return controller.stream;
}
```

### Local DataSource (SharedPreferences)

**인터페이스:** `i_local_notification_datasource.dart`
**구현체:** `local/shared_prefs_notification_datasource.dart`

**책임:**
- 오프라인 캐싱 (최대 100개, 30분 TTL)
- 처리된 알림 ID 추적 (중복 표시 방지)
- 사용자 알림 설정 저장

**핵심 메서드:**

```dart
// 캐싱 관리
Future<List<Map<String, dynamic>>> getCachedNotifications(String userId);
Future<void> cacheNotifications(String userId, List<Map<String, dynamic>> notifications);
Future<void> clearCache(String userId);
Future<DateTime?> getLastCacheTime(String userId);

// 처리된 알림 ID 관리
Future<Set<String>> getProcessedNotificationIds();
Future<void> saveProcessedNotificationIds(Set<String> ids);
Future<void> addProcessedNotificationId(String id);

// 사용자 설정 관리
Future<Map<String, dynamic>> getNotificationPreferences(String userId);
Future<void> saveNotificationPreferences(String userId, Map<String, dynamic> preferences);

// Contract 지원 메서드
Future<Map<String, bool>?> getNotificationSettings(String userId);
Future<void> saveNotificationSettings(String userId, Map<String, bool> settings);
```

**캐시 전략:**

```dart
// 30분 캐시 만료 시간
static const Duration _cacheExpiry = Duration(minutes: 30);
static const int _maxCacheSize = 100;

Future<List<Map<String, dynamic>>> getCachedNotifications(String userId) async {
  // 1. 캐시 시간 확인
  final lastCacheTime = await getLastCacheTime(userId);
  if (lastCacheTime != null) {
    final difference = DateTime.now().difference(lastCacheTime);
    if (difference > _cacheExpiry) {
      await clearCache(userId);
      return [];
    }
  }

  // 2. 캐시된 데이터 가져오기
  final cachedJson = _prefs.getString('cached_notifications_$userId');
  if (cachedJson == null) return [];

  // 3. JSON 디코딩
  try {
    final List<dynamic> decodedList = json.decode(cachedJson);
    return decodedList.map((item) => item as Map<String, dynamic>).toList();
  } catch (e) {
    await clearCache(userId);
    return [];
  }
}
```

**기본 사용자 설정:**

```dart
// 기본 알림 설정 구조
{
  'enablePushNotifications': true,
  'enableInAppNotifications': true,
  'notificationTypes': {
    'votingRequest': true,
    'systemAlert': true,
    'social': true,
  },
  'quietHoursEnabled': false,
  'quietHoursStart': '22:00',
  'quietHoursEnd': '08:00',
}
```

---

## 📦 Models (DTOs)

### NotificationDto (Base)

**위치:** `models/notification_dto.dart`

**역할:** Firebase Firestore 직렬화/역직렬화 처리

**핵심 필드:**

```dart
class NotificationDto {
  final String? id;
  final String? userId;
  final String? type;            // 'systemAlert', 'social', 'votingRequest'
  final String? title;
  final String? content;
  final Map<String, dynamic>? data;
  final Timestamp? createdAt;    // Firebase Timestamp
  final Timestamp? readAt;
  final bool? isRead;
  final Timestamp? expiryTime;
  final Map<String, dynamic>? metadata;
  final int? priority;           // 1 (high) ~ 3 (low)
}
```

**Factory 메서드:**

```dart
// Firestore 문서에서 생성
factory NotificationDto.fromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data() ?? {};
  return NotificationDto(
    id: doc.id,
    userId: data['userId'] as String?,
    type: data['type'] as String?,
    // ... 나머지 필드
  );
}

// JSON Map에서 생성
factory NotificationDto.fromJson(Map<String, dynamic> json) {
  return NotificationDto(
    id: json['id'] as String?,
    // Timestamp 변환 처리
    createdAt: json['createdAt'] != null
        ? (json['createdAt'] is Timestamp
            ? json['createdAt'] as Timestamp
            : Timestamp.fromMillisecondsSinceEpoch(json['createdAt'] as int))
        : null,
    // ... 나머지 필드
  );
}

// Firestore 문서로 변환
Map<String, dynamic> toFirestore() {
  final json = toJson();
  json.remove('id');  // ID는 문서 ID로 관리
  return json;
}
```

### SystemNotificationDto

**위치:** `models/system_notification_dto.dart`

**추가 필드:**

```dart
class SystemNotificationDto extends NotificationDto {
  final String? alertType;      // 'info', 'warning', 'error', 'success'
  final String? actionUrl;       // 액션 버튼 URL
  final String? actionLabel;     // 액션 버튼 레이블

  // ... 생성자 및 메서드
}
```

### SocialNotificationDto

**위치:** `models/social_notification_dto.dart`

**추가 필드:**

```dart
class SocialNotificationDto extends NotificationDto {
  final String? actionType;      // 'follow', 'like', 'comment', 'share'
  final String? actorId;         // 액션을 수행한 사용자 ID
  final String? actorName;       // 액션을 수행한 사용자 이름
  final String? actorProfileImage;
  final String? targetId;        // 대상 포스트/댓글 ID
  final String? targetType;      // 'post', 'comment'
  final Map<String, dynamic>? socialData;  // 추가 소셜 데이터

  // ... 생성자 및 메서드
}
```

### DTO 확장 (DtoHelper)

**위치:** `models/dto_extensions.dart`

**유틸리티 메서드:**

```dart
extension DtoHelper on Object? {
  /// Timestamp, DateTime, int를 DateTime으로 안전하게 변환
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }
}

extension DateTimeExtension on DateTime {
  /// DateTime을 Timestamp로 변환
  Timestamp toTimestamp() {
    return Timestamp.fromDate(this);
  }
}
```

---

## 🔄 Mappers

### NotificationMapper

**위치:** `mappers/notification_mapper.dart`

**역할:** Domain Entity ↔ DTO 양방향 변환

**핵심 메서드:**

```dart
class NotificationMapper {
  /// DTO → Domain Entity
  static Notification toDomain(NotificationDto dto) {
    final type = dto.type ?? 'systemAlert';

    switch (type) {
      case 'systemAlert':
        return _toSystemNotification(dto);
      case 'social':
        return _toSocialNotification(dto);
      default:
        // VoteNotification은 Voting Feature의 mapper가 처리
        return _toSystemNotification(dto);
    }
  }

  /// Domain Entity → DTO
  static NotificationDto toDto(Notification entity) {
    if (entity is SystemNotification) {
      return _fromSystemNotification(entity);
    } else if (entity is SocialNotification) {
      return _fromSocialNotification(entity);
    } else {
      return NotificationDto(...);
    }
  }
}
```

**System 알림 변환:**

```dart
static SystemNotification _toSystemNotification(NotificationDto dto) {
  final systemDto = dto is SystemNotificationDto ? dto : /* 기본 변환 */;

  return SystemNotification(
    id: systemDto.id ?? '',
    userId: systemDto.userId ?? '',
    title: systemDto.title ?? '',
    content: systemDto.content ?? '',
    createdAt: DtoHelper.parseDateTime(systemDto.createdAt) ?? DateTime.now(),
    readAt: DtoHelper.parseDateTime(systemDto.readAt),
    isRead: systemDto.isRead ?? false,
    expiryTime: DtoHelper.parseDateTime(systemDto.expiryTime),
    metadata: systemDto.metadata ?? {},
    // System 전용 필드
    alertType: SystemAlertType.fromString(systemDto.alertType ?? 'info'),
    actionUrl: systemDto.actionUrl,
    actionLabel: systemDto.actionLabel,
  );
}
```

**Social 알림 변환:**

```dart
static SocialNotification _toSocialNotification(NotificationDto dto) {
  final socialDto = dto is SocialNotificationDto ? dto : /* 기본 변환 */;

  return SocialNotification(
    // 기본 필드
    id: socialDto.id ?? '',
    userId: socialDto.userId ?? '',
    // ...
    // Social 전용 필드
    actionType: SocialActionType.fromString(socialDto.actionType ?? 'follow'),
    fromUserId: socialDto.actorId ?? '',
    fromUserName: socialDto.actorName ?? '',
    fromUserProfileUrl: socialDto.actorProfileImage,
    relatedPostId: socialDto.targetId,
    relatedCommentId: socialDto.targetType == 'comment' ? socialDto.targetId : null,
    relatedContent: socialDto.socialData?['content'] as String?,
    interactionCount: socialDto.socialData?['count'] as int?,
  );
}
```

---

## 🔌 Adapters

### NotificationService

**위치:** `adapters/notification_service.dart`

**역할:** `NotificationQueueService`와 Repository 간의 통합 어댑터

**핵심 책임:**
1. Domain의 `INotificationService` 구현
2. NotificationQueueService 초기화 및 관리
3. Repository의 스트림을 NotificationQueueService로 전달

**주요 메서드:**

```dart
class NotificationService implements INotificationService {
  final INotificationRepository _repository;
  final NotificationQueueService _queueService;

  StreamSubscription<List<Notification>>? _notificationSubscription;

  // NotificationQueueService의 스트림 노출
  Stream<Notification> get notificationsStream =>
    _queueService.showNotificationStream;

  @override
  void startListening(String userId, {String? type}) {
    // 1. Repository 스트림 구독
    _notificationSubscription = _repository
      .watchUserNotifications(
        userId: userId,
        type: type,
        unreadOnly: true,
      )
      .listen((notifications) {
        // 2. NotificationQueueService에 알림 전달
        Logger.debug('NotificationQueueService에 ${notifications.length}개 알림 전달');
        // _queueService는 내부적으로 큐를 관리하고 순차적으로 표시
      });
  }

  @override
  void stopListening() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  @override
  void dispose() {
    stopListening();
  }
}
```

**NotificationQueueService 통합:**

```dart
// NotificationQueueService는 /services/ 디렉토리에 위치
// 실시간 알림 큐 관리 및 순차적 표시 담당

// 사용 예시:
final notificationService = NotificationService(
  repository: getIt<INotificationRepository>(),
  queueService: getIt<NotificationQueueService>(),
);

// 알림 리스닝 시작
notificationService.startListening(userId);

// UI에서 알림 스트림 구독
notificationService.notificationsStream.listen((notification) {
  // NotificationOverlay.showVoting(...) 등으로 표시
});
```

---

## 📊 데이터 플로우

### 알림 수신 플로우

```
[Firebase Functions]
  └─> 새 알림 생성
        ↓
[Firebase Firestore]
  └─> notifications 컬렉션에 문서 추가
        ↓
[FirebaseNotificationDatasource]
  └─> watchUserNotifications 스트림 감지
        ↓
[NotificationRepositoryImpl]
  ├─> Local에 캐싱
  └─> DTO → Domain 변환
        ↓
[NotificationService]
  └─> NotificationQueueService로 전달
        ↓
[NotificationQueueService]
  ├─> 큐에 추가
  └─> 순차적 표시 (showNotificationStream)
        ↓
[Presentation Layer]
  └─> NotificationOverlay/Dialog로 UI 표시
```

### 알림 읽음 처리 플로우

```
[UI] 사용자가 알림 읽음
  ↓
[UseCase] MarkNotificationAsReadUseCase
  ↓
[Repository] markAsRead(notificationId)
  ├─> Remote: updateNotification({ 'isRead': true })
  └─> Local: 캐시 업데이트
        ↓
[Firebase Firestore]
  └─> 문서 업데이트
        ↓
[스트림 업데이트]
  └─> UI에 자동 반영 (watchUnreadCount)
```

### 캐싱 플로우

```
[Repository] getUserNotifications()
  ↓
  1. Local에서 캐시 확인
     ├─ 캐시 유효 (30분 이내) → 캐시 반환
     └─ 캐시 없음/만료 → 2단계로
  ↓
  2. Remote에서 데이터 가져오기
     └─> Firebase 쿼리 실행
  ↓
  3. Local에 캐싱 (최대 100개)
     └─> SharedPrefs에 JSON 저장
  ↓
  4. DTO → Domain 변환
     └─> NotificationMapper 사용
  ↓
  5. UseCase로 반환
```

---

## 🛡️ 에러 처리

### Repository 레벨

```dart
@override
Future<List<Notification>> getUserNotifications({
  required String userId,
  String? type,
  int? limit,
}) async {
  try {
    // 1. Remote 데이터 가져오기
    final remoteData = await _remoteDataSource.getNotifications(
      userId: userId,
      type: type,
      limit: limit,
    );

    // 2. 캐싱
    await _localDataSource.cacheNotifications(userId, remoteData);

    // 3. 변환
    return remoteData.map((data) =>
      NotificationMapper.toDomain(NotificationDto.fromJson(data))
    ).toList();

  } on FirebaseException catch (e) {
    // Firebase 에러 처리
    Logger.error('Firebase 에러', error: e);

    // 캐시 폴백
    final cachedData = await _localDataSource.getCachedNotifications(userId);
    if (cachedData.isNotEmpty) {
      return cachedData.map((data) =>
        NotificationMapper.toDomain(NotificationDto.fromJson(data))
      ).toList();
    }

    rethrow;

  } catch (e) {
    Logger.error('알림 가져오기 실패', error: e);
    rethrow;
  }
}
```

### DataSource 레벨

```dart
@override
Future<List<Map<String, dynamic>>> getNotifications(...) async {
  try {
    final snapshot = await _firestore
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();

  } catch (e) {
    throw Exception('Failed to get notifications: $e');
  }
}
```

### 캐시 손상 처리

```dart
Future<List<Map<String, dynamic>>> getCachedNotifications(String userId) async {
  final cachedJson = _prefs.getString('cached_notifications_$userId');
  if (cachedJson == null) return [];

  try {
    final List<dynamic> decodedList = json.decode(cachedJson);
    return decodedList.map((item) => item as Map<String, dynamic>).toList();
  } catch (e) {
    // 캐시 데이터 손상 시 삭제
    await clearCache(userId);
    return [];
  }
}
```

---

## 🧪 테스트 전략

### Repository 테스트

```dart
group('NotificationRepositoryImpl', () {
  late MockRemoteNotificationDatasource mockRemoteSource;
  late MockLocalNotificationDatasource mockLocalSource;
  late NotificationRepositoryImpl repository;

  setUp(() {
    mockRemoteSource = MockRemoteNotificationDatasource();
    mockLocalSource = MockLocalNotificationDatasource();
    repository = NotificationRepositoryImpl(
      remoteDataSource: mockRemoteSource,
      localDataSource: mockLocalSource,
    );
  });

  test('getUserNotifications는 Remote에서 가져와 Local에 캐싱한다', () async {
    // Arrange
    final userId = 'user123';
    final mockData = [/* DTO Maps */];
    when(() => mockRemoteSource.getNotifications(userId: userId))
      .thenAnswer((_) async => mockData);

    // Act
    final result = await repository.getUserNotifications(userId: userId);

    // Assert
    expect(result, isA<List<Notification>>());
    verify(() => mockRemoteSource.getNotifications(userId: userId)).called(1);
    verify(() => mockLocalSource.cacheNotifications(userId, mockData)).called(1);
  });

  test('Firebase 에러 시 캐시 폴백', () async {
    // Arrange
    when(() => mockRemoteSource.getNotifications(userId: any(named: 'userId')))
      .thenThrow(FirebaseException(plugin: 'test'));
    when(() => mockLocalSource.getCachedNotifications(any()))
      .thenAnswer((_) async => [/* cached data */]);

    // Act
    final result = await repository.getUserNotifications(userId: 'user123');

    // Assert
    expect(result.isNotEmpty, true);
    verify(() => mockLocalSource.getCachedNotifications('user123')).called(1);
  });
});
```

### DataSource 테스트

```dart
group('FirebaseNotificationDatasource', () {
  late MockFirebaseFirestore mockFirestore;
  late FirebaseNotificationDatasource datasource;

  test('watchUserNotifications는 스트림을 재사용한다', () async {
    // Arrange
    final userId = 'user123';

    // Act
    final stream1 = datasource.watchUserNotifications(userId: userId);
    final stream2 = datasource.watchUserNotifications(userId: userId);

    // Assert
    expect(identical(stream1, stream2), true);
  });
});
```

### Mapper 테스트

```dart
group('NotificationMapper', () {
  test('SystemNotificationDto → SystemNotification 변환', () {
    // Arrange
    final dto = SystemNotificationDto(
      id: 'notif123',
      userId: 'user123',
      type: 'systemAlert',
      title: 'Test',
      content: 'Test content',
      createdAt: Timestamp.now(),
      isRead: false,
      alertType: 'info',
    );

    // Act
    final result = NotificationMapper.toDomain(dto);

    // Assert
    expect(result, isA<SystemNotification>());
    expect(result.id, 'notif123');
    expect((result as SystemNotification).alertType, SystemAlertType.info);
  });
});
```

---

## 🔐 보안 고려사항

### Firestore 보안 규칙

```javascript
// firestore.rules
match /notifications/{notificationId} {
  // 읽기: 자신의 알림만 읽을 수 있음
  allow read: if request.auth != null &&
                 request.auth.uid == resource.data.userId;

  // 생성: Firebase Functions만 생성 가능 (일반 사용자는 불가)
  allow create: if false;  // Functions에서만 생성

  // 업데이트: 자신의 알림만 읽음 처리 가능
  allow update: if request.auth != null &&
                   request.auth.uid == resource.data.userId &&
                   request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isRead', 'readAt']);

  // 삭제: 금지 (자동 정리 함수에서만)
  allow delete: if false;
}
```

### 데이터 검증

```dart
// Repository에서 데이터 검증
Future<String> createNotification(Notification notification) async {
  // 1. 필수 필드 검증
  if (notification.userId.isEmpty) {
    throw ValidationException('userId는 필수입니다');
  }

  // 2. DTO 변환
  final dto = NotificationMapper.toDto(notification);

  // 3. Remote 생성
  return await _remoteDataSource.createNotification(dto.toJson());
}
```

---

## ⚡ 성능 최적화

### 1. 스트림 재사용

```dart
// 동일한 쿼리에 대해 스트림을 재사용하여 중복 구독 방지
final streamKey = '$userId-$type-$unreadOnly-$limit';

if (_streamControllers.containsKey(streamKey)) {
  return _streamControllers[streamKey]!.stream;
}
```

### 2. 캐싱 전략

```dart
// 30분 TTL, 최대 100개 알림
static const Duration _cacheExpiry = Duration(minutes: 30);
static const int _maxCacheSize = 100;

// 최근 알림만 캐싱
final limitedNotifications = notifications.take(_maxCacheSize).toList();
```

### 3. 배치 작업

```dart
// Firestore 배치 업데이트로 네트워크 요청 최소화
Future<void> markAllAsRead(String userId) async {
  final snapshot = await _firestore
    .collection('notifications')
    .where('userId', isEqualTo: userId)
    .where('isRead', isEqualTo: false)
    .get();

  final batch = _firestore.batch();
  for (final doc in snapshot.docs) {
    batch.update(doc.reference, {
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();  // 단일 네트워크 요청
}
```

### 4. 페이지네이션

```dart
// limit 파라미터로 쿼리 크기 제한
query = query.limit(limit ?? 20);  // 기본 20개

// 이후 페이지 로드는 UseCase에서 관리
```

---

## 🔗 관련 문서

### Feature 내부 문서
- [Domain Layer](../domain/README.md) - 비즈니스 로직 및 모델
- [Presentation Layer](../presentation/README.md) - UI 컴포넌트
- [Feature Root](../README.md) - Notifications Feature 전체 개요

### 다른 Feature와의 통합
- [Voting Feature](../../voting/README.md) - VoteNotification 타입 처리
- [App Layer Contracts](../../../../app/contracts/README.md) - NotificationContract 인터페이스
- [NotificationQueueService](../../../../services/notification/README.md) - 실시간 알림 큐 관리

### 프로젝트 전체 문서
- [Clean Architecture Guide](../../../../docs/architecture/clean-architecture.md)
- [Feature-First Structure](../../../../docs/architecture/feature-first.md)
- [DI Container Setup](../../../../app/di/README.md)

---

## 📝 변경 이력

### v2.0.0 (2025-01-20)
- ✅ INotificationContentService 삭제 (미사용 인터페이스)
- ✅ notification_factory_demo.dart 삭제 (데모 파일)
- ✅ GlobalNotificationManager → NotificationQueueService 명칭 통일 (9개 파일)
- ✅ 모든 마크다운 문서 삭제 및 재작성
- ✅ README.md 신규 작성 (creation/data 형식 참조)

### v1.3.0 (2025-01-18)
- Phase 3: 통합 완료 (NotificationService, NotificationQueueService)
- Contract 지원 메서드 추가 (getRealTimeNotificationStream)
- Repository에 NotificationContract 구현 추가

### v1.2.0 (2025-01-15)
- P1 추가 메서드 구현 (deleteAllUserNotifications, getNotificationStats 등)
- 배치 작업 최적화
- 캐싱 전략 강화 (30분 TTL, 100개 제한)

### v1.1.0 (2025-01-10)
- DTO 패턴 도입
- Mapper 분리
- DataSource 인터페이스 분리

### v1.0.0 (2025-01-05)
- 초기 구현
- Firebase 통합
- Repository 패턴 적용

---

## 👥 기여자

- Feature Owner: Backend Team
- Architecture Lead: Clean Architecture Team
- Code Review: Tech Lead

**마지막 업데이트:** 2025-01-20
**문서 버전:** 2.0.0
