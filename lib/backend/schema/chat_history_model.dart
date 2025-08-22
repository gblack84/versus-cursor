import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class ChatHistoryModel extends FirestoreRecord {
  ChatHistoryModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "rolChat" field.
  String? _rolChat;
  String get rolChat => _rolChat ?? '';
  bool hasRolChat() => _rolChat != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "timeStamp" field.
  DateTime? _timeStamp;
  DateTime? get timeStamp => _timeStamp;
  bool hasTimeStamp() => _timeStamp != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _rolChat = snapshotData['rolChat'] as String?;
    _content = snapshotData['content'] as String?;
    _timeStamp = snapshotData['timeStamp'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('chatHistory')
          : FirebaseFirestore.instance.collectionGroup('chatHistory');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('chatHistory').doc(id);

  static Stream<ChatHistoryModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatHistoryModel.fromSnapshot(s));

  static Future<ChatHistoryModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChatHistoryModel.fromSnapshot(s));

  static ChatHistoryModel fromSnapshot(DocumentSnapshot snapshot) =>
      ChatHistoryModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatHistoryModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatHistoryModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatHistoryModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatHistoryModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatHistoryModelData({
  String? rolChat,
  String? content,
  DateTime? timeStamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'rolChat': rolChat,
      'content': content,
      'timeStamp': timeStamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatHistoryModelDocumentEquality implements Equality<ChatHistoryModel> {
  const ChatHistoryModelDocumentEquality();

  @override
  bool equals(ChatHistoryModel? e1, ChatHistoryModel? e2) {
    return e1?.rolChat == e2?.rolChat &&
        e1?.content == e2?.content &&
        e1?.timeStamp == e2?.timeStamp;
  }

  @override
  int hash(ChatHistoryModel? e) =>
      const ListEquality().hash([e?.rolChat, e?.content, e?.timeStamp]);

  @override
  bool isValidKey(Object? o) => o is ChatHistoryModel;
}
