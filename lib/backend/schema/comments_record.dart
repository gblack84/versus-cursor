import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CommentsRecord extends FirestoreRecord {
  CommentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "post_id" field.
  String? _postId;
  String get postId => _postId ?? '';
  bool hasPostId() => _postId != null;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "parent_comment_id" field.
  String? _parentCommentId;
  String get parentCommentId => _parentCommentId ?? '';
  bool hasParentCommentId() => _parentCommentId != null;

  // "is_anonymous" field.
  bool? _isAnonymous;
  bool get isAnonymous => _isAnonymous ?? false;
  bool hasIsAnonymous() => _isAnonymous != null;

  // "report_count" field.
  int? _reportCount;
  int get reportCount => _reportCount ?? 0;
  bool hasReportCount() => _reportCount != null;

  // "reported_by" field.
  List<String>? _reportedBy;
  List<String> get reportedBy => _reportedBy ?? const [];
  bool hasReportedBy() => _reportedBy != null;

  // "is_blocked" field.
  bool? _isBlocked;
  bool get isBlocked => _isBlocked ?? false;
  bool hasIsBlocked() => _isBlocked != null;

  // "premium_required" field.
  bool? _premiumRequired;
  bool get premiumRequired => _premiumRequired ?? false;
  bool hasPremiumRequired() => _premiumRequired != null;

  void _initializeFields() {
    _postId = snapshotData['post_id'] as String?;
    _userId = snapshotData['user_id'] as String?;
    _content = snapshotData['content'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _parentCommentId = snapshotData['parent_comment_id'] as String?;
    _isAnonymous = snapshotData['is_anonymous'] as bool?;
    _reportCount = castToType<int>(snapshotData['report_count']);
    _reportedBy = getDataList(snapshotData['reported_by']);
    _isBlocked = snapshotData['is_blocked'] as bool?;
    _premiumRequired = snapshotData['premium_required'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('comments');

  static Stream<CommentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CommentsRecord.fromSnapshot(s));

  static Future<CommentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CommentsRecord.fromSnapshot(s));

  static CommentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CommentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CommentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CommentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CommentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CommentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCommentsRecordData({
  String? postId,
  String? userId,
  String? content,
  DateTime? createdAt,
  String? parentCommentId,
  bool? isAnonymous,
  int? reportCount,
  bool? isBlocked,
  bool? premiumRequired,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt,
      'parent_comment_id': parentCommentId,
      'is_anonymous': isAnonymous,
      'report_count': reportCount,
      'is_blocked': isBlocked,
      'premium_required': premiumRequired,
    }.withoutNulls,
  );

  return firestoreData;
}

class CommentsRecordDocumentEquality implements Equality<CommentsRecord> {
  const CommentsRecordDocumentEquality();

  @override
  bool equals(CommentsRecord? e1, CommentsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.postId == e2?.postId &&
        e1?.userId == e2?.userId &&
        e1?.content == e2?.content &&
        e1?.createdAt == e2?.createdAt &&
        e1?.parentCommentId == e2?.parentCommentId &&
        e1?.isAnonymous == e2?.isAnonymous &&
        e1?.reportCount == e2?.reportCount &&
        listEquality.equals(e1?.reportedBy, e2?.reportedBy) &&
        e1?.isBlocked == e2?.isBlocked &&
        e1?.premiumRequired == e2?.premiumRequired;
  }

  @override
  int hash(CommentsRecord? e) => const ListEquality().hash([
        e?.postId,
        e?.userId,
        e?.content,
        e?.createdAt,
        e?.parentCommentId,
        e?.isAnonymous,
        e?.reportCount,
        e?.reportedBy,
        e?.isBlocked,
        e?.premiumRequired
      ]);

  @override
  bool isValidKey(Object? o) => o is CommentsRecord;
}
