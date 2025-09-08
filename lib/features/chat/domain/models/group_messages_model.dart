import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';
import '/core/firebase/utils/schema_util.dart';

import '/core_exports.dart';

class GroupMessagesModel extends FirestoreRecord {
  GroupMessagesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "gMessageId" field.
  String? _gMessageId;
  String get gMessageId => _gMessageId ?? '';
  bool hasGMessageId() => _gMessageId != null;

  // "gSenderId" field.
  String? _gSenderId;
  String get gSenderId => _gSenderId ?? '';
  bool hasGSenderId() => _gSenderId != null;

  // "gContent" field.
  String? _gContent;
  String get gContent => _gContent ?? '';
  bool hasGContent() => _gContent != null;

  // "gTimeStamp" field.
  DateTime? _gTimeStamp;
  DateTime? get gTimeStamp => _gTimeStamp;
  bool hasGTimeStamp() => _gTimeStamp != null;

  // "gAttachmentUrl" field.
  String? _gAttachmentUrl;
  String get gAttachmentUrl => _gAttachmentUrl ?? '';
  bool hasGAttachmentUrl() => _gAttachmentUrl != null;

  // "gIsReadBy" field.
  List<String>? _gIsReadBy;
  List<String> get gIsReadBy => _gIsReadBy ?? const [];
  bool hasGIsReadBy() => _gIsReadBy != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _gMessageId = snapshotData['gMessageId'] as String?;
    _gSenderId = snapshotData['gSenderId'] as String?;
    _gContent = snapshotData['gContent'] as String?;
    _gTimeStamp = snapshotData['gTimeStamp'] as DateTime?;
    _gAttachmentUrl = snapshotData['gAttachmentUrl'] as String?;
    _gIsReadBy = getDataList(snapshotData['gIsReadBy']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('groupMessages')
          : FirebaseFirestore.instance.collectionGroup('groupMessages');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('groupMessages').doc(id);

  static Stream<GroupMessagesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GroupMessagesModel.fromSnapshot(s));

  static Future<GroupMessagesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GroupMessagesModel.fromSnapshot(s));

  static GroupMessagesModel fromSnapshot(DocumentSnapshot snapshot) =>
      GroupMessagesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GroupMessagesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GroupMessagesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GroupMessagesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GroupMessagesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGroupMessagesModelData({
  String? gMessageId,
  String? gSenderId,
  String? gContent,
  DateTime? gTimeStamp,
  String? gAttachmentUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'gMessageId': gMessageId,
      'gSenderId': gSenderId,
      'gContent': gContent,
      'gTimeStamp': gTimeStamp,
      'gAttachmentUrl': gAttachmentUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class GroupMessagesModelDocumentEquality
    implements Equality<GroupMessagesModel> {
  const GroupMessagesModelDocumentEquality();

  @override
  bool equals(GroupMessagesModel? e1, GroupMessagesModel? e2) {
    const listEquality = ListEquality();
    return e1?.gMessageId == e2?.gMessageId &&
        e1?.gSenderId == e2?.gSenderId &&
        e1?.gContent == e2?.gContent &&
        e1?.gTimeStamp == e2?.gTimeStamp &&
        e1?.gAttachmentUrl == e2?.gAttachmentUrl &&
        listEquality.equals(e1?.gIsReadBy, e2?.gIsReadBy);
  }

  @override
  int hash(GroupMessagesModel? e) => const ListEquality().hash([
        e?.gMessageId,
        e?.gSenderId,
        e?.gContent,
        e?.gTimeStamp,
        e?.gAttachmentUrl,
        e?.gIsReadBy
      ]);

  @override
  bool isValidKey(Object? o) => o is GroupMessagesModel;
}
