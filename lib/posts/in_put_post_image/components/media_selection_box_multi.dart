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
  final double? dynamicHeight; // 동적 높이 (null이면 기본값 사용)
  final double? dynamicWidth; // 동적 너비 (null이면 기본값 사용)
  final Function(int index)? onCurrentIndexChanged; // 현재 인덱스 변경 콜백

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
    this.dynamicHeight,
    this.dynamicWidth,
    this.onCurrentIndexChanged,
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
    _currentIndex = 0; // 명시적으로 0으로 초기화
    _pageController = PageController(initialPage: 0);
    
    // 첫 번째와 두 번째 이미지 프리로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imageUrls.isNotEmpty) {
        // 첫 번째 이미지
        precacheImage(
          CachedNetworkImageProvider(
            widget.imageUrls[0],
            cacheKey: widget.imageUrls[0],
          ),
          context,
        );
        
        // 두 번째 이미지가 있으면 프리로드
        if (widget.imageUrls.length > 1) {
          precacheImage(
            CachedNetworkImageProvider(
              widget.imageUrls[1],
              cacheKey: widget.imageUrls[1],
            ),
            context,
          );
        }
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  /// 메모리 캐시 너비 계산
  int _calculateMemCacheWidth() {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    double baseWidth;
    if (widget.dynamicWidth != null && widget.dynamicWidth!.isFinite) {
      baseWidth = widget.dynamicWidth!;
    } else {
      baseWidth = widget.isHorizontal 
          ? MediaQuery.of(context).size.width / 2 
          : MediaQuery.of(context).size.width;
    }
    
    final targetWidth = (baseWidth * pixelRatio).round();
    return targetWidth.clamp(200, 800);
  }

  @override
  void didUpdateWidget(MediaSelectionBoxMulti oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 이미지 개수가 변경되었을 때
    if (widget.imageUrls.length != oldWidget.imageUrls.length) {
      print('${widget.label}박스 이미지 개수 변경: ${oldWidget.imageUrls.length} → ${widget.imageUrls.length}');
      
      // 현재 인덱스가 범위를 벗어나면 조정
      if (_currentIndex >= widget.imageUrls.length && widget.imageUrls.isNotEmpty) {
        _currentIndex = widget.imageUrls.length - 1;
        print('${widget.label}박스 인덱스 조정: $_currentIndex');
        // PageController가 attach 상태인지 확인
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      } else if (widget.imageUrls.isEmpty) {
        _currentIndex = 0;
      }
    }
  }
  
  Widget _buildRemoteImage(int index) {
    if (index >= widget.imageUrls.length) {
      return Icon(
        Icons.error,
        color: AppTheme.of(context).error,
      );
    }
    
    return CachedNetworkImage(
      imageUrl: widget.imageUrls[index],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: _calculateMemCacheWidth(),
      placeholder: (context, url) => Container(
        color: AppTheme.of(context).secondaryBackground,
        child: const SizedBox.shrink(),
      ),
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 150),
      errorWidget: (context, url, error) {
        print('이미지 로드 에러: $error');
        print('문제 URL: $url');
        return Icon(
          Icons.error,
          color: AppTheme.of(context).error,
        );
      },
    );
  }
  
  /// 우측 상단 클로즈 버튼 빌드
  Widget? _buildTopRightCloseButton() {
    // A박스 - 이미지가 있을 때 X 아이콘 (삭제)
    if (widget.label == 'A' && widget.imageUrls.isNotEmpty && widget.onCancel != null) {
      return Align(
        alignment: AlignmentDirectional(1.0, -1.0),
        child: Padding(
          padding: EdgeInsets.all(widget.isHorizontal ? 10.0 : 10.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              final safeIndex = widget.imageUrls.isEmpty ? 0 : _currentIndex.clamp(0, widget.imageUrls.length - 1);
              print('${widget.label}박스 이미지 삭제 시도 - 현재 인덱스: $_currentIndex, 안전한 인덱스: $safeIndex, 전체 이미지 수: ${widget.imageUrls.length}');
              widget.onCancel?.call(safeIndex);
            },
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
      );
    }
    
    // B박스의 X 아이콘 - 이미지 유무에 따라 다른 스타일
    if (widget.label == 'B' && widget.onCancel != null) {
      return Align(
        alignment: AlignmentDirectional(1.0, -1.0),
        child: Padding(
          padding: EdgeInsets.all(widget.isHorizontal ? 10.0 : 10.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              final safeIndex = widget.imageUrls.isEmpty ? 0 : _currentIndex.clamp(0, widget.imageUrls.length - 1);
              print('${widget.label}박스 이미지 삭제 시도 - 현재 인덱스: $_currentIndex, 안전한 인덱스: $safeIndex, 전체 이미지 수: ${widget.imageUrls.length}');
              widget.onCancel?.call(safeIndex);
            },
            child: widget.imageUrls.isNotEmpty
              ? Container(
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
                )
              : Icon(
                  Icons.cancel,
                  color: Colors.black.withValues(alpha: 0.6),
                  size: 40.0,
                ),
          ),
        ),
      );
    }
    
    return null;
  }

  /// 액션 버튼들 빌드
  Widget? _buildActionButtons() {
    if (widget.imageUrls.isEmpty) return null;
    
    return Positioned(
      right: 12.0,
      bottom: 12.0,
      child: widget.isHorizontal 
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildActionButtonList(),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildActionButtonList(),
          ),
    );
  }
  
  /// 액션 버튼 리스트 생성
  List<Widget> _buildActionButtonList() {
    final buttons = <Widget>[];
    
    // +B 아이콘 (A박스에만, B박스가 숨겨진 상태일 때)
    if (widget.label == 'A' && widget.showPlusIcon && widget.onPlusIconTap != null) {
      buttons.add(
        Container(
          margin: EdgeInsets.only(
            bottom: widget.isHorizontal ? 8.0 : 0.0,
            right: widget.isHorizontal ? 0.0 : 8.0,
          ),
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
            onPressed: widget.onPlusIconTap!,
          ),
        ),
      );
    }
    
    // +이미지 아이콘
    buttons.add(
      Container(
        margin: EdgeInsets.only(
          bottom: widget.isHorizontal ? 8.0 : 0.0,
          right: widget.isHorizontal ? 0.0 : 8.0,
        ),
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
          onPressed: widget.onAddImageTap ?? () {},
        ),
      ),
    );
    
    // 편집 아이콘
    buttons.add(
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
          onPressed: widget.onEditTap ?? () {},
        ),
      ),
    );
    
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    // 동적 높이가 제공되면 사용, 아니면 기본값 사용
    final double boxHeight = widget.dynamicHeight ?? (widget.isSelected 
        ? (widget.isHorizontal ? 350.0 : 250.0)
        : (widget.isHorizontal ? 350.0 : 200.0));
    
    if (widget.dynamicHeight != null) {
      print('${widget.label}박스: dynamicHeight=${widget.dynamicHeight}, isHorizontal=${widget.isHorizontal}');
    }
    
    // 박스 높이에 비례한 동적 아이콘 크기 계산
    // 가로형일 때는 45%, 세로형일 때는 40%
    final double iconRatio = widget.isHorizontal ? 0.45 : 0.40;
    final double calculatedIconSize = boxHeight * iconRatio;
    
    // 최소 80px, 최대 300px로 제한
    final double iconSize = calculatedIconSize.clamp(80.0, 300.0);

    Widget content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: widget.dynamicWidth ?? (widget.isHorizontal ? double.infinity : null),
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
                      Container(
                        color: AppTheme.of(context).secondaryBackground,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.imageUrls.length,
                          pageSnapping: true,
                          physics: const PageScrollPhysics(),
                          allowImplicitScrolling: true, // 인접 페이지 프리로딩
                          onPageChanged: (index) {
                            print('${widget.label}박스 PageView 페이지 변경: $index');
                            setState(() {
                              _currentIndex = index;
                            });
                            // 현재 인덱스 변경을 부모에게 알림
                            widget.onCurrentIndexChanged?.call(index);
                            
                            // 다음 이미지 프리로드
                            if (index < widget.imageUrls.length - 1) {
                              precacheImage(
                                CachedNetworkImageProvider(
                                  widget.imageUrls[index + 1],
                                  cacheKey: widget.imageUrls[index + 1],
                                ),
                                context,
                              );
                            }
                            // 이전 이미지도 프리로드 (뒤로 스와이프 대비)
                            if (index > 0) {
                              precacheImage(
                                CachedNetworkImageProvider(
                                  widget.imageUrls[index - 1],
                                  cacheKey: widget.imageUrls[index - 1],
                                ),
                                context,
                              );
                            }
                          },
                          itemBuilder: (context, index) {
                            return _buildRemoteImage(index);
                          },
                        ),
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
                      : Icon(
                          Icons.image,
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
                    style: TextStyle(
                      fontSize: 50.0,
                      letterSpacing: 0.0,
                      color: widget.imageUrls.isNotEmpty
                          ? Colors.white 
                          : AppTheme.of(context).primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 우측 상단 클로즈 버튼
              if (_buildTopRightCloseButton() != null) _buildTopRightCloseButton()!,
              // 액션 버튼들 (이미지가 있을 때만)
              if (_buildActionButtons() != null) _buildActionButtons()!,
              // 이미지 카운터
              if (_buildImageCounter() != null) _buildImageCounter()!,
            ],
          ),
        ),
      ),
    );
    
    // 흔들림 애니메이션 적용
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
  
  /// 이미지 카운터 빌드
  Widget? _buildImageCounter() {
    if (widget.imageUrls.length <= 1) return null;
    
    return Positioned(
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
    );
  }
}