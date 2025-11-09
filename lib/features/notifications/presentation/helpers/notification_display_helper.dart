import 'package:flutter/material.dart';
import '/app/types/notification_types.dart';

/// Helper for notification display information (titles, icons)
///
/// Clean Architecture - Presentation Layer Helper
/// Keeps UI concerns (icons, display strings) separate from domain logic
///
/// Example:
/// ```dart
/// final title = NotificationDisplayHelper.getTitle(notification.type);
/// final icon = NotificationDisplayHelper.getIcon(notification.type);
/// ```
class NotificationDisplayHelper {
  /// Get localized display title for notification type
  ///
  /// Returns user-friendly Korean titles for each notification type
  static String getTitle(String type) {
    switch (type) {
      // Voting Feature types
      case NotificationTypes.votingRequest:
        return '투표 요청';

      // Social Feature types
      case NotificationTypes.postLiked:
        return '좋아요';
      case NotificationTypes.commentAdded:
        return '댓글';
      case NotificationTypes.friendRequest:
        return '친구 요청';

      // System Feature types
      case NotificationTypes.systemAlert:
        return '시스템 알림';
      case NotificationTypes.postCompleted:
        return '투표 완료';
      case NotificationTypes.achievementUnlocked:
        return '업적 달성';

      default:
        return '알림';
    }
  }

  /// Get Material icon for notification type
  ///
  /// Returns semantically appropriate icons from Material Design
  static IconData getIcon(String type) {
    switch (type) {
      // Voting Feature types
      case NotificationTypes.votingRequest:
        return Icons.how_to_vote;

      // Social Feature types
      case NotificationTypes.postLiked:
        return Icons.favorite;
      case NotificationTypes.commentAdded:
        return Icons.comment;
      case NotificationTypes.friendRequest:
        return Icons.person_add;

      // System Feature types
      case NotificationTypes.systemAlert:
        return Icons.info;
      case NotificationTypes.postCompleted:
        return Icons.check_circle;
      case NotificationTypes.achievementUnlocked:
        return Icons.emoji_events;

      default:
        return Icons.notifications;
    }
  }

  /// Private constructor to prevent instantiation
  /// This is a utility class with only static methods
  NotificationDisplayHelper._();
}
