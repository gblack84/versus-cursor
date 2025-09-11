import 'package:flutter/material.dart';
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/notifications/domain/models/notification_display_data.dart';
import '/features/notifications/domain/handlers/i_notification_handler.dart';
import '../managers/vote_ui_manager.dart';
import '/features/voting/domain/models/versus_box_size_data.dart';

/// Implementation of INotificationHandler in the presentation layer
///
/// This class bridges the domain layer with the actual UI implementation,
/// delegating UI operations to VoteUIManager while conforming
/// to the domain interface.
class VoteHandlerImpl implements INotificationHandler {
  final VoteUIManager _uiManager;

  VoteHandlerImpl({
    VoteUIManager? uiManager,
  }) : _uiManager = uiManager ?? VoteUIManager.instance;

  @override
  Future<BuildContext?> waitForUIContext() async {
    return _uiManager.waitForUIContext();
  }

  @override
  Future<void> showVotingNotification({
    required domain.Notification notification,
    required BuildContext context,
    required NotificationDisplayData displayData,
    required Function(String) onVote,
    required Function(bool) onDismiss,
  }) async {
    // Convert NotificationDisplayData to individual parameters for UIManager
    await _uiManager.showVotingNotification(
      notification: notification,
      context: context,
      question: displayData.question,
      optionA: displayData.optionA,
      optionB: displayData.optionB,
      imageUrlA: displayData.imageUrlA,
      imageUrlB: displayData.imageUrlB,
      imageUrlsA: displayData.imageUrlsA,
      imageUrlsB: displayData.imageUrlsB,
      description: displayData.description,
      authorName: displayData.authorName,
      sizeData: createSizeDataFromAspectRatios(
        context: context,
        aspectRatioA: displayData.aspectRatioA,
        aspectRatioB: displayData.aspectRatioB,
        layoutType: displayData.layoutType,
        hasImageA: displayData.hasImageA,
        hasImageB: displayData.hasImageB,
      ) as VersusBoxSizeData?,
      onVote: (selectedOption) async {
        await onVote(selectedOption);
      },
      onDismiss: (hasVoted) async {
        await onDismiss(hasVoted);
      },
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
    return _uiManager.createSizeDataFromAspectRatios(
      context: context,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      layoutType: layoutType,
      hasImageA: hasImageA ?? false,
      hasImageB: hasImageB ?? false,
    );
  }
}
