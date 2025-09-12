import 'dart:async';
import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/versus_box_size_data.dart';
import '../constants/voting_dialog_constraints.dart';

// Import decomposed components
import 'voting_dialog/components/voting_dialog_header.dart';
import 'voting_dialog/components/voting_dialog_content.dart';
import 'voting_dialog/components/voting_dialog_actions.dart';
import 'voting_dialog/components/voting_dialog_timer.dart';
import 'voting_dialog/animations/voting_dialog_animations.dart';
import 'voting_dialog/models/voting_dialog_state.dart';

/// Refactored voting notification dialog
/// Main orchestrator that coordinates all sub-components
class VotingNotificationDialog extends StatefulWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? description;
  final Function(String option) onVote;
  final Function(bool hasVoted)? onDismiss;
  final VersusBoxSizeData? sizeData;
  final bool showResults;
  final double? votePercentageA;
  final double? votePercentageB;
  final int? voteCountA;
  final int? voteCountB;
  final bool showDebugInfo;
  final String? authorName;
  final double? aspectRatioA;
  final double? aspectRatioB;

  const VotingNotificationDialog({
    super.key,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.description,
    required this.onVote,
    this.onDismiss,
    this.sizeData,
    this.showResults = false,
    this.votePercentageA,
    this.votePercentageB,
    this.voteCountA,
    this.voteCountB,
    this.showDebugInfo = false,
    this.authorName,
    this.aspectRatioA,
    this.aspectRatioB,
  });

  @override
  State<VotingNotificationDialog> createState() =>
      _VotingNotificationDialogState();
}

class _VotingNotificationDialogState extends State<VotingNotificationDialog>
    with TickerProviderStateMixin {
  // Animation management
  late VotingDialogAnimations _animations;
  late AnimationController _animationController;
  
  // Timer management
  late VotingDialogTimer _timer;
  
  // State management
  late VotingDialogState _dialogState;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _startAnimations();
  }

  void _initializeComponents() {
    // Initialize animations
    _animationController = VotingDialogAnimations.createController(this);
    _animations = VotingDialogAnimations(controller: _animationController);
    
    // Initialize timer
    _timer = VotingDialogTimer(
      onTimeExpired: _dismiss,
      hasVoted: () => _dialogState.hasVoted,
    );
    _timer.startTimer();
    
    // Initialize state
    _dialogState = const VotingDialogState();
  }

  void _startAnimations() {
    _animations.animateIn();
  }

  @override
  void dispose() {
    _timer.dispose();
    _animations.dispose();
    super.dispose();
  }

  bool get hasVoted => _dialogState.hasVoted;

  void _dismiss() async {
    await _animations.animateOut();
    widget.onDismiss?.call(_dialogState.hasVoted);
  }

  void _vote(String option) {
    if (_dialogState.hasVoted) return;

    setState(() {
      _dialogState = _dialogState.copyWith(
        hasVoted: true,
        selectedOption: option,
        voteTimestamp: DateTime.now(),
      );
    });

    _timer.cancelTimer();
    widget.onVote(option);

    // Auto-dismiss after vote completion
    Future.delayed(VotingDialogConstraints.voteCompleteDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '투표 알림: ${widget.question}',
      container: true,
      child: _animations.buildCombinedTransitions(
        child: Material(
          elevation: 12,
          borderRadius: VersusRadius.dialog,
          child: Container(
            decoration: BoxDecoration(
              color: VersusColors.backgroundSecondary,
              borderRadius: VersusRadius.dialog,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: VotingDialogConstraints.shadowOpacity),
                  blurRadius: VotingDialogConstraints.shadowBlurRadius,
                  offset: VotingDialogConstraints.shadowOffset,
                ),
              ],
            ),
            child: Padding(
              padding: VersusSpacing.paddingMD,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header component
                  VotingDialogHeader(
                    authorName: widget.authorName,
                    onClose: _dismiss,
                    showCloseButton: !_dialogState.hasVoted,
                  ),

                  VersusSpacing.gapMD,

                  // Content component (question and boxes)
                  VotingDialogContent(
                    question: widget.question,
                    optionA: widget.optionA,
                    optionB: widget.optionB,
                    imageUrlA: widget.imageUrlA,
                    imageUrlB: widget.imageUrlB,
                    imageUrlsA: widget.imageUrlsA,
                    imageUrlsB: widget.imageUrlsB,
                    description: widget.description,
                    sizeData: widget.sizeData,
                    aspectRatioA: widget.aspectRatioA,
                    aspectRatioB: widget.aspectRatioB,
                    showResults: widget.showResults,
                    votePercentageA: widget.votePercentageA,
                    votePercentageB: widget.votePercentageB,
                    voteCountA: widget.voteCountA,
                    voteCountB: widget.voteCountB,
                    showDebugInfo: widget.showDebugInfo,
                    hasVoted: _dialogState.hasVoted,
                    onVote: _vote,
                    animationController: _animationController,
                  ),

                  // Action buttons (only show if not voted)
                  if (!_dialogState.hasVoted) ...[
                    VersusSpacing.gapMD,
                    VotingDialogActions(
                      optionA: widget.optionA,
                      optionB: widget.optionB,
                      imageUrlB: widget.imageUrlB,
                      onVote: _vote,
                      isEnabled: !_dialogState.hasVoted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}