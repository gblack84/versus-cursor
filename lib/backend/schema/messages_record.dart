import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class MessagesRecord extends FirestoreRecord {
  MessagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "message_id" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  bool hasMessageId() => _messageId != null;

  // "sender_id" field.
  String? _senderId;
  String get senderId => _senderId ?? '';
  bool hasSenderId() => _senderId != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "attachment_url" field.
  String? _attachmentUrl;
  String get attachmentUrl => _attachmentUrl ?? '';
  bool hasAttachmentUrl() => _attachmentUrl != null;

  // "attachment_type" field.
  DateTime? _attachmentType;
  DateTime? get attachmentType => _attachmentType;
  bool hasAttachmentType() => _attachmentType != null;

  // "time_stamp" field.
  DateTime? _timeStamp;
  DateTime? get timeStamp => _timeStamp;
  bool hasTimeStamp() => _timeStamp != null;

  // "is_read" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _messageId = snapshotData['message_id'] as String?;
    _senderId = snapshotData['sender_id'] as String?;
    _content = snapshotData['content'] as String?;
    _attachmentUrl = snapshotData['attachment_url'] as String?;
    _attachmentType = snapshotData['attachment_type'] as DateTime?;
    _timeStamp = snapshotData['time_stamp'] as DateTime?;
    _isRead = snapshotData['is_read'] as bool?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('messages')
          : FirebaseFirestore.instance.collectionGroup('messages');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('messages').doc(id);

  static Stream<MessagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MessagesRecord.fromSnapshot(s));

  static Future<MessagesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MessagesRecord.fromSnapshot(s));

  static MessagesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MessagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MessagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MessagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MessagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MessagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMessagesRecordData({
  String? messageId,
  String? senderId,
  String? content,
  String? attachmentUrl,
  DateTime? attachmentType,
  DateTime? timeStamp,
  bool? isRead,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'message_id': messageId,
      'sender_id': senderId,
      'content': content,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'time_stamp': timeStamp,
      'is_read': isRead,
    }.withoutNulls,
  );

  return firestoreData;
}

class MessagesRecordDocumentEquality implements Equality<MessagesRecord> {
  const MessagesRecordDocumentEquality();

  @override
  bool equals(MessagesRecord? e1, MessagesRecord? e2) {
    return e1?.messageId == e2?.messageId &&
        e1?.senderId == e2?.senderId &&
        e1?.content == e2?.content &&
        e1?.attachmentUrl == e2?.attachmentUrl &&
        e1?.attachmentType == e2?.attachmentType &&
        e1?.timeStamp == e2?.timeStamp &&
        e1?.isRead == e2?.isRead;
  }

  @override
  int hash(MessagesRecord? e) => const ListEquality().hash([
        e?.messageId,
        e?.senderId,
        e?.content,
        e?.attachmentUrl,
        e?.attachmentType,
        e?.timeStamp,
        e?.isRead
      ]);

  @override
  bool isValidKey(Object? o) => o is MessagesRecord;
}
