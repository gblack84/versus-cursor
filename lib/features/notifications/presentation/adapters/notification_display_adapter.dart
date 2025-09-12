import 'package:flutter/material.dart';
import '/core/domain/ports/i_notification_display_port.dart';
import '../../domain/handlers/i_notification_handler.dart';
import '../../domain/models/notification.dart' as domain;
import '../../domain/models/notification_display_data.dart';

/// Adapter implementation that bridges the Port to the actual notification handler
/// 
/// This adapter implements BOTH INotificationHandler and INotificationDisplayPort
/// to bridge between the two interfaces. It delegates to the Port implementation
/// which is provided by the voting feature.
class NotificationDisplayAdapter implements INotificationHandler {
  final INotificationDisplayPort _port;

  NotificationDisplayAdapter({
    required INotificationDisplayPort port,
  }) : _port = port;

  @override
  Future<BuildContext?> waitForUIContext() {
    return _port.waitForUIContext();
  }

  @override
  Future<void> showVotingNotification({
    required domain.Notification notification,
    required BuildContext context,
    required NotificationDisplayData displayData,
    required Function(String) onVote,
    required Function(bool) onDismiss,
  }) {
    // Convert to Map for the Port interface to avoid cross-feature dependencies
    final displayDataMap = {
      'question': displayData.question,
      'optionA': displayData.optionA,
      'optionB': displayData.optionB,
      'imageUrlA': displayData.imageUrlA,
      'imageUrlB': displayData.imageUrlB,
      'imageUrlsA': displayData.imageUrlsA,
      'imageUrlsB': displayData.imageUrlsB,
      'description': displayData.description,
      'authorName': displayData.authorName,
      'aspectRatioA': displayData.aspectRatioA,
      'aspectRatioB': displayData.aspectRatioB,
      'layoutType': displayData.layoutType,
      'hasImageA': displayData.hasImageA,
      'hasImageB': displayData.hasImageB,
    };

    return _port.showVotingNotification(
      notification: notification,
      context: context,
      displayData: displayDataMap,
      onVote: onVote,
      onDismiss: onDismiss,
    );
  }

  @override
  dynamic createSizeDataFromAspectRatios({
    required BuildContext context,
    double? aspectRatioA,
    double? aspectRatioB,
    String? layoutType,
    bool? hasImageA,
    bool? hasImageB,
  }) {
    return _port.createSizeDataFromAspectRatios(
      context: context,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      layoutType: layoutType,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
  }
}