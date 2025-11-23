import 'package:flutter/material.dart';
import '/core/types/layout_type.dart';
import '/core/utils/ui/box_sizing/config/box_calculator_config.dart';

/// 통합 박스 계산 서비스
///
/// 모든 컴포넌트(질문 작성, 알림, 메시지)에서 일관된 박스 크기를 계산합니다.
/// 핵심 원칙:
/// 1. 너비는 컨테이너가 허용하는 최대값 사용
/// 2. 높이는 aspectRatio 기반으로 계산 후 평균값 사용
/// 3. 각 컨테이너별 고유 제한값 존중
class UnifiedBoxCalculator {
  /// 박스 크기 계산 결과
  static BoxSizes calculate({
    required double containerWidth,
    double? containerHeight,
    required String containerType,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    // 1. 단일 이미지 처리
    final isSingle = layoutType == LayoutType.single ||
        (hasImageA && !hasImageB) ||
        (!hasImageA && hasImageB);

    // 2. 레이아웃 타입 결정
    final isHorizontal = layoutType == LayoutType.horizontal;

    // 3. 컨테이너별 제한값 가져오기
    final maxHeight = BoxCalculatorConfig.getMaxHeight(
      containerType: containerType,
      isHorizontal: isHorizontal,
      isSingle: isSingle,
      screenHeight: containerHeight,
    );

    final minHeight = BoxCalculatorConfig.getMinHeight(
      containerType: containerType,
      isHorizontal: isHorizontal,
      isSingle: isSingle,
    );

    // 4. 박스 너비 계산
    final spacing = BoxCalculatorConfig.getSpacing(isHorizontal);
    double boxWidth;

    if (isSingle) {
      // 단일 이미지는 80% 너비 사용
      boxWidth = containerWidth * BoxCalculatorConfig.singleBoxWidthRatio;
    } else if (isHorizontal) {
      // 가로 배치: 간격 제외하고 절반씩
      final availableWidth = containerWidth - spacing;
      boxWidth = availableWidth * BoxCalculatorConfig.horizontalBoxWidthRatio;
    } else {
      // 세로 배치: 95% 너비 사용
      boxWidth = containerWidth * BoxCalculatorConfig.verticalBoxWidthRatio;
    }

    // 5. 높이 계산 (aspectRatio 기반)
    double heightA = BoxCalculatorConfig.defaultBoxHeight;
    double heightB = BoxCalculatorConfig.defaultBoxHeight;

    if (aspectRatioA != null && aspectRatioA > 0) {
      heightA = boxWidth / aspectRatioA;
    }

    if (aspectRatioB != null && aspectRatioB > 0) {
      heightB = boxWidth / aspectRatioB;
    }

    // 6. 통일된 높이 계산 (핵심!)
    double unifiedHeight;

    if (isSingle) {
      // 단일 이미지는 해당 이미지의 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    } else if (hasImageA && hasImageB) {
      // 두 이미지 모두 있으면 평균 높이 사용
      unifiedHeight = (heightA + heightB) / 2;
    } else {
      // 하나만 있으면 해당 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    }

    // 7. 높이 제한 적용
    unifiedHeight = unifiedHeight.clamp(minHeight, maxHeight);

    // 8. 세로 배치에서 전체 높이가 컨테이너를 초과하는지 확인
    if (!isHorizontal && hasImageA && hasImageB && containerHeight != null) {
      final totalRequiredHeight = (unifiedHeight * 2) + spacing;
      final maxAvailableHeight = containerHeight * BoxCalculatorConfig.containerHeightUsageRatio; // 88% 사용

      if (totalRequiredHeight > maxAvailableHeight) {
        // 비율을 유지하면서 전체 크기 조정
        final scalingFactor = maxAvailableHeight / totalRequiredHeight;
        unifiedHeight *= scalingFactor;
      }
    }

    // 9. 최종 크기 반환
    final sizeA = hasImageA ? Size(boxWidth, unifiedHeight) : Size.zero;
    final sizeB = hasImageB ? Size(boxWidth, unifiedHeight) : Size.zero;

    return BoxSizes(
      sizeA: sizeA,
      sizeB: sizeB,
      layoutType: layoutType,
      containerType: containerType,
      spacing: spacing,
      unifiedHeight: unifiedHeight,
      boxWidth: boxWidth,
    );
  }

  /// 메시지 카드용 간편 계산 메서드 (기존 - deprecated)
  @Deprecated('Use calculateForMessageCard instead')
  static BoxSizes calculateForMessage({
    required double containerWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    return calculate(
      containerWidth: containerWidth,
      containerType: BoxCalculatorConfig.containerTypeMessage,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
  }

  /// 메시지 카드 전용 계산 메서드
  ///
  /// 채팅 버블 내부에서 적절한 크기로 표시되도록 최적화
  /// - 버블 너비 기준으로 계산
  /// - 고정 최대 높이: 단일(400px), 가로(400px), 세로(350px 전체)
  static BoxSizes calculateForMessageCard({
    required double bubbleWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    // 1. 박스 간격
    const double spacing = BoxCalculatorConfig.messageCardSpacing;

    // 2. 박스 너비 계산
    double boxWidth;
    if (layoutType == LayoutType.single) {
      boxWidth = bubbleWidth * BoxCalculatorConfig.messageCardSingleWidthRatio; // 단일: 80%
    } else if (layoutType == LayoutType.horizontal) {
      // 가로 배치: 간격 빼고 절반씩
      final availableWidth = bubbleWidth - spacing;
      boxWidth = availableWidth * BoxCalculatorConfig.messageCardHorizontalWidthRatio;
    } else {
      // 세로 배치: 95%
      boxWidth = bubbleWidth * BoxCalculatorConfig.messageCardVerticalWidthRatio;
    }

    // 3. 고정 최대 높이 (업데이트된 사양)
    double maxHeight;
    double minHeight;

    if (layoutType == LayoutType.single) {
      maxHeight = BoxCalculatorConfig.messageCardSingleMaxHeight; // 단일: 400px
      minHeight = BoxCalculatorConfig.messageCardSingleMinHeight; // 단일 이미지는 최소 100px로 설정 (자연스러운 크기 유지)
    } else if (layoutType == LayoutType.horizontal) {
      maxHeight = BoxCalculatorConfig.messageCardHorizontalMaxHeight; // 가로: 400px (개별 박스)
      minHeight = BoxCalculatorConfig.messageCardHorizontalMinHeight;
    } else {
      // 세로: 전체 350px, 개별 박스는 171px
      if (hasImageA && hasImageB) {
        maxHeight = (BoxCalculatorConfig.messageCardVerticalTotalMaxHeight - spacing) / 2; // 171px
        minHeight = BoxCalculatorConfig.messageCardVerticalMinHeightTwoBoxes; // 세로에서 두 박스일 때는 최소 100px
      } else {
        maxHeight = BoxCalculatorConfig.messageCardVerticalMaxHeightSingleBox; // 박스 하나만 있으면 350px
        minHeight = BoxCalculatorConfig.messageCardVerticalMinHeightSingleBox;
      }
    }

    // 4. aspectRatio 기반 높이 계산
    // 기본값을 boxWidth 기반으로 계산 (기본 비율 1.5)
    double heightA = boxWidth / BoxCalculatorConfig.messageCardDefaultAspectRatio; // 기본 비율 1.5
    double heightB = boxWidth / BoxCalculatorConfig.messageCardDefaultAspectRatio;

    if (aspectRatioA != null && aspectRatioA > 0) {
      heightA = boxWidth / aspectRatioA;
    }

    if (aspectRatioB != null && aspectRatioB > 0) {
      heightB = boxWidth / aspectRatioB;
    }

    // 5. 통일된 높이 계산
    double unifiedHeight;
    final isSingle = layoutType == LayoutType.single ||
        (hasImageA && !hasImageB) ||
        (!hasImageA && hasImageB);

    if (isSingle) {
      // 단일 이미지는 해당 이미지의 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    } else if (hasImageA && hasImageB) {
      // 두 이미지 모두 있으면 평균 높이 사용
      unifiedHeight = (heightA + heightB) / 2;
    } else {
      // 하나만 있으면 해당 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    }

    // 6. 높이 제한 적용
    unifiedHeight = unifiedHeight.clamp(minHeight, maxHeight);

    // 7. 최종 크기 반환
    final sizeA = hasImageA ? Size(boxWidth, unifiedHeight) : Size.zero;
    final sizeB = hasImageB ? Size(boxWidth, unifiedHeight) : Size.zero;

    return BoxSizes(
      sizeA: sizeA,
      sizeB: sizeB,
      layoutType: layoutType,
      containerType: BoxCalculatorConfig.containerTypeMessage,
      spacing: spacing,
      unifiedHeight: unifiedHeight,
      boxWidth: boxWidth,
    );
  }

  /// 알림 다이얼로그용 간편 계산 메서드 (기존 - deprecated)
  @Deprecated('Use calculateForNotificationDialog instead')
  static BoxSizes calculateForNotification({
    required double containerWidth,
    required double screenHeight,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    return calculate(
      containerWidth: containerWidth,
      containerHeight: screenHeight,
      containerType: BoxCalculatorConfig.containerTypeNotification,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
  }

  /// 알림 다이얼로그 전용 계산 메서드
  ///
  /// 다이얼로그 내부 공간을 최대한 활용하고 고정된 높이 제한을 사용합니다.
  /// - 다이얼로그 너비의 95% 사용
  /// - 고정 최대 높이: 단일(500px), 가로(400px), 세로(350px 전체)
  static BoxSizes calculateForNotificationDialog({
    required double dialogWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    // 1. 박스 간격
    const double spacing = BoxCalculatorConfig.notificationDialogSpacing;

    // 2. 박스 너비 계산 - 다이얼로그 너비를 최대한 활용
    double boxWidth;
    if (layoutType == LayoutType.single) {
      boxWidth = dialogWidth * BoxCalculatorConfig.notificationDialogSingleWidthRatio; // 단일: 95%
    } else if (layoutType == LayoutType.horizontal) {
      // 가로 배치: 양쪽 여백과 간격을 고려하여 계산
      final availableWidth = dialogWidth - spacing - BoxCalculatorConfig.notificationDialogHorizontalPadding; // 양쪽 8px 여백
      boxWidth = availableWidth / 2;
    } else {
      // 세로 배치: 95%
      boxWidth = dialogWidth * BoxCalculatorConfig.notificationDialogVerticalWidthRatio;
    }

    // 3. 고정 최대 높이
    double maxHeight;
    double minHeight;

    if (layoutType == LayoutType.single) {
      maxHeight = BoxCalculatorConfig.notificationDialogSingleMaxHeight;
      minHeight = BoxCalculatorConfig.notificationDialogSingleMinHeight;
    } else if (layoutType == LayoutType.horizontal) {
      maxHeight = BoxCalculatorConfig.notificationDialogHorizontalMaxHeight;
      minHeight = BoxCalculatorConfig.notificationDialogHorizontalMinHeight;
    } else {
      // 세로: 전체 350px, 개별 박스는 171px
      if (hasImageA && hasImageB) {
        maxHeight = (BoxCalculatorConfig.notificationDialogVerticalTotalMaxHeight - spacing) / 2; // 171px
        minHeight = BoxCalculatorConfig.notificationDialogVerticalMinHeightTwoBoxes; // 세로에서 두 박스일 때는 최소 100px
      } else {
        maxHeight = BoxCalculatorConfig.notificationDialogVerticalMaxHeightSingleBox; // 박스 하나만 있으면 350px
        minHeight = BoxCalculatorConfig.notificationDialogVerticalMinHeightSingleBox;
      }
    }

    // 4. aspectRatio 기반 높이 계산
    // 기본값을 boxWidth 기반으로 계산 (기본 비율 1.5)
    double heightA = boxWidth / BoxCalculatorConfig.notificationDialogDefaultAspectRatio; // 기본 비율 1.5
    double heightB = boxWidth / BoxCalculatorConfig.notificationDialogDefaultAspectRatio;

    if (aspectRatioA != null && aspectRatioA > 0) {
      heightA = boxWidth / aspectRatioA;
    }

    if (aspectRatioB != null && aspectRatioB > 0) {
      heightB = boxWidth / aspectRatioB;
    }

    // 5. 통일된 높이 계산
    double unifiedHeight;
    final isSingle = layoutType == LayoutType.single ||
        (hasImageA && !hasImageB) ||
        (!hasImageA && hasImageB);

    if (isSingle) {
      // 단일 이미지는 해당 이미지의 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    } else if (hasImageA && hasImageB) {
      // 두 이미지 모두 있으면 평균 높이 사용
      unifiedHeight = (heightA + heightB) / 2;
    } else {
      // 하나만 있으면 해당 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    }

    // 6. 높이 제한 적용
    unifiedHeight = unifiedHeight.clamp(minHeight, maxHeight);

    // 7. 최종 크기 반환
    final sizeA = hasImageA ? Size(boxWidth, unifiedHeight) : Size.zero;
    final sizeB = hasImageB ? Size(boxWidth, unifiedHeight) : Size.zero;

    return BoxSizes(
      sizeA: sizeA,
      sizeB: sizeB,
      layoutType: layoutType,
      containerType: BoxCalculatorConfig.containerTypeNotification,
      spacing: spacing,
      unifiedHeight: unifiedHeight,
      boxWidth: boxWidth,
    );
  }

  /// 질문 작성용 간편 계산 메서드
  static BoxSizes calculateForQuestion({
    required double containerWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  }) {
    return calculate(
      containerWidth: containerWidth,
      containerType: BoxCalculatorConfig.containerTypeQuestion,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
  }

}

/// 박스 크기 계산 결과
class BoxSizes {
  /// A 박스 크기
  final Size sizeA;

  /// B 박스 크기
  final Size sizeB;

  /// 레이아웃 타입
  final LayoutType layoutType;

  /// 컨테이너 타입
  final String containerType;

  /// 박스 간 간격
  final double spacing;

  /// 통일된 높이
  final double unifiedHeight;

  /// 박스 너비
  final double boxWidth;

  const BoxSizes({
    required this.sizeA,
    required this.sizeB,
    required this.layoutType,
    required this.containerType,
    required this.spacing,
    required this.unifiedHeight,
    required this.boxWidth,
  });

  /// 가로 배치인지 확인
  bool get isHorizontal => layoutType == LayoutType.horizontal;

  /// 세로 배치인지 확인
  bool get isVertical => layoutType == LayoutType.vertical;

  /// 단일 이미지인지 확인
  bool get isSingle =>
      layoutType == LayoutType.single ||
      sizeA == Size.zero ||
      sizeB == Size.zero;
  
  // Convenience getters for backward compatibility
  double get boxWidthA => sizeA.width;
  double get boxHeightA => sizeA.height;
  double get boxWidthB => sizeB.width;
  double get boxHeightB => sizeB.height;
  
  // Legacy getters for older code
  Size get boxA => sizeA;
  Size get boxB => sizeB;

  /// 전체 컨테이너 크기
  Size get containerSize {
    if (isSingle) {
      return sizeA != Size.zero ? sizeA : sizeB;
    }

    if (isHorizontal) {
      final totalWidth = sizeA.width + sizeB.width + spacing;
      return Size(totalWidth, unifiedHeight);
    } else {
      final totalHeight = sizeA.height + sizeB.height + spacing;
      return Size(boxWidth, totalHeight);
    }
  }

  /// 두 박스가 동일한 크기인지 확인
  bool get hasUnifiedSize {
    if (sizeA == Size.zero || sizeB == Size.zero) {
      return true; // 하나만 있으면 통일된 것으로 간주
    }

    // 높이 차이가 1픽셀 미만이면 동일한 것으로 간주
    return (sizeA.height - sizeB.height).abs() < 1.0 &&
        (sizeA.width - sizeB.width).abs() < 1.0;
  }

  /// 디버그용 문자열
  @override
  String toString() {
    return 'BoxSizes(\n'
        '  Container: $containerType\n'
        '  Layout: ${layoutType.name}\n'
        '  SizeA: ${sizeA.width.toStringAsFixed(1)} x ${sizeA.height.toStringAsFixed(1)}\n'
        '  SizeB: ${sizeB.width.toStringAsFixed(1)} x ${sizeB.height.toStringAsFixed(1)}\n'
        '  Unified: $hasUnifiedSize\n'
        '  Container Size: ${containerSize.width.toStringAsFixed(1)} x ${containerSize.height.toStringAsFixed(1)}\n'
        ')';
  }

  /// 간단한 설명
  String get shortDescription {
    return 'BoxSizes($containerType, ${layoutType.name}, '
        'A: ${sizeA.width.toStringAsFixed(0)}x${sizeA.height.toStringAsFixed(0)}, '
        'B: ${sizeB.width.toStringAsFixed(0)}x${sizeB.height.toStringAsFixed(0)})';
  }
}
