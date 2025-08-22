import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class SearchesModel extends FirestoreRecord {
  SearchesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "searchId" field.
  String? _searchId;
  String get searchId => _searchId ?? '';
  bool hasSearchId() => _searchId != null;

  // "userId" field.
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
    _searchId = snapshotData['searchId'] as String?;
    _userId = snapshotData['userId'] as String?;
    _query = snapshotData['query'] as String?;
    _date = snapshotData['date'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('searches');

  static Stream<SearchesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SearchesModel.fromSnapshot(s));

  static Future<SearchesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SearchesModel.fromSnapshot(s));

  static SearchesModel fromSnapshot(DocumentSnapshot snapshot) =>
      SearchesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SearchesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SearchesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SearchesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SearchesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSearchesModelData({
  String? searchId,
  String? userId,
  String? query,
  DateTime? date,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'searchId': searchId,
      'userId': userId,
      'query': query,
      'date': date,
    }.withoutNulls,
  );

  return firestoreData;
}

class SearchesModelDocumentEquality implements Equality<SearchesModel> {
  const SearchesModelDocumentEquality();

  @override
  bool equals(SearchesModel? e1, SearchesModel? e2) {
    return e1?.searchId == e2?.searchId &&
        e1?.userId == e2?.userId &&
        e1?.query == e2?.query &&
        e1?.date == e2?.date;
  }

  @override
  int hash(SearchesModel? e) =>
      const ListEquality().hash([e?.searchId, e?.userId, e?.query, e?.date]);

  @override
  bool isValidKey(Object? o) => o is SearchesModel;
}
