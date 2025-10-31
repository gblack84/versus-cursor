import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// UserSettings Domain Model
/// Clean Architecture - Domain Layer Entity
///
/// **변경사항** (2025-01-20):
/// - Freezed sealed class로 전환 (148줄 → 81줄, 45% 감소)
/// - copyWith, toString, hashCode, == 자동 생성
/// - fromJson/toJson 자동 생성
/// - 39줄의 boilerplate 코드 제거
/// - 비즈니스 로직 getter 유지 (hasAnyNotificationEnabled, notificationSettings)
///
/// This model contains user preferences, notification settings,
/// and subscription information, separated from profile data
/// and authentication for better separation of concerns.
@freezed
sealed class UserSettings with _$UserSettings {
  const UserSettings._();

  const factory UserSettings({
    // Core Fields
    required String userId, // Foreign key to AuthUser.uid

    // Premium Status
    @Default(false) bool isPremiumUser,

    // Notification Preferences
    @Default(true) bool receiveRankUpdateNotifications,
    @Default(true) bool receiveTitleUpdateNotifications,
    @Default(true) bool receiveVoteNotifications,
    @Default(true) bool receiveCommentNotifications,
    @Default(true) bool receiveFriendNotifications,

    // Complex Settings
    @Default({}) Map<String, dynamic> subscription, // Subscription details
    @Default({}) Map<String, dynamic> stats, // User statistics preferences
    @Default({}) Map<String, dynamic> privacySettings, // Privacy configurations
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  /// Create UserSettings from Map (Firestore or cache)
  factory UserSettings.fromMap(Map<String, dynamic> data, String userId) {
    return UserSettings(
      userId: userId,
      isPremiumUser: data['isPremiumUser'] ?? false,
      receiveRankUpdateNotifications:
          data['receiveRankUpdateNotifications'] ?? true,
      receiveTitleUpdateNotifications:
          data['receiveTitleUpdateNotifications'] ?? true,
      receiveVoteNotifications: data['receiveVoteNotifications'] ?? true,
      receiveCommentNotifications: data['receiveCommentNotifications'] ?? true,
      receiveFriendNotifications: data['receiveFriendNotifications'] ?? true,
      subscription: Map<String, dynamic>.from(data['subscription'] ?? {}),
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
      privacySettings: Map<String, dynamic>.from(data['privacySettings'] ?? {}),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'isPremiumUser': isPremiumUser,
      'receiveRankUpdateNotifications': receiveRankUpdateNotifications,
      'receiveTitleUpdateNotifications': receiveTitleUpdateNotifications,
      'receiveVoteNotifications': receiveVoteNotifications,
      'receiveCommentNotifications': receiveCommentNotifications,
      'receiveFriendNotifications': receiveFriendNotifications,
      if (subscription.isNotEmpty) 'subscription': subscription,
      if (stats.isNotEmpty) 'stats': stats,
      if (privacySettings.isNotEmpty) 'privacySettings': privacySettings,
    };
  }

  // ============= Business Logic Getters =============

  /// Check if user has any notification enabled
  bool get hasAnyNotificationEnabled =>
      receiveRankUpdateNotifications ||
      receiveTitleUpdateNotifications ||
      receiveVoteNotifications ||
      receiveCommentNotifications ||
      receiveFriendNotifications;

  /// Get all notification settings as a map
  Map<String, bool> get notificationSettings => {
        'rankUpdates': receiveRankUpdateNotifications,
        'titleUpdates': receiveTitleUpdateNotifications,
        'votes': receiveVoteNotifications,
        'comments': receiveCommentNotifications,
        'friends': receiveFriendNotifications,
      };
}
