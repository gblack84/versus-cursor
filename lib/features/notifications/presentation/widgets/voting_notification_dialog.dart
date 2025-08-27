import 'dart:async';
import 'package:flutter/material.dart';
import '/features/common/presentation/design_system/design_system.dart';
import '/features/notifications/presentation/models/versus_box_size_data.dart';
import '/features/common/data/services/unified_box_calculator.dart';
import 'versus_notification_box.dart';
import '/features/notifications/presentation/constants/voting_notification_constraints.dart';
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
  Timer? _autoCloseTimer;

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
    
    // 10분 자동 닫기 타이머 시작
    _autoCloseTimer = Timer(VotingNotificationConstraints.votingTimeLimit, () {
      if (mounted && !_hasVoted) {
        debugPrint('[VotingNotificationDialog] 10분 시간 제한 도달 - 자동 닫기');
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  /// 사용자가 투표했는지 여부를 외부에서 확인 가능하도록
  bool get hasVoted => _hasVoted;

  void _dismiss() async {
    await _controller.reverse();
    if (widget.onDismiss != null) {
      // 투표 여부를 onDismiss에 전달
      widget.onDismiss!(_hasVoted);
    }
  }

  void _vote(String option) {
    if (_hasVoted) return;
    
    setState(() {
      _hasVoted = true;
    });
    
    // 타이머 취소 (투표했으므로 10분 타이머 불필요)
    _autoCloseTimer?.cancel();
    
    widget.onVote(option);
    
    // 투표 완료 후 자동 사라짐
    Future.delayed(VotingNotificationConstraints.voteCompleteDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 멀티이미지 데이터 디버그 - 로그 제거
    
    return Semantics(
      label: '투표 알림: ${widget.question}',
      container: true,
      child: SlideTransition(
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
                      // 테스트 유저 프로필 이미지
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: VersusColors.borderLight,
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: VersusColors.textSecondary,
                        ),
                      ),
                      VersusSpacing.gapH(2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/pikle_icon.png',
                                  width: 30,
                                  height: 30,
                                ),
                                Text(
                                  'Pikle 도착!',
                                  style: VersusTextStyles.headingSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),  // 더 작은 간격 사용
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: widget.authorName ?? 'Test User',
                                      style: VersusTextStyles.labelSmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: VersusColors.textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '님이 물어봅니다',
                                      style: VersusTextStyles.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Title.',
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: VersusColors.textPrimary,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }

  /// A/B 박스 구성
  Widget _buildVersusBoxes() {
    // B 옵션이 있는지 확인
    final bool hasBOption = widget.primaryImageUrlB != null || widget.optionB.isNotEmpty;
    final bool hasOnlyTextB = widget.primaryImageUrlB == null && widget.optionB.isNotEmpty;
    
    // sizeData가 없고 aspectRatio가 있으면 생성
    VersusBoxSizeData? effectiveSizeData = widget.sizeData;
    if (effectiveSizeData == null && (widget.aspectRatioA != null || widget.aspectRatioB != null)) {
      // aspectRatio 정보를 사용하여 VersusBoxSizeData 생성
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);
      
      // 레이아웃 결정
      LayoutType layoutType;
      if (!hasBOption || hasOnlyTextB) {
        layoutType = LayoutType.single;
      } else if (widget.aspectRatioA != null && widget.aspectRatioB != null) {
        layoutType = AspectRatioAnalyzer.getOptimalLayout(widget.aspectRatioA, widget.aspectRatioB);
        // AspectRatioAnalyzer 결과 - 로그 제거
      } else {
        layoutType = LayoutType.horizontal;
      }
      
      effectiveSizeData = VersusBoxSizeData(
        layoutType: layoutType,
        aspectRatioA: widget.aspectRatioA,
        aspectRatioB: widget.aspectRatioB,
        originalSizeA: baseSize,
        originalSizeB: baseSize,
        screenWidth: screenWidth,
        createdAt: DateTime.now(),
        hasImageA: widget.primaryImageUrlA != null,
        hasImageB: widget.primaryImageUrlB != null,
      );
    }
    
    // 단일 박스만 필요한 경우
    if (!hasBOption || hasOnlyTextB) {
      Widget boxWidget;
      if (effectiveSizeData != null) {
        boxWidget = _buildSingleBox(effectiveSizeData);
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
    if (effectiveSizeData != null) {
      // buildBoxPair 호출 전 데이터 확인 - 로그 제거
      
      boxesWidget = VersusNotificationBoxBuilder.buildBoxPair(
        context: context,
        sizeData: effectiveSizeData,
        titleA: widget.optionA,
        titleB: widget.optionB,
        imageUrlA: widget.primaryImageUrlA,
        imageUrlB: widget.primaryImageUrlB,
        description: widget.description,
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
    final description = widget.description;
    
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Description.',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textPrimary,
            fontWeight: FontWeight.w600,
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
    
    // _buildSingleBox 호출 - 로그 제거
    
    return Center(
      child: VersusNotificationBox(
        boxType: 'A',
        boxSize: UnifiedBoxCalculator.calculateForNotificationDialog(
          dialogWidth: MediaQuery.of(context).size.width * 0.92,
          layoutType: sizeData.layoutType,
          aspectRatioA: sizeData.aspectRatioA,
          aspectRatioB: sizeData.aspectRatioB,
          hasImageA: sizeData.hasImageA,
          hasImageB: sizeData.hasImageB,
        ).sizeA,
        title: widget.optionA,
        imageUrl: widget.primaryImageUrlA,
        description: widget.description,
        question: widget.question,
        otherOptionTitle: widget.optionB,
        otherImageUrl: widget.primaryImageUrlB,
        otherDescription: widget.description,
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
    // aspectRatio를 전달받은 값이나 null로 설정
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);
    
    // AspectRatioAnalyzer를 사용하여 최적 레이아웃 결정
    LayoutType layoutType;
    if (!hasBOption || hasOnlyTextB) {
      layoutType = LayoutType.single;
    } else if (widget.aspectRatioA != null && widget.aspectRatioB != null) {
      // aspectRatio가 있으면 분석해서 결정
      layoutType = AspectRatioAnalyzer.getOptimalLayout(widget.aspectRatioA, widget.aspectRatioB);
      // AspectRatioAnalyzer 결과 - 로그 제거
    } else {
      layoutType = LayoutType.horizontal; // 기본값
    }
    
    final defaultSizeData = VersusBoxSizeData(
      layoutType: layoutType,
      aspectRatioA: widget.aspectRatioA,  // 전달받은 비율 사용
      aspectRatioB: widget.aspectRatioB,  // 전달받은 비율 사용
      originalSizeA: baseSize,
      originalSizeB: baseSize,
      screenWidth: screenWidth,
      createdAt: DateTime.now(),
      hasImageA: widget.primaryImageUrlA != null,
      hasImageB: widget.primaryImageUrlB != null,
    );
    
    // 투표용 크기 계산
    final votingSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: screenWidth * 0.92,
      layoutType: defaultSizeData.layoutType,
      aspectRatioA: defaultSizeData.aspectRatioA,
      aspectRatioB: defaultSizeData.aspectRatioB,
      hasImageA: defaultSizeData.hasImageA,
      hasImageB: defaultSizeData.hasImageB,
    );
    
    // 단일 박스인 경우 또는 B가 텍스트만 있는 경우
    if (!hasBOption || hasOnlyTextB) {
      return Center(
        child: VersusNotificationBox(
          boxType: 'A',
          boxSize: votingSizes.sizeA,
          title: widget.optionA,
          imageUrl: widget.primaryImageUrlA,
          description: widget.description,
          question: widget.question,
          otherOptionTitle: widget.optionB,
          otherImageUrl: widget.primaryImageUrlB,
          otherDescription: widget.description,
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
          description: widget.description,
          question: widget.question,
          otherOptionTitle: widget.optionB,
          otherImageUrl: widget.primaryImageUrlB,
          otherDescription: widget.description,
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
        SizedBox(width: votingSizes.spacing),
        VersusNotificationBox(
          boxType: 'B',
          boxSize: votingSizes.sizeB,
          title: widget.optionB,
          imageUrl: widget.primaryImageUrlB,
          description: widget.description,
          question: widget.question,
          otherOptionTitle: widget.optionA,
          otherImageUrl: widget.primaryImageUrlA,
          otherDescription: widget.description,
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