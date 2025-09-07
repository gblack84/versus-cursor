/// UserSettings Domain Model
/// Clean Architecture - Domain Layer Entity
/// 
/// This model contains user preferences, notification settings,
/// and subscription information, separated from profile data
/// and authentication for better separation of concerns.
class UserSettings {
  const UserSettings({
    required this.userId,
    this.isPremiumUser = false,
    this.receiveRankUpdateNotifications = true,
    this.receiveTitleUpdateNotifications = true,
    this.receiveVoteNotifications = true,
    this.receiveCommentNotifications = true,
    this.receiveFriendNotifications = true,
    this.subscription = const {},
    this.stats = const {},
    this.privacySettings = const {},
  });

  // Core Fields
  final String userId; // Foreign key to AuthUser.uid
  
  // Premium Status
  final bool isPremiumUser;
  
  // Notification Preferences
  final bool receiveRankUpdateNotifications;
  final bool receiveTitleUpdateNotifications;
  final bool receiveVoteNotifications;
  final bool receiveCommentNotifications;
  final bool receiveFriendNotifications;
  
  // Complex Settings
  final Map<String, dynamic> subscription; // Subscription details
  final Map<String, dynamic> stats; // User statistics preferences
  final Map<String, dynamic> privacySettings; // Privacy configurations

  /// Create UserSettings from Map (Firestore or cache)
  factory UserSettings.fromMap(Map<String, dynamic> data, String userId) {
    return UserSettings(
      userId: userId,
      isPremiumUser: data['isPremiumUser'] ?? false,
      receiveRankUpdateNotifications: data['receiveRankUpdateNotifications'] ?? true,
      receiveTitleUpdateNotifications: data['receiveTitleUpdateNotifications'] ?? true,
      receiveVoteNotifications: data['receiveVoteNotifications'] ?? true,
      receiveCommentNotifications: data['receiveCommentNotifications'] ?? true,
      receiveFriendNotifications: data['receiveFriendNotifications'] ?? true,
      subscription: Map<String, dynamic>.from(data['subscription'] ?? {}),
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
      privacySettings: Map<String, dynamic>.from(data['privacySettings'] ?? {}),
    );
  }

  /// Create UserSettings from JSON (for caching)
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings.fromMap(json, json['userId'] ?? '');
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

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      ...toFirestore(),
    };
  }

  /// Create a copy with updated fields
  UserSettings copyWith({
    String? userId,
    bool? isPremiumUser,
    bool? receiveRankUpdateNotifications,
    bool? receiveTitleUpdateNotifications,
    bool? receiveVoteNotifications,
    bool? receiveCommentNotifications,
    bool? receiveFriendNotifications,
    Map<String, dynamic>? subscription,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? privacySettings,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      receiveRankUpdateNotifications: receiveRankUpdateNotifications ?? this.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: receiveTitleUpdateNotifications ?? this.receiveTitleUpdateNotifications,
      receiveVoteNotifications: receiveVoteNotifications ?? this.receiveVoteNotifications,
      receiveCommentNotifications: receiveCommentNotifications ?? this.receiveCommentNotifications,
      receiveFriendNotifications: receiveFriendNotifications ?? this.receiveFriendNotifications,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserSettings(userId: $userId, premium: $isPremiumUser, notifications: $hasAnyNotificationEnabled)';
  }
}