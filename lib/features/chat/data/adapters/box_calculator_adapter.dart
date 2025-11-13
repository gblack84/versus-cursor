import '/core/utils/ui/box_sizing/unified_box_calculator.dart';
import '/core/types/layout_type.dart';
import '../../domain/services/i_box_calculator_service.dart';

/// Implementation of IBoxCalculatorService that wraps UnifiedBoxCalculator
///
/// This adapter bridges the domain layer with the services layer,
/// converting between different data structures while maintaining
/// Clean Architecture boundaries.
///
/// **Pattern**: Adapter Pattern
/// - **Domain**: IBoxCalculatorService (abstract interface)
/// - **Data**: BoxCalculatorAdapter (concrete implementation)
/// - **Services**: UnifiedBoxCalculator (global infrastructure)
///
/// **Responsibility**:
/// - Wraps UnifiedBoxCalculator.calculateForMessageCard()
/// - Converts BoxSizes (services) → BoxSizesData (domain)
/// - Provides Clean Architecture abstraction for Chat Feature
///
/// **Used by**:
/// - Chat Presentation Layer (via GetIt DI)
/// - Message rendering components
class BoxCalculatorAdapter implements IBoxCalculatorService {
  @override
  BoxSizesData calculateForMessageCard({
    required double bubbleWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    // Call UnifiedBoxCalculator (Services Layer)
    final result = UnifiedBoxCalculator.calculateForMessageCard(
      bubbleWidth: bubbleWidth,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );

    // Convert to Domain data structure
    return _convertToBoxSizesData(result);
  }

  /// Convert UnifiedBoxCalculator result to domain data structure
  ///
  /// **Type Conversion**:
  /// - BoxSizes (services/ui/models/box_sizes.dart)
  ///   → BoxSizesData (chat/domain/services/i_box_calculator_service.dart)
  ///
  /// Both types have identical fields (sizeA, sizeB, spacing, layoutType),
  /// but are separate to maintain layer independence.
  BoxSizesData _convertToBoxSizesData(BoxSizes result) {
    return BoxSizesData(
      sizeA: result.sizeA,
      sizeB: result.sizeB,
      spacing: result.spacing,
      layoutType: result.layoutType,
    );
  }
}
