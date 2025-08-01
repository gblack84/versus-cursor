import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class ContentCommentsModel extends FirestoreRecord {
  ContentCommentsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "comment_id" field.
  String? _commentId;
  String get commentId => _commentId ?? '';
  bool hasCommentId() => _commentId != null;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "is_premium" field.
  bool? _isPremium;
  bool get isPremium => _isPremium ?? false;
  bool hasIsPremium() => _isPremium != null;

  // "likes_count" field.
  int? _likesCount;
  int get likesCount => _likesCount ?? 0;
  bool hasLikesCount() => _likesCount != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _commentId = snapshotData['comment_id'] as String?;
    _userId = snapshotData['user_id'] as String?;
    _text = snapshotData['text'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _isPremium = snapshotData['is_premium'] as bool?;
    _likesCount = castToType<int>(snapshotData['likes_count']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('content_comments')
          : FirebaseFirestore.instance.collectionGroup('content_comments');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('content_comments').doc(id);

  static Stream<ContentCommentsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentCommentsModel.fromSnapshot(s));

  static Future<ContentCommentsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContentCommentsModel.fromSnapshot(s));

  static ContentCommentsModel fromSnapshot(DocumentSnapshot snapshot) =>
      ContentCommentsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentCommentsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentCommentsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentCommentsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentCommentsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentCommentsModelData({
  String? commentId,
  String? userId,
  String? text,
  DateTime? createdAt,
  bool? isPremium,
  int? likesCount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'comment_id': commentId,
      'user_id': userId,
      'text': text,
      'created_at': createdAt,
      'is_premium': isPremium,
      'likes_count': likesCount,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContentCommentsModelDocumentEquality
    implements Equality<ContentCommentsModel> {
  const ContentCommentsModelDocumentEquality();

  @override
  bool equals(ContentCommentsModel? e1, ContentCommentsModel? e2) {
    return e1?.commentId == e2?.commentId &&
        e1?.userId == e2?.userId &&
        e1?.text == e2?.text &&
        e1?.createdAt == e2?.createdAt &&
        e1?.isPremium == e2?.isPremium &&
        e1?.likesCount == e2?.likesCount;
  }

  @override
  int hash(ContentCommentsModel? e) => const ListEquality().hash([
        e?.commentId,
        e?.userId,
        e?.text,
        e?.createdAt,
        e?.isPremium,
        e?.likesCount
      ]);

  @override
  bool isValidKey(Object? o) => o is ContentCommentsModel;
}
