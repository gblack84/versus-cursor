import 'package:flutter/material.dart' show Size;
import '/core/types/layout_type.dart';

/// Service interface for box size calculation (Creation Feature)
///
/// This interface abstracts the dependency on the UI services layer,
/// allowing the creation domain to calculate box sizes without
/// directly depending on the services implementation.
///
/// Clean Architecture Pattern:
/// - Domain Layer: This interface (abstraction)
/// - Data Layer: BoxCalculatorAdapter (implementation)
/// - Presentation Layer: Uses interface via DI (GetIt)
abstract class IBoxCalculatorService {
  /// Calculate box sizes for question creation (post composition)
  ///
  /// This is the primary method used by Creation Feature for previewing
  /// how the question will appear to users.
  ///
  /// **Parameters**:
  /// - `containerWidth`: Question container width
  /// - `layoutType`: Vertical or Horizontal layout
  /// - `aspectRatioA`: Aspect ratio of option A image
  /// - `aspectRatioB`: Aspect ratio of option B image
  /// - `hasImageA`: Whether option A has an image
  /// - `hasImageB`: Whether option B has an image
  ///
  /// **Returns**: Box sizes for rendering the question preview
  BoxSizesData calculateForQuestion({
    required double containerWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  });
}

/// Data class for box sizes calculation result
///
/// This class encapsulates the calculated sizes for both option boxes
/// and the spacing between them.
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
