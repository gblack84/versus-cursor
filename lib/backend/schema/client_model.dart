import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class ClientModel extends FirestoreRecord {
  ClientModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "versus_image" field.
  String? _versusImage;
  String get versusImage => _versusImage ?? '';
  bool hasVersusImage() => _versusImage != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _versusImage = snapshotData['versus_image'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('client');

  static Stream<ClientModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClientModel.fromSnapshot(s));

  static Future<ClientModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClientModel.fromSnapshot(s));

  static ClientModel fromSnapshot(DocumentSnapshot snapshot) => ClientModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClientModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClientModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClientModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClientModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClientModelData({
  String? uid,
  String? versusImage,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'versus_image': versusImage,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClientModelDocumentEquality implements Equality<ClientModel> {
  const ClientModelDocumentEquality();

  @override
  bool equals(ClientModel? e1, ClientModel? e2) {
    return e1?.uid == e2?.uid && e1?.versusImage == e2?.versusImage;
  }

  @override
  int hash(ClientModel? e) =>
      const ListEquality().hash([e?.uid, e?.versusImage]);

  @override
  bool isValidKey(Object? o) => o is ClientModel;
}
