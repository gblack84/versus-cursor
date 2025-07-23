import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/versus_box_size_data.dart';
import '../constants/voting_notification_constraints.dart';
import 'layout_synchronizer.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '/posts/in_put_post_image/helpers/dynamic_box_calculator.dart';
import '/posts/in_put_post_image/in_put_post_image_model.dart';
import '/app_state.dart';

/// 질문 작성 페이지와 투표 알림 간 박스 크기 계산 서비스
/// 
/// 일관된 시각적 경험을 위해 원본 크기를 투표 알림에 맞게 스케일링합니다.
class VersusBoxSizeCalculator {
  
  /// 질문 작성 페이지에서 현재 상태의 사이즈 데이터 캡처
  /// 
  /// [context] 현재 BuildContext
  /// [appState] AppState 인스턴스
  /// [model] InPutPostImageModel 인스턴스 (레이아웃 정보용)
  static VersusBoxSizeData? captureCurrentSizes(
    BuildContext context,
    AppState appState,
    InPutPostImageModel model,
  ) {
    try {
      // 현재 이미지 정보 수집
      final hasImageA = appState.uploadImageA.isNotEmpty;
      final hasImageB = appState.uploadImageB.isNotEmpty;
      
      // 이미지가 하나도 없으면 null 반환
      if (!hasImageA && !hasImageB) {
        return null;
      }
      
      // 현재 레이아웃 타입 결정
      final layoutType = _determineCurrentLayout(appState, model);
      
      // 박스 크기 계산
      final boxSizes = _calculateCurrentBoxSizes(context, appState, model, layoutType);
      
      return VersusBoxSizeData.fromCurrentState(
        context: context,
        layoutType: layoutType,
        aspectRatiosA: hasImageA ? appState.uploadImageAspectRatioA : null,
        aspectRatiosB: hasImageB ? appState.uploadImageAspectRatioB : null,
        boxSizeA: boxSizes.sizeA,
        boxSizeB: boxSizes.sizeB,
      );
      
    } catch (e) {
      print('[VersusBoxSizeCalculator] Error capturing sizes: $e');
      return null;
    }
  }
  
  /// 투표 알림에서 사용할 박스 크기 계산 (개선된 버전)
  /// 
  /// [sizeData] 원본 사이즈 데이터
  /// [context] 투표 알림의 BuildContext
  /// [maxWidth] 알림의 최대 너비 (기본값: 화면 너비 - 패딩)
  /// [maxHeight] 박스의 최대 높이 (기본값: 160px)
  static VotingBoxSizes calculateVotingSize(
    VersusBoxSizeData sizeData,
    BuildContext context, {
    double? maxWidth,
    double? maxHeight,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = maxWidth ?? VotingNotificationConstraints.getNotificationWidth(screenWidth);
    final containerHeight = maxHeight ?? VotingNotificationConstraints.maxBoxHeight;
    
    // 1. 화면 크기에 따른 스케일링 팩터 계산
    final scaleFactor = VotingNotificationConstraints.getScaleFactor(screenWidth);
    
    // 2. LayoutSynchronizer를 사용한 최적 레이아웃 결정
    final votingLayout = LayoutSynchronizer.optimizeForVoting(
      originalLayout: sizeData.layoutType,
      containerWidth: containerWidth,
      aspectRatioA: sizeData.aspectRatioA,
      aspectRatioB: sizeData.aspectRatioB,
      hasImageA: sizeData.hasImageA,
      hasImageB: sizeData.hasImageB,
    );
    
    print('[VersusBoxSizeCalculator] ========== 크기 계산 시작 ==========');
    print('  화면 정보:');
    print('    - 화면 너비: ${screenWidth.toStringAsFixed(1)}px');
    print('    - 컨테이너 너비: ${containerWidth.toStringAsFixed(1)}px (화면의 ${(containerWidth/screenWidth*100).toStringAsFixed(0)}%)');
    print('    - 컨테이너 높이: ${containerHeight.toStringAsFixed(1)}px');
    print('    - 스케일 팩터: ${(scaleFactor * 100).toStringAsFixed(0)}%');
    print('  레이아웃 최적화:');
    print('    - 원본 레이아웃: ${sizeData.layoutType}');
    print('    - 최적화된 레이아웃: ${votingLayout.layoutType}');
    print('    - 변환 이유: ${votingLayout.reason}');
    
    // 3. 레이아웃 변환에 따른 크기 조정 팩터 계산
    final sizeAdjustment = LayoutSynchronizer.calculateSizeAdjustment(
      originalLayout: sizeData.layoutType,
      targetLayout: votingLayout.layoutType,
      originalSize: sizeData.originalSizeA,
    );
    
    // 4. 최적 간격 계산 (동적 간격 사용)
    final dynamicSpacing = VotingNotificationConstraints.getDynamicBoxSpacing(screenWidth);
    final spacing = VotingSpacing(
      horizontal: dynamicSpacing,
      vertical: dynamicSpacing * 1.5,
      reason: 'Dynamic spacing based on screen size',
    );
    
    // 5. 각 박스의 크기 계산
    Size sizeA, sizeB;
    
    if (votingLayout.layoutType == LayoutType.horizontal) {
      // 가로 배치
      final availableWidth = containerWidth - spacing.horizontal;
      final boxWidth = sizeData.hasImageB 
          ? availableWidth / 2 
          : availableWidth * 0.95; // 단일 이미지는 95% 너비 사용
      
      sizeA = _calculateOptimizedBoxSize(
        originalSize: sizeData.originalSizeA,
        containerWidth: boxWidth,
        containerHeight: containerHeight,
        scaleFactor: scaleFactor,
        sizeAdjustment: sizeAdjustment,
        aspectRatio: sizeData.aspectRatioA,
      );
      
      sizeB = sizeData.hasImageB 
          ? _calculateOptimizedBoxSize(
              originalSize: sizeData.originalSizeB,
              containerWidth: boxWidth,
              containerHeight: containerHeight,
              scaleFactor: scaleFactor,
              sizeAdjustment: sizeAdjustment,
              aspectRatio: sizeData.aspectRatioB,
            )
          : Size.zero; // B박스가 없으면 크기 0
      
    } else {
      // 세로 배치
      final isSingleImage = sizeData.hasImageA && !sizeData.hasImageB;
      
      if (isSingleImage) {
        // 단일 이미지는 전체 높이와 너비 사용 (더 큰 이미지 표시)
        sizeA = _calculateOptimizedBoxSize(
          originalSize: sizeData.originalSizeA,
          containerWidth: containerWidth * 0.95,  // 95% 너비 사용 (좌우 여백)
          containerHeight: containerHeight * 0.9,  // 90% 높이 사용
          scaleFactor: scaleFactor,
          sizeAdjustment: sizeAdjustment,
          aspectRatio: sizeData.aspectRatioA,
        );
        sizeB = Size.zero;
      } else {
        // 두 개의 이미지는 높이를 나눔
        final availableHeight = containerHeight - spacing.vertical;
        final boxHeight = availableHeight / 2;
        
        sizeA = _calculateOptimizedBoxSize(
          originalSize: sizeData.originalSizeA,
          containerWidth: containerWidth,
          containerHeight: boxHeight,
          scaleFactor: scaleFactor,
          sizeAdjustment: sizeAdjustment,
          aspectRatio: sizeData.aspectRatioA,
        );
        
        sizeB = _calculateOptimizedBoxSize(
          originalSize: sizeData.originalSizeB,
          containerWidth: containerWidth,
          containerHeight: boxHeight,
          scaleFactor: scaleFactor,
          sizeAdjustment: sizeAdjustment,
          aspectRatio: sizeData.aspectRatioB,
        );
      }
    }
    
    // 6. 최종 크기 제약 조건 적용
    // 레이아웃에 따라 적절한 maxWidth 설정
    double maxWidthForBox;
    if (votingLayout.layoutType == LayoutType.horizontal) {
      // 가로 배치: 각 박스는 전체 너비의 절반에서 간격을 뺀 크기
      maxWidthForBox = (containerWidth - spacing.horizontal) / 2;
    } else {
      // 세로 배치: 각 박스는 전체 너비 사용 가능
      maxWidthForBox = containerWidth;
    }
    
    sizeA = VotingNotificationConstraints.constrainBoxSize(sizeA, 1.0, maxWidth: maxWidthForBox);
    if (sizeData.hasImageB) {
      sizeB = VotingNotificationConstraints.constrainBoxSize(sizeB, 1.0, maxWidth: maxWidthForBox);
    }
    
    print('  최종 박스 크기:');
    print('    - A박스: ${sizeA.width.toStringAsFixed(1)} x ${sizeA.height.toStringAsFixed(1)}');
    if (sizeData.hasImageB) {
      print('    - B박스: ${sizeB.width.toStringAsFixed(1)} x ${sizeB.height.toStringAsFixed(1)}');
    }
    print('    - A박스 비율: ${sizeData.aspectRatioA?.toStringAsFixed(3) ?? 'null'}');
    if (sizeData.hasImageB) {
      print('    - B박스 비율: ${sizeData.aspectRatioB?.toStringAsFixed(3) ?? 'null'}');
    }
    print('[VersusBoxSizeCalculator] ========== 크기 계산 완료 ==========');
    
    return VotingBoxSizes(
      sizeA: sizeA,
      sizeB: sizeB,
      layoutType: votingLayout.layoutType,
      scaleFactor: scaleFactor,
      spacing: spacing,
      conversionReason: votingLayout.reason,
    );
  }
  
  /// 원본 크기를 컨테이너에 맞게 스케일링
  /// 
  /// [originalSize] 원본 박스 크기
  /// [containerSize] 목표 컨테이너 크기
  /// [preserveRatio] 비율 유지 여부 (기본값: true)
  static Size scaleToFit(
    Size originalSize,
    Size containerSize, {
    bool preserveRatio = true,
  }) {
    if (!preserveRatio) {
      return containerSize;
    }
    
    final scaleX = containerSize.width / originalSize.width;
    final scaleY = containerSize.height / originalSize.height;
    final scale = math.min(scaleX, scaleY);
    
    return Size(
      originalSize.width * scale,
      originalSize.height * scale,
    );
  }
  
  // 내부 헬퍼 메서드들
  
  /// 현재 상태에서 레이아웃 타입 결정
  static LayoutType _determineCurrentLayout(AppState appState, InPutPostImageModel model) {
    final hasImageA = appState.uploadImageA.isNotEmpty;
    final hasImageB = appState.uploadImageB.isNotEmpty;
    
    if (hasImageA && hasImageB) {
      // 둘 다 있으면 비율 분석으로 결정
      final ratioA = appState.uploadImageAspectRatioA.isNotEmpty 
          ? appState.uploadImageAspectRatioA.first 
          : null;
      final ratioB = appState.uploadImageAspectRatioB.isNotEmpty 
          ? appState.uploadImageAspectRatioB.first 
          : null;
      
      return AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);
    } else {
      // 하나만 있으면 단일 레이아웃
      return LayoutType.single;
    }
  }
  
  /// 현재 상태의 박스 크기 계산
  static ({Size sizeA, Size sizeB}) _calculateCurrentBoxSizes(
    BuildContext context,
    AppState appState,
    InPutPostImageModel model,
    LayoutType layoutType,
  ) {
    final hasImageA = appState.uploadImageA.isNotEmpty;
    final hasImageB = appState.uploadImageB.isNotEmpty;
    
    final ratioA = hasImageA && appState.uploadImageAspectRatioA.isNotEmpty 
        ? appState.uploadImageAspectRatioA.first 
        : null;
    final ratioB = hasImageB && appState.uploadImageAspectRatioB.isNotEmpty 
        ? appState.uploadImageAspectRatioB.first 
        : null;
    
    Size sizeA, sizeB;
    
    if (layoutType == LayoutType.single) {
      // 단일 이미지
      sizeA = DynamicBoxCalculator.getSingleBoxSize(context, ratioA, 'A');
      sizeB = hasImageB 
          ? DynamicBoxCalculator.getSingleBoxSize(context, ratioB, 'B')
          : Size.zero;
    } else {
      // 가로/세로 배치
      final unifiedSize = DynamicBoxCalculator.getUnifiedSize(
        context: context,
        layoutType: layoutType,
        aspectRatioA: ratioA,
        aspectRatioB: ratioB,
      );
      
      sizeA = unifiedSize;
      sizeB = hasImageB ? unifiedSize : Size.zero;
    }
    
    return (sizeA: sizeA, sizeB: sizeB);
  }
  
  /// 화면 크기에 따른 스케일링 팩터 계산
  static double _getScaleFactorForScreen(double screenWidth) {
    if (screenWidth > 400) return 0.9;      // 큰 화면: 90%
    if (screenWidth > 350) return 0.8;      // 중간 화면: 80%
    return 0.7;                             // 작은 화면: 70%
  }
  
  /// 투표 알림에 적합한 레이아웃으로 변환
  static VotingLayoutConfig _convertToVotingLayout(
    VersusBoxSizeData sizeData,
    double containerWidth,
  ) {
    // 세로 배치는 공간 절약을 위해 가로 배치로 변환
    if (sizeData.layoutType == LayoutType.vertical) {
      return VotingLayoutConfig(
        layoutType: LayoutType.horizontal,
        reason: 'Converted from vertical to save space',
      );
    }
    
    // 단일 이미지는 A + 빈 B박스 형태로 표시
    if (sizeData.layoutType == LayoutType.single) {
      return VotingLayoutConfig(
        layoutType: LayoutType.horizontal,
        reason: 'Single image with empty B box',
      );
    }
    
    // 가로 배치는 그대로 유지
    return VotingLayoutConfig(
      layoutType: LayoutType.horizontal,
      reason: 'Original horizontal layout preserved',
    );
  }
  
  /// 최적화된 박스 크기 계산 (새로운 메서드)
  static Size _calculateOptimizedBoxSize({
    required Size originalSize,
    required double containerWidth,
    required double containerHeight,
    required double scaleFactor,
    required SizeAdjustmentFactor sizeAdjustment,
    double? aspectRatio,
  }) {
    Size calculatedSize;
    
    // 1. 이미지 비율이 있으면 비율 기준으로 계산
    if (aspectRatio != null) {
      // 컨테이너에 맞는 최대 크기 계산
      double width = containerWidth;
      double height = width / aspectRatio;
      
      // 높이가 컨테이너를 초과하면 높이 기준으로 재계산
      if (height > containerHeight) {
        height = containerHeight;
        width = height * aspectRatio;
      }
      
      // 너비가 컨테이너를 초과하면 너비 기준으로 재계산
      if (width > containerWidth) {
        width = containerWidth;
        height = width / aspectRatio;
      }
      
      calculatedSize = Size(width, height);
    } else {
      // 비율이 없으면 원본 크기 기준으로 스케일링
      final targetSize = Size(containerWidth, containerHeight);
      calculatedSize = scaleToFit(originalSize, targetSize);
    }
    
    // 2. 레이아웃 변환에 따른 크기 조정 적용
    calculatedSize = sizeAdjustment.apply(calculatedSize);
    
    // 3. 화면 크기에 따른 스케일링 팩터 적용
    calculatedSize = Size(
      calculatedSize.width * scaleFactor,
      calculatedSize.height * scaleFactor,
    );
    
    return calculatedSize;
  }

  /// 박스를 컨테이너에 맞게 스케일링 (레거시 메서드 - 호환성 유지)
  static Size _scaleBoxToFit({
    required Size originalSize,
    required double containerWidth,
    required double containerHeight,
    required double scaleFactor,
    double? aspectRatio,
  }) {
    // 기본 크기 조정 팩터 사용
    final defaultAdjustment = SizeAdjustmentFactor(
      widthFactor: 1.0,
      heightFactor: 1.0,
      reason: 'Legacy method compatibility',
    );
    
    return _calculateOptimizedBoxSize(
      originalSize: originalSize,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      scaleFactor: scaleFactor,
      sizeAdjustment: defaultAdjustment,
      aspectRatio: aspectRatio,
    );
  }
}

/// 투표 알림용 박스 크기 정보 (확장된 버전)
class VotingBoxSizes {
  final Size sizeA;
  final Size sizeB;
  final LayoutType layoutType;
  final double scaleFactor;
  final VotingSpacing? spacing;
  final String? conversionReason;
  
  const VotingBoxSizes({
    required this.sizeA,
    required this.sizeB,
    required this.layoutType,
    required this.scaleFactor,
    this.spacing,
    this.conversionReason,
  });
  
  /// 통합된 높이 (A/B 중 큰 값)
  double get unifiedHeight => math.max(sizeA.height, sizeB.height);
  
  /// 통합된 너비 (가로 배치 시 A+B+간격, 세로 배치 시 더 큰 값)
  double get unifiedWidth {
    if (layoutType == LayoutType.horizontal) {
      final spacingWidth = spacing?.horizontal ?? 8.0;
      return sizeA.width + sizeB.width + spacingWidth;
    } else {
      return math.max(sizeA.width, sizeB.width);
    }
  }
  
  /// 전체 컨테이너 크기
  Size get containerSize {
    if (layoutType == LayoutType.horizontal) {
      return Size(unifiedWidth, unifiedHeight);
    } else {
      final spacingHeight = spacing?.vertical ?? 12.0;
      return Size(unifiedWidth, sizeA.height + sizeB.height + spacingHeight);
    }
  }
  
  /// A박스가 B박스보다 큰지 확인
  bool get isALargerThanB {
    return sizeA.width * sizeA.height > sizeB.width * sizeB.height;
  }
  
  /// 박스들이 균형 잡힌 크기인지 확인 (50% 이내 차이)
  bool get isBalanced {
    final areaA = sizeA.width * sizeA.height;
    final areaB = sizeB.width * sizeB.height;
    final ratio = math.min(areaA, areaB) / math.max(areaA, areaB);
    return ratio > 0.5; // 50% 이상이면 균형 잡힌 것으로 간주
  }
  
  /// 투표 버튼에 적합한 크기 계산
  Size get voteButtonSize {
    final avgWidth = (sizeA.width + sizeB.width) / 2;
    return VotingNotificationConstraints.getVoteButtonSize(avgWidth);
  }
  
  /// 텍스트 크기 계산 (박스 높이에 적응)
  double getAdaptiveTextSize([double baseSize = 12.0]) {
    return VotingNotificationConstraints.getAdaptiveTextSize(unifiedHeight, baseTextSize: baseSize);
  }
  
  /// 간격 정보
  EdgeInsets get spacingAsEdgeInsets {
    return spacing?.asEdgeInsets ?? EdgeInsets.zero;
  }
  
  /// 레이아웃 변환이 발생했는지 확인
  bool get hasLayoutConversion {
    return conversionReason != null && 
           conversionReason!.toLowerCase().contains('convert');
  }
  
  /// 성능 정보 (디버그용)
  Map<String, dynamic> get performanceInfo {
    return {
      'unifiedHeight': unifiedHeight.toStringAsFixed(1),
      'unifiedWidth': unifiedWidth.toStringAsFixed(1),
      'containerSize': '${containerSize.width.toStringAsFixed(1)}x${containerSize.height.toStringAsFixed(1)}',
      'isBalanced': isBalanced,
      'hasConversion': hasLayoutConversion,
      'scaleFactor': '${(scaleFactor * 100).toStringAsFixed(0)}%',
      'textSize': getAdaptiveTextSize().toStringAsFixed(1),
    };
  }
  
  /// 디버그용 상세 문자열
  @override
  String toString() {
    return 'VotingBoxSizes(\n'
           '  A: ${sizeA.width.toStringAsFixed(1)}x${sizeA.height.toStringAsFixed(1)}\n'
           '  B: ${sizeB.width.toStringAsFixed(1)}x${sizeB.height.toStringAsFixed(1)}\n'
           '  Layout: $layoutType\n'
           '  Scale: ${(scaleFactor * 100).toStringAsFixed(0)}%\n'
           '  Container: ${containerSize.width.toStringAsFixed(1)}x${containerSize.height.toStringAsFixed(1)}\n'
           '  Balanced: $isBalanced\n'
           '  Conversion: ${conversionReason ?? 'None'}\n'
           ')';
  }
  
  /// 간단한 디버그용 문자열
  String get shortDescription {
    return 'VotingBoxSizes(A: ${sizeA.width.toStringAsFixed(0)}x${sizeA.height.toStringAsFixed(0)}, '
           'B: ${sizeB.width.toStringAsFixed(0)}x${sizeB.height.toStringAsFixed(0)}, '
           'layout: $layoutType, scale: ${(scaleFactor * 100).toStringAsFixed(0)}%)';
  }
}

