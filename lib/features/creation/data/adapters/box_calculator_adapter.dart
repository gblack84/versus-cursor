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
/// - Wraps UnifiedBoxCalculator.calculateForQuestion()
/// - Converts BoxSizes (services) → BoxSizesData (domain)
/// - Provides Clean Architecture abstraction for Creation Feature
///
/// **Used by**:
/// - Creation Presentation Layer (via GetIt DI)
/// - Question preview components
class BoxCalculatorAdapter implements IBoxCalculatorService {
  @override
  BoxSizesData calculateForQuestion({
    required double containerWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    // Call UnifiedBoxCalculator (Services Layer)
    final result = UnifiedBoxCalculator.calculateForQuestion(
      containerWidth: containerWidth,
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
  /// - BoxSizes (services/ui/unified_box_calculator.dart)
  ///   → BoxSizesData (creation/domain/services/i_box_calculator_service.dart)
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
