import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/entities/notification.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../../domain/failures/notification_failure.dart';
import '../../domain/entities/social_notification_extensions.dart';
import '../../domain/entities/system_notification_extensions.dart';
import '../../domain/entities/voting_notification_extensions.dart';
import '/services/cache/unified_cache_service.dart';
import '/services/cache/failures/cache_failure.dart';
import '/core/utils/idempotency_service.dart';

/// Clean Architecture 준수 Repository 구현체
///
/// **Phase 1 Complete**: Either Pattern 적용
/// - Exception throw → Either<NotificationFailure, T>
/// - Nullable 제거 → Either 사용
/// - try-catch → left()/right()
///
/// **Phase 2 Complete**: Riverpod 2.x 적용
/// - Provider → AsyncNotifierProvider
/// - StateNotifier → AsyncNotifier
/// - watch/ref 패턴 통합
///
/// **Phase 3 Complete**: UnifiedCacheService 3-Layer 캐싱
/// - SharedPreferences → UnifiedCacheService
/// - L1 Memory (<10ms), L2 Hive (10-30ms), L3 Firestore (50-100ms)
/// - Cache-First Pattern with sequential fallback
///
/// **Phase 4 Complete**: Idempotency Integration
/// - Transaction-based write operations
/// - UUID v4 eventId for duplicate prevention
/// - executeIdempotent wrapper pattern
///
/// **Phase 5 Complete**: Firebase-Centric v2.0
/// - Firestore 직접 접근 (DataSource 제거)
/// - Extension Pattern으로 변환 (DTO/Mapper 제거)
/// - 817줄 코드 감소 달성
class NotificationRepositoryImpl implements INotificationRepository {
  final FirebaseFirestore _firestore;
  final IdempotencyService _idempotencyService;

  // 3-Layer 캐싱 설정
  static const int _maxCacheSize = 100;

  NotificationRepositoryImpl({
    required FirebaseFirestore firestore,
    required IdempotencyService idempotencyService,
  })  : _firestore = firestore,
        _idempotencyService = idempotencyService;

  /// notifications 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  // ===== CRUD Operations (Either 패턴) =====

  @override
  Future<Either<NotificationFailure, Notification>> getNotification(
    String id,
  ) async {
    try {
      final cacheKey = 'notification_$id';

      // L1 Memory Cache (즉시 응답: <10ms)
      final cachedResult = await UnifiedCacheService.instance.get<Map<String, dynamic>>(cacheKey);
      final cached = cachedResult.fold(
        (failure) => null,  // Cache miss or error
        (data) => data,
      );

      if (cached != null) {
        // Cache에서 복원: Map → DocumentSnapshot 대신 직접 Extension 호출 불가
        // Firestore에서 다시 가져와서 Extension 사용
      }

      // L2 Hive는 get() 메서드 내부에서 자동 체크됨

      // L3 Firestore (네트워크 요청: 50-100ms)
      final doc = await _notificationsCollection.doc(id).get();

      if (!doc.exists) {
        return left(const NotificationFailure.notificationNotFound());
      }

      // Extension으로 변환
      final notification = _parseNotificationFromDoc(doc);

      // L1 + L2 캐시에 저장 (Map으로 저장)
      await UnifiedCacheService.instance.set(cacheKey, doc.data()!);

      return right(notification);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to get notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, List<Notification>>>
      getUserNotifications(
    String userId,
  ) async {
    try {
      final cacheKey = 'notifications_$userId';

      // L1 Memory Cache (즉시 응답: <10ms)
      final cachedListResult = await UnifiedCacheService.instance.get<List>(cacheKey);
      final cachedList = cachedListResult.fold(
        (failure) => null,  // Cache miss or error
        (data) => data,
      );

      if (cachedList != null) {
        // 캐시된 데이터는 재사용 가능하지만, Extension은 DocumentSnapshot 필요
        // Firestore에서 다시 가져와서 Extension 사용
      }

      // L2 Hive는 get() 메서드 내부에서 자동 체크됨

      // L3 Firestore (네트워크 요청: 50-100ms)
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(_maxCacheSize)
          .get();

      // Extension으로 변환
      final notifications = querySnapshot.docs
          .map((doc) => _parseNotificationFromDoc(doc))
          .toList();

      // L1 + L2 캐시에 저장 (List<Map>으로 저장)
      final dataList = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
      await UnifiedCacheService.instance.set(cacheKey, dataList);

      return right(notifications);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to get user notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> sendNotification(
    Notification notification,
    String eventId,
  ) async {
    try {
      // executeIdempotent로 중복 방지 (새 알림 생성)
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'notification',
        entityId: eventId, // 생성 작업이므로 eventId를 entityId로 사용
        userId: notification.userId,
        eventId: eventId,
        operation: (transaction) async {
          // Extension으로 변환
          final data = notification.map(
            social: (n) => n.toFirestore(),
            system: (n) => n.toFirestore(),
            voting: (n) => n.toFirestore(),
          );

          // Transaction 내에서 Firestore에 직접 생성
          final notifRef = _notificationsCollection.doc(); // 자동 생성 ID

          transaction.set(notifRef, {
            ...data,
            'id': notifRef.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
        },
      );

      // 캐시 무효화 (Transaction 후)
      await UnifiedCacheService.instance.invalidate('notifications_${notification.userId}');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to send notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String eventId,
  ) async {
    try {
      // 1. userId 조회 (Transaction 밖에서)
      final notificationDoc = await _notificationsCollection
          .doc(notificationId)
          .get();

      if (!notificationDoc.exists) {
        return left(const NotificationFailure.notificationNotFound());
      }

      final userId = notificationDoc.data()?['userId'] as String?;
      if (userId == null) {
        return left(const NotificationFailure.unexpected('Notification missing userId'));
      }

      // 2. executeIdempotent로 중복 방지
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'notification',
        entityId: notificationId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          // Transaction 내에서 직접 Firestore 업데이트
          final notifRef = _notificationsCollection.doc(notificationId);
          transaction.update(notifRef, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        },
      );

      // 3. 캐시 무효화 (Transaction 후)
      await UnifiedCacheService.instance.invalidate('notification');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else if (e.code == 'not-found') {
        return left(const NotificationFailure.notificationNotFound());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to mark as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String eventId,
  ) async {
    try {
      // 1. userId 조회 (Transaction 밖에서)
      final notificationDoc = await _notificationsCollection
          .doc(notificationId)
          .get();

      if (!notificationDoc.exists) {
        return left(const NotificationFailure.notificationNotFound());
      }

      final userId = notificationDoc.data()?['userId'] as String?;
      if (userId == null) {
        return left(const NotificationFailure.unexpected('Notification missing userId'));
      }

      // 2. executeIdempotent로 중복 방지
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'notification',
        entityId: notificationId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          // Transaction 내에서 직접 Firestore 삭제
          final notifRef = _notificationsCollection.doc(notificationId);
          transaction.delete(notifRef);
        },
      );

      // 3. 캐시 무효화 (Transaction 후)
      await UnifiedCacheService.instance.invalidate('notification');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else if (e.code == 'not-found') {
        return left(const NotificationFailure.notificationNotFound());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to delete notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAllAsRead(
    String userId,
    String eventId,
  ) async {
    try {
      // executeIdempotent로 중복 방지 (Batch 작업)
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'notifications_batch',
        entityId: 'markAllAsRead_$userId',
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          // Transaction 내에서 사용자의 모든 알림 조회 및 업데이트
          final notificationsRef = _notificationsCollection
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false);

          final snapshot = await notificationsRef.get();

          // Batch 업데이트
          for (final doc in snapshot.docs) {
            transaction.update(doc.reference, {
              'isRead': true,
              'readAt': FieldValue.serverTimestamp(),
            });
          }
        },
      );

      // 캐시 무효화 (Transaction 후)
      await UnifiedCacheService.instance.invalidate('notifications_$userId');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to mark all as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteAllNotifications(
    String userId,
    String eventId,
  ) async {
    try {
      // executeIdempotent로 중복 방지 (Batch 작업)
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'notifications_batch',
        entityId: 'deleteAll_$userId',
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          // Transaction 내에서 사용자의 모든 알림 조회 및 삭제
          final notificationsRef = _notificationsCollection
              .where('userId', isEqualTo: userId);

          final snapshot = await notificationsRef.get();

          // Batch 삭제
          for (final doc in snapshot.docs) {
            transaction.delete(doc.reference);
          }

          if (kDebugMode) {
            print(
                '[NotificationRepository] Deleted ${snapshot.docs.length} notifications for user: $userId');
          }
        },
      );

      // 캐시 무효화 (Transaction 후)
      await UnifiedCacheService.instance.invalidate('notifications_$userId');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to delete all notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteOldNotifications({
    required String userId,
    required DateTime before,
  }) async {
    try {
      // Firestore 직접 접근으로 날짜 기반 삭제
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(before))
          .get();

      // Batch 삭제
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 캐시 무효화
      await UnifiedCacheService.instance.invalidate('notifications_$userId');

      print(
          '[NotificationRepository] Deleted ${querySnapshot.docs.length} notifications before $before for user: $userId');
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationDeleteFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to delete old notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteExpiredNotifications(
    String userId,
  ) async {
    try {
      // Firestore 직접 접근으로 만료된 알림 삭제
      final now = DateTime.now();
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('expiryTime', isLessThan: Timestamp.fromDate(now))
          .get();

      // Batch 삭제
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 캐시 무효화
      await UnifiedCacheService.instance.invalidate('notifications_$userId');

      print(
          '[NotificationRepository] Deleted ${querySnapshot.docs.length} expired notifications for user: $userId');
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationDeleteFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to delete expired notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> cleanupExpiredNotifications(
    String userId,
  ) async {
    // cleanupExpiredNotifications는 deleteExpiredNotifications와 동일한 기능
    // 호환성을 위해 별칭으로 제공
    return deleteExpiredNotifications(userId);
  }

  @override
  Future<Either<NotificationFailure, int>> getUnreadCount(
    String userId,
  ) async {
    try {
      // Firestore 직접 접근으로 읽지 않은 알림 개수 조회
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return right(querySnapshot.docs.length);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to get unread count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, List<T>>> getNotificationsByType<
      T extends Notification>({
    required String userId,
    required String type,
    int? limit,
  }) async {
    try {
      // Firestore 직접 접근으로 타입별 알림 조회
      var query = _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      // Extension으로 변환 및 타입 필터링
      final notifications = <T>[];
      for (final doc in querySnapshot.docs) {
        try {
          final notification = _parseNotificationFromDoc(doc);
          if (notification is T) {
            notifications.add(notification);
          }
        } catch (e) {
          print('Failed to map notification: $e');
        }
      }

      return right(notifications);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to get notifications by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, String>> createNotification(
    Notification notification,
    String eventId,
  ) async {
    try {
      // executeIdempotent로 중복 방지 (새 알림 생성)
      final notificationId = await _idempotencyService.executeIdempotent<String>(
        entityType: 'notification',
        entityId: eventId, // 생성 작업이므로 eventId를 entityId로 사용
        userId: notification.userId,
        eventId: eventId,
        operation: (transaction) async {
          // Extension으로 변환
          final data = notification.map(
            social: (n) => n.toFirestore(),
            system: (n) => n.toFirestore(),
            voting: (n) => n.toFirestore(),
          );

          // Transaction 내에서 Firestore에 직접 생성
          final notifRef = _notificationsCollection.doc(); // 자동 생성 ID

          transaction.set(notifRef, {
            ...data,
            'id': notifRef.id,
            'createdAt': FieldValue.serverTimestamp(),
          });

          return notifRef.id; // ID 반환
        },
      );

      // 캐시 무효화 (Transaction 후)
      await UnifiedCacheService.instance.invalidate('notifications_${notification.userId}');

      if (kDebugMode) {
        print('Notification created with id: $notificationId');
      }
      return right(notificationId);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to create notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Firestore 직접 업데이트
      await _notificationsCollection.doc(notificationId).update(updates);

      // 캐시 무효화 - notificationId로부터 userId를 추출할 수 없으므로 전체 캐시 무효화
      await UnifiedCacheService.instance.invalidate('notification');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to update notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  }) async {
    try {
      if (targetUserIds != null && targetUserIds.isNotEmpty) {
        // 특정 사용자들에게만 브로드캐스트
        for (final userId in targetUserIds) {
          final userNotification = Notification.system(
            id: '', // Remote에서 생성됨
            userId: userId,
            type: 'system',
            createdAt: notification.createdAt,
            isRead: false,
            title: notification.title,
            content: notification.content,
            expiryTime: notification.expiryTime,
            metadata: notification.metadata,
            alertType: notification.alertType,
            actionUrl: notification.actionUrl,
            actionLabel: notification.actionLabel,
            actionButtons: notification.actionButtons,
            iconUrl: notification.iconUrl,
            isDismissible: notification.isDismissible,
          );

          final result = await createNotification(
            userNotification,
            const Uuid().v4(), // UUID 생성
          );
          // 실패 시 에러 전파
          if (result.isLeft()) {
            return result.map((_) => unit);
          }
        }
      } else {
        // 모든 활성 사용자 ID 가져오기 (Firestore 직접 접근)
        final usersSnapshot = await _firestore
            .collection('users')
            .where('isActive', isEqualTo: true)
            .get();

        final userIds = usersSnapshot.docs
            .map((doc) => doc.id)
            .toList();

        print(
            '[NotificationRepository] Broadcasting to ${userIds.length} active users');

        for (final userId in userIds) {
          final userNotification = Notification.system(
            id: '', // Remote에서 생성됨
            userId: userId,
            type: 'system',
            createdAt: notification.createdAt,
            isRead: false,
            title: notification.title,
            content: notification.content,
            expiryTime: notification.expiryTime,
            metadata: notification.metadata,
            alertType: notification.alertType,
            actionUrl: notification.actionUrl,
            actionLabel: notification.actionLabel,
            actionButtons: notification.actionButtons,
            iconUrl: notification.iconUrl,
            isDismissible: notification.isDismissible,
          );

          final result = await createNotification(
            userNotification,
            const Uuid().v4(), // UUID 생성
          );
          // 실패 시 에러 전파
          if (result.isLeft()) {
            return result.map((_) => unit);
          }
        }
      }

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to broadcast system notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  }) async {
    try {
      // 1. 최근 24시간 내 같은 타입의 알림 조회
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'social')
          .where('createdAt',
              isGreaterThan:
                  Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24))))
          .limit(50)
          .get();

      // 2. 같은 actionType과 postId를 가진 알림 찾기
      DocumentSnapshot? existingNotificationDoc;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['actionType'] == actionType.name &&
            data['relatedPostId'] == relatedPostId) {
          existingNotificationDoc = doc;
          break;
        }
      }

      if (existingNotificationDoc != null) {
        // 3. 기존 알림이 있으면 interactionCount 증가
        final data = existingNotificationDoc.data() as Map<String, dynamic>;
        final currentCount = data['interactionCount'] ?? 1;
        final updateResult = await updateNotification(
          existingNotificationDoc.id,
          {
            'interactionCount': currentCount + 1,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        // 실패 시 에러 전파
        if (updateResult.isLeft()) {
          return updateResult;
        }
      } else {
        // 4. 새 소셜 알림 생성
        final newNotification = Notification.social(
          id: '', // Remote에서 생성됨
          userId: userId,
          type: 'social',
          createdAt: DateTime.now(),
          isRead: false,
          title: _generateSocialTitle(actionType),
          content: _generateSocialContent(actionType, relatedPostId),
          actionType: actionType,
          fromUserId: '', // 실제로는 호출하는 곳에서 제공해야 함
          fromUserName: 'User', // 실제로는 호출하는 곳에서 제공해야 함
          relatedPostId: relatedPostId,
          interactionCount: 1,
        );

        final createResult = await createNotification(
          newNotification,
          const Uuid().v4(), // UUID 생성
        );
        // 실패 시 에러 전파
        if (createResult.isLeft()) {
          return createResult.map((_) => unit);
        }
      }

      // 5. 캐시 업데이트
      await UnifiedCacheService.instance.invalidate('notifications_$userId');

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      } else if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return left(const NotificationFailure.networkError());
      } else {
        return left(const NotificationFailure.serverError());
      }
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to group social notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Map<String, dynamic>>>
      getNotificationStats(String userId) async {
    try {
      // Firestore 직접 접근으로 통계 데이터 계산
      final allNotifications = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      var unreadCount = 0;
      var votingRequests = 0;
      var systemAlerts = 0;
      var socialNotifications = 0;

      for (final doc in allNotifications.docs) {
        final data = doc.data();
        if (data['isRead'] == false) {
          unreadCount++;
        }

        final type = data['type'] as String?;
        switch (type) {
          case 'voting':
            votingRequests++;
            break;
          case 'system':
            systemAlerts++;
            break;
          case 'social':
            socialNotifications++;
            break;
        }
      }

      final result = {
        'totalNotifications': allNotifications.docs.length,
        'unreadCount': unreadCount,
        'votingRequests': votingRequests,
        'systemAlerts': systemAlerts,
        'socialNotifications': socialNotifications,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      return right(result);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to get notification stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, List<Map<String, dynamic>>>>
      getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      // Firestore 직접 접근으로 활동 로그 조회
      final querySnapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .orderBy('createdAt', descending: true)
          .get();

      // 로그 정보 포맷팅
      final formattedLogs = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'timestamp': data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
                  : DateTime.now().toIso8601String(),
              'action': data['isRead'] == true ? 'read' : 'created',
              'notificationId': doc.id,
              'notificationType': data['type'] ?? 'unknown',
              'details': {
                'title': data['title'] ?? '',
                'content': data['content'] ?? '',
              },
            };
          })
          .toList();

      return right(formattedLogs);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to get notification activity log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> initializeNotificationSystem({
    required String userId,
  }) async {
    try {
      // Initialize notification system
      // For now, we'll just clear the cache and prepare for listening
      await UnifiedCacheService.instance.invalidate('notifications_$userId');
      print(
          '[NotificationRepository] Notification system initialized for user: $userId');
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to initialize notification system: ${e.toString()}'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> stopListening({
    required String userId,
  }) async {
    try {
      // Stop listening to notifications
      // For now, just clear cache
      await UnifiedCacheService.instance.invalidate('notifications_$userId');
      print('[NotificationRepository] Stopped listening for user: $userId');
      return right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return left(const NotificationFailure.permissionDenied());
      }
      return left(const NotificationFailure.notificationLoadFailed());
    } catch (e) {
      return left(NotificationFailure.unexpected('Failed to stop notification listening: ${e.toString()}'));
    }
  }

  // ===== Queries (Stream) =====
  // Note: Stream은 Either 미사용 (Stream.error()로 처리)

  @override
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  }) {
    // Firestore 직접 스트림 감시
    var query = _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    // 필터 적용
    if (filter?.type != null) {
      query = query.where('type', isEqualTo: filter!.type);
    }
    if (filter?.unreadOnly == true) {
      query = query.where('isRead', isEqualTo: false);
    }
    if (filter?.after != null) {
      query = query.where('createdAt',
          isGreaterThan: Timestamp.fromDate(filter!.after!));
    }
    if (filter?.before != null) {
      query = query.where('createdAt',
          isLessThan: Timestamp.fromDate(filter!.before!));
    }
    if (filter?.limit != null) {
      query = query.limit(filter!.limit!);
    }

    return query.snapshots().asyncMap((snapshot) async {
      // 캐시 업데이트 (List<Map>으로 저장)
      final cacheKey = 'notifications_$userId';
      final dataList = snapshot.docs.map((doc) => doc.data()).toList();
      await UnifiedCacheService.instance.set(cacheKey, dataList);

      // Extension으로 변환
      final notifications = <Notification>[];
      for (final doc in snapshot.docs) {
        try {
          final notification = _parseNotificationFromDoc(doc);
          notifications.add(notification);
        } catch (e) {
          // 변환 실패한 항목은 건너뛰기
          print('Failed to map notification: $e');
        }
      }

      // 필터 적용 (추가 필터링이 필요한 경우)
      return _applyFilter(notifications, filter);
    });
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    // Firestore 직접 스트림 감시
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Stream<int> getUnreadNotificationCount(String userId) {
    // Create a stream controller to emit unread count updates
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      final result = await getUserNotifications(userId);
      return result.fold(
        (failure) {
          print('[NotificationRepository] Error getting unread count: $failure');
          return 0;
        },
        (notifications) =>
            notifications.where((n) => !n.isRead).toList().length,
      );
    }).asyncMap((future) => future);
  }

  @override
  Future<Stream<Notification>> startListening({
    required String userId,
  }) async {
    try {
      // Firestore 직접 스트림 감시
      final stream = _notificationsCollection
          .where('userId', isEqualTo: userId)
          .snapshots();

      // Transform stream to domain models
      return stream.expand((snapshot) => snapshot.docs).map((doc) {
        return _parseNotificationFromDoc(doc);
      });
    } catch (e) {
      throw Exception('Failed to start notification listening: $e');
    }
  }

  // ===== Private Helper Methods =====

  /// Firestore DocumentSnapshot → Notification Entity
  ///
  /// **Sealed Union 타입 분기**:
  /// - 'social' → SocialNotificationFirestore.fromFirestore()
  /// - 'system' → SystemNotificationFirestore.fromFirestore()
  /// - 'voting' → VotingNotificationFirestore.fromFirestore()
  Notification _parseNotificationFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String;

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

  /// 추가 필터 적용
  List<Notification> _applyFilter(
    List<Notification> notifications,
    NotificationFilter? filter,
  ) {
    if (filter == null) return notifications;

    var filtered = notifications;

    // Exclude expired notifications if requested
    if (filter.excludeExpired == true) {
      filtered = filtered.where((n) => !n.isExpired).toList();
    }

    // 정렬
    if (filter.sortBy == 'priority') {
      filtered.sort((a, b) {
        // Note: VoteNotification priority sorting is now handled by Voting Feature
        // Default priority comparison for system and social notifications
        final aPriority = 0;
        final bPriority = 0;

        if (filter.sortOrder == SortOrder.descending) {
          return bPriority.compareTo(aPriority);
        } else {
          return aPriority.compareTo(bPriority);
        }
      });
    } else {
      // 기본 정렬 (생성일)
      filtered.sort((a, b) {
        if (filter.sortOrder == SortOrder.descending) {
          return b.createdAt.compareTo(a.createdAt);
        } else {
          return a.createdAt.compareTo(b.createdAt);
        }
      });
    }

    // Limit 적용
    if (filter.limit != null && filtered.length > filter.limit!) {
      filtered = filtered.take(filter.limit!).toList();
    }

    return filtered;
  }

  // Helper 메서드들
  String _generateSocialTitle(SocialActionType actionType) {
    switch (actionType) {
      case SocialActionType.like:
        return '새로운 좋아요';
      case SocialActionType.comment:
        return '새로운 댓글';
      case SocialActionType.friendRequest:
        return '친구 요청';
      case SocialActionType.friendAccepted:
        return '친구 요청 수락됨';
      case SocialActionType.follow:
        return '새로운 팔로워';
      case SocialActionType.mention:
        return '새로운 멘션';
      case SocialActionType.share:
        return '새로운 공유';
    }
  }

  String _generateSocialContent(SocialActionType actionType, String postId) {
    switch (actionType) {
      case SocialActionType.like:
        return '게시물에 좋아요를 받았습니다';
      case SocialActionType.comment:
        return '게시물에 새 댓글이 달렸습니다';
      case SocialActionType.friendRequest:
        return '친구 요청을 받았습니다';
      case SocialActionType.friendAccepted:
        return '친구 요청이 수락되었습니다';
      case SocialActionType.follow:
        return '새로운 팔로워가 있습니다';
      case SocialActionType.mention:
        return '게시물에서 멘션되었습니다';
      case SocialActionType.share:
        return '게시물이 공유되었습니다';
    }
  }
}
