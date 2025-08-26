import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core_exports.dart';

class VotecountsModel extends FirestoreRecord {
  VotecountsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "option1" field.
  int? _option1;
  int get option1 => _option1 ?? 0;
  bool hasOption1() => _option1 != null;

  // "option2" field.
  int? _option2;
  int get option2 => _option2 ?? 0;
  bool hasOption2() => _option2 != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _option1 = castToType<int>(snapshotData['option1']);
    _option2 = castToType<int>(snapshotData['option2']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('votecounts')
          : FirebaseFirestore.instance.collectionGroup('votecounts');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('votecounts').doc(id);

  static Stream<VotecountsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VotecountsModel.fromSnapshot(s));

  static Future<VotecountsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VotecountsModel.fromSnapshot(s));

  static VotecountsModel fromSnapshot(DocumentSnapshot snapshot) =>
      VotecountsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VotecountsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VotecountsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VotecountsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VotecountsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVotecountsModelData({
  int? option1,
  int? option2,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'option1': option1,
      'option2': option2,
    }.withoutNulls,
  );

  return firestoreData;
}

class VotecountsModelDocumentEquality implements Equality<VotecountsModel> {
  const VotecountsModelDocumentEquality();

  @override
  bool equals(VotecountsModel? e1, VotecountsModel? e2) {
    return e1?.option1 == e2?.option1 && e1?.option2 == e2?.option2;
  }

  @override
  int hash(VotecountsModel? e) =>
      const ListEquality().hash([e?.option1, e?.option2]);

  @override
  bool isValidKey(Object? o) => o is VotecountsModel;
}
