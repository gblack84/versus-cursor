import 'package:flutter/material.dart';

/// Port interface for notification display operations
/// 
/// This interface defines the contract for displaying notifications
/// without creating cross-feature dependencies. The voting feature
/// depends on this abstraction rather than the concrete notification
/// implementation, following the Dependency Inversion Principle.
abstract class INotificationDisplayPort {
  /// Wait for UI context to be ready for displaying notifications
  Future<BuildContext?> waitForUIContext();

  /// Display a voting notification to the user
  /// 
  /// Parameters follow the exact signature from the original handler
  /// to maintain compatibility during migration
  Future<void> showVotingNotification({
    required dynamic notification,  // Using dynamic to avoid cross-feature dependency
    required BuildContext context,
    required dynamic displayData,   // Using dynamic to avoid cross-feature dependency
    required Function(String) onVote,
    required Function(bool) onDismiss,
  });

  /// Create size data from aspect ratios for notification display
  /// 
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