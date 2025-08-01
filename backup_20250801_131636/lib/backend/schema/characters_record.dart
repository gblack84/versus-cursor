import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class CharactersRecord extends FirestoreRecord {
  CharactersRecord._(
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

  static Stream<CharactersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CharactersRecord.fromSnapshot(s));

  static Future<CharactersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CharactersRecord.fromSnapshot(s));

  static CharactersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CharactersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CharactersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CharactersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CharactersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CharactersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCharactersRecordData({
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

class CharactersRecordDocumentEquality implements Equality<CharactersRecord> {
  const CharactersRecordDocumentEquality();

  @override
  bool equals(CharactersRecord? e1, CharactersRecord? e2) {
    return e1?.charactersName == e2?.charactersName &&
        e1?.charactersImageUrl == e2?.charactersImageUrl;
  }

  @override
  int hash(CharactersRecord? e) =>
      const ListEquality().hash([e?.charactersName, e?.charactersImageUrl]);

  @override
  bool isValidKey(Object? o) => o is CharactersRecord;
}
