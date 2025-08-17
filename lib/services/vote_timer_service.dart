import 'dart:async';
import 'package:flutter/foundation.dart';

/// 투표 타이머 동기화 서비스
/// 
/// 모든 투표 카드 위젯이 동일한 남은 시간을 표시하도록
/// postId별로 단일 Timer를 관리하는 싱글톤 서비스
class VoteTimerService extends ChangeNotifier {
  // 싱글톤 인스턴스
  static final VoteTimerService _instance = VoteTimerService._internal();
  factory VoteTimerService() => _instance;
  VoteTimerService._internal();
  
  // postId별 Stream Controller 관리
  final Map<String, StreamController<Duration>> _streamControllers = {};
  
  // postId별 Timer 관리 (자동 정리를 위해)
  final Map<String, Timer> _timers = {};
  
  // postId별 마지막 남은 시간 캐시 (즉시 표시용)
  final Map<String, Duration> _lastRemainingTimes = {};
  
  // 활성 리스너 수 추적 (메모리 관리용)
  final Map<String, int> _listenerCounts = {};
  
  /// 특정 투표의 남은 시간 Stream 가져오기
  /// 
  /// 이미 존재하는 Stream이 있으면 재사용하고,
  /// 없으면 새로 생성하여 반환
  Stream<Duration> getRemainingTimeStream(String postId, DateTime voteEndTime) {
    // 이미 Stream이 존재하면 재사용
    if (_streamControllers.containsKey(postId)) {
      _incrementListenerCount(postId);
      return _streamControllers[postId]!.stream;
    }
    
    // 새 Stream 생성
    _createTimerStream(postId, voteEndTime);
    _incrementListenerCount(postId);
    return _streamControllers[postId]!.stream;
  }
  
  /// 캐시된 마지막 남은 시간 즉시 가져오기
  /// 
  /// Stream 구독 전에 즉시 표시할 값이 필요한 경우 사용
  Duration? getCachedRemainingTime(String postId) {
    return _lastRemainingTimes[postId];
  }
  
  /// 특정 투표의 Timer Stream 생성
  void _createTimerStream(String postId, DateTime voteEndTime) {
    // Broadcast Stream Controller 생성
    final controller = StreamController<Duration>.broadcast(
      onCancel: () => _handleStreamCancel(postId),
    );
    _streamControllers[postId] = controller;
    
    // 초기 남은 시간 계산
    final now = DateTime.now();
    final initialRemaining = voteEndTime.difference(now);
    
    // 이미 만료된 경우
    if (initialRemaining.isNegative) {
      _lastRemainingTimes[postId] = Duration.zero;
      controller.add(Duration.zero);
      _cleanup(postId);
      return;
    }
    
    // 초기값 캐시 및 전송
    _lastRemainingTimes[postId] = initialRemaining;
    controller.add(initialRemaining);
    
    // 1초마다 업데이트하는 Timer 생성
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = voteEndTime.difference(now);
      
      if (remaining.isNegative || remaining.inSeconds <= 0) {
        // 타이머 만료
        _lastRemainingTimes[postId] = Duration.zero;
        if (!controller.isClosed) {
          controller.add(Duration.zero);
        }
        timer.cancel();
        _cleanup(postId);
      } else {
        // 남은 시간 업데이트
        _lastRemainingTimes[postId] = remaining;
        if (!controller.isClosed) {
          controller.add(remaining);
        }
      }
    });
    
    _timers[postId] = timer;
    
    if (kDebugMode) {
      print('[VoteTimerService] Timer created for postId: $postId');
      print('[VoteTimerService] Initial remaining time: ${initialRemaining.inSeconds} seconds');
    }
  }
  
  /// 리스너 수 증가
  void _incrementListenerCount(String postId) {
    _listenerCounts[postId] = (_listenerCounts[postId] ?? 0) + 1;
    
    if (kDebugMode) {
      print('[VoteTimerService] Listener added for $postId. Total: ${_listenerCounts[postId]}');
    }
  }
  
  /// 리스너 수 감소
  void _decrementListenerCount(String postId) {
    if (_listenerCounts.containsKey(postId)) {
      _listenerCounts[postId] = _listenerCounts[postId]! - 1;
      
      if (kDebugMode) {
        print('[VoteTimerService] Listener removed for $postId. Remaining: ${_listenerCounts[postId]}');
      }
      
      // 모든 리스너가 해제되면 정리
      if (_listenerCounts[postId]! <= 0) {
        _cleanup(postId);
      }
    }
  }
  
  /// Stream 취소 핸들러
  void _handleStreamCancel(String postId) {
    _decrementListenerCount(postId);
  }
  
  /// 특정 투표의 Timer 및 관련 리소스 정리
  void _cleanup(String postId) {
    if (kDebugMode) {
      print('[VoteTimerService] Cleaning up resources for postId: $postId');
    }
    
    // Timer 정리
    _timers[postId]?.cancel();
    _timers.remove(postId);
    
    // Stream Controller 정리
    _streamControllers[postId]?.close();
    _streamControllers.remove(postId);
    
    // 캐시 정리 (선택적 - 일정 시간 유지할 수도 있음)
    Future.delayed(const Duration(minutes: 1), () {
      _lastRemainingTimes.remove(postId);
    });
    
    // 리스너 카운트 정리
    _listenerCounts.remove(postId);
    
    notifyListeners();
  }
  
  /// 모든 Timer 정리 (앱 종료 시)
  void disposeAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    
    _lastRemainingTimes.clear();
    _listenerCounts.clear();
    
    if (kDebugMode) {
      print('[VoteTimerService] All timers and resources disposed');
    }
  }
  
  /// 현재 활성 Timer 수 (디버깅용)
  int get activeTimerCount => _timers.length;
  
  /// 현재 활성 Stream 수 (디버깅용)
  int get activeStreamCount => _streamControllers.length;
}