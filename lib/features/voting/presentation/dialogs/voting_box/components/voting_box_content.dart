import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design_system/design_system.dart';
import '/services/cache/unified_image_cache_service.dart';
import '/features/voting/presentation/dialogs/voting_dialog_constraints.dart';
import '/features/voting/domain/constants/voting_constants.dart';

/// Main content area component for voting box
class VotingBoxContent extends StatelessWidget {
  final Size boxSize;
  final String title;
  final String? imageUrl;
  final List<String>? imageUrls;
  final List<Color>? gradientColors;
  final String boxType;
  final double textSize;
  final bool isSingleImageMode;
  final String? dualModeSecondTitle;
  final String? description;

  const VotingBoxContent({
    Key? key,
    required this.boxSize,
    required this.title,
    required this.boxType,
    required this.textSize,
    this.imageUrl,
    this.imageUrls,
    this.gradientColors,
    this.isSingleImageMode = false,
    this.dualModeSecondTitle,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background (image or gradient)
        _buildBackground(),
        
        // Title overlay
        _buildTitleOverlay(),
        
        // Multi-image indicator
        if (imageUrls != null && imageUrls!.length > 1)
          _buildMultiImageIndicator(),
      ],
    );
  }

  Widget _buildBackground() {
    return ClipRRect(
      borderRadius: VersusRadius.container,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? _buildImageBackground()
          : _buildGradientBackground(),
    );
  }

  Widget _buildImageBackground() {
    const double maxSafeSize = 1000.0;
    final safeWidth = boxSize.width.clamp(0.0, maxSafeSize);
    final safeHeight = boxSize.height.clamp(0.0, maxSafeSize);

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: safeWidth,
      height: safeHeight,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: UnifiedImageCacheService.calculateMemCacheWidth(safeWidth),
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildGradientBackground() {
    final colors = gradientColors ?? _getDefaultGradientColors();

    return Container(
      width: boxSize.width,
      height: boxSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  List<Color> _getDefaultGradientColors() {
    if (boxType == 'A') {
      return [
        VersusColors.primary,
        VersusColors.primary.withValues(alpha: 0.8),
      ];
    } else {
      return [
        VersusColors.secondary,
        VersusColors.secondary.withValues(alpha: 0.8),
      ];
    }
  }

  Widget _buildTitleOverlay() {
    if (isSingleImageMode && dualModeSecondTitle != null) {
      return _buildDualTitleContent();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: VersusRadius.container.bottomLeft,
            bottomRight: VersusRadius.container.bottomRight,
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.w600,
            fontFamily: VersusTextStyles.bodyMedium.fontFamily,
            letterSpacing: VersusTextStyles.bodyMedium.letterSpacing,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDualTitleContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: VersusRadius.container.bottomLeft,
            bottomRight: VersusRadius.container.bottomRight,
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option A
            _buildDualOption('A', title, VersusColors.primary),
            const SizedBox(height: 8.0),
            // Option B
            _buildDualOption('B', dualModeSecondTitle!, VersusColors.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDualOption(String label, String optionTitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: textSize * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            optionTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: textSize * 0.85,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiImageIndicator() {
    final imageCount = imageUrls?.length ?? 0;
    if (imageCount <= 1) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library,
              size: VotingConstants.multiImageIndicatorIconSize,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              '$imageCount',
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

  Widget _buildPlaceholder() {
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      color: VersusColors.borderLight,
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      decoration: BoxDecoration(
        color: VersusColors.borderLight,
        borderRadius: VersusRadius.container,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: VotingDialogConstraints.statusIconSize,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapXS,
          Text(
            '이미지 로드 실패',
            style: VersusTextStyles.labelSmall.copyWith(
              fontSize: textSize * 0.8,
            ),
          ),
        ],
      ),
    );
  }
}