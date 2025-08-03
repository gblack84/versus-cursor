import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class NotificationsModel extends FirestoreRecord {
  NotificationsModel._(
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

  // NEW: Extended notification fields
  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "completed_at" field.
  DateTime? _completedAt;
  DateTime? get completedAt => _completedAt;
  bool hasCompletedAt() => _completedAt != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "action_url" field.
  String? _actionUrl;
  String get actionUrl => _actionUrl ?? '';
  bool hasActionUrl() => _actionUrl != null;

  // "priority" field.
  String? _priority;
  String get priority => _priority ?? 'normal';
  bool hasPriority() => _priority != null;

  // "source_type" field.
  String? _sourceType;
  String get sourceType => _sourceType ?? '';
  bool hasSourceType() => _sourceType != null;

  // Structured content from JSON
  Map<String, dynamic>? _postData;
  Map<String, dynamic> get postData => _postData ?? const {};
  bool hasPostData() => _postData != null;

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
    
    // Initialize extended fields
    _status = snapshotData['status'] as String?;
    _completedAt = snapshotData['completedAt'] as DateTime? ?? snapshotData['completed_at'] as DateTime?;
    _title = snapshotData['title'] as String?;
    _message = snapshotData['message'] as String?;
    _imageUrl = snapshotData['imageUrl'] as String? ?? snapshotData['image_url'] as String?;
    _actionUrl = snapshotData['actionUrl'] as String? ?? snapshotData['action_url'] as String?;
    _priority = snapshotData['priority'] as String?;
    _sourceType = snapshotData['sourceType'] as String? ?? snapshotData['source_type'] as String?;
    
    // Parse JSON content if present
    if (_content != null) {
      try {
        final parsed = json.decode(_content!);
        if (parsed is Map<String, dynamic> && parsed.containsKey('postData')) {
          _postData = parsed['postData'] as Map<String, dynamic>?;
        }
      } catch (e) {
        // If content is not valid JSON, keep it as string
      }
    }
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsModel.fromSnapshot(s));

  static Future<NotificationsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsModel.fromSnapshot(s));

  static NotificationsModel fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationsModelData({
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
  String? status,
  DateTime? completedAt,
  String? title,
  String? message,
  String? imageUrl,
  String? actionUrl,
  String? priority,
  String? sourceType,
  Map<String, dynamic>? postData,
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
      'status': status,
      'completed_at': completedAt,
      'title': title,
      'message': message,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'priority': priority,
      'source_type': sourceType,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationsModelDocumentEquality
    implements Equality<NotificationsModel> {
  const NotificationsModelDocumentEquality();

  @override
  bool equals(NotificationsModel? e1, NotificationsModel? e2) {
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
        e1?.interactionType == e2?.interactionType &&
        e1?.status == e2?.status &&
        e1?.completedAt == e2?.completedAt &&
        e1?.title == e2?.title &&
        e1?.message == e2?.message &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.actionUrl == e2?.actionUrl &&
        e1?.priority == e2?.priority &&
        e1?.sourceType == e2?.sourceType;
  }

  @override
  int hash(NotificationsModel? e) => const ListEquality().hash([
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
        e?.interactionType,
        e?.status,
        e?.completedAt,
        e?.title,
        e?.message,
        e?.imageUrl,
        e?.actionUrl,
        e?.priority,
        e?.sourceType
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsModel;
}
