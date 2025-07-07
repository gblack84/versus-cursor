import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/app_theme.dart';

class ThumbnailSelectionPage extends StatefulWidget {
  const ThumbnailSelectionPage({
    super.key,
    required this.imagePaths,
    required this.box,
  });

  final List<File> imagePaths;
  final String box; // 'A' or 'B'

  static String routeName = 'ThumbnailSelection';
  static String routePath = '/thumbnailSelection';

  @override
  State<ThumbnailSelectionPage> createState() => _ThumbnailSelectionPageState();
}

class _ThumbnailSelectionPageState extends State<ThumbnailSelectionPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 전체 화면 이미지
            Positioned.fill(
              child: _buildImagePreview(),
            ),
            
            // UI 요소들을 SafeArea로 감싸기
            SafeArea(
              child: Stack(
                children: [
                  // 하단 UI 요소들
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 안내 문구
                        _buildInfoText(),
                        
                        // 썸네일 리스트
                        _buildThumbnailList(),
                      ],
                    ),
                  ),
                  
                  // 뒤로가기 버튼 (ProImageEditor 스타일)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context, {'action': 'back_to_picker'}),
                      ),
                    ),
                  ),
                  
                  // 체크 버튼 (우측 상단)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          // 선택된 이미지 정보와 함께 결과 반환
                          Navigator.pop(context, {
                            'selectedIndex': _selectedIndex,
                            'allFiles': widget.imagePaths,
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImagePreview() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.imagePaths.length,
      onPageChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return Image.file(
          widget.imagePaths[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '선택한 이미지를 편집할 수 있습니다',
            style: AppTheme.of(context).bodyLarge.override(
              fontFamily: 'Readex Pro',
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '나머지 이미지는 나중에 편집할 수 있어요',
            style: AppTheme.of(context).bodyMedium.override(
              fontFamily: 'Readex Pro',
              color: Colors.white70,
              fontSize: 14,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailList() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(top: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.imagePaths.length, (index) {
            final isSelected = index == _selectedIndex;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.of(context).primary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.file(
                        widget.imagePaths[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 선택된 썸네일에 체크 표시
                    if (isSelected)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    // 순서 표시
                    Positioned(
                      left: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      ),
    );
  }

}