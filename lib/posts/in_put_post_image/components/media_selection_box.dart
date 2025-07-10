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
  final double? dynamicHeight; // 동적 높이 (null이면 기본값 사용)
  final double? dynamicWidth; // 동적 너비 (null이면 기본값 사용)
  final String? moderationStatus; // 이미지 검열 상태

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
    this.dynamicHeight,
    this.dynamicWidth,
    this.moderationStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 동적 높이가 제공되면 사용, 없으면 기본값 사용
    final double boxHeight = dynamicHeight ?? (isSelected 
        ? (isHorizontal ? 350.0 : 250.0)
        : (isHorizontal ? 200.0 : 150.0));
    
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
          width: dynamicWidth ?? (isHorizontal ? double.infinity : null),
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
                    memCacheWidth: isHorizontal 
                      ? (isSelected ? 380 : 190) 
                      : (isSelected ? 350 : 250),
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
                                onPressed: onPlusIconTap,
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
                              onPressed: onAddImageTap,
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
                            onPressed: onPlusIconTap,
                          ),
                        ),
                      // +이미지 아이콘
                      Container(
                        margin: EdgeInsets.only(bottom: isHorizontal ? 0.0 : 8.0, right: isHorizontal ? 8.0 : 0.0),
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
                          onPressed: onAddImageTap,
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
                          onPressed: onEditTap,
                        ),
                      ),
                    ],
                  ),
                ),
            
              // 검열 상태 표시 및 오버레이
              if (imageUrl != null && imageUrl!.isNotEmpty && moderationStatus != null)
                ...[
                  // 거부된 이미지 오버레이
                  if (moderationStatus == 'rejected')
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              color: Colors.white,
                              size: 48.0,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '부적절한 콘텐츠',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              ),
                              child: Text(
                                '다시 선택',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // 검열 중 오버레이
                  if (moderationStatus == 'pending' || moderationStatus == 'moderating')
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3.0,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              '안전성 검사 중...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // 상태 표시 배지
                  Positioned(
                    left: 12.0,
                    bottom: 12.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: _getModerationStatusColor(moderationStatus!).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (moderationStatus == 'pending' || moderationStatus == 'moderating')
                            SizedBox(
                              width: 12.0,
                              height: 12.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          if (moderationStatus == 'approved')
                            Icon(Icons.check_circle, color: Colors.white, size: 16.0),
                          if (moderationStatus == 'rejected')
                            Icon(Icons.error, color: Colors.white, size: 16.0),
                          SizedBox(width: 6.0),
                          Text(
                            _getModerationStatusText(moderationStatus!),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
  
  Color _getModerationStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'moderating':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'error':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  String _getModerationStatusText(String status) {
    switch (status) {
      case 'pending':
      case 'moderating':
        return '검사 중...';
      case 'approved':
        return '승인됨';
      case 'rejected':
        return '거부됨';
      case 'error':
        return '오류';
      default:
        return status;
    }
  }
}