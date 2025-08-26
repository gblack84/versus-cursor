import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import '/app/widgets/index.dart';
import '/core_exports.dart';

class ContentsSharesModel extends FirestoreRecord {
  ContentsSharesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "shearedToUserId" field.
  String? _shearedToUserId;
  String get shearedToUserId => _shearedToUserId ?? '';
  bool hasShearedToUserId() => _shearedToUserId != null;

  // "sharedId" field.
  DateTime? _sharedId;
  DateTime? get sharedId => _sharedId;
  bool hasSharedId() => _sharedId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _shearedToUserId = snapshotData['shearedToUserId'] as String?;
    _sharedId = snapshotData['sharedId'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('contentsShares')
          : FirebaseFirestore.instance.collectionGroup('contentsShares');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contentsShares').doc(id);

  static Stream<ContentsSharesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentsSharesModel.fromSnapshot(s));

  static Future<ContentsSharesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContentsSharesModel.fromSnapshot(s));

  static ContentsSharesModel fromSnapshot(DocumentSnapshot snapshot) =>
      ContentsSharesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentsSharesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentsSharesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentsSharesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentsSharesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentsSharesModelData({
  String? userId,
  String? shearedToUserId,
  DateTime? sharedId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'shearedToUserId': shearedToUserId,
      'sharedId': sharedId,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContentsSharesModelDocumentEquality
    implements Equality<ContentsSharesModel> {
  const ContentsSharesModelDocumentEquality();

  @override
  bool equals(ContentsSharesModel? e1, ContentsSharesModel? e2) {
    return e1?.userId == e2?.userId &&
        e1?.shearedToUserId == e2?.shearedToUserId &&
        e1?.sharedId == e2?.sharedId;
  }

  @override
  int hash(ContentsSharesModel? e) =>
      const ListEquality().hash([e?.userId, e?.shearedToUserId, e?.sharedId]);

  @override
  bool isValidKey(Object? o) => o is ContentsSharesModel;
}
