import '/services/ui/unified_box_calculator.dart';
import '/core/types/layout_type.dart';
import '../../domain/services/i_box_calculator_service.dart';

/// Implementation of IBoxCalculatorService that wraps UnifiedBoxCalculator
///
/// This adapter bridges the domain layer with the services layer,
/// converting between different data structures while maintaining
/// Clean Architecture boundaries.
class BoxCalculatorAdapter implements IBoxCalculatorService {
  @override
  BoxSizesData calculate({
    required double containerWidth,
    double? containerHeight,
    required String containerType,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    final result = UnifiedBoxCalculator.calculate(
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      containerType: containerType,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
    
    return _convertToBoxSizesData(result);
  }
  
  @override
  BoxSizesData calculateForNotificationDialog({
    required double dialogWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    final result = UnifiedBoxCalculator.calculateForNotificationDialog(
      dialogWidth: dialogWidth,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
    
    return _convertToBoxSizesData(result);
  }
  
  /// Convert UnifiedBoxCalculator result to domain data structure
  BoxSizesData _convertToBoxSizesData(BoxSizes result) {
    return BoxSizesData(
      sizeA: result.sizeA,
      sizeB: result.sizeB,
      spacing: result.spacing,
      layoutType: result.layoutType,
    );
  }
}