import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/features/common/presentation/design_system/design_system.dart';
import '../models/versus_box_size_data.dart';
import '/features/common/data/services/unified_box_calculator.dart';
import '/services/unified_image_cache_service.dart';
import '../constants/voting_notification_constraints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import 'notification_image_viewer.dart';

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
  
  /// 단일 이미지 모드에서 B 타이틀 (A박스에 함께 표시)
  final String? dualModeSecondTitle;
  
  /// 단일 이미지 모드 여부
  final bool isSingleImageMode;
  
  /// 설명 텍스트 (하단에 1줄로 표시)
  final String? description;
  
  /// 이미지 뷰어 표시를 위한 전체 데이터
  final String? question;
  final String? otherOptionTitle;
  final String? otherImageUrl;
  final String? otherDescription;
  
  /// 멀티이미지 지원을 위한 데이터
  final List<String>? imageUrls;
  final List<String>? otherImageUrls;
  
  /// 이미지 탭 가능 여부
  final bool enableImageTap;

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
    this.dualModeSecondTitle,
    this.isSingleImageMode = false,
    this.description,
    this.question,
    this.otherOptionTitle,
    this.otherImageUrl,
    this.otherDescription,
    this.imageUrls,
    this.otherImageUrls,
    this.enableImageTap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '옵션 $boxType: $title',
      selected: isSelected,
      hint: showResult && votePercentage != null 
          ? '투표 결과: ${(votePercentage! * 100).toStringAsFixed(0)}%' 
          : '탭하여 선택',
      child: _buildBox(context),
    );
  }

  Widget _buildBox(BuildContext context) {
    // 멀티이미지 데이터 디버그 (제거됨)
    
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
    // 🚨 안전장치: 박스 크기 제한
    const double maxSafeSize = 1000.0;
    final safeWidth = boxSize.width.clamp(0.0, maxSafeSize); 
    final safeHeight = boxSize.height.clamp(0.0, maxSafeSize);
    
    // 비정상적으로 큰 값이 감지되면 로그 출력 (제거됨)
    
    return GestureDetector(
      onTap: () {
        // 이미지가 있고 이미지 탭이 활성화되어 있으면 이미지 뷰어 표시
        if (enableImageTap && imageUrl != null && question != null) {
          _showImageViewer(context);
        } else if (onTap != null) {
          // 일반 탭 핸들러 실행
          onTap!();
        }
      },
      child: Container(
        width: safeWidth,
        height: safeHeight,
        decoration: _buildBoxDecoration(),
        child: Stack(
          clipBehavior: Clip.none,  // 오버레이 요소가 잘리지 않도록 설정
          children: [
            // 배경 이미지 또는 그라데이션
            _buildBackground(),
            
            // 투표 결과 오버레이
            if (showResult) _buildResultOverlay(),
            
            // 선택 상태 오버레이
            if (isSelected) _buildSelectionOverlay(),
            
            // 컨텐츠 (제목, 라벨 등)
            _buildContent(),
            
            // 멀티이미지 카운트 인디케이터
            if (imageUrls != null && imageUrls!.length > 1) 
              _buildMultiImageIndicator(),
            
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
    // 안전한 크기 계산 (이미 clamp된 값 사용)
    const double maxSafeSize = 1000.0;
    final safeWidth = boxSize.width.clamp(0.0, maxSafeSize); 
    final safeHeight = boxSize.height.clamp(0.0, maxSafeSize);
    
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: safeWidth,
      height: safeHeight,
      fit: BoxFit.cover,
      alignment: Alignment.center,  // 중앙 정렬로 일관성 확보
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: UnifiedImageCacheService.calculateMemCacheWidth(safeWidth), // 통합 캐시 서비스 사용
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
    // showResult가 true여도 votePercentage가 null일 수 있음
    if (!showResult || votePercentage == null) return const SizedBox.shrink();
    
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
    // 단일 이미지 모드에서 듀얼 타이틀 표시
    if (isSingleImageMode && dualModeSecondTitle != null) {
      return _buildDualTitleContent();
    }
    
    return Positioned.fill(
      child: Stack(
        children: [
          // A/B 라벨은 상단에
          Positioned(
            top: 12.0,
            left: 12.0,
            child: showLabel ? _buildLabel() : const SizedBox.shrink(),
          ),
          
          // 제목은 하단에 위치
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: VersusRadius.container.bottomLeft,
                  bottomRight: VersusRadius.container.bottomRight,
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getAdaptiveTextSize(),
                  fontWeight: FontWeight.w600,
                  fontFamily: VersusTextStyles.bodyMedium.fontFamily,
                  letterSpacing: VersusTextStyles.bodyMedium.letterSpacing,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// A/B 라벨
  Widget _buildLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: boxType == 'A' 
          ? VersusColors.primary.withValues(alpha: 0.3)
          : VersusColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4.0),
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
  
  // 이미지 내 텍스트 표시는 제거됨 - 알림 다이얼로그에서는 이미지 외부에 표시
  // 이미지 뷰어에서는 여전히 사용될 수 있으므로 메서드는 유지
  
  /// 플레이스홀더 위젯
  Widget _buildPlaceholder() {
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      color: VersusColors.borderLight,
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
  
  /// 멀티이미지 카운트 인디케이터
  Widget _buildMultiImageIndicator() {
    final imageCount = imageUrls?.length ?? 0;
    
    if (imageCount <= 1) return const SizedBox.shrink();
    
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              '$imageCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
  
  /// 단일 이미지 모드에서 A/B 타이틀을 함께 표시
  Widget _buildDualTitleContent() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: VersusRadius.container.bottomLeft,
              bottomRight: VersusRadius.container.bottomRight,
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A 옵션
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: VersusColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getAdaptiveTextSize() * 0.7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getAdaptiveTextSize() * 0.85,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8.0),
              
              // B 옵션
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: VersusColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getAdaptiveTextSize() * 0.7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      dualModeSecondTitle!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getAdaptiveTextSize() * 0.85,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 적응형 텍스트 크기 계산
  double _getAdaptiveTextSize() {
    if (customTextSize != null) {
      return customTextSize!;
    }
    
    final textSize = VotingNotificationConstraints.getAdaptiveTextSize(
      boxSize.height,
      baseTextSize: VotingNotificationConstraints.defaultTextSize,
    );
    
    // 텍스트 크기 계산 로그 제거됨
    
    return textSize;
  }
  
  /// 이미지 뷰어 표시 (멀티이미지 지원)
  void _showImageViewer(BuildContext context) {
    if (question == null) {
      return;
    }
    
    // 멀티이미지 데이터 준비
    final effectiveImageUrlsA = _getEffectiveImageUrls('A');
    final effectiveImageUrlsB = _getEffectiveImageUrls('B');
    
    // 이미지 뷰어 데이터 로그 제거됨
    
    // 초기 인덱스 계산 (A박스의 모든 이미지 → B박스의 모든 이미지 순서)
    int initialIndex = 0;
    if (boxType == 'B') {
      // B박스를 탭했다면 A박스 이미지들을 건너뛰고 B박스 첫 번째 이미지로 이동
      initialIndex = effectiveImageUrlsA.length;
    }
    
    NotificationImageViewer.show(
      context,
      question: question!,
      // 항상 올바른 A/B 타이틀을 전달
      optionA: boxType == 'A' ? title : (otherOptionTitle ?? ''),
      optionB: boxType == 'A' ? (otherOptionTitle ?? '') : title,
      // 단일 이미지 호환성
      imageUrlA: effectiveImageUrlsA.isNotEmpty ? effectiveImageUrlsA.first : null,
      imageUrlB: effectiveImageUrlsB.isNotEmpty ? effectiveImageUrlsB.first : null,
      // 멀티이미지 지원
      imageUrlsA: effectiveImageUrlsA.isNotEmpty ? effectiveImageUrlsA : null,
      imageUrlsB: effectiveImageUrlsB.isNotEmpty ? effectiveImageUrlsB : null,
      description: description,
      initialIndex: initialIndex,
    );
  }
  
  /// 박스별 효과적인 이미지 URL 리스트 반환
  /// 
  /// 멀티이미지가 있으면 우선 사용, 없으면 단일 이미지 사용
  List<String> _getEffectiveImageUrls(String forBoxType) {
    // _getEffectiveImageUrls 로그 제거됨
    
    if (forBoxType == 'A') {
      // 현재 박스가 A인 경우
      if (boxType == 'A') {
        // 자신의 멀티이미지 우선
        if (imageUrls != null && imageUrls!.isNotEmpty) {
          return imageUrls!;
        }
        // 단일 이미지 사용
        if (imageUrl != null) {
          return [imageUrl!];
        }
      } else {
        // 다른 박스(B)의 데이터 사용
        if (otherImageUrls != null && otherImageUrls!.isNotEmpty) {
          return otherImageUrls!;
        }
        if (otherImageUrl != null) {
          return [otherImageUrl!];
        }
      }
    } else if (forBoxType == 'B') {
      // 현재 박스가 B인 경우
      if (boxType == 'B') {
        // 자신의 멀티이미지 우선
        if (imageUrls != null && imageUrls!.isNotEmpty) {
          return imageUrls!;
        }
        // 단일 이미지 사용
        if (imageUrl != null) {
          return [imageUrl!];
        }
      } else {
        // 다른 박스(A)의 데이터 사용
        if (otherImageUrls != null && otherImageUrls!.isNotEmpty) {
          return otherImageUrls!;
        }
        if (otherImageUrl != null) {
          return [otherImageUrl!];
        }
      }
    }
    return [];
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
    String? description,
    VoidCallback? onTap,
    bool isSelected = false,
    bool showResult = false,
    double? votePercentage,
    int? voteCount,
    AnimationController? animationController,
    bool showDebugInfo = false,
    // 멀티이미지 지원 파라미터 추가
    List<String>? imageUrls,
    List<String>? otherImageUrls,
    String? question,
    String? otherOptionTitle,
    String? otherImageUrl,
    String? otherDescription,
    bool isSingleImageMode = false,
    String? dualModeSecondTitle,
    bool enableImageTap = true,
  }) {
    // 투표용 크기 계산
    final votingSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: MediaQuery.of(context).size.width * 0.92,
      layoutType: sizeData.layoutType,
      aspectRatioA: sizeData.aspectRatioA,
      aspectRatioB: sizeData.aspectRatioB,
      hasImageA: sizeData.hasImageA,
      hasImageB: sizeData.hasImageB,
    );
    
    // 박스 타입에 따른 크기 선택
    final boxSize = boxType == 'A' ? votingSizes.sizeA : votingSizes.sizeB;
    
    return VersusNotificationBox(
      boxType: boxType,
      boxSize: boxSize,
      title: title,
      imageUrl: imageUrl,
      description: description,
      onTap: onTap,
      isSelected: isSelected,
      showResult: showResult,
      votePercentage: votePercentage,
      voteCount: voteCount,
      animationController: animationController,
      showDebugInfo: showDebugInfo,
      // 멀티이미지 지원 파라미터 전달
      imageUrls: imageUrls,
      otherImageUrls: otherImageUrls,
      question: question,
      otherOptionTitle: otherOptionTitle,
      otherImageUrl: otherImageUrl,
      otherDescription: otherDescription,
      isSingleImageMode: isSingleImageMode,
      dualModeSecondTitle: dualModeSecondTitle,
      enableImageTap: enableImageTap,
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
    String? description,
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
    // 멀티이미지 지원 파라미터 추가
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? question,
    bool enableImageTap = true,
  }) {
    // 투표용 크기 계산
    // UnifiedBoxCalculator가 내부적으로 패딩과 간격을 처리함
    final dialogTotalWidth = MediaQuery.of(context).size.width * 0.92;
    
    final votingSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: dialogTotalWidth,  // 전체 다이얼로그 너비 전달
      layoutType: sizeData.layoutType,
      aspectRatioA: sizeData.aspectRatioA,
      aspectRatioB: sizeData.aspectRatioB,
      hasImageA: sizeData.hasImageA,
      hasImageB: sizeData.hasImageB,
    );
    
    // 레이아웃에 따른 배치
    if (votingSizes.layoutType == LayoutType.horizontal) {
      return FittedBox(
        fit: BoxFit.scaleDown,  // 화면 크기에 맞춰 자동 조정
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,  // 최소 크기 사용
          children: [
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'A',
            title: titleA,
            imageUrl: imageUrlA,
            description: description,
            onTap: onTapA,
            isSelected: selectedBox == 'A',
            showResult: showResults,
            votePercentage: votePercentageA,
            voteCount: voteCountA,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
            // 멀티이미지 지원 파라미터 전달
            imageUrls: imageUrlsA,
            otherImageUrls: imageUrlsB,
            question: question,
            otherOptionTitle: titleB,
            otherImageUrl: imageUrlB,
            otherDescription: description,
            enableImageTap: enableImageTap,
          ),
          SizedBox(width: votingSizes.spacing),
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'B',
            title: titleB,
            imageUrl: imageUrlB,
            description: description,
            onTap: onTapB,
            isSelected: selectedBox == 'B',
            showResult: showResults,
            votePercentage: votePercentageB,
            voteCount: voteCountB,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
            // 멀티이미지 지원 파라미터 전달
            imageUrls: imageUrlsB,
            otherImageUrls: imageUrlsA,
            question: question,
            otherOptionTitle: titleA,
            otherImageUrl: imageUrlA,
            otherDescription: description,
            enableImageTap: enableImageTap,
          ),
        ],
        ),
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
            description: description,
            onTap: onTapA,
            isSelected: selectedBox == 'A',
            showResult: showResults,
            votePercentage: votePercentageA,
            voteCount: voteCountA,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
            // 멀티이미지 지원 파라미터 전달
            imageUrls: imageUrlsA,
            otherImageUrls: imageUrlsB,
            question: question,
            otherOptionTitle: titleB,
            otherImageUrl: imageUrlB,
            otherDescription: description,
            enableImageTap: enableImageTap,
          ),
          SizedBox(height: votingSizes.spacing),
          buildFromSizeData(
            context: context,
            sizeData: sizeData,
            boxType: 'B',
            title: titleB,
            imageUrl: imageUrlB,
            description: description,
            onTap: onTapB,
            isSelected: selectedBox == 'B',
            showResult: showResults,
            votePercentage: votePercentageB,
            voteCount: voteCountB,
            animationController: animationController,
            showDebugInfo: showDebugInfo,
            // 멀티이미지 지원 파라미터 전달
            imageUrls: imageUrlsB,
            otherImageUrls: imageUrlsA,
            question: question,
            otherOptionTitle: titleA,
            otherImageUrl: imageUrlA,
            otherDescription: description,
            enableImageTap: enableImageTap,
          ),
        ],
      );
    }
  }
}