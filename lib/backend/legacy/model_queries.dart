import 'package:cloud_firestore/cloud_firestore.dart';

import '/features/chat/domain/models/chats_model.dart';
import '/features/profile/domain/models/friends_list_model.dart';
import '/features/notifications/domain/models/notifications_model.dart';

import 'legacy_query_methods.dart';

// Legacy query methods for specific models
// These are deprecated and should be replaced with repository pattern

// ===== CHATS MODEL QUERIES =====

@Deprecated('Use GetIt.instance<IChatRepository>().getChatsCount() instead')
Future<int> queryChatsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ChatsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

@Deprecated('Use GetIt.instance<IChatRepository>().getChatsStream() instead')
Stream<List<ChatsModel>> queryChatsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ChatsModel.collection,
      ChatsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

@Deprecated('Use GetIt.instance<IChatRepository>().getChats() instead')
Future<List<ChatsModel>> queryChatsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ChatsModel.collection,
      ChatsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

// ===== FRIENDS LIST MODEL QUERIES =====

@Deprecated('Use GetIt.instance<IUserRepository>().getFriendsListCount() instead')
Future<int> queryFriendsListModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) async {
  Query query = FriendsListModel.collection(parent);
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.length;
}

@Deprecated('Use GetIt.instance<IUserRepository>().getFriendsListStream() instead')
Stream<List<FriendsListModel>> queryFriendsListModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = FriendsListModel.collection(parent);
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (limit > 0) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  
  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => FriendsListModel.fromSnapshot(doc)).toList());
}

@Deprecated('Use GetIt.instance<IUserRepository>().getFriendsList() instead')
Future<List<FriendsListModel>> queryFriendsListModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) async {
  Query query = FriendsListModel.collection(parent);
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (limit > 0) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => FriendsListModel.fromSnapshot(doc)).toList();
}

// ===== NOTIFICATIONS MODEL QUERIES =====

@Deprecated('Use GetIt.instance<INotificationRepository>().getNotificationsCount() instead')
Future<int> queryNotificationsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      NotificationsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

@Deprecated('Use GetIt.instance<INotificationRepository>().getNotificationsStream() instead')
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

@Deprecated('Use GetIt.instance<INotificationRepository>().getNotifications() instead')
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