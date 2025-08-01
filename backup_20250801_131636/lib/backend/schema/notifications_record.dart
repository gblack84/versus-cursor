import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class NotificationsRecord extends FirestoreRecord {
  NotificationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "notification_id" field.
  String? _notificationId;
  String get notificationId => _notificationId ?? '';
  bool hasNotificationId() => _notificationId != null;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "source_id" field.
  String? _sourceId;
  String get sourceId => _sourceId ?? '';
  bool hasSourceId() => _sourceId != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "read" field.
  bool? _read;
  bool get read => _read ?? false;
  bool hasRead() => _read != null;

  // "target_audience" field.
  List<String>? _targetAudience;
  List<String> get targetAudience => _targetAudience ?? const [];
  bool hasTargetAudience() => _targetAudience != null;

  // "expiry_time" field.
  DateTime? _expiryTime;
  DateTime? get expiryTime => _expiryTime;
  bool hasExpiryTime() => _expiryTime != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "interaction_type" field.
  String? _interactionType;
  String get interactionType => _interactionType ?? '';
  bool hasInteractionType() => _interactionType != null;

  void _initializeFields() {
    _notificationId = snapshotData['notification_id'] as String?;
    _userId = snapshotData['user_id'] as String?;
    _type = snapshotData['type'] as String?;
    _sourceId = snapshotData['source_id'] as String?;
    _content = snapshotData['content'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _read = snapshotData['read'] as bool?;
    _targetAudience = getDataList(snapshotData['target_audience']);
    _expiryTime = snapshotData['expiry_time'] as DateTime?;
    _location = snapshotData['location'] as LatLng?;
    _interactionType = snapshotData['interaction_type'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsRecord.fromSnapshot(s));

  static Future<NotificationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsRecord.fromSnapshot(s));

  static NotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationsRecordData({
  String? notificationId,
  String? userId,
  String? type,
  String? sourceId,
  String? content,
  DateTime? createdAt,
  bool? read,
  DateTime? expiryTime,
  LatLng? location,
  String? interactionType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'notification_id': notificationId,
      'user_id': userId,
      'type': type,
      'source_id': sourceId,
      'content': content,
      'created_at': createdAt,
      'read': read,
      'expiry_time': expiryTime,
      'location': location,
      'interaction_type': interactionType,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationsRecordDocumentEquality
    implements Equality<NotificationsRecord> {
  const NotificationsRecordDocumentEquality();

  @override
  bool equals(NotificationsRecord? e1, NotificationsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.notificationId == e2?.notificationId &&
        e1?.userId == e2?.userId &&
        e1?.type == e2?.type &&
        e1?.sourceId == e2?.sourceId &&
        e1?.content == e2?.content &&
        e1?.createdAt == e2?.createdAt &&
        e1?.read == e2?.read &&
        listEquality.equals(e1?.targetAudience, e2?.targetAudience) &&
        e1?.expiryTime == e2?.expiryTime &&
        e1?.location == e2?.location &&
        e1?.interactionType == e2?.interactionType;
  }

  @override
  int hash(NotificationsRecord? e) => const ListEquality().hash([
        e?.notificationId,
        e?.userId,
        e?.type,
        e?.sourceId,
        e?.content,
        e?.createdAt,
        e?.read,
        e?.targetAudience,
        e?.expiryTime,
        e?.location,
        e?.interactionType
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsRecord;
}
