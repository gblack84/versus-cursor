import 'package:flutter/material.dart';
import '/core/types/layout_type.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/models/dialog/versus_box_size_data.dart';
import '/features/voting/domain/constants/voting_constants.dart';
import '/services/ui/unified_box_calculator.dart';
import '/features/voting/presentation/dialogs/voting_dialog_constraints.dart';

// Components
import 'voting_box/components/voting_box_header.dart';
import 'voting_box/components/voting_box_content.dart';
import 'voting_box/components/voting_box_overlay.dart';
import 'voting_box/components/voting_box_animations.dart';

// Models
import 'voting_box/models/voting_box_state.dart';

// Utils
import 'voting_box/utils/voting_box_helpers.dart';

/// 투표 알림에서 사용되는 A/B 박스 컴포넌트
///
/// 질문 작성 페이지에서 생성된 사이즈 데이터를 기반으로
/// 일관된 크기와 레이아웃을 투표 알림에서 재현합니다.
///
/// This widget has been refactored into smaller components for better maintainability:
/// - VotingBoxHeader: Handles labels and vote counts
/// - VotingBoxContent: Manages main content area
/// - VotingBoxOverlay: Controls overlay elements
/// - VotingBoxAnimations: Manages animations
class VotingBox extends StatelessWidget {
  final VotingBoxConfig config;
  final VotingBoxState state;

  const VotingBox({
    Key? key,
    required this.config,
    required this.state,
  }) : super(key: key);

  /// Legacy constructor for backward compatibility
  factory VotingBox.legacy({
    Key? key,
    required String boxType,
    required Size boxSize,
    required String title,
    String? imageUrl,
    VoidCallback? onTap,
    bool isSelected = false,
    bool showResult = false,
    double? votePercentage,
    int? voteCount,
    AnimationController? animationController,
    List<Color>? gradientColors,
    double? customTextSize,
    bool showLabel = true,
    bool showDebugInfo = false,
    String? dualModeSecondTitle,
    bool isSingleImageMode = false,
    String? description,
    String? question,
    String? otherOptionTitle,
    String? otherImageUrl,
    String? otherDescription,
    List<String>? imageUrls,
    List<String>? otherImageUrls,
    bool enableImageTap = true,
  }) {
    return VotingBox(
      key: key,
      config: VotingBoxConfig(
        boxType: boxType,
        boxSize: boxSize,
        title: title,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        description: description,
        showLabel: showLabel,
        showDebugInfo: showDebugInfo,
        isSingleImageMode: isSingleImageMode,
        dualModeSecondTitle: dualModeSecondTitle,
        enableImageTap: enableImageTap,
        gradientColors: gradientColors,
        customTextSize: customTextSize,
        question: question,
        otherOptionTitle: otherOptionTitle,
        otherImageUrl: otherImageUrl,
        otherDescription: otherDescription,
        otherImageUrls: otherImageUrls,
      ),
      state: VotingBoxState(
        isSelected: isSelected,
        showResult: showResult,
        votePercentage: votePercentage,
        voteCount: voteCount,
        onTap: onTap,
        animationController: animationController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '옵션 ${config.boxType}: ${config.title}',
      selected: state.isSelected,
      hint: state.showResult && state.votePercentage != null
          ? '투표 결과: ${(state.votePercentage! * 100).toStringAsFixed(0)}%'
          : '탭하여 선택',
      child: _buildBox(context),
    );
  }

  Widget _buildBox(BuildContext context) {
    // Apply animations if animation controller is provided
    final boxWidget = _buildBoxContainer(context);
    
    if (state.animationController != null) {
      return VotingBoxAnimations(
        animationController: state.animationController,
        child: boxWidget,
      );
    }
    
    return boxWidget;
  }


  /// Build the main box container
  Widget _buildBoxContainer(BuildContext context) {
    // Validate box size
    final safeSize = VotingBoxHelpers.validateBoxSize(config.boxSize);
    final textSize = VotingBoxHelpers.getAdaptiveTextSize(
      boxHeight: safeSize.height,
      customTextSize: config.customTextSize,
    );

    return GestureDetector(
      onTap: _handleTap(context),
      child: Container(
        width: safeSize.width,
        height: safeSize.height,
        decoration: _buildBoxDecoration(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content with background
            VotingBoxContent(
              boxSize: safeSize,
              title: config.title,
              boxType: config.boxType,
              textSize: textSize,
              imageUrl: config.imageUrl,
              imageUrls: config.imageUrls,
              gradientColors: config.gradientColors,
              isSingleImageMode: config.isSingleImageMode,
              dualModeSecondTitle: config.dualModeSecondTitle,
              description: config.description,
            ),

            // Header with labels
            VotingBoxHeader(
              boxType: config.boxType,
              showLabel: config.showLabel,
              showResult: state.showResult,
              boxSize: safeSize,
              votePercentage: state.votePercentage,
              voteCount: state.voteCount,
              textSize: textSize,
            ),

            // Overlays (selection, results, debug)
            VotingBoxOverlay(
              showResult: state.showResult,
              isSelected: state.isSelected,
              boxSize: safeSize,
              textSize: textSize,
              votePercentage: state.votePercentage,
              voteCount: state.voteCount,
              showDebugInfo: config.showDebugInfo,
            ),
          ],
        ),
      ),
    );
  }

  /// Build box decoration
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: VersusRadius.container,
      boxShadow: [
        BoxShadow(
          color: Colors.black
              .withValues(alpha: VotingDialogConstraints.shadowOpacity),
          blurRadius: VotingDialogConstraints.shadowBlurRadius,
          offset: VotingDialogConstraints.shadowOffset,
        ),
      ],
      border: state.isSelected
          ? Border.all(
              color: VersusColors.primary,
              width: 2.0,
            )
          : null,
    );
  }

  /// Handle tap events
  VoidCallback? _handleTap(BuildContext context) {
    return () {
      // Show image viewer if enabled and has image
      if (config.enableImageTap && 
          config.imageUrl != null && 
          config.question != null) {
        VotingBoxHelpers.showImageViewer(
          context: context,
          boxType: config.boxType,
          title: config.title,
          question: config.question,
          imageUrl: config.imageUrl,
          imageUrls: config.imageUrls,
          otherOptionTitle: config.otherOptionTitle,
          otherImageUrl: config.otherImageUrl,
          otherImageUrls: config.otherImageUrls,
          description: config.description,
        );
      } else if (state.onTap != null) {
        // Execute regular tap handler
        state.onTap!();
      }
    };
  }
}

/// 투표 알림 박스 빌더
///
/// VersusBoxSizeData를 받아서 자동으로 VotingBox를 생성합니다.
class VotingBoxBuilder {
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
      dialogWidth: MediaQuery.of(context).size.width * VotingConstants.messageCardWidthRatio,
      layoutType: sizeData.layoutType,
      aspectRatioA: sizeData.aspectRatioA,
      aspectRatioB: sizeData.aspectRatioB,
      hasImageA: sizeData.hasImageA,
      hasImageB: sizeData.hasImageB,
    );

    // 박스 타입에 따른 크기 선택
    final boxSize = boxType == 'A' ? votingSizes.sizeA : votingSizes.sizeB;

    return VotingBox.legacy(
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
    final dialogTotalWidth = MediaQuery.of(context).size.width * VotingConstants.messageCardWidthRatio;

    final votingSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: dialogTotalWidth, // 전체 다이얼로그 너비 전달
      layoutType: sizeData.layoutType,
      aspectRatioA: sizeData.aspectRatioA,
      aspectRatioB: sizeData.aspectRatioB,
      hasImageA: sizeData.hasImageA,
      hasImageB: sizeData.hasImageB,
    );

    // 레이아웃에 따른 배치
    if (votingSizes.layoutType == LayoutType.horizontal) {
      return FittedBox(
        fit: BoxFit.scaleDown, // 화면 크기에 맞춰 자동 조정
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 최소 크기 사용
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
