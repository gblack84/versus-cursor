import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/dialog/versus_box_size_data.dart';
import '/services/image/unified_image_cache_service.dart';
import 'voting_dialog_constraints.dart';

// Import decomposed components
import 'voting_dialog/components/voting_dialog_header.dart';
import 'voting_dialog/components/voting_dialog_content.dart';
import 'voting_dialog/components/voting_dialog_actions.dart';
import 'voting_dialog/components/voting_dialog_timer.dart';
import 'voting_dialog/animations/voting_dialog_animations.dart';
import 'voting_dialog/models/voting_dialog_state.dart';

class VotingNotificationDialog extends ConsumerStatefulWidget {
  // ===== Full Voting Notification Mode =====
  final String? question;
  final String? optionA;
  final String? optionB;
  final String? imageUrlA;
  final String? imageUrlB;

  /// 멀티이미지 지원 (새로운 기능)
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? description;
  final Function(String option)? onVote;
  final Function(bool hasVoted)? onDismiss;

  // ===== Simple Notification Mode =====
  /// Simple notification 제목 (question이 null일 때 사용)
  final String? title;

  /// Simple notification 메시지 (question이 null일 때 사용)
  final String? message;

  /// Simple notification 버튼 텍스트 (기본값: '참여하기')
  final String? buttonText;

  /// Simple notification 버튼 탭 핸들러 (question이 null일 때 사용)
  final VoidCallback? onTap;

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
    // Full voting notification parameters
    this.question,
    this.optionA,
    this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.description,
    this.onVote,
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
    // Simple notification parameters
    this.title,
    this.message,
    this.buttonText,
    this.onTap,
  }) : assert(
         (question != null && optionA != null && optionB != null && onVote != null) ||
         (title != null && message != null && onTap != null),
         'Either provide full voting notification parameters (question, optionA, optionB, onVote) '
         'or simple notification parameters (title, message, onTap)',
       );


  @override
  ConsumerState<VotingNotificationDialog> createState() =>
      _VotingNotificationDialogState();
}

class _VotingNotificationDialogState extends ConsumerState<VotingNotificationDialog>
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
    widget.onVote!(option);

    // Auto-dismiss after vote completion
    Future.delayed(VotingDialogConstraints.voteCompleteDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simple notification mode (배너 스타일)
    if (widget.question == null) {
      return _buildSimpleNotification(context);
    }

    // Full voting notification mode (기존 다이얼로그)
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
                    question: widget.question!,
                    optionA: widget.optionA!,
                    optionB: widget.optionB!,
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
                      optionA: widget.optionA!,
                      optionB: widget.optionB!,
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

  /// Simple notification UI (InAppNotificationDialog 스타일)
  Widget _buildSimpleNotification(BuildContext context) {
    return _animations.buildCombinedTransitions(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Material(
          elevation: 8,
          borderRadius: VersusRadius.dialog,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VersusColors.primary,
                  VersusColors.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: VersusRadius.dialog,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: VersusSpacing.paddingMD,
              child: Row(
                children: [
                  // 아이콘
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: VersusRadius.radiusCircular,
                    ),
                    child: Center(
                      child: Icon(
                        VersusIcons.target.getIcon(VersusIcons.currentStyle),
                        size: 24,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  VersusSpacing.gapH(VersusSpacing.sm),

                  // 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title!,
                          style: VersusTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        VersusSpacing.gapXS,
                        Text(
                          widget.message!,
                          style: VersusTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 버튼들
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 참여 버튼
                      ElevatedButton(
                        onPressed: () {
                          _dismiss();
                          widget.onTap!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: VersusColors.primary,
                          padding: VersusSpacing.buttonInternal,
                          shape: VersusRadius.buttonShape,
                        ),
                        child: Text(
                          widget.buttonText ?? '참여하기',
                          style: VersusTextStyles.buttonSmall.copyWith(
                            color: VersusColors.primary,
                          ),
                        ),
                      ),

                      // 닫기 버튼
                      TextButton(
                        onPressed: _dismiss,
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
