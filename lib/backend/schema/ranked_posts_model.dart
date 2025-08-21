import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class RankedPostsModel extends FirestoreRecord {
  RankedPostsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "post_id" field.
  String? _postId;
  String get postId => _postId ?? '';
  bool hasPostId() => _postId != null;

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  bool hasScore() => _score != null;

  // "rank" field.
  int? _rank;
  int get rank => _rank ?? 0;
  bool hasRank() => _rank != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "view_count" field.
  int? _viewCount;
  int get viewCount => _viewCount ?? 0;
  bool hasViewCount() => _viewCount != null;

  // "like_count" field.
  int? _likeCount;
  int get likeCount => _likeCount ?? 0;
  bool hasLikeCount() => _likeCount != null;

  // "comment_count" field.
  int? _commentCount;
  int get commentCount => _commentCount ?? 0;
  bool hasCommentCount() => _commentCount != null;

  // "interest_count" field.
  int? _interestCount;
  int get interestCount => _interestCount ?? 0;
  bool hasInterestCount() => _interestCount != null;

  // "share_count" field.
  int? _shareCount;
  int get shareCount => _shareCount ?? 0;
  bool hasShareCount() => _shareCount != null;

  // "content_type" field.
  String? _contentType;
  String get contentType => _contentType ?? '';
  bool hasContentType() => _contentType != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _postId = snapshotData['post_id'] as String?;
    _score = castToType<int>(snapshotData['score']);
    _rank = castToType<int>(snapshotData['rank']);
    _category = snapshotData['category'] as String?;
    _title = snapshotData['title'] as String?;
    _viewCount = castToType<int>(snapshotData['view_count']);
    _likeCount = castToType<int>(snapshotData['like_count']);
    _commentCount = castToType<int>(snapshotData['comment_count']);
    _interestCount = castToType<int>(snapshotData['interest_count']);
    _shareCount = castToType<int>(snapshotData['share_count']);
    _contentType = snapshotData['content_type'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('rankedPosts')
          : FirebaseFirestore.instance.collectionGroup('ranked_posts');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('rankedPosts').doc(id);

  static Stream<RankedPostsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RankedPostsModel.fromSnapshot(s));

  static Future<RankedPostsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RankedPostsModel.fromSnapshot(s));

  static RankedPostsModel fromSnapshot(DocumentSnapshot snapshot) =>
      RankedPostsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RankedPostsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RankedPostsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RankedPostsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RankedPostsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRankedPostsModelData({
  String? postId,
  int? score,
  int? rank,
  String? category,
  String? title,
  int? viewCount,
  int? likeCount,
  int? commentCount,
  int? interestCount,
  int? shareCount,
  String? contentType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'post_id': postId,
      'score': score,
      'rank': rank,
      'category': category,
      'title': title,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'interest_count': interestCount,
      'share_count': shareCount,
      'content_type': contentType,
    }.withoutNulls,
  );

  return firestoreData;
}

class RankedPostsModelDocumentEquality implements Equality<RankedPostsModel> {
  const RankedPostsModelDocumentEquality();

  @override
  bool equals(RankedPostsModel? e1, RankedPostsModel? e2) {
    return e1?.postId == e2?.postId &&
        e1?.score == e2?.score &&
        e1?.rank == e2?.rank &&
        e1?.category == e2?.category &&
        e1?.title == e2?.title &&
        e1?.viewCount == e2?.viewCount &&
        e1?.likeCount == e2?.likeCount &&
        e1?.commentCount == e2?.commentCount &&
        e1?.interestCount == e2?.interestCount &&
        e1?.shareCount == e2?.shareCount &&
        e1?.contentType == e2?.contentType;
  }

  @override
  int hash(RankedPostsModel? e) => const ListEquality().hash([
        e?.postId,
        e?.score,
        e?.rank,
        e?.category,
        e?.title,
        e?.viewCount,
        e?.likeCount,
        e?.commentCount,
        e?.interestCount,
        e?.shareCount,
        e?.contentType
      ]);

  @override
  bool isValidKey(Object? o) => o is RankedPostsModel;
}
