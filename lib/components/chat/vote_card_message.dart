import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '/design_system/design_system.dart';
import '/components/notifications/voting_notification_dialog.dart';
import '/utils/responsive_breakpoints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
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
  });

  @override
  State<VoteCardMessage> createState() => _VoteCardMessageState();
}

class _VoteCardMessageState extends State<VoteCardMessage> 
    with BaseVoteMessageStateMixin<VoteCardMessage>, TickerProviderStateMixin {
  // 투표 상태 변경 애니메이션
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didUpdateWidget(VoteCardMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
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
                    _buildHeader(statusInfo),
                    const SizedBox(height: VersusSpacing.sm),
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
  
  Widget _buildHeader(Map<String, dynamic> statusInfo) {
    return Row(
      children: [
        Image.asset(
          'assets/images/pikle_icon.png',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: VersusSpacing.xs),
        Text(
          widget.messageType == 'vote_created' ? '내가 만든 피클' : 'Pikle 도착!',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
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
    // 레이아웃 타입 결정
    final layoutType = _getLayoutType();
    final hasImages = widget.optionAImage != null || widget.optionBImage != null ||
        (widget.optionAImages != null && widget.optionAImages!.isNotEmpty) ||
        (widget.optionBImages != null && widget.optionBImages!.isNotEmpty);
    
    // 스마트 높이 계산 (최대 400px)
    final smartHeight = _calculateSmartHeight(400.0);
    
    // 단일 이미지 모드 체크 (B가 이미지 없이 텍스트만 있을 때)
    final bool hasOnlyTextB = widget.effectiveImageUrlsB.isEmpty && widget.optionBText.isNotEmpty;
    
    // 단일 이미지 모드일 때는 하나의 박스만 표시
    if (hasOnlyTextB) {
      return _buildSingleImageBox(smartHeight);
    }
    
    // 일반 상태
    if (layoutType == LayoutType.horizontal) {
      return _buildHorizontalLayout(smartHeight);
    } else {
      return _buildVerticalLayout(smartHeight);
    }
  }

  Widget _buildHorizontalLayout(double height) {
    // vote_request일 때 VoteRequestMessage와 동일한 스타일 적용
    
    return SizedBox(
      height: height,
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

  Widget _buildVerticalLayout(double height) {
    // 세로 레이아웃에서 각 박스의 개별 높이 계산
    final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
    final boxWidth = maxMessageWidth - 24;
    
    double heightA = 250.0; // 기본값
    double heightB = 250.0;
    
    // A 이미지 비율로 높이 계산
    if (widget.aspectRatioA != null) {
      heightA = boxWidth / widget.aspectRatioA!;
    }
    
    // B 이미지 비율로 높이 계산
    if (widget.aspectRatioB != null) {
      heightB = boxWidth / widget.aspectRatioB!;
    }
    
    // 전체 높이가 제한을 초과하면 비율에 맞춰 조정
    final totalDesiredHeight = heightA + heightB + 10;
    if (totalDesiredHeight > height) {
      final scale = (height - 10) / (heightA + heightB);
      heightA *= scale;
      heightB *= scale;
    }
    
    // 최소 높이 보장
    heightA = math.max(heightA, 150.0);
    heightB = math.max(heightB, 150.0);
    
    return Column(
      children: [
        SizedBox(
          height: heightA,
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
          height: heightB,
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
  
  /// 스마트 높이 계산 메서드 - 최대 400px 제한
  double _calculateSmartHeight(double maxHeight) {
    const double MAX_HEIGHT = 400.0;
    const double MIN_HEIGHT = 200.0;
    
    // 이미지가 없으면 최소 높이
    if (widget.aspectRatioA == null && widget.aspectRatioB == null) {
      return MIN_HEIGHT;
    }
    
    // 레이아웃 타입에 따라 조정
    final layoutType = _getLayoutType();
    
    if (layoutType == LayoutType.horizontal) {
      // 가로 레이아웃: 두 이미지 중 더 높은 것 기준 (최대 400px)
      return _calculateHorizontalHeight(MAX_HEIGHT);
    } else if (layoutType == LayoutType.vertical) {
      // 세로 레이아웃: 이미지 비율에 따른 동적 높이
      return _calculateVerticalHeight(MAX_HEIGHT);
    } else if (layoutType == LayoutType.single) {
      // 단일 이미지: 적절한 높이 계산
      return _calculateSingleHeight(MAX_HEIGHT);
    }
    
    return MIN_HEIGHT;
  }
  
  /// 가로 레이아웃용 높이 계산
  double _calculateHorizontalHeight(double maxHeight) {
    // 화면 너비의 절반으로 박스 너비 계산
    final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
    final boxWidth = (maxMessageWidth - 20) / 2; // 10px 간격 고려
    
    double heightA = 200.0; // 기본값
    double heightB = 200.0;
    
    // A 이미지 비율로 높이 계산
    if (widget.aspectRatioA != null) {
      heightA = boxWidth / widget.aspectRatioA!;
    }
    
    // B 이미지 비율로 높이 계산
    if (widget.aspectRatioB != null) {
      heightB = boxWidth / widget.aspectRatioB!;
    }
    
    // 둘 중 큰 값 사용 (최대 400, 최소 200)
    final optimalHeight = math.max(heightA, heightB);
    return optimalHeight.clamp(200.0, maxHeight);
  }
  
  /// 단일 이미지용 높이 계산
  double _calculateSingleHeight(double maxHeight) {
    final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
    final boxWidth = maxMessageWidth - 24; // 양쪽 패딩
    
    double height = 250.0; // 기본값
    
    // 이미지 비율로 높이 계산
    if (widget.aspectRatioA != null) {
      height = boxWidth / widget.aspectRatioA!;
    } else if (widget.aspectRatioB != null) {
      height = boxWidth / widget.aspectRatioB!;
    }
    
    // 제한 적용 (최대 400, 최소 200)
    return height.clamp(200.0, maxHeight);
  }
  
  /// 세로 레이아웃용 높이 계산
  double _calculateVerticalHeight(double maxHeight) {
    final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
    final boxWidth = maxMessageWidth - 24; // 전체 너비 사용
    
    double heightA = 250.0; // 기본값
    double heightB = 250.0;
    
    // A 이미지 비율로 높이 계산
    if (widget.aspectRatioA != null) {
      heightA = boxWidth / widget.aspectRatioA!;
      debugPrint('  세로 레이아웃 A박스: 너비=$boxWidth, 비율=${widget.aspectRatioA}, 높이=$heightA');
    }
    
    // B 이미지 비율로 높이 계산
    if (widget.aspectRatioB != null) {
      heightB = boxWidth / widget.aspectRatioB!;
      debugPrint('  세로 레이아웃 B박스: 너비=$boxWidth, 비율=${widget.aspectRatioB}, 높이=$heightB');
    }
    
    // 두 박스 높이 합 + 간격 (10px)
    final totalHeight = heightA + heightB + 10;
    
    // 제한 적용 (최대 600px, 최소 400px) - 세로는 더 큰 높이 허용
    const double VERTICAL_MAX_HEIGHT = 600.0;
    const double VERTICAL_MIN_HEIGHT = 400.0;
    
    final result = totalHeight.clamp(VERTICAL_MIN_HEIGHT, VERTICAL_MAX_HEIGHT);
    debugPrint('  세로 레이아웃 총 높이: $totalHeight → 제한 적용: $result');
    
    return result;
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: CachedNetworkImage(
                    imageUrl: effectiveImageUrl,
                    fit: BoxFit.cover,
                    // 메모리 최적화 설정
                    memCacheWidth: 400,
                    maxWidthDiskCache: 800,
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
  
  Widget _buildSingleImageBox(double height) {
    // 단일 이미지 모드: B가 텍스트만 있을 때 하나의 박스에 A/B 모두 표시
    return SizedBox(
      height: height,
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
    // 디버깅: aspectRatio 값 확인
    debugPrint('[VoteCardMessage] _getLayoutType 호출');
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
        return LayoutType.horizontal;
      } else if (hasImageA || hasImageB) {
        // 이미지가 하나만 있으면 single
        debugPrint('  → 이미지 하나만 있음, single 반환');
        return LayoutType.single;
      } else {
        // 이미지가 없으면 가로 레이아웃
        debugPrint('  → 이미지 없음, 기본값 horizontal 반환');
        return LayoutType.horizontal;
      }
    }
    
    // AspectRatioAnalyzer를 사용하여 최적 레이아웃 결정
    final layout = AspectRatioAnalyzer.getOptimalLayout(
      widget.aspectRatioA,
      widget.aspectRatioB,
    );
    
    debugPrint('  → AspectRatioAnalyzer 결과: ${layout.name}');
    return layout;
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