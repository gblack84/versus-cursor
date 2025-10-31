# Notification Feature - Phase 1: Either Pattern Migration

> **마이그레이션 가이드**: Result<T> → Either<NotificationFailure, T> 전환
> **난이도**: ⭐⭐☆☆☆ (중)
> **예상 소요 시간**: 4시간
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

Notification Feature의 에러 처리를 Legacy `Result<T>` 패턴에서 fpdart의 `Either<L,R>` 패턴으로 전환하여 Auth/Voting/Profile Feature와 일관성을 맞춥니다.

### 핵심 문제점

1. **Legacy Result 패턴**: `Result<T>`, `ResultFailure()`, `Success()` 사용
2. **타입 안전성 부족**: Result의 Failure 타입이 명시적이지 않음
3. **에러 처리 불일치**: try-catch + throw Exception 혼용
4. **Feature 간 불일치**: Auth는 Either, Notification은 Result 사용

### 영향 범위

| 레이어 | 파일 수 | 변경 줄 수 | 주요 변경 사항 |
|--------|---------|-----------|---------------|
| **Domain (Repository)** | 1개 | +50줄 | Either 반환 타입 적용 |
| **Domain (UseCases)** | 5개 | +150줄 | Either 패턴, fold() 메서드 |
| **Data (Repository)** | 1개 | +80줄 | Either 반환, 에러 변환 |
| **합계** | **7개** | **+280줄** | - |

### 주요 이점

| 항목 | Before (Result) | After (Either) | 변화 |
|------|-----------------|----------------|------|
| **타입 안전성** | Dynamic | Explicit | **100% 향상** |
| **에러 타입** | String | NotificationFailure | **명시적** |
| **패턴 일관성** | 불일치 | 통일 | **4개 Feature** |
| **컴파일 체크** | 런타임 | 컴파일 타임 | **조기 발견** |

---

## 🔍 현재 상태 분석 (Phase 0)

### 1. Repository 인터페이스 (예외 기반 에러 처리)

**파일**: `domain/repositories/i_notification_repository.dart`

```dart
/// ❌ 현재: 예외 기반 에러 처리 (Result/Either 미사용)
import '../models/notification.dart';
import '../value_objects/notification_filter.dart';

abstract class INotificationRepository {
  // ❌ Nullable 반환 (에러 타입 없음)
  Future<Notification?> getNotification(String notificationId);

  // ❌ Future<T> 반환, 예외 throw
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  // ❌ Future<void> 반환, 예외 throw
  Future<void> markAsRead(String notificationId);

  // ❌ Future<String> 반환, 예외 throw
  Future<String> createNotification(Notification notification);

  // ❌ Future<void> 반환, 예외 throw
  Future<void> updateNotification(String notificationId, Map<String, dynamic> updates);

  // Stream은 Either 미사용 (표준 패턴)
  Stream<int> watchUnreadCount(String userId);
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });
}
```

**문제점**:
1. **예외 기반 에러 처리**: Repository가 NotificationFailure를 throw
2. **Nullable 반환**: getNotification은 null 또는 예외 throw
3. **타입 안전성 부족**: 에러 타입이 메서드 시그니처에 명시되지 않음
4. **Feature 간 불일치**: Auth/Voting/Profile은 Either<L,R> 사용

### 2. Repository 구현체 (예외 throw 방식)

**파일**: `data/repositories/notification_repository_impl.dart`

```dart
/// ❌ 현재: 예외 기반 에러 처리
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  final NotificationQueueService _queueService;

  @override
  Future<Notification?> getNotification(String notificationId) async {
    try {
      // L1 Cache 조회
      final cached = await _localDatasource.getCachedNotification(notificationId);
      if (cached != null) {
        final dto = _createDtoFromMap(cached);
        return NotificationMapper.toDomain(dto);
      }

      // L2 Firestore 조회
      final data = await _remoteDatasource.getNotification(notificationId);
      // ... DTO → Entity 변환
      return notification;
    } catch (e) {
      print('Error getting notification: $e');
      return null;  // ❌ 예외 정보 손실
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);
      await _localDatasource.clearAllCache();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();  // ❌ 예외 throw
      }
      throw const NotificationLoadFailed();  // ❌ 예외 throw
    }
  }
}
```

**문제점**:
1. **예외 throw**: 에러 발생 시 NotificationFailure를 throw
2. **Nullable 반환**: getNotification은 null 반환으로 에러 정보 손실
3. **타입 안전성 부족**: 메서드 시그니처에 에러 타입 명시 안 됨

### 3. UseCase (Result<T> 번역 레이어)

**파일**: `domain/usecases/mark_as_read_usecase.dart`

```dart
/// ⚠️ 현재: Repository 예외를 Result<T>로 번역
import '/core/types/result.dart';
import '../repositories/i_notification_repository.dart';
import '../failures/notification_failure.dart';

class MarkAsReadUseCase {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  // ⚠️ Result<T> 반환하지만, Repository는 예외 throw
  Future<Result<void>> call(MarkAsReadParams params) async {
    try {
      // 비즈니스 규칙: 권한 검증
      if (params.userId.isEmpty || params.notificationId.isEmpty) {
        return ResultFailure(Unexpected('잘못된 요청입니다'));
      }

      // Repository 호출 (예외 발생 가능)
      final notification =
          await _repository.getNotification(params.notificationId);

      if (notification == null) {
        return ResultFailure(const NotificationNotFound());
      }

      // 비즈니스 규칙: 본인 알림만 읽음 처리 가능
      if (notification.userId != params.userId) {
        return ResultFailure(const PermissionDenied());
      }

      // 비즈니스 규칙: 이미 읽은 알림은 스킵 (Idempotent)
      if (notification.isRead) {
        return const Success(null);
      }

      // Repository 호출 (예외 throw 가능)
      await _repository.markAsRead(params.notificationId);

      return const Success(null);
    } on NotificationFailure catch (failure) {
      // ⚠️ Repository 예외를 Result로 번역
      return ResultFailure(failure);
    } catch (e) {
      return ResultFailure(Unexpected(e.toString()));
    }
  }
}
```

**현재 아키텍처의 문제점**:
1. **번역 레이어 존재**: Repository는 예외 throw, UseCase가 Result<T>로 변환
2. **이중 에러 처리**: try-catch + Result 패턴 혼용
3. **불필요한 복잡도**: Either 패턴 도입 시 try-catch 제거 가능
4. **Feature 간 불일치**: Auth/Voting은 Repository부터 Either 사용

### 4. NotificationFailure (✅ 이미 Sealed Class)

**파일**: `domain/failures/notification_failure.dart`

```dart
/// ✅ 현재: Sealed Class 패턴 이미 적용
sealed class NotificationFailure extends Failure {
  const NotificationFailure() : super(message: '');

  @override
  String get message {
    return switch (this) {
      NotificationNotFound() => '알림을 찾을 수 없습니다',
      NotificationLoadFailed() => '알림을 불러오는데 실패했습니다',
      NotificationSendFailed() => '알림 전송에 실패했습니다',
      PermissionDenied() => '권한이 없습니다',
      InvalidNotificationData() => '잘못된 알림 데이터입니다',
      NotificationExpired() => '만료된 알림입니다',
      Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// ===== Concrete Failure Types =====

class NotificationNotFound extends NotificationFailure {
  const NotificationNotFound();
}

class NotificationLoadFailed extends NotificationFailure {
  const NotificationLoadFailed();
}

class NotificationSendFailed extends NotificationFailure {
  final String? reason;
  const NotificationSendFailed({this.reason});
}

class PermissionDenied extends NotificationFailure {
  const PermissionDenied();
}

class InvalidNotificationData extends NotificationFailure {
  final String? field;
  const InvalidNotificationData({this.field});
}

class NotificationExpired extends NotificationFailure {
  final DateTime? expiredAt;
  const NotificationExpired({this.expiredAt});
}

class Unexpected extends NotificationFailure {
  final String? errorMessage;
  final Object? error;
  final StackTrace? stackTrace;

  const Unexpected(this.errorMessage, {this.error, this.stackTrace});
}
```

**장점**: ✅ 이미 Sealed Class 패턴 적용되어 Phase 1 준비 완료!

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. Repository 인터페이스

```dart
// ❌ Before: 예외 기반 에러 처리
abstract class INotificationRepository {
  // Future<T> 반환, 예외 throw
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  // Future<void> 반환, 예외 throw
  Future<void> markAsRead(String notificationId);

  // Nullable 반환 (예외 정보 손실)
  Future<Notification?> getNotification(String id);

  // Stream은 Either 미사용 (표준 패턴)
  Stream<int> watchUnreadCount(String userId);
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });
}

// ✅ After: Either<L,R> 패턴
import 'package:fpdart/fpdart.dart';

abstract class INotificationRepository {
  // Either로 명시적 에러 타입
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  // void → Unit
  Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId);

  // Nullable 제거, Either 사용
  Future<Either<NotificationFailure, Notification>> getNotification(String id);

  // Stream은 Either 미사용 (표준 패턴)
  Stream<int> watchUnreadCount(String userId);
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });
}
```

#### 2. UseCase - Either 패턴으로 간소화

```dart
// ❌ Before: Repository 예외를 Result<T>로 번역
import '/core/types/result.dart';

Future<Result<void>> call(MarkAsReadParams params) async {
  try {
    if (params.userId.isEmpty) {
      return ResultFailure(Unexpected('잘못된 요청입니다'));
    }

    // Repository 호출 (예외 throw 가능)
    final notification = await _repository.getNotification(params.notificationId);
    if (notification == null) {
      return ResultFailure(const NotificationNotFound());
    }

    // Repository 호출 (예외 throw 가능)
    await _repository.markAsRead(params.notificationId);
    return const Success(null);
  } on NotificationFailure catch (failure) {
    // ⚠️ Repository 예외를 Result로 번역
    return ResultFailure(failure);
  } catch (e) {
    return ResultFailure(Unexpected(e.toString()));
  }
}

// ✅ After: Either<L,R> (try-catch 제거)
import 'package:fpdart/fpdart.dart';

Future<Either<NotificationFailure, Unit>> call(MarkAsReadParams params) async {
  // 비즈니스 규칙 검증
  if (params.userId.isEmpty || params.notificationId.isEmpty) {
    return left(const Unexpected('잘못된 요청입니다'));
  }

  // Repository 호출 (Either 반환 - try-catch 불필요)
  final notificationResult = await _repository.getNotification(params.notificationId);

  // Either 패턴: fold()로 처리
  return notificationResult.fold(
    (failure) => left(failure),  // Left: 에러
    (notification) async {
      // 비즈니스 규칙: 본인 알림만
      if (notification.userId != params.userId) {
        return left(const PermissionDenied());
      }

      // 이미 읽은 알림은 스킵
      if (notification.isRead) {
        return right(unit);  // Idempotent
      }

      // 읽음 처리 (Either 반환 - try-catch 불필요)
      return _repository.markAsRead(params.notificationId);
    },
  );
}
```

#### 3. Repository 구현체 - Either로 명시적 변환

```dart
// ❌ Before: 예외 throw 방식
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  final NotificationQueueService _queueService;

  @override
  Future<Notification?> getNotification(String id) async {
    try {
      final dto = await _remoteDatasource.getNotification(id);
      if (dto == null) return null;  // ❌ 에러 정보 손실
      return NotificationMapper.toDomain(dto);
    } catch (e) {
      print('Error: $e');
      return null;  // ❌ 예외 정보 손실
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);
      await _localDatasource.clearAllCache();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDenied();  // ❌ 예외 throw
      }
      throw const NotificationLoadFailed();  // ❌ 예외 throw
    }
  }
}

// ✅ After: Either 명시적 반환
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  final NotificationQueueService _queueService;

  @override
  Future<Either<NotificationFailure, Notification>> getNotification(
    String id,
  ) async {
    try {
      final dto = await _remoteDatasource.getNotification(id);

      if (dto == null) {
        return left(const NotificationNotFound());  // ✅ 명시적 에러
      }

      final notification = NotificationMapper.toDomain(dto);
      return right(notification);  // ✅ 명시적 성공
    } on FirebaseException catch (e) {
      return left(const NotificationLoadFailed());  // ✅
    } catch (e, stackTrace) {
      return left(Unexpected(
        e.toString(),
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
  ) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);
      await _localDatasource.clearAllCache();
      return right(unit);  // ✅ 명시적 성공
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const PermissionDenied());  // ✅ 명시적 에러
      }
      return left(const NotificationLoadFailed());
    } catch (e, stackTrace) {
      return left(Unexpected(
        e.toString(),
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: fpdart 의존성 추가

**파일**: `pubspec.yaml`

```yaml
dependencies:
  fpdart: ^1.1.0  # Either 패턴 지원
```

```bash
flutter pub get
```

### Step 2: Repository 인터페이스 업데이트

**파일**: `domain/repositories/i_notification_repository.dart`

#### Before:

```dart
import '../models/notification.dart';
import '../value_objects/notification_filter.dart';

abstract class INotificationRepository {
  // ===== 조회 Operations =====

  /// 단일 알림 조회 (Nullable 반환, 예외 throw)
  Future<Notification?> getNotification(String notificationId);

  /// 사용자의 알림 목록 조회 (예외 throw)
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  /// 사용자의 알림 스트림 감시
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  });

  /// 읽지 않은 알림 개수 조회 (예외 throw)
  Future<int> getUnreadCount(String userId);

  /// 읽지 않은 알림 개수 스트림
  Stream<int> watchUnreadCount(String userId);

  // ===== 생성/수정 Operations =====

  /// 새 알림 생성 (예외 throw)
  Future<String> createNotification(Notification notification);

  /// 알림 업데이트 (예외 throw)
  Future<void> updateNotification(String notificationId, Map<String, dynamic> updates);

  /// 알림을 읽음으로 표시 (예외 throw)
  Future<void> markAsRead(String notificationId);

  /// 모든 알림을 읽음으로 표시 (예외 throw)
  Future<void> markAllAsRead(String userId);

  // ===== 삭제 Operations =====

  /// 단일 알림 삭제 (예외 throw)
  Future<void> deleteNotification(String notificationId);

  /// 사용자의 모든 알림 삭제 (예외 throw)
  Future<void> deleteAllNotifications(String userId);
}
```

#### After:

```dart
import 'package:fpdart/fpdart.dart';

import '../models/notification.dart';
import '../failures/notification_failure.dart';

abstract class INotificationRepository {
  // ===== CRUD Operations (Either 패턴) =====

  /// 사용자의 알림 목록 조회
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  );

  /// 알림 전송
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
  );

  /// 단일 알림 조회
  /// ✅ Nullable 제거, Either 사용
  Future<Either<NotificationFailure, Notification>> getNotification(String id);

  /// 알림 읽음 처리
  Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId);

  /// 알림 삭제
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
  );

  // ===== Queries (Stream) =====
  // Note: Stream은 Either 미사용 (Stream.error()로 처리)

  /// 읽지 않은 알림 개수 실시간 감시
  Stream<int> watchUnreadCount(String userId);

  /// 사용자 알림 실시간 감시
  Stream<List<Notification>> watchUserNotifications(String userId);
}
```

**변경 사항**:
1. **Result → Either**: `Result<T>` → `Either<NotificationFailure, T>`
2. **void → Unit**: `Result<void>` → `Either<NotificationFailure, Unit>`
3. **Nullable 제거**: `Notification?` → `Either<NotificationFailure, Notification>`
4. **import 변경**: `/core/types/result.dart` 제거, `fpdart` 추가

### Step 3: UseCases 업데이트

#### 3-1. MarkAsReadUseCase

**파일**: `domain/usecases/mark_as_read_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';

import '../repositories/i_notification_repository.dart';
import '../failures/notification_failure.dart';

/// UseCase for marking notification as read
/// Clean Architecture - Domain Business Logic
class MarkAsReadUseCase {
  final INotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  /// 알림 읽음 처리
  ///
  /// **비즈니스 규칙**:
  /// 1. userId, notificationId 필수
  /// 2. 본인 알림만 읽음 처리 가능
  /// 3. 이미 읽은 알림은 스킵 (Idempotent)
  Future<Either<NotificationFailure, Unit>> call(
    MarkAsReadParams params,
  ) async {
    // 1. 입력 검증
    if (params.userId.isEmpty || params.notificationId.isEmpty) {
      return left(const Unexpected('잘못된 요청입니다'));
    }

    // 2. 알림 조회
    final notificationResult = await _repository.getNotification(
      params.notificationId,
    );

    // 3. Either 패턴: fold()로 처리
    return notificationResult.fold(
      // Left: 알림 조회 실패
      (failure) => left(failure),

      // Right: 알림 조회 성공
      (notification) async {
        // 비즈니스 규칙: 본인 알림만 읽음 처리 가능
        if (notification.userId != params.userId) {
          return left(const PermissionDenied());
        }

        // 비즈니스 규칙: 이미 읽은 알림은 스킵 (Idempotent)
        if (notification.isRead) {
          return right(unit);
        }

        // 읽음 처리
        return _repository.markAsRead(params.notificationId);
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

#### 3-2. GetUserNotificationsUseCase

**파일**: `domain/usecases/get_user_notifications_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';

import '../repositories/i_notification_repository.dart';
import '../models/notification.dart';
import '../failures/notification_failure.dart';

class GetUserNotificationsUseCase {
  final INotificationRepository _repository;

  GetUserNotificationsUseCase(this._repository);

  /// 사용자 알림 목록 조회
  ///
  /// **비즈니스 규칙**:
  /// - 만료된 알림 자동 필터링
  /// - 읽지 않은 알림 우선 정렬
  Future<Either<NotificationFailure, List<Notification>>> call(
    String userId,
  ) async {
    if (userId.isEmpty) {
      return left(const Unexpected('사용자 ID가 필요합니다'));
    }

    // Repository 호출
    final result = await _repository.getUserNotifications(userId);

    // 비즈니스 로직: 만료된 알림 필터링 + 정렬
    return result.map((notifications) {
      final filtered = notifications
          .where((n) => !n.isExpired)  // 만료 안 된 알림만
          .toList()
        ..sort((a, b) {
          // 우선순위: priority > 생성일
          final priorityCompare = b.priority.compareTo(a.priority);
          if (priorityCompare != 0) return priorityCompare;
          return b.createdAt.compareTo(a.createdAt);
        });

      return filtered;
    });
  }
}
```

#### 3-3. SendNotificationUseCase

**파일**: `domain/usecases/send_notification_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';

import '../repositories/i_notification_repository.dart';
import '../models/notification.dart';
import '../failures/notification_failure.dart';

class SendNotificationUseCase {
  final INotificationRepository _repository;

  SendNotificationUseCase(this._repository);

  /// 알림 전송
  ///
  /// **비즈니스 규칙**:
  /// - 필수 필드 검증
  /// - 만료 시간 검증 (미래 시간만)
  Future<Either<NotificationFailure, Unit>> call(
    Notification notification,
  ) async {
    // 비즈니스 규칙: 필수 필드 검증
    if (notification.userId.isEmpty) {
      return left(const InvalidNotificationData(field: 'userId'));
    }
    if (notification.title.isEmpty) {
      return left(const InvalidNotificationData(field: 'title'));
    }

    // 비즈니스 규칙: 만료 시간 검증
    if (notification.expiryTime != null) {
      if (notification.expiryTime!.isBefore(DateTime.now())) {
        return left(NotificationExpired(
          expiredAt: notification.expiryTime,
        ));
      }
    }

    // Repository 호출
    return _repository.sendNotification(notification);
  }
}
```

#### 3-4. WatchUnreadCountUseCase

**파일**: `domain/usecases/watch_unread_count_usecase.dart`

```dart
import '../repositories/i_notification_repository.dart';

/// UseCase for watching unread notification count
/// Stream은 Either 미사용 (Stream.error()로 처리)
class WatchUnreadCountUseCase {
  final INotificationRepository _repository;

  WatchUnreadCountUseCase(this._repository);

  /// 읽지 않은 알림 개수 실시간 감시
  ///
  /// **Note**: Stream은 Either 패턴 미사용
  /// - 성공: Stream<int> 반환
  /// - 실패: Stream.error() 발생
  Stream<int> call(String userId) {
    if (userId.isEmpty) {
      return Stream.error(
        const Unexpected('사용자 ID가 필요합니다'),
      );
    }

    return _repository.watchUnreadCount(userId);
  }
}
```

#### 3-5. WatchUserNotificationsUseCase

**파일**: `domain/usecases/watch_user_notifications_usecase.dart`

```dart
import '../repositories/i_notification_repository.dart';
import '../models/notification.dart';

class WatchUserNotificationsUseCase {
  final INotificationRepository _repository;

  WatchUserNotificationsUseCase(this._repository);

  /// 사용자 알림 실시간 감시
  ///
  /// **비즈니스 로직**: 만료된 알림 자동 필터링
  Stream<List<Notification>> call(String userId) {
    if (userId.isEmpty) {
      return Stream.error(
        const Unexpected('사용자 ID가 필요합니다'),
      );
    }

    return _repository
        .watchUserNotifications(userId)
        .map((notifications) {
      // 비즈니스 로직: 만료된 알림 필터링
      return notifications
          .where((n) => !n.isExpired)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}
```

### Step 4: Repository 구현체 업데이트

**파일**: `data/repositories/notification_repository_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/models/notification.dart';
import '../../domain/failures/notification_failure.dart';
import '../datasources/remote/i_remote_notification_datasource.dart';
import '../datasources/local/i_local_notification_datasource.dart';
import '../mappers/notification_mapper.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;

  NotificationRepositoryImpl({
    required IRemoteNotificationDatasource remoteDatasource,
    required ILocalNotificationDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  // ===== CRUD Operations =====

  @override
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  ) async {
    try {
      // L1 Cache: SharedPreferences
      final cachedDtos = await _localDatasource.getCachedNotifications(userId);
      if (cachedDtos.isNotEmpty) {
        final notifications = cachedDtos
            .map((dto) => NotificationMapper.toDomain(dto))
            .toList();
        return right(notifications);
      }

      // L2: Firestore
      final dtos = await _remoteDatasource.getUserNotifications(userId);
      final notifications = dtos
          .map((dto) => NotificationMapper.toDomain(dto))
          .toList();

      // Cache 업데이트
      await _localDatasource.cacheNotifications(userId, dtos);

      return right(notifications);
    } on FirebaseException catch (e) {
      return left(const NotificationLoadFailed());
    } catch (e, stackTrace) {
      return left(Unexpected(
        'Failed to get user notifications: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<NotificationFailure, Notification>> getNotification(
    String id,
  ) async {
    try {
      final dto = await _remoteDatasource.getNotification(id);

      if (dto == null) {
        return left(const NotificationNotFound());
      }

      final notification = NotificationMapper.toDomain(dto);
      return right(notification);
    } on FirebaseException catch (e) {
      return left(const NotificationLoadFailed());
    } catch (e, stackTrace) {
      return left(Unexpected(
        'Failed to get notification: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
  ) async {
    try {
      final dto = NotificationMapper.toDto(notification);
      await _remoteDatasource.sendNotification(dto);

      // Cache 무효화
      await _localDatasource.invalidateCache(notification.userId);

      return right(unit);
    } on FirebaseException catch (e) {
      return left(const NotificationSendFailed());
    } catch (e, stackTrace) {
      return left(Unexpected(
        'Failed to send notification: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
  ) async {
    try {
      await _remoteDatasource.markAsRead(notificationId);

      // Cache 무효화
      // (알림 소유자를 모르므로 전체 캐시 무효화)
      await _localDatasource.clearAllCache();

      return right(unit);
    } on FirebaseException catch (e) {
      return left(const NotificationLoadFailed());
    } catch (e, stackTrace) {
      return left(Unexpected(
        'Failed to mark as read: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _remoteDatasource.deleteNotification(notificationId);

      // Cache 무효화
      await _localDatasource.clearAllCache();

      return right(unit);
    } on FirebaseException catch (e) {
      return left(const NotificationLoadFailed());
    } catch (e, stackTrace) {
      return left(Unexpected(
        'Failed to delete notification: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  // ===== Queries (Stream) =====

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _remoteDatasource.watchUnreadCount(userId);
  }

  @override
  Stream<List<Notification>> watchUserNotifications(String userId) {
    return _remoteDatasource
        .watchUserNotifications(userId)
        .map((dtos) => dtos
            .map((dto) => NotificationMapper.toDomain(dto))
            .toList());
  }
}
```

### Step 5: DI 모듈 업데이트 (변경 없음)

**파일**: `di/notification_di_module.dart`

```dart
// DI 모듈은 변경 불필요 (인터페이스 구현체만 업데이트됨)
void registerNotificationModule(GetIt getIt) {
  _registerDataSources(getIt);
  _registerMapper(getIt);
  _registerServices(getIt);
  _registerRepository(getIt);
  _registerContract(getIt);
  _registerUseCases(getIt);
  _registerProviders(getIt);
}
```

---

## 🧪 테스트 전략

### 1. UseCase 단위 테스트

**파일**: `test/unit/usecases/mark_as_read_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:versus_app/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:versus_app/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:versus_app/features/notifications/domain/models/notification.dart';
import 'package:versus_app/features/notifications/domain/failures/notification_failure.dart';

class MockNotificationRepository extends Mock implements INotificationRepository {}

void main() {
  late MarkAsReadUseCase usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = MarkAsReadUseCase(mockRepository);
  });

  group('MarkAsReadUseCase - Either Pattern', () {
    const testUserId = 'user_123';
    const testNotificationId = 'notif_456';
    final testNotification = Notification.social(
      id: testNotificationId,
      userId: testUserId,
      type: 'social',
      title: 'Test',
      content: 'Content',
      createdAt: DateTime.now(),
      isRead: false,
      actionType: SocialActionType.like,
      fromUserId: 'user_789',
      fromUserName: 'John',
    );

    test('성공: 알림 읽음 처리', () async {
      // Arrange
      when(() => mockRepository.getNotification(testNotificationId))
          .thenAnswer((_) async => right(testNotification));
      when(() => mockRepository.markAsRead(testNotificationId))
          .thenAnswer((_) async => right(unit));

      // Act
      final result = await usecase(MarkAsReadParams(
        notificationId: testNotificationId,
        userId: testUserId,
      ));

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockRepository.getNotification(testNotificationId)).called(1);
      verify(() => mockRepository.markAsRead(testNotificationId)).called(1);
    });

    test('실패: 알림 없음', () async {
      // Arrange
      when(() => mockRepository.getNotification(testNotificationId))
          .thenAnswer((_) async => left(const NotificationNotFound()));

      // Act
      final result = await usecase(MarkAsReadParams(
        notificationId: testNotificationId,
        userId: testUserId,
      ));

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotificationNotFound>()),
        (_) => fail('Should be Left'),
      );
      verifyNever(() => mockRepository.markAsRead(any()));
    });

    test('실패: 권한 없음 (다른 사용자 알림)', () async {
      // Arrange
      final otherUserNotification = testNotification.copyWith(
        userId: 'other_user',
      );
      when(() => mockRepository.getNotification(testNotificationId))
          .thenAnswer((_) async => right(otherUserNotification));

      // Act
      final result = await usecase(MarkAsReadParams(
        notificationId: testNotificationId,
        userId: testUserId,
      ));

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<PermissionDenied>()),
        (_) => fail('Should be Left'),
      );
    });

    test('Idempotent: 이미 읽은 알림은 스킵', () async {
      // Arrange
      final readNotification = testNotification.copyWith(isRead: true);
      when(() => mockRepository.getNotification(testNotificationId))
          .thenAnswer((_) async => right(readNotification));

      // Act
      final result = await usecase(MarkAsReadParams(
        notificationId: testNotificationId,
        userId: testUserId,
      ));

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockRepository.getNotification(testNotificationId)).called(1);
      verifyNever(() => mockRepository.markAsRead(any()));
    });
  });
}
```

### 2. Repository 통합 테스트

**파일**: `test/integration/notification_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:versus_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:versus_app/features/notifications/domain/failures/notification_failure.dart';

void main() {
  late NotificationRepositoryImpl repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = NotificationRepositoryImpl(
      remoteDatasource: FirebaseNotificationDatasource(
        firestore: fakeFirestore,
      ),
      localDatasource: SharedPrefsNotificationDatasource(
        sharedPreferences: MockSharedPreferences(),
      ),
    );
  });

  group('NotificationRepositoryImpl - Either Pattern', () {
    test('getNotification - 성공', () async {
      // Arrange
      await fakeFirestore.collection('notifications').doc('notif_1').set({
        'userId': 'user_1',
        'type': 'social',
        'title': 'Test',
        'content': 'Content',
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      // Act
      final result = await repository.getNotification('notif_1');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (notification) {
          expect(notification.id, 'notif_1');
          expect(notification.title, 'Test');
        },
      );
    });

    test('getNotification - 알림 없음', () async {
      // Act
      final result = await repository.getNotification('notif_999');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotificationNotFound>()),
        (_) => fail('Should be Left'),
      );
    });

    test('markAsRead - 성공', () async {
      // Arrange
      await fakeFirestore.collection('notifications').doc('notif_1').set({
        'userId': 'user_1',
        'isRead': false,
      });

      // Act
      final result = await repository.markAsRead('notif_1');

      // Assert
      expect(result.isRight(), isTrue);

      final doc = await fakeFirestore
          .collection('notifications')
          .doc('notif_1')
          .get();
      expect(doc.data()?['isRead'], isTrue);
    });
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **컴파일 에러**: Either 패턴 적용 중 타입 에러 다수 발생
2. **테스트 실패**: 기존 테스트의 50% 이상 실패
3. **복잡도 증가**: 팀원들이 Either 패턴 이해 어려움

### 롤백 절차

#### Step 1: Git Revert

```bash
git log --oneline --grep="Either Pattern"
git revert <commit-hash>
```

#### Step 2: Repository 인터페이스 복구

```dart
// After (롤백 후) - Result 패턴으로 복구
import '/core/types/result.dart';

abstract class INotificationRepository {
  Future<Result<List<Notification>>> getUserNotifications(String userId);
  Future<Result<void>> markAsRead(String notificationId);
  Future<Notification?> getNotification(String id);
}
```

#### Step 3: UseCases 복구

```dart
// After (롤백 후)
Future<Result<void>> call(MarkAsReadParams params) async {
  try {
    // ...
    return const Success(null);
  } catch (e) {
    return ResultFailure(Unexpected(e.toString()));
  }
}
```

---

## ✅ 완료 체크리스트

### Phase 1 완료 기준

- [ ] **의존성 추가**
  - [ ] pubspec.yaml에 fpdart 추가
  - [ ] flutter pub get 실행

- [ ] **Repository 인터페이스 업데이트**
  - [ ] i_notification_repository.dart: Either 반환 타입
  - [ ] Result<T> 제거
  - [ ] Nullable 반환 제거

- [ ] **UseCases 업데이트 (5개)**
  - [ ] MarkAsReadUseCase: Either 패턴
  - [ ] GetUserNotificationsUseCase: Either 패턴
  - [ ] SendNotificationUseCase: Either 패턴
  - [ ] WatchUnreadCountUseCase: Stream (변경 없음)
  - [ ] WatchUserNotificationsUseCase: Stream (변경 없음)

- [ ] **Repository 구현체 업데이트**
  - [ ] notification_repository_impl.dart: Either 반환
  - [ ] throw 제거, left()/right() 사용
  - [ ] FirebaseException 처리

- [ ] **테스트**
  - [ ] UseCase 단위 테스트 (5개)
  - [ ] Repository 통합 테스트
  - [ ] Either 패턴 검증

- [ ] **검증**
  - [ ] flutter analyze 통과
  - [ ] 모든 테스트 통과
  - [ ] 컴파일 에러 0개

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] Phase 1 완료 표시

---

## 📊 마이그레이션 영향 분석

### 코드 변경량

| 파일 | Before (줄) | After (줄) | 변경률 |
|------|------------|-----------|--------|
| i_notification_repository.dart | 45 | 65 | +44% |
| mark_as_read_usecase.dart | 71 | 85 | +20% |
| get_user_notifications_usecase.dart | 45 | 60 | +33% |
| send_notification_usecase.dart | 40 | 55 | +38% |
| notification_repository_impl.dart | 285 | 365 | +28% |
| **합계** | **486줄** | **630줄** | **+30%** |

### Result vs Either 비교

```
Before (Result):
✅ 간단한 Success/Failure 패턴
❌ 타입 안전성 부족
❌ Failure 타입 명시 안 됨
❌ Feature 간 불일치

After (Either):
✅ 타입 안전 (Either<L,R>)
✅ 명시적 Failure 타입
✅ fold() 패턴으로 처리
✅ 4개 Feature 통일
```

---

## 🎓 추가 학습 자료

### Either 패턴 심화

#### 1. fold() vs getOrElse()

```dart
// fold(): Left/Right 모두 처리
final result = await repository.getNotification(id);
result.fold(
  (failure) => print('Error: ${failure.message}'),  // Left
  (notification) => print('Success: ${notification.title}'),  // Right
);

// getOrElse(): Right만 사용, Left는 기본값
final notification = result.getOrElse(() => defaultNotification);

// isLeft(), isRight(): 타입 체크
if (result.isLeft()) {
  // 에러 처리
}
```

#### 2. Either 체이닝

```dart
// map(): Right 값 변환
final titleResult = notificationResult.map((n) => n.title);

// flatMap(): Either 반환하는 함수 체이닝
final result = await repository
    .getNotification(id)
    .flatMap((notification) => repository.markAsRead(notification.id));
```

### Auth & Voting Feature 참조

- **Auth PHASE_1_EITHER_PATTERN.md**: Either 패턴 상세 가이드
- **Voting Feature**: Either 패턴 실전 예시
- **Profile Feature**: fold() 활용 패턴

---

## 📌 다음 단계

Phase 1 완료 후 **Phase 2: Riverpod Migration**으로 이동합니다.

**Phase 2 주요 작업**:
- notification_providers.dart 신규 생성
- StreamProvider.autoDispose.family 패턴
- AsyncValue.when() UI 통합

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
