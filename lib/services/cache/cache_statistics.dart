import 'package:flutter/foundation.dart';

/// 캐시 통계 및 성능 모니터링
class CacheStatistics {
  // 싱글톤 인스턴스
  static final CacheStatistics _instance = CacheStatistics._internal();
  static CacheStatistics get instance => _instance;

  CacheStatistics._internal();

  // 전체 통계
  int _totalRequests = 0;
  int _totalHits = 0;

  // 레이어별 통계
  int _l1Hits = 0; // Memory hits
  int _l2Hits = 0; // Hive hits
  int _l3Hits = 0; // Firestore cache hits
  int _networkHits = 0; // Network fetches

  // 응답 시간 추적
  final List<int> _responseTimes = []; // in milliseconds
  static const int _maxResponseTimeHistory = 100;

  // Firestore 읽기 절약
  int _firestoreSavedReads = 0;

  // 캐시 요청 기록
  void recordRequest() {
    _totalRequests++;
  }

  // L1 히트 기록
  void recordL1Hit({int? responseTimeMs}) {
    _totalHits++;
    _l1Hits++;
    _firestoreSavedReads++;
    if (responseTimeMs != null) {
      _addResponseTime(responseTimeMs);
    }
  }

  // L2 히트 기록
  void recordL2Hit({int? responseTimeMs}) {
    _totalHits++;
    _l2Hits++;
    _firestoreSavedReads++;
    if (responseTimeMs != null) {
      _addResponseTime(responseTimeMs);
    }
  }

  // L3 히트 기록
  void recordL3Hit({int? responseTimeMs}) {
    _totalHits++;
    _l3Hits++;
    // Firestore 오프라인 캐시도 읽기 절약으로 계산
    _firestoreSavedReads++;
    if (responseTimeMs != null) {
      _addResponseTime(responseTimeMs);
    }
  }

  // 네트워크 히트 기록
  void recordNetworkHit({int? responseTimeMs}) {
    _networkHits++;
    if (responseTimeMs != null) {
      _addResponseTime(responseTimeMs);
    }
  }

  // 응답 시간 추가
  void _addResponseTime(int responseTimeMs) {
    _responseTimes.add(responseTimeMs);
    if (_responseTimes.length > _maxResponseTimeHistory) {
      _responseTimes.removeAt(0);
    }
  }

  // === Getters ===

  // 전체 히트율
  double get overallHitRate =>
      _totalRequests == 0 ? 0 : _totalHits / _totalRequests;

  // L1 히트율
  double get l1HitRate => _totalRequests == 0 ? 0 : _l1Hits / _totalRequests;

  // L2 히트율
  double get l2HitRate => _totalRequests == 0 ? 0 : _l2Hits / _totalRequests;

  // L3 히트율
  double get l3HitRate => _totalRequests == 0 ? 0 : _l3Hits / _totalRequests;

  // 네트워크 히트율
  double get networkHitRate =>
      _totalRequests == 0 ? 0 : _networkHits / _totalRequests;

  // 평균 응답 시간
  double get averageResponseTime {
    if (_responseTimes.isEmpty) return 0;
    final sum = _responseTimes.reduce((a, b) => a + b);
    return sum / _responseTimes.length;
  }

  // 최소 응답 시간
  int get minResponseTime => _responseTimes.isEmpty
      ? 0
      : _responseTimes.reduce((a, b) => a < b ? a : b);

  // 최대 응답 시간
  int get maxResponseTime => _responseTimes.isEmpty
      ? 0
      : _responseTimes.reduce((a, b) => a > b ? a : b);

  // Firestore 절약 비용 (읽기당 $0.06/100,000 documents 기준)
  double get estimatedCostSavings {
    const costPer100k = 0.06; // USD
    return (_firestoreSavedReads / 100000) * costPer100k;
  }

  // 통계 리셋
  void reset() {
    _totalRequests = 0;
    _totalHits = 0;
    _l1Hits = 0;
    _l2Hits = 0;
    _l3Hits = 0;
    _networkHits = 0;
    _responseTimes.clear();
    _firestoreSavedReads = 0;
  }

  // 통계 요약 출력
  String getSummary() {
    return '''
╔════════════════════════════════════════════════════╗
║              CACHE STATISTICS SUMMARY              ║
╠════════════════════════════════════════════════════╣
║ Total Requests: $_totalRequests
║ Total Hits: $_totalHits (${(overallHitRate * 100).toStringAsFixed(1)}%)
╠────────────────────────────────────────────────────╣
║ Layer Performance:
║   L1 Memory:    $_l1Hits hits (${(l1HitRate * 100).toStringAsFixed(1)}%)
║   L2 Hive:      $_l2Hits hits (${(l2HitRate * 100).toStringAsFixed(1)}%)
║   L3 Firestore: $_l3Hits hits (${(l3HitRate * 100).toStringAsFixed(1)}%)
║   Network:      $_networkHits fetches (${(networkHitRate * 100).toStringAsFixed(1)}%)
╠────────────────────────────────────────────────────╣
║ Response Times:
║   Average: ${averageResponseTime.toStringAsFixed(2)}ms
║   Min: ${minResponseTime}ms
║   Max: ${maxResponseTime}ms
╠────────────────────────────────────────────────────╣
║ Cost Savings:
║   Firestore Reads Saved: $_firestoreSavedReads
║   Estimated Savings: \$${estimatedCostSavings.toStringAsFixed(4)}
╚════════════════════════════════════════════════════╝
''';
  }

  // 디버그 모드에서 자동 출력
  void logStatistics() {
    if (kDebugMode) {
      debugPrint(getSummary());
    }
  }
}
