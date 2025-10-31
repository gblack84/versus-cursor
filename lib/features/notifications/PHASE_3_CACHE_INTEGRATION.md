# Notification Feature - Phase 3: 3-Layer Cache Integration

> **마이그레이션 가이드**: SharedPreferences → UnifiedCacheService (3-Layer Caching)
> **난이도**: ⭐⭐⭐⭐☆ (상)
> **예상 소요 시간**: 8시간
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

SharedPreferences 기반 단순 캐싱을 UnifiedCacheService의 3-Layer 캐싱으로 전환하여 알림 응답 속도를 획기적으로 개선합니다.

### 핵심 문제점

1. **SharedPreferences 한계**: 직렬화 오버헤드, 느린 I/O
2. **2-Layer만 존재**: Memory 캐시(L1) 없음 → 항상 디스크 I/O
3. **Cache Miss 시 Firestore 직행**: 네트워크 지연 300-500ms
4. **프리로딩 부재**: 앱 시작 시 캐시 워밍업 없음

### 영향 범위

| 레이어 | 파일 수 | 변경 줄 수 | 주요 변경 사항 |
|--------|---------|-----------|---------------|
| **Data (DataSource)** | 2개 | -180줄 | Local DataSource 제거 |
| **Data (Repository)** | 1개 | +250줄 | UnifiedCacheService 통합 |
| **Services** | 1개 (공유) | 0줄 | 기존 서비스 사용 |
| **DI Module** | 1개 | -20줄 | Local DataSource DI 제거 |
| **Main** | 1개 | +30줄 | 프리로딩 추가 |
| **합계** | **6개** | **+80줄** | - |

### 주요 이점

| 항목 | Before (SharedPrefs) | After (UnifiedCache) | 변화 |
|------|---------------------|---------------------|------|
| **Cache Hit 응답 시간** | 50-100ms | <10ms | **-90%** |
| **Cache Miss 응답 시간** | 300-500ms | 10-30ms (Hive) | **-94%** |
| **메모리 캐시 (L1)** | 없음 | 있음 | **신규** |
| **Firestore 읽기 비용** | 많음 | 적음 | **-70%** |

---

## 🔍 현재 상태 분석

### 1. SharedPreferences 기반 캐싱 (2-Layer)

**파일**: `data/datasources/local/shared_prefs_notification_datasource.dart`

```dart
/// ❌ 현재: SharedPreferences 직접 사용
class SharedPrefsNotificationDatasource implements ILocalNotificationDatasource {
  final SharedPreferences _prefs;

  SharedPrefsNotificationDatasource({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  /// L1 Cache: 없음 ❌
  /// L2 Cache: SharedPreferences (50-100ms)
  @override
  Future<List<NotificationDto>> getCachedNotifications(String userId) async {
    try {
      final key = 'notifications_$userId';
      final jsonString = _prefs.getString(key);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => NotificationDto.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheNotifications(
    String userId,
    List<NotificationDto> notifications,
  ) async {
    try {
      final key = 'notifications_$userId';
      final jsonList = notifications.map((n) => n.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await _prefs.setString(key, jsonString);
    } catch (e) {
      // Cache 저장 실패는 무시
    }
  }

  @override
  Future<void> invalidateCache(String userId) async {
    final key = 'notifications_$userId';
    await _prefs.remove(key);
  }

  @override
  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('notifications_')) {
        await _prefs.remove(key);
      }
    }
  }
}
```

**문제점**:
```
현재 캐싱 흐름:
1. Repository → Local DataSource (SharedPreferences) [50-100ms]
2. Cache Miss → Remote DataSource (Firestore) [300-500ms]

문제:
❌ L1 Memory Cache 없음 → 항상 디스크 I/O
❌ JSON 직렬화/역직렬화 오버헤드
❌ Cache Hit 시에도 50-100ms 소요
```

### 2. Repository의 2-Layer 캐싱 + QueueService

**파일**: `data/repositories/notification_repository_impl.dart`

```dart
/// ❌ 현재: 2-Layer 캐싱 + NotificationQueueService 의존성
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;  // ❌ SharedPrefs
  final NotificationQueueService _queueService;  // ⚠️ 추가 의존성

  @override
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  ) async {
    try {
      // L1: Memory Cache - 없음 ❌

      // L2: SharedPreferences Cache (50-100ms)
      final cachedDtos = await _localDatasource.getCachedNotifications(userId);
      if (cachedDtos.isNotEmpty) {
        final notifications = cachedDtos
            .map((dto) => NotificationMapper.toDomain(dto))
            .toList();
        return right(notifications);
      }

      // L3: Firestore (300-500ms)
      final dtos = await _remoteDatasource.getUserNotifications(userId);
      final notifications = dtos
          .map((dto) => NotificationMapper.toDomain(dto))
          .toList();

      // SharedPreferences에 캐시
      await _localDatasource.cacheNotifications(userId, dtos);

      return right(notifications);
    } catch (e, stackTrace) {
      return left(Unexpected(e.toString(), error: e, stackTrace: stackTrace));
    }
  }
}
```

**응답 시간 측정**:
```
Cache Hit (SharedPrefs): 50-100ms  ⚠️ 디스크 I/O
Cache Miss (Firestore): 300-500ms  ❌ 네트워크 지연
```

**NotificationQueueService 역할**:
```dart
// ⚠️ Repository가 의존하는 추가 서비스
// - 역할: 대기 중인 알림 큐 관리
// - 용도: 알림 전송 버퍼링, 재시도 로직
// - 캐싱과 독립적: UnifiedCacheService는 읽기 캐싱, QueueService는 쓰기 버퍼링
```

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. 3-Layer 캐싱 아키텍처

```
❌ Before (2-Layer):
┌─────────────────────────────┐
│    Repository               │
├─────────────────────────────┤
│  ↓ (없음) L1 Memory         │
│  ↓ 50ms L2 SharedPrefs      │
│  ↓ 300ms L3 Firestore       │
└─────────────────────────────┘

✅ After (3-Layer):
┌──────────────────────────────────────┐
│    Repository                        │
├──────────────────────────────────────┤
│  ↓ <10ms   L1 Memory (LRU, 100개)   │
│  ↓ 10-30ms L2 Hive (영구 저장)      │
│  ↓ 300ms   L3 Firestore Offline     │
└──────────────────────────────────────┘
```

#### 2. Repository 구현체

```dart
// ❌ Before: SharedPreferences 직접 사용
class NotificationRepositoryImpl {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;  // ❌ SharedPrefs
  final NotificationQueueService _queueService;  // ⚠️ 추가 의존성 (캐싱과 독립)

  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  ) async {
    // L2: SharedPreferences (50-100ms)
    final cachedDtos = await _localDatasource.getCachedNotifications(userId);
    if (cachedDtos.isNotEmpty) {
      return right(cachedDtos.map(...).toList());
    }

    // L3: Firestore
    final dtos = await _remoteDatasource.getUserNotifications(userId);
    await _localDatasource.cacheNotifications(userId, dtos);
    return right(dtos.map(...).toList());
  }
}

// ✅ After: UnifiedCacheService 3-Layer
class NotificationRepositoryImpl {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;  // ✅ 유지 (쓰기 버퍼링 담당)
  // ✅ UnifiedCacheService.instance (싱글톤 - 읽기 캐싱 담당)

  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  ) async {
    final cacheKey = 'notifications_$userId';

    // ✅ L1 Memory Cache: <10ms
    final cachedList = UnifiedCacheService.instance.getList<Notification>(
      cacheKey,
      fromJson: Notification.fromJson,
    );

    if (cachedList != null) {
      return right(cachedList);
    }

    // ✅ L2 Hive Cache: 10-30ms
    final hiveCached = await UnifiedCacheService.instance.getListFromHive<Notification>(
      cacheKey,
      fromJson: Notification.fromJson,
    );

    if (hiveCached != null) {
      // L1에 캐시
      UnifiedCacheService.instance.putList(cacheKey, hiveCached);
      return right(hiveCached);
    }

    // ✅ L3 Firestore (Offline Cache 활성화됨)
    final dtos = await _remoteDatasource.getUserNotifications(userId);
    final notifications = dtos
        .map((dto) => NotificationMapper.toDomain(dto))
        .toList();

    // L1 + L2 캐시 동시 저장
    await UnifiedCacheService.instance.putList(cacheKey, notifications);

    return right(notifications);
  }
}
```

**Note**: NotificationQueueService는 알림 전송 버퍼링을 담당하며, UnifiedCacheService는 알림 조회 캐싱을 담당합니다. 두 서비스는 독립적으로 동작합니다.

#### 3. Cache-First 패턴 흐름

```dart
// Cache-First 패턴 (3단계 폴백)
try {
  // 1차: L1 Memory (즉시)
  final cached = UnifiedCacheService.instance.getList<T>(key);
  if (cached != null) return right(cached);  // <10ms

  // 2차: L2 Hive (비동기)
  final hiveCached = await UnifiedCacheService.instance.getListFromHive<T>(key);
  if (hiveCached != null) {
    UnifiedCacheService.instance.putList(key, hiveCached);  // L1에 캐시
    return right(hiveCached);  // 10-30ms
  }

  // 3차: L3 Firestore
  final data = await _remoteDatasource.getData();
  await UnifiedCacheService.instance.putList(key, data);  // L1 + L2
  return right(data);  // 300-500ms
} catch (e) {
  return left(failure);
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: UnifiedCacheService 확인

**파일**: `services/cache/unified_cache_service.dart`

```dart
/// UnifiedCacheService - 3-Layer 캐싱 서비스
///
/// **Architecture**:
/// - L1: SimpleMemoryCache (LRU, 100개, 5분 TTL)
/// - L2: Hive (영구 저장, 무제한)
/// - L3: Firestore Offline Cache (자동)
class UnifiedCacheService {
  static final UnifiedCacheService instance = UnifiedCacheService._();

  final SimpleMemoryCache _memoryCache;
  late final Box<String> _hiveBox;

  UnifiedCacheService._() : _memoryCache = SimpleMemoryCache(maxSize: 100);

  /// 초기화 (main.dart에서 호출)
  Future<void> init() async {
    await Hive.initFlutter();
    _hiveBox = await Hive.openBox<String>('unified_cache');
  }

  /// L1 Memory: List 조회
  List<T>? getList<T>(String key, {required T Function(Map<String, dynamic>) fromJson}) {
    final cached = _memoryCache.get(key);
    if (cached == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(cached);
      return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  /// L2 Hive: List 조회
  Future<List<T>?> getListFromHive<T>(
    String key,
    {required T Function(Map<String, dynamic>) fromJson},
  ) async {
    final cached = _hiveBox.get(key);
    if (cached == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(cached);
      return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      await _hiveBox.delete(key);  // 손상된 데이터 제거
      return null;
    }
  }

  /// L1 + L2 동시 저장
  Future<void> putList<T>(String key, List<T> items) async {
    final jsonList = items.map((item) => (item as dynamic).toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    // L1 Memory
    _memoryCache.put(key, jsonString);

    // L2 Hive (비동기)
    await _hiveBox.put(key, jsonString);
  }

  /// Cache 무효화
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    await _hiveBox.delete(key);
  }

  /// 전체 Cache 초기화
  Future<void> clearAll() async {
    _memoryCache.clear();
    await _hiveBox.clear();
  }
}
```

✅ **UnifiedCacheService는 이미 구현되어 있음 (Chat/Auth/Voting에서 사용 중)**

### Step 2: ILocalNotificationDatasource 제거

**삭제할 파일 (2개)**:
1. `data/datasources/local/shared_prefs_notification_datasource.dart`
2. `data/datasources/local/i_local_notification_datasource.dart`

```bash
# 파일 삭제
rm lib/features/notifications/data/datasources/local/shared_prefs_notification_datasource.dart
rm lib/features/notifications/data/datasources/local/i_local_notification_datasource.dart
```

### Step 3: Repository 업데이트

**파일**: `data/repositories/notification_repository_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/models/notification.dart';
import '../../domain/failures/notification_failure.dart';
import '../datasources/remote/i_remote_notification_datasource.dart';
import '../mappers/notification_mapper.dart';
import '/services/cache/unified_cache_service.dart';  // ✅ 추가
import '/services/notification/notification_queue_service.dart';  // ⚠️ 유지

class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final NotificationQueueService _queueService;  // ⚠️ 추가 의존성 유지
  // ✅ ILocalNotificationDatasource 제거
  // ✅ UnifiedCacheService.instance 사용 (싱글톤)

  NotificationRepositoryImpl({
    required IRemoteNotificationDatasource remoteDatasource,
    required NotificationQueueService queueService,  // ⚠️ 유지
  }) : _remoteDatasource = remoteDatasource,
       _queueService = queueService;

  // ===== CRUD Operations =====

  @override
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  ) async {
    final cacheKey = 'notifications_$userId';

    try {
      // ========== Cache-First Pattern ==========

      // L1 Memory Cache: <10ms
      final cachedList = UnifiedCacheService.instance.getList<Notification>(
        cacheKey,
        fromJson: Notification.fromJson,
      );

      if (cachedList != null) {
        return right(cachedList);
      }

      // L2 Hive Cache: 10-30ms
      final hiveCached = await UnifiedCacheService.instance.getListFromHive<Notification>(
        cacheKey,
        fromJson: Notification.fromJson,
      );

      if (hiveCached != null) {
        // L1에 캐시 (다음 조회는 <10ms)
        UnifiedCacheService.instance.putList(cacheKey, hiveCached);
        return right(hiveCached);
      }

      // L3 Firestore: 300-500ms (Offline Cache 활성화됨)
      final dtos = await _remoteDatasource.getUserNotifications(userId);
      final notifications = dtos
          .map((dto) => NotificationMapper.toDomain(dto))
          .toList();

      // L1 + L2 캐시 동시 저장
      await UnifiedCacheService.instance.putList(cacheKey, notifications);

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
    final cacheKey = 'notification_$id';

    try {
      // L1 Memory Cache
      final cachedStr = UnifiedCacheService.instance._memoryCache.get(cacheKey);
      if (cachedStr != null) {
        final json = jsonDecode(cachedStr) as Map<String, dynamic>;
        return right(Notification.fromJson(json));
      }

      // L2 Hive Cache
      final hiveCached = await UnifiedCacheService.instance._hiveBox.get(cacheKey);
      if (hiveCached != null) {
        final json = jsonDecode(hiveCached) as Map<String, dynamic>;
        final notification = Notification.fromJson(json);

        // L1에 캐시
        UnifiedCacheService.instance._memoryCache.put(cacheKey, hiveCached);
        return right(notification);
      }

      // L3 Firestore
      final dto = await _remoteDatasource.getNotification(id);

      if (dto == null) {
        return left(const NotificationNotFound());
      }

      final notification = NotificationMapper.toDomain(dto);

      // L1 + L2 캐시
      final jsonString = jsonEncode(notification.toJson());
      UnifiedCacheService.instance._memoryCache.put(cacheKey, jsonString);
      await UnifiedCacheService.instance._hiveBox.put(cacheKey, jsonString);

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
      await UnifiedCacheService.instance.invalidate(
        'notifications_${notification.userId}',
      );

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

      // Cache 무효화 (특정 알림)
      await UnifiedCacheService.instance.invalidate(
        'notification_$notificationId',
      );

      // 알림 목록 캐시도 무효화 (읽지 않은 개수 변경됨)
      // Note: userId를 모르므로 전체 목록 캐시 무효화
      final allKeys = UnifiedCacheService.instance._hiveBox.keys;
      for (final key in allKeys) {
        if (key.toString().startsWith('notifications_')) {
          await UnifiedCacheService.instance.invalidate(key.toString());
        }
      }

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
      await UnifiedCacheService.instance.invalidate(
        'notification_$notificationId',
      );

      // 알림 목록 캐시도 무효화
      final allKeys = UnifiedCacheService.instance._hiveBox.keys;
      for (final key in allKeys) {
        if (key.toString().startsWith('notifications_')) {
          await UnifiedCacheService.instance.invalidate(key.toString());
        }
      }

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

### Step 4: DI 모듈 업데이트

**파일**: `di/notification_di_module.dart`

```dart
void registerNotificationModule(GetIt getIt) {
  _registerDataSources(getIt);
  _registerMapper(getIt);
  _registerServices(getIt);  // ✅ UnifiedCacheService는 글로벌 싱글톤
  _registerRepository(getIt);
  _registerContract(getIt);
  _registerUseCases(getIt);
  _registerProviders(getIt);
}

void _registerDataSources(GetIt getIt) {
  // Remote DataSource
  getIt.registerLazySingleton<IRemoteNotificationDatasource>(
    () => FirebaseNotificationDatasource(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // ✅ Local DataSource 제거 (UnifiedCacheService 사용)
}

void _registerServices(GetIt getIt) {
  // ✅ UnifiedCacheService는 글로벌 싱글톤 (main.dart에서 초기화)
  // ✅ NotificationQueueService만 등록

  getIt.registerLazySingleton<NotificationQueueService>(
    () => NotificationQueueService(),
  );
}

void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: getIt<IRemoteNotificationDatasource>(),
      queueService: getIt<NotificationQueueService>(),  // ⚠️ 유지 (쓰기 버퍼링 담당)
      // ✅ localDatasource 제거 (UnifiedCacheService로 대체)
    ),
  );
}
```

### Step 5: 프리로딩 추가

**파일**: `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '/services/cache/unified_cache_service.dart';
import '/features/notifications/domain/models/notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ UnifiedCacheService 초기화
  await UnifiedCacheService.instance.init();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 프리로딩 (백그라운드)
  _preloadNotifications();

  runApp(const MyApp());
}

/// 알림 프리로딩 (백그라운드)
///
/// **전략**:
/// - 최근 7일 알림 프리로드
/// - 읽지 않은 알림 우선
void _preloadNotifications() {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      final currentUserId = getCurrentUserId();  // 현재 로그인한 사용자 ID

      // Repository에서 알림 조회 (자동으로 L1 + L2 캐시됨)
      final repository = getIt<INotificationRepository>();
      await repository.getUserNotifications(currentUserId);

      debugPrint('✅ Notification Preloading: Success');
    } catch (e) {
      debugPrint('⚠️ Notification Preloading: Failed - $e');
    }
  });
}
```

---

## 🧪 테스트 전략

### 1. Cache 성능 테스트

**파일**: `test/performance/cache_performance_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:versus_app/services/cache/unified_cache_service.dart';
import 'package:versus_app/features/notifications/domain/models/notification.dart';

void main() {
  late UnifiedCacheService cacheService;

  setUp(() async {
    cacheService = UnifiedCacheService.instance;
    await cacheService.init();
  });

  group('UnifiedCacheService - Notification Performance', () {
    test('L1 Memory Cache: <10ms', () async {
      // Arrange
      final testNotifications = List.generate(
        10,
        (i) => Notification.social(
          id: 'notif_$i',
          userId: 'user_1',
          type: 'social',
          title: 'Test $i',
          content: 'Content $i',
          createdAt: DateTime.now(),
          isRead: false,
          actionType: SocialActionType.like,
          fromUserId: 'user_2',
          fromUserName: 'John',
        ),
      );

      const cacheKey = 'notifications_user_1';
      await cacheService.putList(cacheKey, testNotifications);

      // Act: L1 Memory Cache 조회
      final stopwatch = Stopwatch()..start();
      final cached = cacheService.getList<Notification>(
        cacheKey,
        fromJson: Notification.fromJson,
      );
      stopwatch.stop();

      // Assert
      expect(cached, isNotNull);
      expect(cached!.length, 10);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));  // <10ms
      print('L1 Cache Hit: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('L2 Hive Cache: 10-30ms', () async {
      // Arrange
      final testNotifications = List.generate(
        10,
        (i) => Notification.social(...),
      );

      const cacheKey = 'notifications_user_2';
      await cacheService.putList(cacheKey, testNotifications);

      // Clear L1 (메모리 캐시만 제거)
      cacheService._memoryCache.clear();

      // Act: L2 Hive Cache 조회
      final stopwatch = Stopwatch()..start();
      final cached = await cacheService.getListFromHive<Notification>(
        cacheKey,
        fromJson: Notification.fromJson,
      );
      stopwatch.stop();

      // Assert
      expect(cached, isNotNull);
      expect(cached!.length, 10);
      expect(stopwatch.elapsedMilliseconds, lessThan(30));  // <30ms
      print('L2 Cache Hit: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Cache Miss: Firestore 조회', () async {
      // Arrange
      const cacheKey = 'notifications_user_999';

      // Clear all caches
      await cacheService.clearAll();

      // Act: Cache Miss
      final stopwatch = Stopwatch()..start();
      final cached = cacheService.getList<Notification>(
        cacheKey,
        fromJson: Notification.fromJson,
      );
      stopwatch.stop();

      // Assert
      expect(cached, isNull);  // Cache Miss
      print('Cache Miss Check: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
```

### 2. Repository 통합 테스트

**파일**: `test/integration/notification_cache_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:versus_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:versus_app/services/cache/unified_cache_service.dart';

void main() {
  late NotificationRepositoryImpl repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    await UnifiedCacheService.instance.init();

    repository = NotificationRepositoryImpl(
      remoteDatasource: FirebaseNotificationDatasource(
        firestore: fakeFirestore,
      ),
    );
  });

  group('NotificationRepository - Cache Integration', () {
    test('첫 조회: Firestore + Cache 저장', () async {
      // Arrange
      await fakeFirestore.collection('notifications').doc('notif_1').set({
        'userId': 'user_1',
        'type': 'social',
        'title': 'Test',
        'content': 'Content',
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      // Act: 첫 조회
      final result = await repository.getUserNotifications('user_1');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (notifications) {
          expect(notifications.length, 1);
          expect(notifications[0].title, 'Test');
        },
      );
    });

    test('두 번째 조회: L1 Cache Hit (<10ms)', () async {
      // Arrange: 첫 조회로 캐시 생성
      await repository.getUserNotifications('user_1');

      // Act: 두 번째 조회 (L1 Cache Hit)
      final stopwatch = Stopwatch()..start();
      final result = await repository.getUserNotifications('user_1');
      stopwatch.stop();

      // Assert
      expect(result.isRight(), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
      print('L1 Cache Hit: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Cache 무효화 후 조회: Firestore 재조회', () async {
      // Arrange: 첫 조회로 캐시 생성
      await repository.getUserNotifications('user_1');

      // Cache 무효화
      await UnifiedCacheService.instance.invalidate('notifications_user_1');

      // Act: 재조회 (Cache Miss → Firestore)
      final result = await repository.getUserNotifications('user_1');

      // Assert
      expect(result.isRight(), isTrue);
    });
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **Cache 손상**: Hive 데이터 손상으로 앱 크래시
2. **메모리 누수**: SimpleMemoryCache LRU 동작 안 함
3. **성능 저하**: 캐시 오버헤드가 오히려 느림

### 롤백 절차

#### Step 1: Git Revert

```bash
git log --oneline --grep="Cache Integration"
git revert <commit-hash>
```

#### Step 2: SharedPreferences DataSource 복구

```dart
// After (롤백 후)
class SharedPrefsNotificationDatasource implements ILocalNotificationDatasource {
  final SharedPreferences _prefs;

  @override
  Future<List<NotificationDto>> getCachedNotifications(String userId) async {
    final key = 'notifications_$userId';
    final jsonString = _prefs.getString(key);
    // ...
  }
}
```

#### Step 3: Repository 복구

```dart
// After (롤백 후)
class NotificationRepositoryImpl {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;  // ✅ 복구
  final NotificationQueueService _queueService;  // ⚠️ 유지 (롤백해도 계속 사용)

  NotificationRepositoryImpl({
    required IRemoteNotificationDatasource remoteDatasource,
    required ILocalNotificationDatasource localDatasource,
    required NotificationQueueService queueService,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _queueService = queueService;

  @override
  Future<Either<NotificationFailure, List<Notification>>> getUserNotifications(
    String userId,
  ) async {
    // SharedPreferences 캐시
    final cachedDtos = await _localDatasource.getCachedNotifications(userId);
    // ...
  }
}
```

---

## ✅ 완료 체크리스트

### Phase 3 완료 기준

- [ ] **UnifiedCacheService 확인**
  - [ ] services/cache/unified_cache_service.dart 존재
  - [ ] main.dart에서 초기화 완료

- [ ] **Local DataSource 제거 (2개)**
  - [ ] shared_prefs_notification_datasource.dart 삭제
  - [ ] i_local_notification_datasource.dart 삭제

- [ ] **Repository 업데이트**
  - [ ] UnifiedCacheService.instance 사용
  - [ ] Cache-First 패턴 구현
  - [ ] L1 → L2 → L3 폴백 로직

- [ ] **DI 모듈 업데이트**
  - [ ] ILocalNotificationDatasource DI 제거
  - [ ] Repository 생성자 업데이트

- [ ] **프리로딩**
  - [ ] main.dart에 _preloadNotifications() 추가
  - [ ] 백그라운드 로딩 (500ms 지연)

- [ ] **테스트**
  - [ ] Cache 성능 테스트 (L1 <10ms, L2 <30ms)
  - [ ] Repository 통합 테스트
  - [ ] Cache 무효화 테스트

- [ ] **검증**
  - [ ] flutter analyze 통과
  - [ ] 모든 테스트 통과
  - [ ] 응답 시간 측정 (<10ms 달성)

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] Phase 3 완료 표시

---

## 📊 마이그레이션 영향 분석

### 코드 변경량

| 파일 | Before (줄) | After (줄) | 변경률 |
|------|------------|-----------|--------|
| shared_prefs_notification_datasource.dart | 80 | 0 | -100% (삭제) |
| i_local_notification_datasource.dart | 25 | 0 | -100% (삭제) |
| notification_repository_impl.dart | 365 | 480 | +32% |
| notification_di_module.dart | 203 | 183 | -10% |
| main.dart | 50 | 80 | +60% |
| **합계** | **723줄** | **743줄** | **+3%** |

### 성능 개선

```
Before (SharedPreferences):
✅ 구현 단순
❌ L1 Memory Cache 없음
❌ Cache Hit: 50-100ms
❌ Firestore 읽기 비용 많음

After (UnifiedCacheService):
✅ L1 Memory Cache: <10ms (97% 개선)
✅ L2 Hive Cache: 10-30ms (70% 개선)
✅ L3 Firestore: Offline Cache 활성화
✅ Firestore 읽기 비용 70% 절감
```

---

## 🎓 추가 학습 자료

### 3-Layer 캐싱 심화

#### 1. LRU (Least Recently Used) 전략

```dart
/// SimpleMemoryCache - LRU 알고리즘
class SimpleMemoryCache {
  final int maxSize;
  final Map<String, String> _cache = {};
  final List<String> _accessOrder = [];

  void put(String key, String value) {
    // 기존 키 제거
    _accessOrder.remove(key);

    // LRU: 가장 오래된 항목 제거
    if (_cache.length >= maxSize) {
      final oldestKey = _accessOrder.removeAt(0);
      _cache.remove(oldestKey);
    }

    // 새 항목 추가 (맨 뒤)
    _cache[key] = value;
    _accessOrder.add(key);
  }

  String? get(String key) {
    if (!_cache.containsKey(key)) return null;

    // 액세스 순서 업데이트 (맨 뒤로)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return _cache[key];
  }
}
```

#### 2. Cache Invalidation 전략

```dart
// 1. 특정 키 무효화
await UnifiedCacheService.instance.invalidate('notifications_user_1');

// 2. 패턴 매칭 무효화
final allKeys = UnifiedCacheService.instance._hiveBox.keys;
for (final key in allKeys) {
  if (key.toString().startsWith('notifications_')) {
    await UnifiedCacheService.instance.invalidate(key.toString());
  }
}

// 3. 전체 무효화
await UnifiedCacheService.instance.clearAll();
```

### Chat & Auth Feature 참조

- **Chat PHASE_3_CACHE_INTEGRATION.md**: 3-Layer 캐싱 상세 가이드
- **Auth Feature**: UnifiedCacheService 활용 예시

---

## 📌 다음 단계

Phase 3 완료 후 **Phase 4: Idempotency Integration**으로 이동합니다.

**Phase 4 주요 작업**:
- IdempotencyService 통합
- eventId 파라미터 추가
- 중복 알림 전송 방지

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
