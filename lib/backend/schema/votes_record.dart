import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class VotesRecord extends FirestoreRecord {
  VotesRecord._(
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

  static Stream<VotesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VotesRecord.fromSnapshot(s));

  static Future<VotesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VotesRecord.fromSnapshot(s));

  static VotesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VotesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VotesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VotesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VotesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VotesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVotesRecordData({
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

class VotesRecordDocumentEquality implements Equality<VotesRecord> {
  const VotesRecordDocumentEquality();

  @override
  bool equals(VotesRecord? e1, VotesRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.choice == e2?.choice &&
        e1?.votedAt == e2?.votedAt &&
        e1?.userInfo == e2?.userInfo;
  }

  @override
  int hash(VotesRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.choice,
        e?.votedAt,
        e?.userInfo
      ]);

  @override
  bool isValidKey(Object? o) => o is VotesRecord;
}