import 'package:cloud_firestore/cloud_firestore.dart';

// Legacy query methods for backward compatibility
// These are deprecated and should be replaced with repository pattern

@Deprecated('Use GetIt.instance<IChatRepository>().getChatsStream() instead')
Stream<List<T>> queryCollection<T>(
  CollectionReference collection,
  T Function(DocumentSnapshot) fromSnapshot, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = collection;
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (limit > 0) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  
  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => fromSnapshot(doc)).toList());
}

@Deprecated('Use GetIt.instance<IChatRepository>().getChatsCount() instead')
Future<int> queryCollectionCount(
  CollectionReference collection, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) async {
  Query query = collection;
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.length;
}

@Deprecated('Use GetIt.instance<IChatRepository>().getChats() instead')
Future<List<T>> queryCollectionOnce<T>(
  CollectionReference collection,
  T Function(DocumentSnapshot) fromSnapshot, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) async {
  Query query = collection;
  
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (limit > 0) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => fromSnapshot(doc)).toList();
}