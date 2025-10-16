import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/profile_info.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/user_profile.dart';

/// Adapter to convert between legacy UserProfile and new domain models (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20 Phase 6):
/// - AuthUser 타입 제거 (Auth Feature 의존성 격리)
/// - auth 필드를 Map<String, dynamic>으로 변경
/// - Feature 간 의존성 완전 제거
///
/// This adapter enables gradual migration from monolithic UserProfile (526 lines)
/// to 3 focused domain models following Single Responsibility Principle
class UserProfileAdapter {
  /// Converts legacy UserProfile to 3 domain models
  /// Returns a tuple of (Map auth, ProfileInfo, UserSettings)
  static ({
    Map<String, dynamic> auth,
    ProfileInfo profile,
    UserSettings settings,
  }) toDomainModels(UserProfile legacy) {
    // Convert to Auth data map (authentication data)
    // 필드: uid, email, displayName, photoUrl, phoneNumber,
    //       isEmailVerified, isAnonymous, createdAt, lastLoginAt
    final authData = <String, dynamic>{
      'uid': legacy.uid,
      'email': legacy.email,
      'displayName': legacy.displayName,
      'photoUrl': legacy.photoUrl,
      'phoneNumber': legacy.phoneNumber,
      'isEmailVerified': false, // Not available in UserProfile
      'isAnonymous': false, // Not available in UserProfile
      'createdAt': legacy.createdTime,
      'lastLoginAt': legacy.lastActive,
    };

    // Convert to ProfileInfo (display data)
    final profileInfo = ProfileInfo(
      userId: legacy.uid, // uid is non-null String
      displayName: legacy.displayName ?? '',
      photoUrl: legacy.photoUrl,
      shortDescription: legacy.shortDescription,
      gender: legacy.gender,
      dateOfBirth: legacy.dateOfBirth,
      language: legacy.language ?? 'en', // Default to 'en' if null
      interests: legacy.interests,
      expertise: legacy.expertise,
      location: legacy.location, // Both use LatLng now
    );

    // Convert to UserSettings (preferences)
    final userSettings = UserSettings(
      userId: legacy.uid, // uid is non-null String
      isPremiumUser: legacy.isPremiumUser,
      receiveRankUpdateNotifications: legacy.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: legacy.receiveTitleUpdateNotifications,
      receiveVoteNotifications: true, // Default, not in UserProfile
      receiveCommentNotifications: true, // Default, not in UserProfile
      receiveFriendNotifications: true, // Default, not in UserProfile
      subscription: legacy.subscription,
      stats: legacy.stats,
      privacySettings: const {}, // Not available in UserProfile
    );

    return (
      auth: authData,
      profile: profileInfo,
      settings: userSettings,
    );
  }

  /// Converts 3 domain models back to legacy UserProfile
  /// Used for backward compatibility with existing code
  ///
  /// **변경사항** (2025-01-20 Phase 6):
  /// - getDocumentFromData 제거 (Phase 1에서 FirestoreRecord 제거됨)
  /// - 직접 UserProfile 생성자 사용
  /// - reference 파라미터는 UserProfileBundle에서만 사용
  ///
  /// **변경사항** (2025-01-20 Phase 2):
  /// - UserStats 파라미터 제거
  /// - 포인트/랭킹 필드는 기본값 사용 (향후 필요시 재구현)
  static UserProfile fromDomainModels({
    required Map<String, dynamic> auth,
    required ProfileInfo profile,
    required UserSettings settings,
    required DocumentReference? reference,
  }) {
    // Create UserProfile instance using the constructor
    return UserProfile(
      // Core Identity Fields (from Auth data)
      uid: auth['uid'] as String,
      email: auth['email'] as String,
      displayName: (auth['displayName'] as String?) ?? profile.displayName,
      photoUrl: (auth['photoUrl'] as String?) ?? profile.photoUrl,
      phoneNumber: auth['phoneNumber'] as String?,
      createdTime: auth['createdAt'] as DateTime?,
      lastActive: auth['lastLoginAt'] as DateTime?,

      // Profile Information (from ProfileInfo)
      shortDescription: profile.shortDescription,
      gender: profile.gender,
      dateOfBirth: profile.dateOfBirth,
      language: profile.language,
      interests: profile.interests,
      expertise: profile.expertise,
      location: profile.location, // Both use LatLng now
      hobbies: const [], // Not in domain models

      // User Settings (from UserSettings)
      isPremiumUser: settings.isPremiumUser,
      receiveRankUpdateNotifications: settings.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications:
          settings.receiveTitleUpdateNotifications,
      subscription: settings.subscription,
      stats: settings.stats,

      // User Stats: 기본값 사용 (향후 Stats Feature 구현 시 복구)
      // pointsA, pointsQ, totalAPoints, totalQPoints = 0
      // currentRank, currentTitle = null
      // isRankEligible = false
      // rankEvaluationCount = 0
      // rankHistory, titleHistory, friends, activeChats = []
      // anonymousPostsCount, anonymousCommentsCount = 0
    );
  }

  /// Validates field mapping completeness
  /// Used for testing to ensure core fields are properly mapped
  static bool validateMapping({
    required UserProfile legacy,
    required Map<String, dynamic> auth,
    required ProfileInfo profile,
    required UserSettings settings,
  }) {
    // Core validation checks
    return legacy.uid == auth['uid'] &&
        legacy.uid == profile.userId &&
        legacy.uid == settings.userId &&
        legacy.email == auth['email'] &&
        legacy.displayName == profile.displayName &&
        legacy.isPremiumUser == settings.isPremiumUser;
  }
}
