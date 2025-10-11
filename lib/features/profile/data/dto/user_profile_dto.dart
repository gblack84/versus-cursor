import 'package:cloud_firestore/cloud_firestore.dart';

/// UserProfile DTO (Clean Architecture v4.0)
///
/// **책임**: Firestore 문서 구조와 Dart 객체 간 변환
/// UserProfile의 45개 필드 전체 지원 (hobbies, jobCategory, jobName 추가)
class UserProfileDto {
  // Core Identity Fields
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  // Profile Information
  final GeoPoint? location;
  final String? shortDescription;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? language;

  // System Timestamps
  final DateTime? createdTime;
  final DateTime? lastActive;
  final DateTime? lastActiveTime;

  // Points System
  final int? pointsA;
  final int? pointsQ;
  final int? totalAPoints;
  final int? totalQPoints;

  // Interests and Expertise
  final List<String>? interests;
  final List<String>? expertise;
  final List<String>? hobbies;
  final String? jobCategory;
  final String? jobName;

  // Premium Status
  final bool? isPremiumUser;

  // Anonymous Activity Counters
  final int? anonymousPostsCount;
  final int? anonymousCommentsCount;
  final int? anonymousQuestionCount;

  // Ranking System
  final String? currentRank;
  final String? currentTitle;
  final DateTime? rankChangeDate;
  final DateTime? titleChangeDate;
  final bool? isRankEligible;
  final int? rankEvaluationCount;
  final List<String>? rankHistory;
  final List<String>? titleHistory;

  // Notification Settings
  final bool? receiveRankUpdateNotifications;
  final bool? receiveTitleUpdateNotifications;

  // Social Connections
  final List<String>? friends;
  final List<String>? activeChats;
  final List<String>? groupChats;

  // System Fields
  final String? role;
  final String? title;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? subscription;

  const UserProfileDto({
    this.uid,
    this.email,
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
    this.pointsA,
    this.pointsQ,
    this.totalAPoints,
    this.totalQPoints,
    this.interests,
    this.expertise,
    this.hobbies,
    this.jobCategory,
    this.jobName,
    this.isPremiumUser,
    this.anonymousPostsCount,
    this.anonymousCommentsCount,
    this.anonymousQuestionCount,
    this.currentRank,
    this.currentTitle,
    this.rankChangeDate,
    this.titleChangeDate,
    this.isRankEligible,
    this.rankEvaluationCount,
    this.rankHistory,
    this.titleHistory,
    this.receiveRankUpdateNotifications,
    this.receiveTitleUpdateNotifications,
    this.friends,
    this.activeChats,
    this.groupChats,
    this.role,
    this.title,
    this.stats,
    this.subscription,
  });

  /// Firestore → DTO
  factory UserProfileDto.fromFirestore(Map<String, dynamic> data) {
    return UserProfileDto(
      uid: data['uid'] as String?,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      location: data['location'] as GeoPoint?,
      shortDescription: data['shortDescription'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      language: data['language'] as String?,
      createdTime: (data['createdTime'] as Timestamp?)?.toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      lastActiveTime: (data['lastActiveTime'] as Timestamp?)?.toDate(),
      pointsA: data['pointsA'] as int?,
      pointsQ: data['pointsQ'] as int?,
      totalAPoints: data['totalAPoints'] as int?,
      totalQPoints: data['totalQPoints'] as int?,
      interests: (data['interests'] as List<dynamic>?)?.cast<String>(),
      expertise: (data['expertise'] as List<dynamic>?)?.cast<String>(),
      hobbies: (data['hobbies'] as List<dynamic>?)?.cast<String>(),
      jobCategory: data['jobCategory'] as String?,
      jobName: data['jobName'] as String?,
      isPremiumUser: data['isPremiumUser'] as bool?,
      anonymousPostsCount: data['anonymousPostsCount'] as int?,
      anonymousCommentsCount: data['anonymousCommentsCount'] as int?,
      anonymousQuestionCount: data['anonymousQuestionCount'] as int?,
      currentRank: data['currentRank'] as String?,
      currentTitle: data['currentTitle'] as String?,
      rankChangeDate: (data['rankChangeDate'] as Timestamp?)?.toDate(),
      titleChangeDate: (data['titleChangeDate'] as Timestamp?)?.toDate(),
      isRankEligible: data['isRankEligible'] as bool?,
      rankEvaluationCount: data['rankEvaluationCount'] as int?,
      rankHistory: (data['rankHistory'] as List<dynamic>?)?.cast<String>(),
      titleHistory: (data['titleHistory'] as List<dynamic>?)?.cast<String>(),
      receiveRankUpdateNotifications:
          data['receiveRankUpdateNotifications'] as bool?,
      receiveTitleUpdateNotifications:
          data['receiveTitleUpdateNotifications'] as bool?,
      friends: (data['friends'] as List<dynamic>?)?.cast<String>(),
      activeChats: (data['activeChats'] as List<dynamic>?)?.cast<String>(),
      groupChats: (data['groupChats'] as List<dynamic>?)?.cast<String>(),
      role: data['role'] as String?,
      title: data['title'] as String?,
      stats: data['stats'] as Map<String, dynamic>?,
      subscription: data['subscription'] as Map<String, dynamic>?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (location != null) 'location': location,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null)
        'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (language != null) 'language': language,
      if (createdTime != null) 'createdTime': Timestamp.fromDate(createdTime!),
      if (lastActive != null) 'lastActive': Timestamp.fromDate(lastActive!),
      if (lastActiveTime != null)
        'lastActiveTime': Timestamp.fromDate(lastActiveTime!),
      if (pointsA != null) 'pointsA': pointsA,
      if (pointsQ != null) 'pointsQ': pointsQ,
      if (totalAPoints != null) 'totalAPoints': totalAPoints,
      if (totalQPoints != null) 'totalQPoints': totalQPoints,
      if (interests != null) 'interests': interests,
      if (expertise != null) 'expertise': expertise,
      if (hobbies != null) 'hobbies': hobbies,
      if (jobCategory != null) 'jobCategory': jobCategory,
      if (jobName != null) 'jobName': jobName,
      if (isPremiumUser != null) 'isPremiumUser': isPremiumUser,
      if (anonymousPostsCount != null)
        'anonymousPostsCount': anonymousPostsCount,
      if (anonymousCommentsCount != null)
        'anonymousCommentsCount': anonymousCommentsCount,
      if (anonymousQuestionCount != null)
        'anonymousQuestionCount': anonymousQuestionCount,
      if (currentRank != null) 'currentRank': currentRank,
      if (currentTitle != null) 'currentTitle': currentTitle,
      if (rankChangeDate != null)
        'rankChangeDate': Timestamp.fromDate(rankChangeDate!),
      if (titleChangeDate != null)
        'titleChangeDate': Timestamp.fromDate(titleChangeDate!),
      if (isRankEligible != null) 'isRankEligible': isRankEligible,
      if (rankEvaluationCount != null)
        'rankEvaluationCount': rankEvaluationCount,
      if (rankHistory != null) 'rankHistory': rankHistory,
      if (titleHistory != null) 'titleHistory': titleHistory,
      if (receiveRankUpdateNotifications != null)
        'receiveRankUpdateNotifications': receiveRankUpdateNotifications,
      if (receiveTitleUpdateNotifications != null)
        'receiveTitleUpdateNotifications': receiveTitleUpdateNotifications,
      if (friends != null) 'friends': friends,
      if (activeChats != null) 'activeChats': activeChats,
      if (groupChats != null) 'groupChats': groupChats,
      if (role != null) 'role': role,
      if (title != null) 'title': title,
      if (stats != null) 'stats': stats,
      if (subscription != null) 'subscription': subscription,
    };
  }
}
