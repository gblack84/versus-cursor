import 'package:flutter/material.dart';

/// Configuration model for VotingBox
class VotingBoxConfig {
  final String boxType;
  final Size boxSize;
  final String title;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String? description;
  final bool showLabel;
  final bool showDebugInfo;
  final bool isSingleImageMode;
  final String? dualModeSecondTitle;
  final bool enableImageTap;
  final List<Color>? gradientColors;
  final double? customTextSize;

  // Other box data for image viewer
  final String? question;
  final String? otherOptionTitle;
  final String? otherImageUrl;
  final String? otherDescription;
  final List<String>? otherImageUrls;

  const VotingBoxConfig({
    required this.boxType,
    required this.boxSize,
    required this.title,
    this.imageUrl,
    this.imageUrls,
    this.description,
    this.showLabel = true,
    this.showDebugInfo = false,
    this.isSingleImageMode = false,
    this.dualModeSecondTitle,
    this.enableImageTap = true,
    this.gradientColors,
    this.customTextSize,
    this.question,
    this.otherOptionTitle,
    this.otherImageUrl,
    this.otherDescription,
    this.otherImageUrls,
  });

  VotingBoxConfig copyWith({
    String? boxType,
    Size? boxSize,
    String? title,
    String? imageUrl,
    List<String>? imageUrls,
    String? description,
    bool? showLabel,
    bool? showDebugInfo,
    bool? isSingleImageMode,
    String? dualModeSecondTitle,
    bool? enableImageTap,
    List<Color>? gradientColors,
    double? customTextSize,
    String? question,
    String? otherOptionTitle,
    String? otherImageUrl,
    String? otherDescription,
    List<String>? otherImageUrls,
  }) {
    return VotingBoxConfig(
      boxType: boxType ?? this.boxType,
      boxSize: boxSize ?? this.boxSize,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      showLabel: showLabel ?? this.showLabel,
      showDebugInfo: showDebugInfo ?? this.showDebugInfo,
      isSingleImageMode: isSingleImageMode ?? this.isSingleImageMode,
      dualModeSecondTitle: dualModeSecondTitle ?? this.dualModeSecondTitle,
      enableImageTap: enableImageTap ?? this.enableImageTap,
      gradientColors: gradientColors ?? this.gradientColors,
      customTextSize: customTextSize ?? this.customTextSize,
      question: question ?? this.question,
      otherOptionTitle: otherOptionTitle ?? this.otherOptionTitle,
      otherImageUrl: otherImageUrl ?? this.otherImageUrl,
      otherDescription: otherDescription ?? this.otherDescription,
      otherImageUrls: otherImageUrls ?? this.otherImageUrls,
    );
  }
}

/// State model for VotingBox interaction
class VotingBoxState {
  final bool isSelected;
  final bool showResult;
  final double? votePercentage;
  final int? voteCount;
  final VoidCallback? onTap;
  final AnimationController? animationController;

  const VotingBoxState({
    this.isSelected = false,
    this.showResult = false,
    this.votePercentage,
    this.voteCount,
    this.onTap,
    this.animationController,
  });

  VotingBoxState copyWith({
    bool? isSelected,
    bool? showResult,
    double? votePercentage,
    int? voteCount,
    VoidCallback? onTap,
    AnimationController? animationController,
  }) {
    return VotingBoxState(
      isSelected: isSelected ?? this.isSelected,
      showResult: showResult ?? this.showResult,
      votePercentage: votePercentage ?? this.votePercentage,
      voteCount: voteCount ?? this.voteCount,
      onTap: onTap ?? this.onTap,
      animationController: animationController ?? this.animationController,
    );
  }
}

/// Combined model for VotingBox
class VotingBoxData {
  final VotingBoxConfig config;
  final VotingBoxState state;

  const VotingBoxData({
    required this.config,
    required this.state,
  });

  VotingBoxData copyWith({
    VotingBoxConfig? config,
    VotingBoxState? state,
  }) {
    return VotingBoxData(
      config: config ?? this.config,
      state: state ?? this.state,
    );
  }
}