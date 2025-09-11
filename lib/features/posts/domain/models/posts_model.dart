import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';
import '/core/firebase/utils/schema_util.dart';

import '/core_exports.dart';

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

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // NEW: Vote system fields
  // "voteStartTime" field.
  DateTime? _voteStartTime;
  DateTime? get voteStartTime => _voteStartTime;
  bool hasVoteStartTime() => _voteStartTime != null;

  // "voteEndTime" field.
  DateTime? _voteEndTime;
  DateTime? get voteEndTime => _voteEndTime;
  bool hasVoteEndTime() => _voteEndTime != null;

  // "vote_status" field.
  String? _voteStatus;
  String get voteStatus => _voteStatus ?? '';
  bool hasVoteStatus() => _voteStatus != null;

  // "vote_completed" field.
  bool? _voteCompleted;
  bool get voteCompleted => _voteCompleted ?? false;
  bool hasVoteCompleted() => _voteCompleted != null;

  // "votes_a" field.
  int? _votesA;
  int get votesA => _votesA ?? 0;
  bool hasVotesA() => _votesA != null;

  // "votes_b" field.
  int? _votesB;
  int get votesB => _votesB ?? 0;
  bool hasVotesB() => _votesB != null;

  // "votedUserIdsA" field.
  List<String>? _votedUserIdsA;
  List<String> get votedUserIdsA => _votedUserIdsA ?? const [];
  bool hasVotedUserIdsA() => _votedUserIdsA != null;

  // "votedUserIdsB" field.
  List<String>? _votedUserIdsB;
  List<String> get votedUserIdsB => _votedUserIdsB ?? const [];
  bool hasVotedUserIdsB() => _votedUserIdsB != null;

  // "total_votes" field.
  int? _totalVotes;
  int get totalVotes => _totalVotes ?? 0;
  bool hasTotalVotes() => _totalVotes != null;

  // "vote_timeout" field.
  bool? _voteTimeout;
  bool get voteTimeout => _voteTimeout ?? false;
  bool hasVoteTimeout() => _voteTimeout != null;

  // "voteCompletedAt" field.
  DateTime? _voteCompletedAt;
  DateTime? get voteCompletedAt => _voteCompletedAt;
  bool hasVoteCompletedAt() => _voteCompletedAt != null;

  // "voteCancelledAt" field.
  DateTime? _voteCancelledAt;
  DateTime? get voteCancelledAt => _voteCancelledAt;
  bool hasVoteCancelledAt() => _voteCancelledAt != null;

  // "voteCancelledReason" field.
  String? _voteCancelledReason;
  String get voteCancelledReason => _voteCancelledReason ?? '';
  bool hasVoteCancelledReason() => _voteCancelledReason != null;

  // "notificationsSent" field.
  bool? _notificationsSent;
  bool get notificationsSent => _notificationsSent ?? false;
  bool hasNotificationsSent() => _notificationsSent != null;

  // "notificationsSentAt" field.
  DateTime? _notificationsSentAt;
  DateTime? get notificationsSentAt => _notificationsSentAt;
  bool hasNotificationsSentAt() => _notificationsSentAt != null;

  // "displayVotesA" field.
  int? _displayVotesA;
  int get displayVotesA => _displayVotesA ?? 0;
  bool hasDisplayVotesA() => _displayVotesA != null;

  // "displayVotesB" field.
  int? _displayVotesB;
  int get displayVotesB => _displayVotesB ?? 0;
  bool hasDisplayVotesB() => _displayVotesB != null;

  // "displayPercentA" field.
  int? _displayPercentA;
  int get displayPercentA => _displayPercentA ?? 0;
  bool hasDisplayPercentA() => _displayPercentA != null;

  // "displayPercentB" field.
  int? _displayPercentB;
  int get displayPercentB => _displayPercentB ?? 0;
  bool hasDisplayPercentB() => _displayPercentB != null;

  // "actualVotesA" field.
  int? _actualVotesA;
  int get actualVotesA => _actualVotesA ?? 0;
  bool hasActualVotesA() => _actualVotesA != null;

  // "actualVotesB" field.
  int? _actualVotesB;
  int get actualVotesB => _actualVotesB ?? 0;
  bool hasActualVotesB() => _actualVotesB != null;

  // "actualTotalVotes" field.
  int? _actualTotalVotes;
  int get actualTotalVotes => _actualTotalVotes ?? 0;
  bool hasActualTotalVotes() => _actualTotalVotes != null;

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
    // Support both field names for backwards compatibility
    _voteCompleted = snapshotData['voteCompleted'] as bool?;
    _expansionPointsUsed = castToType<int>(snapshotData['expansionPointsUsed']);
    _expandedUserCount = castToType<int>(snapshotData['expandedUserCount']);
    _expansionStatus = snapshotData['expansionStatus'] as String?;
    _isAnonymous = snapshotData['isAnonymous'] as bool?;
    _isReported = snapshotData['isReported'] as bool?;
    _reportCount = castToType<int>(snapshotData['reportCount']);
    _reportedBy = getDataList(snapshotData['reportedBy']);
    _premiumRequired = snapshotData['premiumRequired'] as bool?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['displayName'] as String?;
    _photoUrl = snapshotData['photoUrl'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _phoneNumber = snapshotData['phoneNumber'] as String?;
    _questionTitle = snapshotData['questionTitle'] as String?;
    _creatorInfo = snapshotData['creatorInfo'] as Map<String, dynamic>?;
    _optionA = snapshotData['optionA'] as Map<String, dynamic>?;
    _optionB = snapshotData['optionB'] as Map<String, dynamic>?;
    _stats = snapshotData['stats'] as Map<String, dynamic>?;
    _moderation = snapshotData['moderation'] as Map<String, dynamic>?;
    _targetAudience = snapshotData['targetAudience'] as Map<String, dynamic>?;
    _description = snapshotData['description'] as String?;

    // Initialize vote system fields
    _voteStartTime = snapshotData['voteStartTime'] as DateTime?;
    _voteEndTime = snapshotData['voteEndTime'] as DateTime?;
    _voteStatus = snapshotData['voteStatus'] as String?;
    _votesA = castToType<int>(snapshotData['votesA']);
    _votesB = castToType<int>(snapshotData['votesB']);
    _votedUserIdsA = getDataList(snapshotData['votedUserIdsA']);
    _votedUserIdsB = getDataList(snapshotData['votedUserIdsB']);
    _totalVotes = castToType<int>(snapshotData['totalVotes']);
    _voteTimeout = snapshotData['voteTimeout'] as bool?;
    _voteCompletedAt = snapshotData['voteCompletedAt'] as DateTime?;
    _voteCancelledAt = snapshotData['voteCancelledAt'] as DateTime?;
    _voteCancelledReason = snapshotData['voteCancelledReason'] as String?;

    // Initialize notification and display fields
    _notificationsSent = snapshotData['notificationsSent'] as bool?;
    _notificationsSentAt = snapshotData['notificationsSentAt'] as DateTime?;
    _displayVotesA = castToType<int>(snapshotData['displayVotesA']);
    _displayVotesB = castToType<int>(snapshotData['displayVotesB']);
    _displayPercentA = castToType<int>(snapshotData['displayPercentA']);
    _displayPercentB = castToType<int>(snapshotData['displayPercentB']);
    _actualVotesA = castToType<int>(snapshotData['actualVotesA']);
    _actualVotesB = castToType<int>(snapshotData['actualVotesB']);
    _actualTotalVotes = castToType<int>(snapshotData['actualTotalVotes']);
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
  String? description,
  DateTime? voteStartTime,
  DateTime? voteEndTime,
  String? voteStatus,
  bool? voteCompleted,
  int? votesA,
  int? votesB,
  List<String>? votedUserIdsA,
  List<String>? votedUserIdsB,
  int? totalVotes,
  bool? voteTimeout,
  DateTime? voteCompletedAt,
  DateTime? voteCancelledAt,
  String? voteCancelledReason,
  bool? notificationsSent,
  DateTime? notificationsSentAt,
  int? displayVotesA,
  int? displayVotesB,
  int? displayPercentA,
  int? displayPercentB,
  int? actualVotesA,
  int? actualVotesB,
  int? actualTotalVotes,
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
      'displayName': displayName,
      'photoUrl': photoUrl,
      'uid': uid,
      'createdTime': createdTime,
      'phoneNumber': phoneNumber,
      'questionTitle': questionTitle,
      'creatorInfo': creatorInfo,
      'optionA': optionA,
      'optionB': optionB,
      'stats': stats,
      'moderation': moderation,
      'targetAudience': targetAudience,
      'description': description,
      'voteStartTime': voteStartTime,
      'voteEndTime': voteEndTime,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
      'votesA': votesA,
      'votesB': votesB,
      'votedUserIdsA': votedUserIdsA,
      'votedUserIdsB': votedUserIdsB,
      'totalVotes': totalVotes,
      'voteTimeout': voteTimeout,
      'voteCompletedAt': voteCompletedAt,
      'voteCancelledAt': voteCancelledAt,
      'voteCancelledReason': voteCancelledReason,
      'notificationsSent': notificationsSent,
      'notificationsSentAt': notificationsSentAt,
      'displayVotesA': displayVotesA,
      'displayVotesB': displayVotesB,
      'displayPercentA': displayPercentA,
      'displayPercentB': displayPercentB,
      'actualVotesA': actualVotesA,
      'actualVotesB': actualVotesB,
      'actualTotalVotes': actualTotalVotes,
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
        e1?.moderation == e2?.moderation &&
        e1?.targetAudience == e2?.targetAudience &&
        e1?.description == e2?.description &&
        e1?.voteStartTime == e2?.voteStartTime &&
        e1?.voteEndTime == e2?.voteEndTime &&
        e1?.voteStatus == e2?.voteStatus &&
        e1?.voteCompleted == e2?.voteCompleted &&
        e1?.votesA == e2?.votesA &&
        e1?.votesB == e2?.votesB &&
        listEquality.equals(e1?.votedUserIdsA, e2?.votedUserIdsA) &&
        listEquality.equals(e1?.votedUserIdsB, e2?.votedUserIdsB) &&
        e1?.totalVotes == e2?.totalVotes &&
        e1?.voteTimeout == e2?.voteTimeout &&
        e1?.voteCompletedAt == e2?.voteCompletedAt &&
        e1?.voteCancelledAt == e2?.voteCancelledAt &&
        e1?.voteCancelledReason == e2?.voteCancelledReason &&
        e1?.notificationsSent == e2?.notificationsSent &&
        e1?.notificationsSentAt == e2?.notificationsSentAt &&
        e1?.displayVotesA == e2?.displayVotesA &&
        e1?.displayVotesB == e2?.displayVotesB &&
        e1?.displayPercentA == e2?.displayPercentA &&
        e1?.displayPercentB == e2?.displayPercentB &&
        e1?.actualVotesA == e2?.actualVotesA &&
        e1?.actualVotesB == e2?.actualVotesB &&
        e1?.actualTotalVotes == e2?.actualTotalVotes;
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
        e?.moderation,
        e?.targetAudience,
        e?.description,
        e?.voteStartTime,
        e?.voteEndTime,
        e?.voteStatus,
        e?.voteCompleted,
        e?.votesA,
        e?.votesB,
        e?.votedUserIdsA,
        e?.votedUserIdsB,
        e?.totalVotes,
        e?.voteTimeout,
        e?.voteCompletedAt,
        e?.voteCancelledAt,
        e?.voteCancelledReason,
        e?.notificationsSent,
        e?.notificationsSentAt,
        e?.displayVotesA,
        e?.displayVotesB,
        e?.displayPercentA,
        e?.displayPercentB,
        e?.actualVotesA,
        e?.actualVotesB,
        e?.actualTotalVotes
      ]);

  @override
  bool isValidKey(Object? o) => o is PostsModel;
}
