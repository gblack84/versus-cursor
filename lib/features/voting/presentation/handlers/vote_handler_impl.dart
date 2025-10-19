import 'package:flutter/material.dart';
import '/core/domain/ports/i_notification_display_port.dart';
import '/core/utils/logger.dart';
import '../managers/vote_ui_manager.dart';
import '/features/voting/domain/models/versus_box_size_data.dart';
import '/features/voting/domain/usecases/submit_vote_use_case.dart';
import '/features/voting/domain/models/vote_notification.dart';

/// Implementation of INotificationDisplayPort for the voting feature
///
/// This class implements the Port interface to handle notification display
/// operations specific to voting. It delegates UI operations to VoteUIManager
/// while maintaining clean architecture boundaries.
///
/// This handler now owns the complete voting responsibility including:
/// - Vote submission via SubmitVoteUseCase
/// - UI display via VoteUIManager
class VoteHandlerImpl implements INotificationDisplayPort {
  final VoteUIManager _uiManager;
  final SubmitVoteUseCase _submitVote;

  VoteHandlerImpl({
    VoteUIManager? uiManager,
    required SubmitVoteUseCase submitVote,
  })  : _uiManager = uiManager ?? VoteUIManager.instance,
        _submitVote = submitVote;

  @override
  Future<BuildContext?> waitForUIContext() async {
    return _uiManager.waitForUIContext();
  }

  @override
  Future<void> showVotingNotification({
    required dynamic notification,
    required BuildContext context,
    required dynamic displayData,
    required Function(String) onVote,
    required Function(bool) onDismiss,
  }) async {
    // Extract properties from dynamic displayData
    // This maintains compatibility while avoiding cross-feature dependencies
    final data = displayData as Map<String, dynamic>;

    await _uiManager.showVotingNotification(
      notification: notification,
      context: context,
      question: data['question'] ?? '',
      optionA: data['optionA'] ?? '',
      optionB: data['optionB'] ?? '',
      imageUrlA: data['imageUrlA'],
      imageUrlB: data['imageUrlB'],
      imageUrlsA: data['imageUrlsA'] ?? [],
      imageUrlsB: data['imageUrlsB'] ?? [],
      description: data['description'],
      authorName: data['authorName'],
      sizeData: createSizeDataFromAspectRatios(
        context: context,
        aspectRatioA: data['aspectRatioA'],
        aspectRatioB: data['aspectRatioB'],
        layoutType: data['layoutType'],
        hasImageA: data['hasImageA'] ?? false,
        hasImageB: data['hasImageB'] ?? false,
      ) as VersusBoxSizeData?,
      onVote: (selectedOption) async {
        // Cast notification to access voting-specific fields
        final voteNotif = notification as VoteNotification;

        Logger.info(
          'Submitting vote: $selectedOption for post ${voteNotif.postId}',
          tag: 'VoteHandlerImpl',
        );

        // 1. Submit vote first (Voting Feature responsibility)
        final result = await _submitVote.call(SubmitVoteParams(
          postId: voteNotif.postId,
          userId: voteNotif.userId,
          choice: selectedOption,
        ));

        result.fold(
          (failure) => Logger.warning(
            'Vote submission failed: ${failure.message}',
            tag: 'VoteHandlerImpl',
          ),
          (_) => Logger.info(
            'Vote submitted successfully',
            tag: 'VoteHandlerImpl',
          ),
        );

        // 2. Then call notification callback (Notification Feature's concern)
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
