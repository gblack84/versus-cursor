import 'package:flutter/material.dart';
import 'aspect_ratio_analyzer.dart';
import '../../../shared/services/unified_box_calculator.dart';

/// 이미지 비율에 따른 동적 박스 크기 계산 클래스
class DynamicBoxCalculator {
  // 박스 크기 제한값
  static const double maxHeightHorizontal = 500; // 가로 배치 시 최대 높이
  static const double minHeightHorizontal = 150; // 가로 배치 시 최소 높이
  static const double maxHeightVertical = 400;   // 세로 배치 시 최대 높이
  static const double minHeightVertical = 120;   // 세로 배치 시 최소 높이
  static const double padding = 5;                // 박스 간 패딩
  
  // 기본 박스 높이 (이미지가 없을 때)
  static const double defaultHeightHorizontal = 350;  // A/B 둘 다 있을 때
  static const double defaultHeightVertical = 200;
  static const double defaultHeightSingle = 400;      // A 하나만 있을 때
  
  /// 가로 배치일 때 박스 크기 계산
  static Size getHorizontalBoxSize(BuildContext context, double? aspectRatio) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Expanded 위젯이 자동으로 공간을 분배하므로 정확한 너비 계산 불필요
    final boxWidth = (screenWidth - padding * 2 - padding) / 2; // 양쪽 5px + 중간 5px
    
    if (aspectRatio == null) {
      return Size(boxWidth, defaultHeightHorizontal);
    }
    
    // 이미지 비율에 맞춰 높이 계산
    double height = boxWidth / aspectRatio;
    
    // 높이 제한 적용
    height = height.clamp(minHeightHorizontal, maxHeightHorizontal);
    
    return Size(boxWidth, height);
  }
  
  /// 세로 배치일 때 박스 크기 계산
  static Size getVerticalBoxSize(BuildContext context, double? aspectRatio) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth - padding * 2; // 양쪽 패딩만
    
    if (aspectRatio == null) {
      return Size(boxWidth, defaultHeightVertical);
    }
    
    // 이미지 비율에 맞춰 높이 계산
    double height = boxWidth / aspectRatio;
    
    // 세로 배치는 더 낮은 높이 제한
    height = height.clamp(minHeightVertical, maxHeightVertical);
    
    return Size(boxWidth, height);
  }
  
  /// 단일 이미지일 때 박스 크기 계산
  static Size getSingleBoxSize(BuildContext context, double? aspectRatio, String box) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // A 박스만 있을 때는 전체 너비 사용
    if (box == 'A') {
      final boxWidth = screenWidth - padding * 2;
      
      print('[DynamicBoxCalculator] getSingleBoxSize:');
      print('  - screenWidth: $screenWidth');
      print('  - boxWidth: $boxWidth');
      print('  - aspectRatio: $aspectRatio');
      
      if (aspectRatio == null) {
        print('  - aspectRatio가 null이므로 기본 높이 사용: $defaultHeightSingle');
        return Size(boxWidth, defaultHeightSingle);
      }
      
      // 이미지 비율에 맞춰 높이 계산
      double height = boxWidth / aspectRatio;
      print('  - 계산된 초기 높이: $height');
      
      // 단일 이미지는 좀 더 큰 높이 허용
      height = height.clamp(minHeightHorizontal, maxHeightHorizontal * 1.2);
      print('  - 제한 적용 후 높이: $height (최소: $minHeightHorizontal, 최대: ${maxHeightHorizontal * 1.2})');
      
      return Size(boxWidth, height);
    }
    
    // B 박스만 있을 때 (일반적이지 않지만 처리)
    return getHorizontalBoxSize(context, aspectRatio);
  }
  
  /// 레이아웃 타입과 이미지 비율에 따른 박스 크기 계산
  static Size getBoxSize({
    required BuildContext context,
    required LayoutType layoutType,
    required String box,
    double? aspectRatio,
    bool hasOtherBox = true,
  }) {
    print('[DynamicBoxCalculator] getBoxSize 호출:');
    print('  - layoutType: $layoutType');
    print('  - box: $box');
    print('  - aspectRatio: $aspectRatio');
    print('  - hasOtherBox: $hasOtherBox');
    
    // 단일 이미지 레이아웃
    if (layoutType == LayoutType.single || !hasOtherBox) {
      return getSingleBoxSize(context, aspectRatio, box);
    }
    
    // 가로 배치
    if (layoutType == LayoutType.horizontal) {
      return getHorizontalBoxSize(context, aspectRatio);
    }
    
    // 세로 배치
    if (layoutType == LayoutType.vertical) {
      return getVerticalBoxSize(context, aspectRatio);
    }
    
    // 기본값 (발생하지 않아야 함)
    return getHorizontalBoxSize(context, aspectRatio);
  }
  
  /// 박스 높이만 계산 (너비는 이미 정해진 경우)
  static double getBoxHeight({
    required double width,
    required LayoutType layoutType,
    double? aspectRatio,
  }) {
    if (aspectRatio == null) {
      return layoutType == LayoutType.horizontal 
        ? defaultHeightHorizontal 
        : defaultHeightVertical;
    }
    
    // 너비에 맞춰 높이 계산
    double height = width / aspectRatio;
    
    // 레이아웃에 따른 높이 제한
    if (layoutType == LayoutType.horizontal) {
      return height.clamp(minHeightHorizontal, maxHeightHorizontal);
    } else {
      return height.clamp(minHeightVertical, maxHeightVertical);
    }
  }
  
  /// 최적의 박스 높이 계산 (A/B 둘 다 고려)
  static double getOptimalHeight({
    required LayoutType layoutType,
    required double width,
    double? aspectRatioA,
    double? aspectRatioB,
  }) {
    // 둘 다 없으면 기본값
    if (aspectRatioA == null && aspectRatioB == null) {
      return layoutType == LayoutType.horizontal 
        ? defaultHeightHorizontal 
        : defaultHeightVertical;
    }
    
    // 하나만 있으면 그것으로 계산
    if (aspectRatioA != null && aspectRatioB == null) {
      return getBoxHeight(width: width, layoutType: layoutType, aspectRatio: aspectRatioA);
    }
    if (aspectRatioA == null && aspectRatioB != null) {
      return getBoxHeight(width: width, layoutType: layoutType, aspectRatio: aspectRatioB);
    }
    
    // 둘 다 있으면 평균값 사용
    final heightA = getBoxHeight(width: width, layoutType: layoutType, aspectRatio: aspectRatioA);
    final heightB = getBoxHeight(width: width, layoutType: layoutType, aspectRatio: aspectRatioB);
    
    return (heightA + heightB) / 2;
  }
  
  /// A/B 박스 통합 크기 계산 (둘 다 같은 크기로)
  /// UnifiedBoxCalculator에 위임
  static Size getUnifiedSize({
    required BuildContext context,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // UnifiedBoxCalculator를 사용하여 통일된 크기 계산
    final boxSizes = UnifiedBoxCalculator.calculateForQuestion(
      containerWidth: screenWidth,
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      hasImageA: aspectRatioA != null,
      hasImageB: aspectRatioB != null,
    );
    
    // 두 박스가 같은 크기를 가지므로 A 박스 크기 반환
    // (UnifiedBoxCalculator는 항상 통일된 크기를 반환함)
    return boxSizes.sizeA;
  }
}