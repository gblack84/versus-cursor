import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class FeedDetailsRecord extends FirestoreRecord {
  FeedDetailsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "media_url" field.
  String? _mediaUrl;
  String get mediaUrl => _mediaUrl ?? '';
  bool hasMediaUrl() => _mediaUrl != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _mediaUrl = snapshotData['media_url'] as String?;
    _text = snapshotData['text'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('feed_details')
          : FirebaseFirestore.instance.collectionGroup('feed_details');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('feed_details').doc(id);

  static Stream<FeedDetailsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FeedDetailsRecord.fromSnapshot(s));

  static Future<FeedDetailsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FeedDetailsRecord.fromSnapshot(s));

  static FeedDetailsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FeedDetailsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FeedDetailsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FeedDetailsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FeedDetailsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FeedDetailsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFeedDetailsRecordData({
  String? mediaUrl,
  String? text,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'media_url': mediaUrl,
      'text': text,
    }.withoutNulls,
  );

  return firestoreData;
}

class FeedDetailsRecordDocumentEquality implements Equality<FeedDetailsRecord> {
  const FeedDetailsRecordDocumentEquality();

  @override
  bool equals(FeedDetailsRecord? e1, FeedDetailsRecord? e2) {
    return e1?.mediaUrl == e2?.mediaUrl && e1?.text == e2?.text;
  }

  @override
  int hash(FeedDetailsRecord? e) =>
      const ListEquality().hash([e?.mediaUrl, e?.text]);

  @override
  bool isValidKey(Object? o) => o is FeedDetailsRecord;
}
