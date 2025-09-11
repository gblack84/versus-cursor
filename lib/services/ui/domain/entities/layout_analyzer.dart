import 'package:versus_space_flutter/core/types/layout_type.dart';

/// Layout analyzer for UI calculations
class LayoutAnalyzer {
  /// Analyzes aspect ratios and determines optimal layout
  static LayoutType determineLayout(List<double?> aspectRatios) {
    if (aspectRatios.isEmpty) return LayoutType.horizontal;

    final validRatios = aspectRatios.whereType<double>().toList();
    if (validRatios.isEmpty) return LayoutType.horizontal;

    // If most images are portrait (ratio < 1), use vertical layout
    final portraitCount = validRatios.where((r) => r < 1.0).length;
    return portraitCount > validRatios.length / 2
        ? LayoutType.vertical
        : LayoutType.horizontal;
  }
}
