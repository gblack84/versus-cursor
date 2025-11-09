import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart';
import 'profile_info.dart';
import 'user_settings.dart';
import '/features/profile/domain/failures/profile_failure.dart';
import '/app/types/lat_lng.dart';

/// UserProfile Extension for Firestore conversion
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Repository에서 직접 Firebase SDK 사용
/// - Extension으로 Entity ↔ Firestore 변환
/// - Adapter/Mapper 불필요
///
/// **Auth Feature 참조**:
/// ```dart
/// // lib/features/auth/domain/entities/auth_user_extensions.dart
/// extension AuthUserFirestore on AuthUser {
///   static AuthUser fromFirebaseUser(User firebaseUser) { ... }
/// }
/// ```
extension UserProfileFirestore on UserProfile {
  /// Firestore DocumentSnapshot → UserProfile
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(userId)
  ///     .get();
  ///
  /// final profile = UserProfileFirestore.fromFirestore(doc);
  /// ```
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return UserProfile(
      // Core Identity
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,

      // Profile Information
      location: _parseLatLng(data['location']),
      country: data['country'] as String?,
      countryCode: data['countryCode'] as String?,
      shortDescription: data['shortDescription'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      language: data['language'] as String?,

      // System Timestamps
      createdTime: (data['createdTime'] as Timestamp?)?.toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      lastActiveTime: (data['lastActiveTime'] as Timestamp?)?.toDate(),

      // Points System
      pointsA: data['pointsA'] as int? ?? 0,
      pointsQ: data['pointsQ'] as int? ?? 0,
      totalAPoints: data['totalAPoints'] as int? ?? 0,
      totalQPoints: data['totalQPoints'] as int? ?? 0,

      // Interests and Expertise
      interests: _parseStringList(data['interests']),
      expertise: _parseStringList(data['expertise']),
      hobbies: _parseStringList(data['hobbies']),
      jobCategory: data['jobCategory'] as String?,
      jobName: data['jobName'] as String?,

      // Premium Status
      isPremiumUser: data['isPremiumUser'] as bool? ?? false,

      // Anonymous Activity Counters
      anonymousPostsCount: data['anonymousPostsCount'] as int? ?? 0,
      anonymousCommentsCount: data['anonymousCommentsCount'] as int? ?? 0,
      anonymousQuestionCount: data['anonymousQuestionCount'] as int? ?? 0,

      // Ranking System
      currentRank: data['currentRank'] as String?,
      currentTitle: data['currentTitle'] as String?,
      rankChangeDate: (data['rankChangeDate'] as Timestamp?)?.toDate(),
      titleChangeDate: (data['titleChangeDate'] as Timestamp?)?.toDate(),
      isRankEligible: data['isRankEligible'] as bool? ?? false,
      rankEvaluationCount: data['rankEvaluationCount'] as int? ?? 0,
      rankHistory: _parseStringList(data['rankHistory']),
      titleHistory: _parseStringList(data['titleHistory']),

      // Notification Settings
      receiveRankUpdateNotifications:
          data['receiveRankUpdateNotifications'] as bool? ?? false,
      receiveTitleUpdateNotifications:
          data['receiveTitleUpdateNotifications'] as bool? ?? false,

      // Character Selection
      characterId: data['characterId'] as String?,

      // Social Connections
      friends: _parseStringList(data['friends']),
      activeChats: _parseStringList(data['activeChats']),
      groupChats: _parseStringList(data['groupChats']),

      // System Fields
      role: data['role'] as String?,
      title: data['title'] as String?,
      stats: _parseMap(data['stats']),
      subscription: _parseMap(data['subscription']),
    );
  }

  /// UserProfile → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final profile = UserProfile(...);
  /// final data = profile.toFirestore();
  ///
  /// await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(userId)
  ///     .set(data);
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // Core Identity (uid는 document ID로 사용되므로 제외)
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,

      // Profile Information
      if (location != null)
        'location': {
          'latitude': location!.latitude,
          'longitude': location!.longitude,
        },
      if (country != null) 'country': country,
      if (countryCode != null) 'countryCode': countryCode,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null)
        'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (language != null) 'language': language,

      // System Timestamps
      'createdTime': createdTime != null
          ? Timestamp.fromDate(createdTime!)
          : FieldValue.serverTimestamp(),
      'lastActive': lastActive != null
          ? Timestamp.fromDate(lastActive!)
          : FieldValue.serverTimestamp(),
      'lastActiveTime': lastActiveTime != null
          ? Timestamp.fromDate(lastActiveTime!)
          : FieldValue.serverTimestamp(),

      // Points System
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'totalAPoints': totalAPoints,
      'totalQPoints': totalQPoints,

      // Interests and Expertise
      'interests': interests,
      'expertise': expertise,
      'hobbies': hobbies,
      if (jobCategory != null) 'jobCategory': jobCategory,
      if (jobName != null) 'jobName': jobName,

      // Premium Status
      'isPremiumUser': isPremiumUser,

      // Anonymous Activity Counters
      'anonymousPostsCount': anonymousPostsCount,
      'anonymousCommentsCount': anonymousCommentsCount,
      'anonymousQuestionCount': anonymousQuestionCount,

      // Ranking System
      if (currentRank != null) 'currentRank': currentRank,
      if (currentTitle != null) 'currentTitle': currentTitle,
      if (rankChangeDate != null)
        'rankChangeDate': Timestamp.fromDate(rankChangeDate!),
      if (titleChangeDate != null)
        'titleChangeDate': Timestamp.fromDate(titleChangeDate!),
      'isRankEligible': isRankEligible,
      'rankEvaluationCount': rankEvaluationCount,
      'rankHistory': rankHistory,
      'titleHistory': titleHistory,

      // Notification Settings
      'receiveRankUpdateNotifications': receiveRankUpdateNotifications,
      'receiveTitleUpdateNotifications': receiveTitleUpdateNotifications,

      // Character Selection
      if (characterId != null) 'characterId': characterId,

      // Social Connections
      'friends': friends,
      'activeChats': activeChats,
      'groupChats': groupChats,

      // System Fields
      if (role != null) 'role': role,
      if (title != null) 'title': title,
      if (stats.isNotEmpty) 'stats': stats,
      if (subscription.isNotEmpty) 'subscription': subscription,
    };
  }
}

/// ProfileInfo Extension
extension ProfileInfoFirestore on ProfileInfo {
  static ProfileInfo fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return ProfileInfo(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      shortDescription: data['shortDescription'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      language: data['language'] as String? ?? 'en',
      interests: _parseStringList(data['interests']),
      expertise: _parseStringList(data['expertise']),
      location: _parseLatLng(data['location']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null)
        'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'language': language,
      'interests': interests,
      'expertise': expertise,
      if (location != null)
        'location': {
          'latitude': location!.latitude,
          'longitude': location!.longitude,
        },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Settings Extension
extension UserSettingsFirestore on UserSettings {
  static UserSettings fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ProfileFailure.profileNotFound(userId: doc.id);
    }

    return UserSettings(
      userId: doc.id,
      isPremiumUser: data['isPremiumUser'] as bool? ?? false,
      receiveRankUpdateNotifications:
          data['receiveRankUpdateNotifications'] as bool? ?? true,
      receiveTitleUpdateNotifications:
          data['receiveTitleUpdateNotifications'] as bool? ?? true,
      receiveVoteNotifications: data['receiveVoteNotifications'] as bool? ?? true,
      receiveCommentNotifications:
          data['receiveCommentNotifications'] as bool? ?? true,
      receiveFriendNotifications:
          data['receiveFriendNotifications'] as bool? ?? true,
      subscription: _parseMap(data['subscription']),
      stats: _parseMap(data['stats']),
      privacySettings: _parseMap(data['privacySettings']),
    );
  }

  // toFirestore() 메서드는 이미 UserSettings 클래스에 정의되어 있음
  // Extension에서 중복 정의하지 않음
}

// ============= Helper Functions =============

/// Parse LatLng from Firestore data
LatLng? _parseLatLng(dynamic data) {
  if (data == null) return null;
  if (data is! Map) return null;

  final latitude = data['latitude'] as num?;
  final longitude = data['longitude'] as num?;

  if (latitude == null || longitude == null) return null;

  return LatLng(latitude.toDouble(), longitude.toDouble());
}

/// Parse List<String> from Firestore data
List<String> _parseStringList(dynamic data) {
  if (data == null) return [];
  if (data is! List) return [];
  return List<String>.from(data.map((e) => e.toString()));
}

/// Parse Map<String, dynamic> from Firestore data
Map<String, dynamic> _parseMap(dynamic data) {
  if (data == null) return {};
  if (data is! Map) return {};
  return Map<String, dynamic>.from(data);
}
