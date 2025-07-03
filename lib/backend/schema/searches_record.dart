import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class SearchesRecord extends FirestoreRecord {
  SearchesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "search_id" field.
  String? _searchId;
  String get searchId => _searchId ?? '';
  bool hasSearchId() => _searchId != null;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "query" field.
  String? _query;
  String get query => _query ?? '';
  bool hasQuery() => _query != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  void _initializeFields() {
    _searchId = snapshotData['search_id'] as String?;
    _userId = snapshotData['user_id'] as String?;
    _query = snapshotData['query'] as String?;
    _date = snapshotData['date'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('searches');

  static Stream<SearchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SearchesRecord.fromSnapshot(s));

  static Future<SearchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SearchesRecord.fromSnapshot(s));

  static SearchesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SearchesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SearchesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SearchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SearchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SearchesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSearchesRecordData({
  String? searchId,
  String? userId,
  String? query,
  DateTime? date,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'search_id': searchId,
      'user_id': userId,
      'query': query,
      'date': date,
    }.withoutNulls,
  );

  return firestoreData;
}

class SearchesRecordDocumentEquality implements Equality<SearchesRecord> {
  const SearchesRecordDocumentEquality();

  @override
  bool equals(SearchesRecord? e1, SearchesRecord? e2) {
    return e1?.searchId == e2?.searchId &&
        e1?.userId == e2?.userId &&
        e1?.query == e2?.query &&
        e1?.date == e2?.date;
  }

  @override
  int hash(SearchesRecord? e) =>
      const ListEquality().hash([e?.searchId, e?.userId, e?.query, e?.date]);

  @override
  bool isValidKey(Object? o) => o is SearchesRecord;
}
