# Notification Routes Module

## Overview
This module contains all routing configuration for the Notifications feature, following the Feature-First Architecture pattern.

## Structure

### `notification_routes.dart`
- Contains all notification-related route definitions
- Exports routes to be consumed by the main router
- Maintains feature encapsulation

## Routes

### NotificationsListWidget
- **Path**: `/notifications`
- **Name**: `notificationsList`
- **Auth Required**: Yes
- **Description**: Displays the list of user notifications

## Integration

The notification routes are integrated into the main router at `/lib/app/router/navigation/nav.dart`:

```dart
// Import at the top
import '/features/notifications/presentation/routes/notification_routes.dart';

// Usage in router configuration
...NotificationRoutes.routes,
```

## Migration Details

**Date**: 2025-09-12
**Changes**:
- Extracted NotificationsListWidget route from main router
- Created dedicated NotificationRoutes module
- Followed existing pattern from VotingRoutes

## Benefits

1. **Feature Isolation**: Notification routes are now self-contained within the feature module
2. **Maintainability**: Changes to notification routing don't require modifying the main router
3. **Consistency**: Follows the same pattern as other feature modules (e.g., voting)
4. **Clean Architecture**: Supports the Feature-First Architecture principle