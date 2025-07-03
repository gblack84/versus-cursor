import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class GroupMessagesRecord extends FirestoreRecord {
  GroupMessagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "g_message_id" field.
  String? _gMessageId;
  String get gMessageId => _gMessageId ?? '';
  bool hasGMessageId() => _gMessageId != null;

  // "g_sender_id" field.
  String? _gSenderId;
  String get gSenderId => _gSenderId ?? '';
  bool hasGSenderId() => _gSenderId != null;

  // "g_content" field.
  String? _gContent;
  String get gContent => _gContent ?? '';
  bool hasGContent() => _gContent != null;

  // "g_time_stamp" field.
  DateTime? _gTimeStamp;
  DateTime? get gTimeStamp => _gTimeStamp;
  bool hasGTimeStamp() => _gTimeStamp != null;

  // "g_attachment_url" field.
  String? _gAttachmentUrl;
  String get gAttachmentUrl => _gAttachmentUrl ?? '';
  bool hasGAttachmentUrl() => _gAttachmentUrl != null;

  // "g_is_read_by" field.
  List<String>? _gIsReadBy;
  List<String> get gIsReadBy => _gIsReadBy ?? const [];
  bool hasGIsReadBy() => _gIsReadBy != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _gMessageId = snapshotData['g_message_id'] as String?;
    _gSenderId = snapshotData['g_sender_id'] as String?;
    _gContent = snapshotData['g_content'] as String?;
    _gTimeStamp = snapshotData['g_time_stamp'] as DateTime?;
    _gAttachmentUrl = snapshotData['g_attachment_url'] as String?;
    _gIsReadBy = getDataList(snapshotData['g_is_read_by']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('group_messages')
          : FirebaseFirestore.instance.collectionGroup('group_messages');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('group_messages').doc(id);

  static Stream<GroupMessagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GroupMessagesRecord.fromSnapshot(s));

  static Future<GroupMessagesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GroupMessagesRecord.fromSnapshot(s));

  static GroupMessagesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      GroupMessagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GroupMessagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GroupMessagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GroupMessagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GroupMessagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGroupMessagesRecordData({
  String? gMessageId,
  String? gSenderId,
  String? gContent,
  DateTime? gTimeStamp,
  String? gAttachmentUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'g_message_id': gMessageId,
      'g_sender_id': gSenderId,
      'g_content': gContent,
      'g_time_stamp': gTimeStamp,
      'g_attachment_url': gAttachmentUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class GroupMessagesRecordDocumentEquality
    implements Equality<GroupMessagesRecord> {
  const GroupMessagesRecordDocumentEquality();

  @override
  bool equals(GroupMessagesRecord? e1, GroupMessagesRecord? e2) {
    const listEquality = ListEquality();
    return e1?.gMessageId == e2?.gMessageId &&
        e1?.gSenderId == e2?.gSenderId &&
        e1?.gContent == e2?.gContent &&
        e1?.gTimeStamp == e2?.gTimeStamp &&
        e1?.gAttachmentUrl == e2?.gAttachmentUrl &&
        listEquality.equals(e1?.gIsReadBy, e2?.gIsReadBy);
  }

  @override
  int hash(GroupMessagesRecord? e) => const ListEquality().hash([
        e?.gMessageId,
        e?.gSenderId,
        e?.gContent,
        e?.gTimeStamp,
        e?.gAttachmentUrl,
        e?.gIsReadBy
      ]);

  @override
  bool isValidKey(Object? o) => o is GroupMessagesRecord;
}
