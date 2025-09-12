import 'package:flutter/material.dart' show Size;
import '/core/types/layout_type.dart';

/// Port interface for box size calculation
/// 
/// This interface abstracts the dependency on the UI services layer,
/// allowing the voting domain to calculate box sizes without
/// directly depending on the services implementation.
abstract class IBoxCalculatorPort {
  /// Calculate box sizes for voting components
  BoxSizesData calculate({
    required double containerWidth,
    double? containerHeight,
    required String containerType,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  });
  
  /// Calculate sizes specifically for notification dialogs
  BoxSizesData calculateForNotificationDialog({
    required double dialogWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  });
}

/// Data class for box sizes calculation result
class BoxSizesData {
  final Size sizeA;
  final Size sizeB;
  final double spacing;
  final LayoutType layoutType;
  
  const BoxSizesData({
    required this.sizeA,
    required this.sizeB,
    required this.spacing,
    required this.layoutType,
  });
}