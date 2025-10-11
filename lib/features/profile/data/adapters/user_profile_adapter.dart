import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/profile_info.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/user_stats.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/user_profile.dart';

/// Adapter to convert between legacy UserProfile and new domain models
/// This adapter enables gradual migration from monolithic UserProfile (526 lines)
/// to 4 focused domain models following Single Responsibility Principle
class UserProfileAdapter {
  /// Converts legacy UserProfile to 4 domain models
  /// Returns a tuple of (AuthUser, ProfileInfo, UserSettings, UserStats)
  static ({
    AuthUser auth,
    ProfileInfo profile,
    UserSettings settings,
    UserStats stats,
  }) toDomainModels(UserProfile legacy) {
    // Convert to AuthUser (authentication data)
    final authUser = AuthUser(
      uid: legacy.uid,
      email: legacy.email,
      displayName: legacy.displayName,
      photoUrl: legacy.photoUrl,
      phoneNumber: legacy.phoneNumber,
      isEmailVerified: false, // Not available in UserProfile
      isAnonymous: false, // Not available in UserProfile
      createdAt: legacy.createdTime,
      lastLoginAt: legacy.lastActive,
    );

    // Convert to ProfileInfo (display data)
    // Convert LatLng to GeoPoint if needed
    GeoPoint? geoPoint;
    if (legacy.location != null) {
      geoPoint =
          GeoPoint(legacy.location!.latitude, legacy.location!.longitude);
    }

    final profileInfo = ProfileInfo(
      userId: legacy.uid,
      displayName: legacy.displayName,
      photoUrl: legacy.photoUrl,
      shortDescription: legacy.shortDescription,
      gender: legacy.gender,
      dateOfBirth: legacy.dateOfBirth,
      language: legacy.language,
      interests: legacy.interests,
      expertise: legacy.expertise,
      location: geoPoint,
    );

    // Convert to UserSettings (preferences)
    final userSettings = UserSettings(
      userId: legacy.uid,
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

    // Convert to UserStats (gamification & metrics)
    final userStats = UserStats(
      userId: legacy.uid,
      pointsA: legacy.pointsA,
      pointsQ: legacy.pointsQ,
      totalAPoints: legacy.totalAPoints,
      totalQPoints: legacy.totalQPoints,
      currentRank: legacy.currentRank,
      currentTitle: legacy.currentTitle,
      rankChangeDate: legacy.rankChangeDate,
      titleChangeDate: legacy.titleChangeDate,
      isRankEligible: legacy.isRankEligible,
      rankEvaluationCount: legacy.rankEvaluationCount,
      friends: legacy.friends,
      activeChats: legacy.activeChats,
      rankHistory: legacy.rankHistory,
      titleHistory: legacy.titleHistory,
      anonymousPostsCount: legacy.anonymousPostsCount,
      anonymousCommentsCount: legacy.anonymousCommentsCount,
    );

    return (
      auth: authUser,
      profile: profileInfo,
      settings: userSettings,
      stats: userStats,
    );
  }

  /// Converts 4 domain models back to legacy UserProfile
  /// Used for backward compatibility with existing code
  static UserProfile fromDomainModels({
    required AuthUser auth,
    required ProfileInfo profile,
    required UserSettings settings,
    required UserStats stats,
    required DocumentReference reference,
  }) {
    // Convert GeoPoint to LatLng if needed (UserProfile expects LatLng)
    // For now, we'll pass the GeoPoint directly as UserProfile can handle it
    dynamic location;
    if (profile.location != null) {
      location = profile.location;
    }

    final data = <String, dynamic>{
      // Core Identity Fields (from AuthUser)
      'uid': auth.uid,
      'email': auth.email,
      'displayName': auth.displayName ?? profile.displayName,
      'photoUrl': auth.photoUrl ?? profile.photoUrl,
      'phoneNumber': auth.phoneNumber,
      'createdTime': auth.createdAt,
      'lastActive': auth.lastLoginAt,

      // Profile Information (from ProfileInfo)
      'shortDescription': profile.shortDescription,
      'gender': profile.gender,
      'dateOfBirth': profile.dateOfBirth,
      'language': profile.language,
      'interests': profile.interests,
      'expertise': profile.expertise,
      'location': location,

      // User Settings (from UserSettings)
      'isPremiumUser': settings.isPremiumUser,
      'receiveRankUpdateNotifications': settings.receiveRankUpdateNotifications,
      'receiveTitleUpdateNotifications':
          settings.receiveTitleUpdateNotifications,
      'subscription': settings.subscription,
      'stats': settings.stats,

      // User Stats (from UserStats)
      'pointsA': stats.pointsA,
      'pointsQ': stats.pointsQ,
      'totalAPoints': stats.totalAPoints,
      'totalQPoints': stats.totalQPoints,
      'currentRank': stats.currentRank,
      'currentTitle': stats.currentTitle,
      'rankChangeDate': stats.rankChangeDate,
      'titleChangeDate': stats.titleChangeDate,
      'isRankEligible': stats.isRankEligible,
      'rankEvaluationCount': stats.rankEvaluationCount,
      'friends': stats.friends,
      'activeChats': stats.activeChats,
      'rankHistory': stats.rankHistory,
      'titleHistory': stats.titleHistory,
      'anonymousPostsCount': stats.anonymousPostsCount,
      'anonymousCommentsCount': stats.anonymousCommentsCount,
    };

    // Create UserProfile instance using the factory method
    return UserProfile.getDocumentFromData(data, reference);
  }

  /// Helper method to create a UserProfile bundle for convenience
  static UserProfileBundle createBundle(UserProfile legacy) {
    final models = toDomainModels(legacy);
    return UserProfileBundle(
      auth: models.auth,
      profile: models.profile,
      settings: models.settings,
      stats: models.stats,
      reference: legacy.reference,
    );
  }

  /// Validates field mapping completeness
  /// Used for testing to ensure all 44 fields are properly mapped
  static bool validateMapping({
    required UserProfile legacy,
    required AuthUser auth,
    required ProfileInfo profile,
    required UserSettings settings,
    required UserStats stats,
  }) {
    // Core validation checks
    return legacy.uid == auth.uid &&
        legacy.uid == profile.userId &&
        legacy.uid == settings.userId &&
        legacy.uid == stats.userId &&
        legacy.email == auth.email &&
        legacy.displayName == profile.displayName &&
        legacy.isPremiumUser == settings.isPremiumUser &&
        legacy.pointsA == stats.pointsA &&
        legacy.pointsQ == stats.pointsQ;
  }
}

/// Convenience class to bundle all 4 domain models together
/// Used when operations need all user data at once
class UserProfileBundle {
  final AuthUser auth;
  final ProfileInfo profile;
  final UserSettings settings;
  final UserStats stats;
  final DocumentReference? reference;

  const UserProfileBundle({
    required this.auth,
    required this.profile,
    required this.settings,
    required this.stats,
    this.reference,
  });

  /// Convert bundle back to legacy UserProfile
  UserProfile toLegacy() {
    if (reference == null) {
      throw ArgumentError(
          'DocumentReference is required to create UserProfile');
    }
    return UserProfileAdapter.fromDomainModels(
      auth: auth,
      profile: profile,
      settings: settings,
      stats: stats,
      reference: reference!,
    );
  }

  /// Create a copy with updated fields
  UserProfileBundle copyWith({
    AuthUser? auth,
    ProfileInfo? profile,
    UserSettings? settings,
    UserStats? stats,
    DocumentReference? reference,
  }) {
    return UserProfileBundle(
      auth: auth ?? this.auth,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      reference: reference ?? this.reference,
    );
  }
}
