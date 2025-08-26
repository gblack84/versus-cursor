// Example of how to navigate to the NotificationsListWidget

import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/pages/notifications_list/notifications_list_widget.dart';

class NavigationExample {
  // Navigate to notifications list (replacement - removes current route)
  static void navigateToNotificationsList(BuildContext context) {
    context.goNamed(NotificationsListWidget.routeName);
  }
  
  // Push notifications list (keeps current route in stack)
  static void pushNotificationsList(BuildContext context) {
    context.pushNamed(NotificationsListWidget.routeName);
  }
  
  // Navigate with authentication check
  static void navigateWithAuth(BuildContext context, bool mounted) {
    context.goNamedAuth(
      NotificationsListWidget.routeName,
      mounted,
    );
  }
  
  // Push with authentication check
  static void pushWithAuth(BuildContext context, bool mounted) {
    context.pushNamedAuth(
      NotificationsListWidget.routeName,
      mounted,
    );
  }
}

// Example usage in a widget:
/*
IconButton(
  icon: Icon(Icons.notifications),
  onPressed: () {
    // Simple navigation
    context.pushNamed(NotificationsListWidget.routeName);
    
    // Or with auth check
    context.pushNamedAuth(
      NotificationsListWidget.routeName,
      mounted,
    );
  },
)
*/