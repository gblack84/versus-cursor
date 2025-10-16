import 'dart:async';
import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/versus_box_size_data.dart';
import '/services/image/unified_image_cache_service.dart';
import '../constants/voting_dialog_constraints.dart';

// Import decomposed components
import 'voting_dialog/components/voting_dialog_header.dart';
import 'voting_dialog/components/voting_dialog_content.dart';
import 'voting_dialog/components/voting_dialog_actions.dart';
import 'voting_dialog/components/voting_dialog_timer.dart';
import 'voting_dialog/animations/voting_dialog_animations.dart';
import 'voting_dialog/models/voting_dialog_state.dart';

class VotingNotificationDialog extends StatefulWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;

  /// 멀티이미지 지원 (새로운 기능)
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? description;
  final Function(String option) onVote;
  final Function(bool hasVoted)? onDismiss;

  /// 질문 작성 페이지에서 생성된 사이즈 데이터 (선택사항)
  /// 제공되면 일관된 크기로 표시, 없으면 기본 크기 사용
  final VersusBoxSizeData? sizeData;

  /// 투표 결과 표시 여부
  final bool showResults;

  /// A 옵션 투표 비율 (0.0 ~ 1.0)
  final double? votePercentageA;

  /// B 옵션 투표 비율 (0.0 ~ 1.0)
  final double? votePercentageB;

  /// A 옵션 투표 수
  final int? voteCountA;

  /// B 옵션 투표 수
  final int? voteCountB;

  /// 디버그 정보 표시 여부
  final bool showDebugInfo;

  /// 알림을 보낸 사람의 이름
  final String? authorName;

  /// 이미지 aspect ratio (스마트 레이아웃용)
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✨ 투표 이미지 프리로딩 (UnifiedImageCacheService)
    if (mounted) {
      UnifiedImageCacheService.instance.preloadVoteMessageImages(
        context,
        imageUrlA: widget.imageUrlA,
        imageUrlB: widget.imageUrlB,
        imageUrlsA: widget.imageUrlsA,
        imageUrlsB: widget.imageUrlsB,
      );
    }
  }

  @override
  void dispose() {
    _timer.dispose();
    _animations.dispose();
    super.dispose();
  }

  /// 사용자가 투표했는지 여부를 외부에서 확인 가능하도록
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
