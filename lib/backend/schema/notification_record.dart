import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class NotificationRecord extends FirestoreRecord {
  NotificationRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "maxNotificationsPerDay" field.
  int? _maxNotificationsPerDay;
  int get maxNotificationsPerDay => _maxNotificationsPerDay ?? 0;
  bool hasMaxNotificationsPerDay() => _maxNotificationsPerDay != null;

  // "receiveQuestionNotifications" field.
  bool? _receiveQuestionNotifications;
  bool get receiveQuestionNotifications =>
      _receiveQuestionNotifications ?? false;
  bool hasReceiveQuestionNotifications() =>
      _receiveQuestionNotifications != null;

  // "receiveResultNotifications" field.
  bool? _receiveResultNotifications;
  bool get receiveResultNotifications => _receiveResultNotifications ?? false;
  bool hasReceiveResultNotifications() => _receiveResultNotifications != null;

  // "receiveCommentNotifications" field.
  bool? _receiveCommentNotifications;
  bool get receiveCommentNotifications => _receiveCommentNotifications ?? false;
  bool hasReceiveCommentNotifications() => _receiveCommentNotifications != null;

  // "receiveFollowNotifications" field.
  bool? _receiveFollowNotifications;
  bool get receiveFollowNotifications => _receiveFollowNotifications ?? false;
  bool hasReceiveFollowNotifications() => _receiveFollowNotifications != null;

  // "receiveMessageNotifications" field.
  bool? _receiveMessageNotifications;
  bool get receiveMessageNotifications => _receiveMessageNotifications ?? false;
  bool hasReceiveMessageNotifications() => _receiveMessageNotifications != null;

  // "notificationTimeWindows" field.
  List<String>? _notificationTimeWindows;
  List<String> get notificationTimeWindows =>
      _notificationTimeWindows ?? const [];
  bool hasNotificationTimeWindows() => _notificationTimeWindows != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _maxNotificationsPerDay =
        castToType<int>(snapshotData['maxNotificationsPerDay']);
    _receiveQuestionNotifications =
        snapshotData['receiveQuestionNotifications'] as bool?;
    _receiveResultNotifications =
        snapshotData['receiveResultNotifications'] as bool?;
    _receiveCommentNotifications =
        snapshotData['receiveCommentNotifications'] as bool?;
    _receiveFollowNotifications =
        snapshotData['receiveFollowNotifications'] as bool?;
    _receiveMessageNotifications =
        snapshotData['receiveMessageNotifications'] as bool?;
    _notificationTimeWindows =
        getDataList(snapshotData['notificationTimeWindows']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('notification')
          : FirebaseFirestore.instance.collectionGroup('notification');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('notification').doc(id);

  static Stream<NotificationRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationRecord.fromSnapshot(s));

  static Future<NotificationRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationRecord.fromSnapshot(s));

  static NotificationRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationRecordData({
  int? maxNotificationsPerDay,
  bool? receiveQuestionNotifications,
  bool? receiveResultNotifications,
  bool? receiveCommentNotifications,
  bool? receiveFollowNotifications,
  bool? receiveMessageNotifications,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'maxNotificationsPerDay': maxNotificationsPerDay,
      'receiveQuestionNotifications': receiveQuestionNotifications,
      'receiveResultNotifications': receiveResultNotifications,
      'receiveCommentNotifications': receiveCommentNotifications,
      'receiveFollowNotifications': receiveFollowNotifications,
      'receiveMessageNotifications': receiveMessageNotifications,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationRecordDocumentEquality
    implements Equality<NotificationRecord> {
  const NotificationRecordDocumentEquality();

  @override
  bool equals(NotificationRecord? e1, NotificationRecord? e2) {
    const listEquality = ListEquality();
    return e1?.maxNotificationsPerDay == e2?.maxNotificationsPerDay &&
        e1?.receiveQuestionNotifications == e2?.receiveQuestionNotifications &&
        e1?.receiveResultNotifications == e2?.receiveResultNotifications &&
        e1?.receiveCommentNotifications == e2?.receiveCommentNotifications &&
        e1?.receiveFollowNotifications == e2?.receiveFollowNotifications &&
        e1?.receiveMessageNotifications == e2?.receiveMessageNotifications &&
        listEquality.equals(
            e1?.notificationTimeWindows, e2?.notificationTimeWindows);
  }

  @override
  int hash(NotificationRecord? e) => const ListEquality().hash([
        e?.maxNotificationsPerDay,
        e?.receiveQuestionNotifications,
        e?.receiveResultNotifications,
        e?.receiveCommentNotifications,
        e?.receiveFollowNotifications,
        e?.receiveMessageNotifications,
        e?.notificationTimeWindows
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationRecord;
}
