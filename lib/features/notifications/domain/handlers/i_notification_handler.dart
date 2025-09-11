import 'package:flutter/material.dart';
import '../models/notification.dart' as domain;
import '../models/notification_display_data.dart';

/// Domain layer interface for handling notification UI display
///
/// This interface defines the contract for displaying notifications
/// without the data layer knowing about specific UI implementations.
/// The presentation layer will implement this interface.
abstract class INotificationHandler {
  /// Wait for UI context to be ready
  Future<BuildContext?> waitForUIContext();

  /// Display a voting notification with the provided data
  Future<void> showVotingNotification({
    required domain.Notification notification,
    required BuildContext context,
    required NotificationDisplayData displayData,
    required Function(String) onVote,
    required Function(bool) onDismiss,
  });

  /// Create size data from aspect ratios (optional method)
  /// Returns null if implementation doesn't support size calculation
  dynamic createSizeDataFromAspectRatios({
    required BuildContext context,
    double? aspectRatioA,
    double? aspectRatioB,
    String? layoutType,
    bool? hasImageA,
    bool? hasImageB,
  });
}
