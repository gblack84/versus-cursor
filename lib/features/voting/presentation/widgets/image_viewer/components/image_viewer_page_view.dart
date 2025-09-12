import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 이미지 뷰어 페이지뷰 컴포넌트
///
/// 이미지를 표시하고 줌/팬 기능을 제공합니다.
class ImageViewerPageView extends StatelessWidget {
  final List<String> imageUrls;
  final PageController controller;
  final String title;
  final String? description;
  final String boxType;
  final ValueChanged<int> onPageChanged;
  final Axis scrollDirection;

  const ImageViewerPageView({
    Key? key,
    required this.imageUrls,
    required this.controller,
    required this.title,
    this.description,
    required this.boxType,
    required this.onPageChanged,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return PageView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      onPageChanged: onPageChanged,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildImageView(imageUrls[index]);
      },
    );
  }

  Widget _buildImageView(String imageUrl) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error, color: Colors.red, size: 64),
          ),
        ),
      ),
    );
  }
}