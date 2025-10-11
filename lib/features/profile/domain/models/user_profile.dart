import '/app/models/lat_lng.dart';

/// UserProfile pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createUserProfileData() 제거 → UserProfileDto.toFirestore()로 이동
/// - UserProfileDocumentEquality 제거 → == operator 사용
/// - @Deprecated 필드 4개 제거
///
/// Represents a user's profile information and system state
class UserProfile {
  // ============= Core Identity Fields =============
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  // ============= Profile Information =============
  final LatLng? location;
  final String? shortDescription;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? language;

  // ============= System Timestamps =============
  final DateTime? createdTime;
  final DateTime? lastActive;
  final DateTime? lastActiveTime;

  // ============= Points System =============
  final int pointsA;
  final int pointsQ;
  final int totalAPoints;
  final int totalQPoints;

  // ============= Interests and Expertise =============
  final List<String> interests;
  final List<String> expertise;
  final List<String> hobbies;
  final String? jobCategory;
  final String? jobName;

  // ============= Premium Status =============
  final bool isPremiumUser;

  // ============= Anonymous Activity Counters =============
  final int anonymousPostsCount;
  final int anonymousCommentsCount;
  final int anonymousQuestionCount;

  // ============= Ranking System =============
  final String? currentRank;
  final String? currentTitle;
  final DateTime? rankChangeDate;
  final DateTime? titleChangeDate;
  final bool isRankEligible;
  final int rankEvaluationCount;
  final List<String> rankHistory;
  final List<String> titleHistory;

  // ============= Notification Settings =============
  final bool receiveRankUpdateNotifications;
  final bool receiveTitleUpdateNotifications;

  // ============= Social Connections =============
  final List<String> friends;
  final List<String> activeChats;
  final List<String> groupChats;

  // ============= System Fields =============
  final String? role;
  final String? title;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> subscription;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.location,
    this.shortDescription,
    this.gender,
    this.dateOfBirth,
    this.language,
    this.createdTime,
    this.lastActive,
    this.lastActiveTime,
    this.pointsA = 0,
    this.pointsQ = 0,
    this.totalAPoints = 0,
    this.totalQPoints = 0,
    this.interests = const [],
    this.expertise = const [],
    this.hobbies = const [],
    this.jobCategory,
    this.jobName,
    this.isPremiumUser = false,
    this.anonymousPostsCount = 0,
    this.anonymousCommentsCount = 0,
    this.anonymousQuestionCount = 0,
    this.currentRank,
    this.currentTitle,
    this.rankChangeDate,
    this.titleChangeDate,
    this.isRankEligible = false,
    this.rankEvaluationCount = 0,
    this.rankHistory = const [],
    this.titleHistory = const [],
    this.receiveRankUpdateNotifications = false,
    this.receiveTitleUpdateNotifications = false,
    this.friends = const [],
    this.activeChats = const [],
    this.groupChats = const [],
    this.role,
    this.title,
    this.stats = const {},
    this.subscription = const {},
  });

  /// Create a copy of this UserProfile with updated fields
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    LatLng? location,
    String? shortDescription,
    String? gender,
    DateTime? dateOfBirth,
    String? language,
    DateTime? createdTime,
    DateTime? lastActive,
    DateTime? lastActiveTime,
    int? pointsA,
    int? pointsQ,
    int? totalAPoints,
    int? totalQPoints,
    List<String>? interests,
    List<String>? expertise,
    List<String>? hobbies,
    String? jobCategory,
    String? jobName,
    bool? isPremiumUser,
    int? anonymousPostsCount,
    int? anonymousCommentsCount,
    int? anonymousQuestionCount,
    String? currentRank,
    String? currentTitle,
    DateTime? rankChangeDate,
    DateTime? titleChangeDate,
    bool? isRankEligible,
    int? rankEvaluationCount,
    List<String>? rankHistory,
    List<String>? titleHistory,
    bool? receiveRankUpdateNotifications,
    bool? receiveTitleUpdateNotifications,
    List<String>? friends,
    List<String>? activeChats,
    List<String>? groupChats,
    String? role,
    String? title,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? subscription,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      shortDescription: shortDescription ?? this.shortDescription,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      language: language ?? this.language,
      createdTime: createdTime ?? this.createdTime,
      lastActive: lastActive ?? this.lastActive,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      pointsA: pointsA ?? this.pointsA,
      pointsQ: pointsQ ?? this.pointsQ,
      totalAPoints: totalAPoints ?? this.totalAPoints,
      totalQPoints: totalQPoints ?? this.totalQPoints,
      interests: interests ?? this.interests,
      expertise: expertise ?? this.expertise,
      hobbies: hobbies ?? this.hobbies,
      jobCategory: jobCategory ?? this.jobCategory,
      jobName: jobName ?? this.jobName,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      anonymousPostsCount: anonymousPostsCount ?? this.anonymousPostsCount,
      anonymousCommentsCount: anonymousCommentsCount ?? this.anonymousCommentsCount,
      anonymousQuestionCount: anonymousQuestionCount ?? this.anonymousQuestionCount,
      currentRank: currentRank ?? this.currentRank,
      currentTitle: currentTitle ?? this.currentTitle,
      rankChangeDate: rankChangeDate ?? this.rankChangeDate,
      titleChangeDate: titleChangeDate ?? this.titleChangeDate,
      isRankEligible: isRankEligible ?? this.isRankEligible,
      rankEvaluationCount: rankEvaluationCount ?? this.rankEvaluationCount,
      rankHistory: rankHistory ?? this.rankHistory,
      titleHistory: titleHistory ?? this.titleHistory,
      receiveRankUpdateNotifications: receiveRankUpdateNotifications ?? this.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: receiveTitleUpdateNotifications ?? this.receiveTitleUpdateNotifications,
      friends: friends ?? this.friends,
      activeChats: activeChats ?? this.activeChats,
      groupChats: groupChats ?? this.groupChats,
      role: role ?? this.role,
      title: title ?? this.title,
      stats: stats ?? this.stats,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  String toString() => 'UserProfile('
      'uid: $uid, '
      'email: $email, '
      'displayName: $displayName, '
      'pointsA: $pointsA, '
      'pointsQ: $pointsQ, '
      'isPremiumUser: $isPremiumUser, '
      'currentRank: $currentRank'
      ')';

  @override
  int get hashCode => Object.hashAll([
        uid,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        location,
        shortDescription,
        gender,
        dateOfBirth,
        language,
        createdTime,
        lastActive,
        lastActiveTime,
        pointsA,
        pointsQ,
        totalAPoints,
        totalQPoints,
        interests,
        expertise,
        hobbies,
        jobCategory,
        jobName,
        isPremiumUser,
        anonymousPostsCount,
        anonymousCommentsCount,
        anonymousQuestionCount,
        currentRank,
        currentTitle,
        rankChangeDate,
        titleChangeDate,
        isRankEligible,
        rankEvaluationCount,
        rankHistory,
        titleHistory,
        receiveRankUpdateNotifications,
        receiveTitleUpdateNotifications,
        friends,
        activeChats,
        groupChats,
        role,
        title,
        stats,
        subscription,
      ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          phoneNumber == other.phoneNumber &&
          location == other.location &&
          shortDescription == other.shortDescription &&
          gender == other.gender &&
          dateOfBirth == other.dateOfBirth &&
          language == other.language &&
          createdTime == other.createdTime &&
          lastActive == other.lastActive &&
          lastActiveTime == other.lastActiveTime &&
          pointsA == other.pointsA &&
          pointsQ == other.pointsQ &&
          totalAPoints == other.totalAPoints &&
          totalQPoints == other.totalQPoints &&
          _listEquals(interests, other.interests) &&
          _listEquals(expertise, other.expertise) &&
          _listEquals(hobbies, other.hobbies) &&
          jobCategory == other.jobCategory &&
          jobName == other.jobName &&
          isPremiumUser == other.isPremiumUser &&
          anonymousPostsCount == other.anonymousPostsCount &&
          anonymousCommentsCount == other.anonymousCommentsCount &&
          anonymousQuestionCount == other.anonymousQuestionCount &&
          currentRank == other.currentRank &&
          currentTitle == other.currentTitle &&
          rankChangeDate == other.rankChangeDate &&
          titleChangeDate == other.titleChangeDate &&
          isRankEligible == other.isRankEligible &&
          rankEvaluationCount == other.rankEvaluationCount &&
          _listEquals(rankHistory, other.rankHistory) &&
          _listEquals(titleHistory, other.titleHistory) &&
          receiveRankUpdateNotifications == other.receiveRankUpdateNotifications &&
          receiveTitleUpdateNotifications == other.receiveTitleUpdateNotifications &&
          _listEquals(friends, other.friends) &&
          _listEquals(activeChats, other.activeChats) &&
          _listEquals(groupChats, other.groupChats) &&
          role == other.role &&
          title == other.title &&
          _mapEquals(stats, other.stats) &&
          _mapEquals(subscription, other.subscription);

  // Helper methods for equality comparison
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

// Backward compatibility aliases
@Deprecated('Use UserProfile instead')
typedef UsersModel = UserProfile;
