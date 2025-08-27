import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design_system/design_system.dart';
import '/services/image/unified_image_cache_service.dart';

/// 투표 카드의 옵션 박스 컴포넌트
/// 
/// A/B 옵션을 시각적으로 표현하며, 이미지와 텍스트를 함께 표시합니다.
class VoteOptionBox extends StatelessWidget {
  final String label;
  final String text;
  final String? imageUrl;
  final List<String>? imageUrls;
  final Color color;
  final double? aspectRatio;
  final bool isSingleImageMode;
  final String? dualModeSecondTitle;
  final double? boxHeight;
  final String? searchQuery;

  const VoteOptionBox({
    super.key,
    required this.label,
    required this.text,
    this.imageUrl,
    this.imageUrls,
    required this.color,
    this.aspectRatio,
    this.isSingleImageMode = false,
    this.dualModeSecondTitle,
    this.boxHeight,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    // 멀티이미지 우선 사용
    final effectiveImageUrl = (imageUrls != null && imageUrls!.isNotEmpty) 
        ? imageUrls!.first : imageUrl;
    final hasMultipleImages = (imageUrls != null && imageUrls!.length > 1);
    
    // 효과적인 높이 계산 (폴백 처리)
    final double effectiveHeight = boxHeight ?? 200;  // 기본값 200px
    
    return Semantics(
      label: '옵션 $label: $text',
      image: effectiveImageUrl != null,
      button: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        height: effectiveHeight,  // 고정 높이 설정
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
              _buildImageBackground(effectiveImageUrl, context),
            
            // 그라데이션 오버레이
            if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
              _buildGradientOverlay(),
            
            // 텍스트 콘텐츠
            _buildTextContent(effectiveImageUrl, hasMultipleImages),
            
            // 멀티이미지 인디케이터
            if (hasMultipleImages)
              _buildMultiImageIndicator(imageUrls!.length),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBackground(String imageUrl, BuildContext context) {
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          memCacheWidth: _calculateDynamicCacheWidth(context),
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
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
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
    );
  }

  Widget _buildTextContent(String? effectiveImageUrl, bool hasMultipleImages) {
    return Positioned(
      bottom: 4,
      left: 4,
      right: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSingleImageMode && dualModeSecondTitle != null) ...[
            // 단일 이미지 모드: A/B 타이틀 함께 표시
            _buildSingleImageModeContent(),
          ] else ...[
            // 일반 모드: 각 옵션 텍스트만 표시
            _buildNormalModeContent(effectiveImageUrl),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleImageModeContent() {
    return Column(
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
                dualModeSecondTitle ?? '',
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
    );
  }

  Widget _buildNormalModeContent(String? effectiveImageUrl) {
    return Row(
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
          child: searchQuery != null && searchQuery!.isNotEmpty
              ? _highlightText(
                  text,
                  VersusTextStyles.bodySmall.copyWith(
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
                )
              : Text(
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
    );
  }

  Widget _buildMultiImageIndicator(int count) {
    return Positioned(
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
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색어 하이라이팅 위젯
  Widget _highlightText(String text, TextStyle style) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery!.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery, start);
    
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }
      
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery!.length),
        style: style.copyWith(
          backgroundColor: VersusColors.warning.withValues(alpha: 0.4),
        ),
      ));
      
      start = index + searchQuery!.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }
    
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  /// 동적 캐시 폭 계산
  int _calculateDynamicCacheWidth(BuildContext context) {
    // VoteCardMessage와 동일한 로직 사용
    final view = View.of(context);
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    
    // 메시지 카드는 화면 폭의 약 92% 사용
    final cardWidth = screenWidth * 0.92;
    
    // 옵션 박스는 카드 폭의 약 절반 (가로 배치) 또는 전체 (세로 배치)
    // 여기서는 최대값 기준으로 계산
    final optionWidth = cardWidth * 0.8;
    
    // 캐시 폭을 400-1200px 범위로 제한
    return optionWidth.clamp(400, 1200).toInt();
  }
}