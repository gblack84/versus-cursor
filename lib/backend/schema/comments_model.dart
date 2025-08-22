import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class CommentsModel extends FirestoreRecord {
  CommentsModel._(
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
    _postId = snapshotData['postId'] as String?;
    _userId = snapshotData['userId'] as String?;
    _content = snapshotData['content'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _parentCommentId = snapshotData['parentCommentId'] as String?;
    _isAnonymous = snapshotData['isAnonymous'] as bool?;
    _reportCount = castToType<int>(snapshotData['reportCount']);
    _reportedBy = getDataList(snapshotData['reportedBy']);
    _isBlocked = snapshotData['isBlocked'] as bool?;
    _premiumRequired = snapshotData['premiumRequired'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('comments');

  static Stream<CommentsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CommentsModel.fromSnapshot(s));

  static Future<CommentsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CommentsModel.fromSnapshot(s));

  static CommentsModel fromSnapshot(DocumentSnapshot snapshot) =>
      CommentsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CommentsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CommentsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CommentsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CommentsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCommentsModelData({
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
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'parentCommentId': parentCommentId,
      'isAnonymous': isAnonymous,
      'reportCount': reportCount,
      'isBlocked': isBlocked,
      'premiumRequired': premiumRequired,
    }.withoutNulls,
  );

  return firestoreData;
}

class CommentsModelDocumentEquality implements Equality<CommentsModel> {
  const CommentsModelDocumentEquality();

  @override
  bool equals(CommentsModel? e1, CommentsModel? e2) {
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
  int hash(CommentsModel? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is CommentsModel;
}
