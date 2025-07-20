import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/design_system/design_system.dart';
import '../models/versus_box_size_data.dart';
import '../services/versus_box_size_calculator.dart';
import '../constants/voting_notification_constraints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';

/// 투표 알림에서 사용되는 A/B 박스 컴포넌트
/// 
/// 질문 작성 페이지에서 생성된 사이즈 데이터를 기반으로
/// 일관된 크기와 레이아웃을 투표 알림에서 재현합니다.
class VersusNotificationBox extends StatelessWidget {
  /// 박스 타입 ('A' 또는 'B')
  final String boxType;
  
  /// 박스 크기
  final Size boxSize;
  
  /// 박스 제목
  final String title;
  
  /// 이미지 URL (선택사항)
  final String? imageUrl;
  
  /// 박스 클릭 콜백
  final VoidCallback? onTap;
  
  /// 선택된 상태 여부
  final bool isSelected;
  
  /// 투표 결과 표시 여부
  final bool showResult;
  
  /// 투표 비율 (0.0 ~ 1.0)
  final double? votePercentage;
  
  /// 투표 수
  final int? voteCount;
  
  /// 애니메이션 컨트롤러
  final AnimationController? animationController;
  
  /// 커스텀 그라데이션 색상
  final List<Color>? gradientColors;
  
  /// 텍스트 크기 (자동 계산되지만 오버라이드 가능)
  final double? customTextSize;
  
  /// 라벨 표시 여부 (A/B 라벨)
  final bool showLabel;
  
  /// 디버그 정보 표시 여부
  final bool showDebugInfo;

  const VersusNotificationBox({
    Key? key,
    required this.boxType,
    required this.boxSize,
    required this.title,
    this.imageUrl,
    this.onTap,
    this.isSelected = false,
    this.showResult = false,
    this.votePercentage,
    this.voteCount,
    this.animationController,
    this.gradientColors,
    this.customTextSize,
    this.showLabel = true,
    this.showDebugInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildAnimatedBox(context);
  }
  
  /// 애니메이션이 적용된 박스 위젯
  Widget _buildAnimatedBox(BuildContext context) {
    if (animationController != null) {
      return AnimatedBuilder(
        animation: animationController!,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (0.05 * animationController!.value),
            child: _buildBoxContainer(context),
          );
        },
      );
    }
    
    return _buildBoxContainer(context);
  }
  
  /// 박스 컨테이너 위젯
  Widget _buildBoxContainer(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: boxSize.width,
        height: boxSize.height,
        decoration: _buildBoxDecoration(),
        child: Stack(
          children: [
            // 배경 이미지 또는 그라데이션
            _buildBackground(),
            
            // 투표 결과 오버레이
            if (showResult) _buildResultOverlay(),
            
            // 선택 상태 오버레이
            if (isSelected) _buildSelectionOverlay(),
            
            // 컨텐츠 (제목, 라벨 등)
            _buildContent(),
            
            // 디버그 정보
            if (showDebugInfo) _buildDebugInfo(),
          ],
        ),
      ),
    );
  }
  
  /// 박스 장식 (테두리, 그림자 등)
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: VersusRadius.container,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: VotingNotificationConstraints.shadowOpacity),
          blurRadius: VotingNotificationConstraints.shadowBlurRadius,
          offset: VotingNotificationConstraints.shadowOffset,
        ),
      ],
      border: isSelected 
          ? Border.all(
              color: VersusColors.primary,
              width: 2.0,
            )
          : null,
    );
  }
  
  /// 배경 위젯 (이미지 또는 그라데이션)
  Widget _buildBackground() {
    return ClipRRect(
      borderRadius: VersusRadius.container,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? _buildImageBackground()
          : _buildGradientBackground(),
    );
  }
  
  /// 이미지 배경
  Widget _buildImageBackground() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: boxSize.width,
      height: boxSize.height,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: (boxSize.width * 2).round(), // 고해상도 지원
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }
  
  /// 그라데이션 배경
  Widget _buildGradientBackground() {
    final colors = gradientColors ?? _getDefaultGradientColors();
    
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
  
  /// 기본 그라데이션 색상
  List<Color> _getDefaultGradientColors() {
    if (boxType == 'A') {
      return [
        VersusColors.primary,
        VersusColors.primary.withValues(alpha: 0.8),
      ];
    } else {
      return [
        VersusColors.secondary,
        VersusColors.secondary.withValues(alpha: 0.8),
      ];
    }
  }
  
  /// 투표 결과 오버레이
  Widget _buildResultOverlay() {
    if (votePercentage == null) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: VersusRadius.container,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(votePercentage! * 100).toStringAsFixed(1)}%',
                  style: VersusTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontSize: _getAdaptiveTextSize() * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (voteCount != null)
                  Text(
                    '$voteCount표',
                    style: VersusTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                      fontSize: _getAdaptiveTextSize() * 0.8,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 선택 상태 오버레이
  Widget _buildSelectionOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: VersusRadius.container,
          color: VersusColors.primary.withValues(alpha: 0.3),
        ),
        child: Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.white,
            size: VotingNotificationConstraints.statusIconSize * 1.5,
          ),
        ),
      ),
    );
  }
  
  /// 컨텐츠 (제목, 라벨 등)
  Widget _buildContent() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A/B 라벨
            if (showLabel) _buildLabel(),
            
            const Spacer(),
            
            // 제목
            _buildTitle(),
          ],
        ),
      ),
    );
  }
  
  /// A/B 라벨
  Widget _buildLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: VersusRadius.radiusSmall,
      ),
      child: Text(
        boxType,
        style: VersusTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontSize: VotingNotificationConstraints.labelIconSize * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// 제목
  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: VersusRadius.radiusSmall,
      ),
      child: Text(
        title,
        style: VersusTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontSize: _getAdaptiveTextSize(),
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  /// 플레이스홀더 위젯
  Widget _buildPlaceholder() {
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      color: VersusColors.borderLight,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              VersusColors.primary,
            ),
          ),
        ),
      ),
    );
  }
  
  /// 에러 위젯
  Widget _buildErrorWidget() {
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      decoration: BoxDecoration(
        color: VersusColors.borderLight,
        borderRadius: VersusRadius.container,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: VotingNotificationConstraints.statusIconSize,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapXS,
          Text(
            '이미지 로드 실패',
            style: VersusTextStyles.labelSmall.copyWith(
              fontSize: _getAdaptiveTextSize() * 0.8,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 디버그 정보 위젯
  Widget _buildDebugInfo() {
    return Positioned(
      top: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          '${boxSize.width.toStringAsFixed(0)}x${boxSize.height.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
  
  /// 적응형 텍스트 크기 계산
  double _getAdaptiveTextSize() {
    if (customTextSize != null) return customTextSize!;
    
    return VotingNotificationConstraints.getAdaptiveTextSize(
      boxSize.height,
      baseTextSize: VotingNotificationConstraints.defaultTextSize,
    );
  }
}

/// 투표 알림 박스 빌더
/// 
/// VersusBoxSizeData를 받아서 자동으로 VersusNotificationBox를 생성합니다.
class VersusNotificationBoxBuilder {
  /// 사이즈 데이터를 기반으로 박스 위젯 생성
  static Widget buildFromSizeData({
    required BuildContext context,
    required VersusBoxSizeData sizeData,
    required String boxType,
    required String title,
    String? imageUrl,
    VoidCallback? onTap,
    bool isSelected = false,
    bool showResult = false,
    double? votePercentage,
    int? voteCount,
    AnimationController? animationController,
    bool showDebugInfo = false,
  }) {
    // 투표용 크기 계산
    final votingSizes = VersusBoxSizeCalculator.calculateVotingSize(
      sizeData,
      context,
    );
    
    // 박스 타입에 따른 크기 선택
    final boxSize = boxType == 'A' ? votingSizes.sizeA : votingSizes.sizeB;
    
    return VersusNotificationBox(
      boxType: boxType,
      boxSize: boxSize,
      title: title,
      imageUrl: imageUrl,
      onTap: onTap,
      isSelected: isSelected,
      showResult: showResult,
      votePercentage: votePercentage,
      voteCount: voteCount,
      animationController: animationController,
      showDebugInfo: showDebugInfo,
    );
  }
  
  /// A/B 박스 쌍 생성
  static Widget buildBoxPair({
    required BuildContext context,
    required VersusBoxSizeData sizeData,
    required String titleA,
    required String titleB,
    String? imageUrlA,
    String? imageUrlB,
    VoidCallback? onTapA,
    VoidCallback? onTapB,
    String? selectedBox,
    bool showResults = false,
    double? votePercentageA,
    double? votePercentageB,
    int? voteCountA,
    int? voteCountB,
    AnimationController? animationController,
    bool showDebugInfo = false,
  }) {
    // 투표용 크기 계산
    final votingSizes = VersusBoxSizeCalculator.calculateVotingSize(
      sizeData,
      context,
    );
    
    // 레이아웃에 따른 배치
    if (votingSizes.layoutType == LayoutType.horizontal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'A',
            title: titleA,
            imageUrl: imageUrlA,
            onTap: onTapA,
            isSelected: selectedBox == 'A',
            showResult: showResults,
            votePercentage: votePercentageA,
            voteCount: voteCountA,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
          ),
          SizedBox(width: votingSizes.spacing?.horizontal ?? 8.0),
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'B',
            title: titleB,
            imageUrl: imageUrlB,
            onTap: onTapB,
            isSelected: selectedBox == 'B',
            showResult: showResults,
            votePercentage: votePercentageB,
            voteCount: voteCountB,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'A',
            title: titleA,
            imageUrl: imageUrlA,
            onTap: onTapA,
            isSelected: selectedBox == 'A',
            showResult: showResults,
            votePercentage: votePercentageA,
            voteCount: voteCountA,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
          ),
          SizedBox(height: votingSizes.spacing?.vertical ?? 12.0),
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'B',
            title: titleB,
            imageUrl: imageUrlB,
            onTap: onTapB,
            isSelected: selectedBox == 'B',
            showResult: showResults,
            votePercentage: votePercentageB,
            voteCount: voteCountB,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
          ),
        ],
      );
    }
  }
}