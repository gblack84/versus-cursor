import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/design_system/design_system.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '/utils/responsive_breakpoints.dart';

class VoteRequestMessage extends StatefulWidget {
  const VoteRequestMessage({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    required this.optionAText,
    required this.optionBText,
    this.optionAImage,
    this.optionBImage,
    this.aspectRatioA,
    this.aspectRatioB,
    required this.voteStatus,
    required this.isMe,
    required this.timestamp,
    required this.onTap,
  });

  final String postId;
  final String title;
  final String description;
  final String optionAText;
  final String optionBText;
  final String? optionAImage;
  final String? optionBImage;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final String voteStatus;
  final bool isMe;
  final DateTime? timestamp;
  final VoidCallback onTap;

  @override
  State<VoteRequestMessage> createState() => _VoteRequestMessageState();
}

class _VoteRequestMessageState extends State<VoteRequestMessage> 
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  
  // 레이아웃 전환 애니메이션
  late AnimationController _layoutTransitionController;
  late Animation<double> _layoutTransitionAnimation;
  LayoutType? _currentLayoutType;
  LayoutType? _previousLayoutType;
  
  // 투표 상태 변경 애니메이션
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // 레이아웃 전환 애니메이션 초기화
    _layoutTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _layoutTransitionAnimation = CurvedAnimation(
      parent: _layoutTransitionController,
      curve: Curves.easeInOutCubic,
    );
    
    // 애니메이션 완료 시 previousLayoutType 리셋
    _layoutTransitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _previousLayoutType = null;
        });
      }
    });
    
    _currentLayoutType = _getLayoutType();
  }
  
  @override
  void didUpdateWidget(VoteRequestMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // aspectRatio가 변경되었는지 확인
    if (oldWidget.aspectRatioA != widget.aspectRatioA ||
        oldWidget.aspectRatioB != widget.aspectRatioB) {
      final newLayoutType = _getLayoutType();
      if (newLayoutType != _currentLayoutType) {
        _previousLayoutType = _currentLayoutType;
        _currentLayoutType = newLayoutType;
        _layoutTransitionController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _layoutTransitionController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Semantics(
      button: true,
      label: '투표 요청: ${widget.title}',
      hint: _isExpanded ? '탭하여 투표하기, 길게 눌러 접기' : '탭하여 투표하기, 길게 눌러 펼치기',
      value: '상태: $statusText',
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
                widget.onTap();
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
          onTap: _isVoting ? null : () {
            setState(() {
              _isVoting = true;
            });
            widget.onTap();
            // 짧은 딜레이 후 상태 리셋
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isVoting = false;
                });
              }
            });
          },
          onLongPress: _isVoting ? null : _toggleExpanded,
          child: Stack(
        children: [
          Container(
            margin: ResponsiveBreakpoints.getMessageMargin(context, widget.isMe),
            decoration: BoxDecoration(
              color: widget.isMe ? VersusColors.primary : VersusColors.backgroundSecondary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
                bottomRight: Radius.circular(widget.isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveBreakpoints.getMaxMessageWidth(context),
              ),
              child: Padding(
                padding: const EdgeInsets.all(VersusSpacing.md),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 16,
                    color: widget.isMe ? Colors.white : VersusColors.primary,
                    semanticLabel: '투표 아이콘',
                  ),
                  const SizedBox(width: VersusSpacing.xs),
                  Text(
                    '투표 요청',
                    style: VersusTextStyles.labelSmall.copyWith(
                      color: widget.isMe ? Colors.white : VersusColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // 레이아웃 인디케이터
                  if (_shouldShowLayoutIndicator()) ...[
                    _buildLayoutIndicator(),
                    const SizedBox(width: VersusSpacing.xs),
                  ],
                  Semantics(
                    label: '투표 상태: $statusText',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VersusSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: VersusTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VersusSpacing.sm),
              
              // 제목
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: VersusTextStyles.bodyLarge.copyWith(
                    color: widget.isMe ? Colors.white : VersusColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: VersusTextStyles.bodySmall.copyWith(
                    color: widget.isMe ? Colors.white.withValues(alpha: 0.8) : VersusColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: VersusSpacing.sm),
              
              // A vs B 박스 (스마트 레이아웃 적용)
              Semantics(
                label: '투표 옵션',
                hint: '${widget.optionAText} 대 ${widget.optionBText}',
                child: _buildSmartLayout(),
              ),
              
              // 타임스탬프
              if (widget.timestamp != null) ...[
                const SizedBox(height: VersusSpacing.xs),
                Semantics(
                  label: '전송 시간: ${_formatTime(widget.timestamp!)}',
                  child: Text(
                    _formatTime(widget.timestamp!),
                    style: VersusTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: widget.isMe ? Colors.white.withValues(alpha: 0.6) : VersusColors.textSecondary,
                    ),
                  ),
                ),
              ],
                ],
              ),
            ),
          ),
        ),
      // 투표 중 오버레이
      if (_isVoting)
        Positioned.fill(
          child: Semantics(
            label: '투표 처리 중',
            child: Container(
              margin: ResponsiveBreakpoints.getMessageMargin(context, widget.isMe),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
                  bottomRight: Radius.circular(widget.isMe ? 4 : 16),
                ),
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
    );
  }

  Widget _buildSmartLayout() {
    // 레이아웃 타입 결정
    final layoutType = _currentLayoutType ?? _getLayoutType();
    final hasImages = widget.optionAImage != null || widget.optionBImage != null;
    
    // 반응형 높이 계산
    final baseHeight = ResponsiveBreakpoints.getVsBoxHeight(context, hasImages, false);
    final expandedHeight = ResponsiveBreakpoints.getVsBoxHeight(context, hasImages, true);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_expandAnimation, _layoutTransitionAnimation]),
      builder: (context, child) {
        final height = baseHeight + (_expandAnimation.value * (expandedHeight - baseHeight));
        
        // 레이아웃 전환 중인 경우
        if (_layoutTransitionController.isAnimating && _previousLayoutType != null) {
          return Stack(
            children: [
              // 이전 레이아웃 (fade out)
              Opacity(
                opacity: 1.0 - _layoutTransitionAnimation.value,
                child: IgnorePointer(
                  child: _previousLayoutType == LayoutType.horizontal
                      ? _buildHorizontalLayout(height)
                      : _buildVerticalLayout(height),
                ),
              ),
              // 새 레이아웃 (fade in)
              Opacity(
                opacity: _layoutTransitionAnimation.value,
                child: layoutType == LayoutType.horizontal
                    ? _buildHorizontalLayout(height)
                    : _buildVerticalLayout(height),
              ),
            ],
          );
        }
        
        // 일반 상태
        if (layoutType == LayoutType.horizontal) {
          return _buildHorizontalLayout(height);
        } else {
          return _buildVerticalLayout(height);
        }
      },
    );
  }

  Widget _buildHorizontalLayout(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _buildSmartOptionBox(
              label: 'A',
              text: widget.optionAText,
              imageUrl: widget.optionAImage,
              color: const Color(0xFFFF6B6B),
              aspectRatio: widget.aspectRatioA,
            ),
          ),
          const SizedBox(width: VersusSpacing.xs),
          Text(
            'VS',
            style: VersusTextStyles.labelSmall.copyWith(
              color: widget.isMe ? Colors.white : VersusColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: VersusSpacing.xs),
          Expanded(
            child: _buildSmartOptionBox(
              label: 'B',
              text: widget.optionBText,
              imageUrl: widget.optionBImage,
              color: const Color(0xFF4ECDC4),
              aspectRatio: widget.aspectRatioB,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(double height) {
    return Column(
      children: [
        SizedBox(
          height: height / 2 - 4,
          child: _buildSmartOptionBox(
            label: 'A',
            text: widget.optionAText,
            imageUrl: widget.optionAImage,
            color: const Color(0xFFFF6B6B),
            aspectRatio: widget.aspectRatioA,
          ),
        ),
        const SizedBox(height: VersusSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VS',
              style: VersusTextStyles.labelSmall.copyWith(
                color: widget.isMe ? Colors.white : VersusColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: VersusSpacing.xs),
        SizedBox(
          height: height / 2 - 4,
          child: _buildSmartOptionBox(
            label: 'B',
            text: widget.optionBText,
            imageUrl: widget.optionBImage,
            color: const Color(0xFF4ECDC4),
            aspectRatio: widget.aspectRatioB,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartOptionBox({
    required String label,
    required String text,
    String? imageUrl,
    required Color color,
    double? aspectRatio,
  }) {
    return Semantics(
      label: '옵션 $label: $text',
      image: imageUrl != null,
      button: false,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.3),
                  colorBlendMode: BlendMode.darken,
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
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: VersusTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Text(
              text,
              style: VersusTextStyles.bodySmall.copyWith(
                color: imageUrl != null ? Colors.white : color,
                fontWeight: FontWeight.w600,
                shadows: imageUrl != null
                    ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              maxLines: _isExpanded ? 4 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 확장 힌트
          if (!_isExpanded && (widget.optionAImage != null || widget.optionBImage != null))
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Icon(
                  Icons.zoom_out_map,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildLayoutIndicator() {
    final layoutType = _getLayoutType();
    return Semantics(
      label: layoutType == LayoutType.horizontal ? '가로 레이아웃' : '세로 레이아웃',
      child: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        layoutType == LayoutType.horizontal 
          ? Icons.view_column_outlined
          : Icons.view_agenda_outlined,
        size: 12,
        color: widget.isMe ? Colors.white.withValues(alpha: 0.8) : VersusColors.textSecondary,
      ),
      ),
    );
  }

  LayoutType _getLayoutType() {
    // 이미지가 없으면 항상 가로 레이아웃
    if (widget.aspectRatioA == null && widget.aspectRatioB == null) {
      return LayoutType.horizontal;
    }
    
    // AspectRatioAnalyzer를 사용하여 최적 레이아웃 결정
    return AspectRatioAnalyzer.getOptimalLayout(
      widget.aspectRatioA,
      widget.aspectRatioB,
    );
  }

  bool _shouldShowLayoutIndicator() {
    // 이미지가 있고 확장되지 않은 상태일 때만 표시
    return (widget.optionAImage != null || widget.optionBImage != null) && !_isExpanded;
  }

  Color _getStatusColor() {
    switch (widget.voteStatus) {
      case 'completed':
        return Colors.green;
      case 'expired':
        return Colors.grey;
      case 'pending':
      default:
        return VersusColors.primary;
    }
  }

  String _getStatusText() {
    switch (widget.voteStatus) {
      case 'completed':
        return '완료';
      case 'expired':
        return '만료';
      case 'pending':
      default:
        return '대기중';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}