/// UserSettings DTO
///
/// **책임**: Firestore 문서 구조와 Dart 객체 간 변환
class UserSettingsDto {
  final String? userId;
  final bool? isPremiumUser;
  final bool? receiveRankUpdateNotifications;
  final bool? receiveTitleUpdateNotifications;
  final bool? receiveVoteNotifications;
  final bool? receiveCommentNotifications;
  final bool? receiveFriendNotifications;
  final Map<String, dynamic>? subscription;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? privacySettings;

  const UserSettingsDto({
    this.userId,
    this.isPremiumUser,
    this.receiveRankUpdateNotifications,
    this.receiveTitleUpdateNotifications,
    this.receiveVoteNotifications,
    this.receiveCommentNotifications,
    this.receiveFriendNotifications,
    this.subscription,
    this.stats,
    this.privacySettings,
  });

  /// Firestore → DTO
  factory UserSettingsDto.fromFirestore(Map<String, dynamic> data) {
    return UserSettingsDto(
      userId: data['userId'] as String?,
      isPremiumUser: data['isPremiumUser'] as bool?,
      receiveRankUpdateNotifications:
          data['receiveRankUpdateNotifications'] as bool?,
      receiveTitleUpdateNotifications:
          data['receiveTitleUpdateNotifications'] as bool?,
      receiveVoteNotifications: data['receiveVoteNotifications'] as bool?,
      receiveCommentNotifications:
          data['receiveCommentNotifications'] as bool?,
      receiveFriendNotifications: data['receiveFriendNotifications'] as bool?,
      subscription: data['subscription'] as Map<String, dynamic>?,
      stats: data['stats'] as Map<String, dynamic>?,
      privacySettings: data['privacySettings'] as Map<String, dynamic>?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (isPremiumUser != null) 'isPremiumUser': isPremiumUser,
      if (receiveRankUpdateNotifications != null)
        'receiveRankUpdateNotifications': receiveRankUpdateNotifications,
      if (receiveTitleUpdateNotifications != null)
        'receiveTitleUpdateNotifications': receiveTitleUpdateNotifications,
      if (receiveVoteNotifications != null)
        'receiveVoteNotifications': receiveVoteNotifications,
      if (receiveCommentNotifications != null)
        'receiveCommentNotifications': receiveCommentNotifications,
      if (receiveFriendNotifications != null)
        'receiveFriendNotifications': receiveFriendNotifications,
      if (subscription != null) 'subscription': subscription,
      if (stats != null) 'stats': stats,
      if (privacySettings != null) 'privacySettings': privacySettings,
    };
  }
}
