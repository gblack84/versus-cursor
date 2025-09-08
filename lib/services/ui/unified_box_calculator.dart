import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '/core/constants/layout_constants.dart';
import '/core/usecases/media/aspect_ratio_analyzer.dart';
import '/core/types/layout_type.dart';

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
    final maxHeight = LayoutConstants.getMaxHeight(
      containerType: containerType,
      isHorizontal: isHorizontal,
      isSingle: isSingle,
      screenHeight: containerHeight,
    );
    
    final minHeight = LayoutConstants.getMinHeight(
      containerType: containerType,
      isHorizontal: isHorizontal,
      isSingle: isSingle,
    );
    
    // 4. 박스 너비 계산
    final spacing = LayoutConstants.getSpacing(isHorizontal);
    double boxWidth;
    
    if (isSingle) {
      // 단일 이미지는 80% 너비 사용
      boxWidth = containerWidth * LayoutConstants.singleBoxWidthRatio;
    } else if (isHorizontal) {
      // 가로 배치: 간격 제외하고 절반씩
      final availableWidth = containerWidth - spacing;
      boxWidth = availableWidth * LayoutConstants.horizontalBoxWidthRatio;
    } else {
      // 세로 배치: 95% 너비 사용
      boxWidth = containerWidth * LayoutConstants.verticalBoxWidthRatio;
    }
    
    // 5. 높이 계산 (aspectRatio 기반)
    double heightA = LayoutConstants.defaultBoxHeight;
    double heightB = LayoutConstants.defaultBoxHeight;
    
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
      
      // 디버그 출력
      _printDebugInfo(
        containerType: containerType,
        layoutType: layoutType,
        heightA: heightA,
        heightB: heightB,
        unifiedHeight: unifiedHeight,
        boxWidth: boxWidth,
      );
    } else {
      // 하나만 있으면 해당 높이 사용
      unifiedHeight = hasImageA ? heightA : heightB;
    }
    
    // 7. 높이 제한 적용
    unifiedHeight = unifiedHeight.clamp(minHeight, maxHeight);
    
    // 8. 세로 배치에서 전체 높이가 컨테이너를 초과하는지 확인
    if (!isHorizontal && hasImageA && hasImageB && containerHeight != null) {
      final totalRequiredHeight = (unifiedHeight * 2) + spacing;
      final maxAvailableHeight = containerHeight * 0.88; // 88% 사용
      
      if (totalRequiredHeight > maxAvailableHeight) {
        // 비율을 유지하면서 전체 크기 조정
        final scalingFactor = maxAvailableHeight / totalRequiredHeight;
        unifiedHeight *= scalingFactor;
        
        if (!kReleaseMode) {
          print('[UnifiedBoxCalculator] 세로 배치 스케일링 적용:');
          print('  - 필요 높이: ${totalRequiredHeight.toStringAsFixed(1)}px');
          print('  - 최대 높이: ${maxAvailableHeight.toStringAsFixed(1)}px');
          print('  - 스케일링: ${(scalingFactor * 100).toStringAsFixed(1)}%');
        }
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
      containerType: LayoutConstants.containerTypeMessage,
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
    const double spacing = 8.0;
    
    // 2. 박스 너비 계산
    double boxWidth;
    if (layoutType == LayoutType.single) {
      boxWidth = bubbleWidth * 0.8;  // 단일: 80%
    } else if (layoutType == LayoutType.horizontal) {
      // 가로 배치: 간격 빼고 절반씩
      final availableWidth = bubbleWidth - spacing;
      boxWidth = availableWidth * 0.495;
    } else {
      // 세로 배치: 95%
      boxWidth = bubbleWidth * 0.95;
    }
    
    // 3. 고정 최대 높이 (업데이트된 사양)
    double maxHeight;
    double minHeight;
    
    if (layoutType == LayoutType.single) {
      maxHeight = 400.0;  // 단일: 400px
      minHeight = 100.0;  // 단일 이미지는 최소 100px로 설정 (자연스러운 크기 유지)
    } else if (layoutType == LayoutType.horizontal) {
      maxHeight = 400.0;  // 가로: 400px (개별 박스)
      minHeight = 200.0;
    } else {
      // 세로: 전체 350px, 개별 박스는 171px
      if (hasImageA && hasImageB) {
        maxHeight = (350.0 - spacing) / 2;  // 171px
        minHeight = 100.0;  // 세로에서 두 박스일 때는 최소 100px
      } else {
        maxHeight = 350.0;  // 박스 하나만 있으면 350px
        minHeight = 200.0;
      }
    }
    
    // 4. aspectRatio 기반 높이 계산
    // 기본값을 boxWidth 기반으로 계산 (기본 비율 1.5)
    double heightA = boxWidth / 1.5;  // 기본 비율 1.5
    double heightB = boxWidth / 1.5;
    
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
    
    // 7. 디버그 정보
    if (!kReleaseMode) {
      print('\n[UnifiedBoxCalculator] 메시지 카드 계산:');
      print('  버블 너비: ${bubbleWidth.toStringAsFixed(1)}px');
      print('  레이아웃: ${layoutType.name}');
      print('  박스 너비: ${boxWidth.toStringAsFixed(1)}px');
      print('  최대 높이: ${maxHeight.toStringAsFixed(1)}px');
      print('  계산된 높이 A: ${heightA.toStringAsFixed(1)}px');
      print('  계산된 높이 B: ${heightB.toStringAsFixed(1)}px');
      print('  통일 높이: ${unifiedHeight.toStringAsFixed(1)}px');
      
      if (layoutType == LayoutType.vertical && hasImageA && hasImageB) {
        final totalHeight = (unifiedHeight * 2) + spacing;
        print('  세로 전체 높이: ${totalHeight.toStringAsFixed(1)}px (최대 350px)');
      }
    }
    
    // 8. 최종 크기 반환
    final sizeA = hasImageA ? Size(boxWidth, unifiedHeight) : Size.zero;
    final sizeB = hasImageB ? Size(boxWidth, unifiedHeight) : Size.zero;
    
    return BoxSizes(
      sizeA: sizeA,
      sizeB: sizeB,
      layoutType: layoutType,
      containerType: LayoutConstants.containerTypeMessage,
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
      containerType: LayoutConstants.containerTypeNotification,
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
    const double spacing = 8.0;
    
    // 2. 박스 너비 계산 - 다이얼로그 너비를 최대한 활용
    double boxWidth;
    if (layoutType == LayoutType.single) {
      boxWidth = dialogWidth * 0.95;  // 단일: 95%
    } else if (layoutType == LayoutType.horizontal) {
      // 가로 배치: 양쪽 여백과 간격을 고려하여 계산
      final availableWidth = dialogWidth - spacing - 16;  // 양쪽 8px 여백
      boxWidth = availableWidth / 2;
    } else {
      // 세로 배치: 95%
      boxWidth = dialogWidth * 0.95;
    }
    
    // 3. 고정 최대 높이
    double maxHeight;
    double minHeight;
    
    if (layoutType == LayoutType.single) {
      maxHeight = 500.0;
      minHeight = 150.0;
    } else if (layoutType == LayoutType.horizontal) {
      maxHeight = 400.0;
      minHeight = 150.0;
    } else {
      // 세로: 전체 350px, 개별 박스는 171px
      if (hasImageA && hasImageB) {
        maxHeight = (350.0 - spacing) / 2;  // 171px
        minHeight = 100.0;  // 세로에서 두 박스일 때는 최소 100px
      } else {
        maxHeight = 350.0;  // 박스 하나만 있으면 350px
        minHeight = 150.0;
      }
    }
    
    // 4. aspectRatio 기반 높이 계산
    // 기본값을 boxWidth 기반으로 계산 (기본 비율 1.5)
    double heightA = boxWidth / 1.5;  // 기본 비율 1.5
    double heightB = boxWidth / 1.5;
    
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
    
    // 7. 디버그 정보
    if (!kReleaseMode) {
      print('\n[UnifiedBoxCalculator] 알림 다이얼로그 계산:');
      print('  다이얼로그 너비: ${dialogWidth.toStringAsFixed(1)}px');
      print('  레이아웃: ${layoutType.name}');
      print('  박스 너비: ${boxWidth.toStringAsFixed(1)}px (95% 사용)');
      print('  최대 높이: ${maxHeight.toStringAsFixed(1)}px');
      print('  계산된 높이 A: ${heightA.toStringAsFixed(1)}px');
      print('  계산된 높이 B: ${heightB.toStringAsFixed(1)}px');
      print('  통일 높이: ${unifiedHeight.toStringAsFixed(1)}px');
      
      if (layoutType == LayoutType.vertical && hasImageA && hasImageB) {
        final totalHeight = (unifiedHeight * 2) + spacing;
        print('  세로 전체 높이: ${totalHeight.toStringAsFixed(1)}px (최대 350px)');
      }
    }
    
    // 9. 최종 크기 반환
    final sizeA = hasImageA ? Size(boxWidth, unifiedHeight) : Size.zero;
    final sizeB = hasImageB ? Size(boxWidth, unifiedHeight) : Size.zero;
    
    return BoxSizes(
      sizeA: sizeA,
      sizeB: sizeB,
      layoutType: layoutType,
      containerType: LayoutConstants.containerTypeNotification,
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
      containerType: LayoutConstants.containerTypeQuestion,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: hasImageA,
      hasImageB: hasImageB,
    );
  }
  
  /// 디버그 정보 출력
  static void _printDebugInfo({
    required String containerType,
    required LayoutType layoutType,
    required double heightA,
    required double heightB,
    required double unifiedHeight,
    required double boxWidth,
  }) {
    // 프로덕션 빌드에서는 로그 비활성화
    if (kReleaseMode) return;
    
    print('\n[UnifiedBoxCalculator] 계산 결과:');
    print('  컨테이너: $containerType');
    print('  레이아웃: ${layoutType.name}');
    print('  박스 너비: ${boxWidth.toStringAsFixed(1)}px');
    print('  A 개별 높이: ${heightA.toStringAsFixed(1)}px');
    print('  B 개별 높이: ${heightB.toStringAsFixed(1)}px');
    print('  통일 높이: ${unifiedHeight.toStringAsFixed(1)}px');
    print('  높이 차이: ${(heightA - heightB).abs().toStringAsFixed(1)}px');
    print('  평균 사용: ✅\n');
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
  bool get isSingle => layoutType == LayoutType.single || 
                       sizeA == Size.zero || 
                       sizeB == Size.zero;
  
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