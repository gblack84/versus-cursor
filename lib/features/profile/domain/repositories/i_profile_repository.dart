import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_info.dart';
import '../models/user_settings.dart';
import '../models/user_stats.dart';

/// Repository interface for profile operations
/// Extends IUserRepository functionality with profile-specific operations
abstract class IProfileRepository {
  /// Get profile info by user ID
  Future<ProfileInfo?> getProfileInfo(String userId);

  /// Get profile info stream
  Stream<ProfileInfo?> getProfileInfoStream(String userId);

  /// Update profile info
  Future<void> updateProfileInfo(String userId, ProfileInfo profile);

  /// Get user settings
  Future<UserSettings?> getUserSettings(String userId);

  /// Get user settings stream
  Stream<UserSettings?> getUserSettingsStream(String userId);

  /// Update user settings
  Future<void> updateUserSettings(String userId, UserSettings settings);

  /// Get user stats
  Future<UserStats?> getUserStats(String userId);

  /// Get user stats stream
  Stream<UserStats?> getUserStatsStream(String userId);

  /// Update user stats
  Future<void> updateUserStats(String userId, UserStats stats);

  /// Update specific profile field
  Future<void> updateProfileField(String userId, String field, dynamic value);

  /// Update multiple profile fields
  Future<void> updateProfileFields(String userId, Map<String, dynamic> fields);

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String userId, String imagePath);

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String userId);

  /// Check if profile is complete
  Future<bool> isProfileComplete(String userId);

  /// Get profile completion percentage
  Future<double> getProfileCompletionPercentage(String userId);

  /// Search profiles by criteria
  Future<List<ProfileInfo>> searchProfiles({
    String? query,
    List<String>? interests,
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    GeoPoint? userLocation,
    int limit = 20,
  });

  /// Get suggested profiles
  Future<List<ProfileInfo>> getSuggestedProfiles(String userId,
      {int limit = 10});

  /// Block user
  Future<void> blockUser(String userId, String blockedUserId);

  /// Unblock user
  Future<void> unblockUser(String userId, String blockedUserId);

  /// Get blocked users
  Future<List<String>> getBlockedUsers(String userId);

  /// Report user
  Future<void> reportUser(String userId, String reportedUserId, String reason);
}
