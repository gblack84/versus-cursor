import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design_system/design_system.dart';
import '/services/ui/models/box_sizes.dart';

/// 투표 옵션 A/B 표시 위젯
/// 이미지와 텍스트 옵션을 레이아웃에 맞게 표시합니다
class VoteOptionsWidget extends StatelessWidget {
  
  const VoteOptionsWidget({
    super.key,
    required this.optionAText,
    required this.optionBText,
    required this.optionAImages,
    required this.optionBImages,
    required this.boxSizes,
    required this.isHorizontal,
    this.searchHighlighter,
  });
  final String optionAText;
  final String optionBText;
  final List<String> optionAImages;
  final List<String> optionBImages;
  final BoxSizes boxSizes;
  final bool isHorizontal;
  final Widget? searchHighlighter;
  
  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalLayout();
    } else {
      return _buildVerticalLayout();
    }
  }
  
  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionBox(
            text: optionAText,
            images: optionAImages,
            label: 'A',
            width: boxSizes.boxWidthA,
            height: boxSizes.boxHeightA,
          ),
        ),
        const SizedBox(width: VersusSpacing.xs),
        Expanded(
          child: _buildOptionBox(
            text: optionBText,
            images: optionBImages,
            label: 'B',
            width: boxSizes.boxWidthB,
            height: boxSizes.boxHeightB,
          ),
        ),
      ],
    );
  }
  
  Widget _buildVerticalLayout() {
    return Column(
      children: [
        _buildOptionBox(
          text: optionAText,
          images: optionAImages,
          label: 'A',
          width: boxSizes.boxWidthA,
          height: boxSizes.boxHeightA,
        ),
        const SizedBox(height: VersusSpacing.xs),
        _buildOptionBox(
          text: optionBText,
          images: optionBImages,
          label: 'B',
          width: boxSizes.boxWidthB,
          height: boxSizes.boxHeightB,
        ),
      ],
    );
  }
  
  Widget _buildOptionBox({
    required String text,
    required List<String> images,
    required String label,
    required double width,
    required double height,
  }) {
    final hasImage = images.isNotEmpty;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: hasImage ? Colors.transparent : VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: VersusColors.borderLight,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 이미지 또는 텍스트
          if (hasImage)
            _buildImageContent(images, width)
          else
            _buildTextContent(text),
            
          // 라벨
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: VersusColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: VersusTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageContent(List<String> images, double boxWidth) {
    return Builder(
      builder: (context) {
        if (images.isEmpty) return const SizedBox.shrink();
        
        final memCacheWidth = (boxWidth * MediaQuery.of(context).devicePixelRatio).toInt();
        
        // 단일 이미지
        if (images.length == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: images[0],
              fit: BoxFit.cover,
              memCacheWidth: memCacheWidth,
              placeholder: (context, url) => Container(
                color: VersusColors.backgroundSecondary,
              ),
              errorWidget: (context, url, error) => Container(
                color: VersusColors.backgroundSecondary,
                child: Icon(
                  Icons.image_not_supported,
                  color: VersusColors.textSecondary,
                ),
              ),
            ),
          );
        }
        
        // 멀티 이미지는 PageView로 표시
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                memCacheWidth: memCacheWidth,
                placeholder: (context, url) => Container(
                  color: VersusColors.backgroundSecondary,
                ),
                errorWidget: (context, url, error) => Container(
                  color: VersusColors.backgroundSecondary,
                  child: Icon(
                    Icons.image_not_supported,
                    color: VersusColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildTextContent(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VersusSpacing.sm),
        child: Text(
          text,
          style: VersusTextStyles.bodyMedium,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}