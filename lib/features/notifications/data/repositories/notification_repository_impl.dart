import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/firebase/firestore/utils/firestore_util.dart';
import '/backend/backend.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/features/notifications/domain/models/notification_model.dart';
import '/features/notifications/domain/models/notifications_model.dart';

/// Implementation of notification repository with migrated backend query functions
class NotificationRepositoryImpl {
  static NotificationRepositoryImpl? _instance;
  static NotificationRepositoryImpl get instance => _instance ??= NotificationRepositoryImpl._();
  
  NotificationRepositoryImpl._();
  
  // MIGRATED: Notification queries (lines 99-137 from backend.dart)
  Future<int> queryNotificationModelCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        NotificationModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<NotificationModel>> queryNotificationModel({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        NotificationModel.collection(parent),
        NotificationModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<NotificationModel>> queryNotificationModelOnce({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        NotificationModel.collection(parent),
        NotificationModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Notifications queries (lines 801-836 from backend.dart)
  Future<int> queryNotificationsModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        NotificationsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<NotificationsModel>> queryNotificationsModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        NotificationsModel.collection,
        NotificationsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<NotificationsModel>> queryNotificationsModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        NotificationsModel.collection,
        NotificationsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );
}