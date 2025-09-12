import 'package:flutter/material.dart';

/// 이미지 뷰어 상단 앱바
///
/// 닫기 버튼과 현재 위치 표시를 담당합니다.
class ImageViewerAppBar extends StatelessWidget {
  final String boxType;
  final int imageIndex;
  final int totalInBox;
  final bool isSingleMode;
  final VoidCallback onClose;

  const ImageViewerAppBar({
    Key? key,
    required this.boxType,
    required this.imageIndex,
    required this.totalInBox,
    required this.isSingleMode,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          _buildPositionIndicator(),
        ],
      ),
    );
  }

  Widget _buildPositionIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isSingleMode
              ? Colors.red
              : (boxType == 'A' ? Colors.red : Colors.green),
          width: 1.5,
        ),
      ),
      child: Text(
        isSingleMode
            ? '$imageIndex/$totalInBox'
            : '$boxType $imageIndex/$totalInBox',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}