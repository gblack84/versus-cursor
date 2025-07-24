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
  
  /// 멀티이미지 지원 (새로운 기능)
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? descriptionA;
  final String? descriptionB;
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
    this.imageUrlsA,
    this.imageUrlsB, 
    this.descriptionA,
    this.descriptionB,
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

  /// 멀티이미지 지원 헬퍼 메서드들
  /// 
  /// 기존 단일 이미지와 새로운 멀티이미지를 모두 지원
  
  /// A박스의 이미지 URL 리스트 반환 (멀티이미지 우선, 없으면 단일 이미지)
  List<String> get effectiveImageUrlsA {
    if (imageUrlsA != null && imageUrlsA!.isNotEmpty) {
      return imageUrlsA!;
    }
    if (imageUrlA != null) {
      return [imageUrlA!];
    }
    return [];
  }
  
  /// B박스의 이미지 URL 리스트 반환 (멀티이미지 우선, 없으면 단일 이미지)
  List<String> get effectiveImageUrlsB {
    if (imageUrlsB != null && imageUrlsB!.isNotEmpty) {
      return imageUrlsB!;
    }
    if (imageUrlB != null) {
      return [imageUrlB!];
    }
    return [];
  }
  
  /// A박스의 첫 번째 이미지 URL (기존 호환성용)
  String? get primaryImageUrlA {
    final urls = effectiveImageUrlsA;
    return urls.isNotEmpty ? urls.first : null;
  }
  
  /// B박스의 첫 번째 이미지 URL (기존 호환성용)
  String? get primaryImageUrlB {
    final urls = effectiveImageUrlsB;
    return urls.isNotEmpty ? urls.first : null;
  }

  @override
  State<VotingNotificationDialog> createState() => _VotingNotificationDialogState();
}

class _VotingNotificationDialogState extends State<VotingNotificationDialog>
    with TickerProviderStateMixin {
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
    // 멀티이미지 데이터 디버그
    print('[VotingNotificationDialog] ===== 멀티이미지 데이터 확인 =====');
    print('  - effectiveImageUrlsA: ${widget.effectiveImageUrlsA.length}개');
    print('  - effectiveImageUrlsB: ${widget.effectiveImageUrlsB.length}개');
    print('  - imageUrlsA: ${widget.imageUrlsA?.length ?? 0}개');
    print('  - imageUrlsB: ${widget.imageUrlsB?.length ?? 0}개');
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
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
                            const SizedBox(height: 2.0),  // 더 작은 간격 사용
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
                  
                  VersusSpacing.gapMD,  // 16px로 복원
                  
                  // 질문
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '질문:',
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.question,
                        style: VersusTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  VersusSpacing.gapMD,  // 16px로 복원
                  
                  // A vs B 박스들
                  _buildVersusBoxes(),
                  
                  if (!_hasVoted) ...[
                    VersusSpacing.gapMD,  // 16px로 복원
                    
                    // 투표 버튼들
                    _buildVoteButtons(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A/B 박스 구성
  Widget _buildVersusBoxes() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.primaryImageUrlB != null || widget.optionB.isNotEmpty;
    final bool hasOnlyTextB = widget.primaryImageUrlB == null && widget.optionB.isNotEmpty;
    
    // 단일 박스만 필요한 경우
    if (!hasBOption || hasOnlyTextB) {
      Widget boxWidget;
      if (widget.sizeData != null) {
        boxWidget = _buildSingleBox(widget.sizeData!);
      } else {
        boxWidget = _buildDefaultBoxes();
      }
      
      // 단일 박스일 때도 설명 표시
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          boxWidget,
          const SizedBox(height: 12),
          // 설명만 표시
          _buildOptionsText(),
        ],
      );
    }
    
    // 두 박스 표시
    Widget boxesWidget;
    if (widget.sizeData != null) {
      print('[VotingNotificationDialog] buildBoxPair 호출 전 데이터 확인:');
      print('  - imageUrlsA 전달: ${widget.effectiveImageUrlsA.length}개');
      print('  - imageUrlsB 전달: ${widget.effectiveImageUrlsB.length}개');
      
      boxesWidget = VersusNotificationBoxBuilder.buildBoxPair(
        context: context,
        sizeData: widget.sizeData!,
        titleA: widget.optionA,
        titleB: widget.optionB,
        imageUrlA: widget.primaryImageUrlA,
        imageUrlB: widget.primaryImageUrlB,
        descriptionA: widget.descriptionA,
        descriptionB: widget.descriptionB,
        onTapA: _hasVoted ? null : () => _vote('A'),
        onTapB: _hasVoted ? null : () => _vote('B'),
        showResults: widget.showResults || _hasVoted,
        votePercentageA: widget.votePercentageA,
        votePercentageB: widget.votePercentageB,
        voteCountA: widget.voteCountA,
        voteCountB: widget.voteCountB,
        animationController: _controller,
        showDebugInfo: widget.showDebugInfo,
        // 멀티이미지 지원 파라미터 추가
        imageUrlsA: widget.effectiveImageUrlsA,
        imageUrlsB: widget.effectiveImageUrlsB,
        question: widget.question,
        enableImageTap: true,  // 명시적으로 true 설정
      );
    } else {
      boxesWidget = _buildDefaultBoxes();
    }
    
    // 박스들과 텍스트를 포함하는 Column 반환
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        boxesWidget,
        const SizedBox(height: 12),
        // 제목과 설명을 표시하는 위젯
        _buildOptionsText(),
      ],
    );
  }
  
  /// 옵션 텍스트 빌드 (설명만 표시)
  Widget _buildOptionsText() {
    // 설명이 있는 경우에만 표시 (A 또는 B 중 하나만)
    final description = widget.descriptionA ?? widget.descriptionB;
    
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설명:',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: VersusTextStyles.bodySmall.copyWith(
            color: VersusColors.textPrimary,  // textSecondary → textPrimary로 변경
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  
  /// 단일 박스 빌드 (B 옵션이 없을 때)
  Widget _buildSingleBox(VersusBoxSizeData sizeData) {
    // 중앙에 A박스만 표시 - 단일 이미지 모드에서 A/B 타이틀 함께 표시
    final bool hasOnlyText = widget.primaryImageUrlB == null && widget.optionB.isNotEmpty;
    
    print('[VotingNotificationDialog] _buildSingleBox 호출:');
    print('  - imageUrlsA: ${widget.effectiveImageUrlsA.length}개');
    print('  - imageUrlsB: ${widget.effectiveImageUrlsB.length}개');
    
    return Center(
      child: VersusNotificationBox(
        boxType: 'A',
        boxSize: VersusBoxSizeCalculator.calculateVotingSize(sizeData, context).sizeA,
        title: widget.optionA,
        imageUrl: widget.primaryImageUrlA,
        description: widget.descriptionA,
        question: widget.question,
        otherOptionTitle: widget.optionB,
        otherImageUrl: widget.primaryImageUrlB,
        otherDescription: widget.descriptionB,
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
        // 멀티이미지 지원 파라미터 추가
        imageUrls: widget.effectiveImageUrlsA,
        otherImageUrls: widget.effectiveImageUrlsB,
        enableImageTap: true,  // 명시적으로 true 설정
      ),
    );
  }
  
  /// 기본 크기의 박스들 (fallback)
  Widget _buildDefaultBoxes() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.primaryImageUrlB != null || widget.optionB.isNotEmpty;
    final bool hasOnlyTextB = widget.primaryImageUrlB == null && widget.optionB.isNotEmpty;
    
    // 기본 사이즈 데이터 생성
    // aspectRatio를 null로 설정하여 이미지의 원본 비율을 유지하도록 함
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);
    
    final defaultSizeData = VersusBoxSizeData(
      layoutType: hasBOption ? LayoutType.horizontal : LayoutType.single,
      aspectRatioA: null,  // 이미지 원본 비율 사용
      aspectRatioB: null,  // 이미지 원본 비율 사용
      originalSizeA: baseSize,
      originalSizeB: baseSize,
      screenWidth: screenWidth,
      createdAt: DateTime.now(),
      hasImageA: widget.primaryImageUrlA != null,
      hasImageB: widget.primaryImageUrlB != null,
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
          imageUrl: widget.primaryImageUrlA,
          description: widget.descriptionA,
          question: widget.question,
          otherOptionTitle: widget.optionB,
          otherImageUrl: widget.primaryImageUrlB,
          otherDescription: widget.descriptionB,
          onTap: null,  // 박스 클릭으로 투표 비활성화
          showResult: widget.showResults || _hasVoted,
          votePercentage: widget.votePercentageA,
          voteCount: widget.voteCountA,
          animationController: _controller,
          showDebugInfo: widget.showDebugInfo,
          // 단일 이미지 모드에서 B 타이틀 함께 표시
          isSingleImageMode: hasOnlyTextB,
          dualModeSecondTitle: hasOnlyTextB ? widget.optionB : null,
          // 멀티이미지 지원 파라미터 추가
          imageUrls: widget.effectiveImageUrlsA,
          otherImageUrls: widget.effectiveImageUrlsB,
          enableImageTap: true,  // 명시적으로 true 설정
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
          imageUrl: widget.primaryImageUrlA,
          description: widget.descriptionA,
          question: widget.question,
          otherOptionTitle: widget.optionB,
          otherImageUrl: widget.primaryImageUrlB,
          otherDescription: widget.descriptionB,
          onTap: _hasVoted ? null : () => _vote('A'),
          showResult: widget.showResults || _hasVoted,
          votePercentage: widget.votePercentageA,
          voteCount: widget.voteCountA,
          animationController: _controller,
          showDebugInfo: widget.showDebugInfo,
          // 멀티이미지 지원 파라미터 추가
          imageUrls: widget.effectiveImageUrlsA,
          otherImageUrls: widget.effectiveImageUrlsB,
          enableImageTap: true,  // 명시적으로 true 설정
        ),
        SizedBox(width: votingSizes.spacing?.horizontal ?? 8.0),
        VersusNotificationBox(
          boxType: 'B',
          boxSize: votingSizes.sizeB,
          title: widget.optionB,
          imageUrl: widget.primaryImageUrlB,
          description: widget.descriptionB,
          question: widget.question,
          otherOptionTitle: widget.optionA,
          otherImageUrl: widget.primaryImageUrlA,
          otherDescription: widget.descriptionA,
          onTap: _hasVoted ? null : () => _vote('B'),
          showResult: widget.showResults || _hasVoted,
          votePercentage: widget.votePercentageB,
          voteCount: widget.voteCountB,
          animationController: _controller,
          showDebugInfo: widget.showDebugInfo,
          // 멀티이미지 지원 파라미터 추가
          imageUrls: widget.effectiveImageUrlsB,
          otherImageUrls: widget.effectiveImageUrlsA,
          enableImageTap: true,  // 명시적으로 true 설정
        ),
      ],
    );
  }
  
  /// 투표 버튼 빌드
  Widget _buildVoteButtons() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.primaryImageUrlB != null || widget.optionB.isNotEmpty;
    
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