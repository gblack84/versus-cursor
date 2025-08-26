import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core_exports.dart';

class CharactersModel extends FirestoreRecord {
  CharactersModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "CharactersName" field.
  String? _charactersName;
  String get charactersName => _charactersName ?? '';
  bool hasCharactersName() => _charactersName != null;

  // "CharactersImageUrl" field.
  String? _charactersImageUrl;
  String get charactersImageUrl => _charactersImageUrl ?? '';
  bool hasCharactersImageUrl() => _charactersImageUrl != null;

  void _initializeFields() {
    _charactersName = snapshotData['CharactersName'] as String?;
    _charactersImageUrl = snapshotData['CharactersImageUrl'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('characters');

  static Stream<CharactersModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CharactersModel.fromSnapshot(s));

  static Future<CharactersModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CharactersModel.fromSnapshot(s));

  static CharactersModel fromSnapshot(DocumentSnapshot snapshot) =>
      CharactersModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CharactersModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CharactersModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CharactersModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CharactersModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCharactersModelData({
  String? charactersName,
  String? charactersImageUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'CharactersName': charactersName,
      'CharactersImageUrl': charactersImageUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class CharactersModelDocumentEquality implements Equality<CharactersModel> {
  const CharactersModelDocumentEquality();

  @override
  bool equals(CharactersModel? e1, CharactersModel? e2) {
    return e1?.charactersName == e2?.charactersName &&
        e1?.charactersImageUrl == e2?.charactersImageUrl;
  }

  @override
  int hash(CharactersModel? e) =>
      const ListEquality().hash([e?.charactersName, e?.charactersImageUrl]);

  @override
  bool isValidKey(Object? o) => o is CharactersModel;
}
