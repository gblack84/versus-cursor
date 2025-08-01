import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class UsersModel extends FirestoreRecord {
  UsersModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "points_A" field.
  int? _pointsA;
  int get pointsA => _pointsA ?? 0;
  bool hasPointsA() => _pointsA != null;

  // "points_Q" field.
  int? _pointsQ;
  int get pointsQ => _pointsQ ?? 0;
  bool hasPointsQ() => _pointsQ != null;

  // "lastActive" field.
  DateTime? _lastActive;
  DateTime? get lastActive => _lastActive;
  bool hasLastActive() => _lastActive != null;

  // "interests" field.
  List<String>? _interests;
  List<String> get interests => _interests ?? const [];
  bool hasInterests() => _interests != null;

  // "expertise" field.
  List<String>? _expertise;
  List<String> get expertise => _expertise ?? const [];
  bool hasExpertise() => _expertise != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "is_prmium_user" field.
  bool? _isPrmiumUser;
  bool get isPrmiumUser => _isPrmiumUser ?? false;
  bool hasIsPrmiumUser() => _isPrmiumUser != null;

  // "anonymous_posts_count" field.
  int? _anonymousPostsCount;
  int get anonymousPostsCount => _anonymousPostsCount ?? 0;
  bool hasAnonymousPostsCount() => _anonymousPostsCount != null;

  // "anonymous_comments_count" field.
  int? _anonymousCommentsCount;
  int get anonymousCommentsCount => _anonymousCommentsCount ?? 0;
  bool hasAnonymousCommentsCount() => _anonymousCommentsCount != null;

  // "current_rank" field.
  String? _currentRank;
  String get currentRank => _currentRank ?? '';
  bool hasCurrentRank() => _currentRank != null;

  // "current_title" field.
  String? _currentTitle;
  String get currentTitle => _currentTitle ?? '';
  bool hasCurrentTitle() => _currentTitle != null;

  // "rank_change_date" field.
  DateTime? _rankChangeDate;
  DateTime? get rankChangeDate => _rankChangeDate;
  bool hasRankChangeDate() => _rankChangeDate != null;

  // "title_change_date" field.
  DateTime? _titleChangeDate;
  DateTime? get titleChangeDate => _titleChangeDate;
  bool hasTitleChangeDate() => _titleChangeDate != null;

  // "is_rank_eligible" field.
  bool? _isRankEligible;
  bool get isRankEligible => _isRankEligible ?? false;
  bool hasIsRankEligible() => _isRankEligible != null;

  // "rank_evaluation_count" field.
  int? _rankEvaluationCount;
  int get rankEvaluationCount => _rankEvaluationCount ?? 0;
  bool hasRankEvaluationCount() => _rankEvaluationCount != null;

  // "rank_history" field.
  List<String>? _rankHistory;
  List<String> get rankHistory => _rankHistory ?? const [];
  bool hasRankHistory() => _rankHistory != null;

  // "title_history" field.
  List<String>? _titleHistory;
  List<String> get titleHistory => _titleHistory ?? const [];
  bool hasTitleHistory() => _titleHistory != null;

  // "receive_Rank_Update_Notifications" field.
  bool? _receiveRankUpdateNotifications;
  bool get receiveRankUpdateNotifications =>
      _receiveRankUpdateNotifications ?? false;
  bool hasReceiveRankUpdateNotifications() =>
      _receiveRankUpdateNotifications != null;

  // "receive_Title_Update_Notifications" field.
  bool? _receiveTitleUpdateNotifications;
  bool get receiveTitleUpdateNotifications =>
      _receiveTitleUpdateNotifications ?? false;
  bool hasReceiveTitleUpdateNotifications() =>
      _receiveTitleUpdateNotifications != null;

  // "anonymous_Question_Count" field.
  int? _anonymousQuestionCount;
  int get anonymousQuestionCount => _anonymousQuestionCount ?? 0;
  bool hasAnonymousQuestionCount() => _anonymousQuestionCount != null;

  // "frinds" field.
  List<String>? _frinds;
  List<String> get frinds => _frinds ?? const [];
  bool hasFrinds() => _frinds != null;

  // "active_chats" field.
  List<String>? _activeChats;
  List<String> get activeChats => _activeChats ?? const [];
  bool hasActiveChats() => _activeChats != null;

  // "group_chats" field.
  List<String>? _groupChats;
  List<String> get groupChats => _groupChats ?? const [];
  bool hasGroupChats() => _groupChats != null;

  // "total_a_points" field.
  int? _totalAPoints;
  int get totalAPoints => _totalAPoints ?? 0;
  bool hasTotalAPoints() => _totalAPoints != null;

  // "total_q_points" field.
  int? _totalQPoints;
  int get totalQPoints => _totalQPoints ?? 0;
  bool hasTotalQPoints() => _totalQPoints != null;

  // "shortDescription" field.
  String? _shortDescription;
  String get shortDescription => _shortDescription ?? '';
  bool hasShortDescription() => _shortDescription != null;

  // "last_active_time" field.
  DateTime? _lastActiveTime;
  DateTime? get lastActiveTime => _lastActiveTime;
  bool hasLastActiveTime() => _lastActiveTime != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  // "date_of_birth" field.
  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool hasDateOfBirth() => _dateOfBirth != null;

  // "Language" field.
  String? _language;
  String get language => _language ?? '';
  bool hasLanguage() => _language != null;

  // "stats" field.
  Map<String, dynamic>? _stats;
  Map<String, dynamic> get stats => _stats ?? const {};
  bool hasStats() => _stats != null;

  // "subscription" field.
  Map<String, dynamic>? _subscription;
  Map<String, dynamic> get subscription => _subscription ?? const {};
  bool hasSubscription() => _subscription != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _email = snapshotData['email'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _pointsA = castToType<int>(snapshotData['points_A']);
    _pointsQ = castToType<int>(snapshotData['points_Q']);
    _lastActive = snapshotData['lastActive'] as DateTime?;
    _interests = getDataList(snapshotData['interests']);
    _expertise = getDataList(snapshotData['expertise']);
    _displayName = snapshotData['display_name'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _isPrmiumUser = snapshotData['is_prmium_user'] as bool?;
    _anonymousPostsCount =
        castToType<int>(snapshotData['anonymous_posts_count']);
    _anonymousCommentsCount =
        castToType<int>(snapshotData['anonymous_comments_count']);
    _currentRank = snapshotData['current_rank'] as String?;
    _currentTitle = snapshotData['current_title'] as String?;
    _rankChangeDate = snapshotData['rank_change_date'] as DateTime?;
    _titleChangeDate = snapshotData['title_change_date'] as DateTime?;
    _isRankEligible = snapshotData['is_rank_eligible'] as bool?;
    _rankEvaluationCount =
        castToType<int>(snapshotData['rank_evaluation_count']);
    _rankHistory = getDataList(snapshotData['rank_history']);
    _titleHistory = getDataList(snapshotData['title_history']);
    _receiveRankUpdateNotifications =
        snapshotData['receive_Rank_Update_Notifications'] as bool?;
    _receiveTitleUpdateNotifications =
        snapshotData['receive_Title_Update_Notifications'] as bool?;
    _anonymousQuestionCount =
        castToType<int>(snapshotData['anonymous_Question_Count']);
    _frinds = getDataList(snapshotData['frinds']);
    _activeChats = getDataList(snapshotData['active_chats']);
    _groupChats = getDataList(snapshotData['group_chats']);
    _totalAPoints = castToType<int>(snapshotData['total_a_points']);
    _totalQPoints = castToType<int>(snapshotData['total_q_points']);
    _shortDescription = snapshotData['shortDescription'] as String?;
    _lastActiveTime = snapshotData['last_active_time'] as DateTime?;
    _role = snapshotData['role'] as String?;
    _title = snapshotData['title'] as String?;
    _gender = snapshotData['gender'] as String?;
    _dateOfBirth = snapshotData['date_of_birth'] as DateTime?;
    _language = snapshotData['Language'] as String?;
    _stats = snapshotData['stats'] as Map<String, dynamic>?;
    _subscription = snapshotData['subscription'] as Map<String, dynamic>?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersModel.fromSnapshot(s));

  static Future<UsersModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersModel.fromSnapshot(s));

  static UsersModel fromSnapshot(DocumentSnapshot snapshot) => UsersModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersModelData({
  String? uid,
  String? email,
  LatLng? location,
  int? pointsA,
  int? pointsQ,
  DateTime? lastActive,
  String? displayName,
  DateTime? createdTime,
  String? photoUrl,
  String? phoneNumber,
  bool? isPrmiumUser,
  int? anonymousPostsCount,
  int? anonymousCommentsCount,
  String? currentRank,
  String? currentTitle,
  DateTime? rankChangeDate,
  DateTime? titleChangeDate,
  bool? isRankEligible,
  int? rankEvaluationCount,
  bool? receiveRankUpdateNotifications,
  bool? receiveTitleUpdateNotifications,
  int? anonymousQuestionCount,
  int? totalAPoints,
  int? totalQPoints,
  String? shortDescription,
  DateTime? lastActiveTime,
  String? role,
  String? title,
  String? gender,
  DateTime? dateOfBirth,
  String? language,
  Map<String, dynamic>? stats,
  Map<String, dynamic>? subscription,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'email': email,
      'location': location,
      'points_A': pointsA,
      'points_Q': pointsQ,
      'lastActive': lastActive,
      'display_name': displayName,
      'created_time': createdTime,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'is_prmium_user': isPrmiumUser,
      'anonymous_posts_count': anonymousPostsCount,
      'anonymous_comments_count': anonymousCommentsCount,
      'current_rank': currentRank,
      'current_title': currentTitle,
      'rank_change_date': rankChangeDate,
      'title_change_date': titleChangeDate,
      'is_rank_eligible': isRankEligible,
      'rank_evaluation_count': rankEvaluationCount,
      'receive_Rank_Update_Notifications': receiveRankUpdateNotifications,
      'receive_Title_Update_Notifications': receiveTitleUpdateNotifications,
      'anonymous_Question_Count': anonymousQuestionCount,
      'total_a_points': totalAPoints,
      'total_q_points': totalQPoints,
      'shortDescription': shortDescription,
      'last_active_time': lastActiveTime,
      'role': role,
      'title': title,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'Language': language,
      'stats': stats,
      'subscription': subscription,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersModelDocumentEquality implements Equality<UsersModel> {
  const UsersModelDocumentEquality();

  @override
  bool equals(UsersModel? e1, UsersModel? e2) {
    const listEquality = ListEquality();
    return e1?.uid == e2?.uid &&
        e1?.email == e2?.email &&
        e1?.location == e2?.location &&
        e1?.pointsA == e2?.pointsA &&
        e1?.pointsQ == e2?.pointsQ &&
        e1?.lastActive == e2?.lastActive &&
        listEquality.equals(e1?.interests, e2?.interests) &&
        listEquality.equals(e1?.expertise, e2?.expertise) &&
        e1?.displayName == e2?.displayName &&
        e1?.createdTime == e2?.createdTime &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.isPrmiumUser == e2?.isPrmiumUser &&
        e1?.anonymousPostsCount == e2?.anonymousPostsCount &&
        e1?.anonymousCommentsCount == e2?.anonymousCommentsCount &&
        e1?.currentRank == e2?.currentRank &&
        e1?.currentTitle == e2?.currentTitle &&
        e1?.rankChangeDate == e2?.rankChangeDate &&
        e1?.titleChangeDate == e2?.titleChangeDate &&
        e1?.isRankEligible == e2?.isRankEligible &&
        e1?.rankEvaluationCount == e2?.rankEvaluationCount &&
        listEquality.equals(e1?.rankHistory, e2?.rankHistory) &&
        listEquality.equals(e1?.titleHistory, e2?.titleHistory) &&
        e1?.receiveRankUpdateNotifications ==
            e2?.receiveRankUpdateNotifications &&
        e1?.receiveTitleUpdateNotifications ==
            e2?.receiveTitleUpdateNotifications &&
        e1?.anonymousQuestionCount == e2?.anonymousQuestionCount &&
        listEquality.equals(e1?.frinds, e2?.frinds) &&
        listEquality.equals(e1?.activeChats, e2?.activeChats) &&
        listEquality.equals(e1?.groupChats, e2?.groupChats) &&
        e1?.totalAPoints == e2?.totalAPoints &&
        e1?.totalQPoints == e2?.totalQPoints &&
        e1?.shortDescription == e2?.shortDescription &&
        e1?.lastActiveTime == e2?.lastActiveTime &&
        e1?.role == e2?.role &&
        e1?.title == e2?.title &&
        e1?.gender == e2?.gender &&
        e1?.dateOfBirth == e2?.dateOfBirth &&
        e1?.language == e2?.language &&
        e1?.stats == e2?.stats &&
        e1?.subscription == e2?.subscription;
  }

  @override
  int hash(UsersModel? e) => const ListEquality().hash([
        e?.uid,
        e?.email,
        e?.location,
        e?.pointsA,
        e?.pointsQ,
        e?.lastActive,
        e?.interests,
        e?.expertise,
        e?.displayName,
        e?.createdTime,
        e?.photoUrl,
        e?.phoneNumber,
        e?.isPrmiumUser,
        e?.anonymousPostsCount,
        e?.anonymousCommentsCount,
        e?.currentRank,
        e?.currentTitle,
        e?.rankChangeDate,
        e?.titleChangeDate,
        e?.isRankEligible,
        e?.rankEvaluationCount,
        e?.rankHistory,
        e?.titleHistory,
        e?.receiveRankUpdateNotifications,
        e?.receiveTitleUpdateNotifications,
        e?.anonymousQuestionCount,
        e?.frinds,
        e?.activeChats,
        e?.groupChats,
        e?.totalAPoints,
        e?.totalQPoints,
        e?.shortDescription,
        e?.lastActiveTime,
        e?.role,
        e?.title,
        e?.gender,
        e?.dateOfBirth,
        e?.language,
        e?.stats,
        e?.subscription
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersModel;
}
