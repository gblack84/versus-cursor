import 'dart:async';
import 'package:collection/collection.dart';
import '/core_exports.dart';

class ChatInterestJopsModel extends FirestoreRecord {
  ChatInterestJopsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "categoryA" field.
  String? _categoryA;
  String get categoryA => _categoryA ?? '';
  bool hasCategoryA() => _categoryA != null;

  // "categoryB" field.
  String? _categoryB;
  String get categoryB => _categoryB ?? '';
  bool hasCategoryB() => _categoryB != null;

  // "categoryC" field.
  String? _categoryC;
  String get categoryC => _categoryC ?? '';
  bool hasCategoryC() => _categoryC != null;

  // "timeStamp" field.
  DateTime? _timeStamp;
  DateTime? get timeStamp => _timeStamp;
  bool hasTimeStamp() => _timeStamp != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _categoryA = snapshotData['categoryA'] as String?;
    _categoryB = snapshotData['categoryB'] as String?;
    _categoryC = snapshotData['categoryC'] as String?;
    _timeStamp = snapshotData['timeStamp'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('chatInterestJops')
          : FirebaseFirestore.instance.collectionGroup('chatInterestJops');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('chatInterestJops').doc(id);

  static Stream<ChatInterestJopsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatInterestJopsModel.fromSnapshot(s));

  static Future<ChatInterestJopsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChatInterestJopsModel.fromSnapshot(s));

  static ChatInterestJopsModel fromSnapshot(DocumentSnapshot snapshot) =>
      ChatInterestJopsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatInterestJopsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatInterestJopsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatInterestJopsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatInterestJopsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatInterestJopsModelData({
  String? categoryA,
  String? categoryB,
  String? categoryC,
  DateTime? timeStamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'categoryA': categoryA,
      'categoryB': categoryB,
      'categoryC': categoryC,
      'timeStamp': timeStamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatInterestJopsModelDocumentEquality
    implements Equality<ChatInterestJopsModel> {
  const ChatInterestJopsModelDocumentEquality();

  @override
  bool equals(ChatInterestJopsModel? e1, ChatInterestJopsModel? e2) {
    return e1?.categoryA == e2?.categoryA &&
        e1?.categoryB == e2?.categoryB &&
        e1?.categoryC == e2?.categoryC &&
        e1?.timeStamp == e2?.timeStamp;
  }

  @override
  int hash(ChatInterestJopsModel? e) => const ListEquality()
      .hash([e?.categoryA, e?.categoryB, e?.categoryC, e?.timeStamp]);

  @override
  bool isValidKey(Object? o) => o is ChatInterestJopsModel;
}
