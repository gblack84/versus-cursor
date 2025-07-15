import 'dart:math' as math;

/// 이미지 비율 계산을 위한 헬퍼 클래스
class RatioCalculator {
  /// 여러 이미지의 대표 비율을 계산하는 메서드
  /// 
  /// 하이브리드 방식:
  /// 1. 비율 차이가 크면 (>0.5): 가장 세로 이미지 기준
  /// 2. 비율이 비슷하면: 평균 비율 사용
  static double calculateRepresentativeRatio(List<double> ratios) {
    // 빈 배열 처리
    if (ratios.isEmpty) {
      print('[RatioCalc] 비율 배열이 비어있음 - 기본값 1.0 반환');
      return 1.0;
    }
    
    // 단일 이미지는 그대로 반환
    if (ratios.length == 1) {
      print('[RatioCalc] 단일 이미지 - 비율: ${ratios.first}');
      return ratios.first;
    }
    
    // 최소/최대 비율 계산
    final minRatio = ratios.reduce(math.min);
    final maxRatio = ratios.reduce(math.max);
    final difference = maxRatio - minRatio;
    
    print('[RatioCalc] 비율 분석:');
    print('  - 이미지 개수: ${ratios.length}');
    print('  - 비율들: ${ratios.map((r) => r.toStringAsFixed(3)).join(', ')}');
    print('  - 최소 비율: ${minRatio.toStringAsFixed(3)} (가장 세로)');
    print('  - 최대 비율: ${maxRatio.toStringAsFixed(3)} (가장 가로)');
    print('  - 차이: ${difference.toStringAsFixed(3)}');
    
    // 극단적 차이가 있으면 가장 세로 이미지 기준
    if (difference > 0.5) {
      print('[RatioCalc] 극단적 차이 감지 - 최소 비율 사용: ${minRatio.toStringAsFixed(3)}');
      return minRatio;
    }
    
    // 비슷한 비율이면 평균 사용
    final average = ratios.reduce((a, b) => a + b) / ratios.length;
    print('[RatioCalc] 비슷한 비율 - 평균 사용: ${average.toStringAsFixed(3)}');
    
    return average;
  }
  
  /// 레거시 모드 플래그 (테스트용)
  static bool useLegacyMode = false;
  
  /// 비율 계산 (레거시 모드 지원)
  static double getRatio(List<double> ratios) {
    if (useLegacyMode && ratios.isNotEmpty) {
      print('[RatioCalc] 레거시 모드 - 첫 번째 비율 사용: ${ratios.first}');
      return ratios.first;
    }
    return calculateRepresentativeRatio(ratios);
  }
}