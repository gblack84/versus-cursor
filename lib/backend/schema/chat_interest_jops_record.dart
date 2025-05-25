import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatInterestJopsRecord extends FirestoreRecord {
  ChatInterestJopsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Category_A" field.
  String? _categoryA;
  String get categoryA => _categoryA ?? '';
  bool hasCategoryA() => _categoryA != null;

  // "Category_B" field.
  String? _categoryB;
  String get categoryB => _categoryB ?? '';
  bool hasCategoryB() => _categoryB != null;

  // "Category_C" field.
  String? _categoryC;
  String get categoryC => _categoryC ?? '';
  bool hasCategoryC() => _categoryC != null;

  // "Time_Stamp" field.
  DateTime? _timeStamp;
  DateTime? get timeStamp => _timeStamp;
  bool hasTimeStamp() => _timeStamp != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _categoryA = snapshotData['Category_A'] as String?;
    _categoryB = snapshotData['Category_B'] as String?;
    _categoryC = snapshotData['Category_C'] as String?;
    _timeStamp = snapshotData['Time_Stamp'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Chat_interest_jops')
          : FirebaseFirestore.instance.collectionGroup('Chat_interest_jops');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Chat_interest_jops').doc(id);

  static Stream<ChatInterestJopsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatInterestJopsRecord.fromSnapshot(s));

  static Future<ChatInterestJopsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ChatInterestJopsRecord.fromSnapshot(s));

  static ChatInterestJopsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ChatInterestJopsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatInterestJopsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatInterestJopsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatInterestJopsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatInterestJopsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatInterestJopsRecordData({
  String? categoryA,
  String? categoryB,
  String? categoryC,
  DateTime? timeStamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Category_A': categoryA,
      'Category_B': categoryB,
      'Category_C': categoryC,
      'Time_Stamp': timeStamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatInterestJopsRecordDocumentEquality
    implements Equality<ChatInterestJopsRecord> {
  const ChatInterestJopsRecordDocumentEquality();

  @override
  bool equals(ChatInterestJopsRecord? e1, ChatInterestJopsRecord? e2) {
    return e1?.categoryA == e2?.categoryA &&
        e1?.categoryB == e2?.categoryB &&
        e1?.categoryC == e2?.categoryC &&
        e1?.timeStamp == e2?.timeStamp;
  }

  @override
  int hash(ChatInterestJopsRecord? e) => const ListEquality()
      .hash([e?.categoryA, e?.categoryB, e?.categoryC, e?.timeStamp]);

  @override
  bool isValidKey(Object? o) => o is ChatInterestJopsRecord;
}
