import 'package:go_router/go_router.dart';
import '../screens/notifications_list/notifications_list_widget.dart';
import '../screens/voting_notifications/voting_notifications_widget.dart';
import '../screens/social_notifications/social_notifications_widget.dart';
import '../screens/system_notifications/system_notifications_widget.dart';

/// Notification feature routes configuration
///
/// This module encapsulates all notification-related routes,
/// following the Feature-First Architecture pattern.
/// Routes are exported as a static list to be included in the main router.
class NotificationRoutes {
  /// Private constructor to prevent instantiation
  NotificationRoutes._();

  /// List of all notification-related routes
  static List<GoRoute> get routes => [
    GoRoute(
      name: 'notificationsList',
      path: '/notifications',
      builder: (context, state) => NotificationsListWidget(),
    ),
    GoRoute(
      name: 'votingNotifications',
      path: '/notifications/voting',
      builder: (context, state) => const VotingNotificationsWidget(),
    ),
    GoRoute(
      name: 'socialNotifications',
      path: '/notifications/social',
      builder: (context, state) => const SocialNotificationsWidget(),
    ),
    GoRoute(
      name: 'systemNotifications',
      path: '/notifications/system',
      builder: (context, state) => const SystemNotificationsWidget(),
    ),
  ];

  /// Route names for type-safe navigation
  static const String notificationsList = 'notificationsList';
  static const String votingNotifications = 'votingNotifications';
  static const String socialNotifications = 'socialNotifications';
  static const String systemNotifications = 'systemNotifications';

  /// Route paths for direct navigation
  static const String notificationsListPath = '/notifications';
  static const String votingNotificationsPath = '/notifications/voting';
  static const String socialNotificationsPath = '/notifications/social';
  static const String systemNotificationsPath = '/notifications/system';
}