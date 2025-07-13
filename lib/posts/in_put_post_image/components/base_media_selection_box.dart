import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/app_theme.dart';
import '../utils/debug_helper.dart';

/// MediaSelectionBox의 기본 추상 클래스
abstract class BaseMediaSelectionBox extends StatefulWidget {
  final String label; // 'A' or 'B'
  final bool isSelected;
  final bool isVideoSelected;
  final VoidCallback onTap;
  final bool isHorizontal;
  final Color boxColor;
  final List<String> imageUrls;
  final bool showPlusIcon;
  final VoidCallback? onPlusIconTap;
  final Animation<double>? shakeAnimation;
  final double? dynamicHeight;
  final double? dynamicWidth;

  const BaseMediaSelectionBox({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.isVideoSelected,
    required this.onTap,
    required this.isHorizontal,
    required this.boxColor,
    required this.imageUrls,
    this.showPlusIcon = false,
    this.onPlusIconTap,
    this.shakeAnimation,
    this.dynamicHeight,
    this.dynamicWidth,
  }) : super(key: key);
}

/// 공통 기능을 제공하는 State 믹스인
mixin MediaSelectionBoxMixin<T extends BaseMediaSelectionBox> on State<T> {
  
  /// 박스 높이 계산
  double getBoxHeight() {
    return widget.dynamicHeight ?? (widget.isSelected 
        ? (widget.isHorizontal ? 350.0 : 250.0)
        : (widget.isHorizontal ? 350.0 : 200.0));
  }

  /// 아이콘 크기 계산
  double getIconSize(double boxHeight) {
    final double iconRatio = widget.isHorizontal ? 0.45 : 0.40;
    final double calculatedIconSize = boxHeight * iconRatio;
    return calculatedIconSize.clamp(80.0, 300.0);
  }

  /// 메모리 캐시 너비 계산
  int calculateMemCacheWidth() {
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

  /// 기본 컨테이너 빌드
  Widget buildContainer({required Widget child}) {
    final boxHeight = getBoxHeight();

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
          child: child,
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

  /// 라벨 빌드
  Widget buildLabel({Color? color}) {
    return Align(
      alignment: AlignmentDirectional(-1.0, -1.0),
      child: Padding(
        padding: EdgeInsets.all(widget.isHorizontal ? 8.0 : 10.0),
        child: Text(
          widget.label,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
                fontSize: 50.0,
                letterSpacing: 0.0,
                color: color ?? (widget.imageUrls.isNotEmpty
                    ? Colors.white 
                    : AppTheme.of(context).primaryText),
              ),
        ),
      ),
    );
  }

  /// 메인 아이콘 빌드 (이미지가 없을 때)
  Widget buildMainIcon(double iconSize) {
    return Align(
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
    );
  }

  /// + 아이콘 빌드 (A박스 전용)
  Widget? buildPlusIcon() {
    if (widget.label == 'A' && 
        widget.imageUrls.isEmpty && 
        widget.showPlusIcon && 
        widget.onPlusIconTap != null) {
      return Align(
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
      );
    }
    return null;
  }

  /// 이미지 프리로드
  void preloadImages() {
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

  /// 원격 이미지 빌드
  Widget buildRemoteImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: calculateMemCacheWidth(),
      placeholder: (context, url) => Container(
        color: AppTheme.of(context).secondaryBackground,
        child: const SizedBox.shrink(),
      ),
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 150),
      errorWidget: (context, url, error) {
        if (!mounted) return const SizedBox.shrink();
        DebugHelper.logError('이미지 로드 에러', error);
        DebugHelper.logError('문제 URL: $url');
        return Icon(
          Icons.error,
          color: AppTheme.of(context).error,
        );
      },
    );
  }

  /// 액션 버튼 스타일
  Widget buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 29.0,
        padding: EdgeInsets.all(8.0),
        constraints: BoxConstraints(
          minWidth: 45.0,
          minHeight: 45.0,
        ),
        onPressed: onPressed,
      ),
    );
  }

  /// X 버튼 스타일
  Widget buildCloseButton({
    required VoidCallback onTap,
    bool isSmall = true,
  }) {
    if (isSmall) {
      return Container(
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
      );
    } else {
      return Icon(
        Icons.cancel,
        color: Colors.black.withValues(alpha: 0.6),
        size: 40.0,
      );
    }
  }
}