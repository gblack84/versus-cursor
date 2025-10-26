import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/core/types/layout_type.dart';
import '/features/voting/domain/entities/dialog/versus_box_size_data.dart';
import '/features/voting/domain/constants/voting_constants.dart';
import '../../voting_box.dart';
import '/services/ui/unified_box_calculator.dart';
import '/core/utils/media/aspect_ratio_analyzer.dart';

/// Content component for the voting dialog
/// Displays the question and A/B voting boxes
class VotingDialogContent extends StatelessWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? description;
  final VersusBoxSizeData? sizeData;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final bool showResults;
  final double? votePercentageA;
  final double? votePercentageB;
  final int? voteCountA;
  final int? voteCountB;
  final bool showDebugInfo;
  final bool hasVoted;
  final Function(String option)? onVote;
  final AnimationController? animationController;

  const VotingDialogContent({
    super.key,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.description,
    this.sizeData,
    this.aspectRatioA,
    this.aspectRatioB,
    this.showResults = false,
    this.votePercentageA,
    this.votePercentageB,
    this.voteCountA,
    this.voteCountB,
    this.showDebugInfo = false,
    this.hasVoted = false,
    this.onVote,
    this.animationController,
  });

  /// Helper methods for multi-image support
  List<String> get effectiveImageUrlsA {
    if (imageUrlsA != null && imageUrlsA!.isNotEmpty) {
      return imageUrlsA!;
    }
    if (imageUrlA != null) {
      return [imageUrlA!];
    }
    return [];
  }

  List<String> get effectiveImageUrlsB {
    if (imageUrlsB != null && imageUrlsB!.isNotEmpty) {
      return imageUrlsB!;
    }
    if (imageUrlB != null) {
      return [imageUrlB!];
    }
    return [];
  }

  String? get primaryImageUrlA {
    final urls = effectiveImageUrlsA;
    return urls.isNotEmpty ? urls.first : null;
  }

  String? get primaryImageUrlB {
    final urls = effectiveImageUrlsB;
    return urls.isNotEmpty ? urls.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Question section
        _buildQuestionSection(),
        VersusSpacing.gapMD,
        
        // Versus boxes
        _buildVersusBoxes(context),
      ],
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Title.',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question,
          style: VersusTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersusBoxes(BuildContext context) {
    final bool hasBOption = primaryImageUrlB != null || optionB.isNotEmpty;
    final bool hasOnlyTextB = primaryImageUrlB == null && optionB.isNotEmpty;

    // Calculate effective size data
    VersusBoxSizeData? effectiveSizeData = _calculateEffectiveSizeData(context, hasBOption, hasOnlyTextB);

    // Build boxes based on configuration
    Widget boxWidget;
    if (!hasBOption || hasOnlyTextB) {
      boxWidget = effectiveSizeData != null
          ? _buildSingleBox(context, effectiveSizeData, hasOnlyTextB)
          : _buildDefaultSingleBox(context, hasOnlyTextB);
    } else {
      boxWidget = effectiveSizeData != null
          ? _buildBoxPair(context, effectiveSizeData)
          : _buildDefaultBoxPair(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        boxWidget,
        const SizedBox(height: 12),
        _buildDescriptionText(),
      ],
    );
  }

  VersusBoxSizeData? _calculateEffectiveSizeData(BuildContext context, bool hasBOption, bool hasOnlyTextB) {
    if (sizeData != null) return sizeData;
    
    if (aspectRatioA == null && aspectRatioB == null) return null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);

    LayoutType layoutType;
    if (!hasBOption || hasOnlyTextB) {
      layoutType = LayoutType.single;
    } else if (aspectRatioA != null && aspectRatioB != null) {
      layoutType = AspectRatioAnalyzer.getOptimalLayout(aspectRatioA, aspectRatioB);
    } else {
      layoutType = LayoutType.horizontal;
    }

    return VersusBoxSizeData(
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      originalSizeA: baseSize,
      originalSizeB: baseSize,
      screenWidth: screenWidth,
      createdAt: DateTime.now(),
      hasImageA: primaryImageUrlA != null,
      hasImageB: primaryImageUrlB != null,
    );
  }

  Widget _buildSingleBox(BuildContext context, VersusBoxSizeData sizeData, bool hasOnlyTextB) {
    return Center(
      child: VotingBox.legacy(
        boxType: 'A',
        boxSize: UnifiedBoxCalculator.calculateForNotificationDialog(
          dialogWidth: MediaQuery.of(context).size.width * VotingConstants.messageCardWidthRatio,
          layoutType: sizeData.layoutType,
          aspectRatioA: sizeData.aspectRatioA,
          aspectRatioB: sizeData.aspectRatioB,
          hasImageA: sizeData.hasImageA,
          hasImageB: sizeData.hasImageB,
        ).sizeA,
        title: optionA,
        imageUrl: primaryImageUrlA,
        description: description,
        question: question,
        otherOptionTitle: optionB,
        otherImageUrl: primaryImageUrlB,
        otherDescription: description,
        onTap: null,
        isSelected: false,
        showResult: showResults || hasVoted,
        votePercentage: votePercentageA,
        voteCount: voteCountA,
        animationController: animationController,
        showDebugInfo: showDebugInfo,
        isSingleImageMode: hasOnlyTextB,
        dualModeSecondTitle: hasOnlyTextB ? optionB : null,
        imageUrls: effectiveImageUrlsA,
        otherImageUrls: effectiveImageUrlsB,
        enableImageTap: true,
      ),
    );
  }

  Widget _buildBoxPair(BuildContext context, VersusBoxSizeData sizeData) {
    return VotingBoxBuilder.buildBoxPair(
      context: context,
      sizeData: sizeData,
      titleA: optionA,
      titleB: optionB,
      imageUrlA: primaryImageUrlA,
      imageUrlB: primaryImageUrlB,
      description: description,
      onTapA: hasVoted ? null : () => onVote?.call('A'),
      onTapB: hasVoted ? null : () => onVote?.call('B'),
      showResults: showResults || hasVoted,
      votePercentageA: votePercentageA,
      votePercentageB: votePercentageB,
      voteCountA: voteCountA,
      voteCountB: voteCountB,
      animationController: animationController,
      showDebugInfo: showDebugInfo,
      imageUrlsA: effectiveImageUrlsA,
      imageUrlsB: effectiveImageUrlsB,
      question: question,
      enableImageTap: true,
    );
  }

  Widget _buildDefaultSingleBox(BuildContext context, bool hasOnlyTextB) {
    final screenWidth = MediaQuery.of(context).size.width;
    final votingSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: screenWidth * VotingConstants.messageCardWidthRatio,
      layoutType: LayoutType.single,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: primaryImageUrlA != null,
      hasImageB: primaryImageUrlB != null,
    );

    return Center(
      child: VotingBox.legacy(
        boxType: 'A',
        boxSize: votingSizes.sizeA,
        title: optionA,
        imageUrl: primaryImageUrlA,
        description: description,
        question: question,
        otherOptionTitle: optionB,
        otherImageUrl: primaryImageUrlB,
        otherDescription: description,
        onTap: null,
        showResult: showResults || hasVoted,
        votePercentage: votePercentageA,
        voteCount: voteCountA,
        animationController: animationController,
        showDebugInfo: showDebugInfo,
        isSingleImageMode: hasOnlyTextB,
        dualModeSecondTitle: hasOnlyTextB ? optionB : null,
        imageUrls: effectiveImageUrlsA,
        otherImageUrls: effectiveImageUrlsB,
        enableImageTap: true,
      ),
    );
  }

  Widget _buildDefaultBoxPair(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final layoutType = (aspectRatioA != null && aspectRatioB != null)
        ? AspectRatioAnalyzer.getOptimalLayout(aspectRatioA, aspectRatioB)
        : LayoutType.horizontal;

    final votingSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: screenWidth * VotingConstants.messageCardWidthRatio,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: primaryImageUrlA != null,
      hasImageB: primaryImageUrlB != null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VotingBox.legacy(
          boxType: 'A',
          boxSize: votingSizes.sizeA,
          title: optionA,
          imageUrl: primaryImageUrlA,
          description: description,
          question: question,
          otherOptionTitle: optionB,
          otherImageUrl: primaryImageUrlB,
          otherDescription: description,
          onTap: hasVoted ? null : () => onVote?.call('A'),
          showResult: showResults || hasVoted,
          votePercentage: votePercentageA,
          voteCount: voteCountA,
          animationController: animationController,
          showDebugInfo: showDebugInfo,
          imageUrls: effectiveImageUrlsA,
          otherImageUrls: effectiveImageUrlsB,
          enableImageTap: true,
        ),
        SizedBox(width: votingSizes.spacing),
        VotingBox.legacy(
          boxType: 'B',
          boxSize: votingSizes.sizeB,
          title: optionB,
          imageUrl: primaryImageUrlB,
          description: description,
          question: question,
          otherOptionTitle: optionA,
          otherImageUrl: primaryImageUrlA,
          otherDescription: description,
          onTap: hasVoted ? null : () => onVote?.call('B'),
          showResult: showResults || hasVoted,
          votePercentage: votePercentageB,
          voteCount: voteCountB,
          animationController: animationController,
          showDebugInfo: showDebugInfo,
          imageUrls: effectiveImageUrlsB,
          otherImageUrls: effectiveImageUrlsA,
          enableImageTap: true,
        ),
      ],
    );
  }

  Widget _buildDescriptionText() {
    if (description == null || description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Description.',
          style: VersusTextStyles.labelSmall.copyWith(
            color: VersusColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description!,
          style: VersusTextStyles.bodySmall.copyWith(
            color: VersusColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}