import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/app_theme.dart';

class MediaSelectionBox extends StatelessWidget {
  final String label; // 'A' or 'B'
  final bool isSelected;
  final bool isVideoSelected;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final bool isHorizontal;
  final Color boxColor;
  final String? imageUrl; // 선택된 이미지 URL
  final bool showPlusIcon; // A박스 전용 + 아이콘 표시
  final VoidCallback? onPlusIconTap; // + 아이콘 탭 콜백
  final Animation<double>? shakeAnimation; // 흔들림 애니메이션
  final VoidCallback? onEditTap; // 편집 버튼 탭 콜백
  final VoidCallback? onAddImageTap; // 이미지 추가 버튼 탭 콜백

  const MediaSelectionBox({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.isVideoSelected,
    required this.onTap,
    this.onCancel,
    required this.isHorizontal,
    required this.boxColor,
    this.imageUrl,
    this.showPlusIcon = false,
    this.onPlusIconTap,
    this.shakeAnimation,
    this.onEditTap,
    this.onAddImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double boxHeight = isSelected 
        ? (isHorizontal ? 350.0 : 250.0)
        : (isHorizontal ? 200.0 : 150.0);
    
    final double iconSize = isSelected
        ? (isHorizontal ? 300.0 : 250.0)  // 세로 레이아웃에서 선택된 경우 적절한 크기
        : (isHorizontal ? 180.0 : 100.0);

    Widget content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          label == 'A' ? 5.0 : 2.5,
          label == 'A' ? 2.5 : 0.0,
          label == 'B' ? 5.0 : 2.5,
          2.5),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: isHorizontal ? double.infinity : null,
          height: boxHeight,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              // 이미지가 있으면 이미지 표시, 없으면 아이콘 표시
              if (imageUrl != null && imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                  ),
                )
              else
                // Main Icon
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: isVideoSelected
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
                  padding: EdgeInsets.all(isHorizontal ? 8.0 : 10.0),
                  child: Text(
                    label,
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
                          color: (imageUrl != null && imageUrl!.isNotEmpty) 
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
              if (label == 'A' && imageUrl != null && imageUrl!.isNotEmpty && onCancel != null)
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsets.all(isHorizontal ? 10.0 : 10.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: onCancel,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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
              if (label == 'A' && (imageUrl == null || imageUrl!.isEmpty) && showPlusIcon && onPlusIconTap != null)
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsets.all(isHorizontal ? 10.0 : 10.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: onPlusIconTap,
                      child: Icon(
                        Icons.add,
                        color: AppTheme.of(context).primaryText,
                        size: 29.0,
                      ),
                    ),
                  ),
                ),
              // B박스의 X 아이콘 - 항상 표시
              if (label == 'B' && onCancel != null)
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsets.all(isHorizontal ? 10.0 : 10.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: onCancel,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Positioned(
                  right: 12.0,
                  bottom: 12.0,
                  child: isHorizontal 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // +B 아이콘 (A박스에만, B박스가 숨겨진 상태일 때)
                          if (label == 'A' && showPlusIcon && onPlusIconTap != null)
                            Container(
                              margin: EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
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
                                onPressed: onPlusIconTap,
                              ),
                            ),
                          // +이미지 아이콘
                          Container(
                            margin: EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
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
                              onPressed: onAddImageTap,
                            ),
                          ),
                          // 편집 아이콘
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
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
                              onPressed: onEditTap,
                            ),
                          ),
                        ],
                      )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // +B 아이콘 (A박스에만, B박스가 숨겨진 상태일 때)
                      if (label == 'A' && showPlusIcon && onPlusIconTap != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
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
                            onPressed: onPlusIconTap,
                          ),
                        ),
                      // +이미지 아이콘
                      Container(
                        margin: EdgeInsets.only(bottom: isHorizontal ? 0.0 : 8.0, right: isHorizontal ? 8.0 : 0.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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
                          onPressed: onAddImageTap,
                        ),
                      ),
                      // 편집 아이콘
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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
                          onPressed: onEditTap,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    
    // 흔들림 애니메이션이 있으면 Transform으로 감싸기
    if (shakeAnimation != null) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shakeAnimation!.value, 0),
            child: child,
          );
        },
        child: content,
      );
    }
    
    return content;
  }
}