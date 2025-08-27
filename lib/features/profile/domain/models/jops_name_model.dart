import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/firebase/firestore/utils/firestore_util.dart';

import '/core_exports.dart';

class JopsNameModel extends FirestoreRecord {
  JopsNameModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "categoryRef" field.
  String? _categoryRef;
  String get categoryRef => _categoryRef ?? '';
  bool hasCategoryRef() => _categoryRef != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _categoryRef = snapshotData['categoryRef'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('jopsName');

  static Stream<JopsNameModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => JopsNameModel.fromSnapshot(s));

  static Future<JopsNameModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => JopsNameModel.fromSnapshot(s));

  static JopsNameModel fromSnapshot(DocumentSnapshot snapshot) =>
      JopsNameModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static JopsNameModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      JopsNameModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'JopsNameModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is JopsNameModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createJopsNameModelData({
  String? name,
  String? categoryRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'categoryRef': categoryRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class JopsNameModelDocumentEquality implements Equality<JopsNameModel> {
  const JopsNameModelDocumentEquality();

  @override
  bool equals(JopsNameModel? e1, JopsNameModel? e2) {
    return e1?.name == e2?.name && e1?.categoryRef == e2?.categoryRef;
  }

  @override
  int hash(JopsNameModel? e) =>
      const ListEquality().hash([e?.name, e?.categoryRef]);

  @override
  bool isValidKey(Object? o) => o is JopsNameModel;
}
