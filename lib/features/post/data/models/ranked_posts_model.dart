import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';

import '/core_exports.dart';

/// DEPRECATED: Use features/posts/domain/models/ranked_posts_model.dart instead
///
/// This model is maintained in backend for backward compatibility only.
/// New code should import from the posts feature domain layer.
@Deprecated('Use features/posts/domain/models/ranked_posts_model.dart')
class RankedPostsModel extends FirestoreRecord {
  RankedPostsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "postId" field.
  String? _postId;
  String get postId => _postId ?? '';
  bool hasPostId() => _postId != null;

  // "rank" field.
  int? _rank;
  int get rank => _rank ?? 0;
  bool hasRank() => _rank != null;

  // "score" field.
  double? _score;
  double get score => _score ?? 0.0;
  bool hasScore() => _score != null;

  // "votesA" field.
  int? _votesA;
  int get votesA => _votesA ?? 0;
  bool hasVotesA() => _votesA != null;

  // "votesB" field.
  int? _votesB;
  int get votesB => _votesB ?? 0;
  bool hasVotesB() => _votesB != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _postId = snapshotData['postId'] as String?;
    _rank = castToType<int>(snapshotData['rank']);
    _score = castToType<double>(snapshotData['score']);
    _votesA = castToType<int>(snapshotData['votesA']);
    _votesB = castToType<int>(snapshotData['votesB']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _category = snapshotData['category'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('rankedPosts')
          : FirebaseFirestore.instance.collectionGroup('rankedPosts');

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
  int? rank,
  double? score,
  int? votesA,
  int? votesB,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? category,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'postId': postId,
      'rank': rank,
      'score': score,
      'votesA': votesA,
      'votesB': votesB,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'category': category,
    }.withoutNulls,
  );

  return firestoreData;
}

class RankedPostsModelDocumentEquality implements Equality<RankedPostsModel> {
  const RankedPostsModelDocumentEquality();

  @override
  bool equals(RankedPostsModel? e1, RankedPostsModel? e2) {
    return e1?.postId == e2?.postId &&
        e1?.rank == e2?.rank &&
        e1?.score == e2?.score &&
        e1?.votesA == e2?.votesA &&
        e1?.votesB == e2?.votesB &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.category == e2?.category;
  }

  @override
  int hash(RankedPostsModel? e) => const ListEquality().hash([
        e?.postId,
        e?.rank,
        e?.score,
        e?.votesA,
        e?.votesB,
        e?.createdAt,
        e?.updatedAt,
        e?.category
      ]);

  @override
  bool isValidKey(Object? o) => o is RankedPostsModel;
}
