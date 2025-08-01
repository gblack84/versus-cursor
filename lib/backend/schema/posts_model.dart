import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class PostsModel extends FirestoreRecord {
  PostsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userid" field.
  String? _userid;
  String get userid => _userid ?? '';
  bool hasUserid() => _userid != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "option" field.
  List<int>? _option;
  List<int> get option => _option ?? const [];
  bool hasOption() => _option != null;

  // "commentcount" field.
  int? _commentcount;
  int get commentcount => _commentcount ?? 0;
  bool hasCommentcount() => _commentcount != null;

  // "likecount" field.
  int? _likecount;
  int get likecount => _likecount ?? 0;
  bool hasLikecount() => _likecount != null;

  // "interestcount" field.
  int? _interestcount;
  int get interestcount => _interestcount ?? 0;
  bool hasInterestcount() => _interestcount != null;

  // "sherecount" field.
  int? _sherecount;
  int get sherecount => _sherecount ?? 0;
  bool hasSherecount() => _sherecount != null;

  // "savecount" field.
  int? _savecount;
  int get savecount => _savecount ?? 0;
  bool hasSavecount() => _savecount != null;

  // "participantcount" field.
  int? _participantcount;
  int get participantcount => _participantcount ?? 0;
  bool hasParticipantcount() => _participantcount != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "visibility" field.
  int? _visibility;
  int get visibility => _visibility ?? 0;
  bool hasVisibility() => _visibility != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "initialCommentLimit" field.
  int? _initialCommentLimit;
  int get initialCommentLimit => _initialCommentLimit ?? 0;
  bool hasInitialCommentLimit() => _initialCommentLimit != null;

  // "currentCommentCount" field.
  int? _currentCommentCount;
  int get currentCommentCount => _currentCommentCount ?? 0;
  bool hasCurrentCommentCount() => _currentCommentCount != null;

  // "isVotingComplete" field.
  bool? _isVotingComplete;
  bool get isVotingComplete => _isVotingComplete ?? false;
  bool hasIsVotingComplete() => _isVotingComplete != null;

  // "expansionPointsUsed" field.
  int? _expansionPointsUsed;
  int get expansionPointsUsed => _expansionPointsUsed ?? 0;
  bool hasExpansionPointsUsed() => _expansionPointsUsed != null;

  // "expandedUserCount" field.
  int? _expandedUserCount;
  int get expandedUserCount => _expandedUserCount ?? 0;
  bool hasExpandedUserCount() => _expandedUserCount != null;

  // "expansionStatus" field.
  String? _expansionStatus;
  String get expansionStatus => _expansionStatus ?? '';
  bool hasExpansionStatus() => _expansionStatus != null;

  // "isAnonymous" field.
  bool? _isAnonymous;
  bool get isAnonymous => _isAnonymous ?? false;
  bool hasIsAnonymous() => _isAnonymous != null;

  // "isReported" field.
  bool? _isReported;
  bool get isReported => _isReported ?? false;
  bool hasIsReported() => _isReported != null;

  // "reportCount" field.
  int? _reportCount;
  int get reportCount => _reportCount ?? 0;
  bool hasReportCount() => _reportCount != null;

  // "reportedBy" field.
  List<String>? _reportedBy;
  List<String> get reportedBy => _reportedBy ?? const [];
  bool hasReportedBy() => _reportedBy != null;

  // "premiumRequired" field.
  bool? _premiumRequired;
  bool get premiumRequired => _premiumRequired ?? false;
  bool hasPremiumRequired() => _premiumRequired != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "questionTitle" field.
  String? _questionTitle;
  String get questionTitle => _questionTitle ?? '';
  bool hasQuestionTitle() => _questionTitle != null;

  // "creatorInfo" field.
  Map<String, dynamic>? _creatorInfo;
  Map<String, dynamic> get creatorInfo => _creatorInfo ?? const {};
  bool hasCreatorInfo() => _creatorInfo != null;

  // "optionA" field.
  Map<String, dynamic>? _optionA;
  Map<String, dynamic> get optionA => _optionA ?? const {};
  bool hasOptionA() => _optionA != null;

  // "optionB" field.
  Map<String, dynamic>? _optionB;
  Map<String, dynamic> get optionB => _optionB ?? const {};
  bool hasOptionB() => _optionB != null;

  // "stats" field.
  Map<String, dynamic>? _stats;
  Map<String, dynamic> get stats => _stats ?? const {};
  bool hasStats() => _stats != null;

  // "moderation" field.
  Map<String, dynamic>? _moderation;
  Map<String, dynamic> get moderation => _moderation ?? const {};
  bool hasModeration() => _moderation != null;

  // "targetAudience" field.
  Map<String, dynamic>? _targetAudience;
  Map<String, dynamic> get targetAudience => _targetAudience ?? const {};
  bool hasTargetAudience() => _targetAudience != null;

  // "descriptionA" field.
  String? _descriptionA;
  String get descriptionA => _descriptionA ?? '';
  bool hasDescriptionA() => _descriptionA != null;

  // "descriptionB" field.
  String? _descriptionB;
  String get descriptionB => _descriptionB ?? '';
  bool hasDescriptionB() => _descriptionB != null;

  void _initializeFields() {
    _userid = snapshotData['userid'] as String?;
    _content = snapshotData['content'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _option = getDataList(snapshotData['option']);
    _commentcount = castToType<int>(snapshotData['commentcount']);
    _likecount = castToType<int>(snapshotData['likecount']);
    _interestcount = castToType<int>(snapshotData['interestcount']);
    _sherecount = castToType<int>(snapshotData['sherecount']);
    _savecount = castToType<int>(snapshotData['savecount']);
    _participantcount = castToType<int>(snapshotData['participantcount']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _tags = getDataList(snapshotData['tags']);
    _category = snapshotData['category'] as String?;
    _visibility = castToType<int>(snapshotData['visibility']);
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _initialCommentLimit = castToType<int>(snapshotData['initialCommentLimit']);
    _currentCommentCount = castToType<int>(snapshotData['currentCommentCount']);
    _isVotingComplete = snapshotData['isVotingComplete'] as bool?;
    _expansionPointsUsed = castToType<int>(snapshotData['expansionPointsUsed']);
    _expandedUserCount = castToType<int>(snapshotData['expandedUserCount']);
    _expansionStatus = snapshotData['expansionStatus'] as String?;
    _isAnonymous = snapshotData['isAnonymous'] as bool?;
    _isReported = snapshotData['isReported'] as bool?;
    _reportCount = castToType<int>(snapshotData['reportCount']);
    _reportedBy = getDataList(snapshotData['reportedBy']);
    _premiumRequired = snapshotData['premiumRequired'] as bool?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _questionTitle = snapshotData['questionTitle'] as String?;
    _creatorInfo = snapshotData['creatorInfo'] as Map<String, dynamic>?;
    _optionA = snapshotData['optionA'] as Map<String, dynamic>?;
    _optionB = snapshotData['optionB'] as Map<String, dynamic>?;
    _stats = snapshotData['stats'] as Map<String, dynamic>?;
    _moderation = snapshotData['moderation'] as Map<String, dynamic>?;
    _targetAudience = snapshotData['targetAudience'] as Map<String, dynamic>?;
    _descriptionA = snapshotData['descriptionA'] as String?;
    _descriptionB = snapshotData['descriptionB'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('posts');

  static Stream<PostsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PostsModel.fromSnapshot(s));

  static Future<PostsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PostsModel.fromSnapshot(s));

  static PostsModel fromSnapshot(DocumentSnapshot snapshot) => PostsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PostsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PostsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PostsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PostsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPostsModelData({
  String? userid,
  String? content,
  LatLng? location,
  int? commentcount,
  int? likecount,
  int? interestcount,
  int? sherecount,
  int? savecount,
  int? participantcount,
  DateTime? createdAt,
  String? category,
  int? visibility,
  DateTime? updatedAt,
  int? initialCommentLimit,
  int? currentCommentCount,
  bool? isVotingComplete,
  int? expansionPointsUsed,
  int? expandedUserCount,
  String? expansionStatus,
  bool? isAnonymous,
  bool? isReported,
  int? reportCount,
  bool? premiumRequired,
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? questionTitle,
  Map<String, dynamic>? creatorInfo,
  Map<String, dynamic>? optionA,
  Map<String, dynamic>? optionB,
  Map<String, dynamic>? stats,
  Map<String, dynamic>? moderation,
  Map<String, dynamic>? targetAudience,
  String? descriptionA,
  String? descriptionB,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userid': userid,
      'content': content,
      'location': location,
      'commentcount': commentcount,
      'likecount': likecount,
      'interestcount': interestcount,
      'sherecount': sherecount,
      'savecount': savecount,
      'participantcount': participantcount,
      'createdAt': createdAt,
      'category': category,
      'visibility': visibility,
      'updatedAt': updatedAt,
      'initialCommentLimit': initialCommentLimit,
      'currentCommentCount': currentCommentCount,
      'isVotingComplete': isVotingComplete,
      'expansionPointsUsed': expansionPointsUsed,
      'expandedUserCount': expandedUserCount,
      'expansionStatus': expansionStatus,
      'isAnonymous': isAnonymous,
      'isReported': isReported,
      'reportCount': reportCount,
      'premiumRequired': premiumRequired,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'questionTitle': questionTitle,
      'creatorInfo': creatorInfo,
      'optionA': optionA,
      'optionB': optionB,
      'stats': stats,
      'moderation': moderation,
      'targetAudience': targetAudience,
      'descriptionA': descriptionA,
      'descriptionB': descriptionB,
    }.withoutNulls,
  );

  return firestoreData;
}

class PostsModelDocumentEquality implements Equality<PostsModel> {
  const PostsModelDocumentEquality();

  @override
  bool equals(PostsModel? e1, PostsModel? e2) {
    const listEquality = ListEquality();
    return e1?.userid == e2?.userid &&
        e1?.content == e2?.content &&
        e1?.location == e2?.location &&
        listEquality.equals(e1?.option, e2?.option) &&
        e1?.commentcount == e2?.commentcount &&
        e1?.likecount == e2?.likecount &&
        e1?.interestcount == e2?.interestcount &&
        e1?.sherecount == e2?.sherecount &&
        e1?.savecount == e2?.savecount &&
        e1?.participantcount == e2?.participantcount &&
        e1?.createdAt == e2?.createdAt &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        e1?.category == e2?.category &&
        e1?.visibility == e2?.visibility &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.initialCommentLimit == e2?.initialCommentLimit &&
        e1?.currentCommentCount == e2?.currentCommentCount &&
        e1?.isVotingComplete == e2?.isVotingComplete &&
        e1?.expansionPointsUsed == e2?.expansionPointsUsed &&
        e1?.expandedUserCount == e2?.expandedUserCount &&
        e1?.expansionStatus == e2?.expansionStatus &&
        e1?.isAnonymous == e2?.isAnonymous &&
        e1?.isReported == e2?.isReported &&
        e1?.reportCount == e2?.reportCount &&
        listEquality.equals(e1?.reportedBy, e2?.reportedBy) &&
        e1?.premiumRequired == e2?.premiumRequired &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.questionTitle == e2?.questionTitle &&
        e1?.creatorInfo == e2?.creatorInfo &&
        e1?.optionA == e2?.optionA &&
        e1?.optionB == e2?.optionB &&
        e1?.stats == e2?.stats &&
        e1?.moderation == e2?.moderation;
  }

  @override
  int hash(PostsModel? e) => const ListEquality().hash([
        e?.userid,
        e?.content,
        e?.location,
        e?.option,
        e?.commentcount,
        e?.likecount,
        e?.interestcount,
        e?.sherecount,
        e?.savecount,
        e?.participantcount,
        e?.createdAt,
        e?.tags,
        e?.category,
        e?.visibility,
        e?.updatedAt,
        e?.initialCommentLimit,
        e?.currentCommentCount,
        e?.isVotingComplete,
        e?.expansionPointsUsed,
        e?.expandedUserCount,
        e?.expansionStatus,
        e?.isAnonymous,
        e?.isReported,
        e?.reportCount,
        e?.reportedBy,
        e?.premiumRequired,
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.questionTitle,
        e?.creatorInfo,
        e?.optionA,
        e?.optionB,
        e?.stats,
        e?.moderation
      ]);

  @override
  bool isValidKey(Object? o) => o is PostsModel;
}
