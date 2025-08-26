import 'dart:async';

import '/backend/algolia/algolia_manager.dart';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import '/app/widgets/index.dart';
import '/core_exports.dart';

class JopsCategoryModel extends FirestoreRecord {
  JopsCategoryModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "jopName" field.
  String? _jopName;
  String get jopName => _jopName ?? '';
  bool hasJopName() => _jopName != null;

  // "categoryRefA" field.
  String? _categoryRefA;
  String get categoryRefA => _categoryRefA ?? '';
  bool hasCategoryRefA() => _categoryRefA != null;

  // "categoryRefB" field.
  String? _categoryRefB;
  String get categoryRefB => _categoryRefB ?? '';
  bool hasCategoryRefB() => _categoryRefB != null;

  // "searchTags" field.
  List<String>? _searchTags;
  List<String> get searchTags => _searchTags ?? const [];
  bool hasSearchTags() => _searchTags != null;

  void _initializeFields() {
    _jopName = snapshotData['jopName'] as String?;
    _categoryRefA = snapshotData['categoryRefA'] as String?;
    _categoryRefB = snapshotData['categoryRefB'] as String?;
    _searchTags = getDataList(snapshotData['searchTags']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('jopsCategory');

  static Stream<JopsCategoryModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => JopsCategoryModel.fromSnapshot(s));

  static Future<JopsCategoryModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => JopsCategoryModel.fromSnapshot(s));

  static JopsCategoryModel fromSnapshot(DocumentSnapshot snapshot) =>
      JopsCategoryModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static JopsCategoryModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      JopsCategoryModel._(reference, mapFromFirestore(data));

  static JopsCategoryModel fromAlgolia(AlgoliaObjectSnapshot snapshot) =>
      JopsCategoryModel.getDocumentFromData(
        {
          'jopName': snapshot.data['jopName'],
          'categoryRefA': snapshot.data['categoryRefA'],
          'categoryRefB': snapshot.data['categoryRefB'],
          'searchTags': safeGet(
            () => snapshot.data['searchTags'].toList(),
          ),
        },
        JopsCategoryModel.collection.doc(snapshot.objectID),
      );

  static Future<List<JopsCategoryModel>> search({
    String? term,
    FutureOr<LatLng>? location,
    int? maxResults,
    double? searchRadiusMeters,
    bool useCache = false,
  }) =>
      AppAlgoliaManager.instance
          .algoliaQuery(
            index: 'jopsCategory',
            term: term,
            maxResults: maxResults,
            location: location,
            searchRadiusMeters: searchRadiusMeters,
            useCache: useCache,
          )
          .then((r) => r.map(fromAlgolia).toList());

  @override
  String toString() =>
      'JopsCategoryModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is JopsCategoryModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createJopsCategoryModelData({
  String? jopName,
  String? categoryRefA,
  String? categoryRefB,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'jopName': jopName,
      'categoryRefA': categoryRefA,
      'categoryRefB': categoryRefB,
    }.withoutNulls,
  );

  return firestoreData;
}

class JopsCategoryModelDocumentEquality
    implements Equality<JopsCategoryModel> {
  const JopsCategoryModelDocumentEquality();

  @override
  bool equals(JopsCategoryModel? e1, JopsCategoryModel? e2) {
    const listEquality = ListEquality();
    return e1?.jopName == e2?.jopName &&
        e1?.categoryRefA == e2?.categoryRefA &&
        e1?.categoryRefB == e2?.categoryRefB &&
        listEquality.equals(e1?.searchTags, e2?.searchTags);
  }

  @override
  int hash(JopsCategoryModel? e) => const ListEquality()
      .hash([e?.jopName, e?.categoryRefA, e?.categoryRefB, e?.searchTags]);

  @override
  bool isValidKey(Object? o) => o is JopsCategoryModel;
}
