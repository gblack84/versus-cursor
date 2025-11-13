import 'package:flutter/material.dart' show Size;
import '/core/types/layout_type.dart';

/// Service interface for box size calculation (Chat Feature)
///
/// This interface abstracts the dependency on the UI services layer,
/// allowing the chat domain to calculate box sizes without
/// directly depending on the services implementation.
///
/// Clean Architecture Pattern:
/// - Domain Layer: This interface (abstraction)
/// - Data Layer: BoxCalculatorAdapter (implementation)
/// - Presentation Layer: Uses interface via DI (GetIt)
abstract class IBoxCalculatorService {
  /// Calculate box sizes for message cards in chat
  ///
  /// This is the primary method used by Chat Feature for rendering
  /// message bubbles with A vs B vote options.
  ///
  /// **Parameters**:
  /// - `bubbleWidth`: Message bubble container width
  /// - `layoutType`: Vertical or Horizontal layout
  /// - `aspectRatioA`: Aspect ratio of option A image
  /// - `aspectRatioB`: Aspect ratio of option B image
  /// - `hasImageA`: Whether option A has an image
  /// - `hasImageB`: Whether option B has an image
  ///
  /// **Returns**: Box sizes for rendering the vote card
  BoxSizesData calculateForMessageCard({
    required double bubbleWidth,
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
