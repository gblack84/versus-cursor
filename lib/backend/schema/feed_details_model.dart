import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import '/core_exports.dart';

class FeedDetailsModel extends FirestoreRecord {
  FeedDetailsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "mediaUrl" field.
  String? _mediaUrl;
  String get mediaUrl => _mediaUrl ?? '';
  bool hasMediaUrl() => _mediaUrl != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _mediaUrl = snapshotData['mediaUrl'] as String?;
    _text = snapshotData['text'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('feedDetails')
          : FirebaseFirestore.instance.collectionGroup('feedDetails');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('feedDetails').doc(id);

  static Stream<FeedDetailsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FeedDetailsModel.fromSnapshot(s));

  static Future<FeedDetailsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FeedDetailsModel.fromSnapshot(s));

  static FeedDetailsModel fromSnapshot(DocumentSnapshot snapshot) =>
      FeedDetailsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FeedDetailsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FeedDetailsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FeedDetailsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FeedDetailsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFeedDetailsModelData({
  String? mediaUrl,
  String? text,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'mediaUrl': mediaUrl,
      'text': text,
    }.withoutNulls,
  );

  return firestoreData;
}

class FeedDetailsModelDocumentEquality implements Equality<FeedDetailsModel> {
  const FeedDetailsModelDocumentEquality();

  @override
  bool equals(FeedDetailsModel? e1, FeedDetailsModel? e2) {
    return e1?.mediaUrl == e2?.mediaUrl && e1?.text == e2?.text;
  }

  @override
  int hash(FeedDetailsModel? e) =>
      const ListEquality().hash([e?.mediaUrl, e?.text]);

  @override
  bool isValidKey(Object? o) => o is FeedDetailsModel;
}
