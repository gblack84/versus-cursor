import 'package:flutter/material.dart';
import '/features/voting/presentation/constants/voting_dialog_constraints.dart';
import '../../voting_image_viewer.dart';

/// Helper functions for VotingBox
class VotingBoxHelpers {
  /// Calculate adaptive text size based on box height
  static double getAdaptiveTextSize({
    required double boxHeight,
    double? customTextSize,
    double baseTextSize = VotingDialogConstraints.defaultTextSize,
  }) {
    if (customTextSize != null) {
      return customTextSize;
    }

    return VotingDialogConstraints.getAdaptiveTextSize(
      boxHeight,
      baseTextSize: baseTextSize,
    );
  }

  /// Get effective image URLs for a box type
  static List<String> getEffectiveImageUrls({
    required String forBoxType,
    required String currentBoxType,
    String? imageUrl,
    List<String>? imageUrls,
    String? otherImageUrl,
    List<String>? otherImageUrls,
  }) {
    if (forBoxType == currentBoxType) {
      // Use own images
      if (imageUrls != null && imageUrls.isNotEmpty) {
        return imageUrls;
      }
      if (imageUrl != null) {
        return [imageUrl];
      }
    } else {
      // Use other box's images
      if (otherImageUrls != null && otherImageUrls.isNotEmpty) {
        return otherImageUrls;
      }
      if (otherImageUrl != null) {
        return [otherImageUrl];
      }
    }
    return [];
  }

  /// Show image viewer for voting box
  static void showImageViewer({
    required BuildContext context,
    required String boxType,
    required String title,
    required String? question,
    String? imageUrl,
    List<String>? imageUrls,
    String? otherOptionTitle,
    String? otherImageUrl,
    List<String>? otherImageUrls,
    String? description,
  }) {
    if (question == null) return;

    // Get effective image URLs
    final effectiveImageUrlsA = getEffectiveImageUrls(
      forBoxType: 'A',
      currentBoxType: boxType,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      otherImageUrl: otherImageUrl,
      otherImageUrls: otherImageUrls,
    );

    final effectiveImageUrlsB = getEffectiveImageUrls(
      forBoxType: 'B',
      currentBoxType: boxType,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      otherImageUrl: otherImageUrl,
      otherImageUrls: otherImageUrls,
    );

    // Calculate initial index
    int initialIndex = 0;
    if (boxType == 'B') {
      initialIndex = effectiveImageUrlsA.length;
    }

    // Show viewer
    VotingImageViewer.show(
      context,
      question: question,
      optionA: boxType == 'A' ? title : (otherOptionTitle ?? ''),
      optionB: boxType == 'A' ? (otherOptionTitle ?? '') : title,
      imageUrlA: effectiveImageUrlsA.isNotEmpty ? effectiveImageUrlsA.first : null,
      imageUrlB: effectiveImageUrlsB.isNotEmpty ? effectiveImageUrlsB.first : null,
      imageUrlsA: effectiveImageUrlsA.isNotEmpty ? effectiveImageUrlsA : null,
      imageUrlsB: effectiveImageUrlsB.isNotEmpty ? effectiveImageUrlsB : null,
      description: description,
      initialIndex: initialIndex,
    );
  }

  /// Validate box size within safe limits
  static Size validateBoxSize(Size boxSize) {
    const double maxSafeSize = 1000.0;
    return Size(
      boxSize.width.clamp(0.0, maxSafeSize),
      boxSize.height.clamp(0.0, maxSafeSize),
    );
  }

  /// Get default gradient colors for box type
  static List<Color> getDefaultGradientColors(String boxType) {
    // This would need to import VersusColors from design system
    // For now, returning basic colors
    if (boxType == 'A') {
      return [
        const Color(0xFF6200EE),
        const Color(0xFF6200EE).withValues(alpha: 0.8),
      ];
    } else {
      return [
        const Color(0xFF03DAC6),
        const Color(0xFF03DAC6).withValues(alpha: 0.8),
      ];
    }
  }
}