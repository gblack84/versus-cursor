import '../../domain/models/user_settings.dart';
import '../models/user_settings_dto.dart';

/// UserSettings Mapper
///
/// **책임**: DTO와 Domain Model 간 양방향 변환
class UserSettingsMapper {
  /// DTO → Domain Model
  static UserSettings toDomain(UserSettingsDto dto) {
    return UserSettings(
      userId: dto.userId ?? '',
      isPremiumUser: dto.isPremiumUser ?? false,
      receiveRankUpdateNotifications:
          dto.receiveRankUpdateNotifications ?? true,
      receiveTitleUpdateNotifications:
          dto.receiveTitleUpdateNotifications ?? true,
      receiveVoteNotifications: dto.receiveVoteNotifications ?? true,
      receiveCommentNotifications: dto.receiveCommentNotifications ?? true,
      receiveFriendNotifications: dto.receiveFriendNotifications ?? true,
      subscription: dto.subscription ?? const {},
      stats: dto.stats ?? const {},
      privacySettings: dto.privacySettings ?? const {},
    );
  }

  /// Domain Model → DTO
  static UserSettingsDto fromDomain(UserSettings settings) {
    return UserSettingsDto(
      userId: settings.userId,
      isPremiumUser: settings.isPremiumUser,
      receiveRankUpdateNotifications: settings.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: settings.receiveTitleUpdateNotifications,
      receiveVoteNotifications: settings.receiveVoteNotifications,
      receiveCommentNotifications: settings.receiveCommentNotifications,
      receiveFriendNotifications: settings.receiveFriendNotifications,
      subscription:
          settings.subscription.isNotEmpty ? settings.subscription : null,
      stats: settings.stats.isNotEmpty ? settings.stats : null,
      privacySettings: settings.privacySettings.isNotEmpty
          ? settings.privacySettings
          : null,
    );
  }
}
