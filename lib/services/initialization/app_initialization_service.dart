import 'package:flutter/foundation.dart';
import '/services/cache/preload_strategy.dart';

/// 앱 초기화 서비스
///
/// **책임**:
/// - 사용자 로그인 시 백그라운드 프리로드 실행
/// - 병렬 프리로드로 초기화 시간 단축
/// - 개별 에러 허용 (하나 실패해도 나머지 성공)
///
/// **Phase B-3 개선** (2025-11-11):
/// - app.dart의 Presentation 레이어에서 서비스 레이어로 이동
/// - 순차 실행 → 병렬 실행 (Future.wait)
/// - 초기화 통계 제공 (성공/실패 건수)
class AppInitializationService {
  final PreloadStrategy _preloadStrategy;

  AppInitializationService({
    PreloadStrategy? preloadStrategy,
  }) : _preloadStrategy = preloadStrategy ?? PreloadStrategy();

  /// 앱 초기화 수행
  ///
  /// **병렬 프리로드**:
  /// - 채팅 프리로드 (최근 10개 채팅 + 메시지)
  /// - 홈 피드 프리로드 (최근 20개 게시물)
  ///
  /// **에러 허용**:
  /// - 하나 실패해도 나머지 계속 진행
  /// - 통계로 성공/실패 건수 확인
  ///
  /// **파라미터**:
  /// - `userId`: 프리로드 대상 사용자 ID
  ///
  /// **반환값**:
  /// - `InitializationResult`: 성공/실패 건수 포함
  Future<InitializationResult> initialize(String userId) async {
    // UI 렌더링 완료 대기 (500ms)
    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('[AppInitialization] 프리로드 시작: $userId');

    // 병렬 프리로드 실행
    final results = await Future.wait([
      _preloadChats(userId),
      _preloadHomeFeed(),
    ]);

    final result = InitializationResult(
      successCount: results.where((r) => r).length,
      failureCount: results.where((r) => !r).length,
    );

    if (result.isSuccess) {
      debugPrint('[AppInitialization] 프리로드 완료: '
          '성공 ${result.successCount}개, 실패 ${result.failureCount}개');
    } else {
      debugPrint('[AppInitialization] 프리로드 전체 실패');
    }

    return result;
  }

  /// 채팅 프리로드 (최근 10개 채팅 + 메시지)
  ///
  /// **에러 처리**: 실패해도 false 반환, 다른 프리로드는 계속
  Future<bool> _preloadChats(String userId) async {
    try {
      await _preloadStrategy.preloadRecentChats(userId);
      debugPrint('[AppInitialization] 채팅 프리로드 성공');
      return true;
    } catch (e) {
      debugPrint('[AppInitialization] 채팅 프리로드 실패: $e');
      return false;
    }
  }

  /// 홈 피드 프리로드 (최근 20개 게시물)
  ///
  /// **에러 처리**: 실패해도 false 반환, 다른 프리로드는 계속
  Future<bool> _preloadHomeFeed() async {
    try {
      await _preloadStrategy.preloadHomeFeedPosts();
      debugPrint('[AppInitialization] 홈 피드 프리로드 성공');
      return true;
    } catch (e) {
      debugPrint('[AppInitialization] 홈 피드 프리로드 실패: $e');
      return false;
    }
  }

  /// 프리로드 추적 초기화 (로그아웃 시 호출)
  void clearTracking() {
    _preloadStrategy.clearPreloadTracking();
    debugPrint('[AppInitialization] 프리로드 추적 초기화 완료');
  }

  /// 프리로드 통계 조회
  Map<String, dynamic> getStats() {
    return _preloadStrategy.getPreloadStats();
  }
}

/// 초기화 결과
///
/// **프로퍼티**:
/// - `successCount`: 성공한 프리로드 작업 수 (0-2)
/// - `failureCount`: 실패한 프리로드 작업 수 (0-2)
class InitializationResult {
  /// 성공한 작업 수
  final int successCount;

  /// 실패한 작업 수
  final int failureCount;

  const InitializationResult({
    required this.successCount,
    required this.failureCount,
  });

  /// 하나라도 성공했는지 여부
  bool get isSuccess => successCount > 0;

  /// 실패한 작업이 있는지 여부
  bool get hasFailures => failureCount > 0;

  /// 전체 작업이 성공했는지 여부
  bool get isFullSuccess => successCount == 2 && failureCount == 0;

  @override
  String toString() {
    return 'InitializationResult(success: $successCount, failure: $failureCount)';
  }
}
