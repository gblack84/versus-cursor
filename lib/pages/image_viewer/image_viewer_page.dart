import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import 'image_viewer_model.dart';
export 'image_viewer_model.dart';

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.box,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String? box;

  static String routeName = 'ImageViewer';
  static String routePath = '/imageViewer';

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late ImageViewerModel _model;
  late PageController _pageController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageViewerModel());
    _model.currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _model.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _model.currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.of(context).primary,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.of(context).error,
                            size: 64.0,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            '이미지를 불러올 수 없습니다',
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      
                      // Title
                      Text(
                        widget.box != null ? '${widget.box} 이미지' : '이미지 보기',
                        style: AppTheme.of(context).titleMedium.override(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      
                      // Page Indicator
                      if (widget.imageUrls.length > 1)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            '${_model.currentIndex + 1} / ${widget.imageUrls.length}',
                            style: AppTheme.of(context).bodySmall.override(
                                  color: Colors.white,
                                ),
                          ),
                        )
                      else
                        SizedBox(width: 48.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Download Button
                      _buildActionButton(
                        icon: Icons.download,
                        label: '다운로드',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('다운로드 기능은 준비 중입니다.'),
                              backgroundColor: AppTheme.of(context).primary,
                            ),
                          );
                        },
                      ),
                      
                      // Share Button
                      _buildActionButton(
                        icon: Icons.share,
                        label: '공유',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('공유 기능은 준비 중입니다.'),
                              backgroundColor: AppTheme.of(context).primary,
                            ),
                          );
                        },
                      ),
                      
                      // Delete Button
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: '삭제',
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('이미지 삭제'),
                                content: Text('이 이미지를 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () => Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text('삭제'),
                                    onPressed: () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );
                          
                          if (confirm == true) {
                            // TODO: 실제 삭제 로직 구현
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('삭제 기능은 준비 중입니다.'),
                                backgroundColor: AppTheme.of(context).error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24.0,
            ),
            SizedBox(height: 4.0),
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}