import 'dart:math' as math;
import '/features/posts/presentation/utils/debug_helper.dart';

/// 이미지 비율 계산을 위한 헬퍼 클래스
class RatioCalculator {
  // 캐싱을 위한 변수들
  static List<double>? _lastRatiosA;
  static List<double>? _lastRatiosB;
  static double? _lastResultA;
  static double? _lastResultB;
  
  /// 여러 이미지의 대표 비율을 계산하는 메서드
  /// 
  /// 하이브리드 방식:
  /// 1. 비율 차이가 크면 (>0.5): 가장 세로 이미지 기준
  /// 2. 비율이 비슷하면: 평균 비율 사용
  static double calculateRepresentativeRatio(List<double> ratios, {bool enableLog = true}) {
    // 빈 배열 처리
    if (ratios.isEmpty) {
      if (enableLog) DebugHelper.logLayout('[RatioCalc] 비율 배열이 비어있음 - 기본값 1.0 반환');
      return 1.0;
    }
    
    // 단일 이미지는 그대로 반환
    if (ratios.length == 1) {
      if (enableLog) DebugHelper.logLayout('[RatioCalc] 단일 이미지 - 비율: ${ratios.first}');
      return ratios.first;
    }
    
    // 최소/최대 비율 계산
    final minRatio = ratios.reduce(math.min);
    final maxRatio = ratios.reduce(math.max);
    final difference = maxRatio - minRatio;
    
    if (enableLog) {
      DebugHelper.logLayout('[RatioCalc] 비율 분석:');
      DebugHelper.logLayout('  - 이미지 개수: ${ratios.length}');
      DebugHelper.logLayout('  - 비율들: ${ratios.map((r) => r.toStringAsFixed(3)).join(', ')}');
      DebugHelper.logLayout('  - 최소 비율: ${minRatio.toStringAsFixed(3)} (가장 세로)');
      DebugHelper.logLayout('  - 최대 비율: ${maxRatio.toStringAsFixed(3)} (가장 가로)');
      DebugHelper.logLayout('  - 차이: ${difference.toStringAsFixed(3)}');
    }
    
    // 극단적 차이가 있으면 가장 세로 이미지 기준
    if (difference > 0.5) {
      if (enableLog) DebugHelper.logLayout('[RatioCalc] 극단적 차이 감지 - 최소 비율 사용: ${minRatio.toStringAsFixed(3)}');
      return minRatio;
    }
    
    // 비슷한 비율이면 평균 사용
    final average = ratios.reduce((a, b) => a + b) / ratios.length;
    if (enableLog) DebugHelper.logLayout('[RatioCalc] 비슷한 비율 - 평균 사용: ${average.toStringAsFixed(3)}');
    
    return average;
  }
  
  
  /// 비율 계산 (레거시 모드 지원)
  static double getRatio(List<double> ratios, {String box = ''}) {
    // 캐싱 체크
    if (box == 'A') {
      if (_lastRatiosA != null && 
          _lastRatiosA!.length == ratios.length &&
          _listEquals(_lastRatiosA!, ratios) &&
          _lastResultA != null) {
        // 캐시된 값 반환 (로그 없음)
        return _lastResultA!;
      }
    } else if (box == 'B') {
      if (_lastRatiosB != null && 
          _lastRatiosB!.length == ratios.length &&
          _listEquals(_lastRatiosB!, ratios) &&
          _lastResultB != null) {
        // 캐시된 값 반환 (로그 없음)
        return _lastResultB!;
      }
    }
    
    // 계산 수행
    final result = calculateRepresentativeRatio(ratios, enableLog: true);
    
    // 캐시 업데이트
    if (box == 'A') {
      _lastRatiosA = List<double>.from(ratios);
      _lastResultA = result;
    } else if (box == 'B') {
      _lastRatiosB = List<double>.from(ratios);
      _lastResultB = result;
    }
    
    return result;
  }
  
  /// 두 리스트가 같은지 비교
  static bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.0001) return false;
    }
    return true;
  }
}