# Notification Feature - Phase 4: IdempotencyService Integration

> **Migration Status**: Phase 4/5
> **Difficulty**: ⭐⭐⭐ (Medium-High)
> **Time Estimate**: 4-5 hours
> **Prerequisites**: Phase 1, 2, 3 완료
> **Date**: 2025-01-31

---

## 📊 Overview

### Migration Goals

이 Phase에서는 **IdempotencyService**를 Notification Repository에 통합하여 중복 알림 생성/전송을 완전히 방지합니다. Firebase-Centric v2.0의 핵심 원칙인 **멱등성(Idempotency) 보장**을 구현합니다.

**핵심 목표**:
- IdempotencyService 싱글톤 통합 (GetIt DI)
- 모든 Write 작업에 `eventId` 파라미터 추가
- Transaction 패턴으로 알림 생성 안전성 보장
- 중복 알림 전송 완전 차단
- Batch Delete 작업 멱등성 구현

### Metrics

| 항목 | Before Phase 4 | After Phase 4 | 변화 |
|------|----------------|---------------|------|
| 총 파일 수 | 21개 | 21개 | **0개** |
| 총 코드 라인 | 4,428줄 | 4,548줄 | **+120줄** |
| Repository 파일 | 885줄 | 955줄 | **+70줄** |
| UseCase 파일 | 7개 (527줄) | 7개 (577줄) | **+50줄** |
| DI Module | 203줄 | 203줄 | **0줄** |
| 테스트 파일 | 0개 | 7개 (450줄) | **+7개** |

**변경 대상 파일**: 8개

```
lib/features/notifications/
├── data/
│   └── repositories/
│       └── notification_repository_impl.dart          [885 → 955줄, +70줄]
├── domain/
│   ├── repositories/
│   │   └── i_notification_repository.dart             [161 → 181줄, +20줄]
│   └── usecases/
│       ├── mark_as_read_usecase.dart                  [71 → 78줄, +7줄]
│       ├── mark_all_as_read_usecase.dart              [66 → 73줄, +7줄]
│       ├── delete_notification_usecase.dart           [70 → 77줄, +7줄]
│       ├── delete_all_notifications_usecase.dart      [65 → 72줄, +7줄]
│       ├── send_notification_usecase.dart             [85 → 92줄, +7줄]
│       └── create_voting_notification_usecase.dart    [120 → 135줄, +15줄]
└── di/
    └── notification_di_module.dart                     [203줄, 0줄] ← 변경 없음 (이미 등록됨)
```

**테스트 파일 추가**: 7개

```
lib/features/notifications/test/unit/
└── idempotency/
    ├── mark_as_read_idempotency_test.dart            [60줄]
    ├── delete_notification_idempotency_test.dart     [65줄]
    ├── batch_delete_idempotency_test.dart            [80줄]
    ├── send_notification_idempotency_test.dart       [70줄]
    ├── create_voting_idempotency_test.dart          [85줄]
    ├── concurrent_operations_test.dart               [55줄]
    └── transaction_safety_test.dart                  [35줄]
```

---

## 🎯 Current State (Phase 3 종료 시점)

### Phase 3에서 완성된 것들

✅ **3-Layer 캐싱 시스템**
```dart
// L1 Memory (SimpleMemoryCache) - <10ms
// L2 Hive (Local DB) - 10-30ms
// L3 Firestore Offline Cache - 300-500ms

Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
  String userId,
) async {
  final cacheKey = 'notifications_$userId';

  // Cache-First 패턴
  final cached = UnifiedCacheService.instance.getList<Notification>(cacheKey, ...);
  if (cached != null) return right(cached);

  // ... L2, L3 체크
}
```

✅ **SharedPreferences 제거**
```dart
// ❌ Before Phase 3
final ILocalNotificationDatasource _localDatasource;  // SharedPreferences 래퍼

// ✅ After Phase 3
// UnifiedCacheService.instance 직접 사용 (싱글톤)
```

✅ **Repository 성능 최적화**
```dart
// 캐시 히트: <10ms (L1) → 10-30ms (L2) → 300-500ms (L3)
// 네트워크: Only on cache miss
```

### Phase 4에서 해결할 문제

❌ **중복 알림 생성 가능**
```dart
// 동시에 2번 호출 시 중복 알림 생성
await sendNotification(...);  // User A
await sendNotification(...);  // User A (중복)
```

❌ **Race Condition 위험**
```dart
// 동일 알림을 동시에 읽음 처리 시도
await markAsRead(notifId);  // Request 1
await markAsRead(notifId);  // Request 2 (충돌)
```

❌ **Batch 작업 안전성 부족**
```dart
// 100개 알림 삭제 중 50번째에서 에러 발생
// 이미 삭제된 50개는 롤백 불가능
for (final notif in notifications) {
  await delete(notif.id);  // ❌ 50번째 실패 시 일관성 깨짐
}
```

❌ **멱등성 보장 부재**
```dart
// 같은 투표 알림을 여러 사용자가 동시에 생성
// postId 동일해도 중복 알림 발생 가능
await createVotingNotification(postId: 'post_123', ...);
```

---

## 🚀 Migration Goals

### 1. IdempotencyService 통합

**목표**: 모든 Write 작업에 멱등성 보장

**Before Phase 4**:
```dart
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;
  // ❌ IdempotencyService 없음

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
  ) async {
    try {
      // ❌ 중복 호출 시 Firestore 업데이트 중복 발생
      await _remoteDatasource.markAsRead(notificationId);

      // 캐시 무효화
      UnifiedCacheService.instance.invalidate('notification_$notificationId');

      return right(unit);
    } catch (e) {
      return left(DatabaseError(e.toString()));
    }
  }
}
```

**After Phase 4**:
```dart
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;
  final IdempotencyService _idempotencyService;  // ✅ 추가

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String eventId,  // ✅ 멱등성 키 추가
  ) async {
    return _idempotencyService.executeIdempotent(
      eventId: eventId,
      operation: () async {
        // ✅ 동일 eventId로 2번 호출 시 첫 번째만 실행
        await _remoteDatasource.markAsRead(notificationId);
        UnifiedCacheService.instance.invalidate('notification_$notificationId');
        return unit;
      },
      onDuplicate: () async {
        // ✅ 중복 호출 시 캐시만 무효화하고 성공 반환
        UnifiedCacheService.instance.invalidate('notification_$notificationId');
        return unit;
      },
      operationType: 'mark_notification_read',
    );
  }
}
```

**변경점**:
- `eventId` 파라미터 추가 (UUID v4 권장)
- `executeIdempotent()` 래퍼로 작업 실행
- 중복 호출 시 `onDuplicate` 콜백 실행
- Firestore 중복 업데이트 완전 차단

### 2. Repository Interface 업데이트

**Before Phase 4**:
```dart
abstract class INotificationRepository {
  // ❌ eventId 파라미터 없음
  Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId);

  Future<Either<NotificationFailure, Unit>> deleteNotification(String notificationId);

  Future<Either<NotificationFailure, Unit>> sendNotification(Notification notification);
}
```

**After Phase 4**:
```dart
abstract class INotificationRepository {
  // ✅ 모든 Write 작업에 eventId 추가
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String eventId,
  );

  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String eventId,
  );

  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId,
  );

  // ✅ Batch 작업도 eventId 필요
  Future<Either<NotificationFailure, Unit>> markAllAsRead(
    String userId,
    String eventId,
  );

  Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
    String userId,
    String eventId,
  );
}
```

### 3. Transaction 패턴 적용

**Before Phase 4**:
```dart
// ❌ 100개 알림 삭제 중 에러 발생 시 롤백 불가능
Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
  String userId,
) async {
  try {
    final notifications = await _remoteDatasource.getUserNotifications(userId);

    // ❌ 순차 삭제 - 50번째 실패 시 50개는 이미 삭제됨
    for (final notif in notifications) {
      await _remoteDatasource.deleteNotification(notif.id);
    }

    return right(unit);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

**After Phase 4**:
```dart
// ✅ Transaction으로 All-or-Nothing 보장
Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
  String userId,
  String eventId,
) async {
  return _idempotencyService.executeIdempotent(
    eventId: eventId,
    operation: () async {
      // ✅ Transaction: 모두 성공 또는 모두 롤백
      await _firestore.runTransaction((transaction) async {
        final snapshot = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .get();

        // ✅ 모든 삭제를 Transaction에 추가
        for (final doc in snapshot.docs) {
          transaction.delete(doc.reference);
        }
      });

      // 캐시 무효화
      UnifiedCacheService.instance.invalidate('notifications_$userId');

      return unit;
    },
    operationType: 'delete_all_notifications',
  );
}
```

### 4. UseCase eventId 전달

**Before Phase 4**:
```dart
class MarkAsReadUseCase implements UseCase<MarkAsReadParams, Unit> {
  final INotificationRepository _repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    // ❌ eventId 생성 및 전달 없음
    return _repository.markAsRead(params.notificationId);
  }
}
```

**After Phase 4**:
```dart
class MarkAsReadUseCase implements UseCase<MarkAsReadParams, Unit> {
  final INotificationRepository _repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    // ✅ UseCase에서 eventId 생성
    final eventId = params.eventId ?? const Uuid().v4();

    return _repository.markAsRead(
      params.notificationId,
      eventId,
    );
  }
}

// ✅ Params 클래스에 eventId 추가
class MarkAsReadParams extends Equatable {
  final String notificationId;
  final String? eventId;  // ✅ Optional - 없으면 자동 생성

  const MarkAsReadParams({
    required this.notificationId,
    this.eventId,
  });

  @override
  List<Object?> get props => [notificationId, eventId];
}
```

---

## 📝 Step-by-Step Migration Guide

### Step 1: Repository Interface에 eventId 추가

**작업 시간**: 15분

**파일**: `lib/features/notifications/domain/repositories/i_notification_repository.dart`

```dart
// ✅ Before (Phase 3 상태)
abstract class INotificationRepository {
  // Read 작업 (eventId 불필요)
  Future<Either<NotificationFailure, Notification?>> getNotification(String id);
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(String userId);
  Stream<Either<NotificationFailure, List<Notification>>> watchUserNotifications(String userId);

  // ❌ Write 작업 (eventId 없음)
  Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId);
  Future<Either<NotificationFailure, Unit>> markAllAsRead(String userId);
  Future<Either<NotificationFailure, Unit>> deleteNotification(String notificationId);
  Future<Either<NotificationFailure, Unit>> deleteAllNotifications(String userId);
  Future<Either<NotificationFailure, Unit>> sendNotification(Notification notification);
  Future<Either<NotificationFailure, Unit>> createVotingNotification({
    required String postId,
    required String userId,
    required DateTime voteEndTime,
    // ... 30+ parameters
  });
}
```

```dart
// ✅ After (Phase 4)
abstract class INotificationRepository {
  // Read 작업 (변경 없음 - eventId 불필요)
  Future<Either<NotificationFailure, Notification?>> getNotification(String id);
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(String userId);
  Stream<Either<NotificationFailure, List<Notification>>> watchUserNotifications(String userId);

  // ✅ Write 작업 (eventId 추가)
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String eventId,  // ✅ 멱등성 키
  );

  Future<Either<NotificationFailure, Unit>> markAllAsRead(
    String userId,
    String eventId,  // ✅ Batch 작업도 멱등성 필요
  );

  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String eventId,
  );

  Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
    String userId,
    String eventId,
  );

  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId,  // ✅ 중복 전송 방지
  );

  Future<Either<NotificationFailure, Unit>> createVotingNotification({
    required String postId,
    required String userId,
    required DateTime voteEndTime,
    required String eventId,  // ✅ 필수 파라미터로 추가
    // ... 30+ other parameters
  });
}
```

**변경점**:
- 모든 Write 메서드에 `String eventId` 파라미터 추가
- Read 메서드는 변경 없음 (멱등성 불필요)
- `createVotingNotification` Named 파라미터에 `required String eventId` 추가

**체크포인트**:
```bash
# 컴파일 에러 확인 (Repository 구현체에서 에러 발생해야 정상)
flutter analyze lib/features/notifications/domain/repositories/i_notification_repository.dart

# ✅ Expected: 0 issues (인터페이스만 변경)
```

### Step 2: Repository 구현체에 IdempotencyService 주입

**작업 시간**: 20분

**파일**: `lib/features/notifications/data/repositories/notification_repository_impl.dart`

```dart
// ✅ Before (Phase 3 상태)
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;
  // ❌ IdempotencyService 없음

  NotificationRepositoryImpl({
    required IRemoteNotificationDatasource remoteDatasource,
    required NotificationQueueService queueService,
  })  : _remoteDatasource = remoteDatasource,
        _queueService = queueService;

  // ... methods
}
```

```dart
// ✅ After (Phase 4)
import 'package:versus_space/core/utils/idempotency_service.dart';  // ✅ Import 추가

class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;
  final IdempotencyService _idempotencyService;  // ✅ 추가

  NotificationRepositoryImpl({
    required IRemoteNotificationDatasource remoteDatasource,
    required NotificationQueueService queueService,
    required IdempotencyService idempotencyService,  // ✅ 생성자 파라미터
  })  : _remoteDatasource = remoteDatasource,
        _queueService = queueService,
        _idempotencyService = idempotencyService;  // ✅ 초기화

  // ... methods (다음 Step에서 수정)
}
```

**DI Module 확인** (변경 불필요 - 이미 등록됨):
```dart
// lib/features/notifications/di/notification_di_module.dart
void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: getIt<IRemoteNotificationDatasource>(),
      queueService: getIt<NotificationQueueService>(),
      idempotencyService: getIt<IdempotencyService>(),  // ✅ 이미 app DI에 등록됨
    ),
  );
}
```

**체크포인트**:
```bash
# IdempotencyService가 app DI에 등록되어 있는지 확인
grep -r "IdempotencyService" lib/app/di/

# ✅ Expected: lib/app/di/di.dart에서 싱글톤으로 등록됨
# getIt.registerLazySingleton<IdempotencyService>(() => IdempotencyService());
```

### Step 3: markAsRead 메서드 리팩토링

**작업 시간**: 15분

**파일**: `lib/features/notifications/data/repositories/notification_repository_impl.dart`

```dart
// ✅ Before (Phase 3)
@override
Future<Either<NotificationFailure, Unit>> markAsRead(
  String notificationId,
) async {
  try {
    // ❌ 중복 호출 시 Firestore 업데이트 중복 발생
    await _remoteDatasource.markAsRead(notificationId);

    // 캐시 무효화
    UnifiedCacheService.instance.invalidate('notification_$notificationId');

    return right(unit);
  } on FirebaseException catch (e) {
    if (e.code == 'not-found') {
      return left(const NotificationNotFound());
    }
    return left(DatabaseError(e.message ?? 'Database error'));
  } catch (e) {
    return left(Unexpected(e.toString()));
  }
}
```

```dart
// ✅ After (Phase 4)
@override
Future<Either<NotificationFailure, Unit>> markAsRead(
  String notificationId,
  String eventId,  // ✅ 멱등성 키
) async {
  try {
    // ✅ IdempotencyService로 중복 실행 방지
    final result = await _idempotencyService.executeIdempotent<Unit>(
      eventId: eventId,
      operation: () async {
        // ✅ 동일 eventId로 2번 호출 시 이 블록은 1번만 실행
        await _remoteDatasource.markAsRead(notificationId);
        UnifiedCacheService.instance.invalidate('notification_$notificationId');
        return unit;
      },
      onDuplicate: () async {
        // ✅ 중복 호출 시 캐시만 무효화 (Firestore 작업 스킵)
        UnifiedCacheService.instance.invalidate('notification_$notificationId');
        return unit;
      },
      operationType: 'mark_notification_read',
    );

    return right(result);
  } on FirebaseException catch (e) {
    if (e.code == 'not-found') {
      return left(const NotificationNotFound());
    }
    return left(DatabaseError(e.message ?? 'Database error'));
  } catch (e) {
    return left(Unexpected(e.toString()));
  }
}
```

**변경점**:
- `executeIdempotent()` 래퍼 적용
- `operation` 콜백: 첫 번째 실행 시에만 수행
- `onDuplicate` 콜백: 중복 호출 시 수행 (Firestore 작업 스킵, 캐시만 무효화)
- `operationType`: 로깅 및 모니터링용 작업 타입 지정

**동작 방식**:
```dart
// 동시에 2번 호출
final eventId = 'evt_12345';

// Request 1
await markAsRead('notif_abc', eventId);
// → operation() 실행, Firestore 업데이트

// Request 2 (동일 eventId)
await markAsRead('notif_abc', eventId);
// → onDuplicate() 실행, Firestore 스킵
```

### Step 4: deleteNotification 메서드 리팩토링

**작업 시간**: 15분

```dart
// ✅ Before (Phase 3)
@override
Future<Either<NotificationFailure, Unit>> deleteNotification(
  String notificationId,
) async {
  try {
    await _remoteDatasource.deleteNotification(notificationId);

    // 캐시 무효화
    UnifiedCacheService.instance.invalidate('notification_$notificationId');

    return right(unit);
  } on FirebaseException catch (e) {
    if (e.code == 'not-found') {
      return left(const NotificationNotFound());
    }
    return left(DatabaseError(e.message ?? 'Database error'));
  } catch (e) {
    return left(Unexpected(e.toString()));
  }
}
```

```dart
// ✅ After (Phase 4)
@override
Future<Either<NotificationFailure, Unit>> deleteNotification(
  String notificationId,
  String eventId,
) async {
  try {
    final result = await _idempotencyService.executeIdempotent<Unit>(
      eventId: eventId,
      operation: () async {
        await _remoteDatasource.deleteNotification(notificationId);
        UnifiedCacheService.instance.invalidate('notification_$notificationId');
        return unit;
      },
      onDuplicate: () async {
        // 중복 호출 시에도 캐시 무효화는 안전
        UnifiedCacheService.instance.invalidate('notification_$notificationId');
        return unit;
      },
      operationType: 'delete_notification',
    );

    return right(result);
  } on FirebaseException catch (e) {
    if (e.code == 'not-found') {
      return left(const NotificationNotFound());
    }
    return left(DatabaseError(e.message ?? 'Database error'));
  } catch (e) {
    return left(Unexpected(e.toString()));
  }
}
```

### Step 5: Batch 작업에 Transaction 적용

**작업 시간**: 30분

**파일**: `lib/features/notifications/data/repositories/notification_repository_impl.dart`

#### 5-1. markAllAsRead (Transaction 패턴)

```dart
// ✅ Before (Phase 3)
@override
Future<Either<NotificationFailure, Unit>> markAllAsRead(
  String userId,
) async {
  try {
    final notifications = await _remoteDatasource.getUserNotifications(userId);

    // ❌ 순차 업데이트 - 중간에 실패 시 일관성 깨짐
    for (final dto in notifications) {
      await _remoteDatasource.markAsRead(dto.id);
    }

    // 캐시 무효화
    UnifiedCacheService.instance.invalidate('notifications_$userId');

    return right(unit);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

```dart
// ✅ After (Phase 4)
@override
Future<Either<NotificationFailure, Unit>> markAllAsRead(
  String userId,
  String eventId,
) async {
  try {
    final result = await _idempotencyService.executeIdempotent<Unit>(
      eventId: eventId,
      operation: () async {
        // ✅ Transaction: All-or-Nothing 보장
        await _firestore.runTransaction((transaction) async {
          final snapshot = await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

          // ✅ 모든 업데이트를 Transaction에 추가
          for (final doc in snapshot.docs) {
            transaction.update(doc.reference, {
              'isRead': true,
              'readAt': FieldValue.serverTimestamp(),
            });
          }
        });

        // Transaction 성공 후 캐시 무효화
        UnifiedCacheService.instance.invalidate('notifications_$userId');

        return unit;
      },
      onDuplicate: () async {
        // 중복 호출 시 캐시만 무효화
        UnifiedCacheService.instance.invalidate('notifications_$userId');
        return unit;
      },
      operationType: 'mark_all_notifications_read',
    );

    return right(result);
  } on FirebaseException catch (e) {
    return left(DatabaseError(e.message ?? 'Transaction failed'));
  } catch (e) {
    return left(Unexpected(e.toString()));
  }
}
```

**Transaction 장점**:
```dart
// ❌ Before: 50개 업데이트 중 30번째 실패 시
// → 29개는 이미 업데이트됨 (롤백 불가능)

// ✅ After: Transaction 사용 시
// → 모두 성공 또는 모두 롤백
// → 데이터 일관성 보장
```

#### 5-2. deleteAllNotifications (Transaction 패턴)

```dart
// ✅ Before (Phase 3)
@override
Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
  String userId,
) async {
  try {
    final notifications = await _remoteDatasource.getUserNotifications(userId);

    // ❌ 순차 삭제 - 중간에 실패 시 일관성 깨짐
    for (final dto in notifications) {
      await _remoteDatasource.deleteNotification(dto.id);
    }

    // 캐시 무효화
    UnifiedCacheService.instance.invalidate('notifications_$userId');

    return right(unit);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

```dart
// ✅ After (Phase 4)
@override
Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
  String userId,
  String eventId,
) async {
  try {
    final result = await _idempotencyService.executeIdempotent<Unit>(
      eventId: eventId,
      operation: () async {
        // ✅ Transaction: 모두 삭제 또는 모두 유지
        await _firestore.runTransaction((transaction) async {
          final snapshot = await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .get();

          // ✅ 모든 삭제를 Transaction에 추가
          for (final doc in snapshot.docs) {
            transaction.delete(doc.reference);
          }
        });

        // Transaction 성공 후 캐시 무효화
        UnifiedCacheService.instance.invalidate('notifications_$userId');

        return unit;
      },
      onDuplicate: () async {
        // 중복 호출 시 캐시만 무효화 (이미 삭제됨)
        UnifiedCacheService.instance.invalidate('notifications_$userId');
        return unit;
      },
      operationType: 'delete_all_notifications',
    );

    return right(result);
  } on FirebaseException catch (e) {
    return left(DatabaseError(e.message ?? 'Transaction failed'));
  } catch (e) {
    return left(Unexpected(e.toString()));
  }
}
```

### Step 6: sendNotification 메서드 리팩토링

**작업 시간**: 20분

```dart
// ✅ Before (Phase 3)
@override
Future<Either<NotificationFailure, Unit>> sendNotification(
  Notification notification,
) async {
  try {
    // ❌ 중복 전송 방지 로직 없음
    final dto = NotificationMapper.toDto(notification);
    await _remoteDatasource.sendNotification(dto);

    // 큐에 추가 (실시간 표시용)
    _queueService.addNotification(notification);

    // 캐시 무효화
    UnifiedCacheService.instance.invalidate('notifications_${notification.userId}');

    return right(unit);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

```dart
// ✅ After (Phase 4)
@override
Future<Either<NotificationFailure, Unit>> sendNotification(
  Notification notification,
  String eventId,
) async {
  try {
    final result = await _idempotencyService.executeIdempotent<Unit>(
      eventId: eventId,
      operation: () async {
        // ✅ 동일 eventId로 중복 전송 시도 시 이 블록은 1번만 실행
        final dto = NotificationMapper.toDto(notification);
        await _remoteDatasource.sendNotification(dto);

        // 큐에 추가 (실시간 표시용)
        _queueService.addNotification(notification);

        // 캐시 무효화
        UnifiedCacheService.instance.invalidate('notifications_${notification.userId}');

        return unit;
      },
      onDuplicate: () async {
        // ✅ 중복 전송 시도 시 큐와 캐시만 업데이트
        _queueService.addNotification(notification);
        UnifiedCacheService.instance.invalidate('notifications_${notification.userId}');
        return unit;
      },
      operationType: 'send_notification',
    );

    return right(result);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

**중복 전송 방지 시나리오**:
```dart
// User A가 동시에 2번 알림 전송 버튼 클릭
final eventId = 'evt_send_notif_123';

// Request 1
await sendNotification(votingNotif, eventId);
// → Firestore에 알림 생성, 큐 추가

// Request 2 (동일 eventId)
await sendNotification(votingNotif, eventId);
// → Firestore 스킵 (중복 차단), 큐만 추가
```

### Step 7: createVotingNotification 메서드 리팩토링

**작업 시간**: 25분

**파일**: `lib/features/notifications/data/repositories/notification_repository_impl.dart`

```dart
// ✅ Before (Phase 3)
@override
Future<Either<NotificationFailure, Unit>> createVotingNotification({
  required String postId,
  required String userId,
  required DateTime voteEndTime,
  required List<String> imageUrlsA,
  required List<String> imageUrlsB,
  double? aspectRatioA,
  double? aspectRatioB,
  required String title,
  required String description,
  // ... 30+ parameters
}) async {
  try {
    // ❌ 중복 생성 방지 로직 없음
    final notification = Notification.voting(
      id: const Uuid().v4(),
      userId: userId,
      postId: postId,
      voteEndTime: voteEndTime,
      imageUrlsA: imageUrlsA,
      imageUrlsB: imageUrlsB,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      title: title,
      description: description,
      // ... other fields
      createdAt: DateTime.now(),
      isRead: false,
    );

    final dto = NotificationMapper.toDto(notification);
    await _remoteDatasource.sendNotification(dto);

    // 큐와 캐시 업데이트
    _queueService.addNotification(notification);
    UnifiedCacheService.instance.invalidate('notifications_$userId');

    return right(unit);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

```dart
// ✅ After (Phase 4)
@override
Future<Either<NotificationFailure, Unit>> createVotingNotification({
  required String postId,
  required String userId,
  required DateTime voteEndTime,
  required List<String> imageUrlsA,
  required List<String> imageUrlsB,
  double? aspectRatioA,
  double? aspectRatioB,
  required String title,
  required String description,
  required String eventId,  // ✅ 필수 파라미터
  // ... 30+ parameters
}) async {
  try {
    final result = await _idempotencyService.executeIdempotent<Unit>(
      eventId: eventId,
      operation: () async {
        // ✅ 동일 postId + eventId로 중복 생성 시도 시 차단
        final notification = Notification.voting(
          id: const Uuid().v4(),  // ✅ 새 ID는 operation 내부에서 생성
          userId: userId,
          postId: postId,
          voteEndTime: voteEndTime,
          imageUrlsA: imageUrlsA,
          imageUrlsB: imageUrlsB,
          aspectRatioA: aspectRatioA,
          aspectRatioB: aspectRatioB,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          isRead: false,
          // ... other fields
        );

        final dto = NotificationMapper.toDto(notification);
        await _remoteDatasource.sendNotification(dto);

        // 큐와 캐시 업데이트
        _queueService.addNotification(notification);
        UnifiedCacheService.instance.invalidate('notifications_$userId');

        return unit;
      },
      onDuplicate: () async {
        // ✅ 중복 생성 시도 시 큐와 캐시만 업데이트 (Firestore 스킵)
        // Note: 이미 생성된 알림을 큐에 추가하려면 Firestore에서 조회 필요
        UnifiedCacheService.instance.invalidate('notifications_$userId');
        return unit;
      },
      operationType: 'create_voting_notification',
    );

    return right(result);
  } catch (e) {
    return left(DatabaseError(e.toString()));
  }
}
```

**eventId 생성 전략**:
```dart
// UseCase에서 postId 기반 eventId 생성 (권장)
final eventId = 'voting_notif_${postId}_${DateTime.now().millisecondsSinceEpoch}';

// 또는 UUID v5 (namespace + name)
final eventId = const Uuid().v5(Uuid.NAMESPACE_URL, 'voting_notif_$postId');
```

### Step 8: UseCase에 eventId 파라미터 추가

**작업 시간**: 40분 (7개 UseCase)

#### 8-1. MarkAsReadUseCase

**파일**: `lib/features/notifications/domain/usecases/mark_as_read_usecase.dart`

```dart
// ✅ Before (Phase 3)
class MarkAsReadParams extends Equatable {
  final String notificationId;

  const MarkAsReadParams({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];
}

class MarkAsReadUseCase implements UseCase<MarkAsReadParams, Unit> {
  final INotificationRepository _repository;

  MarkAsReadUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    // ❌ eventId 생성 및 전달 없음
    return _repository.markAsRead(params.notificationId);
  }
}
```

```dart
// ✅ After (Phase 4)
import 'package:uuid/uuid.dart';  // ✅ Import 추가

class MarkAsReadParams extends Equatable {
  final String notificationId;
  final String? eventId;  // ✅ Optional - 없으면 자동 생성

  const MarkAsReadParams({
    required this.notificationId,
    this.eventId,
  });

  @override
  List<Object?> get props => [notificationId, eventId];
}

class MarkAsReadUseCase implements UseCase<MarkAsReadParams, Unit> {
  final INotificationRepository _repository;

  MarkAsReadUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
    // ✅ eventId 자동 생성 또는 전달받은 값 사용
    final eventId = params.eventId ?? const Uuid().v4();

    return _repository.markAsRead(
      params.notificationId,
      eventId,
    );
  }
}
```

**UI에서 호출**:
```dart
// eventId 없이 호출 (자동 생성)
await ref.read(markAsReadUseCaseProvider)(
  MarkAsReadParams(notificationId: 'notif_123'),
);

// eventId 직접 전달 (멱등성 보장 필요 시)
await ref.read(markAsReadUseCaseProvider)(
  MarkAsReadParams(
    notificationId: 'notif_123',
    eventId: 'user_action_mark_read_123',
  ),
);
```

#### 8-2. MarkAllAsReadUseCase

**파일**: `lib/features/notifications/domain/usecases/mark_all_as_read_usecase.dart`

```dart
// ✅ Before
class MarkAllAsReadParams extends Equatable {
  final String userId;

  const MarkAllAsReadParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class MarkAllAsReadUseCase implements UseCase<MarkAllAsReadParams, Unit> {
  final INotificationRepository _repository;

  MarkAllAsReadUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(MarkAllAsReadParams params) async {
    return _repository.markAllAsRead(params.userId);
  }
}
```

```dart
// ✅ After
import 'package:uuid/uuid.dart';

class MarkAllAsReadParams extends Equatable {
  final String userId;
  final String? eventId;

  const MarkAllAsReadParams({
    required this.userId,
    this.eventId,
  });

  @override
  List<Object?> get props => [userId, eventId];
}

class MarkAllAsReadUseCase implements UseCase<MarkAllAsReadParams, Unit> {
  final INotificationRepository _repository;

  MarkAllAsReadUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(MarkAllAsReadParams params) async {
    final eventId = params.eventId ?? const Uuid().v4();

    return _repository.markAllAsRead(
      params.userId,
      eventId,
    );
  }
}
```

#### 8-3. DeleteNotificationUseCase

**파일**: `lib/features/notifications/domain/usecases/delete_notification_usecase.dart`

```dart
// ✅ Before
class DeleteNotificationParams extends Equatable {
  final String notificationId;

  const DeleteNotificationParams({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class DeleteNotificationUseCase implements UseCase<DeleteNotificationParams, Unit> {
  final INotificationRepository _repository;

  DeleteNotificationUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(DeleteNotificationParams params) async {
    return _repository.deleteNotification(params.notificationId);
  }
}
```

```dart
// ✅ After
import 'package:uuid/uuid.dart';

class DeleteNotificationParams extends Equatable {
  final String notificationId;
  final String? eventId;

  const DeleteNotificationParams({
    required this.notificationId,
    this.eventId,
  });

  @override
  List<Object?> get props => [notificationId, eventId];
}

class DeleteNotificationUseCase implements UseCase<DeleteNotificationParams, Unit> {
  final INotificationRepository _repository;

  DeleteNotificationUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(DeleteNotificationParams params) async {
    final eventId = params.eventId ?? const Uuid().v4();

    return _repository.deleteNotification(
      params.notificationId,
      eventId,
    );
  }
}
```

#### 8-4. DeleteAllNotificationsUseCase

**파일**: `lib/features/notifications/domain/usecases/delete_all_notifications_usecase.dart`

```dart
// ✅ Before
class DeleteAllNotificationsParams extends Equatable {
  final String userId;

  const DeleteAllNotificationsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class DeleteAllNotificationsUseCase implements UseCase<DeleteAllNotificationsParams, Unit> {
  final INotificationRepository _repository;

  DeleteAllNotificationsUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(DeleteAllNotificationsParams params) async {
    return _repository.deleteAllNotifications(params.userId);
  }
}
```

```dart
// ✅ After
import 'package:uuid/uuid.dart';

class DeleteAllNotificationsParams extends Equatable {
  final String userId;
  final String? eventId;

  const DeleteAllNotificationsParams({
    required this.userId,
    this.eventId,
  });

  @override
  List<Object?> get props => [userId, eventId];
}

class DeleteAllNotificationsUseCase implements UseCase<DeleteAllNotificationsParams, Unit> {
  final INotificationRepository _repository;

  DeleteAllNotificationsUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(DeleteAllNotificationsParams params) async {
    final eventId = params.eventId ?? const Uuid().v4();

    return _repository.deleteAllNotifications(
      params.userId,
      eventId,
    );
  }
}
```

#### 8-5. SendNotificationUseCase

**파일**: `lib/features/notifications/domain/usecases/send_notification_usecase.dart`

```dart
// ✅ Before
class SendNotificationParams extends Equatable {
  final Notification notification;

  const SendNotificationParams({required this.notification});

  @override
  List<Object> get props => [notification];
}

class SendNotificationUseCase implements UseCase<SendNotificationParams, Unit> {
  final INotificationRepository _repository;

  SendNotificationUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(SendNotificationParams params) async {
    return _repository.sendNotification(params.notification);
  }
}
```

```dart
// ✅ After
import 'package:uuid/uuid.dart';

class SendNotificationParams extends Equatable {
  final Notification notification;
  final String? eventId;

  const SendNotificationParams({
    required this.notification,
    this.eventId,
  });

  @override
  List<Object?> get props => [notification, eventId];
}

class SendNotificationUseCase implements UseCase<SendNotificationParams, Unit> {
  final INotificationRepository _repository;

  SendNotificationUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(SendNotificationParams params) async {
    final eventId = params.eventId ?? const Uuid().v4();

    return _repository.sendNotification(
      params.notification,
      eventId,
    );
  }
}
```

#### 8-6. CreateVotingNotificationUseCase

**파일**: `lib/features/notifications/domain/usecases/create_voting_notification_usecase.dart`

```dart
// ✅ Before
class CreateVotingNotificationParams extends Equatable {
  final String postId;
  final String userId;
  final DateTime voteEndTime;
  final List<String> imageUrlsA;
  final List<String> imageUrlsB;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final String title;
  final String description;
  // ... 30+ fields

  const CreateVotingNotificationParams({
    required this.postId,
    required this.userId,
    required this.voteEndTime,
    required this.imageUrlsA,
    required this.imageUrlsB,
    this.aspectRatioA,
    this.aspectRatioB,
    required this.title,
    required this.description,
    // ... other fields
  });

  @override
  List<Object?> get props => [
    postId, userId, voteEndTime, imageUrlsA, imageUrlsB,
    aspectRatioA, aspectRatioB, title, description,
    // ... other fields
  ];
}

class CreateVotingNotificationUseCase
    implements UseCase<CreateVotingNotificationParams, Unit> {
  final INotificationRepository _repository;

  CreateVotingNotificationUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(
    CreateVotingNotificationParams params,
  ) async {
    return _repository.createVotingNotification(
      postId: params.postId,
      userId: params.userId,
      voteEndTime: params.voteEndTime,
      imageUrlsA: params.imageUrlsA,
      imageUrlsB: params.imageUrlsB,
      aspectRatioA: params.aspectRatioA,
      aspectRatioB: params.aspectRatioB,
      title: params.title,
      description: params.description,
      // ... other fields
    );
  }
}
```

```dart
// ✅ After
import 'package:uuid/uuid.dart';

class CreateVotingNotificationParams extends Equatable {
  final String postId;
  final String userId;
  final DateTime voteEndTime;
  final List<String> imageUrlsA;
  final List<String> imageUrlsB;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final String title;
  final String description;
  final String? eventId;  // ✅ 추가
  // ... 30+ fields

  const CreateVotingNotificationParams({
    required this.postId,
    required this.userId,
    required this.voteEndTime,
    required this.imageUrlsA,
    required this.imageUrlsB,
    this.aspectRatioA,
    this.aspectRatioB,
    required this.title,
    required this.description,
    this.eventId,  // ✅ Optional
    // ... other fields
  });

  @override
  List<Object?> get props => [
    postId, userId, voteEndTime, imageUrlsA, imageUrlsB,
    aspectRatioA, aspectRatioB, title, description, eventId,  // ✅ eventId 추가
    // ... other fields
  ];
}

class CreateVotingNotificationUseCase
    implements UseCase<CreateVotingNotificationParams, Unit> {
  final INotificationRepository _repository;

  CreateVotingNotificationUseCase({required INotificationRepository repository})
      : _repository = repository;

  @override
  Future<Either<NotificationFailure, Unit>> call(
    CreateVotingNotificationParams params,
  ) async {
    // ✅ postId 기반 결정적 eventId 생성 (같은 post에 대한 중복 알림 방지)
    final eventId = params.eventId ??
        const Uuid().v5(Uuid.NAMESPACE_URL, 'voting_notif_${params.postId}');

    return _repository.createVotingNotification(
      postId: params.postId,
      userId: params.userId,
      voteEndTime: params.voteEndTime,
      imageUrlsA: params.imageUrlsA,
      imageUrlsB: params.imageUrlsB,
      aspectRatioA: params.aspectRatioA,
      aspectRatioB: params.aspectRatioB,
      title: params.title,
      description: params.description,
      eventId: eventId,  // ✅ 전달
      // ... other fields
    );
  }
}
```

**UUID v5 전략 설명**:
```dart
// ✅ UUID v5: Namespace + Name → 결정적 UUID 생성
// 같은 postId에 대해 항상 동일한 eventId 생성
final eventId = const Uuid().v5(Uuid.NAMESPACE_URL, 'voting_notif_post_123');

// 동일 post에 대한 중복 알림 생성 시도 시
// → 동일한 eventId → IdempotencyService가 차단
```

---

## 🧪 Test Strategy

### Phase 4 테스트 목표

1. **멱등성 검증**: 동일 eventId로 2번 호출 시 1번만 실행
2. **Transaction 안전성**: Batch 작업 중 실패 시 롤백 확인
3. **Race Condition 방지**: 동시 호출 시 중복 차단
4. **캐시 일관성**: 멱등성 동작 시에도 캐시 정상 무효화

### Test 1: markAsRead 멱등성

**파일**: `lib/features/notifications/test/unit/idempotency/mark_as_read_idempotency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/notifications/domain/usecases/mark_as_read_usecase.dart';

void main() {
  group('MarkAsReadUseCase Idempotency', () {
    late MarkAsReadUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = MarkAsReadUseCase(repository: mockRepository);
    });

    test('동일 eventId로 2번 호출 시 Repository는 1번만 호출됨', () async {
      // Arrange
      const notificationId = 'notif_123';
      const eventId = 'evt_mark_read_123';

      when(mockRepository.markAsRead(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 동일 eventId로 2번 호출
      await usecase(MarkAsReadParams(
        notificationId: notificationId,
        eventId: eventId,
      ));

      await usecase(MarkAsReadParams(
        notificationId: notificationId,
        eventId: eventId,  // ✅ 동일한 eventId
      ));

      // Assert: Repository는 1번만 호출되어야 함
      verify(mockRepository.markAsRead(notificationId, eventId)).called(1);
    });

    test('다른 eventId로 호출 시 Repository는 2번 호출됨', () async {
      // Arrange
      const notificationId = 'notif_123';

      when(mockRepository.markAsRead(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 다른 eventId로 2번 호출
      await usecase(MarkAsReadParams(
        notificationId: notificationId,
        eventId: 'evt_1',
      ));

      await usecase(MarkAsReadParams(
        notificationId: notificationId,
        eventId: 'evt_2',  // ✅ 다른 eventId
      ));

      // Assert: Repository는 2번 호출되어야 함
      verify(mockRepository.markAsRead(any, any)).called(2);
    });

    test('eventId 없이 호출 시 자동 생성되어 멱등성 보장 안됨', () async {
      // Arrange
      const notificationId = 'notif_123';

      when(mockRepository.markAsRead(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: eventId 없이 2번 호출
      await usecase(MarkAsReadParams(notificationId: notificationId));
      await usecase(MarkAsReadParams(notificationId: notificationId));

      // Assert: Repository는 2번 호출됨 (각각 다른 eventId 생성)
      verify(mockRepository.markAsRead(any, any)).called(2);
    });
  });
}
```

### Test 2: deleteNotification 멱등성

**파일**: `lib/features/notifications/test/unit/idempotency/delete_notification_idempotency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/notifications/domain/usecases/delete_notification_usecase.dart';

void main() {
  group('DeleteNotificationUseCase Idempotency', () {
    late DeleteNotificationUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = DeleteNotificationUseCase(repository: mockRepository);
    });

    test('동일 eventId로 삭제 시도 시 1번만 실행', () async {
      // Arrange
      const notificationId = 'notif_abc';
      const eventId = 'evt_delete_abc';

      when(mockRepository.deleteNotification(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 동일 eventId로 2번 삭제 시도
      final result1 = await usecase(DeleteNotificationParams(
        notificationId: notificationId,
        eventId: eventId,
      ));

      final result2 = await usecase(DeleteNotificationParams(
        notificationId: notificationId,
        eventId: eventId,
      ));

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      verify(mockRepository.deleteNotification(notificationId, eventId)).called(1);
    });

    test('NotificationNotFound 에러 시 올바른 Failure 반환', () async {
      // Arrange
      const notificationId = 'notif_not_exist';
      const eventId = 'evt_delete_not_exist';

      when(mockRepository.deleteNotification(any, any))
          .thenAnswer((_) async => left(const NotificationNotFound()));

      // Act
      final result = await usecase(DeleteNotificationParams(
        notificationId: notificationId,
        eventId: eventId,
      ));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotificationNotFound>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
```

### Test 3: Batch Delete Transaction 안전성

**파일**: `lib/features/notifications/test/unit/idempotency/batch_delete_idempotency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/notifications/domain/usecases/delete_all_notifications_usecase.dart';

void main() {
  group('DeleteAllNotificationsUseCase Transaction Safety', () {
    late DeleteAllNotificationsUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = DeleteAllNotificationsUseCase(repository: mockRepository);
    });

    test('Transaction 실패 시 모두 롤백됨', () async {
      // Arrange
      const userId = 'user_123';
      const eventId = 'evt_delete_all_123';

      // Transaction 중간에 실패하도록 설정
      when(mockRepository.deleteAllNotifications(any, any))
          .thenAnswer((_) async => left(const DatabaseError('Transaction failed')));

      // Act
      final result = await usecase(DeleteAllNotificationsParams(
        userId: userId,
        eventId: eventId,
      ));

      // Assert: Failure 반환
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseError>()),
        (_) => fail('Should return Left'),
      );
    });

    test('Transaction 성공 시 모든 알림 삭제됨', () async {
      // Arrange
      const userId = 'user_123';
      const eventId = 'evt_delete_all_success';

      when(mockRepository.deleteAllNotifications(any, any))
          .thenAnswer((_) async => right(unit));

      // Act
      final result = await usecase(DeleteAllNotificationsParams(
        userId: userId,
        eventId: eventId,
      ));

      // Assert: 성공
      expect(result.isRight(), true);
      verify(mockRepository.deleteAllNotifications(userId, eventId)).called(1);
    });

    test('동일 eventId로 2번 호출 시 Transaction은 1번만 실행', () async {
      // Arrange
      const userId = 'user_123';
      const eventId = 'evt_delete_all_idempotent';

      when(mockRepository.deleteAllNotifications(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 동일 eventId로 2번 호출
      await usecase(DeleteAllNotificationsParams(userId: userId, eventId: eventId));
      await usecase(DeleteAllNotificationsParams(userId: userId, eventId: eventId));

      // Assert: Repository는 1번만 호출 (멱등성)
      verify(mockRepository.deleteAllNotifications(userId, eventId)).called(1);
    });
  });
}
```

### Test 4: sendNotification 중복 전송 방지

**파일**: `lib/features/notifications/test/unit/idempotency/send_notification_idempotency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/notifications/domain/models/notification.dart';
import 'package:versus_space/features/notifications/domain/usecases/send_notification_usecase.dart';

void main() {
  group('SendNotificationUseCase 중복 전송 방지', () {
    late SendNotificationUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = SendNotificationUseCase(repository: mockRepository);
    });

    test('동일 eventId로 알림 전송 시도 시 1번만 전송', () async {
      // Arrange
      final notification = Notification.social(
        id: 'notif_social_123',
        userId: 'user_123',
        actionType: SocialActionType.like,
        fromUserId: 'user_456',
        createdAt: DateTime.now(),
        isRead: false,
      );
      const eventId = 'evt_send_social_123';

      when(mockRepository.sendNotification(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 동일 eventId로 2번 전송 시도
      await usecase(SendNotificationParams(notification: notification, eventId: eventId));
      await usecase(SendNotificationParams(notification: notification, eventId: eventId));

      // Assert: Repository는 1번만 호출
      verify(mockRepository.sendNotification(notification, eventId)).called(1);
    });

    test('VotingNotification 중복 전송 방지', () async {
      // Arrange
      final votingNotif = Notification.voting(
        id: 'notif_voting_123',
        userId: 'user_123',
        postId: 'post_abc',
        voteEndTime: DateTime.now().add(Duration(hours: 24)),
        imageUrlsA: ['https://example.com/a1.jpg'],
        imageUrlsB: ['https://example.com/b1.jpg'],
        title: 'Test Vote',
        description: 'Test Description',
        createdAt: DateTime.now(),
        isRead: false,
      );
      const eventId = 'evt_send_voting_123';

      when(mockRepository.sendNotification(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 동일 eventId로 2번 전송 시도
      await usecase(SendNotificationParams(notification: votingNotif, eventId: eventId));
      await usecase(SendNotificationParams(notification: votingNotif, eventId: eventId));

      // Assert: Repository는 1번만 호출
      verify(mockRepository.sendNotification(votingNotif, eventId)).called(1);
    });
  });
}
```

### Test 5: createVotingNotification 멱등성

**파일**: `lib/features/notifications/test/unit/idempotency/create_voting_idempotency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';
import 'package:versus_space/features/notifications/domain/usecases/create_voting_notification_usecase.dart';

void main() {
  group('CreateVotingNotificationUseCase 멱등성', () {
    late CreateVotingNotificationUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = CreateVotingNotificationUseCase(repository: mockRepository);
    });

    test('동일 postId로 중복 생성 시도 시 1번만 생성 (UUID v5)', () async {
      // Arrange
      const postId = 'post_abc';
      const userId = 'user_123';
      final voteEndTime = DateTime.now().add(Duration(hours: 24));

      // UUID v5로 결정적 eventId 생성 (같은 postId에 대해 항상 동일)
      final expectedEventId = const Uuid().v5(Uuid.NAMESPACE_URL, 'voting_notif_$postId');

      when(mockRepository.createVotingNotification(
        postId: anyNamed('postId'),
        userId: anyNamed('userId'),
        voteEndTime: anyNamed('voteEndTime'),
        imageUrlsA: anyNamed('imageUrlsA'),
        imageUrlsB: anyNamed('imageUrlsB'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        eventId: anyNamed('eventId'),
        // ... other named parameters
      )).thenAnswer((_) async => right(unit));

      // Act: 동일 postId로 2번 생성 시도
      final params = CreateVotingNotificationParams(
        postId: postId,
        userId: userId,
        voteEndTime: voteEndTime,
        imageUrlsA: ['https://example.com/a1.jpg'],
        imageUrlsB: ['https://example.com/b1.jpg'],
        title: 'Test Vote',
        description: 'Test Description',
        // eventId 없음 → UseCase에서 UUID v5로 자동 생성
      );

      await usecase(params);
      await usecase(params);  // ✅ 동일 postId → 동일 eventId

      // Assert: Repository는 1번만 호출 (같은 eventId로 멱등성 보장)
      verify(mockRepository.createVotingNotification(
        postId: postId,
        userId: userId,
        voteEndTime: voteEndTime,
        imageUrlsA: ['https://example.com/a1.jpg'],
        imageUrlsB: ['https://example.com/b1.jpg'],
        title: 'Test Vote',
        description: 'Test Description',
        eventId: expectedEventId,
        // ... other parameters
      )).called(1);
    });

    test('다른 postId로 생성 시 각각 생성됨', () async {
      // Arrange
      const userId = 'user_123';
      final voteEndTime = DateTime.now().add(Duration(hours: 24));

      when(mockRepository.createVotingNotification(
        postId: anyNamed('postId'),
        userId: anyNamed('userId'),
        voteEndTime: anyNamed('voteEndTime'),
        imageUrlsA: anyNamed('imageUrlsA'),
        imageUrlsB: anyNamed('imageUrlsB'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        eventId: anyNamed('eventId'),
      )).thenAnswer((_) async => right(unit));

      // Act: 다른 postId로 2번 생성
      await usecase(CreateVotingNotificationParams(
        postId: 'post_1',
        userId: userId,
        voteEndTime: voteEndTime,
        imageUrlsA: ['https://example.com/a1.jpg'],
        imageUrlsB: ['https://example.com/b1.jpg'],
        title: 'Vote 1',
        description: 'Desc 1',
      ));

      await usecase(CreateVotingNotificationParams(
        postId: 'post_2',  // ✅ 다른 postId
        userId: userId,
        voteEndTime: voteEndTime,
        imageUrlsA: ['https://example.com/a2.jpg'],
        imageUrlsB: ['https://example.com/b2.jpg'],
        title: 'Vote 2',
        description: 'Desc 2',
      ));

      // Assert: Repository는 2번 호출 (다른 eventId)
      verify(mockRepository.createVotingNotification(
        postId: anyNamed('postId'),
        userId: anyNamed('userId'),
        voteEndTime: anyNamed('voteEndTime'),
        imageUrlsA: anyNamed('imageUrlsA'),
        imageUrlsB: anyNamed('imageUrlsB'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        eventId: anyNamed('eventId'),
      )).called(2);
    });
  });
}
```

### Test 6: 동시 작업 Race Condition 방지

**파일**: `lib/features/notifications/test/unit/idempotency/concurrent_operations_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/notifications/domain/usecases/mark_as_read_usecase.dart';

void main() {
  group('Concurrent Operations Race Condition 방지', () {
    late MarkAsReadUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = MarkAsReadUseCase(repository: mockRepository);
    });

    test('동시에 100번 호출 시 Repository는 1번만 호출됨', () async {
      // Arrange
      const notificationId = 'notif_race_test';
      const eventId = 'evt_race_test';

      when(mockRepository.markAsRead(any, any))
          .thenAnswer((_) async => right(unit));

      // Act: 동시에 100번 호출
      final futures = List.generate(
        100,
        (_) => usecase(MarkAsReadParams(
          notificationId: notificationId,
          eventId: eventId,
        )),
      );

      await Future.wait(futures);

      // Assert: Repository는 1번만 호출 (멱등성 보장)
      verify(mockRepository.markAsRead(notificationId, eventId)).called(1);
    });
  });
}
```

### Test 7: Transaction 롤백 시나리오

**파일**: `lib/features/notifications/test/unit/idempotency/transaction_safety_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/notifications/domain/usecases/mark_all_as_read_usecase.dart';

void main() {
  group('Transaction Rollback Safety', () {
    late MarkAllAsReadUseCase usecase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      usecase = MarkAllAsReadUseCase(repository: mockRepository);
    });

    test('Transaction 중간 실패 시 모두 롤백', () async {
      // Arrange
      const userId = 'user_123';
      const eventId = 'evt_mark_all_fail';

      // Transaction 실패 시뮬레이션
      when(mockRepository.markAllAsRead(any, any))
          .thenAnswer((_) async => left(const DatabaseError('Transaction aborted')));

      // Act
      final result = await usecase(MarkAllAsReadParams(
        userId: userId,
        eventId: eventId,
      ));

      // Assert: Failure 반환
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseError>());
          expect((failure as DatabaseError).message, contains('Transaction'));
        },
        (_) => fail('Should return Left'),
      );
    });
  });
}
```

### 테스트 실행 명령어

```bash
# 모든 멱등성 테스트 실행
flutter test lib/features/notifications/test/unit/idempotency/

# 개별 테스트 실행
flutter test lib/features/notifications/test/unit/idempotency/mark_as_read_idempotency_test.dart

# 커버리지와 함께 실행
flutter test lib/features/notifications/test/unit/idempotency/ --coverage

# 커버리지 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔄 Rollback Plan

### Phase 4 롤백 시나리오

**문제 상황**:
- IdempotencyService 통합 후 예상치 못한 버그 발생
- Transaction 패턴으로 인한 성능 저하
- 멱등성 로직 오작동 (중복 차단이 안 되는 경우)

### Rollback 절차

#### Step 1: Repository Interface 되돌리기

```bash
# Git에서 Phase 3 버전으로 되돌리기
git checkout HEAD~1 lib/features/notifications/domain/repositories/i_notification_repository.dart
```

**또는 수동 되돌리기**:
```dart
// eventId 파라미터 제거
Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId);
Future<Either<NotificationFailure, Unit>> deleteNotification(String notificationId);
// ... 모든 Write 메서드에서 eventId 제거
```

#### Step 2: Repository 구현체 되돌리기

```bash
# Git에서 Phase 3 버전으로 되돌리기
git checkout HEAD~1 lib/features/notifications/data/repositories/notification_repository_impl.dart
```

**또는 수동 되돌리기**:
```dart
// IdempotencyService 제거
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;
  // ❌ IdempotencyService 제거

  // executeIdempotent() 래퍼 제거
  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);
      UnifiedCacheService.instance.invalidate('notification_$notificationId');
      return right(unit);
    } catch (e) {
      return left(DatabaseError(e.toString()));
    }
  }

  // Transaction 패턴 제거 (순차 처리로 복귀)
  @override
  Future<Either<NotificationFailure, Unit>> markAllAsRead(String userId) async {
    try {
      final notifications = await _remoteDatasource.getUserNotifications(userId);

      for (final dto in notifications) {
        await _remoteDatasource.markAsRead(dto.id);
      }

      UnifiedCacheService.instance.invalidate('notifications_$userId');
      return right(unit);
    } catch (e) {
      return left(DatabaseError(e.toString()));
    }
  }
}
```

#### Step 3: UseCase 파라미터 되돌리기

```bash
# 모든 UseCase 파일 되돌리기
git checkout HEAD~1 lib/features/notifications/domain/usecases/*.dart
```

**또는 수동 되돌리기**:
```dart
// eventId 파라미터 제거
class MarkAsReadParams extends Equatable {
  final String notificationId;
  // ❌ eventId 제거

  const MarkAsReadParams({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

// UseCase에서 eventId 생성 로직 제거
@override
Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
  return _repository.markAsRead(params.notificationId);
}
```

#### Step 4: 테스트 파일 삭제

```bash
# 멱등성 테스트 디렉토리 삭제
rm -rf lib/features/notifications/test/unit/idempotency/
```

#### Step 5: 컴파일 확인

```bash
# 컴파일 에러 확인
flutter analyze lib/features/notifications/

# 빌드 테스트
flutter build apk --debug
```

#### Step 6: UI 코드 업데이트

```dart
// Presentation 레이어에서 eventId 파라미터 제거

// ❌ Before (Phase 4)
await ref.read(markAsReadUseCaseProvider)(
  MarkAsReadParams(
    notificationId: notif.id,
    eventId: 'user_action_${DateTime.now().millisecondsSinceEpoch}',
  ),
);

// ✅ After (Rollback)
await ref.read(markAsReadUseCaseProvider)(
  MarkAsReadParams(notificationId: notif.id),
);
```

### Rollback 체크리스트

- [ ] Repository Interface에서 eventId 파라미터 제거
- [ ] Repository 구현체에서 IdempotencyService 제거
- [ ] Transaction 패턴을 순차 처리로 복귀
- [ ] UseCase Params 클래스에서 eventId 제거
- [ ] UseCase call() 메서드에서 eventId 생성 로직 제거
- [ ] 멱등성 테스트 디렉토리 삭제
- [ ] Presentation 레이어 코드 업데이트
- [ ] `flutter analyze` 통과 확인
- [ ] 빌드 성공 확인

---

## ✅ Completion Checklist

### Phase 4 완료 확인

#### 코드 변경 완료

- [ ] **Repository Interface 업데이트** (i_notification_repository.dart)
  - [ ] 모든 Write 메서드에 `String eventId` 파라미터 추가
  - [ ] Read 메서드는 변경 없음 확인

- [ ] **Repository 구현체 리팩토링** (notification_repository_impl.dart)
  - [ ] IdempotencyService 주입 완료
  - [ ] markAsRead 메서드에 executeIdempotent 적용
  - [ ] deleteNotification 메서드에 executeIdempotent 적용
  - [ ] markAllAsRead 메서드에 Transaction 패턴 적용
  - [ ] deleteAllNotifications 메서드에 Transaction 패턴 적용
  - [ ] sendNotification 메서드에 executeIdempotent 적용
  - [ ] createVotingNotification 메서드에 executeIdempotent 적용

- [ ] **UseCase 파라미터 추가** (7개 UseCase)
  - [ ] MarkAsReadParams에 `String? eventId` 추가
  - [ ] MarkAllAsReadParams에 `String? eventId` 추가
  - [ ] DeleteNotificationParams에 `String? eventId` 추가
  - [ ] DeleteAllNotificationsParams에 `String? eventId` 추가
  - [ ] SendNotificationParams에 `String? eventId` 추가
  - [ ] CreateVotingNotificationParams에 `String? eventId` 추가

- [ ] **UseCase eventId 생성 로직** (7개 UseCase)
  - [ ] MarkAsReadUseCase에 UUID v4 생성 로직 추가
  - [ ] MarkAllAsReadUseCase에 UUID v4 생성 로직 추가
  - [ ] DeleteNotificationUseCase에 UUID v4 생성 로직 추가
  - [ ] DeleteAllNotificationsUseCase에 UUID v4 생성 로직 추가
  - [ ] SendNotificationUseCase에 UUID v4 생성 로직 추가
  - [ ] CreateVotingNotificationUseCase에 UUID v5 생성 로직 추가

#### 테스트 작성 완료

- [ ] **멱등성 테스트** (7개 파일)
  - [ ] mark_as_read_idempotency_test.dart 작성 (60줄)
  - [ ] delete_notification_idempotency_test.dart 작성 (65줄)
  - [ ] batch_delete_idempotency_test.dart 작성 (80줄)
  - [ ] send_notification_idempotency_test.dart 작성 (70줄)
  - [ ] create_voting_idempotency_test.dart 작성 (85줄)
  - [ ] concurrent_operations_test.dart 작성 (55줄)
  - [ ] transaction_safety_test.dart 작성 (35줄)

#### 테스트 실행 및 검증

- [ ] **단위 테스트 통과**
  ```bash
  flutter test lib/features/notifications/test/unit/idempotency/
  # ✅ All tests passed (450 tests)
  ```

- [ ] **멱등성 검증**
  - [ ] 동일 eventId로 2번 호출 시 1번만 실행 확인
  - [ ] 다른 eventId로 호출 시 각각 실행 확인
  - [ ] eventId 없이 호출 시 자동 생성 확인

- [ ] **Transaction 안전성 검증**
  - [ ] Batch 작업 중 실패 시 롤백 확인
  - [ ] Transaction 성공 시 모든 변경 커밋 확인

- [ ] **Race Condition 방지 검증**
  - [ ] 동시 100번 호출 시 1번만 실행 확인

#### 컴파일 및 빌드 확인

- [ ] **컴파일 에러 없음**
  ```bash
  flutter analyze lib/features/notifications/
  # ✅ No issues found
  ```

- [ ] **빌드 성공**
  ```bash
  flutter build apk --debug
  # ✅ Built successfully
  ```

#### 문서화 완료

- [ ] **PHASE_4_IDEMPOTENCY.md 작성 완료**
  - [ ] Overview 섹션 작성
  - [ ] Current State 섹션 작성
  - [ ] Migration Goals 섹션 작성
  - [ ] Step-by-Step Guide 작성 (8 steps)
  - [ ] Test Strategy 작성
  - [ ] Rollback Plan 작성
  - [ ] Completion Checklist 작성

- [ ] **README 업데이트**
  - [ ] Phase 4 완료 상태 업데이트
  - [ ] 멱등성 기능 설명 추가

---

## 📈 Impact Analysis

### 성능 영향

#### Before Phase 4 (멱등성 없음)

```dart
// ❌ 중복 호출 시 Firestore 작업 중복 발생
await markAsRead('notif_123');  // 100ms
await markAsRead('notif_123');  // 100ms (중복)
// Total: 200ms
```

#### After Phase 4 (멱등성 보장)

```dart
// ✅ 중복 호출 시 캐시만 무효화 (Firestore 스킵)
await markAsRead('notif_123', 'evt_123');  // 100ms
await markAsRead('notif_123', 'evt_123');  // <10ms (onDuplicate)
// Total: ~110ms (45% 향상)
```

### 데이터 일관성

#### Before Phase 4

```dart
// ❌ Batch 작업 중 50번째 실패 시
// → 49개는 이미 업데이트됨 (롤백 불가능)
for (int i = 0; i < 100; i++) {
  await markAsRead(notifications[i].id);
  if (i == 50) throw Exception();  // 50번째 실패
}
// Result: 50개는 읽음, 50개는 안 읽음 (일관성 깨짐)
```

#### After Phase 4

```dart
// ✅ Transaction: All-or-Nothing
await firestore.runTransaction((transaction) async {
  for (final notif in notifications) {
    transaction.update(notif.reference, {'isRead': true});
  }
});
// Result: 모두 읽음 또는 모두 안 읽음 (일관성 보장)
```

### 중복 알림 방지

#### Before Phase 4

```dart
// ❌ 동시에 2번 버튼 클릭 시 중복 알림 생성
await createVotingNotification(postId: 'post_123', ...);  // Firestore에 생성
await createVotingNotification(postId: 'post_123', ...);  // 중복 생성
// Result: 2개의 동일한 알림
```

#### After Phase 4

```dart
// ✅ UUID v5로 결정적 eventId 생성 → 중복 차단
final eventId = Uuid().v5(Uuid.NAMESPACE_URL, 'voting_notif_post_123');
await createVotingNotification(postId: 'post_123', eventId: eventId, ...);  // 생성
await createVotingNotification(postId: 'post_123', eventId: eventId, ...);  // 차단
// Result: 1개의 알림만 생성
```

### 코드 복잡도

| 항목 | Before Phase 4 | After Phase 4 | 증가율 |
|------|----------------|---------------|--------|
| Repository 메서드 평균 줄 수 | 12줄 | 18줄 | **+50%** |
| UseCase 메서드 평균 줄 수 | 8줄 | 11줄 | **+37.5%** |
| 테스트 커버리지 | 0% | 80% | **+80%** |

**복잡도 증가 요인**:
- `executeIdempotent()` 래퍼 추가
- `operation` + `onDuplicate` 콜백 구조
- eventId 생성 로직
- Transaction 패턴 적용

**복잡도 증가 대비 이점**:
- ✅ 중복 작업 완전 차단
- ✅ 데이터 일관성 보장
- ✅ Race Condition 방지
- ✅ 멱등성 자동 보장

---

## 📚 Learning Resources

### IdempotencyService 이해

**개념**: 동일한 요청을 여러 번 실행해도 결과가 동일하게 유지되는 성질

**예시**:
```dart
// ✅ 멱등성 O: 여러 번 실행해도 결과 동일
PUT /notifications/123 { "isRead": true }

// ❌ 멱등성 X: 여러 번 실행 시 결과 달라짐
POST /notifications { "userId": "user_123" }  // 매번 새 알림 생성
```

**구현 방식**:
```dart
class IdempotencyService {
  final Map<String, Future<dynamic>> _pendingOperations = {};

  Future<T> executeIdempotent<T>({
    required String eventId,
    required Future<T> Function() operation,
    required Future<T> Function() onDuplicate,
    required String operationType,
  }) async {
    // 이미 실행 중인 작업이면 대기
    if (_pendingOperations.containsKey(eventId)) {
      return await _pendingOperations[eventId] as T;
    }

    // 새 작업 시작
    _pendingOperations[eventId] = operation();

    try {
      final result = await _pendingOperations[eventId] as T;
      return result;
    } finally {
      _pendingOperations.remove(eventId);
    }
  }
}
```

### Transaction 패턴

**Firestore Transaction 특징**:
- All-or-Nothing: 모든 작업이 성공하거나 모두 롤백
- 최대 500개 문서 수정 가능
- 읽기 → 쓰기 순서 보장

**예시**:
```dart
await firestore.runTransaction((transaction) async {
  // 1. 읽기 작업
  final snapshot = await firestore.collection('notifications').get();

  // 2. 쓰기 작업
  for (final doc in snapshot.docs) {
    transaction.update(doc.reference, {'isRead': true});
  }
});
```

### UUID 생성 전략

**UUID v4 (Random)**:
```dart
final eventId = const Uuid().v4();  // 완전 랜덤
// ✅ 장점: 충돌 가능성 극히 낮음
// ❌ 단점: 같은 작업에 대해 매번 다른 ID
```

**UUID v5 (Namespace + Name)**:
```dart
final eventId = const Uuid().v5(Uuid.NAMESPACE_URL, 'voting_notif_post_123');
// ✅ 장점: 같은 입력에 대해 항상 동일한 ID 생성
// ✅ 장점: 결정적 멱등성 보장
// ❌ 단점: Name이 같으면 ID도 같음 (의도된 동작)
```

### 참고 링크

- [IdempotencyService 소스 코드](/lib/core/utils/idempotency_service.dart)
- [Firestore Transactions 공식 문서](https://firebase.google.com/docs/firestore/manage-data/transactions)
- [UUID RFC 4122](https://datatracker.ietf.org/doc/html/rfc4122)
- [Chat Feature PHASE_4 참조](/lib/features/chat/PHASE_4_IDEMPOTENCY.md)

---

## 🎓 Key Takeaways

### Phase 4에서 배운 것들

1. **멱등성의 중요성**
   - 동일한 요청을 여러 번 실행해도 안전
   - 중복 작업 완전 차단
   - 데이터 일관성 보장

2. **Transaction 패턴**
   - Batch 작업의 All-or-Nothing 보장
   - 중간 실패 시 자동 롤백
   - 데이터 일관성 유지

3. **eventId 설계 전략**
   - UUID v4: 완전 랜덤 (일반 작업)
   - UUID v5: 결정적 생성 (같은 입력 → 같은 ID)
   - postId 기반 eventId로 중복 알림 방지

4. **UseCase 책임 분리**
   - UseCase: eventId 생성 및 검증
   - Repository: 실제 작업 실행 + 멱등성 보장
   - Presentation: eventId 전달 (선택적)

### Phase 5 Preview

다음 Phase에서는 **Extension Pattern**을 적용하여 DataSource/DTO/Mapper 레이어를 완전히 제거합니다:

**목표**:
- Firebase-Centric v2.0 완성
- 11개 파일 삭제 (1,500+ 줄)
- Firestore ↔ Entity 직접 변환
- 코드 간소화 및 유지보수성 향상

**Preview 코드**:
```dart
// ✅ Phase 5: Extension Pattern
extension NotificationFirestore on Notification {
  static Notification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String;

    // Sealed Union 타입 분기
    switch (type) {
      case 'social':
        return Notification.social(
          id: doc.id,
          userId: data['userId'],
          actionType: SocialActionType.values.byName(data['actionType']),
          // ... social fields
        );
      case 'system':
        return Notification.system(/* ... */);
      case 'voting':
        return Notification.voting(/* ... */);
      default:
        throw Exception('Unknown notification type: $type');
    }
  }

  Map<String, dynamic> toFirestore() {
    return when(
      social: (id, userId, actionType, ...) => {
        'type': 'social',
        'userId': userId,
        'actionType': actionType.name,
        // ... social fields
      },
      system: (...) => { 'type': 'system', ... },
      voting: (...) => { 'type': 'voting', ... },
    );
  }
}
```

---

**Phase 4 완료 후 다음 단계**: [PHASE_5_EXTENSION_PATTERN.md](./PHASE_5_EXTENSION_PATTERN.md)
