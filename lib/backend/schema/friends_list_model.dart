import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import '/app/widgets/index.dart';
import '/core_exports.dart';

class FriendsListModel extends FirestoreRecord {
  FriendsListModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "friendsId" field.
  String? _friendsId;
  String get friendsId => _friendsId ?? '';
  bool hasFriendsId() => _friendsId != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "following" field.
  bool? _following;
  bool get following => _following ?? false;
  bool hasFollowing() => _following != null;

  // "follower" field.
  bool? _follower;
  bool get follower => _follower ?? false;
  bool hasFollower() => _follower != null;

  // "isBlocked" field.
  bool? _isBlocked;
  bool get isBlocked => _isBlocked ?? false;
  bool hasIsBlocked() => _isBlocked != null;

  // "lastInteraction" field.
  DateTime? _lastInteraction;
  DateTime? get lastInteraction => _lastInteraction;
  bool hasLastInteraction() => _lastInteraction != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _friendsId = snapshotData['friendsId'] as String?;
    _status = snapshotData['status'] as String?;
    _following = snapshotData['following'] as bool?;
    _follower = snapshotData['follower'] as bool?;
    _isBlocked = snapshotData['isBlocked'] as bool?;
    _lastInteraction = snapshotData['lastInteraction'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('friendsList')
          : FirebaseFirestore.instance.collectionGroup('friendsList');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('friendsList').doc(id);

  static Stream<FriendsListModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FriendsListModel.fromSnapshot(s));

  static Future<FriendsListModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FriendsListModel.fromSnapshot(s));

  static FriendsListModel fromSnapshot(DocumentSnapshot snapshot) =>
      FriendsListModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FriendsListModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FriendsListModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FriendsListModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FriendsListModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFriendsListModelData({
  String? friendsId,
  String? status,
  bool? following,
  bool? follower,
  bool? isBlocked,
  DateTime? lastInteraction,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'friendsId': friendsId,
      'status': status,
      'following': following,
      'follower': follower,
      'isBlocked': isBlocked,
      'lastInteraction': lastInteraction,
    }.withoutNulls,
  );

  return firestoreData;
}

class FriendsListModelDocumentEquality implements Equality<FriendsListModel> {
  const FriendsListModelDocumentEquality();

  @override
  bool equals(FriendsListModel? e1, FriendsListModel? e2) {
    return e1?.friendsId == e2?.friendsId &&
        e1?.status == e2?.status &&
        e1?.following == e2?.following &&
        e1?.follower == e2?.follower &&
        e1?.isBlocked == e2?.isBlocked &&
        e1?.lastInteraction == e2?.lastInteraction;
  }

  @override
  int hash(FriendsListModel? e) => const ListEquality().hash([
        e?.friendsId,
        e?.status,
        e?.following,
        e?.follower,
        e?.isBlocked,
        e?.lastInteraction
      ]);

  @override
  bool isValidKey(Object? o) => o is FriendsListModel;
}
