import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/versus_box_size_data.dart';
import '../constants/voting_notification_constraints.dart';
import 'layout_synchronizer.dart';
import '../../../posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '../../../posts/in_put_post_image/helpers/dynamic_box_calculator.dart';
import '../../../posts/in_put_post_image/in_put_post_image_model.dart';
import '../../../app_state.dart';

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
  /// [maxHeight] 박스의 최대 높이 (기본값: 화면 높이의 80%)
  static VotingBoxSizes calculateVotingSize(
    VersusBoxSizeData sizeData,
    BuildContext context, {
    double? maxWidth,
    double? maxHeight,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = maxWidth ?? VotingNotificationConstraints.getNotificationWidth(screenWidth);
    // 화면 높이의 80%를 최대 높이로 설정
    final containerHeight = maxHeight ?? VotingNotificationConstraints.getMaxNotificationHeight(screenHeight);
    
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
      // 가로 배치 - 평균 높이를 사용한 통일된 크기 계산
      final boxSizes = _calculateHorizontalLayoutBoxSize(
        containerWidth: containerWidth,
        containerHeight: containerHeight,
        aspectRatioA: sizeData.aspectRatioA,
        aspectRatioB: sizeData.aspectRatioB,
        spacing: spacing.horizontal,
        scaleFactor: scaleFactor,
        sizeAdjustment: sizeAdjustment,
        hasImageB: sizeData.hasImageB,
      );
      
      sizeA = boxSizes.sizeA;
      sizeB = boxSizes.sizeB;
      
    } else {
      // 세로 배치 - 통일된 너비로 계산
      final isSingleImage = sizeData.hasImageA && !sizeData.hasImageB;
      
      if (isSingleImage) {
        // 단일 이미지는 전체 높이와 너비 사용 (더 큰 이미지 표시)
        sizeA = _calculateOptimizedBoxSize(
          originalSize: sizeData.originalSizeA,
          containerWidth: containerWidth * 0.9,  // 90% 너비 사용 (증가)
          containerHeight: containerHeight * 0.85,  // 85% 높이 사용 (증가)
          scaleFactor: scaleFactor,
          sizeAdjustment: sizeAdjustment,
          aspectRatio: sizeData.aspectRatioA,
        );
        sizeB = Size.zero;
      } else {
        // 두 개의 이미지 - 세로 배치 전용 크기 계산
        sizeA = _calculateVerticalLayoutBoxSize(
          containerWidth: containerWidth,
          containerHeight: containerHeight,
          aspectRatioA: sizeData.aspectRatioA,
          aspectRatioB: sizeData.aspectRatioB,
          spacing: spacing.vertical,
          scaleFactor: scaleFactor,
          sizeAdjustment: sizeAdjustment,
        ).sizeA;
        
        sizeB = _calculateVerticalLayoutBoxSize(
          containerWidth: containerWidth,
          containerHeight: containerHeight,
          aspectRatioA: sizeData.aspectRatioA,
          aspectRatioB: sizeData.aspectRatioB,
          spacing: spacing.vertical,
          scaleFactor: scaleFactor,
          sizeAdjustment: sizeAdjustment,
        ).sizeB;
      }
    }
    
    // 6. 최종 크기 검증 (제약 조건 적용하지 않음)
    // _calculateOptimizedBoxSize에서 이미 적절한 크기 계산이 완료됨
    // 추가적인 constrainBoxSize 호출은 크기를 불필요하게 축소시킴
    
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
  
  
  /// 최적화된 박스 크기 계산 (새로운 메서드)
  static Size _calculateOptimizedBoxSize({
    required Size originalSize,
    required double containerWidth,
    required double containerHeight,
    required double scaleFactor,
    required SizeAdjustmentFactor sizeAdjustment,
    double? aspectRatio,
  }) {
    // 🚨 안전장치: 비정상적으로 큰 값들을 제한
    const double maxSafeWidth = 2000.0;  // 최대 너비 2000px
    const double maxSafeHeight = 2000.0; // 최대 높이 2000px
    
    final safeContainerWidth = math.min(containerWidth, maxSafeWidth);
    final safeContainerHeight = math.min(containerHeight, maxSafeHeight);
    final safeScaleFactor = math.min(scaleFactor, 3.0); // 최대 3배 확대
    
    print('[SAFE] Container 크기 제한: ${containerWidth.toStringAsFixed(1)} → ${safeContainerWidth.toStringAsFixed(1)}');
    
    Size calculatedSize;
    
    // 1. 이미지 비율이 있으면 비율 기준으로 계산
    if (aspectRatio != null) {
      // 컨테이너에 맞는 최대 크기 계산
      double width = safeContainerWidth;
      double height = width / aspectRatio;
      
      // 높이가 컨테이너를 초과하면 높이 기준으로 재계산
      if (height > safeContainerHeight) {
        height = safeContainerHeight;
        width = height * aspectRatio;
      }
      
      // 너비가 컨테이너를 초과하면 너비 기준으로 재계산
      if (width > safeContainerWidth) {
        width = safeContainerWidth;
        height = width / aspectRatio;
      }
      
      calculatedSize = Size(width, height);
    } else {
      // 비율이 없으면 원본 크기 기준으로 스케일링
      final targetSize = Size(safeContainerWidth, safeContainerHeight);
      calculatedSize = scaleToFit(originalSize, targetSize);
    }
    
    // 2. 레이아웃 변환에 따른 크기 조정 적용
    calculatedSize = sizeAdjustment.apply(calculatedSize);
    
    // 3. 화면 크기에 따른 스케일링 팩터 적용
    calculatedSize = Size(
      calculatedSize.width * safeScaleFactor,
      calculatedSize.height * safeScaleFactor,
    );
    
    // 🚨 최종 안전장치: 계산된 크기가 여전히 너무 크면 강제로 제한
    final finalWidth = math.min(calculatedSize.width, maxSafeWidth);
    final finalHeight = math.min(calculatedSize.height, maxSafeHeight);
    
    final finalSize = Size(finalWidth, finalHeight);
    print('[SAFE] 최종 크기: ${calculatedSize.width.toStringAsFixed(1)} x ${calculatedSize.height.toStringAsFixed(1)} → ${finalSize.width.toStringAsFixed(1)} x ${finalSize.height.toStringAsFixed(1)}');
    
    return finalSize;
  }

  /// 가로 배치 전용 박스 크기 계산
  /// 
  /// 가로 배치에서는 두 박스의 크기를 통일하고, 평균 높이를 사용
  static ({Size sizeA, Size sizeB}) _calculateHorizontalLayoutBoxSize({
    required double containerWidth,
    required double containerHeight,
    double? aspectRatioA,
    double? aspectRatioB,
    required double spacing,
    required double scaleFactor,
    required SizeAdjustmentFactor sizeAdjustment,
    required bool hasImageB,
  }) {
    // 1. 동적 간격 계산 (컨테이너의 1%, 최소 4px)
    final dynamicSpacing = hasImageB 
        ? math.max(containerWidth * 0.01, 4.0)  // 두 개일 때만 간격 필요
        : 0.0;  // 단일 이미지는 간격 불필요
    
    // 2. 박스 너비 계산
    final availableWidth = containerWidth - dynamicSpacing;
    
    // 단일 이미지는 80%, 두 개 이미지는 각각 49.5% 사용 (간격 포함 99%)
    final boxWidth = hasImageB 
        ? availableWidth * 0.495  // 두 개일 때는 49.5%씩 (최대한 크게)
        : containerWidth * 0.8;  // 단일 이미지는 80% 사용 (증가)
    
    // 2. 평균 높이 계산
    final maxBoxHeight = containerHeight * 0.9; // 가로 배치에서는 높이를 화면의 90%까지 사용 (증가)
    double unifiedHeight;
    
    if (aspectRatioA != null && aspectRatioB != null && hasImageB) {
      // 두 이미지 모두 있으면 평균 높이 사용
      final heightA = boxWidth / aspectRatioA;
      final heightB = boxWidth / aspectRatioB;
      unifiedHeight = (heightA + heightB) / 2;
      
      print('[VersusBoxSizeCalculator] 가로 배치 평균 높이 계산:');
      print('  - A박스 개별 높이: ${heightA.toStringAsFixed(1)}px (비율: ${aspectRatioA.toStringAsFixed(3)})');
      print('  - B박스 개별 높이: ${heightB.toStringAsFixed(1)}px (비율: ${aspectRatioB.toStringAsFixed(3)})');
      print('  - 평균 높이: ${unifiedHeight.toStringAsFixed(1)}px');
    } else if (aspectRatioA != null) {
      // A박스만 있으면 A박스 비율 사용
      unifiedHeight = boxWidth / aspectRatioA;
    } else if (aspectRatioB != null && hasImageB) {
      // B박스만 있으면 B박스 비율 사용
      unifiedHeight = boxWidth / aspectRatioB;
    } else {
      // 비율 정보가 없으면 기본 높이 사용
      unifiedHeight = 350.0; // 기본 높이
    }
    
    // 3. 높이 제한 적용
    unifiedHeight = unifiedHeight.clamp(150.0, maxBoxHeight);
    
    // 4. 실제 사용할 간격으로 크기 재계산 (동적 간격 적용)
    final actualBoxWidth = hasImageB 
        ? (containerWidth - dynamicSpacing) * 0.495
        : containerWidth * 0.8;
    
    // 5. 크기 조정 팩터 적용
    Size sizeA = Size(actualBoxWidth, unifiedHeight);
    Size sizeB = hasImageB ? Size(actualBoxWidth, unifiedHeight) : Size.zero;
    
    sizeA = sizeAdjustment.apply(sizeA);
    if (hasImageB) {
      sizeB = sizeAdjustment.apply(sizeB);
    }
    
    // 5. 스케일링 팩터 적용
    sizeA = Size(
      sizeA.width * scaleFactor,
      sizeA.height * scaleFactor,
    );
    if (hasImageB) {
      sizeB = Size(
        sizeB.width * scaleFactor,
        sizeB.height * scaleFactor,
      );
    }
    
    print('[VersusBoxSizeCalculator] 가로 배치 통일된 크기 계산:');
    print('  - 동적 간격: ${dynamicSpacing.toStringAsFixed(1)}px');
    print('  - 박스 너비: ${actualBoxWidth.toStringAsFixed(1)}px (${hasImageB ? "49.5%" : "80%"})');
    print('  - 통일 높이: ${unifiedHeight.toStringAsFixed(1)}px');
    print('  - A박스 최종: ${sizeA.width.toStringAsFixed(1)} x ${sizeA.height.toStringAsFixed(1)}');
    if (hasImageB) {
      print('  - B박스 최종: ${sizeB.width.toStringAsFixed(1)} x ${sizeB.height.toStringAsFixed(1)}');
      print('  - 총 사용률: ${((sizeA.width * 2 + dynamicSpacing) / containerWidth * 100).toStringAsFixed(1)}%');
      print('  - 크기 일치: ${(sizeA.width - sizeB.width).abs() < 1.0 && (sizeA.height - sizeB.height).abs() < 1.0 ? "✅" : "❌"}');
    }
    
    return (sizeA: sizeA, sizeB: sizeB);
  }
  
  /// 세로 배치 전용 박스 크기 계산
  /// 
  /// 세로 배치에서는 두 박스의 너비를 통일하고, 각 이미지 비율에 맞춰 높이를 조정
  static ({Size sizeA, Size sizeB}) _calculateVerticalLayoutBoxSize({
    required double containerWidth,
    required double containerHeight,
    double? aspectRatioA,
    double? aspectRatioB,
    required double spacing,
    required double scaleFactor,
    required SizeAdjustmentFactor sizeAdjustment,
  }) {
    // 1. 통일된 너비 계산 (컨테이너의 85%)
    final unifiedWidth = containerWidth * 0.85;
    
    // 2. 각 이미지 비율에 맞춰 개별 높이 계산
    double heightA = aspectRatioA != null ? unifiedWidth / aspectRatioA : 200.0;
    double heightB = aspectRatioB != null ? unifiedWidth / aspectRatioB : 200.0;
    
    // 3. 전체 높이가 컨테이너를 초과하는지 확인
    final totalRequiredHeight = heightA + heightB + spacing;
    final maxAvailableHeight = containerHeight * 0.88; // 88%로 증가
    
    // 4. 필요시 전체 스케일링 적용
    if (totalRequiredHeight > maxAvailableHeight) {
      final scalingFactor = maxAvailableHeight / totalRequiredHeight;
      heightA *= scalingFactor;
      heightB *= scalingFactor;
      
      print('[VersusBoxSizeCalculator] 세로 배치 스케일링 적용:');
      print('  - 필요 높이: ${totalRequiredHeight.toStringAsFixed(1)}px');
      print('  - 최대 높이: ${maxAvailableHeight.toStringAsFixed(1)}px');
      print('  - 스케일링 팩터: ${(scalingFactor * 100).toStringAsFixed(1)}%');
    }
    
    // 5. 크기 조정 팩터 적용
    Size sizeA = Size(unifiedWidth, heightA);
    Size sizeB = Size(unifiedWidth, heightB);
    
    sizeA = sizeAdjustment.apply(sizeA);
    sizeB = sizeAdjustment.apply(sizeB);
    
    // 6. 스케일링 팩터 적용
    sizeA = Size(
      sizeA.width * scaleFactor,
      sizeA.height * scaleFactor,
    );
    sizeB = Size(
      sizeB.width * scaleFactor,
      sizeB.height * scaleFactor,
    );
    
    print('[VersusBoxSizeCalculator] 세로 배치 통일된 크기 계산:');
    print('  - 통일 너비: ${unifiedWidth.toStringAsFixed(1)}px');
    print('  - A박스 최종: ${sizeA.width.toStringAsFixed(1)} x ${sizeA.height.toStringAsFixed(1)}');
    print('  - B박스 최종: ${sizeB.width.toStringAsFixed(1)} x ${sizeB.height.toStringAsFixed(1)}');
    print('  - 너비 일치: ${(sizeA.width - sizeB.width).abs() < 1.0 ? "✅" : "❌"}');
    
    return (sizeA: sizeA, sizeB: sizeB);
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

