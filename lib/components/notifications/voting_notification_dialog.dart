import 'package:flutter/material.dart';
import '/design_system/design_system.dart';
import 'models/versus_box_size_data.dart';
import 'services/versus_box_size_calculator.dart';
import 'widgets/versus_notification_box.dart';
import 'constants/voting_notification_constraints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';

class VotingNotificationDialog extends StatefulWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;
  final Function(String option) onVote;
  final VoidCallback? onDismiss;
  
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

  const VotingNotificationDialog({
    super.key,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    required this.onVote,
    this.onDismiss,
    this.sizeData,
    this.showResults = false,
    this.votePercentageA,
    this.votePercentageB,
    this.voteCountA,
    this.voteCountB,
    this.showDebugInfo = false,
  });

  @override
  State<VotingNotificationDialog> createState() => _VotingNotificationDialogState();
}

class _VotingNotificationDialogState extends State<VotingNotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _hasVoted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: VotingNotificationConstraints.slideAnimationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    
    // 자동 사라짐 (투표 시간)
    Future.delayed(VotingNotificationConstraints.autoHideDuration, () {
      if (mounted && !_hasVoted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  void _vote(String option) {
    if (_hasVoted) return;
    
    setState(() {
      _hasVoted = true;
    });
    
    widget.onVote(option);
    
    // 투표 완료 후 자동 사라짐
    Future.delayed(VotingNotificationConstraints.voteCompleteDuration, () {
      if (mounted) _dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Material(
            elevation: 12,
            borderRadius: VersusRadius.dialog,
            child: Container(
              decoration: BoxDecoration(
                color: VersusColors.backgroundSecondary,
                borderRadius: VersusRadius.dialog,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: VotingNotificationConstraints.shadowOpacity),
                    blurRadius: VotingNotificationConstraints.shadowBlurRadius,
                    offset: VotingNotificationConstraints.shadowOffset,
                  ),
                ],
              ),
              child: Padding(
                padding: VersusSpacing.paddingMD,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: VersusColors.primary.withValues(alpha: 0.1),
                            borderRadius: VersusRadius.radiusCircular,
                          ),
                          child: Center(
                            child: Icon(
                              VersusIcons.target.getIcon(VersusIcons.currentStyle),
                              size: 20,
                              color: VersusColors.primary,
                            ),
                          ),
                        ),
                        VersusSpacing.gapH(VersusSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '새로운 투표 도착!',
                                style: VersusTextStyles.headingSmall,
                              ),
                              VersusSpacing.gapXS,
                              Text(
                                _hasVoted ? '투표 완료!' : '참여해보세요',
                                style: _hasVoted 
                                  ? VersusTextStyles.success 
                                  : VersusTextStyles.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        if (!_hasVoted)
                          IconButton(
                            onPressed: _dismiss,
                            icon: Icon(
                              Icons.close,
                              color: VersusColors.textSecondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    
                    VersusSpacing.gapMD,
                    
                    // 질문
                    Text(
                      widget.question,
                      style: VersusTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    VersusSpacing.gapMD,
                    
                    // A vs B 박스들 (새로운 VersusNotificationBox 사용)
                    _buildVersusBoxes(),
                    
                    if (!_hasVoted) ...[
                      VersusSpacing.gapMD,
                      
                      // 투표 버튼들
                      _buildVoteButtons(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 새로운 VersusNotificationBox를 사용한 A/B 박스 구성
  Widget _buildVersusBoxes() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.imageUrlB != null || widget.optionB.isNotEmpty;
    final bool hasOnlyTextB = widget.imageUrlB == null && widget.optionB.isNotEmpty;
    
    // 사이즈 데이터가 제공된 경우 일관된 크기 사용
    if (widget.sizeData != null) {
      // 단일 이미지/옵션인 경우 또는 B가 텍스트만 있는 경우 단일 박스만 표시
      if (!hasBOption || hasOnlyTextB) {
        return _buildSingleBox(widget.sizeData!);
      }
      
      // 두 옵션 모두 이미지가 있는 경우 박스 쌍 표시
      return VersusNotificationBoxBuilder.buildBoxPair(
        context: context,
        sizeData: widget.sizeData!,
        titleA: widget.optionA,
        titleB: widget.optionB,
        imageUrlA: widget.imageUrlA,
        imageUrlB: widget.imageUrlB,
        onTapA: null,  // 박스 클릭으로 투표 비활성화
        onTapB: null,  // 박스 클릭으로 투표 비활성화
        selectedBox: _hasVoted ? null : null, // 선택 상태는 투표 후에만
        showResults: widget.showResults || _hasVoted,
        votePercentageA: widget.votePercentageA,
        votePercentageB: widget.votePercentageB,
        voteCountA: widget.voteCountA,
        voteCountB: widget.voteCountB,
        animationController: _controller,
        showDebugInfo: widget.showDebugInfo,
      );
    }
    
    // 사이즈 데이터가 없는 경우 기본 크기 사용
    return _buildDefaultBoxes();
  }
  
  /// 단일 박스 빌드 (B 옵션이 없을 때)
  Widget _buildSingleBox(VersusBoxSizeData sizeData) {
    // 중앙에 A박스만 표시 - 단일 이미지 모드에서 A/B 타이틀 함께 표시
    final bool hasOnlyText = widget.imageUrlB == null && widget.optionB.isNotEmpty;
    
    return Center(
      child: VersusNotificationBox(
        boxType: 'A',
        boxSize: VersusBoxSizeCalculator.calculateVotingSize(sizeData, context).sizeA,
        title: widget.optionA,
        imageUrl: widget.imageUrlA,
        onTap: null,  // 박스 클릭으로 투표 비활성화
        isSelected: false,
        showResult: widget.showResults || _hasVoted,
        votePercentage: widget.votePercentageA,
        voteCount: widget.voteCountA,
        animationController: _controller,
        showDebugInfo: widget.showDebugInfo,
        // 단일 이미지 모드에서 B 타이틀 함께 표시
        isSingleImageMode: hasOnlyText,
        dualModeSecondTitle: hasOnlyText ? widget.optionB : null,
      ),
    );
  }
  
  /// 기본 크기의 박스들 (fallback)
  Widget _buildDefaultBoxes() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.imageUrlB != null || widget.optionB.isNotEmpty;
    final bool hasOnlyTextB = widget.imageUrlB == null && widget.optionB.isNotEmpty;
    
    // 기본 사이즈 데이터 생성
    // aspectRatio를 null로 설정하여 이미지의 원본 비율을 유지하도록 함
    final defaultSizeData = VersusBoxSizeData(
      layoutType: hasBOption ? LayoutType.horizontal : LayoutType.single,
      aspectRatioA: null,  // 이미지 원본 비율 사용
      aspectRatioB: null,  // 이미지 원본 비율 사용
      originalSizeA: const Size(150, 150),
      originalSizeB: const Size(150, 150),
      screenWidth: MediaQuery.of(context).size.width,
      createdAt: DateTime.now(),
      hasImageA: widget.imageUrlA != null,
      hasImageB: widget.imageUrlB != null,
    );
    
    // 투표용 크기 계산
    final votingSizes = VersusBoxSizeCalculator.calculateVotingSize(
      defaultSizeData,
      context,
    );
    
    // 단일 박스인 경우 또는 B가 텍스트만 있는 경우
    if (!hasBOption || hasOnlyTextB) {
      return Center(
        child: VersusNotificationBox(
          boxType: 'A',
          boxSize: votingSizes.sizeA,
          title: widget.optionA,
          imageUrl: widget.imageUrlA,
          onTap: null,  // 박스 클릭으로 투표 비활성화
          showResult: widget.showResults || _hasVoted,
          votePercentage: widget.votePercentageA,
          voteCount: widget.voteCountA,
          animationController: _controller,
          showDebugInfo: widget.showDebugInfo,
          // 단일 이미지 모드에서 B 타이틀 함께 표시
          isSingleImageMode: hasOnlyTextB,
          dualModeSecondTitle: hasOnlyTextB ? widget.optionB : null,
        ),
      );
    }
    
    // 두 박스 모두 표시
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VersusNotificationBox(
          boxType: 'A',
          boxSize: votingSizes.sizeA,
          title: widget.optionA,
          imageUrl: widget.imageUrlA,
          onTap: _hasVoted ? null : () => _vote('A'),
          showResult: widget.showResults || _hasVoted,
          votePercentage: widget.votePercentageA,
          voteCount: widget.voteCountA,
          animationController: _controller,
          showDebugInfo: widget.showDebugInfo,
        ),
        SizedBox(width: votingSizes.spacing?.horizontal ?? 8.0),
        VersusNotificationBox(
          boxType: 'B',
          boxSize: votingSizes.sizeB,
          title: widget.optionB,
          imageUrl: widget.imageUrlB,
          onTap: _hasVoted ? null : () => _vote('B'),
          showResult: widget.showResults || _hasVoted,
          votePercentage: widget.votePercentageB,
          voteCount: widget.voteCountB,
          animationController: _controller,
          showDebugInfo: widget.showDebugInfo,
        ),
      ],
    );
  }
  
  /// 투표 버튼 빌드
  Widget _buildVoteButtons() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.imageUrlB != null || widget.optionB.isNotEmpty;
    final bool hasOnlyTextB = widget.imageUrlB == null && widget.optionB.isNotEmpty;
    
    // 단일 옵션인 경우 A 버튼만 표시
    if (!hasBOption) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _vote('A'),
          style: ElevatedButton.styleFrom(
            backgroundColor: VersusColors.primary,
            foregroundColor: Colors.white,
            shape: VersusRadius.buttonShape,
            padding: VersusSpacing.buttonInternal,
          ),
          child: Text(
            '선택하기',
            style: VersusTextStyles.buttonMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    
    // 두 옵션 모두 있는 경우 A/B 버튼 표시
    return Row(
      children: [
        // A 선택 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () => _vote('A'),
            style: ElevatedButton.styleFrom(
              backgroundColor: VersusColors.primary,
              foregroundColor: Colors.white,
              shape: VersusRadius.buttonShape,
              padding: VersusSpacing.buttonInternal,
            ),
            child: Text(
              'A 선택',
              style: VersusTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        VersusSpacing.gapH(VersusSpacing.sm),
        
        // B 선택 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () => _vote('B'),
            style: ElevatedButton.styleFrom(
              backgroundColor: VersusColors.secondary,
              foregroundColor: Colors.white,
              shape: VersusRadius.buttonShape,
              padding: VersusSpacing.buttonInternal,
            ),
            child: Text(
              'B 선택',
              style: VersusTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}