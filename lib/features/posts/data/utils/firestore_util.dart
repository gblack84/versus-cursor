import 'package:cloud_firestore/cloud_firestore.dart';

/// Posts feature-specific Firestore utility functions
/// Migrated from backend/firebase/firestore/utils/firestore_util.dart
class PostsFirestoreUtil {
  /// Maps data from Firestore format for reading
  /// Handles Timestamp -> DateTime and GeoPoint -> GeoPoint conversion
  static Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) {
    return data.map((key, value) {
      // Handle Timestamp
      if (value is Timestamp) {
        value = value.toDate();
      }
      // Handle list of Timestamp
      if (value is Iterable && value.isNotEmpty && value.first is Timestamp) {
        value = value.map((v) => (v as Timestamp).toDate()).toList();
      }
      // Handle nested data
      if (value is Map) {
        value = mapFromFirestore(value as Map<String, dynamic>);
      }
      // Handle list of nested data
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapFromFirestore(v as Map<String, dynamic>))
            .toList();
      }
      return MapEntry(key, value);
    });
  }

  /// Maps data to Firestore format for writing
  /// Handles DateTime -> Timestamp and other format conversions
  static Map<String, dynamic> mapToFirestore(Map<String, dynamic> data) {
    return data.map((key, value) {
      // Handle DateTime -> Timestamp (implicit conversion by Firestore)
      // Handle nested data
      if (value is Map) {
        value = mapToFirestore(value as Map<String, dynamic>);
      }
      // Handle list of nested data
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapToFirestore(v as Map<String, dynamic>))
            .toList();
      }
      return MapEntry(key, value);
    });
  }

  /// Safe getter with error handling
  static T? safeGet<T>(T Function() func, [Function(dynamic)? reportError]) {
    try {
      return func();
    } catch (e) {
      reportError?.call(e);
    }
    return null;
  }

  /// Convert string path to DocumentReference
  static DocumentReference toRef(String ref) => FirebaseFirestore.instance.doc(ref);
}

/// Type definition for record builders
typedef RecordBuilder<T> = T Function(DocumentSnapshot snapshot);

/// Query collection helper functions
/// Migrated from backend.dart to posts feature
class PostsQueryUtil {
  /// Count documents in a collection
  static Future<int> queryCollectionCount(
    Query collection, {
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) {
    final builder = queryBuilder ?? (q) => q;
    var query = builder(collection);
    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.count().get().then((value) => value.count!).catchError((err) {
      print('Error querying $collection: $err');
      return 0;
    });
  }

  /// Stream query for collection
  static Stream<List<T>> queryCollection<T>(
    Query collection,
    RecordBuilder<T> recordBuilder, {
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    final builder = queryBuilder ?? (q) => q;
    var query = builder(collection);
    if (limit > 0 || singleRecord) {
      query = query.limit(singleRecord ? 1 : limit);
    }
    return query.snapshots().handleError((err) {
      print('Error querying $collection: $err');
    }).map((s) => s.docs
        .map(
          (d) => PostsFirestoreUtil.safeGet(
            () => recordBuilder(d),
            (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
          ),
        )
        .where((d) => d != null)
        .map((d) => d!)
        .toList());
  }

  /// One-time query for collection
  static Future<List<T>> queryCollectionOnce<T>(
    Query collection,
    RecordBuilder<T> recordBuilder, {
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    final builder = queryBuilder ?? (q) => q;
    var query = builder(collection);
    if (limit > 0 || singleRecord) {
      query = query.limit(singleRecord ? 1 : limit);
    }
    return query.get().then((s) => s.docs
        .map(
          (d) => PostsFirestoreUtil.safeGet(
            () => recordBuilder(d),
            (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
          ),
        )
        .where((d) => d != null)
        .map((d) => d!)
        .toList());
  }
}

/// Extension for query helpers
extension PostsQueryExtension on Query {
  Query whereIn(String field, List? list) => (list?.isEmpty ?? true)
      ? where(field, whereIn: null)
      : where(field, whereIn: list);

  Query whereNotIn(String field, List? list) => (list?.isEmpty ?? true)
      ? where(field, whereNotIn: null)
      : where(field, whereNotIn: list);

  Query whereArrayContainsAny(String field, List? list) =>
      (list?.isEmpty ?? true)
          ? where(field, arrayContainsAny: null)
          : where(field, arrayContainsAny: list);
}

/// Overloaded query functions for collections that take parent parameter
extension PostsQueryUtilParent on PostsQueryUtil {
  /// Count documents with parent parameter
  static Future<int> queryCollectionCountWithParent(
    Query<Map<String, dynamic>> Function([DocumentReference?]) collectionBuilder, {
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) {
    final collection = collectionBuilder(parent);
    return PostsQueryUtil.queryCollectionCount(
      collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  /// Stream query with parent parameter
  static Stream<List<T>> queryCollectionWithParent<T>(
    Query<Map<String, dynamic>> Function([DocumentReference?]) collectionBuilder,
    RecordBuilder<T> recordBuilder, {
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    final collection = collectionBuilder(parent);
    return PostsQueryUtil.queryCollection<T>(
      collection,
      recordBuilder,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  /// One-time query with parent parameter
  static Future<List<T>> queryCollectionOnceWithParent<T>(
    Query<Map<String, dynamic>> Function([DocumentReference?]) collectionBuilder,
    RecordBuilder<T> recordBuilder, {
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    final collection = collectionBuilder(parent);
    return PostsQueryUtil.queryCollectionOnce<T>(
      collection,
      recordBuilder,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }
}
