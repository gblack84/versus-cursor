import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core_exports.dart';

class ImagesModel extends FirestoreRecord {
  ImagesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "url" field.
  String? _url;
  String get url => _url ?? '';
  bool hasUrl() => _url != null;

  // "option" field.
  int? _option;
  int get option => _option ?? 0;
  bool hasOption() => _option != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _url = snapshotData['url'] as String?;
    _option = castToType<int>(snapshotData['option']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('images')
          : FirebaseFirestore.instance.collectionGroup('images');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('images').doc(id);

  static Stream<ImagesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ImagesModel.fromSnapshot(s));

  static Future<ImagesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ImagesModel.fromSnapshot(s));

  static ImagesModel fromSnapshot(DocumentSnapshot snapshot) => ImagesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ImagesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ImagesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ImagesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ImagesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createImagesModelData({
  String? url,
  int? option,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'url': url,
      'option': option,
    }.withoutNulls,
  );

  return firestoreData;
}

class ImagesModelDocumentEquality implements Equality<ImagesModel> {
  const ImagesModelDocumentEquality();

  @override
  bool equals(ImagesModel? e1, ImagesModel? e2) {
    return e1?.url == e2?.url && e1?.option == e2?.option;
  }

  @override
  int hash(ImagesModel? e) => const ListEquality().hash([e?.url, e?.option]);

  @override
  bool isValidKey(Object? o) => o is ImagesModel;
}
