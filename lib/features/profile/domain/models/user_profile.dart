import 'dart:async';
import 'package:collection/collection.dart';
import '../../../../core_exports.dart';

/// UserProfile domain model for the profile feature
/// Represents a user's profile information and system state
class UserProfile extends FirestoreRecord {
  UserProfile._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // Core Identity Fields
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // Profile Information
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  String? _shortDescription;
  String get shortDescription => _shortDescription ?? '';
  bool hasShortDescription() => _shortDescription != null;

  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool hasDateOfBirth() => _dateOfBirth != null;

  String? _language;
  String get language => _language ?? '';
  bool hasLanguage() => _language != null;

  // System Timestamps
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  DateTime? _lastActive;
  DateTime? get lastActive => _lastActive;
  bool hasLastActive() => _lastActive != null;

  DateTime? _lastActiveTime;
  DateTime? get lastActiveTime => _lastActiveTime;
  bool hasLastActiveTime() => _lastActiveTime != null;

  // Points System
  int? _pointsA;
  int get pointsA => _pointsA ?? 0;
  bool hasPointsA() => _pointsA != null;

  int? _pointsQ;
  int get pointsQ => _pointsQ ?? 0;
  bool hasPointsQ() => _pointsQ != null;

  int? _totalAPoints;
  int get totalAPoints => _totalAPoints ?? 0;
  bool hasTotalAPoints() => _totalAPoints != null;

  int? _totalQPoints;
  int get totalQPoints => _totalQPoints ?? 0;
  bool hasTotalQPoints() => _totalQPoints != null;

  // Interests and Expertise
  List<String>? _interests;
  List<String> get interests => _interests ?? const [];
  bool hasInterests() => _interests != null;

  List<String>? _expertise;
  List<String> get expertise => _expertise ?? const [];
  bool hasExpertise() => _expertise != null;

  // Premium Status
  bool? _isPremiumUser;
  bool get isPremiumUser => _isPremiumUser ?? false;
  bool hasIsPremiumUser() => _isPremiumUser != null;

  // Deprecated: kept for backwards compatibility
  @Deprecated('Use isPremiumUser instead')
  bool get isPrmiumUser => isPremiumUser;
  @Deprecated('Use hasIsPremiumUser instead')
  bool hasIsPrmiumUser() => hasIsPremiumUser();

  // Anonymous Activity Counters
  int? _anonymousPostsCount;
  int get anonymousPostsCount => _anonymousPostsCount ?? 0;
  bool hasAnonymousPostsCount() => _anonymousPostsCount != null;

  int? _anonymousCommentsCount;
  int get anonymousCommentsCount => _anonymousCommentsCount ?? 0;
  bool hasAnonymousCommentsCount() => _anonymousCommentsCount != null;

  int? _anonymousQuestionCount;
  int get anonymousQuestionCount => _anonymousQuestionCount ?? 0;
  bool hasAnonymousQuestionCount() => _anonymousQuestionCount != null;

  // Ranking System
  String? _currentRank;
  String get currentRank => _currentRank ?? '';
  bool hasCurrentRank() => _currentRank != null;

  String? _currentTitle;
  String get currentTitle => _currentTitle ?? '';
  bool hasCurrentTitle() => _currentTitle != null;

  DateTime? _rankChangeDate;
  DateTime? get rankChangeDate => _rankChangeDate;
  bool hasRankChangeDate() => _rankChangeDate != null;

  DateTime? _titleChangeDate;
  DateTime? get titleChangeDate => _titleChangeDate;
  bool hasTitleChangeDate() => _titleChangeDate != null;

  bool? _isRankEligible;
  bool get isRankEligible => _isRankEligible ?? false;
  bool hasIsRankEligible() => _isRankEligible != null;

  int? _rankEvaluationCount;
  int get rankEvaluationCount => _rankEvaluationCount ?? 0;
  bool hasRankEvaluationCount() => _rankEvaluationCount != null;

  List<String>? _rankHistory;
  List<String> get rankHistory => _rankHistory ?? const [];
  bool hasRankHistory() => _rankHistory != null;

  List<String>? _titleHistory;
  List<String> get titleHistory => _titleHistory ?? const [];
  bool hasTitleHistory() => _titleHistory != null;

  // Notification Settings
  bool? _receiveRankUpdateNotifications;
  bool get receiveRankUpdateNotifications =>
      _receiveRankUpdateNotifications ?? false;
  bool hasReceiveRankUpdateNotifications() =>
      _receiveRankUpdateNotifications != null;

  bool? _receiveTitleUpdateNotifications;
  bool get receiveTitleUpdateNotifications =>
      _receiveTitleUpdateNotifications ?? false;
  bool hasReceiveTitleUpdateNotifications() =>
      _receiveTitleUpdateNotifications != null;

  // Social Connections
  List<String>? _friends;
  List<String> get friends => _friends ?? const [];
  bool hasFriends() => _friends != null;

  // Deprecated: kept for backwards compatibility
  @Deprecated('Use friends instead')
  List<String> get frinds => friends;
  @Deprecated('Use hasFriends instead')
  bool hasFrinds() => hasFriends();

  List<String>? _activeChats;
  List<String> get activeChats => _activeChats ?? const [];
  bool hasActiveChats() => _activeChats != null;

  List<String>? _groupChats;
  List<String> get groupChats => _groupChats ?? const [];
  bool hasGroupChats() => _groupChats != null;

  // System Fields
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  Map<String, dynamic>? _stats;
  Map<String, dynamic> get stats => _stats ?? const {};
  bool hasStats() => _stats != null;

  Map<String, dynamic>? _subscription;
  Map<String, dynamic> get subscription => _subscription ?? const {};
  bool hasSubscription() => _subscription != null;

  void _initializeFields() {
    // Support both snake_case (legacy) and camelCase (new) field names
    _uid = snapshotData['uid'] as String?;
    _email = snapshotData['email'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _pointsA = castToType<int>(snapshotData['pointsA']);
    _pointsQ = castToType<int>(snapshotData['pointsQ']);
    _lastActive = snapshotData['lastActive'] as DateTime?;
    _interests = getDataList(snapshotData['interests']);
    _expertise = getDataList(snapshotData['expertise']);
    _displayName = snapshotData['displayName'] as String?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _photoUrl = snapshotData['photoUrl'] as String?;
    _phoneNumber = snapshotData['phoneNumber'] as String?;
    _isPremiumUser = snapshotData['isPremiumUser'] as bool?;
    _anonymousPostsCount = castToType<int>(snapshotData['anonymousPostsCount']);
    _anonymousCommentsCount =
        castToType<int>(snapshotData['anonymousCommentsCount']);
    _currentRank = snapshotData['currentRank'] as String?;
    _currentTitle = snapshotData['currentTitle'] as String?;
    _rankChangeDate = snapshotData['rankChangeDate'] as DateTime?;
    _titleChangeDate = snapshotData['titleChangeDate'] as DateTime?;
    _isRankEligible = snapshotData['isRankEligible'] as bool?;
    _rankEvaluationCount = castToType<int>(snapshotData['rankEvaluationCount']);
    _rankHistory = getDataList(snapshotData['rankHistory']);
    _titleHistory = getDataList(snapshotData['titleHistory']);
    _receiveRankUpdateNotifications =
        snapshotData['receiveRankUpdateNotifications'] as bool?;
    _receiveTitleUpdateNotifications =
        snapshotData['receiveTitleUpdateNotifications'] as bool?;
    _anonymousQuestionCount =
        castToType<int>(snapshotData['anonymousQuestionCount']);
    _friends = getDataList(snapshotData['friends']);
    _activeChats = getDataList(snapshotData['activeChats']);
    _groupChats = getDataList(snapshotData['groupChats']);
    _totalAPoints = castToType<int>(snapshotData['totalAPoints']);
    _totalQPoints = castToType<int>(snapshotData['totalQPoints']);
    _shortDescription = snapshotData['shortDescription'] as String?;
    _lastActiveTime = snapshotData['lastActiveTime'] as DateTime?;
    _role = snapshotData['role'] as String?;
    _title = snapshotData['title'] as String?;
    _gender = snapshotData['gender'] as String?;
    _dateOfBirth = snapshotData['dateOfBirth'] as DateTime?;
    _language = snapshotData['Language'] as String?;
    _stats = snapshotData['stats'] as Map<String, dynamic>?;
    _subscription = snapshotData['subscription'] as Map<String, dynamic>?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UserProfile> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserProfile.fromSnapshot(s));

  static Future<UserProfile> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserProfile.fromSnapshot(s));

  static UserProfile fromSnapshot(DocumentSnapshot snapshot) => UserProfile._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserProfile getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserProfile._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserProfile(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserProfile &&
      reference.path.hashCode == other.reference.path.hashCode;
}

/// Factory function to create UserProfile data for Firestore
Map<String, dynamic> createUserProfileData({
  String? uid,
  String? email,
  LatLng? location,
  int? pointsA,
  int? pointsQ,
  DateTime? lastActive,
  List<String>? interests,
  List<String>? expertise,
  String? displayName,
  DateTime? createdTime,
  String? photoUrl,
  String? phoneNumber,
  bool? isPremiumUser,
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
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'lastActive': lastActive,
      'interests': interests,
      'expertise': expertise,
      'displayName': displayName,
      'createdTime': createdTime,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isPremiumUser': isPremiumUser,
      'anonymousPostsCount': anonymousPostsCount,
      'anonymousCommentsCount': anonymousCommentsCount,
      'currentRank': currentRank,
      'currentTitle': currentTitle,
      'rankChangeDate': rankChangeDate,
      'titleChangeDate': titleChangeDate,
      'isRankEligible': isRankEligible,
      'rankEvaluationCount': rankEvaluationCount,
      'receiveRankUpdateNotifications': receiveRankUpdateNotifications,
      'receiveTitleUpdateNotifications': receiveTitleUpdateNotifications,
      'anonymousQuestionCount': anonymousQuestionCount,
      'totalAPoints': totalAPoints,
      'totalQPoints': totalQPoints,
      'shortDescription': shortDescription,
      'lastActiveTime': lastActiveTime,
      'role': role,
      'title': title,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'language': language,
      'stats': stats,
      'subscription': subscription,
    }.withoutNulls,
  );

  return firestoreData;
}

/// Document equality implementation for UserProfile
class UserProfileDocumentEquality implements Equality<UserProfile> {
  const UserProfileDocumentEquality();

  @override
  bool equals(UserProfile? e1, UserProfile? e2) {
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
        e1?.isPremiumUser == e2?.isPremiumUser &&
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
        listEquality.equals(e1?.friends, e2?.friends) &&
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
  int hash(UserProfile? e) => const ListEquality().hash([
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
        e?.isPremiumUser,
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
        e?.friends,
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
  bool isValidKey(Object? o) => o is UserProfile;
}

// Backward compatibility aliases
typedef UsersModel = UserProfile;
typedef UsersModelDocumentEquality = UserProfileDocumentEquality;
Map<String, dynamic> createUsersModelData({
  String? uid,
  String? email,
  LatLng? location,
  int? pointsA,
  int? pointsQ,
  DateTime? lastActive,
  List<String>? interests,
  List<String>? expertise,
  String? displayName,
  DateTime? createdTime,
  String? photoUrl,
  String? phoneNumber,
  bool? isPremiumUser,
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
}) =>
    createUserProfileData(
      uid: uid,
      email: email,
      location: location,
      pointsA: pointsA,
      pointsQ: pointsQ,
      lastActive: lastActive,
      interests: interests,
      expertise: expertise,
      displayName: displayName,
      createdTime: createdTime,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      isPremiumUser: isPremiumUser,
      anonymousPostsCount: anonymousPostsCount,
      anonymousCommentsCount: anonymousCommentsCount,
      currentRank: currentRank,
      currentTitle: currentTitle,
      rankChangeDate: rankChangeDate,
      titleChangeDate: titleChangeDate,
      isRankEligible: isRankEligible,
      rankEvaluationCount: rankEvaluationCount,
      receiveRankUpdateNotifications: receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: receiveTitleUpdateNotifications,
      anonymousQuestionCount: anonymousQuestionCount,
      totalAPoints: totalAPoints,
      totalQPoints: totalQPoints,
      shortDescription: shortDescription,
      lastActiveTime: lastActiveTime,
      role: role,
      title: title,
      gender: gender,
      dateOfBirth: dateOfBirth,
      language: language,
      stats: stats,
      subscription: subscription,
    );
