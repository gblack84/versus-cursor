import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/app_theme.dart';

class MediaSelectionBoxMulti extends StatefulWidget {
  final String label; // 'A' or 'B'
  final bool isSelected;
  final bool isVideoSelected;
  final VoidCallback onTap;
  final Function(int index)? onCancel;  // 인덱스를 받도록 변경
  final bool isHorizontal;
  final Color boxColor;
  final List<String> imageUrls; // 멀티 이미지 URL 리스트
  final bool showPlusIcon; // A박스 전용 + 아이콘 표시
  final VoidCallback? onPlusIconTap; // + 아이콘 탭 콜백
  final Animation<double>? shakeAnimation; // 흔들림 애니메이션
  final VoidCallback? onEditTap; // 편집 버튼 탭 콜백
  final VoidCallback? onAddImageTap; // 이미지 추가 버튼 탭 콜백

  const MediaSelectionBoxMulti({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.isVideoSelected,
    required this.onTap,
    this.onCancel,
    required this.isHorizontal,
    required this.boxColor,
    required this.imageUrls,
    this.showPlusIcon = false,
    this.onPlusIconTap,
    this.shakeAnimation,
    this.onEditTap,
    this.onAddImageTap,
  }) : super(key: key);
  
  @override
  State<MediaSelectionBoxMulti> createState() => _MediaSelectionBoxMultiState();
}

class _MediaSelectionBoxMultiState extends State<MediaSelectionBoxMulti> {
  late PageController _pageController;
  int _currentIndex = 0;
  
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
    final double boxHeight = widget.isSelected 
        ? (widget.isHorizontal ? 350.0 : 250.0)
        : (widget.isHorizontal ? 200.0 : 150.0);
    
    final double iconSize = widget.isSelected
        ? (widget.isHorizontal ? 300.0 : 250.0)
        : (widget.isHorizontal ? 180.0 : 100.0);

    Widget content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          widget.label == 'A' ? 5.0 : 2.5,
          widget.label == 'A' ? 2.5 : 0.0,
          widget.label == 'B' ? 5.0 : 2.5,
          2.5),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: widget.isHorizontal ? double.infinity : null,
          height: boxHeight,
          decoration: BoxDecoration(
            color: widget.boxColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              // 이미지가 있으면 이미지 표시, 없으면 아이콘 표시
              if (widget.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    children: [
                      // PageView로 여러 이미지 표시
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: widget.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            memCacheWidth: widget.isHorizontal 
                              ? (widget.isSelected ? 380 : 190) 
                              : (widget.isSelected ? 350 : 250),
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.of(context).primary,
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print('이미지 로드 에러: $error');
                              print('문제 URL: $url');
                              return Icon(
                                Icons.error,
                                color: AppTheme.of(context).error,
                              );
                            },
                          );
                        },
                      ),
                      // 페이지 인디케이터 (이미지가 2개 이상일 때만 표시)
                      if (widget.imageUrls.length > 1)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.imageUrls.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentIndex
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                // Main Icon
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: widget.isVideoSelected
                      ? Icon(
                          Icons.videocam,
                          color: AppTheme.of(context).primaryText,
                          size: iconSize,
                        )
                      : FaIcon(
                          FontAwesomeIcons.image,
                          color: AppTheme.of(context).primaryText,
                          size: iconSize,
                        ),
                ),
              // Label (A or B)
              Align(
                alignment: AlignmentDirectional(-1.0, -1.0),
                child: Padding(
                  padding: EdgeInsets.all(widget.isHorizontal ? 8.0 : 10.0),
                  child: Text(
                    widget.label,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: AppTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 50.0,
                          letterSpacing: 0.0,
                          color: widget.imageUrls.isNotEmpty
                              ? Colors.white 
                              : AppTheme.of(context).primaryText,
                          fontWeight: AppTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle: AppTheme.of(context)
                              .bodyMedium
                              .fontStyle,
                        ),
                  ),
                ),
              ),
              // 오른쪽 상단 아이콘 처리
              // A박스 - 이미지가 있을 때 X 아이콘 (삭제)
              if (widget.label == 'A' && widget.imageUrls.isNotEmpty && widget.onCancel != null)
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsets.all(widget.isHorizontal ? 10.0 : 10.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => widget.onCancel?.call(_currentIndex),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
              // + 아이콘 - A박스에서 이미지가 없을 때만 표시 (B박스 표시용)
              if (widget.label == 'A' && widget.imageUrls.isEmpty && widget.showPlusIcon && widget.onPlusIconTap != null)
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsets.all(widget.isHorizontal ? 10.0 : 10.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: widget.onPlusIconTap,
                      child: Icon(
                        Icons.add,
                        color: AppTheme.of(context).primaryText,
                        size: 29.0,
                      ),
                    ),
                  ),
                ),
              // B박스의 X 아이콘 - 항상 표시
              if (widget.label == 'B' && widget.onCancel != null)
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsets.all(widget.isHorizontal ? 10.0 : 10.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => widget.onCancel?.call(_currentIndex),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
              // 이미지가 있을 때 오른쪽 하단 아이콘들
              if (widget.imageUrls.isNotEmpty)
                Positioned(
                  right: 12.0,
                  bottom: 12.0,
                  child: widget.isHorizontal 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // +B 아이콘 (A박스에만, B박스가 숨겨진 상태일 때)
                          if (widget.label == 'A' && widget.showPlusIcon && widget.onPlusIconTap != null)
                            Container(
                              margin: EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                color: Colors.white,
                                iconSize: 29.0,
                                padding: EdgeInsets.all(8.0),
                                constraints: BoxConstraints(
                                  minWidth: 45.0,
                                  minHeight: 45.0,
                                ),
                                onPressed: widget.onPlusIconTap,
                              ),
                            ),
                          // +이미지 아이콘
                          Container(
                            margin: EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add_photo_alternate_outlined),
                              color: Colors.white,
                              iconSize: 29.0,
                              padding: EdgeInsets.all(8.0),
                              constraints: BoxConstraints(
                                minWidth: 45.0,
                                minHeight: 45.0,
                              ),
                              onPressed: widget.onAddImageTap,
                            ),
                          ),
                          // 편집 아이콘
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.edit_outlined),
                              color: Colors.white,
                              iconSize: 29.0,
                              padding: EdgeInsets.all(8.0),
                              constraints: BoxConstraints(
                                minWidth: 45.0,
                                minHeight: 45.0,
                              ),
                              onPressed: widget.onEditTap,
                            ),
                          ),
                        ],
                      )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // +B 아이콘 (A박스에만, B박스가 숨겨진 상태일 때)
                      if (widget.label == 'A' && widget.showPlusIcon && widget.onPlusIconTap != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.white,
                            iconSize: 29.0,
                            padding: EdgeInsets.all(8.0),
                            constraints: BoxConstraints(
                              minWidth: 45.0,
                              minHeight: 45.0,
                            ),
                            onPressed: widget.onPlusIconTap,
                          ),
                        ),
                      // +이미지 아이콘
                      Container(
                        margin: EdgeInsets.only(bottom: widget.isHorizontal ? 0.0 : 8.0, right: widget.isHorizontal ? 8.0 : 0.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add_photo_alternate_outlined),
                          color: Colors.white,
                          iconSize: 29.0,
                          padding: EdgeInsets.all(8.0),
                          constraints: BoxConstraints(
                            minWidth: 45.0,
                            minHeight: 45.0,
                          ),
                          onPressed: widget.onAddImageTap,
                        ),
                      ),
                      // 편집 아이콘
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit_outlined),
                          color: Colors.white,
                          iconSize: 29.0,
                          padding: EdgeInsets.all(8.0),
                          constraints: BoxConstraints(
                            minWidth: 45.0,
                            minHeight: 45.0,
                          ),
                          onPressed: widget.onEditTap,
                        ),
                      ),
                    ],
                  ),
                ),
              // 이미지 카운터 (이미지가 2개 이상일 때만 표시)
              if (widget.imageUrls.length > 1)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    
    // 흔들림 애니메이션이 있으면 Transform으로 감싸기
    if (widget.shakeAnimation != null) {
      return AnimatedBuilder(
        animation: widget.shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(widget.shakeAnimation!.value, 0),
            child: child,
          );
        },
        child: content,
      );
    }
    
    return content;
  }
}