import 'dart:async';

import '/backend/algolia/algolia_manager.dart';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class JopsCategoryRecord extends FirestoreRecord {
  JopsCategoryRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "jop_name" field.
  String? _jopName;
  String get jopName => _jopName ?? '';
  bool hasJopName() => _jopName != null;

  // "category_ref_A" field.
  String? _categoryRefA;
  String get categoryRefA => _categoryRefA ?? '';
  bool hasCategoryRefA() => _categoryRefA != null;

  // "category_ref_B" field.
  String? _categoryRefB;
  String get categoryRefB => _categoryRefB ?? '';
  bool hasCategoryRefB() => _categoryRefB != null;

  // "search_tags" field.
  List<String>? _searchTags;
  List<String> get searchTags => _searchTags ?? const [];
  bool hasSearchTags() => _searchTags != null;

  void _initializeFields() {
    _jopName = snapshotData['jop_name'] as String?;
    _categoryRefA = snapshotData['category_ref_A'] as String?;
    _categoryRefB = snapshotData['category_ref_B'] as String?;
    _searchTags = getDataList(snapshotData['search_tags']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('jops_category');

  static Stream<JopsCategoryRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => JopsCategoryRecord.fromSnapshot(s));

  static Future<JopsCategoryRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => JopsCategoryRecord.fromSnapshot(s));

  static JopsCategoryRecord fromSnapshot(DocumentSnapshot snapshot) =>
      JopsCategoryRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static JopsCategoryRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      JopsCategoryRecord._(reference, mapFromFirestore(data));

  static JopsCategoryRecord fromAlgolia(AlgoliaObjectSnapshot snapshot) =>
      JopsCategoryRecord.getDocumentFromData(
        {
          'jop_name': snapshot.data['jop_name'],
          'category_ref_A': snapshot.data['category_ref_A'],
          'category_ref_B': snapshot.data['category_ref_B'],
          'search_tags': safeGet(
            () => snapshot.data['search_tags'].toList(),
          ),
        },
        JopsCategoryRecord.collection.doc(snapshot.objectID),
      );

  static Future<List<JopsCategoryRecord>> search({
    String? term,
    FutureOr<LatLng>? location,
    int? maxResults,
    double? searchRadiusMeters,
    bool useCache = false,
  }) =>
      AppAlgoliaManager.instance
          .algoliaQuery(
            index: 'jops_category',
            term: term,
            maxResults: maxResults,
            location: location,
            searchRadiusMeters: searchRadiusMeters,
            useCache: useCache,
          )
          .then((r) => r.map(fromAlgolia).toList());

  @override
  String toString() =>
      'JopsCategoryRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is JopsCategoryRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createJopsCategoryRecordData({
  String? jopName,
  String? categoryRefA,
  String? categoryRefB,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'jop_name': jopName,
      'category_ref_A': categoryRefA,
      'category_ref_B': categoryRefB,
    }.withoutNulls,
  );

  return firestoreData;
}

class JopsCategoryRecordDocumentEquality
    implements Equality<JopsCategoryRecord> {
  const JopsCategoryRecordDocumentEquality();

  @override
  bool equals(JopsCategoryRecord? e1, JopsCategoryRecord? e2) {
    const listEquality = ListEquality();
    return e1?.jopName == e2?.jopName &&
        e1?.categoryRefA == e2?.categoryRefA &&
        e1?.categoryRefB == e2?.categoryRefB &&
        listEquality.equals(e1?.searchTags, e2?.searchTags);
  }

  @override
  int hash(JopsCategoryRecord? e) => const ListEquality()
      .hash([e?.jopName, e?.categoryRefA, e?.categoryRefB, e?.searchTags]);

  @override
  bool isValidKey(Object? o) => o is JopsCategoryRecord;
}
