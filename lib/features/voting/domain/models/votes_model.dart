import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';

import '/core_exports.dart';

class VotesModel extends FirestoreRecord {
  VotesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "choice" field.
  String? _choice;
  String get choice => _choice ?? '';
  bool hasChoice() => _choice != null;

  // "votedAt" field.
  DateTime? _votedAt;
  DateTime? get votedAt => _votedAt;
  bool hasVotedAt() => _votedAt != null;

  // "userInfo" field.
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic> get userInfo => _userInfo ?? const {};
  bool hasUserInfo() => _userInfo != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _choice = snapshotData['choice'] as String?;
    _votedAt = snapshotData['votedAt'] as DateTime?;
    _userInfo = snapshotData['userInfo'] as Map<String, dynamic>?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('votes')
          : FirebaseFirestore.instance.collectionGroup('votes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('votes').doc(id);

  static Stream<VotesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VotesModel.fromSnapshot(s));

  static Future<VotesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VotesModel.fromSnapshot(s));

  static VotesModel fromSnapshot(DocumentSnapshot snapshot) =>
      VotesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VotesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VotesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VotesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VotesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVotesModelData({
  String? userId,
  String? choice,
  DateTime? votedAt,
  Map<String, dynamic>? userInfo,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'choice': choice,
      'votedAt': votedAt,
      'userInfo': userInfo,
    }.withoutNulls,
  );

  return firestoreData;
}

class VotesModelDocumentEquality implements Equality<VotesModel> {
  const VotesModelDocumentEquality();

  @override
  bool equals(VotesModel? e1, VotesModel? e2) {
    return e1?.userId == e2?.userId &&
        e1?.choice == e2?.choice &&
        e1?.votedAt == e2?.votedAt &&
        e1?.userInfo == e2?.userInfo;
  }

  @override
  int hash(VotesModel? e) => const ListEquality().hash([
        e?.userId,
        e?.choice,
        e?.votedAt,
        e?.userInfo
      ]);

  @override
  bool isValidKey(Object? o) => o is VotesModel;
}