import 'package:go_router/go_router.dart';
import '../screens/notifications_list/notifications_list_widget.dart';

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
  ];

  /// Route names for type-safe navigation
  static const String notificationsList = 'notificationsList';

  /// Route paths for direct navigation
  static const String notificationsListPath = '/notifications';
}