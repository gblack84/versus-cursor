import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class JopsNameRecord extends FirestoreRecord {
  JopsNameRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "category_ref" field.
  String? _categoryRef;
  String get categoryRef => _categoryRef ?? '';
  bool hasCategoryRef() => _categoryRef != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _categoryRef = snapshotData['category_ref'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('jops_name');

  static Stream<JopsNameRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => JopsNameRecord.fromSnapshot(s));

  static Future<JopsNameRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => JopsNameRecord.fromSnapshot(s));

  static JopsNameRecord fromSnapshot(DocumentSnapshot snapshot) =>
      JopsNameRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static JopsNameRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      JopsNameRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'JopsNameRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is JopsNameRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createJopsNameRecordData({
  String? name,
  String? categoryRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'category_ref': categoryRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class JopsNameRecordDocumentEquality implements Equality<JopsNameRecord> {
  const JopsNameRecordDocumentEquality();

  @override
  bool equals(JopsNameRecord? e1, JopsNameRecord? e2) {
    return e1?.name == e2?.name && e1?.categoryRef == e2?.categoryRef;
  }

  @override
  int hash(JopsNameRecord? e) =>
      const ListEquality().hash([e?.name, e?.categoryRef]);

  @override
  bool isValidKey(Object? o) => o is JopsNameRecord;
}
