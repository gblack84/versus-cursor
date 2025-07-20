import 'package:flutter/material.dart';
import '../models/versus_box_size_data.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';

/// 질문 작성 페이지와 투표 알림 간 레이아웃 동기화 서비스
/// 
/// 다양한 레이아웃 변환 규칙을 적용하여 투표 알림에서
/// 최적의 사용자 경험을 제공합니다.
class LayoutSynchronizer {
  
  /// 투표 알림에 최적화된 레이아웃으로 변환
  /// 
  /// [originalLayout] 원본 레이아웃 타입
  /// [containerWidth] 알림 컨테이너 너비
  /// [aspectRatioA] A 이미지 비율 (nullable)
  /// [aspectRatioB] B 이미지 비율 (nullable)
  /// [hasImageA] A 이미지 존재 여부
  /// [hasImageB] B 이미지 존재 여부
  static VotingLayoutConfig optimizeForVoting({
    required LayoutType originalLayout,
    required double containerWidth,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = false,
    bool hasImageB = false,
  }) {
    
    // 1. 세로 배치 → 가로 배치 변환 (공간 절약)
    if (originalLayout == LayoutType.vertical) {
      return VotingLayoutConfig(
        layoutType: LayoutType.horizontal,
        reason: 'Vertical to horizontal for space efficiency',
        conversionRules: [
          'Original vertical layout converted to horizontal',
          'Both images displayed side by side',
          'Reduced height for notification constraint',
        ],
      );
    }
    
    // 2. 단일 이미지 → A + 빈 B박스 형태
    if (originalLayout == LayoutType.single) {
      return VotingLayoutConfig(
        layoutType: LayoutType.horizontal,
        reason: 'Single image with empty B box for voting UI',
        conversionRules: [
          'Single image placed in A box',
          'Empty B box added for voting balance',
          'Horizontal layout for consistent voting experience',
        ],
      );
    }
    
    // 3. 작은 화면에서 추가 최적화
    if (containerWidth < 350) {
      return _optimizeForSmallScreen(
        originalLayout: originalLayout,
        containerWidth: containerWidth,
        aspectRatioA: aspectRatioA,
        aspectRatioB: aspectRatioB,
        hasImageA: hasImageA,
        hasImageB: hasImageB,
      );
    }
    
    // 4. 가로 배치는 그대로 유지
    return VotingLayoutConfig(
      layoutType: LayoutType.horizontal,
      reason: 'Original horizontal layout preserved',
      conversionRules: [
        'Horizontal layout maintained',
        'Optimal for voting interaction',
        'No conversion needed',
      ],
    );
  }
  
  /// 작은 화면에서의 추가 최적화
  static VotingLayoutConfig _optimizeForSmallScreen({
    required LayoutType originalLayout,
    required double containerWidth,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = false,
    bool hasImageB = false,
  }) {
    
    // 극도로 세로형 이미지들의 경우 세로 배치 유지 고려
    if (aspectRatioA != null && aspectRatioB != null) {
      final orientationA = AspectRatioAnalyzer.getOrientation(aspectRatioA);
      final orientationB = AspectRatioAnalyzer.getOrientation(aspectRatioB);
      
      // 둘 다 극도로 세로형 (비율 < 0.5)이면 세로 배치가 더 나을 수 있음
      if (aspectRatioA < 0.5 && aspectRatioB < 0.5 && 
          orientationA == ImageOrientation.portrait && 
          orientationB == ImageOrientation.portrait) {
        return VotingLayoutConfig(
          layoutType: LayoutType.vertical,
          reason: 'Extreme portrait images better in vertical on small screen',
          conversionRules: [
            'Both images are extremely tall (ratio < 0.5)',
            'Vertical layout provides better visibility',
            'Small screen optimization applied',
          ],
        );
      }
    }
    
    // 기본적으로는 가로 배치 (투표 UI의 일관성을 위해)
    return VotingLayoutConfig(
      layoutType: LayoutType.horizontal,
      reason: 'Small screen with horizontal layout for voting consistency',
      conversionRules: [
        'Small screen detected (< 350px)',
        'Horizontal layout for voting consistency',
        'Compact sizing applied',
      ],
    );
  }
  
  /// 레이아웃 변환 시 크기 조정 팩터 계산
  /// 
  /// [originalLayout] 원본 레이아웃
  /// [targetLayout] 변환될 레이아웃
  /// [originalSize] 원본 크기
  static SizeAdjustmentFactor calculateSizeAdjustment({
    required LayoutType originalLayout,
    required LayoutType targetLayout,
    required Size originalSize,
  }) {
    
    // 세로 → 가로 변환
    if (originalLayout == LayoutType.vertical && targetLayout == LayoutType.horizontal) {
      return SizeAdjustmentFactor(
        widthFactor: 0.8,  // 가로 80% 축소
        heightFactor: 0.7, // 세로 70% 축소 (공간 절약)
        reason: 'Vertical to horizontal conversion requires size reduction',
      );
    }
    
    // 단일 → 가로 변환
    if (originalLayout == LayoutType.single && targetLayout == LayoutType.horizontal) {
      return SizeAdjustmentFactor(
        widthFactor: 0.9,  // 가로 90% (B박스 공간 확보)
        heightFactor: 1.0, // 세로 유지
        reason: 'Single to horizontal conversion needs width adjustment',
      );
    }
    
    // 가로 → 가로 (변환 없음)
    if (originalLayout == LayoutType.horizontal && targetLayout == LayoutType.horizontal) {
      return SizeAdjustmentFactor(
        widthFactor: 1.0,
        heightFactor: 1.0,
        reason: 'No layout conversion, size maintained',
      );
    }
    
    // 기타 경우 기본값
    return SizeAdjustmentFactor(
      widthFactor: 0.85,
      heightFactor: 0.85,
      reason: 'Default size adjustment for layout conversion',
    );
  }
  
  /// 투표 알림에서 사용할 최적 간격 계산
  /// 
  /// [layoutType] 레이아웃 타입
  /// [containerWidth] 컨테이너 너비
  /// [boxCount] 박스 개수 (1 또는 2)
  static VotingSpacing calculateOptimalSpacing({
    required LayoutType layoutType,
    required double containerWidth,
    int boxCount = 2,
  }) {
    
    if (layoutType == LayoutType.horizontal) {
      // 가로 배치
      double spacing;
      if (containerWidth > 350) {
        spacing = 12.0; // 큰 화면: 여유 있는 간격
      } else if (containerWidth > 300) {
        spacing = 8.0;  // 중간 화면: 적당한 간격
      } else {
        spacing = 4.0;  // 작은 화면: 최소 간격
      }
      
      return VotingSpacing(
        horizontal: spacing,
        vertical: 0,
        reason: 'Horizontal layout spacing based on screen width',
      );
      
    } else {
      // 세로 배치
      double spacing;
      if (containerWidth > 350) {
        spacing = 16.0; // 큰 화면: 여유 있는 세로 간격
      } else {
        spacing = 12.0; // 작은 화면: 축소된 세로 간격
      }
      
      return VotingSpacing(
        horizontal: 0,
        vertical: spacing,
        reason: 'Vertical layout spacing for readability',
      );
    }
  }
  
  /// 변환 규칙 유효성 검사
  /// 
  /// [sizeData] 원본 사이즈 데이터
  /// [targetLayout] 목표 레이아웃
  /// [containerConstraints] 컨테이너 제약 조건
  static ValidationResult validateConversion({
    required VersusBoxSizeData sizeData,
    required LayoutType targetLayout,
    required BoxConstraints containerConstraints,
  }) {
    
    final errors = <String>[];
    final warnings = <String>[];
    
    // 1. 최소 크기 검사
    if (containerConstraints.maxWidth < 200) {
      errors.add('Container width too small for voting UI (${containerConstraints.maxWidth}px < 200px)');
    }
    
    if (containerConstraints.maxHeight < 80) {
      errors.add('Container height too small for voting UI (${containerConstraints.maxHeight}px < 80px)');
    }
    
    // 2. 이미지 비율 검사
    if (sizeData.aspectRatioA != null && sizeData.aspectRatioA! < 0.1) {
      warnings.add('A image extremely tall (ratio: ${sizeData.aspectRatioA}), may not display well');
    }
    
    if (sizeData.aspectRatioB != null && sizeData.aspectRatioB! < 0.1) {
      warnings.add('B image extremely tall (ratio: ${sizeData.aspectRatioB}), may not display well');
    }
    
    // 3. 레이아웃 변환 적합성 검사
    if (sizeData.layoutType == LayoutType.vertical && targetLayout == LayoutType.horizontal) {
      if (containerConstraints.maxWidth < 300) {
        warnings.add('Converting vertical to horizontal on narrow container may cause crowding');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// 디버그용 변환 정보 출력
  static void printConversionInfo({
    required VersusBoxSizeData originalData,
    required VotingLayoutConfig targetConfig,
    required double containerWidth,
  }) {
    print('\n[LayoutSynchronizer] Conversion Info:');
    print('  Original Layout: ${originalData.layoutType}');
    print('  Target Layout: ${targetConfig.layoutType}');
    print('  Container Width: ${containerWidth.toStringAsFixed(1)}px');
    print('  Conversion Reason: ${targetConfig.reason}');
    print('  Rules Applied:');
    for (int i = 0; i < targetConfig.conversionRules.length; i++) {
      print('    ${i + 1}. ${targetConfig.conversionRules[i]}');
    }
    print('  Images: A=${originalData.hasImageA} B=${originalData.hasImageB}');
    if (originalData.aspectRatioA != null) {
      print('  Aspect Ratio A: ${originalData.aspectRatioA!.toStringAsFixed(2)}');
    }
    if (originalData.aspectRatioB != null) {
      print('  Aspect Ratio B: ${originalData.aspectRatioB!.toStringAsFixed(2)}');
    }
  }
}

/// 투표 알림용 레이아웃 설정 (확장된 버전)
class VotingLayoutConfig {
  final LayoutType layoutType;
  final String reason;
  final List<String> conversionRules;
  
  const VotingLayoutConfig({
    required this.layoutType,
    required this.reason,
    this.conversionRules = const [],
  });
  
  @override
  String toString() {
    return 'VotingLayoutConfig(type: $layoutType, reason: $reason, rules: ${conversionRules.length})';
  }
}

/// 크기 조정 팩터
class SizeAdjustmentFactor {
  final double widthFactor;
  final double heightFactor;
  final String reason;
  
  const SizeAdjustmentFactor({
    required this.widthFactor,
    required this.heightFactor,
    required this.reason,
  });
  
  /// 크기에 팩터 적용
  Size apply(Size originalSize) {
    return Size(
      originalSize.width * widthFactor,
      originalSize.height * heightFactor,
    );
  }
  
  @override
  String toString() {
    return 'SizeAdjustmentFactor(w: ${widthFactor.toStringAsFixed(2)}, h: ${heightFactor.toStringAsFixed(2)})';
  }
}

/// 투표 알림용 간격 설정
class VotingSpacing {
  final double horizontal;
  final double vertical;
  final String reason;
  
  const VotingSpacing({
    required this.horizontal,
    required this.vertical,
    required this.reason,
  });
  
  /// EdgeInsets로 변환
  EdgeInsets get asEdgeInsets => EdgeInsets.symmetric(
    horizontal: horizontal,
    vertical: vertical,
  );
  
  @override
  String toString() {
    return 'VotingSpacing(h: $horizontal, v: $vertical)';
  }
}

/// 변환 유효성 검사 결과
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  
  /// 경고가 있는지 확인
  bool get hasWarnings => warnings.isNotEmpty;
  
  /// 전체 메시지 수
  int get totalMessageCount => errors.length + warnings.length;
  
  @override
  String toString() {
    return 'ValidationResult(valid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
  }
}