import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '/design_system/design_system.dart';
import '/components/notifications/voting_notification_dialog.dart';
import '/utils/responsive_breakpoints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '/shared/services/unified_box_calculator.dart';
import '/services/unified_image_cache_service.dart';
import 'base_vote_message.dart';

/// AI 피클 채팅에서 사용되는 투표 카드 메시지 위젯
/// 4가지 상태를 지원: voting_request, in_progress, completed, not_participated
class VoteCardMessage extends BaseVoteMessage {
  const VoteCardMessage({
    super.key,
    required super.postId,
    required super.title,
    super.description,
    required super.optionAText,
    required super.optionBText,
    super.optionAImage,
    super.optionBImage,
    super.optionAImages,
    super.optionBImages,
    super.aspectRatioA,
    super.aspectRatioB,
    required super.cardStatus,
    super.voteEndTime,
    super.userVotes,
    super.voteResults,
    required super.isMe,
    super.timestamp,
    required super.messageType,
    super.messageId,
    super.chatId,
    super.currentUserName,
    super.senderProfileImageUrl,
    super.senderDisplayName,
    super.showSenderProfile,
  });

  @override
  State<VoteCardMessage> createState() => _VoteCardMessageState();
}

class _VoteCardMessageState extends State<VoteCardMessage> 
    with BaseVoteMessageStateMixin<VoteCardMessage>, TickerProviderStateMixin {
  // 투표 상태 변경 애니메이션
  bool _isVoting = false;
  
  // 캐싱 변수 추가 (중복 계산 방지)
  LayoutType? _cachedLayoutType;
  BoxSizes? _cachedBoxSizes;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didUpdateWidget(VoteCardMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // aspectRatio가 변경되면 캐시 무효화
    if (oldWidget.aspectRatioA != widget.aspectRatioA ||
        oldWidget.aspectRatioB != widget.aspectRatioB ||
        oldWidget.effectiveImageUrlsA.length != widget.effectiveImageUrlsA.length ||
        oldWidget.effectiveImageUrlsB.length != widget.effectiveImageUrlsB.length) {
      _cachedLayoutType = null;
      _cachedBoxSizes = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final statusInfo = getStatusInfo();
    // vote_request 타입일 때 상태 텍스트를 '대기중'으로 오버라이드
    if (widget.messageType == 'vote_request' && widget.cardStatus == 'voting_request') {
      statusInfo['text'] = '대기중';
    }
    
    return Semantics(
      button: true,
      label: '투표 요청: ${widget.title}',
      hint: '탭하여 투표하기',
      value: '상태: ${statusInfo['text']}',
      excludeSemantics: _isVoting,
      child: Focus(
        canRequestFocus: !_isVoting,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey.keyLabel == 'Enter' || 
                event.logicalKey.keyLabel == ' ') {
              if (!_isVoting) {
                setState(() {
                  _isVoting = true;
                });
                _handleTap();
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _isVoting = false;
                    });
                  }
                });
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _isVoting ? null : _handleTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 새로운 프로필 헤더 (최상단)
                    _buildProfileHeader(statusInfo),
                    const SizedBox(height: VersusSpacing.md),
                    
                    _buildTitle(),
                    if (widget.description != null && widget.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildDescription(),
                    ],
                    const SizedBox(height: VersusSpacing.sm),
                    _buildSmartLayout(),
                    if (shouldShowTimer()) ...[
                      const SizedBox(height: VersusSpacing.sm),
                      buildTimer(),
                    ],
                    if (shouldShowAction()) ...[
                      const SizedBox(height: VersusSpacing.sm),
                      _buildActionButton(),
                    ],
                    if (shouldShowResult()) ...[
                      const SizedBox(height: VersusSpacing.sm),
                      _buildResults(),
                    ],
                    if (widget.timestamp != null) ...[
                      const SizedBox(height: VersusSpacing.xs),
                      buildTimestamp(),
                    ],
                  ],
                ),
                // 투표 중 오버레이
                if (_isVoting)
                  Positioned.fill(
                    child: Semantics(
                      label: '투표 처리 중',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.9),
                            ),
                            semanticsLabel: '로딩 중',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(Map<String, dynamic> statusInfo) {
    final displayName = widget.senderDisplayName ?? '알 수 없는 사용자';
    final hasProfileImage = widget.senderProfileImageUrl?.isNotEmpty ?? false;
    
    return Row(
      children: [
        // 프로필 이미지
        GestureDetector(
          onTap: () {
            // TODO: 프로필 페이지로 이동
            debugPrint('Navigate to profile: $displayName');
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage: hasProfileImage
                ? CachedNetworkImageProvider(widget.senderProfileImageUrl!)
                : null,
            backgroundColor: hasProfileImage 
                ? Colors.transparent 
                : VersusColors.borderLight,
            child: !hasProfileImage
                ? Icon(
                    Icons.person,
                    size: 24,
                    color: VersusColors.textSecondary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        
        // 중간 영역: Pikle 브랜딩 + 발신자 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pikle 도착! 라인
              Row(
                children: [
                  Image.asset(
                    'assets/images/pikle_icon.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.messageType == 'vote_created' 
                        ? '내가 만든 피클' 
                        : 'Pikle 도착!',
                    style: VersusTextStyles.labelMedium.copyWith(
                      color: VersusColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              
              // 발신자 정보
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: displayName,
                        style: VersusTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: VersusColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: widget.messageType == 'vote_created'
                            ? ' • 투표 생성됨'
                            : '님이 물어봅니다',
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 오른쪽: 상태 배지
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: VersusSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: (statusInfo['color'] as Color).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusInfo['icon'] as IconData,
                size: 12,
                color: statusInfo['color'] as Color,
              ),
              const SizedBox(width: 4),
              Text(
                statusInfo['text'] as String,
                style: VersusTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: statusInfo['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTitle() {
    return Text(
      widget.title,
      style: VersusTextStyles.bodyLarge.copyWith(
        color: VersusColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildDescription() {
    return Text(
      widget.description!,
      style: VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildSmartLayout() {
    // 레이아웃 타입 결정 (캐싱됨)
    final layoutType = _getLayoutType();
    
    // BoxSizes를 여기서 한 번만 계산 (캐싱)
    if (_cachedBoxSizes == null) {
      final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
      _cachedBoxSizes = UnifiedBoxCalculator.calculateForMessageCard(
        bubbleWidth: maxMessageWidth,
        layoutType: layoutType,
        aspectRatioA: widget.aspectRatioA,
        aspectRatioB: widget.aspectRatioB,
        hasImageA: widget.effectiveImageUrlsA.isNotEmpty,
        hasImageB: widget.effectiveImageUrlsB.isNotEmpty,
      );
      
      debugPrint('[VoteCardMessage] 박스 크기 계산 완료:');
      debugPrint('  - 레이아웃: ${layoutType.name}');
      debugPrint('  - 통일 높이: ${_cachedBoxSizes!.unifiedHeight.toStringAsFixed(1)}px');
    }
    
    // 단일 이미지 모드 체크 (B가 이미지 없이 텍스트만 있을 때)
    final bool hasOnlyTextB = widget.effectiveImageUrlsB.isEmpty && widget.optionBText.isNotEmpty;
    
    // 단일 이미지 모드일 때는 하나의 박스만 표시
    if (hasOnlyTextB) {
      return _buildSingleImageBox(_cachedBoxSizes!);
    }
    
    // 일반 상태
    if (layoutType == LayoutType.horizontal) {
      return _buildHorizontalLayout(_cachedBoxSizes!);
    } else {
      return _buildVerticalLayout(_cachedBoxSizes!);
    }
  }

  Widget _buildHorizontalLayout(BoxSizes boxSizes) {
    return SizedBox(
      height: boxSizes.unifiedHeight,
      child: Row(
        children: [
          Expanded(
            child: _buildSmartOptionBox(
              label: 'A',
              text: widget.optionAText,
              imageUrl: widget.optionAImage,
              imageUrls: widget.effectiveImageUrlsA,
              color: const Color(0xFFFF6B6B),
              aspectRatio: widget.aspectRatioA,
              isSingleImageMode: false,
              dualModeSecondTitle: null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSmartOptionBox(
              label: 'B',
              text: widget.optionBText,
              imageUrl: widget.optionBImage,
              imageUrls: widget.effectiveImageUrlsB,
              color: const Color(0xFF4ECDC4),
              aspectRatio: widget.aspectRatioB,
              isSingleImageMode: false,
              dualModeSecondTitle: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(BoxSizes boxSizes) {
    final unifiedHeight = boxSizes.unifiedHeight;
    
    return Column(
      children: [
        SizedBox(
          height: unifiedHeight,
          child: _buildSmartOptionBox(
            label: 'A',
            text: widget.optionAText,
            imageUrl: widget.optionAImage,
            imageUrls: widget.effectiveImageUrlsA,
            color: const Color(0xFFFF6B6B),
            aspectRatio: widget.aspectRatioA,
            isSingleImageMode: false,
            dualModeSecondTitle: null,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: unifiedHeight,
          child: _buildSmartOptionBox(
            label: 'B',
            text: widget.optionBText,
            imageUrl: widget.optionBImage,
            imageUrls: widget.effectiveImageUrlsB,
            color: const Color(0xFF4ECDC4),
            aspectRatio: widget.aspectRatioB,
            isSingleImageMode: false,
            dualModeSecondTitle: null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSmartOptionBox({
    required String label,
    required String text,
    String? imageUrl,
    List<String>? imageUrls,
    required Color color,
    double? aspectRatio,
    bool isSingleImageMode = false,
    String? dualModeSecondTitle,
  }) {
    // 멀티이미지 우선 사용
    final effectiveImageUrl = (imageUrls != null && imageUrls.isNotEmpty) 
        ? imageUrls.first : imageUrl;
    final hasMultipleImages = (imageUrls != null && imageUrls.length > 1);
    
    return Semantics(
      label: '옵션 $label: $text',
      image: effectiveImageUrl != null,
      button: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: aspectRatio ?? 1.0,  // 원본 aspect ratio 유지
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: effectiveImageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,  // 중앙 정렬로 일관성 확보
                      // 통합 이미지 캐시 서비스 사용
                      memCacheWidth: _calculateDynamicCacheWidth(),
                      maxWidthDiskCache: UnifiedImageCacheService.MAX_CACHE_WIDTH,
                      fadeInDuration: const Duration(milliseconds: 200),
                      fadeOutDuration: const Duration(milliseconds: 100),
                      placeholder: (context, url) => Container(
                        color: color.withValues(alpha: 0.05),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: color.withValues(alpha: 0.05),
                        child: Center(
                          child: Icon(
                            Icons.error_outline,
                            color: color.withValues(alpha: 0.6),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // 그라데이션 오버레이
            if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isSingleImageMode
                          ? [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ]
                          : [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                      stops: isSingleImageMode
                          ? const [0.0, 0.3]  // 단일: 30%까지
                          : const [0.0, 0.2],  // 멀티: 20%까지
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSingleImageMode && dualModeSecondTitle != null) ...[
                    // 단일 이미지 모드: A/B 타이틀 함께 표시
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A 옵션
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'A',
                                style: VersusTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                text,
                                style: VersusTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // B 옵션
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'B',
                                style: VersusTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dualModeSecondTitle,
                                style: VersusTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    // 일반 모드: 각 옵션 텍스트만 표시
                    Row(
                      children: [
                        // 멀티이미지에서도 A/B 라벨 표시
                        if (!isSingleImageMode)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: label == 'A' 
                                  ? const Color(0xFFFF6B6B).withValues(alpha: 0.8)
                                  : const Color(0xFF4ECDC4).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              style: VersusTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (!isSingleImageMode)
                          const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            text,
                            style: VersusTextStyles.bodySmall.copyWith(
                              color: effectiveImageUrl != null ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                              shadows: effectiveImageUrl != null
                                  ? [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 멀티이미지 인디케이터
            if (hasMultipleImages)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSingleImageBox(BoxSizes boxSizes) {
    // 단일 이미지 모드: B가 텍스트만 있을 때 하나의 박스에 A/B 모두 표시
    return SizedBox(
      height: boxSizes.unifiedHeight,
      child: _buildSmartOptionBox(
        label: 'A',  // 라벨은 A로 표시하지만
        text: widget.optionAText,
        imageUrl: widget.optionAImage,
        imageUrls: widget.effectiveImageUrlsA,
        color: const Color(0xFFFF6B6B),
        aspectRatio: widget.aspectRatioA,
        isSingleImageMode: true,
        dualModeSecondTitle: widget.optionBText,  // B 옵션 텍스트도 함께 전달
      ),
    );
  }

  LayoutType _getLayoutType() {
    // 캐시된 값이 있으면 반환
    if (_cachedLayoutType != null) {
      return _cachedLayoutType!;
    }
    
    // 디버깅: aspectRatio 값 확인 (한 번만 출력)
    debugPrint('[VoteCardMessage] 레이아웃 타입 계산');
    debugPrint('  - aspectRatioA: ${widget.aspectRatioA}');
    debugPrint('  - aspectRatioB: ${widget.aspectRatioB}');
    
    final hasImageA = widget.optionAImage != null || (widget.optionAImages?.isNotEmpty ?? false);
    final hasImageB = widget.optionBImage != null || (widget.optionBImages?.isNotEmpty ?? false);
    debugPrint('  - 이미지 A: $hasImageA');
    debugPrint('  - 이미지 B: $hasImageB');
    
    // aspectRatio가 없지만 이미지는 있는 경우 (fallback)
    if (widget.aspectRatioA == null && widget.aspectRatioB == null) {
      if (hasImageA && hasImageB) {
        // 이미지가 둘 다 있으면 가로 배치 (기본값)
        debugPrint('  → aspectRatio null이지만 이미지 있음, fallback으로 horizontal 반환');
        _cachedLayoutType = LayoutType.horizontal;
        return _cachedLayoutType!;
      } else if (hasImageA || hasImageB) {
        // 이미지가 하나만 있으면 single
        debugPrint('  → 이미지 하나만 있음, single 반환');
        _cachedLayoutType = LayoutType.single;
        return _cachedLayoutType!;
      } else {
        // 이미지가 없으면 가로 레이아웃
        debugPrint('  → 이미지 없음, 기본값 horizontal 반환');
        _cachedLayoutType = LayoutType.horizontal;
        return _cachedLayoutType!;
      }
    }
    
    // AspectRatioAnalyzer를 사용하여 최적 레이아웃 결정
    final layout = AspectRatioAnalyzer.getOptimalLayout(
      widget.aspectRatioA,
      widget.aspectRatioB,
    );
    
    debugPrint('  → 레이아웃 결정: ${layout.name}');
    _cachedLayoutType = layout;
    return _cachedLayoutType!;
  }
  
  
  /// 동적 캐시 너비 계산
  int _calculateDynamicCacheWidth() {
    // 캐시된 박스 크기가 있으면 사용
    if (_cachedBoxSizes != null) {
      final layoutType = _getLayoutType();
      
      if (layoutType == LayoutType.horizontal) {
        // 가로 배치: 박스 너비 기준
        final width = MediaQuery.of(context).size.width / 2;
        return UnifiedImageCacheService.calculateMemCacheWidth(width);
      } else if (layoutType == LayoutType.vertical) {
        // 세로 배치: 통일된 높이 기준
        final height = _cachedBoxSizes!.unifiedHeight;
        return UnifiedImageCacheService.calculateMemCacheWidth(height);
      } else {
        // 단일 이미지: 전체 너비 기준
        final width = MediaQuery.of(context).size.width * 0.9;
        return UnifiedImageCacheService.calculateMemCacheWidth(width);
      }
    }
    
    // 기본값
    return UnifiedImageCacheService.MIN_CACHE_WIDTH;
  }
  
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleActionTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: VersusColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: VersusSpacing.sm,
          ),
        ),
        child: Text(
          widget.cardStatus == 'voting_request' ? '투표하기' : '투표 현황 보기',
          style: VersusTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildResults() {
    final displayName = widget.currentUserName ?? '나';
    
    return Container(
      padding: const EdgeInsets.all(VersusSpacing.sm),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '피클! 피클! 피클!',
              style: TextStyle(
                fontSize: 18,
                color: VersusColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$displayName님 결과를 보러오세요!',
              style: TextStyle(
                fontSize: 14,
                color: VersusColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  
  
  void _handleTap() {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
    });
    
    if (widget.cardStatus == 'voting_request') {
      _showVotingDialog();
    } else {
      // 게시물 페이지로 이동
      context.pushNamed(
        'PostView',
        queryParameters: {'postId': widget.postId},
      );
    }
    
    // 짧은 딜레이 후 상태 리셋
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    });
  }
  
  void _handleActionTap() {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
    });
    
    if (widget.cardStatus == 'voting_request') {
      _showVotingDialog();
    } else {
      context.pushNamed(
        'PostView',
        queryParameters: {'postId': widget.postId},
      );
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    });
  }
  
  void _showVotingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: VotingNotificationDialog(
          question: widget.title,
          optionA: widget.optionAText,
          optionB: widget.optionBText,
          imageUrlA: widget.optionAImage,
          imageUrlB: widget.optionBImage,
          imageUrlsA: widget.optionAImages,
          imageUrlsB: widget.optionBImages,
          onVote: (option) async {
            // 투표 처리
            await submitVote(option);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onDismiss: (hasVoted) {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
}